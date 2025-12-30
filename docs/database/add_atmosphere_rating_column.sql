-- ========================================
-- 添加缺失的 atmosphere_rating 字段
-- ========================================

DO $$
BEGIN
    -- 添加atmosphere_rating字段 (如果不存在)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'reviews' AND column_name = 'atmosphere_rating') THEN
        ALTER TABLE public.reviews 
        ADD COLUMN atmosphere_rating integer CHECK (atmosphere_rating >= 1 AND atmosphere_rating <= 5);
        
        RAISE NOTICE '✅ atmosphere_rating字段已添加到reviews表';
    ELSE
        RAISE NOTICE 'ℹ️ atmosphere_rating字段已存在';
    END IF;
END $$;

-- 验证字段是否添加成功
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'reviews' 
AND column_name IN ('atmosphere_rating', 'service_rating', 'value_rating', 'quality_rating')
ORDER BY column_name;






