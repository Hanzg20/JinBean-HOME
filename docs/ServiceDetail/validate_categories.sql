-- =====================================================
-- 验证分类ID脚本
-- 检查测试数据中使用的所有分类ID是否在ref_codes表中存在
-- 基于真实的ref_codes_rows.sql数据
-- =====================================================

-- 检查一级分类
SELECT 'Level 1 Categories' as check_type, id, name->>'en' as name_en
FROM ref_codes 
WHERE level = 1 
ORDER BY id;

-- 检查二级分类
SELECT 'Level 2 Categories' as check_type, id, name->>'en' as name_en, parent_id
FROM ref_codes 
WHERE level = 2 
ORDER BY parent_id, id;

-- 检查三级分类
SELECT 'Level 3 Categories' as check_type, id, name->>'en' as name_en, parent_id
FROM ref_codes 
WHERE level = 3 
ORDER BY parent_id, id;

-- 验证测试数据中使用的分类ID
WITH test_categories AS (
    SELECT 1010000 as id, 'Food Court' as name UNION ALL
    SELECT 1010301, 'China Cuisine' UNION ALL
    SELECT 1010303, 'Asian Cuisine' UNION ALL
    SELECT 1020000, 'Home to Home' UNION ALL
    SELECT 1020101, 'Home Cleaning' UNION ALL
    SELECT 1020106, 'Plumbing' UNION ALL
    SELECT 1020301, 'Lawn Mowing' UNION ALL
    SELECT 1020401, 'Pet Sitting' UNION ALL
    SELECT 1040000, 'Share Park' UNION ALL
    SELECT 1040100, 'Tool Rental' UNION ALL
    SELECT 1050000, 'Learning Park' UNION ALL
    SELECT 1050100, 'Tutoring' UNION ALL
    SELECT 1050200, 'Arts & Hobbies' UNION ALL
    SELECT 1060000, 'Life Help' UNION ALL
    SELECT 1060201, 'IT Support' UNION ALL
    SELECT 1060302, 'Loan/Insurance' UNION ALL
    SELECT 1060304, 'Legal' UNION ALL
    SELECT 1060401, 'Physio' UNION ALL
    SELECT 1060500, 'Other'
)
SELECT 
    tc.id,
    tc.name as test_name,
    CASE 
        WHEN rc.id IS NOT NULL THEN 'EXISTS'
        ELSE 'MISSING'
    END as status,
    rc.name->>'en' as ref_name,
    rc.level as ref_level
FROM test_categories tc
LEFT JOIN ref_codes rc ON tc.id = rc.id
ORDER BY tc.id;

-- 检查是否有缺失的分类ID
SELECT 
    'Missing Categories' as check_type,
    tc.id,
    tc.name as test_name
FROM test_categories tc
LEFT JOIN ref_codes rc ON tc.id = rc.id
WHERE rc.id IS NULL
ORDER BY tc.id;

-- 检查分类层级是否正确
SELECT 
    'Category Level Check' as check_type,
    tc.id,
    tc.name as test_name,
    rc.level as actual_level,
    CASE 
        WHEN rc.level = 2 THEN 'Level 2 (Correct)'
        WHEN rc.level = 3 THEN 'Level 3 (Correct)'
        ELSE 'Level ' || rc.level || ' (Unexpected)'
    END as level_status
FROM test_categories tc
JOIN ref_codes rc ON tc.id = rc.id
WHERE tc.id IN (
    1010301, 1010303, 1020101, 1020106, 1020301, 1020401,
    1040100, 1050100, 1050200, 1060201, 1060302, 1060304, 1060401
)
ORDER BY tc.id;
