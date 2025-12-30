-- ============================================
-- Service Details Test Data for Dynamic Tabs
-- ============================================
-- This script creates test data for all 5 industry-specific tabs:
-- 1. Menu Tab (Food - 1010000) - category: 'menu_item'
-- 2. Services Tab (Home Services - 1020000) - category: 'service_package'
-- 3. Inventory Tab (Rental - 1040000) - category: 'rental_item'
-- 4. Courses Tab (Education - 1050000) - category: 'course'
-- 5. Treatments Tab (Life Help - 1060000) - category: 'treatment'

-- ============================================
-- 1. MENU TAB TEST DATA (Food - 1010000)
-- ============================================
-- Note: Replace 'YOUR_FOOD_SERVICE_ID' with an actual service ID from category 1010000

-- Menu Items for a Restaurant
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
) VALUES
-- Appetizers
(
    'YOUR_FOOD_SERVICE_ID', -- Replace with actual service_id
    'menu_item',
    'Appetizer',
    '{"en": "Spring Rolls", "zh": "春卷"}'::jsonb,
    8.99,
    'CAD',
    'fixed',
    '15 min',
    true,
    1,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_FOOD_SERVICE_ID',
    'menu_item',
    'Appetizer',
    '{"en": "Fried Dumplings", "zh": "煎饺"}'::jsonb,
    9.99,
    'CAD',
    'fixed',
    '15 min',
    true,
    2,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_FOOD_SERVICE_ID',
    'menu_item',
    'Appetizer',
    '{"en": "Edamame", "zh": "毛豆"}'::jsonb,
    5.99,
    'CAD',
    'fixed',
    '10 min',
    true,
    3,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
),

-- Main Courses
(
    'YOUR_FOOD_SERVICE_ID',
    'menu_item',
    'Main Course',
    '{"en": "Beef Noodle Soup", "zh": "牛肉面"}'::jsonb,
    15.99,
    'CAD',
    'fixed',
    '25 min',
    true,
    4,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_FOOD_SERVICE_ID',
    'menu_item',
    'Main Course',
    '{"en": "Kung Pao Chicken", "zh": "宫保鸡丁"}'::jsonb,
    14.99,
    'CAD',
    'fixed',
    '20 min',
    true,
    5,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_FOOD_SERVICE_ID',
    'menu_item',
    'Main Course',
    '{"en": "Sweet and Sour Pork", "zh": "糖醋排骨"}'::jsonb,
    16.99,
    'CAD',
    'fixed',
    '20 min',
    true,
    6,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
),

-- Desserts
(
    'YOUR_FOOD_SERVICE_ID',
    'menu_item',
    'Dessert',
    '{"en": "Mango Sticky Rice", "zh": "芒果糯米饭"}'::jsonb,
    6.99,
    'CAD',
    'fixed',
    '10 min',
    true,
    7,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_FOOD_SERVICE_ID',
    'menu_item',
    'Dessert',
    '{"en": "Sesame Balls", "zh": "芝麻球"}'::jsonb,
    4.99,
    'CAD',
    'fixed',
    '10 min',
    true,
    8,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
);

-- ============================================
-- 2. SERVICES TAB TEST DATA (Home Services - 1020000)
-- ============================================
-- Note: Replace 'YOUR_HOME_SERVICE_ID' with an actual service ID from category 1020000

