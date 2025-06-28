-- Docu/database_schema/services.sql

-- 启用 UUID 扩展 (如果尚未启用)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

--
-- Table structure for table `services`
-- 核心服务信息表
--

CREATE TABLE public.services (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id), -- 关联到服务商资料表
    title jsonb NOT NULL, -- 修改为 jsonb 类型以支持多语言
    description jsonb, -- 修改为 jsonb 类型以支持多语言
    category_level1_id bigint NOT NULL REFERENCES public.ref_codes(id), -- 关联一级服务类别 (ref_codes type_code='SERVICE_TYPE')
    category_level2_id bigint REFERENCES public.ref_codes(id),          -- 关联二级服务类别 (ref_codes type_code='SERVICE_TYPE')
    status text NOT NULL DEFAULT 'draft',                               -- 服务状态：draft/active/paused/archived
    average_rating numeric DEFAULT 0.0,
    review_count integer DEFAULT 0,
    latitude numeric,
    longitude numeric,
    images_url jsonb, -- 服务图片URL列表，jsonb数组，支持多张图片
    service_delivery_method text NOT NULL DEFAULT 'on_site',           -- 服务交付方式：on_site/remote/online/pickup
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 添加索引
CREATE INDEX idx_services_provider_id ON public.services (provider_id);
CREATE INDEX idx_services_category_level1_id ON public.services (category_level1_id);
CREATE INDEX idx_services_category_level2_id ON public.services (category_level2_id);
CREATE INDEX idx_services_status ON public.services (status);
CREATE INDEX idx_services_location ON public.services (latitude, longitude);
CREATE INDEX idx_services_delivery_method ON public.services (service_delivery_method);

--
-- Table structure for table `service_details`
-- 服务详细信息表
--

CREATE TABLE public.service_details (
    service_id uuid PRIMARY KEY REFERENCES public.services(id) ON DELETE CASCADE, -- 关联到 services 表，并作为主键
    pricing_type text NOT NULL DEFAULT 'fixed_price',                              -- 定价类型：fixed_price/hourly/by_project/negotiable/quote_based/free/custom
    price numeric,
    currency text,
    negotiation_details text,
    duration_type text NOT NULL DEFAULT 'hours',                                   -- 时长单位：minutes/hours/days/visits/fixed/variable/scope_based
    duration interval,
    images_url text[] DEFAULT '{}',
    videos_url text[] DEFAULT '{}',
    tags text[] DEFAULT '{}',
    service_area_codes text[] DEFAULT '{}',                                        -- 服务覆盖区域编码列表（如邮政编码，关联 ref_codes）
    platform_service_fee_rate numeric,
    min_platform_service_fee numeric,
    service_details_json jsonb,                                                    -- 服务详情（流程、材料、注意事项等，通用JSON字段）
    extra_data jsonb,                                                              -- 额外数据（通用JSON字段）
    promotion_start timestamptz,
    promotion_end timestamptz,
    view_count integer DEFAULT 0,
    favorite_count integer DEFAULT 0,
    order_count integer DEFAULT 0,
    verification_status text NOT NULL DEFAULT 'pending',                           -- 服务的审核状态：verified/pending/rejected
    verification_documents text[] DEFAULT '{}',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 添加索引
CREATE INDEX idx_service_details_pricing_type ON public.service_details (pricing_type);
CREATE INDEX idx_service_details_duration_type ON public.service_details (duration_type);
CREATE INDEX idx_service_details_tags ON public.service_details USING GIN (tags);
CREATE INDEX idx_service_details_service_area_codes ON public.service_details USING GIN (service_area_codes);

--
-- Sample data for `services` and `service_details` (新版ID规则)
-- Note: provider_id UUIDs must exist in the public.provider_profiles table.
-- Note: category_level1_id and category_level2_id must exist in the public.ref_codes table.
--

-- 1. 家政到家 > 清洁保养
INSERT INTO public.services (id, provider_id, title, description, category_level1_id, category_level2_id, status, average_rating, review_count, latitude, longitude, images_url, service_delivery_method, created_at, updated_at) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', (SELECT id FROM public.provider_profiles LIMIT 1), '{"en": "Standard Home Cleaning", "zh": "标准居家清洁"}', '{"en": "Comprehensive cleaning for homes, including living rooms, bedrooms, and bathrooms.", "zh": "全面家庭清洁，包括客厅、卧室和浴室的清洁。"}', 1020000, 1020100, 'active', 4.7, 95, 34.0522, -118.2437, '{"https://example.com/clean1.jpg", "https://example.com/clean2.jpg"}', 'on_site', now(), now());
INSERT INTO public.service_details (service_id, pricing_type, price, currency, duration_type, duration, images_url, tags, service_area_codes, service_details_json, promotion_start, promotion_end) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'fixed_price', 150.00, 'CAD', 'fixed', '4 hours', '{"https://example.com/clean1.jpg", "https://example.com/clean2.jpg"}', ARRAY['深度清洁', '住宅', '小时计费'], ARRAY['V6B', 'V5K'], '{"included": ["吸尘", "拖地", "除尘"], "excluded": ["擦窗"]}', '2023-10-01 00:00:00+00', '2024-12-31 23:59:59+00');

