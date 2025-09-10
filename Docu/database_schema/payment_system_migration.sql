-- =====================================================
-- 金豆平台支付系统数据库迁移脚本
-- 
-- 目标：扩展现有表结构以支持通用支付订单系统
-- 兼容性：保证现有数据100%完整性
-- =====================================================

-- =====================================================
-- 第一部分：扩展现有orders表
-- =====================================================

-- 添加支付相关字段到orders表
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS payment_intent_id VARCHAR(200),
ADD COLUMN IF NOT EXISTS payment_status VARCHAR(50) DEFAULT 'pending' CHECK (payment_status IN (
  'pending', 'processing', 'paid', 'failed', 'canceled', 'refunded', 'partially_refunded', 'authorized'
)),
ADD COLUMN IF NOT EXISTS industry_metadata JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS pricing_breakdown JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS total_amount DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS currency VARCHAR(3) DEFAULT 'CAD',
ADD COLUMN IF NOT EXISTS fulfillment_mode VARCHAR(50) CHECK (fulfillment_mode IN (
  'delivery', 'pickup', 'on_site', 'online', 'hybrid'
));

-- 为现有数据设置默认值
UPDATE orders 
SET 
  industry_metadata = '{"legacy": true, "migrated_at": "' || NOW() || '"}',
  pricing_breakdown = '{"base_amount": 0, "fees": [], "discounts": [], "taxes": []}'
WHERE industry_metadata = '{}' OR industry_metadata IS NULL;

-- =====================================================
-- 第二部分：创建支付相关表
-- =====================================================

-- 支付意图表
CREATE TABLE IF NOT EXISTS payment_intents (
  id VARCHAR(200) PRIMARY KEY, -- Stripe PaymentIntent ID
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  customer_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(3) NOT NULL DEFAULT 'CAD',
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  client_secret TEXT,
  stripe_payment_intent_id VARCHAR(200),
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 支付记录表
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  payment_intent_id VARCHAR(200) REFERENCES payment_intents(id),
  customer_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(3) NOT NULL DEFAULT 'CAD',
  status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN (
    'pending', 'processing', 'paid', 'failed', 'canceled', 'refunded', 'partially_refunded', 'authorized'
  )),
  provider VARCHAR(50) NOT NULL DEFAULT 'Stripe',
  external_transaction_id VARCHAR(200),
  payment_method_snapshot JSONB NOT NULL,
  metadata JSONB DEFAULT '{}',
  processed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 支付方式表
CREATE TABLE IF NOT EXISTS payment_methods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  provider VARCHAR(50) NOT NULL DEFAULT 'Stripe',
  external_payment_method_id VARCHAR(200) NOT NULL,
  type VARCHAR(50) NOT NULL CHECK (type IN ('card', 'bank_account', 'digital_wallet', 'cash', 'other')),
  card_last_four VARCHAR(4),
  card_brand VARCHAR(20),
  card_exp_month INTEGER,
  card_exp_year INTEGER,
  is_default BOOLEAN DEFAULT FALSE,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  UNIQUE(customer_id, external_payment_method_id)
);

-- 退款记录表
CREATE TABLE IF NOT EXISTS refunds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(3) NOT NULL DEFAULT 'CAD',
  status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN (
    'pending', 'completed', 'failed', 'canceled'
  )),
  provider VARCHAR(50) NOT NULL DEFAULT 'Stripe',
  external_refund_id VARCHAR(200),
  reason VARCHAR(255),
  metadata JSONB DEFAULT '{}',
  processed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 定价规则表
CREATE TABLE IF NOT EXISTS pricing_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  description TEXT,
  industry_type VARCHAR(50) NOT NULL CHECK (industry_type IN (
    'Food', 'HomeServices', 'Transportation', 'RentalShare', 'Learning', 'ProGigs', 'General'
  )),
  rule_type VARCHAR(50) NOT NULL CHECK (rule_type IN (
    'base_price', 'percentage_fee', 'fixed_fee', 'tax', 'discount', 'surge_pricing'
  )),
  calculation_method VARCHAR(50) NOT NULL CHECK (calculation_method IN (
    'fixed', 'percentage', 'tiered', 'distance_based', 'time_based', 'dynamic'
  )),
  value DECIMAL(10,4) NOT NULL,
  conditions JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT TRUE,
  valid_from TIMESTAMP WITH TIME ZONE,
  valid_until TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 优惠券表
