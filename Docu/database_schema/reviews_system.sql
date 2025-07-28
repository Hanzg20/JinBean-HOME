-- 点评系统数据库设计
-- 支持多语言、评分、标签、匿名、回复等功能

-- ========================================
-- 1. 点评表 (reviews)
-- ========================================
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
    
    -- 评分和内容
    overall_rating DECIMAL(2,1) NOT NULL CHECK (overall_rating >= 1.0 AND overall_rating <= 5.0),
    content JSONB NOT NULL, -- 多语言内容 {"en": "...", "zh": "..."}
    is_anonymous BOOLEAN DEFAULT FALSE,
    
    -- 详细评分维度
    quality_rating DECIMAL(2,1) CHECK (quality_rating >= 1.0 AND quality_rating <= 5.0),
    punctuality_rating DECIMAL(2,1) CHECK (punctuality_rating >= 1.0 AND punctuality_rating <= 5.0),
    communication_rating DECIMAL(2,1) CHECK (communication_rating >= 1.0 AND communication_rating <= 5.0),
    value_rating DECIMAL(2,1) CHECK (value_rating >= 1.0 AND value_rating <= 5.0),
    
    -- 标签和图片
    tags TEXT[], -- 用户选择的标签
    images TEXT[], -- 图片URL数组
    
    -- 状态和统计
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'hidden', 'deleted')),
    helpful_count INTEGER DEFAULT 0,
    report_count INTEGER DEFAULT 0,
    
    -- 时间戳
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- 约束：每个用户对同一服务只能评价一次
    UNIQUE(service_id, user_id)
);

-- ========================================
-- 2. 点评回复表 (review_replies)
-- ========================================
CREATE TABLE IF NOT EXISTS public.review_replies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID NOT NULL REFERENCES public.reviews(id) ON DELETE CASCADE,
    replier_id UUID NOT NULL, -- 可以是provider_id或user_id
    replier_type TEXT NOT NULL CHECK (replier_type IN ('provider', 'user')),
    content JSONB NOT NULL, -- 多语言内容
    is_anonymous BOOLEAN DEFAULT FALSE,
    
    -- 状态
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'hidden', 'deleted')),
    
    -- 时间戳
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- 3. 点评标签表 (review_tags)
-- ========================================
CREATE TABLE IF NOT EXISTS public.review_tags (
    id SERIAL PRIMARY KEY,
    name JSONB NOT NULL, -- 多语言标签名
    category TEXT NOT NULL, -- 'quality', 'service', 'attitude', etc.
    icon TEXT, -- 图标名称
    color TEXT, -- 颜色代码
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- 4. 点评有用性投票表 (review_helpful_votes)
-- ========================================
CREATE TABLE IF NOT EXISTS public.review_helpful_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID NOT NULL REFERENCES public.reviews(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    is_helpful BOOLEAN NOT NULL, -- TRUE for helpful, FALSE for not helpful
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- 每个用户对同一评价只能投票一次
    UNIQUE(review_id, user_id)
);

-- ========================================
-- 5. 点评举报表 (review_reports)
-- ========================================
CREATE TABLE IF NOT EXISTS public.review_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID NOT NULL REFERENCES public.reviews(id) ON DELETE CASCADE,
    reporter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reason TEXT NOT NULL, -- 'spam', 'inappropriate', 'fake', etc.
    description TEXT, -- 详细描述
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'dismissed')),
    admin_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ,
    
    -- 每个用户对同一评价只能举报一次
    UNIQUE(review_id, reporter_id)
);

