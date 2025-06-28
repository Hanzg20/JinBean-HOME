-- 创建所有必要表的SQL脚本
-- 在Supabase SQL编辑器中运行此脚本

-- 启用 UUID 扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========================================
-- 1. 创建 ref_codes 表（如果不存在）
-- ========================================
CREATE TABLE IF NOT EXISTS public.ref_codes (
    id bigint PRIMARY KEY,
    type_code text NOT NULL,
    code text NOT NULL,
    name jsonb NOT NULL,
    description jsonb,
    parent_id bigint REFERENCES public.ref_codes(id),
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    UNIQUE(type_code, code)
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_ref_codes_type_code ON public.ref_codes (type_code);
CREATE INDEX IF NOT EXISTS idx_ref_codes_parent_id ON public.ref_codes (parent_id);

-- ========================================
-- 2. 创建 user_profiles 表
-- ========================================
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    avatar_url text,
    display_name text,
    gender text,
    birthday date,
    language text DEFAULT 'en',
    timezone text DEFAULT 'UTC',
    bio text,
    points integer DEFAULT 0,
    phone_verified boolean DEFAULT false,
    preferences jsonb DEFAULT '{
        "notification": {
            "push_enabled": true,
            "email_enabled": true,
            "sms_enabled": true
        },
        "privacy": {
            "profile_visible": true,
            "show_online": true
        }
    }',
    verification jsonb DEFAULT '{
        "is_verified": false,
        "documents": []
    }',
    service_preferences jsonb DEFAULT '{
        "favorite_categories": [],
        "preferred_providers": []
    }',
    social_links jsonb DEFAULT '{
        "facebook": null,
        "twitter": null,
        "instagram": null
    }',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 添加索引
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON public.user_profiles (user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_display_name ON public.user_profiles (display_name);
CREATE INDEX IF NOT EXISTS idx_user_profiles_created_at ON public.user_profiles (created_at);

-- 启用 RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- 创建 RLS 策略
DROP POLICY IF EXISTS "Users can view their own profile" ON public.user_profiles;
CREATE POLICY "Users can view their own profile"
    ON public.user_profiles
    FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own profile" ON public.user_profiles;
CREATE POLICY "Users can update their own profile"
    ON public.user_profiles
    FOR UPDATE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own profile" ON public.user_profiles;
CREATE POLICY "Users can insert their own profile"
    ON public.user_profiles
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ========================================
-- 3. 创建 provider_profiles 表
-- ========================================
CREATE TABLE IF NOT EXISTS public.provider_profiles (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid UNIQUE NOT NULL REFERENCES auth.users(id),
    company_name text,
    contact_phone text NOT NULL,
    contact_email text NOT NULL,
    business_address text,
    license_number text,
    description text,
    ratings_avg numeric DEFAULT 0.0,
    review_count integer DEFAULT 0,
    status text NOT NULL DEFAULT 'pending',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    provider_type text DEFAULT 'individual',
    has_gst_hst boolean DEFAULT FALSE,
    bn_number text,
    annual_income_estimate numeric DEFAULT 0,
    tax_status_notice_shown boolean DEFAULT FALSE,
    tax_report_available boolean DEFAULT FALSE
);

-- 添加索引
CREATE INDEX IF NOT EXISTS idx_provider_profiles_user_id ON public.provider_profiles (user_id);
CREATE INDEX IF NOT EXISTS idx_provider_profiles_status ON public.provider_profiles (status);
CREATE INDEX IF NOT EXISTS idx_provider_profiles_provider_type ON public.provider_profiles (provider_type);
CREATE INDEX IF NOT EXISTS idx_provider_profiles_has_gst_hst ON public.provider_profiles (has_gst_hst);

-- ========================================
-- 4. 创建 services 表
-- ========================================
CREATE TABLE IF NOT EXISTS public.services (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id),
    title jsonb NOT NULL,
    description jsonb,
    category_level1_id bigint NOT NULL REFERENCES public.ref_codes(id),
    category_level2_id bigint REFERENCES public.ref_codes(id),
    status text NOT NULL DEFAULT 'draft',
    average_rating numeric DEFAULT 0.0,
    review_count integer DEFAULT 0,
    latitude numeric,
    longitude numeric,
    service_delivery_method text NOT NULL DEFAULT 'on_site',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 添加索引
CREATE INDEX IF NOT EXISTS idx_services_provider_id ON public.services (provider_id);
CREATE INDEX IF NOT EXISTS idx_services_category_level1_id ON public.services (category_level1_id);
CREATE INDEX IF NOT EXISTS idx_services_category_level2_id ON public.services (category_level2_id);
CREATE INDEX IF NOT EXISTS idx_services_status ON public.services (status);
CREATE INDEX IF NOT EXISTS idx_services_location ON public.services (latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_services_delivery_method ON public.services (service_delivery_method);

-- ========================================
-- 5. 创建 service_details 表
-- ========================================
CREATE TABLE IF NOT EXISTS public.service_details (
    service_id uuid PRIMARY KEY REFERENCES public.services(id) ON DELETE CASCADE,
    pricing_type text NOT NULL DEFAULT 'fixed_price',
    price numeric,
    currency text,
    negotiation_details text,
    duration_type text NOT NULL DEFAULT 'hours',
    duration interval,
    images_url text[] DEFAULT '{}',
    videos_url text[] DEFAULT '{}',
    tags text[] DEFAULT '{}',
    service_area_codes text[] DEFAULT '{}',
    platform_service_fee_rate numeric,
    min_platform_service_fee numeric,
    service_details_json jsonb,
    extra_data jsonb,
    promotion_start timestamptz,
    promotion_end timestamptz,
    view_count integer DEFAULT 0,
    favorite_count integer DEFAULT 0,
    order_count integer DEFAULT 0,
    verification_status text NOT NULL DEFAULT 'pending',
    verification_documents text[] DEFAULT '{}',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 添加索引
CREATE INDEX IF NOT EXISTS idx_service_details_pricing_type ON public.service_details (pricing_type);
CREATE INDEX IF NOT EXISTS idx_service_details_duration_type ON public.service_details (duration_type);
CREATE INDEX IF NOT EXISTS idx_service_details_tags ON public.service_details USING GIN (tags);
CREATE INDEX IF NOT EXISTS idx_service_details_service_area_codes ON public.service_details USING GIN (service_area_codes);

-- ========================================
-- 6. 创建 orders 表
-- ========================================
CREATE TABLE IF NOT EXISTS public.orders (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number text UNIQUE NOT NULL,
    user_id uuid NOT NULL REFERENCES auth.users(id),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id),
    service_id uuid NOT NULL REFERENCES public.services(id),
    order_type text NOT NULL DEFAULT 'on_demand',
    fulfillment_mode_snapshot text NOT NULL,
    order_status text NOT NULL DEFAULT 'PendingAcceptance',
    total_price numeric NOT NULL,
    currency text NOT NULL DEFAULT 'CAD',
    payment_status text NOT NULL DEFAULT 'Pending',
    deposit_amount numeric,
    final_payment_amount numeric,
    coupon_id uuid,
    points_deduction_amount numeric DEFAULT 0,
    platform_service_fee_rate_snapshot numeric,
    platform_service_fee_amount numeric,
    scheduled_start_time timestamptz,
    scheduled_end_time timestamptz,
    actual_start_time timestamptz,
    actual_end_time timestamptz,
    service_address_id uuid,
    service_address_snapshot jsonb,
    service_latitude numeric,
    service_longitude numeric,
    user_notes text,
    provider_notes text,
    expires_at timestamptz,
    cancellation_reason text,
    cancellation_fee numeric,
    dispute_status text DEFAULT 'NoDispute',
    support_ticket_id uuid,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 添加索引
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON public.orders (user_id);
CREATE INDEX IF NOT EXISTS idx_orders_provider_id ON public.orders (provider_id);
CREATE INDEX IF NOT EXISTS idx_orders_service_id ON public.orders (service_id);
CREATE INDEX IF NOT EXISTS idx_orders_order_status ON public.orders (order_status);
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON public.orders (payment_status);
CREATE INDEX IF NOT EXISTS idx_orders_order_type ON public.orders (order_type);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON public.orders (created_at);
CREATE INDEX IF NOT EXISTS idx_orders_scheduled_start_time ON public.orders (scheduled_start_time);

-- ========================================
-- 7. 创建 order_items 表
-- ========================================
CREATE TABLE IF NOT EXISTS public.order_items (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    service_id uuid NOT NULL REFERENCES public.services(id),
    quantity integer NOT NULL DEFAULT 1,
    unit_price_snapshot numeric NOT NULL,
    subtotal_price numeric NOT NULL,
    service_name_snapshot text NOT NULL,
    service_description_snapshot text,
    service_image_snapshot text[] DEFAULT '{}',
    item_details_snapshot jsonb,
    pricing_type_snapshot text,
    duration_type_snapshot text,
    duration_snapshot interval,
    is_package_item boolean NOT NULL DEFAULT FALSE,
    parent_item_id uuid REFERENCES public.order_items(id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 添加索引
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON public.order_items (order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_service_id ON public.order_items (service_id);

-- ========================================
-- 8. 启用 RLS 并创建策略
-- ========================================

-- 启用 RLS
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.provider_profiles ENABLE ROW LEVEL SECURITY;

-- 创建 SELECT 策略
DROP POLICY IF EXISTS "Allow select on services" ON public.services;
CREATE POLICY "Allow select on services" ON public.services
FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "Allow select on service_details" ON public.service_details;
CREATE POLICY "Allow select on service_details" ON public.service_details
FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "Allow select on orders" ON public.orders;
CREATE POLICY "Allow select on orders" ON public.orders
FOR SELECT
TO authenticated
USING (auth.uid() = user_id OR auth.uid() IN (
    SELECT user_id FROM public.provider_profiles WHERE id = provider_id
));

DROP POLICY IF EXISTS "Allow select on order_items" ON public.order_items;
CREATE POLICY "Allow select on order_items" ON public.order_items
FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "Allow select on provider_profiles" ON public.provider_profiles;
CREATE POLICY "Allow select on provider_profiles" ON public.provider_profiles
FOR SELECT
TO authenticated
USING (true);

-- 创建 INSERT 策略
DROP POLICY IF EXISTS "Allow insert on orders" ON public.orders;
CREATE POLICY "Allow insert on orders" ON public.orders
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow insert on order_items" ON public.order_items;
CREATE POLICY "Allow insert on order_items" ON public.order_items
FOR INSERT
TO authenticated
WITH CHECK (true);

-- 创建 UPDATE 策略
DROP POLICY IF EXISTS "Allow update on orders" ON public.orders;
CREATE POLICY "Allow update on orders" ON public.orders
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id OR auth.uid() IN (
    SELECT user_id FROM public.provider_profiles WHERE id = provider_id
));

-- ========================================
-- 9. 插入基础数据
-- ========================================

-- 插入基础的服务类别数据
INSERT INTO public.ref_codes (id, type_code, code, name, description, parent_id, sort_order) VALUES
-- 一级类别
(1010000, 'SERVICE_TYPE', 'FOOD', '{"en": "Food & Dining", "zh": "美食天地"}', '{"en": "Food and dining services", "zh": "美食和餐饮服务"}', NULL, 1),
(1020000, 'SERVICE_TYPE', 'HOME', '{"en": "Home Services", "zh": "家政到家"}', '{"en": "Home maintenance and cleaning services", "zh": "家庭维护和清洁服务"}', NULL, 2),
(1030000, 'SERVICE_TYPE', 'TRANSPORT', '{"en": "Transportation", "zh": "出行广场"}', '{"en": "Transportation and delivery services", "zh": "交通和配送服务"}', NULL, 3),
(1040000, 'SERVICE_TYPE', 'SHARING', '{"en": "Sharing Economy", "zh": "共享乐园"}', '{"en": "Sharing economy services", "zh": "共享经济服务"}', NULL, 4),
(1050000, 'SERVICE_TYPE', 'EDUCATION', '{"en": "Education", "zh": "学习课堂"}', '{"en": "Education and tutoring services", "zh": "教育和辅导服务"}', NULL, 5),
(1060000, 'SERVICE_TYPE', 'LIFESTYLE', '{"en": "Lifestyle", "zh": "生活帮忙"}', '{"en": "Lifestyle and wellness services", "zh": "生活方式和健康服务"}', NULL, 6),

-- 二级类别
(1010100, 'SERVICE_TYPE', 'FOOD_DELIVERY', '{"en": "Food Delivery", "zh": "美食外卖"}', '{"en": "Food delivery services", "zh": "美食外卖服务"}', 1010000, 1),
(1010200, 'SERVICE_TYPE', 'CATERING', '{"en": "Custom Catering", "zh": "定制美食"}', '{"en": "Custom catering services", "zh": "定制餐饮服务"}', 1010000, 2),
(1020100, 'SERVICE_TYPE', 'CLEANING', '{"en": "Cleaning & Maintenance", "zh": "清洁保养"}', '{"en": "Cleaning and maintenance services", "zh": "清洁和保养服务"}', 1020000, 1),
(1020200, 'SERVICE_TYPE', 'REPAIR', '{"en": "Repair Services", "zh": "维修服务"}', '{"en": "Repair and maintenance services", "zh": "维修和保养服务"}', 1020000, 2),
(1030100, 'SERVICE_TYPE', 'TRANSPORT_PERSONAL', '{"en": "Personal Transport", "zh": "日常接送"}', '{"en": "Personal transportation services", "zh": "个人交通服务"}', 1030000, 1),
(1030200, 'SERVICE_TYPE', 'DELIVERY', '{"en": "Delivery Services", "zh": "配送服务"}', '{"en": "Delivery and courier services", "zh": "配送和快递服务"}', 1030000, 2),
(1040100, 'SERVICE_TYPE', 'TOOL_RENTAL', '{"en": "Tool Rental", "zh": "工具租赁"}', '{"en": "Tool and equipment rental", "zh": "工具和设备租赁"}', 1040000, 1),
(1040200, 'SERVICE_TYPE', 'SPACE_SHARING', '{"en": "Space Sharing", "zh": "空间共享"}', '{"en": "Space sharing services", "zh": "空间共享服务"}', 1040000, 2),
(1050100, 'SERVICE_TYPE', 'LANGUAGE_TUTORING', '{"en": "Language Tutoring", "zh": "学科辅导"}', '{"en": "Language tutoring services", "zh": "语言辅导服务"}', 1050000, 1),
(1050200, 'SERVICE_TYPE', 'SKILL_TUTORING', '{"en": "Skill Tutoring", "zh": "技能辅导"}', '{"en": "Skill tutoring services", "zh": "技能辅导服务"}', 1050000, 2),
(1060100, 'SERVICE_TYPE', 'FITNESS', '{"en": "Fitness & Health", "zh": "健身健康"}', '{"en": "Fitness and health services", "zh": "健身和健康服务"}', 1060000, 1),
(1060200, 'SERVICE_TYPE', 'TECH_SUPPORT', '{"en": "Tech Support", "zh": "专业服务"}', '{"en": "Technical support services", "zh": "技术支持服务"}', 1060000, 2),
(1060300, 'SERVICE_TYPE', 'BEAUTY', '{"en": "Beauty Services", "zh": "美容美发"}', '{"en": "Beauty and grooming services", "zh": "美容和美容服务"}', 1060000, 3),
(1060400, 'SERVICE_TYPE', 'WELLNESS', '{"en": "Wellness & Therapy", "zh": "健康支持"}', '{"en": "Wellness and therapy services", "zh": "健康和理疗服务"}', 1060000, 4)
ON CONFLICT (id) DO NOTHING;

-- 插入示例服务商数据
INSERT INTO public.provider_profiles (id, user_id, company_name, contact_phone, contact_email, business_address, license_number, description, ratings_avg, review_count, status, provider_type, has_gst_hst, bn_number, annual_income_estimate, tax_status_notice_shown, tax_report_available, created_at, updated_at) VALUES
('00000000-0000-0000-0000-000000000001', '4d639519-c607-48af-af3d-6c8c3e9c1c50', 'HomeCare Solutions Inc.', '123-456-7890', 'info@homecare.com', '123 Main St, Anytown', 'LIC12345', 'Professional home services specializing in cleaning and plumbing.', 4.8, 120, 'active', 'corporate', TRUE, 'BN123456789', 100000, TRUE, FALSE, now(), now()),
('00000000-0000-0000-0000-000000000002', '95ac66e5-4e8d-4b1b-b2fb-4648fef6e398', 'Relaxing Hands Massage', '987-654-3210', 'contact@relaxinghands.com', '456 Oak Ave, Anytown', 'LIC67890', 'Certified massage therapist offering mobile and in-clinic services.', 4.9, 80, 'active', 'individual', FALSE, NULL, 50000, FALSE, FALSE, now(), now()),
('00000000-0000-0000-0000-000000000003', '73440be0-ea60-4617-ba71-aff972138aae', 'Tech Guru Services', '555-111-2222', 'tech@techguru.com', '789 Tech Rd, Cyberville', NULL, 'Expert remote IT support and custom software development.', 4.5, 50, 'active', 'individual', TRUE, 'BN987654321', 75000, FALSE, FALSE, now(), now())
ON CONFLICT (id) DO NOTHING;

-- 插入示例服务数据
INSERT INTO public.services (id, provider_id, title, description, category_level1_id, category_level2_id, status, average_rating, review_count, latitude, longitude, service_delivery_method, created_at, updated_at) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '00000000-0000-0000-0000-000000000001', '{"en": "Standard Home Cleaning", "zh": "标准居家清洁"}', '{"en": "Comprehensive cleaning for homes, including living rooms, bedrooms, and bathrooms.", "zh": "全面家庭清洁，包括客厅、卧室和浴室的清洁。"}', 1020000, 1020100, 'active', 4.7, 95, 34.0522, -118.2437, 'on_site', now(), now()),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', '00000000-0000-0000-0000-000000000001', '{"en": "Emergency Plumbing Repair", "zh": "紧急管道维修"}', '{"en": "Fast and reliable plumbing services for leaks, clogs, and pipe repairs. Price negotiable based on complexity.", "zh": "快速可靠的管道服务，解决漏水、堵塞和管道维修问题。价格可根据复杂程度协商。"}', 1020000, 1020100, 'active', 4.9, 150, 34.0522, -118.2437, 'on_site', now(), now()),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', '00000000-0000-0000-0000-000000000003', '{"en": "Remote Desktop Troubleshooting", "zh": "远程桌面故障排除"}', '{"en": "Get help with software issues, network problems, and virus removal remotely.", "zh": "远程协助解决软件问题、网络问题和病毒清除。"}', 1060000, 1060200, 'active', 4.5, 70, NULL, NULL, 'remote', now(), now()),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', '00000000-0000-0000-0000-000000000002', '{"en": "Full Body Relaxation Massage", "zh": "全身放松按摩"}', '{"en": "Experience a calming full-body massage in the comfort of your home.", "zh": "在您舒适的家中享受全身放松按摩。"}', 1060000, 1060400, 'active', 4.9, 85, 34.0522, -118.2437, 'on_site', now(), now())
ON CONFLICT (id) DO NOTHING;

-- 插入示例服务详情数据
INSERT INTO public.service_details (service_id, pricing_type, price, currency, duration_type, duration, images_url, tags, service_area_codes, service_details_json, promotion_start, promotion_end) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'fixed_price', 150.00, 'CAD', 'fixed', '4 hours', ARRAY['https://example.com/clean1.jpg', 'https://example.com/clean2.jpg'], ARRAY['深度清洁', '住宅', '小时计费'], ARRAY['V6B', 'V5K'], '{"included": ["吸尘", "拖地", "除尘"], "excluded": ["擦窗"]}', '2023-10-01 00:00:00+00', '2024-12-31 23:59:59+00'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'negotiable', NULL, 'CAD', 'hourly', '2 hours', ARRAY['https://example.com/plumb1.jpg'], ARRAY['紧急服务', '漏水修复', '疏通下水道'], ARRAY['V6B'], '{"steps": ["诊断", "维修", "测试"]}', NULL, NULL),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'fixed_price', 80.00, 'CAD', 'fixed', '1 hour', ARRAY['https://example.com/tech1.jpg'], ARRAY['技术支持', '远程服务', '软件帮助'], ARRAY['CA'], '{"software": ["Zoom", "TeamViewer"]}', NULL, NULL),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'fixed_price', 100.00, 'CAD', 'fixed', '60 minutes', ARRAY['https://example.com/massage1.jpg'], ARRAY['放松', '健康', '上门按摩'], ARRAY['V6B'], '{"benefits": ["缓解压力", "肌肉放松"]}', NULL, NULL)
ON CONFLICT (service_id) DO NOTHING;

