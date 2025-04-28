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
import 'package:pve_flutter_frontend/states/pve_access_management_state.dart';
import 'package:pve_flutter_frontend/states/pve_cluster_status_state.dart';
import 'package:pve_flutter_frontend/states/pve_file_selector_state.dart';
import 'package:pve_flutter_frontend/states/pve_resource_state.dart';
import 'package:pve_flutter_frontend/states/pve_storage_selector_state.dart';
import 'package:pve_flutter_frontend/utils/renderers.dart';
import 'package:pve_flutter_frontend/widgets/colored_safe_area.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_capacity_indicator.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_custom_icon.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_gauge_chart.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_heartbeat_indicator.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_stream_builder_widget.dart';
import 'package:pve_flutter_frontend/widgets/pve_file_selector_widget.dart';
import 'package:pve_flutter_frontend/widgets/pve_guest_icon_widget.dart';
import 'package:pve_flutter_frontend/widgets/pve_help_icon_button_widget.dart';
import 'package:pve_flutter_frontend/widgets/pve_resource_data_card_widget.dart';
import 'package:pve_flutter_frontend/widgets/pve_resource_status_chip_widget.dart';
import 'package:pve_flutter_frontend/widgets/pve_subscription_alert_dialog.dart';
import 'package:pve_flutter_frontend/utils/proxmox_colors.dart';
import 'package:rxdart/rxdart.dart';

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
        onPopInvoked: (didPop) async {
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

Widget getMainContent(snapshot, context) {
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
    final light = Theme.of(context).colorScheme.brightness == Brightness.light;
    return NavigationBar(
        backgroundColor: light ? Colors.white : ProxmoxColors.greyShade40,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          NavigationDestination(
            icon: Icon(Icons.developer_board),
            label: "Resources",
          ),
          NavigationDestination(
            icon: Icon(Icons.supervised_user_circle),
            label: "Access",
          ),
          NavigationDestination(
            icon: Icon(Icons.logout),
            label: "Sites",
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
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proxmox',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            Text(
              'Virtual Environment',
              style: TextStyle(
                fontSize: 14,
              ),
            )
          ],
        ),
        elevation: 0.0,
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
      body: Stack(children: [
        Container(
          height: 350,
          color: Theme.of(context).colorScheme.primary,
        ),
        ProxmoxStreamBuilder<PveClusterStatusBloc, PveClusterStatusState>(
            bloc: cBloc,
            builder: (context, cState) {
              return ListView(children: <Widget>[
                if (cState.cluster != null) ...[
                  ListTile(
                    title: const Text(
                      "Status",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      cState.cluster?.name ?? "Datacenter",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    trailing: SizedBox(
                      width: 96,
                      height: 48,
                      child: ProxmoxHeartbeatIndicator(
                        isHealthy: cState.healthy,
                        healthyColor: Colors.greenAccent,
                        warningColor: Colors.orangeAccent,
                      ),
                    ),
                  ),
                ],
                SizedBox(
                  height: 80,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (cState.missingSubscription)
                        ActionChip(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          avatar: const Icon(Icons.report, color: Colors.red),
                          label: const Text(
                            'Subscription',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (c) => const PveSubscriptionAlertDialog(),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ActionChip(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          avatar: Icon(
                            Renderers.getDefaultResourceIcon('qemu'),
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 20,
                          ),
                          label: const Text(
                            'Virtual Machines',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          onPressed: () {
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ActionChip(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          avatar: Icon(
                            Renderers.getDefaultResourceIcon('lxc'),
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 20,
                          ),
                          label: const Text(
                            'Linux Containers',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          onPressed: () {
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
                        title: const Text(
                          'Analytics',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        subtitle: const Text('Usage across all online nodes'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: ProxmoxGaugeChartListTile(
                              title: const Text('CPU'),
                              subtitle:
                                  Text('$aggrCpus Cores ${nodes.length} Nodes'),
                              legend: Text('$cpuUsagePercent %'),
                              value: aggrCpuUsage,
                              maxValue: aggrCpus,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: ProxmoxGaugeChartListTile(
                              title: const Text('Memory'),
                              subtitle: Text(
                                  '${Renderers.formatSize(aggrMemUsage)} of ${Renderers.formatSize(aggrMem)}'),
                              legend: Text('$memUsagePercent %'),
                              value: aggrMemUsage,
                              maxValue: aggrMem,
                            ),
                          ),
                        ],
                      );
                    }),
                PveResourceDataCardWidget(
                  title: const Text(
                    'Nodes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
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
                        title: const Text(
                          'Guests',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        children: <Widget>[
                          ListTile(
                            title: const Text("Virtual Machines"),
                            trailing: Text(totalVMs.toString()),
                            leading:
                                Icon(Renderers.getDefaultResourceIcon('qemu')),
                            onTap: () {
                              Provider.of<BehaviorSubject<int>>(context,
                                      listen: false)
                                  .add(1);
                              Provider.of<PveResourceBloc>(context,
                                      listen: false)
                                  .events
                                  .add(FilterResources(
                                    typeFilter: BuiltSet.from(['qemu']),
                                  ));
                            },
                          ),
                          ListTile(
                              dense: true,
                              title: const Text(
                                "Online",
                                style: TextStyle(fontSize: 14),
                              ),
                              leading: const Icon(Icons.play_circle_outline,
                                  color: Colors.green),
                              trailing: Text(onlineVMs.length.toString()),
                              onTap: () {
                                Provider.of<BehaviorSubject<int>>(context,
                                        listen: false)
                                    .add(1);
                                Provider.of<PveResourceBloc>(context,
                                        listen: false)
                                    .events
                                    .add(FilterResources(
                                      typeFilter: BuiltSet.from(['qemu']),
                                      statusFilter: BuiltSet.from(
                                          [PveResourceStatusType.running]),
                                    ));
                              }),
                          ListTile(
                            dense: true,
                            title: const Text(
                              "Offline",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            leading: const Icon(Icons.stop),
                            trailing: Text(offVMs.toString()),
                            onTap: () {
                              Provider.of<BehaviorSubject<int>>(context,
                                      listen: false)
                                  .add(1);
                              Provider.of<PveResourceBloc>(context,
                                      listen: false)
                                  .events
                                  .add(FilterResources(
                                    typeFilter: BuiltSet.from(['qemu']),
                                    statusFilter: BuiltSet.from(
                                        [PveResourceStatusType.stopped]),
                                  ));
                            },
                          ),
                          const Divider(
                            indent: 10,
                          ),
                          ListTile(
                            title: const Text("LXC Container"),
                            trailing: Text(totalCTs.toString()),
                            leading:
                                Icon(Renderers.getDefaultResourceIcon('lxc')),
                            onTap: () {
                              Provider.of<BehaviorSubject<int>>(context,
                                      listen: false)
                                  .add(1);
                              Provider.of<PveResourceBloc>(context,
                                      listen: false)
                                  .events
                                  .add(FilterResources(
                                    typeFilter: BuiltSet.from(['lxc']),
                                  ));
                            },
                          ),
                          ListTile(
                            dense: true,
                            title: const Text(
                              "Online",
                              style: TextStyle(fontSize: 14),
                            ),
                            leading: const Icon(Icons.play_circle_outline,
                                color: Colors.green),
                            trailing: Text(onlineCTs.length.toString()),
                            onTap: () {
                              Provider.of<BehaviorSubject<int>>(context,
                                      listen: false)
                                  .add(1);
                              Provider.of<PveResourceBloc>(context,
                                      listen: false)
                                  .events
                                  .add(FilterResources(
                                    typeFilter: BuiltSet.from(['lxc']),
                                    statusFilter: BuiltSet.from(
                                        [PveResourceStatusType.running]),
                                  ));
                            },
                          ),
                          ListTile(
                            dense: true,
                            title: const Text(
                              "Offline",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            leading: const Icon(Icons.stop),
                            trailing: Text(offCTs.toString()),
                            onTap: () {
                              Provider.of<BehaviorSubject<int>>(context,
                                      listen: false)
                                  .add(1);
                              Provider.of<PveResourceBloc>(context,
                                      listen: false)
                                  .events
                                  .add(FilterResources(
                                    typeFilter: BuiltSet.from(['lxc']),
                                    statusFilter: BuiltSet.from(
                                        [PveResourceStatusType.stopped]),
                                  ));
                            },
                          ),
                        ],
                      );
                    }),
              ]);
            }),
      ]),
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
      leading: Icon(
        Renderers.getDefaultResourceIcon(type),
      ),
      title: Text(name),
      subtitle: Text(getNodeTileSubtitle(online, level, ip)),
      trailing: Icon(Icons.power, color: online ? Colors.green : Colors.grey),
      onTap: () => Navigator.pushNamed(context, '/nodes/$name'),
    );
  }

  String getNodeTileSubtitle(bool online, String? level, String? ip) {
    if (online) {
      return '$ip - ${Renderers.renderSupportLevel(level)}';
    }
    return 'offline';
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
          child: ColoredSafeArea(
              child: Scaffold(
            endDrawer: _MobileResourceFilterSheet(),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              title: AppbarSearchTextField(
                onChanged: (filter) =>
                    rBloc.events.add(FilterResources(nameFilter: filter)),
              ),
              actions: const <Widget>[AppBarFilterIconButton()],
            ),
            body: ListView.separated(
              itemCount: fResources.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final resource = fResources[index];
                StatelessWidget listWidget = const ListTile(
                  title: Text('Unkown resource type'),
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
                if (otherCategory(fResources, index)) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          resource.type.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      listWidget,
                    ],
                  );
                } else {
                  return listWidget;
                }
              },
            ),
          )),
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

    return ListTile(
      leading: PveGuestIcon(
        type: resource.type,
        template: resource.template,
        status: status,
      ),
      title: Text(resource.displayName),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(resource.node!),
          StatusChip(
            status: status,
            fontzsize: 12,
          ),
        ],
      ),
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
      title: Text(resource.displayName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(resource.node!),
              StatusChip(
                status: resource.getStatus(),
                fontzsize: 12,
              ),
            ],
          ),
          if (resource.getStatus() == PveResourceStatusType.running &&
              !(usedPercent.isNaN || usedPercent.isInfinite))
            ProxmoxCapacityIndicator(
              usedValue: Renderers.formatSize(resource.disk ?? 0),
              totalValue: Renderers.formatSize(resource.maxdisk ?? 0),
              usedPercent:
                  usedPercent.isNaN || usedPercent.isInfinite ? 0 : usedPercent,
              icon: Icon(
                Renderers.getDefaultResourceIcon(resource.type,
                    shared: resource.shared),
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
        //fillColor: Color(0xFFF1F2F4),
        fillColor: Theme.of(context).colorScheme.surface,
        filled: true,
        isDense: true,
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
      ),
      style: const TextStyle(fontSize: 20),
      onChanged: (value) => widget.onChanged!(value),
      controller: _controller,
    );
  }
}

class _MobileResourceFilterSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rBloc = Provider.of<PveResourceBloc>(context);

    return ProxmoxStreamBuilder<PveResourceBloc, PveResourceState>(
      bloc: rBloc,
      builder: (context, state) => Drawer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 0),
                child: ListTile(
                  title: const Text(
                    'Filter Results',
                  ),
                  trailing: rBloc.isFiltered
                      ? TextButton(
                          onPressed: () => rBloc.events.add(ResetFilter()),
                          child: Text(
                            'Reset',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              const Divider(
                indent: 0,
                endIndent: 0,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                child: Column(
                  children: [
                    const ListTile(
                      title: Text(
                        'Type',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    CheckboxListTile(
                      dense: true,
                      title: Text(
                        'Nodes',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.75)),
                      ),
                      value: state.typeFilter.contains('node'),
                      onChanged: (v) => rBloc.events.add(FilterResources(
                        typeFilter: addOrRemove(v!, 'node', state.typeFilter),
                      )),
                    ),
                    CheckboxListTile(
                      dense: true,
                      title: Text(
                        'Qemu',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.75)),
                      ),
                      value: state.typeFilter.contains('qemu'),
                      onChanged: (v) => rBloc.events.add(FilterResources(
                        typeFilter: addOrRemove(v!, 'qemu', state.typeFilter),
                      )),
                    ),
                    CheckboxListTile(
                      dense: true,
                      title: Text(
                        'LXC',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.75)),
                      ),
                      value: state.typeFilter.contains('lxc'),
                      onChanged: (v) => rBloc.events.add(FilterResources(
                        typeFilter: addOrRemove(v!, 'lxc', state.typeFilter),
                      )),
                    ),
                    CheckboxListTile(
                      dense: true,
                      title: Text(
                        'Storage',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.75)),
                      ),
                      value: state.typeFilter.contains('storage'),
                      onChanged: (v) => rBloc.events.add(FilterResources(
                        typeFilter:
                            addOrRemove(v!, 'storage', state.typeFilter),
                      )),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                child: Column(
                  children: [
                    const ListTile(
                      title: Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    CheckboxListTile(
                      dense: true,
                      title: Text(
                        'Online',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.75)),
                      ),
                      value: state.statusFilter
                          .contains(PveResourceStatusType.running),
                      onChanged: (v) => rBloc.events.add(FilterResources(
                        statusFilter: addOrRemove(v!,
                            PveResourceStatusType.running, state.statusFilter),
                      )),
                    ),
                    CheckboxListTile(
                      dense: true,
                      title: Text(
                        'Offline',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.75)),
                      ),
                      value: state.statusFilter
                          .contains(PveResourceStatusType.stopped),
                      onChanged: (v) => rBloc.events.add(FilterResources(
                        statusFilter: addOrRemove(v!,
                            PveResourceStatusType.stopped, state.statusFilter),
                      )),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  BuiltSet<S> addOrRemove<S>(bool value, S element, BuiltSet<S> filter) {
    if (value) {
      return filter.rebuild((b) => b..add(element));
    } else {
      return filter.rebuild((b) => b..remove(element));
    }
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
                ? const Icon(
                    FontAwesomeIcons.filter,
                    color: Colors.black,
                  )
                : const Icon(
                    FontAwesomeIcons.filter,
                    color: Colors.grey,
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
        appBar: AppBar(
          title: const Text('Permissions'),
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
              tabs: const [
                Tab(
                  text: 'Users',
                  icon: Icon(Icons.person),
                ),
                Tab(
                  text: 'API Tokens',
                  icon: Icon(Icons.person_outline),
                ),
                Tab(
                  text: 'Groups',
                  icon: Icon(Icons.group),
                ),
                Tab(
                  text: 'Roles',
                  icon: Icon(Icons.lock_open),
                ),
                Tab(
                  text: 'Domains',
                  icon: Icon(Icons.domain),
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
                ListView.builder(
                    itemCount: aState.tokens.length,
                    itemBuilder: (context, index) {
                      final token = aState.tokens[index];
                      var expireDate = 'infinite';
                      if (token.expire != null) {
                        expireDate = DateFormat.yMd().format(token.expire!);
                      }

                      return ListTile(
                        title: Text('${token.userid} ${token.tokenid}'),
                        subtitle: Text('Expires: $expireDate'),
                      );
                    }),
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
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title:
                                        Text('Group members (${users.length})'),
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
                            ? 'Built in Role'
                            : 'Custom'),
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
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text('Privileges (${perms.length})'),
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