-- ========================================
-- 6. 索引优化
-- ========================================
CREATE INDEX IF NOT EXISTS idx_reviews_service_id ON public.reviews(service_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON public.reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_provider_id ON public.reviews(provider_id);
CREATE INDEX IF NOT EXISTS idx_reviews_overall_rating ON public.reviews(overall_rating);
CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON public.reviews(created_at);
CREATE INDEX IF NOT EXISTS idx_reviews_status ON public.reviews(status);

CREATE INDEX IF NOT EXISTS idx_review_replies_review_id ON public.review_replies(review_id);
CREATE INDEX IF NOT EXISTS idx_review_replies_replier_id ON public.review_replies(replier_id);

CREATE INDEX IF NOT EXISTS idx_review_helpful_votes_review_id ON public.review_helpful_votes(review_id);
CREATE INDEX IF NOT EXISTS idx_review_helpful_votes_user_id ON public.review_helpful_votes(user_id);

CREATE INDEX IF NOT EXISTS idx_review_reports_review_id ON public.review_reports(review_id);
CREATE INDEX IF NOT EXISTS idx_review_reports_status ON public.review_reports(status);

-- ========================================
-- 7. 行级安全策略 (RLS)
-- ========================================
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_replies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_helpful_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_reports ENABLE ROW LEVEL SECURITY;

-- Reviews表策略
CREATE POLICY "Users can view all active reviews" ON public.reviews
    FOR SELECT USING (status = 'active');

CREATE POLICY "Users can create reviews for their orders" ON public.reviews
    FOR INSERT WITH CHECK (
        user_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM public.orders 
            WHERE id = review_id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update their own reviews" ON public.reviews
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Users can delete their own reviews" ON public.reviews
    FOR DELETE USING (user_id = auth.uid());

-- Review replies表策略
CREATE POLICY "Users can view all active replies" ON public.review_replies
    FOR SELECT USING (status = 'active');

CREATE POLICY "Users can create replies" ON public.review_replies
    FOR INSERT WITH CHECK (replier_id = auth.uid());

CREATE POLICY "Users can update their own replies" ON public.review_replies
    FOR UPDATE USING (replier_id = auth.uid());

-- Helpful votes表策略
CREATE POLICY "Users can view all votes" ON public.review_helpful_votes
    FOR SELECT USING (true);

CREATE POLICY "Users can create their own votes" ON public.review_helpful_votes
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own votes" ON public.review_helpful_votes
    FOR UPDATE USING (user_id = auth.uid());

-- Reports表策略
CREATE POLICY "Users can create reports" ON public.review_reports
    FOR INSERT WITH CHECK (reporter_id = auth.uid());

CREATE POLICY "Users can view their own reports" ON public.review_reports
    FOR SELECT USING (reporter_id = auth.uid());

-- ========================================
-- 8. 触发器函数
-- ========================================

-- 更新reviews表的updated_at
CREATE OR REPLACE FUNCTION update_reviews_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_reviews_updated_at
    BEFORE UPDATE ON public.reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_reviews_updated_at();

-- 更新review_replies表的updated_at
CREATE OR REPLACE FUNCTION update_review_replies_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_review_replies_updated_at
    BEFORE UPDATE ON public.review_replies
    FOR EACH ROW
    EXECUTE FUNCTION update_review_replies_updated_at();

-- 更新helpful_count
CREATE OR REPLACE FUNCTION update_review_helpful_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.reviews 
        SET helpful_count = helpful_count + 1
        WHERE id = NEW.review_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.reviews 
        SET helpful_count = helpful_count - 1
        WHERE id = OLD.review_id;
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        -- 如果投票状态改变
        IF NEW.is_helpful != OLD.is_helpful THEN
            IF NEW.is_helpful THEN
                UPDATE public.reviews 
                SET helpful_count = helpful_count + 1
                WHERE id = NEW.review_id;
            ELSE
                UPDATE public.reviews 
                SET helpful_count = helpful_count - 1
                WHERE id = NEW.review_id;
            END IF;
        END IF;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_review_helpful_count
    AFTER INSERT OR UPDATE OR DELETE ON public.review_helpful_votes
    FOR EACH ROW
    EXECUTE FUNCTION update_review_helpful_count();

-- 更新report_count
CREATE OR REPLACE FUNCTION update_review_report_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.reviews 
        SET report_count = report_count + 1
        WHERE id = NEW.review_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.reviews 
        SET report_count = report_count - 1
        WHERE id = OLD.review_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_review_report_count
    AFTER INSERT OR DELETE ON public.review_reports
    FOR EACH ROW
    EXECUTE FUNCTION update_review_report_count();

-- ========================================
-- 9. 视图和函数
-- ========================================

-- 服务评分统计视图
CREATE OR REPLACE VIEW public.service_rating_stats AS
SELECT 
    service_id,
    COUNT(*) as total_reviews,
    AVG(overall_rating) as average_rating,
    COUNT(CASE WHEN overall_rating >= 4.0 THEN 1 END) as positive_reviews,
    COUNT(CASE WHEN overall_rating <= 2.0 THEN 1 END) as negative_reviews,
    AVG(quality_rating) as avg_quality_rating,
    AVG(punctuality_rating) as avg_punctuality_rating,
    AVG(communication_rating) as avg_communication_rating,
    AVG(value_rating) as avg_value_rating
FROM public.reviews
WHERE status = 'active'
GROUP BY service_id;

-- 用户点评列表视图
CREATE OR REPLACE VIEW public.user_reviews_view AS
SELECT 
    r.id,
    r.service_id,
    r.provider_id,
    r.order_id,
    r.overall_rating,
    r.content,
    r.is_anonymous,
    r.quality_rating,
    r.punctuality_rating,
    r.communication_rating,
    r.value_rating,
    r.tags,
    r.images,
    r.helpful_count,
    r.report_count,
    r.created_at,
    r.updated_at,
    s.title as service_title,
    pp.display_name as provider_name,
    u.email as user_email,
    u.raw_user_meta_data as user_metadata
FROM public.reviews r
JOIN public.services s ON r.service_id = s.id
JOIN public.provider_profiles pp ON r.provider_id = pp.id
JOIN auth.users u ON r.user_id = u.id
WHERE r.status = 'active';

-- ========================================
-- 10. 插入示例数据
-- ========================================

-- 插入点评标签
INSERT INTO public.review_tags (name, category, icon, color, sort_order) VALUES
('{"en": "Professional", "zh": "专业"}', 'quality', 'star', '#4CAF50', 1),
('{"en": "On Time", "zh": "准时"}', 'service', 'schedule', '#2196F3', 2),
('{"en": "Good Communication", "zh": "沟通良好"}', 'attitude', 'chat', '#FF9800', 3),
('{"en": "Good Value", "zh": "性价比高"}', 'value', 'attach_money', '#9C27B0', 4),
('{"en": "Clean Work", "zh": "工作干净"}', 'quality', 'cleaning_services', '#4CAF50', 5),
('{"en": "Friendly", "zh": "友好"}', 'attitude', 'sentiment_satisfied', '#FF9800', 6),
('{"en": "Responsive", "zh": "响应迅速"}', 'service', 'speed', '#2196F3', 7),
('{"en": "Reasonable Price", "zh": "价格合理"}', 'value', 'payments', '#9C27B0', 8)
ON CONFLICT DO NOTHING;

-- ========================================
-- 11. 验证脚本
-- ========================================

-- 验证表创建
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name LIKE 'review%';

-- 验证索引创建
SELECT indexname, tablename FROM pg_indexes 
WHERE tablename LIKE 'review%';

-- 验证触发器创建
SELECT trigger_name, event_manipulation, event_object_table 
FROM information_schema.triggers 
WHERE trigger_name LIKE '%review%';

-- 验证视图创建
SELECT table_name FROM information_schema.views 
WHERE table_schema = 'public' AND table_name LIKE '%review%'; 