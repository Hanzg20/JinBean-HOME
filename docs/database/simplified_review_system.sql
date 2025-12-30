-- ========================================
-- 非订单评价系统 - 简化版实现
-- 遵循KISS原则，减少复杂度
-- ========================================

-- 1. 修改reviews表，支持非订单评价 (简化版)
ALTER TABLE public.reviews 
    ALTER COLUMN order_id DROP NOT NULL, -- 允许order_id为空
    ADD COLUMN review_type varchar(20) DEFAULT 'order_based' CHECK (review_type IN ('order_based', 'visit_based', 'consultation', 'environmental')),
    ADD COLUMN service_rating integer CHECK (service_rating >= 1 AND service_rating <= 5),
    ADD COLUMN tags jsonb DEFAULT '[]'::jsonb, -- 简化标签存储
    ADD COLUMN is_anonymous boolean DEFAULT false;

-- 2. 处理images字段的类型转换
ALTER TABLE public.reviews ADD COLUMN images_new jsonb DEFAULT '[]'::jsonb;

UPDATE public.reviews 
SET images_new = CASE 
    WHEN images IS NULL OR array_length(images, 1) IS NULL THEN '[]'::jsonb
    ELSE to_jsonb(images)
END;

ALTER TABLE public.reviews DROP COLUMN images;
ALTER TABLE public.reviews RENAME COLUMN images_new TO images;

-- 3. 创建评价互动表 (简化版)
CREATE TABLE IF NOT EXISTS public.review_interactions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    review_id uuid NOT NULL REFERENCES public.reviews(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    interaction_type varchar(20) NOT NULL CHECK (interaction_type IN ('helpful', 'not_helpful')),
    created_at timestamptz DEFAULT now(),
    
    UNIQUE(review_id, user_id, interaction_type)
);

-- 4. 创建评价标签库表 (简化版)
CREATE TABLE IF NOT EXISTS public.review_tags (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name varchar(50) NOT NULL UNIQUE,
    category varchar(20) NOT NULL,
    usage_count integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now()
);

-- ========================================
-- 核心索引 (简化版)
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
-- 简化触发器 (只保留必要的)
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

CREATE TRIGGER trigger_update_review_helpful_count
    AFTER INSERT OR UPDATE OR DELETE ON public.review_interactions
    FOR EACH ROW EXECUTE FUNCTION update_review_helpful_count();

-- ========================================
-- RLS策略 (简化版)
-- ========================================

-- 启用RLS
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_interactions ENABLE ROW LEVEL SECURITY;

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
-- 示例数据 (简化版)
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
-- 简化视图 (可选)
-- ========================================

-- 评价详情视图 (简化版)
CREATE OR REPLACE VIEW public.review_details AS
SELECT 
    r.*,
    up.display_name as reviewer_name,
    up.avatar_url as reviewer_avatar,
    pp.business_name as provider_name,
    s.name as service_name
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
-- 完成
-- ========================================
