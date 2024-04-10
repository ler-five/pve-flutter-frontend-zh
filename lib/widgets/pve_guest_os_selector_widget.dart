import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pve_flutter_frontend/bloc/pve_guest_os_selector_bloc.dart';
import 'package:proxmox_dart_api_client/proxmox_dart_api_client.dart';

class PveGuestOsSelector extends StatelessWidget {
  const PveGuestOsSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final gBloc = Provider.of<PveGuestOsSelectorBloc>(context);
    return StreamBuilder<PveGuestOsSelectorState>(
        stream: gBloc.state,
        initialData: gBloc.state.value,
        builder: (context, snapshot) {
          return DropdownButtonFormField<OSType>(
            decoration: const InputDecoration(labelText: 'Guest OS'),
            items: gBloc.osChoices.keys
                .map((choice) => DropdownMenuItem(
                      value: choice,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          getIcon(gBloc.osChoices[choice]!['type']),
                          Text(gBloc.osChoices[choice]!['desc']!),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (choice) {
              gBloc.events.add(ChangeOsType(choice));
            },
            value: snapshot.data?.value,
            validator: (_) => snapshot.data?.errorText,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          );
        });
  }

  Widget getIcon(String? osGroup) {
    if (osGroup == "Microsoft Windows") {
      return const Icon(FontAwesomeIcons.windows);
    }

    if (osGroup == "Linux") {
      return const Icon(FontAwesomeIcons.linux);
    }

    return Text(osGroup!);
  }
}
