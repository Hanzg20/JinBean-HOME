# JinBean Project Developer Guide

> This document is the **single source of truth** for all development guidelines in the JinBean project, covering frontend, backend, database, API, CI/CD, logging, and more. All developers must read and follow this guide before starting any new work. For special cases, discuss and update the guideline as a team.

## Table of Contents
1. General Principles
2. Frontend Development Guidelines
3. Backend Development Guidelines
4. Database Design Guidelines
5. API & Interface Guidelines
6. CI/CD & Automation Guidelines
7. Logging & Monitoring Guidelines
8. Code Review & Release Guidelines
9. Appendix

---

## 1. General Principles
- This guideline applies to all code, configuration, and documentation in the JinBean project.
- All team members must read and follow this document before starting any new feature or module.
- Any changes to the guidelines must be reviewed and approved by the team.

---

## 2. Frontend Development Guidelines
- 所有颜色必须通过 `Theme.of(context)` 获取，禁止硬编码色值。
- 按角色（customer/provider）支持 per-role 主题记忆，切换角色自动切换主题。
- 按主题色配置按钮、AppBar、底部导航栏、卡片、分割线、文本等所有控件。
- 切换主题后页面需能自动刷新。
- 所有页面文本必须通过国际化资源（.arb/.json）管理，禁止硬编码中英文。
- 新增页面/功能时，必须同步补充多语言资源。
- UI布局要考虑多语言长度差异，避免溢出或遮挡。
- 所有功能页面应以插件形式注册，并通过统一的插件管理器管理。
- 页面路由注册必须带上对应的 Binding，确保 Controller 正确注入。
- 页面跳转统一用 `Get.toNamed` 或 `Get.offAllNamed`，禁止直接 new 页面。
- 每个页面必须有独立的 Controller，且通过 Binding 注入。
- Controller 里所有状态必须用 Rx 类型（如 RxString、RxInt、RxBool）管理。
- 页面销毁时要注意关闭 Rx 变量，避免内存泄漏。
- 所有自定义组件必须支持主题色和国际化。
- 禁止在组件/页面中直接写死尺寸、颜色、文本，应通过参数、Theme、i18n 传递。
- 布局要自适应不同屏幕尺寸，避免溢出和遮挡。
- 所有页面/功能都要考虑多角色（customer/provider/customer+provider）适配。
- 角色切换时，页面、主题、插件、导航等都要自动切换到对应状态。

## 3. Backend Development Guidelines
- Code structure and modularity requirements
- RESTful/GraphQL API design principles
- Exception handling and error response standards
- Service registration, dependency injection, and configuration management
- Security best practices (authentication, authorization, input validation)
- Unit and integration testing requirements
- Logging and monitoring integration
- Documentation and code comments

## 4. Database Design Guidelines
- Table and field naming conventions (use English, snake_case)
- Data type selection and constraints
- Indexing and performance optimization
- Migration and version control
- Data security and privacy compliance
- Backup and disaster recovery

## 5. API & Interface Guidelines
- RESTful/GraphQL API design standards
- Versioning and backward compatibility
- Request/response format and error code conventions
- API documentation (OpenAPI/Swagger, GraphQL schema, etc.)
- Authentication and authorization
- Rate limiting and throttling

## 6. CI/CD & Automation Guidelines
- Branch management and naming conventions
- Automated testing and code quality checks
- Build, deployment, and rollback processes
- Environment configuration and secrets management
- Release versioning and tagging
- Monitoring and alerting integration

## 7. Logging & Monitoring Guidelines
### 7.1 日志级别划分
- DEBUG：调试信息，开发阶段详细追踪。
- INFO：关键业务流程、正常操作记录。
- WARNING：可恢复的异常、非致命问题。
- ERROR：严重错误、致命异常。

### 7.2 日志开关与输出控制
- 全局日志开关，通过配置或环境变量控制日志是否输出。
- 按级别开关，可单独开启/关闭某些级别日志。
- 生产环境自动关闭 DEBUG/INFO 日志，只保留 WARNING/ERROR。
- 日志输出可定向到控制台、文件、远程服务（如 Sentry、Crashlytics）。

### 7.3 日志使用规范
- 所有日志必须带有级别前缀，如 [DEBUG] [INFO] [WARNING] [ERROR]。
- 日志内容要包含上下文信息，如页面名、函数名、用户ID、角色、参数等。
- 禁止输出敏感信息（如密码、token、身份证号等）。
- 关键流程、异常捕获、分支判断、外部接口调用等必须加日志。

### 7.4 日志工具推荐实现
```dart
class AppLogger {
  static bool debugEnabled = true;
  static bool infoEnabled = true;
  static bool warningEnabled = true;
  static bool errorEnabled = true;

  static void debug(String msg) {
    if (debugEnabled) print('[DEBUG] $msg');
  }
  static void info(String msg) {
    if (infoEnabled) print('[INFO] $msg');
  }
  static void warning(String msg) {
    if (warningEnabled) print('[WARNING] $msg');
  }
  static void error(String msg) {
    if (errorEnabled) print('[ERROR] $msg');
  }
}
```

### 7.5 日志开关配置建议
- 开发环境：全部开启（DEBUG/INFO/WARNING/ERROR）
- 测试环境：INFO/WARNING/ERROR
- 生产环境：WARNING/ERROR（DEBUG/INFO 关闭）

### 7.6 日志与异常处理结合
- 所有 try-catch 必须在 catch 里加 error 日志，并带上堆栈信息。
- 关键业务流程的分支、失败、降级等都要有 warning 或 error 日志。

### 7.7 日志输出与隐私合规
- 禁止输出用户敏感信息。
- 生产环境日志如需远程收集，需脱敏处理。

### 7.8 日志规范执行流程
1. 开发前：明确本模块/页面的关键流程、异常点，设计日志点。
2. 开发中：严格按级别、格式、内容写日志。
3. 开发后：自查日志是否覆盖所有关键流程和异常。
4. 评审时：重点检查日志点和日志级别是否合规。

### 7.9 典型反例
- 只用 print()，无级别、无上下文。
- 生产环境输出 DEBUG/INFO 日志。
- 日志内容无关紧要或泄露敏感信息。
- 关键异常无日志，调试困难。

### 7.10 推荐日志点
- App 启动、插件加载、用户登录/注册/登出、角色切换、主题切换、接口调用、异常捕获、降级处理、权限校验、导航跳转等。

## 8. Code Review & Release Guidelines
- All new features and bug fixes must be reviewed by at least one other team member
- Review checklist: theme, i18n, plugin, DI, routing, role adaptation, logging, security, performance, documentation
- Pre-release full regression testing (all roles, all themes, all languages)
- Release notes and change log requirements

## 9. Appendix
- Glossary
- Common issues and troubleshooting
- Reference links and further reading

---

> **This guideline is mandatory for all JinBean project developers. Please read and follow before any development. For special cases, discuss and update the guideline as a team.** 