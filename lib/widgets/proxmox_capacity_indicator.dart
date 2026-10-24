import 'package:flutter/material.dart';
import 'package:pve_flutter_frontend/l10n/app_localizations.dart';

class ProxmoxCapacityIndicator extends StatelessWidget {
  final Icon? icon;
  final String totalValue;
  final String usedValue;
  final double? usedPercent;
  final Color? indicatorBackgroundColor;
  final Color? textColor;
  final Animation<Color>? valueColor;
  final bool selected;

  const ProxmoxCapacityIndicator(
      {super.key,
      this.icon,
      required this.totalValue,
      required this.usedValue,
      required this.usedPercent,
      this.selected = false,
      this.indicatorBackgroundColor,
      this.textColor,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    if (usedPercent == null || usedPercent!.isNaN || usedPercent!.isInfinite) {
      return Container();
    }
    return Theme(
      data: Theme.of(context).copyWith(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 8.0),
                    child: icon ??
                        Icon(Icons.storage,
                            color: (selected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha: 0.75))),
                  ),
                  Text(usedValue,
                      style: TextStyle(
                          color: textColor ??
                              (selected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant)
                                  .withValues(alpha: 0.66),
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Text(AppLocalizations.of(context).totalTotalvalue(totalValue),
                  style: TextStyle(
                      color: textColor ??
                          (selected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant)
                              .withValues(alpha: 0.66),
                      fontWeight: FontWeight.bold))
            ],
          ),
          LinearProgressIndicator(
            backgroundColor: indicatorBackgroundColor ??
                Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: valueColor ?? getUsageAwareColor(usedPercent),
            value: usedPercent,
          )
        ],
      ),
    );
  }

  AlwaysStoppedAnimation<Color>? getUsageAwareColor(double? usedPercent) {
    if (usedPercent == null) {
      return null;
    }

    if (usedPercent < 0.75) {
      return AlwaysStoppedAnimation<Color>(Colors.green[400]!);
    } else if (usedPercent < 0.85) {
      return const AlwaysStoppedAnimation<Color>(Colors.yellow);
    } else {
      return const AlwaysStoppedAnimation<Color>(Colors.red);
    }
  }
}
