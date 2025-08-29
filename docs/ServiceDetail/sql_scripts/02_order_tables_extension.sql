-- =====================================================
-- 订单表扩展脚本 - 支持多种订单来源
-- 执行环境: Supabase PostgreSQL
-- 创建日期: 2025-01-08
-- 版本: v1.0
-- =====================================================

-- =====================================================
-- 1. 扩展 orders 表
-- =====================================================

-- 添加新字段支持多种订单来源
ALTER TABLE public.orders 
ADD COLUMN IF NOT EXISTS order_source text DEFAULT 'direct' CHECK (order_source IN ('direct', 'cart', 'quote')),
ADD COLUMN IF NOT EXISTS source_cart_id uuid REFERENCES public.unified_carts(id),
ADD COLUMN IF NOT EXISTS source_quote_id uuid REFERENCES public.negotiation_records(id),
ADD COLUMN IF NOT EXISTS batch_order_id uuid,
ADD COLUMN IF NOT EXISTS delivery_method text CHECK (delivery_method IN ('delivery', 'pickup', 'dine_in', 'on_site')),
ADD COLUMN IF NOT EXISTS estimated_completion_time timestamptz,
ADD COLUMN IF NOT EXISTS cart_snapshot jsonb; -- 购物车转换时的快照

-- 添加字段注释
COMMENT ON COLUMN public.orders.order_source IS '订单来源：direct(直接下单), cart(购物车), quote(询价)';
COMMENT ON COLUMN public.orders.source_cart_id IS '来源购物车ID，当order_source为cart时使用';
COMMENT ON COLUMN public.orders.source_quote_id IS '来源询价记录ID，当order_source为quote时使用';
COMMENT ON COLUMN public.orders.batch_order_id IS '批量订单ID，多个订单可共享同一批次';
COMMENT ON COLUMN public.orders.delivery_method IS '配送方式：delivery(配送), pickup(自取), dine_in(堂食), on_site(上门)';
COMMENT ON COLUMN public.orders.cart_snapshot IS '购物车转换时的快照数据，用于订单历史追踪';

-- =====================================================
-- 2. 扩展 order_items 表
-- =====================================================

-- 添加新字段支持更详细的订单项目信息
ALTER TABLE public.order_items
ADD COLUMN IF NOT EXISTS item_type text DEFAULT 'service' CHECK (item_type IN ('service', 'menu_item', 'appointment', 'package')),
ADD COLUMN IF NOT EXISTS customizations_snapshot jsonb DEFAULT '{}',
ADD COLUMN IF NOT EXISTS dietary_restrictions_snapshot text[],
ADD COLUMN IF NOT EXISTS scheduled_start_time timestamptz,
ADD COLUMN IF NOT EXISTS scheduled_end_time timestamptz,
ADD COLUMN IF NOT EXISTS service_address_snapshot jsonb;

-- 添加字段注释
COMMENT ON COLUMN public.order_items.item_type IS '订单项目类型：service(普通服务), menu_item(菜品), appointment(预约), package(套餐)';
COMMENT ON COLUMN public.order_items.customizations_snapshot IS '定制选项快照，保存下单时的定制要求';
COMMENT ON COLUMN public.order_items.dietary_restrictions_snapshot IS '饮食限制快照';
COMMENT ON COLUMN public.order_items.scheduled_start_time IS '预约开始时间（预约类服务使用）';
COMMENT ON COLUMN public.order_items.scheduled_end_time IS '预约结束时间（预约类服务使用）';
COMMENT ON COLUMN public.order_items.service_address_snapshot IS '服务地址快照';

-- =====================================================
-- 3. 创建批量订单表
-- =====================================================

CREATE TABLE IF NOT EXISTS public.batch_orders (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id),
    cart_id uuid REFERENCES public.unified_carts(id),
    
    -- 批次信息
    batch_number text NOT NULL UNIQUE, -- 批次号，如 BO20250108001
    total_orders_count integer NOT NULL CHECK (total_orders_count > 0),
    completed_orders_count integer DEFAULT 0 CHECK (completed_orders_count >= 0),
    total_amount numeric NOT NULL CHECK (total_amount >= 0),
    currency text DEFAULT 'CAD',
    
    -- 支付信息
    payment_status text DEFAULT 'pending' CHECK (payment_status IN ('pending', 'partial', 'completed', 'failed', 'refunded')),
    payment_method_id uuid,
    payment_intent_id text, -- Stripe等支付平台的意图ID
    payment_breakdown jsonb, -- 支付明细
    
    -- 配送信息
    delivery_info jsonb, -- 配送相关信息
    estimated_total_completion_time timestamptz,
    
    -- 时间戳
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    paid_at timestamptz,
    completed_at timestamptz
);

