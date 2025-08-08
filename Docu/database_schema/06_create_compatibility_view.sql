-- 第6步：创建兼容性视图
-- 创建向后兼容的视图，保持现有API不变

-- 1. 创建兼容性视图
CREATE OR REPLACE VIEW service_details_legacy AS
SELECT 
    service_id,
    pricing_type,
    price,
    currency,
    negotiation_details,
    duration_type,
    duration,
    images_url,
    videos_url,
    tags,
    service_area_codes,
    platform_service_fee_rate,
    created_at,
    updated_at
FROM service_details 
WHERE category = 'main';

-- 2. 测试兼容性视图
SELECT 
    'legacy_view_test' as check_type,
    COUNT(*) as legacy_view_count,
    (SELECT COUNT(*) FROM service_details WHERE category = 'main') as main_records_count,
    CASE 
        WHEN COUNT(*) = (SELECT COUNT(*) FROM service_details WHERE category = 'main')
        THEN '✅ 兼容性视图正常'
        ELSE '❌ 兼容性视图有问题'
    END as status
FROM service_details_legacy;

-- 3. 验证视图结构
SELECT 
    'legacy_view_structure' as check_type,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name = 'service_details_legacy'
ORDER BY ordinal_position;

-- 4. 测试视图查询功能
SELECT 
    'legacy_view_sample' as check_type,
    service_id,
    pricing_type,
    price,
    currency
FROM service_details_legacy 
LIMIT 3;

-- 创建迁移日志表（如果不存在）
CREATE TABLE IF NOT EXISTS migration_log (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    migration_name text UNIQUE NOT NULL,
    version text NOT NULL,
    executed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    status text NOT NULL,
    description text
);

-- 记录迁移完成
INSERT INTO migration_log (migration_name, version, status, description)
VALUES (
    'service_details_restructure_step_by_step', 
    'v1.1', 
    'completed',
    'Service details table restructured to support sub-services and enhanced functionality'
)
ON CONFLICT (migration_name) DO UPDATE SET
    version = EXCLUDED.version,
    executed_at = CURRENT_TIMESTAMP,
    status = EXCLUDED.status,
    description = EXCLUDED.description;

-- 成功提示
SELECT '✅ 兼容性视图创建完成，迁移已完成！' as message; 