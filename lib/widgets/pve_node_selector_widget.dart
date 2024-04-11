import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pve_flutter_frontend/bloc/pve_node_selector_bloc.dart';
import 'package:pve_flutter_frontend/states/pve_node_selector_state.dart';

class PveNodeSelector extends StatelessWidget {
  final String? labelText;

  const PveNodeSelector({super.key, this.labelText});

  @override
  Widget build(BuildContext context) {
    final pveNodeSelectorBloc = Provider.of<PveNodeSelectorBloc>(context);
    return StreamBuilder<PveNodeSelectorState>(
      stream: pveNodeSelectorBloc.state,
      initialData: pveNodeSelectorBloc.state.value,
      builder:
          (BuildContext context, AsyncSnapshot<PveNodeSelectorState> snapshot) {
        if (snapshot.hasData && snapshot.data!.availableNodes.isNotEmpty) {
          final state = snapshot.data!;

          return DropdownButton(
            items: state.availableNodes
                .map((item) => DropdownMenuItem(
                      value: item.nodeName,
                      child: Row(
                        children: <Widget>[
                          Text(item.nodeName),
                          const VerticalDivider(),
                          Text(item.renderMemoryUsagePercent()),
                          const VerticalDivider(),
                          Text(item.renderCpuUsage())
                        ],
                      ),
                    ))
                .toList(),
            selectedItemBuilder: (context) => state.availableNodes
                .map((item) => Text(item.nodeName))
                .toList(),
            onChanged: (String? selectedNode) =>
                pveNodeSelectorBloc.events.add(NodeSelectedEvent(selectedNode)),
            value: state.selectedNode!.nodeName,
          );
        }

        return Container();
      },
    );
  }
}
