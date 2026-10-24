import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:proxmox_dart_api_client/proxmox_dart_api_client.dart';
import 'package:pve_flutter_frontend/l10n/app_localizations.dart';
import 'package:pve_flutter_frontend/utils/utils.dart';
import 'package:pve_flutter_frontend/widgets/pve_app_bar.dart';

class PveGuestSnapshotWidget extends StatefulWidget {
  final ProxmoxApiClient apiClient;
  final String nodeID;
  final String guestID;
  final String guestType; // 'qemu' or 'lxc'

  const PveGuestSnapshotWidget({
    super.key,
    required this.apiClient,
    required this.nodeID,
    required this.guestID,
    required this.guestType,
  });

  @override
  State<PveGuestSnapshotWidget> createState() => _PveGuestSnapshotWidgetState();
}

class _PveGuestSnapshotWidgetState extends State<PveGuestSnapshotWidget> {
  List<PveGuestSnapshotModel>? _snapshots;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await widget.apiClient
          .getGuestSnapshots(widget.nodeID, widget.guestType, widget.guestID);
      // 'current' is a pseudo entry rendered by the web UI as "You are here"
      list.removeWhere((s) => s.name == 'current');
      if (mounted) {
        setState(() {
          _snapshots = list;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _snapshots = [];
        });
        _showError();
      }
    }
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context).actionFailed),
      backgroundColor: Theme.of(context).colorScheme.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final list = _snapshots;
    return Scaffold(
      appBar: PveAppBar(
        title: Text(loc.snapshotGuestid(widget.guestID)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: list == null
            ? const Center(child: CircularProgressIndicator())
            : list.isEmpty
                ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(child: Text(loc.noSnapshots)),
                      )
                    ],
                  )
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final snap = list[index];
                      return Card(
                        child: ListTile(
                          leading: FaIcon(
                            FontAwesomeIcons.camera,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          title: Text(snap.name),
                          subtitle: Text(_subtitle(snap)),
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) =>
                                _onAction(action, snap.name),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'rollback',
                                child: Text(loc.rollback),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(loc.remove),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_a_photo),
        label: Text(loc.takeSnapshot),
        onPressed: _showCreateDialog,
      ),
    );
  }

  String _subtitle(PveGuestSnapshotModel snap) {
    final loc = AppLocalizations.of(context);
    final parts = <String>[
      if (snap.snapDateTime != null) _formatDateTime(snap.snapDateTime!),
      if (snap.vmstate) loc.withRamState,
      if (snap.description != null && snap.description!.isNotEmpty)
        snap.description!,
    ];
    return parts.isEmpty ? snap.name : parts.join(' · ');
  }

  String _formatDateTime(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  Future<void> _onAction(String action, String snapname) async {
    final loc = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.attention),
        content: Text(action == 'rollback'
            ? loc.rollbackSnapshotConfirm(snapname)
            : loc.deleteSnapshotConfirm(snapname)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(loc.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final upid = action == 'rollback'
          ? await widget.apiClient.rollbackGuestSnapshot(
              widget.nodeID, widget.guestType, widget.guestID, snapname)
          : await widget.apiClient.deleteGuestSnapshot(
              widget.nodeID, widget.guestType, widget.guestID, snapname);
      if (!mounted) return;
      if (upid != null) {
        await showTaskLogBottomSheet(
          context,
          widget.apiClient,
          widget.nodeID,
          upid,
          jobTitle: Text(snapname),
        );
      }
      _load();
    } on ProxmoxApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    } catch (e) {
      if (mounted) _showError();
    }
  }

  Future<void> _showCreateDialog() async {
    final loc = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final descController = TextEditingController();
    var includeRam = false;
    final formKey = GlobalKey<FormState>();
    final isQemu = widget.guestType == 'qemu';

    final create = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(loc.takeSnapshot),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(labelText: loc.snapshotName),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return loc.snapshotNameRequired;
                    }
                    if (!RegExp(r'^[A-Za-z0-9_\-]+$').hasMatch(value)) {
                      return loc.snapshotNameInvalid;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: descController,
                  decoration: InputDecoration(labelText: loc.description),
                ),
                if (isQemu)
                  CheckboxListTile(
                    value: includeRam,
                    contentPadding: EdgeInsets.zero,
                    title: Text(loc.includeRamState),
                    onChanged: (v) =>
                        setDialogState(() => includeRam = v ?? false),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
              child: Text(loc.confirm),
            ),
          ],
        ),
      ),
    );
    if (create != true) return;
    try {
      final upid = await widget.apiClient.createGuestSnapshot(
        widget.nodeID,
        widget.guestType,
        widget.guestID,
        nameController.text.trim(),
        description: descController.text.trim(),
        vmstate: isQemu && includeRam,
      );
      if (!mounted) return;
      if (upid != null) {
        await showTaskLogBottomSheet(
          context,
          widget.apiClient,
          widget.nodeID,
          upid,
          icon: const Icon(Icons.add_a_photo),
          jobTitle: Text(nameController.text.trim()),
        );
      }
      _load();
    } on ProxmoxApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    } catch (e) {
      if (mounted) _showError();
    }
  }
}
