-- 第3步：添加新字段
-- 安全地为service_details表添加新字段

-- 1. 添加新字段（使用IF NOT EXISTS确保安全）
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

-- 2. 验证新字段已添加
SELECT 
    'new_fields_verification' as check_type,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'service_details' 
  AND column_name IN (
    'detail_id', 'category', 'detail_name', 'sub_category', 
    'is_available', 'sort_order', 'current_stock', 'max_stock', 
    'attributes', 'business_rules'
  )
ORDER BY column_name;

-- 3. 检查新字段的数据
SELECT 
    'field_data_check' as check_type,
    COUNT(*) as total_rows,
    COUNT(detail_id) as has_detail_id,
    COUNT(CASE WHEN category IS NOT NULL THEN 1 END) as has_category,
    COUNT(CASE WHEN is_available IS NOT NULL THEN 1 END) as has_is_available
FROM service_details;

-- 成功提示
SELECT '✅ 新字段添加完成，准备进行数据迁移' as message; 