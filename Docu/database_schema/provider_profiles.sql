-- Docu/database_schema/provider_profiles.sql

-- 启用 UUID 扩展 (如果尚未启用)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

--
-- Table structure for table `provider_profiles`
-- 服务商资料表
--

CREATE TABLE public.provider_profiles (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid UNIQUE NOT NULL REFERENCES auth.users(id), -- 关联到 auth.users 表的ID
    company_name text,
    contact_phone text NOT NULL,
    contact_email text NOT NULL,
    business_address text,
    license_number text,
    description text,
    ratings_avg numeric DEFAULT 0.0,
    review_count integer DEFAULT 0,
    status text NOT NULL DEFAULT 'pending',                           -- 服务商状态：pending/active/suspended/rejected
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    provider_type text DEFAULT 'individual',                         -- 服务商类型：individual/corporate
    has_gst_hst boolean DEFAULT FALSE,
    bn_number text,
    annual_income_estimate numeric DEFAULT 0,
    tax_status_notice_shown boolean DEFAULT FALSE,
    tax_report_available boolean DEFAULT FALSE
);

-- 添加索引
CREATE INDEX idx_provider_profiles_user_id ON public.provider_profiles (user_id);
CREATE INDEX idx_provider_profiles_status ON public.provider_profiles (status);
CREATE INDEX idx_provider_profiles_provider_type ON public.provider_profiles (provider_type);
CREATE INDEX idx_provider_profiles_has_gst_hst ON public.provider_profiles (has_gst_hst);

--
-- Sample data for `provider_profiles`
-- Note: `user_id` needs to exist in `auth.users` table for foreign key constraint.
-- Replace with actual user_ids or create dummy users in auth.users first.
--

INSERT INTO public.provider_profiles (id, user_id, company_name, contact_phone, contact_email, business_address, license_number, description, ratings_avg, review_count, status, provider_type, has_gst_hst, bn_number, annual_income_estimate, tax_status_notice_shown, tax_report_available, created_at, updated_at) VALUES
('00000000-0000-0000-0000-000000000001', '4d639519-c607-48af-af3d-6c8c3e9c1c50', 'HomeCare Solutions Inc.', '123-456-7890', 'info@homecare.com', '123 Main St, Anytown', 'LIC12345', 'Professional home services specializing in cleaning and plumbing.', 4.8, 120, 'active', 'corporate', TRUE, 'BN123456789', 100000, TRUE, FALSE, now(), now()),
('00000000-0000-0000-0000-000000000002', '95ac66e5-4e8d-4b1b-b2fb-4648fef6e398', 'Relaxing Hands Massage', '987-654-3210', 'contact@relaxinghands.com', '456 Oak Ave, Anytown', 'LIC67890', 'Certified massage therapist offering mobile and in-clinic services.', 4.9, 80, 'active', 'individual', FALSE, NULL, 50000, FALSE, FALSE, now(), now()),
('00000000-0000-0000-0000-000000000003', '73440be0-ea60-4617-ba71-aff972138aae', 'Tech Guru Services', '555-111-2222', 'tech@techguru.com', '789 Tech Rd, Cyberville', NULL, 'Expert remote IT support and custom software development.', 4.5, 50, 'active', 'individual', TRUE, 'BN987654321', 75000, FALSE, FALSE, now(), now()); 