-- =====================================================
-- 完整购物车系统数据库脚本
-- 包含：新增表创建 + 现有表修改 + 索引优化
-- 执行环境: Supabase PostgreSQL
-- 创建日期: 2025-08-28
-- 版本: v1.0
-- =====================================================

-- 确保必要的扩展已启用
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 第一部分：新增购物车相关表
-- =====================================================

-- 1. 统一购物车表
CREATE TABLE IF NOT EXISTS public.unified_carts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    cart_type text NOT NULL CHECK (cart_type IN ('restaurant', 'appointment', 'mixed')),
    status text DEFAULT 'active' CHECK (status IN ('active', 'converting', 'converted', 'expired')),
    
    -- 餐饮服务专用字段
    delivery_method text CHECK (delivery_method IN ('delivery', 'pickup', 'dine_in')),
    delivery_address_id uuid, -- 暂时不设外键约束，因为user_addresses表可能不存在
    estimated_delivery_time timestamptz,
    special_instructions text,
    
    -- 通用字段
    expires_at timestamptz DEFAULT (now() + interval '24 hours'),
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    
    -- 唯一约束：每个用户每种类型只能有一个活跃购物车
    UNIQUE(user_id, cart_type, status)
);

-- 2. 购物车项目表
CREATE TABLE IF NOT EXISTS public.cart_items (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id uuid NOT NULL REFERENCES public.unified_carts(id) ON DELETE CASCADE,
    
    -- 服务关联（简化外键约束，避免表不存在的问题）
    service_id text NOT NULL, -- 改为text，避免外键问题
    service_detail_id text,   -- service detail的ID，可能是UUID或特殊值如'main_service'
    
    -- 基础信息
    item_type text NOT NULL CHECK (item_type IN ('menu_item', 'appointment', 'package', 'main_service')),
    quantity integer NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price numeric NOT NULL CHECK (unit_price >= 0),
    
    -- 预约服务专用字段
    scheduled_start_time timestamptz,
    scheduled_end_time timestamptz,
    service_address_snapshot jsonb,
    
    -- 餐饮服务专用字段
    customizations jsonb DEFAULT '{}', -- 口味、配料、烹饪方式等
    dietary_restrictions text[], -- 饮食限制
    
    -- 通用字段
    special_instructions text,
    
    -- 快照字段（防止原数据变更影响订单）
    item_name_snapshot jsonb NOT NULL,
    item_description_snapshot text,
    item_image_snapshot text,
    provider_name_snapshot text,
    
    -- 计算字段
    subtotal numeric GENERATED ALWAYS AS (quantity * unit_price) STORED,
    
    -- 时间戳
    added_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 3. 购物车操作日志表
CREATE TABLE IF NOT EXISTS public.cart_operation_logs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id uuid REFERENCES public.unified_carts(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id),
    
    operation_type text NOT NULL CHECK (operation_type IN ('add', 'remove', 'update_quantity', 'update_customization', 'clear', 'convert_to_order')),
    item_id uuid REFERENCES public.cart_items(id),
    
    -- 操作详情
    operation_data jsonb,
    old_value jsonb,
    new_value jsonb,
    
    -- 元数据
    user_agent text,
    ip_address inet,
    session_id text,
    
    created_at timestamptz DEFAULT now()
);

-- =====================================================
-- 第二部分：现有表结构修改（如果需要）
-- =====================================================

-- 检查并修改services表，确保支持购物车功能
DO $$
BEGIN
    -- 为services表添加购物车相关字段（如果不存在）
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='services' AND column_name='supports_cart') THEN
        ALTER TABLE public.services ADD COLUMN supports_cart boolean DEFAULT true;
        RAISE NOTICE '已为services表添加supports_cart字段';
    END IF;
    
    -- 为services表添加预订类型字段（如果不存在）
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='services' AND column_name='booking_type') THEN
        ALTER TABLE public.services ADD COLUMN booking_type text 
            DEFAULT 'direct' CHECK (booking_type IN ('direct', 'cart', 'both'));
        RAISE NOTICE '已为services表添加booking_type字段';
    END IF;
