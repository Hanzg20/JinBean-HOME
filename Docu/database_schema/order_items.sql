-- Docu/database_schema/order_items.sql

-- 启用 UUID 扩展 (如果尚未启用)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

--
-- Table structure for table `order_items`
-- 订单明细表
--

CREATE TABLE public.order_items (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE, -- 关联到 orders 表
    service_id uuid NOT NULL REFERENCES public.services(id),             -- 关联到 services 表
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
    parent_item_id uuid REFERENCES public.order_items(id) ON DELETE CASCADE, -- 如果是套餐内子项，关联主套餐项ID
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 添加索引
CREATE INDEX idx_order_items_order_id ON public.order_items (order_id);
CREATE INDEX idx_order_items_service_id ON public.order_items (service_id);

--
-- Sample data for `order_items`
-- Note: order_id and service_id must exist in their respective tables.
-- Replace with actual UUIDs.
--

INSERT INTO public.order_items (id, order_id, service_id, quantity, unit_price_snapshot, subtotal_price, service_name_snapshot, service_description_snapshot, pricing_type_snapshot, duration_type_snapshot, duration_snapshot, created_at, updated_at) VALUES
('g0eebc99-9c0b-4ef8-bb6d-6bb9bd380c01', 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380b01', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 1, 150.00, 150.00, 'Standard Home Cleaning', 'Comprehensive cleaning for homes.', 'fixed_price', 'fixed', '4 hours', now(), now()),
('g0eebc99-9c0b-4ef8-bb6d-6bb9bd380c02', 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380b02', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 1, 200.00, 200.00, 'Emergency Plumbing Repair', 'Fast and reliable plumbing services.', 'negotiable', 'hourly', '2 hours', now(), now()),
('g0eebc99-9c0b-4ef8-bb6d-6bb9bd380c03', 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380b03', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 1, 100.00, 100.00, 'Full Body Relaxation Massage', 'Calming full-body massage.', 'fixed_price', 'fixed', '60 minutes', now(), now()); 