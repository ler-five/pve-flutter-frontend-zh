import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pve_flutter_frontend/utils/proxmox_colors.dart';

// goodbye
class PveWelcomePageLast extends StatelessWidget {
  const PveWelcomePageLast({Key? key, this.onDone}) : super(key: key);

  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return Container(child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Spacer(flex: 3),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Enjoy the app"),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.emoji_people_rounded,
                          color: Colors.white,
                          size: 70,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () => {onDone!()},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ProxmoxColors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Start"),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 1),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      children: [
                        const Text(
                          'If you have suggestions or experience any problems, please contact us via',
                          textAlign: TextAlign.center,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton(
                              onPressed: () =>
                                  {launch('https://forum.proxmox.com')},
                              child: const Text('Forum'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: ProxmoxColors.supportGrey),
                                foregroundColor: Colors.white,
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () => {
                                launch(
                                    'https://lists.proxmox.com/cgi-bin/mailman/listinfo/pve-user')
                              },
                              child: const Text('User Mailing List'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: ProxmoxColors.supportGrey),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(
                    flex: 2,
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }));
  }
}
