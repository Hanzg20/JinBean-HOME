-- Docu/database_schema/service_details.sql
-- 根据实际数据库表结构更新

-- 启用 UUID 扩展（如未启用）
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP TABLE IF EXISTS public.service_details CASCADE;

CREATE TABLE public.service_details (
    service_id uuid NOT NULL,
    pricing_type text NOT NULL DEFAULT 'fixed_price'::text,
    price numeric NULL,
    currency text NULL,
    negotiation_details text NULL,
    duration_type text NOT NULL DEFAULT 'hours'::text,
    duration interval NULL,
    images_url text[] NULL DEFAULT '{}'::text[],
    videos_url text[] NULL DEFAULT '{}'::text[],
    tags text[] NULL DEFAULT '{}'::text[],
    service_area_codes text[] NULL DEFAULT '{}'::text[],
    platform_service_fee_rate numeric NULL,
    min_platform_service_fee numeric NULL,
    service_details_json jsonb NULL,
    extra_data jsonb NULL,
    promotion_start timestamp with time zone NULL,
    promotion_end timestamp with time zone NULL,
    view_count integer NULL DEFAULT 0,
    favorite_count integer NULL DEFAULT 0,
    order_count integer NULL DEFAULT 0,
    verification_status text NOT NULL DEFAULT 'pending'::text,
    verification_documents text[] NULL DEFAULT '{}'::text[],
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    category text NULL DEFAULT 'main'::text,
    name jsonb NULL,
    sub_category text NULL,
    is_available boolean NULL DEFAULT true,
    sort_order integer NULL DEFAULT 0,
    current_stock integer NULL,
    max_stock integer NULL,
    attributes jsonb NULL DEFAULT '{}'::jsonb,
    business_rules jsonb NULL DEFAULT '{}'::jsonb,
    
    -- 约束
    CONSTRAINT service_details_pkey PRIMARY KEY (id),
    CONSTRAINT unique_service_category_name UNIQUE (service_id, category, name),
    CONSTRAINT service_details_service_id_fkey FOREIGN KEY (service_id) REFERENCES services (id) ON DELETE CASCADE
) TABLESPACE pg_default;

-- 索引
CREATE INDEX IF NOT EXISTS idx_service_details_duration_type ON public.service_details USING btree (duration_type) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_service_details_pricing_type ON public.service_details USING btree (pricing_type) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_service_details_service_area_codes ON public.service_details USING gin (service_area_codes) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_service_details_tags ON public.service_details USING gin (tags) TABLESPACE pg_default;

-- 表注释
COMMENT ON TABLE public.service_details IS '服务详情表，支持多子服务架构，存储服务的详细信息和子服务配置';
COMMENT ON COLUMN public.service_details.service_id IS '关联的服务ID';
COMMENT ON COLUMN public.service_details.pricing_type IS '定价类型：fixed_price/hourly/negotiable等';
COMMENT ON COLUMN public.service_details.price IS '服务价格';
COMMENT ON COLUMN public.service_details.currency IS '货币类型';
COMMENT ON COLUMN public.service_details.negotiation_details IS '协商详情';
COMMENT ON COLUMN public.service_details.duration_type IS '时长类型：hours/days/weeks等';
COMMENT ON COLUMN public.service_details.duration IS '服务时长';
COMMENT ON COLUMN public.service_details.images_url IS '图片URL数组';
COMMENT ON COLUMN public.service_details.videos_url IS '视频URL数组';
COMMENT ON COLUMN public.service_details.tags IS '标签数组';
COMMENT ON COLUMN public.service_details.service_area_codes IS '服务区域代码数组';
COMMENT ON COLUMN public.service_details.platform_service_fee_rate IS '平台服务费率';
COMMENT ON COLUMN public.service_details.min_platform_service_fee IS '最低平台服务费';
COMMENT ON COLUMN public.service_details.service_details_json IS '服务详情JSON数据';
COMMENT ON COLUMN public.service_details.extra_data IS '额外数据JSON';
COMMENT ON COLUMN public.service_details.promotion_start IS '促销开始时间';
COMMENT ON COLUMN public.service_details.promotion_end IS '促销结束时间';
COMMENT ON COLUMN public.service_details.view_count IS '浏览次数';
COMMENT ON COLUMN public.service_details.favorite_count IS '收藏次数';
COMMENT ON COLUMN public.service_details.order_count IS '订单次数';
COMMENT ON COLUMN public.service_details.verification_status IS '验证状态';
COMMENT ON COLUMN public.service_details.verification_documents IS '验证文档数组';
COMMENT ON COLUMN public.service_details.id IS '主键ID';
COMMENT ON COLUMN public.service_details.category IS '服务类别：main/menu_item/rental_item/course_module等';
COMMENT ON COLUMN public.service_details.name IS '服务名称（JSON格式，支持多语言）';
COMMENT ON COLUMN public.service_details.sub_category IS '子类别：appetizer/main_course/dessert/power_tools/hand_tools等';
COMMENT ON COLUMN public.service_details.is_available IS '是否可用';
COMMENT ON COLUMN public.service_details.sort_order IS '排序顺序';
COMMENT ON COLUMN public.service_details.current_stock IS '当前库存';
COMMENT ON COLUMN public.service_details.max_stock IS '最大库存';
COMMENT ON COLUMN public.service_details.attributes IS '属性JSON：品牌、规格、条件等';
COMMENT ON COLUMN public.service_details.business_rules IS '业务规则JSON：最小订单、押金、取消政策等'; 