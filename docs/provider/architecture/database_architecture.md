# 数据库架构设计

> 本文档分析了JinBean项目中数据库架构的设计决策，包括单数据库实例vs多数据库实例的对比分析和最终方案。

## 🎯 架构决策问题

### 问题描述
在JinBean项目中，Provider端和Customer端的数据表应该：
- **方案A**: 在同一个数据库实例中，使用不同的Schema或表前缀
- **方案B**: 分成两个独立的数据库实例

## 📊 方案对比分析

### 方案A: 单数据库实例

#### 优势
1. **管理简单**
   - 单一数据库实例，运维成本低
   - 统一的备份和恢复策略
   - 统一的监控和告警

2. **成本效益**
   - 减少数据库实例费用
   - 减少运维人力成本
   - 减少存储成本

3. **数据一致性**
   - 跨端数据事务支持
   - 数据完整性约束
   - 避免数据同步问题

4. **查询便利**
   - 跨端数据关联查询
   - 统一的数据分析
   - 简化的报表生成

#### 劣势
1. **安全隔离**
   - 数据隔离性相对较弱
   - 权限管理复杂
   - 潜在的数据泄露风险

2. **性能影响**
   - 单点故障风险
   - 资源竞争
   - 扩展性限制

3. **维护复杂**
   - 表结构变更影响面大
   - 索引优化复杂
   - 性能调优困难

### 方案B: 多数据库实例

#### 优势
1. **安全隔离**
   - 完全的数据隔离
   - 独立的权限管理
   - 降低数据泄露风险

2. **性能优化**
   - 独立的资源配置
   - 针对性的性能调优
   - 更好的并发处理

3. **扩展性**
   - 独立扩展
   - 灵活的部署策略
   - 微服务架构友好

4. **故障隔离**
   - 单点故障影响范围小
   - 独立的故障恢复
   - 更好的可用性

#### 劣势
1. **管理复杂**
   - 多个数据库实例管理
   - 复杂的备份策略
   - 监控成本高

2. **成本增加**
   - 多个数据库实例费用
   - 运维成本增加
   - 存储成本增加

3. **数据同步**
   - 跨实例数据同步复杂
   - 数据一致性挑战
   - 事务处理困难

## 🏗 推荐方案：单数据库实例 + Schema隔离

### 1. 架构设计

```
┌─────────────────────────────────────────────────────────────┐
│                    JinBean Database                        │
├─────────────────────────────────────────────────────────────┤
│  public Schema (公共表)                                     │
│  ├── users (用户基础信息)                                   │
│  ├── auth (认证相关)                                        │
│  ├── notifications (通知)                                   │
│  └── system_config (系统配置)                               │
├─────────────────────────────────────────────────────────────┤
│  provider Schema (Provider端表)                             │
│  ├── provider_profiles (Provider配置)                       │
│  ├── provider_services (Provider服务)                       │
│  ├── provider_orders (Provider订单)                         │
│  ├── provider_clients (Provider客户)                        │
│  └── provider_income (Provider收入)                         │
├─────────────────────────────────────────────────────────────┤
│  customer Schema (Customer端表)                             │
│  ├── customer_profiles (Customer配置)                       │
│  ├── customer_orders (Customer订单)                         │
│  ├── customer_addresses (Customer地址)                      │
│  ├── customer_preferences (Customer偏好)                    │
│  └── customer_reviews (Customer评价)                        │
├─────────────────────────────────────────────────────────────┤
│  shared Schema (共享表)                                     │
│  ├── orders (订单主表)                                      │
│  ├── services (服务主表)                                    │
│  ├── payments (支付记录)                                    │
│  └── messages (消息记录)                                    │
└─────────────────────────────────────────────────────────────┘
```

### 2. Schema设计

#### public Schema (公共表)
```sql
-- 用户基础信息表
CREATE TABLE public.users (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    email text UNIQUE NOT NULL,
    phone text UNIQUE,
    display_name text NOT NULL,
    avatar text,
    status text NOT NULL DEFAULT 'active',
    user_type text NOT NULL, -- 'provider', 'customer', 'admin'
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 认证相关表
CREATE TABLE public.auth_sessions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    token text NOT NULL,
    expires_at timestamptz NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- 通知表
CREATE TABLE public.notifications (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title text NOT NULL,
    content text NOT NULL,
    type text NOT NULL, -- 'info', 'warning', 'error', 'success'
    is_read boolean DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- 系统配置表
CREATE TABLE public.system_config (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    config_key text UNIQUE NOT NULL,
    config_value text NOT NULL,
    description text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);
```

