-- 第5步：创建索引和约束
-- 为新字段创建性能优化索引

-- 1. 创建基础索引
CREATE INDEX IF NOT EXISTS idx_service_details_detail_id ON service_details(detail_id);
CREATE INDEX IF NOT EXISTS idx_service_details_category ON service_details(category);
CREATE INDEX IF NOT EXISTS idx_service_details_available ON service_details(is_available);
CREATE INDEX IF NOT EXISTS idx_service_details_sort_order ON service_details(sort_order);

-- 2. 创建复合索引
CREATE INDEX IF NOT EXISTS idx_service_details_service_category 
ON service_details(service_id, category);

CREATE INDEX IF NOT EXISTS idx_service_details_category_available 
ON service_details(category, is_available);

-- 3. 创建JSON字段的GIN索引
CREATE INDEX IF NOT EXISTS idx_service_details_name_gin 
ON service_details USING gin(detail_name);

CREATE INDEX IF NOT EXISTS idx_service_details_attributes_gin 
ON service_details USING gin(attributes);

-- 4. 添加数据完整性约束
ALTER TABLE service_details 
ALTER COLUMN detail_name SET NOT NULL,
ALTER COLUMN category SET NOT NULL;

-- 5. 验证索引创建
SELECT 
    'index_verification' as check_type,
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'service_details' 
  AND indexname LIKE 'idx_service_details_%'
ORDER BY indexname;

-- 6. 验证约束
SELECT 
    'constraint_verification' as check_type,
    column_name,
    is_nullable,
    data_type
FROM information_schema.columns 
WHERE table_name = 'service_details' 
  AND column_name IN ('detail_name', 'category');

-- 成功提示
SELECT '✅ 索引和约束创建完成，准备创建兼容性视图' as message; 