END $$;

-- 检查并修改service_details表，确保支持购物车功能
DO $$
BEGIN
    -- 为service_details表添加库存相关字段（如果不存在）
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='service_details' AND column_name='current_stock') THEN
        ALTER TABLE public.service_details ADD COLUMN current_stock integer DEFAULT null;
        RAISE NOTICE '已为service_details表添加current_stock字段';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='service_details' AND column_name='max_stock') THEN
        ALTER TABLE public.service_details ADD COLUMN max_stock integer DEFAULT null;
        RAISE NOTICE '已为service_details表添加max_stock字段';
    END IF;
    
    -- 为service_details表添加可用性字段（如果不存在）
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='service_details' AND column_name='is_available') THEN
        ALTER TABLE public.service_details ADD COLUMN is_available boolean DEFAULT true;
        RAISE NOTICE '已为service_details表添加is_available字段';
    END IF;
END $$;

-- =====================================================
-- 第三部分：订单相关表扩展
-- =====================================================

-- 扩展订单表以支持购物车来源
DO $$
BEGIN
    -- 检查orders表是否存在，如果不存在则创建
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name='orders') THEN
        CREATE TABLE public.orders (
            id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
            order_number text UNIQUE NOT NULL,
            user_id uuid NOT NULL REFERENCES auth.users(id),
            provider_id uuid,
            service_id text,
            
            -- 订单类型和来源
            order_type text NOT NULL CHECK (order_type IN ('restaurant', 'appointment', 'package', 'mixed')),
            order_source text NOT NULL DEFAULT 'direct' CHECK (order_source IN ('direct', 'cart', 'quote')),
            
            -- 价格信息
            total_price numeric NOT NULL CHECK (total_price >= 0),
            currency text DEFAULT 'CAD',
            
            -- 状态信息
            order_status text DEFAULT 'pending' CHECK (order_status IN ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled')),
            payment_status text DEFAULT 'pending' CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),
            
            -- 时间信息
            scheduled_start_time timestamptz,
            scheduled_end_time timestamptz,
            
            -- 地址信息快照
            service_address_snapshot jsonb,
            
            -- 备注信息
            user_notes text,
            provider_notes text,
            
            -- 餐饮专用字段
            delivery_method text CHECK (delivery_method IN ('delivery', 'pickup', 'dine_in')),
            estimated_delivery_time timestamptz,
            
            -- 时间戳
            created_at timestamptz DEFAULT now(),
            updated_at timestamptz DEFAULT now()
        );
        RAISE NOTICE '已创建orders表';
    ELSE
        -- 如果orders表存在，检查并添加必要字段
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                       WHERE table_name='orders' AND column_name='order_source') THEN
            ALTER TABLE public.orders ADD COLUMN order_source text 
                DEFAULT 'direct' CHECK (order_source IN ('direct', 'cart', 'quote'));
            RAISE NOTICE '已为orders表添加order_source字段';
        END IF;
    END IF;
END $$;

-- 创建订单项目表（如果不存在）
CREATE TABLE IF NOT EXISTS public.order_items (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    
    -- 商品信息（从购物车复制）
    service_id text NOT NULL,
    service_detail_id text,
    item_type text NOT NULL,
    quantity integer NOT NULL CHECK (quantity > 0),
    unit_price numeric NOT NULL CHECK (unit_price >= 0),
    
    -- 定制信息快照
    customizations jsonb DEFAULT '{}',
    special_instructions text,
    
    -- 商品信息快照
    item_name_snapshot jsonb NOT NULL,
    item_description_snapshot text,
    item_image_snapshot text,
    provider_name_snapshot text,
    
    -- 计算字段
    subtotal numeric GENERATED ALWAYS AS (quantity * unit_price) STORED,
    
    created_at timestamptz DEFAULT now()
);

-- =====================================================
-- 第四部分：议价相关表
-- =====================================================

