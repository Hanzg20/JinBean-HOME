# System Design Document for JinBean App

## Table of Contents
1. Introduction
2. Overall Architecture
3. Core Module Design
4. Internationalization & Localization
5. Data Flow and Interactions
6. Development Environment & Tools
7. Deployment & Operations
8. Design Discussion & Q&A
9. Category ID Encoding Rules

---

## 1. Introduction

### 1.1 Purpose
详细描述金豆荚App的系统设计，包括架构、技术选型、模块划分及关键组件设计，为开发团队提供实现指导。

### 1.2 Scope
涵盖客户端核心架构、插件管理、状态管理、路由、国际化、本地数据存储等。

### 1.3 Terminology
- **Super App**: 集成多种独立服务或功能模块的移动应用。
- **Plugin**: 可独立开发、部署和管理的功能模块。
- **GetX**: Flutter状态管理、依赖注入和路由框架。
- **ARB**: Flutter国际化文本定义文件。

---

## 2. Overall Architecture

（此处插入架构分层图、模块划分、技术选型等内容，保留原文相关描述）

---

## 3. Core Module Design

（此处插入插件管理系统、认证模块、主应用壳、各业务模块等设计内容，保留原文相关描述）

---

## 4. Internationalization & Localization

本系统采用"静态文本国际化 + 动态内容多语言字段"混合方案：

### 4.1 界面静态文本
- 使用 Flutter 官方国际化（arb/json 文件），所有 UI 固定文本均支持多语言切换。
- 便于开发、维护和编译时检查。

### 4.2 动态内容多语言
- 数据库字段（如 title、description）采用 jsonb 结构，每种语言一个 key。
- 查询时根据当前语言动态取值，无对应语言时自动 fallback 到主语言。
- 后台支持多语言录入，或主语言+自动翻译补全。

### 4.3 方案优点与未来扩展
- 灵活扩展，支持任意语言。
- 查询高效，结构简单，Flutter 端处理方便。
- 易于后台批量管理和未来自动翻译集成。
- 新增语言只需在 jsonb 字段加新 key，可集成第三方翻译 API，运营人工校对。

---

## 5. Data Flow and Interactions

（此处插入应用启动、插件初始化、认证、主壳加载、插件间数据共享等内容，保留原文相关描述）

---

## 6. Development Environment & Tools

（此处插入IDE、版本控制、包管理、模拟器/设备等内容，保留原文相关描述）

---

## 7. Deployment & Operations

（此处插入iOS/Android配置、CI/CD、后端集成等内容，保留原文相关描述）

---

## 8. Design Discussion & Q&A

（将所有"如何.../解决思路"问题清单及其解答，全部移到本章节，按主题分组整理，便于查阅）

---

## 9. Category ID Encoding Rules

为实现多级服务分类的高效管理与扩展，JinBean App采用统一的分类ID编码规则：

### 1. 规则结构
- **ID格式**：10 + 3位一级分类 + 2位二级分类 + 2位三级分类（共7位数字，字符串类型存储）
  - 10：前缀，标识分类类型（如服务类）
  - XXX：一级分类（3位，支持001-999）
  - YY：二级分类（2位，支持01-99）
  - ZZ：三级分类（2位，支持01-99）
- 例如：
  - 1010000：美食天地（一级分类，二三级为00）
  - 1010100：居家美食（一级+二级，三级为00）
  - 1010101：家常菜送到家（完整三级分类）

### 2. 设计原则
- **层级清晰**：ID前缀即可判断所属层级和父级。
- **排序友好**：数字排序即为分类顺序。
- **扩展性强**：每级预留足够空间，便于后续插入新分类。
- **查询方便**：可通过ID前缀快速筛选同一大类/子类。
- **主键类型**：建议用字符串（varchar），避免前导0丢失。

### 3. 示例
| ID      | 中文名         | 英文名              | 备注                |
| ------- | -------------- | ------------------- | ------------------- |
| 1010000 | 美食天地       | Food Court          | 一级                |
| 1010100 | 居家美食       | Home-cooked         | 二级                |
| 1010101 | 家常菜送到家   | Homestyle Delivery  | 三级                |
| 1010102 | 家庭小灶       | Home Kitchen        | 三级                |
| 1010103 | 私人厨师上门   | Private Chef        | 三级                |
| 1010200 | 定制美食       | Custom Catering     | 二级                |
| 1010201 | 聚会大餐       | Party Catering      | 三级                |

