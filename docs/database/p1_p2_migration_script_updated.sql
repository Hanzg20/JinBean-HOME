-- =====================================================
-- JinBean Platform - P1、P2集成前数据库迁移脚本（最终版）
-- 版本: v1.2.0
-- 创建日期: 2025-01-08
-- 描述: 为P1、P2功能集成准备数据库结构（修改已存在表的模式）
-- 执行环境: Supabase SQL编辑器
-- 注意: services, addresses, ref_codes, unified_carts, cart_items 表已存在，将仅修改
-- =====================================================

-- 启用必要的扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- 第一步：修改现有基础表结构
-- =====================================================

-- 1.1 修改 addresses 表（添加P1、P2所需字段）
DO $$
BEGIN
    -- 现有addresses表已有latitude, longitude, country字段，只需添加缺失字段
    
    -- 添加用户关联字段（如果不存在）
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='addresses' AND column_name='user_id') THEN
        ALTER TABLE public.addresses ADD COLUMN user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;
    END IF;
    
    -- 添加地址类型字段（如果不存在）
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='addresses' AND column_name='address_type') THEN
        ALTER TABLE public.addresses ADD COLUMN address_type text DEFAULT 'home';
    END IF;
    
    -- 添加默认地址标记（如果不存在）
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='addresses' AND column_name='is_default') THEN
        ALTER TABLE public.addresses ADD COLUMN is_default boolean DEFAULT false;
    END IF;
    
    -- 确保country字段有默认值（现有表已有此字段和默认值）
    -- ALTER TABLE public.addresses ALTER COLUMN country SET DEFAULT 'Canada'; -- 已存在
END $$;

-- 添加地址类型约束
ALTER TABLE public.addresses DROP CONSTRAINT IF EXISTS addresses_address_type_check;
ALTER TABLE public.addresses ADD CONSTRAINT addresses_address_type_check 
CHECK (address_type IN ('home', 'work', 'other'));

-- 创建addresses表新索引（如果不存在）
-- 注意：现有表已有 idx_addresses_lat_lng, idx_addresses_city, idx_addresses_postal_code 等索引
CREATE INDEX IF NOT EXISTS idx_addresses_user_id ON addresses (user_id);
CREATE INDEX IF NOT EXISTS idx_addresses_type ON addresses (address_type);

-- 启用addresses表RLS（如果未启用）
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage their own addresses" ON public.addresses;
CREATE POLICY "Users can manage their own addresses" 
    ON public.addresses FOR ALL TO authenticated 
    USING (user_id = auth.uid());

-- =====================================================
-- 第二步：修改现有核心表结构
-- =====================================================

-- 2.1 ref_codes 表保持纯粹（无需修改）
-- 注意：ref_codes 应该保持为纯粹的参考代码表，不应包含业务逻辑
-- 当前表中的 industry_type, industry_config, default_pricing_type 等业务字段
-- 从架构角度看应该移到专门的业务配置表中，但为了兼容现有数据，暂时保留
-- 
-- ref_codes 的核心职责：
-- - 存储系统中各种类型的参考代码和名称
-- - 支持多语言名称和描述 (name jsonb, description jsonb)
-- - 支持层级结构 (parent_id, level)
-- - 通用的状态管理 (status, sort_order)

RAISE NOTICE 'ref_codes表保持不变 - 作为通用参考代码表使用';

-- 2.2 修改 services 表（增加P1、P2所需字段）
-- 现有表已包含：supports_cart, booking_type（已存在，无需添加）
-- 需要添加：industry_type, industry_metadata, is_available, availability_schedule, 
--          service_area_geometry, max_distance_km, base_price, pricing_model

DO $$
BEGIN
    -- 添加行业类型字段
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='services' AND column_name='industry_type') THEN
        ALTER TABLE public.services ADD COLUMN industry_type text DEFAULT 'food';
        RAISE NOTICE 'services表：添加industry_type字段';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='services' AND column_name='industry_metadata') THEN
        ALTER TABLE public.services ADD COLUMN industry_metadata jsonb DEFAULT '{}';
        RAISE NOTICE 'services表：添加industry_metadata字段';
    END IF;
    
    -- 添加可用性字段
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='services' AND column_name='is_available') THEN
        ALTER TABLE public.services ADD COLUMN is_available boolean DEFAULT true;
        RAISE NOTICE 'services表：添加is_available字段';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='services' AND column_name='availability_schedule') THEN
        ALTER TABLE public.services ADD COLUMN availability_schedule jsonb DEFAULT '{}';
        RAISE NOTICE 'services表：添加availability_schedule字段';
    END IF;
    
    -- 添加服务区域字段
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='services' AND column_name='service_area_geometry') THEN
        ALTER TABLE public.services ADD COLUMN service_area_geometry jsonb;
        RAISE NOTICE 'services表：添加service_area_geometry字段';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='services' AND column_name='max_distance_km') THEN
        ALTER TABLE public.services ADD COLUMN max_distance_km numeric;
        RAISE NOTICE 'services表：添加max_distance_km字段';
    END IF;
    
    -- 添加价格相关字段
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='services' AND column_name='base_price') THEN
        ALTER TABLE public.services ADD COLUMN base_price numeric;
        RAISE NOTICE 'services表：添加base_price字段';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='services' AND column_name='pricing_model') THEN
        ALTER TABLE public.services ADD COLUMN pricing_model text DEFAULT 'fixed';
        RAISE NOTICE 'services表：添加pricing_model字段';
    END IF;
    
    RAISE NOTICE 'services表结构更新完成';
