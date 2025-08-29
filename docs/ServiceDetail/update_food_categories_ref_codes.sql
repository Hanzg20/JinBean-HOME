-- =====================================================
-- JinBean Platform - 美食天地二级目录更新脚本
-- 基于产品经理分析和竞品研究优化
-- =====================================================

-- 1. 首先检查当前美食相关的分类数据
SELECT 
    id, 
    name, 
    extra_data, 
    level, 
    parent_id, 
    sort_order,
    status
FROM ref_codes 
WHERE type_code = 'SERVICE_TYPE' 
    AND level IN (1, 2) 
    AND (name->>'zh' LIKE '%美食%' OR name->>'en' LIKE '%Food%')
ORDER BY level, sort_order;

-- 2. 更新现有的一级分类"美食天地"（如果存在）
UPDATE ref_codes 
SET 
    name = jsonb_build_object(
        'zh', '美食天地',
        'en', 'Food World',
        'ja', '美食世界',
        'ko', '음식 세계'
    ),
    extra_data = jsonb_build_object(
        'icon', 'restaurant',
        'color', '#4CAF50',
        'description_zh', '提供各种美食相关服务，包括外卖、上门烹饪、餐厅预订等',
        'description_en', 'Various food-related services including delivery, in-home cooking, restaurant booking',
        'keywords', '["美食", "餐饮", "外卖", "烹饪", "餐厅"]',
        'updated_at', CURRENT_TIMESTAMP
    ),
    updated_at = CURRENT_TIMESTAMP
WHERE type_code = 'SERVICE_TYPE' 
    AND level = 1 
    AND (name->>'zh' = '美食天地' OR name->>'en' = 'Food World');

-- 3. 如果美食天地一级分类不存在，则创建
INSERT INTO ref_codes (
    type_code, 
    level, 
    parent_id, 
    name, 
    extra_data, 
    sort_order, 
    status, 
    created_at, 
    updated_at
)
SELECT 
    'SERVICE_TYPE',
    1,
    NULL,
    jsonb_build_object(
        'zh', '美食天地',
        'en', 'Food World',
        'ja', '美食世界',
        'ko', '음식 세계'
    ),
    jsonb_build_object(
        'icon', 'restaurant',
        'color', '#4CAF50',
        'description_zh', '提供各种美食相关服务，包括外卖、上门烹饪、餐厅预订等',
        'description_en', 'Various food-related services including delivery, in-home cooking, restaurant booking',
        'keywords', '["美食", "餐饮", "外卖", "烹饪", "餐厅"]'
    ),
    1, -- 美食天地排在第一
    1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM ref_codes 
    WHERE type_code = 'SERVICE_TYPE' 
        AND level = 1 
        AND (name->>'zh' = '美食天地' OR name->>'en' = 'Food World')
);