-- 添加注释
COMMENT ON TABLE public.batch_orders IS '批量订单表，用于管理从购物车生成的多个订单';
COMMENT ON COLUMN public.batch_orders.batch_number IS '批次号，格式：BO + YYYYMMDD + 序号';
COMMENT ON COLUMN public.batch_orders.payment_breakdown IS '支付明细，包含各种费用的分解';
COMMENT ON COLUMN public.batch_orders.delivery_info IS '配送信息，包含配送地址、时间等';

-- =====================================================
-- 4. 创建订单状态历史表
-- =====================================================

CREATE TABLE IF NOT EXISTS public.order_status_history (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    
    -- 状态变更信息
    old_status text,
    new_status text NOT NULL,
    status_reason text, -- 状态变更原因
    
    -- 操作者信息
    changed_by_user_id uuid REFERENCES auth.users(id),
    changed_by_user_type text CHECK (changed_by_user_type IN ('customer', 'provider', 'system', 'admin')),
    
    -- 额外信息
    notes text,
    metadata jsonb,
    
    created_at timestamptz DEFAULT now()
);

-- 添加注释
COMMENT ON TABLE public.order_status_history IS '订单状态历史表，记录订单状态的所有变更';
COMMENT ON COLUMN public.order_status_history.changed_by_user_type IS '操作者类型：customer(客户), provider(服务商), system(系统), admin(管理员)';

-- =====================================================
-- 5. 创建索引
-- =====================================================

-- orders表新增字段索引
CREATE INDEX IF NOT EXISTS idx_orders_order_source ON public.orders(order_source);
CREATE INDEX IF NOT EXISTS idx_orders_source_cart_id ON public.orders(source_cart_id);
CREATE INDEX IF NOT EXISTS idx_orders_source_quote_id ON public.orders(source_quote_id);
CREATE INDEX IF NOT EXISTS idx_orders_batch_order_id ON public.orders(batch_order_id);
CREATE INDEX IF NOT EXISTS idx_orders_delivery_method ON public.orders(delivery_method);
CREATE INDEX IF NOT EXISTS idx_orders_estimated_completion ON public.orders(estimated_completion_time);

-- order_items表新增字段索引
CREATE INDEX IF NOT EXISTS idx_order_items_item_type ON public.order_items(item_type);
CREATE INDEX IF NOT EXISTS idx_order_items_scheduled_start ON public.order_items(scheduled_start_time);
CREATE INDEX IF NOT EXISTS idx_order_items_scheduled_end ON public.order_items(scheduled_end_time);

-- GIN索引优化JSON查询
CREATE INDEX IF NOT EXISTS idx_order_items_customizations_gin ON public.order_items USING GIN (customizations_snapshot);
CREATE INDEX IF NOT EXISTS idx_orders_cart_snapshot_gin ON public.orders USING GIN (cart_snapshot);

-- batch_orders表索引
CREATE INDEX IF NOT EXISTS idx_batch_orders_user_id ON public.batch_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_batch_orders_cart_id ON public.batch_orders(cart_id);
CREATE INDEX IF NOT EXISTS idx_batch_orders_payment_status ON public.batch_orders(payment_status);
CREATE INDEX IF NOT EXISTS idx_batch_orders_created_at ON public.batch_orders(created_at);
CREATE INDEX IF NOT EXISTS idx_batch_orders_batch_number ON public.batch_orders(batch_number);

-- order_status_history表索引
CREATE INDEX IF NOT EXISTS idx_order_status_history_order_id ON public.order_status_history(order_id);
CREATE INDEX IF NOT EXISTS idx_order_status_history_created_at ON public.order_status_history(created_at);
CREATE INDEX IF NOT EXISTS idx_order_status_history_new_status ON public.order_status_history(new_status);

-- =====================================================
-- 6. RLS策略
-- =====================================================

-- 批量订单表RLS
ALTER TABLE public.batch_orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own batch orders" ON public.batch_orders
    FOR ALL USING (auth.uid() = user_id);

-- 订单状态历史表RLS
ALTER TABLE public.order_status_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view order status history" ON public.order_status_history
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.orders 
            WHERE orders.id = order_status_history.order_id 
            AND (orders.user_id = auth.uid() OR orders.provider_id IN (
                SELECT id FROM public.provider_profiles WHERE user_id = auth.uid()
            ))
        )
    );

-- =====================================================
-- 7. 权限设置
-- =====================================================

-- 授予authenticated用户权限
GRANT SELECT, INSERT, UPDATE, DELETE ON public.batch_orders TO authenticated;
GRANT SELECT, INSERT ON public.order_status_history TO authenticated;

-- =====================================================
-- 8. 触发器
-- =====================================================

