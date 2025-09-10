-- ========================================
-- Phase 1: 餐饮美食行业支付系统数据库迁移脚本
-- 基于现有数据库结构的安全扩展
-- ========================================

BEGIN;

-- ========================================
-- 1. 扩展现有orders表以支持支付功能
-- ========================================

-- 添加支付相关字段到现有orders表
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS payment_intent_id VARCHAR(200);
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS payment_method_snapshot JSONB DEFAULT '{}';
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS pricing_breakdown JSONB DEFAULT '{}';

-- 确保industry_metadata字段存在（用于餐饮特定数据）
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS industry_metadata JSONB DEFAULT '{}';

-- 添加餐饮行业特定字段
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS delivery_address JSONB;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS delivery_instructions TEXT;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS estimated_delivery_time TIMESTAMPTZ;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS delivery_status VARCHAR(30) DEFAULT 'pending';

-- 添加索引优化查询性能
CREATE INDEX IF NOT EXISTS idx_orders_payment_intent_id ON public.orders(payment_intent_id);
CREATE INDEX IF NOT EXISTS idx_orders_delivery_status ON public.orders(delivery_status);
CREATE INDEX IF NOT EXISTS idx_orders_estimated_delivery_time ON public.orders(estimated_delivery_time);

-- ========================================
-- 2. 创建支付记录表
-- ========================================

CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id VARCHAR(100) UNIQUE NOT NULL, -- 外部支付系统ID
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    
    -- 支付基本信息
    payment_type VARCHAR(20) NOT NULL DEFAULT 'charge', -- 'charge', 'refund', 'transfer'
    payment_method VARCHAR(30) NOT NULL, -- 'credit_card', 'debit_card', 'paypal'
    payment_provider VARCHAR(30) NOT NULL DEFAULT 'stripe', -- 'stripe', 'square', 'paypal'
    
    -- 金额信息
    currency VARCHAR(3) NOT NULL DEFAULT 'CAD',
    amount DECIMAL(12,2) NOT NULL,
    processing_fee DECIMAL(12,2) DEFAULT 0,
    net_amount DECIMAL(12,2) NOT NULL,
    
    -- 状态管理
    status VARCHAR(20) NOT NULL DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'failed', 'refunded'
    failure_reason TEXT,
    
    -- 支付方式详情（加密存储敏感信息的引用）
    payment_method_details JSONB DEFAULT '{}',
    
    -- 外部系统引用
    external_transaction_id VARCHAR(200),
    external_reference VARCHAR(200),
    provider_response JSONB DEFAULT '{}',
    
    -- 审计信息
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMPTZ
);

-- 支付表索引
CREATE INDEX idx_payments_order_id ON public.payments(order_id);
CREATE INDEX idx_payments_status ON public.payments(status);
CREATE INDEX idx_payments_payment_type ON public.payments(payment_type);
CREATE INDEX idx_payments_payment_provider ON public.payments(payment_provider);
CREATE INDEX idx_payments_created_at ON public.payments(created_at);
CREATE INDEX idx_payments_external_transaction_id ON public.payments(external_transaction_id);

-- ========================================
-- 3. 创建支付方式管理表
-- ========================================

CREATE TABLE IF NOT EXISTS public.payment_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- 支付提供商信息
    payment_provider VARCHAR(30) NOT NULL DEFAULT 'stripe',
    external_token_id VARCHAR(200) NOT NULL, -- 支付提供商的令牌ID
    
    -- 卡片信息（非敏感）
    card_last4 VARCHAR(4),
    card_brand VARCHAR(20), -- 'visa', 'mastercard', 'amex'
    card_exp_month INTEGER,
    card_exp_year INTEGER,
    card_holder_name VARCHAR(100),
    
    -- 状态管理
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- 审计信息
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 支付方式表索引
CREATE INDEX idx_payment_methods_user_id ON public.payment_methods(user_id);
CREATE INDEX idx_payment_methods_is_default ON public.payment_methods(is_default);
CREATE INDEX idx_payment_methods_is_active ON public.payment_methods(is_active);

-- ========================================
-- 4. 创建餐饮行业定价规则表
-- ========================================

CREATE TABLE IF NOT EXISTS public.food_pricing_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    
    -- 定价规则类型
    rule_type VARCHAR(30) NOT NULL, -- 'delivery_fee', 'packaging_fee', 'peak_surcharge', 'distance_based'
    rule_name VARCHAR(100) NOT NULL,
    
    -- 规则配置
    rule_config JSONB NOT NULL, -- 存储规则的具体配置参数
    
    -- 适用条件
    min_order_amount DECIMAL(10,2),
    max_order_amount DECIMAL(10,2),
    applicable_areas TEXT[], -- 适用的邮政编码或区域
    time_restrictions JSONB, -- 时间限制配置
    
    -- 状态管理
    is_active BOOLEAN DEFAULT TRUE,
    priority INTEGER DEFAULT 0, -- 规则优先级
    
    -- 审计信息
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 餐饮定价规则表索引
CREATE INDEX idx_food_pricing_rules_service_id ON public.food_pricing_rules(service_id);
CREATE INDEX idx_food_pricing_rules_rule_type ON public.food_pricing_rules(rule_type);
CREATE INDEX idx_food_pricing_rules_is_active ON public.food_pricing_rules(is_active);
CREATE INDEX idx_food_pricing_rules_priority ON public.food_pricing_rules(priority);

