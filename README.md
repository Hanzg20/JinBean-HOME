# JinBean 项目总览

## 项目简介
JinBean 是一款为海外华人及本地居民提供便民生活服务的超级应用，支持多角色（客户/服务商）、插件化架构、多语言、主题切换等。

## 目录结构
```
/
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── Docu/
│   ├── system_design.md
│   ├── requirements.md
│   ├── development_progress.md
│   ├── database_schema.md
│   ├── database_setup.md
│   ├── api_rest_spec.md
│   ├── api_websocket_spec.md
│   ├── api_examples.md
│   ├── deployment_guide.md
│   ├── environment_config.md
│   ├── ci_cd_pipeline.md
│   ├── developer_guide.md
│   ├── user_manual.md
│   ├── admin_guide.md
│   ├── faq.md
│   └── migration_scripts/
└── (src/ 或 lib/ 代码目录)
```

## 文档使用规范

### 1. 文档分类与用途
- **README.md**：项目简介、目录结构、文档说明、快速启动。
- **CHANGELOG.md**：记录每次发布/迭代的主要变更。
- **CONTRIBUTING.md**：贡献指南，说明如何参与开发、提 issue、提 PR、代码规范等。
- **LICENSE**：开源协议或版权声明。
- **Docu/system_design.md**：系统整体架构设计、模块划分、数据库、角色、业务流程等。
- **Docu/requirements.md**：产品功能需求、用户故事、业务逻辑。
- **Docu/development_progress.md**：开发进度、任务分配、已完成/待办事项。
- **Docu/database_schema.md**：数据库设计、表结构、关系模型。
- **Docu/database_setup.md**：数据库初始化、配置说明。
- **Docu/api_rest_spec.md**：REST API 规范。
- **Docu/api_websocket_spec.md**：WebSocket API 规范。
- **Docu/api_examples.md**：API 使用示例。
- **Docu/deployment_guide.md**：部署指南。
- **Docu/environment_config.md**：环境配置说明。
- **Docu/ci_cd_pipeline.md**：CI/CD 流水线说明。
- **Docu/developer_guide.md**：开发环境搭建、编码规范、测试、排错等。
- **Docu/user_manual.md**：用户手册。
- **Docu/admin_guide.md**：管理员手册。
- **Docu/faq.md**：常见问题。

### 2. 命名与结构规范
- 所有文档采用英文命名、小写、下划线或中划线分隔。
- 目录结构清晰，主文档放 Docu/，根目录保留项目总览、协议、贡献等核心文件。
- 文档内容结构化，使用清晰的标题层级、目录、表格、代码块。

### 3. 维护与协作要求
- 重大变更时及时更新核心设计文档。
- 每次迭代后更新开发进度和变更记录。
- 新功能开发前先查阅/更新相关设计和需求文档。
- 贡献者请先阅读 CONTRIBUTING.md 并遵循代码/文档规范。
- 所有文档建议用 Markdown 编辑器（如 VS Code、Typora）维护。

### 4. 审核与发布流程
- 文档初稿由作者提交，技术负责人审核，团队讨论通过后归档。
- 重要文档建议保留历史版本。

---

如需详细设计、API、数据库等内容，请查阅 Docu/ 目录下对应文档。

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
