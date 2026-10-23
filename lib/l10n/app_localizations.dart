import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Proxmox'**
  String get appTitle;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @coresNodesSummary.
  ///
  /// In en, this message translates to:
  /// **'{cpus} Cores {nodes} Nodes'**
  String coresNodesSummary(String cpus, String nodes);

  /// No description provided for @groupMembersCount.
  ///
  /// In en, this message translates to:
  /// **'Group members ({count})'**
  String groupMembersCount(String count);

  /// No description provided for @privilegesCount.
  ///
  /// In en, this message translates to:
  /// **'Privileges ({count})'**
  String privilegesCount(String count);

  /// No description provided for @migrationTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Migration {guestId}'**
  String migrationTaskTitle(String guestId);

  /// No description provided for @lastTaskType.
  ///
  /// In en, this message translates to:
  /// **'Last Task: {type}'**
  String lastTaskType(String type);

  /// No description provided for @taskType.
  ///
  /// In en, this message translates to:
  /// **'Task: {type}'**
  String taskType(String type);

  /// No description provided for @cpuInfoSocket.
  ///
  /// In en, this message translates to:
  /// **'CPU Information (Socket: {sockets})'**
  String cpuInfoSocket(String sockets);

  /// No description provided for @packagesReadyToUpdate.
  ///
  /// In en, this message translates to:
  /// **'{count} packages are ready to update'**
  String packagesReadyToUpdate(String count);

  /// No description provided for @diskUsage.
  ///
  /// In en, this message translates to:
  /// **'Usage: {used} {size}'**
  String diskUsage(String used, String size);

  /// No description provided for @cpuMemoryUsage.
  ///
  /// In en, this message translates to:
  /// **'CPU: {cpu}\nMemory: {mem}'**
  String cpuMemoryUsage(String cpu, String mem);

  /// No description provided for @nodePowerWarning.
  ///
  /// In en, this message translates to:
  /// **'A {action} of \'{node}\' might render the node and all its virtual guests unavailable for a prolonged period.'**
  String nodePowerWarning(String action, String node);

  /// No description provided for @pastDuration.
  ///
  /// In en, this message translates to:
  /// **'past {duration}'**
  String pastDuration(String duration);

  /// No description provided for @memoryUsageOf.
  ///
  /// In en, this message translates to:
  /// **'{used} of {total}'**
  String memoryUsageOf(String used, String total);

  /// No description provided for @subscriptionAlertBody.
  ///
  /// In en, this message translates to:
  /// **'One or more nodes do not have a valid subscription. The Proxmox team works very hard to make sure you are running the best software and getting stable updates and security enhancements, as well as quick enterprise support.\n\nPlease consider to buy a subscription.'**
  String get subscriptionAlertBody;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @proxmox.
  ///
  /// In en, this message translates to:
  /// **'Proxmox'**
  String get proxmox;

  /// No description provided for @virtualEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Virtual Environment'**
  String get virtualEnvironment;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @virtualMachines.
  ///
  /// In en, this message translates to:
  /// **'Virtual Machines'**
  String get virtualMachines;

  /// No description provided for @containers.
  ///
  /// In en, this message translates to:
  /// **'Containers'**
  String get containers;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @usageAcrossAllOnlineNodes.
  ///
  /// In en, this message translates to:
  /// **'Usage across all online nodes'**
  String get usageAcrossAllOnlineNodes;

  /// No description provided for @cpu.
  ///
  /// In en, this message translates to:
  /// **'CPU'**
  String get cpu;

  /// No description provided for @cpuusagepercent.
  ///
  /// In en, this message translates to:
  /// **'{cpuUsagePercent} %'**
  String cpuusagepercent(String cpuUsagePercent);

  /// No description provided for @memory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get memory;

  /// No description provided for @memusagepercent.
  ///
  /// In en, this message translates to:
  /// **'{memUsagePercent} %'**
  String memusagepercent(String memUsagePercent);

  /// No description provided for @nodes.
  ///
  /// In en, this message translates to:
  /// **'Nodes'**
  String get nodes;

  /// No description provided for @guests.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get guests;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @unknownResourceType.
  ///
  /// In en, this message translates to:
  /// **'Unknown resource type'**
  String get unknownResourceType;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @noTokens.
  ///
  /// In en, this message translates to:
  /// **'No Tokens'**
  String get noTokens;

  /// No description provided for @expiresExpiredate.
  ///
  /// In en, this message translates to:
  /// **'Expires: {expireDate}'**
  String expiresExpiredate(String expireDate);

  /// No description provided for @noGroups.
  ///
  /// In en, this message translates to:
  /// **'No Groups'**
  String get noGroups;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found!'**
  String get pageNotFound;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @couldNotLaunchPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Could not launch privacy policy'**
  String get couldNotLaunchPrivacyPolicy;

  /// No description provided for @proxmoxForum.
  ///
  /// In en, this message translates to:
  /// **'Proxmox Forum'**
  String get proxmoxForum;

  /// No description provided for @couldNotOpenForum.
  ///
  /// In en, this message translates to:
  /// **'Could not open forum'**
  String get couldNotOpenForum;

  /// No description provided for @reportABug.
  ///
  /// In en, this message translates to:
  /// **'Report a bug'**
  String get reportABug;

  /// No description provided for @couldNotOpenBugzilla.
  ///
  /// In en, this message translates to:
  /// **'Could not open bugzilla'**
  String get couldNotOpenBugzilla;

  /// No description provided for @job.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get job;

  /// No description provided for @enjoyTheApp.
  ///
  /// In en, this message translates to:
  /// **'Enjoy the app'**
  String get enjoyTheApp;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @ifYouHaveSuggestionsOrExperienceAnyProblemsPlease.
  ///
  /// In en, this message translates to:
  /// **'If you have suggestions or experience any problems, please contact us via'**
  String get ifYouHaveSuggestionsOrExperienceAnyProblemsPlease;

  /// No description provided for @forum.
  ///
  /// In en, this message translates to:
  /// **'Forum'**
  String get forum;

  /// No description provided for @userMailingList.
  ///
  /// In en, this message translates to:
  /// **'User Mailing List'**
  String get userMailingList;

  /// No description provided for @proxmoxVirtualEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Proxmox Virtual Environment'**
  String get proxmoxVirtualEnvironment;

  /// No description provided for @totalTotalvalue.
  ///
  /// In en, this message translates to:
  /// **'Total: {totalValue}'**
  String totalTotalvalue(String totalValue);

  /// No description provided for @useCdDvdDiscImageFileIso.
  ///
  /// In en, this message translates to:
  /// **'Use CD/DVD disc image file (iso)'**
  String get useCdDvdDiscImageFileIso;

  /// No description provided for @usePhysicalCdDvdDrive.
  ///
  /// In en, this message translates to:
  /// **'Use physical CD/DVD Drive'**
  String get usePhysicalCdDvdDrive;

  /// No description provided for @doNotUseAnyMedia.
  ///
  /// In en, this message translates to:
  /// **'Do not use any media'**
  String get doNotUseAnyMedia;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'pending'**
  String get pending;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @spice.
  ///
  /// In en, this message translates to:
  /// **'SPICE'**
  String get spice;

  /// No description provided for @openSpiceConnectionFileWithExternalApp.
  ///
  /// In en, this message translates to:
  /// **'Open SPICE connection file with external App'**
  String get openSpiceConnectionFileWithExternalApp;

  /// No description provided for @gotException.
  ///
  /// In en, this message translates to:
  /// **'Got Exception'**
  String get gotException;

  /// No description provided for @openConsoleView.
  ///
  /// In en, this message translates to:
  /// **'Open console view'**
  String get openConsoleView;

  /// No description provided for @aTlsErrorHasOccurred.
  ///
  /// In en, this message translates to:
  /// **'A TLS error has occurred:'**
  String get aTlsErrorHasOccurred;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error Message:'**
  String get errorMessage;

  /// No description provided for @certificateInformation.
  ///
  /// In en, this message translates to:
  /// **'Certificate Information:'**
  String get certificateInformation;

  /// No description provided for @issuedTo.
  ///
  /// In en, this message translates to:
  /// **'Issued to:'**
  String get issuedTo;

  /// No description provided for @fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint:'**
  String get fingerprint;

  /// No description provided for @doYouWantToContinue.
  ///
  /// In en, this message translates to:
  /// **'Do you want to continue?'**
  String get doYouWantToContinue;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @noStorageAvailable.
  ///
  /// In en, this message translates to:
  /// **'No storage available'**
  String get noStorageAvailable;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// No description provided for @storageOffline.
  ///
  /// In en, this message translates to:
  /// **'Storage offline'**
  String get storageOffline;

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothingFound;

  /// No description provided for @pleaseSelectAStorage.
  ///
  /// In en, this message translates to:
  /// **'Please select a storage'**
  String get pleaseSelectAStorage;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @prev.
  ///
  /// In en, this message translates to:
  /// **'Prev'**
  String get prev;

  /// No description provided for @backupGuestid.
  ///
  /// In en, this message translates to:
  /// **'Backup {guestID}'**
  String backupGuestid(String guestID);

  /// No description provided for @recentBackups.
  ///
  /// In en, this message translates to:
  /// **'Recent backups'**
  String get recentBackups;

  /// No description provided for @backupNow.
  ///
  /// In en, this message translates to:
  /// **'Backup now'**
  String get backupNow;

  /// No description provided for @noExistingBackupFileForGuestFound.
  ///
  /// In en, this message translates to:
  /// **'No existing backup file for guest found'**
  String get noExistingBackupFileForGuestFound;

  /// No description provided for @pleaseSelectATargetStorage.
  ///
  /// In en, this message translates to:
  /// **'Please select a target storage'**
  String get pleaseSelectATargetStorage;

  /// No description provided for @selection.
  ///
  /// In en, this message translates to:
  /// **'Selection:'**
  String get selection;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @showConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Show Configuration'**
  String get showConfiguration;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @configuration.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configuration;

  /// No description provided for @scheduleBackup.
  ///
  /// In en, this message translates to:
  /// **'Schedule backup'**
  String get scheduleBackup;

  /// No description provided for @startBackupNow.
  ///
  /// In en, this message translates to:
  /// **'Start backup now'**
  String get startBackupNow;

  /// No description provided for @backupGuestid2.
  ///
  /// In en, this message translates to:
  /// **'Backup {guestId}'**
  String backupGuestid2(String guestId);

  /// No description provided for @errorCouldNotStartBackup.
  ///
  /// In en, this message translates to:
  /// **'Error: Could not start backup'**
  String get errorCouldNotStartBackup;

  /// No description provided for @migration.
  ///
  /// In en, this message translates to:
  /// **'Migration'**
  String get migration;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @haState.
  ///
  /// In en, this message translates to:
  /// **'HA State'**
  String get haState;

  /// No description provided for @noRrdData.
  ///
  /// In en, this message translates to:
  /// **'no rrd data'**
  String get noRrdData;

  /// No description provided for @pageOf2.
  ///
  /// In en, this message translates to:
  /// **'{page} of 2'**
  String pageOf2(String page);

  /// No description provided for @couldNotOpenDocs.
  ///
  /// In en, this message translates to:
  /// **'Could not open Docs'**
  String get couldNotOpenDocs;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @startShutdownOrder.
  ///
  /// In en, this message translates to:
  /// **'Start/Shutdown order'**
  String get startShutdownOrder;

  /// No description provided for @osType.
  ///
  /// In en, this message translates to:
  /// **'OS Type'**
  String get osType;

  /// No description provided for @architecture.
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get architecture;

  /// No description provided for @ttyCount.
  ///
  /// In en, this message translates to:
  /// **'TTY Count'**
  String get ttyCount;

  /// No description provided for @consoleMode.
  ///
  /// In en, this message translates to:
  /// **'Console Mode'**
  String get consoleMode;

  /// No description provided for @unprivileged.
  ///
  /// In en, this message translates to:
  /// **'Unprivileged'**
  String get unprivileged;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @template.
  ///
  /// In en, this message translates to:
  /// **'TEMPLATE'**
  String get template;

  /// No description provided for @resources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resources;

  /// No description provided for @swap.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get swap;

  /// No description provided for @cores.
  ///
  /// In en, this message translates to:
  /// **'Cores'**
  String get cores;

  /// No description provided for @network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// No description provided for @dns.
  ///
  /// In en, this message translates to:
  /// **'DNS'**
  String get dns;

  /// No description provided for @dnsDomain.
  ///
  /// In en, this message translates to:
  /// **'DNS Domain'**
  String get dnsDomain;

  /// No description provided for @dnsServer.
  ///
  /// In en, this message translates to:
  /// **'DNS Server'**
  String get dnsServer;

  /// No description provided for @turnOnLxcContainer.
  ///
  /// In en, this message translates to:
  /// **'Turn on LXC container'**
  String get turnOnLxcContainer;

  /// No description provided for @shutdown.
  ///
  /// In en, this message translates to:
  /// **'Shutdown'**
  String get shutdown;

  /// No description provided for @turnOffLxcContainer.
  ///
  /// In en, this message translates to:
  /// **'Turn off LXC container'**
  String get turnOffLxcContainer;

  /// No description provided for @reboot.
  ///
  /// In en, this message translates to:
  /// **'Reboot'**
  String get reboot;

  /// No description provided for @rebootLxcContainer.
  ///
  /// In en, this message translates to:
  /// **'Reboot LXC container'**
  String get rebootLxcContainer;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @stopLxcContainer.
  ///
  /// In en, this message translates to:
  /// **'Stop LXC container'**
  String get stopLxcContainer;

  /// No description provided for @tree.
  ///
  /// In en, this message translates to:
  /// **'Tree'**
  String get tree;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @datacenter.
  ///
  /// In en, this message translates to:
  /// **'Datacenter'**
  String get datacenter;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @userPermissions.
  ///
  /// In en, this message translates to:
  /// **'User/Permissions'**
  String get userPermissions;

  /// No description provided for @newVm.
  ///
  /// In en, this message translates to:
  /// **'new VM'**
  String get newVm;

  /// No description provided for @newCt.
  ///
  /// In en, this message translates to:
  /// **'new CT'**
  String get newCt;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @ceph.
  ///
  /// In en, this message translates to:
  /// **'Ceph'**
  String get ceph;

  /// No description provided for @replication.
  ///
  /// In en, this message translates to:
  /// **'Replication'**
  String get replication;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @firewall.
  ///
  /// In en, this message translates to:
  /// **'Firewall'**
  String get firewall;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @filterResults.
  ///
  /// In en, this message translates to:
  /// **'Filter Results'**
  String get filterResults;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @nodeNodeid.
  ///
  /// In en, this message translates to:
  /// **'Node {nodeID}'**
  String nodeNodeid(String nodeID);

  /// No description provided for @pageOf4.
  ///
  /// In en, this message translates to:
  /// **'{page} of 4'**
  String pageOf4(String page);

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @kernel.
  ///
  /// In en, this message translates to:
  /// **'Kernel'**
  String get kernel;

  /// No description provided for @kernelSamePageMergingKsm.
  ///
  /// In en, this message translates to:
  /// **'Kernel same-page merging (KSM)'**
  String get kernelSamePageMergingKsm;

  /// No description provided for @hdSpaceRoot.
  ///
  /// In en, this message translates to:
  /// **'HD space (root)'**
  String get hdSpaceRoot;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @allRunning.
  ///
  /// In en, this message translates to:
  /// **'All running'**
  String get allRunning;

  /// No description provided for @oneOrMoreNotRunning.
  ///
  /// In en, this message translates to:
  /// **'One or more not running'**
  String get oneOrMoreNotRunning;

  /// No description provided for @updates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updates;

  /// No description provided for @lackingPermissionToQueryUpdates.
  ///
  /// In en, this message translates to:
  /// **'Lacking permission to query updates'**
  String get lackingPermissionToQueryUpdates;

  /// No description provided for @noUpdatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No updates available'**
  String get noUpdatesAvailable;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @disks.
  ///
  /// In en, this message translates to:
  /// **'Disks'**
  String get disks;

  /// No description provided for @noHealthIssues.
  ///
  /// In en, this message translates to:
  /// **'No health issues'**
  String get noHealthIssues;

  /// No description provided for @checkDisksHealthErrorIndicated.
  ///
  /// In en, this message translates to:
  /// **'Check disks, health error indicated!'**
  String get checkDisksHealthErrorIndicated;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @device.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @usage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get usage;

  /// No description provided for @gpt.
  ///
  /// In en, this message translates to:
  /// **'GPT'**
  String get gpt;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @serial.
  ///
  /// In en, this message translates to:
  /// **'Serial'**
  String get serial;

  /// No description provided for @sMART.
  ///
  /// In en, this message translates to:
  /// **'S.M.A.R.T'**
  String get sMART;

  /// No description provided for @wearout.
  ///
  /// In en, this message translates to:
  /// **'Wearout'**
  String get wearout;

  /// No description provided for @rebootNode.
  ///
  /// In en, this message translates to:
  /// **'Reboot Node'**
  String get rebootNode;

  /// No description provided for @shutdownNode.
  ///
  /// In en, this message translates to:
  /// **'Shutdown Node'**
  String get shutdownNode;

  /// No description provided for @capitalizedactiontextNode.
  ///
  /// In en, this message translates to:
  /// **'{capitalizedActionText} node?'**
  String capitalizedactiontextNode(String capitalizedActionText);

  /// No description provided for @bootDevice.
  ///
  /// In en, this message translates to:
  /// **'Boot Device'**
  String get bootDevice;

  /// No description provided for @hotplug.
  ///
  /// In en, this message translates to:
  /// **'Hotplug'**
  String get hotplug;

  /// No description provided for @rtcStartDate.
  ///
  /// In en, this message translates to:
  /// **'RTC start date'**
  String get rtcStartDate;

  /// No description provided for @smbiosSettingsType1.
  ///
  /// In en, this message translates to:
  /// **'SMBIOS settings (type1)'**
  String get smbiosSettingsType1;

  /// No description provided for @qemuGuestAgent.
  ///
  /// In en, this message translates to:
  /// **'QEMU Guest Agent'**
  String get qemuGuestAgent;

  /// No description provided for @spiceEnhancements.
  ///
  /// In en, this message translates to:
  /// **'Spice Enhancements'**
  String get spiceEnhancements;

  /// No description provided for @vmStateStorage.
  ///
  /// In en, this message translates to:
  /// **'VM State Storage'**
  String get vmStateStorage;

  /// No description provided for @hardware.
  ///
  /// In en, this message translates to:
  /// **'Hardware'**
  String get hardware;

  /// No description provided for @processor.
  ///
  /// In en, this message translates to:
  /// **'Processor'**
  String get processor;

  /// No description provided for @bios.
  ///
  /// In en, this message translates to:
  /// **'BIOS'**
  String get bios;

  /// No description provided for @machineType.
  ///
  /// In en, this message translates to:
  /// **'Machine Type'**
  String get machineType;

  /// No description provided for @scsiController.
  ///
  /// In en, this message translates to:
  /// **'SCSI Controller'**
  String get scsiController;

  /// No description provided for @cdDvdDrive.
  ///
  /// In en, this message translates to:
  /// **'CD/DVD Drive'**
  String get cdDvdDrive;

  /// No description provided for @hardDisk.
  ///
  /// In en, this message translates to:
  /// **'Hard Disk'**
  String get hardDisk;

  /// No description provided for @networkDevice.
  ///
  /// In en, this message translates to:
  /// **'Network Device'**
  String get networkDevice;

  /// No description provided for @turnOnQemuVirtualMachine.
  ///
  /// In en, this message translates to:
  /// **'Turn on QEMU virtual machine'**
  String get turnOnQemuVirtualMachine;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @resumeQemuVirtualMachine.
  ///
  /// In en, this message translates to:
  /// **'Resume QEMU virtual machine'**
  String get resumeQemuVirtualMachine;

  /// No description provided for @shutdownQemuVirtualMachine.
  ///
  /// In en, this message translates to:
  /// **'Shutdown QEMU virtual machine'**
  String get shutdownQemuVirtualMachine;

  /// No description provided for @rebootQemuVirtualMachine.
  ///
  /// In en, this message translates to:
  /// **'Reboot QEMU virtual machine'**
  String get rebootQemuVirtualMachine;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @pauseQemuVirtualMachine.
  ///
  /// In en, this message translates to:
  /// **'Pause QEMU virtual machine'**
  String get pauseQemuVirtualMachine;

  /// No description provided for @hibernate.
  ///
  /// In en, this message translates to:
  /// **'Hibernate'**
  String get hibernate;

  /// No description provided for @hibernateQemuVirtualMachine.
  ///
  /// In en, this message translates to:
  /// **'Hibernate QEMU virtual machine'**
  String get hibernateQemuVirtualMachine;

  /// No description provided for @stopQemuVirtualMachine.
  ///
  /// In en, this message translates to:
  /// **'Stop QEMU virtual machine'**
  String get stopQemuVirtualMachine;

  /// No description provided for @resetQemuVirtualMachine.
  ///
  /// In en, this message translates to:
  /// **'Reset QEMU virtual machine'**
  String get resetQemuVirtualMachine;

  /// No description provided for @node.
  ///
  /// In en, this message translates to:
  /// **'Node'**
  String get node;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get action;

  /// No description provided for @getSubscription.
  ///
  /// In en, this message translates to:
  /// **'Get subscription'**
  String get getSubscription;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get startTime;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @shortlog.
  ///
  /// In en, this message translates to:
  /// **'Shortlog'**
  String get shortlog;

  /// No description provided for @moreTasks.
  ///
  /// In en, this message translates to:
  /// **'More Tasks'**
  String get moreTasks;

  /// No description provided for @fullLog.
  ///
  /// In en, this message translates to:
  /// **'Full Log'**
  String get fullLog;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @onlyErrors.
  ///
  /// In en, this message translates to:
  /// **'Only errors'**
  String get onlyErrors;

  /// No description provided for @noTasksFound.
  ///
  /// In en, this message translates to:
  /// **'No tasks found'**
  String get noTasksFound;

  /// No description provided for @loadingLogData.
  ///
  /// In en, this message translates to:
  /// **'Loading log data..'**
  String get loadingLogData;

  /// No description provided for @ioWait.
  ///
  /// In en, this message translates to:
  /// **'I/O wait'**
  String get ioWait;

  /// No description provided for @spiceEmptyReplyTitle.
  ///
  /// In en, this message translates to:
  /// **'Empty reply from SPICE API'**
  String get spiceEmptyReplyTitle;

  /// No description provided for @spiceEmptyReplyBody.
  ///
  /// In en, this message translates to:
  /// **'Ensure you have \"{perm}.Console\" permissions.'**
  String spiceEmptyReplyBody(String perm);

  /// No description provided for @spiceClientRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'SPICE client required'**
  String get spiceClientRequiredTitle;

  /// No description provided for @spiceClientRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'A Spice client-app is required.'**
  String get spiceClientRequiredBody;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid email address'**
  String get pleaseEnterValidEmail;

  /// No description provided for @load.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get load;

  /// No description provided for @powerSettings.
  ///
  /// In en, this message translates to:
  /// **'Power Settings'**
  String get powerSettings;

  /// No description provided for @console.
  ///
  /// In en, this message translates to:
  /// **'Console'**
  String get console;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @guestOs.
  ///
  /// In en, this message translates to:
  /// **'Guest OS'**
  String get guestOs;

  /// No description provided for @emailTo.
  ///
  /// In en, this message translates to:
  /// **'Email to'**
  String get emailTo;

  /// No description provided for @compression.
  ///
  /// In en, this message translates to:
  /// **'Compression'**
  String get compression;

  /// No description provided for @byUser.
  ///
  /// In en, this message translates to:
  /// **'by user'**
  String get byUser;

  /// No description provided for @byType.
  ///
  /// In en, this message translates to:
  /// **'by type'**
  String get byType;

  /// No description provided for @qemu.
  ///
  /// In en, this message translates to:
  /// **'Qemu'**
  String get qemu;

  /// No description provided for @lxc.
  ///
  /// In en, this message translates to:
  /// **'LXC'**
  String get lxc;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @cpuMax.
  ///
  /// In en, this message translates to:
  /// **'CPU ({max})'**
  String cpuMax(String max);

  /// No description provided for @editTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit: {title}'**
  String editTitle(String title);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
