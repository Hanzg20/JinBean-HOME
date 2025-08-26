-- =====================================================
-- JinBean Platform - Simple Test Data Script
-- 使用变量管理UUID引用的简化版本
-- =====================================================

-- 清理现有测试数据（可选）
-- DELETE FROM service_details WHERE service_id IN (SELECT id FROM services WHERE title->>'en' LIKE '%Test%');
-- DELETE FROM services WHERE title->>'en' LIKE '%Test%';
-- DELETE FROM provider_profiles WHERE email LIKE '%@test.com';

-- =====================================================
-- 1. 创建必要的ref_codes数据
-- =====================================================

INSERT INTO ref_codes (type_code, code, chinese_name, english_name, parent_id, level, description, sort_order, status, created_at, updated_at) VALUES
-- 一级服务类别
('SERVICE_TYPE', '1010000', '餐饮服务', 'Food & Beverage', NULL, 1, '餐饮相关服务', 1, 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('SERVICE_TYPE', '1020000', '家政服务', 'Home Services', NULL, 1, '家庭相关服务', 2, 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('SERVICE_TYPE', '1060000', '技术服务', 'Technical Services', NULL, 1, '技术相关服务', 6, 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- 二级服务类别
('SERVICE_TYPE', '1010100', '餐厅', 'Restaurant', 1010000, 2, '餐厅服务', 1, 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('SERVICE_TYPE', '1020100', '清洁服务', 'Cleaning Services', 1020000, 2, '清洁相关服务', 1, 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('SERVICE_TYPE', '1060100', 'IT支持', 'IT Support', 1060000, 2, 'IT技术支持', 1, 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (type_code, code) DO NOTHING;

-- =====================================================
-- 2. 创建服务提供商数据
-- =====================================================

INSERT INTO provider_profiles (id, display_name, provider_type, email, phone, status, created_at, updated_at) VALUES
(
    gen_random_uuid(),
    '{"en": "Test Italian Restaurant", "zh": "测试意大利餐厅", "fr": "Restaurant Italien Test"}',
    'business',
    'test@italian.com',
    '+1-416-555-0101',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Test Cleaning Service", "zh": "测试清洁服务", "fr": "Service de Nettoyage Test"}',
    'business',
    'test@cleaning.com',
    '+1-416-555-0102',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Test IT Service", "zh": "测试IT服务", "fr": "Service IT Test"}',
    'business',
    'test@it.com',
    '+1-416-555-0103',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- =====================================================
-- 3. 创建services主表数据
-- =====================================================

INSERT INTO services (id, title, description, category_level1_id, category_level2_id, provider_id, status, average_rating, review_count, latitude, longitude, service_delivery_method, created_at, updated_at) VALUES
(
    gen_random_uuid(),
    '{"en": "Test Italian Restaurant", "zh": "测试意大利餐厅", "fr": "Restaurant Italien Test"}',
    '{"en": "Test Italian cuisine service", "zh": "测试意大利美食服务", "fr": "Service de cuisine italienne test"}',
    1010000,  -- 餐饮服务
    1010100,  -- 餐厅
    (SELECT id FROM provider_profiles WHERE email = 'test@italian.com'),
    'active',
    4.8,
    156,
    43.6532,
    -79.3832,
    'on_site',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Test Home Cleaning", "zh": "测试家庭清洁", "fr": "Nettoyage à Domicile Test"}',
    '{"en": "Test home cleaning service", "zh": "测试家庭清洁服务", "fr": "Service de nettoyage à domicile test"}',
    1020000,  -- 家政服务
    1020100,  -- 清洁服务
    (SELECT id FROM provider_profiles WHERE email = 'test@cleaning.com'),
    'active',
    4.9,
    234,
    43.6520,
    -79.3845,
    'on_site',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Test IT Support", "zh": "测试IT支持", "fr": "Support IT Test"}',
    '{"en": "Test IT support service", "zh": "测试IT支持服务", "fr": "Service de support IT test"}',
    1060000,  -- 技术服务
    1060100,  -- IT支持
    (SELECT id FROM provider_profiles WHERE email = 'test@it.com'),
    'active',
    4.9,
    189,
    43.6535,
    -79.3815,
    'hybrid',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- =====================================================
-- 4. 创建service_details详情数据
-- =====================================================

INSERT INTO service_details (service_id, pricing_type, price, currency, duration_type, tags, service_details_json, created_at, updated_at) VALUES
-- 餐厅服务详情
(
    (SELECT id FROM services WHERE title->>'en' = 'Test Italian Restaurant'),
    'fixed_price',
    0,
    'CAD',
    'fixed',
    ARRAY['test', 'italian', 'restaurant'],
    '{"test": true, "cuisine_type": "italian"}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 清洁服务详情
(
    (SELECT id FROM services WHERE title->>'en' = 'Test Home Cleaning'),
    'fixed_price',
    120.00,
    'CAD',
    'hours',
    ARRAY['test', 'cleaning', 'professional'],
    '{"test": true, "service_type": "cleaning"}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- IT服务详情
(
    (SELECT id FROM services WHERE title->>'en' = 'Test IT Support'),
    'hourly',
    85.00,
    'CAD',
    'hours',
    ARRAY['test', 'it_support', 'consulting'],
    '{"test": true, "service_type": "it_support"}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- =====================================================
-- 5. 数据验证查询
-- =====================================================

-- 验证ref_codes数据
SELECT 'Ref Codes Check' as check_type, COUNT(*) as total_codes FROM ref_codes WHERE type_code = 'SERVICE_TYPE';

-- 验证数据完整性
SELECT 'Data Integrity Check' as check_type, COUNT(*) as total_records FROM service_details;

-- 检查各服务详情
SELECT 
    'Service Details' as check_type,
    s.title->>'en' as service_name,
    sd.pricing_type,
    sd.price,
    sd.currency
FROM services s
JOIN service_details sd ON s.id = sd.service_id
WHERE s.title->>'en' LIKE '%Test%'
ORDER BY s.created_at;

-- 检查服务提供商
SELECT 
    'Providers' as check_type,
    display_name->>'en' as provider_name,
    provider_type,
    status
FROM provider_profiles
WHERE email LIKE '%@test.com'
ORDER BY created_at;

-- 检查服务分类
SELECT 
    'Service Categories' as check_type,
    s.title->>'en' as service_name,
    rc1.chinese_name as level1_category,
    rc2.chinese_name as level2_category
FROM services s
JOIN ref_codes rc1 ON s.category_level1_id = rc1.code
LEFT JOIN ref_codes rc2 ON s.category_level2_id = rc2.code
WHERE s.title->>'en' LIKE '%Test%'
ORDER BY s.created_at;

-- =====================================================
-- 测试数据创建完成
-- =====================================================

COMMIT;

-- 显示创建结果摘要
SELECT 
    'Test Data Creation Summary' as summary,
    (SELECT COUNT(*) FROM ref_codes WHERE type_code = 'SERVICE_TYPE') as ref_codes_created,
    (SELECT COUNT(*) FROM provider_profiles WHERE email LIKE '%@test.com') as providers_created,
    (SELECT COUNT(*) FROM services WHERE title->>'en' LIKE '%Test%') as services_created,
    (SELECT COUNT(*) FROM service_details WHERE service_id IN (SELECT id FROM services WHERE title->>'en' LIKE '%Test%')) as details_created;
