-- =====================================================
-- JinBean Platform - Corrected Test Data Script
-- 根据实际数据库表结构创建测试数据
-- 注意：满足unique_service_category_name约束 (service_id, category, name) 唯一
-- =====================================================

-- 清理现有测试数据（可选）
-- DELETE FROM service_details WHERE service_id LIKE 'test-%';
-- DELETE FROM services WHERE id LIKE 'test-%';
-- DELETE FROM provider_profiles WHERE display_name LIKE 'Test%';



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
-- 根据实际的表结构，使用display_name而不是company_name
-- =====================================================

INSERT INTO provider_profiles (id, display_name, provider_type, email, phone, status, created_at, updated_at) VALUES
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
    '{"en": "CleanPro Services", "zh": "优质清洁服务", "fr": "Services de Nettoyage CleanPro"}',
    'corporate',
    'info@cleanpro.com',
    '+1-416-555-0102',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "TechPro Solutions", "zh": "科技专业解决方案", "fr": "Solutions TechPro"}',
    'corporate',
    'info@techprosolutions.com',
    '+1-416-555-0103',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 新增更多服务提供商
(
    gen_random_uuid(),
    '{"en": "Golden Dragon Restaurant", "zh": "金龙餐厅", "fr": "Restaurant Dragon d''Or"}',
    'corporate',
    'info@goldendragon.com',
    '+1-416-555-0104',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Sushi Master", "zh": "寿司大师", "fr": "Maître Sushi"}',
    'corporate',
    'info@sushimaster.com',
    '+1-416-555-0105',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Handyman Express", "zh": "万能手艺人", "fr": "Bricoleur Express"}',
    'corporate',
    'info@handymanexpress.com',
    '+1-416-555-0106',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Garden Care Plus", "zh": "花园护理专家", "fr": "Expert Jardinage Plus"}',
    'corporate',
    'info@gardencareplus.com',
    '+1-416-555-0107',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Pet Paradise", "zh": "宠物天堂", "fr": "Paradis des Animaux"}',
    'corporate',
    'info@petparadise.com',
    '+1-416-555-0108',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Pro Tools Rental", "zh": "专业工具租赁", "fr": "Location d''Outils Pro"}',
    'corporate',
    'info@protoolsrental.com',
    '+1-416-555-0109',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "WebDev Academy", "zh": "网页开发学院", "fr": "Académie WebDev"}',
    'corporate',
    'info@webdevacademy.com',
    '+1-416-555-0110',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Language Learning Center", "zh": "语言学习中心", "fr": "Centre d''Apprentissage des Langues"}',
    'corporate',
    'info@languagecenter.com',
    '+1-416-555-0111',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Fitness Pro", "zh": "健身专家", "fr": "Expert Fitness"}',
    'corporate',
    'info@fitnesspro.com',
    '+1-416-555-0112',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Beauty Salon Elite", "zh": "精英美容沙龙", "fr": "Salon de Beauté Elite"}',
    'corporate',
    'info@beautysalonelite.com',
    '+1-416-555-0113',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Legal Consult Pro", "zh": "法律咨询专家", "fr": "Expert Consultation Juridique"}',
    'corporate',
    'info@legalconsultpro.com',
    '+1-416-555-0114',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Financial Advisor Plus", "zh": "理财顾问专家", "fr": "Expert Conseiller Financier"}',
    'corporate',
    'info@financialadvisorplus.com',
    '+1-416-555-0115',
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
    (SELECT id FROM provider_profiles WHERE email = 'info@bellaitalia.com' LIMIT 1),
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
    (SELECT id FROM provider_profiles WHERE email = 'info@cleanpro.com' LIMIT 1),
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
    (SELECT id FROM provider_profiles WHERE email = 'info@techprosolutions.com' LIMIT 1),
    'active',
    4.9,
    189,
    43.6535,
    -79.3815,
    'hybrid',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 新增更多服务
