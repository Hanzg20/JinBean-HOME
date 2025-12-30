-- ============================================
-- 创建测试Providers和Services
-- ============================================
-- 此脚本创建：
-- 1. 5个测试Provider Profiles（每个服务类别一个）
-- 2. 5个测试Services（对应不同的行业类别）
-- 3. Service Details测试数据（菜单、服务套餐、租赁等）

-- ============================================
-- STEP 1: 创建测试Provider Profiles
-- ============================================

-- 1. 餐饮服务Provider (Food - 1010000)
INSERT INTO provider_profiles (
    id,
    display_name,
    bio,
    avatar_url,
    phone,
    email,
    rating,
    review_count,
    status,
    is_certified,
    is_active,
    provider_type,
    experience_years,
    service_categories,
    tags,
    base_price,
    pricing_type
) VALUES (
    gen_random_uuid(),  -- 或使用固定UUID: 'a1111111-1111-1111-1111-111111111111'
    '{"en": "Golden Wok Restaurant", "zh": "金锅餐厅"}'::jsonb,
    '{"en": "Authentic Chinese cuisine with 15 years of experience", "zh": "15年正宗中餐经验"}'::jsonb,
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5',
    '+1-604-555-0101',
    'goldenwok@example.com',
    4.8,
    127,
    'active',
    true,
    true,
    'individual',
    15,
    ARRAY['1010000', '1010100', '1010101'],
    ARRAY['chinese', 'restaurant', 'food', 'delivery'],
    0.00,
    'menu_based'
) ON CONFLICT (id) DO NOTHING
RETURNING id, display_name->>'en' as name;

-- 2. 家政服务Provider (Home Services - 1020000)
INSERT INTO provider_profiles (
    id,
    display_name,
    bio,
    avatar_url,
    phone,
    email,
    rating,
    review_count,
    status,
    is_certified,
    is_active,
    provider_type,
    experience_years,
    service_categories,
    tags,
    base_price,
    pricing_type
) VALUES (
    gen_random_uuid(),  -- 或使用固定UUID: 'a2222222-2222-2222-2222-222222222222'
    '{"en": "Sparkle Clean Services", "zh": "清洁专家"}'::jsonb,
    '{"en": "Professional cleaning services for your home", "zh": "专业家庭清洁服务"}'::jsonb,
    'https://images.unsplash.com/photo-1581578731548-c64695cc6952',
    '+1-604-555-0102',
    'sparkle@example.com',
    4.9,
    215,
    'active',
    true,
    true,
    'corporate',
    10,
    ARRAY['1020000', '1020100', '1020101'],
    ARRAY['cleaning', 'home', 'professional'],
    80.00,
    'package_based'
) ON CONFLICT (id) DO NOTHING
RETURNING id, display_name->>'en' as name;

-- 3. 租赁服务Provider (Rental - 1040000)
INSERT INTO provider_profiles (
    id,
    display_name,
    bio,
    avatar_url,
    phone,
    email,
    rating,
    review_count,
    status,
    is_certified,
    is_active,
    provider_type,
    experience_years,
    service_categories,
    tags,
    base_price,
    pricing_type
) VALUES (
    gen_random_uuid(),  -- 或使用固定UUID: 'a3333333-3333-3333-3333-333333333333'
    '{"en": "Tool Rental Pro", "zh": "工具租赁专家"}'::jsonb,
    '{"en": "Professional tools and equipment rental", "zh": "专业工具设备租赁"}'::jsonb,
    'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1',
    '+1-604-555-0103',
    'toolrental@example.com',
    4.7,
    89,
    'active',
    true,
    true,
    'corporate',
    8,
    ARRAY['1040000', '1040100', '1040101'],
    ARRAY['tools', 'rental', 'equipment'],
    25.00,
    'rental'
) ON CONFLICT (id) DO NOTHING
RETURNING id, display_name->>'en' as name;

