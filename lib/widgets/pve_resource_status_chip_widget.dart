import 'package:flutter/material.dart';
import 'package:proxmox_dart_api_client/proxmox_dart_api_client.dart';
import 'package:pve_flutter_frontend/l10n/app_localizations.dart';
import 'package:pve_flutter_frontend/utils/proxmox_colors.dart';

/// Compact status pill: a colored dot followed by the localized status text.
class StatusChip extends StatelessWidget {
  final PveResourceStatusType? status;
  final double fontzsize;
  final FontWeight fontWeight;
  final Color offlineColor;
  final Color intermediateColor;

  final Color onlineColor;
  const StatusChip({
    super.key,
    this.status,
    this.fontzsize = 12,
    this.fontWeight = FontWeight.w600,
    this.offlineColor = ProxmoxColors.textMuted,
    this.onlineColor = ProxmoxColors.accentGreen,
    this.intermediateColor = ProxmoxColors.accentAmber,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Color statusColor;
    String statusText;
    switch (status) {
      case PveResourceStatusType.running:
        statusColor = onlineColor;
        statusText = l10n.online;
        break;
      case PveResourceStatusType.stopped:
        statusColor = offlineColor;
        statusText = l10n.offline;
        break;
      case PveResourceStatusType.suspended:
        statusColor = offlineColor;
        statusText = l10n.suspended;
        break;
      case PveResourceStatusType.paused:
        statusColor = intermediateColor;
        statusText = l10n.paused;
        break;
      case PveResourceStatusType.suspending:
        statusColor = intermediateColor;
        statusText = l10n.suspending;
        break;
      case PveResourceStatusType.prelaunch:
        statusColor = offlineColor;
        statusText = l10n.prelaunch;
        break;
      default:
        statusColor = offlineColor;
        statusText = l10n.unknownStatus;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: fontzsize,
              fontWeight: fontWeight,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
