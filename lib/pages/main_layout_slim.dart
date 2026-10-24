import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:proxmox_dart_api_client/proxmox_dart_api_client.dart';
import 'package:pve_flutter_frontend/bloc/pve_access_management_bloc.dart';
import 'package:pve_flutter_frontend/bloc/pve_authentication_bloc.dart';
import 'package:pve_flutter_frontend/bloc/pve_cluster_status_bloc.dart';
import 'package:pve_flutter_frontend/bloc/pve_file_selector_bloc.dart';
import 'package:pve_flutter_frontend/bloc/pve_resource_bloc.dart';
import 'package:pve_flutter_frontend/bloc/pve_storage_selector_bloc.dart';
import 'package:pve_flutter_frontend/widgets/pve_mobile_resource_filter_sheet.dart';
import 'package:pve_flutter_frontend/states/pve_access_management_state.dart';
import 'package:pve_flutter_frontend/states/pve_cluster_status_state.dart';
import 'package:pve_flutter_frontend/states/pve_file_selector_state.dart';
import 'package:pve_flutter_frontend/states/pve_resource_state.dart';
import 'package:pve_flutter_frontend/states/pve_storage_selector_state.dart';
import 'package:pve_flutter_frontend/utils/renderers.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_capacity_indicator.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_custom_icon.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_gauge_chart.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_heartbeat_indicator.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_stream_builder_widget.dart';
import 'package:pve_flutter_frontend/widgets/pve_app_bar.dart';
import 'package:pve_flutter_frontend/widgets/pve_file_selector_widget.dart';
import 'package:pve_flutter_frontend/widgets/pve_guest_icon_widget.dart';
import 'package:pve_flutter_frontend/widgets/pve_help_icon_button_widget.dart';
import 'package:pve_flutter_frontend/widgets/pve_resource_data_card_widget.dart';
import 'package:pve_flutter_frontend/widgets/pve_resource_status_chip_widget.dart';
import 'package:pve_flutter_frontend/widgets/pve_subscription_alert_dialog.dart';
import 'package:pve_flutter_frontend/utils/proxmox_colors.dart';
import 'package:rxdart/rxdart.dart';
import 'package:pve_flutter_frontend/l10n/app_localizations.dart';

class MainLayoutSlim extends StatefulWidget {
  const MainLayoutSlim({super.key});

  @override
  _MainLayoutSlimState createState() => _MainLayoutSlimState();
}

class _MainLayoutSlimState extends State<MainLayoutSlim> {
  BehaviorSubject<int> pageSelector = BehaviorSubject.seeded(0);
  @override
  Widget build(BuildContext context) {
    final apiClient = Provider.of<ProxmoxApiClient>(context);
    return MultiProvider(
      providers: [
        Provider.value(
          value: pageSelector,
        ),
        Provider<PveResourceBloc>(
          create: (context) => PveResourceBloc(
            apiClient: apiClient,
            init: PveResourceState.init().rebuild(
              (b) => b
                ..typeFilter.replace({'qemu', 'lxc', 'storage'})
                ..statusFilter.replace(PveResourceStatusType.values),
            ),
          )..events.add(PollResources()),
          dispose: (context, bloc) => bloc.dispose(),
        ),
        Provider<PveAccessManagementBloc>(
          create: (context) => PveAccessManagementBloc(
              apiClient: apiClient,
              init:
                  PveAccessManagementState.init(apiClient.credentials.username))
            ..events.add(LoadUsers()),
          dispose: (context, bloc) => bloc.dispose(),
        )
      ],
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop || pageSelector.value != 0) {
            if (pageSelector.value != 0) pageSelector.add(0);
            return;
          }
          // minimize/return from the app
          SystemNavigator.pop();
        },
        child: StreamBuilder<int>(
          stream: pageSelector.stream,
          initialData: pageSelector.value,
          builder: (context, snapshot) {
            return Scaffold(
              body: getMainContent(snapshot, context),
              // it cannot be const, but depends only on context
              // ignore: prefer_const_constructors
              bottomNavigationBar: PveMobileBottomNavigationbar(),
            );
          },
        ),
      ),
    );
  }

  @override
  dispose() {
    pageSelector.close();
    super.dispose();
  }
}

