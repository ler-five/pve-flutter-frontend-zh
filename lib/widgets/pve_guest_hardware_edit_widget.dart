import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:proxmox_dart_api_client/proxmox_dart_api_client.dart';
import 'package:pve_flutter_frontend/l10n/app_localizations.dart';
import 'package:pve_flutter_frontend/utils/utils.dart';
import 'package:pve_flutter_frontend/widgets/pve_app_bar.dart';

/// Quick editor for the most common hardware changes:
/// CPU cores / memory (and sockets/swap), disk resize, network bridge.
class PveGuestHardwareEditWidget extends StatefulWidget {
  final ProxmoxApiClient apiClient;
  final String nodeID;
  final String guestID;
  final String guestType; // 'qemu' or 'lxc'

  const PveGuestHardwareEditWidget({
    super.key,
    required this.apiClient,
    required this.nodeID,
    required this.guestID,
    required this.guestType,
  });

  @override
  State<PveGuestHardwareEditWidget> createState() =>
      _PveGuestHardwareEditWidgetState();
}

class _PveGuestHardwareEditWidgetState
    extends State<PveGuestHardwareEditWidget> {
  Map<String, dynamic>? _config;
  bool _loadFailed = false;

  bool get _isQemu => widget.guestType == 'qemu';

  static final _qemuDiskKey = RegExp(r'^(scsi|virtio|sata|ide)\d+$');
  static final _lxcMountKey = RegExp(r'^mp\d+$');
  static final _netKey = RegExp(r'^net\d+$');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final config = await widget.apiClient
          .getGuestConfigRaw(widget.nodeID, widget.guestType, widget.guestID);
      if (mounted) {
        setState(() {
          _config = config;
          _loadFailed = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadFailed = true;
        });
      }
    }
  }

  List<MapEntry<String, String>> get _disks {
    final config = _config;
    if (config == null) return [];
    final entries = <MapEntry<String, String>>[];
    config.forEach((key, value) {
      if (value is! String) return;
      if (_isQemu) {
        if (!_qemuDiskKey.hasMatch(key)) return;
        // skip cdrom/cloudinit pseudo disks
        if (value.contains('media=cdrom')) return;
      } else {
        if (key != 'rootfs' && !_lxcMountKey.hasMatch(key)) return;
      }
      if (key == 'rootfs' || value.contains('size=') || value.contains('=')) {
        entries.add(MapEntry(key, value));
      }
    });
    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  List<MapEntry<String, String>> get _nets {
    final config = _config;
    if (config == null) return [];
    final entries = <MapEntry<String, String>>[];
    config.forEach((key, value) {
      if (value is String && _netKey.hasMatch(key)) {
        entries.add(MapEntry(key, value));
      }
    });
    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final config = _config;
    return Scaffold(
      appBar: PveAppBar(
        title: Text(loc.editHardware),
      ),
      body: config == null
          ? Center(
              child: _loadFailed
                  ? Text(loc.actionFailed)
                  : const CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(8),
              children: [
                Card(
                  child: Column(
                    children: [
                      _buildNumberTile(
                        icon: const Icon(Icons.memory),
                        title: loc.cpuCores,
                        configKey: 'cores',
                      ),
                      _buildNumberTile(
                        icon: const FaIcon(FontAwesomeIcons.memory),
                        title: loc.memoryMib,
                        configKey: 'memory',
                      ),
                      if (_isQemu)
                        _buildNumberTile(
                          icon: const FaIcon(FontAwesomeIcons.microchip),
                          title: loc.sockets,
                          configKey: 'sockets',
                        ),
                      if (!_isQemu)
                        _buildNumberTile(
                          icon: const Icon(Icons.cached),
                          title: loc.swapMib,
                          configKey: 'swap',
                        ),
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      for (final disk in _disks)
                        ListTile(
                          leading: const FaIcon(FontAwesomeIcons.hardDrive),
                          title: Text(disk.key),
                          subtitle: Text(
                            disk.value,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.open_in_full),
                            tooltip: loc.resizeDisk,
                            onPressed: () =>
                                _showResizeDialog(disk.key, disk.value),
                          ),
                        ),
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      for (final net in _nets)
                        ListTile(
                          leading: const FaIcon(FontAwesomeIcons.ethernet),
                          title: Text(net.key),
                          subtitle: Text(
                            net.value,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: loc.bridge,
                            onPressed: () =>
                                _showBridgeDialog(net.key, net.value),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNumberTile({
    required Widget icon,
    required String title,
    required String configKey,
  }) {
    final value = _config?[configKey];
    return ListTile(
      leading: icon,
      title: Text(title),
      subtitle: Text(value?.toString() ?? '-'),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () => _showNumberEditDialog(configKey, title, value),
      ),
    );
  }

  Future<void> _showNumberEditDialog(
      String configKey, String title, dynamic current) async {
    final loc = AppLocalizations.of(context);
    final controller =
        TextEditingController(text: current?.toString() ?? '');
    final formKey = GlobalKey<FormState>();
    final apply = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.editTitle(title)),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: title),
            validator: (value) {
              final v = int.tryParse(value ?? '');
              if (v == null || v < 0) {
                return loc.invalidNumber;
              }
              return null;
            },
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
            child: Text(loc.apply),
          ),
        ],
      ),
    );
    if (apply != true) return;
    await _updateConfig({configKey: controller.text.trim()});
  }

  Future<void> _showResizeDialog(String diskKey, String diskValue) async {
    final loc = AppLocalizations.of(context);
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final apply = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${loc.resizeDisk} $diskKey'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: loc.resizeDisk,
              helperText: loc.resizeDiskHint,
            ),
            validator: (value) {
              if (!RegExp(r'^\+\d+(\.\d+)?[GMTK]$')
                  .hasMatch((value ?? '').trim())) {
                return loc.invalidSizeIncrement;
              }
              return null;
            },
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
            child: Text(loc.apply),
          ),
        ],
      ),
    );
    if (apply != true) return;
    try {
      final upid = await widget.apiClient.resizeGuestDisk(widget.nodeID,
          widget.guestType, widget.guestID, diskKey, controller.text.trim());
      if (!mounted) return;
      if (upid != null) {
        await showTaskLogBottomSheet(
          context,
          widget.apiClient,
          widget.nodeID,
          upid,
          jobTitle: Text('${loc.resizeDisk} $diskKey'),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(loc.configUpdated),
        ));
      }
      _load();
    } on ProxmoxApiException catch (e) {
      _showApiError(e);
    }
  }

  Future<void> _showBridgeDialog(String netKey, String netValue) async {
    final loc = AppLocalizations.of(context);
    List<PveNodeNetworkModel> bridges;
    try {
      bridges = await widget.apiClient
          .getNodeNetwork(widget.nodeID, type: InterfaceType.bridge);
    } catch (e) {
      _showApiError(null);
      return;
    }
    if (!mounted) return;
    final currentBridge = _extractBridge(netValue);
    String? selected = currentBridge;
    if (selected == null && bridges.isNotEmpty) {
      selected = bridges.first.iface;
    }
    final apply = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('$netKey ${loc.bridge}'),
          content: DropdownButtonFormField<String>(
            initialValue: selected,
            decoration: InputDecoration(labelText: loc.bridge),
            items: [
              for (final b in bridges)
                if (b.iface != null)
                  DropdownMenuItem(value: b.iface!, child: Text(b.iface!)),
            ],
            onChanged: (v) => setDialogState(() => selected = v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: selected == null
                  ? null
                  : () => Navigator.of(context).pop(true),
              child: Text(loc.apply),
            ),
          ],
        ),
      ),
    );
    if (apply != true || selected == null) return;
    final newValue = _replaceBridge(netValue, selected!);
    await _updateConfig({netKey: newValue});
  }

  String? _extractBridge(String netValue) {
    for (final part in netValue.split(',')) {
      final kv = part.split('=');
      if (kv.length == 2 && kv[0].trim() == 'bridge') {
        return kv[1].trim();
      }
    }
    return null;
  }

  String _replaceBridge(String netValue, String bridge) {
    final parts = netValue.split(',');
    var replaced = false;
    final out = parts.map((part) {
      final kv = part.split('=');
      if (kv.length == 2 && kv[0].trim() == 'bridge') {
        replaced = true;
        return 'bridge=$bridge';
      }
      return part;
    }).toList();
    if (!replaced) {
      out.add('bridge=$bridge');
    }
    return out.join(',');
  }

  Future<void> _updateConfig(Map<String, String> params) async {
    final loc = AppLocalizations.of(context);
    try {
      if (_isQemu) {
        await widget.apiClient
            .setQemuConfig(widget.nodeID, widget.guestID, params);
      } else {
        await widget.apiClient
            .setLxcConfig(widget.nodeID, widget.guestID, params);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(loc.configUpdated),
      ));
      _load();
    } on ProxmoxApiException catch (e) {
      _showApiError(e);
    }
  }

  void _showApiError(ProxmoxApiException? e) {
    if (!mounted) return;
    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(e?.message ?? loc.actionFailed),
      backgroundColor: Theme.of(context).colorScheme.error,
    ));
  }
}
