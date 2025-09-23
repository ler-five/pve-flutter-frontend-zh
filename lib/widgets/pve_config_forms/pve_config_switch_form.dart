import 'package:flutter/material.dart';
import 'package:pve_flutter_frontend/widgets/pve_config_list_tile.dart';

class PveConfigSwitchForm extends StatefulWidget {
  const PveConfigSwitchForm({
    super.key,
    required this.value,
    required this.title,
    required this.controller,
  });

  final bool value;
  final String title;
  final PveConfigEditorController<bool> controller;

  @override
  State<PveConfigSwitchForm> createState() => _PveConfigSwitchFormState();
}

class _PveConfigSwitchFormState extends State<PveConfigSwitchForm> {
  late bool _currentValue;

  bool get _isDirty => _currentValue != widget.value;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;

    widget.controller
      ..setValue(_currentValue)
      ..setDirty(false);
  }

  void _handleChanged(bool value) {
    setState(() {
      _currentValue = value;
    });

    widget.controller
      ..setValue(_currentValue)
      ..setDirty(_isDirty);
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(widget.title),
      value: _currentValue,
      onChanged: _handleChanged,
    );
  }
}
