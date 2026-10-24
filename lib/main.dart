import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pve_flutter_frontend/pages/pve_settings_page.dart';
import 'package:pve_flutter_frontend/widgets/pve_first_welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proxmox_login_manager/proxmox_login_manager.dart';
import 'package:pve_flutter_frontend/bloc/pve_authentication_bloc.dart';
import 'package:pve_flutter_frontend/bloc/pve_cluster_status_bloc.dart';
import 'package:pve_flutter_frontend/bloc/pve_lxc_overview_bloc.dart';
import 'package:pve_flutter_frontend/bloc/pve_node_overview_bloc.dart';
import 'package:pve_flutter_frontend/bloc/pve_qemu_overview_bloc.dart';
import 'package:pve_flutter_frontend/bloc/pve_resource_bloc.dart';
import 'package:pve_flutter_frontend/bloc/pve_task_log_bloc.dart';
import 'package:pve_flutter_frontend/pages/page_not_found.dart';
import 'package:pve_flutter_frontend/pages/main_layout_slim.dart';
import 'package:pve_flutter_frontend/states/pve_cluster_status_state.dart';
import 'package:pve_flutter_frontend/states/pve_lxc_overview_state.dart';
import 'package:pve_flutter_frontend/states/pve_node_overview_state.dart';
import 'package:pve_flutter_frontend/states/pve_qemu_overview_state.dart';
import 'package:pve_flutter_frontend/states/pve_resource_state.dart';
import 'package:pve_flutter_frontend/states/pve_task_log_state.dart';
import 'package:pve_flutter_frontend/widgets/proxmox_stream_listener.dart';
import 'package:proxmox_dart_api_client/proxmox_dart_api_client.dart'
    as proxclient;

import 'package:pve_flutter_frontend/utils/proxmox_layout_builder.dart';

