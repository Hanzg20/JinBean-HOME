-- Provider端数据库Schema分离脚本
-- 将Provider相关表移动到专用Schema，实现逻辑分离

-- ========================================
-- 1. 创建Provider专用Schema
-- ========================================
CREATE SCHEMA IF NOT EXISTS provider;

-- ========================================
-- 2. 创建Provider专用角色和权限
-- ========================================
-- 创建Provider专用角色
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'provider_role') THEN
        CREATE ROLE provider_role;
    END IF;
END
$$;

-- 授予Schema权限
GRANT USAGE ON SCHEMA provider TO provider_role;
GRANT CREATE ON SCHEMA provider TO provider_role;

-- ========================================
-- 3. 移动Provider相关表到专用Schema
-- ========================================

-- 移动provider_profiles表
ALTER TABLE public.provider_profiles SET SCHEMA provider;

-- 移动services表
ALTER TABLE public.services SET SCHEMA provider;

-- 移动service_details表
ALTER TABLE public.service_details SET SCHEMA provider;

-- 移动orders表（Provider相关订单）
ALTER TABLE public.orders SET SCHEMA provider;

-- 移动order_items表
ALTER TABLE public.order_items SET SCHEMA provider;

-- 移动provider_schedules表（如果存在）
-- ALTER TABLE public.provider_schedules SET SCHEMA provider;

-- ========================================
-- 4. 更新外键约束
-- ========================================

-- 更新provider_profiles表的外键
ALTER TABLE provider.provider_profiles 
    DROP CONSTRAINT IF EXISTS provider_profiles_user_id_fkey,
    ADD CONSTRAINT provider_profiles_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id);

-- 更新services表的外键
ALTER TABLE provider.services 
    DROP CONSTRAINT IF EXISTS services_provider_id_fkey,
    ADD CONSTRAINT services_provider_id_fkey 
    FOREIGN KEY (provider_id) REFERENCES provider.provider_profiles(id);

-- 更新service_details表的外键
ALTER TABLE provider.service_details 
    DROP CONSTRAINT IF EXISTS service_details_service_id_fkey,
    ADD CONSTRAINT service_details_service_id_fkey 
    FOREIGN KEY (service_id) REFERENCES provider.services(id);

-- 更新orders表的外键
ALTER TABLE provider.orders 
    DROP CONSTRAINT IF EXISTS orders_provider_id_fkey,
    ADD CONSTRAINT orders_provider_id_fkey 
    FOREIGN KEY (provider_id) REFERENCES provider.provider_profiles(id);

ALTER TABLE provider.orders 
    DROP CONSTRAINT IF EXISTS orders_service_id_fkey,
    ADD CONSTRAINT orders_service_id_fkey 
    FOREIGN KEY (service_id) REFERENCES provider.services(id);

-- 更新order_items表的外键
ALTER TABLE provider.order_items 
    DROP CONSTRAINT IF EXISTS order_items_order_id_fkey,
    ADD CONSTRAINT order_items_order_id_fkey 
    FOREIGN KEY (order_id) REFERENCES provider.orders(id);

ALTER TABLE provider.order_items 
    DROP CONSTRAINT IF EXISTS order_items_service_id_fkey,
    ADD CONSTRAINT order_items_service_id_fkey 
    FOREIGN KEY (service_id) REFERENCES provider.services(id);

-- ========================================
-- 5. 创建Provider专用视图
-- ========================================

-- Provider仪表板视图
CREATE OR REPLACE VIEW provider.dashboard_view AS
SELECT 
    pp.id,
    pp.display_name,
    pp.certification_status,
    pp.is_active,
    pp.rating,
    pp.review_count,
    COUNT(DISTINCT s.id) as service_count,
    COUNT(DISTINCT o.id) as order_count,
    COUNT(DISTINCT CASE WHEN o.order_status = 'PendingAcceptance' THEN o.id END) as pending_orders,
    COUNT(DISTINCT CASE WHEN o.order_status = 'InProgress' THEN o.id END) as active_orders,
    SUM(CASE WHEN o.payment_status = 'Paid' THEN o.total_price ELSE 0 END) as total_earnings
FROM provider.provider_profiles pp
LEFT JOIN provider.services s ON pp.id = s.provider_id
LEFT JOIN provider.orders o ON pp.id = o.provider_id
WHERE pp.user_id = auth.uid()
GROUP BY pp.id, pp.display_name, pp.certification_status, pp.is_active, pp.rating, pp.review_count;

-- Provider服务列表视图
CREATE OR REPLACE VIEW provider.my_services_view AS
SELECT 
    s.id,
    s.title,
    s.description,
    s.status,
    s.average_rating,
    s.review_count,
    sd.price,
    sd.pricing_type,
    s.created_at,
    s.updated_at
FROM provider.services s
LEFT JOIN provider.service_details sd ON s.id = sd.service_id
WHERE s.provider_id IN (
    SELECT id FROM provider.provider_profiles WHERE user_id = auth.uid()
);

-- Provider订单列表视图
CREATE OR REPLACE VIEW provider.my_orders_view AS
SELECT 
    o.id,
    o.order_number,
    o.order_status,
    o.payment_status,
    o.total_price,
    o.scheduled_start_time,
    o.scheduled_end_time,
    o.created_at,
    s.title as service_title,
    u.email as customer_email
FROM provider.orders o
LEFT JOIN provider.services s ON o.service_id = s.id
LEFT JOIN auth.users u ON o.user_id = u.id
WHERE o.provider_id IN (
    SELECT id FROM provider.provider_profiles WHERE user_id = auth.uid()
);

-- ========================================
-- 6. 设置行级安全策略(RLS)
-- ========================================

