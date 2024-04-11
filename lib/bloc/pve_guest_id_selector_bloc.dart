import 'dart:async';
import 'package:pve_flutter_frontend/bloc/proxmox_base_bloc.dart';
import 'package:pve_flutter_frontend/states/proxmox_form_field_state.dart';

import 'package:rxdart/rxdart.dart';
import 'package:proxmox_dart_api_client/proxmox_dart_api_client.dart';

class PveGuestIdSelectorBloc
    extends ProxmoxBaseBloc<PveGuestIdSelectorEvent, GuestIdSelectorState> {
  final ProxmoxApiClient apiClient;

  @override
  GuestIdSelectorState get initialState => GuestIdSelectorState();

  PveGuestIdSelectorBloc({required this.apiClient});

  @override
  Stream<GuestIdSelectorState> eventPipe(
    PublishSubject<PveGuestIdSelectorEvent> events,
    Stream<GuestIdSelectorState> Function(PveGuestIdSelectorEvent event)
        pipeInto,
  ) {
    return events
        .debounceTime(const Duration(milliseconds: 150))
        .switchMap(pipeInto);
  }

  @override
  Stream<GuestIdSelectorState> processEvents(
      PveGuestIdSelectorEvent event) async* {
    if (event is PrefetchId) {
      try {
        final id = await apiClient.getNextFreeID();
        yield GuestIdSelectorState(value: id);
      } on ProxmoxApiException {
        yield GuestIdSelectorState(value: null, errorText: "Could not load ID");
      }
    }
    if (event is OnChanged) {
      if (event.id == "") {
        yield GuestIdSelectorState(
            value: event.id, errorText: "Input required");
        return;
      }

      try {
        final id = await apiClient.getNextFreeID(id: event.id);
        yield GuestIdSelectorState(value: id);
      } on ProxmoxApiException catch (e) {
        if (e.details != null && e.details!['vmid'] != null) {
          yield GuestIdSelectorState(
              value: event.id, errorText: e.details!['vmid']);
        }
      }
    }
  }
}

abstract class PveGuestIdSelectorEvent {}

class PrefetchId extends PveGuestIdSelectorEvent {}

class OnChanged extends PveGuestIdSelectorEvent {
  final String id;

  OnChanged(this.id);
}

class GuestIdSelectorState extends PveFormFieldState<String?> {
  GuestIdSelectorState({super.value, super.errorText});
}
