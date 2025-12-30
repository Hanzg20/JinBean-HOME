-- ============================================
-- Service Details Test Data Generator
-- ============================================
-- This script helps you create test data for the 5 industry-specific tabs
-- by first checking for existing services in your database

-- ============================================
-- STEP 1: Find Existing Services
-- ============================================

-- Query existing services by category
SELECT
    id,
    title,
    category_level1_id,
    CASE
        WHEN category_level1_id::text LIKE '1010%' THEN 'Food (美食天地)'
        WHEN category_level1_id::text LIKE '1020%' THEN 'Home Services (家政到家)'
        WHEN category_level1_id::text LIKE '1030%' THEN 'Transportation (出行广场)'
        WHEN category_level1_id::text LIKE '1040%' THEN 'Rental (共享乐园)'
        WHEN category_level1_id::text LIKE '1050%' THEN 'Education (学习课堂)'
        WHEN category_level1_id::text LIKE '1060%' THEN 'Life Help (生活帮忙)'
        ELSE 'Other'
    END as category_type
FROM services
WHERE category_level1_id IN (1010000, 1020000, 1040000, 1050000, 1060000)
ORDER BY category_level1_id, created_at DESC;

-- ============================================
-- STEP 2: Insert Test Data (Replace service_id values)
-- ============================================

-- 📝 INSTRUCTIONS:
-- 1. Run the query above to find service IDs
-- 2. Replace the service_id values below with actual IDs from your database
-- 3. Execute the INSERT statements

-- ============================================
-- 1. MENU TAB - Food Services (1010000)
-- ============================================
-- category: 'menu_item'

-- Example: Replace 'your-food-service-id-here' with actual service ID
INSERT INTO service_details (
    service_id,
    category,
    sub_category,
    name,
    price,
    currency,
    pricing_type,
    duration,
    is_available,
    sort_order,
    attributes,
    business_rules
)
SELECT
    'your-food-service-id-here' as service_id,
    'menu_item' as category,
    unnest(ARRAY['Appetizer', 'Appetizer', 'Appetizer', 'Main Course', 'Main Course', 'Main Course', 'Dessert', 'Dessert']) as sub_category,
    unnest(ARRAY[
        '{"en": "Spring Rolls", "zh": "春卷"}',
        '{"en": "Fried Dumplings", "zh": "煎饺"}',
        '{"en": "Edamame", "zh": "毛豆"}',
        '{"en": "Beef Noodle Soup", "zh": "牛肉面"}',
        '{"en": "Kung Pao Chicken", "zh": "宫保鸡丁"}',
        '{"en": "Sweet and Sour Pork", "zh": "糖醋排骨"}',
        '{"en": "Mango Sticky Rice", "zh": "芒果糯米饭"}',
        '{"en": "Sesame Balls", "zh": "芝麻球"}'
    ]::jsonb[]) as name,
    unnest(ARRAY[8.99, 9.99, 5.99, 15.99, 14.99, 16.99, 6.99, 4.99]) as price,
    'CAD' as currency,
    'fixed' as pricing_type,
    unnest(ARRAY['15 min', '15 min', '10 min', '25 min', '20 min', '20 min', '10 min', '10 min']) as duration,
    true as is_available,
    generate_series(1, 8) as sort_order,
    '{}'::jsonb as attributes,
    '{}'::jsonb as business_rules
WHERE EXISTS (SELECT 1 FROM services WHERE id = 'your-food-service-id-here');

-- ============================================
-- 2. SERVICES TAB - Home Services (1020000)
-- ============================================
-- category: 'service_package'

INSERT INTO service_details (
    service_id,
    category,
    sub_category,
    name,
    price,
    currency,
    pricing_type,
    duration,
    is_available,
    sort_order,
    attributes,
    business_rules
)
SELECT
    'your-home-service-id-here' as service_id,
    'service_package' as category,
    unnest(ARRAY['Basic', 'Premium', 'Specialized', 'Specialized', 'Premium']) as sub_category,
    unnest(ARRAY[
        '{"en": "Regular Cleaning", "zh": "常规清洁"}',
        '{"en": "Deep Cleaning", "zh": "深度清洁"}',
        '{"en": "Window Cleaning", "zh": "窗户清洁"}',
        '{"en": "Carpet Cleaning", "zh": "地毯清洁"}',
        '{"en": "Move-in/Move-out Cleaning", "zh": "搬家清洁"}'
    ]::jsonb[]) as name,
    unnest(ARRAY[80.00, 120.00, 60.00, 90.00, 150.00]) as price,
    'CAD' as currency,
    'fixed' as pricing_type,
    unnest(ARRAY['2-3 hours', '3-4 hours', '1-2 hours', '2-3 hours', '4-5 hours']) as duration,
    true as is_available,
    generate_series(1, 5) as sort_order,
    '{}'::jsonb as attributes,
    '{}'::jsonb as business_rules
