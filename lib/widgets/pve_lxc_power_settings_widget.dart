import 'package:flutter/material.dart';
import 'package:proxmox_dart_api_client/proxmox_dart_api_client.dart';
import 'package:pve_flutter_frontend/bloc/pve_lxc_overview_bloc.dart';
import 'package:pve_flutter_frontend/states/pve_lxc_overview_state.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_stream_builder_widget.dart';
import 'package:pve_flutter_frontend/l10n/app_localizations.dart';

class PveLxcPowerSettings extends StatelessWidget {
  final PveLxcOverviewBloc? lxcBloc;

  const PveLxcPowerSettings({super.key, this.lxcBloc});
  @override
  Widget build(BuildContext context) {
    return ProxmoxStreamBuilder<PveLxcOverviewBloc, PveLxcOverviewState>(
      bloc: lxcBloc,
      builder: (context, state) {
        final status = state.currentStatus;
        final disableShutdown =
            status?.getLxcStatus() != PveResourceStatusType.running;
        return SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height / 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (disableShutdown && !(status?.template ?? false))
                  ListTile(
                    leading: const Icon(Icons.play_arrow),
                    title: Text(AppLocalizations.of(context).start,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(AppLocalizations.of(context).turnOnLxcContainer),
                    onTap: () => action(
                        context, PveClusterResourceAction.start, lxcBloc!),
                  ),
                if (!disableShutdown) ...[
                  ListTile(
                    leading: const Icon(Icons.power_settings_new),
                    title: Text(AppLocalizations.of(context).shutdown,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(AppLocalizations.of(context).turnOffLxcContainer),
                    onTap: () => action(
                        context, PveClusterResourceAction.shutdown, lxcBloc!),
                  ),
                  ListTile(
                    leading: const Icon(Icons.loop),
                    title: Text(AppLocalizations.of(context).reboot,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(AppLocalizations.of(context).rebootLxcContainer),
                    onTap: () => action(
                        context, PveClusterResourceAction.reboot, lxcBloc!),
                  ),
                  ListTile(
                    leading: const Icon(Icons.stop),
                    title: Text(AppLocalizations.of(context).stop,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(AppLocalizations.of(context).stopLxcContainer),
                    onTap: () => action(
                        context, PveClusterResourceAction.stop, lxcBloc!),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  void action(BuildContext context, PveClusterResourceAction action,
      PveLxcOverviewBloc bloc) {
    bloc.events.add(PerformLxcAction(action));
    Navigator.of(context).pop();
  }
}
