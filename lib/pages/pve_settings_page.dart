import 'package:flutter/material.dart';
import 'package:proxmox_login_manager/proxmox_general_settings_form.dart';
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
          ],
        ),
      ),
    );
  }
}
