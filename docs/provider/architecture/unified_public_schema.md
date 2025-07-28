# 统一Public Schema数据库架构设计

> 本文档描述了JinBean项目采用统一public schema的数据库架构设计，所有表都放在public schema中，通过表名前缀和权限管理实现数据隔离。

## 🎯 架构决策

### 设计原则
- **简化管理**: 所有表统一在public schema中
- **表名前缀**: 通过表名前缀区分不同模块
- **权限隔离**: 通过行级安全策略实现数据隔离
- **统一访问**: 简化数据访问层设计

### 命名规范
- **用户相关**: `users_*`
- **Provider相关**: `provider_*`
- **Customer相关**: `customer_*`
- **订单相关**: `orders_*`
- **服务相关**: `services_*`
- **支付相关**: `payments_*`
- **消息相关**: `messages_*`
- **系统相关**: `system_*`

## 🏗 表结构设计

### 1. 用户基础表

#### 用户表
```sql
-- 用户基础信息表
CREATE TABLE public.users (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    email text UNIQUE NOT NULL,
    phone text UNIQUE,
    display_name text NOT NULL,
    avatar text,
    status text NOT NULL DEFAULT 'active', -- 'active', 'inactive', 'suspended'
    user_type text NOT NULL, -- 'provider', 'customer', 'admin'
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 用户认证会话表
CREATE TABLE public.users_auth_sessions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    token text NOT NULL,
    expires_at timestamptz NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- 用户地址表
CREATE TABLE public.users_addresses (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
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
```

### 2. Provider相关表

#### Provider配置文件表
```sql
CREATE TABLE public.provider_profiles (
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
    verification_status text DEFAULT 'pending', -- 'pending', 'verified', 'rejected'
    is_active boolean DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(user_id)
);
```

#### Provider服务表
```sql
CREATE TABLE public.provider_services (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    service_name text NOT NULL,
    service_description text,
    service_category text NOT NULL,
    price numeric NOT NULL,
    price_type text NOT NULL DEFAULT 'fixed', -- 'fixed', 'hourly', 'negotiable'
    duration_minutes integer,
    is_available boolean DEFAULT true,
    max_bookings_per_day integer,
    cancellation_policy text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);
```

#### Provider客户关系表
```sql
CREATE TABLE public.provider_clients (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    client_user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    display_name text NOT NULL DEFAULT '未知客户',
    phone text,
    email text,
    status text NOT NULL DEFAULT 'active', -- 'active', 'inactive'
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

#### Provider收入记录表
```sql
CREATE TABLE public.provider_income_records (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    order_id uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    amount numeric NOT NULL,
    commission_rate numeric DEFAULT 0.1,
    commission_amount numeric NOT NULL,
    net_amount numeric NOT NULL,
    payment_status text NOT NULL DEFAULT 'pending', -- 'pending', 'paid', 'cancelled'
    payment_method text,
    payment_date timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);
