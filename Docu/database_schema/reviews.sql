-- Docu/database_schema/reviews.sql

-- 启用 UUID 扩展 (如果尚未启用)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

--
-- Table structure for table `reviews`
-- 评价表
--

CREATE TABLE public.reviews (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id uuid UNIQUE NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE, -- 关联到 orders 表，确保一个订单只有一条评价
    service_id uuid NOT NULL REFERENCES public.services(id),             -- 关联到 services 表
    reviewer_id uuid NOT NULL REFERENCES auth.users(id),                -- 评价人ID (用户)
    reviewed_id uuid NOT NULL REFERENCES public.provider_profiles(id),  -- 被评价人ID (服务商)
    rating smallint NOT NULL CHECK (rating >= 1 AND rating <= 5),     -- 评分 (1-5星)
    comment text,
    image_urls text[] DEFAULT '{}',
    is_anonymous boolean NOT NULL DEFAULT FALSE,
    review_type text NOT NULL DEFAULT 'user_to_provider',             -- 评价类型：user_to_provider/provider_to_user
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 添加索引
CREATE INDEX idx_reviews_order_id ON public.reviews (order_id);
CREATE INDEX idx_reviews_service_id ON public.reviews (service_id);
CREATE INDEX idx_reviews_reviewer_id ON public.reviews (reviewer_id);
CREATE INDEX idx_reviews_reviewed_id ON public.reviews (reviewed_id);
CREATE INDEX idx_reviews_review_type ON public.reviews (review_type);
CREATE INDEX idx_reviews_rating ON public.reviews (rating);

--
-- Sample data for `reviews`
-- Note: order_id, service_id, reviewer_id, reviewed_id must exist in their respective tables.
-- Replace with actual UUIDs.
--

INSERT INTO public.reviews (id, order_id, service_id, reviewer_id, reviewed_id, rating, comment, is_anonymous, review_type, created_at, updated_at) VALUES
('h0eebc99-9c0b-4ef8-bb6d-6bb9bd380d01', 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380b01', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b3c4d5e6-7890-1234-5678-901234567890', '00000000-0000-0000-0000-000000000001', 5, 'Excellent cleaning service, very thorough and professional!', FALSE, 'user_to_provider', now(), now()),
('h0eebc99-9c0b-4ef8-bb6d-6bb9bd380d02', 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380b03', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'c4d5e6f7-8901-2345-6789-012345678901', '00000000-0000-0000-0000-000000000002', 4, 'Great massage, very relaxing. Punctual and polite.', FALSE, 'user_to_provider', now(), now()),
('h0eebc99-9c0b-4ef8-bb6d-6bb9bd380d03', 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380b01', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '00000000-0000-0000-0000-000000000001', 'b3c4d5e6-7890-1234-5678-901234567890', 5, 'User was very cooperative and the house was easy to clean.', FALSE, 'provider_to_user', now(), now()); 