### 4. 其它说明
- 若某级分类下暂未细分下级，可用00占位。
- 后续如需四级分类，可再加两位。
- 该规则适用于所有服务分类、标签等多级结构。

---













# 金豆荚App - 系统设计文档\n\n## 1. 引言\n\n### 1.1 目的\n本文档旨在详细描述金豆荚App的系统设计，包括其架构、技术选型、模块划分以及关键组件的设计思路，为开发团队提供清晰的实现指导。\n\n### 1.2 范围\n本设计文档涵盖金豆荚App客户端的核心架构、插件管理系统、状态管理、路由、国际化和本地数据存储。\n\n### 1.3 术语与定义\n*   **超级App (Super App)**: 一个集成多种独立服务或功能模块的移动应用。\n*   **插件 (Plugin)**: 金豆荚App中可独立开发、部署和管理的功能模块。\n*   **GetX**: Flutter中用于状态管理、依赖注入和路由的框架。\n*   **ARBs (.arb files)**: Application Resource Bundle 文件，用于Flutter国际化文本定义。\n\n## 2. 总体架构 (Overall Architecture)\n\n金豆荚App采用**插件化架构**，核心是一个轻量级的应用壳（ShellApp），通过**插件管理器 (Plugin Manager)** 动态加载和管理各个独立的功能模块（Plugins）。每个功能模块内部遵循**MVVM (Model-View-ViewModel)** 模式，通过GetX进行状态管理和依赖注入。\n\n### 2.1 架构分层\n\n```\n+-------------------------------------------------------------+\n|                          金豆荚 App                         |\n|                                                             |\n| +---------------------------------------------------------+ |\n| |                         UI / 视图层                       | |\n| | +-----------------------------------------------------+ | |\n| | |                       ShellApp (应用壳)               | | |\n| | |  - 底部导航栏                                         | | |\n| | |  - 页面容器                                           | | |\n| | +-----------------------------------------------------+ | |\n| | +-----------------------------------------------------+ | |\n| | |                  功能模块 (Plugins)                   | | |\n| | |  - Auth Plugin                                        | | |\n| | |  - Home Plugin                                        | | |\n| | |  - Service Booking Plugin                             | | |\n| | |  - Community Plugin                                   | | |\n| | |  - Profile Plugin                                     | | |\n| | |  (各模块内部遵循 MVVM: Page -> Controller -> Service/Repository) |\n| | +-----------------------------------------------------+ | |\n| +---------------------------------------------------------+ |\n|                                                             |\n| +---------------------------------------------------------+ |\n| |                     业务逻辑 / 控制器层                     | |\n| | +-----------------------------------------------------+ | |\
| | |                     GetX Controllers                    | | |\n| | |  - 处理业务逻辑                                       | | |\n| | |  - 管理响应式状态 (Rx variables)                      | | |\
| | +-----------------------------------------------------+ | |\
| +---------------------------------------------------------+ |\
|                                                             |\
| +---------------------------------------------------------+ |\
| |                      数据 / 服务层                        | |\
| | +-----------------------------------------------------+ | |\
| | |                  本地数据存储 (GetStorage)              | | |\
| | |  - 用户偏好设置                                       | | |\
| | |  - 登录状态                                           | | |\
| | +-----------------------------------------------------+ | |\
| | +-----------------------------------------------------+ | |\
| | |                  插件管理系统 (Plugin Manager)          | | |\
| | |  - 插件注册与生命周期管理                             | | |\
| | |  - 动态路由注册                                       | | |\
| | +-----------------------------------------------------+ | |\
| | +-----------------------------------------------------+ | |\
| | |                  API 服务 / Mock 数据                  | | |\
| | |  - 认证服务 (Mock)                                    | | |\
| | |  - 各业务模块数据 (Mock)                              | | |\
| | +-----------------------------------------------------+ | |\
| +---------------------------------------------------------+ |\
+-------------------------------------------------------------+\n```\n\n### 2.2 模块划分 (Modularization)\n\n项目代码按照功能模块进行划分，主要体现在 `lib/features` 目录下。每个功能模块（例如 `auth`, `home` 等）被视为一个独立的插件，内部结构如下：\n\n```\nfeatures/\n└── [plugin_name]/\n    ├── [plugin_name]_plugin.dart  # 插件入口定义 (AppPlugin 的实现)\n    └── presentation/             # 模块的UI和状态管理层\n        ├── [plugin_name]_binding.dart    # GetX 依赖绑定\n        ├── [plugin_name]_controller.dart # GetX 状态控制器\n        └── [plugin_name]_page.dart       # UI 页面\n```\n\n这种划分方式的好处：\n*   **高内聚低耦合**: 每个模块专注于自身功能，减少与其他模块的直接依赖。\n*   **易于扩展**: 添加新功能只需创建新的插件模块，无需修改核心代码。\n*   **团队协作**: 不同团队或开发者可以并行开发不同的模块。\n*   **可维护性**: 模块化结构使代码更易于理解、测试和调试。\n\n## 3. 技术选型 (Technology Stack)\n\n*   **前端框架**: Flutter (Dart)\n*   **状态管理 / 依赖注入 / 路由**: GetX\n*   **本地数据存储**: GetStorage\n*   **国际化**: Flutter 自带国际化机制 (.arb 文件)\n*   **社交登录**: `google_sign_in` 和 `sign_in_with_apple` 包\n*   **后端**: 当前阶段为 Mock 数据和 Mock 认证逻辑，未来可扩展至 Supabase、Firebase 或自定义后端。\n\n## 4. 核心组件设计\n\n### 4.1 插件管理系统 (Plugin Management System)\n\n*   **`AppPlugin` (lib/core/plugin_management/app_plugin.dart)**:\n    *   抽象基类，定义了所有插件必须实现的接口。\n    *   包含 `PluginMetadata` (插件ID, 名称Key, 图标, 启用状态, 顺序, 类型, 路由名) 来描述插件属性。\n    *   定义了 `buildEntryWidget()`, `getRoutes()`, `init()`, `dispose()` 等方法，用于插件的UI构建、路由注册和生命周期管理。\n\n*   **`PluginManager` (lib/core/plugin_management/plugin_manager.dart)**:\n    *   单例模式 (`Get.put` 全局初始化)。\n    *   负责注册所有可用的 `AppPlugin` 实例。\n    *   模拟从后端获取插件配置（`_fetchPluginsConfiguration()`），根据配置动态启用/禁用插件。\n    *   在插件初始化时调用其 `init()` 方法和 `bindings?.dependencies()` 来注入控制器。\n    *   根据插件类型 (如 `standalonePage`) 动态注册 GetX 路由。\n    *   维护 `isInitialized` 状态，确保其他模块在插件系统就绪后才进行操作。\n    *   维护 `isLoggedIn` 状态，与 `AuthController` 联动，控制导航逻辑。\n\n### 4.2 认证模块 (Auth Plugin)\n\n*   **`AuthController` (lib/features/auth/presentation/auth_controller.dart)**:\n    *   管理用户认证状态 (登录/未登录)。\n    *   处理邮箱/密码登录和注册逻辑 (当前为Mock实现)。\n    *   集成 `google_sign_in` 和 `sign_in_with_apple` 包，提供社交登录入口 (当前UI可见，功能暂时禁用并返回提示)。\n    *   管理UI相关的状态（如 `isLoading`, `errorMessage`, `isPasswordVisible`）。\n    *   成功登录后，更新 `PluginManager` 的 `isLoggedIn` 状态，并导航至主应用壳。\n    *   通过 `GetStorage` 持久化用户登录信息（如邮箱）。\n\n*   **`LoginPage` / `RegisterPage` (lib/features/auth/presentation/)**:\n    *   使用 `GetView<AuthController>` 访问 `AuthController` 的状态和方法。\n    *   UI设计遵循Figma，包含文本输入框、按钮、以及社交登录按钮的占位。\n    *   `RegisterPage` 包含密码确认逻辑。\n\n### 4.3 主应用壳 (ShellApp)\n\n*   **`ShellApp` (lib/app/shell_app.dart)**:\n    *   作为应用程序的根部Widget，负责构建底部导航栏 (`BottomNavigationBar`)。\n    *   通过 `PluginManager` 获取所有启用的 `bottomTab` 类型插件的元数据，并动态生成导航栏项和对应的页面内容。\n    *   使用 `PageView` 来管理底部导航栏页面的切换，并通过 `IndexedStack` 保持页面状态。\n\n*   **`ShellAppController` (lib/app/shell_app_controller.dart)**:\n    *   管理 `ShellApp` 内部的状态，例如当前选中的底部导航栏索引。\n\n### 4.4 国际化 (Internationalization)\n\n*   **`.arb` 文件 (lib/l10n/)**:\n    *   使用 JSON 格式定义不同语言的字符串资源。\n    *   包含描述性元数据 (`@key` 语法) 提升可维护性。\n*   **`flutter gen-l10n`**: 命令行工具，根据 `.arb` 文件自动生成 `AppLocalizations` 类，提供类型安全的字符串访问。\n*   **`GetMaterialApp`**: 配置 `localizationsDelegates` 和 `supportedLocales` 来启用多语言支持。\n\n## 5. 数据流与交互 (Data Flow and Interactions)\n\n1.  **应用启动**: `main.dart` -> `WidgetsFlutterBinding.ensureInitialized()` -> `GetStorage.init()` -> `Get.put(PluginManager())` -> `Get.put(AuthController())` -> `Get.put(SplashController())` -> `runApp(GetMaterialApp(initialRoute: '/splash'))`。\n2.  **Splash页面加载**: `SplashPage` 构建，`SplashController` 初始化并开始加载插件（通过 `PluginManager`）。\n3.  **插件初始化**: `PluginManager` 异步加载配置，注册插件，并调用各插件的 `init()` 和 `bindings?.dependencies()`。\n4.  **导航至登录/注册**: `SplashPage` 动画完成后，用户点击"Sign In"或"Sign Up"按钮，触发 `SplashController` 中的 `navigateToLogin()` 或 `navigateToRegister()`，通过 `Get.offAllNamed()` 导航至 `/auth` 或 `/register` 路由。\n5.  **用户认证**: 在 `LoginPage` 或 `RegisterPage` 中，用户输入凭据或点击社交登录按钮。`AuthController` 处理这些请求：\n    *   普通登录/注册: 验证凭据 (Mock)，成功则调用 `_handleSuccessfulLogin()`。\n    *   社交登录: 调用对应的SDK (当前为UI占位)。\n6.  **登录成功**: `_handleSuccessfulLogin()` 方法更新 `GetStorage` 和 `PluginManager.isLoggedIn` 状态，并通过 `Get.offAllNamed('/main_shell')` 导航到主应用壳。\n7.  **ShellApp 加载**: `ShellApp` 构建，通过 `PluginManager` 获取启用的底部标签页插件，动态构建 `BottomNavigationBar` 和对应的 `PageView`。各标签页的控制器由各自的 `_binding.dart` 在页面首次加载时 `lazyPut`。\n8.  **插件间数据共享**: 通过 `Get.find<Controller>()` 或 `Get.put<Controller>()` 实现控制器间的通信和数据共享。\n\n## 6. 开发环境与工具\n\n*   **IDE**: VS Code (推荐使用 Flutter 和 Dart 扩展)\n*   **版本控制**: Git\n*   **包管理**: pub (Flutter)\n*   **模拟器/设备**: iOS Simulator / Android Emulator / 真实设备\n\n## 7. 部署考虑 (Deployment Considerations)\n\n*   **iOS/Android 配置**: 需要根据具体平台进行额外的配置（如 Info.plist, AndroidManifest.xml），尤其是社交登录和推送通知。\n*   **CI/CD**: 未来可集成持续集成/持续部署管道，自动化构建、测试和发布流程。\n*   **后端集成**: 当前为Mock，未来需要与真实的后端服务（如Supabase、Firebase）进行API集成，实现数据持久化和安全性。 