-- ========================================
-- 5. 创建优惠券表（餐饮专用）
-- ========================================

CREATE TABLE IF NOT EXISTS public.food_coupons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) UNIQUE NOT NULL,
    
    -- 优惠券基本信息
    title JSONB NOT NULL, -- 多语言标题
    description JSONB,
    
    -- 折扣配置
    discount_type VARCHAR(20) NOT NULL, -- 'percentage', 'fixed_amount', 'free_delivery'
    discount_value DECIMAL(10,2) NOT NULL,
    
    -- 使用条件
    min_order_amount DECIMAL(10,2),
    max_discount_amount DECIMAL(10,2),
    applicable_services UUID[], -- 适用的服务ID数组
    applicable_categories BIGINT[], -- 适用的分类ID数组
    
    -- 有效期管理
    valid_from TIMESTAMPTZ NOT NULL,
    valid_until TIMESTAMPTZ NOT NULL,
    
    -- 使用限制
    usage_limit INTEGER, -- 总使用次数限制
    usage_limit_per_user INTEGER DEFAULT 1, -- 每用户使用次数限制
    used_count INTEGER DEFAULT 0,
    
    -- 状态管理
    is_active BOOLEAN DEFAULT TRUE,
    
    -- 审计信息
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 优惠券表索引
CREATE INDEX idx_food_coupons_code ON public.food_coupons(code);
CREATE INDEX idx_food_coupons_is_active ON public.food_coupons(is_active);
CREATE INDEX idx_food_coupons_valid_from ON public.food_coupons(valid_from);
CREATE INDEX idx_food_coupons_valid_until ON public.food_coupons(valid_until);

-- ========================================
-- 6. 创建优惠券使用记录表
-- ========================================

CREATE TABLE IF NOT EXISTS public.food_coupon_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    coupon_id UUID NOT NULL REFERENCES public.food_coupons(id) ON DELETE CASCADE,
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- 使用详情
    original_amount DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL,
    final_amount DECIMAL(10,2) NOT NULL,
    
    -- 审计信息
    used_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- 确保每个订单只能使用一张优惠券
    UNIQUE(order_id)
);

-- 优惠券使用记录表索引
CREATE INDEX idx_food_coupon_usage_coupon_id ON public.food_coupon_usage(coupon_id);
CREATE INDEX idx_food_coupon_usage_user_id ON public.food_coupon_usage(user_id);
CREATE INDEX idx_food_coupon_usage_used_at ON public.food_coupon_usage(used_at);

-- ========================================
-- 7. 扩展service_details表以支持餐饮特性
-- ========================================

-- 为餐饮服务添加特定字段
ALTER TABLE public.service_details ADD COLUMN IF NOT EXISTS food_category VARCHAR(50); -- 'chinese', 'korean', 'western', 'dessert'
ALTER TABLE public.service_details ADD COLUMN IF NOT EXISTS cuisine_type VARCHAR(50); -- 'sichuan', 'cantonese', 'korean_bbq'
ALTER TABLE public.service_details ADD COLUMN IF NOT EXISTS spice_level INTEGER DEFAULT 0; -- 0-5 辣度等级
ALTER TABLE public.service_details ADD COLUMN IF NOT EXISTS allergens TEXT[]; -- 过敏原列表
ALTER TABLE public.service_details ADD COLUMN IF NOT EXISTS dietary_tags TEXT[]; -- 'vegetarian', 'vegan', 'halal', 'gluten_free'
ALTER TABLE public.service_details ADD COLUMN IF NOT EXISTS preparation_time INTEGER; -- 制作时间（分钟）
ALTER TABLE public.service_details ADD COLUMN IF NOT EXISTS serving_size VARCHAR(20); -- '1人份', '2-3人份'

-- 餐饮特性索引
CREATE INDEX IF NOT EXISTS idx_service_details_food_category ON public.service_details(food_category);
CREATE INDEX IF NOT EXISTS idx_service_details_cuisine_type ON public.service_details(cuisine_type);
CREATE INDEX IF NOT EXISTS idx_service_details_spice_level ON public.service_details(spice_level);
CREATE INDEX IF NOT EXISTS idx_service_details_allergens ON public.service_details USING GIN(allergens);
CREATE INDEX IF NOT EXISTS idx_service_details_dietary_tags ON public.service_details USING GIN(dietary_tags);

-- ========================================
-- 8. 创建配送区域和费用表
-- ========================================

