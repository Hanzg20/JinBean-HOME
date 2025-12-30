-- ========================================
-- 非订单评价系统 - 简化版实现 (最终修复版)
-- 修复所有字段引用问题，确保完全兼容
-- ========================================

-- 1. 修改reviews表，支持非订单评价 (安全版)
DO $$
BEGIN
    -- 允许order_id为空
    ALTER TABLE public.reviews ALTER COLUMN order_id DROP NOT NULL;
    
    -- 添加review_type字段 (如果不存在)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'reviews' AND column_name = 'review_type') THEN
        ALTER TABLE public.reviews 
        ADD COLUMN review_type varchar(20) DEFAULT 'order_based' 
        CHECK (review_type IN ('order_based', 'visit_based', 'consultation', 'environmental'));
    END IF;
    
    -- 添加service_rating字段 (如果不存在)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'reviews' AND column_name = 'service_rating') THEN
        ALTER TABLE public.reviews 
        ADD COLUMN service_rating integer CHECK (service_rating >= 1 AND service_rating <= 5);
    END IF;
    
    -- 添加tags字段 (如果不存在)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'reviews' AND column_name = 'tags') THEN
        ALTER TABLE public.reviews 
        ADD COLUMN tags jsonb DEFAULT '[]'::jsonb;
    END IF;
    
    -- 添加is_anonymous字段 (如果不存在)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'reviews' AND column_name = 'is_anonymous') THEN
        ALTER TABLE public.reviews 
        ADD COLUMN is_anonymous boolean DEFAULT false;
    END IF;
    
    RAISE NOTICE 'Reviews table updated successfully';
END $$;

-- 2. 处理images字段的类型转换 (安全版)
DO $$
BEGIN
    -- 检查images字段类型
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'reviews' AND column_name = 'images' AND data_type = 'ARRAY') THEN
        -- 添加新的jsonb列
        ALTER TABLE public.reviews ADD COLUMN images_new jsonb DEFAULT '[]'::jsonb;
        
        -- 转换数据
        UPDATE public.reviews 
        SET images_new = CASE 
            WHEN images IS NULL OR array_length(images, 1) IS NULL THEN '[]'::jsonb
            ELSE to_jsonb(images)
        END;
        
        -- 删除旧列
        ALTER TABLE public.reviews DROP COLUMN images;
        
        -- 重命名新列
        ALTER TABLE public.reviews RENAME COLUMN images_new TO images;
        
        RAISE NOTICE 'Images field converted from text[] to jsonb';
    ELSE
        RAISE NOTICE 'Images field is already jsonb or does not exist';
    END IF;
END $$;

-- 3. 创建评价互动表 (如果不存在)
CREATE TABLE IF NOT EXISTS public.review_interactions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    review_id uuid NOT NULL REFERENCES public.reviews(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    interaction_type varchar(20) NOT NULL CHECK (interaction_type IN ('helpful', 'not_helpful')),
    created_at timestamptz DEFAULT now(),
    
    UNIQUE(review_id, user_id, interaction_type)
);

-- 4. 创建评价标签库表 (如果不存在)
CREATE TABLE IF NOT EXISTS public.review_tags (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name varchar(50) NOT NULL UNIQUE,
    category varchar(20) NOT NULL,
    usage_count integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now()
);

-- ========================================
-- 核心索引 (安全版)
-- ========================================

