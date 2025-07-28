# Provider端架构概览

> 本文档描述了JinBean项目中Provider端的整体架构设计，包括技术选型、架构模式、模块划分和系统集成。

## 🏗 架构设计原则

### 1. 分层架构
- **表现层 (Presentation Layer)**: UI界面和用户交互
- **业务逻辑层 (Business Logic Layer)**: 业务规则和流程控制
- **数据访问层 (Data Access Layer)**: 数据持久化和外部服务集成
- **基础设施层 (Infrastructure Layer)**: 系统服务和工具

### 2. 模块化设计
- **高内聚**: 相关功能聚集在同一模块内
- **低耦合**: 模块间依赖最小化
- **可扩展**: 支持功能模块的灵活扩展
- **可维护**: 便于代码维护和功能更新

### 3. 响应式架构
- **状态管理**: 使用GetX进行响应式状态管理
- **数据流**: 单向数据流，状态变化驱动UI更新
- **异步处理**: 支持异步操作和并发处理

## 🎯 技术架构

### 前端架构 (Flutter)

```
┌─────────────────────────────────────────────────────────────┐
│                    Provider端应用                            │
├─────────────────────────────────────────────────────────────┤
│  表现层 (Presentation Layer)                                │
│  ├── Pages (页面)                                           │
│  │   ├── HomePage (首页)                                    │
│  │   ├── OrderPage (订单页)                                 │
│  │   ├── ClientPage (客户页)                                │
│  │   └── SettingsPage (设置页)                              │
│  ├── Widgets (组件)                                         │
│  │   ├── CommonWidgets (通用组件)                           │
│  │   ├── OrderWidgets (订单组件)                            │
│  │   ├── ClientWidgets (客户组件)                           │
│  │   └── ServiceWidgets (服务组件)                          │
│  └── Navigation (导航)                                      │
│      └── BottomNavigation (底部导航)                        │
├─────────────────────────────────────────────────────────────┤
│  业务逻辑层 (Business Logic Layer)                          │
│  ├── Controllers (控制器)                                   │
│  │   ├── OrderController (订单控制器)                       │
│  │   ├── ClientController (客户控制器)                      │
│  │   ├── ServiceController (服务控制器)                     │
│  │   └── IncomeController (收入控制器)                      │
│  ├── Services (服务)                                        │
│  │   ├── ApiService (API服务)                               │
│  │   ├── AuthService (认证服务)                             │
│  │   ├── StorageService (存储服务)                          │
│  │   └── NotificationService (通知服务)                     │
│  └── Models (数据模型)                                      │
│      ├── Order (订单模型)                                   │
│      ├── Client (客户模型)                                  │
│      ├── Service (服务模型)                                 │
│      └── Income (收入模型)                                  │
├─────────────────────────────────────────────────────────────┤
│  数据访问层 (Data Access Layer)                             │
│  ├── Repositories (仓储)                                    │
│  │   ├── OrderRepository (订单仓储)                         │
│  │   ├── ClientRepository (客户仓储)                        │
│  │   ├── ServiceRepository (服务仓储)                       │
│  │   └── IncomeRepository (收入仓储)                        │
│  ├── Local Storage (本地存储)                               │
│  │   ├── SharedPreferences (偏好设置)                       │
│  │   └── SQLite (本地数据库)                                │
│  └── Remote APIs (远程API)                                  │
│      ├── Supabase API (Supabase接口)                        │
│      └── Third-party APIs (第三方接口)                      │
├─────────────────────────────────────────────────────────────┤
│  基础设施层 (Infrastructure Layer)                          │
│  ├── Network (网络)                                         │
│  │   ├── Dio (HTTP客户端)                                   │
│  │   ├── WebSocket (实时通信)                               │
│  │   └── Connectivity (网络状态)                            │
│  ├── Utils (工具类)                                         │
│  │   ├── Logger (日志)                                      │
│  │   ├── Validator (验证器)                                 │
│  │   ├── Formatter (格式化器)                               │
│  │   └── Constants (常量)                                   │
│  └── Config (配置)                                          │
│      ├── AppConfig (应用配置)                               │
│      ├── ApiConfig (API配置)                                │
│      └── ThemeConfig (主题配置)                             │
└─────────────────────────────────────────────────────────────┘
```

### 后端架构 (Supabase)

```
┌─────────────────────────────────────────────────────────────┐
│                    Supabase后端                              │
├─────────────────────────────────────────────────────────────┤
│  API Gateway (API网关)                                      │
│  ├── REST API (REST接口)                                    │
│  ├── GraphQL API (GraphQL接口)                              │
│  └── Real-time API (实时接口)                               │
├─────────────────────────────────────────────────────────────┤
│  Authentication (认证)                                      │
│  ├── User Management (用户管理)                             │
│  ├── Role-based Access (基于角色的访问控制)                 │
│  └── JWT Tokens (JWT令牌)                                   │
├─────────────────────────────────────────────────────────────┤
│  Database (数据库)                                          │
│  ├── PostgreSQL (主数据库)                                  │
│  │   ├── Provider Tables (Provider相关表)                   │
│  │   ├── Order Tables (订单相关表)                          │
│  │   ├── Client Tables (客户相关表)                         │
│  │   └── Service Tables (服务相关表)                        │
│  ├── Row Level Security (行级安全)                          │
│  └── Database Functions (数据库函数)                        │
├─────────────────────────────────────────────────────────────┤
│  Storage (存储)                                             │
│  ├── File Storage (文件存储)                                │
│  ├── Image Storage (图片存储)                               │
│  └── Document Storage (文档存储)                            │
├─────────────────────────────────────────────────────────────┤
│  Edge Functions (边缘函数)                                  │
│  ├── Business Logic (业务逻辑)                              │
│  ├── Data Processing (数据处理)                             │
│  └── Third-party Integration (第三方集成)                   │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 数据流架构

### 1. 单向数据流

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   用户操作   │───▶│   Controller │───▶│   Service   │
└─────────────┘    └─────────────┘    └─────────────┘
       ▲                   │                   │
       │                   ▼                   ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│     UI      │◀───│   State     │◀───│   API/DB    │
└─────────────┘    └─────────────┘    └─────────────┘
```

