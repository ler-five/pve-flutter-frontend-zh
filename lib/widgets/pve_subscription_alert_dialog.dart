import 'package:flutter/material.dart';
import 'package:pve_flutter_frontend/utils/links.dart';

class PveSubscriptionAlertDialog extends StatelessWidget {
  const PveSubscriptionAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Subscription'),
      content: const Text(
          'One or more nodes do not have a valid subscription.\n\n'
          'The Proxmox team works very hard to make sure you are running the best'
          ' software and getting stable updates and security enhancements,'
          ' as well as quick enterprise support.\n\nPlease consider to buy a subscription.'),
      actions: [
        TextButton(
            onPressed: () async {
              await tryLaunchUrl(Links.pvePricing);
            },
            child: const Text('Get subscription'))
      ],
    );
  }
}