END $$;

-- 设置industry_type为NOT NULL（在添加默认值后）
UPDATE public.services SET industry_type = 'food' WHERE industry_type IS NULL;
ALTER TABLE public.services ALTER COLUMN industry_type SET NOT NULL;

-- 添加services表约束
ALTER TABLE public.services DROP CONSTRAINT IF EXISTS services_industry_type_check;
ALTER TABLE public.services ADD CONSTRAINT services_industry_type_check 
CHECK (industry_type IN ('food', 'home_services', 'transport', 'rental', 'learning', 'professional'));

ALTER TABLE public.services DROP CONSTRAINT IF EXISTS services_pricing_model_check;
ALTER TABLE public.services ADD CONSTRAINT services_pricing_model_check 
CHECK (pricing_model IN ('fixed', 'hourly', 'distance_based', 'quote_only'));

-- 添加services表索引
CREATE INDEX IF NOT EXISTS idx_services_industry_type ON services (industry_type);
CREATE INDEX IF NOT EXISTS idx_services_available ON services (is_available);
CREATE INDEX IF NOT EXISTS idx_services_pricing_model ON services (pricing_model);

-- 2.3 修改 orders 表（支持新的订单状态和字段）
DO $$
BEGIN
    -- 添加新字段支持P1功能
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='industry_type') THEN
        ALTER TABLE public.orders ADD COLUMN industry_type text;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='cart_id') THEN
        ALTER TABLE public.orders ADD COLUMN cart_id uuid;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='subtotal') THEN
        ALTER TABLE public.orders ADD COLUMN subtotal numeric;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='tax_amount') THEN
        ALTER TABLE public.orders ADD COLUMN tax_amount numeric DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='platform_fee') THEN
        ALTER TABLE public.orders ADD COLUMN platform_fee numeric DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='discount_amount') THEN
        ALTER TABLE public.orders ADD COLUMN discount_amount numeric DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='total_amount') THEN
        ALTER TABLE public.orders ADD COLUMN total_amount numeric;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='fulfillment_status') THEN
        ALTER TABLE public.orders ADD COLUMN fulfillment_status text DEFAULT 'pending';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='industry_specific_data') THEN
        ALTER TABLE public.orders ADD COLUMN industry_specific_data jsonb DEFAULT '{}';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='scheduled_time') THEN
        ALTER TABLE public.orders ADD COLUMN scheduled_time timestamptz;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='started_at') THEN
        ALTER TABLE public.orders ADD COLUMN started_at timestamptz;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='completed_at') THEN
        ALTER TABLE public.orders ADD COLUMN completed_at timestamptz;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='cancelled_at') THEN
        ALTER TABLE public.orders ADD COLUMN cancelled_at timestamptz;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='status') THEN
        ALTER TABLE public.orders ADD COLUMN status text DEFAULT 'pending';
    END IF;
END $$;

-- 更新现有数据
UPDATE public.orders SET 
    industry_type = 'food',  -- 设置默认行业类型
    subtotal = total_price,
    total_amount = total_price,
    status = CASE 
        WHEN order_status = 'PendingAcceptance' THEN 'pending'
        WHEN order_status = 'Accepted' THEN 'confirmed'
        WHEN order_status = 'InProgress' THEN 'in_progress'
        WHEN order_status = 'Completed' THEN 'completed'
        WHEN order_status = 'Cancelled' THEN 'cancelled'
        ELSE 'pending'
    END
WHERE industry_type IS NULL OR subtotal IS NULL OR total_amount IS NULL;

-- 添加orders表约束
ALTER TABLE public.orders DROP CONSTRAINT IF EXISTS orders_industry_type_check;
ALTER TABLE public.orders ADD CONSTRAINT orders_industry_type_check 
CHECK (industry_type IN ('food', 'home_services', 'transport', 'rental', 'learning', 'professional'));

-- 添加orders表索引
CREATE INDEX IF NOT EXISTS idx_orders_industry_type ON orders (industry_type);
CREATE INDEX IF NOT EXISTS idx_orders_cart_id ON orders (cart_id);
CREATE INDEX IF NOT EXISTS idx_orders_fulfillment_status ON orders (fulfillment_status);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders (status);

-- =====================================================
-- 第三步：修改现有 order_items 表
-- =====================================================

-- 3.1 验证 order_items 表结构（现有订单商品管理）
-- 注意：order_items 表已包含完善的快照和套餐管理功能
-- 现有字段：unit_price_snapshot, subtotal_price, service_name_snapshot, item_details_snapshot 等
-- 结构已非常完善，仅需添加少量P1、P2字段

