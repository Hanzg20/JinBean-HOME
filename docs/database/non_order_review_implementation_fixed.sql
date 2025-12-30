-- ========================================
-- 非订单评价系统 - 数据库更新脚本 (修复版)
-- 修复text[]到jsonb的转换问题
-- ========================================

-- 1. 修改reviews表，支持非订单评价
ALTER TABLE public.reviews 
    ALTER COLUMN order_id DROP NOT NULL, -- 允许order_id为空
    ADD COLUMN review_type varchar(20) DEFAULT 'order_based' CHECK (review_type IN ('order_based', 'visit_based', 'consultation', 'online_interaction', 'environmental')),
    ADD COLUMN source_description text, -- 评价来源详细描述
    ADD COLUMN atmosphere_rating integer CHECK (atmosphere_rating >= 1 AND atmosphere_rating <= 5), -- 环境评分
    ADD COLUMN tags jsonb DEFAULT '[]'::jsonb, -- 评价标签
    ADD COLUMN categories jsonb DEFAULT '[]'::jsonb, -- 分类标签
    ADD COLUMN is_anonymous boolean DEFAULT false, -- 匿名评价
    ADD COLUMN report_count integer DEFAULT 0, -- 举报次数
    ADD COLUMN published_at timestamptz, -- 发布时间
    ADD COLUMN videos jsonb DEFAULT '[]'::jsonb; -- 视频支持

-- 2. 处理images字段的类型转换
-- 先添加一个新的jsonb列
ALTER TABLE public.reviews ADD COLUMN images_new jsonb DEFAULT '[]'::jsonb;

-- 将现有的text[]数据转换为jsonb
UPDATE public.reviews 
SET images_new = CASE 
    WHEN images IS NULL OR array_length(images, 1) IS NULL THEN '[]'::jsonb
    ELSE to_jsonb(images)
END;

-- 删除旧的images列
ALTER TABLE public.reviews DROP COLUMN images;

-- 重命名新列为images
ALTER TABLE public.reviews RENAME COLUMN images_new TO images;

-- 3. 创建评价来源表
CREATE TABLE IF NOT EXISTS public.review_sources (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    review_id uuid NOT NULL REFERENCES public.reviews(id) ON DELETE CASCADE,
    source_type varchar(20) NOT NULL CHECK (source_type IN ('order_based', 'visit_based', 'consultation', 'online_interaction', 'environmental')),
    source_description text, -- 详细描述评价来源
    visit_date date, -- 到店日期（如果有）
    interaction_channel varchar(50), -- 互动渠道：phone, online, in-person, walk-by
    
    -- 体验详情
    experience_duration integer, -- 体验时长（分钟）
    interaction_quality integer CHECK (interaction_quality >= 1 AND interaction_quality <= 5),
    environment_rating integer CHECK (environment_rating >= 1 AND environment_rating <= 5),
    
    created_at timestamptz NOT NULL DEFAULT now()
);

-- 4. 创建用户信任度表
CREATE TABLE IF NOT EXISTS public.user_trust_metrics (
    user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- 基础指标
    total_reviews integer DEFAULT 0,
    helpful_votes_received integer DEFAULT 0,
    profile_completeness decimal(3,2) DEFAULT 0.0, -- 0.00-1.00
    
    -- 质量指标
    average_review_length integer DEFAULT 0,
    photo_upload_rate decimal(3,2) DEFAULT 0.0,
    response_rate decimal(3,2) DEFAULT 0.0, -- 对回复的回应率
    
    -- 行为指标
    review_frequency decimal(5,2) DEFAULT 0.0, -- 每月评价数
    diversity_score decimal(3,2) DEFAULT 0.0, -- 评价商家多样性
    
    -- 综合信任度
    trust_score decimal(3,2) DEFAULT 0.5, -- 0.00-1.00
    verification_level varchar(20) DEFAULT 'basic', -- basic, verified, elite
    
    -- 时间戳
    last_calculated_at timestamptz DEFAULT now(),
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 5. 创建评价质量评估表
CREATE TABLE IF NOT EXISTS public.review_quality_metrics (
    review_id uuid PRIMARY KEY REFERENCES public.reviews(id) ON DELETE CASCADE,
    
    -- 内容质量
    content_length integer DEFAULT 0,
    has_images boolean DEFAULT false,
    has_videos boolean DEFAULT false,
    tag_count integer DEFAULT 0,
    
    -- 互动质量
    helpful_votes integer DEFAULT 0,
    total_votes integer DEFAULT 0,
    reply_count integer DEFAULT 0,
    
    -- 质量分数
    content_quality_score decimal(3,2) DEFAULT 0.0,
    engagement_score decimal(3,2) DEFAULT 0.0,
    overall_quality_score decimal(3,2) DEFAULT 0.0,
    
    -- 时间戳
    calculated_at timestamptz DEFAULT now()
);

-- 6. 创建评价标签库表
CREATE TABLE IF NOT EXISTS public.review_tags (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name varchar(50) NOT NULL UNIQUE,
    category varchar(20) NOT NULL, -- 分类: environment, service, price, food, etc.
    usage_count integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now()
);

-- 7. 创建评价举报表
CREATE TABLE IF NOT EXISTS public.review_reports (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    review_id uuid NOT NULL REFERENCES public.reviews(id) ON DELETE CASCADE,
    reporter_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reason varchar(50) NOT NULL, -- 举报原因
    description text,
    status varchar(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'dismissed')),
    admin_notes text,
    created_at timestamptz DEFAULT now(),
    resolved_at timestamptz,
    resolved_by uuid REFERENCES auth.users(id)
);

