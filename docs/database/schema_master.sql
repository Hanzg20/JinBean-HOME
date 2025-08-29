-- =====================================================
-- JinBean Platform - 数据库表结构主入口文件
-- 版本: v2.0.0
-- 创建日期: 2025-01-08
-- 描述: 所有表结构的统一入口，确保一致性
-- =====================================================

-- 启用必要的扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. 创建 provider_profiles 表
-- =====================================================
DROP TABLE IF EXISTS public.provider_profiles CASCADE;

CREATE TABLE public.provider_profiles (
    -- 基本标识字段
    id uuid NOT NULL,
    user_id uuid NULL DEFAULT auth.uid(),
    
    -- 业务基本信息
    business_address text NULL,
    service_areas text[] NULL,
    service_categories text[] NULL,
    status text NOT NULL DEFAULT 'pending'::text,
    documents text[] NULL,
    license_number text NULL,
    review_count integer NULL DEFAULT 0,
    provider_type text NULL DEFAULT 'individual'::text,
    
    -- 税务和法务信息
    has_gst_hst boolean NULL DEFAULT false,
    bn_number text NULL,
    annual_income_estimate numeric NULL DEFAULT 0,
    tax_status_notice_shown boolean NULL DEFAULT false,
    tax_report_available boolean NULL DEFAULT false,
    
    -- 地址和位置信息
    address_id uuid NULL,
    
    -- 认证和资质信息  
    certification_files jsonb NULL,
    certification_status text NULL DEFAULT 'pending'::text,
    is_certified boolean NULL DEFAULT false,
    experience_years integer NULL,
    
    -- 服务范围和定价
    service_radius_km numeric NULL,
    base_price numeric NULL,
    pricing_type text NULL,
    
    -- 工作安排和团队
    work_schedule jsonb NULL,
    team_members jsonb NULL,
    payment_methods jsonb NULL,
    
    -- 状态管理
    is_active boolean NULL DEFAULT true,
    vacation_mode boolean NULL DEFAULT false,
    notification_settings jsonb NULL,
    
    -- 个人信息和展示（国际化支持）
    display_name jsonb NULL,          -- 多语言显示名称
    bio jsonb NULL,                   -- 多语言个人简介
    avatar_url text NULL,             -- 头像URL
    phone text NULL,                  -- 联系电话
    email text NULL,                  -- 联系邮箱
    
    -- 评价和统计
    rating numeric NULL,              -- 平均评分
    
    -- 标签和社交
    tags text[] NULL,                 -- 服务标签
    social_links jsonb NULL,          -- 社交媒体链接
    custom_fields jsonb NULL,         -- 自定义字段
    
    -- 时间戳
    created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    
    -- 约束
    CONSTRAINT provider_profiles_pkey PRIMARY KEY (id),
    CONSTRAINT provider_profiles_address_id_fkey FOREIGN KEY (address_id) REFERENCES addresses (id),
    CONSTRAINT provider_profiles_provider_type_check CHECK (
        (provider_type = ANY (ARRAY['individual'::text, 'corporate'::text]))
    ),
    CONSTRAINT provider_profiles_status_check CHECK (
        (status = ANY (
            ARRAY[
                'pending'::text,
                'active'::text,
                'suspended'::text,
                'rejected'::text
            ]
        ))
    )
) TABLESPACE pg_default;

-- =====================================================
-- 2. 创建 services 表
-- =====================================================
DROP TABLE IF EXISTS public.services CASCADE;

CREATE TABLE public.services (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id),
    title jsonb NOT NULL,
    description jsonb,
    category_level1_id bigint NOT NULL,
    category_level2_id bigint,
    status text NOT NULL DEFAULT 'draft',
    average_rating numeric DEFAULT 0.0,
    review_count integer DEFAULT 0,
    latitude numeric,
    longitude numeric,
    images_url jsonb,
    service_delivery_method text NOT NULL DEFAULT 'on_site',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- =====================================================
-- 3. 创建 service_details 表（重构后）
-- =====================================================
DROP TABLE IF EXISTS public.service_details CASCADE;

CREATE TABLE public.service_details (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id uuid NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
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
    updated_at timestamptz NOT NULL DEFAULT now(),
    -- 新增字段：支持多子服务架构
    category text DEFAULT 'main',
    name jsonb,
    sub_category text,
    is_available boolean DEFAULT true,
    sort_order integer DEFAULT 0,
    current_stock integer,
    max_stock integer,
    attributes jsonb DEFAULT '{}',
    business_rules jsonb DEFAULT '{}',
    
    -- 约束
    CONSTRAINT unique_service_category_name UNIQUE (service_id, category, name)
);

-- =====================================================
-- 4. 创建 orders 表
-- =====================================================
DROP TABLE IF EXISTS public.orders CASCADE;

