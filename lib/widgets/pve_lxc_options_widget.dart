import 'package:flutter/material.dart';
import 'package:pve_flutter_frontend/bloc/pve_lxc_overview_bloc.dart';
import 'package:pve_flutter_frontend/states/pve_lxc_overview_state.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_stream_builder_widget.dart';
import 'package:pve_flutter_frontend/widgets/pve_config_forms/pve_config_switch_form.dart';
import 'package:pve_flutter_frontend/widgets/pve_config_list_tile.dart';

class PveLxcOptions extends StatelessWidget {
  final PveLxcOverviewBloc? lxcBloc;

  const PveLxcOptions({super.key, this.lxcBloc});
  @override
  Widget build(BuildContext context) {
    return ProxmoxStreamBuilder<PveLxcOverviewBloc, PveLxcOverviewState>(
        bloc: lxcBloc,
        builder: (context, state) {
          final config = state.config;
          if (config != null) {
            return Scaffold(
              appBar: AppBar(),
              body: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: const Text("Name"),
                      subtitle: Text(config.hostname ?? 'undefined'),
                    ),
                    PveConfigListTile<bool>(
                      title: "Start on boot",
                      trailingText: config.onboot == true ? 'Yes' : 'No',
                      pending: config.getPending('onboot'),
                      onSubmit: (value) => lxcBloc!.events.add(
                        UpdateLxcConfigBool(
                          'onboot',
                          value,
                        ),
                      ),
                      editorBuilder: (_, controller) {
                        return PveConfigSwitchForm(
                          title: "Start on boot",
                          value: config.onboot == true,
                          controller: controller,
                        );
                      },
                      onCancelEdit: () => lxcBloc!.events.add(
                        RevertPendingLxcConfig('onboot'),
                      ),
                    ),
                    ListTile(
                      title: const Text("Start/Shutdown order"),
                      subtitle: Text(config.startup ?? "Default (any)"),
                    ),
                    ListTile(
                      title: const Text("OS Type"),
                      subtitle: Text("${config.ostype}"),
                    ),
                    ListTile(
                      title: const Text("Architecture"),
                      subtitle: Text("${config.arch}"),
                    ),
                    PveConfigListTile<bool>(
                      title: "/dev/console",
                      trailingText: config.console == true ? 'Yes' : 'No',
                      pending: config.getPending('console'),
                      onSubmit: (v) => lxcBloc!.events.add(
                        UpdateLxcConfigBool('console', v),
                      ),
                      editorBuilder: (_, controller) {
                        return PveConfigSwitchForm(
                          title: "/dev/console",
                          value: config.console == true,
                          controller: controller,
                        );
                      },
                      onCancelEdit: () => lxcBloc!.events.add(
                        RevertPendingLxcConfig('console'),
                      ),
                    ),
                    ListTile(
                      title: const Text("TTY Count"),
                      subtitle: Text("${config.tty ?? 2}"),
                    ),
                    ListTile(
                      title: const Text("Console Mode"),
                      subtitle: Text(config.cmode?.name ?? 'tty'),
                    ),
                    PveConfigListTile<bool>(
                      title: "Protection",
                      trailingText: config.protection == true ? 'Yes' : 'No',
                      pending: config.getPending('protection'),
                      onSubmit: (v) => lxcBloc!.events.add(
                        UpdateLxcConfigBool('protection', v),
                      ),
                      editorBuilder: (_, controller) {
                        return PveConfigSwitchForm(
                          title: "Protection",
                          value: config.protection == true,
                          controller: controller,
                        );
                      },
                      onCancelEdit: () => lxcBloc!.events.add(
                        RevertPendingLxcConfig('protection'),
                      ),
                    ),
                    ListTile(
                      title: const Text("Unprivileged"),
                      subtitle:
                          Text(config.unprivileged ?? false ? 'Yes' : 'No'),
                    ),
                    ListTile(
                      title: const Text("Features"),
                      subtitle: Text(config.features?.toString() ?? 'none'),
                    ),
                  ],
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
