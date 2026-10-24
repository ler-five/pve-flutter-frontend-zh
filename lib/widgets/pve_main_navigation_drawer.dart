import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pve_flutter_frontend/bloc/pve_cluster_status_bloc.dart';
import 'package:pve_flutter_frontend/bloc/pve_resource_bloc.dart';
import 'package:pve_flutter_frontend/states/pve_cluster_status_state.dart';
import 'package:pve_flutter_frontend/states/pve_resource_state.dart';
import 'package:pve_flutter_frontend/utils/renderers.dart';
import 'package:pve_flutter_frontend/widgets/cluster_status_widget.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_tree_widget.dart';
import 'package:pve_flutter_frontend/l10n/app_localizations.dart';

class PveMainNavigationDrawer extends StatelessWidget {
  const PveMainNavigationDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: DefaultTabController(
        initialIndex: 1,
        length: 2,
        child: Column(
          children: <Widget>[
            TabBar(
              tabs: <Widget>[
                Tab(
                  child: Text(AppLocalizations.of(context).tree),
                ),
                Tab(
                  child: Text(AppLocalizations.of(context).actions),
                )
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  StreamBuilder<PveResourceState>(
                    stream: Provider.of<PveResourceBloc>(context).state,
                    initialData:
                        Provider.of<PveResourceBloc>(context).state.value,
                    builder: (context, snapshot) => ProxmoxTreeWidget(
                      data: snapshot.data!.resources
                          .where((resource) =>
                              resource.type == "node" ||
                              resource.type == "pool")
                          .map((resource) => ProxmoxTreeItem(
                              id: resource.id,
                              headerValue: resource.displayName,
                              icon: Icon(
                                Renderers.getDefaultResourceIcon(
                                  resource.type,
                                  shared: resource.shared,
                                ),
                              ),
                              children: snapshot.data!.resources
                                  .where((child) =>
                                      child.node != null &&
                                      resource.id.contains(child.node!) &&
                                      child.type != resource.type)
                                  .map((child) {
                                return ProxmoxTreeItem(
                                  id: child.id,
                                  headerValue: child.displayName,
                                  icon: Icon(
                                    Renderers.getDefaultResourceIcon(
                                      child.type,
                                      shared: child.shared,
                                    ),
                                  ),
                                );
                              }).toList()))
                          .toList(),
                    ),
                  ),
                  ListView(
                    children: <Widget>[
                      DrawerHeader(
                        child: ListTile(
                          leading: const Icon(Icons.cloud),
                          title: Text(AppLocalizations.of(context).datacenter),
                          trailing: PopupMenuButton(
                            icon: const Icon(Icons.settings),
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry>[
                              PopupMenuItem(
                                value: 1,
                                child: ListTile(
                                  title: Text(AppLocalizations.of(context).settings),
                                  onTap: () {
                                    Navigator.pushNamed(context, '/settings');
                                  },
                                ),
                              ),
                              PopupMenuItem(
                                value: 2,
                                child: Text(AppLocalizations.of(context).userPermissions),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StreamBuilder<PveClusterStatusState>(
                            stream: Provider.of<PveClusterStatusBloc>(context)
                                .state,
                            initialData:
                                Provider.of<PveClusterStatusBloc>(context)
                                    .state
                                    .value,
                            builder: (context, snapshot) {
                              final state = snapshot.data!;
                              return ClusterStatus(
                                isHealthy: state.healthy,
                                healthyColor: Colors.greenAccent,
                                warningColor: Colors.orangeAccent,
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                version: state.cluster!.version.toString(),
                              );
                            }),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          OutlinedButton(
                            child: Text(AppLocalizations.of(context).newVm),
                            onPressed: () {
                              Navigator.pushNamed(context, '/qemu/create');
                            },
                          ),
                          // TODO General new button or distinct ones??
                          OutlinedButton(
                            onPressed: null,
                            child: Text(AppLocalizations.of(context).newCt),
                          )
                        ],
                      ),
                      ListTile(
                        leading: Icon(Icons.home),
                        title: Text(AppLocalizations.of(context).overview),
                      ),
                      ListTile(
                        leading: Icon(Icons.timeline),
                        title: Text(AppLocalizations.of(context).performance),
                      ),
                      ListTile(
                        leading: Icon(Icons.storage),
                        title: Text(AppLocalizations.of(context).storage),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: ListTile(
                          leading: Icon(Icons.line_style),
                          title: Text(AppLocalizations.of(context).ceph),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: ListTile(
                          leading: Icon(Icons.content_copy),
                          title: Text(AppLocalizations.of(context).replication),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.save),
                        title: Text(AppLocalizations.of(context).backup),
                      ),
                      ListTile(
                        leading: Icon(Icons.security),
                        title: Text(AppLocalizations.of(context).firewall),
                      ),
                      ListTile(
                        leading: Icon(Icons.help),
                        title: Text(AppLocalizations.of(context).support),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
