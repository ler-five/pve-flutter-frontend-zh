import 'package:flutter/material.dart';
import 'package:pve_flutter_frontend/utils/links.dart';
import 'package:pve_flutter_frontend/l10n/app_localizations.dart';

class PveSubscriptionAlertDialog extends StatelessWidget {
  const PveSubscriptionAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).subscription),
      content: Text(AppLocalizations.of(context).subscriptionAlertBody),
      actions: [
        TextButton(
            onPressed: () async {
              await tryLaunchUrl(Links.pvePricing);
            },
            child: Text(AppLocalizations.of(context).getSubscription))
      ],
    );
  }
}