### 2. 状态管理流程

```
1. 用户触发操作
   ↓
2. Controller接收操作
   ↓
3. Controller调用Service
   ↓
4. Service处理业务逻辑
   ↓
5. Service调用API/Repository
   ↓
6. API/Repository返回数据
   ↓
7. Service处理响应数据
   ↓
8. Controller更新状态
   ↓
9. UI响应状态变化
```

## 🧩 模块划分

### 1. 核心模块

#### 订单管理模块 (Order Management)
- **职责**: 处理Provider端订单相关业务
- **组件**: 
  - OrderController
  - OrderService
  - OrderRepository
  - OrderPage
  - OrderWidgets

#### 客户管理模块 (Client Management)
- **职责**: 管理Provider与客户的关系
- **组件**:
  - ClientController
  - ClientService
  - ClientRepository
  - ClientPage
  - ClientWidgets

#### 服务管理模块 (Service Management)
- **职责**: 管理Provider提供的服务
- **组件**:
  - ServiceController
  - ServiceService
  - ServiceRepository
  - ServicePage
  - ServiceWidgets

#### 收入管理模块 (Income Management)
- **职责**: 管理Provider的收入和财务
- **组件**:
  - IncomeController
  - IncomeService
  - IncomeRepository
  - IncomePage
  - IncomeWidgets

### 2. 共享模块

#### 认证模块 (Authentication)
- **职责**: 处理用户认证和授权
- **组件**:
  - AuthService
  - AuthController
  - LoginPage
  - AuthWidgets

#### 通知模块 (Notification)
- **职责**: 处理应用内通知和消息
- **组件**:
  - NotificationService
  - NotificationController
  - NotificationPage
  - NotificationWidgets

#### 设置模块 (Settings)
- **职责**: 管理应用设置和配置
- **组件**:
  - SettingsService
  - SettingsController
  - SettingsPage
  - SettingsWidgets

## 🔌 系统集成

### 1. 外部服务集成

#### Supabase集成
- **认证服务**: 用户登录、注册、权限管理
- **数据库服务**: 数据存储、查询、事务处理
- **存储服务**: 文件上传、下载、管理
- **实时服务**: 实时数据同步、消息推送

#### 第三方服务集成
- **支付服务**: 订单支付、退款处理
- **地图服务**: 位置服务、地址解析
- **推送服务**: 消息推送、通知管理
- **分析服务**: 用户行为分析、性能监控

### 2. 内部模块集成

#### 模块间通信
- **事件总线**: 使用GetX的事件系统
- **依赖注入**: 使用GetX的依赖注入
- **路由管理**: 使用GetX的路由系统
- **状态共享**: 使用GetX的全局状态

#### 数据同步
- **本地缓存**: SharedPreferences和SQLite
- **网络同步**: 自动同步和手动刷新
- **冲突解决**: 时间戳和版本控制
- **离线支持**: 离线数据存储和同步

## 🚀 性能优化

### 1. 前端优化
- **懒加载**: 页面和组件按需加载
- **缓存策略**: 数据缓存和图片缓存
- **内存管理**: 及时释放不需要的资源
- **渲染优化**: 减少不必要的重建

### 2. 后端优化
- **数据库优化**: 索引优化和查询优化
- **API优化**: 接口缓存和响应优化
- **存储优化**: 文件压缩和CDN加速
- **监控优化**: 性能监控和错误追踪

## 🔒 安全设计

### 1. 数据安全
- **加密传输**: HTTPS和WSS协议
- **数据加密**: 敏感数据加密存储
- **访问控制**: 基于角色的权限控制
- **审计日志**: 操作日志和安全审计

### 2. 应用安全
- **输入验证**: 客户端和服务端验证
- **SQL注入防护**: 参数化查询
- **XSS防护**: 输出编码和内容过滤
- **CSRF防护**: Token验证和同源策略

## 📊 监控和日志

### 1. 应用监控
- **性能监控**: 页面加载时间和响应时间
- **错误监控**: 异常捕获和错误报告
- **用户行为**: 用户操作和页面访问
- **业务指标**: 订单量、收入、用户活跃度

### 2. 日志管理
- **日志级别**: DEBUG、INFO、WARN、ERROR
- **日志格式**: 结构化日志和JSON格式
- **日志存储**: 本地存储和云端存储
- **日志分析**: 日志聚合和分析工具

---

**最后更新**: 2024年12月
**维护者**: Provider端开发团队 