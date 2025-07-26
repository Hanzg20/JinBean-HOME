# Provider端客户管理功能设计

> 本文档详细描述了Provider端客户管理功能的设计，包括功能需求、技术实现、UI设计和开发计划。

## 🎯 功能概述

### 1. 功能定位
客户管理是Provider端的核心功能之一，用于管理Provider与客户之间的关系，包括客户信息管理、沟通记录、订单历史等。

### 2. 目标用户
- **主要用户**: Provider（服务提供者）
- **次要用户**: 系统管理员

### 3. 核心价值
- 帮助Provider更好地管理客户关系
- 提供客户历史订单和沟通记录
- 支持客户分类和状态管理
- 提升客户服务质量

## 📋 功能需求

### 1. 客户列表管理
- **客户列表展示**: 显示所有与Provider有关系的客户
- **客户搜索**: 支持按姓名、手机号、邮箱搜索
- **客户筛选**: 按状态、类型、时间范围筛选
- **客户排序**: 按订单数量、消费金额、最后联系时间排序

### 2. 客户信息管理
- **基本信息**: 姓名、手机号、邮箱、地址
- **客户状态**: 活跃、不活跃、潜在客户
- **客户类型**: 已服务客户、潜在客户
- **客户备注**: 自定义备注信息

### 3. 客户沟通管理
- **沟通记录**: 记录与客户的沟通历史
- **消息发送**: 向客户发送消息
- **电话拨打**: 一键拨打客户电话
- **沟通统计**: 沟通频率和效果统计

### 4. 客户订单管理
- **订单历史**: 查看客户的历史订单
- **订单统计**: 订单数量、消费金额统计
- **订单状态**: 订单状态跟踪
- **订单详情**: 订单详细信息查看

## 🏗 技术设计

### 1. 数据模型设计

#### 简化的客户模型
```dart
class SimpleClient {
  final String id;                    // 客户ID
  final String providerId;            // 服务商ID
  final String clientUserId;          // 客户用户ID
  final String displayName;           // 显示名称
  final String? phone;                // 手机号
  final String? email;                // 邮箱
  final String status;                // 客户状态：'active', 'inactive'
  final int totalOrders;              // 总订单数
  final double totalSpent;            // 总消费金额
  final double averageRating;         // 平均评分
  final DateTime? firstOrderDate;     // 首次订单日期
  final DateTime? lastOrderDate;      // 最后订单日期
  final DateTime? lastContactDate;    // 最后联系日期
  final String? notes;                // 备注
  final DateTime createdAt;           // 创建时间
  final DateTime updatedAt;           // 更新时间
}
```

#### 客户沟通记录模型
```dart
class ClientCommunication {
  final String id;                    // 记录ID
  final String providerId;            // 服务商ID
  final String clientUserId;          // 客户用户ID
  final String message;               // 消息内容
  final String direction;             // 方向：'inbound', 'outbound'
  final DateTime createdAt;           // 创建时间
}
```

### 2. 数据库设计

#### 客户关系表
```sql
CREATE TABLE simple_client_relationships (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    client_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name text NOT NULL DEFAULT '未知客户',
    phone text,
    email text,
    status text NOT NULL DEFAULT 'active',
    total_orders integer NOT NULL DEFAULT 0,
    total_spent numeric NOT NULL DEFAULT 0,
    average_rating numeric DEFAULT 0,
    first_order_date timestamptz,
    last_order_date timestamptz,
    last_contact_date timestamptz,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(provider_id, client_user_id)
);
```

#### 客户沟通记录表
```sql
CREATE TABLE simple_client_communications (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    client_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    message text NOT NULL,
    direction text NOT NULL DEFAULT 'outbound',
    created_at timestamptz NOT NULL DEFAULT now()
);
```

### 3. API设计

