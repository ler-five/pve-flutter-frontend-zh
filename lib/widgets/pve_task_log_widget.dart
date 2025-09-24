import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pve_flutter_frontend/bloc/pve_task_log_bloc.dart';
import 'package:pve_flutter_frontend/bloc/pve_task_log_viewer_bloc.dart';
import 'package:pve_flutter_frontend/states/pve_task_log_state.dart';
import 'package:pve_flutter_frontend/states/pve_task_log_viewer_state.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_stream_builder_widget.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_stream_listener.dart';
import 'package:pve_flutter_frontend/widgets/pve_task_log_expansiontile_widget.dart';

class PveTaskLog extends StatefulWidget {
  const PveTaskLog({super.key});

  @override
  _PveTaskLogState createState() => _PveTaskLogState();
}

class _PveTaskLogState extends State<PveTaskLog> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController _userFilterController;
  late TextEditingController _typeFilterController;
  @override
  void initState() {
    super.initState();
    final bloc = Provider.of<PveTaskLogBloc>(context, listen: false);
    final PveTaskLogState state = bloc.latestState;
    _userFilterController = TextEditingController.fromValue(
        TextEditingValue(text: state.userFilter ?? ''));
    _typeFilterController = TextEditingController.fromValue(
        TextEditingValue(text: state.typeFilter ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<PveTaskLogBloc>(context);
    return ProxmoxStreamBuilder<PveTaskLogBloc, PveTaskLogState>(
        bloc: bloc,
        builder: (context, state) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                )
              ],
            ),
            endDrawer: Drawer(
                child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Filters',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'by user',
                          filled: true,
                          prefixIcon: Icon(Icons.person)),
                      onChanged: (newValue) {
                        bloc.events.add(FilterTasksByUser(newValue));
                        bloc.events.add(LoadTasks());
                      },
                      controller: _userFilterController,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'by type',
                          filled: true,
                          prefixIcon: Icon(Icons.description)),
                      onChanged: (newValue) {
                        bloc.events.add(FilterTasksByType(newValue));
                        bloc.events.add(LoadTasks());
                      },
                      controller: _typeFilterController,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Source'),
                      initialValue: state.source,
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      onChanged: (String? newValue) {
                        bloc.events.add(FilterTasksBySource(newValue));
                        bloc.events.add(LoadTasks());
                      },
                      items: <String>[
                        'all',
                        'active',
                        'archive',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    FormField(
                      builder: (FormFieldState<bool> formFieldState) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text("Only errors"),
                          Checkbox(
                            value: state.onlyErrors,
                            onChanged: (value) {
                              formFieldState.didChange(value);
                              bloc.events.add(FilterTasksByError());
                              bloc.events.add(LoadTasks());
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )),
            body: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels >=
                    (0.8 * scrollInfo.metrics.maxScrollExtent)) {
                  if (!state.isLoading) {
                    bloc.events.add(LoadMoreTasks());
                  }
                }
                return false;
              },
              child: state.tasks.isNotEmpty
                  ? ListView.builder(
                      itemCount: state.tasks.length,
                      itemBuilder: (context, index) => PveTaskExpansionTile(
                        task: state.tasks[index],
                      ),
                    )
                  : const Center(
                      child: Text("No tasks found"),
                    ),
            ),
          );
        });
  }
}

class PveTaskLogScrollView extends StatefulWidget {
  final Widget icon;
  final Widget jobTitle;

  const PveTaskLogScrollView({
    super.key,
    required this.icon,
    required this.jobTitle,
  });
  @override
  _PveTaskLogScrollViewState createState() => _PveTaskLogScrollViewState();
}

class _PveTaskLogScrollViewState extends State<PveTaskLogScrollView> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    if (mounted) {
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamListener<PveTaskLogViewerState>(
      stream: Provider.of<PveTaskLogViewerBloc>(context).state.distinct(),
      onStateChange: (newState) {
        if (_scrollController.hasClients) {
          _scrollToBottom();
        }
      },
      child: ProxmoxStreamBuilder<PveTaskLogViewerBloc, PveTaskLogViewerState>(
          bloc: Provider.of<PveTaskLogViewerBloc>(context),
          builder: (context, state) {
            var indicatorColor = Colors.teal.shade500;
            var statusChipColor = Colors.teal.shade100;
            if (state.status?.failed ?? false) {
              indicatorColor = Colors.red;
              statusChipColor = Colors.red.shade100;
            } else if ((state.status?.exitStatus ?? '')
                .startsWith('WARNINGS:')) {
              indicatorColor = Colors.orange;
              statusChipColor = Colors.orange.shade100;
            }
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (state.isBlank)
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text("Loading log data.."),
                      ),
                    ),
                  if (!state.isBlank) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 40,
                          height: 3,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (state.status != null)
                      ListTile(
                        leading: widget.icon,
                        title: AnimatedDefaultTextStyle(
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                          duration: kThemeChangeDuration,
                          child: widget.jobTitle,
                        ),
                        trailing: Chip(
                          label: Text(
                            state.status!.status.name,
                            style: TextStyle(color: indicatorColor),
                          ),
                          backgroundColor: statusChipColor,
                        ),
                      ),
                    const Divider(),
                    if (state.log != null)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: state.log!.lines!.length,
                            itemBuilder: (context, index) {
                              final log = state.log!.lines!;
                              final isLast = index == log.length - 1;
                              final errorLine =
                                  log[index].lineText?.contains('ERROR') ??
                                      false;
                              final warningLine =
                                  log[index].lineText?.contains('WARNING') ??
                                      false;
                              return Card(
                                color: isLast || errorLine
                                    ? indicatorColor
                                    : Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    log[index].lineText ?? '<unknown>',
                                    style: TextStyle(
                                      color: isLast || errorLine
                                          ? Colors.white
                                          : warningLine
                                              ? Colors.orange.shade800
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ]
                ],
              ),
            );
          }),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    }
  }
}