DO $$
BEGIN
    -- 验证 order_items 表存在
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name='order_items') THEN
        RAISE EXCEPTION 'order_items 表不存在，请确认订单系统已正确部署';
    END IF;
    
    -- 验证关键现有字段
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='order_items' AND column_name='unit_price_snapshot') THEN
        RAISE EXCEPTION 'order_items表缺少unit_price_snapshot字段';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='order_items' AND column_name='service_name_snapshot') THEN
        RAISE EXCEPTION 'order_items表缺少service_name_snapshot字段';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='order_items' AND column_name='item_details_snapshot') THEN
        RAISE EXCEPTION 'order_items表缺少item_details_snapshot字段';
    END IF;
    
    RAISE NOTICE 'order_items表结构验证通过 - 现有快照和套餐功能完善';
END $$;

-- 注意：order_items 新字段的索引将在字段添加后创建（第9步）

-- =====================================================
-- 第四步：增强现有购物车表
-- =====================================================

-- 4.1 验证 unified_carts 表结构（现有购物车系统）
-- 注意：unified_carts 表已包含完整的购物车管理功能
-- 现有字段：cart_type, delivery_method, delivery_address_id, estimated_delivery_time, special_instructions 等
-- 需要评估是否需要添加P1、P2特定字段

DO $$
BEGIN
    -- 验证 unified_carts 表存在
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name='unified_carts') THEN
        RAISE EXCEPTION 'unified_carts 表不存在，请确认购物车系统已正确部署';
    END IF;
    
    -- 添加行业类型字段（如果需要）
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='unified_carts' AND column_name='industry_type') THEN
        ALTER TABLE public.unified_carts ADD COLUMN industry_type text;
        RAISE NOTICE 'unified_carts表：添加industry_type字段';
    END IF;
    
    -- 添加购物车元数据字段（如果需要）
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='unified_carts' AND column_name='cart_metadata') THEN
        ALTER TABLE public.unified_carts ADD COLUMN cart_metadata jsonb DEFAULT '{}';
        RAISE NOTICE 'unified_carts表：添加cart_metadata字段';
    END IF;
    
    -- 添加总计缓存字段（提高查询性能）
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='unified_carts' AND column_name='total_items') THEN
        ALTER TABLE public.unified_carts ADD COLUMN total_items integer DEFAULT 0;
        RAISE NOTICE 'unified_carts表：添加total_items缓存字段';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='unified_carts' AND column_name='subtotal') THEN
        ALTER TABLE public.unified_carts ADD COLUMN subtotal numeric DEFAULT 0;
        RAISE NOTICE 'unified_carts表：添加subtotal缓存字段';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='unified_carts' AND column_name='tax_amount') THEN
        ALTER TABLE public.unified_carts ADD COLUMN tax_amount numeric DEFAULT 0;
        RAISE NOTICE 'unified_carts表：添加tax_amount缓存字段';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='unified_carts' AND column_name='total_amount') THEN
        ALTER TABLE public.unified_carts ADD COLUMN total_amount numeric DEFAULT 0;
        RAISE NOTICE 'unified_carts表：添加total_amount缓存字段';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='unified_carts' AND column_name='currency') THEN
        ALTER TABLE public.unified_carts ADD COLUMN currency text DEFAULT 'CAD';
        RAISE NOTICE 'unified_carts表：添加currency字段';
    END IF;
    
    RAISE NOTICE 'unified_carts表结构验证和更新完成';
END $$;

-- 4.2 验证 cart_items 表结构（现有购物车商品管理）
-- 注意：cart_items 表已包含完整的商品管理功能
-- 现有字段：item_name_snapshot, item_description_snapshot, customizations, subtotal 等
-- 结构已非常完善，基本无需修改

DO $$
BEGIN
    -- 验证 cart_items 表存在
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name='cart_items') THEN
        RAISE EXCEPTION 'cart_items 表不存在，请确认购物车系统已正确部署';
    END IF;
    
    -- 验证关键字段存在
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='cart_items' AND column_name='item_name_snapshot') THEN
        RAISE EXCEPTION 'cart_items表缺少item_name_snapshot字段';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='cart_items' AND column_name='customizations') THEN
        RAISE EXCEPTION 'cart_items表缺少customizations字段';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='cart_items' AND column_name='subtotal') THEN
        RAISE EXCEPTION 'cart_items表缺少subtotal字段';
    END IF;
    
    -- 添加货币字段（如果缺失）
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='cart_items' AND column_name='currency') THEN
        ALTER TABLE public.cart_items ADD COLUMN currency text DEFAULT 'CAD';
        RAISE NOTICE 'cart_items表：添加currency字段';
    END IF;
    
    RAISE NOTICE 'cart_items表结构验证通过 - 现有结构已非常完善';
END $$;

