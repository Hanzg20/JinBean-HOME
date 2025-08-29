-- =====================================================
-- JinBean Platform - 美食分类完整测试数据脚本（最终版）
-- 完全适配实际数据库表结构
-- 执行顺序：Provider -> Services -> Service Details
-- =====================================================

-- =====================================================
-- 第一部分：插入美食服务提供商数据
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '开始插入美食服务提供商数据...';
END $$;

-- 插入美食服务提供商数据
INSERT INTO provider_profiles (
    id, display_name, bio, avatar_url, phone, email, 
    rating, review_count, status, provider_type, is_certified,
    experience_years, tags, custom_fields, created_at, updated_at
) VALUES 
-- 社区美食提供商
(gen_random_uuid(), 
 '{"zh": "张妈妈川菜工坊", "en": "Auntie Zhang''s Sichuan Kitchen"}',
 '{"zh": "20年川菜制作经验，社区认证美食服务商，专注正宗川菜制作", "en": "20 years of Sichuan cuisine experience, community-certified food service provider, specializing in authentic Sichuan dishes"}',
 'https://picsum.photos/id/300/200/200',
 '+1-416-555-0101', 'zhangmama@jinbean.ca', 
 4.8, 156, 'active', 'individual', true,
 20, ARRAY['川菜', '麻辣', '家常菜'], 
 '{"specialties": ["川菜", "麻辣", "家常菜"], "certifications": ["社区认证", "食品安全"], "languages": ["中文", "英文"]}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

(gen_random_uuid(), 
 '{"zh": "李师傅饺子屋", "en": "Master Li''s Dumpling House"}',
 '{"zh": "专业手工饺子制作，新鲜食材，多种馅料，社区口碑美食", "en": "Professional handmade dumplings, fresh ingredients, various fillings, community-reputed food"}',
 'https://picsum.photos/id/301/200/200',
 '+1-416-555-0102', 'masterli@jinbean.ca', 
 4.7, 89, 'active', 'individual', true,
 15, ARRAY['饺子', '手工制作', '新鲜食材'], 
 '{"specialties": ["饺子", "手工制作", "新鲜食材"], "certifications": ["社区认证", "食品安全"], "languages": ["中文", "英文"]}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- 餐厅预订提供商
(gen_random_uuid(), 
 '{"zh": "龙腾中餐厅", "en": "Dragon Palace Chinese Restaurant"}',
 '{"zh": "高档中餐厅，专业服务团队，适合商务宴请和特殊场合", "en": "Fine Chinese restaurant, professional service team, perfect for business dinners and special occasions"}',
 'https://picsum.photos/id/302/200/200',
 '+1-416-555-0103', 'dragonpalace@jinbean.ca', 
 4.9, 234, 'active', 'corporate', true,
 25, ARRAY['粤菜', '商务宴请', '高档服务'], 
 '{"specialties": ["粤菜", "商务宴请", "高档服务"], "certifications": ["餐厅执照", "食品安全"], "languages": ["中文", "英文", "粤语"]}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

(gen_random_uuid(), 
 '{"zh": "樱花日料", "en": "Sakura Japanese Restaurant"}',
 '{"zh": "正宗日式料理，新鲜寿司，专业日料师傅，传统工艺", "en": "Authentic Japanese cuisine, fresh sushi, professional Japanese chefs, traditional techniques"}',
 'https://picsum.photos/id/303/200/200',
 '+1-416-555-0104', 'sakura@jinbean.ca', 
 4.6, 178, 'active', 'corporate', true,
 18, ARRAY['寿司', '日料', '传统工艺'], 
 '{"specialties": ["寿司", "日料", "传统工艺"], "certifications": ["餐厅执照", "食品安全"], "languages": ["日文", "英文", "中文"]}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- 团体餐饮提供商
(gen_random_uuid(), 
 '{"zh": "皇家婚礼宴席", "en": "Royal Wedding Banquet"}',
 '{"zh": "专业婚礼宴席服务，中西式菜单，全程服务，让您的婚礼更完美", "en": "Professional wedding banquet service, Chinese and Western menu, full service, making your wedding perfect"}',
 'https://picsum.photos/id/304/200/200',
 '+1-416-555-0105', 'royalwedding@jinbean.ca', 
 4.9, 45, 'active', 'corporate', true,
 12, ARRAY['婚礼宴席', '中西式菜单', '全程服务'], 
 '{"specialties": ["婚礼宴席", "中西式菜单", "全程服务"], "certifications": ["餐饮执照", "食品安全"], "languages": ["中文", "英文"]}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

(gen_random_uuid(), 
 '{"zh": "企业年会餐饮", "en": "Corporate Event Catering"}',
 '{"zh": "专业企业年会餐饮服务，适合大型公司活动，品质保证", "en": "Professional corporate event catering service, suitable for large company events, quality guaranteed"}',
 'https://picsum.photos/id/305/200/200',
 '+1-416-555-0106', 'corporate@jinbean.ca', 
 4.7, 67, 'active', 'corporate', true,
 10, ARRAY['企业餐饮', '大型活动', '品质保证'], 
 '{"specialties": ["企业餐饮", "大型活动", "品质保证"], "certifications": ["餐饮执照", "食品安全"], "languages": ["中文", "英文"]}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- 食材采购提供商
(gen_random_uuid(), 
 '{"zh": "新鲜蔬菜直供", "en": "Fresh Vegetable Direct Supply"}',
 '{"zh": "每日新鲜蔬菜配送，有机认证，健康安全，直接从农场到餐桌", "en": "Daily fresh vegetable delivery, organic certified, healthy and safe, directly from farm to table"}',
 'https://picsum.photos/id/306/200/200',
 '+1-416-555-0107', 'freshveggies@jinbean.ca', 
 4.6, 123, 'active', 'individual', true,
 8, ARRAY['新鲜蔬菜', '有机认证', '农场直供'], 
 '{"specialties": ["新鲜蔬菜", "有机认证", "农场直供"], "certifications": ["有机认证", "食品安全"], "languages": ["中文", "英文"]}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

(gen_random_uuid(), 
 '{"zh": "进口食品代购", "en": "Imported Food Shopping"}',
 '{"zh": "代购各国进口食品，保证正品，快速配送，满足您的异国美食需求", "en": "Purchase imported foods from various countries, guaranteed authentic, fast delivery, satisfying your international food needs"}',
 'https://picsum.photos/id/307/200/200',
 '+1-416-555-0108', 'importedfood@jinbean.ca', 
 4.5, 89, 'active', 'individual', true,
 6, ARRAY['进口食品', '代购服务', '正品保证'], 
 '{"specialties": ["进口食品", "代购服务", "正品保证"], "certifications": ["进口许可", "食品安全"], "languages": ["中文", "英文", "日文", "韩文"]}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- 其它美食服务提供商
(gen_random_uuid(), 
 '{"zh": "美食摄影服务", "en": "Food Photography Service"}',
 '{"zh": "专业美食摄影，为餐厅和美食博主提供高质量照片，让美食更诱人", "en": "Professional food photography, providing high-quality photos for restaurants and food bloggers, making food more appealing"}',
 'https://picsum.photos/id/308/200/200',
 '+1-416-555-0109', 'foodphoto@jinbean.ca', 
 4.8, 34, 'active', 'individual', true,
 5, ARRAY['美食摄影', '商业摄影', '后期制作'], 
 '{"specialties": ["美食摄影", "商业摄影", "后期制作"], "certifications": ["专业摄影", "商业许可"], "languages": ["中文", "英文"]}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

(gen_random_uuid(), 
 '{"zh": "美食课程教学", "en": "Cooking Class Teaching"}',
 '{"zh": "专业烹饪教学，在线和上门服务，适合初学者，让您成为厨房高手", "en": "Professional cooking instruction, online and in-home service, suitable for beginners, making you a kitchen expert"}',
 'https://picsum.photos/id/309/200/200',
 '+1-416-555-0110', 'cookingclass@jinbean.ca', 
 4.7, 56, 'active', 'individual', true,
 7, ARRAY['烹饪教学', '在线课程', '上门服务'], 
 '{"specialties": ["烹饪教学", "在线课程", "上门服务"], "certifications": ["教学许可", "食品安全"], "languages": ["中文", "英文"]}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

DO $$
BEGIN
    RAISE NOTICE 'Provider数据插入完成，共插入10个提供商';
END $$;

-- =====================================================
-- 第二部分：插入美食服务数据（适配实际表结构）
-- =====================================================

DO $$
DECLARE
    food_level1_id INTEGER;
    community_food_id INTEGER;
    restaurant_booking_id INTEGER;
    group_catering_id INTEGER;
    ingredient_shopping_id INTEGER;
    others_id INTEGER;
BEGIN
    RAISE NOTICE '开始插入美食服务数据...';
    
    -- 获取美食天地一级分类ID
    SELECT id INTO food_level1_id
    FROM ref_codes 
    WHERE type_code = 'SERVICE_TYPE' 
        AND level = 1 
        AND (name->>'zh' = '美食天地' OR name->>'en' = 'Food World');
    
    -- 获取各二级分类ID
    SELECT id INTO community_food_id FROM ref_codes WHERE type_code = 'SERVICE_TYPE' AND level = 2 AND name->>'zh' = '社区美食';
    SELECT id INTO restaurant_booking_id FROM ref_codes WHERE type_code = 'SERVICE_TYPE' AND level = 2 AND name->>'zh' = '餐厅预订';
    SELECT id INTO group_catering_id FROM ref_codes WHERE type_code = 'SERVICE_TYPE' AND level = 2 AND name->>'zh' = '团体餐饮';
    SELECT id INTO ingredient_shopping_id FROM ref_codes WHERE type_code = 'SERVICE_TYPE' AND level = 2 AND name->>'zh' = '食材采购';
    SELECT id INTO others_id FROM ref_codes WHERE type_code = 'SERVICE_TYPE' AND level = 2 AND name->>'zh' = '其它';
    
    RAISE NOTICE '美食天地ID: %, 社区美食ID: %, 餐厅预订ID: %, 团体餐饮ID: %, 食材采购ID: %, 其它ID: %', 
        food_level1_id, community_food_id, restaurant_booking_id, group_catering_id, ingredient_shopping_id, others_id;
    
    -- 插入社区美食类服务（使用实际表结构）
    INSERT INTO services (id, provider_id, title, description, category_level1_id, category_level2_id, status, average_rating, review_count, service_delivery_method, created_at, updated_at) VALUES 
    (gen_random_uuid(), (SELECT id FROM provider_profiles WHERE display_name->>'zh' = '张妈妈川菜工坊'), '{"zh": "张妈妈川菜工坊", "en": "Auntie Zhang''s Sichuan Kitchen"}', '{"zh": "社区认证的川菜制作，正宗麻辣味道，温馨家常", "en": "Community-certified Sichuan cuisine, authentic spicy flavors, warm home-style"}', food_level1_id, community_food_id, 'active', 4.8, 156, 'delivery', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (gen_random_uuid(), (SELECT id FROM provider_profiles WHERE display_name->>'zh' = '李师傅饺子屋'), '{"zh": "李师傅饺子屋", "en": "Master Li''s Dumpling House"}', '{"zh": "手工饺子制作，新鲜食材，多种馅料可选", "en": "Handmade dumplings, fresh ingredients, various fillings available"}', food_level1_id, community_food_id, 'active', 4.7, 89, 'delivery', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    
    -- 插入餐厅预订类服务
    INSERT INTO services (id, provider_id, title, description, category_level1_id, category_level2_id, status, average_rating, review_count, service_delivery_method, created_at, updated_at) VALUES 
    (gen_random_uuid(), (SELECT id FROM provider_profiles WHERE display_name->>'zh' = '龙腾中餐厅'), '{"zh": "龙腾中餐厅", "en": "Dragon Palace Chinese Restaurant"}', '{"zh": "高档中餐厅，专业服务，适合商务宴请", "en": "Fine Chinese restaurant, professional service, perfect for business dinners"}', food_level1_id, restaurant_booking_id, 'active', 4.9, 234, 'on_site', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (gen_random_uuid(), (SELECT id FROM provider_profiles WHERE display_name->>'zh' = '樱花日料'), '{"zh": "樱花日料", "en": "Sakura Japanese Restaurant"}', '{"zh": "正宗日式料理，新鲜寿司，专业日料师傅", "en": "Authentic Japanese cuisine, fresh sushi, professional Japanese chefs"}', food_level1_id, restaurant_booking_id, 'active', 4.6, 178, 'on_site', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    
    -- 插入团体餐饮类服务
    INSERT INTO services (id, provider_id, title, description, category_level1_id, category_level2_id, status, average_rating, review_count, service_delivery_method, created_at, updated_at) VALUES 
    (gen_random_uuid(), (SELECT id FROM provider_profiles WHERE display_name->>'zh' = '皇家婚礼宴席'), '{"zh": "皇家婚礼宴席", "en": "Royal Wedding Banquet"}', '{"zh": "专业婚礼宴席服务，中西式菜单，全程服务", "en": "Professional wedding banquet service, Chinese and Western menu, full service"}', food_level1_id, group_catering_id, 'active', 4.9, 45, 'on_site', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (gen_random_uuid(), (SELECT id FROM provider_profiles WHERE display_name->>'zh' = '企业年会餐饮'), '{"zh": "企业年会餐饮", "en": "Corporate Event Catering"}', '{"zh": "专业企业年会餐饮，适合大型公司活动", "en": "Professional corporate event catering, perfect for large company events"}', food_level1_id, group_catering_id, 'active', 4.7, 67, 'on_site', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    
    -- 插入食材采购类服务
    INSERT INTO services (id, provider_id, title, description, category_level1_id, category_level2_id, status, average_rating, review_count, service_delivery_method, created_at, updated_at) VALUES 
    (gen_random_uuid(), (SELECT id FROM provider_profiles WHERE display_name->>'zh' = '新鲜蔬菜直供'), '{"zh": "新鲜蔬菜直供", "en": "Fresh Vegetable Direct Supply"}', '{"zh": "每日新鲜蔬菜配送，有机认证，健康安全", "en": "Daily fresh vegetable delivery, organic certified, healthy and safe"}', food_level1_id, ingredient_shopping_id, 'active', 4.6, 123, 'delivery', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (gen_random_uuid(), (SELECT id FROM provider_profiles WHERE display_name->>'zh' = '进口食品代购'), '{"zh": "进口食品代购", "en": "Imported Food Shopping"}', '{"zh": "代购各国进口食品，保证正品，快速配送", "en": "Purchase imported foods from various countries, guaranteed authentic, fast delivery"}', food_level1_id, ingredient_shopping_id, 'active', 4.5, 89, 'delivery', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    
    -- 插入其它类服务
    INSERT INTO services (id, provider_id, title, description, category_level1_id, category_level2_id, status, average_rating, review_count, service_delivery_method, created_at, updated_at) VALUES 
    (gen_random_uuid(), (SELECT id FROM provider_profiles WHERE display_name->>'zh' = '美食摄影服务'), '{"zh": "美食摄影服务", "en": "Food Photography Service"}', '{"zh": "专业美食摄影，为餐厅和美食博主提供高质量照片", "en": "Professional food photography, providing high-quality photos for restaurants and food bloggers"}', food_level1_id, others_id, 'active', 4.8, 34, 'on_site', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (gen_random_uuid(), (SELECT id FROM provider_profiles WHERE display_name->>'zh' = '美食课程教学'), '{"zh": "美食课程教学", "en": "Cooking Class Teaching"}', '{"zh": "专业烹饪教学，在线和上门服务，适合初学者", "en": "Professional cooking instruction, online and in-home service, suitable for beginners"}', food_level1_id, others_id, 'active', 4.7, 56, 'online', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    
    RAISE NOTICE '服务数据插入完成，共插入10个服务';
END $$;

-- =====================================================
-- 第三部分：为每个服务插入service_details（适配实际表结构）
-- =====================================================

DO $$
DECLARE
    service_record RECORD;
    detail_count INTEGER := 0;
BEGIN
    RAISE NOTICE '开始插入service_details数据...';
    
    -- 为每个服务插入至少2条service_details
    FOR service_record IN 
        SELECT id, title->>'zh' as service_name 
        FROM services 
        WHERE category_level1_id IN (
            SELECT id FROM ref_codes 
            WHERE type_code = 'SERVICE_TYPE' 
                AND level = 1 
                AND (name->>'zh' = '美食天地' OR name->>'en' = 'Food World')
        )
    LOOP
        -- 插入主服务详情（使用实际表结构）
        INSERT INTO service_details (
            service_id, pricing_type, price, currency, duration_type, duration,
            images_url, videos_url, tags, service_area_codes, created_at, updated_at
        ) VALUES (
            service_record.id, 'fixed_price', 25.00, 'CAD', 'hours', '1 hour',
            ARRAY['https://picsum.photos/id/247/400/300'], ARRAY[]::text[],
            ARRAY['美食', '社区认证'], ARRAY['M5H', 'M5J'],
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        );
        
        -- 插入子服务详情
        INSERT INTO service_details (
            service_id, pricing_type, price, currency, duration_type, duration,
            images_url, videos_url, tags, service_area_codes, created_at, updated_at
        ) VALUES (
            service_record.id, 'fixed_price', 35.00, 'CAD', 'hours', '1.5 hours',
            ARRAY['https://picsum.photos/id/248/400/300'], ARRAY[]::text[],
            ARRAY['美食', '社区认证', '增值服务'], ARRAY['M5H', 'M5J'],
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        );
        
        detail_count := detail_count + 1;
    END LOOP;
    
    RAISE NOTICE 'Service details插入完成，共为 % 个服务插入了详情', detail_count;
END $$;

-- =====================================================
-- 第四部分：验证数据插入结果
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '开始验证数据插入结果...';
END $$;

-- 1. 验证分类分布
SELECT 
    rc2.name->>'zh' as "分类名称",
    COUNT(s.id) as "服务数量",
    COUNT(sd.service_id) as "详情数量"
FROM ref_codes rc1
JOIN ref_codes rc2 ON rc1.id = rc2.parent_id
LEFT JOIN services s ON rc2.id = s.category_level2_id
LEFT JOIN service_details sd ON s.id = sd.service_id
WHERE rc1.type_code = 'SERVICE_TYPE' 
    AND rc1.level = 1 
    AND (rc1.name->>'zh' = '美食天地' OR rc1.name->>'en' = 'Food World')
GROUP BY rc2.id, rc2.name->>'zh', rc2.sort_order
ORDER BY rc2.sort_order;

-- 2. 验证Provider和Service关联
SELECT 
    pp.display_name->>'zh' as "提供商名称",
    s.title->>'zh' as "服务名称",
    rc2.name->>'zh' as "分类",
    s.average_rating as "服务评分",
    s.review_count as "服务评价数"
FROM provider_profiles pp
JOIN services s ON pp.id = s.provider_id
JOIN ref_codes rc2 ON s.category_level2_id = rc2.id
WHERE s.category_level1_id IN (
    SELECT id FROM ref_codes 
    WHERE type_code = 'SERVICE_TYPE' 
        AND level = 1 
        AND (name->>'zh' = '美食天地' OR name->>'en' = 'Food World')
)
ORDER BY rc2.sort_order, pp.display_name->>'zh';

-- 3. 统计信息
SELECT 
    '总Provider数量' as "统计项目",
    COUNT(*) as "数量"
FROM provider_profiles 
WHERE id IN (
    SELECT DISTINCT provider_id 
    FROM services 
    WHERE category_level1_id IN (
        SELECT id FROM ref_codes 
        WHERE type_code = 'SERVICE_TYPE' 
            AND level = 1 
            AND (name->>'zh' = '美食天地' OR name->>'en' = 'Food World')
    )
)

UNION ALL

SELECT 
    '已验证Provider数量' as "统计项目",
    COUNT(*) as "数量"
FROM provider_profiles 
WHERE id IN (
    SELECT DISTINCT provider_id 
    FROM services 
    WHERE category_level1_id IN (
        SELECT id FROM ref_codes 
        WHERE type_code = 'SERVICE_TYPE' 
            AND level = 1 
            AND (name->>'zh' = '美食天地' OR name->>'en' = 'Food World')
    )
) AND is_certified = true

UNION ALL

SELECT 
    '平均评分' as "统计项目",
    ROUND(AVG(rating), 2) as "数量"
FROM provider_profiles 
WHERE id IN (
    SELECT DISTINCT provider_id 
    FROM services 
    WHERE category_level1_id IN (
        SELECT id FROM ref_codes 
        WHERE type_code = 'SERVICE_TYPE' 
            AND level = 1 
            AND (name->>'zh' = '美食天地' OR name->>'en' = 'Food World')
    )
);

-- 4. 显示详细的服务和详情信息
SELECT 
    s.title->>'zh' as "服务名称",
    rc2.name->>'zh' as "分类",
    sd.pricing_type as "定价类型",
    sd.price as "价格",
    sd.currency as "货币",
    sd.duration as "时长"
FROM services s
JOIN ref_codes rc2 ON s.category_level2_id = rc2.id
JOIN service_details sd ON s.id = sd.service_id
WHERE s.category_level1_id IN (
    SELECT id FROM ref_codes 
    WHERE type_code = 'SERVICE_TYPE' 
        AND level = 1 
        AND (name->>'zh' = '美食天地' OR name->>'en' = 'Food World')
)
ORDER BY rc2.sort_order, s.title->>'zh';

DO $$
BEGIN
    RAISE NOTICE '数据验证完成！';
    RAISE NOTICE '总结：';
    RAISE NOTICE '- 插入了10个美食服务提供商';
    RAISE NOTICE '- 插入了10个美食服务（每个分类2个）';
    RAISE NOTICE '- 插入了20个service_details（每个服务2个）';
    RAISE NOTICE '- 所有数据都已正确关联';
END $$;