-- 4. 教育服务Provider (Education - 1050000)
INSERT INTO provider_profiles (
    id,
    display_name,
    bio,
    avatar_url,
    phone,
    email,
    rating,
    review_count,
    status,
    is_certified,
    is_active,
    provider_type,
    experience_years,
    service_categories,
    tags,
    base_price,
    pricing_type
) VALUES (
    gen_random_uuid(),  -- 或使用固定UUID: 'a4444444-4444-4444-4444-444444444444'
    '{"en": "English Language Academy", "zh": "英语学院"}'::jsonb,
    '{"en": "Professional English language instruction", "zh": "专业英语语言教学"}'::jsonb,
    'https://images.unsplash.com/photo-1524178232363-1fb2b075b655',
    '+1-604-555-0104',
    'english@example.com',
    4.9,
    342,
    'active',
    true,
    true,
    'corporate',
    12,
    ARRAY['1050000', '1050100', '1050102'],
    ARRAY['english', 'education', 'tutoring'],
    200.00,
    'course_based'
) ON CONFLICT (id) DO NOTHING
RETURNING id, display_name->>'en' as name;

-- 5. 健康服务Provider (Health/Life Help - 1060000)
INSERT INTO provider_profiles (
    id,
    display_name,
    bio,
    avatar_url,
    phone,
    email,
    rating,
    review_count,
    status,
    is_certified,
    is_active,
    provider_type,
    experience_years,
    service_categories,
    tags,
    base_price,
    pricing_type
) VALUES (
    gen_random_uuid(),  -- 或使用固定UUID: 'a5555555-5555-5555-5555-555555555555'
    '{"en": "Wellness Clinic", "zh": "健康诊所"}'::jsonb,
    '{"en": "Holistic health and wellness services", "zh": "全方位健康养生服务"}'::jsonb,
    'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d',
    '+1-604-555-0105',
    'wellness@example.com',
    4.8,
    178,
    'active',
    true,
    true,
    'corporate',
    20,
    ARRAY['1060000', '1060400', '1060401'],
    ARRAY['health', 'wellness', 'therapy'],
    80.00,
    'session_based'
) ON CONFLICT (id) DO NOTHING
RETURNING id, display_name->>'en' as name;

-- ============================================
-- STEP 2: 查看创建的Providers
-- ============================================

SELECT
    id,
    display_name->>'en' as name,
    status,
    rating,
    service_categories,
    tags
FROM provider_profiles
WHERE display_name->>'en' IN (
    'Golden Wok Restaurant',
    'Sparkle Clean Services',
    'Tool Rental Pro',
    'English Language Academy',
    'Wellness Clinic'
)
ORDER BY created_at DESC;

-- ============================================
-- STEP 3: 创建对应的Services
-- ============================================
-- 注意: 需要手动替换provider_id的值

-- 3.1 餐饮服务 (Food Service)
DO $$
DECLARE
    v_provider_id uuid;
    v_service_id uuid;
BEGIN
    -- 获取餐饮provider的ID
    SELECT id INTO v_provider_id
    FROM provider_profiles
    WHERE display_name->>'en' = 'Golden Wok Restaurant'
    LIMIT 1;

    IF v_provider_id IS NOT NULL THEN
        -- 创建服务
        INSERT INTO services (
            title,
            description,
            category_level1_id,
            category_level2_id,
            provider_id,
            status,
            service_delivery_method,
            industry_type,
            is_available
        ) VALUES (
            '{"en": "Golden Wok Restaurant", "zh": "金锅餐厅"}'::jsonb,
            '{"en": "Authentic Chinese cuisine with delivery and pickup", "zh": "正宗中餐，提供外卖和自取"}'::jsonb,
            1010000,
            1010100,
            v_provider_id,
            'active',
            'on_site',
            'food',
            true
        ) RETURNING id INTO v_service_id;

        RAISE NOTICE 'Created Food Service with ID: %', v_service_id;

        -- 创建菜单项 (Menu Items)
        INSERT INTO service_details (
            service_id, category, sub_category, name, price, currency, pricing_type, duration, is_available, sort_order, attributes, business_rules
        )
        SELECT
            v_service_id,
            'menu_item',
            unnest(ARRAY['Appetizer', 'Appetizer', 'Appetizer', 'Main Course', 'Main Course', 'Main Course', 'Dessert', 'Dessert']),
            unnest(ARRAY[
                '{"en": "Spring Rolls", "zh": "春卷"}',
                '{"en": "Fried Dumplings", "zh": "煎饺"}',
                '{"en": "Edamame", "zh": "毛豆"}',
                '{"en": "Beef Noodle Soup", "zh": "牛肉面"}',
                '{"en": "Kung Pao Chicken", "zh": "宫保鸡丁"}',
                '{"en": "Sweet and Sour Pork", "zh": "糖醋排骨"}',
                '{"en": "Mango Sticky Rice", "zh": "芒果糯米饭"}',
                '{"en": "Sesame Balls", "zh": "芝麻球"}'
            ]::jsonb[]),
            unnest(ARRAY[8.99, 9.99, 5.99, 15.99, 14.99, 16.99, 6.99, 4.99]),
            'CAD',
            'fixed',
            unnest(ARRAY['15 minutes'::interval, '15 minutes'::interval, '10 minutes'::interval, '25 minutes'::interval, '20 minutes'::interval, '20 minutes'::interval, '10 minutes'::interval, '10 minutes'::interval]),
            true,
            generate_series(1, 8),
            '{}'::jsonb,
            '{}'::jsonb;

        RAISE NOTICE 'Created 8 menu items for Food Service';
    END IF;