Widget getMainContent(
  AsyncSnapshot<int> snapshot,
  BuildContext context,
) {
  if (snapshot.hasData) {
    switch (snapshot.data) {
      case 0:
        return const MobileDashboard();
      case 1:
        return const MobileResourceOverview();
      case 2:
        Provider.of<PveAccessManagementBloc>(context).events.add(LoadUsers());
        return const MobileAccessManagement();
      default:
    }
  }
  return Container();
}

class PveMobileBottomNavigationbar extends StatelessWidget {
  const PveMobileBottomNavigationbar({super.key});

  @override
  Widget build(BuildContext context) {
    final pageSelector = Provider.of<BehaviorSubject<int>>(context);
    final l10n = AppLocalizations.of(context);
    return NavigationBar(
        destinations: <Widget>[
          NavigationDestination(
            icon: const Icon(Icons.space_dashboard_outlined),
            selectedIcon: const Icon(Icons.space_dashboard),
            label: l10n.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.developer_board_outlined),
            selectedIcon: const Icon(Icons.developer_board),
            label: l10n.resources,
          ),
          NavigationDestination(
            icon: const Icon(Icons.supervised_user_circle_outlined),
            selectedIcon: const Icon(Icons.supervised_user_circle),
            label: l10n.access,
          ),
          NavigationDestination(
            icon: const Icon(Icons.logout),
            label: l10n.sites,
          ),
        ],
        selectedIndex: pageSelector.value,
        onDestinationSelected: (int index) {
          if (index == 3) {
            Provider.of<PveAuthenticationBloc>(context, listen: false)
                .events
                .add(LoggedOut());
            Navigator.of(context).pushReplacementNamed('/login');
          } else {
            pageSelector.add(index);
          }
        });
  }
}

