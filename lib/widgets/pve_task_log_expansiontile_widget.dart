import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:proxmox_dart_api_client/proxmox_dart_api_client.dart';
import 'package:pve_flutter_frontend/bloc/pve_task_log_bloc.dart';
import 'package:pve_flutter_frontend/utils/renderers.dart';
import 'package:pve_flutter_frontend/utils/utils.dart';

class PveTaskExpansionTile extends StatefulWidget {
  final Color? errorColor;
  final Color? headerColor;
  final Color? headerColorExpanded;
  final Widget? showMorePage;
  const PveTaskExpansionTile({
    super.key,
    required this.task,
    this.showMorePage,
    this.errorColor,
    this.headerColor,
    this.headerColorExpanded,
  });

  final PveClusterTasksModel task;

  @override
  _PveTaskExpansionTileState createState() => _PveTaskExpansionTileState();
}

class _PveTaskExpansionTileState extends State<PveTaskExpansionTile> {
  late bool isExpanded;
  @override
  void initState() {
    super.initState();
    isExpanded = false;
  }

  @override
  Widget build(BuildContext context) {
    final hasWarnings = widget.task.status.startsWith('WARNINGS:');
    final hasError = widget.task.status != 'RUNNING' &&
        widget.task.status != "OK" &&
        !hasWarnings;
    final isFinished = widget.task.endTime != null;
    final taskLogBloc = Provider.of<PveTaskLogBloc>(context);
    Duration duration;
    if (isFinished) {
      duration = widget.task.endTime!.difference(widget.task.startTime);
    } else {
      duration = DateTime.now().difference(widget.task.startTime);
    }
    final colorScheme = Theme.of(context).colorScheme;
    final errorColor = widget.errorColor ?? colorScheme.error;
    final warningColor = Colors.orange.shade200;
    final headerColor = isExpanded
        ? (widget.headerColorExpanded ?? colorScheme.onSurface)
        : (widget.headerColor ?? colorScheme.onBackground);

    final taskText = widget.showMorePage != null ? 'Last Task' : 'Task';

    return ExpansionTile(
      onExpansionChanged: (value) {
        setState(() {
          isExpanded = value;
        });
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      collapsedBackgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      key: PageStorageKey<PveClusterTasksModel>(widget.task),
      leading: Icon(
        hasError
            ? Icons.warning
            : hasWarnings
                ? Icons.warning_rounded
                : Icons.info,
        color: hasError
            ? errorColor
            : hasWarnings
                ? warningColor
                : headerColor,
      ),
      title: Text(
        '$taskText: ${widget.task.type}',
        style: TextStyle(color: headerColor),
      ),
      subtitle: isFinished
          ? Text(DateFormat.Md().add_Hms().format(widget.task.endTime!),
              style: TextStyle(color: headerColor))
          : LinearProgressIndicator(
              backgroundColor: headerColor.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(headerColor),
            ),
      trailing: Icon(
        Icons.expand_more,
        color: headerColor,
      ),
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.person),
          title: Text(widget.task.user),
          subtitle: const Text('User'),
        ),
        ListTile(
          leading: const Icon(Icons.timer),
          title: Text(
            DateFormat.Md().add_Hms().format(widget.task.startTime),
          ),
          subtitle: const Text('Start time'),
        ),
        ListTile(
          leading: const Icon(Icons.timelapse),
          title: Text(
            Renderers.renderDuration(duration),
          ),
          subtitle: const Text('Duration'),
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: Text(widget.task.status),
          dense: true,
          subtitle: const Text('Shortlog'),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 8),
          child: OverflowBar(
            alignment: MainAxisAlignment.end,
            spacing: 8,
            overflowAlignment: OverflowBarAlignment.end,
            children: <Widget>[
              if (widget.showMorePage != null)
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                      _createTaskLogRoute(taskLogBloc, widget.showMorePage)),
                  icon: const Icon(Icons.format_list_bulleted),
                  label: const Text('More Tasks'),
                ),
              OutlinedButton.icon(
                onPressed: () => showTaskLogBottomSheet(context,
                    taskLogBloc.apiClient, widget.task.node, widget.task.upid),
                icon: const Icon(Icons.article),
                label: const Text(
                  'Full Log',
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Route _createTaskLogRoute(PveTaskLogBloc bloc, Widget? page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page!,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
          ),
          child: child,
        );
      },
    );
  }
}