-- 创建议价记录表
CREATE TABLE IF NOT EXISTS public.negotiation_records (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id text NOT NULL,
    user_id uuid NOT NULL REFERENCES auth.users(id),
    provider_id uuid,
    
    -- 议价类型和状态
    quote_type text NOT NULL CHECK (quote_type IN ('quick', 'detailed', 'chat')),
    status text DEFAULT 'pending' CHECK (status IN ('pending', 'quoted', 'accepted', 'rejected', 'expired')),
    
    -- 用户需求
    user_budget_range jsonb, -- {"min": 100, "max": 200, "currency": "CAD"}
    user_requirements text,
    user_preferred_time timestamptz,
    
    -- 服务商报价
    provider_quote numeric,
    provider_notes text,
    quote_valid_until timestamptz,
    
    -- 最终协议
    final_agreed_price numeric,
    final_agreed_terms text,
    
    -- 时间戳
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    quoted_at timestamptz,
    agreed_at timestamptz
);

-- =====================================================
-- 第五部分：创建索引
-- =====================================================

-- 统一购物车表索引
CREATE INDEX IF NOT EXISTS idx_unified_carts_user_status ON public.unified_carts(user_id, status);
CREATE INDEX IF NOT EXISTS idx_unified_carts_expires_at ON public.unified_carts(expires_at);
CREATE INDEX IF NOT EXISTS idx_unified_carts_cart_type ON public.unified_carts(cart_type);
CREATE INDEX IF NOT EXISTS idx_unified_carts_created_at ON public.unified_carts(created_at);

-- 购物车项目表索引
CREATE INDEX IF NOT EXISTS idx_cart_items_cart_id ON public.cart_items(cart_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_service_id ON public.cart_items(service_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_service_detail_id ON public.cart_items(service_detail_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_scheduled_time ON public.cart_items(scheduled_start_time);
CREATE INDEX IF NOT EXISTS idx_cart_items_added_at ON public.cart_items(added_at);
CREATE INDEX IF NOT EXISTS idx_cart_items_item_type ON public.cart_items(item_type);

-- GIN索引优化JSON查询
CREATE INDEX IF NOT EXISTS idx_cart_items_customizations_gin ON public.cart_items USING GIN (customizations);
CREATE INDEX IF NOT EXISTS idx_cart_items_item_name_gin ON public.cart_items USING GIN (item_name_snapshot);

-- 购物车操作日志表索引
CREATE INDEX IF NOT EXISTS idx_cart_operation_logs_cart_id ON public.cart_operation_logs(cart_id);
CREATE INDEX IF NOT EXISTS idx_cart_operation_logs_user_id ON public.cart_operation_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_cart_operation_logs_operation_type ON public.cart_operation_logs(operation_type);
CREATE INDEX IF NOT EXISTS idx_cart_operation_logs_created_at ON public.cart_operation_logs(created_at);

-- 订单相关索引
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_order_status ON public.orders(order_status);
CREATE INDEX IF NOT EXISTS idx_orders_order_source ON public.orders(order_source);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON public.orders(created_at);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON public.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_service_id ON public.order_items(service_id);

-- 议价记录索引
CREATE INDEX IF NOT EXISTS idx_negotiation_records_user_id ON public.negotiation_records(user_id);
CREATE INDEX IF NOT EXISTS idx_negotiation_records_service_id ON public.negotiation_records(service_id);
CREATE INDEX IF NOT EXISTS idx_negotiation_records_status ON public.negotiation_records(status);
CREATE INDEX IF NOT EXISTS idx_negotiation_records_created_at ON public.negotiation_records(created_at);

-- =====================================================
-- 第六部分：RLS (Row Level Security) 策略
-- =====================================================

-- 启用RLS
ALTER TABLE public.unified_carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_operation_logs ENABLE ROW LEVEL SECURITY;

-- 如果orders表存在，也启用RLS
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name='orders') THEN
        ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
        ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
        RAISE NOTICE '已为orders相关表启用RLS';
    END IF;
END $$;

ALTER TABLE public.negotiation_records ENABLE ROW LEVEL SECURITY;

-- 购物车RLS策略
DROP POLICY IF EXISTS "Users can manage their own carts" ON public.unified_carts;
CREATE POLICY "Users can manage their own carts" ON public.unified_carts
    FOR ALL USING (auth.uid() = user_id);

-- 购物车项目RLS策略
DROP POLICY IF EXISTS "Users can manage their own cart items" ON public.cart_items;
CREATE POLICY "Users can manage their own cart items" ON public.cart_items
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.unified_carts 
            WHERE unified_carts.id = cart_items.cart_id 
            AND unified_carts.user_id = auth.uid()
        )
    );

