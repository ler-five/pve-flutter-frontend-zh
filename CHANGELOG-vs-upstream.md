# 相对官方 Proxmox PVE Companion App 的差异备忘录

> 用途：作为 GitHub 分支（建议命名 `feature/zh-multilang-ui`）的维护说明。
> 上游仓库：
> - `https://git.proxmox.com/git/pve-flutter-frontend.git`
> - `https://git.proxmox.com/git/proxmox-dart-api-client.git`
> - `https://git.proxmox.com/git/proxmox-login-manager.git`
>
> 原则：**品牌、包名、图标、关于页、原有业务逻辑保持不变**，所有改动均为增量。

---

## 0. 提交序列（自上而下为时间顺序）

| commit | 内容 |
|--------|------|
| `i18n: scaffolding` | 接入 flutter_localizations + intl，建立 ARB 目录与 l10n.yaml |
| `i18n: extract UI strings` | 全量提取硬编码英文到 ARB，26 个 widget/page 改为 `AppLocalizations` |
| `i18n: localize guest option panels and status labels` | 补齐 qemu/lxc 选项面板、状态标签、导航/权限页文案 |
| `feat: snapshot / hardware edit / backup restore` | P0 功能 |
| `ui: modern dark theme and compact layout` | 深色主题 + 布局重构 |
| `feat: theme & language settings + zh_Hant` | 外观/语言设置、繁体中文 |

---

## 1. 国际化（i18n）

### 新增基础设施
| 文件 | 说明 |
|------|------|
| `pve_flutter_frontend/l10n.yaml` | `output-class: AppLocalizations`，`nullable-getter: false` |
| `pve_flutter_frontend/lib/l10n/app_en.arb` | 模板语言，含 `@` 元数据与占位符定义 |
| `pve_flutter_frontend/lib/l10n/app_zh.arb` | 简体中文 |
| `pve_flutter_frontend/lib/l10n/app_zh_Hant.arb` | 繁体中文（台湾用语：網路／設定／記憶體／預設／儲存／登入） |
| `proxmox_login_manager/l10n.yaml` + `lib/l10n/*.arb` | 登录包独立多语言，`output-class: LoginLocalizations` |

### 代码改动
- `main.dart`：注册 `AppLocalizations.localizationsDelegates` + `LoginLocalizations.delegate`，`supportedLocales` 由生成类提供。
- 全部 UI 文案改为 `AppLocalizations.of(context).<key>`；登录包改为 `LoginLocalizations.of(context).<key>`。
- `pubspec.yaml`：新增 `flutter_localizations`（sdk）、`intl`。

### 新增语种的方法（主流做法，保持可扩展）
1. 复制 `app_en.arb` → `app_xx.arb`，翻译值，首行 `"@@locale": "xx"`。
2. 在 `lib/l10n/` 下执行 `flutter gen-l10n`。
3. 在 `PveAppSettings` 的语言选项里增加一项（`lib/models/pve_app_settings.dart` + `lib/pages/pve_settings_page.dart`）。
4. 登录包同理（`proxmox_login_manager/lib/l10n/`）。
> 无需改任何业务代码，语言列表与 `supportedLocales` 自动生效。

---

## 2. API 客户端扩展（proxmox_dart_api_client）

`lib/src/client.dart` 新增：

| 方法 | 端点 |
|------|------|
| `getGuestSnapshots` | `GET /nodes/{node}/{qemu\|lxc}/{vmid}/snapshot` |
| `createGuestSnapshot` | `POST /nodes/{node}/{qemu\|lxc}/{vmid}/snapshot` |
| `rollbackGuestSnapshot` | `POST .../snapshot/{name}/rollback` |
| `deleteGuestSnapshot` | `DELETE .../snapshot/{name}` |
| `getGuestConfigRaw` | `GET .../config`（原始 Map） |
| `setQemuConfig` / `setLxcConfig` | `PUT .../config` |
| `resizeGuestDisk` | `PUT .../resize` |
| `restoreGuest` | `POST /nodes/{node}/{qemu\|lxc}` |
| `_putWithValidation` | 内部辅助，校验返回体 |

新增模型：`lib/src/models/pve_guest_snapshot_model.dart`（普通 class），并在 `pve_models.dart` 导出。

---

## 3. P0 功能（pve_flutter_frontend）

### 3.1 快照管理
新增 `lib/widgets/pve_guest_snapshot_widget.dart`
- 列表 / 创建（QEMU 可选含内存状态）/ 回滚 / 删除
- 所有危险操作带确认对话框，结果接任务日志
- 入口：QEMU、LXC 概览页「快照」卡片

### 3.2 硬件快捷编辑
新增 `lib/widgets/pve_guest_hardware_edit_widget.dart`
- CPU 核数、内存（QEMU 额外插槽数；LXC 额外 Swap）
- 磁盘扩容（+10G，格式校验）
- 网卡网桥切换（自动拉取节点 bridge 列表）
- 入口：QEMU、LXC 概览页「编辑硬件」卡片

### 3.3 备份恢复
修改 `lib/widgets/pve_guest_backup_widget.dart`
- 启用原先置灰的「恢复」按钮
- 从 volid 自动识别 qemu/lxc，可选「恢复后启动」
- 删除确认文案本地化

### 3.4 接入点
- `lib/widgets/pve_qemu_overview.dart`、`lib/widgets/pve_lxc_overview.dart` 新增入口卡片

---

## 4. UI 改造

### 4.1 主题与配色
`lib/utils/proxmox_colors.dart` 新增深色调色板：