class MobileDashboard extends StatelessWidget {
  const MobileDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final cBloc = Provider.of<PveClusterStatusBloc>(context);
    final rBloc = Provider.of<PveResourceBloc>(context);
    return Scaffold(
      appBar: PveAppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).proxmox,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            Text(AppLocalizations.of(context).virtualEnvironment,
              style: TextStyle(
                fontSize: 14,
              ),
            )
          ],
        ),
        leading: const Icon(
          ProxmoxIcons.proxmox,
          size: 36,
        ),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          PveHelpIconButton(
              baseUrl: (Provider.of<PveResourceBloc>(context)
                      .apiClient
                      ?.credentials
                      .apiBaseUrl) ??
                  Uri.parse('https://pve.proxmox.com'),
              docPath: 'index.html'),
        ],
      ),
      body: ProxmoxStreamBuilder<PveClusterStatusBloc, PveClusterStatusState>(
          bloc: cBloc,
          builder: (context, cState) {
            return ListView(
                padding: const EdgeInsets.only(bottom: 18),
                children: <Widget>[
                  _ClusterHeroCard(cState: cState),
                  SizedBox(
                    height: 46,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        if (cState.missingSubscription)
                          _DashboardChip(
                            icon: Icons.report_gmailerrorred,
                            label: AppLocalizations.of(context).subscription,
                            color: ProxmoxColors.accentRed,
                            onTap: () => showDialog(
                              context: context,
                              builder: (c) => const PveSubscriptionAlertDialog(),
                            ),
                          ),
                        _DashboardChip(
                          icon: Renderers.getDefaultResourceIcon('qemu'),
                          label: AppLocalizations.of(context).virtualMachines,
                          color: ProxmoxColors.accentCyan,
                          onTap: () {
                            Provider.of<BehaviorSubject<int>>(context,
                                    listen: false)
                                .add(1);
                            Provider.of<PveResourceBloc>(context, listen: false)
                                .events
                                .add(FilterResources(
                                  typeFilter: BuiltSet.from(['qemu']),
                                ));
                          },
                        ),
                        _DashboardChip(
                          icon: Renderers.getDefaultResourceIcon('lxc'),
                          label: AppLocalizations.of(context).containers,
                          color: ProxmoxColors.accentViolet,
                          onTap: () {
                            Provider.of<BehaviorSubject<int>>(context,
                                    listen: false)
                                .add(1);
                            Provider.of<PveResourceBloc>(context, listen: false)
                                .events
                                .add(FilterResources(
                                  typeFilter: BuiltSet.from(['lxc']),
                                ));
                          },
                        ),
                      ],
                    ),
                  ),
                ProxmoxStreamBuilder<PveResourceBloc, PveResourceState>(
                    bloc: rBloc,
                    builder: (context, rState) {
                      final nodes = rState.nodes;
                      var aggrCpus = 0.0;
                      var aggrCpuUsage = 0.0;
                      var aggrMemUsage = 0.0;
                      var aggrMem = 0.0;
                      for (var element in nodes) {
                        aggrCpuUsage +=
                            (element.cpu ?? 0) * (element.maxcpu ?? 0);
                        aggrCpus += element.maxcpu ?? 0;
                        aggrMemUsage += element.mem ?? 0;
                        aggrMem += element.maxmem ?? 0;
                      }
                      final cpuUsagePercent =
                          ((aggrCpuUsage / aggrCpus) * 100).toStringAsFixed(2);
                      final memUsagePercent =
                          ((aggrMemUsage / aggrMem) * 100).toStringAsFixed(2);
                      return PveResourceDataCardWidget(
                        title: Text(AppLocalizations.of(context).analytics,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(AppLocalizations.of(context).usageAcrossAllOnlineNodes),
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: ProxmoxGaugeChartListTile(
                              title: Text(AppLocalizations.of(context).cpu),
                              subtitle: Text(AppLocalizations.of(context)
                                  .coresNodesSummary('$aggrCpus', '${nodes.length}')),
                              legend: Text(AppLocalizations.of(context).cpuusagepercent(cpuUsagePercent)),
                              value: aggrCpuUsage,
                              maxValue: aggrCpus,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: ProxmoxGaugeChartListTile(
                              title: Text(AppLocalizations.of(context).memory),
                              subtitle: Text(
                                  AppLocalizations.of(context).memoryUsageOf(
                                      Renderers.formatSize(aggrMemUsage),
                                      Renderers.formatSize(aggrMem))),
                              legend: Text(AppLocalizations.of(context).memusagepercent(memUsagePercent)),
                              value: aggrMemUsage,
                              maxValue: aggrMem,
                            ),
                          ),
                        ],
                      );
                    }),
                PveResourceDataCardWidget(
                  title: Text(AppLocalizations.of(context).nodes,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                  children: [
                    ...cState.nodes.map((node) {
                      return PveNodeListTile(
                        name: node.name,
                        online: node.online ?? false,
                        type: node.type,
                        level: node.level,
                        ip: node.ip,
                      );
                    }),
                  ],
                ),
                ProxmoxStreamBuilder<PveResourceBloc, PveResourceState>(
                    bloc: rBloc,
                    builder: (context, rState) {
                      final onlineVMs = rState.vms.where((e) =>
                          e.getStatus() == PveResourceStatusType.running);
                      final onlineCTs = rState.container.where((e) =>
                          e.getStatus() == PveResourceStatusType.running);
                      final totalVMs = rState.vms.length;
                      final offVMs = totalVMs - onlineVMs.length;
                      final totalCTs = rState.container.length;
                      final offCTs = totalCTs - onlineCTs.length;
                      return PveResourceDataCardWidget(
                        title: Text(AppLocalizations.of(context).guests,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                        children: <Widget>[
                          _GuestSummaryTile(
                            icon: Renderers.getDefaultResourceIcon('qemu'),
                            label: AppLocalizations.of(context).virtualMachines,
                            total: totalVMs,
                            online: onlineVMs.length,
                            offline: offVMs,
                            color: ProxmoxColors.accentCyan,
                            onTap: () =>
                                openResourceList(context, 'qemu'),
                          ),
                          _GuestSummaryTile(
                            icon: Renderers.getDefaultResourceIcon('lxc'),
                            label: AppLocalizations.of(context).containers,
                            total: totalCTs,
                            online: onlineCTs.length,
                            offline: offCTs,
                            color: ProxmoxColors.accentViolet,
                            onTap: () =>
                                openResourceList(context, 'lxc'),
                          ),
                        ],
                      );
                    }),
            ]);
          }),
    );
  }
}

