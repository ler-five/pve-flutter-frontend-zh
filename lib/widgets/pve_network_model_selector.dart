import 'package:flutter/material.dart';

class PveNetworkInterfaceModelSelector extends StatefulWidget {
  final String? labelText;
  final Function? onChange;
  final String? initialSelection;

  const PveNetworkInterfaceModelSelector(
      {super.key, this.labelText, this.onChange, this.initialSelection});
  @override
  State<PveNetworkInterfaceModelSelector> createState() =>
      _PveNetworkInterfaceModelSelectorState();
}

class _PveNetworkInterfaceModelSelectorState
    extends State<PveNetworkInterfaceModelSelector> {
  Map<String, String> models = {
    'e1000': 'Intel E1000',
    'virtio': 'VirtIO (paravirtualized)',
    'rtl8139': 'Realtek RTL8139',
    'vmxnet3': 'VMware vmxnet3'
  };
  String? selection;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: widget.labelText,
        helperText: ' ',
      ),
      items: models.keys
          .map((f) => DropdownMenuItem(
                value: f,
                child: Text(models[f]!),
              ))
          .toList(),
      selectedItemBuilder: (context) => models.keys
          .map((f) => DropdownMenuItem(
                value: f,
                child: Text(models[f]!),
              ))
          .toList(),
      onChanged: (String? selection) {
        setState(() {
          this.selection = selection;
        });
        widget.onChange!(selection);
      },
      value: selection ?? widget.initialSelection,
    );
  }
}
