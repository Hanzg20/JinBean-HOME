-- Docu/database_schema/orders.sql

-- 启用 UUID 扩展 (如果尚未启用)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

--
-- Table structure for table `orders`
-- 订单主表
--

CREATE TABLE public.orders (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number text UNIQUE NOT NULL,
    user_id uuid NOT NULL REFERENCES auth.users(id),                   -- 关联到 auth.users 表
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id), -- 关联到 provider_profiles 表
    service_id uuid NOT NULL REFERENCES public.services(id),           -- 关联到 services 表
    order_type text NOT NULL DEFAULT 'on_demand',                     -- 订单类型：on_demand/rental/appointment/negotiated/package
    fulfillment_mode_snapshot text NOT NULL,                            -- 订单创建时服务的履行模式快照：platform/external
    order_status text NOT NULL DEFAULT 'PendingAcceptance',           -- 订单状态：PendingAcceptance/Accepted/InProgress/Completed/Canceled/Refunded/Disputed/PendingPayment
    total_price numeric NOT NULL,
    currency text NOT NULL DEFAULT 'CAD',
    payment_status text NOT NULL DEFAULT 'Pending',                   -- 支付状态：Pending/Paid/PartiallyPaid/Refunded/Failed
    deposit_amount numeric,
    final_payment_amount numeric,
    coupon_id uuid,                                                     -- 关联优惠券模板表
    points_deduction_amount numeric DEFAULT 0,
    platform_service_fee_rate_snapshot numeric,
    platform_service_fee_amount numeric,
    scheduled_start_time timestamptz,
    scheduled_end_time timestamptz,
    actual_start_time timestamptz,
    actual_end_time timestamptz,
    service_address_id uuid REFERENCES public.user_addresses(id),     -- 关联用户地址表
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
CREATE INDEX idx_orders_user_id ON public.orders (user_id);
CREATE INDEX idx_orders_provider_id ON public.orders (provider_id);
CREATE INDEX idx_orders_service_id ON public.orders (service_id);
CREATE INDEX idx_orders_order_status ON public.orders (order_status);
CREATE INDEX idx_orders_payment_status ON public.orders (payment_status);
CREATE INDEX idx_orders_order_type ON public.orders (order_type);
CREATE INDEX idx_orders_created_at ON public.orders (created_at);
CREATE INDEX idx_orders_scheduled_start_time ON public.orders (scheduled_start_time);

--
-- Sample data for `orders`
-- Note: user_id, provider_id, and service_id must exist in their respective tables.
-- Replace with actual UUIDs from your `auth.users`, `provider_profiles`, and `services` tables.
--

INSERT INTO public.orders (id, order_number, user_id, provider_id, service_id, order_type, fulfillment_mode_snapshot, order_status, total_price, currency, payment_status, scheduled_start_time, scheduled_end_time, created_at, updated_at) VALUES
('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380b01', 'ORD-20240726-0001', 'b3c4d5e6-7890-1234-5678-901234567890', '00000000-0000-0000-0000-000000000001', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'on_demand', 'platform', 'PendingAcceptance', 150.00, 'CAD', 'Pending', '2024-08-01 10:00:00+00', '2024-08-01 14:00:00+00', now(), now()),
('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380b02', 'ORD-20240726-0002', 'b3c4d5e6-7890-1234-5678-901234567890', '00000000-0000-0000-0000-000000000001', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'negotiated', 'external', 'Accepted', 200.00, 'CAD', 'Paid', '2024-08-05 09:00:00+00', '2024-08-05 11:00:00+00', now(), now()),
('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380b03', 'ORD-20240726-0003', 'c4d5e6f7-8901-2345-6789-012345678901', '00000000-0000-0000-0000-000000000002', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'appointment', 'platform', 'Completed', 100.00, 'CAD', 'Paid', '2024-07-20 15:00:00+00', '2024-07-20 16:00:00+00', now(), now()); 