END $$;

-- 3.2 家政服务 (Home Services)
DO $$
DECLARE
    v_provider_id uuid;
    v_service_id uuid;
BEGIN
    SELECT id INTO v_provider_id
    FROM provider_profiles
    WHERE display_name->>'en' = 'Sparkle Clean Services'
    LIMIT 1;

    IF v_provider_id IS NOT NULL THEN
        INSERT INTO services (
            title, description,
            category_level1_id, category_level2_id,
            provider_id, status, service_delivery_method, industry_type, is_available
        ) VALUES (
            '{"en": "Sparkle Clean Services", "zh": "清洁专家"}'::jsonb,
            '{"en": "Professional home cleaning services", "zh": "专业家庭清洁服务"}'::jsonb,
            1020000, 1020100,
            v_provider_id, 'active', 'on_site', 'home_services', true
        ) RETURNING id INTO v_service_id;

        INSERT INTO service_details (
            service_id, category, sub_category, name, price, currency, pricing_type, duration, is_available, sort_order, attributes, business_rules
        )
        SELECT
            v_service_id, 'service_package',
            unnest(ARRAY['Basic', 'Premium', 'Specialized', 'Specialized', 'Premium']),
            unnest(ARRAY[
                '{"en": "Regular Cleaning", "zh": "常规清洁"}',
                '{"en": "Deep Cleaning", "zh": "深度清洁"}',
                '{"en": "Window Cleaning", "zh": "窗户清洁"}',
                '{"en": "Carpet Cleaning", "zh": "地毯清洁"}',
                '{"en": "Move-in/Move-out Cleaning", "zh": "搬家清洁"}'
            ]::jsonb[]),
            unnest(ARRAY[80.00, 120.00, 60.00, 90.00, 150.00]),
            'CAD', 'fixed',
            unnest(ARRAY['2 hours 30 minutes'::interval, '3 hours 30 minutes'::interval, '1 hour 30 minutes'::interval, '2 hours 30 minutes'::interval, '4 hours 30 minutes'::interval]),
            true, generate_series(1, 5), '{}'::jsonb, '{}'::jsonb;

        RAISE NOTICE 'Created Home Service with % packages', 5;
    END IF;
END $$;

-- 3.3 租赁服务 (Rental Service)
DO $$
DECLARE
    v_provider_id uuid;
    v_service_id uuid;
