-- Service Detail表重构 - 测试数据脚本
-- 版本: v1.0
-- 创建日期: 2025-01-08
-- 描述: 为重构后的service_details表创建测试数据，展示多子服务功能

-- ========================================
-- 测试场景1: 餐饮服务 - 菜单系统
-- ========================================

-- 假设我们有一个餐厅服务ID
DO $$
DECLARE
    restaurant_service_id uuid;
BEGIN
    -- 获取一个现有的餐饮服务ID，如果没有则创建一个
    SELECT id INTO restaurant_service_id 
    FROM services 
    WHERE category_level1_id = '1010000' 
    LIMIT 1;
    
    IF restaurant_service_id IS NULL THEN
        -- 创建一个测试餐厅服务
        INSERT INTO services (
            id, provider_id, title, description, category_level1_id, 
            status, created_at, updated_at
        ) VALUES (
            gen_random_uuid(),
            '00000000-0000-0000-0000-000000000001',
            '{"en": "Golden Dragon Restaurant", "zh": "金龙餐厅"}',
            '{"en": "Authentic Chinese cuisine with traditional flavors", "zh": "正宗中式料理，传统风味"}',
            '1010000',
            'active',
            NOW(),
            NOW()
        ) RETURNING id INTO restaurant_service_id;
    END IF;
    
    -- 添加菜单项目
    INSERT INTO service_details (
        service_id, category, sub_category, detail_name, 
        price, currency, attributes, business_rules, sort_order
    ) VALUES
    -- 开胃菜
    (restaurant_service_id, 'menu_item', 'appetizer', 
     '{"en": "Spring Rolls", "zh": "春卷"}', 8.99, 'CAD',
     '{"vegetarian": true, "spicy_level": 0, "preparation_time": 10}',
     '{"min_order": 1, "available_hours": "11:00-22:00"}', 1),
     
    (restaurant_service_id, 'menu_item', 'appetizer', 
     '{"en": "Dumplings (6pcs)", "zh": "饺子(6个)"}', 12.99, 'CAD',
     '{"vegetarian": false, "spicy_level": 0, "preparation_time": 15}',
     '{"min_order": 1, "available_hours": "11:00-22:00"}', 2),
     
    -- 主菜
    (restaurant_service_id, 'menu_item', 'main_course', 
     '{"en": "Sweet and Sour Pork", "zh": "糖醋里脊"}', 18.99, 'CAD',
     '{"vegetarian": false, "spicy_level": 1, "preparation_time": 20}',
     '{"min_order": 1, "popular": true}', 3),
     
    (restaurant_service_id, 'menu_item', 'main_course', 
     '{"en": "Mapo Tofu", "zh": "麻婆豆腐"}', 16.99, 'CAD',
     '{"vegetarian": true, "spicy_level": 3, "preparation_time": 15}',
     '{"min_order": 1, "chef_special": true}', 4),
     
    -- 甜品
    (restaurant_service_id, 'menu_item', 'dessert', 
     '{"en": "Mango Pudding", "zh": "芒果布丁"}', 6.99, 'CAD',
     '{"vegetarian": true, "spicy_level": 0, "preparation_time": 5}',
     '{"min_order": 1, "seasonal": false}', 5);
     
    RAISE NOTICE '餐厅菜单数据已添加，服务ID: %', restaurant_service_id;
END $$;

-- ========================================
-- 测试场景2: 共享租赁 - 库存系统
-- ========================================

DO $$
DECLARE
    rental_service_id uuid;
