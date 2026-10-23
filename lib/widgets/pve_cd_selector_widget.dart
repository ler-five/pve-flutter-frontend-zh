import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pve_flutter_frontend/bloc/pve_cd_selector_bloc.dart';
import 'package:pve_flutter_frontend/bloc/pve_file_selector_bloc.dart';
import 'package:pve_flutter_frontend/bloc/pve_storage_selector_bloc.dart';
import 'package:pve_flutter_frontend/states/pve_file_selector_state.dart';
import 'package:pve_flutter_frontend/states/pve_storage_selector_state.dart';
import 'package:pve_flutter_frontend/widgets/pve_file_selector_widget.dart';
import 'package:proxmox_dart_api_client/proxmox_dart_api_client.dart';
import 'package:pve_flutter_frontend/l10n/app_localizations.dart';

class PveCdSelector extends StatelessWidget {
  const PveCdSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final client = Provider.of<ProxmoxApiClient>(context);
    final cdBloc = Provider.of<PveCdSelectorBloc>(context);

    return StreamBuilder<PveCdSelectorState>(
        stream: cdBloc.state,
        initialData: cdBloc.state.value,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final state = snapshot.data!;
            return RadioGroup(
                groupValue: state.value,
                onChanged: (value) => cdBloc.events.add(ChangeValue(value)),
                child: Column(children: [
                  RadioListTile<CdType>(
                    title: Text(AppLocalizations.of(context).useCdDvdDiscImageFileIso),
                    value: CdType.iso,
                  ),
                  if (state.value == CdType.iso)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: state.hasError
                            ? const BorderSide(color: Colors.red)
                            : null,
                      ),
                      child: Text((state.file == null || state.file!.isEmpty)
                          ? "Choose File"
                          : state.file!),
                      onPressed: () async {
                        final PveNodesStorageContentModel? file =
                            await showDialog(
                                context: context,
                                builder: (context) => PveFileSelector(
                                      fBloc: PveFileSelectorBloc(
                                        apiClient: client,
                                        init: PveFileSelectorState.init()
                                            .rebuild((b) => b
                                              ..fileType =
                                                  PveStorageContentType.iso),
                                      ),
                                      sBloc: PveStorageSelectorBloc(
                                        apiClient: client,
                                        init: PveStorageSelectorState.init()
                                            .rebuild((b) => b
                                              ..content =
                                                  PveStorageContentType.iso),
                                      )..events.add(LoadStoragesEvent()),
                                    ));
                        if (file != null) {
                          cdBloc.events.add(FileSelected(file.volid));
                        }
                      },
                    ),
                  RadioListTile<CdType>(
                    title: Text(AppLocalizations.of(context).usePhysicalCdDvdDrive),
                    value: CdType.cdrom,
                  ),
                  RadioListTile<CdType>(
                    title: Text(AppLocalizations.of(context).doNotUseAnyMedia),
                    value: CdType.none,
                  ),
                ]));
          }

          return Container();
        });
  }
}