BEGIN
    SELECT id INTO v_provider_id
    FROM provider_profiles
    WHERE display_name->>'en' = 'Tool Rental Pro'
    LIMIT 1;

    IF v_provider_id IS NOT NULL THEN
        INSERT INTO services (
            title, description,
            category_level1_id, category_level2_id,
            provider_id, status, service_delivery_method, industry_type, is_available
        ) VALUES (
            '{"en": "Tool Rental Pro", "zh": "工具租赁专家"}'::jsonb,
            '{"en": "Professional tools and equipment rental", "zh": "专业工具设备租赁"}'::jsonb,
            1040000, 1040100,
            v_provider_id, 'active', 'on_site', 'rental', true
        ) RETURNING id INTO v_service_id;

        INSERT INTO service_details (
            service_id, category, sub_category, name, price, currency, pricing_type, duration,
            is_available, sort_order, current_stock, max_stock, attributes, business_rules
        )
        SELECT
            v_service_id, 'rental_item',
            unnest(ARRAY['Power Tools', 'Power Tools', 'Equipment', 'Equipment', 'Hand Tools', 'Power Tools']),
            unnest(ARRAY[
                '{"en": "Power Drill", "zh": "电钻"}',
                '{"en": "Circular Saw", "zh": "圆锯"}',
                '{"en": "Ladder - 6ft", "zh": "梯子 - 6英尺"}',
                '{"en": "Ladder - 12ft", "zh": "梯子 - 12英尺"}',
                '{"en": "Professional Tool Set", "zh": "专业工具套装"}',
                '{"en": "Pressure Washer", "zh": "高压清洗机"}'
            ]::jsonb[]),
            unnest(ARRAY[25.00, 30.00, 15.00, 20.00, 40.00, 45.00]),
            'CAD', 'per_day', '1 day'::interval, true, generate_series(1, 6),
            unnest(ARRAY[5, 3, 8, 4, 2, 0]),
            unnest(ARRAY[10, 5, 10, 6, 4, 2]),
            '{}'::jsonb, '{}'::jsonb;

        RAISE NOTICE 'Created Rental Service with % items', 6;
    END IF;
END $$;

-- 3.4 教育服务 (Education Service)
DO $$
DECLARE
    v_provider_id uuid;
    v_service_id uuid;
BEGIN
    SELECT id INTO v_provider_id
    FROM provider_profiles
    WHERE display_name->>'en' = 'English Language Academy'
    LIMIT 1;

    IF v_provider_id IS NOT NULL THEN
        INSERT INTO services (
            title, description,
            category_level1_id, category_level2_id,
            provider_id, status, service_delivery_method, industry_type, is_available
        ) VALUES (
            '{"en": "English Language Academy", "zh": "英语学院"}'::jsonb,
            '{"en": "Professional English language courses", "zh": "专业英语语言课程"}'::jsonb,
            1050000, 1050100,
            v_provider_id, 'active', 'on_site', 'learning', true
        ) RETURNING id INTO v_service_id;

        INSERT INTO service_details (
            service_id, category, sub_category, name, price, currency, pricing_type, duration, is_available, sort_order, attributes, business_rules
        )
        SELECT
            v_service_id, 'course',
            unnest(ARRAY['Beginner', 'Intermediate', 'Advanced', 'Specialized', 'Specialized']),
            unnest(ARRAY[
                '{"en": "English Beginner Level", "zh": "英语初级课程"}',
                '{"en": "English Intermediate Level", "zh": "英语中级课程"}',
                '{"en": "English Advanced Level", "zh": "英语高级课程"}',
                '{"en": "Business English", "zh": "商务英语"}',
                '{"en": "IELTS Preparation", "zh": "雅思备考"}'
            ]::jsonb[]),
            unnest(ARRAY[200.00, 350.00, 500.00, 400.00, 450.00]),
            'CAD', 'fixed',
            unnest(ARRAY[
                '8 weeks'::interval,
                '10 weeks'::interval,
                '12 weeks'::interval,
                '8 weeks'::interval,
                '10 weeks'::interval
            ]),
            true, generate_series(1, 5), '{}'::jsonb, '{}'::jsonb;

        RAISE NOTICE 'Created Education Service with % courses', 5;
    END IF;
END $$;

-- 3.5 健康服务 (Health Service)
DO $$
DECLARE
    v_provider_id uuid;
    v_service_id uuid;