-- Service Packages for Cleaning Service
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
) VALUES
(
    'YOUR_HOME_SERVICE_ID', -- Replace with actual service_id
    'service_package',
    'Basic',
    '{"en": "Regular Cleaning", "zh": "常规清洁"}'::jsonb,
    80.00,
    'CAD',
    'fixed',
    '2-3 hours',
    true,
    1,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_HOME_SERVICE_ID',
    'service_package',
    'Premium',
    '{"en": "Deep Cleaning", "zh": "深度清洁"}'::jsonb,
    120.00,
    'CAD',
    'fixed',
    '3-4 hours',
    true,
    2,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_HOME_SERVICE_ID',
    'service_package',
    'Specialized',
    '{"en": "Window Cleaning", "zh": "窗户清洁"}'::jsonb,
    60.00,
    'CAD',
    'fixed',
    '1-2 hours',
    true,
    3,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_HOME_SERVICE_ID',
    'service_package',
    'Specialized',
    '{"en": "Carpet Cleaning", "zh": "地毯清洁"}'::jsonb,
    90.00,
    'CAD',
    'fixed',
    '2-3 hours',
    true,
    4,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_HOME_SERVICE_ID',
    'service_package',
    'Premium',
    '{"en": "Move-in/Move-out Cleaning", "zh": "搬家清洁"}'::jsonb,
    150.00,
    'CAD',
    'fixed',
    '4-5 hours',
    true,
    5,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
);

-- ============================================
-- 3. INVENTORY TAB TEST DATA (Rental - 1040000)
-- ============================================
-- Note: Replace 'YOUR_RENTAL_SERVICE_ID' with an actual service ID from category 1040000

-- Rental Items for Tool Rental Service
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
) VALUES
(
    'YOUR_RENTAL_SERVICE_ID', -- Replace with actual service_id
    'rental_item',
    'Power Tools',
    '{"en": "Power Drill", "zh": "电钻"}'::jsonb,
    25.00,
    'CAD',
    'per_day',
    'per day',
    true,
    1,
    5, -- 5 units available
    10, -- Maximum 10 units
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_RENTAL_SERVICE_ID',
    'rental_item',
    'Power Tools',
    '{"en": "Circular Saw", "zh": "圆锯"}'::jsonb,
    30.00,
    'CAD',
    'per_day',
    'per day',
    true,
    2,
    3,
    5,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_RENTAL_SERVICE_ID',
    'rental_item',
    'Equipment',
    '{"en": "Ladder - 6ft", "zh": "梯子 - 6英尺"}'::jsonb,
    15.00,
    'CAD',
    'per_day',
    'per day',
    true,
    3,
    8,
    10,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_RENTAL_SERVICE_ID',
    'rental_item',
    'Equipment',
    '{"en": "Ladder - 12ft", "zh": "梯子 - 12英尺"}'::jsonb,
    20.00,
    'CAD',
    'per_day',
    'per day',
    true,
    4,
    4,
    6,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_RENTAL_SERVICE_ID',
    'rental_item',
    'Hand Tools',
    '{"en": "Professional Tool Set", "zh": "专业工具套装"}'::jsonb,
    40.00,
    'CAD',
    'per_day',
    'per day',
    true,
    5,
    2,
    4,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_RENTAL_SERVICE_ID',
    'rental_item',
    'Power Tools',
    '{"en": "Pressure Washer", "zh": "高压清洗机"}'::jsonb,
    45.00,
    'CAD',
    'per_day',
    'per day',
    true,
    6,
    0, -- Currently rented out
    2,
    '{}'::jsonb,
    '{}'::jsonb
);

-- ============================================
-- 4. COURSES TAB TEST DATA (Education - 1050000)
-- ============================================
-- Note: Replace 'YOUR_EDUCATION_SERVICE_ID' with an actual service ID from category 1050000

