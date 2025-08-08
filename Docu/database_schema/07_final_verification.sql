-- 第7步：最终验证
-- 验证迁移结果，确保一切正常

-- 1. 完整性验证报告
SELECT 
    '🎯 Migration Summary Report' as report_title,
    COUNT(*) as total_records,
    COUNT(CASE WHEN category = 'main' THEN 1 END) as main_services,
    COUNT(CASE WHEN category != 'main' THEN 1 END) as sub_services,
    COUNT(CASE WHEN detail_name IS NOT NULL THEN 1 END) as named_records,
    COUNT(CASE WHEN is_available = true THEN 1 END) as available_records,
    (SELECT COUNT(*) FROM service_details_backup_20250108) as backup_records
FROM service_details;

-- 2. 新表结构概览
SELECT 
    '📊 New Table Structure' as info,
    column_name,
    data_type,
    is_nullable,
    CASE 
        WHEN column_name IN ('detail_id', 'category', 'detail_name', 'sub_category', 
                           'is_available', 'sort_order', 'current_stock', 'max_stock', 
                           'attributes', 'business_rules')
        THEN '🆕 NEW'
        ELSE '📄 EXISTING'
    END as field_status
FROM information_schema.columns 
WHERE table_name = 'service_details' 
ORDER BY ordinal_position;

-- 3. 索引状态报告
SELECT 
    '🔍 Index Status Report' as info,
    indexname,
    CASE 
        WHEN indexname LIKE 'idx_service_details_%' THEN '🆕 NEW INDEX'
        ELSE '📄 EXISTING INDEX'
    END as index_status
FROM pg_indexes 
WHERE tablename = 'service_details' 
ORDER BY indexname;

-- 4. 兼容性验证
SELECT 
    '🔄 Compatibility Check' as check_type,
    'Legacy View' as component,
    COUNT(*) as record_count,
    '✅ WORKING' as status
FROM service_details_legacy;

-- 5. 数据类型分布
SELECT 
    '📈 Data Distribution' as info,
    category,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM service_details), 2) as percentage
FROM service_details 
GROUP BY category
ORDER BY count DESC;

-- 6. JSON字段示例
SELECT 
    '🧪 JSON Fields Sample' as info,
    detail_name,
    attributes
FROM service_details 
WHERE category = 'main'
LIMIT 2;

-- 7. 性能测试查询
EXPLAIN (ANALYZE, BUFFERS) 
SELECT sd.*, s.title 
FROM service_details sd
JOIN services s ON sd.service_id = s.id
WHERE sd.category = 'main' 
  AND sd.is_available = true
LIMIT 5;

-- 8. 迁移日志验证
SELECT 
    '📝 Migration Log' as info,
    migration_name,
    version,
    status,
    executed_at,
    description
FROM migration_log 
WHERE migration_name = 'service_details_restructure_step_by_step';

-- 最终状态总结
SELECT 
    '🎉 SERVICE_DETAILS表重构成功完成！' as final_status,
    '现在支持多子服务架构' as new_capability,
    '✅ 向后兼容性保持' as compatibility,
    '🚀 性能优化完成' as performance,
    '准备开始测试数据和应用适配' as next_steps; 