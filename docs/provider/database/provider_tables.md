# Provider端数据库表设计

> 本文档详细描述了Provider端相关的数据库表设计，包括表结构、字段定义、索引设计和约束关系。

## 📊 数据库概览

### 1. 设计原则
- **规范化设计**: 遵循数据库规范化原则
- **性能优化**: 合理设计索引和查询优化
- **安全性**: 实施行级安全策略
- **可扩展性**: 支持未来功能扩展

### 2. 命名规范
- **表名**: 使用下划线分隔的小写字母
- **字段名**: 使用下划线分隔的小写字母
- **索引名**: 使用 `idx_表名_字段名` 格式
- **约束名**: 使用 `fk_表名_字段名` 格式

## 🗂 核心表设计

### 1. Provider配置文件表

#### 表结构
```sql
CREATE TABLE public.provider_profiles (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    business_name text NOT NULL,
    business_description text,
    business_address text,
    business_phone text,
    business_email text,
    business_website text,
    service_categories text[], -- 服务分类数组
    service_areas text[], -- 服务区域数组
    working_hours jsonb, -- 工作时间JSON
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

#### 字段说明
| 字段名 | 类型 | 说明 | 约束 |
|--------|------|------|------|
| id | uuid | 主键ID | PRIMARY KEY |
| user_id | uuid | 用户ID | NOT NULL, UNIQUE |
| business_name | text | 商家名称 | NOT NULL |
| business_description | text | 商家描述 | NULL |
| business_address | text | 商家地址 | NULL |
| business_phone | text | 商家电话 | NULL |
| business_email | text | 商家邮箱 | NULL |
| business_website | text | 商家网站 | NULL |
| service_categories | text[] | 服务分类 | NULL |
| service_areas | text[] | 服务区域 | NULL |
| working_hours | jsonb | 工作时间 | NULL |
| average_rating | numeric | 平均评分 | DEFAULT 0 |
| total_reviews | integer | 总评价数 | DEFAULT 0 |
| total_orders | integer | 总订单数 | DEFAULT 0 |
| total_income | numeric | 总收入 | DEFAULT 0 |
| verification_status | text | 认证状态 | DEFAULT 'pending' |
| is_active | boolean | 是否活跃 | DEFAULT true |
| created_at | timestamptz | 创建时间 | NOT NULL |
| updated_at | timestamptz | 更新时间 | NOT NULL |

#### 索引设计
```sql
-- 用户ID索引
CREATE INDEX idx_provider_profiles_user_id ON public.provider_profiles(user_id);

-- 认证状态索引
CREATE INDEX idx_provider_profiles_verification_status ON public.provider_profiles(verification_status);

-- 活跃状态索引
CREATE INDEX idx_provider_profiles_is_active ON public.provider_profiles(is_active);

-- 评分索引
CREATE INDEX idx_provider_profiles_average_rating ON public.provider_profiles(average_rating);

