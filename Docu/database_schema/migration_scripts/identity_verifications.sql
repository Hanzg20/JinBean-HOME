-- Docu/database_schema/identity_verification.sql

--
-- Table structure for table `identity_verification`
-- 实名认证表，支持个人、团队、企业等多类型认证，适配加拿大业务。
--

DROP TABLE IF EXISTS public.identity_verification CASCADE;

CREATE TABLE public.identity_verification (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,                        -- 关联用户ID
    type text NOT NULL,                           -- 认证类型（personal/team/corporate/kyc）
    real_name text,                               -- 法定姓名
    birth_date date,                              -- 出生日期
    id_type text,                                 -- 证件类型（driver_license/photo_id/passport/pr_card）
    id_number text,                               -- 证件号码
    id_card_url text,                             -- 证件照片URL（如多张可用jsonb）
    selfie_url text,                              -- 自拍照URL（可选）
    company_name text,                            -- 企业/团队名称（如有）
    bn_number text,                               -- 企业注册号（如有）
    company_doc_url text,                         -- 企业证明材料URL（如有）
    gst_hst_number text,                          -- GST/HST注册号（如有）
    status text NOT NULL DEFAULT 'pending',       -- 审核状态（pending/approved/rejected）
    reason text,                                  -- 未通过原因
    created_at timestamptz NOT NULL DEFAULT now(),
    reviewed_at timestamptz,
    reviewer_id uuid
);

-- 索引
CREATE INDEX idx_identity_verification_user_id ON public.identity_verification (user_id);
CREATE INDEX idx_identity_verification_type ON public.identity_verification (type);
CREATE INDEX idx_identity_verification_status ON public.identity_verification (status);

-- RLS 策略（示例，实际可按需细化）
ALTER TABLE public.identity_verification ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow select on identity_verification" ON public.identity_verification FOR SELECT TO authenticated USING (true); 