import 'package:pve_flutter_frontend/bloc/proxmox_global_error_bloc.dart';
import 'package:pve_flutter_frontend/widgets/pve_lxc_overview.dart';
import 'package:pve_flutter_frontend/widgets/pve_node_overview.dart';
import 'package:pve_flutter_frontend/widgets/pve_qemu_overview.dart';
import 'package:pve_flutter_frontend/widgets/pve_splash_screen.dart';
import 'package:pve_flutter_frontend/l10n/app_localizations.dart';
import 'package:proxmox_login_manager/l10n/login_localizations.dart';
import 'package:pve_flutter_frontend/utils/proxmox_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authBloc = PveAuthenticationBloc();
  try {
    final loginStorage = await (ProxmoxLoginStorage.fromLocalStorage());
    final apiClient = await loginStorage!.recoverLatestSession();
    authBloc.events.add(LoggedIn(apiClient));
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    authBloc.events.add(LoggedOut());
  }

  ProxmoxGlobalErrorBloc();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) ProxmoxGlobalErrorBloc().addError(details.exception);
  };
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Provider.debugCheckInvalidValueType = null;

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: authBloc),
        Provider<PveResourceBloc>(
          create: (context) => PveResourceBloc(init: PveResourceState.init()),
          dispose: (context, bloc) => bloc.dispose(),
        ),
      ],
      child: MyApp(
        authbloc: authBloc,
        sharedPreferences: sharedPreferences,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final PveAuthenticationBloc? authbloc;
  final SharedPreferences sharedPreferences;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  MyApp({super.key, this.authbloc, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    return StreamListener<PveAuthenticationState>(
      stream: authbloc!.state,
      onStateChange: (state) {
        if (state is Authenticated) {
          Provider.of<PveResourceBloc>(context, listen: false)
            ..apiClient = state.apiClient
            ..events.add(PollResources());
        }
        if (state is Unauthenticated) {
          Provider.of<PveResourceBloc>(context, listen: false).apiClient = null;
        }
      },
      child: MaterialApp(
        navigatorKey: navigatorKey,
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          LoginLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        title: 'Proxmox',
        // the redesign targets a modern dark UI; light theme kept as fallback
        themeMode: ThemeMode.dark,
        theme: buildAppTheme(Brightness.light),
        darkTheme: buildAppTheme(Brightness.dark),
        builder: (context, child) {
          return StreamListener(
            stream: ProxmoxGlobalErrorBloc().onError.distinct(),
            onStateChange: (dynamic error) async {
              if (!ProxmoxGlobalErrorBloc().dialogVisible) {
                ProxmoxGlobalErrorBloc().dialogVisible = true;

                await showDialog<String>(
                  context: navigatorKey.currentState!.overlay!.context,
                  builder: (BuildContext context) {
                    return StreamBuilder<Object>(
                        stream: ProxmoxGlobalErrorBloc().onError,
                        initialData: error,
                        builder: (context, snapshot) {
                          return AlertDialog(
                            contentPadding: const EdgeInsets.fromLTRB(
                                24.0, 12.0, 24.0, 16.0),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(AppLocalizations.of(context).error),
                                Icon(Icons.warning),
                              ],
                            ),
                            content: SingleChildScrollView(
                              child: Text(snapshot.data?.toString() ?? ''),
                            ),
                          );
                        });
                  },
                );
                ProxmoxGlobalErrorBloc().dialogVisible = false;
              }
            },
            child: child,
          );
        },
        onGenerateRoute: (context) {
          if (authbloc!.state.value is Uninitialized) {
            return MaterialPageRoute(
              builder: (context) => const PveSplashScreen(),
            );
          }
          if (sharedPreferences.getBool('showWelcomeScreen') ?? true) {
            return MaterialPageRoute(
              builder: (context) => const PveWelcome(),
            );
          }

          if (context.name == PveSettingsPage.routePath) {
            return MaterialPageRoute(
              settings: context,
              builder: (context) => PveSettingsPage(),
            );
          }

          if (authbloc!.state.value is Unauthenticated ||
              context.name == '/login') {
            return MaterialPageRoute(
              builder: (context) {
                return StreamListener<PveAuthenticationState>(
                  stream: authbloc!.state,
                  onStateChange: (state) {
                    if (state is Authenticated) {
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                  },
                  child: ProxmoxLoginSelector(
                    onLogin: (client) => authbloc!.events.add(LoggedIn(client)),
                  ),
                );
              },
            );
          }
          if (authbloc!.state.value is Authenticated) {
            final state = authbloc!.state.value as Authenticated;
            if (PveQemuOverview.routeName.hasMatch(context.name!)) {
              final match =
                  PveQemuOverview.routeName.firstMatch(context.name!)!;
              final String nodeID = match.group(1)!;
              final String guestID = match.group(2)!;

              return MaterialPageRoute(
                fullscreenDialog: false,
                settings: context,
                builder: (_) {
                  return MultiProvider(
                    providers: [
                      Provider<PveQemuOverviewBloc>(
                        create: (context) => PveQemuOverviewBloc(
                          guestID: guestID,
                          apiClient: state.apiClient,
                          init: PveQemuOverviewState.init(nodeID),
                        )..events.add(UpdateQemuStatus()),
                        dispose: (context, bloc) => bloc.dispose(),
                      ),
                      Provider<PveTaskLogBloc>(
                        create: (context) => PveTaskLogBloc(
                            apiClient: state.apiClient,
                            init: PveTaskLogState.init(nodeID))
                          ..events.add(FilterTasksByGuestID(guestID: guestID))
                          ..events.add(LoadTasks()),
                        dispose: (context, bloc) => bloc.dispose(),
                      )
                    ],
                    child: PveQemuOverview(
                      guestID: guestID,
                    ),
                  );
                },
              );
            }
            if (PveLxcOverview.routeName.hasMatch(context.name!)) {
              final match = PveLxcOverview.routeName.firstMatch(context.name!)!;
              final String nodeID = match.group(1)!;
              final String guestID = match.group(2)!;

              return MaterialPageRoute(
                fullscreenDialog: false,
                settings: context,
                builder: (_) {
                  return MultiProvider(
                    providers: [
                      Provider<PveLxcOverviewBloc>(
                        create: (context) => PveLxcOverviewBloc(
                          guestID: guestID,
                          apiClient: state.apiClient,
                          init: PveLxcOverviewState.init(nodeID),
                        )..events.add(UpdateLxcStatus()),
                        dispose: (context, bloc) => bloc.dispose(),
                      ),
                      Provider<PveTaskLogBloc>(
                        create: (context) => PveTaskLogBloc(
                            apiClient: state.apiClient,
                            init: PveTaskLogState.init(nodeID))
                          ..events.add(FilterTasksByGuestID(guestID: guestID))
                          ..events.add(LoadTasks()),
                        dispose: (context, bloc) => bloc.dispose(),
                      )
                    ],
                    child: PveLxcOverview(
                      guestID: guestID,
                    ),
                  );
                },
              );
            }

            if (PveNodeOverview.routeName.hasMatch(context.name!)) {
              final match =
                  PveNodeOverview.routeName.firstMatch(context.name!)!;
              final String nodeID = match.group(1)!;
              return MaterialPageRoute(
                fullscreenDialog: false,
                settings: context,
                builder: (context) {
                  final rbloc = Provider.of<PveResourceBloc>(context);
                  return MultiProvider(
                    providers: [
                      Provider<PveNodeOverviewBloc>(
                        create: (context) => PveNodeOverviewBloc(
                          apiClient: state.apiClient,
                          nodeID: nodeID,
                          init: PveNodeOverviewState.init(
                              rbloc.latestState.isStandalone),
                        )..events.add(UpdateNodeStatus()),
                        dispose: (context, bloc) => bloc.dispose(),
                      ),
                      Provider<PveTaskLogBloc>(
                        create: (context) => PveTaskLogBloc(
                            apiClient: state.apiClient,
                            init: PveTaskLogState.init(nodeID))
                          ..events.add(LoadTasks()),
                        dispose: (context, bloc) => bloc.dispose(),
                      )
                    ],
                    child: PveNodeOverview(
                      nodeID: nodeID,
                    ),
                  );
                },
              );
            }
            switch (context.name) {
              case '/':
                return MaterialPageRoute(
                  fullscreenDialog: true,
                  settings: context,
                  builder: (context) => MultiProvider(
                    providers: [
                      Provider<proxclient.ProxmoxApiClient>.value(
                        value: state.apiClient,
                      ),
                      Provider<PveClusterStatusBloc>(
                        create: (context) => PveClusterStatusBloc(
                            apiClient: state.apiClient,
                            init: PveClusterStatusState.init())
                          ..events.add(UpdateClusterStatus()),
                        dispose: (context, bloc) => bloc.dispose(),
                      )
                    ],
                    //TODO add a wide layout option here when it's ready
                    child: ProxmoxLayoutBuilder(
                      builder: (context, layout) => layout != ProxmoxLayout.slim
                          ? const MainLayoutSlim()
                          : const MainLayoutSlim(),
                    ),
                  ),
                );
              default:
                return MaterialPageRoute(
                  settings: context,
                  builder: (context) {
                    return const NotFoundPage();
                  },
                );
            }
          }
          return MaterialPageRoute(
            settings: context,
            builder: (context) {
              return const NotFoundPage();
            },
          );
        },
        initialRoute: '/',
      ),
    );
  }
}