```

### 3. Customer相关表

#### Customer配置文件表
```sql
CREATE TABLE public.customer_profiles (
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
```

#### Customer偏好表
```sql
CREATE TABLE public.customer_preferences (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id uuid NOT NULL REFERENCES public.customer_profiles(id) ON DELETE CASCADE,
    preference_key text NOT NULL,
    preference_value text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(customer_id, preference_key)
);
```

#### Customer评价表
```sql
CREATE TABLE public.customer_reviews (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id uuid NOT NULL REFERENCES public.customer_profiles(id) ON DELETE CASCADE,
    order_id uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text text,
    is_anonymous boolean DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);
```

### 4. 订单相关表

#### 订单主表
```sql
CREATE TABLE public.orders (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    provider_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    service_id uuid NOT NULL REFERENCES public.provider_services(id) ON DELETE CASCADE,
    status text NOT NULL DEFAULT 'pending', -- 'pending', 'accepted', 'in_progress', 'completed', 'cancelled'
    amount numeric NOT NULL,
    scheduled_date timestamptz NOT NULL,
    actual_start_date timestamptz,
    actual_end_date timestamptz,
    customer_address_id uuid REFERENCES public.users_addresses(id),
    notes text,
    cancellation_reason text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);
```

#### 订单状态历史表
```sql
CREATE TABLE public.orders_status_history (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    status text NOT NULL,
    changed_by uuid NOT NULL REFERENCES public.users(id),
    reason text,
    created_at timestamptz NOT NULL DEFAULT now()
);
```

### 5. 支付相关表

#### 支付记录表
```sql
CREATE TABLE public.payments (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    amount numeric NOT NULL,
    payment_method text NOT NULL, -- 'credit_card', 'debit_card', 'bank_transfer', 'digital_wallet'
    payment_status text NOT NULL DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'failed', 'refunded'
    transaction_id text,
    payment_date timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);
```

### 6. 消息相关表

#### 消息记录表
```sql
CREATE TABLE public.messages (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    receiver_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    message_type text NOT NULL DEFAULT 'text', -- 'text', 'image', 'file'
    message_content text NOT NULL,
    is_read boolean DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now()
);
```

### 7. 通知相关表

#### 通知表
```sql
CREATE TABLE public.notifications (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title text NOT NULL,
    content text NOT NULL,
    type text NOT NULL, -- 'info', 'warning', 'error', 'success'
    is_read boolean DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now()
);
```

### 8. 系统相关表

#### 系统配置表
```sql
CREATE TABLE public.system_config (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    config_key text UNIQUE NOT NULL,
    config_value text NOT NULL,
    description text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);
```

## 🔒 权限管理

### 1. 角色定义
```sql
-- 创建应用角色
CREATE ROLE provider_app;
CREATE ROLE customer_app;
CREATE ROLE admin_user;

-- 设置密码
ALTER ROLE provider_app WITH PASSWORD 'provider_password';
ALTER ROLE customer_app WITH PASSWORD 'customer_password';
ALTER ROLE admin_user WITH PASSWORD 'admin_password';
```

### 2. 表权限
```sql
-- Provider应用权限
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO provider_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO provider_app;

-- Customer应用权限
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO customer_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO customer_app;

-- 管理员权限
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin_user;
```

### 3. 行级安全策略 (RLS)

#### 用户表RLS
```sql
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 用户只能查看自己的信息
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (id = auth.uid());

-- 用户只能更新自己的信息
CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (id = auth.uid());
```

#### Provider表RLS
```sql
-- Provider配置文件
ALTER TABLE public.provider_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Providers can view own profile" ON public.provider_profiles
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Providers can update own profile" ON public.provider_profiles
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Providers can insert own profile" ON public.provider_profiles
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Provider服务
ALTER TABLE public.provider_services ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Providers can manage own services" ON public.provider_services
    FOR ALL USING (
        provider_id IN (
            SELECT id FROM public.provider_profiles 
            WHERE user_id = auth.uid()
        )
    );

-- Provider客户关系
ALTER TABLE public.provider_clients ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Providers can manage own clients" ON public.provider_clients
    FOR ALL USING (
        provider_id IN (
            SELECT id FROM public.provider_profiles 
            WHERE user_id = auth.uid()
        )
    );

-- Provider收入记录
ALTER TABLE public.provider_income_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Providers can view own income" ON public.provider_income_records
    FOR SELECT USING (
        provider_id IN (
            SELECT id FROM public.provider_profiles 
            WHERE user_id = auth.uid()
        )
    );
```

#### Customer表RLS
```sql
-- Customer配置文件
ALTER TABLE public.customer_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Customers can view own profile" ON public.customer_profiles
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Customers can update own profile" ON public.customer_profiles
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Customers can insert own profile" ON public.customer_profiles
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Customer偏好
ALTER TABLE public.customer_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Customers can manage own preferences" ON public.customer_preferences
    FOR ALL USING (
        customer_id IN (
            SELECT id FROM public.customer_profiles 
            WHERE user_id = auth.uid()
        )
    );

-- Customer评价
ALTER TABLE public.customer_reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Customers can manage own reviews" ON public.customer_reviews
    FOR ALL USING (
        customer_id IN (
            SELECT id FROM public.customer_profiles 
            WHERE user_id = auth.uid()
        )
    );
```

#### 订单表RLS
```sql
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- 用户只能查看自己相关的订单
CREATE POLICY "Users can view own orders" ON public.orders
    FOR SELECT USING (customer_id = auth.uid() OR provider_id = auth.uid());

-- 客户可以创建订单
CREATE POLICY "Customers can create orders" ON public.orders
    FOR INSERT WITH CHECK (customer_id = auth.uid());

-- Provider可以更新订单状态
CREATE POLICY "Providers can update orders" ON public.orders
    FOR UPDATE USING (provider_id = auth.uid());
```

#### 消息表RLS
```sql
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- 用户只能查看自己发送或接收的消息
CREATE POLICY "Users can view own messages" ON public.messages
    FOR SELECT USING (sender_id = auth.uid() OR receiver_id = auth.uid());

-- 用户只能发送消息
CREATE POLICY "Users can send messages" ON public.messages
    FOR INSERT WITH CHECK (sender_id = auth.uid());
```

## 📊 索引设计

### 1. 用户相关索引
```sql
-- 用户表索引
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_phone ON public.users(phone);
CREATE INDEX idx_users_user_type ON public.users(user_type);
CREATE INDEX idx_users_status ON public.users(status);

-- 用户地址索引
CREATE INDEX idx_users_addresses_user_id ON public.users_addresses(user_id);
CREATE INDEX idx_users_addresses_is_default ON public.users_addresses(user_id, is_default);
```

### 2. Provider相关索引
```sql
-- Provider配置文件索引
CREATE INDEX idx_provider_profiles_user_id ON public.provider_profiles(user_id);
CREATE INDEX idx_provider_profiles_verification_status ON public.provider_profiles(verification_status);
CREATE INDEX idx_provider_profiles_is_active ON public.provider_profiles(is_active);
CREATE INDEX idx_provider_profiles_service_categories ON public.provider_profiles USING GIN(service_categories);

-- Provider服务索引
CREATE INDEX idx_provider_services_provider_id ON public.provider_services(provider_id);
CREATE INDEX idx_provider_services_category ON public.provider_services(service_category);
CREATE INDEX idx_provider_services_is_available ON public.provider_services(is_available);

-- Provider客户关系索引
CREATE INDEX idx_provider_clients_provider_id ON public.provider_clients(provider_id);
CREATE INDEX idx_provider_clients_client_user_id ON public.provider_clients(client_user_id);
CREATE INDEX idx_provider_clients_status ON public.provider_clients(status);
CREATE INDEX idx_provider_clients_last_order_date ON public.provider_clients(last_order_date);

-- Provider收入记录索引
CREATE INDEX idx_provider_income_records_provider_id ON public.provider_income_records(provider_id);
CREATE INDEX idx_provider_income_records_order_id ON public.provider_income_records(order_id);
CREATE INDEX idx_provider_income_records_payment_status ON public.provider_income_records(payment_status);
```

### 3. Customer相关索引
```sql
-- Customer配置文件索引
CREATE INDEX idx_customer_profiles_user_id ON public.customer_profiles(user_id);

-- Customer偏好索引
CREATE INDEX idx_customer_preferences_customer_id ON public.customer_preferences(customer_id);
CREATE INDEX idx_customer_preferences_key ON public.customer_preferences(customer_id, preference_key);

-- Customer评价索引
CREATE INDEX idx_customer_reviews_customer_id ON public.customer_reviews(customer_id);
CREATE INDEX idx_customer_reviews_provider_id ON public.customer_reviews(provider_id);
CREATE INDEX idx_customer_reviews_order_id ON public.customer_reviews(order_id);
CREATE INDEX idx_customer_reviews_rating ON public.customer_reviews(rating);
```

### 4. 订单相关索引
```sql
-- 订单主表索引
CREATE INDEX idx_orders_customer_id ON public.orders(customer_id);
CREATE INDEX idx_orders_provider_id ON public.orders(provider_id);
CREATE INDEX idx_orders_service_id ON public.orders(service_id);
CREATE INDEX idx_orders_status ON public.orders(status);
CREATE INDEX idx_orders_scheduled_date ON public.orders(scheduled_date);
CREATE INDEX idx_orders_created_at ON public.orders(created_at);

-- 订单状态历史索引
CREATE INDEX idx_orders_status_history_order_id ON public.orders_status_history(order_id);
CREATE INDEX idx_orders_status_history_created_at ON public.orders_status_history(created_at);
```

### 5. 支付相关索引
```sql
-- 支付记录索引
CREATE INDEX idx_payments_order_id ON public.payments(order_id);
CREATE INDEX idx_payments_payment_status ON public.payments(payment_status);
CREATE INDEX idx_payments_payment_date ON public.payments(payment_date);
CREATE INDEX idx_payments_transaction_id ON public.payments(transaction_id);
```

### 6. 消息相关索引
```sql
-- 消息记录索引
CREATE INDEX idx_messages_sender_id ON public.messages(sender_id);
CREATE INDEX idx_messages_receiver_id ON public.messages(receiver_id);
CREATE INDEX idx_messages_sender_receiver ON public.messages(sender_id, receiver_id);
CREATE INDEX idx_messages_created_at ON public.messages(created_at);
CREATE INDEX idx_messages_is_read ON public.messages(receiver_id, is_read);
```

### 7. 通知相关索引
```sql
-- 通知索引
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_is_read ON public.notifications(user_id, is_read);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at);
```

## 🔄 触发器设计

### 1. 更新时间触发器
```sql
-- 创建更新时间函数
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为所有表添加更新时间触发器
CREATE TRIGGER set_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER set_provider_profiles_updated_at
    BEFORE UPDATE ON public.provider_profiles
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER set_provider_services_updated_at
    BEFORE UPDATE ON public.provider_services
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER set_provider_clients_updated_at
    BEFORE UPDATE ON public.provider_clients
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER set_customer_profiles_updated_at
    BEFORE UPDATE ON public.customer_profiles
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER set_orders_updated_at
    BEFORE UPDATE ON public.orders
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER set_payments_updated_at
    BEFORE UPDATE ON public.payments
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();
```

### 2. 统计更新触发器
```sql
-- 订单创建时更新统计
CREATE OR REPLACE FUNCTION update_order_statistics()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- 更新Provider统计
        UPDATE public.provider_profiles 
        SET 
            total_orders = total_orders + 1,
            updated_at = now()
        WHERE user_id = NEW.provider_id;
        
        -- 更新Customer统计
        UPDATE public.customer_profiles 
        SET 
            total_orders = total_orders + 1,
            updated_at = now()
        WHERE user_id = NEW.customer_id;
        
    ELSIF TG_OP = 'UPDATE' AND NEW.status = 'completed' AND OLD.status != 'completed' THEN
        -- 订单完成时更新收入统计
        UPDATE public.provider_profiles 
        SET 
            total_income = total_income + NEW.amount,
            updated_at = now()
        WHERE user_id = NEW.provider_id;
        
        UPDATE public.customer_profiles 
        SET 
            total_spent = total_spent + NEW.amount,
            updated_at = now()
        WHERE user_id = NEW.customer_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_order_statistics
    AFTER INSERT OR UPDATE ON public.orders
    FOR EACH ROW
    EXECUTE FUNCTION update_order_statistics();