CREATE TABLE IF NOT EXISTS coupons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  type VARCHAR(50) NOT NULL CHECK (type IN ('percentage', 'fixed_amount', 'free_shipping', 'buy_x_get_y')),
  value DECIMAL(10,4) NOT NULL,
  minimum_order_amount DECIMAL(10,2),
  maximum_discount_amount DECIMAL(10,2),
  usage_limit INTEGER,
  usage_count INTEGER DEFAULT 0,
  per_customer_limit INTEGER DEFAULT 1,
  industry_restrictions TEXT[], -- Array of industry types
  is_active BOOLEAN DEFAULT TRUE,
  valid_from TIMESTAMP WITH TIME ZONE NOT NULL,
  valid_until TIMESTAMP WITH TIME ZONE NOT NULL,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 优惠券使用记录表
CREATE TABLE IF NOT EXISTS coupon_usages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coupon_id UUID NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
  customer_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  discount_amount DECIMAL(10,2) NOT NULL,
  used_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  UNIQUE(coupon_id, order_id)
);

-- =====================================================
-- 第三部分：扩展user_profiles表
-- =====================================================

-- 添加Stripe客户ID字段
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS stripe_customer_id VARCHAR(200);

-- =====================================================
-- 第四部分：创建索引以优化性能
-- =====================================================

-- orders表索引
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON orders(payment_status);
CREATE INDEX IF NOT EXISTS idx_orders_payment_intent_id ON orders(payment_intent_id);
CREATE INDEX IF NOT EXISTS idx_orders_industry_metadata ON orders USING GIN(industry_metadata);
CREATE INDEX IF NOT EXISTS idx_orders_pricing_breakdown ON orders USING GIN(pricing_breakdown);

