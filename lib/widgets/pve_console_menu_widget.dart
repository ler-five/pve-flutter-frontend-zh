import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:proxmox_dart_api_client/proxmox_dart_api_client.dart';
import 'package:proxmox_login_manager/proxmox_general_settings_model.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:crypto/crypto.dart';
import 'package:pve_flutter_frontend/widgets/pve_app_bar.dart';

class PveConsoleMenu extends StatelessWidget {
  static const platform =
      MethodChannel('com.proxmox.app.pve_flutter_frontend/filesharing');
  final ProxmoxApiClient apiClient;
  final String? guestID;
  final bool? allowSpice;
  final String node;
  final String type;

  const PveConsoleMenu({
    super.key,
    required this.apiClient,
    this.guestID,
    required this.node,
    required this.type,
    this.allowSpice = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        constraints:
            BoxConstraints(minHeight: MediaQuery.of(context).size.height / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if ((Platform.isAndroid || Platform.isIOS) && (allowSpice ?? true))
              ListTile(
                title: const Text(
                  "SPICE",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle:
                    const Text("Open SPICE connection file with external App"),
                onTap: () async {
                  final tempDir = await getTemporaryDirectory();

                  String apiPath;
                  if (['qemu', 'lxc'].contains(type)) {
                    apiPath = '/nodes/$node/$type/$guestID/spiceproxy';
                  } else if (type == 'node') {
                    apiPath = '/nodes/$node/spiceshell';
                  } else {
                    throw 'Unsupported console type "$type", must be one of "qemu", "lxc", "node"';
                  }
                  final response = await apiClient.postRequest(apiPath);
                  final data = json.decode(response.body)['data'];
                  if (data == null) {
                    if (context.mounted) {
                      showTextDialog(context, 'Empty reply from SPICE API',
                          'Ensure you have "${type == 'node' ? 'Sys' : 'VM'}.Console" permissions.');
                    }
                    return;
                  }
                  var filePath = await writeSpiceFile(data, tempDir.path);

                  try {
                    await platform.invokeMethod('shareFile', {
                      'path': filePath,
                      'type': 'application/x-virt-viewer'
                    });
                  } on PlatformException catch (e, s) {
                    if (!context.mounted) return;
                    if (e.code.contains('ActivityNotFoundException')) {
                      showTextDialog(context, 'SPICE client required',
                          'A Spice client-app is required.');
                    } else {
                      debugPrint("$e $s");
                      if (e.message != null) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Got Exception'),
                            content: Text(e.message!),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'))
                            ],
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            if (Platform.isAndroid ||
                Platform.isIOS) // web_view is only available for mobile :(
              ListTile(
                title: const Text(
                  //type == "qemu" ? "noVNC Console" : "xterm.js Console",
                  "noVNC Console", // xterm.js doesn't work that well on mobile
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Open console view"),
                onTap: () => _openNoVncConsole(context, type),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openNoVncConsole(BuildContext context, String type) async {
    if (!['lxc', 'node', 'qemu'].contains(type)) return;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    await Navigator.push(context, _createHTMLConsoleRoute());
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ],
    );
  }

  void showTextDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'))
        ],
      ),
    );
  }

  Future<String> writeSpiceFile(Map data, String path) async {
    var vvFileContent = '[virt-viewer]\n';

    data.forEach((key, value) {
      if (key == 'proxy' && type != 'node') {
        final proxy = apiClient.credentials.apiBaseUrl
            .replace(port: 3128, scheme: 'http');
        vvFileContent += '$key=$proxy\n';
      } else {
        vvFileContent += '$key=$value\n';
      }
    });
    final vvFile = File('$path/vvFile.vv');
    await vvFile.writeAsString(vvFileContent, flush: true);
    return vvFile.path;
  }

  Route _createHTMLConsoleRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => PVEWebConsole(
        apiClient: apiClient,
        node: node,
        guestID: guestID,
        type: type,
      ),
    );
  }
}

class PVEWebConsole extends StatefulWidget {
  final ProxmoxApiClient apiClient;
  final String node;
  final String? guestID;
  final String? type;

