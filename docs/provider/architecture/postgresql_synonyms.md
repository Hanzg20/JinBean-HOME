# PostgreSQL同义词替代方案

> 本文档描述了在PostgreSQL中实现类似Oracle同义词功能的多种方案，包括视图、函数、Schema别名等。

## 🎯 Oracle同义词 vs PostgreSQL

### Oracle同义词功能
```sql
-- Oracle同义词示例
CREATE SYNONYM emp FOR hr.employees;
CREATE SYNONYM dept FOR hr.departments;

-- 使用同义词
SELECT * FROM emp WHERE department_id = 10;
SELECT * FROM dept WHERE location_id = 1700;
```

### PostgreSQL替代方案
PostgreSQL没有直接的`CREATE SYNONYM`语法，但提供了多种替代方案：

## 📋 替代方案对比

| 方案 | 优点 | 缺点 | 适用场景 |
|------|------|------|----------|
| **视图 (Views)** | 简单易用，支持复杂逻辑 | 性能开销，不支持DML | 只读查询 |
| **函数 (Functions)** | 灵活，支持参数化 | 语法复杂，需要调用 | 复杂查询逻辑 |
| **Schema别名** | 性能好，语法简单 | 需要修改连接配置 | 跨Schema访问 |
| **触发器** | 自动同步，透明 | 复杂，维护困难 | 数据同步 |
| **外部表** | 跨数据库访问 | 配置复杂 | 分布式查询 |

## 🏗 具体实现方案

### 1. 视图 (Views) - 推荐方案

#### 基础视图
```sql
-- 创建Provider端视图
CREATE VIEW provider_orders AS
SELECT 
    o.id,
    o.customer_id,
    o.provider_id,
    o.service_id,
    o.status,
    o.amount,
    o.scheduled_date,
    o.actual_start_date,
    o.actual_end_date,
    o.notes,
    o.created_at,
    o.updated_at,
    c.display_name as customer_name,
    c.phone as customer_phone,
    c.email as customer_email,
    p.business_name as provider_name,
    p.business_phone as provider_phone,
    s.service_name,
    s.service_category
FROM shared.orders o
LEFT JOIN public.users c ON o.customer_id = c.id
LEFT JOIN provider.provider_profiles p ON o.provider_id = p.user_id
LEFT JOIN shared.services s ON o.service_id = s.id
WHERE o.provider_id = current_setting('app.current_user_id')::uuid;

-- 创建Customer端视图
CREATE VIEW customer_orders AS
SELECT 
    o.id,
    o.customer_id,
    o.provider_id,
    o.service_id,
    o.status,
    o.amount,
    o.scheduled_date,
    o.actual_start_date,
    o.actual_end_date,
    o.notes,
    o.created_at,
    o.updated_at,
    p.business_name as provider_name,
    p.business_phone as provider_phone,
    p.business_address as provider_address,
    s.service_name,
    s.service_category,
    s.price,
    s.duration_minutes
FROM shared.orders o
LEFT JOIN provider.provider_profiles p ON o.provider_id = p.user_id
LEFT JOIN shared.services s ON o.service_id = s.id
WHERE o.customer_id = current_setting('app.current_user_id')::uuid;
```

#### 可更新视图
```sql
-- 创建可更新的Provider订单视图
CREATE VIEW provider_orders_updatable AS
SELECT 
    o.id,
    o.customer_id,
    o.provider_id,
    o.service_id,
    o.status,
    o.amount,
    o.scheduled_date,
    o.actual_start_date,
    o.actual_end_date,
    o.notes,
    o.created_at,
    o.updated_at
FROM shared.orders o
WHERE o.provider_id = current_setting('app.current_user_id')::uuid;

-- 创建更新触发器
CREATE OR REPLACE FUNCTION update_provider_orders_view()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        UPDATE shared.orders 
        SET 
            status = NEW.status,
            actual_start_date = NEW.actual_start_date,
            actual_end_date = NEW.actual_end_date,
            notes = NEW.notes,
            updated_at = now()
        WHERE id = NEW.id;
        RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO shared.orders (
            customer_id, provider_id, service_id, status, 
            amount, scheduled_date, notes, created_at, updated_at
        ) VALUES (
            NEW.customer_id, NEW.provider_id, NEW.service_id, NEW.status,
            NEW.amount, NEW.scheduled_date, NEW.notes, now(), now()
        );
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_provider_orders_view
    INSTEAD OF INSERT OR UPDATE ON provider_orders_updatable
    FOR EACH ROW
    EXECUTE FUNCTION update_provider_orders_view();
```

