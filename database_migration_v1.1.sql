-- Database Migration v1.1
-- 添加Provider平台新功能所需的数据库表

-- 启用 UUID 扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========================================
-- 1. 创建 provider_schedules 表
-- ========================================
CREATE TABLE IF NOT EXISTS public.provider_schedules (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    title text NOT NULL,
    description text,
    scheduled_date timestamptz NOT NULL,
    duration_minutes integer DEFAULT 60,
    status text NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
    priority text DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    location text,
    client_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
    order_id uuid REFERENCES public.orders(id) ON DELETE SET NULL,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_provider_schedules_provider_id ON public.provider_schedules(provider_id);
CREATE INDEX IF NOT EXISTS idx_provider_schedules_scheduled_date ON public.provider_schedules(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_provider_schedules_status ON public.provider_schedules(status);
CREATE INDEX IF NOT EXISTS idx_provider_schedules_client_id ON public.provider_schedules(client_id);

-- 创建触发器
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_provider_schedules_updated_at
    BEFORE UPDATE ON public.provider_schedules
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 2. 创建 provider_reviews 表（评价管理）
-- ========================================
CREATE TABLE IF NOT EXISTS public.provider_reviews (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    customer_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    order_id uuid REFERENCES public.orders(id) ON DELETE SET NULL,
    rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text text,
    review_type text DEFAULT 'service' CHECK (review_type IN ('service', 'communication', 'punctuality', 'quality')),
    is_public boolean DEFAULT true,
    is_verified boolean DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_provider_reviews_provider_id ON public.provider_reviews(provider_id);
CREATE INDEX IF NOT EXISTS idx_provider_reviews_customer_id ON public.provider_reviews(customer_id);
CREATE INDEX IF NOT EXISTS idx_provider_reviews_order_id ON public.provider_reviews(order_id);
CREATE INDEX IF NOT EXISTS idx_provider_reviews_rating ON public.provider_reviews(rating);
CREATE INDEX IF NOT EXISTS idx_provider_reviews_created_at ON public.provider_reviews(created_at);

-- 创建触发器
CREATE TRIGGER update_provider_reviews_updated_at
    BEFORE UPDATE ON public.provider_reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 3. 创建 provider_promotions 表（推广功能）
-- ========================================
CREATE TABLE IF NOT EXISTS public.provider_promotions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    title text NOT NULL,
    description text,
    promotion_type text NOT NULL CHECK (promotion_type IN ('discount', 'bonus', 'featured', 'special_offer')),
    discount_percentage numeric(5,2),
    discount_amount numeric(10,2),
    start_date timestamptz NOT NULL,
    end_date timestamptz NOT NULL,
    status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'expired')),
    target_services uuid[],
    target_customers uuid[],
    budget numeric(10,2),
    spent_amount numeric(10,2) DEFAULT 0,
    impressions integer DEFAULT 0,
    clicks integer DEFAULT 0,
    conversions integer DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_provider_promotions_provider_id ON public.provider_promotions(provider_id);
CREATE INDEX IF NOT EXISTS idx_provider_promotions_status ON public.provider_promotions(status);
CREATE INDEX IF NOT EXISTS idx_provider_promotions_start_date ON public.provider_promotions(start_date);
CREATE INDEX IF NOT EXISTS idx_provider_promotions_end_date ON public.provider_promotions(end_date);

-- 创建触发器
CREATE TRIGGER update_provider_promotions_updated_at
    BEFORE UPDATE ON public.provider_promotions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 4. 创建 provider_reports 表（报表功能）
-- ========================================
CREATE TABLE IF NOT EXISTS public.provider_reports (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    report_type text NOT NULL CHECK (report_type IN ('income', 'orders', 'clients', 'services', 'performance')),
    report_period text NOT NULL CHECK (report_period IN ('daily', 'weekly', 'monthly', 'yearly')),
    report_data jsonb NOT NULL DEFAULT '{}',
    generated_at timestamptz NOT NULL DEFAULT now(),
    period_start timestamptz NOT NULL,
    period_end timestamptz NOT NULL,
    is_exported boolean DEFAULT false,
    export_format text CHECK (export_format IN ('pdf', 'csv', 'excel')),
    created_at timestamptz NOT NULL DEFAULT now()
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_provider_reports_provider_id ON public.provider_reports(provider_id);
CREATE INDEX IF NOT EXISTS idx_provider_reports_type ON public.provider_reports(report_type);
CREATE INDEX IF NOT EXISTS idx_provider_reports_period ON public.provider_reports(report_period);
CREATE INDEX IF NOT EXISTS idx_provider_reports_generated_at ON public.provider_reports(generated_at);

-- ========================================
-- 5. 更新现有表结构
-- ========================================

-- 确保 services 表有必要的字段
ALTER TABLE public.services 
ADD COLUMN IF NOT EXISTS order_count integer DEFAULT 0,
ADD COLUMN IF NOT EXISTS average_rating numeric(3,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS review_count integer DEFAULT 0;

-- 确保 orders 表有必要的字段
ALTER TABLE public.orders 
ADD COLUMN IF NOT EXISTS status text DEFAULT 'pending',
ADD COLUMN IF NOT EXISTS order_status text DEFAULT 'pending';

-- 更新现有记录的status字段
UPDATE public.orders 
SET status = order_status 
WHERE status IS NULL AND order_status IS NOT NULL;

-- ========================================
-- 6. 创建视图和函数
-- ========================================

-- 创建Provider收入统计视图
CREATE OR REPLACE VIEW provider_income_stats AS
SELECT 
    ir.provider_id,
    COUNT(ir.id) as total_records,
    SUM(ir.amount) as total_income,
    SUM(CASE WHEN ir.status = 'pending' THEN ir.amount ELSE 0 END) as pending_amount,
    SUM(CASE WHEN ir.status = 'settled' THEN ir.amount ELSE 0 END) as settled_amount,
    AVG(ir.amount) as average_income,
    MIN(ir.created_at) as first_income_date,
    MAX(ir.created_at) as last_income_date
FROM income_records ir
GROUP BY ir.provider_id;

-- 创建Provider评价统计视图
CREATE OR REPLACE VIEW provider_review_stats AS
SELECT 
    pr.provider_id,
    COUNT(pr.id) as total_reviews,
    AVG(pr.rating) as average_rating,
    COUNT(CASE WHEN pr.rating >= 4 THEN 1 END) as positive_reviews,
    COUNT(CASE WHEN pr.rating <= 2 THEN 1 END) as negative_reviews,
    MIN(pr.created_at) as first_review_date,
    MAX(pr.created_at) as last_review_date
FROM provider_reviews pr
GROUP BY pr.provider_id;

-- ========================================
-- 7. 创建行级安全策略
-- ========================================

-- Provider日程表RLS
ALTER TABLE public.provider_schedules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Providers can view their own schedules" ON public.provider_schedules
    FOR SELECT USING (provider_id = auth.uid());

CREATE POLICY "Providers can insert their own schedules" ON public.provider_schedules
    FOR INSERT WITH CHECK (provider_id = auth.uid());

CREATE POLICY "Providers can update their own schedules" ON public.provider_schedules
    FOR UPDATE USING (provider_id = auth.uid());

CREATE POLICY "Providers can delete their own schedules" ON public.provider_schedules
    FOR DELETE USING (provider_id = auth.uid());

-- Provider评价表RLS
ALTER TABLE public.provider_reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Providers can view reviews about them" ON public.provider_reviews
    FOR SELECT USING (provider_id = auth.uid());

CREATE POLICY "Customers can insert reviews" ON public.provider_reviews
    FOR INSERT WITH CHECK (customer_id = auth.uid());

CREATE POLICY "Providers can update their own reviews" ON public.provider_reviews
    FOR UPDATE USING (provider_id = auth.uid());

-- Provider推广表RLS
ALTER TABLE public.provider_promotions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Providers can manage their own promotions" ON public.provider_promotions
    FOR ALL USING (provider_id = auth.uid());

-- Provider报表表RLS
ALTER TABLE public.provider_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Providers can manage their own reports" ON public.provider_reports
    FOR ALL USING (provider_id = auth.uid());

-- ========================================
-- 8. 创建示例数据（可选）
-- ========================================

-- 插入示例日程数据
INSERT INTO public.provider_schedules (provider_id, title, description, scheduled_date, status, priority)
SELECT 
    pp.id,
    '客户会议 - ' || u.full_name,
    '与客户讨论服务需求',
    NOW() + INTERVAL '1 day',
    'scheduled',
    'high'
FROM public.provider_profiles pp
CROSS JOIN auth.users u
WHERE u.id != pp.id
LIMIT 5;

-- 插入示例评价数据
INSERT INTO public.provider_reviews (provider_id, customer_id, rating, review_text, review_type)
SELECT 
    pp.id,
    u.id,
    FLOOR(RANDOM() * 5) + 1,
    '服务很好，非常满意！',
    'service'
FROM public.provider_profiles pp
CROSS JOIN auth.users u
WHERE u.id != pp.id
LIMIT 10;

-- ========================================
-- 9. 创建索引优化
-- ========================================

-- 为常用查询创建复合索引
CREATE INDEX IF NOT EXISTS idx_provider_schedules_provider_date ON public.provider_schedules(provider_id, scheduled_date);
CREATE INDEX IF NOT EXISTS idx_provider_reviews_provider_rating ON public.provider_reviews(provider_id, rating);
CREATE INDEX IF NOT EXISTS idx_provider_promotions_provider_status ON public.provider_promotions(provider_id, status);

-- ========================================
-- 10. 完成迁移
-- ========================================

-- 更新数据库版本
INSERT INTO public.migrations (version, applied_at, description)
VALUES ('1.1.0', NOW(), 'Added provider schedules, reviews, promotions, and reports tables')
ON CONFLICT (version) DO NOTHING;

-- 输出迁移完成信息
SELECT 'Database migration v1.1 completed successfully!' as status; 