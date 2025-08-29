-- =====================================================
-- JinBean Platform - 美食天地分类安全更新脚本 V2
-- 使用现有code，只更新名称和描述
-- =====================================================

-- 1. 获取美食天地一级分类ID
DO $$
DECLARE
    food_category_id INTEGER;
BEGIN
    -- 获取美食天地一级分类ID
    SELECT id INTO food_category_id
    FROM ref_codes 
    WHERE type_code = 'SERVICE_TYPE' 
        AND level = 1 
        AND (name->>'zh' = '美食天地' OR name->>'en' = 'Food World');
    
    RAISE NOTICE '美食天地一级分类ID: %', food_category_id;
    
    -- 2. 更新现有的5个分类，保持原有code不变
    
    -- 更新 1010100: 居家美食 -> 外卖配送 (保持原有code: HOME_COOKED)
    UPDATE ref_codes 
    SET 
        name = '{"zh": "外卖配送", "en": "Food Delivery"}',
        extra_data = '{"icon": "delivery_dining", "color": "#FF9800", "description_zh": "快速配送各种美食，包括中餐、西餐、日韩料理等", "description_en": "Fast delivery of various cuisines including Chinese, Western, Japanese, Korean"}',
        sort_order = 1,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = 1010100;
    
    -- 更新 1010200: 定制美食 -> 上门烹饪 (保持原有code: CUSTOM_CATERING)
    UPDATE ref_codes 
    SET 
        name = '{"zh": "上门烹饪", "en": "In-Home Cooking"}',
        extra_data = '{"icon": "home_repair_service", "color": "#2196F3", "description_zh": "专业厨师上门服务，提供家常菜制作、私厨服务等", "description_en": "Professional chefs provide in-home cooking services, home-style meals, private chef services"}',
        sort_order = 2,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = 1010200;
    
    -- 更新 1010300: 世界美食 -> 餐厅预订 (保持原有code: WORLD_CUISINE)
    UPDATE ref_codes 
    SET 
        name = '{"zh": "餐厅预订", "en": "Restaurant Booking"}',
        extra_data = '{"icon": "restaurant_menu", "color": "#9C27B0", "description_zh": "预订高档餐厅、特色餐厅、网红餐厅等", "description_en": "Book fine dining, specialty restaurants, popular restaurants"}',
        sort_order = 3,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = 1010300;
    
    -- 更新 1010400: 速食代购 -> 美食代购 (保持原有code: QUICK_EATS)
    UPDATE ref_codes 
    SET 
        name = '{"zh": "美食代购", "en": "Food Shopping"}',
        extra_data = '{"icon": "shopping_cart", "color": "#FF5722", "description_zh": "代购进口食品、地方特产、特色小吃、生鲜配送等", "description_en": "Purchase imported foods, local specialties, unique snacks, fresh delivery"}',
        sort_order = 4,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = 1010400;
    
    -- 更新 1010500: 其它 -> 活动餐饮 (保持原有code: FOOD_COURT_OTHER)
    UPDATE ref_codes 
    SET 
        name = '{"zh": "活动餐饮", "en": "Event Catering"}',
        extra_data = '{"icon": "event", "color": "#E91E63", "description_zh": "提供婚礼宴席、公司年会、生日派对、节日聚餐等服务", "description_en": "Wedding banquets, corporate events, birthday parties, holiday gatherings"}',
        sort_order = 5,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = 1010500;
    
    -- 3. 添加新的分类（甜品饮品）
    INSERT INTO ref_codes (
        id, type_code, level, parent_id, code, name, extra_data, sort_order, status, created_at, updated_at
    ) VALUES (
        1010600, 'SERVICE_TYPE', 2, food_category_id, 'DESSERTS_DRINKS',
        '{"zh": "甜品饮品", "en": "Desserts & Drinks"}',
        '{"icon": "cake", "color": "#FFC107", "description_zh": "提供各种甜品、饮品、咖啡、茶类、健康饮品等", "description_en": "Various desserts, beverages, coffee, tea, healthy drinks and more"}',
        6, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    );
    
    -- 4. 添加其它分类
    INSERT INTO ref_codes (
        id, type_code, level, parent_id, code, name, extra_data, sort_order, status, created_at, updated_at
    ) VALUES (
        1010700, 'SERVICE_TYPE', 2, food_category_id, 'FOOD_OTHERS',
        '{"zh": "其它", "en": "Others"}',
        '{"icon": "more_horiz", "color": "#9E9E9E", "description_zh": "其他美食相关服务", "description_en": "Other food-related services"}',
        7, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    );
    
    RAISE NOTICE '美食天地二级分类更新完成！';
    RAISE NOTICE '更新了5个现有分类，新增了2个分类';
    RAISE NOTICE '最终分类：外卖配送、上门烹饪、餐厅预订、美食代购、活动餐饮、甜品饮品、其它';
END $$;

-- 5. 验证更新结果
SELECT 
    rc1.name->>'zh' as "一级分类",
    rc2.id as "分类ID",
    rc2.code as "分类代码",
    rc2.name->>'zh' as "二级分类",
    rc2.sort_order as "排序",
    rc2.extra_data->>'icon' as "图标",
    rc2.extra_data->>'color' as "颜色"
FROM ref_codes rc1
LEFT JOIN ref_codes rc2 ON rc1.id = rc2.parent_id
WHERE rc1.type_code = 'SERVICE_TYPE' 
    AND rc1.level = 1 
    AND (rc1.name->>'zh' = '美食天地' OR rc1.name->>'en' = 'Food World')
ORDER BY rc2.sort_order;

-- 6. 输出完成信息
SELECT 
    '美食天地分类安全更新完成' as status,
    COUNT(*) as total_categories,
    COUNT(CASE WHEN level = 1 THEN 1 END) as level1_count,
    COUNT(CASE WHEN level = 2 THEN 1 END) as level2_count
FROM ref_codes 
WHERE type_code = 'SERVICE_TYPE' 
    AND (name->>'zh' LIKE '%美食%' OR name->>'en' LIKE '%Food%');
