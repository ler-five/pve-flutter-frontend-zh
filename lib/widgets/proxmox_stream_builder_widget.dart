import 'package:flutter/material.dart';
import 'package:pve_flutter_frontend/states/pve_base_state.dart';

import 'package:pve_flutter_frontend/bloc/proxmox_base_bloc.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_stream_listener.dart';

typedef AsyncWidgetBuilder<S> = Widget Function(BuildContext context, S state);

abstract class ProxmoxBaseStreamBuilder<B extends ProxmoxBaseBloc<dynamic, S>,
    S extends PveBaseState?> extends StatefulWidget {
  final B? bloc;
  final bool? errorHandler;
  const ProxmoxBaseStreamBuilder({super.key, this.bloc, this.errorHandler});

  Widget build(BuildContext context, S state);

  @override
  _ProxmoxBaseStreamBuilderState createState() =>
      _ProxmoxBaseStreamBuilderState();
}

class _ProxmoxBaseStreamBuilderState<B extends ProxmoxBaseBloc<dynamic, S>,
    S extends PveBaseState> extends State<ProxmoxBaseStreamBuilder<B, S?>> {
  @override
  Widget build(BuildContext context) {
    return StreamListener<S>(
      stream: widget.bloc!.state,
      onStateChange: (newState) {
        if (newState.isFailure && widget.errorHandler!) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                newState.errorMessage,
                style: ThemeData.dark().textTheme.labelLarge,
              ),
              backgroundColor: ThemeData.dark().colorScheme.error,
            ),
          );
        }
      },
      child: StreamBuilder<S>(
          stream: widget.bloc!.state,
          initialData: widget.bloc!.initialState,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return widget.build(context, snapshot.data);
            }
            return Container();
          }),
    );
  }
}

class ProxmoxStreamBuilder<B extends ProxmoxBaseBloc<dynamic, S>,
    S extends PveBaseState> extends ProxmoxBaseStreamBuilder<B, S> {
  final AsyncWidgetBuilder<S> builder;

  const ProxmoxStreamBuilder({
    super.key,
    required this.builder,
    super.bloc,
    bool super.errorHandler = true,
  });

  @override
  Widget build(BuildContext context, S state) => builder(context, state);
}