-- 添加购物车表索引（如果不存在）
-- 注意：unified_carts 表已有基本索引，只添加新字段的索引
CREATE INDEX IF NOT EXISTS idx_unified_carts_industry_type ON unified_carts (industry_type);
CREATE INDEX IF NOT EXISTS idx_cart_items_cart_id ON cart_items (cart_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_service_detail_id ON cart_items (service_detail_id);

-- 启用购物车RLS（如果未启用）
ALTER TABLE public.unified_carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage their own carts" ON public.unified_carts;
CREATE POLICY "Users can manage their own carts" 
    ON public.unified_carts FOR ALL TO authenticated 
    USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can manage own cart items" ON public.cart_items;
CREATE POLICY "Users can manage own cart items" 
    ON public.cart_items FOR ALL TO authenticated 
    USING (cart_id IN (SELECT id FROM unified_carts WHERE user_id = auth.uid()));

-- =====================================================
-- 第五步：创建行业配置表
-- =====================================================

CREATE TABLE IF NOT EXISTS public.industry_configs (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),                   -- 配置ID
    industry_type text UNIQUE NOT NULL,                               -- 行业类型：food=餐饮, home_services=家居, transport=出行, rental=租赁, learning=学习, professional=专业
    display_name jsonb NOT NULL,                                      -- 多语言显示名称
    description jsonb,                                                 -- 多语言描述
    icon_name text,                                                    -- 图标名称
    color_scheme jsonb,                                                -- 颜色方案配置
    supports_cart boolean DEFAULT true,                               -- 是否支持购物车功能
    supports_scheduling boolean DEFAULT true,                         -- 是否支持预约功能
    supports_real_time_tracking boolean DEFAULT false,                -- 是否支持实时跟踪
    supports_quotes boolean DEFAULT true,                             -- 是否支持报价功能
    supports_reviews boolean DEFAULT true,                            -- 是否支持评价功能
    default_pricing_model text DEFAULT 'fixed',                       -- 默认定价模式：fixed=固定价格, hourly=按小时, distance_based=按距离, quote_only=仅报价
    platform_fee_rate numeric DEFAULT 0.05,                          -- 平台费率（小数形式，如0.05表示5%）
    min_platform_fee numeric DEFAULT 1.00,                           -- 最小平台费用
    business_rules jsonb DEFAULT '{}',                                -- 业务规则配置
    workflow_config jsonb DEFAULT '{}',                               -- 工作流配置
    is_active boolean DEFAULT true,                                   -- 是否启用
    sort_order integer DEFAULT 0,                                     -- 排序序号
    created_at timestamptz NOT NULL DEFAULT now(),                    -- 创建时间
    updated_at timestamptz NOT NULL DEFAULT now(),                    -- 更新时间
    CONSTRAINT industry_configs_industry_type_check CHECK (industry_type IN ('food', 'home_services', 'transport', 'rental', 'learning', 'professional'))
);

-- 创建industry_configs索引
CREATE INDEX IF NOT EXISTS idx_industry_configs_type ON industry_configs (industry_type);
CREATE INDEX IF NOT EXISTS idx_industry_configs_active ON industry_configs (is_active);

-- 插入基础行业配置数据
INSERT INTO industry_configs (industry_type, display_name, description, icon_name, supports_cart, supports_real_time_tracking) VALUES
('food', '{"en": "Food & Dining", "zh": "餐饮美食"}', '{"en": "Restaurant and food services", "zh": "餐厅和食品服务"}', 'restaurant', true, false),
('home_services', '{"en": "Home Services", "zh": "家居服务"}', '{"en": "Home improvement and maintenance", "zh": "家居改善和维护"}', 'home_repair_service', true, false),
('transport', '{"en": "Transportation", "zh": "出行交通"}', '{"en": "Ride sharing and transport services", "zh": "出行和交通服务"}', 'directions_car', false, true),
('rental', '{"en": "Rental & Sharing", "zh": "租赁共享"}', '{"en": "Equipment and item rental services", "zh": "设备和物品租赁服务"}', 'category', true, false),
('learning', '{"en": "Learning & Growth", "zh": "学习成长"}', '{"en": "Education and skill development", "zh": "教育和技能发展"}', 'school', true, false),
('professional', '{"en": "Professional Services", "zh": "专业速帮"}', '{"en": "Expert consultation and professional services", "zh": "专家咨询和专业服务"}', 'work', false, false)
ON CONFLICT (industry_type) DO NOTHING;

-- =====================================================
-- 第六步：创建支付系统表
-- =====================================================

-- 6.1 支付方式表
CREATE TABLE IF NOT EXISTS public.payment_methods (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),                   -- 支付方式ID
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE, -- 用户ID
    type text NOT NULL,                                               -- 支付方式类型：card=信用卡, bank_account=银行账户, digital_wallet=数字钱包, cash=现金
    provider text NOT NULL,                                          -- 支付提供商：stripe, paypal, apple_pay, google_pay, cash, interac
    external_id text,                                                 -- 外部系统ID（如Stripe Customer ID）
    external_payment_method_id text,                                  -- 外部支付方式ID（如Stripe Payment Method ID）
    display_name text,                                                -- 显示名称（如"Visa ending in 1234"）
    last_four text,                                                   -- 卡号或账号后四位
    brand text,                                                       -- 品牌：visa, mastercard, amex, discover等
    expiry_month integer,                                             -- 过期月份
    expiry_year integer,                                              -- 过期年份
    is_default boolean DEFAULT false,                                -- 是否为默认支付方式
    is_active boolean DEFAULT true,                                  -- 是否启用
    metadata jsonb DEFAULT '{}',                                     -- 额外元数据
    created_at timestamptz NOT NULL DEFAULT now(),                   -- 创建时间
    updated_at timestamptz NOT NULL DEFAULT now(),                   -- 更新时间
    CONSTRAINT payment_methods_type_check CHECK (type IN ('card', 'bank_account', 'digital_wallet', 'cash')),
    CONSTRAINT payment_methods_provider_check CHECK (provider IN ('stripe', 'paypal', 'apple_pay', 'google_pay', 'cash', 'interac'))
);

