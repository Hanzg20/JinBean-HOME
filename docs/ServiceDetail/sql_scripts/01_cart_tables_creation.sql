-- =====================================================
-- 统一购物车表结构创建脚本
-- 执行环境: Supabase PostgreSQL
-- 创建日期: 2025-01-08
-- 版本: v1.0
-- =====================================================

-- 确保必要的扩展已启用
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. 统一购物车表
-- =====================================================
CREATE TABLE IF NOT EXISTS public.unified_carts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    cart_type text NOT NULL CHECK (cart_type IN ('restaurant', 'appointment', 'mixed')),
    status text DEFAULT 'active' CHECK (status IN ('active', 'converting', 'converted', 'expired')),
    
    -- 餐饮服务专用字段
    delivery_method text CHECK (delivery_method IN ('delivery', 'pickup', 'dine_in')),
    delivery_address_id uuid REFERENCES public.user_addresses(id),
    estimated_delivery_time timestamptz,
    special_instructions text,
    
    -- 通用字段
    expires_at timestamptz DEFAULT (now() + interval '24 hours'),
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    
    -- 约束条件
    UNIQUE(user_id, cart_type, status)
);

-- 添加注释
COMMENT ON TABLE public.unified_carts IS '统一购物车表，支持餐饮和预约服务';
COMMENT ON COLUMN public.unified_carts.cart_type IS '购物车类型：restaurant(餐饮), appointment(预约), mixed(混合)';
COMMENT ON COLUMN public.unified_carts.status IS '购物车状态：active(活跃), converting(转换中), converted(已转换), expired(已过期)';
COMMENT ON COLUMN public.unified_carts.delivery_method IS '配送方式：delivery(配送), pickup(自取), dine_in(堂食)';

-- =====================================================
-- 2. 购物车项目表
-- =====================================================
CREATE TABLE IF NOT EXISTS public.cart_items (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id uuid NOT NULL REFERENCES public.unified_carts(id) ON DELETE CASCADE,
    
    -- 服务关联
    service_id uuid NOT NULL REFERENCES public.services(id),
    service_detail_id uuid REFERENCES public.service_details(id),
    
    -- 基础信息
    item_type text NOT NULL CHECK (item_type IN ('menu_item', 'appointment', 'package')),
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

-- 添加注释
COMMENT ON TABLE public.cart_items IS '购物车项目表，存储购物车中的具体商品/服务';
COMMENT ON COLUMN public.cart_items.item_type IS '项目类型：menu_item(菜品), appointment(预约), package(套餐)';
COMMENT ON COLUMN public.cart_items.customizations IS '定制选项，JSON格式存储口味、配料等信息';
COMMENT ON COLUMN public.cart_items.item_name_snapshot IS '商品名称快照，JSON格式支持多语言';
COMMENT ON COLUMN public.cart_items.subtotal IS '小计金额，自动计算 = quantity * unit_price';

-- =====================================================
-- 3. 购物车操作日志表
-- =====================================================
CREATE TABLE IF NOT EXISTS public.cart_operation_logs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id uuid NOT NULL REFERENCES public.unified_carts(id) ON DELETE CASCADE,
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

-- 添加注释
COMMENT ON TABLE public.cart_operation_logs IS '购物车操作日志表，记录所有购物车相关操作';
COMMENT ON COLUMN public.cart_operation_logs.operation_type IS '操作类型：add(添加), remove(删除), update_quantity(更新数量), update_customization(更新定制), clear(清空), convert_to_order(转换为订单)';

-- =====================================================
-- 4. 创建索引
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

-- =====================================================
-- 5. RLS (Row Level Security) 策略
-- =====================================================

-- 启用RLS
ALTER TABLE public.unified_carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_operation_logs ENABLE ROW LEVEL SECURITY;

-- 购物车RLS策略
CREATE POLICY "Users can manage their own carts" ON public.unified_carts
    FOR ALL USING (auth.uid() = user_id);

-- 购物车项目RLS策略
CREATE POLICY "Users can manage their own cart items" ON public.cart_items
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.unified_carts 
            WHERE unified_carts.id = cart_items.cart_id 
            AND unified_carts.user_id = auth.uid()
        )
    );

-- 购物车操作日志RLS策略
CREATE POLICY "Users can view their own cart operations" ON public.cart_operation_logs
    FOR SELECT USING (auth.uid() = user_id);

-- =====================================================
-- 6. 权限设置
-- =====================================================

-- 授予authenticated用户权限
GRANT SELECT, INSERT, UPDATE, DELETE ON public.unified_carts TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.cart_items TO authenticated;
GRANT SELECT, INSERT ON public.cart_operation_logs TO authenticated;

-- 授予序列权限
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- =====================================================
-- 7. 触发器：自动更新时间戳
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
CREATE TRIGGER update_unified_carts_updated_at 
    BEFORE UPDATE ON public.unified_carts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 为购物车项目表添加触发器
CREATE TRIGGER update_cart_items_updated_at 
    BEFORE UPDATE ON public.cart_items 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 8. 验证脚本
-- =====================================================

-- 验证表创建成功
DO $$
DECLARE
    table_count INTEGER;
    index_count INTEGER;
    policy_count INTEGER;
BEGIN
    -- 检查表数量
    SELECT COUNT(*) INTO table_count 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name IN ('unified_carts', 'cart_items', 'cart_operation_logs');
    
    -- 检查索引数量
    SELECT COUNT(*) INTO index_count 
    FROM pg_indexes 
    WHERE schemaname = 'public' 
    AND indexname LIKE 'idx_cart%' OR indexname LIKE 'idx_unified_carts%';
    
    -- 检查RLS策略数量
    SELECT COUNT(*) INTO policy_count 
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename IN ('unified_carts', 'cart_items', 'cart_operation_logs');
    
    RAISE NOTICE '购物车表创建完成！';
    RAISE NOTICE '表数量: % (预期: 3)', table_count;
    RAISE NOTICE '索引数量: % (预期: >= 12)', index_count;
    RAISE NOTICE 'RLS策略数量: % (预期: 3)', policy_count;
    
    IF table_count = 3 AND index_count >= 12 AND policy_count = 3 THEN
        RAISE NOTICE '✅ 所有购物车表和配置创建成功！';
    ELSE
        RAISE WARNING '⚠️ 部分配置可能未正确创建，请检查日志';
    END IF;
END $$;