-- 评价查询索引
CREATE INDEX IF NOT EXISTS idx_reviews_service_id ON public.reviews(service_id);
CREATE INDEX IF NOT EXISTS idx_reviews_reviewer_id ON public.reviews(reviewer_id);
CREATE INDEX IF NOT EXISTS idx_reviews_status ON public.reviews(status);
CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON public.reviews(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reviews_helpful_count ON public.reviews(helpful_count DESC);

-- 复合索引
CREATE INDEX IF NOT EXISTS idx_reviews_service_status ON public.reviews(service_id, status);
CREATE INDEX IF NOT EXISTS idx_reviews_service_published ON public.reviews(service_id, created_at DESC) WHERE status = 'published';

-- 互动索引
CREATE INDEX IF NOT EXISTS idx_review_interactions_review_id ON public.review_interactions(review_id);
CREATE INDEX IF NOT EXISTS idx_review_interactions_user_id ON public.review_interactions(user_id);

-- ========================================
-- 简化触发器 (安全版)
-- ========================================

-- 更新评价统计 (简化版)
CREATE OR REPLACE FUNCTION update_review_helpful_count()
RETURNS TRIGGER AS $$
BEGIN
    -- 更新有用数统计
    UPDATE public.reviews 
    SET helpful_count = (
        SELECT COUNT(*) 
        FROM public.review_interactions 
        WHERE review_id = NEW.review_id AND interaction_type = 'helpful'
    )
    WHERE id = NEW.review_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器 (如果不存在)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_update_review_helpful_count') THEN
        CREATE TRIGGER trigger_update_review_helpful_count
            AFTER INSERT OR UPDATE OR DELETE ON public.review_interactions
            FOR EACH ROW EXECUTE FUNCTION update_review_helpful_count();
    END IF;
END $$;

-- ========================================
-- RLS策略 (安全版)
-- ========================================

-- 启用RLS
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_interactions ENABLE ROW LEVEL SECURITY;

-- 删除现有策略 (如果存在)
DROP POLICY IF EXISTS "Users can view published reviews" ON public.reviews;
DROP POLICY IF EXISTS "Users can view own reviews" ON public.reviews;
DROP POLICY IF EXISTS "Users can create reviews" ON public.reviews;
DROP POLICY IF EXISTS "Users can update own reviews" ON public.reviews;
DROP POLICY IF EXISTS "Users can delete own reviews" ON public.reviews;

DROP POLICY IF EXISTS "Users can view interactions" ON public.review_interactions;
DROP POLICY IF EXISTS "Users can create interactions" ON public.review_interactions;
DROP POLICY IF EXISTS "Users can update own interactions" ON public.review_interactions;
DROP POLICY IF EXISTS "Users can delete own interactions" ON public.review_interactions;

-- 评价查看策略
CREATE POLICY "Users can view published reviews" ON public.reviews
    FOR SELECT USING (status = 'published');

CREATE POLICY "Users can view own reviews" ON public.reviews
    FOR SELECT USING (auth.uid() = reviewer_id);

-- 评价创建策略
CREATE POLICY "Users can create reviews" ON public.reviews
    FOR INSERT WITH CHECK (auth.uid() = reviewer_id);

-- 评价更新策略
CREATE POLICY "Users can update own reviews" ON public.reviews
    FOR UPDATE USING (auth.uid() = reviewer_id);

-- 评价删除策略
CREATE POLICY "Users can delete own reviews" ON public.reviews
    FOR DELETE USING (auth.uid() = reviewer_id);

-- 互动策略
CREATE POLICY "Users can view interactions" ON public.review_interactions
    FOR SELECT USING (true);

CREATE POLICY "Users can create interactions" ON public.review_interactions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own interactions" ON public.review_interactions
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own interactions" ON public.review_interactions
    FOR DELETE USING (auth.uid() = user_id);

-- ========================================
-- 示例数据 (安全版)
-- ========================================

-- 插入评价标签
INSERT INTO public.review_tags (name, category) VALUES
-- 环境类
('环境优雅', 'environment'),
('装修精美', 'environment'),
('干净整洁', 'environment'),

-- 服务类
('服务热情', 'service'),
('响应迅速', 'service'),
('专业细致', 'service'),

-- 价格类
('性价比高', 'price'),
('价格合理', 'price'),
('物有所值', 'price'),

-- 食物类
('味道不错', 'food'),
('食材新鲜', 'food'),
('分量充足', 'food')

ON CONFLICT (name) DO NOTHING;

-- ========================================
-- 简化视图 (最终修复版)
-- ========================================

-- 评价详情视图 (最终修复版)
CREATE OR REPLACE VIEW public.review_details AS
SELECT 
    r.*,
    -- 处理user_profiles的display_name字段
    CASE 
        WHEN up.display_name IS NULL THEN 'Anonymous User'
        WHEN jsonb_typeof(up.display_name) = 'string' THEN up.display_name::text
        WHEN jsonb_typeof(up.display_name) = 'object' THEN COALESCE(up.display_name->>'en', up.display_name->>'zh', 'Anonymous User')
        ELSE 'Anonymous User'
    END as reviewer_name,
    up.avatar_url as reviewer_avatar,
    
    -- 处理provider_profiles的display_name字段 (jsonb类型)
    CASE 
        WHEN pp.display_name IS NULL THEN 'Unknown Provider'
        WHEN jsonb_typeof(pp.display_name) = 'string' THEN pp.display_name::text
        WHEN jsonb_typeof(pp.display_name) = 'object' THEN COALESCE(pp.display_name->>'en', pp.display_name->>'zh', 'Unknown Provider')
        ELSE 'Unknown Provider'
    END as provider_name,
    
    -- 处理services的title字段 (jsonb类型)
    CASE 
        WHEN s.title IS NULL THEN 'Unknown Service'
        WHEN jsonb_typeof(s.title) = 'string' THEN s.title::text
        WHEN jsonb_typeof(s.title) = 'object' THEN COALESCE(s.title->>'en', s.title->>'zh', 'Unknown Service')
        ELSE 'Unknown Service'
    END as service_name
FROM public.reviews r
LEFT JOIN public.user_profiles up ON r.reviewer_id = up.user_id
LEFT JOIN public.provider_profiles pp ON r.reviewee_id = pp.id
LEFT JOIN public.services s ON r.service_id = s.id;

-- 服务评价统计视图 (简化版)
CREATE OR REPLACE VIEW public.service_review_stats AS
SELECT 
    service_id,
    COUNT(*) as total_reviews,
    ROUND(AVG(overall_rating), 1) as average_rating,
    COUNT(CASE WHEN overall_rating = 5 THEN 1 END) as five_star_count,
    COUNT(CASE WHEN overall_rating = 4 THEN 1 END) as four_star_count,
    COUNT(CASE WHEN overall_rating = 3 THEN 1 END) as three_star_count,
    COUNT(CASE WHEN overall_rating = 2 THEN 1 END) as two_star_count,
    COUNT(CASE WHEN overall_rating = 1 THEN 1 END) as one_star_count,
    COUNT(CASE WHEN is_verified = true THEN 1 END) as verified_reviews,
    MAX(created_at) as latest_review_date
FROM public.reviews 
WHERE status = 'published'
GROUP BY service_id;

-- ========================================
-- 验证脚本
-- ========================================

DO $$
DECLARE
    review_count integer;
    interaction_count integer;
    tag_count integer;
BEGIN
    -- 统计数据
    SELECT COUNT(*) INTO review_count FROM public.reviews;
    SELECT COUNT(*) INTO interaction_count FROM public.review_interactions;
    SELECT COUNT(*) INTO tag_count FROM public.review_tags;
    
    RAISE NOTICE '=== 非订单评价系统安装完成 ===';
    RAISE NOTICE '评价数量: %', review_count;
    RAISE NOTICE '互动数量: %', interaction_count;
    RAISE NOTICE '标签数量: %', tag_count;
    RAISE NOTICE '系统已准备就绪！';
END $$;

-- ========================================
-- 完成
-- ========================================






