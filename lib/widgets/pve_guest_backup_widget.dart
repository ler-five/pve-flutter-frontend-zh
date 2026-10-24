import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:proxmox_dart_api_client/proxmox_dart_api_client.dart';
import 'package:pve_flutter_frontend/bloc/pve_file_selector_bloc.dart';
import 'package:pve_flutter_frontend/bloc/pve_storage_selector_bloc.dart';
import 'package:pve_flutter_frontend/states/pve_file_selector_state.dart';
import 'package:pve_flutter_frontend/states/pve_storage_selector_state.dart';
import 'package:pve_flutter_frontend/utils/renderers.dart';
import 'package:pve_flutter_frontend/utils/utils.dart';
import 'package:pve_flutter_frontend/utils/validators.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_stream_builder_widget.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_stream_listener.dart';
import 'package:pve_flutter_frontend/widgets/pve_app_bar.dart';
import 'package:pve_flutter_frontend/widgets/pve_file_selector_widget.dart';
import 'package:pve_flutter_frontend/widgets/pve_storage_selector_widget.dart';
import 'package:pve_flutter_frontend/l10n/app_localizations.dart';

class PveGuestBackupWidget extends StatelessWidget {
  final String guestID;

  const PveGuestBackupWidget({super.key, required this.guestID});

  @override
  Widget build(BuildContext context) {
    final sBloc = Provider.of<PveStorageSelectorBloc>(context);
    final fBloc = Provider.of<PveFileSelectorBloc>(context);
    return Scaffold(
      appBar: PveAppBar(
        title: Text(AppLocalizations.of(context).backupGuestid(guestID)),
      ),
      body: Column(
        children: [
          StreamListener<PveStorageSelectorState>(
            stream: sBloc.state,
            onStateChange: (storageSelectorState) {
              fBloc.events
                  .add(ChangeStorage(storageSelectorState.selected?.id));
            },
            child: SizedBox(
              height: 170,
              child: ProxmoxStreamBuilder<PveStorageSelectorBloc,
                      PveStorageSelectorState>(
                  bloc: sBloc,
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (state.storages.length > 1) {
                      return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.storages.length,
                          itemBuilder: (context, index) {
                            var storage = state.storages[index];
                            var isSelected = storage.id == state.selected?.id;
                            var storageIcon =
                                Renderers.getStorageIcon(storage.type);
                            return PveStorageCard(
                              isSelected: isSelected,
                              sBloc: sBloc,
                              storage: storage,
                              storageIcon: PveStorageCardIcon(
                                icon: storageIcon,
                                selected: isSelected,
                              ),
                            );
                          });
                    }
                    if (state.storages.length == 1) {
                      var storage = state.storages[0];
                      var isSelected = storage.id == state.selected?.id;
                      var storageIcon = Renderers.getStorageIcon(storage.type);
                      return PveStorageCard(
                        isSelected: isSelected,
                        sBloc: sBloc,
                        storage: storage,
                        storageIcon: PveStorageCardIcon(
                          icon: storageIcon,
                          selected: isSelected,
                        ),
                        width: MediaQuery.of(context).size.width * 0.9,
                      );
                    }
                    return Center(
                      child: Text(AppLocalizations.of(context).noStorageAvailable),
                    );
                  }),
            ),
          ),
          Expanded(
            child: StreamBuilder<PveFileSelectorState>(
                stream: fBloc.state,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final state = snapshot.data!;
                    return Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(AppLocalizations.of(context).recentBackups,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                IconButton(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  icon: const Icon(Icons.search),
                                  onPressed: () =>
                                      fBloc.events.add(ToggleSearch()),
                                ),
                              ],
                            )
                          ],
                        ),
                        if (state.search)
                          TextField(
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: AppLocalizations.of(context).search,
                            ),
                            autofocus: true,
                            onChanged: (searchTerm) => fBloc.events
                                .add(FilterContent(searchTerm: searchTerm)),
                          ),
                        Expanded(
                          child: PveGuestBackupContent(
                            content: state.content.toList(),
                            storageSelected: state.storageID != null,
                          ),
                        )
                      ],
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.save),
        onPressed: () async {
          await Navigator.of(context)
              .push(_createBackupNowRoute(sBloc, guestID));
          fBloc.events.add(LoadStorageContent());
        },
        label: Text(AppLocalizations.of(context).backupNow),
      ),
    );
  }

  Route _createBackupNowRoute(PveStorageSelectorBloc sBloc, String guestID) {
    return MaterialPageRoute(
        builder: (context) => PveBackupForm(
              sBloc: sBloc,
              guestID: guestID,
            ));
  }
}

class PveGuestBackupContent extends StatelessWidget {
  final List<PveNodesStorageContentModel>? content;
  final bool? storageSelected;