(
    gen_random_uuid(),
    '{"en": "Golden Dragon Restaurant", "zh": "金龙餐厅", "fr": "Restaurant Dragon d''Or"}',
    '{"en": "Authentic Chinese cuisine with traditional flavors and modern presentation", "zh": "正宗中式料理，传统风味现代呈现", "fr": "Cuisine chinoise authentique avec des saveurs traditionnelles et une présentation moderne"}',
    1010000,  -- 美食天地
    1010301,  -- 地道中餐
    (SELECT id FROM provider_profiles WHERE email = 'info@goldendragon.com' LIMIT 1),
    'active',
    4.7,
    203,
    43.6538,
    -79.3840,
    'on_site',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Sushi Master", "zh": "寿司大师", "fr": "Maître Sushi"}',
    '{"en": "Premium Japanese sushi and sashimi with fresh ingredients", "zh": "使用新鲜食材的高级日本寿司和刺身", "fr": "Sushi et sashimi japonais premium avec des ingrédients frais"}',
    1010000,  -- 美食天地
    1010303,  -- 东南亚菜
    (SELECT id FROM provider_profiles WHERE email = 'info@sushimaster.com' LIMIT 1),
    'active',
    4.9,
    167,
    43.6540,
    -79.3835,
    'on_site',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Handyman Express", "zh": "万能手艺人", "fr": "Bricoleur Express"}',
    '{"en": "Professional handyman services for all your home repair needs", "zh": "专业的万能手艺人服务，满足您的所有家居维修需求", "fr": "Services de bricolage professionnels pour tous vos besoins de réparation à domicile"}',
    1020000,  -- 家政到家
    1020106,  -- 水管维护
    (SELECT id FROM provider_profiles WHERE email = 'info@handymanexpress.com' LIMIT 1),
    'active',
    4.8,
    145,
    43.6525,
    -79.3848,
    'on_site',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Garden Care Plus", "zh": "花园护理专家", "fr": "Expert Jardinage Plus"}',
    '{"en": "Professional gardening and outdoor maintenance services", "zh": "专业的花园护理和户外维护服务", "fr": "Services professionnels de jardinage et d''entretien extérieur"}',
    1020000,  -- 家政到家
    1020301,  -- 割草修树
    (SELECT id FROM provider_profiles WHERE email = 'info@gardencareplus.com' LIMIT 1),
    'active',
    4.7,
    98,
    43.6530,
    -79.3850,
    'on_site',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Pet Paradise", "zh": "宠物天堂", "fr": "Paradis des Animaux"}',
    '{"en": "Comprehensive pet care services including sitting, walking, and grooming", "zh": "全面的宠物护理服务，包括托管、遛狗和美容", "fr": "Services complets de soins pour animaux de compagnie incluant la garde, la promenade et le toilettage"}',
    1020000,  -- 家政到家
    1020401,  -- 宠物托管
    (SELECT id FROM provider_profiles WHERE email = 'info@petparadise.com' LIMIT 1),
    'active',
    4.9,
    134,
    43.6528,
    -79.3842,
    'on_site',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Pro Tools Rental", "zh": "专业工具租赁", "fr": "Location d''Outils Pro"}',
    '{"en": "Professional tools and equipment rental for DIY projects", "zh": "为DIY项目提供专业工具和设备租赁", "fr": "Location d''outils et d''équipements professionnels pour les projets DIY"}',
    1040000,  -- 共享乐园
    1040100,  -- 工具租赁
    (SELECT id FROM provider_profiles WHERE email = 'info@protoolsrental.com' LIMIT 1),
    'active',
    4.8,
    89,
    43.6542,
    -79.3818,
    'on_site',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "WebDev Academy", "zh": "网页开发学院", "fr": "Académie WebDev"}',
    '{"en": "Comprehensive web development training programs for all skill levels", "zh": "为所有技能水平提供全面的网页开发培训课程", "fr": "Programmes de formation complets en développement web pour tous les niveaux de compétence"}',
    1050000,  -- 学习课堂
    1050100,  -- 技术培训
    (SELECT id FROM provider_profiles WHERE email = 'info@webdevacademy.com' LIMIT 1),
    'active',
    4.9,
    156,
    43.6536,
    -79.3820,
    'hybrid',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Language Learning Center", "zh": "语言学习中心", "fr": "Centre d''Apprentissage des Langues"}',
    '{"en": "Professional language learning services in multiple languages", "zh": "多语言专业语言学习服务", "fr": "Services professionnels d''apprentissage des langues en plusieurs langues"}',
    1050000,  -- 学习课堂
    1050200,  -- 语言培训
    (SELECT id FROM provider_profiles WHERE email = 'info@languagecenter.com' LIMIT 1),
    'active',
    4.8,
    123,
    43.6534,
    -79.3825,
    'hybrid',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Fitness Pro", "zh": "健身专家", "fr": "Expert Fitness"}',
    '{"en": "Personal fitness training and wellness coaching services", "zh": "个人健身训练和健康指导服务", "fr": "Services de formation fitness personnelle et de coaching bien-être"}',
    1060000,  -- 生活帮忙
    1060300,  -- 健康健身
    (SELECT id FROM provider_profiles WHERE email = 'info@fitnesspro.com' LIMIT 1),
    'active',
    4.7,
    178,
    43.6539,
    -79.3830,
    'on_site',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Beauty Salon Elite", "zh": "精英美容沙龙", "fr": "Salon de Beauté Elite"}',
    '{"en": "Premium beauty and salon services for all your beauty needs", "zh": "为您的所有美容需求提供优质美容和沙龙服务", "fr": "Services de beauté et de salon premium pour tous vos besoins de beauté"}',
    1060000,  -- 生活帮忙
    1060404,  -- 美容美发
    (SELECT id FROM provider_profiles WHERE email = 'info@beautysalonelite.com' LIMIT 1),
    'active',
    4.8,
    145,
    43.6541,
    -79.3828,
    'on_site',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Legal Consult Pro", "zh": "法律咨询专家", "fr": "Expert Consultation Juridique"}',
    '{"en": "Professional legal consultation and advisory services", "zh": "专业法律咨询和顾问服务", "fr": "Services professionnels de consultation et de conseil juridiques"}',
    1060000,  -- 生活帮忙
    1060500,  -- 法律咨询
    (SELECT id FROM provider_profiles WHERE email = 'info@legalconsultpro.com' LIMIT 1),
    'active',
    4.9,
    67,
    43.6537,
    -79.3822,
    'hybrid',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    gen_random_uuid(),
    '{"en": "Financial Advisor Plus", "zh": "理财顾问专家", "fr": "Expert Conseiller Financier"}',
    '{"en": "Professional financial planning and investment advisory services", "zh": "专业财务规划和投资顾问服务", "fr": "Services professionnels de planification financière et de conseil en investissement"}',
    1060000,  -- 生活帮忙
          1060302,  -- 贷款保险
    (SELECT id FROM provider_profiles WHERE email = 'info@financialadvisorplus.com' LIMIT 1),
    'active',
    4.8,
    89,
    43.6533,
    -79.3826,
    'hybrid',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- =====================================================