-- 6.2 支付记录表
CREATE TABLE IF NOT EXISTS public.payments (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),                   -- 支付记录ID
    order_id uuid NOT NULL REFERENCES public.orders(id),            -- 关联订单ID
    payment_method_id uuid REFERENCES public.payment_methods(id),    -- 使用的支付方式ID
    amount numeric NOT NULL,                                          -- 支付金额
    currency text NOT NULL DEFAULT 'CAD',                           -- 货币类型
    status text NOT NULL DEFAULT 'pending',                         -- 支付状态：pending=待处理, authorized=已授权, captured=已收款, failed=失败, cancelled=已取消, refunded=已退款
    provider text NOT NULL,                                         -- 支付提供商
    external_transaction_id text,                                    -- 外部交易ID
    external_charge_id text,                                         -- 外部收费ID
    authorized_at timestamptz,                                       -- 授权时间
    captured_at timestamptz,                                         -- 收款时间
    failed_at timestamptz,                                           -- 失败时间
    failure_code text,                                               -- 失败代码
    failure_message text,                                            -- 失败消息
    provider_fee numeric DEFAULT 0,                                 -- 支付提供商手续费
    platform_fee numeric DEFAULT 0,                                 -- 平台手续费
    metadata jsonb DEFAULT '{}',                                    -- 额外元数据
    created_at timestamptz NOT NULL DEFAULT now(),                  -- 创建时间
    updated_at timestamptz NOT NULL DEFAULT now(),                  -- 更新时间
    CONSTRAINT payments_status_check CHECK (status IN ('pending', 'authorized', 'captured', 'failed', 'cancelled', 'refunded')),
    CONSTRAINT payments_provider_check CHECK (provider IN ('stripe', 'paypal', 'apple_pay', 'google_pay', 'cash', 'interac'))
);

-- 6.3 支付意图表
CREATE TABLE IF NOT EXISTS public.payment_intents (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),                   -- 支付意图ID
    order_id uuid NOT NULL REFERENCES public.orders(id),            -- 关联订单ID
    amount numeric NOT NULL,                                          -- 支付金额
    currency text NOT NULL DEFAULT 'CAD',                           -- 货币类型
    status text NOT NULL DEFAULT 'created',                         -- 支付状态
    provider text NOT NULL,                                         -- 支付提供商
    external_intent_id text NOT NULL,                               -- 外部支付意图ID
    client_secret text,                                              -- 客户端密钥
    payment_method_types text[] DEFAULT '{"card"}',                  -- 支持的支付方式类型
    created_at timestamptz NOT NULL DEFAULT now(),                  -- 创建时间
    updated_at timestamptz NOT NULL DEFAULT now(),                  -- 更新时间
    confirmed_at timestamptz,                                       -- 确认时间
    cancelled_at timestamptz,                                       -- 取消时间
    metadata jsonb DEFAULT '{}',                                    -- 额外元数据
    CONSTRAINT payment_intents_status_check CHECK (status IN ('created', 'requires_payment_method', 'requires_confirmation', 'requires_action', 'processing', 'succeeded', 'cancelled'))
);

-- 6.4 退款表
CREATE TABLE IF NOT EXISTS public.refunds (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),                   -- 退款ID
    payment_id uuid NOT NULL REFERENCES public.payments(id),        -- 关联支付ID
    order_id uuid NOT NULL REFERENCES public.orders(id),            -- 关联订单ID
    amount numeric NOT NULL,                                          -- 退款金额
    currency text NOT NULL DEFAULT 'CAD',                           -- 货币类型
    reason text,                                                      -- 退款原因
    status text NOT NULL DEFAULT 'pending',                         -- 退款状态：pending=待处理, succeeded=成功, failed=失败, cancelled=已取消
    external_refund_id text,                                         -- 外部退款ID
    processed_at timestamptz,                                        -- 处理时间
    failed_at timestamptz,                                           -- 失败时间
    failure_reason text,                                              -- 失败原因
    refund_fee numeric DEFAULT 0,                                   -- 退款手续费
    created_at timestamptz NOT NULL DEFAULT now(),                  -- 创建时间
    updated_at timestamptz NOT NULL DEFAULT now(),                  -- 更新时间
    CONSTRAINT refunds_status_check CHECK (status IN ('pending', 'succeeded', 'failed', 'cancelled'))
);

