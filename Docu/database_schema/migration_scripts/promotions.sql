-- Docu/database_schema/promotions.sql

-- 启用 UUID 扩展 (如果尚未启用)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

--
-- Table structure for table `promotions`
-- 营销活动表
--

CREATE TABLE public.promotions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text NOT NULL,
    description text,
    type text NOT NULL,                                   -- 活动类型：coupon/discount/package/referral
    value numeric NOT NULL,
    value_type text NOT NULL,                             -- 优惠值类型：percentage/fixed_amount
    min_order_amount numeric DEFAULT 0,
    max_discount_amount numeric,
    usage_limit_per_user integer,
    usage_limit_total integer,
    start_time timestamptz NOT NULL,
    end_time timestamptz NOT NULL,
    target_audience text NOT NULL DEFAULT 'all',        -- 目标用户：all/new_users/specific_users/specific_providers
    target_categories bigint[] DEFAULT '{}',             -- 目标服务类别（关联 ref_codes）
    target_services uuid[] DEFAULT '{}',                 -- 目标服务（关联 services）
    status text NOT NULL DEFAULT 'scheduled',            -- 活动状态：active/inactive/ended/scheduled
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 添加索引
CREATE INDEX idx_promotions_type ON public.promotions (type);
CREATE INDEX idx_promotions_time_status ON public.promotions (start_time, end_time, status);
CREATE INDEX idx_promotions_target_audience ON public.promotions (target_audience);
CREATE INDEX idx_promotions_target_categories ON public.promotions USING GIN (target_categories);
CREATE INDEX idx_promotions_target_services ON public.promotions USING GIN (target_services);

--
-- Sample data for `promotions`
-- Note: target_categories IDs should exist in `ref_codes`.
-- Note: target_services IDs should exist in `services`.
--

INSERT INTO public.promotions (id, name, description, type, value, value_type, min_order_amount, max_discount_amount, usage_limit_per_user, usage_limit_total, start_time, end_time, target_audience, target_categories, target_services, status, created_at, updated_at) VALUES
('i0eebc99-9c0b-4ef8-bb6d-6bb9bd380e01', 'New User Welcome Coupon', 'Get 10% off on your first home cleaning service!', 'coupon', 0.10, 'percentage', 50.00, 20.00, 1, 1000, '2024-01-01 00:00:00+00', '2024-12-31 23:59:59+00', 'new_users', ARRAY[100, 1001], ARRAY['a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'], 'active', now(), now()),
('i0eebc99-9c0b-4ef8-bb6d-6bb9bd380e02', 'Summer Massage Discount', 'Enjoy $15 off all massage services this summer!', 'discount', 15.00, 'fixed_amount', 80.00, NULL, NULL, 500, '2024-06-01 00:00:00+00', '2024-08-31 23:59:59+00', 'all', ARRAY[101, 1003], ARRAY['a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14'], 'active', now(), now()),
('i0eebc99-9c0b-4ef8-bb6d-6bb9bd380e03', 'IT Support Promo', 'First session of remote IT support is 50% off.', 'discount', 0.50, 'percentage', 0.00, 40.00, 1, 200, '2024-07-01 00:00:00+00', '2024-09-30 23:59:59+00', 'all', ARRAY[102], ARRAY['a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13'], 'active', now(), now()); 