```

## 📋 数据访问层设计

### 1. 统一数据库连接
```dart
// 统一数据库连接配置
class DatabaseConfig {
  static const String host = 'your-supabase-host';
  static const String database = 'postgres';
  static const String schema = 'public';
  
  // 不同角色的连接配置
  static const Map<String, dynamic> providerConfig = {
    'username': 'provider_app',
    'password': 'provider_password',
  };
  
  static const Map<String, dynamic> customerConfig = {
    'username': 'customer_app',
    'password': 'customer_password',
  };
  
  static const Map<String, dynamic> adminConfig = {
    'username': 'admin_user',
    'password': 'admin_password',
  };
}

// 统一数据库连接管理
class DatabaseConnectionManager {
  static final Map<String, SupabaseClient> _connections = {};
  
  static SupabaseClient getProviderConnection() {
    if (!_connections.containsKey('provider')) {
      _connections['provider'] = SupabaseClient(
        DatabaseConfig.host,
        DatabaseConfig.providerConfig['password'],
        options: SupabaseClientOptions(
          db: DatabaseConfig.database,
          schema: DatabaseConfig.schema,
        ),
      );
    }
    return _connections['provider']!;
  }
  
  static SupabaseClient getCustomerConnection() {
    if (!_connections.containsKey('customer')) {
      _connections['customer'] = SupabaseClient(
        DatabaseConfig.host,
        DatabaseConfig.customerConfig['password'],
        options: SupabaseClientOptions(
          db: DatabaseConfig.database,
          schema: DatabaseConfig.schema,
        ),
      );
    }
    return _connections['customer']!;
  }
  
