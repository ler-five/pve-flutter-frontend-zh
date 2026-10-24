import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pve_flutter_frontend/bloc/pve_qemu_overview_bloc.dart';
import 'package:pve_flutter_frontend/states/pve_qemu_overview_state.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_stream_builder_widget.dart';
import 'package:pve_flutter_frontend/widgets/pve_config_forms/pve_config_switch_form.dart';
import 'package:pve_flutter_frontend/widgets/pve_config_list_tile.dart';
import 'package:pve_flutter_frontend/l10n/app_localizations.dart';

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
                          title: Text(AppLocalizations.of(context).name),
                          subtitle: Text(config.name ?? 'VM$guestID'),
                        ),
                        PveConfigListTile<bool>(
                          title: AppLocalizations.of(context).startOnBoot,
                          trailingText: config.onboot == true ? AppLocalizations.of(context).yes : AppLocalizations.of(context).no,
                          pending: config.getPending('onboot'),
                          onSubmit: (v) => bloc.events.add(
                            UpdateQemuConfigBool('onboot', v),
                          ),
                          editorBuilder: (_, controller) {
                            return PveConfigSwitchForm(
                              title: AppLocalizations.of(context).startOnBoot,
                              value: config.onboot == true,
                              controller: controller,
                            );
                          },
                          onCancelEdit: () => bloc.events.add(
                            RevertPendingQemuConfig('onboot'),
                          ),
                        ),
                        ListTile(
                          title: Text(AppLocalizations.of(context).startShutdownOrder),
                          subtitle: Text(config.startup ?? AppLocalizations.of(context).defaultAny),
                        ),
                        ListTile(
                          title: Text(AppLocalizations.of(context).osType),
                          subtitle: Text(config.ostype != null
                              ? "${config.ostype!.type} ${config.ostype!.description}"
                              : AppLocalizations.of(context).other),
                        ),
                        //TODO add better ui component e.g. collapseable
                        ListTile(
                          title: Text(AppLocalizations.of(context).bootDevice),
                          subtitle: Text(config.boot ?? AppLocalizations.of(context).diskNetworkUsb),
                        ),
                        PveConfigListTile<bool>(
                          title: AppLocalizations.of(context).useTabletForPointer,
                          trailingText: config.tablet == true ? AppLocalizations.of(context).yes : AppLocalizations.of(context).no,
                          pending: config.getPending('tablet'),
                          onSubmit: (v) => bloc.events.add(
                            UpdateQemuConfigBool('tablet', v),
                          ),
                          editorBuilder: (_, controller) {
                            return PveConfigSwitchForm(
                              title: AppLocalizations.of(context).useTabletForPointer,
                              value: config.tablet == true,
                              controller: controller,
                            );
                          },
                          onCancelEdit: () => bloc.events.add(
                            RevertPendingQemuConfig('tablet'),
                          ),
                        ),
                        ListTile(
                          title: Text(AppLocalizations.of(context).hotplug),
                          subtitle: Text(config.hotplug ?? 'disk,network,usb'),
                        ),
                        PveConfigListTile<bool>(
                          title: AppLocalizations.of(context).acpiSupport,
                          trailingText: config.acpi == true ? AppLocalizations.of(context).yes : AppLocalizations.of(context).no,
                          pending: config.getPending('acpi'),
                          onSubmit: (v) => bloc.events.add(
                            UpdateQemuConfigBool('acpi', v),
                          ),
                          editorBuilder: (_, controller) {
                            return PveConfigSwitchForm(
                              title: AppLocalizations.of(context).acpiSupport,
                              value: config.acpi == true,
                              controller: controller,
                            );
                          },
                          onCancelEdit: () => bloc.events.add(
                            RevertPendingQemuConfig('acpi'),
                          ),
                        ),
                        PveConfigListTile<bool>(
                          title: AppLocalizations.of(context).kvmHardwareVirtualization,
                          trailingText: config.kvm == true ? AppLocalizations.of(context).yes : AppLocalizations.of(context).no,
                          pending: config.getPending('kvm'),
                          onSubmit: (v) => bloc.events.add(
                            UpdateQemuConfigBool('kvm', v),
                          ),
                          editorBuilder: (_, controller) {
                            return PveConfigSwitchForm(
                              title: AppLocalizations.of(context).kvmHardwareVirtualization,
                              value: config.kvm == true,
                              controller: controller,
                            );
                          },
                          onCancelEdit: () => bloc.events.add(
                            RevertPendingQemuConfig('kvm'),
                          ),
                        ),
                        PveConfigListTile<bool>(
                          title: AppLocalizations.of(context).freezeCpuOnStartup,
                          trailingText: config.freeze == true ? AppLocalizations.of(context).yes : AppLocalizations.of(context).no,
                          pending: config.getPending('freeze'),
                          onSubmit: (v) => bloc.events.add(
                            UpdateQemuConfigBool('freeze', v),
                          ),
                          editorBuilder: (_, controller) {
                            return PveConfigSwitchForm(
                              title: AppLocalizations.of(context).freezeCpuOnStartup,
                              value: config.freeze == true,
                              controller: controller,
                            );
                          },
                          onCancelEdit: () => bloc.events.add(
                            RevertPendingQemuConfig('freeze'),
                          ),
                        ),
                        PveConfigListTile<bool>(
                          title: AppLocalizations.of(context).useLocalTimeForRtc,
                          trailingText: config.localtime == true ? AppLocalizations.of(context).yes : AppLocalizations.of(context).no,
                          pending: config.getPending('localtime'),
                          onSubmit: (v) => bloc.events.add(
                            UpdateQemuConfigBool('localtime', v),
                          ),
                          editorBuilder: (_, controller) {
                            return PveConfigSwitchForm(
                              title: AppLocalizations.of(context).useLocalTimeForRtc,
                              value: config.localtime == true,
                              controller: controller,
                            );
                          },
                          onCancelEdit: () => bloc.events.add(
                            RevertPendingQemuConfig('localtime'),
                          ),
                        ),
                        ListTile(
                          title: Text(AppLocalizations.of(context).rtcStartDate),
                          subtitle: Text(config.startdate ?? AppLocalizations.of(context).now),
                        ),
                        ListTile(
                          title: Text(AppLocalizations.of(context).smbiosSettingsType1),
                          subtitle: Text(config.smbios1 ?? ''),
                        ),
                        //Todo enhance UI
                        ListTile(
                          title: Text(AppLocalizations.of(context).qemuGuestAgent),
                          subtitle: Text(config.agent ?? AppLocalizations.of(context).defaultDisabled),
                        ),
                        PveConfigListTile<bool>(
                          title: AppLocalizations.of(context).protection,
                          trailingText:
                              config.protection == true ? AppLocalizations.of(context).yes : AppLocalizations.of(context).no,
                          pending: config.getPending('protection'),
                          onSubmit: (v) => bloc.events.add(
                            UpdateQemuConfigBool('protection', v),
                          ),
                          editorBuilder: (_, controller) {
                            return PveConfigSwitchForm(
                              title: AppLocalizations.of(context).protection,
                              value: config.protection == true,
                              controller: controller,
                            );
                          },
                          onCancelEdit: () => bloc.events.add(
                            RevertPendingQemuConfig('protection'),
                          ),
                        ),
                        ListTile(
                          title: Text(AppLocalizations.of(context).spiceEnhancements),
                          subtitle: Text(
                              config.spiceEnhancements ?? AppLocalizations.of(context).noEnhancements),
                        ),
                        ListTile(
                          title: Text(AppLocalizations.of(context).vmStateStorage),
                          subtitle: Text(config.vmstatestorage ?? AppLocalizations.of(context).automatic),
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