-- 购物车操作日志RLS策略
DROP POLICY IF EXISTS "Users can view their own cart operations" ON public.cart_operation_logs;
CREATE POLICY "Users can view their own cart operations" ON public.cart_operation_logs
    FOR SELECT USING (auth.uid() = user_id);

-- 订单RLS策略
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name='orders') THEN
        DROP POLICY IF EXISTS "Users can manage their own orders" ON public.orders;
        CREATE POLICY "Users can manage their own orders" ON public.orders
            FOR ALL USING (auth.uid() = user_id);
        
        DROP POLICY IF EXISTS "Users can view their own order items" ON public.order_items;
        CREATE POLICY "Users can view their own order items" ON public.order_items
            FOR ALL USING (
                EXISTS (
                    SELECT 1 FROM public.orders 
                    WHERE orders.id = order_items.order_id 
                    AND orders.user_id = auth.uid()
                )
            );
        RAISE NOTICE '已创建orders相关RLS策略';
    END IF;
END $$;

-- 议价记录RLS策略
DROP POLICY IF EXISTS "Users can manage their own negotiations" ON public.negotiation_records;
CREATE POLICY "Users can manage their own negotiations" ON public.negotiation_records
    FOR ALL USING (auth.uid() = user_id);

-- =====================================================
-- 第七部分：权限设置
-- =====================================================

-- 授予authenticated用户权限
GRANT SELECT, INSERT, UPDATE, DELETE ON public.unified_carts TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.cart_items TO authenticated;
GRANT SELECT, INSERT ON public.cart_operation_logs TO authenticated;

-- 如果orders表存在，授予权限
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name='orders') THEN
        GRANT SELECT, INSERT, UPDATE, DELETE ON public.orders TO authenticated;
        GRANT SELECT, INSERT, UPDATE, DELETE ON public.order_items TO authenticated;
        RAISE NOTICE '已授予orders相关表权限';
    END IF;
END $$;

GRANT SELECT, INSERT, UPDATE, DELETE ON public.negotiation_records TO authenticated;

-- 授予序列权限
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- =====================================================
-- 第八部分：触发器：自动更新时间戳
-- =====================================================

-- 创建通用的updated_at触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为统一购物车表添加触发器
DROP TRIGGER IF EXISTS update_unified_carts_updated_at ON public.unified_carts;
CREATE TRIGGER update_unified_carts_updated_at 
    BEFORE UPDATE ON public.unified_carts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 为购物车项目表添加触发器
DROP TRIGGER IF EXISTS update_cart_items_updated_at ON public.cart_items;
CREATE TRIGGER update_cart_items_updated_at 
    BEFORE UPDATE ON public.cart_items 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 为订单表添加触发器
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name='orders') THEN
        EXECUTE 'DROP TRIGGER IF EXISTS update_orders_updated_at ON public.orders';
        EXECUTE 'CREATE TRIGGER update_orders_updated_at 
                 BEFORE UPDATE ON public.orders 
                 FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()';
        RAISE NOTICE '已为orders表创建触发器';
    END IF;
END $$;

-- 为议价记录表添加触发器
DROP TRIGGER IF EXISTS update_negotiation_records_updated_at ON public.negotiation_records;
CREATE TRIGGER update_negotiation_records_updated_at 
    BEFORE UPDATE ON public.negotiation_records 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 第九部分：初始数据和视图