CREATE TABLE IF NOT EXISTS public.food_delivery_zones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    
    -- 配送区域定义
    zone_name VARCHAR(100) NOT NULL,
    zone_type VARCHAR(20) NOT NULL, -- 'postal_code', 'radius', 'polygon'
    zone_config JSONB NOT NULL, -- 区域配置（邮政编码列表、半径、多边形坐标等）
    
    -- 配送费用
    base_delivery_fee DECIMAL(10,2) NOT NULL DEFAULT 0,
    free_delivery_threshold DECIMAL(10,2), -- 免配送费门槛
    peak_hour_surcharge DECIMAL(10,2) DEFAULT 0,
    
    -- 配送时间
    estimated_delivery_time INTEGER NOT NULL, -- 预计配送时间（分钟）
    max_delivery_time INTEGER, -- 最大配送时间
    
    -- 状态管理
    is_active BOOLEAN DEFAULT TRUE,
    priority INTEGER DEFAULT 0,
    
    -- 审计信息
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 配送区域表索引
CREATE INDEX idx_food_delivery_zones_service_id ON public.food_delivery_zones(service_id);
CREATE INDEX idx_food_delivery_zones_zone_type ON public.food_delivery_zones(zone_type);
CREATE INDEX idx_food_delivery_zones_is_active ON public.food_delivery_zones(is_active);

-- ========================================
-- 9. 插入餐饮行业基础配置数据
-- ========================================

-- 插入基础定价规则示例
INSERT INTO public.food_pricing_rules (service_id, rule_type, rule_name, rule_config, is_active) 
SELECT 
    s.id,
    'delivery_fee',
    'Standard Delivery Fee',
    '{"base_fee": 3.50, "free_threshold": 30.00}',
    true
FROM public.services s 
WHERE s.category_level1_id = (
    SELECT id FROM public.ref_codes WHERE code = 'DINING' AND type_code = 'SERVICE_TYPE'
)
ON CONFLICT DO NOTHING;

-- 插入包装费规则
INSERT INTO public.food_pricing_rules (service_id, rule_type, rule_name, rule_config, is_active)
SELECT 
    s.id,
    'packaging_fee',
    'Eco-friendly Packaging',
    '{"fee_per_item": 0.50, "max_fee": 3.00}',
    true
FROM public.services s 
WHERE s.category_level1_id = (
    SELECT id FROM public.ref_codes WHERE code = 'DINING' AND type_code = 'SERVICE_TYPE'
)
ON CONFLICT DO NOTHING;

-- 插入示例优惠券
INSERT INTO public.food_coupons (code, title, description, discount_type, discount_value, min_order_amount, valid_from, valid_until, usage_limit, is_active)
VALUES 
('WELCOME10', 
 '{"en": "Welcome 10% Off", "zh": "新用户10%折扣"}',
 '{"en": "Get 10% off your first order", "zh": "首次订单享受10%折扣"}',
 'percentage', 
 10.00, 
 20.00, 
 NOW(), 
 NOW() + INTERVAL '30 days',
 1000,
 true),
('FREEDELIV', 
 '{"en": "Free Delivery", "zh": "免费配送"}',
 '{"en": "Free delivery on orders over $25", "zh": "满$25免配送费"}',
 'free_delivery', 
 0.00, 
 25.00, 
 NOW(), 
 NOW() + INTERVAL '7 days',
 500,
 true)
ON CONFLICT (code) DO NOTHING;

-- ========================================
-- 10. 创建触发器和函数
-- ========================================

-- 创建更新updated_at的函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为新表添加updated_at自动更新触发器
CREATE TRIGGER update_payments_updated_at
    BEFORE UPDATE ON public.payments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payment_methods_updated_at
    BEFORE UPDATE ON public.payment_methods
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_food_pricing_rules_updated_at
    BEFORE UPDATE ON public.food_pricing_rules
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_food_coupons_updated_at
    BEFORE UPDATE ON public.food_coupons
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_food_delivery_zones_updated_at
    BEFORE UPDATE ON public.food_delivery_zones
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 11. 数据完整性检查
-- ========================================

-- 验证迁移是否成功
DO $$
DECLARE
    table_count INTEGER;
BEGIN
    -- 检查新表是否创建成功
    SELECT COUNT(*) INTO table_count 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name IN ('payments', 'payment_methods', 'food_pricing_rules', 'food_coupons', 'food_coupon_usage', 'food_delivery_zones');
    
    IF table_count != 6 THEN
        RAISE EXCEPTION '新表创建不完整，期望6个表，实际创建%个', table_count;
    END IF;
    
    -- 检查orders表字段是否添加成功
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'orders' 
        AND column_name = 'payment_intent_id'
        AND table_schema = 'public'
    ) THEN
        RAISE EXCEPTION 'orders表字段扩展失败';
    END IF;
    
    RAISE NOTICE '✅ 餐饮美食行业支付系统数据库迁移完成';
END $$;

COMMIT;

-- ========================================
-- 迁移完成日志
-- ========================================
INSERT INTO public.schema_migrations (version, description, applied_at) 
VALUES ('20240801_001', 'Phase 1: Food Industry Payment System Migration', NOW())
ON CONFLICT (version) DO NOTHING;
