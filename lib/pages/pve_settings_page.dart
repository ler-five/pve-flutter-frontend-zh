import 'package:flutter/material.dart';
import 'package:proxmox_login_manager/proxmox_general_settings_form.dart';
import 'package:pve_flutter_frontend/utils/links.dart';
import 'package:pve_flutter_frontend/widgets/pve_app_bar.dart';

class PveSettingsPage extends StatelessWidget {
  static final routePath = '/settings';

  const PveSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PveAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProxmoxGeneralSettingsForm(),
            const ListTile(
              title: Text(
                'LEGAL',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () {
                try {
                  tryLaunchUrl(Links.privacyPolicyUrl);
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Could not launch privacy policy',
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