-- 2. 家政到家 > 清洁保养 > 水管维护
INSERT INTO public.services (id, provider_id, title, description, category_level1_id, category_level2_id, status, average_rating, review_count, latitude, longitude, images_url, service_delivery_method, created_at, updated_at) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', (SELECT id FROM public.provider_profiles OFFSET 1 LIMIT 1), '{"en": "Emergency Plumbing Repair", "zh": "紧急管道维修"}', '{"en": "Fast and reliable plumbing services for leaks, clogs, and pipe repairs. Price negotiable based on complexity.", "zh": "快速可靠的管道服务，解决漏水、堵塞和管道维修问题。价格可根据复杂程度协商。"}', 1020000, 1020100, 'active', 4.9, 150, 34.0522, -118.2437, '{"https://example.com/plumb1.jpg"}', 'on_site', now(), now());
INSERT INTO public.service_details (service_id, pricing_type, price, currency, negotiation_details, duration_type, images_url, tags, service_details_json) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'negotiable', NULL, 'CAD', '价格取决于零件和人工。请致电估价。', 'hourly', '{"https://example.com/plumb1.jpg"}', ARRAY['紧急服务', '漏水修复', '疏通下水道'], '{"steps": ["诊断", "维修", "测试"]}');

-- 3. 生活帮忙 > 专业服务 > IT支持
INSERT INTO public.services (id, provider_id, title, description, category_level1_id, category_level2_id, status, average_rating, review_count, latitude, longitude, images_url, service_delivery_method, created_at, updated_at) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', (SELECT id FROM public.provider_profiles LIMIT 1), '{"en": "Remote Desktop Troubleshooting", "zh": "远程桌面故障排除"}', '{"en": "Get help with software issues, network problems, and virus removal remotely.", "zh": "远程协助解决软件问题、网络问题和病毒清除。"}', 1060000, 1060200, 'active', 4.5, 70, NULL, NULL, '{"https://example.com/tutoring1.jpg"}', 'remote', now(), now());
INSERT INTO public.service_details (service_id, pricing_type, price, currency, duration_type, duration, images_url, tags, service_area_codes, service_details_json) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'fixed_price', 80.00, 'CAD', 'fixed', '1 hour', '{"https://example.com/tutoring1.jpg"}', ARRAY['技术支持', '远程服务', '软件帮助'], ARRAY['CA'], '{"level": ["初级", "中级", "高级"], "software": ["Zoom", "Skype"]}');

-- 4. 生活帮忙 > 健康支持 > 理疗服务
INSERT INTO public.services (id, provider_id, title, description, category_level1_id, category_level2_id, status, average_rating, review_count, latitude, longitude, images_url, service_delivery_method, created_at, updated_at) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', (SELECT id FROM public.provider_profiles OFFSET 1 LIMIT 1), '{"en": "Full Body Relaxation Massage", "zh": "全身放松按摩"}', '{"en": "Experience a calming full-body massage in the comfort of your home.", "zh": "在您舒适的家中享受全身放松按摩。"}', 1060000, 1060400, 'active', 4.9, 85, 34.0522, -118.2437, '{"https://example.com/massage1.jpg"}', 'on_site', now(), now());
INSERT INTO public.service_details (service_id, pricing_type, price, currency, duration_type, duration, images_url, tags, service_details_json) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'fixed_price', 100.00, 'CAD', 'fixed', '60 minutes', '{"https://example.com/massage1.jpg"}', ARRAY['放松', '健康', '上门按摩'], '{"benefits": ["缓解压力", "肌肉放松"]}');