WHERE EXISTS (SELECT 1 FROM services WHERE id = 'your-home-service-id-here');

-- ============================================
-- 3. INVENTORY TAB - Rental Services (1040000)
-- ============================================
-- category: 'rental_item'

INSERT INTO service_details (
    service_id,
    category,
    sub_category,
    name,
    price,
    currency,
    pricing_type,
    duration,
    is_available,
    sort_order,
    current_stock,
    max_stock,
    attributes,
    business_rules
)
SELECT
    'your-rental-service-id-here' as service_id,
    'rental_item' as category,
    unnest(ARRAY['Power Tools', 'Power Tools', 'Equipment', 'Equipment', 'Hand Tools', 'Power Tools']) as sub_category,
    unnest(ARRAY[
        '{"en": "Power Drill", "zh": "电钻"}',
        '{"en": "Circular Saw", "zh": "圆锯"}',
        '{"en": "Ladder - 6ft", "zh": "梯子 - 6英尺"}',
        '{"en": "Ladder - 12ft", "zh": "梯子 - 12英尺"}',
        '{"en": "Professional Tool Set", "zh": "专业工具套装"}',
        '{"en": "Pressure Washer", "zh": "高压清洗机"}'
    ]::jsonb[]) as name,
    unnest(ARRAY[25.00, 30.00, 15.00, 20.00, 40.00, 45.00]) as price,
    'CAD' as currency,
    'per_day' as pricing_type,
    'per day' as duration,
    true as is_available,
    generate_series(1, 6) as sort_order,
    unnest(ARRAY[5, 3, 8, 4, 2, 0]) as current_stock,
    unnest(ARRAY[10, 5, 10, 6, 4, 2]) as max_stock,
    '{}'::jsonb as attributes,
    '{}'::jsonb as business_rules
WHERE EXISTS (SELECT 1 FROM services WHERE id = 'your-rental-service-id-here');

-- ============================================
-- 4. COURSES TAB - Education Services (1050000)
-- ============================================
-- category: 'course'

INSERT INTO service_details (
    service_id,
    category,
    sub_category,
    name,
    price,
    currency,
    pricing_type,
    duration,
    is_available,
    sort_order,
    attributes,
    business_rules
)
SELECT
    'your-education-service-id-here' as service_id,
    'course' as category,
    unnest(ARRAY['Beginner', 'Intermediate', 'Advanced', 'Specialized', 'Specialized']) as sub_category,
    unnest(ARRAY[
        '{"en": "English Beginner Level", "zh": "英语初级课程"}',
        '{"en": "English Intermediate Level", "zh": "英语中级课程"}',
        '{"en": "English Advanced Level", "zh": "英语高级课程"}',
        '{"en": "Business English", "zh": "商务英语"}',
        '{"en": "IELTS Preparation", "zh": "雅思备考"}'
    ]::jsonb[]) as name,
    unnest(ARRAY[200.00, 350.00, 500.00, 400.00, 450.00]) as price,
    'CAD' as currency,
    'fixed' as pricing_type,
    unnest(ARRAY[
        '8 weeks, 2 hours/week',
        '10 weeks, 3 hours/week',
        '12 weeks, 3 hours/week',
        '8 weeks, 2 hours/week',
        '10 weeks, 3 hours/week'
    ]) as duration,
    true as is_available,
    generate_series(1, 5) as sort_order,
    '{}'::jsonb as attributes,
    '{}'::jsonb as business_rules
WHERE EXISTS (SELECT 1 FROM services WHERE id = 'your-education-service-id-here');

-- ============================================
-- 5. TREATMENTS TAB - Health/Life Help Services (1060000)
-- ============================================
-- category: 'treatment'

INSERT INTO service_details (
    service_id,
    category,
    sub_category,
    name,
    price,
    currency,
    pricing_type,
    duration,
    is_available,
    sort_order,
    attributes,
    business_rules
)
SELECT
    'your-health-service-id-here' as service_id,
    'treatment' as category,
    unnest(ARRAY['Consultation', 'Therapy', 'Therapy', 'Follow-up', 'Therapy', 'Specialized']) as sub_category,
    unnest(ARRAY[
        '{"en": "Initial Consultation", "zh": "初诊咨询"}',
        '{"en": "Massage Therapy", "zh": "按摩理疗"}',
        '{"en": "Acupuncture Session", "zh": "针灸治疗"}',
        '{"en": "Follow-up Visit", "zh": "复诊"}',
        '{"en": "Physiotherapy Session", "zh": "物理治疗"}',
        '{"en": "Chiropractic Adjustment", "zh": "脊椎调整"}'
    ]::jsonb[]) as name,
    unnest(ARRAY[80.00, 120.00, 100.00, 60.00, 110.00, 90.00]) as price,
    'CAD' as currency,
    'fixed' as pricing_type,
    unnest(ARRAY['30 min', '60 min', '45 min', '20 min', '50 min', '30 min']) as duration,
    true as is_available,
    generate_series(1, 6) as sort_order,
    '{}'::jsonb as attributes,
    '{}'::jsonb as business_rules
