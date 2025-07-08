-- Docu/database_schema/provider_profiles.sql

-- 启用 UUID 扩展（如未启用）
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP TABLE IF EXISTS public.provider_profiles CASCADE;

CREATE TABLE public.provider_profiles (
    id uuid PRIMARY KEY REFERENCES user_profiles(id) ON DELETE CASCADE, -- 主键，和 user_profiles 关联
    business_address text null,                 -- 业务地址 (已从 text 类型转换为结构化地址外键)

    certification_files jsonb,           -- 资质/保险/证书文件URL列表
    certification_status text DEFAULT 'pending', -- 认证状态（pending/approved/rejected）
    service_areas text[],                -- 服务区域（城市/邮编/多选）
    service_radius_km numeric,           -- 可服务半径（公里）
    service_categories text[],           -- 主营服务类别
    base_price numeric,                  -- 起步价/上门费
    pricing_type text,                   -- 定价方式（hourly/project/package）
    work_schedule jsonb,                 -- 工作时间（每周可预约时间段）
    team_members jsonb,                  -- 员工/技师信息
    payment_methods jsonb,               -- 支付方式/账户信息
    is_active boolean DEFAULT true,      -- 是否营业
    vacation_mode boolean DEFAULT false, -- 是否休假
    notification_settings jsonb,         -- 通知设置

    display_name text,                   -- 个人/团队名称
    avatar_url text,                     -- 头像
    bio text,                            -- 简介
    phone text,                          -- 联系电话
    email text,                          -- 联系邮箱
    address_id uuid REFERENCES public.addresses(id), -- 结构化地址外键

    rating numeric,                      -- 评分
    review_count integer DEFAULT 0,      -- 评价数 (已添加默认值)

    created_at timestamptz NOT NULL DEFAULT timezone('utc'::text, now()), -- 注册时间
    updated_at timestamptz NOT NULL DEFAULT timezone('utc'::text, now()), -- 更新时间

    user_id uuid NULL DEFAULT auth.uid(), -- 用户ID (已添加)
    license_number text,                 -- 执照编号
    provider_type text DEFAULT 'individual'::text, -- 服务者类型（个人/团队/公司等）
    has_gst_hst boolean DEFAULT false,         -- 是否已注册GST/HST
    bn_number text,                            -- 加拿大企业号（Business Number）
    annual_income_estimate numeric DEFAULT 0,  -- 年收入预估 (已添加默认值)
    tax_status_notice_shown boolean DEFAULT false, -- 是否已展示税务合规提示
    tax_report_available boolean DEFAULT false,    -- 是否已上传税务报表

    is_certified boolean DEFAULT false,  -- 是否认证
    experience_years integer,            -- 从业年限
    tags text[],                         -- 标签/技能
    social_links jsonb,                  -- 社交媒体/推广链接
    custom_fields jsonb,                 -- 自定义扩展字段

    -- 约束
    CONSTRAINT provider_profiles_pkey PRIMARY KEY (id),
    CONSTRAINT provider_profiles_address_id_fkey FOREIGN KEY (address_id) REFERENCES addresses (id),
    CONSTRAINT provider_profiles_provider_type_check CHECK (
        (provider_type = ANY (ARRAY['individual'::text, 'corporate'::text]))
    ),
    CONSTRAINT provider_profiles_status_check CHECK (
        (status = ANY (ARRAY['pending'::text, 'active'::text, 'suspended'::text, 'rejected'::text]))
    )
) TABLESPACE pg_default;

-- 索引
CREATE INDEX IF NOT EXISTS idx_provider_profiles_certification_status ON public.provider_profiles USING btree (certification_status) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_provider_profiles_provider_type ON public.provider_profiles USING btree (provider_type) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_provider_profiles_is_certified ON public.provider_profiles USING btree (is_certified) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_provider_profiles_experience_years ON public.provider_profiles USING btree (experience_years) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_provider_profiles_tags ON public.provider_profiles USING gin (tags) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_provider_profiles_service_categories ON public.provider_profiles USING gin (service_categories) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_provider_profiles_address_id ON public.provider_profiles USING btree (address_id) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_provider_profiles_user_id ON public.provider_profiles USING btree (user_id) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_provider_profiles_status ON public.provider_profiles USING btree (status) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_provider_profiles_has_gst_hst ON public.provider_profiles USING btree (has_gst_hst) TABLESPACE pg_default;

-- 触发器
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.provider_profiles FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

--
-- Sample data for `provider_profiles`
-- Note: `id` 需为 user_profiles 表中已存在的 uuid，address_id 需为 addresses 表中已存在的 uuid
--
-- REMOVE sample data or update it as it might cause issues if not carefully handled.
-- It's generally better to insert sample data separately or comment it out in schema files.
-- For now, I will keep the original sample data for illustration, but note that it might not reflect all new fields.

INSERT INTO public.provider_profiles (
    id, certification_files, certification_status, service_areas, service_radius_km, service_categories, base_price, pricing_type, work_schedule, team_members, payment_methods, is_active, vacation_mode, notification_settings, display_name, avatar_url, bio, phone, email, address_id, rating, review_count, created_at, updated_at, provider_type, is_certified, experience_years, tags, license_number, social_links, custom_fields, has_gst_hst, bn_number, annual_income_estimate, tax_status_notice_shown, tax_report_available, business_address, user_id -- Added business_address and user_id to INSERT statement
) VALUES (
    '22222222-2222-2222-2222-222222222222',
    '[{"type": "business_license", "url": "https://example.com/license.pdf"}, {"type": "insurance", "url": "https://example.com/insurance.pdf"}]',
    'approved',
    '["Ottawa", "Nepean", "Kanata", "K2P 1L4"]',
    30,
    ARRAY['Cleaning', 'Handyman', 'Snow Removal'],
    80,
    'hourly',
    '{"monday": [{"start": "08:00", "end": "17:00"}], "saturday": [{"start": "10:00", "end": "15:00"}]}',
    '[{"name": "John Smith", "role": "Technician", "phone": "613-555-1234"}, {"name": "Emily Chen", "role": "Cleaner", "phone": "613-555-5678"}]',
    '[{"type": "e-transfer", "account": "ottawateam@gmail.com"}, {"type": "credit_card", "account": "**** **** **** 1234"}]',
    TRUE,
    FALSE,
    '{"order_new": true, "promo": true}',
    'Ottawa Home Services',
    'https://example.com/ottawa_team_avatar.jpg',
    'Trusted local team offering cleaning, handyman, and snow removal services in Ottawa and surrounding areas.',
    '613-555-0000',
    'contact@ottawahomeservices.ca',
    'a1b2c3d4-5678-1234-5678-abcdefabcdef', -- 示例地址ID
    4.9,
    87,
    now(),
    now(),
    'Team',
    TRUE,
    8,
    ARRAY['reliable', 'bilingual', 'eco-friendly'],
    'ON-987654',
    '{"facebook": "https://facebook.com/ottawahomeservices", "website": "https://ottawahomeservices.ca"}',
    '{"notes": "Available for emergency snow removal during winter."}',
    FALSE,
    '',
    0,
    FALSE,
    FALSE,
    '123 Main St, Anytown, ON A1B 2C3', -- Sample business_address
    '22222222-2222-2222-2222-222222222222' -- Sample user_id
); 