-- 4. 创建service_details详情数据（重构后的表结构）
-- 根据实际数据库表结构，添加所有必要字段
-- 注意：确保满足unique_service_category_name约束
-- =====================================================

INSERT INTO service_details (
    service_id, pricing_type, price, currency, duration_type, duration, 
    images_url, videos_url, tags, service_area_codes, 
    platform_service_fee_rate, min_platform_service_fee,
    service_details_json, extra_data, verification_status, verification_documents,
    category, name, sub_category, is_available, sort_order, 
    current_stock, max_stock, attributes, business_rules,
    created_at, updated_at
) VALUES
-- 餐厅服务详情 - 主服务
(
    (SELECT id FROM services WHERE provider_id = (SELECT id FROM provider_profiles WHERE email = 'info@bellaitalia.com' LIMIT 1) AND title->>'en' = 'Bella Italia Restaurant' LIMIT 1),
    'fixed_price',
    0,
    'CAD',
    'hours',
    '2 hours',
    ARRAY['https://example.com/restaurant1.jpg', 'https://example.com/restaurant2.jpg'],
    ARRAY['https://example.com/restaurant_video.mp4'],
    ARRAY['italian', 'restaurant', 'fine_dining'],
    ARRAY['M5V', 'M5X', 'M6J'],
    0.05,
    2.50,
    '{"cuisine_type": "italian", "dress_code": "smart_casual", "parking": true, "delivery": true, "takeout": true}',
    '{"special_offers": ["happy_hour", "weekend_brunch"], "payment_methods": ["cash", "credit", "debit"]}',
    'approved',
    ARRAY['https://example.com/business_license.pdf', 'https://example.com/food_safety_cert.pdf'],
    'main',
    '{"en": "Bella Italia Restaurant", "zh": "贝拉意大利餐厅", "fr": "Restaurant Bella Italia"}',
    'restaurant',
    true,
    1,
    NULL,
    NULL,
    '{"cuisine_type": "italian", "dress_code": "smart_casual", "parking": true, "delivery": true, "takeout": true}',
    '{"reservation_required": false, "min_party_size": 1, "max_party_size": 20, "cancellation_policy": "2_hours"}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 清洁服务详情 - 主服务
(
    (SELECT id FROM services WHERE provider_id = (SELECT id FROM provider_profiles WHERE email = 'info@cleanpro.com' LIMIT 1) AND title->>'en' = 'Premium Home Cleaning' LIMIT 1),
    'fixed_price',
    120.00,
    'CAD',
    'hours',
    '3 hours',
    ARRAY['https://example.com/cleaning1.jpg', 'https://example.com/cleaning2.jpg'],
    ARRAY['https://example.com/cleaning_video.mp4'],
    ARRAY['cleaning', 'eco_friendly', 'professional'],
    ARRAY['M5V', 'M5X', 'M6J', 'M6K'],
    0.05,
    6.00,
    '{"service_type": "cleaning", "eco_friendly": true, "insured": true, "duration": "3-4_hours"}',
    '{"equipment": ["vacuum", "eco_cleaners"], "team_size": 2, "guarantee": "100% satisfaction"}',
    'approved',
    ARRAY['https://example.com/insurance_cert.pdf', 'https://example.com/cleaning_cert.pdf'],
    'main',
    '{"en": "Premium Home Cleaning", "zh": "优质家庭清洁", "fr": "Nettoyage Premium à Domicile"}',
    'cleaning',
    true,
    1,
    NULL,
    NULL,
    '{"service_type": "cleaning", "eco_friendly": true, "insured": true, "duration": "3-4_hours"}',
    '{"advance_booking": "24_hours", "cancellation_policy": "4_hours", "satisfaction_guarantee": true}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- IT服务详情 - 主服务
(
    (SELECT id FROM services WHERE provider_id = (SELECT id FROM provider_profiles WHERE email = 'info@techprosolutions.com' LIMIT 1) AND title->>'en' = 'IT Support & Consulting' LIMIT 1),
    'hourly',
    85.00,
    'CAD',
    'hours',
    '1 hour',
    ARRAY['https://example.com/it1.jpg', 'https://example.com/it2.jpg'],
    ARRAY['https://example.com/it_video.mp4'],
    ARRAY['it_support', 'consulting', 'network'],
    ARRAY['M5V', 'M5X', 'M6J', 'M6K', 'M6L'],
    0.05,
    4.25,
    '{"service_type": "it_support", "certification": ["CompTIA", "Cisco"], "response_time": "2_hours"}',
    '{"remote_support": true, "on_site_available": true, "emergency_24_7": true}',
    'approved',
    ARRAY['https://example.com/compTIA_cert.pdf', 'https://example.com/cisco_cert.pdf'],
    'main',
    '{"en": "IT Support & Consulting", "zh": "IT技术支持与咨询", "fr": "Support et Conseil IT"}',
    'it_support',
    true,
    1,
    NULL,
    NULL,
    '{"service_type": "it_support", "certification": ["CompTIA", "Cisco"], "response_time": "2_hours"}',
    '{"advance_booking": "24_hours", "cancellation_policy": "4_hours", "emergency_support": true}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- 新增更多服务详情
INSERT INTO service_details (
    service_id, pricing_type, price, currency, duration_type, duration, 
    images_url, videos_url, tags, service_area_codes, 
    platform_service_fee_rate, min_platform_service_fee,
    service_details_json, extra_data, verification_status, verification_documents,
    category, name, sub_category, is_available, sort_order, 
    current_stock, max_stock, attributes, business_rules,
    created_at, updated_at
) VALUES
-- 金龙餐厅详情
(
    (SELECT id FROM services WHERE provider_id = (SELECT id FROM provider_profiles WHERE email = 'info@goldendragon.com' LIMIT 1) AND title->>'en' = 'Golden Dragon Restaurant' LIMIT 1),
    'fixed_price',
    0,
    'CAD',
    'hours',
    '2 hours',
    ARRAY['https://example.com/chinese1.jpg', 'https://example.com/chinese2.jpg'],
    ARRAY['https://example.com/chinese_video.mp4'],
    ARRAY['chinese', 'restaurant', 'traditional'],
    ARRAY['M5V', 'M5X', 'M6J', 'M6K'],
    0.05,
    2.50,
    '{"cuisine_type": "chinese", "dress_code": "casual", "parking": true, "delivery": true, "takeout": true}',
    '{"special_offers": ["lunch_special", "family_package"], "payment_methods": ["cash", "credit", "debit"]}',
    'approved',
    ARRAY['https://example.com/business_license.pdf', 'https://example.com/food_safety_cert.pdf'],
    'main',
    '{"en": "Golden Dragon Restaurant", "zh": "金龙餐厅", "fr": "Restaurant Dragon d''Or"}',
    'chinese_restaurant',
    true,
    1,
    NULL,
    NULL,
    '{"cuisine_type": "chinese", "dress_code": "casual", "parking": true, "delivery": true, "takeout": true}',
    '{"reservation_required": false, "min_party_size": 1, "max_party_size": 25, "cancellation_policy": "2_hours"}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 寿司大师详情
(
    (SELECT id FROM services WHERE provider_id = (SELECT id FROM provider_profiles WHERE email = 'info@sushimaster.com' LIMIT 1) AND title->>'en' = 'Sushi Master' LIMIT 1),
    'fixed_price',
    0,
    'CAD',
    'hours',
    '1.5 hours',
    ARRAY['https://example.com/sushi1.jpg', 'https://example.com/sushi2.jpg'],
    ARRAY['https://example.com/sushi_video.mp4'],
    ARRAY['japanese', 'sushi', 'premium'],
    ARRAY['M5V', 'M5X', 'M6J'],
    0.05,
    3.00,
    '{"cuisine_type": "japanese", "dress_code": "smart_casual", "parking": true, "delivery": false, "takeout": true}',
    '{"special_offers": ["omakase_experience", "sake_pairing"], "payment_methods": ["cash", "credit", "debit"]}',
    'approved',
    ARRAY['https://example.com/business_license.pdf', 'https://example.com/food_safety_cert.pdf'],
    'main',
    '{"en": "Sushi Master", "zh": "寿司大师", "fr": "Maître Sushi"}',
    'sushi_restaurant',
    true,
    1,
    NULL,
    NULL,
    '{"cuisine_type": "japanese", "dress_code": "smart_casual", "parking": true, "delivery": false, "takeout": true}',
    '{"reservation_required": true, "min_party_size": 1, "max_party_size": 8, "cancellation_policy": "24_hours"}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 万能手艺人详情
(
    (SELECT id FROM services WHERE provider_id = (SELECT id FROM provider_profiles WHERE email = 'info@handymanexpress.com' LIMIT 1) AND title->>'en' = 'Handyman Express' LIMIT 1),
    'hourly',
    65.00,
    'CAD',
    'hours',
    '2 hours',
    ARRAY['https://example.com/handyman1.jpg', 'https://example.com/handyman2.jpg'],
    ARRAY['https://example.com/handyman_video.mp4'],
    ARRAY['handyman', 'repair', 'maintenance'],
    ARRAY['M5V', 'M5X', 'M6J', 'M6K', 'M6L'],
    0.05,
    3.25,
    '{"service_type": "handyman", "insured": true, "response_time": "4_hours", "areas": ["plumbing", "electrical", "carpentry"]}',
    '{"emergency_service": true, "warranty": "90_days", "free_quote": true}',
    'approved',
    ARRAY['https://example.com/insurance_cert.pdf', 'https://example.com/trade_license.pdf'],
    'main',
    '{"en": "Handyman Express", "zh": "万能手艺人", "fr": "Bricoleur Express"}',
    'handyman',
    true,
    1,
    NULL,
    NULL,
    '{"service_type": "handyman", "insured": true, "response_time": "4_hours", "areas": ["plumbing", "electrical", "carpentry"]}',
    '{"advance_booking": "24_hours", "cancellation_policy": "4_hours", "emergency_service": true}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 花园护理专家详情
(
    (SELECT id FROM services WHERE provider_id = (SELECT id FROM provider_profiles WHERE email = 'info@gardencareplus.com' LIMIT 1) AND title->>'en' = 'Garden Care Plus' LIMIT 1),
    'hourly',
    45.00,
    'CAD',
    'hours',
    '3 hours',
    ARRAY['https://example.com/garden1.jpg', 'https://example.com/garden2.jpg'],
    ARRAY['https://example.com/garden_video.mp4'],
    ARRAY['gardening', 'outdoor', 'landscaping'],
    ARRAY['M5V', 'M5X', 'M6J', 'M6K'],
    0.05,
    2.25,
    '{"service_type": "gardening", "eco_friendly": true, "equipment": "provided", "seasonal": true}',
    '{"seasonal_packages": true, "maintenance_plans": true, "free_consultation": true}',
    'approved',
    ARRAY['https://example.com/business_license.pdf', 'https://example.com/insurance_cert.pdf'],
    'main',
    '{"en": "Garden Care Plus", "zh": "花园护理专家", "fr": "Expert Jardinage Plus"}',
    'gardening',
    true,
    1,
    NULL,
    NULL,
    '{"service_type": "gardening", "eco_friendly": true, "equipment": "provided", "seasonal": true}',
    '{"advance_booking": "48_hours", "cancellation_policy": "24_hours", "weather_dependent": true}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 宠物天堂详情
(
    (SELECT id FROM services WHERE provider_id = (SELECT id FROM provider_profiles WHERE email = 'info@petparadise.com' LIMIT 1) AND title->>'en' = 'Pet Paradise' LIMIT 1),
    'hourly',
    35.00,
    'CAD',
    'hours',
    '1 hour',
    ARRAY['https://example.com/pet1.jpg', 'https://example.com/pet2.jpg'],
    ARRAY['https://example.com/pet_video.mp4'],
    ARRAY['pet_care', 'pet_sitting', 'grooming'],
    ARRAY['M5V', 'M5X', 'M6J', 'M6K'],
    0.05,
    1.75,
    '{"service_type": "pet_care", "pet_types": ["dogs", "cats", "birds"], "certified": true, "bonded": true}',
    '{"emergency_contact": true, "daily_updates": true, "photo_reports": true}',
    'approved',
    ARRAY['https://example.com/business_license.pdf', 'https://example.com/pet_care_cert.pdf'],
    'main',
    '{"en": "Pet Paradise", "zh": "宠物天堂", "fr": "Paradis des Animaux"}',
    'pet_care',
    true,
    1,
    NULL,
    NULL,
    '{"service_type": "pet_care", "pet_types": ["dogs", "cats", "birds"], "certified": true, "bonded": true}',
    '{"advance_booking": "24_hours", "cancellation_policy": "6_hours", "emergency_service": true}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 专业工具租赁详情
(
    (SELECT id FROM services WHERE provider_id = (SELECT id FROM provider_profiles WHERE email = 'info@protoolsrental.com' LIMIT 1) AND title->>'en' = 'Pro Tools Rental' LIMIT 1),
    'daily',
    25.00,
    'CAD',
    'days',
    '1 day',
    ARRAY['https://example.com/tools1.jpg', 'https://example.com/tools2.jpg'],
    ARRAY['https://example.com/tools_video.mp4'],
    ARRAY['tool_rental', 'equipment', 'diy'],
    ARRAY['M5V', 'M5X', 'M6J', 'M6K', 'M6L'],
    0.05,
    1.25,
    '{"service_type": "tool_rental", "tool_categories": ["power_tools", "hand_tools", "garden_tools"], "delivery": true}',
    '{"safety_training": true, "damage_insurance": true, "extended_rental": true}',
    'approved',
    ARRAY['https://example.com/business_license.pdf', 'https://example.com/insurance_cert.pdf'],
    'main',
    '{"en": "Pro Tools Rental", "zh": "专业工具租赁", "fr": "Location d''Outils Pro"}',
    'tool_rental',
    true,
    1,
    50,
    100,
    '{"service_type": "tool_rental", "tool_categories": ["power_tools", "hand_tools", "garden_tools"], "delivery": true}',
    '{"min_rental": "1_day", "deposit_required": true, "safety_waiver": true}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 网页开发学院详情
(
    (SELECT id FROM services WHERE provider_id = (SELECT id FROM provider_profiles WHERE email = 'info@webdevacademy.com' LIMIT 1) AND title->>'en' = 'WebDev Academy' LIMIT 1),
    'package',
    999.00,
    'CAD',
    'weeks',
    '12 weeks',
    ARRAY['https://example.com/webdev1.jpg', 'https://example.com/webdev2.jpg'],
    ARRAY['https://example.com/webdev_video.mp4'],
    ARRAY['web_development', 'training', 'coding'],
    ARRAY['M5V', 'M5X', 'M6J', 'M6K', 'M6L'],
    0.05,
    50.00,
    '{"service_type": "education", "course_level": "beginner_to_advanced", "certification": true, "online": true}',
    '{"lifetime_access": true, "job_placement": true, "mentorship": true}',
    'approved',
    ARRAY['https://example.com/education_license.pdf', 'https://example.com/accreditation.pdf'],
    'main',
    '{"en": "WebDev Academy", "zh": "网页开发学院", "fr": "Académie WebDev"}',
    'web_development',
    true,
    1,
    25,
    30,
    '{"service_type": "education", "course_level": "beginner_to_advanced", "certification": true, "online": true}',
    '{"advance_booking": "2_weeks", "cancellation_policy": "1_week", "refund_policy": "30_days"}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 语言学习中心详情
(
    (SELECT id FROM services WHERE provider_id = (SELECT id FROM provider_profiles WHERE email = 'info@languagecenter.com' LIMIT 1) AND title->>'en' = 'Language Learning Center' LIMIT 1),
    'hourly',
    45.00,
    'CAD',
    'hours',
    '1 hour',
    ARRAY['https://example.com/language1.jpg', 'https://example.com/language2.jpg'],
    ARRAY['https://example.com/language_video.mp4'],
    ARRAY['language_learning', 'tutoring', 'education'],
    ARRAY['M5V', 'M5X', 'M6J', 'M6K'],
    0.05,
    2.25,
    '{"service_type": "education", "languages": ["english", "french", "spanish", "mandarin"], "certified_teachers": true}',
    '{"free_assessment": true, "flexible_schedule": true, "group_discounts": true}',
    'approved',
    ARRAY['https://example.com/education_license.pdf', 'https://example.com/teacher_cert.pdf'],
    'main',
    '{"en": "Language Learning Center", "zh": "语言学习中心", "fr": "Centre d''Apprentissage des Langues"}',
    'language_learning',
    true,
    1,
    15,
    20,
    '{"service_type": "education", "languages": ["english", "french", "spanish", "mandarin"], "certified_teachers": true}',
    '{"advance_booking": "24_hours", "cancellation_policy": "4_hours", "makeup_classes": true}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 健身专家详情
(
    (SELECT id FROM services WHERE provider_id = (SELECT id FROM provider_profiles WHERE email = 'info@fitnesspro.com' LIMIT 1) AND title->>'en' = 'Fitness Pro' LIMIT 1),
    'hourly',
    75.00,
    'CAD',
    'hours',
    '1 hour',
    ARRAY['https://example.com/fitness1.jpg', 'https://example.com/fitness2.jpg'],
    ARRAY['https://example.com/fitness_video.mp4'],
    ARRAY['fitness', 'training', 'wellness'],
    ARRAY['M5V', 'M5X', 'M6J', 'M6K'],
    0.05,
    3.75,
    '{"service_type": "fitness", "specialties": ["strength_training", "cardio", "yoga"], "certified_trainer": true}',
    '{"free_consultation": true, "nutrition_advice": true, "progress_tracking": true}',
    'approved',
    ARRAY['https://example.com/fitness_cert.pdf', 'https://example.com/first_aid_cert.pdf'],
    'main',
    '{"en": "Fitness Pro", "zh": "健身专家", "fr": "Expert Fitness"}',
    'fitness_training',
    true,
    1,
    NULL,
    NULL,
    '{"service_type": "fitness", "specialties": ["strength_training", "cardio", "yoga"], "certified_trainer": true}',
    '{"advance_booking": "24_hours", "cancellation_policy": "6_hours", "package_discounts": true}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 精英美容沙龙详情
(
    (SELECT id FROM services WHERE provider_id = (SELECT id FROM provider_profiles WHERE email = 'info@beautysalonelite.com' LIMIT 1) AND title->>'en' = 'Beauty Salon Elite' LIMIT 1),
    'fixed_price',
    120.00,
    'CAD',
    'hours',
    '2 hours',
    ARRAY['https://example.com/beauty1.jpg', 'https://example.com/beauty2.jpg'],
    ARRAY['https://example.com/beauty_video.mp4'],
    ARRAY['beauty', 'salon', 'spa'],
    ARRAY['M5V', 'M5X', 'M6J', 'M6K'],
    0.05,
    6.00,
    '{"service_type": "beauty", "services": ["hair", "makeup", "facial", "massage"], "luxury": true}',
    '{"complimentary_consultation": true, "loyalty_program": true, "gift_cards": true}',
    'approved',
    ARRAY['https://example.com/business_license.pdf', 'https://example.com/beauty_license.pdf'],
    'main',
    '{"en": "Beauty Salon Elite", "zh": "精英美容沙龙", "fr": "Salon de Beauté Elite"}',
    'beauty_salon',
    true,
    1,
    NULL,
    NULL,
    '{"service_type": "beauty", "services": ["hair", "makeup", "facial", "massage"], "luxury": true}',
    '{"advance_booking": "48_hours", "cancellation_policy": "24_hours", "deposit_required": true}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 法律咨询专家详情
(
    (SELECT id FROM services WHERE provider_id = (SELECT id FROM provider_profiles WHERE email = 'info@legalconsultpro.com' LIMIT 1) AND title->>'en' = 'Legal Consult Pro' LIMIT 1),
    'hourly',
    200.00,
    'CAD',
    'hours',
    '1 hour',
    ARRAY['https://example.com/legal1.jpg', 'https://example.com/legal2.jpg'],
    ARRAY['https://example.com/legal_video.mp4'],
    ARRAY['legal', 'consultation', 'law'],
    ARRAY['M5V', 'M5X', 'M6J', 'M6K', 'M6L'],
    0.05,
    10.00,
    '{"service_type": "legal", "practice_areas": ["family_law", "business_law", "real_estate"], "licensed_lawyer": true}',
    '{"free_initial_consultation": true, "payment_plans": true, "emergency_contact": true}',
    'approved',
    ARRAY['https://example.com/law_license.pdf', 'https://example.com/bar_cert.pdf'],
    'main',
    '{"en": "Legal Consult Pro", "zh": "法律咨询专家", "fr": "Expert Consultation Juridique"}',
    'legal_consultation',
    true,
    1,
    NULL,
    NULL,
    '{"service_type": "legal", "practice_areas": ["family_law", "business_law", "real_estate"], "licensed_lawyer": true}',
    '{"advance_booking": "1_week", "cancellation_policy": "24_hours", "confidentiality": true}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
-- 理财顾问专家详情
(
    (SELECT id FROM services WHERE provider_id = (SELECT id FROM provider_profiles WHERE email = 'info@financialadvisorplus.com' LIMIT 1) AND title->>'en' = 'Financial Advisor Plus' LIMIT 1),
    'hourly',
    150.00,
    'CAD',
    'hours',
    '1 hour',
    ARRAY['https://example.com/finance1.jpg', 'https://example.com/finance2.jpg'],
    ARRAY['https://example.com/finance_video.mp4'],
    ARRAY['financial', 'planning', 'investment'],
    ARRAY['M5V', 'M5X', 'M6J', 'M6K', 'M6L'],
    0.05,
    7.50,
    '{"service_type": "financial", "specialties": ["retirement_planning", "investment_advice", "tax_planning"], "certified_advisor": true}',
    '{"free_initial_consultation": true, "ongoing_support": true, "performance_reports": true}',
    'approved',
    ARRAY['https://example.com/financial_license.pdf', 'https://example.com/advisor_cert.pdf'],
    'main',
    '{"en": "Financial Advisor Plus", "zh": "理财顾问专家", "fr": "Expert Conseiller Financier"}',
    'financial_planning',
    true,
    1,
    NULL,
    NULL,
    '{"service_type": "financial", "specialties": ["retirement_planning", "investment_advice", "tax_planning"], "certified_advisor": true}',
    '{"advance_booking": "1_week", "cancellation_policy": "48_hours", "fiduciary_duty": true}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- =====================================================
-- 5. 数据验证查询
-- =====================================================

-- 验证数据完整性
SELECT 'Data Integrity Check' as check_type, COUNT(*) as total_records FROM service_details;

-- 检查各服务详情
SELECT 
    'Service Details' as check_type,
    s.title->>'en' as service_name,
    sd.pricing_type,
    sd.price,
    sd.currency,
    sd.duration_type,
    sd.verification_status
FROM services s
JOIN service_details sd ON s.id = sd.service_id
ORDER BY s.created_at;

-- 检查服务提供商
SELECT 
    'Providers' as check_type,
    display_name as provider_name,
    provider_type,
    status
FROM provider_profiles
ORDER BY created_at;

-- 检查服务分类
SELECT 
    'Service Categories' as check_type,
    s.title->>'en' as service_name,
    rc1.name->>'zh' as level1_category,
    rc2.name->>'zh' as level2_category
FROM services s
JOIN ref_codes rc1 ON s.category_level1_id = rc1.id
LEFT JOIN ref_codes rc2 ON s.category_level2_id = rc2.id
ORDER BY s.created_at;

-- 检查服务详情字段完整性
SELECT 
    'Field Completeness' as check_type,
    COUNT(*) as total_records,
    COUNT(images_url) as with_images,
    COUNT(videos_url) as with_videos,
    COUNT(tags) as with_tags,
    COUNT(service_area_codes) as with_area_codes,
    COUNT(verification_status) as with_verification
FROM service_details;

-- 验证unique_service_category_name约束
SELECT 
    'Unique Constraint Check' as check_type,
    service_id,
    category,
    name,
    COUNT(*) as duplicate_count
FROM service_details
GROUP BY service_id, category, name
HAVING COUNT(*) > 1;

-- 验证外键约束
SELECT 
    'Foreign Key Check - Services' as check_type,
    COUNT(*) as orphaned_services
FROM services s
LEFT JOIN provider_profiles pp ON s.provider_id = pp.id
WHERE pp.id IS NULL;

SELECT 
    'Foreign Key Check - Service Details' as check_type,
    COUNT(*) as orphaned_details
FROM service_details sd
LEFT JOIN services s ON sd.service_id = s.id
WHERE s.id IS NULL;

-- =====================================================
-- 测试数据创建完成
-- =====================================================

COMMIT;

-- 显示创建结果摘要
SELECT 
    'Test Data Creation Summary' as summary,
    (SELECT COUNT(*) FROM provider_profiles WHERE email IS NOT NULL) as providers_created,
    (SELECT COUNT(*) FROM services WHERE title->>'en' IS NOT NULL) as services_created,
    (SELECT COUNT(*) FROM service_details WHERE service_id IS NOT NULL) as details_created;

-- 新增：按行业分类统计
SELECT 
    'Industry Distribution' as summary,
    CASE 
        WHEN s.category_level1_id = 1010000 THEN 'Food Court (美食天地)'
        WHEN s.category_level1_id = 1020000 THEN 'Home to Home (家政到家)'
        WHEN s.category_level1_id = 1030000 THEN 'Travel Plaza (出行广场)'
        WHEN s.category_level1_id = 1040000 THEN 'Share Park (共享乐园)'
        WHEN s.category_level1_id = 1050000 THEN 'Learning Park (学习课堂)'
        WHEN s.category_level1_id = 1060000 THEN 'Life Help (生活帮忙)'
        ELSE 'Other'
    END as industry,
    COUNT(*) as service_count,
    AVG(s.average_rating) as avg_rating
FROM services s
GROUP BY s.category_level1_id
ORDER BY service_count DESC;

-- 新增：按服务类型统计
SELECT 
    'Service Type Distribution' as summary,
    sd.sub_category,
    COUNT(*) as count,
    AVG(sd.price) as avg_price
FROM service_details sd
JOIN services s ON sd.service_id = s.id
WHERE sd.sub_category IS NOT NULL
GROUP BY sd.sub_category
ORDER BY count DESC;

-- 新增：价格范围分析
SELECT 
    'Price Range Analysis' as summary,
    CASE 
        WHEN sd.price = 0 THEN 'Free'
        WHEN sd.price < 50 THEN 'Under $50'
        WHEN sd.price < 100 THEN '$50-$100'
        WHEN sd.price < 200 THEN '$100-$200'
        ELSE 'Over $200'
    END as price_range,
    COUNT(*) as service_count,
    AVG(sd.price) as avg_price
FROM service_details sd
WHERE sd.price IS NOT NULL
GROUP BY 
    CASE 
        WHEN sd.price = 0 THEN 'Free'
        WHEN sd.price < 50 THEN 'Under $50'
        WHEN sd.price < 100 THEN '$50-$100'
        WHEN sd.price < 200 THEN '$100-$200'
        ELSE 'Over $200'
    END
ORDER BY avg_price;
