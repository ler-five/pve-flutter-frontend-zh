import 'package:flutter/material.dart';

typedef PveConfigEditorBuilder<T> = Widget Function(
  BuildContext context,
  PveConfigEditorController<T> controller,
);

class PveConfigEditorController<T> {
  PveConfigEditorController({
    required void Function(bool) onDirtyChanged,
    required void Function(T) onValueChanged,
  })  : _onDirtyChanged = onDirtyChanged,
        _onValueChanged = onValueChanged;

  final void Function(bool) _onDirtyChanged;
  final void Function(T) _onValueChanged;

  void setDirty(bool value) => _onDirtyChanged(value);
  void setValue(T value) => _onValueChanged(value);
}

class PveConfigListTile<T> extends StatelessWidget {
  const PveConfigListTile({
    super.key,
    required this.title,
    required this.editorBuilder,
    required this.onSubmit,
    this.subtitle,
    this.trailingText,
    this.pending,
    this.onCancelEdit,
  });

  final String title;
  final String? subtitle;
  final String? trailingText;
  final PveConfigEditorBuilder<T> editorBuilder;
  final void Function(T value) onSubmit;
  final VoidCallback? onCancelEdit;
  final int? pending;

  static void _showBottomSheet(
    BuildContext context, {
    required Widget Function(BuildContext) builder,
  }) {
    showModalBottomSheet(context: context, builder: builder, useSafeArea: true);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: pending == null,
      title: pending != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Chip(
                  label: const Text('pending'),
                  backgroundColor: Colors.orange,
                  onDeleted: onCancelEdit,
                ),
              ],
            )
          : Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailingText != null
          ? Text(trailingText!, style: const TextStyle(fontSize: 14))
          : null,
      onTap: pending != null
          ? null
          : () {
              _showBottomSheet(
                context,
                builder: (_) {
                  return _PveConfigEditorForm(
                    title: 'Edit: $title',
                    editorBuilder: editorBuilder,
                    onSubmit: onSubmit,
                  );
                },
              );
            },
    );
  }
}

class _PveConfigEditorForm<T> extends StatefulWidget {
  const _PveConfigEditorForm({
    required this.title,
    required this.editorBuilder,
    required this.onSubmit,
  });

  final String title;
  final PveConfigEditorBuilder<T> editorBuilder;
  final void Function(T value) onSubmit;

  @override
  State<_PveConfigEditorForm<T>> createState() =>
      _PveConfigEditorFormState<T>();
}

class _PveConfigEditorFormState<T> extends State<_PveConfigEditorForm<T>> {
  bool _isDirty = false;
  late T _currentValue;

  late final PveConfigEditorController<T> _controller =
      PveConfigEditorController<T>(
    onDirtyChanged: _handleDirtyChanged,
    onValueChanged: _handleValueChanged,
  );

  void _handleDirtyChanged(bool value) {
    if (_isDirty != value) {
      setState(() {
        _isDirty = value;
      });
    }
  }

  void _handleValueChanged(T value) {
    _currentValue = value;
  }

  void _submit() {
    widget.onSubmit(_currentValue);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
          widget.editorBuilder(context, _controller),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.bottomRight,
            child: FilledButton(
              onPressed: _isDirty ? _submit : null,
              child: const Text('Update'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),);
  }
}
