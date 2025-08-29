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
            _PveSettingsSection(
              sectionTitle: 'LEGAL',
              items: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _launchUrl(
                    url: Links.privacyPolicyUrl,
                    onFailure: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Could not launch privacy policy',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            _PveSettingsSection(
              sectionTitle: 'HELP',
              items: [
                ListTile(
                  leading: Icon(Icons.web),
                  trailing: const Icon(Icons.open_in_new),
                  title: const Text('Proxmox Forum'),
                  onTap: () => _launchUrl(
                    url: Links.proxmoxForum,
                    onFailure: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Could not open forum',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.bug_report_outlined),
                  trailing: const Icon(Icons.open_in_new),
                  title: const Text('Report a bug'),
                  onTap: () => _launchUrl(
                    url: Links.bugzillaUri,
                    onFailure: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Could not open bugzilla',
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _launchUrl({
    required Uri url,
    required VoidCallback onFailure,
  }) {
    try {
      tryLaunchUrl(url);
    } catch (_) {
      onFailure();
    }
  }
}

class _PveSettingsSection extends StatelessWidget {
  const _PveSettingsSection({
    required this.sectionTitle,
    required this.items,
  });

  final String sectionTitle;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            sectionTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
}
