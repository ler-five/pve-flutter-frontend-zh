import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:proxmox_dart_api_client/proxmox_dart_api_client.dart';
import 'package:pve_flutter_frontend/bloc/pve_qemu_overview_bloc.dart';
import 'package:pve_flutter_frontend/states/pve_qemu_overview_state.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_stream_builder_widget.dart';
import 'package:pve_flutter_frontend/l10n/app_localizations.dart';

class PveQemuPowerSettings extends StatelessWidget {
  const PveQemuPowerSettings({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<PveQemuOverviewBloc>(context);
    return ProxmoxStreamBuilder<PveQemuOverviewBloc, PveQemuOverviewState>(
        bloc: bloc,
        builder: (context, state) {
          final qemuStatus = state.currentStatus?.getQemuStatus();
          final disableShutdown = qemuStatus != PveResourceStatusType.running;
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height / 3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (qemuStatus == PveResourceStatusType.stopped &&
                        !(state.currentStatus!.template ?? false))
                      ListTile(
                        leading: const Icon(Icons.play_arrow),
                        title: Text(AppLocalizations.of(context).start,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(AppLocalizations.of(context).turnOnQemuVirtualMachine),
                        onTap: () => action(
                            context, PveClusterResourceAction.start, bloc),
                      ),
                    if ([
                          PveResourceStatusType.paused,
                          PveResourceStatusType.suspended,
                          PveResourceStatusType.prelaunch,
                        ].contains(qemuStatus) &&
                        !(state.currentStatus!.template ?? false))
                      ListTile(
                        leading: const Icon(Icons.play_arrow),
                        title: Text(AppLocalizations.of(context).resume,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(AppLocalizations.of(context).resumeQemuVirtualMachine),
                        onTap: () => action(
                            context, PveClusterResourceAction.resume, bloc),
                      ),
                    if (!disableShutdown) ...[
                      ListTile(
                        leading: const Icon(Icons.power_settings_new),
                        title: Text(AppLocalizations.of(context).shutdown,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(AppLocalizations.of(context).shutdownQemuVirtualMachine),
                        onTap: () => action(
                            context, PveClusterResourceAction.shutdown, bloc),
                      ),
                      ListTile(
                        leading: const Icon(Icons.autorenew),
                        title: Text(AppLocalizations.of(context).reboot,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(AppLocalizations.of(context).rebootQemuVirtualMachine),
                        onTap: () => action(
                            context, PveClusterResourceAction.reboot, bloc),
                      ),
                      ListTile(
                        leading: const Icon(Icons.pause),
                        title: Text(AppLocalizations.of(context).pause,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(AppLocalizations.of(context).pauseQemuVirtualMachine),
                        onTap: () => action(
                            context, PveClusterResourceAction.suspend, bloc),
                      ),
                      ListTile(
                        leading: const FaIcon(FontAwesomeIcons.download),
                        title: Text(AppLocalizations.of(context).hibernate,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(AppLocalizations.of(context).hibernateQemuVirtualMachine),
                        onTap: () => action(
                            context, PveClusterResourceAction.hibernate, bloc),
                      ),
                      ListTile(
                        leading: const Icon(Icons.stop),
                        title: Text(AppLocalizations.of(context).stop,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(AppLocalizations.of(context).stopQemuVirtualMachine),
                        onTap: () => action(
                            context, PveClusterResourceAction.stop, bloc),
                      ),
                      ListTile(
                        leading: const FaIcon(FontAwesomeIcons.bolt),
                        title: Text(AppLocalizations.of(context).reset,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(AppLocalizations.of(context).resetQemuVirtualMachine),
                        onTap: () => action(
                            context, PveClusterResourceAction.reset, bloc),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        });
  }

  void action(BuildContext context, PveClusterResourceAction action,
      PveQemuOverviewBloc bloc) {
    bloc.events.add(PerformQemuAction(action));
    Navigator.of(context).pop();
  }
}
