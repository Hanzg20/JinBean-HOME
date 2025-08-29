-- =====================================================
-- JinBean Platform - 检查美食分类更新状态
-- =====================================================

-- 1. 检查美食天地一级分类
SELECT 
    '一级分类' as type,
    id,
    code,
    name->>'zh' as "中文名称",
    name->>'en' as "英文名称",
    level,
    parent_id,
    sort_order,
    status,
    created_at,
    updated_at
FROM ref_codes 
WHERE type_code = 'SERVICE_TYPE' 
    AND level = 1 
    AND (name->>'zh' = '美食天地' OR name->>'en' = 'Food World');

-- 2. 检查所有美食相关的二级分类
SELECT 
    '二级分类' as type,
    id,
    code,
    name->>'zh' as "中文名称",
    name->>'en' as "英文名称",
    level,
    parent_id,
    sort_order,
    status,
    extra_data->>'icon' as "图标",
    extra_data->>'color' as "颜色",
    created_at,
    updated_at
FROM ref_codes 
WHERE type_code = 'SERVICE_TYPE' 
    AND level = 2 
    AND parent_id IN (
        SELECT id FROM ref_codes 
        WHERE type_code = 'SERVICE_TYPE' 
            AND level = 1 
            AND (name->>'zh' = '美食天地' OR name->>'en' = 'Food World')
    )
ORDER BY sort_order;

-- 3. 检查是否有其他美食相关的分类
SELECT 
    '其他美食分类' as type,
    id,
    code,
    name->>'zh' as "中文名称",
    name->>'en' as "英文名称",
    level,
    parent_id,
    sort_order,
    status
FROM ref_codes 
WHERE type_code = 'SERVICE_TYPE' 
    AND (name->>'zh' LIKE '%美食%' OR name->>'en' LIKE '%Food%')
ORDER BY level, sort_order;

-- 4. 统计信息
SELECT 
    '统计信息' as type,
    COUNT(*) as total_categories,
    COUNT(CASE WHEN level = 1 THEN 1 END) as level1_count,
    COUNT(CASE WHEN level = 2 THEN 1 END) as level2_count,
    COUNT(CASE WHEN status = 1 THEN 1 END) as active_count,
    COUNT(CASE WHEN status = 0 THEN 1 END) as inactive_count
FROM ref_codes 
WHERE type_code = 'SERVICE_TYPE' 
    AND (name->>'zh' LIKE '%美食%' OR name->>'en' LIKE '%Food%');