/// Switches to the resources tab and applies a type filter.
void openResourceList(BuildContext context, String type) {
  Provider.of<BehaviorSubject<int>>(context, listen: false).add(1);
  Provider.of<PveResourceBloc>(context, listen: false)
      .events
      .add(FilterResources(typeFilter: BuiltSet.from([type])));
}

/// Compact cluster header shown at the top of the dashboard.
class _ClusterHeroCard extends StatelessWidget {
  final PveClusterStatusState cState;

  const _ClusterHeroCard({required this.cState});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final healthy = cState.healthy;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF12324A), Color(0xFF101826)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ProxmoxColors.accentCyan.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  cState.cluster?.name ?? l10n.datacenter,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ProxmoxColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: <Widget>[
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: healthy
                            ? ProxmoxColors.accentGreen
                            : ProxmoxColors.accentAmber,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      healthy ? l10n.allRunning : l10n.oneOrMoreNotRunning,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: healthy
                            ? ProxmoxColors.accentGreen
                            : ProxmoxColors.accentAmber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 88,
            height: 40,
            child: ProxmoxHeartbeatIndicator(
              isHealthy: healthy,
              healthyColor: ProxmoxColors.accentGreen,
              warningColor: ProxmoxColors.accentAmber,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small pill shaped shortcut used in the dashboard quick action row.
class _DashboardChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DashboardChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(icon, size: 15, color: color),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ProxmoxColors.textPrimary,
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

/// One-line guest summary: icon, name, online/offline split and total.
class _GuestSummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int total;
  final int online;
  final int offline;
  final Color color;
  final VoidCallback onTap;

  const _GuestSummaryTile({
    required this.icon,
    required this.label,
    required this.total,
    required this.online,
    required this.offline,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 17, color: color),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${l10n.online} $online · ${l10n.offline} $offline',
        style: const TextStyle(fontSize: 11, color: ProxmoxColors.textMuted),
      ),
      trailing: Text(
        '$total',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }
}

class PveNodeListTile extends StatelessWidget {
  final String name;
  final bool online;
  final String type;
  final String? level;
  final String? ip;
  const PveNodeListTile(
      {super.key,
      required this.name,
      required this.online,
      required this.type,
      this.level,
      this.ip = ''});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: ProxmoxColors.accentBlue.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Renderers.getDefaultResourceIcon(type),
          size: 17,
          color: ProxmoxColors.accentBlue,
        ),
      ),
      title: Text(name,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(
        getNodeTileSubtitle(context, online, level, ip),
        style: const TextStyle(fontSize: 11, color: ProxmoxColors.textMuted),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 18,
        color: online ? ProxmoxColors.accentGreen : ProxmoxColors.textMuted,
      ),
      onTap: () => Navigator.pushNamed(context, '/nodes/$name'),
    );
  }

  String getNodeTileSubtitle(
      BuildContext context, bool online, String? level, String? ip) {
    if (online) {
      return '$ip - ${Renderers.renderSupportLevel(level)}';
    }
    return AppLocalizations.of(context).offline;
  }
}