  const PVEWebConsole({
    super.key,
    required this.apiClient,
    required this.node,
    this.guestID,
    this.type,
  });

  @override
  PVEWebConsoleState createState() => PVEWebConsoleState();
}

class PVEWebConsoleState extends State<PVEWebConsole> {
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    final ticket = widget.apiClient.credentials.ticket!;
    final baseUrl = widget.apiClient.credentials.apiBaseUrl;

    var consoleUrl =
        "$baseUrl/?novnc=1&node=${widget.node}&isFullscreen=true&resize=scale";
    if (widget.guestID != null) {
      final consoleType = widget.type == 'lxc' ? 'lxc' : 'kvm';
      consoleUrl += "&console=$consoleType&vmid=${widget.guestID}";
    } else {
      consoleUrl += "&console=shell";
    }
    WidgetsFlutterBinding.ensureInitialized();

    return FutureBuilder(
        future: CookieManager.instance().setCookie(
          url: WebUri(consoleUrl),
          name: 'PVEAuthCookie',
          value: ticket,
        ),
        builder: (context, snapshot) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: PveAppBar(),
            body: InAppWebView(
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                final cert = challenge.protectionSpace.sslCertificate;
                final certBytes = cert?.x509Certificate?.encoded;
                final sslError = challenge.protectionSpace.sslError?.message;

                String? issuedTo = cert?.issuedTo?.CName.toString();
                String? hash = certBytes != null
                    ? sha256.convert(certBytes).toString()
                    : null;

                final settings =
                    await ProxmoxGeneralSettingsModel.fromLocalStorage();

                bool trust = false;
                if (hash != null && settings.trustedFingerprints != null) {
                  trust = settings.trustedFingerprints!.contains(hash);
                }

                if (!trust) {
                  // format hash to '01:23:...' format
                  String? formattedHash = hash?.toUpperCase().replaceAllMapped(
                      RegExp(r"[a-zA-Z0-9]{2}"),
                      (match) => "${match.group(0)}:");
                  formattedHash = formattedHash?.substring(
                      0, formattedHash.length - 1); // remove last ':'

                  if (context.mounted) {
                    trust = await showTLSWarning(
                        context,
                        sslError ?? 'An unknown TLS error has occurred',
                        issuedTo ?? 'unknown',
                        formattedHash ?? 'unknown');
                  }
                }

                // save Fingerprint
                if (trust && hash != null) {
                  await settings
                      .rebuild((b) => b..trustedFingerprints.add(hash))
                      .toLocalStorage();
                  print(settings.toJson());
                }

                final action = trust
                    ? ServerTrustAuthResponseAction.PROCEED
                    : ServerTrustAuthResponseAction.CANCEL;
                return ServerTrustAuthResponse(action: action);
              },
              onWebViewCreated: (controller) {
                webViewController = controller;
                controller.loadUrl(
                    urlRequest: URLRequest(url: WebUri(consoleUrl)));
              },
            ),
          );
        });
  }

  Future<bool> showTLSWarning(BuildContext context, String sslError,
      String issuedTo, String hash) async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PopScope(
            // prevent back button from canceling this callback
            canPop: false,
            child: AlertDialog(
                title: const Text('A TLS error has occurred:'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Error Message:'),
                      subtitle: Text(sslError),
                    ),
                    const ListTile(
                      title: Text('Certificate Information:'),
                    ),
                    ListTile(
                      title: const Text('Issued to:'),
                      subtitle: Text(issuedTo),
                    ),
                    ListTile(
                      title: const Text('Fingerprint:'),
                      subtitle: Text(hash),
                    ),
                    const Text(''), // spacer
                    const Text('Do you want to continue?'),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                        Navigator.of(context).pop();
                      },
                      child: const Text('No')),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Yes'))
                ]),
          );
        });
  }
}
