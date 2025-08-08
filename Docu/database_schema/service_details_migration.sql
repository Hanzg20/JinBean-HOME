-- Service Detail表重构迁移脚本
-- 版本: v1.0
-- 创建日期: 2025-01-07
-- 描述: 将service_details表从"服务详情"扩展为"服务项目"，支持多子服务场景

-- ========================================
-- 第一步：备份现有数据
-- ========================================

-- 创建备份表
CREATE TABLE IF NOT EXISTS service_details_backup AS 
SELECT * FROM public.service_details;

-- ========================================
-- 第二步：表结构改造
-- ========================================

-- 1. 添加新的主键字段
ALTER TABLE public.service_details 
ADD COLUMN IF NOT EXISTS id uuid DEFAULT gen_random_uuid();

-- 2. 设置主键
DO $$
BEGIN
    -- 检查是否已经存在主键约束
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'service_details_pkey' 
        AND table_name = 'service_details'
    ) THEN
        -- 删除旧的主键约束
        ALTER TABLE public.service_details DROP CONSTRAINT IF EXISTS service_details_pkey;
        -- 添加新的主键约束
        ALTER TABLE public.service_details ADD CONSTRAINT service_details_pkey PRIMARY KEY (id);
    END IF;
END $$;

-- 3. 修改service_id为普通外键
DO $$
BEGIN
    -- 检查是否已经存在外键约束
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'service_details_service_id_fkey' 
        AND table_name = 'service_details'
    ) THEN
        -- 删除旧的外键约束
        ALTER TABLE public.service_details DROP CONSTRAINT IF EXISTS service_details_service_id_fkey;
        -- 添加新的外键约束
        ALTER TABLE public.service_details 
        ADD CONSTRAINT service_details_service_id_fkey 
        FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE;
    END IF;
END $$;

-- 4. 添加子服务相关字段
ALTER TABLE public.service_details 
ADD COLUMN IF NOT EXISTS name jsonb,
ADD COLUMN IF NOT EXISTS description jsonb,
ADD COLUMN IF NOT EXISTS category text DEFAULT 'main',
ADD COLUMN IF NOT EXISTS sub_category text,
ADD COLUMN IF NOT EXISTS parent_id uuid REFERENCES service_details(id),
ADD COLUMN IF NOT EXISTS sort_order integer DEFAULT 0,
ADD COLUMN IF NOT EXISTS is_active boolean DEFAULT true,
ADD COLUMN IF NOT EXISTS current_stock integer,
ADD COLUMN IF NOT EXISTS max_stock integer,
ADD COLUMN IF NOT EXISTS industry_attributes jsonb;

-- ========================================
-- 第三步：数据迁移
-- ========================================

-- 1. 为现有数据设置默认值
UPDATE public.service_details 
SET 
    name = COALESCE(name, '{"en": "Main Service", "zh": "主要服务"}'::jsonb),
    description = COALESCE(description, '{"en": "Main service description", "zh": "主要服务描述"}'::jsonb),
    category = COALESCE(category, 'main'),
    is_active = COALESCE(is_active, true),
    sort_order = COALESCE(sort_order, 0)
WHERE name IS NULL OR category IS NULL;

-- 2. 确保每个service至少有一条main记录
INSERT INTO public.service_details (
    service_id, 
    name, 
    description, 
    category, 
    is_active, 
    sort_order,
    pricing_type,
    duration_type,
    verification_status
)
SELECT 
    s.id,
    '{"en": "Main Service", "zh": "主要服务"}'::jsonb,
    '{"en": "Main service description", "zh": "主要服务描述"}'::jsonb,
    'main',
    true,
    0,
    'fixed_price',
    'hours',
    'pending'
FROM public.services s
WHERE NOT EXISTS (
    SELECT 1 FROM public.service_details sd 
    WHERE sd.service_id = s.id AND sd.category = 'main'
);

-- ========================================
-- 第四步：添加约束和索引
-- ========================================

-- 1. 设置非空约束
ALTER TABLE public.service_details 
ALTER COLUMN name SET NOT NULL,
ALTER COLUMN category SET NOT NULL;

-- 2. 创建索引
CREATE INDEX IF NOT EXISTS idx_service_details_service_id ON public.service_details(service_id);
CREATE INDEX IF NOT EXISTS idx_service_details_category ON public.service_details(category);
CREATE INDEX IF NOT EXISTS idx_service_details_parent_id ON public.service_details(parent_id);
CREATE INDEX IF NOT EXISTS idx_service_details_available ON public.service_details(is_active);
CREATE INDEX IF NOT EXISTS idx_service_details_sort_order ON public.service_details(sort_order);
CREATE INDEX IF NOT EXISTS idx_service_details_name ON public.service_details USING GIN (name);

-- 3. 添加业务规则约束
-- 确保每个service至少有一条main记录
ALTER TABLE public.service_details 
ADD CONSTRAINT IF NOT EXISTS service_details_main_required 
CHECK (
    EXISTS (
        SELECT 1 FROM service_details sd2 
        WHERE sd2.service_id = service_details.service_id 
        AND sd2.category = 'main'
    )
);

-- 主服务详情唯一性约束
CREATE UNIQUE INDEX IF NOT EXISTS idx_service_details_main_unique 
ON service_details(service_id) 
WHERE category = 'main';

-- 子服务必须关联到主服务
ALTER TABLE public.service_details 
ADD CONSTRAINT IF NOT EXISTS service_details_sub_parent_required 
CHECK (
    (category = 'sub' AND parent_id IS NOT NULL) OR 
    (category != 'sub')
);

-- ========================================
-- 第五步：验证数据完整性
-- ========================================

-- 验证每个service都有main记录
DO $$
DECLARE
    missing_main_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO missing_main_count
    FROM public.services s
    WHERE NOT EXISTS (
        SELECT 1 FROM public.service_details sd 
        WHERE sd.service_id = s.id AND sd.category = 'main'
    );
    
    IF missing_main_count > 0 THEN
        RAISE EXCEPTION '发现 % 个服务缺少主服务详情记录', missing_main_count;
    ELSE
        RAISE NOTICE '所有服务都有主服务详情记录';
    END IF;
END $$;

-- 验证子服务关联性
DO $$
DECLARE
    orphan_sub_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO orphan_sub_count
    FROM public.service_details sd
    WHERE sd.category = 'sub' AND sd.parent_id IS NULL;
    
    IF orphan_sub_count > 0 THEN
        RAISE EXCEPTION '发现 % 个孤立的子服务记录', orphan_sub_count;
    ELSE
        RAISE NOTICE '所有子服务都有正确的关联关系';
    END IF;
END $$;

-- ========================================
-- 第六步：更新统计信息
-- ========================================

-- 更新表的统计信息
ANALYZE public.service_details;

-- ========================================
-- 完成迁移
-- ========================================

-- 记录迁移完成
INSERT INTO public.migration_log (migration_name, version, executed_at, status)
VALUES ('service_details_restructure', '1.0', NOW(), 'completed')
ON CONFLICT (migration_name) DO UPDATE SET
    version = EXCLUDED.version,
    executed_at = EXCLUDED.executed_at,
    status = EXCLUDED.status;

-- 输出迁移结果
SELECT 
    'Service Detail表重构完成' as message,
    COUNT(*) as total_records,
    COUNT(CASE WHEN category = 'main' THEN 1 END) as main_records,
    COUNT(CASE WHEN category = 'sub' THEN 1 END) as sub_records
FROM public.service_details; 