  const PveGuestBackupContent({
    super.key,
    this.content,
    this.storageSelected,
  });
  @override
  Widget build(BuildContext context) {
    final fBloc = Provider.of<PveFileSelectorBloc>(context);

    if (content == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (content!.isEmpty && storageSelected!) {
      return Center(
        child: Text(AppLocalizations.of(context).noExistingBackupFileForGuestFound),
      );
    }

    if (content!.isEmpty && !storageSelected!) {
      return Center(
        child: Text(AppLocalizations.of(context).pleaseSelectATargetStorage),
      );
    }

    return ListView.builder(
      itemCount: content!.length,
      itemBuilder: (context, index) => Card(
        child: ListTile(
          leading: FaIcon(
            FontAwesomeIcons.floppyDisk,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(
            Renderers.renderStorageContent(content![index]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            children: [Text(Renderers.formatSize(content![index].size))],
          ),
          trailing: const Icon(Icons.more_vert),
          onTap: () => _createBackupOptionsSheet(
              context, content![index].volid, content![index].size, fBloc),
        ),
      ),
    );
  }

  Future<T?> _createBackupOptionsSheet<T>(BuildContext context, String? volid,
      int? filesize, PveFileSelectorBloc fBloc) async {
    return await showModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 40,
                    height: 3,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              ListTile(
                title: Text(AppLocalizations.of(context).selection),
                subtitle: Text(volid!),
                trailing: Text(Renderers.formatSize(filesize)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(children: [
                    OutlinedButton.icon(
                      onPressed: () =>
                          _showRestoreDialog(context, fBloc, volid),
                      icon: const Icon(Icons.restore),
                      label: Text(AppLocalizations.of(context).restore),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final loc = AppLocalizations.of(context);
                        final guard = (await _showConfirmDialog(
                            context,
                            loc.attention,
                            loc.deleteBackupConfirm))!;
                        if (guard) {
                          fBloc.events.add(DeleteFile(volid));
                          if (context.mounted) Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.delete),
                      label: Text(AppLocalizations.of(context).remove),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _showConfigurationDialog(context, fBloc, volid),
                      icon: const Icon(Icons.featured_play_list),
                      label: Text(AppLocalizations.of(context).showConfiguration),
                    ),
                  ]),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _showConfirmDialog(
      BuildContext context, String title, String body) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context).cancel,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context).confirm,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _showRestoreDialog(BuildContext parentContext,
      PveFileSelectorBloc fBloc, String volid) async {
    final loc = AppLocalizations.of(parentContext);
    var startAfterRestore = false;
    final guestId = fBloc.latestState.guestID?.toString() ?? '';
    final guestType = volid.contains('vzdump-lxc-') ? 'lxc' : 'qemu';
    final confirmed = await showDialog<bool>(
      context: parentContext,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(loc.restoreBackupTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loc.restoreBackupConfirm(volid, guestId)),
              CheckboxListTile(
                value: startAfterRestore,
                contentPadding: EdgeInsets.zero,
                title: Text(loc.startAfterRestore),
                onChanged: (v) =>
                    setDialogState(() => startAfterRestore = v ?? false),
              ),
            ],
          ),
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
      ),
    );
    if (confirmed != true || guestId.isEmpty) return;
    try {
      final upid = await fBloc.apiClient.restoreGuest(
        fBloc.latestState.nodeID,
        guestType,
        guestId,
        volid,
        start: startAfterRestore,
      );
      if (!parentContext.mounted) return;
      Navigator.of(parentContext).pop();
      if (upid != null) {
        await showTaskLogBottomSheet(
          parentContext,
          fBloc.apiClient,
          fBloc.latestState.nodeID,
          upid,
          icon: const Icon(Icons.restore),
          jobTitle: Text(loc.restoreBackupTitle),
        );
      }
      fBloc.events.add(LoadStorageContent());
    } on ProxmoxApiException catch (e) {
      if (!parentContext.mounted) return;
      ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(
        content: Text(e.message),
        backgroundColor: Theme.of(parentContext).colorScheme.error,
      ));
    } catch (e) {
      if (!parentContext.mounted) return;
      ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(
        content: Text(loc.restoreBackupError),
        backgroundColor: Theme.of(parentContext).colorScheme.error,
      ));
    }
  }

  Future<void> _showConfigurationDialog(
      BuildContext context, PveFileSelectorBloc fBloc, String? volume) async {
    return await showDialog(
      context: context,
      builder: (context) => PveConfigurationDialog(
        apiClient: fBloc.apiClient,
        targetNode: fBloc.latestState.nodeID,
        volume: volume,
      ),
    );
  }
}

class PveConfigurationDialog extends StatefulWidget {
  final ProxmoxApiClient apiClient;
  final String targetNode;
  final String? volume;

  const PveConfigurationDialog({
    super.key,
    required this.apiClient,
    required this.targetNode,
    required this.volume,
  });
  @override
  _PveConfigurationDialogState createState() => _PveConfigurationDialogState();
}

