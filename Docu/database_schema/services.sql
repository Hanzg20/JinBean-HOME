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