  static SupabaseClient getAdminConnection() {
    if (!_connections.containsKey('admin')) {
      _connections['admin'] = SupabaseClient(
        DatabaseConfig.host,
        DatabaseConfig.adminConfig['password'],
        options: SupabaseClientOptions(
          db: DatabaseConfig.database,
          schema: DatabaseConfig.schema,
        ),
      );
    }
    return _connections['admin']!;
  }
}
```

### 2. 统一数据访问服务
```dart
// 统一数据库服务
class UnifiedDatabaseService {
  final SupabaseClient _client;
  
  UnifiedDatabaseService(this._client);
  
  // 通用查询方法
  Future<List<Map<String, dynamic>>> query(String table, {
    String? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client.from(table).select(select ?? '*');
      
      if (filters != null) {
        filters.forEach((key, value) {
          if (value is List) {
            query = query.inFilter(key, value);
          } else {
            query = query.eq(key, value);
          }
        });
      }
      
      if (orderBy != null) {
        query = query.order(orderBy);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 50) - 1);
      }
      
      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('查询失败: $e');
    }
  }
  
  // 通用插入方法
  Future<Map<String, dynamic>> insert(String table, Map<String, dynamic> data) async {
    try {
      final response = await _client.from(table).insert(data).select().single();
      return response;
    } catch (e) {
      throw Exception('插入失败: $e');
    }
  }
  
  // 通用更新方法
  Future<void> update(String table, Map<String, dynamic> data, Map<String, dynamic> filters) async {
    try {
      var query = _client.from(table).update(data);
      
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
      
      await query;
    } catch (e) {
      throw Exception('更新失败: $e');
    }
  }
  
  // 通用删除方法
  Future<void> delete(String table, Map<String, dynamic> filters) async {
    try {
      var query = _client.from(table).delete();
      
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
      
      await query;
    } catch (e) {
      throw Exception('删除失败: $e');
    }
  }
}