BEGIN
    -- 获取一个现有的共享服务ID，如果没有则创建一个
    SELECT id INTO rental_service_id 
    FROM services 
    WHERE category_level1_id = '1040000' 
    LIMIT 1;
    
    IF rental_service_id IS NULL THEN
        -- 创建一个测试租赁服务
        INSERT INTO services (
            id, provider_id, title, description, category_level1_id, 
            status, created_at, updated_at
        ) VALUES (
            gen_random_uuid(),
            '00000000-0000-0000-0000-000000000001',
            '{"en": "Pro Tools Rental", "zh": "专业工具租赁"}',
            '{"en": "Professional tools for all your DIY projects", "zh": "专业工具满足您的DIY项目需求"}',
            '1040000',
            'active',
            NOW(),
            NOW()
        ) RETURNING id INTO rental_service_id;
    END IF;
    
    -- 添加租赁物品
    INSERT INTO service_details (
        service_id, category, sub_category, detail_name, 
        price, currency, current_stock, max_stock, 
        attributes, business_rules, sort_order
    ) VALUES
    -- 电动工具
    (rental_service_id, 'rental_item', 'power_tools', 
     '{"en": "Cordless Drill", "zh": "无线电钻"}', 25.00, 'CAD', 8, 10,
     '{"brand": "DeWalt", "voltage": "20V", "condition": "excellent"}',
     '{"rental_unit": "day", "min_rental": 1, "deposit": 50, "damage_fee": 200}', 1),
     
    (rental_service_id, 'rental_item', 'power_tools', 
     '{"en": "Circular Saw", "zh": "圆锯"}', 35.00, 'CAD', 5, 8,
     '{"brand": "Makita", "blade_size": "7.25 inch", "condition": "good"}',
     '{"rental_unit": "day", "min_rental": 1, "deposit": 100, "safety_training": true}', 2),
     
    -- 手动工具
    (rental_service_id, 'rental_item', 'hand_tools', 
     '{"en": "Tool Set (50pcs)", "zh": "工具套装(50件)"}', 15.00, 'CAD', 12, 15,
     '{"brand": "Craftsman", "pieces": 50, "case_included": true}',
     '{"rental_unit": "day", "min_rental": 1, "deposit": 30}', 3),
     
    -- 测量工具
    (rental_service_id, 'rental_item', 'measuring_tools', 
     '{"en": "Laser Level", "zh": "激光水平仪"}', 20.00, 'CAD', 3, 6,
     '{"brand": "Bosch", "range": "30ft", "accuracy": "±1/8 inch"}',
     '{"rental_unit": "day", "min_rental": 1, "deposit": 75, "calibration_date": "2024-12-01"}', 4);
     
    RAISE NOTICE '租赁工具数据已添加，服务ID: %', rental_service_id;
END $$;

-- ========================================
-- 测试场景3: 教育培训 - 课程模块
-- ========================================

DO $$
DECLARE
    education_service_id uuid;
BEGIN
    -- 获取一个现有的教育服务ID，如果没有则创建一个
    SELECT id INTO education_service_id 
    FROM services 
    WHERE category_level1_id = '1050000' 
    LIMIT 1;
    
    IF education_service_id IS NULL THEN
        -- 创建一个测试教育服务
        INSERT INTO services (
            id, provider_id, title, description, category_level1_id, 
            status, created_at, updated_at
        ) VALUES (
            gen_random_uuid(),
            '00000000-0000-0000-0000-000000000001',
            '{"en": "Web Development Bootcamp", "zh": "网页开发训练营"}',
            '{"en": "Comprehensive web development training program", "zh": "全面的网页开发培训课程"}',
            '1050000',
            'active',
            NOW(),
            NOW()
        ) RETURNING id INTO education_service_id;
    END IF;
    
    -- 添加课程模块
    INSERT INTO service_details (
        service_id, category, sub_category, detail_name, 
        price, currency, duration, attributes, business_rules, sort_order
    ) VALUES
    -- 基础课程
    (education_service_id, 'course_module', 'beginner', 
     '{"en": "HTML/CSS Fundamentals", "zh": "HTML/CSS基础"}', 299.00, 'CAD', '20 hours',
     '{"difficulty": "beginner", "certificate": true, "online": true, "language": "en"}',
     '{"prerequisites": [], "duration_weeks": 4, "class_size": 20}', 1),
     
    (education_service_id, 'course_module', 'beginner', 
     '{"en": "JavaScript Basics", "zh": "JavaScript基础"}', 399.00, 'CAD', '30 hours',
     '{"difficulty": "beginner", "certificate": true, "online": true, "language": "en"}',
     '{"prerequisites": ["HTML/CSS"], "duration_weeks": 6, "class_size": 15}', 2),
     
    -- 中级课程
    (education_service_id, 'course_module', 'intermediate', 
     '{"en": "React.js Development", "zh": "React.js开发"}', 599.00, 'CAD', '40 hours',
     '{"difficulty": "intermediate", "certificate": true, "online": true, "project_based": true}',
     '{"prerequisites": ["JavaScript"], "duration_weeks": 8, "class_size": 12}', 3),
     
    (education_service_id, 'course_module', 'intermediate', 
     '{"en": "Node.js Backend", "zh": "Node.js后端开发"}', 699.00, 'CAD', '45 hours',
     '{"difficulty": "intermediate", "certificate": true, "online": true, "project_based": true}',
     '{"prerequisites": ["JavaScript"], "duration_weeks": 9, "class_size": 10}', 4),
     
    -- 高级课程
    (education_service_id, 'course_module', 'advanced', 
     '{"en": "Full Stack Project", "zh": "全栈项目实战"}', 999.00, 'CAD', '60 hours',
     '{"difficulty": "advanced", "certificate": true, "mentorship": true, "portfolio": true}',
     '{"prerequisites": ["React.js", "Node.js"], "duration_weeks": 12, "class_size": 8}', 5);
     
    RAISE NOTICE '教育课程数据已添加，服务ID: %', education_service_id;
