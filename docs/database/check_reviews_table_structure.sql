-- ========================================
-- 检查reviews表的实际结构
-- ========================================

-- 查看reviews表的所有列
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'reviews' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 查看reviews表的约束
SELECT 
    constraint_name,
    constraint_type,
    column_name
FROM information_schema.table_constraints tc
JOIN information_schema.constraint_column_usage ccu 
    ON tc.constraint_name = ccu.constraint_name
WHERE tc.table_name = 'reviews' 
AND tc.table_schema = 'public';