// Provider端数据库服务
class ProviderDatabaseService extends UnifiedDatabaseService {
  ProviderDatabaseService() : super(DatabaseConnectionManager.getProviderConnection());
  
  // Provider特定方法
  Future<List<Map<String, dynamic>>> getProviderOrders(String providerId) async {
    return query('orders', filters: {'provider_id': providerId});
  }
  
  Future<List<Map<String, dynamic>>> getProviderClients(String providerId) async {
    return query('provider_clients', filters: {'provider_id': providerId});
  }
}

// Customer端数据库服务
class CustomerDatabaseService extends UnifiedDatabaseService {
  CustomerDatabaseService() : super(DatabaseConnectionManager.getCustomerConnection());
  
  // Customer特定方法
  Future<List<Map<String, dynamic>>> getCustomerOrders(String customerId) async {
    return query('orders', filters: {'customer_id': customerId});
  }
  
  Future<List<Map<String, dynamic>>> getCustomerAddresses(String customerId) async {
    return query('users_addresses', filters: {'user_id': customerId});
  }
}
```

## 🚀 实施计划

### 1. 第一阶段：基础架构 (1-2周)
- 创建所有表结构
- 配置权限管理
- 建立索引
- 实现触发器

### 2. 第二阶段：数据访问层 (2-3周)
- 实现统一数据库连接管理
- 开发统一数据访问服务
- 实现Provider和Customer特定服务
- 编写单元测试

### 3. 第三阶段：应用集成 (2-3周)
- 集成Provider端应用
- 集成Customer端应用
- 实现跨表查询
- 性能测试和优化

### 4. 第四阶段：监控和优化 (1-2周)
- 部署监控系统
- 性能调优
- 安全加固
- 文档完善

## ✅ 总结

### 统一Public Schema的优势

#### **1. 简化管理**
- **单一Schema**: 所有表在public schema中，管理简单
- **统一权限**: 权限管理集中在public schema
- **简化备份**: 单一schema的备份和恢复

#### **2. 开发便利**
- **统一访问**: 所有表使用相同的访问方式
- **简化查询**: 不需要指定schema前缀
- **减少复杂性**: 降低开发和维护复杂度

#### **3. 性能优化**
- **统一索引**: 所有索引在同一个schema中
- **查询优化**: 简化查询优化策略
- **连接优化**: 减少跨schema连接开销

#### **4. 安全控制**
- **行级安全**: 通过RLS实现数据隔离
- **权限管理**: 基于角色的权限控制
- **审计便利**: 统一的审计和监控

### 关键特性
- **表名前缀**: 通过前缀区分不同模块
- 🔒 **权限隔离**: 通过RLS实现数据安全
- 📊 **统一索引**: 针对性的索引优化
- 🔄 **自动同步**: 通过触发器实现数据同步
- 🛠 **统一访问**: 简化的数据访问层

这个统一public schema的方案为JinBean项目提供了简洁、高效、安全的数据库架构！ 🎉

---

**最后更新**: 2024年12月
**维护者**: 数据库架构团队 