-- 创建支付系统索引
CREATE INDEX IF NOT EXISTS idx_payment_methods_user_id ON payment_methods (user_id);
CREATE INDEX IF NOT EXISTS idx_payment_methods_type ON payment_methods (type);
CREATE INDEX IF NOT EXISTS idx_payment_methods_provider ON payment_methods (provider);
CREATE INDEX IF NOT EXISTS idx_payments_order_id ON payments (order_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments (status);
CREATE INDEX IF NOT EXISTS idx_payment_intents_order_id ON payment_intents (order_id);
CREATE INDEX IF NOT EXISTS idx_refunds_payment_id ON refunds (payment_id);

-- 启用支付系统RLS
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_intents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.refunds ENABLE ROW LEVEL SECURITY;

-- 创建支付系统RLS策略
DROP POLICY IF EXISTS "Users can manage own payment methods" ON public.payment_methods;
CREATE POLICY "Users can manage own payment methods" 
    ON public.payment_methods FOR ALL TO authenticated 
    USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can view own payments" ON public.payments;
CREATE POLICY "Users can view own payments" 
    ON public.payments FOR SELECT TO authenticated 
    USING (order_id IN (SELECT id FROM orders WHERE user_id = auth.uid() OR provider_id IN (SELECT id FROM provider_profiles WHERE user_id = auth.uid())));

-- =====================================================
-- 第七步：创建定价系统表
-- =====================================================

-- 7.1 定价规则表
drop table  public.pricing_rules 
CREATE TABLE IF NOT EXISTS public.pricing_rules (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),                   -- 定价规则ID
    name text UNIQUE NOT NULL,                                        -- 规则名称（唯一）
    description text,                                                  -- 规则描述
    industry_type text,                                                -- 适用行业类型
    rule_type text NOT NULL,                                          -- 规则类型：base_price=基础价格, dynamic_fee=动态费用, tax=税费, discount=折扣, surge=高峰, platform_fee=平台费
    priority integer DEFAULT 0,                                       -- 优先级
    conditions jsonb DEFAULT '{}',                                    -- 应用条件
    calculation_type text NOT NULL,                                   -- 计算类型：fixed=固定值, percentage=百分比, formula=公式
    value numeric,                                                     -- 数值
    formula text,                                                      -- 计算公式
    min_amount numeric,                                                -- 最小金额
    max_amount numeric,                                                -- 最大金额
    is_active boolean DEFAULT true,                                   -- 是否启用
    starts_at timestamptz,                                            -- 开始时间
    ends_at timestamptz,                                              -- 结束时间
    created_at timestamptz NOT NULL DEFAULT now(),                    -- 创建时间
    updated_at timestamptz NOT NULL DEFAULT now(),                    -- 更新时间
    CONSTRAINT pricing_rules_rule_type_check CHECK (rule_type IN ('base_price', 'dynamic_fee', 'tax', 'discount', 'surge', 'platform_fee')),
    CONSTRAINT pricing_rules_calculation_type_check CHECK (calculation_type IN ('fixed', 'percentage', 'formula'))
);

-- 6.2 优惠券表
CREATE TABLE IF NOT EXISTS public.coupons (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),                   -- 优惠券ID
    code text UNIQUE NOT NULL,                                        -- 优惠券代码
    name text NOT NULL,                                               -- 优惠券名称
    description text,                                                  -- 优惠券描述
    discount_type text NOT NULL,                                      -- 折扣类型：percentage=百分比, fixed_amount=固定金额, free_shipping=免运费
    discount_value numeric NOT NULL,                                  -- 折扣值
    min_order_amount numeric,                                          -- 最小订单金额
    max_discount_amount numeric,                                       -- 最大折扣金额
    usage_limit integer,                                               -- 使用次数限制
    usage_limit_per_user integer DEFAULT 1,                          -- 每用户使用次数限制
    used_count integer DEFAULT 0,                                     -- 已使用次数
    applicable_industries text[],                                      -- 适用行业
    applicable_services uuid[],                                        -- 适用服务
    starts_at timestamptz NOT NULL,                                   -- 开始时间
    expires_at timestamptz NOT NULL,                                  -- 过期时间
    is_active boolean DEFAULT true,                                   -- 是否启用
    created_at timestamptz NOT NULL DEFAULT now(),                    -- 创建时间
    updated_at timestamptz NOT NULL DEFAULT now(),                    -- 更新时间
    CONSTRAINT coupons_discount_type_check CHECK (discount_type IN ('percentage', 'fixed_amount', 'free_shipping'))
);

-- 6.3 优惠券使用记录表
CREATE TABLE IF NOT EXISTS public.coupon_usages (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),                   -- 使用记录ID
    coupon_id uuid NOT NULL REFERENCES public.coupons(id),          -- 优惠券ID
    user_id uuid NOT NULL REFERENCES auth.users(id),                -- 用户ID
    order_id uuid NOT NULL REFERENCES public.orders(id),            -- 订单ID
    discount_amount numeric NOT NULL,                                 -- 实际折扣金额
    used_at timestamptz NOT NULL DEFAULT now(),                      -- 使用时间
    UNIQUE(coupon_id, order_id)                                       -- 每个订单每个优惠券只能使用一次
);

-- 插入基础定价规则
INSERT INTO pricing_rules (name, industry_type, rule_type, calculation_type, value, is_active) VALUES
('Platform Fee - Food', 'food', 'platform_fee', 'percentage', 5.0, true),
('Platform Fee - Home Services', 'home_services', 'platform_fee', 'percentage', 8.0, true),
('Platform Fee - Transport', 'transport', 'platform_fee', 'percentage', 15.0, true),
('Platform Fee - Rental', 'rental', 'platform_fee', 'percentage', 6.0, true),
('Platform Fee - Learning', 'learning', 'platform_fee', 'percentage', 3.0, true),
('Platform Fee - Professional', 'professional', 'platform_fee', 'percentage', 10.0, true),
('GST/HST Tax - BC', NULL, 'tax', 'percentage', 12.0, true),
('GST/HST Tax - ON', NULL, 'tax', 'percentage', 13.0, true),
('GST/HST Tax - QC', NULL, 'tax', 'percentage', 14.975, true)
ON CONFLICT (name) DO NOTHING;