#### 客户管理API
```dart
class SimpleClientApiService {
  // 获取客户列表
  Future<List<SimpleClient>> getClients({
    required String providerId,
    String? searchQuery,
    String? status,
    int? limit,
    int? offset,
  });
  
  // 获取客户详情
  Future<SimpleClient> getClient({
    required String providerId,
    required String clientUserId,
  });
  
  // 更新客户信息
  Future<void> updateClient({
    required String providerId,
    required String clientUserId,
    required Map<String, dynamic> updates,
  });
  
  // 添加客户备注
  Future<void> addClientNote({
    required String providerId,
    required String clientUserId,
    required String note,
  });
  
  // 记录客户沟通
  Future<void> recordCommunication({
    required String providerId,
    required String clientUserId,
    required String message,
    required String direction,
  });
  
  // 获取客户沟通历史
  Future<List<Map<String, dynamic>>> getClientCommunications({
    required String providerId,
    required String clientUserId,
    int? limit,
  });
}
```

### 4. 控制器设计

#### 客户控制器
```dart
class SimpleClientController extends GetxController {
  final SimpleClientApiService _apiService = Get.find<SimpleClientApiService>();
  
  final RxList<SimpleClient> clients = <SimpleClient>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'all'.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadClients();
  }
  
  // 加载客户列表
  Future<void> loadClients() async;
  
  // 更新搜索查询
  void updateSearchQuery(String query);
  
  // 按状态筛选
  void filterByStatus(String status);
  
  // 导航到客户详情
  void navigateToClientDetail(SimpleClient client);
  
  // 添加客户备注
  Future<void> addClientNote(SimpleClient client, String note) async;
  
  // 记录客户沟通
  Future<void> recordCommunication(SimpleClient client, String message) async;
}
```

## 🎨 UI设计

### 1. 客户列表页面

#### 页面布局
```
┌─────────────────────────────────────────────────────────────┐
│  AppBar: 客户管理                                           │
├─────────────────────────────────────────────────────────────┤
│  搜索栏: [搜索客户姓名或手机号...] [🔍]                     │
├─────────────────────────────────────────────────────────────┤
│  状态筛选: [全部] [活跃] [不活跃]                           │
├─────────────────────────────────────────────────────────────┤
│  客户列表:                                                  │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ [头像] 客户姓名                    [状态标签]            │ │
│  │     订单: 5 | 消费: $500                               │ │
│  │     最后订单: 2024-12-01                               │ │
│  └─────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ [头像] 客户姓名                    [状态标签]            │ │
│  │     订单: 3 | 消费: $300                               │ │
│  │     最后订单: 2024-11-28                               │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

#### 交互功能
- **搜索**: 实时搜索，支持姓名和手机号
- **筛选**: 点击状态按钮切换筛选条件
- **排序**: 下拉菜单选择排序方式
- **刷新**: 下拉刷新客户列表
- **点击**: 点击客户卡片进入详情页

### 2. 客户详情页面

#### 页面布局
```
┌─────────────────────────────────────────────────────────────┐
│  AppBar: 客户详情 [编辑]                                    │
├─────────────────────────────────────────────────────────────┤
│  基本信息卡片:                                              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ 基本信息                                                │ │
│  │ 姓名: 张三                                              │ │
│  │ 手机号: 138****1234                                     │ │
│  │ 邮箱: zhangsan@email.com                                │ │
│  │ 状态: 活跃                                              │ │
│  │ 创建时间: 2024-01-15                                    │ │
│  └─────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  统计信息卡片:                                              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ 统计信息                                                │ │
│  │ [5] [总消费] [4.5]                                      │ │
│  │ 总订单     $500    平均评分                             │ │
│  │ 首次订单: 2024-01-20                                    │ │
│  │ 最后订单: 2024-12-01                                    │ │
│  └─────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  备注卡片:                                                  │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ 备注 [+添加]                                            │ │
│  │ 这是一个重要客户，需要重点关注...                       │ │
│  └─────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  快速操作卡片:                                              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ 快速操作                                                │ │
│  │ [发送消息] [拨打电话]                                   │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

#### 交互功能
- **编辑**: 点击编辑按钮修改客户信息
- **添加备注**: 点击添加按钮输入备注
- **发送消息**: 点击发送消息按钮打开对话框
- **拨打电话**: 点击拨打电话按钮直接拨打
- **查看订单**: 点击订单统计查看详细订单

### 3. 组件设计

