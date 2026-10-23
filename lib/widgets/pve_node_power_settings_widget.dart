import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxmox_dart_api_client/proxmox_dart_api_client.dart';
import 'package:pve_flutter_frontend/bloc/pve_node_overview_bloc.dart';
import 'package:pve_flutter_frontend/states/pve_node_overview_state.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_stream_builder_widget.dart';
import 'package:pve_flutter_frontend/l10n/app_localizations.dart';

class PveNodePowerSettings extends StatelessWidget {
  const PveNodePowerSettings({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<PveNodeOverviewBloc>(context);
    return ProxmoxStreamBuilder<PveNodeOverviewBloc, PveNodeOverviewState>(
        bloc: bloc,
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height / 3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.autorenew),
                      title: Text(AppLocalizations.of(context).reboot,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(AppLocalizations.of(context).rebootNode),
                      onTap: () => confirmedAction(context,
                          PveClusterResourceAction.reboot, bloc, "reboot"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.power_settings_new),
                      title: Text(AppLocalizations.of(context).shutdown,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(AppLocalizations.of(context).shutdownNode),
                      onTap: () => confirmedAction(context,
                          PveClusterResourceAction.shutdown, bloc, "shutdown"),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void confirmedAction(BuildContext context, PveClusterResourceAction action,
      PveNodeOverviewBloc bloc, String actionText) async {
    String capitalizedActionText =
        actionText[0].toUpperCase() + actionText.substring(1);
    bool confirmed = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 16.0),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(AppLocalizations.of(context).capitalizedactiontextNode(capitalizedActionText)),
                const Icon(Icons.warning),
              ],
            ),
            content: Text(AppLocalizations.of(context)
                .nodePowerWarning(actionText, bloc.nodeID)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(AppLocalizations.of(context).cancel)),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(capitalizedActionText))
            ],
          );
        });
    if (confirmed) {
      bloc.events.add(PerformNodeAction(action));
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}