-- 8. 创建评价互动表 (点赞、有用等)
CREATE TABLE IF NOT EXISTS public.review_interactions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    review_id uuid NOT NULL REFERENCES public.reviews(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    interaction_type varchar(20) NOT NULL CHECK (interaction_type IN ('helpful', 'not_helpful', 'like', 'report')),
    created_at timestamptz DEFAULT now(),
    
    UNIQUE(review_id, user_id, interaction_type) -- 每个用户对同一评价只能有一种互动
);

-- ========================================
-- 索引优化
-- ========================================

-- 评价查询索引
CREATE INDEX IF NOT EXISTS idx_reviews_service_id ON public.reviews(service_id);
CREATE INDEX IF NOT EXISTS idx_reviews_reviewer_id ON public.reviews(reviewer_id);
CREATE INDEX IF NOT EXISTS idx_reviews_reviewee_id ON public.reviews(reviewee_id);
CREATE INDEX IF NOT EXISTS idx_reviews_status ON public.reviews(status);
CREATE INDEX IF NOT EXISTS idx_reviews_rating ON public.reviews(overall_rating);
CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON public.reviews(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reviews_published_at ON public.reviews(published_at DESC);
CREATE INDEX IF NOT EXISTS idx_reviews_review_type ON public.reviews(review_type);

-- 复合索引
CREATE INDEX IF NOT EXISTS idx_reviews_service_status_rating ON public.reviews(service_id, status, overall_rating);
CREATE INDEX IF NOT EXISTS idx_reviews_service_published ON public.reviews(service_id, published_at DESC) WHERE status = 'published';

-- 全文搜索索引
CREATE INDEX IF NOT EXISTS idx_reviews_content_search ON public.reviews USING gin(to_tsvector('english', content || ' ' || COALESCE(title, '')));

-- 其他表索引
CREATE INDEX IF NOT EXISTS idx_review_sources_review_id ON public.review_sources(review_id);
CREATE INDEX IF NOT EXISTS idx_review_interactions_review_id ON public.review_interactions(review_id);
CREATE INDEX IF NOT EXISTS idx_review_interactions_user_id ON public.review_interactions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_trust_metrics_user_id ON public.user_trust_metrics(user_id);
CREATE INDEX IF NOT EXISTS idx_review_quality_metrics_review_id ON public.review_quality_metrics(review_id);

-- ========================================
-- 触发器函数
-- ========================================

-- 信任度计算函数
CREATE OR REPLACE FUNCTION calculate_user_trust_score(user_uuid uuid)
RETURNS decimal(3,2) AS $$
DECLARE
    trust_score decimal(3,2) := 0.0;
    review_count integer;
    helpful_count integer;
    profile_score decimal(3,2);
    quality_score decimal(3,2);
BEGIN
    -- 获取用户评价统计
    SELECT COUNT(*), COALESCE(SUM(helpful_count), 0)
    INTO review_count, helpful_count
    FROM public.reviews 
    WHERE reviewer_id = user_uuid AND status = 'published';
    
    -- 评价数量因子 (0-0.3)
    IF review_count >= 50 THEN
        trust_score := trust_score + 0.3;
    ELSIF review_count >= 20 THEN
        trust_score := trust_score + 0.2;
    ELSIF review_count >= 10 THEN
        trust_score := trust_score + 0.1;
    ELSIF review_count >= 5 THEN
        trust_score := trust_score + 0.05;
    END IF;
    
    -- 有用性因子 (0-0.3)
    IF helpful_count > 0 THEN
        trust_score := trust_score + LEAST(0.3, (helpful_count::decimal / review_count) * 0.3);
    END IF;
    
    -- 个人资料完整性 (0-0.2)
    SELECT COALESCE(profile_completeness, 0.0) INTO profile_score
    FROM public.user_trust_metrics 
    WHERE user_id = user_uuid;
    trust_score := trust_score + (profile_score * 0.2);
    
    -- 评价质量 (0-0.2)
    SELECT COALESCE(AVG(overall_quality_score), 0.0) INTO quality_score
    FROM public.review_quality_metrics rqm
    JOIN public.reviews r ON rqm.review_id = r.id
    WHERE r.reviewer_id = user_uuid AND r.status = 'published';
    trust_score := trust_score + (quality_score * 0.2);
    
    RETURN LEAST(1.0, trust_score);
END;
$$ LANGUAGE plpgsql;

-- 评价排序算法函数
CREATE OR REPLACE FUNCTION calculate_review_ranking_score(review_uuid uuid)
RETURNS decimal(5,2) AS $$
DECLARE
    ranking_score decimal(5,2) := 0.0;
    review_record record;
    user_trust decimal(3,2);
    quality_score decimal(3,2);
    recency_score decimal(3,2);
    engagement_score decimal(3,2);
BEGIN
    -- 获取评价基础信息
    SELECT r.*, utm.trust_score
    INTO review_record
    FROM public.reviews r
    LEFT JOIN public.user_trust_metrics utm ON r.reviewer_id = utm.user_id
    WHERE r.id = review_uuid;
    
    -- 获取用户信任度
    user_trust := review_record.trust_score;
    
    -- 用户信任度因子 (0-30分)
    ranking_score := ranking_score + (COALESCE(user_trust, 0.5) * 30);
    
    -- 评价质量因子 (0-25分)
    SELECT COALESCE(overall_quality_score, 0.0) INTO quality_score
    FROM public.review_quality_metrics 
    WHERE review_id = review_uuid;
    ranking_score := ranking_score + (quality_score * 25);
    
    -- 时间新鲜度因子 (0-20分)
    recency_score := CASE 
        WHEN review_record.created_at > now() - interval '7 days' THEN 1.0
        WHEN review_record.created_at > now() - interval '30 days' THEN 0.8
        WHEN review_record.created_at > now() - interval '90 days' THEN 0.6
        WHEN review_record.created_at > now() - interval '365 days' THEN 0.4
        ELSE 0.2
    END;
    ranking_score := ranking_score + (recency_score * 20);
    
    -- 互动参与度因子 (0-15分)
    engagement_score := CASE 
        WHEN review_record.helpful_count >= 10 THEN 1.0
        WHEN review_record.helpful_count >= 5 THEN 0.8
        WHEN review_record.helpful_count >= 2 THEN 0.6
        WHEN review_record.helpful_count >= 1 THEN 0.4
        ELSE 0.2
    END;
    ranking_score := ranking_score + (engagement_score * 15);
    
    -- 认证评价加分 (0-10分)
    IF review_record.is_verified THEN
        ranking_score := ranking_score + 10;
    END IF;
    
    RETURN ranking_score;
END;
$$ LANGUAGE plpgsql;

-- 更新用户信任度触发器
CREATE OR REPLACE FUNCTION update_user_trust_metrics()
RETURNS TRIGGER AS $$
BEGIN
    -- 更新用户信任度指标
    INSERT INTO public.user_trust_metrics (
        user_id, 
        total_reviews, 
        helpful_votes_received,
        trust_score,
        last_calculated_at
    )
    VALUES (
        NEW.reviewer_id,
        1,
        0,
        calculate_user_trust_score(NEW.reviewer_id),
        now()
    )
    ON CONFLICT (user_id) DO UPDATE SET
        total_reviews = user_trust_metrics.total_reviews + 1,
        trust_score = calculate_user_trust_score(NEW.reviewer_id),
        last_calculated_at = now(),
        updated_at = now();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器
CREATE TRIGGER trigger_update_user_trust
    AFTER INSERT ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION update_user_trust_metrics();

-- ========================================
-- RLS策略
-- ========================================

-- 启用RLS
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_sources ENABLE ROW LEVEL SECURITY;
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

-- ========================================
-- 示例数据
-- ========================================

-- 插入评价标签
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

-- 食物类
('味道不错', 'food'),
('食材新鲜', 'food'),
('分量充足', 'food'),
('口味独特', 'food'),
('健康营养', 'food')

ON CONFLICT (name) DO NOTHING;

-- ========================================
-- 完成
-- ========================================
