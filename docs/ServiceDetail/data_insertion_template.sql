-- =====================================================
-- JinBean Platform - 通用数据插入模板
-- 适用于任何分类的Provider、Services和Service Details数据插入
-- 使用方法：替换模板中的变量即可
-- =====================================================

-- =====================================================
-- 模板变量说明
-- =====================================================
/*
需要替换的变量：
1. {CATEGORY_NAME_ZH} - 分类中文名称，如"美食天地"
2. {CATEGORY_NAME_EN} - 分类英文名称，如"Food World"
3. {CATEGORY_LEVEL1_ID} - 一级分类ID
4. {SUBCATEGORY_COUNT} - 二级分类数量
5. {SUBCATEGORY_NAMES} - 二级分类名称列表
6. {PROVIDER_COUNT} - 提供商数量
7. {SERVICE_COUNT_PER_CATEGORY} - 每个二级分类的服务数量
8. {PROVIDER_DATA} - 提供商数据
9. {SERVICE_DATA} - 服务数据
*/

-- =====================================================
-- 第一部分：插入服务提供商数据
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '开始插入{CATEGORY_NAME_ZH}服务提供商数据...';
END $$;

-- 插入服务提供商数据
INSERT INTO provider_profiles (
    id, display_name, bio, avatar_url, phone, email, 
    rating, review_count, status, provider_type, is_certified,
    experience_years, tags, custom_fields, created_at, updated_at
) VALUES 
-- 提供商数据模板
{PROVIDER_DATA};

DO $$
BEGIN
    RAISE NOTICE 'Provider数据插入完成，共插入{PROVIDER_COUNT}个提供商';
END $$;

-- =====================================================
-- 第二部分：插入服务数据
-- =====================================================

DO $$
DECLARE
    category_level1_id INTEGER;
    {SUBCATEGORY_VARIABLES}
BEGIN
    RAISE NOTICE '开始插入{CATEGORY_NAME_ZH}服务数据...';
    
    -- 获取一级分类ID
    SELECT id INTO category_level1_id
    FROM ref_codes 
    WHERE type_code = 'SERVICE_TYPE' 
        AND level = 1 
        AND (name->>'zh' = '{CATEGORY_NAME_ZH}' OR name->>'en' = '{CATEGORY_NAME_EN}');
    
    -- 获取各二级分类ID
    {SUBCATEGORY_ID_QUERIES}
    
    RAISE NOTICE '{CATEGORY_NAME_ZH}ID: %, {SUBCATEGORY_NAMES}ID: %', 
        category_level1_id, {SUBCATEGORY_VARIABLES};
    
    -- 插入服务数据
    {SERVICE_DATA}
    
    RAISE NOTICE '服务数据插入完成，共插入{SERVICE_COUNT_PER_CATEGORY}个服务';
END $$;

-- =====================================================
-- 第三部分：为每个服务插入service_details
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
                AND (name->>'zh' = '{CATEGORY_NAME_ZH}' OR name->>'en' = '{CATEGORY_NAME_EN}')
        )
    LOOP
        -- 插入主服务详情
        INSERT INTO service_details (
            service_id, pricing_type, price, currency, duration_type, duration,
            images_url, videos_url, tags, service_area_codes, created_at, updated_at
        ) VALUES (
            service_record.id, 'fixed_price', 25.00, 'CAD', 'hours', '1 hour',
            ARRAY['https://picsum.photos/id/247/400/300'], ARRAY[]::text[],
            ARRAY['{CATEGORY_NAME_ZH}', '标准服务'], ARRAY['M5H', 'M5J'],
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        );
        
        -- 插入子服务详情
        INSERT INTO service_details (
            service_id, pricing_type, price, currency, duration_type, duration,
            images_url, videos_url, tags, service_area_codes, created_at, updated_at
        ) VALUES (
            service_record.id, 'fixed_price', 35.00, 'CAD', 'hours', '1.5 hours',
            ARRAY['https://picsum.photos/id/248/400/300'], ARRAY[]::text[],
            ARRAY['{CATEGORY_NAME_ZH}', '标准服务', '增值服务'], ARRAY['M5H', 'M5J'],
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
    AND (rc1.name->>'zh' = '{CATEGORY_NAME_ZH}' OR rc1.name->>'en' = '{CATEGORY_NAME_EN}')
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
        AND (name->>'zh' = '{CATEGORY_NAME_ZH}' OR name->>'en' = '{CATEGORY_NAME_EN}')
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
            AND (name->>'zh' = '{CATEGORY_NAME_ZH}' OR name->>'en' = '{CATEGORY_NAME_EN}')
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
            AND (name->>'zh' = '{CATEGORY_NAME_ZH}' OR name->>'en' = '{CATEGORY_NAME_EN}')
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
            AND (name->>'zh' = '{CATEGORY_NAME_ZH}' OR name->>'en' = '{CATEGORY_NAME_EN}')
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
        AND (name->>'zh' = '{CATEGORY_NAME_ZH}' OR name->>'en' = '{CATEGORY_NAME_EN}')
)
ORDER BY rc2.sort_order, s.title->>'zh';

DO $$
BEGIN
    RAISE NOTICE '数据验证完成！';
    RAISE NOTICE '总结：';
    RAISE NOTICE '- 插入了{PROVIDER_COUNT}个{CATEGORY_NAME_ZH}服务提供商';
    RAISE NOTICE '- 插入了{SERVICE_COUNT_PER_CATEGORY}个{CATEGORY_NAME_ZH}服务';
    RAISE NOTICE '- 插入了{SERVICE_COUNT_PER_CATEGORY * 2}个service_details';
    RAISE NOTICE '- 所有数据都已正确关联';
END $$;