-- 5. 出行广场 > 日常接送 > 机场接送
INSERT INTO public.services (id, provider_id, title, description, category_level1_id, category_level2_id, status, average_rating, review_count, latitude, longitude, images_url, service_delivery_method, created_at, updated_at) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', (SELECT id FROM public.provider_profiles LIMIT 1), '{"en": "Airport Transfer Service", "zh": "机场接送服务"}', '{"en": "Convenient airport transfer service, punctual and safe.", "zh": "便捷的机场接送服务，准时安全。"}', 1030000, 1030100, 'active', 4.8, 110, 34.0522, -118.2437, '{"https://example.com/airport1.jpg", "https://example.com/airport2.jpg"}', 'on_site', now(), now());
INSERT INTO public.service_details (service_id, pricing_type, price, currency, duration_type, duration, images_url, tags, service_area_codes) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', 'fixed_price', 60.00, 'CAD', 'fixed', '90 minutes', '{"https://example.com/airport1.jpg", "https://example.com/airport2.jpg"}', ARRAY['YVR', 'LAX']);

-- 6. 美食天地 > 定制美食 > 聚会大餐
INSERT INTO public.services (id, provider_id, title, description, category_level1_id, category_level2_id, status, average_rating, review_count, latitude, longitude, images_url, service_delivery_method, created_at, updated_at) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a16', (SELECT id FROM public.provider_profiles OFFSET 1 LIMIT 1), '{"en": "Private Custom Catering", "zh": "私人定制宴席"}', '{"en": "Customized theme banquets and party meals according to your needs.", "zh": "根据您的需求定制各种主题宴席和聚会餐点。"}', 1010000, 1010200, 'active', 4.9, 60, 34.0522, -118.2437, '{"https://example.com/catering1.jpg"}', 'on_site', now(), now());
INSERT INTO public.service_details (service_id, pricing_type, price, currency, negotiation_details, duration_type, images_url, tags, service_details_json) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a16', 'quote_based', NULL, 'CAD', '根据菜单和人数提供报价，欢迎咨询。', 'scope_based', '{"https://example.com/catering1.jpg"}', ARRAY['宴席', '聚会', '定制美食'], '{"cuisine_types": ["中餐", "西餐"], "min_guests": 10}');

-- 7. 学习课堂 > 学科辅导 > 英语/法语
INSERT INTO public.services (id, provider_id, title, description, category_level1_id, category_level2_id, status, average_rating, review_count, latitude, longitude, images_url, service_delivery_method, created_at, updated_at) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a17', (SELECT id FROM public.provider_profiles LIMIT 1), '{"en": "English Speaking 1-on-1 Tutoring", "zh": "英语口语一对一辅导"}', '{"en": "Online English speaking 1-on-1 tutoring to help you improve fluency.", "zh": "在线英语口语一对一辅导，助您提升流利度。"}', 1050000, 1050100, 'active', 4.6, 50, NULL, NULL, '{"https://example.com/tutoring1.jpg"}', 'online', now(), now());
INSERT INTO public.service_details (service_id, pricing_type, price, currency, duration_type, duration, images_url, tags, service_area_codes, service_details_json) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a17', 'hourly', 40.00, 'CAD', 'hours', '1 hour', '{"https://example.com/tutoring1.jpg"}', ARRAY['英语', '在线', '口语'], ARRAY['CA'], '{"level": ["初级", "中级", "高级"], "software": ["Zoom", "Skype"]}');

-- 8. 共享乐园 > 工具租赁 > 工具租赁
INSERT INTO public.services (id, provider_id, title, description, category_level1_id, category_level2_id, status, average_rating, review_count, latitude, longitude, images_url, service_delivery_method, created_at, updated_at) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a18', (SELECT id FROM public.provider_profiles OFFSET 1 LIMIT 1), '{"en": "Power Tool Rental", "zh": "电动工具租赁"}', '{"en": "Rent power tools for home improvement and DIY projects.", "zh": "为家庭装修和DIY项目租赁电动工具。"}', 1040000, 1040100, 'active', 4.7, 75, 49.2827, -123.1207, '{"https://example.com/tool1.jpg", "https://example.com/tool2.jpg"}', 'on_site', now(), now());
INSERT INTO public.service_details (service_id, pricing_type, price, currency, duration_type, tags, service_area_codes) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a18', 'fixed_price', 50.00, 'CAD', 'fixed', ARRAY['工具', '租赁', '家装'], ARRAY['Vancity']);

-- =============================
-- RLS 策略：允许 authenticated 用户 SELECT
-- =============================

-- 启用 RLS
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_details ENABLE ROW LEVEL SECURITY;

-- 创建 SELECT 策略
CREATE POLICY "Allow select on services" ON public.services
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Allow select on service_details" ON public.service_details
FOR SELECT
TO authenticated
USING (true); 