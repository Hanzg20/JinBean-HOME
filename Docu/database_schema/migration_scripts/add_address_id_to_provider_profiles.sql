-- Docu/database_schema/add_address_id_to_provider_profiles.sql
-- 为 provider_profiles 表添加 address_id 字段的迁移脚本

-- 1. 确保 addresses 表存在（如果不存在则创建）
CREATE TABLE IF NOT EXISTS public.addresses (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    standard_address_id text,
    country text DEFAULT 'Canada',
    province text,
    city text,
    district text,
    street_number text,
    street_name text,
    street_type text,
    street_direction text,
    suite_unit text,
    postal_code text,
    latitude numeric,
    longitude numeric,
    geonames_id integer,
    extra jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 2. 为 provider_profiles 表添加 address_id 字段
ALTER TABLE public.provider_profiles
    ADD COLUMN IF NOT EXISTS address_id uuid REFERENCES public.addresses(id);

-- 3. 创建索引
CREATE INDEX IF NOT EXISTS idx_provider_profiles_address_id ON public.provider_profiles (address_id);

-- 4. 可选：将现有的 business_address 数据迁移到 addresses 表
-- 注意：这是一个示例，实际执行时需要根据数据量决定是否批量迁移
-- 建议先保留 business_address 字段，逐步迁移

-- 示例：为现有的一条记录创建地址（如果需要）
-- INSERT INTO public.addresses (country, province, city, street, postal_code, created_at, updated_at)
-- SELECT 
--     'Canada',
--     'ON',
--     'Ottawa',
--     business_address,
--     'K2P 1L4', -- 这里需要根据实际地址提取邮编
--     now(),
--     now()
-- FROM public.provider_profiles 
-- WHERE business_address IS NOT NULL 
--     AND address_id IS NULL
-- LIMIT 1;

-- 然后更新对应的 address_id
-- UPDATE public.provider_profiles 
-- SET address_id = (SELECT id FROM public.addresses WHERE street = provider_profiles.business_address LIMIT 1)
-- WHERE business_address IS NOT NULL 
--     AND address_id IS NULL;

-- 5. 验证迁移结果
-- SELECT 
--     id,
--     business_address,
--     address_id,
--     (SELECT street FROM public.addresses WHERE id = provider_profiles.address_id) as address_street
-- FROM public.provider_profiles 
-- WHERE business_address IS NOT NULL; 