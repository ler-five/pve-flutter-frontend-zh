import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxmox_dart_api_client/proxmox_dart_api_client.dart';
import 'package:pve_flutter_frontend/bloc/pve_resource_bloc.dart';
import 'package:pve_flutter_frontend/states/pve_resource_state.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_stream_builder_widget.dart';
import 'package:pve_flutter_frontend/l10n/app_localizations.dart';

class PveMobileResourceFilterSheet extends StatelessWidget {
  const PveMobileResourceFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final rBloc = Provider.of<PveResourceBloc>(context);
    return ProxmoxStreamBuilder<PveResourceBloc, PveResourceState>(
      bloc: rBloc,
      builder: (context, state) => Drawer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 0),
                child: ListTile(
                  title: Text(AppLocalizations.of(context).filterResults,
                  ),
                  trailing: rBloc.isFiltered
                      ? TextButton(
                          onPressed: () => rBloc.events.add(ResetFilter()),
                          child: Text(AppLocalizations.of(context).reset,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              const Divider(indent: 0, endIndent: 0),
              _PveFilterSheetSection(
                sectionTitle: AppLocalizations.of(context).type,
                items: [
                  _ProxmoxResourceFilterListTile(
                    title: AppLocalizations.of(context).nodes,
                    value: state.typeFilter.contains('node'),
                    onChanged: (v) => rBloc.events.add(
                      FilterResources(
                        typeFilter: _addOrRemove(v!, 'node', state.typeFilter),
                      ),
                    ),
                  ),
                  _ProxmoxResourceFilterListTile(
                    title: AppLocalizations.of(context).qemu,
                    value: state.typeFilter.contains('qemu'),
                    onChanged: (v) => rBloc.events.add(
                      FilterResources(
                        typeFilter: _addOrRemove(v!, 'qemu', state.typeFilter),
                      ),
                    ),
                  ),
                  _ProxmoxResourceFilterListTile(
                    title: AppLocalizations.of(context).lxc,
                    value: state.typeFilter.contains('lxc'),
                    onChanged: (v) => rBloc.events.add(
                      FilterResources(
                        typeFilter: _addOrRemove(v!, 'lxc', state.typeFilter),
                      ),
                    ),
                  ),
                  _ProxmoxResourceFilterListTile(
                    title: AppLocalizations.of(context).storage,
                    value: state.typeFilter.contains('storage'),
                    onChanged: (v) => rBloc.events.add(
                      FilterResources(
                        typeFilter:
                            _addOrRemove(v!, 'storage', state.typeFilter),
                      ),
                    ),
                  ),
                ],
              ),
              _PveFilterSheetSection(
                sectionTitle: AppLocalizations.of(context).status,
                items: [
                  for (var filterItem in [
                    (title: AppLocalizations.of(context).online, type: PveResourceStatusType.running),
                    (title: AppLocalizations.of(context).offline, type: PveResourceStatusType.stopped),
                    (title: AppLocalizations.of(context).paused, type: PveResourceStatusType.paused)
                  ])
                    _ProxmoxResourceFilterListTile(
                      title: filterItem.title,
                      value: state.statusFilter.contains(filterItem.type),
                      onChanged: (v) => rBloc.events.add(
                        FilterResources(
                          statusFilter: _addOrRemove(
                            v!,
                            filterItem.type,
                            state.statusFilter,
                          ),
                        ),
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  BuiltSet<S> _addOrRemove<S>(bool value, S element, BuiltSet<S> filter) {
    if (value) {
      return filter.rebuild((b) => b..add(element));
    } else {
      return filter.rebuild((b) => b..remove(element));
    }
  }
}

class _PveFilterSheetSection extends StatelessWidget {
  const _PveFilterSheetSection({
    required this.items,
    required this.sectionTitle,
  });

  final List<Widget> items;
  final String sectionTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              sectionTitle,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...items,
        ],
      ),
    );
  }
}

class _ProxmoxResourceFilterListTile extends StatelessWidget {
  const _ProxmoxResourceFilterListTile({
    required this.title,
    this.onChanged,
    this.value,
  });

  final String title;
  final ValueChanged<bool?>? onChanged;
  final bool? value;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      dense: true,
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(
                alpha: 0.75,
              ),
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
