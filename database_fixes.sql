-- Database Fixes for Provider Functionality
-- 修复Provider端功能所需的数据库结构问题

-- 1. 修复orders表 - 添加缺失的status列
ALTER TABLE public.orders 
ADD COLUMN IF NOT EXISTS status text DEFAULT 'pending';

-- 更新现有记录的status字段
UPDATE public.orders 
SET status = order_status 
WHERE status IS NULL AND order_status IS NOT NULL;

-- 2. 创建client_relationships表（如果不存在）
CREATE TABLE IF NOT EXISTS public.client_relationships (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    client_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name text NOT NULL DEFAULT '未知客户',
    phone text,
    email text,
    status text NOT NULL DEFAULT 'active',
    total_orders integer NOT NULL DEFAULT 0,
    total_spent numeric NOT NULL DEFAULT 0,
    average_rating numeric DEFAULT 0,
    first_order_date timestamptz,
    last_order_date timestamptz,
    last_contact_date timestamptz,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(provider_id, client_user_id)
);

-- 2.1 创建provider_settings表（如果不存在）
CREATE TABLE IF NOT EXISTS public.provider_settings (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    setting_key text NOT NULL,
    setting_value jsonb NOT NULL DEFAULT '{}',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(provider_id, setting_key)
);

-- 2.2 为provider_settings添加索引
CREATE INDEX IF NOT EXISTS idx_provider_settings_provider_id ON public.provider_settings(provider_id);
CREATE INDEX IF NOT EXISTS idx_provider_settings_key ON public.provider_settings(setting_key);

-- 2.3 为provider_settings添加updated_at触发器
DROP TRIGGER IF EXISTS update_provider_settings_updated_at ON public.provider_settings;
CREATE TRIGGER update_provider_settings_updated_at
    BEFORE UPDATE ON public.provider_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 3. 创建client_communications表（如果不存在）
CREATE TABLE IF NOT EXISTS public.client_communications (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    client_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    message text NOT NULL,
    direction text NOT NULL DEFAULT 'outbound',
    message_type text DEFAULT 'text',
    is_read boolean DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- 4. 创建income_records表（如果不存在）
CREATE TABLE IF NOT EXISTS public.income_records (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    order_id uuid REFERENCES public.orders(id) ON DELETE SET NULL,
    amount numeric NOT NULL,
    income_type text NOT NULL DEFAULT 'service_fee', -- 'service_fee', 'tip', 'bonus', 'refund'
    status text NOT NULL DEFAULT 'pending', -- 'pending', 'settled', 'cancelled'
    settlement_date timestamptz,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 5. 创建notifications表（如果不存在）
CREATE TABLE IF NOT EXISTS public.notifications (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipient_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    notification_type text NOT NULL, -- 'order', 'message', 'system', 'payment'
    title text NOT NULL,
    message text NOT NULL,
    is_read boolean DEFAULT false,
    related_id uuid, -- 关联的订单ID、消息ID等
    created_at timestamptz NOT NULL DEFAULT now()
);

-- 6. 添加索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_client_relationships_provider_id ON public.client_relationships(provider_id);
CREATE INDEX IF NOT EXISTS idx_client_relationships_client_user_id ON public.client_relationships(client_user_id);
CREATE INDEX IF NOT EXISTS idx_client_relationships_status ON public.client_relationships(status);
CREATE INDEX IF NOT EXISTS idx_client_relationships_last_contact_date ON public.client_relationships(last_contact_date);

CREATE INDEX IF NOT EXISTS idx_client_communications_provider_client ON public.client_communications(provider_id, client_user_id);
CREATE INDEX IF NOT EXISTS idx_client_communications_created_at ON public.client_communications(created_at);

CREATE INDEX IF NOT EXISTS idx_income_records_provider_id ON public.income_records(provider_id);
CREATE INDEX IF NOT EXISTS idx_income_records_status ON public.income_records(status);
CREATE INDEX IF NOT EXISTS idx_income_records_created_at ON public.income_records(created_at);

CREATE INDEX IF NOT EXISTS idx_notifications_recipient_id ON public.notifications(recipient_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at);

-- 7. 添加外键约束（如果不存在）
-- 注意：这些约束可能已经存在，使用IF NOT EXISTS避免错误

-- 8. 创建触发器函数来更新updated_at字段
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 9. 为相关表添加updated_at触发器
DROP TRIGGER IF EXISTS update_client_relationships_updated_at ON public.client_relationships;
CREATE TRIGGER update_client_relationships_updated_at
    BEFORE UPDATE ON public.client_relationships
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_income_records_updated_at ON public.income_records;
CREATE TRIGGER update_income_records_updated_at
    BEFORE UPDATE ON public.income_records
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 10. 插入一些测试数据（可选）
-- 注意：这些数据仅用于测试，生产环境请删除

-- 插入测试客户关系数据
INSERT INTO public.client_relationships (provider_id, client_user_id, display_name, phone, email, status, total_orders, total_spent)
SELECT 
    p.id as provider_id,
    u.id as client_user_id,
    '测试客户' as display_name,
    '+1234567890' as phone,
    'test@example.com' as email,
    'active' as status,
    0 as total_orders,
    0 as total_spent
FROM public.provider_profiles p
CROSS JOIN auth.users u
WHERE u.id != p.user_id
LIMIT 5
ON CONFLICT (provider_id, client_user_id) DO NOTHING;

-- 插入测试收入记录
INSERT INTO public.income_records (provider_id, amount, income_type, status)
SELECT 
    p.id as provider_id,
    100.00 as amount,
    'service_fee' as income_type,
    'settled' as status
FROM public.provider_profiles p
LIMIT 3
ON CONFLICT DO NOTHING;

-- 插入测试通知
INSERT INTO public.notifications (recipient_id, notification_type, title, message)
SELECT 
    p.user_id as recipient_id,
    'system' as notification_type,
    '欢迎使用JinBean' as title,
    '您的账户已成功激活，开始提供服务吧！' as message
FROM public.provider_profiles p
LIMIT 3
ON CONFLICT DO NOTHING;

-- 完成修复
SELECT 'Database fixes completed successfully!' as status; 