#### provider Schema (Provider端表)
```sql
-- 创建Provider Schema
CREATE SCHEMA IF NOT EXISTS provider;

-- Provider配置文件表
CREATE TABLE provider.provider_profiles (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    business_name text NOT NULL,
    business_description text,
    business_address text,
    business_phone text,
    business_email text,
    business_website text,
    service_categories text[],
    service_areas text[],
    working_hours jsonb,
    average_rating numeric DEFAULT 0,
    total_reviews integer DEFAULT 0,
    total_orders integer DEFAULT 0,
    total_income numeric DEFAULT 0,
    verification_status text DEFAULT 'pending',
    is_active boolean DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(user_id)
);

-- Provider服务表
CREATE TABLE provider.provider_services (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES provider.provider_profiles(id) ON DELETE CASCADE,
    service_name text NOT NULL,
    service_description text,
    service_category text NOT NULL,
    price numeric NOT NULL,
    price_type text NOT NULL DEFAULT 'fixed',
    duration_minutes integer,
    is_available boolean DEFAULT true,
    max_bookings_per_day integer,
    cancellation_policy text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Provider客户关系表
CREATE TABLE provider.provider_clients (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES provider.provider_profiles(id) ON DELETE CASCADE,
    client_user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
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

-- Provider收入记录表
CREATE TABLE provider.provider_income_records (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES provider.provider_profiles(id) ON DELETE CASCADE,
    order_id uuid NOT NULL REFERENCES shared.orders(id) ON DELETE CASCADE,
    amount numeric NOT NULL,
    commission_rate numeric DEFAULT 0.1,
    commission_amount numeric NOT NULL,
    net_amount numeric NOT NULL,
    payment_status text NOT NULL DEFAULT 'pending',
    payment_method text,
    payment_date timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);
```

#### customer Schema (Customer端表)
```sql
-- 创建Customer Schema
CREATE SCHEMA IF NOT EXISTS customer;

-- Customer配置文件表
CREATE TABLE customer.customer_profiles (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    default_address text,
    preferred_categories text[],
    total_spent numeric DEFAULT 0,
    total_orders integer DEFAULT 0,
    average_rating numeric DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(user_id)
);

-- Customer地址表
CREATE TABLE customer.customer_addresses (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id uuid NOT NULL REFERENCES customer.customer_profiles(id) ON DELETE CASCADE,
    address_type text NOT NULL, -- 'home', 'work', 'other'
    address_line1 text NOT NULL,
    address_line2 text,
    city text NOT NULL,
    state text NOT NULL,
    postal_code text NOT NULL,
    country text NOT NULL DEFAULT 'CN',
    is_default boolean DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Customer偏好表
CREATE TABLE customer.customer_preferences (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id uuid NOT NULL REFERENCES customer.customer_profiles(id) ON DELETE CASCADE,
    preference_key text NOT NULL,
    preference_value text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(customer_id, preference_key)
);

-- Customer评价表
CREATE TABLE customer.customer_reviews (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id uuid NOT NULL REFERENCES customer.customer_profiles(id) ON DELETE CASCADE,
    order_id uuid NOT NULL REFERENCES shared.orders(id) ON DELETE CASCADE,
    provider_id uuid NOT NULL REFERENCES provider.provider_profiles(id) ON DELETE CASCADE,
    rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text text,
    is_anonymous boolean DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);
```

#### shared Schema (共享表)
```sql
-- 创建Shared Schema
CREATE SCHEMA IF NOT EXISTS shared;

-- 订单主表
CREATE TABLE shared.orders (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    provider_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    service_id uuid NOT NULL,
    status text NOT NULL DEFAULT 'pending',
    amount numeric NOT NULL,
    scheduled_date timestamptz NOT NULL,
    actual_start_date timestamptz,
    actual_end_date timestamptz,
    customer_address_id uuid,
    notes text,
    cancellation_reason text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 服务主表
CREATE TABLE shared.services (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    service_name text NOT NULL,
    service_description text,
    service_category text NOT NULL,
    price numeric NOT NULL,
    price_type text NOT NULL DEFAULT 'fixed',
    duration_minutes integer,
    is_available boolean DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 支付记录表
CREATE TABLE shared.payments (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id uuid NOT NULL REFERENCES shared.orders(id) ON DELETE CASCADE,
    amount numeric NOT NULL,
    payment_method text NOT NULL,
    payment_status text NOT NULL DEFAULT 'pending',
    transaction_id text,
    payment_date timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 消息记录表
CREATE TABLE shared.messages (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    receiver_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    message_type text NOT NULL DEFAULT 'text', -- 'text', 'image', 'file'
    message_content text NOT NULL,
    is_read boolean DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now()
);
```

