-- ========================================
-- 非订单评价系统设计
-- 参考Yelp模式：体验即评价
-- ========================================

-- 1. 评价类型扩展
CREATE TYPE review_type AS ENUM (
    'order_based',    -- 基于订单的评价
    'visit_based',    -- 基于到店体验的评价
    'consultation',   -- 基于咨询体验的评价
    'online_interaction', -- 基于在线互动的评价
    'environmental'  -- 基于环境感知的评价
);

-- 2. 评价来源表
CREATE TABLE IF NOT EXISTS public.review_sources (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id uuid NOT NULL REFERENCES public.reviews(id) ON DELETE CASCADE,
    source_type review_type NOT NULL,
    source_description text, -- 详细描述评价来源
    visit_date date, -- 到店日期（如果有）
    interaction_channel varchar(50), -- 互动渠道：phone, online, in-person, walk-by
    
    -- 体验详情
    experience_duration integer, -- 体验时长（分钟）
    interaction_quality integer CHECK (interaction_quality >= 1 AND interaction_quality <= 5),
    environment_rating integer CHECK (environment_rating >= 1 AND environment_rating <= 5),
    
    created_at timestamp with time zone DEFAULT now()
);

-- 3. 用户信任度表
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
    last_calculated_at timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- 4. 评价质量评估表
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
    calculated_at timestamp with time zone DEFAULT now()
);

-- ========================================
-- 信任度计算函数
-- ========================================

CREATE OR REPLACE FUNCTION calculate_user_trust_score(user_uuid uuid)
RETURNS decimal(3,2) AS $$
DECLARE
    trust_score decimal(3,2) := 0.0;
    review_count integer;
    helpful_count integer;
    profile_score decimal(3,2);
    quality_score decimal(3,2);
    diversity_score decimal(3,2);
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

-- ========================================
-- 评价排序算法
-- ========================================

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
    INTO review_record, user_trust
    FROM public.reviews r
    LEFT JOIN public.user_trust_metrics utm ON r.reviewer_id = utm.user_id
    WHERE r.id = review_uuid;
    
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

-- ========================================
-- 触发器：自动更新信任度
-- ========================================

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

CREATE TRIGGER trigger_update_user_trust
    AFTER INSERT ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION update_user_trust_metrics();

-- ========================================
-- 视图：高质量评价展示
-- ========================================

CREATE OR REPLACE VIEW public.high_quality_reviews AS
SELECT 
    r.*,
    utm.trust_score as reviewer_trust_score,
    utm.verification_level as reviewer_level,
    rqm.overall_quality_score,
    calculate_review_ranking_score(r.id) as ranking_score,
    rs.source_type,
    rs.source_description
FROM public.reviews r
LEFT JOIN public.user_trust_metrics utm ON r.reviewer_id = utm.user_id
LEFT JOIN public.review_quality_metrics rqm ON r.id = rqm.review_id
LEFT JOIN public.review_sources rs ON r.id = rs.review_id
WHERE r.status = 'published'
ORDER BY calculate_review_ranking_score(r.id) DESC, r.created_at DESC;

-- ========================================
-- 示例：非订单评价场景
-- ========================================

-- 场景1：路过评价
INSERT INTO public.reviews (
    service_id, reviewer_id, reviewee_id,
    overall_rating, content, status
) VALUES (
    'service-uuid-1', 'user-uuid-1', 'provider-uuid-1',
    4, '路过看到店面很干净，装修很有特色，下次有机会来试试',
    'published'
);

INSERT INTO public.review_sources (
    review_id, source_type, source_description, 
    visit_date, interaction_channel, environment_rating
) VALUES (
    (SELECT id FROM public.reviews WHERE content LIKE '%路过看到店面%'),
    'environmental', '路过观察店面外观和环境',
    CURRENT_DATE, 'walk-by', 4
);

-- 场景2：咨询体验评价
INSERT INTO public.reviews (
    service_id, reviewer_id, reviewee_id,
    overall_rating, content, status
) VALUES (
    'service-uuid-2', 'user-uuid-2', 'provider-uuid-2',
    5, '电话咨询时客服态度很好，回答很专业，价格也很透明',
    'published'
);

INSERT INTO public.review_sources (
    review_id, source_type, source_description,
    interaction_channel, interaction_quality, experience_duration
) VALUES (
    (SELECT id FROM public.reviews WHERE content LIKE '%电话咨询%'),
    'consultation', '电话咨询服务和价格',
    'phone', 5, 15
);

-- ========================================
-- 完成
-- ========================================