-- 4. 获取美食天地一级分类的ID
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
    
    -- 5. 删除现有的美食二级分类（为重新创建做准备）
    DELETE FROM ref_codes 
    WHERE type_code = 'SERVICE_TYPE' 
        AND level = 2 
        AND parent_id = food_category_id;
    
    -- 6. 插入新的美食二级分类
    INSERT INTO ref_codes (
        type_code, 
        level, 
        parent_id, 
        name, 
        extra_data, 
        sort_order, 
        status, 
        created_at, 
        updated_at
    ) VALUES 
    -- 1. 外卖配送 (Food Delivery)
    (
        'SERVICE_TYPE',
        2,
        food_category_id,
        jsonb_build_object(
            'zh', '外卖配送',
            'en', 'Food Delivery',
            'ja', '出前配達',
            'ko', '음식 배달'
        ),
        jsonb_build_object(
            'icon', 'delivery_dining',
            'color', '#FF9800',
            'description_zh', '快速配送各种美食，包括中餐、西餐、日韩料理等',
            'description_en', 'Fast delivery of various cuisines including Chinese, Western, Japanese, Korean',
            'keywords', '["外卖", "配送", "中餐", "西餐", "日韩料理"]',
            'service_types', '["delivery", "takeout"]',
            'avg_delivery_time', '30-45分钟',
            'popular_cuisines', '["中餐", "西餐", "日韩料理", "东南亚菜"]'
        ),
        1,
        1,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    
    -- 2. 上门烹饪 (In-Home Cooking)
    (
        'SERVICE_TYPE',
        2,
        food_category_id,
        jsonb_build_object(
            'zh', '上门烹饪',
            'en', 'In-Home Cooking',
            'ja', '出張料理',
            'ko', '출장 요리'
        ),
        jsonb_build_object(
            'icon', 'home_repair_service',
            'color', '#2196F3',
            'description_zh', '专业厨师上门服务，提供家常菜制作、私厨服务等',
            'description_en', 'Professional chefs provide in-home cooking services, home-style meals, private chef services',
            'keywords', '["上门", "烹饪", "私厨", "家常菜", "节日大餐"]',
            'service_types', '["in_home", "private_chef", "catering"]',
            'avg_service_time', '2-4小时',
            'popular_services', '["家常菜制作", "私厨上门", "节日大餐", "商务宴请"]'
        ),
        2,
        1,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    
    -- 3. 餐厅预订 (Restaurant Booking)
    (
        'SERVICE_TYPE',
        2,
        food_category_id,
        jsonb_build_object(
            'zh', '餐厅预订',
            'en', 'Restaurant Booking',
            'ja', 'レストラン予約',
            'ko', '레스토랑 예약'
        ),
        jsonb_build_object(
            'icon', 'restaurant_menu',
            'color', '#9C27B0',
            'description_zh', '预订高档餐厅、特色餐厅、网红餐厅等',
            'description_en', 'Book fine dining, specialty restaurants, popular restaurants',
            'keywords', '["餐厅", "预订", "高档", "特色", "网红餐厅"]',
            'service_types', '["booking", "reservation", "fine_dining"]',
            'avg_booking_time', '提前1-7天',
            'popular_types', '["高档餐厅", "特色餐厅", "网红餐厅", "主题餐厅"]'
        ),
        3,
        1,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    
    -- 4. 美食代购 (Food Shopping)
    (
        'SERVICE_TYPE',
        2,
        food_category_id,
        jsonb_build_object(
            'zh', '美食代购',
            'en', 'Food Shopping',
            'ja', '食品代購',
            'ko', '음식 대구매'
        ),
        jsonb_build_object(
            'icon', 'shopping_cart',
            'color', '#FF5722',
            'description_zh', '代购进口食品、地方特产、特色小吃、生鲜配送等',
            'description_en', 'Purchase imported foods, local specialties, unique snacks, fresh delivery',
            'keywords', '["代购", "进口食品", "地方特产", "特色小吃", "生鲜"]',
            'service_types', '["shopping", "import", "specialty", "fresh_delivery"]',
            'avg_delivery_time', '1-3天',
            'popular_items', '["进口食品", "地方特产", "特色小吃", "生鲜配送"]'
        ),
        4,
        1,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    
    -- 5. 活动餐饮 (Event Catering)
    (
        'SERVICE_TYPE',
        2,
        food_category_id,
        jsonb_build_object(
            'zh', '活动餐饮',
            'en', 'Event Catering',
            'ja', 'イベントケータリング',
            'ko', '이벤트 케이터링'
        ),
        jsonb_build_object(
            'icon', 'event',
            'color', '#E91E63',
            'description_zh', '提供婚礼宴席、公司年会、生日派对、节日聚餐等服务',
            'description_en', 'Wedding banquets, corporate events, birthday parties, holiday gatherings',
            'keywords', '["活动", "餐饮", "婚礼", "年会", "生日派对"]',
            'service_types', '["catering", "events", "banquets", "parties"]',
            'avg_service_time', '4-8小时',
            'popular_events', '["婚礼宴席", "公司年会", "生日派对", "节日聚餐"]'
        ),
        5,
        1,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    
    -- 6. 烹饪教学 (Cooking Education)
    (
        'SERVICE_TYPE',
        2,
        food_category_id,
        jsonb_build_object(
            'zh', '烹饪教学',
            'en', 'Cooking Education',
            'ja', '料理教室',
            'ko', '요리 교육'
        ),
        jsonb_build_object(
            'icon', 'school',
            'color', '#607D8B',
            'description_zh', '在线教学、上门教学、体验课程、专业培训等',
            'description_en', 'Online classes, in-home teaching, experience courses, professional training',
            'keywords', '["烹饪", "教学", "在线", "上门", "体验课程"]',
            'service_types', '["education", "online", "in_home", "experience"]',
            'avg_class_time', '1-3小时',
            'popular_courses', '["在线教学", "上门教学", "体验课程", "专业培训"]'
        ),
        6,
        1,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    
    -- 7. 甜品饮品 (Desserts & Drinks)
    (
        'SERVICE_TYPE',
        2,
        food_category_id,
        jsonb_build_object(
            'zh', '甜品饮品',
            'en', 'Desserts & Drinks',
            'ja', 'デザート・ドリンク',
            'ko', '디저트・음료'
        ),
        jsonb_build_object(
            'icon', 'cake',
            'color', '#FFC107',
            'description_zh', '提供各种甜品、饮品、咖啡、茶类等',
            'description_en', 'Various desserts, beverages, coffee, tea and more',
            'keywords', '["甜品", "饮品", "咖啡", "茶", "蛋糕"]',
            'service_types', '["desserts", "beverages", "coffee", "tea"]',
            'avg_prep_time', '15-30分钟',
            'popular_items', '["蛋糕", "咖啡", "茶饮", "甜品", "果汁"]'
        ),
        7,
        1,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    
    -- 8. 健康饮食 (Healthy Eating)
    (
        'SERVICE_TYPE',
        2,
        food_category_id,
        jsonb_build_object(
            'zh', '健康饮食',
            'en', 'Healthy Eating',
            'ja', 'ヘルシー食事',
            'ko', '건강식단'
        ),
        jsonb_build_object(
            'icon', 'eco',
            'color', '#4CAF50',
            'description_zh', '提供健身餐、减肥餐、素食、有机食品等健康饮食服务',
            'description_en', 'Fitness meals, diet meals, vegetarian, organic food and healthy eating services',
            'keywords', '["健康", "健身餐", "减肥餐", "素食", "有机"]',
            'service_types', '["healthy", "fitness", "diet", "vegetarian", "organic"]',
            'avg_prep_time', '20-40分钟',
            'popular_types', '["健身餐", "减肥餐", "素食", "有机食品", "营养餐"]'
        ),
        8,
        1,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );
    
    RAISE NOTICE '美食天地二级分类更新完成，共插入8个分类';
END $$;

-- 7. 验证更新结果
SELECT 
    rc1.id as level1_id,
    rc1.name->>'zh' as level1_name,
    rc2.id as level2_id,
    rc2.name->>'zh' as level2_name,
    rc2.sort_order,
    rc2.extra_data->>'icon' as icon,
    rc2.extra_data->>'color' as color
FROM ref_codes rc1
LEFT JOIN ref_codes rc2 ON rc1.id = rc2.parent_id
WHERE rc1.type_code = 'SERVICE_TYPE' 
    AND rc1.level = 1 
    AND (rc1.name->>'zh' = '美食天地' OR rc1.name->>'en' = 'Food World')
ORDER BY rc2.sort_order;

-- 8. 创建索引优化查询性能
CREATE INDEX IF NOT EXISTS idx_ref_codes_food_categories 
ON ref_codes (type_code, level, parent_id, status) 
WHERE type_code = 'SERVICE_TYPE' AND level IN (1, 2);

-- 9. 更新统计信息
ANALYZE ref_codes;

-- 10. 输出完成信息
SELECT 
    '美食天地分类更新完成' as status,
    COUNT(*) as total_categories,
    COUNT(CASE WHEN level = 1 THEN 1 END) as level1_count,
    COUNT(CASE WHEN level = 2 THEN 1 END) as level2_count
FROM ref_codes 
WHERE type_code = 'SERVICE_TYPE' 
    AND (name->>'zh' LIKE '%美食%' OR name->>'en' LIKE '%Food%');