/// Modern, compact theme shared by both brightness modes.
///
/// Dark mode uses a deep charcoal background with vibrant cyan/amber accents,
/// zero-elevation bordered cards and tighter paddings so more content fits on
/// a phone screen.
ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  final scheme = isDark
      ? const ColorScheme.dark(
          primary: ProxmoxColors.accentCyan,
          onPrimary: Color(0xFF06222B),
          primaryContainer: ProxmoxColors.darkSurfaceAlt,
          onPrimaryContainer: ProxmoxColors.accentCyan,
          secondary: ProxmoxColors.accentAmber,
          onSecondary: Color(0xFF241703),
          secondaryContainer: Color(0xFF33260D),
          onSecondaryContainer: ProxmoxColors.accentAmber,
          surface: ProxmoxColors.darkSurface,
          onSurface: ProxmoxColors.textPrimary,
          surfaceContainer: ProxmoxColors.darkSurfaceAlt,
          onSurfaceVariant: ProxmoxColors.textSecondary,
          outline: ProxmoxColors.darkBorder,
          outlineVariant: ProxmoxColors.darkBorder,
          error: ProxmoxColors.accentRed,
          onError: Colors.white,
        )
      : ColorScheme.fromSeed(
          seedColor: ProxmoxColors.supportBlue,
          brightness: Brightness.light,
          primary: ProxmoxColors.supportBlue,
          onPrimary: Colors.white,
          secondary: ProxmoxColors.orange,
          surface: ProxmoxColors.supportGreyTint50,
          onSurface: Colors.black,
          surfaceContainer: ProxmoxColors.supportGreyTint75,
          onSurfaceVariant: ProxmoxColors.supportDarkGrey,
        );

  final bg = isDark ? ProxmoxColors.darkBg : ProxmoxColors.supportGreyTint75;
  final cardColor = isDark ? ProxmoxColors.darkSurface : Colors.white;
  final borderColor =
      isDark ? ProxmoxColors.darkBorder : ProxmoxColors.supportGreyTint50;

  const fontFamily = "Open Sans";
  const radius = BorderRadius.all(Radius.circular(14));

  return ThemeData(
    colorScheme: scheme,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: bg,
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    splashFactory: InkSparkle.splashFactory,
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: borderColor),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: isDark ? ProxmoxColors.textPrimary : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: 52,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: isDark ? ProxmoxColors.textPrimary : Colors.white,
      ),
    ),
    listTileTheme: ListTileThemeData(
      dense: true,
      minVerticalPadding: 4,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
      iconColor: isDark ? ProxmoxColors.textSecondary : ProxmoxColors.grey,
      textColor: isDark ? ProxmoxColors.textPrimary : Colors.black,
    ),
    dividerTheme: DividerThemeData(
      color: borderColor,
      thickness: 1,
      space: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 60,
      backgroundColor: isDark ? ProxmoxColors.darkSurface : Colors.white,
      indicatorColor: scheme.primary.withValues(alpha: isDark ? 0.16 : 0.14),
      elevation: 0,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          fontFamily: fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDark ? ProxmoxColors.textSecondary : ProxmoxColors.grey,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 22,
          color: selected
              ? scheme.primary
              : (isDark ? ProxmoxColors.textMuted : ProxmoxColors.greyTint40),
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: isDark ? ProxmoxColors.darkSurfaceAlt : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.primary, width: 1.4),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: isDark ? ProxmoxColors.darkSurfaceAlt : null,
      side: isDark ? const BorderSide(color: ProxmoxColors.darkBorder) : null,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      labelStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        color: isDark ? ProxmoxColors.textPrimary : Colors.black,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: scheme.primary),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? ProxmoxColors.textPrimary : Colors.black,
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: scheme.primary.withValues(alpha: 0.35),
      selectionHandleColor: scheme.primary,
      cursorColor: scheme.primary,
    ),
    tabBarTheme: TabBarThemeData(
      indicatorColor: scheme.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: scheme.primary,
      unselectedLabelColor:
          isDark ? ProxmoxColors.textSecondary : ProxmoxColors.grey,
      dividerColor: Colors.transparent,
      labelStyle: const TextStyle(
          fontFamily: fontFamily, fontWeight: FontWeight.w600, fontSize: 13),
      unselectedLabelStyle:
          const TextStyle(fontFamily: fontFamily, fontSize: 13),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      showDragHandle: true,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    primaryTextTheme: const TextTheme(
      titleLarge:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700),
    ),
  );
}
