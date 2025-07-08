-- Docu/database_schema/migrate_provider_profiles_to_structured.sql
-- 升级 provider_profiles 表为结构化地址和新版字段结构

-- 1. 新增 address_id 字段，作为结构化地址外键
ALTER TABLE public.provider_profiles
    ADD COLUMN IF NOT EXISTS address_id uuid REFERENCES public.addresses(id);

-- 2. 新增新版字段（如无则添加）
ALTER TABLE public.provider_profiles
    ADD COLUMN IF NOT EXISTS certification_files jsonb,
    ADD COLUMN IF NOT EXISTS certification_status text DEFAULT 'pending',
    ADD COLUMN IF NOT EXISTS service_radius_km numeric,
    ADD COLUMN IF NOT EXISTS base_price numeric,
    ADD COLUMN IF NOT EXISTS pricing_type text,
    ADD COLUMN IF NOT EXISTS work_schedule jsonb,
    ADD COLUMN IF NOT EXISTS team_members jsonb,
    ADD COLUMN IF NOT EXISTS payment_methods jsonb,
    ADD COLUMN IF NOT EXISTS is_active boolean DEFAULT true,
    ADD COLUMN IF NOT EXISTS vacation_mode boolean DEFAULT false,
    ADD COLUMN IF NOT EXISTS notification_settings jsonb,
    ADD COLUMN IF NOT EXISTS display_name text,
    ADD COLUMN IF NOT EXISTS avatar_url text,
    ADD COLUMN IF NOT EXISTS bio text,
    ADD COLUMN IF NOT EXISTS phone text,
    ADD COLUMN IF NOT EXISTS email text,
    ADD COLUMN IF NOT EXISTS rating numeric,
    ADD COLUMN IF NOT EXISTS is_certified boolean DEFAULT false,
    ADD COLUMN IF NOT EXISTS experience_years integer,
    ADD COLUMN IF NOT EXISTS tags text[],
    ADD COLUMN IF NOT EXISTS social_links jsonb,
    ADD COLUMN IF NOT EXISTS custom_fields jsonb;

-- 3. 字段重命名与数据迁移（安全写法）
DO $$
BEGIN
    -- company_name -> display_name
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='provider_profiles' AND column_name='display_name')
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='provider_profiles' AND column_name='company_name') THEN
        UPDATE public.provider_profiles
        SET display_name = company_name
        WHERE (display_name IS NULL OR display_name = '') AND company_name IS NOT NULL;
        ALTER TABLE public.provider_profiles DROP COLUMN company_name;
    ELSIF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='provider_profiles' AND column_name='company_name') THEN
        ALTER TABLE public.provider_profiles RENAME COLUMN company_name TO display_name;
    END IF;

    -- description -> bio
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='provider_profiles' AND column_name='bio')
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='provider_profiles' AND column_name='description') THEN
        UPDATE public.provider_profiles
        SET bio = description
        WHERE (bio IS NULL OR bio = '') AND description IS NOT NULL;
        ALTER TABLE public.provider_profiles DROP COLUMN description;
    ELSIF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='provider_profiles' AND column_name='description') THEN
        ALTER TABLE public.provider_profiles RENAME COLUMN description TO bio;
    END IF;

    -- contact_phone -> phone
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='provider_profiles' AND column_name='phone')
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='provider_profiles' AND column_name='contact_phone') THEN
        UPDATE public.provider_profiles
        SET phone = contact_phone
        WHERE (phone IS NULL OR phone = '') AND contact_phone IS NOT NULL;
        ALTER TABLE public.provider_profiles DROP COLUMN contact_phone;
    ELSIF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='provider_profiles' AND column_name='contact_phone') THEN
        ALTER TABLE public.provider_profiles RENAME COLUMN contact_phone TO phone;
    END IF;

    -- contact_email -> email
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='provider_profiles' AND column_name='email')
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='provider_profiles' AND column_name='contact_email') THEN
        UPDATE public.provider_profiles
        SET email = contact_email
        WHERE (email IS NULL OR email = '') AND contact_email IS NOT NULL;
        ALTER TABLE public.provider_profiles DROP COLUMN contact_email;
    ELSIF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='provider_profiles' AND column_name='contact_email') THEN
        ALTER TABLE public.provider_profiles RENAME COLUMN contact_email TO email;
    END IF;

    -- ratings_avg -> rating
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='provider_profiles' AND column_name='rating')
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='provider_profiles' AND column_name='ratings_avg') THEN
        UPDATE public.provider_profiles
        SET rating = ratings_avg
        WHERE (rating IS NULL) AND ratings_avg IS NOT NULL;
        ALTER TABLE public.provider_profiles DROP COLUMN ratings_avg;
    ELSIF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='provider_profiles' AND column_name='ratings_avg') THEN
        ALTER TABLE public.provider_profiles RENAME COLUMN ratings_avg TO rating;
    END IF;
END $$;

-- 4. 新增新版索引
CREATE INDEX IF NOT EXISTS idx_provider_profiles_certification_status ON public.provider_profiles (certification_status);
CREATE INDEX IF NOT EXISTS idx_provider_profiles_is_certified ON public.provider_profiles (is_certified);
CREATE INDEX IF NOT EXISTS idx_provider_profiles_experience_years ON public.provider_profiles (experience_years);
CREATE INDEX IF NOT EXISTS idx_provider_profiles_tags ON public.provider_profiles USING GIN (tags);
CREATE INDEX IF NOT EXISTS idx_provider_profiles_service_categories ON public.provider_profiles USING GIN (service_categories);
CREATE INDEX IF NOT EXISTS idx_provider_profiles_address_id ON public.provider_profiles (address_id);

-- 5. （可选）删除废弃字段
-- ALTER TABLE public.provider_profiles
--     DROP COLUMN business_address,
--     DROP COLUMN has_gst_hst,
--     DROP COLUMN bn_number,
--     DROP COLUMN annual_income_estimate,
--     DROP COLUMN tax_status_notice_shown,
--     DROP COLUMN tax_report_available,
--     DROP COLUMN documents;

-- 6. 业务数据迁移建议
-- business_address 字段内容可批量插入 addresses 表，生成 address_id 并回填
-- 具体迁移脚本可根据实际数据量和格式定制 