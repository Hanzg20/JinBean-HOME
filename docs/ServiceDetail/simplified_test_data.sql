-- =====================================================
-- JinBean Platform - Simplified Test Data Script
-- 使用实际数据库表结构的测试数据
-- =====================================================

-- 清理现有测试数据（可选）
-- DELETE FROM service_details WHERE service_id LIKE 'test-%';
-- DELETE FROM services WHERE id LIKE 'test-%';
-- DELETE FROM provider_profiles WHERE id LIKE 'provider-%';

-- =====================================================
-- 1. 创建服务提供商数据 (provider_profiles表)
-- =====================================================

INSERT INTO provider_profiles (id, display_name, provider_type, email, phone, status, created_at, updated_at) VALUES
(
    'provider-001',
    '{"en": "Bella Italia Restaurant", "zh": "贝拉意大利餐厅", "fr": "Restaurant Bella Italia"}',
    'business',
    'info@bellaitalia.com',
    '+1-416-555-0101',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    'provider-002',
    '{"en": "CleanPro Services", "zh": "清洁专家服务", "fr": "Services CleanPro"}',
    'business',
    'info@cleanpro.com',
    '+1-416-555-0102',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    'provider-003',
    '{"en": "TechPro Solutions", "zh": "科技专家解决方案", "fr": "Solutions TechPro"}',
    'business',
    'info@techprosolutions.com',
    '+1-416-555-0103',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- =====================================================
-- 2. 创建services主表数据
-- =====================================================

INSERT INTO services (id, title, description, category_level1_id, category_level2_id, provider_id, status, average_rating, review_count, latitude, longitude, service_delivery_method, created_at, updated_at) VALUES
(
    'service-001',
    '{"en": "Bella Italia Restaurant", "zh": "贝拉意大利餐厅", "fr": "Restaurant Bella Italia"}',
    '{"en": "Authentic Italian cuisine with traditional recipes and modern presentation", "zh": "正宗意大利美食，传统配方现代呈现", "fr": "Cuisine italienne authentique avec des recettes traditionnelles et une présentation moderne"}',
    1010000,  -- 餐饮服务 (需要先在ref_codes表中存在)
    1010100,  -- 餐厅
    'provider-001',
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
    'service-002',
    '{"en": "Premium Home Cleaning", "zh": "优质家庭清洁", "fr": "Nettoyage Premium à Domicile"}',
    '{"en": "Professional home cleaning with eco-friendly products", "zh": "使用环保产品的专业家庭清洁服务", "fr": "Nettoyage professionnel à domicile avec des produits écologiques"}',
    1020000,  -- 家政服务
    1020100,  -- 清洁服务
    'provider-002',
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
    'service-003',
    '{"en": "IT Support & Consulting", "zh": "IT技术支持与咨询", "fr": "Support et Conseil IT"}',
    '{"en": "Expert IT support for businesses and individuals", "zh": "为企业和个人提供专业IT技术支持", "fr": "Support IT expert pour les entreprises et les particuliers"}',
    1060000,  -- 技术服务
    1060100,  -- IT支持
    'provider-003',
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
-- 3. 创建service_details详情数据
-- =====================================================

INSERT INTO service_details (service_id, pricing_type, price, currency, duration_type, tags, service_details_json, created_at, updated_at) VALUES
-- 餐厅服务详情
(
    'service-001',
    'fixed_price',
    0,
    'CAD',
    'fixed',
    ARRAY['italian', 'restaurant', 'fine_dining'],
    '{"cuisine_type": "italian", "dress_code": "smart_casual", "parking": true, "delivery": true, "takeout": true}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 清洁服务详情
(
    'service-002',
    'fixed_price',
    120.00,
    'CAD',
    'hours',
    ARRAY['cleaning', 'eco_friendly', 'professional'],
    '{"service_type": "cleaning", "eco_friendly": true, "insured": true, "duration": "3-4_hours"}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- IT服务详情
(
    'service-003',
    'hourly',
    85.00,
    'CAD',
    'hours',
    ARRAY['it_support', 'consulting', 'network'],
    '{"service_type": "it_support", "certification": ["CompTIA", "Cisco"], "response_time": "2_hours"}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- =====================================================
-- 4. 数据验证查询
-- =====================================================

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
ORDER BY s.created_at;

-- 检查服务提供商
SELECT 
    'Providers' as check_type,
    display_name->>'en' as provider_name,
    provider_type,
    status
FROM provider_profiles
ORDER BY created_at;

-- =====================================================
-- 测试数据创建完成
-- =====================================================

COMMIT;

-- 显示创建结果摘要
SELECT 
    'Test Data Creation Summary' as summary,
    (SELECT COUNT(*) FROM provider_profiles WHERE id LIKE 'provider-%') as providers_created,
    (SELECT COUNT(*) FROM services WHERE id LIKE 'service-%') as services_created,
    (SELECT COUNT(*) FROM service_details WHERE service_id LIKE 'service-%') as details_created;
