import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pve_flutter_frontend/utils/proxmox_colors.dart';
import 'package:pve_flutter_frontend/utils/links.dart';
import 'package:pve_flutter_frontend/l10n/app_localizations.dart';

// goodbye
class PveWelcomePageLast extends StatelessWidget {
  const PveWelcomePageLast({super.key, this.onDone});

  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
                      Text(AppLocalizations.of(context).enjoyTheApp),
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
                          child: Text(AppLocalizations.of(context).start),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 1),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      children: [
                        Text(AppLocalizations.of(context).ifYouHaveSuggestionsOrExperienceAnyProblemsPlease,
                          textAlign: TextAlign.center,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton(
                              onPressed: () => {launchUrl(Links.proxmoxForum)},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: ProxmoxColors.supportGrey),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(AppLocalizations.of(context).forum),
                            ),
                            OutlinedButton(
                              onPressed: () => {launchUrl(Links.pveUserList)},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: ProxmoxColors.supportGrey),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(AppLocalizations.of(context).userMailingList),
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
    });
  }
}
