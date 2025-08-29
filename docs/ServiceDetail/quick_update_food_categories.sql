-- =====================================================
-- JinBean Platform - 美食天地二级目录快速更新脚本
-- 简化版本，专注于核心分类更新
-- =====================================================

-- 1. 获取美食天地一级分类ID
DO $$
DECLARE
    food_category_id INTEGER;
BEGIN
    -- 获取或创建美食天地一级分类
    SELECT id INTO food_category_id
    FROM ref_codes 
    WHERE type_code = 'SERVICE_TYPE' 
        AND level = 1 
        AND (name->>'zh' = '美食天地' OR name->>'en' = 'Food World');
    
    -- 如果不存在，创建美食天地一级分类
    IF food_category_id IS NULL THEN
        INSERT INTO ref_codes (
            type_code, level, parent_id, name, extra_data, sort_order, status, created_at, updated_at
        ) VALUES (
            'SERVICE_TYPE', 1, NULL,
            '{"zh": "美食天地", "en": "Food World"}',
            '{"icon": "restaurant", "color": "#4CAF50"}',
            1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        ) RETURNING id INTO food_category_id;
    END IF;
    
    -- 2. 删除现有美食二级分类
    DELETE FROM ref_codes 
    WHERE type_code = 'SERVICE_TYPE' 
        AND level = 2 
        AND parent_id = food_category_id;
    
    -- 3. 插入新的美食二级分类
    INSERT INTO ref_codes (type_code, level, parent_id, name, extra_data, sort_order, status, created_at, updated_at) VALUES 
    ('SERVICE_TYPE', 2, food_category_id, '{"zh": "外卖配送", "en": "Food Delivery"}', '{"icon": "delivery_dining", "color": "#FF9800"}', 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('SERVICE_TYPE', 2, food_category_id, '{"zh": "上门烹饪", "en": "In-Home Cooking"}', '{"icon": "home_repair_service", "color": "#2196F3"}', 2, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('SERVICE_TYPE', 2, food_category_id, '{"zh": "餐厅预订", "en": "Restaurant Booking"}', '{"icon": "restaurant_menu", "color": "#9C27B0"}', 3, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('SERVICE_TYPE', 2, food_category_id, '{"zh": "美食代购", "en": "Food Shopping"}', '{"icon": "shopping_cart", "color": "#FF5722"}', 4, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('SERVICE_TYPE', 2, food_category_id, '{"zh": "活动餐饮", "en": "Event Catering"}', '{"icon": "event", "color": "#E91E63"}', 5, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('SERVICE_TYPE', 2, food_category_id, '{"zh": "甜品饮品", "en": "Desserts & Drinks"}', '{"icon": "cake", "color": "#FFC107"}', 6, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('SERVICE_TYPE', 2, food_category_id, '{"zh": "其它", "en": "Others"}', '{"icon": "more_horiz", "color": "#9E9E9E"}', 7, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    
    RAISE NOTICE '美食天地二级分类更新完成，共插入7个分类';
END $$;

-- 4. 验证结果
SELECT 
    rc1.name->>'zh' as "一级分类",
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
