-- Docu/database_schema/address.sql

-- 启用 UUID 扩展（如未启用）
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP TABLE IF EXISTS public.addresses CASCADE;

CREATE TABLE public.addresses (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(), -- 主键
    standard_address_id text,                       -- 标准地址唯一编码（如GeoNames/Canada Post/自定义编码）
    country text DEFAULT 'Canada',                  -- 国家
    province text,                                  -- 省/州
    city text,                                      -- 城市
    district text,                                  -- 区/县/行政区
    street_number text,                             -- 门牌号
    street_name text,                               -- 街道名
    street_type text,                               -- 街道类型（Ave, St, Rd等）
    street_direction text,                          -- 街道方向（N, S, E, W）
    suite_unit text,                                -- 单元/房间号
    postal_code text,                               -- 邮编
    latitude numeric,                               -- 纬度
    longitude numeric,                              -- 经度
    geonames_id integer,                            -- GeoNames/官方地址库ID
    extra jsonb,                                    -- 其它补充信息
    created_at timestamptz NOT NULL DEFAULT now(),  -- 创建时间
    updated_at timestamptz NOT NULL DEFAULT now()   -- 更新时间
);

-- 索引
CREATE INDEX idx_addresses_standard_address_id ON public.addresses(standard_address_id);
CREATE INDEX idx_addresses_city ON public.addresses(city);
CREATE INDEX idx_addresses_postal_code ON public.addresses(postal_code);
CREATE INDEX idx_addresses_lat_lng ON public.addresses(latitude, longitude);

-- Sample data for `addresses`
INSERT INTO public.addresses (
    standard_address_id, country, province, city, district, street_number, street_name, street_type, street_direction, suite_unit, postal_code, latitude, longitude, geonames_id, extra
) VALUES (
    'CA-ON-OTT-123BANK-K2P1L4', 'Canada', 'ON', 'Ottawa', 'Centretown', '123', 'Bank', 'St', NULL, 'Suite 200', 'K2P 1L4', 45.4167, -75.7000, 6094817, '{"note": "Main office"}'
); 