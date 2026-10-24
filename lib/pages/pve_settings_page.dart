import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxmox_login_manager/proxmox_general_settings_form.dart';
import 'package:pve_flutter_frontend/models/pve_app_settings.dart';
import 'package:pve_flutter_frontend/utils/links.dart';
import 'package:pve_flutter_frontend/utils/proxmox_colors.dart';
import 'package:pve_flutter_frontend/widgets/pve_app_bar.dart';
import 'package:pve_flutter_frontend/l10n/app_localizations.dart';

class PveSettingsPage extends StatelessWidget {
  static final routePath = '/settings';

  const PveSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = Provider.of<PveAppSettings>(context);
    return Scaffold(
      appBar: PveAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _PveSettingsSection(
              sectionTitle: l10n.appearance,
              items: [
                ListTile(
                  leading: const Icon(Icons.brightness_6_outlined),
                  title: Text(l10n.themeMode),
                  subtitle: Text(_themeLabel(l10n, settings.themeModeKey)),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => _pickOption(
                    context,
                    title: l10n.themeMode,
                    current: settings.themeModeKey,
                    options: <String, String>{
                      'system': l10n.themeSystem,
                      'light': l10n.themeLight,
                      'dark': l10n.themeDark,
                    },
                    onSelected: settings.setThemeModeKey,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.translate),
                  title: Text(l10n.language),
                  subtitle: Text(_localeLabel(l10n, settings.localeKey)),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => _pickOption(
                    context,
                    title: l10n.language,
                    current: settings.localeKey,
                    options: <String, String>{
                      'system': l10n.languageSystem,
                      'en': l10n.languageEnglish,
                      'zh': l10n.languageSimplifiedChinese,
                      'zh_Hant': l10n.languageTraditionalChinese,
                    },
                    onSelected: settings.setLocaleKey,
                  ),
                ),
              ],
            ),
            ProxmoxGeneralSettingsForm(),
            _PveSettingsSection(
              sectionTitle: l10n.legal,
              items: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(AppLocalizations.of(context).privacyPolicy),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _launchUrl(
                    url: Links.privacyPolicyUrl,
                    onFailure: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)
                              .couldNotLaunchPrivacyPolicy),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            _PveSettingsSection(
              sectionTitle: l10n.help,
              items: [
                ListTile(
                  leading: const Icon(Icons.web),
                  trailing: const Icon(Icons.open_in_new),
                  title: Text(AppLocalizations.of(context).proxmoxForum),
                  onTap: () => _launchUrl(
                    url: Links.proxmoxForum,
                    onFailure: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              AppLocalizations.of(context).couldNotOpenForum),
                        ),
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  trailing: const Icon(Icons.open_in_new),
                  title: Text(AppLocalizations.of(context).reportABug),
                  onTap: () => _launchUrl(
                    url: Links.bugzillaUri,
                    onFailure: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)
                              .couldNotOpenBugzilla),
                        ),
                      );
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  String _themeLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'light':
        return l10n.themeLight;
      case 'dark':
        return l10n.themeDark;
      default:
        return l10n.themeSystem;
    }
  }

  String _localeLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'en':
        return l10n.languageEnglish;
      case 'zh':
        return l10n.languageSimplifiedChinese;
      case 'zh_Hant':
        return l10n.languageTraditionalChinese;
      default:
        return l10n.languageSystem;
    }
  }

  /// Single choice dialog used for both theme mode and language.
  Future<void> _pickOption(
    BuildContext context, {
    required String title,
    required String current,
    required Map<String, String> options,
    required Future<void> Function(String) onSelected,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.entries.map((entry) {
                final selected = entry.key == current;
                return ListTile(
                  dense: true,
                  title: Text(entry.value),
                  trailing: selected
                      ? const Icon(Icons.check,
                          size: 18, color: ProxmoxColors.accentCyan)
                      : null,
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    if (!selected) onSelected(entry.key);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _launchUrl({
    required Uri url,
    required VoidCallback onFailure,
  }) {
    try {
      tryLaunchUrl(url);
    } catch (_) {
      onFailure();
    }
  }
}

class _PveSettingsSection extends StatelessWidget {
  const _PveSettingsSection({
    required this.sectionTitle,
    required this.items,
  });

  final String sectionTitle;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
          child: Text(
            sectionTitle.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: ProxmoxColors.textMutedOf(context),
            ),
          ),
        ),
        ...items,
      ],
    );
  }
}