-- 插入示例订单数据
INSERT INTO public.orders (id, order_number, user_id, provider_id, service_id, order_type, fulfillment_mode_snapshot, order_status, total_price, currency, payment_status, scheduled_start_time, scheduled_end_time, created_at, updated_at) VALUES
('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380b01', 'ORD-20240726-0001', 'b3c4d5e6-7890-1234-5678-901234567890', '00000000-0000-0000-0000-000000000001', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'on_demand', 'platform', 'PendingAcceptance', 150.00, 'CAD', 'Pending', '2024-08-01 10:00:00+00', '2024-08-01 14:00:00+00', now(), now()),
('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380b02', 'ORD-20240726-0002', 'b3c4d5e6-7890-1234-5678-901234567890', '00000000-0000-0000-0000-000000000001', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'negotiated', 'external', 'Accepted', 200.00, 'CAD', 'Paid', '2024-08-05 09:00:00+00', '2024-08-05 11:00:00+00', now(), now()),
('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380b03', 'ORD-20240726-0003', 'c4d5e6f7-8901-2345-6789-012345678901', '00000000-0000-0000-0000-000000000002', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'appointment', 'platform', 'Completed', 100.00, 'CAD', 'Paid', '2024-07-20 15:00:00+00', '2024-07-20 16:00:00+00', now(), now())
ON CONFLICT (id) DO NOTHING;