class MobileResourceOverview extends StatelessWidget {
  const MobileResourceOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final rBloc = Provider.of<PveResourceBloc>(context);
    return ProxmoxStreamBuilder<PveResourceBloc, PveResourceState>(
      bloc: rBloc,
      builder: (context, rstate) {
        final fResources = rstate.filterResources.toList();
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            endDrawer: Drawer(
              child: SafeArea(
                child: PveMobileResourceFilterSheet(),
              ),
            ),
            appBar: PveAppBar(
              automaticallyImplyLeading: false,
              title: AppbarSearchTextField(
                onChanged: (filter) =>
                    rBloc.events.add(FilterResources(nameFilter: filter)),
              ),
              actions: const <Widget>[AppBarFilterIconButton()],
            ),
            body: ListView.builder(
              padding: const EdgeInsets.only(top: 2, bottom: 16),
              itemCount: fResources.length,
              itemBuilder: (context, index) {
                final resource = fResources[index];
                StatelessWidget listWidget = ListTile(
                  title: Text(AppLocalizations.of(context).unknownResourceType),
                );
                if (const ['lxc', 'qemu'].contains(resource.type)) {
                  listWidget = PveGuestListTile(resource: resource);
                }
                if (resource.type == 'node') {
                  listWidget = PveNodeListTile(
                    name: resource.node!,
                    online:
                        resource.getStatus() == PveResourceStatusType.running,
                    type: resource.type,
                    level: resource.level,
                  );
                }
                if (resource.type == 'storage') {
                  listWidget = PveStorageListeTile(
                    resource: resource,
                  );
                }
                final card = Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  clipBehavior: Clip.antiAlias,
                  child: listWidget,
                );
                if (otherCategory(fResources, index)) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 3),
                        child: Text(
                          resource.type.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                            color: ProxmoxColors.textMuted,
                          ),
                        ),
                      ),
                      card,
                    ],
                  );
                } else {
                  return card;
                }
              },
            ),
          ),
        );
      },
    );
  }

  bool otherCategory(List<PveClusterResourcesModel> fResources, index) {
    PveClusterResourcesModel? previous;
    if (index > 0) {
      previous = fResources[index - 1];
    }
    final current = fResources[index];
    return previous?.type != current.type;
  }
}

class PveGuestListTile extends StatelessWidget {
  const PveGuestListTile({
    super.key,
    required this.resource,
  });

  final PveClusterResourcesModel resource;

  @override
  Widget build(BuildContext context) {
    final status = resource.getStatus();
    final accent = resource.type == 'lxc'
        ? ProxmoxColors.accentViolet
        : ProxmoxColors.accentCyan;

    return ListTile(
      leading: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: PveGuestIcon(
          type: resource.type,
          template: resource.template ?? false,
          status: status,
          color: accent,
          templateColor: accent,
        ),
      ),
      title: Text(
        resource.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(
          children: <Widget>[
            const Icon(Icons.dns_outlined,
                size: 11, color: ProxmoxColors.textMuted),
            const SizedBox(width: 3),
            Text(
              resource.node ?? '',
              style: const TextStyle(
                  fontSize: 11, color: ProxmoxColors.textMuted),
            ),
            const Spacer(),
            StatusChip(status: status, fontzsize: 10),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right,
          size: 18, color: ProxmoxColors.textMuted),
      onTap: () {
        if (['qemu', 'lxc'].contains(resource.type)) {
          Navigator.pushNamed(
              context, '/nodes/${resource.node}/${resource.id}');
        }
      },
    );
  }
}

class PveStorageListeTile extends StatelessWidget {
  const PveStorageListeTile({
    super.key,
    required this.resource,
  });

  final PveClusterResourcesModel resource;