-- Courses for a Language School
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
) VALUES
(
    'YOUR_EDUCATION_SERVICE_ID', -- Replace with actual service_id
    'course',
    'Beginner',
    '{"en": "English Beginner Level", "zh": "英语初级课程"}'::jsonb,
    200.00,
    'CAD',
    'fixed',
    '8 weeks, 2 hours/week',
    true,
    1,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_EDUCATION_SERVICE_ID',
    'course',
    'Intermediate',
    '{"en": "English Intermediate Level", "zh": "英语中级课程"}'::jsonb,
    350.00,
    'CAD',
    'fixed',
    '10 weeks, 3 hours/week',
    true,
    2,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_EDUCATION_SERVICE_ID',
    'course',
    'Advanced',
    '{"en": "English Advanced Level", "zh": "英语高级课程"}'::jsonb,
    500.00,
    'CAD',
    'fixed',
    '12 weeks, 3 hours/week',
    true,
    3,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_EDUCATION_SERVICE_ID',
    'course',
    'Specialized',
    '{"en": "Business English", "zh": "商务英语"}'::jsonb,
    400.00,
    'CAD',
    'fixed',
    '8 weeks, 2 hours/week',
    true,
    4,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_EDUCATION_SERVICE_ID',
    'course',
    'Specialized',
    '{"en": "IELTS Preparation", "zh": "雅思备考"}'::jsonb,
    450.00,
    'CAD',
    'fixed',
    '10 weeks, 3 hours/week',
    true,
    5,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
);

-- ============================================
-- 5. TREATMENTS TAB TEST DATA (Life Help - 1060000)
-- ============================================
-- Note: Replace 'YOUR_HEALTH_SERVICE_ID' with an actual service ID from category 1060000

-- Treatments for a Wellness Clinic
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
) VALUES
(
    'YOUR_HEALTH_SERVICE_ID', -- Replace with actual service_id
    'treatment',
    'Consultation',
    '{"en": "Initial Consultation", "zh": "初诊咨询"}'::jsonb,
    80.00,
    'CAD',
    'fixed',
    '30 min',
    true,
    1,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_HEALTH_SERVICE_ID',
    'treatment',
    'Therapy',
    '{"en": "Massage Therapy", "zh": "按摩理疗"}'::jsonb,
    120.00,
    'CAD',
    'fixed',
    '60 min',
    true,
    2,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_HEALTH_SERVICE_ID',
    'treatment',
    'Therapy',
    '{"en": "Acupuncture Session", "zh": "针灸治疗"}'::jsonb,
    100.00,
    'CAD',
    'fixed',
    '45 min',
    true,
    3,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_HEALTH_SERVICE_ID',
    'treatment',
    'Follow-up',
    '{"en": "Follow-up Visit", "zh": "复诊"}'::jsonb,
    60.00,
    'CAD',
    'fixed',
    '20 min',
    true,
    4,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_HEALTH_SERVICE_ID',
    'treatment',
    'Therapy',
    '{"en": "Physiotherapy Session", "zh": "物理治疗"}'::jsonb,
    110.00,
    'CAD',
    'fixed',
    '50 min',
    true,
    5,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
),
(
    'YOUR_HEALTH_SERVICE_ID',
    'treatment',
    'Specialized',
    '{"en": "Chiropractic Adjustment", "zh": "脊椎调整"}'::jsonb,
    90.00,
    'CAD',
    'fixed',
    '30 min',
    true,
    6,
    NULL,
    NULL,
    '{}'::jsonb,
    '{}'::jsonb
);

-- ============================================
-- USAGE INSTRUCTIONS
-- ============================================
/*
1. Find actual service IDs from your database:

   SELECT id, category_level1_id FROM services
   WHERE category_level1_id IN (1010000, 1020000, 1040000, 1050000, 1060000)
   LIMIT 5;

2. Replace the placeholder service IDs:
   - YOUR_FOOD_SERVICE_ID -> actual service from category 1010000
   - YOUR_HOME_SERVICE_ID -> actual service from category 1020000
   - YOUR_RENTAL_SERVICE_ID -> actual service from category 1040000
   - YOUR_EDUCATION_SERVICE_ID -> actual service from category 1050000
   - YOUR_HEALTH_SERVICE_ID -> actual service from category 1060000

3. Execute the INSERT statements for each category

4. Verify the data:

   SELECT service_id, category, sub_category, name, price
   FROM service_details
   WHERE category IN ('menu_item', 'service_package', 'rental_item', 'course', 'treatment')
   ORDER BY category, sort_order;

5. Test in the app by navigating to services from each category
*/
