-- 第4步：数据迁移
-- 为现有数据填充新字段的默认值

-- 1. 为现有记录设置默认值
UPDATE service_details 
SET 
    category = COALESCE(category, 'main'),
    detail_name = COALESCE(detail_name, '{"en": "Main Service", "zh": "主要服务"}'::jsonb),
    is_available = COALESCE(is_available, true),
    sort_order = COALESCE(sort_order, 0),
    attributes = COALESCE(attributes, '{}'::jsonb),
    business_rules = COALESCE(business_rules, '{}'::jsonb)
WHERE detail_name IS NULL OR category IS NULL;

-- 2. 验证数据迁移结果
SELECT 
    'migration_verification' as check_type,
    COUNT(*) as total_records,
    COUNT(CASE WHEN category = 'main' THEN 1 END) as main_category_records,
    COUNT(CASE WHEN detail_name IS NOT NULL THEN 1 END) as named_records,
    COUNT(CASE WHEN is_available = true THEN 1 END) as available_records,
    COUNT(CASE WHEN attributes IS NOT NULL THEN 1 END) as with_attributes
FROM service_details;

-- 3. 检查JSON字段格式
SELECT 
    'json_validation' as check_type,
    detail_name,
    attributes,
    business_rules
FROM service_details 
LIMIT 3;

-- 4. 检查所有记录都有有效的category
SELECT 
    'category_distribution' as check_type,
    category,
    COUNT(*) as count
FROM service_details 
GROUP BY category;

-- 成功提示
SELECT '✅ 数据迁移完成，准备创建索引' as message; 