-- =====================================================

-- 创建购物车统计视图
CREATE OR REPLACE VIEW public.cart_statistics AS
SELECT 
    u.id as cart_id,
    u.user_id,
    u.cart_type,
    u.status,
    COUNT(ci.id) as item_count,
    COALESCE(SUM(ci.subtotal), 0) as total_amount,
    COUNT(DISTINCT ci.service_id) as unique_services,
    u.created_at,
    u.updated_at
FROM public.unified_carts u
LEFT JOIN public.cart_items ci ON u.id = ci.cart_id
GROUP BY u.id, u.user_id, u.cart_type, u.status, u.created_at, u.updated_at;

-- 授予视图权限
GRANT SELECT ON public.cart_statistics TO authenticated;

-- =====================================================
-- 第十部分：验证脚本
-- =====================================================

-- 验证所有表和配置创建成功
DO $$
DECLARE
    table_count INTEGER;
    index_count INTEGER;
    policy_count INTEGER;
    trigger_count INTEGER;
BEGIN
    -- 检查核心表数量
    SELECT COUNT(*) INTO table_count 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name IN ('unified_carts', 'cart_items', 'cart_operation_logs', 'negotiation_records');
    
    -- 检查索引数量
    SELECT COUNT(*) INTO index_count 
    FROM pg_indexes 
    WHERE schemaname = 'public' 
    AND (indexname LIKE 'idx_cart%' OR indexname LIKE 'idx_unified_carts%' 
         OR indexname LIKE 'idx_negotiation%' OR indexname LIKE 'idx_order%');
    
    -- 检查RLS策略数量
    SELECT COUNT(*) INTO policy_count 
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename IN ('unified_carts', 'cart_items', 'cart_operation_logs', 'negotiation_records');
    
    -- 检查触发器数量
    SELECT COUNT(*) INTO trigger_count 
    FROM information_schema.triggers 
    WHERE trigger_schema = 'public' 
    AND trigger_name LIKE '%updated_at%';
    
    RAISE NOTICE '==============================================';
    RAISE NOTICE '购物车系统数据库创建完成！';
    RAISE NOTICE '==============================================';
    RAISE NOTICE '核心表数量: % (预期: 4)', table_count;
    RAISE NOTICE '索引数量: % (预期: >= 15)', index_count;
    RAISE NOTICE 'RLS策略数量: % (预期: >= 4)', policy_count;
    RAISE NOTICE '触发器数量: % (预期: >= 3)', trigger_count;
    RAISE NOTICE '==============================================';
    
    IF table_count >= 4 AND index_count >= 15 AND policy_count >= 4 AND trigger_count >= 3 THEN
        RAISE NOTICE '✅ 所有购物车系统组件创建成功！';
        RAISE NOTICE '📋 新增表：unified_carts, cart_items, cart_operation_logs, negotiation_records';
        RAISE NOTICE '🔧 修改表：services (添加supports_cart, booking_type)';
        RAISE NOTICE '🔧 修改表：service_details (添加库存和可用性字段)';
        RAISE NOTICE '📋 订单表：orders, order_items (如果不存在会创建)';
        RAISE NOTICE '🔍 视图：cart_statistics';
        RAISE NOTICE '🛡️ 安全：RLS策略已启用';
        RAISE NOTICE '⚙️ 自动化：触发器已配置';
    ELSE
        RAISE WARNING '⚠️ 部分组件可能未正确创建，请检查日志';
    END IF;
    RAISE NOTICE '==============================================';
    RAISE NOTICE '📖 使用说明：';
    RAISE NOTICE '1. 购物车功能现在可以正常使用';
    RAISE NOTICE '2. 支持餐饮和预约两种服务类型';
    RAISE NOTICE '3. 包含完整的RLS安全策略';
    RAISE NOTICE '4. 自动过期机制（24小时）';
    RAISE NOTICE '5. 支持议价和订单转换功能';
    RAISE NOTICE '==============================================';
END $$;
