-- ========================================
-- Review系统完整架构设计
-- 参考Yelp、大众点评等业界最佳实践
-- ========================================

-- 1. 评价主表 (增强版)
CREATE TABLE IF NOT EXISTS public.reviews (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- 基础关联
    service_id uuid NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    reviewer_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reviewee_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    order_id uuid REFERENCES public.orders(id) ON DELETE SET NULL, -- 可选，支持非订单评价
    
    -- 评价内容
    overall_rating integer NOT NULL CHECK (overall_rating >= 1 AND overall_rating <= 5),
    title varchar(200), -- 评价标题
    content text, -- 评价正文
    
    -- 多维度评分 (Yelp风格)
    quality_rating integer CHECK (quality_rating >= 1 AND quality_rating <= 5),
    service_rating integer CHECK (service_rating >= 1 AND service_rating <= 5),
    value_rating integer CHECK (value_rating >= 1 AND value_rating <= 5),
    atmosphere_rating integer CHECK (atmosphere_rating >= 1 AND atmosphere_rating <= 5),
    
    -- 多媒体内容
    images jsonb DEFAULT '[]'::jsonb, -- 图片URL数组
    videos jsonb DEFAULT '[]'::jsonb, -- 视频URL数组
    
    -- 标签系统 (大众点评风格)
    tags jsonb DEFAULT '[]'::jsonb, -- 评价标签: ["环境好", "服务快", "性价比高"]
    categories jsonb DEFAULT '[]'::jsonb, -- 分类标签: ["环境", "服务", "价格"]
    
    -- 状态管理
    status varchar(20) DEFAULT 'published' CHECK (status IN ('draft', 'published', 'hidden', 'reported', 'deleted')),
    is_anonymous boolean DEFAULT false, -- 匿名评价
    is_verified boolean DEFAULT false, -- 认证评价 (基于订单)
    
    -- 互动数据
    helpful_count integer DEFAULT 0, -- 有用数
    total_votes integer DEFAULT 0, -- 总投票数
    report_count integer DEFAULT 0, -- 举报次数
    
    -- 时间戳
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    published_at timestamp with time zone, -- 发布时间
    
    -- 约束
    UNIQUE(reviewer_id, service_id), -- 每个用户对同一服务只能评价一次
    CONSTRAINT reviews_overall_rating_check CHECK (overall_rating >= 1 AND overall_rating <= 5)
);

-- 2. 评价回复表 (商户回复)
CREATE TABLE IF NOT EXISTS public.review_replies (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id uuid NOT NULL REFERENCES public.reviews(id) ON DELETE CASCADE,
    replier_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    content text NOT NULL,
    is_public boolean DEFAULT true, -- 公开回复 vs 私信
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- 3. 评价互动表 (点赞、有用等)
CREATE TABLE IF NOT EXISTS public.review_interactions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id uuid NOT NULL REFERENCES public.reviews(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    interaction_type varchar(20) NOT NULL CHECK (interaction_type IN ('helpful', 'not_helpful', 'like', 'report')),
    created_at timestamp with time zone DEFAULT now(),
    
    UNIQUE(review_id, user_id, interaction_type) -- 每个用户对同一评价只能有一种互动
);

-- 4. 评价标签库表
CREATE TABLE IF NOT EXISTS public.review_tags (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name varchar(50) NOT NULL UNIQUE,
    category varchar(20) NOT NULL, -- 分类: environment, service, price, food, etc.
    usage_count integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now()
);

-- 5. 评价举报表
CREATE TABLE IF NOT EXISTS public.review_reports (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id uuid NOT NULL REFERENCES public.reviews(id) ON DELETE CASCADE,
    reporter_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reason varchar(50) NOT NULL, -- 举报原因
    description text,
    status varchar(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'dismissed')),
    admin_notes text,
    created_at timestamp with time zone DEFAULT now(),
    resolved_at timestamp with time zone,
    resolved_by uuid REFERENCES auth.users(id)
);

-- ========================================
-- 索引优化 (性能关键)
-- ========================================

