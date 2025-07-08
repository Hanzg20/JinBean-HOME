# CHANGELOG

## [本次大版本] - 2024-07-03

### 新特性
- 支持多角色（customer、provider、customer+provider）用户登录与切换。
- 登录页支持多角色用户选择角色，登录后进入对应主页面。
- provider 端采用独立 ProviderShellApp，彻底与插件式 tab 隔离。
- customer 端采用 ShellApp，动态 bottomTab。
- 角色切换时自动应用对应主题（dark teal/golden）。
- 主题设置支持 per-role 记忆，切换角色自动切换主题。

### 自动修复与架构优化
- 角色切换、tab index、主题切换、UI 响应等所有常见 bug 自动修复。
- 切换角色时自动重置 tab index，防止越界和卡死。
- 彻底移除 provider 端插件式 tab 及相关遗留逻辑。
- 登录、注册、profile、provider 申请、审核、切换等流程全部无缝衔接。
- 代码加详细日志，便于后续排查。

### UI/UX 优化
- 登录页角色切换采用 animated_toggle_switch，视觉更现代。
- 所有 UI 颜色响应主题变化，无硬编码色值。
- provider/customer 端主页面结构优化，体验更流畅。

### Bug 修复
- 修复角色切换后页面卡死、tab 越界、主题未切换等问题。
- 修复多角色用户首次登录后自动跳转错误问题。
- 修复 profile 页自动切换 provider 的副作用，只有用户主动点击才切换。
- 修复所有与角色切换、tab、主题相关的历史遗留 bug。

---

如需历史版本变更，请查阅 Git 历史。 