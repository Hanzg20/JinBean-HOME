-- =====================================================
-- JinBean Platform - 轮播图和社区热点数据表
-- 支持Home页面完全基于真实数据
-- =====================================================

-- =====================================================
-- 1. 轮播图表 (carousels)
-- =====================================================

CREATE TABLE IF NOT EXISTS public.carousels (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    title text NOT NULL,
    description text,
    image_url text NOT NULL,
    action_type text CHECK (action_type IN ('service', 'category', 'url')),
    service_id uuid REFERENCES public.services(id),
    category_id text,
    url text,
    is_active boolean DEFAULT true,
    sort_order integer DEFAULT 0,
    start_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    end_date timestamp with time zone DEFAULT (CURRENT_TIMESTAMP + interval '30 days'),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_carousels_active ON public.carousels(is_active);
CREATE INDEX IF NOT EXISTS idx_carousels_dates ON public.carousels(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_carousels_sort ON public.carousels(sort_order);

-- =====================================================
-- 2. 社区热点表 (community_hotspots)
-- =====================================================

CREATE TABLE IF NOT EXISTS public.community_hotspots (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    type text NOT NULL CHECK (type IN ('NEWS', 'JOB', 'BENEFIT', 'EVENT')),
    title text NOT NULL,
    description text,
    publisher text,
    image_url text,
    action_url text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_community_hotspots_active ON public.community_hotspots(is_active);
CREATE INDEX IF NOT EXISTS idx_community_hotspots_type ON public.community_hotspots(type);
CREATE INDEX IF NOT EXISTS idx_community_hotspots_created ON public.community_hotspots(created_at);

-- =====================================================
-- 3. 热点点击记录表 (hotspot_clicks)
-- =====================================================

CREATE TABLE IF NOT EXISTS public.hotspot_clicks (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    hotspot_id uuid NOT NULL REFERENCES public.community_hotspots(id),
    clicked_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_hotspot_clicks_hotspot ON public.hotspot_clicks(hotspot_id);
CREATE INDEX IF NOT EXISTS idx_hotspot_clicks_date ON public.hotspot_clicks(clicked_at);

-- =====================================================
-- 4. 插入测试数据
-- =====================================================

-- 插入轮播图测试数据
INSERT INTO public.carousels (title, description, image_url, action_type, category_id, sort_order) VALUES
('夏季服务优惠！', '所有清洁服务7月享受8折优惠', 'https://picsum.photos/id/237/800/450', 'category', '1020000', 1),
('新电工入驻', '认证电工24小时为您服务', 'https://picsum.photos/id/1015/800/450', 'category', '1060000', 2),
('推荐好友，获得$10！', '邀请朋友使用JinBean获得奖励', 'https://picsum.photos/id/1016/800/450', 'url', NULL, 3),
('美食节活动', '社区美食节即将开始，欢迎参加', 'https://picsum.photos/id/1018/800/450', 'category', '1010000', 4),
('IT支持服务', '专业IT技术支持，解决您的电脑问题', 'https://picsum.photos/id/1019/800/450', 'category', '1060000', 5);

-- 插入社区热点测试数据
INSERT INTO public.community_hotspots (type, title, description, publisher, action_url) VALUES
('NEWS', 'XXX社区：本周末举行亲子活动', '社区将举办亲子互动活动，欢迎家长和孩子们参加', '社区管理委员会', 'https://community.example.com/event/1'),
('JOB', '急聘！社区保安，待遇从优', '招聘社区保安，要求身体健康，责任心强', '物业公司', 'https://jobs.example.com/security'),
('BENEFIT', '长者免费体检活动即将开始', '为社区65岁以上长者提供免费健康体检', '社区卫生服务中心', 'https://health.example.com/checkup'),
('NEWS', '社区图书馆扩建通知', '社区图书馆将进行扩建，预计工期3个月', '社区管理委员会', 'https://community.example.com/library'),
('EVENT', '社区篮球比赛报名开始', '年度社区篮球比赛开始报名，欢迎篮球爱好者参加', '社区体育委员会', 'https://sports.example.com/basketball'),
('JOB', '招聘社区清洁工', '招聘社区清洁工，工作时间灵活', '物业公司', 'https://jobs.example.com/cleaner'),
('BENEFIT', '免费法律咨询服务', '每月第一个周六提供免费法律咨询', '社区法律服务中心', 'https://legal.example.com/consultation'),
('NEWS', '社区WiFi升级完成', '社区公共区域WiFi已升级，网速更快更稳定', '社区管理委员会', 'https://community.example.com/wifi');

-- =====================================================
-- 5. 创建更新时间触发器
-- =====================================================

-- 轮播图更新时间触发器
CREATE OR REPLACE FUNCTION update_carousels_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_carousels_updated_at
    BEFORE UPDATE ON public.carousels
    FOR EACH ROW
    EXECUTE FUNCTION update_carousels_updated_at();

-- 社区热点更新时间触发器
CREATE OR REPLACE FUNCTION update_community_hotspots_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_community_hotspots_updated_at
    BEFORE UPDATE ON public.community_hotspots
    FOR EACH ROW
    EXECUTE FUNCTION update_community_hotspots_updated_at();

-- =====================================================
-- 6. 验证数据
-- =====================================================

-- 验证轮播图数据
SELECT 
    'Carousels' as table_name,
    COUNT(*) as total_count,
    COUNT(CASE WHEN is_active = true THEN 1 END) as active_count
FROM public.carousels;

-- 验证社区热点数据
SELECT 
    'Community Hotspots' as table_name,
    COUNT(*) as total_count,
    COUNT(CASE WHEN is_active = true THEN 1 END) as active_count,
    COUNT(CASE WHEN type = 'NEWS' THEN 1 END) as news_count,
    COUNT(CASE WHEN type = 'JOB' THEN 1 END) as job_count,
    COUNT(CASE WHEN type = 'BENEFIT' THEN 1 END) as benefit_count
FROM public.community_hotspots;

-- 显示活跃的轮播图
SELECT 
    title,
    description,
    action_type,
    category_id,
    sort_order
FROM public.carousels
WHERE is_active = true
  AND start_date <= CURRENT_TIMESTAMP
  AND end_date >= CURRENT_TIMESTAMP
ORDER BY sort_order;

-- 显示最新的社区热点
SELECT 
    type,
    title,
    publisher,
    created_at
FROM public.community_hotspots
WHERE is_active = true
ORDER BY created_at DESC
LIMIT 5;

COMMIT;