CREATE TABLE public.orders (
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

-- =====================================================
-- 5. 创建 order_items 表
-- =====================================================
DROP TABLE IF EXISTS public.order_items CASCADE;

CREATE TABLE public.order_items (
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

-- =====================================================
-- 6. 创建 ref_codes 表
-- =====================================================
DROP TABLE IF EXISTS public.ref_codes CASCADE;

CREATE TABLE public.ref_codes (
    id bigint PRIMARY KEY,
    type_code text NOT NULL,
    code text NOT NULL,
    name jsonb NOT NULL,
    description jsonb,
    parent_id bigint REFERENCES public.ref_codes(id),
    level smallint NOT NULL,
    sort_order integer NOT NULL DEFAULT 0,
    status smallint NOT NULL DEFAULT 1,
    extra_data jsonb DEFAULT '{}',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 唯一约束
ALTER TABLE public.ref_codes ADD CONSTRAINT unique_type_code_code UNIQUE (type_code, code);

-- =====================================================
-- 创建索引
-- =====================================================

-- provider_profiles 索引
CREATE INDEX IF NOT EXISTS idx_provider_profiles_address_id ON public.provider_profiles USING btree (address_id);
CREATE INDEX IF NOT EXISTS idx_provider_profiles_certification_status ON public.provider_profiles USING btree (certification_status);
CREATE INDEX IF NOT EXISTS idx_provider_profiles_experience_years ON public.provider_profiles USING btree (experience_years);
CREATE INDEX IF NOT EXISTS idx_provider_profiles_has_gst_hst ON public.provider_profiles USING btree (has_gst_hst);
CREATE INDEX IF NOT EXISTS idx_provider_profiles_is_certified ON public.provider_profiles USING btree (is_certified);
CREATE INDEX IF NOT EXISTS idx_provider_profiles_provider_type ON public.provider_profiles USING btree (provider_type);
CREATE INDEX IF NOT EXISTS idx_provider_profiles_service_categories ON public.provider_profiles USING gin (service_categories);
CREATE INDEX IF NOT EXISTS idx_provider_profiles_status ON public.provider_profiles USING btree (status);
CREATE INDEX IF NOT EXISTS idx_provider_profiles_tags ON public.provider_profiles USING gin (tags);
CREATE INDEX IF NOT EXISTS idx_provider_profiles_user_id ON public.provider_profiles USING btree (user_id);

-- services 索引
CREATE INDEX IF NOT EXISTS idx_services_provider_id ON public.services (provider_id);
CREATE INDEX IF NOT EXISTS idx_services_category_level1_id ON public.services (category_level1_id);
CREATE INDEX IF NOT EXISTS idx_services_category_level2_id ON public.services (category_level2_id);
CREATE INDEX IF NOT EXISTS idx_services_status ON public.services (status);
CREATE INDEX IF NOT EXISTS idx_services_location ON public.services (latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_services_delivery_method ON public.services (service_delivery_method);

-- service_details 索引
CREATE INDEX IF NOT EXISTS idx_service_details_service_id ON public.service_details (service_id);
CREATE INDEX IF NOT EXISTS idx_service_details_pricing_type ON public.service_details (pricing_type);
CREATE INDEX IF NOT EXISTS idx_service_details_duration_type ON public.service_details (duration_type);
CREATE INDEX IF NOT EXISTS idx_service_details_tags ON public.service_details USING GIN (tags);
CREATE INDEX IF NOT EXISTS idx_service_details_service_area_codes ON public.service_details USING GIN (service_area_codes);
CREATE INDEX IF NOT EXISTS idx_service_details_category ON public.service_details (category);
CREATE INDEX IF NOT EXISTS idx_service_details_available ON public.service_details (is_available);
CREATE INDEX IF NOT EXISTS idx_service_details_sort_order ON public.service_details (sort_order);
CREATE INDEX IF NOT EXISTS idx_service_details_name ON public.service_details USING GIN (name);
CREATE INDEX IF NOT EXISTS idx_service_details_attributes ON public.service_details USING GIN (attributes);
CREATE INDEX IF NOT EXISTS idx_service_details_business_rules ON public.service_details USING GIN (business_rules);

-- orders 索引
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON public.orders (user_id);
CREATE INDEX IF NOT EXISTS idx_orders_provider_id ON public.orders (provider_id);
CREATE INDEX IF NOT EXISTS idx_orders_service_id ON public.orders (service_id);
CREATE INDEX IF NOT EXISTS idx_orders_order_status ON public.orders (order_status);
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON public.orders (payment_status);
CREATE INDEX IF NOT EXISTS idx_orders_order_type ON public.orders (order_type);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON public.orders (created_at);
CREATE INDEX IF NOT EXISTS idx_orders_scheduled_start_time ON public.orders (scheduled_start_time);

-- order_items 索引
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON public.order_items (order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_service_id ON public.order_items (service_id);

-- ref_codes 索引
CREATE INDEX IF NOT EXISTS idx_ref_codes_type_code ON public.ref_codes (type_code);
CREATE INDEX IF NOT EXISTS idx_ref_codes_code ON public.ref_codes (code);
CREATE INDEX IF NOT EXISTS idx_ref_codes_parent_id ON public.ref_codes (parent_id);
CREATE INDEX IF NOT EXISTS idx_ref_codes_level ON public.ref_codes (level);
CREATE INDEX IF NOT EXISTS idx_ref_codes_status ON public.ref_codes (status);

-- =====================================================
-- 启用 RLS 策略
-- =====================================================
ALTER TABLE public.provider_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ref_codes ENABLE ROW LEVEL SECURITY;

-- 创建 SELECT 策略
CREATE POLICY "Allow select on provider_profiles" ON public.provider_profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow select on services" ON public.services FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow select on service_details" ON public.service_details FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow select on orders" ON public.orders FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow select on order_items" ON public.order_items FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow select on ref_codes" ON public.ref_codes FOR SELECT TO authenticated USING (true);

-- =====================================================
-- 完成提示
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '✅ JinBean数据库表结构创建完成！';
    RAISE NOTICE '📊 包含6个主要表：provider_profiles, services, service_details, orders, order_items, ref_codes';
    RAISE NOTICE '🔧 service_details表已重构，支持多子服务架构';
    RAISE NOTICE '🌐 所有关键字段支持多语言（JSONB格式）';
    RAISE NOTICE '📈 已创建完整的索引体系，优化查询性能';
END $$;