| 用途 | 色值 |
|------|------|
| 页面底色 | `#0B0E14` |
| 卡片 | `#141821` |
| 次级面/输入框 | `#1C2230` |
| 描边 | `#2A3242` |
| 主强调 | `#22D3EE` |
| 次强调 | `#FFB020` |
| 成功/错误/紫 | `#34D399` / `#F8555C` / `#8B5CF6` |

`lib/main.dart` 抽出 `buildAppTheme(Brightness)`：
- 卡片零阴影 + 1px 描边 + 14px 圆角
- `visualDensity: compact`、`MaterialTapTargetSize.shrinkWrap`
- AppBar 52、NavigationBar 60、ListTile dense
- 统一 input/chip/dialog/bottomSheet/tabBar 样式

### 4.2 布局重构
| 文件 | 改动 |
|------|------|
| `lib/pages/main_layout_slim.dart` | 仪表盘：350px 蓝色色块 → 渐变 Hero 卡；ActionChip → 胶囊 chip；Guests 6 行 → 2 行摘要；资源列表改卡片式；导航栏文案本地化 |
| `lib/widgets/pve_action_card_widget.dart` | 操作卡 80→68px，渐变 + 描边，图标 55→21 |
| `lib/widgets/pve_resource_status_chip_widget.dart` | 方框 → 圆点 + 胶囊，状态文案本地化 |
| `lib/widgets/pve_guest_overview_header.dart` | 头部 250 → 196（有图表）/84（模板）px，深色渐变 + 图表蒙层 |
| `lib/widgets/pve_resource_data_card_widget.dart` | Card margin 归零，标题紧凑 |
| `lib/widgets/pve_node_overview.dart`、`pve_qemu_overview.dart`、`pve_lxc_overview.dart` | 操作行 130→96px，标题 20→15px |

### 4.3 深色适配修复
搜索框白边框、筛选图标、底部弹层拖拽条、备份计划页 AppBar、KSM 勾选项等硬编码黑色/白色已改为主题色。

---

## 5. 设置项（新增）

### 5.1 实现
| 文件 | 说明 |
|------|------|
| `lib/models/pve_app_settings.dart` | `ChangeNotifier`，SharedPreferences 持久化 `settings.themeMode` / `settings.locale` |
| `lib/pages/pve_settings_page.dart` | 新增「外观」「语言」分区；单选项弹窗；LEGAL/HELP 标题本地化 |
| `lib/main.dart` | `Consumer<PveAppSettings>` 包裹 `MaterialApp`，动态 `themeMode` + `locale` |

### 5.2 可选值
- 主题：跟随系统 / 浅色 / 深色
- 语言：跟随系统 / English / 简体中文 / 繁體中文

---

## 6. 构建配置（Android）

| 文件 | 改动 |
|------|------|
| `android/build.gradle` | AGP 8.13，compileSdk 36 收口 |
| `android/gradle/wrapper/gradle-wrapper.properties` | Gradle 8.14.3 |
| `android/gradle.properties` | `-Xmx4G` |
| `android/app/build.gradle` | release 签名读取 `key.properties`（本地自签，`key.properties` / `*.jks` 已在 `.gitignore`） |

> 正式分发需替换为自有签名证书；当前 keystore 仅为本地构建用。

---

## 7. 其他修复

- `proxmox_login_manager/lib/proxmox_login_form.dart`、`proxmox_tfa_form.dart`：剥离文件首部重复的 UTF-8 BOM（3 个 `U+FEFF`），修复 release 构建失败。
- i18n 资源中的 `@` 元数据仅保留在 `app_en.arb`，其余语言不重复。

---

## 8. 明确未改动的部分

- App 名称 `Proxmox`、图标、包名 `com.proxmox.app.pve_flutter_frontend`
- Proxmox 品牌色（supportBlue 等）、关于页、法务/帮助链接
- 所有原有业务逻辑（仅文案替换，不改行为）
- 登录认证流程、TFA 流程
- 上游原有目录结构（新增文件集中在 `lib/models`、`lib/l10n`、两个新 widget）

---

## 9. 分支维护建议

```bash
# 首次建立分支
git remote add upstream https://git.proxmox.com/git/pve-flutter-frontend.git
git checkout -b feature/zh-multilang-ui
git push origin feature/zh-multilang-ui

# 定期同步上游，冲突高发区：lib/widgets/*（文案替换）
git fetch upstream
git rebase upstream/master

# 回归检查
flutter gen-l10n && flutter analyze     # 必须 No issues found
flutter build apk --release
```

### 同步上游时的注意事项
1. **ARB 键冲突**：上游若新增英文文案，需在 `app_en.arb` 补键，再在 `app_zh.arb` / `app_zh_Hant.arb` 补译文；`app_zh_Hant.arb` 可用 `tool/gen_zh_hant.dart` 从 `app_zh.arb` 重新生成后再人工校对。
2. **widget 冲突**：文案替换与上游逻辑改动常落在同一行，冲突时保留上游逻辑 + 采用 `AppLocalizations` 调用。
3. **主题冲突**：`buildAppTheme()` 与上游主题定义互斥，冲突时整体保留本分支版本。
4. **API 客户端**：`client.dart` 为纯新增方法，冲突概率低。

---

## 10. 工具脚本（不随包发布）

位于工作区 `tool/`：
- `i18n_extract.dart` / `i18n_extract_pkg.dart`：批量提取硬编码文案
- `gen_zh_hant.dart`：简体 ARB → 繁体 ARB（397 字映射 + 19 组词语级修正）
- `list_cjk.dart`：列出 ARB 中出现的全部汉字，用于校验收敛