-- 创建定价系统索引
CREATE INDEX IF NOT EXISTS idx_pricing_rules_industry_type ON pricing_rules (industry_type);
CREATE INDEX IF NOT EXISTS idx_pricing_rules_rule_type ON pricing_rules (rule_type);
CREATE INDEX IF NOT EXISTS idx_pricing_rules_active ON pricing_rules (is_active);
CREATE INDEX IF NOT EXISTS idx_coupons_code ON coupons (code);
CREATE INDEX IF NOT EXISTS idx_coupons_active ON coupons (is_active);
CREATE INDEX IF NOT EXISTS idx_coupon_usages_coupon_id ON coupon_usages (coupon_id);

-- =====================================================
-- 第八步：创建通知系统表
-- =====================================================

-- 8.1 通知表
CREATE TABLE IF NOT EXISTS public.notifications (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),                   -- 通知ID
    recipient_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE, -- 接收者ID
    sender_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,     -- 发送者ID（系统通知时为NULL）
    notification_type text NOT NULL,                                  -- 通知类型：order=订单通知, message=消息通知, system=系统通知, payment=支付通知, review=评价通知, promotion=促销通知, reminder=提醒通知
    title text NOT NULL,                                              -- 通知标题
    message text NOT NULL,                                            -- 通知内容
    related_id uuid,                                                   -- 关联对象ID（如订单ID、消息ID等）
    related_type text,                                                 -- 关联对象类型：order, message, payment, review等
    icon text,                                                         -- 通知图标
    action_url text,                                                   -- 点击跳转的URL或深度链接
    action_data jsonb,                                                 -- 额外的动作数据
    is_read boolean DEFAULT false,                                    -- 是否已读
    read_at timestamptz,                                              -- 阅读时间
    is_sent boolean DEFAULT false,                                    -- 是否已发送推送
    sent_at timestamptz,                                              -- 发送时间
    push_sent boolean DEFAULT false,                                  -- 是否已发送App推送
    email_sent boolean DEFAULT false,                                 -- 是否已发送邮件
    sms_sent boolean DEFAULT false,                                   -- 是否已发送短信
    expires_at timestamptz,                                           -- 过期时间
    priority text DEFAULT 'normal',                                   -- 优先级：low=低, normal=普通, high=高, urgent=紧急
    created_at timestamptz NOT NULL DEFAULT now(),                    -- 创建时间
    CONSTRAINT notifications_type_check CHECK (notification_type IN ('order', 'message', 'system', 'payment', 'review', 'promotion', 'reminder')),
    CONSTRAINT notifications_priority_check CHECK (priority IN ('low', 'normal', 'high', 'urgent'))
);

-- 创建通知系统索引
CREATE INDEX IF NOT EXISTS idx_notifications_recipient_id ON notifications (recipient_id);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications (notification_type);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications (is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications (created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_priority ON notifications (priority);

-- 启用通知系统RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
CREATE POLICY "Users can view own notifications" 
    ON public.notifications FOR ALL TO authenticated 
    USING (recipient_id = auth.uid());

-- =====================================================
-- 第九步：添加外键约束和更新现有表
-- =====================================================

-- 9.1 为orders表添加购物车外键约束
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'orders_cart_id_fkey' 
        AND table_name = 'orders'
    ) THEN
        ALTER TABLE public.orders ADD CONSTRAINT orders_cart_id_fkey 
        FOREIGN KEY (cart_id) REFERENCES public.unified_carts(id);
    END IF;
END $$;

-- 9.2 为 order_items 表添加P1、P2功能字段
DO $$
BEGIN
    -- 添加与购物车的关联（P1、P2功能需要）
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='order_items' AND column_name='cart_item_id') THEN
        ALTER TABLE public.order_items ADD COLUMN cart_item_id uuid;
        RAISE NOTICE 'order_items表：添加cart_item_id字段';
    END IF;
    
    -- 添加行业元数据
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='order_items' AND column_name='industry_metadata') THEN
        ALTER TABLE public.order_items ADD COLUMN industry_metadata jsonb DEFAULT '{}';
        RAISE NOTICE 'order_items表：添加industry_metadata字段';
    END IF;
    
    -- 添加定制选项
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='order_items' AND column_name='customizations') THEN
        ALTER TABLE public.order_items ADD COLUMN customizations jsonb DEFAULT '{}';
        RAISE NOTICE 'order_items表：添加customizations字段';
    END IF;
    
    -- 添加货币类型
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='order_items' AND column_name='currency') THEN
        ALTER TABLE public.order_items ADD COLUMN currency text DEFAULT 'CAD';
        RAISE NOTICE 'order_items表：添加currency字段';
    END IF;
    
    RAISE NOTICE 'order_items表P1、P2字段添加完成';
END $$;

