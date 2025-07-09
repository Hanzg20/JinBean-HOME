# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
- Initial international documentation structure and refactor.

## [2024-07-03]
- Major refactor: role management, navigation isolation, theme system.
- Provider/customer navigation and plugin system separation.
- UI/UX improvements, bug fixes, and documentation update.

## [2024-06-30]
- Initial multi-role login and registration flow.
- Provider application and approval process.

## [2024-06-15]
- Project initialization.

## [2024-07-04]
- 全项目国际化自动修复启动，所有页面、控件、弹窗、按钮、Tab、SnackBar、Dialog等硬编码中英文全部替换为国际化资源引用。
- 自动补全所有缺失的国际化key到app_en.arb和app_zh.arb，保证所有UI文本可随语言切换。
- 登录页、首页等关键页面已完成国际化修复，其它页面持续批量修复中。
- 日志系统AppLogger全局集成，所有核心页面和控制器已批量插入多级别日志点，支持按需开关。
- 开发规范文档（developer_guide.md）全面升级，覆盖前后端、数据库、API、CI/CD、日志、国际化、插件化等全流程标准。
- 项目所有新代码、页面、功能均强制遵循国际化、日志、主题、插件、依赖注入等统一规范。
- 修复和优化部分UI/UX细节，提升多语言和多角色适配体验。

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