-- 评价查询索引
CREATE INDEX IF NOT EXISTS idx_reviews_service_id ON public.reviews(service_id);
CREATE INDEX IF NOT EXISTS idx_reviews_reviewer_id ON public.reviews(reviewer_id);
CREATE INDEX IF NOT EXISTS idx_reviews_reviewee_id ON public.reviews(reviewee_id);
CREATE INDEX IF NOT EXISTS idx_reviews_status ON public.reviews(status);
CREATE INDEX IF NOT EXISTS idx_reviews_rating ON public.reviews(overall_rating);
CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON public.reviews(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reviews_published_at ON public.reviews(published_at DESC);

-- 复合索引 (常用查询组合)
CREATE INDEX IF NOT EXISTS idx_reviews_service_status_rating ON public.reviews(service_id, status, overall_rating);
CREATE INDEX IF NOT EXISTS idx_reviews_service_published ON public.reviews(service_id, published_at DESC) WHERE status = 'published';

-- 全文搜索索引
CREATE INDEX IF NOT EXISTS idx_reviews_content_search ON public.reviews USING gin(to_tsvector('english', content || ' ' || COALESCE(title, '')));

-- 互动索引
CREATE INDEX IF NOT EXISTS idx_review_interactions_review_id ON public.review_interactions(review_id);
CREATE INDEX IF NOT EXISTS idx_review_interactions_user_id ON public.review_interactions(user_id);

-- ========================================
-- 触发器 (自动更新)
-- ========================================

-- 更新评价统计
CREATE OR REPLACE FUNCTION update_review_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- 更新有用数统计
    UPDATE public.reviews 
    SET helpful_count = (
        SELECT COUNT(*) 
        FROM public.review_interactions 
        WHERE review_id = NEW.review_id AND interaction_type = 'helpful'
    ),
    total_votes = (
        SELECT COUNT(*) 
        FROM public.review_interactions 
        WHERE review_id = NEW.review_id AND interaction_type IN ('helpful', 'not_helpful')
    )
    WHERE id = NEW.review_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_review_stats
    AFTER INSERT OR UPDATE OR DELETE ON public.review_interactions
    FOR EACH ROW EXECUTE FUNCTION update_review_stats();

-- 更新时间戳
CREATE TRIGGER update_reviews_updated_at 
    BEFORE UPDATE ON public.reviews 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- RLS策略 (行级安全)
-- ========================================

-- 启用RLS
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_replies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_reports ENABLE ROW LEVEL SECURITY;

-- 评价查看策略
CREATE POLICY "Users can view published reviews" ON public.reviews
    FOR SELECT USING (status = 'published');

CREATE POLICY "Users can view own reviews" ON public.reviews
    FOR SELECT USING (auth.uid() = reviewer_id);

CREATE POLICY "Providers can view reviews for their services" ON public.reviews
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.services 
            WHERE id = service_id AND provider_id = (
                SELECT id FROM public.provider_profiles WHERE user_id = auth.uid()
            )
        )
    );

-- 评价创建策略
CREATE POLICY "Users can create reviews" ON public.reviews
    FOR INSERT WITH CHECK (auth.uid() = reviewer_id);

-- 评价更新策略
CREATE POLICY "Users can update own reviews" ON public.reviews
    FOR UPDATE USING (auth.uid() = reviewer_id);

-- 评价删除策略
CREATE POLICY "Users can delete own reviews" ON public.reviews
    FOR DELETE USING (auth.uid() = reviewer_id);

-- 回复策略
CREATE POLICY "Users can view public replies" ON public.review_replies
    FOR SELECT USING (is_public = true);

CREATE POLICY "Providers can create replies" ON public.review_replies
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.reviews r
            JOIN public.services s ON r.service_id = s.id
            WHERE r.id = review_id AND s.provider_id = (
                SELECT id FROM public.provider_profiles WHERE user_id = auth.uid()
            )
        )
    );

-- ========================================
-- 视图 (业务查询优化)
-- ========================================

-- 评价详情视图 (包含用户信息)
CREATE OR REPLACE VIEW public.review_details AS
SELECT 
    r.*,
    up.display_name as reviewer_name,
    up.avatar_url as reviewer_avatar,
    pp.business_name as provider_name,
    s.name as service_name,
    -- 计算平均分
    ROUND(
        (COALESCE(r.quality_rating, r.overall_rating) + 
         COALESCE(r.service_rating, r.overall_rating) + 
         COALESCE(r.value_rating, r.overall_rating) + 
         COALESCE(r.atmosphere_rating, r.overall_rating)) / 4.0, 1
    ) as average_rating
FROM public.reviews r
LEFT JOIN public.user_profiles up ON r.reviewer_id = up.user_id
LEFT JOIN public.provider_profiles pp ON r.reviewee_id = pp.id
LEFT JOIN public.services s ON r.service_id = s.id;

-- 服务评价统计视图
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
-- 示例数据 (标签库)
-- ========================================

INSERT INTO public.review_tags (name, category) VALUES
-- 环境类
('环境优雅', 'environment'),
('装修精美', 'environment'),
('空间宽敞', 'environment'),
('氛围温馨', 'environment'),
('干净整洁', 'environment'),

-- 服务类
('服务热情', 'service'),
('响应迅速', 'service'),
('专业细致', 'service'),
('态度友好', 'service'),
('效率很高', 'service'),

-- 价格类
('性价比高', 'price'),
('价格合理', 'price'),
('物有所值', 'price'),
('价格实惠', 'price'),
('价格偏贵', 'price'),

-- 食物类 (如果是餐饮)
('味道不错', 'food'),
('食材新鲜', 'food'),
('分量充足', 'food'),
('口味独特', 'food'),
('健康营养', 'food')

ON CONFLICT (name) DO NOTHING;

-- ========================================
-- 完成
-- ========================================






