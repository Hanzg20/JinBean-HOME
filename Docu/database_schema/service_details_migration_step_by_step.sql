-- Service Detail表重构迁移脚本 - 分步执行版本
-- 版本: v1.1 - 分步执行
-- 创建日期: 2025-01-08
-- 描述: 将service_details表从"服务详情"扩展为"服务项目"，支持多子服务场景

-- ========================================
-- 第0步：检查当前数据库状态
-- ========================================

-- 检查当前表结构
\d service_details;

-- 检查现有数据数量
SELECT 
    'Current service_details records' as description,
    COUNT(*) as count
FROM service_details;

-- 检查services表数量
SELECT 
    'Current services records' as description,
    COUNT(*) as count
FROM services;

-- ========================================
-- 第1步：备份现有数据
-- ========================================

-- 创建备份表
DROP TABLE IF EXISTS service_details_backup_20250108;
CREATE TABLE service_details_backup_20250108 AS 
SELECT * FROM service_details;

-- 验证备份
SELECT 
    'Backup verification' as description,
    COUNT(*) as backup_count,
    (SELECT COUNT(*) FROM service_details) as original_count
FROM service_details_backup_20250108;

-- ========================================
-- 第2步：添加新字段（安全操作）
-- ========================================

-- 添加新字段 - 不影响现有数据
ALTER TABLE service_details 
ADD COLUMN IF NOT EXISTS detail_id uuid DEFAULT gen_random_uuid(),
ADD COLUMN IF NOT EXISTS category text DEFAULT 'main',
ADD COLUMN IF NOT EXISTS detail_name jsonb,
ADD COLUMN IF NOT EXISTS sub_category text,
ADD COLUMN IF NOT EXISTS is_available boolean DEFAULT true,
ADD COLUMN IF NOT EXISTS sort_order integer DEFAULT 0,
ADD COLUMN IF NOT EXISTS current_stock integer,
ADD COLUMN IF NOT EXISTS max_stock integer,
ADD COLUMN IF NOT EXISTS attributes jsonb DEFAULT '{}',
ADD COLUMN IF NOT EXISTS business_rules jsonb DEFAULT '{}';

-- 验证新字段
\d service_details;

-- ========================================
-- 第3步：数据迁移和清理
-- ========================================

-- 为现有数据设置默认值
UPDATE service_details 
SET 
    category = COALESCE(category, 'main'),
    detail_name = COALESCE(detail_name, '{"en": "Main Service", "zh": "主要服务"}'::jsonb),
    is_available = COALESCE(is_available, true),
    sort_order = COALESCE(sort_order, 0),
    attributes = COALESCE(attributes, '{}'::jsonb),
    business_rules = COALESCE(business_rules, '{}'::jsonb)
WHERE detail_name IS NULL OR category IS NULL;

-- 验证数据迁移
SELECT 
    COUNT(*) as total_records,
    COUNT(CASE WHEN category = 'main' THEN 1 END) as main_category_records,
    COUNT(CASE WHEN detail_name IS NOT NULL THEN 1 END) as named_records
FROM service_details;

-- ========================================
-- 第4步：创建索引（性能优化）
-- ========================================

-- 为新字段创建索引
CREATE INDEX IF NOT EXISTS idx_service_details_detail_id ON service_details(detail_id);
CREATE INDEX IF NOT EXISTS idx_service_details_category ON service_details(category);
CREATE INDEX IF NOT EXISTS idx_service_details_available ON service_details(is_available);
CREATE INDEX IF NOT EXISTS idx_service_details_sort_order ON service_details(sort_order);
CREATE INDEX IF NOT EXISTS idx_service_details_name_gin ON service_details USING gin(detail_name);
CREATE INDEX IF NOT EXISTS idx_service_details_attributes_gin ON service_details USING gin(attributes);

-- 验证索引创建
SELECT 
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'service_details' 
AND indexname LIKE 'idx_service_details_%'
ORDER BY indexname;

-- ========================================
-- 第5步：添加约束（数据完整性）
-- ========================================

-- 设置非空约束
ALTER TABLE service_details 
ALTER COLUMN detail_name SET NOT NULL,
ALTER COLUMN category SET NOT NULL;

-- 验证约束
SELECT 
    'Data integrity check' as description,
    COUNT(*) as total_records,
    COUNT(CASE WHEN detail_name IS NOT NULL THEN 1 END) as valid_names,
    COUNT(CASE WHEN category IS NOT NULL THEN 1 END) as valid_categories
FROM service_details;

-- ========================================
-- 第6步：创建兼容性视图
-- ========================================

-- 创建向后兼容视图
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

-- 测试兼容性视图
SELECT 
    'Legacy view test' as description,
    COUNT(*) as legacy_view_count,
    (SELECT COUNT(*) FROM service_details WHERE category = 'main') as main_records_count
FROM service_details_legacy;

-- ========================================
-- 第7步：最终验证
-- ========================================

-- 完整性验证报告
SELECT 
    'Migration Summary' as report_type,
    COUNT(*) as total_records,
    COUNT(CASE WHEN category = 'main' THEN 1 END) as main_services,
    COUNT(CASE WHEN category != 'main' THEN 1 END) as sub_services,
    COUNT(CASE WHEN detail_name IS NOT NULL THEN 1 END) as named_records,
    COUNT(CASE WHEN is_available = true THEN 1 END) as available_records
FROM service_details;

-- 性能测试查询
EXPLAIN ANALYZE 
SELECT * FROM service_details 
WHERE service_id IN (
    SELECT id FROM services LIMIT 5
) 
AND category = 'main' 
AND is_available = true;

-- ========================================
-- 完成迁移记录
-- ========================================

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

-- 最终状态报告
SELECT 
    '✅ Service Detail表重构完成' as status,
    COUNT(*) as total_records,
    COUNT(CASE WHEN category = 'main' THEN 1 END) as main_records,
    COUNT(CASE WHEN category != 'main' THEN 1 END) as sub_records,
    (SELECT COUNT(*) FROM service_details_backup_20250108) as backup_records
FROM service_details;

COMMIT; 