#### 客户卡片组件
```dart
class ClientCard extends StatelessWidget {
  final SimpleClient client;
  final VoidCallback? onTap;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            client.displayName.substring(0, 1).toUpperCase(),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          client.displayName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text('订单: ${client.totalOrders} | 消费: \$${client.totalSpent.toStringAsFixed(2)}'),
            if (client.lastOrderDate != null)
              Text('最后订单: ${_formatDate(client.lastOrderDate!)}'),
          ],
        ),
        trailing: _buildClientStatusChip(client),
        onTap: onTap,
      ),
    );
  }
}
```

#### 状态标签组件
```dart
class StatusChip extends StatelessWidget {
  final String status;
  
  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    
    switch (status) {
      case 'active':
        color = Colors.green;
        text = '活跃';
        break;
      case 'inactive':
        color = Colors.grey;
        text = '不活跃';
        break;
      default:
        color = Colors.orange;
        text = '未知';
    }
    
    return Chip(
      label: Text(text, style: TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
    );
  }
}
```

## 📅 开发计划

### 1. 第一阶段：核心功能 (5-7天)

#### 数据层 (2-3天)
- [ ] 创建数据库表结构
- [ ] 实现API服务
- [ ] 编写数据模型
- [ ] 测试数据操作

#### 业务逻辑层 (2-3天)
- [ ] 实现客户控制器
- [ ] 实现搜索和筛选逻辑
- [ ] 实现客户操作功能
- [ ] 编写单元测试

#### 表现层 (1-2天)
- [ ] 实现客户列表页面
- [ ] 实现客户详情页面
- [ ] 集成到导航系统
- [ ] 基础UI测试

### 2. 第二阶段：增强功能 (3-5天)

#### 高级功能
- [ ] 客户沟通记录
- [ ] 客户备注管理
- [ ] 客户状态管理
- [ ] 客户统计图表

#### 用户体验
- [ ] 加载状态优化
- [ ] 错误处理完善
- [ ] 空状态设计
- [ ] 动画效果

### 3. 第三阶段：优化和测试 (2-3天)

#### 性能优化
- [ ] 列表性能优化
- [ ] 图片缓存优化
- [ ] 网络请求优化
- [ ] 内存使用优化

#### 测试和部署
- [ ] 集成测试
- [ ] UI自动化测试
- [ ] 性能测试
- [ ] 生产环境部署

## 🧪 测试策略

### 1. 单元测试
- **控制器测试**: 测试业务逻辑
- **服务测试**: 测试API调用
- **模型测试**: 测试数据转换

### 2. 集成测试
- **API集成测试**: 测试与后端交互
- **数据库集成测试**: 测试数据持久化
- **状态管理测试**: 测试状态变化

### 3. UI测试
- **页面导航测试**: 测试页面跳转
- **用户交互测试**: 测试用户操作
- **响应式测试**: 测试不同屏幕尺寸

### 4. 性能测试
- **加载性能**: 测试页面加载时间
- **内存使用**: 测试内存占用
- **网络性能**: 测试API响应时间

## 📊 成功指标

### 1. 功能指标
- **功能完整性**: 100%实现需求功能
- **错误率**: < 1%的功能错误
- **响应时间**: < 2秒的页面加载时间

### 2. 用户体验指标
- **用户满意度**: > 90%的用户满意度
- **使用频率**: 日活跃用户 > 80%
- **功能使用率**: 核心功能使用率 > 70%

### 3. 技术指标
- **代码覆盖率**: > 80%的测试覆盖率
- **性能指标**: 内存使用 < 100MB
- **稳定性**: 崩溃率 < 0.1%

## 🔄 迭代计划

### 1. 版本1.0 (MVP)
- 基础客户列表和详情
- 简单搜索和筛选
- 客户基本信息管理

### 2. 版本1.1
- 客户沟通记录
- 客户备注功能
- 客户状态管理

### 3. 版本1.2
- 客户统计图表
- 高级搜索功能
- 客户标签管理

### 4. 版本2.0
- 客户价值分析
- 客户行为分析
- 客户推荐系统

---

**最后更新**: 2024年12月
**维护者**: Provider端开发团队 