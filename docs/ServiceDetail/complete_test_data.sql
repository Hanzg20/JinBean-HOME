-- =====================================================
-- JinBean Platform - Complete Test Data Script
-- 包含ref_codes和完整测试数据
-- =====================================================

-- 清理现有测试数据（可选）
-- DELETE FROM service_details WHERE service_id LIKE 'test-%';
-- DELETE FROM services WHERE id LIKE 'test-%';
-- DELETE FROM provider_profiles WHERE id LIKE 'provider-%';
-- DELETE FROM ref_codes WHERE code IN ('1010000', '1020000', '1060000');

-- =====================================================
-- 1. 使用现有的ref_codes数据（不需要插入新数据）
-- 根据ref_codes.sql，我们使用以下现有的分类：
-- 1010000: 美食天地 (Food Court)
-- 1020000: 家政到家 (Home to Home)  
-- 1060000: 生活帮忙 (Life Help)
-- 1010301: 地道中餐 (China Cuisine)
-- 1020101: 家里大扫除 (Home Cleaning)
-- 1060201: IT支持 (IT Support)
-- =====================================================

-- =====================================================
-- 2. 创建服务提供商数据 (provider_profiles表)
-- =====================================================

INSERT INTO provider_profiles (id, company_name, provider_type, contact_email, contact_phone, status, created_at, updated_at) VALUES
(
    gen_random_uuid(),
    '{"en": "Bella Italia Restaurant", "zh": "贝拉意大利餐厅", "fr": "Restaurant Bella Italia"}',
    'corporate',
    'info@bellaitalia.com',
    '+1-416-555-0101',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "CleanPro Services", "zh": "清洁专家服务", "fr": "Services CleanPro"}',
    'corporate',
    'info@cleanpro.com',
    '+1-416-555-0102',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "TechPro Solutions", "zh": "科技专家解决方案", "fr": "Solutions TechPro"}',
    'corporate',
    'info@techprosolutions.com',
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
    '{"en": "Bella Italia Restaurant", "zh": "贝拉意大利餐厅", "fr": "Restaurant Bella Italia"}',
    '{"en": "Authentic Italian cuisine with traditional recipes and modern presentation", "zh": "正宗意大利美食，传统配方现代呈现", "fr": "Cuisine italienne authentique avec des recettes traditionnelles et une présentation moderne"}',
    1010000,  -- 美食天地 (Food Court)
    1010301,  -- 地道中餐 (China Cuisine)
    (SELECT id FROM provider_profiles WHERE contact_email = 'info@bellaitalia.com'),
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
    '{"en": "Premium Home Cleaning", "zh": "优质家庭清洁", "fr": "Nettoyage Premium à Domicile"}',
    '{"en": "Professional home cleaning with eco-friendly products", "zh": "使用环保产品的专业家庭清洁服务", "fr": "Nettoyage professionnel à domicile avec des produits écologiques"}',
    1020000,  -- 家政到家 (Home to Home)
    1020101,  -- 家里大扫除 (Home Cleaning)
    (SELECT id FROM provider_profiles WHERE contact_email = 'info@cleanpro.com'),
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
    '{"en": "IT Support & Consulting", "zh": "IT技术支持与咨询", "fr": "Support et Conseil IT"}',
    '{"en": "Expert IT support for businesses and individuals", "zh": "为企业和个人提供专业IT技术支持", "fr": "Support IT expert pour les entreprises et les particuliers"}',
    1060000,  -- 生活帮忙 (Life Help)
    1060201,  -- IT支持 (IT Support)
    (SELECT id FROM provider_profiles WHERE contact_email = 'info@techprosolutions.com'),
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
-- 4. 创建service_details详情数据（重构后的表结构）
-- =====================================================

INSERT INTO service_details (id, service_id, category, name, description, pricing_type, price, currency, sub_category, is_available, sort_order, attributes, business_rules, created_at, updated_at) VALUES
-- 餐厅服务详情
(
    gen_random_uuid(),
    (SELECT id FROM services WHERE description->>'en' LIKE '%Italian cuisine%'),
    'main',
    '{"en": "Bella Italia Restaurant", "zh": "贝拉意大利餐厅", "fr": "Restaurant Bella Italia"}',
    'Authentic Italian cuisine with traditional recipes and modern presentation',
    'fixed_price',
    0,
    'CAD',
    'restaurant',
    true,
    1,
    '{"cuisine_type": "italian", "dress_code": "smart_casual", "parking": true, "delivery": true, "takeout": true}',
    '{"reservation_required": false, "min_party_size": 1, "max_party_size": 20, "cancellation_policy": "2_hours"}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 清洁服务详情
(
    gen_random_uuid(),
    (SELECT id FROM services WHERE description->>'en' LIKE '%home cleaning%'),
    'main',
    '{"en": "Premium Home Cleaning", "zh": "优质家庭清洁", "fr": "Nettoyage Premium à Domicile"}',
    'Professional home cleaning with eco-friendly products and guaranteed satisfaction',
    'fixed_price',
    120.00,
    'CAD',
    'cleaning',
    true,
    1,
    '{"service_type": "cleaning", "eco_friendly": true, "insured": true, "duration": "3-4_hours"}',
    '{"advance_booking": "24_hours", "cancellation_policy": "4_hours", "satisfaction_guarantee": true}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- IT服务详情
(
    gen_random_uuid(),
    (SELECT id FROM services WHERE description->>'en' LIKE '%IT support%'),
    'main',
    '{"en": "IT Support & Consulting", "zh": "IT技术支持与咨询", "fr": "Support et Conseil IT"}',
    'Expert IT support for businesses and individuals. Network setup, system maintenance, cybersecurity, and digital transformation consulting.',
    'hourly',
    85.00,
    'CAD',
    'it_support',
    true,
    1,
    '{"service_type": "it_support", "certification": ["CompTIA", "Cisco"], "response_time": "2_hours"}',
    '{"advance_booking": "24_hours", "cancellation_policy": "4_hours", "emergency_support": true}',
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
ORDER BY s.created_at;

-- 检查服务提供商
SELECT 
    'Providers' as check_type,
    company_name as provider_name,
    provider_type,
    status
FROM provider_profiles
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
ORDER BY s.created_at;

-- =====================================================
-- 测试数据创建完成
-- =====================================================

COMMIT;

-- 显示创建结果摘要
SELECT 
    'Test Data Creation Summary' as summary,
    (SELECT COUNT(*) FROM provider_profiles WHERE contact_email LIKE '%@%') as providers_created,
    (SELECT COUNT(*) FROM services WHERE title->>'en' IS NOT NULL) as services_created,
    (SELECT COUNT(*) FROM service_details WHERE service_id IS NOT NULL) as details_created;
