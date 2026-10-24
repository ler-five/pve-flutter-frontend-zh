# PVE Companion App 中文版

基于官方 [Proxmox PVE Companion App](https://git.proxmox.com/git/flutter/pve_flutter_frontend.git) 的中文版分支，保留官方全部原有功能与品牌（应用名、图标、包名不变），在此之上新增中文化、多语言与移动端增强功能。

英文原版说明见 [README.md](README.md)；本分支与官方版的完整差异清单见 [CHANGELOG-vs-upstream.md](CHANGELOG-vs-upstream.md)。

## 配套仓库

本项目使用 `../` 路径依赖，克隆时三个仓库必须放在同一层目录：

```bash
git clone https://github.com/ler-five/pve-flutter-frontend-zh.git
git clone https://github.com/ler-five/proxmox-dart-api-client-zh.git
git clone https://github.com/ler-five/proxmox-login-manager-zh.git
```

## 相对官方版的新增功能

### 多语言（语言模块独立拆分）

- 语言文件独立存放于 `lib/l10n/`，当前支持：English、简体中文、繁體中文
- 新增语言只需添加对应 ARB 文件（如 `app_ja.arb`），无需改动业务代码；繁体中文由 `tool/gen_zh_hant.dart` 从简体自动生成
- 登录包 `proxmox_login_manager` 同样接入了 i18n

### 设置增强

- 主题模式：跟随系统 / 浅色 / 深色，可持久化
- 语言切换：跟随系统 / English / 简体中文 / 繁體中文，可持久化
- 入口：App 内「设置」页

### P0 移动端增强

- **快照管理**：VM/CT 快照列表、创建、回滚、删除（含确认框）
- **硬件快捷编辑**：CPU 核数、内存、插槽、Swap 快捷修改；磁盘扩容（+10G）；网桥切换
- **备份入口**：备份历史查看与恢复入口

对应 API 端点已在 `proxmox-dart-api-client-zh` 的 `client.dart` 中新增。

### UI 现代化

- 全新深色主题设计令牌（色板集中在 `lib/utils/proxmox_colors.dart`），浅色/深色双主题
- 仪表盘重构：集群概览渐变卡片、快捷入口胶囊、客机摘要两行布局
- VM 卡片、操作卡片、状态胶囊等组件重写，整体布局更紧凑

## 在线构建 APK（GitHub Actions）

主仓库内置工作流 `.github/workflows/android-release.yml`，无需本地环境即可出包：

- **手动构建**：仓库页 → Actions →「Android APK」→ Run workflow，完成后自动生成 `apk-<时间戳>` 的 Release 并挂载 `app-release.apk`
- **正式发布**：推送 `v*` tag（如 `git tag v1.0.0 && git push origin v1.0.0`），APK 挂到该 tag 的 Release 上

注意：CI 构建的 APK 使用 debug 密钥签名，可直接安装；与本地正式签名的 APK 签名不同，覆盖安装前需先卸载旧版。

## 本地构建

环境要求：Flutter stable（开发时验证版本 3.47.7）、JDK 17、Android SDK 36。

```bash
# 三个仓库同级克隆后，先生成各包的 built_value 模型代码
cd proxmox_dart_api_client && flutter pub get && dart run build_runner build --delete-conflicting-outputs && cd ..
cd proxmox_login_manager && flutter pub get && dart run build_runner build --delete-conflicting-outputs && cd ..
cd pve_flutter_frontend && flutter pub get && dart run build_runner build --delete-conflicting-outputs

# 生成多语言代码并构建
flutter gen-l10n
flutter build apk --release
```

产物：`build/app/outputs/flutter-apk/app-release.apk`

正式分发请在 `android/` 下放置自己的 `key.properties` 与 keystore（均已被 `.gitignore` 忽略）；CI 环境没有该文件时会自动回退到 debug 签名。

## 同步官方更新

各仓库保留了 `upstream` remote 指向官方仓库：

```bash
git fetch upstream
git rebase upstream/master
git push origin master
```

常见冲突点与处理方式（i18n、P0 功能、UI 主题、构建配置）见 [CHANGELOG-vs-upstream.md](CHANGELOG-vs-upstream.md)。

## 许可证

遵循上游 AGPLv3。