END $$;

-- ========================================
-- 数据验证查询
-- ========================================

-- 查看所有测试数据概览
SELECT 
    s.title->>'zh' as service_name,
    s.category_level1_id,
    sd.category,
    sd.sub_category,
    sd.detail_name->>'zh' as item_name,
    sd.price,
    sd.current_stock,
    sd.sort_order
FROM service_details sd
JOIN services s ON sd.service_id = s.id
WHERE sd.category != 'main'
ORDER BY s.title->>'zh', sd.sort_order;

-- 按行业统计子服务数量
SELECT 
    s.category_level1_id,
    CASE s.category_level1_id
        WHEN '1010000' THEN '餐饮服务'
        WHEN '1040000' THEN '共享租赁' 
        WHEN '1050000' THEN '教育培训'
        ELSE '其他'
    END as industry_name,
    COUNT(sd.id) as sub_service_count,
    COUNT(DISTINCT sd.sub_category) as sub_category_count
FROM service_details sd
JOIN services s ON sd.service_id = s.id
WHERE sd.category != 'main'
GROUP BY s.category_level1_id
ORDER BY sub_service_count DESC;

-- 库存状态报告（仅租赁物品）
SELECT 
    sd.detail_name->>'zh' as item_name,
    sd.current_stock,
    sd.max_stock,
    ROUND((sd.current_stock::numeric / sd.max_stock::numeric * 100), 2) as stock_percentage,
    CASE 
        WHEN sd.current_stock = 0 THEN '缺货'
        WHEN sd.current_stock < sd.max_stock * 0.2 THEN '库存不足'
        WHEN sd.current_stock < sd.max_stock * 0.5 THEN '库存正常'
        ELSE '库存充足'
    END as stock_status
FROM service_details sd
JOIN services s ON sd.service_id = s.id
WHERE sd.category = 'rental_item' 
  AND sd.current_stock IS NOT NULL 
  AND sd.max_stock IS NOT NULL
ORDER BY stock_percentage ASC;

-- 价格分析
SELECT 
    sd.category,
    sd.sub_category,
    COUNT(*) as item_count,
    MIN(sd.price) as min_price,
    AVG(sd.price) as avg_price,
    MAX(sd.price) as max_price,
    sd.currency
FROM service_details sd
WHERE sd.category != 'main' AND sd.price IS NOT NULL
GROUP BY sd.category, sd.sub_category, sd.currency
ORDER BY avg_price DESC;

COMMIT; 