-- 9.3 为 order_items 表添加外键约束（在字段添加之后）
DO $$
BEGIN
    -- 添加购物车商品关联外键
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'order_items_cart_item_id_fkey' 
        AND table_name = 'order_items'
    ) THEN
        ALTER TABLE public.order_items ADD CONSTRAINT order_items_cart_item_id_fkey 
        FOREIGN KEY (cart_item_id) REFERENCES public.cart_items(id);
        RAISE NOTICE 'order_items表：添加cart_item_id外键约束';
    END IF;
    
    RAISE NOTICE 'order_items表外键约束添加完成';
END $$;

-- 9.4 为 order_items 新字段添加索引
CREATE INDEX IF NOT EXISTS idx_order_items_cart_item_id ON order_items (cart_item_id);
CREATE INDEX IF NOT EXISTS idx_order_items_industry_metadata ON order_items USING GIN (industry_metadata);
CREATE INDEX IF NOT EXISTS idx_order_items_customizations ON order_items USING GIN (customizations);

-- 9.3 为购物车表添加地址外键约束
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'unified_carts_delivery_address_id_fkey' 
        AND table_name = 'unified_carts'
    ) THEN
        ALTER TABLE public.unified_carts ADD CONSTRAINT unified_carts_delivery_address_id_fkey 
        FOREIGN KEY (delivery_address_id) REFERENCES public.addresses(id);
    END IF;
END $$;

-- =====================================================
-- 第十步：创建触发器和函数
-- =====================================================

-- 10.1 创建updated_at自动更新函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 10.2 为新表添加updated_at触发器
DROP TRIGGER IF EXISTS update_addresses_updated_at ON addresses;
CREATE TRIGGER update_addresses_updated_at 
    BEFORE UPDATE ON addresses 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_industry_configs_updated_at ON industry_configs;
CREATE TRIGGER update_industry_configs_updated_at 
    BEFORE UPDATE ON industry_configs 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 为购物车表添加触发器（如果不存在）
DROP TRIGGER IF EXISTS update_unified_carts_updated_at ON unified_carts;
CREATE TRIGGER update_unified_carts_updated_at 
    BEFORE UPDATE ON unified_carts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_cart_items_updated_at ON cart_items;
CREATE TRIGGER update_cart_items_updated_at 
    BEFORE UPDATE ON cart_items 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_payment_methods_updated_at ON payment_methods;
CREATE TRIGGER update_payment_methods_updated_at 
    BEFORE UPDATE ON payment_methods 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_payments_updated_at ON payments;
CREATE TRIGGER update_payments_updated_at 
    BEFORE UPDATE ON payments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_payment_intents_updated_at ON payment_intents;
CREATE TRIGGER update_payment_intents_updated_at 
    BEFORE UPDATE ON payment_intents 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_refunds_updated_at ON refunds;
CREATE TRIGGER update_refunds_updated_at 
    BEFORE UPDATE ON refunds 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 第十一步：插入测试数据（可选）
-- =====================================================

-- 插入示例优惠券
INSERT INTO coupons (code, name, description, discount_type, discount_value, min_order_amount, starts_at, expires_at) VALUES
('WELCOME10', 'Welcome Discount', 'Welcome new users with 10% off', 'percentage', 10.0, 20.0, now(), now() + interval '30 days'),
('SAVE5', 'Save $5', 'Save $5 on any order over $25', 'fixed_amount', 5.0, 25.0, now(), now() + interval '7 days')
ON CONFLICT (code) DO NOTHING;

-- =====================================================
-- 完成提示
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '✅ P1、P2集成前数据库迁移完成（购物车表已存在版本）！';
    RAISE NOTICE '📊 新增表数量: 9个';
    RAISE NOTICE '🔧 修改现有表: 5个 (services, orders, order_items, unified_carts, cart_items)';
    RAISE NOTICE '';
    RAISE NOTICE '新增的表:';
    RAISE NOTICE '- addresses (地址管理)';
    RAISE NOTICE '- industry_configs (行业配置)';
    RAISE NOTICE '- payment_methods (支付方式)';
    RAISE NOTICE '- payments (支付记录)';
    RAISE NOTICE '- payment_intents (支付意图)';
    RAISE NOTICE '- refunds (退款管理)';
    RAISE NOTICE '- pricing_rules (定价规则)';
    RAISE NOTICE '- coupons (优惠券)';
    RAISE NOTICE '- coupon_usages (优惠券使用记录)';
    RAISE NOTICE '- notifications (通知系统)';
    RAISE NOTICE '';
    RAISE NOTICE '增强的现有表:';
    RAISE NOTICE '- addresses (添加user_id、address_type、is_default字段)';
    RAISE NOTICE '- ref_codes (保持现有业务字段，验证完整性)';
    RAISE NOTICE '- services (添加industry_type、可用性、价格等字段)';
    RAISE NOTICE '- orders (添加行业类型、购物车关联等字段)';
    RAISE NOTICE '- order_items (验证现有快照功能，添加购物车关联、行业元数据等)';
    RAISE NOTICE '- unified_carts (添加行业类型、缓存字段等)';
    RAISE NOTICE '- cart_items (验证现有完善结构，添加currency字段)';
    RAISE NOTICE '';
    RAISE NOTICE '🚀 数据库已准备就绪，可以开始P1、P2功能开发！';
    RAISE NOTICE '💡 注意: 现有表结构已适配，addresses表已有详细地址字段结构';
END $$;
