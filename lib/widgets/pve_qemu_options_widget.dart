import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pve_flutter_frontend/bloc/pve_qemu_overview_bloc.dart';
import 'package:pve_flutter_frontend/states/pve_qemu_overview_state.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_stream_builder_widget.dart';
import 'package:pve_flutter_frontend/widgets/pve_config_switch_list_tile.dart';

class PveQemuOptions extends StatelessWidget {
  final String guestID;
  final _formKey = GlobalKey<FormState>();
  PveQemuOptions({Key? key, required this.guestID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<PveQemuOverviewBloc>(context);
    return ProxmoxStreamBuilder<PveQemuOverviewBloc, PveQemuOverviewState>(
        bloc: bloc,
        builder: (context, state) {
          if (state.config != null) {
            final config = state.config!;
            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                body: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    onChanged: () {},
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: const Text("Name"),
                          subtitle: Text(config.name ?? 'VM$guestID'),
                        ),
                        PveConfigSwitchListTile(
                          title: const Text("Start on boot"),
                          value: config.onboot,
                          defaultValue: false,
                          pending: config.getPending('onboot'),
                          onChanged: (v) => bloc.events
                              .add(UpdateQemuConfigBool('onboot', v)),
                          onDeleted: () => bloc.events
                              .add(RevertPendingQemuConfig('onboot')),
                        ),
                        ListTile(
                          title: const Text("Start/Shutdown order"),
                          subtitle: Text(config.startup ?? "Default (any)"),
                        ),
                        ListTile(
                          title: const Text("OS Type"),
                          subtitle: Text(
                            config.ostype != null ?
                              "${config.ostype!.type} ${config.ostype!.description}" :
                              "Other"
                          ),
                        ),
                        //TODO add better ui component e.g. collapseable
                        ListTile(
                          title: const Text("Boot Device"),
                          subtitle: Text(config.boot ?? 'Disk, Network, USB'),
                        ),
                        PveConfigSwitchListTile(
                          title: const Text("Use tablet for pointer"),
                          value: config.tablet,
                          defaultValue: true,
                          pending: config.getPending('tablet'),
                          onChanged: (v) => bloc.events
                              .add(UpdateQemuConfigBool('tablet', v)),
                          onDeleted: () => bloc.events
                              .add(RevertPendingQemuConfig('tablet')),
                        ),
                        ListTile(
                          title: const Text("Hotplug"),
                          subtitle: Text(config.hotplug ?? 'disk,network,usb'),
                        ),
                        PveConfigSwitchListTile(
                          title: const Text("ACPI support"),
                          value: config.acpi,
                          defaultValue: true,
                          pending: config.getPending('acpi'),
                          onChanged: (v) =>
                              bloc.events.add(UpdateQemuConfigBool('acpi', v)),
                          onDeleted: () =>
                              bloc.events.add(RevertPendingQemuConfig('acpi')),
                        ),
                        PveConfigSwitchListTile(
                          title: const Text("KVM hardware virtualization"),
                          value: config.kvm,
                          defaultValue: true,
                          pending: config.getPending('kvm'),
                          onChanged: (v) =>
                              bloc.events.add(UpdateQemuConfigBool('kvm', v)),
                          onDeleted: () =>
                              bloc.events.add(RevertPendingQemuConfig('kvm')),
                        ),
                        PveConfigSwitchListTile(
                          title: const Text("Freeze CPU on startup"),
                          value: config.freeze,
                          defaultValue: false,
                          pending: config.getPending('freeze'),
                          onChanged: (v) => bloc.events
                              .add(UpdateQemuConfigBool('freeze', v)),
                          onDeleted: () => bloc.events
                              .add(RevertPendingQemuConfig('freeze')),
                        ),
                        PveConfigSwitchListTile(
                          title: const Text("Use local time for RTC"),
                          value: config.localtime,
                          defaultValue: false,
                          pending: config.getPending('localtime'),
                          onChanged: (v) => bloc.events
                              .add(UpdateQemuConfigBool('localtime', v)),
                          onDeleted: () => bloc.events
                              .add(RevertPendingQemuConfig('localtime')),
                        ),
                        ListTile(
                          title: const Text("RTC start date"),
                          subtitle: Text(config.startdate ?? 'now'),
                        ),
                        ListTile(
                          title: const Text("SMBIOS settings (type1)"),
                          subtitle: Text(config.smbios1 ?? ''),
                        ),
                        //Todo enhance UI
                        ListTile(
                          title: const Text("QEMU Guest Agent"),
                          subtitle: Text(config.agent ?? 'Default (disabled)'),
                        ),
                        PveConfigSwitchListTile(
                          title: const Text("Protection"),
                          value: config.protection,
                          defaultValue: false,
                          pending: config.getPending('protection'),
                          onChanged: (v) => bloc.events
                              .add(UpdateQemuConfigBool('protection', v)),
                          onDeleted: () => bloc.events
                              .add(RevertPendingQemuConfig('protection')),
                        ),
                        ListTile(
                          title: const Text("Spice Enhancements"),
                          subtitle: Text(
                              config.spiceEnhancements ?? 'No enhancements'),
                        ),
                        ListTile(
                          title: const Text("VM State Storage"),
                          subtitle: Text(config.vmstatestorage ?? 'Automatic'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
