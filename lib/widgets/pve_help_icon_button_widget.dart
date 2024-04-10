import 'package:flutter/material.dart';
import 'package:pve_flutter_frontend/utils/utils.dart';

class PveHelpIconButton extends StatelessWidget {
  final String? docPath;

  final Uri baseUrl;

  const PveHelpIconButton({
    super.key,
    required this.baseUrl,
    this.docPath,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help),
      tooltip: "Documentation",
      onPressed: () {
        try {
          launchDocURL(baseUrl.replace(path: '/pve-docs/$docPath').toString());
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Could not open Docs",
              style: ThemeData.dark().textTheme.labelLarge,
            ),
            backgroundColor: ThemeData.dark().colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
    );
  }
}