WHERE EXISTS (SELECT 1 FROM services WHERE id = 'your-health-service-id-here');

-- ============================================
-- STEP 3: Verify the Data
-- ============================================

-- Check what was inserted
SELECT
    sd.service_id,
    s.title->>'en' as service_title,
    sd.category,
    sd.sub_category,
    sd.name->>'en' as item_name,
    sd.price,
    sd.currency,
    sd.duration,
    sd.current_stock,
    sd.is_available
FROM service_details sd
LEFT JOIN services s ON s.id = sd.service_id
WHERE sd.category IN ('menu_item', 'service_package', 'rental_item', 'course', 'treatment')
ORDER BY sd.category, sd.sort_order;

-- ============================================
-- HELPER SCRIPT: Create Services If None Exist
-- ============================================
-- If you don't have any services yet, use this to create test services first

-- Create a test food service
INSERT INTO services (
    title,
    description,
    price,
    currency,
    pricing_type,
    category_id,
    category_level1_id,
    category_level2_id,
    provider_id,
    status,
    service_delivery_method,
    service_area_codes,
    tags
) VALUES (
    '{"en": "Golden Wok Restaurant", "zh": "金锅餐厅"}',
    '{"en": "Authentic Chinese cuisine", "zh": "正宗中餐"}',
    0.00,
    'CAD',
    'menu_based',
    '1010101',
    1010000,
    1010100,
    'your-provider-id-here',  -- Replace with actual provider ID
    'active',
    'pickup',
    ARRAY['V6B'],
    ARRAY['chinese', 'restaurant', 'food']
) RETURNING id;

-- Create a test cleaning service
INSERT INTO services (
    title,
    description,
    price,
    currency,
    pricing_type,
    category_id,
    category_level1_id,
    category_level2_id,
    provider_id,
    status,
    service_delivery_method,
    service_area_codes,
    tags
) VALUES (
    '{"en": "Sparkle Clean", "zh": "清洁专家"}',
    '{"en": "Professional cleaning services", "zh": "专业清洁服务"}',
    80.00,
    'CAD',
    'package_based',
    '1020101',
    1020000,
    1020100,
    'your-provider-id-here',  -- Replace with actual provider ID
    'active',
    'onsite',
    ARRAY['V6B', 'V6C'],
    ARRAY['cleaning', 'home']
) RETURNING id;

-- Create a test rental service
INSERT INTO services (
    title,
    description,
    price,
    currency,
    pricing_type,
    category_id,
    category_level1_id,
    category_level2_id,
    provider_id,
    status,
    service_delivery_method,
    service_area_codes,
    tags
) VALUES (
    '{"en": "Tool Rental Pro", "zh": "工具租赁专家"}',
    '{"en": "Rent professional tools", "zh": "租赁专业工具"}',
    25.00,
    'CAD',
    'rental',
    '1040101',
    1040000,
    1040100,
    'your-provider-id-here',  -- Replace with actual provider ID
    'active',
    'pickup',
    ARRAY['V6B'],
    ARRAY['tools', 'rental']
) RETURNING id;

-- Create a test education service
INSERT INTO services (
    title,
    description,
    price,
    currency,
    pricing_type,
    category_id,
    category_level1_id,
    category_level2_id,
    provider_id,
    status,
    service_delivery_method,
    service_area_codes,
    tags
) VALUES (
    '{"en": "English Language Academy", "zh": "英语学院"}',
    '{"en": "Learn English with professionals", "zh": "专业英语教学"}',
    200.00,
    'CAD',
    'course_based',
    '1050102',
    1050000,
    1050100,
    'your-provider-id-here',  -- Replace with actual provider ID
    'active',
    'online',
    ARRAY['V6B'],
    ARRAY['english', 'education']
) RETURNING id;

-- Create a test health service
INSERT INTO services (
    title,
    description,
    price,
    currency,
    pricing_type,
    category_id,
    category_level1_id,
    category_level2_id,
    provider_id,
    status,
    service_delivery_method,
    service_area_codes,
    tags
) VALUES (
    '{"en": "Wellness Clinic", "zh": "健康诊所"}',
    '{"en": "Holistic health services", "zh": "全方位健康服务"}',
    80.00,
    'CAD',
    'session_based',
    '1060401',
    1060000,
    1060400,
    'your-provider-id-here',  -- Replace with actual provider ID
    'active',
    'onsite',
    ARRAY['V6B'],
    ARRAY['health', 'wellness']
) RETURNING id;
