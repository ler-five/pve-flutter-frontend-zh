import 'package:flutter/material.dart';

class PveConfigSwitchListTile extends StatelessWidget {
  final bool? value;
  final int? pending;
  final bool? defaultValue;
  final Widget? title;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onDeleted;

  const PveConfigSwitchListTile({
    super.key,
    this.value,
    this.pending,
    this.defaultValue,
    this.title,
    this.onChanged,
    this.onDeleted,
  });
  @override
  Widget build(BuildContext context) {
    bool? pBool;
    if (pending != null) {
      pBool = pending == 0 ? false : true;
    }
    return SwitchListTile(
      title: _getTitle(),
      value: pBool ?? value ?? defaultValue!,
      onChanged: pending != null ? null : onChanged,
    );
  }

  Widget? _getTitle() {
    if (pending != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          title!,
          Chip(
            label: const Text('pending'),
            backgroundColor: Colors.red,
            onDeleted: onDeleted,
          )
        ],
      );
    } else {
      return title;
    }
  }
}
