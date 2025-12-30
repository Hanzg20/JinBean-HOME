-- ========================================
-- 添加缺失的评价字段
-- ========================================

DO $$
BEGIN
    -- 添加quality_rating字段 (如果不存在)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'reviews' AND column_name = 'quality_rating') THEN
        ALTER TABLE public.reviews 
        ADD COLUMN quality_rating integer CHECK (quality_rating >= 1 AND quality_rating <= 5);
        
        RAISE NOTICE '✅ quality_rating字段已添加到reviews表';
    ELSE
        RAISE NOTICE 'ℹ️ quality_rating字段已存在';
    END IF;

    -- 添加value_rating字段 (如果不存在)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'reviews' AND column_name = 'value_rating') THEN
        ALTER TABLE public.reviews 
        ADD COLUMN value_rating integer CHECK (value_rating >= 1 AND value_rating <= 5);
        
        RAISE NOTICE '✅ value_rating字段已添加到reviews表';
    ELSE
        RAISE NOTICE 'ℹ️ value_rating字段已存在';
    END IF;

    -- 添加atmosphere_rating字段 (如果不存在)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'reviews' AND column_name = 'atmosphere_rating') THEN
        ALTER TABLE public.reviews 
        ADD COLUMN atmosphere_rating integer CHECK (atmosphere_rating >= 1 AND atmosphere_rating <= 5);
        
        RAISE NOTICE '✅ atmosphere_rating字段已添加到reviews表';
    ELSE
        RAISE NOTICE 'ℹ️ atmosphere_rating字段已存在';
    END IF;

    -- 添加source_description字段 (如果不存在)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'reviews' AND column_name = 'source_description') THEN
        ALTER TABLE public.reviews 
        ADD COLUMN source_description text;
        
        RAISE NOTICE '✅ source_description字段已添加到reviews表';
    ELSE
        RAISE NOTICE 'ℹ️ source_description字段已存在';
    END IF;

    -- 添加videos字段 (如果不存在)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'reviews' AND column_name = 'videos') THEN
        ALTER TABLE public.reviews 
        ADD COLUMN videos jsonb DEFAULT '[]'::jsonb;
        
        RAISE NOTICE '✅ videos字段已添加到reviews表';
    ELSE
        RAISE NOTICE 'ℹ️ videos字段已存在';
    END IF;

    -- 添加categories字段 (如果不存在)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'reviews' AND column_name = 'categories') THEN
        ALTER TABLE public.reviews 
        ADD COLUMN categories jsonb DEFAULT '[]'::jsonb;
        
        RAISE NOTICE '✅ categories字段已添加到reviews表';
    ELSE
        RAISE NOTICE 'ℹ️ categories字段已存在';
    END IF;

    -- 添加published_at字段 (如果不存在)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'reviews' AND column_name = 'published_at') THEN
        ALTER TABLE public.reviews 
        ADD COLUMN published_at timestamptz;
        
        RAISE NOTICE '✅ published_at字段已添加到reviews表';
    ELSE
        RAISE NOTICE 'ℹ️ published_at字段已存在';
    END IF;

    -- 添加report_count字段 (如果不存在)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'reviews' AND column_name = 'report_count') THEN
        ALTER TABLE public.reviews 
        ADD COLUMN report_count integer DEFAULT 0;
        
        RAISE NOTICE '✅ report_count字段已添加到reviews表';
    ELSE
        RAISE NOTICE 'ℹ️ report_count字段已存在';
    END IF;
END $$;

-- 验证字段是否添加成功
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'reviews' 
AND column_name IN (
    'quality_rating', 'value_rating', 'atmosphere_rating', 
    'source_description', 'videos', 'categories', 
    'published_at', 'report_count'
)
ORDER BY column_name;
