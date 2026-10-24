import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pve_flutter_frontend/utils/proxmox_colors.dart';

/// Compact action tile used on guest overview pages.
///
/// Renders as a small rounded card with a tinted gradient derived from the
/// accent [color], an icon on top and a two-line label below.
class ActionCard extends StatelessWidget {
  final Function? onTap;
  final String? title;
  final Widget? icon;
  final Color? color;

  const ActionCard({
    super.key,
    this.onTap,
    this.title,
    this.icon,
    this.color,
  });

  factory ActionCard.withIcon(String title, IconData icon, Function onTap) {
    return ActionCard(
      title: title,
      icon: Icon(icon),
      onTap: onTap,
    );
  }

  factory ActionCard.withFaIcon(String title, FaIconData icon, Function onTap) {
    return ActionCard(
      title: title,
      icon: FaIcon(icon),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base =
        ProxmoxColors.accentForText(context, color ?? scheme.primary);
    return SizedBox(
      width: 68,
      height: 68,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                base.withValues(alpha: 0.32),
                base.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: base.withValues(alpha: 0.45)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap as void Function()?,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconTheme(
                    data: IconThemeData(color: base, size: 21),
                    child: icon!,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    title!,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 10,
                      height: 1.15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
