-- Docu/database_schema/provider_profiles.sql
-- 根据实际数据库表结构更新

-- 启用 UUID 扩展（如未启用）
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP TABLE IF EXISTS public.provider_profiles CASCADE;

CREATE TABLE public.provider_profiles (
    id uuid NOT NULL,
    business_address text NULL,
    service_areas text[] NULL,
    service_categories text[] NULL,
    status text NOT NULL DEFAULT 'pending'::text,
    documents text[] NULL,
    created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    user_id uuid NULL DEFAULT auth.uid(),
    license_number text NULL,
    review_count integer NULL DEFAULT 0,
    provider_type text NULL DEFAULT 'individual'::text,
    has_gst_hst boolean NULL DEFAULT false,
    bn_number text NULL,
    annual_income_estimate numeric NULL DEFAULT 0,
    tax_status_notice_shown boolean NULL DEFAULT false,
    tax_report_available boolean NULL DEFAULT false,
    address_id uuid NULL,
    certification_files jsonb NULL,
    certification_status text NULL DEFAULT 'pending'::text,
    service_radius_km numeric NULL,
    base_price numeric NULL,
    pricing_type text NULL,
    work_schedule jsonb NULL,
    team_members jsonb NULL,
    payment_methods jsonb NULL,
    is_active boolean NULL DEFAULT true,
    vacation_mode boolean NULL DEFAULT false,
    notification_settings jsonb NULL,
    -- 国际化字段：改为JSON格式支持多语言
    display_name jsonb NULL,  -- 从 text 改为 jsonb
    avatar_url text NULL,
    bio jsonb NULL,           -- 从 text 改为 jsonb
    phone text NULL,
    email text NULL,
    rating numeric NULL,
    is_certified boolean NULL DEFAULT false,
    experience_years integer NULL,
    tags text[] NULL,
    social_links jsonb NULL,
    custom_fields jsonb NULL,
    
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

-- 索引
CREATE INDEX IF NOT EXISTS idx_provider_profiles_address_id ON public.provider_profiles USING btree (address_id) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_provider_profiles_certification_status ON public.provider_profiles USING btree (certification_status) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_provider_profiles_experience_years ON public.provider_profiles USING btree (experience_years) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_provider_profiles_has_gst_hst ON public.provider_profiles USING btree (has_gst_hst) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_provider_profiles_is_certified ON public.provider_profiles USING btree (is_certified) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_provider_profiles_provider_type ON public.provider_profiles USING btree (provider_type) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_provider_profiles_service_categories ON public.provider_profiles USING gin (service_categories) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_provider_profiles_status ON public.provider_profiles USING btree (status) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_provider_profiles_tags ON public.provider_profiles USING gin (tags) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_provider_profiles_user_id ON public.provider_profiles USING btree (user_id) TABLESPACE pg_default;

-- 触发器
CREATE TRIGGER set_updated_at 
    BEFORE UPDATE ON provider_profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION handle_updated_at();

-- 表注释
COMMENT ON TABLE public.provider_profiles IS '服务提供商档案表，存储服务提供商的基本信息、资质、服务范围等，支持多语言国际化';
COMMENT ON COLUMN public.provider_profiles.id IS '主键ID';
COMMENT ON COLUMN public.provider_profiles.business_address IS '营业地址';
COMMENT ON COLUMN public.provider_profiles.service_areas IS '服务区域（城市/邮编数组）';
COMMENT ON COLUMN public.provider_profiles.service_categories IS '主营服务类别数组';
COMMENT ON COLUMN public.provider_profiles.status IS '状态：pending/active/suspended/rejected';
COMMENT ON COLUMN public.provider_profiles.documents IS '相关文档数组';
COMMENT ON COLUMN public.provider_profiles.user_id IS '关联用户ID';
COMMENT ON COLUMN public.provider_profiles.license_number IS '执照编号';
COMMENT ON COLUMN public.provider_profiles.review_count IS '评价数量';
COMMENT ON COLUMN public.provider_profiles.provider_type IS '提供商类型：individual/corporate';
COMMENT ON COLUMN public.provider_profiles.has_gst_hst IS '是否已注册GST/HST';
COMMENT ON COLUMN public.provider_profiles.bn_number IS '加拿大企业号';
COMMENT ON COLUMN public.provider_profiles.annual_income_estimate IS '年收入预估';
COMMENT ON COLUMN public.provider_profiles.tax_status_notice_shown IS '是否已展示税务合规提示';
COMMENT ON COLUMN public.provider_profiles.tax_report_available IS '是否已上传税务报表';
COMMENT ON COLUMN public.provider_profiles.address_id IS '结构化地址外键';
COMMENT ON COLUMN public.provider_profiles.certification_files IS '资质/保险/证书文件JSON';
COMMENT ON COLUMN public.provider_profiles.certification_status IS '认证状态';
COMMENT ON COLUMN public.provider_profiles.service_radius_km IS '可服务半径（公里）';
COMMENT ON COLUMN public.provider_profiles.base_price IS '起步价/上门费';
COMMENT ON COLUMN public.provider_profiles.pricing_type IS '定价方式';
COMMENT ON COLUMN public.provider_profiles.work_schedule IS '工作时间JSON';
COMMENT ON COLUMN public.provider_profiles.team_members IS '员工/技师信息JSON';
COMMENT ON COLUMN public.provider_profiles.payment_methods IS '支付方式JSON';
COMMENT ON COLUMN public.provider_profiles.is_active IS '是否营业';
COMMENT ON COLUMN public.provider_profiles.vacation_mode IS '是否休假';
COMMENT ON COLUMN public.provider_profiles.notification_settings IS '通知设置JSON';
COMMENT ON COLUMN public.provider_profiles.display_name IS '个人/团队名称（JSON格式，支持多语言：{"en": "English Name", "zh": "中文名称", "fr": "Nom Français"}）';
COMMENT ON COLUMN public.provider_profiles.avatar_url IS '头像URL';
COMMENT ON COLUMN public.provider_profiles.bio IS '简介（JSON格式，支持多语言：{"en": "English bio", "zh": "中文简介", "fr": "Bio française"}）';
COMMENT ON COLUMN public.provider_profiles.phone IS '联系电话';
COMMENT ON COLUMN public.provider_profiles.email IS '联系邮箱';
COMMENT ON COLUMN public.provider_profiles.rating IS '评分';
COMMENT ON COLUMN public.provider_profiles.is_certified IS '是否认证';
COMMENT ON COLUMN public.provider_profiles.experience_years IS '从业年限';
COMMENT ON COLUMN public.provider_profiles.tags IS '标签/技能数组';
COMMENT ON COLUMN public.provider_profiles.social_links IS '社交媒体/推广链接JSON';
COMMENT ON COLUMN public.provider_profiles.custom_fields IS '自定义扩展字段JSON'; 