-- 为batch_orders表添加更新时间戳触发器
CREATE TRIGGER update_batch_orders_updated_at 
    BEFORE UPDATE ON public.batch_orders 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 创建订单状态变更记录触发器
CREATE OR REPLACE FUNCTION log_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
    -- 只有状态真正发生变化时才记录
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO public.order_status_history (
            order_id, 
            old_status, 
            new_status, 
            changed_by_user_id,
            changed_by_user_type,
            status_reason
        ) VALUES (
            NEW.id, 
            OLD.status, 
            NEW.status, 
            auth.uid(),
            CASE 
                WHEN auth.uid() = NEW.user_id THEN 'customer'
                WHEN auth.uid() IN (SELECT user_id FROM public.provider_profiles WHERE id = NEW.provider_id) THEN 'provider'
                ELSE 'system'
            END,
            'Status updated'
        );
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为orders表添加状态变更触发器
CREATE TRIGGER order_status_change_log 
    AFTER UPDATE ON public.orders 
    FOR EACH ROW EXECUTE FUNCTION log_order_status_change();

-- =====================================================
-- 9. 批次号生成函数
-- =====================================================

CREATE OR REPLACE FUNCTION generate_batch_number()
RETURNS TEXT AS $$
DECLARE
    date_part TEXT;
    sequence_part TEXT;
    next_seq INTEGER;
BEGIN
    -- 获取日期部分 (YYYYMMDD)
    date_part := to_char(NOW(), 'YYYYMMDD');
    
    -- 获取当天的下一个序号
    SELECT COALESCE(
        (SELECT MAX(CAST(RIGHT(batch_number, 3) AS INTEGER)) + 1
         FROM public.batch_orders 
         WHERE batch_number LIKE 'BO' || date_part || '%'), 
        1
    ) INTO next_seq;
    
    -- 格式化序号为3位数字
    sequence_part := LPAD(next_seq::TEXT, 3, '0');
    
    -- 返回完整批次号
    RETURN 'BO' || date_part || sequence_part;
END;
$$ LANGUAGE plpgsql;

-- 为batch_orders表添加自动生成批次号的触发器
CREATE OR REPLACE FUNCTION set_batch_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.batch_number IS NULL OR NEW.batch_number = '' THEN
        NEW.batch_number := generate_batch_number();
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER set_batch_number_trigger 
    BEFORE INSERT ON public.batch_orders 
    FOR EACH ROW EXECUTE FUNCTION set_batch_number();

-- =====================================================
-- 10. 验证脚本
-- =====================================================

DO $$
DECLARE
    orders_columns_count INTEGER;
    order_items_columns_count INTEGER;
    batch_orders_exists BOOLEAN;
    new_indexes_count INTEGER;
BEGIN
    -- 检查orders表新增字段
    SELECT COUNT(*) INTO orders_columns_count
    FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'orders'
    AND column_name IN ('order_source', 'source_cart_id', 'source_quote_id', 'batch_order_id', 'delivery_method', 'estimated_completion_time', 'cart_snapshot');
    
    -- 检查order_items表新增字段
    SELECT COUNT(*) INTO order_items_columns_count
    FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'order_items'
    AND column_name IN ('item_type', 'customizations_snapshot', 'dietary_restrictions_snapshot', 'scheduled_start_time', 'scheduled_end_time', 'service_address_snapshot');
    
    -- 检查batch_orders表是否存在
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'batch_orders'
    ) INTO batch_orders_exists;
    
    -- 检查新增索引数量
    SELECT COUNT(*) INTO new_indexes_count
    FROM pg_indexes 
    WHERE schemaname = 'public' 
    AND (indexname LIKE 'idx_orders_%' OR indexname LIKE 'idx_order_items_%' OR indexname LIKE 'idx_batch_orders_%')
    AND indexname NOT IN (
        SELECT indexname FROM pg_indexes 
        WHERE schemaname = 'public' 
        AND tablename IN ('orders', 'order_items')
        AND indexname ~ '^idx_(orders|order_items)_(id|user_id|provider_id|service_id|created_at)$'
    );
    
    RAISE NOTICE '订单表扩展完成！';
    RAISE NOTICE 'orders表新增字段: % (预期: 7)', orders_columns_count;
    RAISE NOTICE 'order_items表新增字段: % (预期: 6)', order_items_columns_count;
    RAISE NOTICE 'batch_orders表已创建: %', batch_orders_exists;
    RAISE NOTICE '新增索引数量: %', new_indexes_count;
    
    IF orders_columns_count = 7 AND order_items_columns_count = 6 AND batch_orders_exists THEN
        RAISE NOTICE '✅ 订单表扩展成功！';
    ELSE
        RAISE WARNING '⚠️ 部分扩展可能未正确完成，请检查日志';
    END IF;
END $$;