-- 启用RLS
ALTER TABLE provider.provider_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE provider.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE provider.service_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE provider.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE provider.order_items ENABLE ROW LEVEL SECURITY;

-- Provider_profiles表策略
DROP POLICY IF EXISTS "Providers can manage their own profile" ON provider.provider_profiles;
CREATE POLICY "Providers can manage their own profile"
    ON provider.provider_profiles
    FOR ALL
    USING (user_id = auth.uid());

-- Services表策略
DROP POLICY IF EXISTS "Providers can manage their own services" ON provider.services;
CREATE POLICY "Providers can manage their own services"
    ON provider.services
    FOR ALL
    USING (provider_id IN (
        SELECT id FROM provider.provider_profiles WHERE user_id = auth.uid()
    ));

-- Service_details表策略
DROP POLICY IF EXISTS "Providers can manage their own service details" ON provider.service_details;
CREATE POLICY "Providers can manage their own service details"
    ON provider.service_details
    FOR ALL
    USING (service_id IN (
        SELECT s.id FROM provider.services s
        JOIN provider.provider_profiles pp ON s.provider_id = pp.id
        WHERE pp.user_id = auth.uid()
    ));

-- Orders表策略
DROP POLICY IF EXISTS "Providers can view their own orders" ON provider.orders;
CREATE POLICY "Providers can view their own orders"
    ON provider.orders
    FOR SELECT
    USING (provider_id IN (
        SELECT id FROM provider.provider_profiles WHERE user_id = auth.uid()
    ));

DROP POLICY IF EXISTS "Providers can update their own orders" ON provider.orders;
CREATE POLICY "Providers can update their own orders"
    ON provider.orders
    FOR UPDATE
    USING (provider_id IN (
        SELECT id FROM provider.provider_profiles WHERE user_id = auth.uid()
    ));

-- Order_items表策略
DROP POLICY IF EXISTS "Providers can view their own order items" ON provider.order_items;
CREATE POLICY "Providers can view their own order items"
    ON provider.order_items
    FOR SELECT
    USING (order_id IN (
        SELECT o.id FROM provider.orders o
        JOIN provider.provider_profiles pp ON o.provider_id = pp.id
        WHERE pp.user_id = auth.uid()
    ));

-- ========================================
-- 7. 创建Provider专用函数
-- ========================================

-- 获取Provider仪表板数据
CREATE OR REPLACE FUNCTION provider.get_dashboard_data()
RETURNS TABLE (
    profile_id uuid,
    display_name text,
    certification_status text,
    is_active boolean,
    rating numeric,
    review_count integer,
    service_count bigint,
    order_count bigint,
    pending_orders bigint,
    active_orders bigint,
    total_earnings numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM provider.dashboard_view;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 获取Provider服务列表
CREATE OR REPLACE FUNCTION provider.get_my_services()
RETURNS TABLE (
    service_id uuid,
    title jsonb,
    description jsonb,
    status text,
    average_rating numeric,
    review_count integer,
    price numeric,
    pricing_type text,
    created_at timestamptz,
    updated_at timestamptz
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM provider.my_services_view;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 获取Provider订单列表
CREATE OR REPLACE FUNCTION provider.get_my_orders()
RETURNS TABLE (
    order_id uuid,
    order_number text,
    order_status text,
    payment_status text,
    total_price numeric,
    scheduled_start_time timestamptz,
    scheduled_end_time timestamptz,
    created_at timestamptz,
    service_title jsonb,
    customer_email text
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM provider.my_orders_view;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- 8. 授予权限
-- ========================================

-- 授予Provider角色对Schema的权限
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA provider TO provider_role;
GRANT SELECT ON ALL VIEWS IN SCHEMA provider TO provider_role;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA provider TO provider_role;

-- 设置默认权限
ALTER DEFAULT PRIVILEGES IN SCHEMA provider 
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO provider_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA provider 
    GRANT SELECT ON VIEWS TO provider_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA provider 
    GRANT EXECUTE ON FUNCTIONS TO provider_role;

-- ========================================
-- 9. 创建索引优化
-- ========================================

-- Provider专用索引
CREATE INDEX IF NOT EXISTS idx_provider_profiles_user_id ON provider.provider_profiles (user_id);
CREATE INDEX IF NOT EXISTS idx_provider_profiles_certification_status ON provider.provider_profiles (certification_status);
CREATE INDEX IF NOT EXISTS idx_provider_profiles_is_active ON provider.provider_profiles (is_active);

CREATE INDEX IF NOT EXISTS idx_services_provider_id ON provider.services (provider_id);
CREATE INDEX IF NOT EXISTS idx_services_status ON provider.services (status);
CREATE INDEX IF NOT EXISTS idx_services_category ON provider.services (category_level1_id, category_level2_id);

CREATE INDEX IF NOT EXISTS idx_orders_provider_id ON provider.orders (provider_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON provider.orders (order_status);
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON provider.orders (payment_status);
CREATE INDEX IF NOT EXISTS idx_orders_scheduled_time ON provider.orders (scheduled_start_time);

-- ========================================
-- 10. 验证脚本
-- ========================================

-- 验证Schema创建
SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'provider';

-- 验证表移动
SELECT table_name FROM information_schema.tables WHERE table_schema = 'provider';

-- 验证视图创建
SELECT table_name FROM information_schema.views WHERE table_schema = 'provider';

-- 验证函数创建
SELECT routine_name FROM information_schema.routines WHERE routine_schema = 'provider';

-- 验证权限设置
SELECT grantee, privilege_type, table_name 
FROM information_schema.role_table_grants 
WHERE table_schema = 'provider' AND grantee = 'provider_role'; 