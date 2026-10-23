import 'package:flutter/material.dart';
import 'package:pve_flutter_frontend/l10n/app_localizations.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context).pageNotFound),
    );
  }
}