BEGIN
    SELECT id INTO v_provider_id
    FROM provider_profiles
    WHERE display_name->>'en' = 'Wellness Clinic'
    LIMIT 1;

    IF v_provider_id IS NOT NULL THEN
        INSERT INTO services (
            title, description,
            category_level1_id, category_level2_id,
            provider_id, status, service_delivery_method, industry_type, is_available
        ) VALUES (
            '{"en": "Wellness Clinic", "zh": "健康诊所"}'::jsonb,
            '{"en": "Holistic health and wellness treatments", "zh": "全方位健康养生治疗"}'::jsonb,
            1060000, 1060400,
            v_provider_id, 'active', 'on_site', 'professional', true
        ) RETURNING id INTO v_service_id;

        INSERT INTO service_details (
            service_id, category, sub_category, name, price, currency, pricing_type, duration, is_available, sort_order, attributes, business_rules
        )
        SELECT
            v_service_id, 'treatment',
            unnest(ARRAY['Consultation', 'Therapy', 'Therapy', 'Follow-up', 'Therapy', 'Specialized']),
            unnest(ARRAY[
                '{"en": "Initial Consultation", "zh": "初诊咨询"}',
                '{"en": "Massage Therapy", "zh": "按摩理疗"}',
                '{"en": "Acupuncture Session", "zh": "针灸治疗"}',
                '{"en": "Follow-up Visit", "zh": "复诊"}',
                '{"en": "Physiotherapy Session", "zh": "物理治疗"}',
                '{"en": "Chiropractic Adjustment", "zh": "脊椎调整"}'
            ]::jsonb[]),
            unnest(ARRAY[80.00, 120.00, 100.00, 60.00, 110.00, 90.00]),
            'CAD', 'fixed',
            unnest(ARRAY['30 minutes'::interval, '60 minutes'::interval, '45 minutes'::interval, '20 minutes'::interval, '50 minutes'::interval, '30 minutes'::interval]),
            true, generate_series(1, 6), '{}'::jsonb, '{}'::jsonb;

        RAISE NOTICE 'Created Health Service with % treatments', 6;
    END IF;
END $$;

-- ============================================
-- STEP 4: 验证创建的数据
-- ============================================

-- 查看所有创建的services
SELECT
    s.id,
    s.title->>'en' as service_title,
    s.category_level1_id,
    p.display_name->>'en' as provider_name,
    p.rating as provider_rating,
    s.status,
    COUNT(sd.id) as detail_count
FROM services s
LEFT JOIN provider_profiles p ON p.id = s.provider_id
LEFT JOIN service_details sd ON sd.service_id = s.id
WHERE p.display_name->>'en' IN (
    'Golden Wok Restaurant',
    'Sparkle Clean Services',
    'Tool Rental Pro',
    'English Language Academy',
    'Wellness Clinic'
)
GROUP BY s.id, s.title, s.category_level1_id, p.display_name, p.rating, s.status
ORDER BY s.category_level1_id;

-- 查看service_details详情
SELECT
    s.title->>'en' as service_title,
    sd.category,
    sd.sub_category,
    sd.name->>'en' as item_name,
    sd.price,
    sd.currency,
    sd.current_stock,
    sd.is_available
FROM service_details sd
JOIN services s ON s.id = sd.service_id
WHERE sd.category IN ('menu_item', 'service_package', 'rental_item', 'course', 'treatment')
ORDER BY s.title, sd.category, sd.sort_order;

-- ============================================
-- STEP 5: 获取Service IDs (用于App测试)
-- ============================================

SELECT
    s.category_level1_id,
    CASE
        WHEN s.category_level1_id = 1010000 THEN 'Food (美食天地)'
        WHEN s.category_level1_id = 1020000 THEN 'Home Services (家政到家)'
        WHEN s.category_level1_id = 1040000 THEN 'Rental (共享乐园)'
        WHEN s.category_level1_id = 1050000 THEN 'Education (学习课堂)'
        WHEN s.category_level1_id = 1060000 THEN 'Health (生活帮忙)'
    END as category_name,
    s.id as service_id,
    s.title->>'en' as service_title
FROM services s
WHERE s.category_level1_id IN (1010000, 1020000, 1040000, 1050000, 1060000)
ORDER BY s.category_level1_id;
