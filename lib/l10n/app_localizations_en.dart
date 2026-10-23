// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Proxmox';

  @override
  String get errorTitle => 'Error';

  @override
  String coresNodesSummary(String cpus, String nodes) {
    return '$cpus Cores $nodes Nodes';
  }

  @override
  String groupMembersCount(String count) {
    return 'Group members ($count)';
  }

  @override
  String privilegesCount(String count) {
    return 'Privileges ($count)';
  }

  @override
  String migrationTaskTitle(String guestId) {
    return 'Migration $guestId';
  }

  @override
  String lastTaskType(String type) {
    return 'Last Task: $type';
  }

  @override
  String taskType(String type) {
    return 'Task: $type';
  }

  @override
  String cpuInfoSocket(String sockets) {
    return 'CPU Information (Socket: $sockets)';
  }

  @override
  String packagesReadyToUpdate(String count) {
    return '$count packages are ready to update';
  }

  @override
  String diskUsage(String used, String size) {
    return 'Usage: $used $size';
  }

  @override
  String cpuMemoryUsage(String cpu, String mem) {
    return 'CPU: $cpu\nMemory: $mem';
  }

  @override
  String nodePowerWarning(String action, String node) {
    return 'A $action of \'$node\' might render the node and all its virtual guests unavailable for a prolonged period.';
  }

  @override
  String pastDuration(String duration) {
    return 'past $duration';
  }

  @override
  String memoryUsageOf(String used, String total) {
    return '$used of $total';
  }

  @override
  String get subscriptionAlertBody =>
      'One or more nodes do not have a valid subscription. The Proxmox team works very hard to make sure you are running the best software and getting stable updates and security enhancements, as well as quick enterprise support.\n\nPlease consider to buy a subscription.';

  @override
  String get error => 'Error';

  @override
  String get proxmox => 'Proxmox';

  @override
  String get virtualEnvironment => 'Virtual Environment';

  @override
  String get status => 'Status';

  @override
  String get subscription => 'Subscription';

  @override
  String get virtualMachines => 'Virtual Machines';

  @override
  String get containers => 'Containers';

  @override
  String get analytics => 'Analytics';

  @override
  String get usageAcrossAllOnlineNodes => 'Usage across all online nodes';

  @override
  String get cpu => 'CPU';

  @override
  String cpuusagepercent(String cpuUsagePercent) {
    return '$cpuUsagePercent %';
  }

  @override
  String get memory => 'Memory';

  @override
  String memusagepercent(String memUsagePercent) {
    return '$memUsagePercent %';
  }

  @override
  String get nodes => 'Nodes';

  @override
  String get guests => 'Guests';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get unknownResourceType => 'Unknown resource type';

  @override
  String get permissions => 'Permissions';

  @override
  String get noTokens => 'No Tokens';

  @override
  String expiresExpiredate(String expireDate) {
    return 'Expires: $expireDate';
  }

  @override
  String get noGroups => 'No Groups';

  @override
  String get pageNotFound => 'Page not found!';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get couldNotLaunchPrivacyPolicy => 'Could not launch privacy policy';

  @override
  String get proxmoxForum => 'Proxmox Forum';

  @override
  String get couldNotOpenForum => 'Could not open forum';

  @override
  String get reportABug => 'Report a bug';

  @override
  String get couldNotOpenBugzilla => 'Could not open bugzilla';

  @override
  String get job => 'Job';

  @override
  String get enjoyTheApp => 'Enjoy the app';

  @override
  String get start => 'Start';

  @override
  String get ifYouHaveSuggestionsOrExperienceAnyProblemsPlease =>
      'If you have suggestions or experience any problems, please contact us via';

  @override
  String get forum => 'Forum';

  @override
  String get userMailingList => 'User Mailing List';

  @override
  String get proxmoxVirtualEnvironment => 'Proxmox Virtual Environment';

  @override
  String totalTotalvalue(String totalValue) {
    return 'Total: $totalValue';
  }

  @override
  String get useCdDvdDiscImageFileIso => 'Use CD/DVD disc image file (iso)';

  @override
  String get usePhysicalCdDvdDrive => 'Use physical CD/DVD Drive';

  @override
  String get doNotUseAnyMedia => 'Do not use any media';

  @override
  String get pending => 'pending';

  @override
  String get close => 'Close';

  @override
  String get update => 'Update';

  @override
  String get spice => 'SPICE';

  @override
  String get openSpiceConnectionFileWithExternalApp =>
      'Open SPICE connection file with external App';

  @override
  String get gotException => 'Got Exception';

  @override
  String get openConsoleView => 'Open console view';

  @override
  String get aTlsErrorHasOccurred => 'A TLS error has occurred:';

  @override
  String get errorMessage => 'Error Message:';

  @override
  String get certificateInformation => 'Certificate Information:';

  @override
  String get issuedTo => 'Issued to:';

  @override
  String get fingerprint => 'Fingerprint:';

  @override
  String get doYouWantToContinue => 'Do you want to continue?';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get storage => 'Storage';

  @override
  String get noStorageAvailable => 'No storage available';

  @override
  String get content => 'Content';

  @override
  String get storageOffline => 'Storage offline';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get pleaseSelectAStorage => 'Please select a storage';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get prev => 'Prev';

  @override
  String backupGuestid(String guestID) {
    return 'Backup $guestID';
  }

  @override
  String get recentBackups => 'Recent backups';

  @override
  String get backupNow => 'Backup now';

  @override
  String get noExistingBackupFileForGuestFound =>
      'No existing backup file for guest found';

  @override
  String get pleaseSelectATargetStorage => 'Please select a target storage';

  @override
  String get selection => 'Selection:';

  @override
  String get restore => 'Restore';

  @override
  String get remove => 'Remove';

  @override
  String get showConfiguration => 'Show Configuration';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get configuration => 'Configuration';

  @override
  String get scheduleBackup => 'Schedule backup';

  @override
  String get startBackupNow => 'Start backup now';

  @override
  String backupGuestid2(String guestId) {
    return 'Backup $guestId';
  }

  @override
  String get errorCouldNotStartBackup => 'Error: Could not start backup';

  @override
  String get migration => 'Migration';

  @override
  String get mode => 'Mode';

  @override
  String get source => 'Source';

  @override
  String get target => 'Target';

  @override
  String get haState => 'HA State';

  @override
  String get noRrdData => 'no rrd data';

  @override
  String pageOf2(String page) {
    return '$page of 2';
  }

  @override
  String get couldNotOpenDocs => 'Could not open Docs';

  @override
  String get name => 'Name';

  @override
  String get startShutdownOrder => 'Start/Shutdown order';

  @override
  String get osType => 'OS Type';

  @override
  String get architecture => 'Architecture';

  @override
  String get ttyCount => 'TTY Count';

  @override
  String get consoleMode => 'Console Mode';

  @override
  String get unprivileged => 'Unprivileged';

  @override
  String get features => 'Features';

  @override
  String get template => 'TEMPLATE';

  @override
  String get resources => 'Resources';

  @override
  String get swap => 'Swap';

  @override
  String get cores => 'Cores';

  @override
  String get network => 'Network';

  @override
  String get dns => 'DNS';

  @override
  String get dnsDomain => 'DNS Domain';

  @override
  String get dnsServer => 'DNS Server';

  @override
  String get turnOnLxcContainer => 'Turn on LXC container';

  @override
  String get shutdown => 'Shutdown';

  @override
  String get turnOffLxcContainer => 'Turn off LXC container';

  @override
  String get reboot => 'Reboot';

  @override
  String get rebootLxcContainer => 'Reboot LXC container';

  @override
  String get stop => 'Stop';

  @override
  String get stopLxcContainer => 'Stop LXC container';

  @override
  String get tree => 'Tree';

  @override
  String get actions => 'Actions';

  @override
  String get datacenter => 'Datacenter';

  @override
  String get settings => 'Settings';

  @override
  String get userPermissions => 'User/Permissions';

  @override
  String get newVm => 'new VM';

  @override
  String get newCt => 'new CT';

  @override
  String get overview => 'Overview';

  @override
  String get performance => 'Performance';

  @override
  String get ceph => 'Ceph';

  @override
  String get replication => 'Replication';

  @override
  String get backup => 'Backup';

  @override
  String get firewall => 'Firewall';

  @override
  String get support => 'Support';

  @override
  String get filterResults => 'Filter Results';

  @override
  String get reset => 'Reset';

  @override
  String nodeNodeid(String nodeID) {
    return 'Node $nodeID';
  }

  @override
  String pageOf4(String page) {
    return '$page of 4';
  }

  @override
  String get summary => 'Summary';

  @override
  String get kernel => 'Kernel';

  @override
  String get kernelSamePageMergingKsm => 'Kernel same-page merging (KSM)';

  @override
  String get hdSpaceRoot => 'HD space (root)';

  @override
  String get services => 'Services';

  @override
  String get allRunning => 'All running';

  @override
  String get oneOrMoreNotRunning => 'One or more not running';

  @override
  String get updates => 'Updates';

  @override
  String get lackingPermissionToQueryUpdates =>
      'Lacking permission to query updates';

  @override
  String get noUpdatesAvailable => 'No updates available';

  @override
  String get description => 'Description';

  @override
  String get disks => 'Disks';

  @override
  String get noHealthIssues => 'No health issues';

  @override
  String get checkDisksHealthErrorIndicated =>
      'Check disks, health error indicated!';

  @override
  String get details => 'Details';

  @override
  String get device => 'Device';

  @override
  String get type => 'Type';

  @override
  String get usage => 'Usage';

  @override
  String get gpt => 'GPT';

  @override
  String get model => 'Model';

  @override
  String get serial => 'Serial';

  @override
  String get sMART => 'S.M.A.R.T';

  @override
  String get wearout => 'Wearout';

  @override
  String get rebootNode => 'Reboot Node';

  @override
  String get shutdownNode => 'Shutdown Node';

  @override
  String capitalizedactiontextNode(String capitalizedActionText) {
    return '$capitalizedActionText node?';
  }

  @override
  String get bootDevice => 'Boot Device';

  @override
  String get hotplug => 'Hotplug';

  @override
  String get rtcStartDate => 'RTC start date';

  @override
  String get smbiosSettingsType1 => 'SMBIOS settings (type1)';

  @override
  String get qemuGuestAgent => 'QEMU Guest Agent';

  @override
  String get spiceEnhancements => 'Spice Enhancements';

  @override
  String get vmStateStorage => 'VM State Storage';

  @override
  String get hardware => 'Hardware';

  @override
  String get processor => 'Processor';

  @override
  String get bios => 'BIOS';

  @override
  String get machineType => 'Machine Type';

  @override
  String get scsiController => 'SCSI Controller';

  @override
  String get cdDvdDrive => 'CD/DVD Drive';

  @override
  String get hardDisk => 'Hard Disk';

  @override
  String get networkDevice => 'Network Device';

  @override
  String get turnOnQemuVirtualMachine => 'Turn on QEMU virtual machine';

  @override
  String get resume => 'Resume';

  @override
  String get resumeQemuVirtualMachine => 'Resume QEMU virtual machine';

  @override
  String get shutdownQemuVirtualMachine => 'Shutdown QEMU virtual machine';

  @override
  String get rebootQemuVirtualMachine => 'Reboot QEMU virtual machine';

  @override
  String get pause => 'Pause';

  @override
  String get pauseQemuVirtualMachine => 'Pause QEMU virtual machine';

  @override
  String get hibernate => 'Hibernate';

  @override
  String get hibernateQemuVirtualMachine => 'Hibernate QEMU virtual machine';

  @override
  String get stopQemuVirtualMachine => 'Stop QEMU virtual machine';

  @override
  String get resetQemuVirtualMachine => 'Reset QEMU virtual machine';

  @override
  String get node => 'Node';

  @override
  String get action => 'Action';

  @override
  String get getSubscription => 'Get subscription';

  @override
  String get user => 'User';

  @override
  String get startTime => 'Start time';

  @override
  String get duration => 'Duration';

  @override
  String get shortlog => 'Shortlog';

  @override
  String get moreTasks => 'More Tasks';

  @override
  String get fullLog => 'Full Log';

  @override
  String get filters => 'Filters';

  @override
  String get onlyErrors => 'Only errors';

  @override
  String get noTasksFound => 'No tasks found';

  @override
  String get loadingLogData => 'Loading log data..';

  @override
  String get ioWait => 'I/O wait';

  @override
  String get spiceEmptyReplyTitle => 'Empty reply from SPICE API';

  @override
  String spiceEmptyReplyBody(String perm) {
    return 'Ensure you have \"$perm.Console\" permissions.';
  }

  @override
  String get spiceClientRequiredTitle => 'SPICE client required';

  @override
  String get spiceClientRequiredBody => 'A Spice client-app is required.';

  @override
  String get pleaseEnterValidEmail => 'Please enter valid email address';

  @override
  String get load => 'Load';

  @override
  String get powerSettings => 'Power Settings';

  @override
  String get console => 'Console';

  @override
  String get search => 'Search';

  @override
  String get guestOs => 'Guest OS';

  @override
  String get emailTo => 'Email to';

  @override
  String get compression => 'Compression';

  @override
  String get byUser => 'by user';

  @override
  String get byType => 'by type';

  @override
  String get qemu => 'Qemu';

  @override
  String get lxc => 'LXC';

  @override
  String get paused => 'Paused';

  @override
  String cpuMax(String max) {
    return 'CPU ($max)';
  }

  @override
  String editTitle(String title) {
    return 'Edit: $title';
  }
}
