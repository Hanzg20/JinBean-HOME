-- 第2步：备份现有数据
-- 在进行任何结构修改之前，先备份数据

-- 1. 创建带时间戳的备份表
DROP TABLE IF EXISTS service_details_backup_20250108;
CREATE TABLE service_details_backup_20250108 AS 
SELECT * FROM service_details;

-- 2. 验证备份完整性
SELECT 
    'backup_verification' as check_type,
    (SELECT COUNT(*) FROM service_details_backup_20250108) as backup_count,
    (SELECT COUNT(*) FROM service_details) as original_count,
    CASE 
        WHEN (SELECT COUNT(*) FROM service_details_backup_20250108) = (SELECT COUNT(*) FROM service_details)
        THEN '✅ 备份成功'
        ELSE '❌ 备份失败，记录数不匹配'
    END as backup_status;

-- 3. 显示备份表结构
SELECT 
    'backup_structure' as info,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name = 'service_details_backup_20250108' 
ORDER BY ordinal_position;

-- 备份完成提示
SELECT '🎯 数据备份已完成，可以安全地进行结构修改' as message; 