class _PveConfigurationDialogState extends State<PveConfigurationDialog> {
  Future<String?>? configuration;
  @override
  void initState() {
    super.initState();
    configuration = widget.apiClient
        .getNodesVZDumpExtractConfig(widget.targetNode, widget.volume!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: configuration,
      builder: (context, snapshot) => AlertDialog(
        insetPadding: const EdgeInsets.all(4),
        title: Text(AppLocalizations.of(context).configuration),
        content: snapshot.hasData
            ? SingleChildScrollView(child: Text(snapshot.data as String))
            : const Center(
                child: CircularProgressIndicator(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context).close,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}

class PveBackupForm extends StatefulWidget {
  final PveStorageSelectorBloc sBloc;
  final String guestID;

  const PveBackupForm({super.key, required this.sBloc, required this.guestID});

  @override
  _PveBackupFormState createState() => _PveBackupFormState();
}

class _PveBackupFormState extends State<PveBackupForm> {
  PveVZDumpModeType? mode = PveVZDumpModeType.suspend;
  PveVZDumpCompressionType? compression = PveVZDumpCompressionType.zstd;
  static const compTypes = [
    {'type': PveVZDumpCompressionType.none, 'name': 'none'},
    {'type': PveVZDumpCompressionType.gzip, 'name': 'GZIP (good)'},
    {'type': PveVZDumpCompressionType.lzo, 'name': 'LZO (fast)'},
    {'type': PveVZDumpCompressionType.zstd, 'name': 'ZSTD (fast & good)'}
  ];
  TextEditingController? emailToController;
  bool enableSubmitButton = true;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    emailToController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        key: _scaffoldKey,
        child: Scaffold(
          appBar: PveAppBar(
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: Colors.transparent,
            title: Text(AppLocalizations.of(context).scheduleBackup,
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Form(
                key: _formKey,
                onChanged: () {
                  final isValid = _formKey.currentState!.validate();
                  setState(() {
                    enableSubmitButton = isValid;
                  });
                },
                child: Column(
                  children: [
                    PveStorageSelectorDropdown(
                      labelText: AppLocalizations.of(context).storage,
                      sBloc: widget.sBloc,
                      allowBlank: false,
                    ),
                    _createModeDropdown(),
                    _createCompressionDropdown(),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).emailTo,
                        helperText: ' ',
                      ),
                      controller: emailToController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value!.isNotEmpty &&
                            !Validators.isValidEmail(value)) {
                          return AppLocalizations.of(context).pleaseEnterValidEmail;
                        }
                        return null;
                      },
                    ),
                    OutlinedButton.icon(
                        onPressed: enableSubmitButton
                            ? () {
                                //TODO remove when async validation is implemented
                                if (!_formKey.currentState!.validate()) {
                                  setState(() {
                                    enableSubmitButton = false;
                                  });
                                  return;
                                }

                                startBackup(
                                  widget.sBloc.apiClient,
                                  widget.sBloc.latestState.nodeID,
                                  widget.sBloc.latestState.selected!.id,
                                  widget.guestID,
                                  compression,
                                  mode!,
                                  mailTo: emailToController!.text,
                                );
                              }
                            : null,
                        icon: const Icon(Icons.save),
                        label: Text(AppLocalizations.of(context).startBackupNow))
                  ],
                ),
              )),
        ));
  }

  Future<void> startBackup(
    ProxmoxApiClient apiClient,
    String node,
    String storage,
    String guestId,
    PveVZDumpCompressionType? compression,
    PveVZDumpModeType mode, {
    String? mailTo,
  }) async {
    try {
      final jobId = (await apiClient.nodesVZDumpCreateBackup(
          node, storage, guestId,
          compressionType: compression, mode: mode, mailTo: mailTo))!;

      if (mounted) {
        await showTaskLogBottomSheet(context, apiClient, node, jobId,
            icon: const Icon(Icons.save), jobTitle: Text(AppLocalizations.of(context).backupGuestid2(guestId)));
        if (mounted) Navigator.of(context).pop();
      }
    } on ProxmoxApiException catch (e) {
      _scaffoldKey.currentState!.showSnackBar(SnackBar(
        content: Text(
          e.message,
          style: ThemeData.dark().textTheme.labelLarge,
        ),
        backgroundColor: ThemeData.dark().colorScheme.error,
      ));
    } catch (e) {
      if (!mounted) return;
      _scaffoldKey.currentState!.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).errorCouldNotStartBackup,
            style: ThemeData.dark().textTheme.labelLarge,
          ),
          backgroundColor: ThemeData.dark().colorScheme.error,
        ),
      );
    }
  }

  Widget _createModeDropdown() {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).mode,
        helperText: ' ',
      ),
      items: <DropdownMenuItem<PveVZDumpModeType>>[
        for (var mode in PveVZDumpModeType.values)
          DropdownMenuItem(
            value: mode,
            child: Text(mode.name.toUpperCase()),
          )
      ],
      onChanged: (PveVZDumpModeType? selection) => setState(() {
        mode = selection;
      }),
      initialValue: mode,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget _createCompressionDropdown() {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).compression,
        helperText: ' ',
      ),
      items: <DropdownMenuItem<PveVZDumpCompressionType>>[
        for (var comp in compTypes)
          DropdownMenuItem(
            value: comp['type'] as PveVZDumpCompressionType?,
            child: Text(comp['name'] as String),
          )
      ],
      onChanged: (PveVZDumpCompressionType? selection) => setState(() {
        compression = selection;
      }),
      initialValue: compression,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
