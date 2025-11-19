import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pve_flutter_frontend/bloc/pve_qemu_overview_bloc.dart';
import 'package:pve_flutter_frontend/states/pve_qemu_overview_state.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_stream_builder_widget.dart';
import 'package:pve_flutter_frontend/widgets/pve_config_forms/pve_config_switch_form.dart';
import 'package:pve_flutter_frontend/widgets/pve_config_list_tile.dart';

class PveQemuOptions extends StatelessWidget {
  final String guestID;
  final _formKey = GlobalKey<FormState>();
  PveQemuOptions({super.key, required this.guestID});

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<PveQemuOverviewBloc>(context);
    return ProxmoxStreamBuilder<PveQemuOverviewBloc, PveQemuOverviewState>(
        bloc: bloc,
        builder: (context, state) {
          if (state.config != null) {
            final config = state.config!;
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: SafeArea(
                bottom: !Platform.isIOS,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    onChanged: () {},
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: const Text("Name"),
                          subtitle: Text(config.name ?? 'VM$guestID'),
                        ),
                        PveConfigListTile<bool>(
                          title: "Start on boot",
                          trailingText: config.onboot == true ? 'Yes' : 'No',
                          pending: config.getPending('onboot'),
                          onSubmit: (v) => bloc.events.add(
                            UpdateQemuConfigBool('onboot', v),
                          ),
                          editorBuilder: (_, controller) {
                            return PveConfigSwitchForm(
                              title: "Start on boot",
                              value: config.onboot == true,
                              controller: controller,
                            );
                          },
                          onCancelEdit: () => bloc.events.add(
                            RevertPendingQemuConfig('onboot'),
                          ),
                        ),
                        ListTile(
                          title: const Text("Start/Shutdown order"),
                          subtitle: Text(config.startup ?? "Default (any)"),
                        ),
                        ListTile(
                          title: const Text("OS Type"),
                          subtitle: Text(config.ostype != null
                              ? "${config.ostype!.type} ${config.ostype!.description}"
                              : "Other"),
                        ),
                        //TODO add better ui component e.g. collapseable
                        ListTile(
                          title: const Text("Boot Device"),
                          subtitle: Text(config.boot ?? 'Disk, Network, USB'),
                        ),
                        PveConfigListTile<bool>(
                          title: "Use tablet for pointer",
                          trailingText: config.tablet == true ? 'Yes' : 'No',
                          pending: config.getPending('tablet'),
                          onSubmit: (v) => bloc.events.add(
                            UpdateQemuConfigBool('tablet', v),
                          ),
                          editorBuilder: (_, controller) {
                            return PveConfigSwitchForm(
                              title: "Use tablet for pointer",
                              value: config.tablet == true,
                              controller: controller,
                            );
                          },
                          onCancelEdit: () => bloc.events.add(
                            RevertPendingQemuConfig('tablet'),
                          ),
                        ),
                        ListTile(
                          title: const Text("Hotplug"),
                          subtitle: Text(config.hotplug ?? 'disk,network,usb'),
                        ),
                        PveConfigListTile<bool>(
                          title: "ACPI support",
                          trailingText: config.acpi == true ? 'Yes' : 'No',
                          pending: config.getPending('acpi'),
                          onSubmit: (v) => bloc.events.add(
                            UpdateQemuConfigBool('acpi', v),
                          ),
                          editorBuilder: (_, controller) {
                            return PveConfigSwitchForm(
                              title: "ACPI support",
                              value: config.acpi == true,
                              controller: controller,
                            );
                          },
                          onCancelEdit: () => bloc.events.add(
                            RevertPendingQemuConfig('acpi'),
                          ),
                        ),
                        PveConfigListTile<bool>(
                          title: "KVM hardware virtualization",
                          trailingText: config.kvm == true ? 'Yes' : 'No',
                          pending: config.getPending('kvm'),
                          onSubmit: (v) => bloc.events.add(
                            UpdateQemuConfigBool('kvm', v),
                          ),
                          editorBuilder: (_, controller) {
                            return PveConfigSwitchForm(
                              title: "KVM hardware virtualization",
                              value: config.kvm == true,
                              controller: controller,
                            );
                          },
                          onCancelEdit: () => bloc.events.add(
                            RevertPendingQemuConfig('kvm'),
                          ),
                        ),
                        PveConfigListTile<bool>(
                          title: "Freeze CPU on startup",
                          trailingText: config.freeze == true ? 'Yes' : 'No',
                          pending: config.getPending('freeze'),
                          onSubmit: (v) => bloc.events.add(
                            UpdateQemuConfigBool('freeze', v),
                          ),
                          editorBuilder: (_, controller) {
                            return PveConfigSwitchForm(
                              title: "Freeze CPU on startup",
                              value: config.freeze == true,
                              controller: controller,
                            );
                          },
                          onCancelEdit: () => bloc.events.add(
                            RevertPendingQemuConfig('freeze'),
                          ),
                        ),
                        PveConfigListTile<bool>(
                          title: "Use local time for RTC",
                          trailingText: config.localtime == true ? 'Yes' : 'No',
                          pending: config.getPending('localtime'),
                          onSubmit: (v) => bloc.events.add(
                            UpdateQemuConfigBool('localtime', v),
                          ),
                          editorBuilder: (_, controller) {
                            return PveConfigSwitchForm(
                              title: "Use local time for RTC",
                              value: config.localtime == true,
                              controller: controller,
                            );
                          },
                          onCancelEdit: () => bloc.events.add(
                            RevertPendingQemuConfig('localtime'),
                          ),
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
                        PveConfigListTile<bool>(
                          title: "Protection",
                          trailingText:
                              config.protection == true ? 'Yes' : 'No',
                          pending: config.getPending('protection'),
                          onSubmit: (v) => bloc.events.add(
                            UpdateQemuConfigBool('protection', v),
                          ),
                          editorBuilder: (_, controller) {
                            return PveConfigSwitchForm(
                              title: "Protection",
                              value: config.protection == true,
                              controller: controller,
                            );
                          },
                          onCancelEdit: () => bloc.events.add(
                            RevertPendingQemuConfig('protection'),
                          ),
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