-- 服务分类索引
CREATE INDEX idx_provider_profiles_service_categories ON public.provider_profiles USING GIN(service_categories);
```

### 2. 简化客户关系表

#### 表结构
```sql
CREATE TABLE public.simple_client_relationships (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    client_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
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

#### 字段说明
| 字段名 | 类型 | 说明 | 约束 |
|--------|------|------|------|
| id | uuid | 主键ID | PRIMARY KEY |
| provider_id | uuid | Provider ID | NOT NULL, FK |
| client_user_id | uuid | 客户用户ID | NOT NULL, FK |
| display_name | text | 显示名称 | NOT NULL |
| phone | text | 手机号 | NULL |
| email | text | 邮箱 | NULL |
| status | text | 客户状态 | NOT NULL, DEFAULT 'active' |
| total_orders | integer | 总订单数 | NOT NULL, DEFAULT 0 |
| total_spent | numeric | 总消费金额 | NOT NULL, DEFAULT 0 |
| average_rating | numeric | 平均评分 | DEFAULT 0 |
| first_order_date | timestamptz | 首次订单日期 | NULL |
| last_order_date | timestamptz | 最后订单日期 | NULL |
| last_contact_date | timestamptz | 最后联系日期 | NULL |
| notes | text | 备注 | NULL |
| created_at | timestamptz | 创建时间 | NOT NULL |
| updated_at | timestamptz | 更新时间 | NOT NULL |

#### 索引设计
```sql
-- Provider ID索引
CREATE INDEX idx_simple_client_relationships_provider_id ON public.simple_client_relationships(provider_id);

-- 客户用户ID索引
CREATE INDEX idx_simple_client_relationships_client_user_id ON public.simple_client_relationships(client_user_id);

-- 状态索引
CREATE INDEX idx_simple_client_relationships_status ON public.simple_client_relationships(status);

-- 最后订单日期索引
CREATE INDEX idx_simple_client_relationships_last_order_date ON public.simple_client_relationships(last_order_date);

-- 最后联系日期索引
CREATE INDEX idx_simple_client_relationships_last_contact_date ON public.simple_client_relationships(last_contact_date);

-- 复合索引：Provider + 状态
CREATE INDEX idx_simple_client_relationships_provider_status ON public.simple_client_relationships(provider_id, status);

-- 复合索引：Provider + 最后订单日期
CREATE INDEX idx_simple_client_relationships_provider_last_order ON public.simple_client_relationships(provider_id, last_order_date);
```

### 3. 客户沟通记录表

#### 表结构
```sql
CREATE TABLE public.simple_client_communications (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    client_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    message text NOT NULL,
    direction text NOT NULL DEFAULT 'outbound', -- 'inbound', 'outbound'
    message_type text DEFAULT 'text', -- 'text', 'image', 'file'
    is_read boolean DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now()
);
```

#### 字段说明
| 字段名 | 类型 | 说明 | 约束 |
|--------|------|------|------|
| id | uuid | 主键ID | PRIMARY KEY |
| provider_id | uuid | Provider ID | NOT NULL, FK |
| client_user_id | uuid | 客户用户ID | NOT NULL, FK |
| message | text | 消息内容 | NOT NULL |
| direction | text | 消息方向 | NOT NULL, DEFAULT 'outbound' |
| message_type | text | 消息类型 | DEFAULT 'text' |
| is_read | boolean | 是否已读 | DEFAULT false |
| created_at | timestamptz | 创建时间 | NOT NULL |

#### 索引设计
```sql
-- Provider + 客户复合索引
CREATE INDEX idx_simple_client_communications_provider_client ON public.simple_client_communications(provider_id, client_user_id);

-- 创建时间索引
CREATE INDEX idx_simple_client_communications_created_at ON public.simple_client_communications(created_at);

-- 方向索引
CREATE INDEX idx_simple_client_communications_direction ON public.simple_client_communications(direction);

-- 已读状态索引
CREATE INDEX idx_simple_client_communications_is_read ON public.simple_client_communications(is_read);

-- 复合索引：Provider + 客户 + 创建时间
CREATE INDEX idx_simple_client_communications_provider_client_time ON public.simple_client_communications(provider_id, client_user_id, created_at);
```

### 4. Provider服务表

#### 表结构
```sql
CREATE TABLE public.provider_services (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    service_name text NOT NULL,
    service_description text,
    service_category text NOT NULL,
    price numeric NOT NULL,
    price_type text NOT NULL DEFAULT 'fixed', -- 'fixed', 'hourly', 'negotiable'
    duration_minutes integer, -- 服务时长（分钟）
    is_available boolean DEFAULT true,
    max_bookings_per_day integer, -- 每日最大预约数
    cancellation_policy text, -- 取消政策
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);
```

#### 字段说明
| 字段名 | 类型 | 说明 | 约束 |
|--------|------|------|------|
| id | uuid | 主键ID | PRIMARY KEY |
| provider_id | uuid | Provider ID | NOT NULL, FK |
| service_name | text | 服务名称 | NOT NULL |
| service_description | text | 服务描述 | NULL |
| service_category | text | 服务分类 | NOT NULL |
| price | numeric | 价格 | NOT NULL |
| price_type | text | 价格类型 | NOT NULL, DEFAULT 'fixed' |
| duration_minutes | integer | 服务时长 | NULL |
| is_available | boolean | 是否可用 | DEFAULT true |
| max_bookings_per_day | integer | 每日最大预约数 | NULL |
| cancellation_policy | text | 取消政策 | NULL |
| created_at | timestamptz | 创建时间 | NOT NULL |
| updated_at | timestamptz | 更新时间 | NOT NULL |

#### 索引设计
```sql
-- Provider ID索引
CREATE INDEX idx_provider_services_provider_id ON public.provider_services(provider_id);

-- 服务分类索引
CREATE INDEX idx_provider_services_category ON public.provider_services(service_category);

-- 可用性索引
CREATE INDEX idx_provider_services_is_available ON public.provider_services(is_available);

-- 价格索引
CREATE INDEX idx_provider_services_price ON public.provider_services(price);

-- 复合索引：Provider + 可用性
CREATE INDEX idx_provider_services_provider_available ON public.provider_services(provider_id, is_available);

-- 复合索引：Provider + 分类
CREATE INDEX idx_provider_services_provider_category ON public.provider_services(provider_id, service_category);
```

### 5. Provider收入记录表

#### 表结构
```sql
CREATE TABLE public.provider_income_records (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    order_id uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    amount numeric NOT NULL,
    commission_rate numeric DEFAULT 0.1, -- 平台佣金率
    commission_amount numeric NOT NULL, -- 平台佣金金额
    net_amount numeric NOT NULL, -- 净收入
    payment_status text NOT NULL DEFAULT 'pending', -- 'pending', 'paid', 'cancelled'
    payment_method text, -- 支付方式
    payment_date timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);
```

#### 字段说明
| 字段名 | 类型 | 说明 | 约束 |
|--------|------|------|------|
| id | uuid | 主键ID | PRIMARY KEY |
| provider_id | uuid | Provider ID | NOT NULL, FK |
| order_id | uuid | 订单ID | NOT NULL, FK |
| amount | numeric | 订单金额 | NOT NULL |
| commission_rate | numeric | 佣金率 | DEFAULT 0.1 |
| commission_amount | numeric | 佣金金额 | NOT NULL |
| net_amount | numeric | 净收入 | NOT NULL |
| payment_status | text | 支付状态 | NOT NULL, DEFAULT 'pending' |
| payment_method | text | 支付方式 | NULL |
| payment_date | timestamptz | 支付日期 | NULL |
| created_at | timestamptz | 创建时间 | NOT NULL |
| updated_at | timestamptz | 更新时间 | NOT NULL |

#### 索引设计
```sql
-- Provider ID索引
CREATE INDEX idx_provider_income_records_provider_id ON public.provider_income_records(provider_id);

-- 订单ID索引
CREATE INDEX idx_provider_income_records_order_id ON public.provider_income_records(order_id);

-- 支付状态索引
CREATE INDEX idx_provider_income_records_payment_status ON public.provider_income_records(payment_status);

-- 支付日期索引
CREATE INDEX idx_provider_income_records_payment_date ON public.provider_income_records(payment_date);

-- 创建时间索引
CREATE INDEX idx_provider_income_records_created_at ON public.provider_income_records(created_at);

-- 复合索引：Provider + 支付状态
CREATE INDEX idx_provider_income_records_provider_status ON public.provider_income_records(provider_id, payment_status);

-- 复合索引：Provider + 创建时间
CREATE INDEX idx_provider_income_records_provider_created ON public.provider_income_records(provider_id, created_at);
```

## 🔒 安全策略

### 1. 行级安全策略 (RLS)

#### Provider配置文件表
```sql
ALTER TABLE public.provider_profiles ENABLE ROW LEVEL SECURITY;

-- Provider只能查看自己的配置文件
CREATE POLICY "Providers can view own profile" ON public.provider_profiles
    FOR SELECT USING (user_id = auth.uid());

-- Provider只能更新自己的配置文件
CREATE POLICY "Providers can update own profile" ON public.provider_profiles
    FOR UPDATE USING (user_id = auth.uid());

-- Provider只能插入自己的配置文件
CREATE POLICY "Providers can insert own profile" ON public.provider_profiles
    FOR INSERT WITH CHECK (user_id = auth.uid());
```

#### 客户关系表
```sql
ALTER TABLE public.simple_client_relationships ENABLE ROW LEVEL SECURITY;

-- Provider只能查看自己的客户关系
CREATE POLICY "Providers can view own client relationships" ON public.simple_client_relationships
    FOR SELECT USING (provider_id = auth.uid());

-- Provider只能更新自己的客户关系
CREATE POLICY "Providers can update own client relationships" ON public.simple_client_relationships
    FOR UPDATE USING (provider_id = auth.uid());

-- Provider只能插入自己的客户关系
CREATE POLICY "Providers can insert own client relationships" ON public.simple_client_relationships
    FOR INSERT WITH CHECK (provider_id = auth.uid());
```

#### 客户沟通记录表
```sql
ALTER TABLE public.simple_client_communications ENABLE ROW LEVEL SECURITY;

-- Provider只能查看自己的客户沟通记录
CREATE POLICY "Providers can view own client communications" ON public.simple_client_communications
    FOR SELECT USING (provider_id = auth.uid());

-- Provider只能插入自己的客户沟通记录
CREATE POLICY "Providers can insert own client communications" ON public.simple_client_communications
    FOR INSERT WITH CHECK (provider_id = auth.uid());
```

#### Provider服务表
```sql
ALTER TABLE public.provider_services ENABLE ROW LEVEL SECURITY;

-- Provider只能查看自己的服务
CREATE POLICY "Providers can view own services" ON public.provider_services
    FOR SELECT USING (provider_id = auth.uid());

-- Provider只能更新自己的服务
CREATE POLICY "Providers can update own services" ON public.provider_services
    FOR UPDATE USING (provider_id = auth.uid());

-- Provider只能插入自己的服务
CREATE POLICY "Providers can insert own services" ON public.provider_services
    FOR INSERT WITH CHECK (provider_id = auth.uid());

-- Provider只能删除自己的服务
CREATE POLICY "Providers can delete own services" ON public.provider_services
    FOR DELETE USING (provider_id = auth.uid());
```

#### Provider收入记录表
```sql
ALTER TABLE public.provider_income_records ENABLE ROW LEVEL SECURITY;

-- Provider只能查看自己的收入记录
CREATE POLICY "Providers can view own income records" ON public.provider_income_records
    FOR SELECT USING (provider_id = auth.uid());
```

### 2. 数据验证约束

#### 检查约束
```sql
-- Provider配置文件表约束
ALTER TABLE public.provider_profiles 
ADD CONSTRAINT check_verification_status 
CHECK (verification_status IN ('pending', 'verified', 'rejected'));

ALTER TABLE public.provider_profiles 
ADD CONSTRAINT check_average_rating 
CHECK (average_rating >= 0 AND average_rating <= 5);

-- 客户关系表约束
ALTER TABLE public.simple_client_relationships 
ADD CONSTRAINT check_client_status 
CHECK (status IN ('active', 'inactive'));

ALTER TABLE public.simple_client_relationships 
ADD CONSTRAINT check_total_orders 
CHECK (total_orders >= 0);

ALTER TABLE public.simple_client_relationships 
ADD CONSTRAINT check_total_spent 
CHECK (total_spent >= 0);

-- 客户沟通记录表约束
ALTER TABLE public.simple_client_communications 
ADD CONSTRAINT check_direction 
CHECK (direction IN ('inbound', 'outbound'));

ALTER TABLE public.simple_client_communications 
ADD CONSTRAINT check_message_type 
CHECK (message_type IN ('text', 'image', 'file'));

-- Provider服务表约束
ALTER TABLE public.provider_services 
ADD CONSTRAINT check_price_type 
CHECK (price_type IN ('fixed', 'hourly', 'negotiable'));

ALTER TABLE public.provider_services 
ADD CONSTRAINT check_price 
CHECK (price >= 0);

ALTER TABLE public.provider_services 
ADD CONSTRAINT check_duration 
CHECK (duration_minutes > 0);

-- Provider收入记录表约束
ALTER TABLE public.provider_income_records 
ADD CONSTRAINT check_payment_status 
CHECK (payment_status IN ('pending', 'paid', 'cancelled'));

ALTER TABLE public.provider_income_records 
ADD CONSTRAINT check_amount 
CHECK (amount >= 0);

ALTER TABLE public.provider_income_records 
ADD CONSTRAINT check_commission_rate 
CHECK (commission_rate >= 0 AND commission_rate <= 1);
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

-- 为相关表添加更新时间触发器
CREATE TRIGGER set_provider_profiles_updated_at
    BEFORE UPDATE ON public.provider_profiles
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER set_simple_client_relationships_updated_at
    BEFORE UPDATE ON public.simple_client_relationships
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER set_provider_services_updated_at
    BEFORE UPDATE ON public.provider_services
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER set_provider_income_records_updated_at
    BEFORE UPDATE ON public.provider_income_records
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();
```

### 2. 统计更新触发器
```sql
-- 更新Provider统计信息
CREATE OR REPLACE FUNCTION update_provider_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- 更新Provider的总订单数和总收入
    UPDATE public.provider_profiles 
    SET 
        total_orders = (
            SELECT COUNT(*) 
            FROM public.orders 
            WHERE provider_id = NEW.provider_id 
            AND status = 'completed'
        ),
        total_income = (
            SELECT COALESCE(SUM(net_amount), 0)
            FROM public.provider_income_records 
            WHERE provider_id = NEW.provider_id 
            AND payment_status = 'paid'
        )
    WHERE id = NEW.provider_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为收入记录表添加统计更新触发器
CREATE TRIGGER update_provider_stats_on_income
    AFTER INSERT OR UPDATE ON public.provider_income_records
    FOR EACH ROW
    EXECUTE FUNCTION update_provider_stats();
```

## 📊 视图设计

### 1. Provider统计视图
```sql
CREATE VIEW provider_statistics AS
SELECT 
    pp.id as provider_id,
    pp.business_name,
    pp.average_rating,
    pp.total_reviews,
    pp.total_orders,
    pp.total_income,
    COUNT(DISTINCT scr.client_user_id) as total_clients,
    COUNT(DISTINCT CASE WHEN scr.status = 'active' THEN scr.client_user_id END) as active_clients,
    AVG(scr.average_rating) as client_avg_rating,
    MAX(scr.last_order_date) as last_client_order
FROM public.provider_profiles pp
LEFT JOIN public.simple_client_relationships scr ON pp.id = scr.provider_id
GROUP BY pp.id, pp.business_name, pp.average_rating, pp.total_reviews, pp.total_orders, pp.total_income;
```

### 2. 客户统计视图
```sql
CREATE VIEW client_statistics AS
SELECT 
    scr.provider_id,
    scr.client_user_id,
    scr.display_name,
    scr.status,
    scr.total_orders,
    scr.total_spent,
    scr.average_rating,
    scr.first_order_date,
    scr.last_order_date,
    scr.last_contact_date,
    COUNT(scc.id) as total_communications,
    COUNT(CASE WHEN scc.direction = 'outbound' THEN 1 END) as outbound_messages,
    COUNT(CASE WHEN scc.direction = 'inbound' THEN 1 END) as inbound_messages,
    MAX(scc.created_at) as last_communication
FROM public.simple_client_relationships scr
LEFT JOIN public.simple_client_communications scc 
    ON scr.provider_id = scc.provider_id 
    AND scr.client_user_id = scc.client_user_id
GROUP BY scr.provider_id, scr.client_user_id, scr.display_name, scr.status, 
         scr.total_orders, scr.total_spent, scr.average_rating, 
         scr.first_order_date, scr.last_order_date, scr.last_contact_date;
```

## 🚀 性能优化建议

### 1. 查询优化
- 使用适当的索引
- 避免全表扫描
- 使用分页查询
- 优化JOIN操作

### 2. 数据维护
- 定期清理过期数据
- 更新统计信息
- 重建索引
- 分析表统计信息

### 3. 监控指标
- 查询响应时间
- 索引使用率
- 表大小增长
- 连接数使用情况

---

**最后更新**: 2024年12月
**维护者**: Provider端开发团队 