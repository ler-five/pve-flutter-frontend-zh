import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pve_flutter_frontend/widgets/firstWelcomeScreen/pve_welcome_common.dart';
import 'package:pve_flutter_frontend/utils/proxmox_colors.dart';
import 'package:pve_flutter_frontend/utils/links.dart';

// FAQ
class PveWelcomePageFAQ extends StatelessWidget {
  const PveWelcomePageFAQ({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PveWelcomePageContent(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PveQuestion(
              text:
                  "How do I connect if I am not using the default port 8006?"),
          const PveAnswer(
              text:
                  "Add the port at the end, separated by a colon. For the default https port add 443."),
          const PveAnswer(
            text: "For example: 192.168.1.10",
            spans: [
              TextSpan(
                  text: ":443",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontStyle: FontStyle.italic))
            ],
          ),
          const PveQuestion(
            text: "What about remote consoles?",
          ),
          const PveAnswer(
              text:
                  "Spice is currently supported, and we also support VNC through noVNC." ),
          const PveQuestion(text: "Which Spice client works?"),
          const PveAnswer(
              text:
                  'Currently only the following 3rd party Spice client works:'),
          Center(
            child: OutlinedButton(
              onPressed: () {
                final link = Platform.isIOS ? Links.aSpiceClient : Links.opaqueApp;
                launchUrl(link);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: ProxmoxColors.supportGrey),
                foregroundColor: Colors.white,
              ),
              child: Text(Platform.isIOS ? "aSPICE Pro" : "Opaque"),
            ),
          ),
        ],
      ),
    );
  }
}
