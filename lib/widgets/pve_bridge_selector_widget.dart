import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxmox_dart_api_client/proxmox_dart_api_client.dart';
import 'package:pve_flutter_frontend/bloc/pve_bridge_selector_bloc.dart';

class PveBridgeSelector extends StatelessWidget {
  final String? labelText;

  const PveBridgeSelector({super.key, this.labelText});

  @override
  Widget build(BuildContext context) {
    final bBloc = Provider.of<PveBridgeSelectorBloc>(context);
    return StreamBuilder<PveBridgeSelectorState>(
      stream: bBloc.state,
      initialData: bBloc.state.value,
      builder: (BuildContext context,
          AsyncSnapshot<PveBridgeSelectorState> snapshot) {
        if (snapshot.hasData) {
          final state = snapshot.data!;

          return DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: labelText,
              helperText: ' ',
            ),
            items: <DropdownMenuItem<PveNodeNetworkModel>>[
              for (var bridge in state.bridges!)
                DropdownMenuItem(
                  value: bridge,
                  child: Row(
                    children: <Widget>[
                      Text(bridge.iface ?? ''),
                      const VerticalDivider(),
                      Text(bridge.active?.toString() ?? ''),
                      const VerticalDivider(),
                      Text(bridge.comment ?? '')
                    ],
                  ),
                )
            ],
            onChanged: (PveNodeNetworkModel? selection) =>
                bBloc.events.add(BridgeSelectedEvent(selection)),
            value: state.value,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (dynamic _) {
              return state.errorText;
            },
          );
        }

        return Container();
      },
    );
  }
}