-- payments表索引
CREATE INDEX IF NOT EXISTS idx_payments_order_id ON payments(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_customer_id ON payments(customer_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_provider ON payments(provider);
CREATE INDEX IF NOT EXISTS idx_payments_external_transaction_id ON payments(external_transaction_id);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON payments(created_at);

-- payment_intents表索引
CREATE INDEX IF NOT EXISTS idx_payment_intents_order_id ON payment_intents(order_id);
CREATE INDEX IF NOT EXISTS idx_payment_intents_customer_id ON payment_intents(customer_id);
CREATE INDEX IF NOT EXISTS idx_payment_intents_status ON payment_intents(status);
CREATE INDEX IF NOT EXISTS idx_payment_intents_stripe_id ON payment_intents(stripe_payment_intent_id);

-- payment_methods表索引
CREATE INDEX IF NOT EXISTS idx_payment_methods_customer_id ON payment_methods(customer_id);
CREATE INDEX IF NOT EXISTS idx_payment_methods_provider ON payment_methods(provider);
CREATE INDEX IF NOT EXISTS idx_payment_methods_is_default ON payment_methods(customer_id, is_default) WHERE is_default = TRUE;

-- refunds表索引
CREATE INDEX IF NOT EXISTS idx_refunds_payment_id ON refunds(payment_id);
CREATE INDEX IF NOT EXISTS idx_refunds_order_id ON refunds(order_id);
CREATE INDEX IF NOT EXISTS idx_refunds_status ON refunds(status);

-- pricing_rules表索引
CREATE INDEX IF NOT EXISTS idx_pricing_rules_industry_type ON pricing_rules(industry_type);
CREATE INDEX IF NOT EXISTS idx_pricing_rules_rule_type ON pricing_rules(rule_type);
CREATE INDEX IF NOT EXISTS idx_pricing_rules_is_active ON pricing_rules(is_active);
CREATE INDEX IF NOT EXISTS idx_pricing_rules_conditions ON pricing_rules USING GIN(conditions);

-- coupons表索引
CREATE INDEX IF NOT EXISTS idx_coupons_code ON coupons(code);
CREATE INDEX IF NOT EXISTS idx_coupons_is_active ON coupons(is_active);
CREATE INDEX IF NOT EXISTS idx_coupons_valid_dates ON coupons(valid_from, valid_until);

-- coupon_usages表索引
CREATE INDEX IF NOT EXISTS idx_coupon_usages_coupon_id ON coupon_usages(coupon_id);
CREATE INDEX IF NOT EXISTS idx_coupon_usages_customer_id ON coupon_usages(customer_id);
CREATE INDEX IF NOT EXISTS idx_coupon_usages_order_id ON coupon_usages(order_id);

-- user_profiles表索引
CREATE INDEX IF NOT EXISTS idx_user_profiles_stripe_customer_id ON user_profiles(stripe_customer_id);

-- =====================================================
-- 第五部分：创建触发器以自动更新时间戳
-- =====================================================

-- 通用的更新时间戳函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为相关表创建触发器
CREATE TRIGGER update_payment_intents_updated_at BEFORE UPDATE ON payment_intents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payment_methods_updated_at BEFORE UPDATE ON payment_methods FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_refunds_updated_at BEFORE UPDATE ON refunds FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_pricing_rules_updated_at BEFORE UPDATE ON pricing_rules FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_coupons_updated_at BEFORE UPDATE ON coupons FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 第六部分：插入基础定价规则数据
-- =====================================================

-- 插入基础定价规则
INSERT INTO pricing_rules (name, description, industry_type, rule_type, calculation_method, value, conditions, is_active) VALUES
-- 餐饮行业规则
('Food Platform Fee', '餐饮平台服务费', 'Food', 'percentage_fee', 'percentage', 5.0, '{"applies_to": "base_amount"}', TRUE),
('Food Delivery Fee', '配送费', 'Food', 'fixed_fee', 'distance_based', 3.00, '{"base_distance": 5, "additional_per_km": 0.5}', TRUE),
('Food Packaging Fee', '包装费', 'Food', 'fixed_fee', 'fixed', 1.50, '{"per_order": true}', TRUE),
('Food GST/HST', '餐饮税费', 'Food', 'tax', 'percentage', 13.0, '{"tax_type": "HST", "region": "Ontario"}', TRUE),

-- 家居服务规则
('Home Platform Fee', '家居服务平台费', 'HomeServices', 'percentage_fee', 'percentage', 8.0, '{"applies_to": "base_amount"}', TRUE),
('Home Transportation Fee', '上门费', 'HomeServices', 'fixed_fee', 'distance_based', 15.00, '{"base_distance": 10, "additional_per_km": 1.0}', TRUE),
('Home Materials Fee', '材料费', 'HomeServices', 'percentage_fee', 'percentage', 10.0, '{"applies_to": "materials_cost"}', TRUE),
('Home GST/HST', '家居服务税费', 'HomeServices', 'tax', 'percentage', 13.0, '{"tax_type": "HST", "region": "Ontario"}', TRUE),

-- 出行交通规则
('Transport Platform Fee', '出行平台服务费', 'Transportation', 'percentage_fee', 'percentage', 15.0, '{"applies_to": "base_amount"}', TRUE),
('Transport Base Fare', '起步价', 'Transportation', 'fixed_fee', 'fixed', 4.00, '{"base_distance": 2}', TRUE),
('Transport Distance Fee', '里程费', 'Transportation', 'fixed_fee', 'distance_based', 1.20, '{"per_km": true}', TRUE),
('Transport Time Fee', '时间费', 'Transportation', 'fixed_fee', 'time_based', 0.30, '{"per_minute": true}', TRUE),
('Transport Surge Pricing', '高峰期加价', 'Transportation', 'surge_pricing', 'percentage', 50.0, '{"peak_hours": ["07:00-09:00", "17:00-19:00"]}', TRUE),

-- 租赁共享规则
('Rental Platform Fee', '租赁平台服务费', 'RentalShare', 'percentage_fee', 'percentage', 10.0, '{"applies_to": "base_amount"}', TRUE),
('Rental Cleaning Fee', '清洁费', 'RentalShare', 'fixed_fee', 'fixed', 25.00, '{"per_rental": true}', TRUE),
('Rental Insurance Fee', '保险费', 'RentalShare', 'percentage_fee', 'percentage', 3.0, '{"applies_to": "rental_value"}', TRUE),

-- 学习成长规则
('Learning Platform Fee', '学习平台服务费', 'Learning', 'percentage_fee', 'percentage', 12.0, '{"applies_to": "base_amount"}', TRUE),
('Learning Processing Fee', '处理费', 'Learning', 'fixed_fee', 'fixed', 2.00, '{"per_course": true}', TRUE),

-- 专业速帮规则
('Professional Platform Fee', '专业服务平台费', 'ProGigs', 'percentage_fee', 'percentage', 20.0, '{"applies_to": "base_amount"}', TRUE),
('Professional Rush Fee', '加急费', 'ProGigs', 'percentage_fee', 'percentage', 25.0, '{"rush_order": true}', TRUE);

-- =====================================================
-- 第七部分：插入示例优惠券
-- =====================================================

-- 插入示例优惠券
INSERT INTO coupons (code, name, description, type, value, minimum_order_amount, maximum_discount_amount, usage_limit, industry_restrictions, valid_from, valid_until) VALUES
('WELCOME10', '新用户10%折扣', '新用户首单享受10%折扣', 'percentage', 10.0, 20.00, 50.00, 1000, NULL, NOW(), NOW() + INTERVAL '30 days'),
('FOOD5OFF', '餐饮5元优惠', '餐饮订单满30元减5元', 'fixed_amount', 5.0, 30.00, NULL, 500, '{Food}', NOW(), NOW() + INTERVAL '15 days'),
('FREESHIP', '免配送费', '免费配送', 'free_shipping', 0.0, 15.00, 10.00, 200, '{Food}', NOW(), NOW() + INTERVAL '7 days'),
('HOME20', '家居服务20%折扣', '家居服务享受20%折扣', 'percentage', 20.0, 100.00, 100.00, 100, '{HomeServices}', NOW(), NOW() + INTERVAL '60 days');

-- =====================================================
-- 第八部分：数据完整性验证查询
-- =====================================================

-- 这些查询可以用于验证迁移是否成功
/*
-- 验证orders表扩展
SELECT COUNT(*) as total_orders, 
       COUNT(payment_status) as orders_with_payment_status,
       COUNT(industry_metadata) as orders_with_metadata
FROM orders;

-- 验证新表创建
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name IN ('payment_intents', 'payments', 'payment_methods', 'refunds', 'pricing_rules', 'coupons')
ORDER BY table_name, ordinal_position;

-- 验证索引创建
SELECT schemaname, tablename, indexname, indexdef 
FROM pg_indexes 
WHERE tablename IN ('orders', 'payments', 'payment_intents', 'payment_methods')
ORDER BY tablename, indexname;

-- 验证定价规则插入
SELECT industry_type, COUNT(*) as rule_count
FROM pricing_rules
GROUP BY industry_type;

-- 验证优惠券插入
SELECT code, name, type, valid_from, valid_until
FROM coupons
WHERE is_active = TRUE;
*/

-- =====================================================
-- 迁移完成
-- =====================================================
-- 此迁移脚本已完成以下任务：
-- 1. ✅ 扩展orders表支持支付和行业元数据
-- 2. ✅ 创建完整的支付相关表结构
-- 3. ✅ 创建性能优化索引
-- 4. ✅ 插入基础定价规则和优惠券数据
-- 5. ✅ 保证现有数据100%兼容性
-- 6. ✅ 支持所有六个行业的差异化定价
-- =====================================================
