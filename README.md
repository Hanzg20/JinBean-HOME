# JinBean App

## 版本说明

### 1. 角色切换与导航
- 支持 customer、provider、多角色（customer+provider）用户。
- 登录页支持多角色用户选择角色，登录后进入对应主页面。
- provider 端采用独立 ProviderShellApp，彻底与插件式 tab 隔离。
- customer 端采用 ShellApp，动态 bottomTab。
- Splash、登录、profile 页等所有角色切换、跳转逻辑已彻底修复。

### 2. 自动修复机制
- 角色切换、tab index、主题切换、UI 响应等所有常见 bug 自动修复。
- 切换角色时自动重置 tab index，防止越界和卡死。
- 彻底移除 provider 端插件式 tab 及相关遗留逻辑。

### 3. 主题切换
- 支持 dark teal、golden 两套主题。
- 角色切换时自动应用对应主题。
- 所有 UI 颜色响应主题变化，无硬编码色值。

### 4. 其它
- 登录、注册、profile、provider 申请、审核、切换等流程全部无缝衔接。
- 代码已加详细日志，便于后续排查。

---

## 如何运行

1. `flutter pub get`
2. `flutter run`

---

## 版本管理

- 本版本已彻底修复所有角色切换、provider/customer 端导航、tab、主题等核心问题。
- 详见代码注释和日志。
