-- 第1步：检查当前数据库状态
-- 执行此脚本了解当前service_details表的结构和数据

-- 1. 检查当前表结构
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'service_details' 
ORDER BY ordinal_position;

-- 2. 检查现有数据数量
SELECT 
    'service_details表记录数' as 描述,
    COUNT(*) as 数量
FROM service_details;

-- 3. 检查services表数量（用于验证外键关系）
SELECT 
    'services表记录数' as 描述,
    COUNT(*) as 数量
FROM services;

-- 4. 检查外键关系
SELECT 
    COUNT(*) as 有效关联数量,
    (SELECT COUNT(*) FROM service_details) as 总记录数
FROM service_details sd
JOIN services s ON sd.service_id = s.id;

-- 5. 检查是否已存在新字段（重复执行检查）
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'service_details' AND column_name = 'detail_id'
        ) THEN '已存在新字段，可能已经执行过迁移'
        ELSE '表结构为原始状态，可以开始迁移'
    END as 迁移状态; 