### 3. 权限管理

#### Schema级别权限
```sql
-- 为不同角色创建用户
CREATE USER provider_app WITH PASSWORD 'provider_password';
CREATE USER customer_app WITH PASSWORD 'customer_password';
CREATE USER admin_user WITH PASSWORD 'admin_password';

-- 授予Schema权限
GRANT USAGE ON SCHEMA public TO provider_app, customer_app, admin_user;
GRANT USAGE ON SCHEMA provider TO provider_app, admin_user;
GRANT USAGE ON SCHEMA customer TO customer_app, admin_user;
GRANT USAGE ON SCHEMA shared TO provider_app, customer_app, admin_user;

-- 授予表权限
-- Provider应用权限
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO provider_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA provider TO provider_app;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA shared TO provider_app;

-- Customer应用权限
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO customer_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA customer TO customer_app;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA shared TO customer_app;

-- 管理员权限
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA provider TO admin_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA customer TO admin_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA shared TO admin_user;
```

#### 行级安全策略 (RLS)
```sql
-- Provider端RLS策略
ALTER TABLE provider.provider_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Providers can view own profile" ON provider.provider_profiles
    FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Providers can update own profile" ON provider.provider_profiles
    FOR UPDATE USING (user_id = auth.uid());

-- Customer端RLS策略
ALTER TABLE customer.customer_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Customers can view own profile" ON customer.customer_profiles
    FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Customers can update own profile" ON customer.customer_profiles
    FOR UPDATE USING (user_id = auth.uid());

-- 共享表RLS策略
ALTER TABLE shared.orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own orders" ON shared.orders
    FOR SELECT USING (customer_id = auth.uid() OR provider_id = auth.uid());
CREATE POLICY "Customers can create orders" ON shared.orders
    FOR INSERT WITH CHECK (customer_id = auth.uid());
CREATE POLICY "Providers can update orders" ON shared.orders
    FOR UPDATE USING (provider_id = auth.uid());
```

### 4. 索引设计

#### 性能优化索引
```sql
-- 用户表索引
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_phone ON public.users(phone);
CREATE INDEX idx_users_user_type ON public.users(user_type);

-- Provider表索引
CREATE INDEX idx_provider_profiles_user_id ON provider.provider_profiles(user_id);
CREATE INDEX idx_provider_profiles_verification_status ON provider.provider_profiles(verification_status);
CREATE INDEX idx_provider_services_provider_id ON provider.provider_services(provider_id);
CREATE INDEX idx_provider_services_category ON provider.provider_services(service_category);

-- Customer表索引
CREATE INDEX idx_customer_profiles_user_id ON customer.customer_profiles(user_id);
CREATE INDEX idx_customer_addresses_customer_id ON customer.customer_addresses(customer_id);
CREATE INDEX idx_customer_reviews_customer_id ON customer.customer_reviews(customer_id);

-- 共享表索引
CREATE INDEX idx_orders_customer_id ON shared.orders(customer_id);
CREATE INDEX idx_orders_provider_id ON shared.orders(provider_id);
CREATE INDEX idx_orders_status ON shared.orders(status);
CREATE INDEX idx_orders_scheduled_date ON shared.orders(scheduled_date);
CREATE INDEX idx_payments_order_id ON shared.payments(order_id);
CREATE INDEX idx_messages_sender_receiver ON shared.messages(sender_id, receiver_id);
```

## 🔄 数据访问层设计

### 1. 数据库连接配置
```dart
// 数据库连接配置
class DatabaseConfig {
  static const String host = 'your-supabase-host';
  static const String port = '5432';
  static const String database = 'postgres';
  
  // Provider端连接
  static const String providerUser = 'provider_app';
  static const String providerPassword = 'provider_password';
  
  // Customer端连接
  static const String customerUser = 'customer_app';
  static const String customerPassword = 'customer_password';
  
  // 管理员连接
  static const String adminUser = 'admin_user';
  static const String adminPassword = 'admin_password';
}

// 数据库连接管理
class DatabaseConnectionManager {
  static final Map<String, SupabaseClient> _connections = {};
  
  static SupabaseClient getProviderConnection() {
    if (!_connections.containsKey('provider')) {
      _connections['provider'] = SupabaseClient(
        DatabaseConfig.host,
        DatabaseConfig.providerPassword,
        options: SupabaseClientOptions(
          db: DatabaseConfig.database,
          schema: 'provider,shared,public',
        ),
      );
    }
    return _connections['provider']!;
  }
  
  static SupabaseClient getCustomerConnection() {
    if (!_connections.containsKey('customer')) {
      _connections['customer'] = SupabaseClient(
        DatabaseConfig.host,
        DatabaseConfig.customerPassword,
        options: SupabaseClientOptions(
          db: DatabaseConfig.database,
          schema: 'customer,shared,public',
        ),
      );
    }
    return _connections['customer']!;
  }
  
  static SupabaseClient getAdminConnection() {
    if (!_connections.containsKey('admin')) {
      _connections['admin'] = SupabaseClient(
        DatabaseConfig.host,
        DatabaseConfig.adminPassword,
        options: SupabaseClientOptions(
          db: DatabaseConfig.database,
          schema: 'provider,customer,shared,public',
        ),
      );
    }
    return _connections['admin']!;
  }
}
```