-- 插入示例订单项数据
INSERT INTO public.order_items (id, order_id, service_id, quantity, unit_price_snapshot, subtotal_price, service_name_snapshot, service_description_snapshot, pricing_type_snapshot, duration_type_snapshot, duration_snapshot, created_at, updated_at) VALUES
('g0eebc99-9c0b-4ef8-bb6d-6bb9bd380c01', 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380b01', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 1, 150.00, 150.00, 'Standard Home Cleaning', 'Comprehensive cleaning for homes.', 'fixed_price', 'fixed', '4 hours', now(), now()),
('g0eebc99-9c0b-4ef8-bb6d-6bb9bd380c02', 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380b02', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 1, 200.00, 200.00, 'Emergency Plumbing Repair', 'Fast and reliable plumbing services.', 'negotiable', 'hourly', '2 hours', now(), now()),
('g0eebc99-9c0b-4ef8-bb6d-6bb9bd380c03', 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380b03', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 1, 100.00, 100.00, 'Full Body Relaxation Massage', 'Calming full-body massage.', 'fixed_price', 'fixed', '60 minutes', now(), now())
ON CONFLICT (id) DO NOTHING;

-- 插入示例用户资料数据
INSERT INTO public.user_profiles (user_id, display_name, gender, language, timezone, bio, points) VALUES
('b3c4d5e6-7890-1234-5678-901234567890', 'John Doe', 'male', 'en', 'America/New_York', 'Software developer and tech enthusiast', 150),
('c4d5e6f7-8901-2345-6789-012345678901', 'Jane Smith', 'female', 'en', 'America/Los_Angeles', 'Professional photographer and traveler', 200)
ON CONFLICT (user_id) DO NOTHING;

-- ========================================
-- 10. 创建触发器函数
-- ========================================

-- 创建 updated_at 触发器函数
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为所有表创建 updated_at 触发器
CREATE TRIGGER IF NOT EXISTS set_updated_at_user_profiles
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER IF NOT EXISTS set_updated_at_provider_profiles
    BEFORE UPDATE ON public.provider_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER IF NOT EXISTS set_updated_at_services
    BEFORE UPDATE ON public.services
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER IF NOT EXISTS set_updated_at_service_details
    BEFORE UPDATE ON public.service_details
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER IF NOT EXISTS set_updated_at_orders
    BEFORE UPDATE ON public.orders
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER IF NOT EXISTS set_updated_at_order_items
    BEFORE UPDATE ON public.order_items
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- 完成！
SELECT 'All tables created successfully!' as status; 