  @override
  Widget build(BuildContext context) {
    final apiClient = Provider.of<ProxmoxApiClient>(context);
    final usedPercent = (resource.disk ?? 0.0) / (resource.maxdisk ?? 100.0);
    return ListTile(
      title: Text(
        resource.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.dns_outlined,
                  size: 11, color: ProxmoxColors.textMuted),
              const SizedBox(width: 3),
              Text(
                resource.node ?? '',
                style: const TextStyle(
                    fontSize: 11, color: ProxmoxColors.textMuted),
              ),
              const Spacer(),
              StatusChip(
                status: resource.getStatus(),
                fontzsize: 10,
              ),
            ],
          ),
          if (resource.getStatus() == PveResourceStatusType.running &&
              !(usedPercent.isNaN || usedPercent.isInfinite))
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: ProxmoxCapacityIndicator(
                usedValue: Renderers.formatSize(resource.disk ?? 0),
                totalValue: Renderers.formatSize(resource.maxdisk ?? 0),
                usedPercent: usedPercent.isNaN || usedPercent.isInfinite
                    ? 0
                    : usedPercent,
                icon: Icon(
                  Renderers.getDefaultResourceIcon(resource.type,
                      shared: resource.shared),
                ),
              ),
            ),
        ],
      ),
      onTap: resource.getStatus() == PveResourceStatusType.running
          ? () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PveFileSelector(
                  fBloc: PveFileSelectorBloc(
                      apiClient: apiClient,
                      init: PveFileSelectorState.init(nodeID: resource.node)
                          .rebuild((b) => b..storageID = resource.storage)),
                  sBloc: PveStorageSelectorBloc(
                    apiClient: apiClient,
                    init: PveStorageSelectorState.init(nodeID: resource.node)
                        .rebuild((b) => b..storage = resource.storage),
                  )..events.add(LoadStoragesEvent()),
                ),
              ))
          : null,
    );
  }
}

class AppbarSearchTextField extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  const AppbarSearchTextField({super.key, this.onChanged});
  @override
  _AppbarSearchTextFieldState createState() => _AppbarSearchTextFieldState();
}

class _AppbarSearchTextFieldState extends State<AppbarSearchTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.search,
          size: 20,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                padding: EdgeInsets.zero,
                iconSize: 20,
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged!('');
                  FocusScope.of(context).unfocus();
                },
              )
            : null,
        contentPadding: const EdgeInsets.fromLTRB(20, 5, 8, 5),
        prefixIconConstraints:
            const BoxConstraints(minHeight: 32, minWidth: 32),
        suffixIconConstraints:
            const BoxConstraints(maxHeight: 32, maxWidth: 32),
        fillColor: Theme.of(context).colorScheme.surfaceContainer,
        filled: true,
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ProxmoxColors.darkBorder),
        ),
      ),
      style: const TextStyle(fontSize: 15),
      onChanged: (value) => widget.onChanged!(value),
      controller: _controller,
    );
  }
}

class AppBarFilterIconButton extends StatelessWidget {
  const AppBarFilterIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final rBloc = Provider.of<PveResourceBloc>(context);

    return ProxmoxStreamBuilder<PveResourceBloc, PveResourceState>(
        bloc: rBloc,
        builder: (context, state) {
          return IconButton(
            icon: rBloc.isFiltered
                ? const FaIcon(
                    FontAwesomeIcons.filter,
                    color: ProxmoxColors.accentCyan,
                  )
                : const FaIcon(
                    FontAwesomeIcons.filter,
                    color: ProxmoxColors.textMuted,
                  ),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          );
        });
  }
}