#### 权限控制视图
```sql
-- 创建带权限控制的视图
CREATE VIEW provider_clients_secure AS
SELECT 
    pc.id,
    pc.provider_id,
    pc.client_user_id,
    pc.display_name,
    pc.phone,
    pc.email,
    pc.status,
    pc.total_orders,
    pc.total_spent,
    pc.average_rating,
    pc.first_order_date,
    pc.last_order_date,
    pc.last_contact_date,
    pc.notes,
    pc.created_at,
    pc.updated_at
FROM provider.provider_clients pc
WHERE pc.provider_id = current_setting('app.current_user_id')::uuid
  AND EXISTS (
    SELECT 1 FROM provider.provider_profiles pp 
    WHERE pp.user_id = current_setting('app.current_user_id')::uuid
      AND pp.id = pc.provider_id
      AND pp.is_active = true
  );
```

### 2. 函数 (Functions) - 灵活方案

#### 查询函数
```sql
-- 创建Provider订单查询函数
CREATE OR REPLACE FUNCTION get_provider_orders(
    p_status text DEFAULT NULL,
    p_start_date date DEFAULT NULL,
    p_end_date date DEFAULT NULL,
    p_limit integer DEFAULT 50,
    p_offset integer DEFAULT 0
)
RETURNS TABLE (
    id uuid,
    customer_id uuid,
    customer_name text,
    customer_phone text,
    customer_email text,
    service_name text,
    service_category text,
    status text,
    amount numeric,
    scheduled_date timestamptz,
    actual_start_date timestamptz,
    actual_end_date timestamptz,
    notes text,
    created_at timestamptz,
    updated_at timestamptz
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.id,
        o.customer_id,
        c.display_name as customer_name,
        c.phone as customer_phone,
        c.email as customer_email,
        s.service_name,
        s.service_category,
        o.status,
        o.amount,
        o.scheduled_date,
        o.actual_start_date,
        o.actual_end_date,
        o.notes,
        o.created_at,
        o.updated_at
    FROM shared.orders o
    LEFT JOIN public.users c ON o.customer_id = c.id
    LEFT JOIN shared.services s ON o.service_id = s.id
    WHERE o.provider_id = current_setting('app.current_user_id')::uuid
      AND (p_status IS NULL OR o.status = p_status)
      AND (p_start_date IS NULL OR o.scheduled_date >= p_start_date)
      AND (p_end_date IS NULL OR o.scheduled_date <= p_end_date)
    ORDER BY o.scheduled_date DESC
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 创建Customer订单查询函数
CREATE OR REPLACE FUNCTION get_customer_orders(
    p_status text DEFAULT NULL,
    p_provider_id uuid DEFAULT NULL,
    p_limit integer DEFAULT 50,
    p_offset integer DEFAULT 0
)
RETURNS TABLE (
    id uuid,
    provider_id uuid,
    provider_name text,
    provider_phone text,
    provider_address text,
    service_name text,
    service_category text,
    status text,
    amount numeric,
    scheduled_date timestamptz,
    actual_start_date timestamptz,
    actual_end_date timestamptz,
    notes text,
    created_at timestamptz,
    updated_at timestamptz
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.id,
        o.provider_id,
        p.business_name as provider_name,
        p.business_phone as provider_phone,
        p.business_address as provider_address,
        s.service_name,
        s.service_category,
        o.status,
        o.amount,
        o.scheduled_date,
        o.actual_start_date,
        o.actual_end_date,
        o.notes,
        o.created_at,
        o.updated_at
    FROM shared.orders o
    LEFT JOIN provider.provider_profiles p ON o.provider_id = p.user_id
    LEFT JOIN shared.services s ON o.service_id = s.id
    WHERE o.customer_id = current_setting('app.current_user_id')::uuid
      AND (p_status IS NULL OR o.status = p_status)
      AND (p_provider_id IS NULL OR o.provider_id = p_provider_id)
    ORDER BY o.scheduled_date DESC
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

#### 统计函数
```sql
-- 创建Provider统计函数
CREATE OR REPLACE FUNCTION get_provider_statistics(
    p_start_date date DEFAULT NULL,
    p_end_date date DEFAULT NULL
)
RETURNS TABLE (
    total_orders integer,
    completed_orders integer,
    pending_orders integer,
    total_income numeric,
    average_rating numeric,
    total_clients integer,
    active_clients integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(o.id)::integer as total_orders,
        COUNT(CASE WHEN o.status = 'completed' THEN 1 END)::integer as completed_orders,
        COUNT(CASE WHEN o.status = 'pending' THEN 1 END)::integer as pending_orders,
        COALESCE(SUM(CASE WHEN o.status = 'completed' THEN o.amount ELSE 0 END), 0) as total_income,
        COALESCE(AVG(pc.average_rating), 0) as average_rating,
        COUNT(DISTINCT pc.client_user_id)::integer as total_clients,
        COUNT(DISTINCT CASE WHEN pc.status = 'active' THEN pc.client_user_id END)::integer as active_clients
    FROM provider.provider_profiles pp
    LEFT JOIN shared.orders o ON pp.user_id = o.provider_id
    LEFT JOIN provider.provider_clients pc ON pp.id = pc.provider_id
    WHERE pp.user_id = current_setting('app.current_user_id')::uuid
      AND (p_start_date IS NULL OR o.scheduled_date >= p_start_date)
      AND (p_end_date IS NULL OR o.scheduled_date <= p_end_date);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 3. Schema别名 - 性能方案

#### 使用Schema别名
```sql
-- 创建Schema别名（通过搜索路径）
SET search_path TO provider, shared, public;

-- 或者为特定用户设置默认Schema
ALTER USER provider_app SET search_path TO provider, shared, public;
ALTER USER customer_app SET search_path TO customer, shared, public;
```

#### 在应用中配置
```dart
// 数据库连接配置
class DatabaseConfig {
  // Provider端连接配置
  static const Map<String, dynamic> providerConfig = {
    'host': 'your-supabase-host',
    'database': 'postgres',
    'username': 'provider_app',
    'password': 'provider_password',
    'options': {
      'search_path': 'provider,shared,public',
    },
  };
  
  // Customer端连接配置
  static const Map<String, dynamic> customerConfig = {
    'host': 'your-supabase-host',
    'database': 'postgres',
    'username': 'customer_app',
    'password': 'customer_password',
    'options': {
      'search_path': 'customer,shared,public',
    },
  };
}

// 数据库连接管理
class DatabaseConnectionManager {
  static SupabaseClient getProviderConnection() {
    return SupabaseClient(
      DatabaseConfig.providerConfig['host'],
      DatabaseConfig.providerConfig['password'],
      options: SupabaseClientOptions(
        db: DatabaseConfig.providerConfig['database'],
        schema: DatabaseConfig.providerConfig['options']['search_path'],
      ),
    );
  }
  
  static SupabaseClient getCustomerConnection() {
    return SupabaseClient(
      DatabaseConfig.customerConfig['host'],
      DatabaseConfig.customerConfig['password'],
      options: SupabaseClientOptions(
        db: DatabaseConfig.customerConfig['database'],
        schema: DatabaseConfig.customerConfig['options']['search_path'],
      ),
    );
  }
}
```

### 4. 触发器 - 同步方案

#### 自动同步触发器
```sql
-- 创建Provider订单同步触发器
CREATE OR REPLACE FUNCTION sync_provider_orders()
RETURNS TRIGGER AS $$
BEGIN
    -- 当shared.orders表更新时，自动更新provider相关统计
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        -- 更新Provider统计
        UPDATE provider.provider_profiles 
        SET 
            total_orders = (
                SELECT COUNT(*) 
                FROM shared.orders 
                WHERE provider_id = NEW.provider_id
            ),
            total_income = (
                SELECT COALESCE(SUM(amount), 0)
                FROM shared.orders 
                WHERE provider_id = NEW.provider_id 
                  AND status = 'completed'
            ),
            updated_at = now()
        WHERE user_id = NEW.provider_id;
        
        -- 更新客户关系
        INSERT INTO provider.provider_clients (
            provider_id, client_user_id, display_name, phone, email,
            total_orders, total_spent, last_order_date, created_at, updated_at
        ) VALUES (
            (SELECT id FROM provider.provider_profiles WHERE user_id = NEW.provider_id),
            NEW.customer_id,
            (SELECT display_name FROM public.users WHERE id = NEW.customer_id),
            (SELECT phone FROM public.users WHERE id = NEW.customer_id),
            (SELECT email FROM public.users WHERE id = NEW.customer_id),
            1,
            NEW.amount,
            NEW.scheduled_date,
            now(),
            now()
        )
        ON CONFLICT (provider_id, client_user_id) 
        DO UPDATE SET
            total_orders = provider.provider_clients.total_orders + 1,
            total_spent = provider.provider_clients.total_spent + NEW.amount,
            last_order_date = NEW.scheduled_date,
            updated_at = now();
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_sync_provider_orders
    AFTER INSERT OR UPDATE ON shared.orders
    FOR EACH ROW
    EXECUTE FUNCTION sync_provider_orders();
```

## 🔧 实际应用示例

### 1. Provider端应用使用

#### 使用视图
```dart
class ProviderOrderService {
  final SupabaseClient _client;
  
  ProviderOrderService(this._client);
  
  // 使用视图查询订单
  Future<List<Map<String, dynamic>>> getOrders({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client.from('provider_orders').select();
      
      if (status != null) {
        query = query.eq('status', status);
      }
      
      if (startDate != null) {
        query = query.gte('scheduled_date', startDate.toIso8601String());
      }
      
      if (endDate != null) {
        query = query.lte('scheduled_date', endDate.toIso8601String());
      }
      
      query = query.order('scheduled_date', ascending: false);
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 50) - 1);
      }
      
      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('获取订单失败: $e');
    }
  }
}
```

#### 使用函数
```dart
class ProviderOrderService {
  final SupabaseClient _client;
  
  ProviderOrderService(this._client);
  
  // 使用函数查询订单
  Future<List<Map<String, dynamic>>> getOrders({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _client.rpc('get_provider_orders', params: {
        'p_status': status,
        'p_start_date': startDate?.toIso8601String(),
        'p_end_date': endDate?.toIso8601String(),
        'p_limit': limit ?? 50,
        'p_offset': offset ?? 0,
      });
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('获取订单失败: $e');
    }
  }
  
  // 使用统计函数
  Future<Map<String, dynamic>> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _client.rpc('get_provider_statistics', params: {
        'p_start_date': startDate?.toIso8601String(),
        'p_end_date': endDate?.toIso8601String(),
      });
      
      return response[0] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('获取统计信息失败: $e');
    }
  }
}
```

### 2. Customer端应用使用

#### 使用视图
```dart
class CustomerOrderService {
  final SupabaseClient _client;
  
  CustomerOrderService(this._client);
  
  // 使用视图查询订单
  Future<List<Map<String, dynamic>>> getOrders({
    String? status,
    String? providerId,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client.from('customer_orders').select();
      
      if (status != null) {
        query = query.eq('status', status);
      }
      
      if (providerId != null) {
        query = query.eq('provider_id', providerId);
      }
      
      query = query.order('scheduled_date', ascending: false);
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 50) - 1);
      }
      
      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('获取订单失败: $e');
    }
  }
}
```

## 📊 性能对比

### 查询性能测试
```sql
-- 测试视图查询性能
EXPLAIN ANALYZE SELECT * FROM provider_orders WHERE status = 'pending';

-- 测试函数查询性能
EXPLAIN ANALYZE SELECT * FROM get_provider_orders('pending');

-- 测试直接查询性能
EXPLAIN ANALYZE 
SELECT o.*, c.display_name, p.business_name 
FROM shared.orders o
LEFT JOIN public.users c ON o.customer_id = c.id
LEFT JOIN provider.provider_profiles p ON o.provider_id = p.user_id
WHERE o.provider_id = 'user-uuid' AND o.status = 'pending';
```

### 性能优化建议

#### 1. 视图优化
```sql
-- 为视图创建索引
CREATE INDEX idx_provider_orders_status ON shared.orders(provider_id, status);
CREATE INDEX idx_provider_orders_date ON shared.orders(provider_id, scheduled_date);

-- 使用物化视图提高性能
CREATE MATERIALIZED VIEW provider_orders_materialized AS
SELECT * FROM provider_orders;

-- 定期刷新物化视图
REFRESH MATERIALIZED VIEW provider_orders_materialized;
```

#### 2. 函数优化
```sql
-- 使用STABLE标记提高函数性能
CREATE OR REPLACE FUNCTION get_provider_orders(...)
RETURNS TABLE (...) AS $$
BEGIN
    -- 函数实现
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;
```

## 🚀 最佳实践

### 1. 选择建议

#### 推荐使用视图的场景
- **简单查询**: 跨表关联查询
- **只读操作**: 不需要修改数据的查询
- **权限控制**: 需要行级权限控制
- **开发便利**: 快速开发和原型设计

#### 推荐使用函数的场景
- **复杂逻辑**: 需要复杂业务逻辑
- **参数化查询**: 需要动态参数
- **性能优化**: 需要优化查询性能
- **安全控制**: 需要严格的安全控制

#### 推荐使用Schema别名的场景
- **性能要求高**: 对查询性能要求极高
- **简单访问**: 简单的跨Schema访问
- **批量操作**: 大量数据的批量操作

### 2. 实施建议

#### 第一阶段：基础视图 (1周)
- 创建基础查询视图
- 实现权限控制
- 编写基础测试

#### 第二阶段：优化函数 (1-2周)
- 创建复杂查询函数
- 实现统计函数
- 性能测试和优化

#### 第三阶段：高级特性 (1周)
- 实现触发器同步
- 创建物化视图
- 监控和调优

---

**总结**: PostgreSQL虽然没有Oracle的同义词功能，但通过视图、函数、Schema别名等方案，可以实现类似甚至更强大的功能。推荐根据具体需求选择合适的方案组合使用！

---

**最后更新**: 2024年12月
**维护者**: 数据库架构团队 