### 2. Schema感知的数据访问
```dart
// Schema感知的数据库服务
class SchemaAwareDatabaseService {
  final SupabaseClient _client;
  final String _schema;
  
  SchemaAwareDatabaseService(this._client, this._schema);
  
  String _getTableName(String table) {
    return '$_schema.$table';
  }
  
  Future<List<Map<String, dynamic>>> query(String table, {
    String? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final tableName = _getTableName(table);
    // 实现查询逻辑
  }
  
  Future<Map<String, dynamic>> insert(String table, Map<String, dynamic> data) async {
    final tableName = _getTableName(table);
    // 实现插入逻辑
  }
  
  Future<void> update(String table, Map<String, dynamic> data, Map<String, dynamic> filters) async {
    final tableName = _getTableName(table);
    // 实现更新逻辑
  }
  
  Future<void> delete(String table, Map<String, dynamic> filters) async {
    final tableName = _getTableName(table);
    // 实现删除逻辑
  }
}

// Provider端数据库服务
class ProviderDatabaseService extends SchemaAwareDatabaseService {
  ProviderDatabaseService() : super(
    DatabaseConnectionManager.getProviderConnection(),
    'provider',
  );
}

// Customer端数据库服务
class CustomerDatabaseService extends SchemaAwareDatabaseService {
  CustomerDatabaseService() : super(
    DatabaseConnectionManager.getCustomerConnection(),
    'customer',
  );
}

// 共享数据库服务
class SharedDatabaseService extends SchemaAwareDatabaseService {
  SharedDatabaseService() : super(
    DatabaseConnectionManager.getProviderConnection(), // 或customer连接
    'shared',
  );
}
```

## 📊 性能优化策略

### 1. 查询优化
- **索引优化**: 为常用查询字段创建索引
- **分区表**: 对大数据量表进行分区
- **查询缓存**: 实现查询结果缓存
- **连接池**: 使用数据库连接池

### 2. 监控和告警
- **性能监控**: 监控查询响应时间
- **资源监控**: 监控CPU、内存、磁盘使用
- **连接监控**: 监控数据库连接数
- **错误监控**: 监控数据库错误

### 3. 备份和恢复
- **自动备份**: 定期自动备份
- **增量备份**: 实现增量备份策略
- **灾难恢复**: 制定灾难恢复计划
- **数据归档**: 对历史数据进行归档

## 🚀 实施计划

### 1. 第一阶段：基础架构 (1-2周)
- 创建数据库Schema
- 实现基础表结构
- 配置权限管理
- 建立索引

### 2. 第二阶段：数据访问层 (2-3周)
- 实现数据库连接管理
- 开发Schema感知的数据访问服务
- 实现基础CRUD操作
- 编写单元测试

### 3. 第三阶段：应用集成 (2-3周)
- 集成Provider端应用
- 集成Customer端应用
- 实现跨Schema查询
- 性能测试和优化

### 4. 第四阶段：监控和优化 (1-2周)
- 部署监控系统
- 性能调优
- 安全加固
- 文档完善

## ✅ 总结

### 推荐方案：单数据库实例 + Schema隔离

#### 选择理由
1. **成本效益**: 降低运维成本和数据库实例费用
2. **管理简单**: 单一数据库实例，便于管理
3. **数据一致性**: 支持跨端数据事务和关联查询
4. **安全隔离**: 通过Schema和权限管理实现数据隔离
5. **扩展性**: 支持未来功能扩展

#### 关键特性
- **Schema隔离**: 通过Schema实现逻辑隔离
- **权限管理**: 基于角色的细粒度权限控制
- **行级安全**: 实现数据行级安全策略
- **性能优化**: 针对性的索引和查询优化
- **监控告警**: 完善的监控和告警体系

这个方案在保证数据安全隔离的同时，最大化了成本效益和运维便利性，是JinBean项目的最佳选择！

---

**最后更新**: 2024年12月
**维护者**: 数据库架构团队 