class MobileAccessManagement extends StatelessWidget {
  const MobileAccessManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final aBloc = Provider.of<PveAccessManagementBloc>(context);
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: PveAppBar(
          title: Text(AppLocalizations.of(context).permissions),
          //backgroundColor: Colors.transparent,
          elevation: 0.0,
          automaticallyImplyLeading: false,
          bottom: TabBar(
              isScrollable: true,
              unselectedLabelStyle:
                  TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              labelStyle:
                  TextStyle(color: Theme.of(context).colorScheme.secondary),
              indicatorColor: Theme.of(context).colorScheme.secondary,
              tabs: [
                Tab(
                  text: AppLocalizations.of(context).users,
                  icon: const Icon(Icons.person),
                ),
                Tab(
                  text: AppLocalizations.of(context).apiTokens,
                  icon: const Icon(Icons.person_outline),
                ),
                Tab(
                  text: AppLocalizations.of(context).groups,
                  icon: const Icon(Icons.group),
                ),
                Tab(
                  text: AppLocalizations.of(context).roles,
                  icon: const Icon(Icons.lock_open),
                ),
                Tab(
                  text: AppLocalizations.of(context).domains,
                  icon: const Icon(Icons.domain),
                )
              ]),
        ),
        body: ProxmoxStreamBuilder<PveAccessManagementBloc,
                PveAccessManagementState>(
            bloc: aBloc,
            builder: (context, aState) {
              return TabBarView(children: [
                ListView.builder(
                    itemCount: aState.users.length,
                    itemBuilder: (context, index) {
                      final user = aState.users[index];
                      return ListTile(
                        title: Text(user.userid),
                        subtitle: Text(user.email ?? ''),
                        trailing: aState.apiUser == user.userid
                            ? const Icon(Icons.person_pin_circle)
                            : null,
                      );
                    }),
                if (aState.tokens.isEmpty)
                  Align(
                    child: Text(AppLocalizations.of(context).noTokens,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                else
                  ListView.builder(
                      itemCount: aState.tokens.length,
                      itemBuilder: (context, index) {
                        final token = aState.tokens[index];
                        var expireDate = AppLocalizations.of(context).never;
                        if (token.expire != null &&
                            token.expire?.millisecondsSinceEpoch != 0) {
                          expireDate = DateFormat.yMd().format(token.expire!);
                        }

                        return ListTile(
                          title: Text('${token.userid} ${token.tokenid}'),
                          subtitle: Text(AppLocalizations.of(context).expiresExpiredate(expireDate)),
                        );
                      }),
                if (aState.groups.isEmpty)
                  Align(
                    child: Text(AppLocalizations.of(context).noGroups,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                else
                  ListView.builder(
                      itemCount: aState.groups.length,
                      itemBuilder: (context, index) {
                        final group = aState.groups[index];
                        final users = (group.users?.isNotEmpty ?? false)
                            ? group.users!.split(',')
                            : [];
                        return ListTile(
                          title: Text(group.groupid),
                          subtitle: Text(group.comment ?? ''),
                          trailing: const Icon(Icons.arrow_right),
                          onTap: () => showModalBottomSheet(
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10))),
                            context: context,
                            builder: (context) {
                              return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          width: 40,
                                          height: 3,
                                          color: ProxmoxColors.textMuted,
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      title: Text(AppLocalizations.of(context)
                                          .groupMembersCount('${users.length}')),
                                    ),
                                    const Divider(),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(14.0),
                                        child: ListView.builder(
                                          itemCount: users.length,
                                          itemBuilder: (context, index) =>
                                              ListTile(
                                            title: Text(users[index]),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }),
                ListView.builder(
                    itemCount: aState.roles.length,
                    itemBuilder: (context, index) {
                      final role = aState.roles[index];
                      final perms = role.privs.split(',');
                      return ListTile(
                        title: Text(role.roleid),
                        subtitle: Text((role.special ?? false)
                            ? AppLocalizations.of(context).builtInRole
                            : AppLocalizations.of(context).custom),
                        trailing: const Icon(Icons.arrow_right),
                        onTap: () => showModalBottomSheet(
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10))),
                          context: context,
                          builder: (context) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        width: 40,
                                        height: 3,
                                        color: ProxmoxColors.textMuted,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(AppLocalizations.of(context)
                                        .privilegesCount('${perms.length}')),
                                  ),
                                  const Divider(),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(14.0),
                                      child: ListView.builder(
                                        itemCount: perms.length,
                                        itemBuilder: (context, index) =>
                                            ListTile(
                                          title: Text(perms[index]),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    }),
                ListView.builder(
                    itemCount: aState.domains.length,
                    itemBuilder: (context, index) {
                      final domain = aState.domains[index];
                      return ListTile(
                        title: Text(domain.realm),
                        subtitle: Text(domain.comment ?? ''),
                        trailing: domain.tfa?.isNotEmpty ?? false
                            ? const Icon(Icons.looks_two)
                            : null,
                      );
                    }),
              ]);
            }),
      ),
    );
  }
}
