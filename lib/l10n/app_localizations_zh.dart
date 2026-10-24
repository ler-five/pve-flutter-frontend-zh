// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Proxmox';

  @override
  String get errorTitle => '错误';

  @override
  String coresNodesSummary(String cpus, String nodes) {
    return '$cpus 核 $nodes 节点';
  }

  @override
  String groupMembersCount(String count) {
    return '组成员 ($count)';
  }

  @override
  String privilegesCount(String count) {
    return '权限 ($count)';
  }

  @override
  String migrationTaskTitle(String guestId) {
    return '迁移 $guestId';
  }

  @override
  String lastTaskType(String type) {
    return '最近任务：$type';
  }

  @override
  String taskType(String type) {
    return '任务：$type';
  }

  @override
  String cpuInfoSocket(String sockets) {
    return 'CPU 信息（插槽：$sockets）';
  }

  @override
  String packagesReadyToUpdate(String count) {
    return '有 $count 个软件包可更新';
  }

  @override
  String diskUsage(String used, String size) {
    return '用量：$used $size';
  }

  @override
  String cpuMemoryUsage(String cpu, String mem) {
    return 'CPU：$cpu\n内存：$mem';
  }

  @override
  String nodePowerWarning(String action, String node) {
    return '对“$node”执行 $action 操作可能导致该节点及其所有虚拟客户机长时间不可用。';
  }

  @override
  String pastDuration(String duration) {
    return '过去 $duration';
  }

  @override
  String memoryUsageOf(String used, String total) {
    return '$used / $total';
  }

  @override
  String get subscriptionAlertBody =>
      '一个或多个节点没有有效的订阅。Proxmox 团队努力确保您运行最佳软件、获得稳定的更新和安全增强，以及快速的企业支持。\n\n请考虑购买订阅。';

  @override
  String get error => '错误';

  @override
  String get proxmox => 'Proxmox';

  @override
  String get virtualEnvironment => '虚拟环境';

  @override
  String get status => '状态';

  @override
  String get subscription => '订阅';

  @override
  String get virtualMachines => '虚拟机';

  @override
  String get containers => '容器';

  @override
  String get analytics => '统计';

  @override
  String get usageAcrossAllOnlineNodes => '所有在线节点的总用量';

  @override
  String get cpu => 'CPU';

  @override
  String cpuusagepercent(String cpuUsagePercent) {
    return '$cpuUsagePercent %';
  }

  @override
  String get memory => '内存';

  @override
  String memusagepercent(String memUsagePercent) {
    return '$memUsagePercent %';
  }

  @override
  String get nodes => '节点';

  @override
  String get guests => '客户机';

  @override
  String get online => '在线';

  @override
  String get offline => '离线';

  @override
  String get unknownResourceType => '未知资源类型';

  @override
  String get permissions => '权限';

  @override
  String get noTokens => '无令牌';

  @override
  String expiresExpiredate(String expireDate) {
    return '过期时间：$expireDate';
  }

  @override
  String get noGroups => '无用户组';

  @override
  String get pageNotFound => '页面未找到！';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get couldNotLaunchPrivacyPolicy => '无法打开隐私政策';

  @override
  String get proxmoxForum => 'Proxmox 论坛';

  @override
  String get couldNotOpenForum => '无法打开论坛';

  @override
  String get reportABug => '报告缺陷';

  @override
  String get couldNotOpenBugzilla => '无法打开 Bugzilla';

  @override
  String get job => '作业';

  @override
  String get enjoyTheApp => '希望您喜欢本应用';

  @override
  String get start => '开始';

  @override
  String get ifYouHaveSuggestionsOrExperienceAnyProblemsPlease =>
      '如果您有任何建议或遇到任何问题，请通过以下方式联系我们';

  @override
  String get forum => '论坛';

  @override
  String get userMailingList => '用户邮件列表';

  @override
  String get proxmoxVirtualEnvironment => 'Proxmox Virtual Environment';

  @override
  String totalTotalvalue(String totalValue) {
    return '总计：$totalValue';
  }

  @override
  String get useCdDvdDiscImageFileIso => '使用 CD/DVD 光盘镜像文件 (iso)';

  @override
  String get usePhysicalCdDvdDrive => '使用物理 CD/DVD 驱动器';

  @override
  String get doNotUseAnyMedia => '不使用任何介质';

  @override
  String get pending => '等待中';

  @override
  String get close => '关闭';

  @override
  String get update => '更新';

  @override
  String get spice => 'SPICE';

  @override
  String get openSpiceConnectionFileWithExternalApp => '使用外部应用打开 SPICE 连接文件';

  @override
  String get gotException => '发生异常';

  @override
  String get openConsoleView => '打开控制台视图';

  @override
  String get aTlsErrorHasOccurred => '发生 TLS 错误：';

  @override
  String get errorMessage => '错误信息：';

  @override
  String get certificateInformation => '证书信息：';

  @override
  String get issuedTo => '颁发给：';

  @override
  String get fingerprint => '指纹：';

  @override
  String get doYouWantToContinue => '是否继续？';

  @override
  String get no => '否';

  @override
  String get yes => '是';

  @override
  String get storage => '存储';

  @override
  String get noStorageAvailable => '无可用存储';

  @override
  String get content => '内容';

  @override
  String get storageOffline => '存储离线';

  @override
  String get nothingFound => '未找到任何内容';

  @override
  String get pleaseSelectAStorage => '请选择存储';

  @override
  String get done => '完成';

  @override
  String get next => '下一步';

  @override
  String get skip => '跳过';

  @override
  String get prev => '上一步';

  @override
  String backupGuestid(String guestID) {
    return '备份 $guestID';
  }

  @override
  String get recentBackups => '最近备份';

  @override
  String get backupNow => '立即备份';

  @override
  String get noExistingBackupFileForGuestFound => '未找到该客户机的现有备份文件';

  @override
  String get pleaseSelectATargetStorage => '请选择目标存储';

  @override
  String get selection => '已选：';

  @override
  String get restore => '恢复';

  @override
  String get remove => '移除';

  @override
  String get showConfiguration => '显示配置';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get configuration => '配置';

  @override
  String get scheduleBackup => '计划备份';

  @override
  String get startBackupNow => '立即开始备份';

  @override
  String backupGuestid2(String guestId) {
    return '备份 $guestId';
  }

  @override
  String get errorCouldNotStartBackup => '错误：无法启动备份';

  @override
  String get migration => '迁移';

  @override
  String get mode => '模式';

  @override
  String get source => '来源';

  @override
  String get target => '目标';

  @override
  String get haState => 'HA 状态';

  @override
  String get noRrdData => '无 RRD 数据';

  @override
  String pageOf2(String page) {
    return '第 $page 页，共 2 页';
  }

  @override
  String get couldNotOpenDocs => '无法打开文档';

  @override
  String get name => '名称';

  @override
  String get startShutdownOrder => '启动/关机顺序';

  @override
  String get osType => '操作系统类型';

  @override
  String get architecture => '架构';

  @override
  String get ttyCount => 'TTY 数量';

  @override
  String get consoleMode => '控制台模式';

  @override
  String get unprivileged => '非特权';

  @override
  String get features => '特性';

  @override
  String get template => '模板';

  @override
  String get resources => '资源';

  @override
  String get swap => '交换空间';

  @override
  String get cores => '核';

  @override
  String get network => '网络';

  @override
  String get dns => 'DNS';

  @override
  String get dnsDomain => 'DNS 域';

  @override
  String get dnsServer => 'DNS 服务器';

  @override
  String get turnOnLxcContainer => '启动 LXC 容器';

  @override
  String get shutdown => '关机';

  @override
  String get turnOffLxcContainer => '关闭 LXC 容器';

  @override
  String get reboot => '重启';

  @override
  String get rebootLxcContainer => '重启 LXC 容器';

  @override
  String get stop => '停止';

  @override
  String get stopLxcContainer => '停止 LXC 容器';

  @override
  String get tree => '资源树';

  @override
  String get actions => '操作';

  @override
  String get datacenter => '数据中心';

  @override
  String get settings => '设置';

  @override
  String get userPermissions => '用户/权限';

  @override
  String get newVm => '新建虚拟机';

  @override
  String get newCt => '新建容器';

  @override
  String get overview => '概览';

  @override
  String get performance => '性能';

  @override
  String get ceph => 'Ceph';

  @override
  String get replication => '复制';

  @override
  String get backup => '备份';

  @override
  String get firewall => '防火墙';

  @override
  String get support => '支持';

  @override
  String get filterResults => '筛选结果';

  @override
  String get reset => '重置';

  @override
  String nodeNodeid(String nodeID) {
    return '节点 $nodeID';
  }

  @override
  String pageOf4(String page) {
    return '第 $page 页，共 4 页';
  }

  @override
  String get summary => '摘要';

  @override
  String get kernel => '内核';

  @override
  String get kernelSamePageMergingKsm => '内核同页合并 (KSM)';

  @override
  String get hdSpaceRoot => '硬盘空间 (root)';

  @override
  String get services => '服务';

  @override
  String get allRunning => '全部运行中';

  @override
  String get oneOrMoreNotRunning => '一个或多个未运行';

  @override
  String get updates => '更新';

  @override
  String get lackingPermissionToQueryUpdates => '缺少查询更新的权限';

  @override
  String get noUpdatesAvailable => '无可用更新';

  @override
  String get description => '描述';

  @override
  String get disks => '磁盘';

  @override
  String get noHealthIssues => '无健康问题';

  @override
  String get checkDisksHealthErrorIndicated => '请检查磁盘，检测到健康错误！';

  @override
  String get details => '详情';

  @override
  String get device => '设备';

  @override
  String get type => '类型';

  @override
  String get usage => '用量';

  @override
  String get gpt => 'GPT';

  @override
  String get model => '型号';

  @override
  String get serial => '序列号';

  @override
  String get sMART => 'S.M.A.R.T';

  @override
  String get wearout => '磨损';

  @override
  String get rebootNode => '重启节点';

  @override
  String get shutdownNode => '关闭节点';

  @override
  String capitalizedactiontextNode(String capitalizedActionText) {
    return '要 $capitalizedActionText 节点吗？';
  }

  @override
  String get bootDevice => '启动设备';

  @override
  String get hotplug => '热插拔';

  @override
  String get rtcStartDate => 'RTC 启动日期';

  @override
  String get smbiosSettingsType1 => 'SMBIOS 设置 (type1)';

  @override
  String get qemuGuestAgent => 'QEMU Guest Agent';

  @override
  String get spiceEnhancements => 'SPICE 增强';

  @override
  String get vmStateStorage => '虚拟机状态存储';

  @override
  String get hardware => '硬件';

  @override
  String get processor => '处理器';

  @override
  String get bios => 'BIOS';

  @override
  String get machineType => '机器类型';

  @override
  String get scsiController => 'SCSI 控制器';

  @override
  String get cdDvdDrive => 'CD/DVD 驱动器';

  @override
  String get hardDisk => '硬盘';

  @override
  String get networkDevice => '网络设备';

  @override
  String get turnOnQemuVirtualMachine => '启动 QEMU 虚拟机';

  @override
  String get resume => '继续运行';

  @override
  String get resumeQemuVirtualMachine => '继续运行 QEMU 虚拟机';

  @override
  String get shutdownQemuVirtualMachine => '关闭 QEMU 虚拟机';

  @override
  String get rebootQemuVirtualMachine => '重启 QEMU 虚拟机';

  @override
  String get pause => '暂停';

  @override
  String get pauseQemuVirtualMachine => '暂停 QEMU 虚拟机';

  @override
  String get hibernate => '休眠';

  @override
  String get hibernateQemuVirtualMachine => '休眠 QEMU 虚拟机';

  @override
  String get stopQemuVirtualMachine => '停止 QEMU 虚拟机';

  @override
  String get resetQemuVirtualMachine => '重置 QEMU 虚拟机';

  @override
  String get node => '节点';

  @override
  String get action => '操作';

  @override
  String get getSubscription => '获取订阅';

  @override
  String get user => '用户';

  @override
  String get startTime => '开始时间';

  @override
  String get duration => '耗时';

  @override
  String get shortlog => '简要日志';

  @override
  String get moreTasks => '更多任务';

  @override
  String get fullLog => '完整日志';

  @override
  String get filters => '筛选';

  @override
  String get onlyErrors => '仅错误';

  @override
  String get noTasksFound => '未找到任务';

  @override
  String get loadingLogData => '正在加载日志数据..';

  @override
  String get ioWait => 'I/O 等待';

  @override
  String get spiceEmptyReplyTitle => 'SPICE API 返回空响应';

  @override
  String spiceEmptyReplyBody(String perm) {
    return '请确保您拥有 \"$perm.Console\" 权限。';
  }

  @override
  String get spiceClientRequiredTitle => '需要 SPICE 客户端';

  @override
  String get spiceClientRequiredBody => '需要安装 Spice 客户端应用。';

  @override
  String get pleaseEnterValidEmail => '请输入有效的电子邮件地址';

  @override
  String get load => '负载';

  @override
  String get powerSettings => '电源设置';

  @override
  String get console => '控制台';

  @override
  String get search => '搜索';

  @override
  String get guestOs => '客户机操作系统';

  @override
  String get emailTo => '发送邮件到';

  @override
  String get compression => '压缩';

  @override
  String get byUser => '按用户';

  @override
  String get byType => '按类型';

  @override
  String get qemu => 'QEMU';

  @override
  String get lxc => 'LXC';

  @override
  String get paused => '已暂停';

  @override
  String cpuMax(String max) {
    return 'CPU ($max)';
  }

  @override
  String editTitle(String title) {
    return '编辑：$title';
  }

  @override
  String get snapshots => '快照';

  @override
  String snapshotGuestid(String guestId) {
    return '快照 $guestId';
  }

  @override
  String get takeSnapshot => '创建快照';

  @override
  String get snapshotName => '快照名称';

  @override
  String get snapshotNameRequired => '请输入快照名称';

  @override
  String get snapshotNameInvalid => '只能包含字母、数字、下划线和连字符';

  @override
  String get includeRamState => '包含内存（虚拟机状态）';

  @override
  String get withRamState => '含内存状态';

  @override
  String get rollback => '回滚';

  @override
  String rollbackSnapshotConfirm(String name) {
    return '确定回滚到快照“$name”？当前状态将丢失。';
  }

  @override
  String deleteSnapshotConfirm(String name) {
    return '确定删除快照“$name”？';
  }

  @override
  String get noSnapshots => '暂无快照';

  @override
  String get options => '选项';

  @override
  String get editHardware => '编辑硬件';

  @override
  String get cpuCores => 'CPU 核数';

  @override
  String get sockets => '插槽数';

  @override
  String get memoryMib => '内存 (MiB)';

  @override
  String get swapMib => '交换空间 (MiB)';

  @override
  String get resizeDisk => '磁盘扩容';

  @override
  String get resizeDiskHint => '容量增量，例如 +10G';

  @override
  String get invalidSizeIncrement => '请使用如 +10G 或 +512M 的格式';

  @override
  String get invalidNumber => '请输入有效数字';

  @override
  String get bridge => '网桥';

  @override
  String get disk => '磁盘';

  @override
  String get apply => '应用';

  @override
  String get configUpdated => '配置已更新';

  @override
  String coresSocketsValue(String cores, String sockets) {
    return '$cores 核 $sockets 插槽';
  }

  @override
  String get unlimited => '无限制';

  @override
  String get useHostSettings => '使用主机设置';

  @override
  String get attention => '注意';

  @override
  String get deleteBackupConfirm => '确定要删除该备份吗？';

  @override
  String get restoreBackupTitle => '恢复备份';

  @override
  String restoreBackupConfirm(String volid, String guestId) {
    return '将备份“$volid”恢复到客户机 $guestId？现有数据将被覆盖。';
  }

  @override
  String get startAfterRestore => '恢复完成后启动';

  @override
  String get restoreBackupError => '无法启动恢复';

  @override
  String get actionFailed => '操作失败';
}
