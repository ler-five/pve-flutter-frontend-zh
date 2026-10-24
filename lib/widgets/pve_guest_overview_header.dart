import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:proxmox_dart_api_client/proxmox_dart_api_client.dart';
import 'package:pve_flutter_frontend/utils/renderers.dart';
import 'package:pve_flutter_frontend/utils/proxmox_colors.dart';

import 'package:pve_flutter_frontend/widgets/pve_resource_status_chip_widget.dart';
import 'package:pve_flutter_frontend/widgets/pve_rrd_chart_widget.dart';
import 'package:pve_flutter_frontend/utils/utils.dart';
import 'package:pve_flutter_frontend/l10n/app_localizations.dart';

class PveGuestOverviewHeader extends StatelessWidget {
  const PveGuestOverviewHeader({
    super.key,
    required this.width,
    required this.guestID,
    required this.guestStatus,
    required this.guestName,
    required this.guestNodeID,
    required this.guestType,
    required this.template,
    required this.ha,
    this.background,
  });

  final double width;
  final String guestID;
  final String guestType;
  final PveResourceStatusType? guestStatus;
  final String guestName;
  final String guestNodeID;
  final Widget? background;
  final PveHAMangerServiceStatusModel? ha;
  final bool template;
  @override
  Widget build(BuildContext context) {
    final haError = ha?.state == 'error';
    final hasChart = background != null;
    final height = hasChart ? 196.0 : 84.0;
    return Container(
      height: height,
      width: width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF111A2B), Color(0xFF0B0E14)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (hasChart) background!,
          if (hasChart)
            // dark scrim so the overlapping labels stay readable on top of
            // the chart
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Color(0xD90B0E14), Color(0x000B0E14)],
                ),
              ),
            ),
          Positioned(
            left: 14,
            right: 14,
            top: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    StatusChip(status: guestStatus, fontzsize: 11),
                    const SizedBox(width: 8),
                    Icon(
                      Renderers.getDefaultResourceIcon(guestType),
                      size: 14,
                      color: ProxmoxColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        guestID,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ProxmoxColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (ha?.managed ?? false) ...<Widget>[
                      const SizedBox(width: 8),
                      FaIcon(
                        FontAwesomeIcons.heartPulse,
                        size: 12,
                        color: haError
                            ? ProxmoxColors.accentRed
                            : ProxmoxColors.accentGreen,
                      ),
                    ],
                  ],
                ),
                if (hasChart) const SizedBox(height: 6),
                if (!hasChart)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.dns_outlined,
                            size: 13, color: ProxmoxColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          guestNodeID,
                          style: const TextStyle(
                            color: ProxmoxColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PveGuestHeaderRRDPageView extends StatefulWidget {
  final BuiltList<PveGuestRRDdataModel>? rrdData;

  const PveGuestHeaderRRDPageView({super.key, this.rrdData});

  @override
  _PveGuestHeaderRRDPageViewState createState() =>
      _PveGuestHeaderRRDPageViewState();
}

class _PveGuestHeaderRRDPageViewState extends State<PveGuestHeaderRRDPageView> {
  PageController controller = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rrdData == null || widget.rrdData!.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(AppLocalizations.of(context).noRrdData),
        ),
      );
    }
    var rrdData = widget.rrdData! // safety: checked for null above...
        .where((e) => e.time != null);
    const fgColor = ProxmoxColors.textSecondary;
    return ScrollConfiguration(
      behavior: PVEScrollBehavior(),
      child: PageView.builder(
        controller: controller,
        itemCount: 2,
        itemBuilder: (context, item) {
          final page = item + 1;
          final pageIndicator = Text(AppLocalizations.of(context).pageOf2('$page'),
            style: TextStyle(
              color: fgColor,
              fontWeight: FontWeight.w500,
            ),
          );
          return Column(
            children: [
              if (item == 0)
                Expanded(
                  child: PveRRDChart(
                    titlePadding: const EdgeInsets.only(bottom: 80),
                    titleWidth: 150,
                    titleAlignment: CrossAxisAlignment.end,
                    title: AppLocalizations.of(context)
                        .cpuMax('${rrdData.last.maxcpu ?? '-'}'),
                    subtitle: "${(rrdData.last.cpu ?? 0).toStringAsFixed(2)}%",
                    data: rrdData.where((e) => e.cpu != null).map(
                        (e) => Point(e.time!.millisecondsSinceEpoch, e.cpu!)),
                    icon: Icon(Icons.memory, color: fgColor),
                    bottomRight: pageIndicator,
                    dataRenderer: (data) => '${data.toStringAsFixed(2)} %',
                  ),
                ),
              if (item == 1)
                Expanded(
                  child: PveRRDChart(
                    titlePadding: const EdgeInsets.only(bottom: 80),
                    titleWidth: 200,
                    titleAlignment: CrossAxisAlignment.end,
                    title: AppLocalizations.of(context).memory,
                    subtitle: Renderers.formatSize(rrdData.last.mem ?? 0),
                    data: rrdData.where((e) => e.mem != null).map(
                        (e) => Point(e.time!.millisecondsSinceEpoch, e.mem!)),
                    icon: FaIcon(FontAwesomeIcons.memory, color: fgColor),
                    bottomRight: pageIndicator,
                    dataRenderer: (data) => Renderers.formatSize(data),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
