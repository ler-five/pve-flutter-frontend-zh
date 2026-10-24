import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pve_flutter_frontend/bloc/pve_lxc_overview_bloc.dart';
import 'package:pve_flutter_frontend/states/pve_lxc_overview_state.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_stream_builder_widget.dart';
import 'package:pve_flutter_frontend/widgets/pve_config_forms/pve_config_switch_form.dart';
import 'package:pve_flutter_frontend/widgets/pve_config_list_tile.dart';
import 'package:pve_flutter_frontend/l10n/app_localizations.dart';

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
              body: SafeArea(
                bottom: !Platform.isIOS,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(AppLocalizations.of(context).name),
                        subtitle: Text(config.hostname ?? 'undefined'),
                      ),
                      PveConfigListTile<bool>(
                        title: AppLocalizations.of(context).startOnBoot,
                        trailingText: config.onboot == true ? AppLocalizations.of(context).yes : AppLocalizations.of(context).no,
                        pending: config.getPending('onboot'),
                        onSubmit: (value) => lxcBloc!.events.add(
                          UpdateLxcConfigBool(
                            'onboot',
                            value,
                          ),
                        ),
                        editorBuilder: (_, controller) {
                          return PveConfigSwitchForm(
                            title: AppLocalizations.of(context).startOnBoot,
                            value: config.onboot == true,
                            controller: controller,
                          );
                        },
                        onCancelEdit: () => lxcBloc!.events.add(
                          RevertPendingLxcConfig('onboot'),
                        ),
                      ),
                      ListTile(
                        title: Text(AppLocalizations.of(context).startShutdownOrder),
                        subtitle: Text(config.startup ?? AppLocalizations.of(context).defaultAny),
                      ),
                      ListTile(
                        title: Text(AppLocalizations.of(context).osType),
                        subtitle: Text("${config.ostype}"),
                      ),
                      ListTile(
                        title: Text(AppLocalizations.of(context).architecture),
                        subtitle: Text("${config.arch}"),
                      ),
                      PveConfigListTile<bool>(
                        title: "/dev/console",
                        trailingText: config.console == true ? AppLocalizations.of(context).yes : AppLocalizations.of(context).no,
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
                        title: Text(AppLocalizations.of(context).ttyCount),
                        subtitle: Text("${config.tty ?? 2}"),
                      ),
                      ListTile(
                        title: Text(AppLocalizations.of(context).consoleMode),
                        subtitle: Text(config.cmode?.name ?? 'tty'),
                      ),
                      PveConfigListTile<bool>(
                        title: AppLocalizations.of(context).protection,
                        trailingText: config.protection == true ? AppLocalizations.of(context).yes : AppLocalizations.of(context).no,
                        pending: config.getPending('protection'),
                        onSubmit: (v) => lxcBloc!.events.add(
                          UpdateLxcConfigBool('protection', v),
                        ),
                        editorBuilder: (_, controller) {
                          return PveConfigSwitchForm(
                            title: AppLocalizations.of(context).protection,
                            value: config.protection == true,
                            controller: controller,
                          );
                        },
                        onCancelEdit: () => lxcBloc!.events.add(
                          RevertPendingLxcConfig('protection'),
                        ),
                      ),
                      ListTile(
                        title: Text(AppLocalizations.of(context).unprivileged),
                        subtitle:
                            Text(config.unprivileged ?? false ? AppLocalizations.of(context).yes : AppLocalizations.of(context).no),
                      ),
                      ListTile(
                        title: Text(AppLocalizations.of(context).features),
                        subtitle: Text(config.features?.toString() ?? AppLocalizations.of(context).none),
                      ),
                    ],
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
