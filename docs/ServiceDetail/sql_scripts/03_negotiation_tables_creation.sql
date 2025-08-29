-- =====================================================
-- 议价记录表创建/扩展脚本
-- 执行环境: Supabase PostgreSQL
-- 创建日期: 2025-01-08
-- 版本: v1.0
-- =====================================================

-- =====================================================
-- 1. 创建议价记录主表
-- =====================================================

CREATE TABLE IF NOT EXISTS public.negotiation_records (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id uuid NOT NULL REFERENCES public.services(id),
    user_id uuid NOT NULL REFERENCES auth.users(id),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id),
    
    -- 询价类型和状态
    quote_type text NOT NULL CHECK (quote_type IN ('quick', 'detailed', 'chat')),
    status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'quoted', 'negotiating', 'accepted', 'rejected', 'expired')),
    
    -- 价格协商
    user_budget_range jsonb, -- {min: 100, max: 200, currency: 'CAD'}
    provider_quote numeric,
    counter_offers jsonb DEFAULT '[]', -- 反议价历史
    final_agreed_price numeric,
    currency text DEFAULT 'CAD',
    
    -- 需求描述
    user_requirements text NOT NULL,
    user_additional_details jsonb, -- 详细需求的结构化数据
    provider_response text,
    provider_quote_breakdown jsonb, -- 报价明细
    
    -- 时间相关
    requested_service_time timestamptz,
    quote_expires_at timestamptz,
    provider_response_deadline timestamptz,
    
    -- 沟通记录
    communication_summary jsonb DEFAULT '{}', -- 聊天记录摘要
    attachments text[], -- 相关附件URL
    
    -- 转换追踪
    converted_to_order_id uuid REFERENCES public.orders(id),
    conversion_rate numeric, -- 最终成交价格/初始预算的比率
    
    -- 元数据
    metadata jsonb DEFAULT '{}',
    
    -- 时间戳
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    quoted_at timestamptz,
    accepted_at timestamptz,
    expired_at timestamptz
);

-- 添加注释
COMMENT ON TABLE public.negotiation_records IS '议价记录表，管理服务询价和价格协商流程';
COMMENT ON COLUMN public.negotiation_records.quote_type IS '询价类型：quick(快速报价), detailed(详细报价), chat(聊天询价)';
COMMENT ON COLUMN public.negotiation_records.status IS '询价状态：pending(待报价), quoted(已报价), negotiating(协商中), accepted(已接受), rejected(已拒绝), expired(已过期)';
COMMENT ON COLUMN public.negotiation_records.user_budget_range IS '用户预算范围，JSON格式：{min, max, currency}';
COMMENT ON COLUMN public.negotiation_records.counter_offers IS '反议价历史，存储所有议价往来';
COMMENT ON COLUMN public.negotiation_records.provider_quote_breakdown IS '服务商报价明细，包含各项费用分解';
COMMENT ON COLUMN public.negotiation_records.conversion_rate IS '转换率：最终成交价/初始预算中位数';

-- =====================================================
-- 2. 创建议价消息表
-- =====================================================

CREATE TABLE IF NOT EXISTS public.negotiation_messages (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    negotiation_id uuid NOT NULL REFERENCES public.negotiation_records(id) ON DELETE CASCADE,
    sender_id uuid NOT NULL REFERENCES auth.users(id),
    sender_type text NOT NULL CHECK (sender_type IN ('customer', 'provider')),
    
    -- 消息内容
    message_type text NOT NULL CHECK (message_type IN ('text', 'quote', 'counter_offer', 'image', 'document', 'system', 'voice')),
    content text,
    quote_amount numeric,
    quote_breakdown jsonb, -- 报价明细
    attachments text[],
    
    -- 系统消息专用
    system_event_type text, -- 'quote_sent', 'offer_accepted', 'negotiation_expired'等
    system_data jsonb,
    
    -- 状态
    is_read boolean DEFAULT false,
    read_at timestamptz,
    
    -- 元数据
    metadata jsonb DEFAULT '{}',
    
    created_at timestamptz DEFAULT now()
);

-- 添加注释
COMMENT ON TABLE public.negotiation_messages IS '议价消息表，存储议价过程中的所有沟通记录';
COMMENT ON COLUMN public.negotiation_messages.message_type IS '消息类型：text(文本), quote(报价), counter_offer(反议价), image(图片), document(文档), system(系统), voice(语音)';
COMMENT ON COLUMN public.negotiation_messages.sender_type IS '发送者类型：customer(客户), provider(服务商)';
COMMENT ON COLUMN public.negotiation_messages.quote_breakdown IS '报价明细，包含费用分解和说明';
COMMENT ON COLUMN public.negotiation_messages.system_event_type IS '系统事件类型，用于系统消息';

-- =====================================================
-- 3. 创建议价模板表
-- =====================================================

CREATE TABLE IF NOT EXISTS public.negotiation_templates (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id),
    service_category_id text, -- 关联服务分类
    
    -- 模板信息
    template_name text NOT NULL,
    template_description text,
    template_type text NOT NULL CHECK (template_type IN ('quick_response', 'detailed_quote', 'counter_offer')),
    
    -- 模板内容
    template_content jsonb NOT NULL, -- 模板的结构化内容
    default_pricing jsonb, -- 默认定价规则
    
    -- 使用统计
    usage_count integer DEFAULT 0,
    last_used_at timestamptz,
    
    -- 状态
    is_active boolean DEFAULT true,
    
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 添加注释
COMMENT ON TABLE public.negotiation_templates IS '议价模板表，供服务商快速响应客户询价';
COMMENT ON COLUMN public.negotiation_templates.template_type IS '模板类型：quick_response(快速回复), detailed_quote(详细报价), counter_offer(反议价)';
COMMENT ON COLUMN public.negotiation_templates.template_content IS '模板内容，包含文本模板和变量占位符';

-- =====================================================
-- 4. 创建索引
-- =====================================================

-- 议价记录表索引
CREATE INDEX IF NOT EXISTS idx_negotiation_records_service_id ON public.negotiation_records(service_id);
CREATE INDEX IF NOT EXISTS idx_negotiation_records_user_id ON public.negotiation_records(user_id);
CREATE INDEX IF NOT EXISTS idx_negotiation_records_provider_id ON public.negotiation_records(provider_id);
CREATE INDEX IF NOT EXISTS idx_negotiation_records_status ON public.negotiation_records(status);
CREATE INDEX IF NOT EXISTS idx_negotiation_records_quote_type ON public.negotiation_records(quote_type);
CREATE INDEX IF NOT EXISTS idx_negotiation_records_expires_at ON public.negotiation_records(quote_expires_at);
CREATE INDEX IF NOT EXISTS idx_negotiation_records_created_at ON public.negotiation_records(created_at);
CREATE INDEX IF NOT EXISTS idx_negotiation_records_converted_order ON public.negotiation_records(converted_to_order_id);

-- 议价消息表索引
CREATE INDEX IF NOT EXISTS idx_negotiation_messages_negotiation_id ON public.negotiation_messages(negotiation_id);
CREATE INDEX IF NOT EXISTS idx_negotiation_messages_sender_id ON public.negotiation_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_negotiation_messages_sender_type ON public.negotiation_messages(sender_type);
CREATE INDEX IF NOT EXISTS idx_negotiation_messages_message_type ON public.negotiation_messages(message_type);
CREATE INDEX IF NOT EXISTS idx_negotiation_messages_created_at ON public.negotiation_messages(created_at);
CREATE INDEX IF NOT EXISTS idx_negotiation_messages_is_read ON public.negotiation_messages(is_read);

-- 议价模板表索引
CREATE INDEX IF NOT EXISTS idx_negotiation_templates_provider_id ON public.negotiation_templates(provider_id);
CREATE INDEX IF NOT EXISTS idx_negotiation_templates_category ON public.negotiation_templates(service_category_id);
CREATE INDEX IF NOT EXISTS idx_negotiation_templates_type ON public.negotiation_templates(template_type);
CREATE INDEX IF NOT EXISTS idx_negotiation_templates_active ON public.negotiation_templates(is_active);

-- GIN索引优化JSON查询
CREATE INDEX IF NOT EXISTS idx_negotiation_records_budget_gin ON public.negotiation_records USING GIN (user_budget_range);
CREATE INDEX IF NOT EXISTS idx_negotiation_records_details_gin ON public.negotiation_records USING GIN (user_additional_details);
CREATE INDEX IF NOT EXISTS idx_negotiation_records_breakdown_gin ON public.negotiation_records USING GIN (provider_quote_breakdown);
CREATE INDEX IF NOT EXISTS idx_negotiation_messages_breakdown_gin ON public.negotiation_messages USING GIN (quote_breakdown);
CREATE INDEX IF NOT EXISTS idx_negotiation_templates_content_gin ON public.negotiation_templates USING GIN (template_content);

-- =====================================================
-- 5. RLS策略
-- =====================================================

-- 议价记录表RLS
ALTER TABLE public.negotiation_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own negotiations" ON public.negotiation_records
    FOR ALL USING (
        auth.uid() = user_id OR 
        auth.uid() IN (SELECT user_id FROM public.provider_profiles WHERE id = provider_id)
    );

-- 议价消息表RLS
ALTER TABLE public.negotiation_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can access negotiation messages" ON public.negotiation_messages
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.negotiation_records nr
            WHERE nr.id = negotiation_messages.negotiation_id
            AND (nr.user_id = auth.uid() OR 
                 auth.uid() IN (SELECT user_id FROM public.provider_profiles WHERE id = nr.provider_id))
        )
    );

-- 议价模板表RLS
ALTER TABLE public.negotiation_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Providers can manage their own templates" ON public.negotiation_templates
    FOR ALL USING (
        auth.uid() IN (SELECT user_id FROM public.provider_profiles WHERE id = provider_id)
    );

-- =====================================================
-- 6. 权限设置
-- =====================================================

-- 授予authenticated用户权限
GRANT SELECT, INSERT, UPDATE, DELETE ON public.negotiation_records TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.negotiation_messages TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.negotiation_templates TO authenticated;

-- =====================================================
-- 7. 触发器
-- =====================================================

-- 为议价记录表添加更新时间戳触发器
CREATE TRIGGER update_negotiation_records_updated_at 
    BEFORE UPDATE ON public.negotiation_records 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 为议价模板表添加更新时间戳触发器
CREATE TRIGGER update_negotiation_templates_updated_at 
    BEFORE UPDATE ON public.negotiation_templates 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 创建议价状态变更触发器
CREATE OR REPLACE FUNCTION handle_negotiation_status_change()
RETURNS TRIGGER AS $$
BEGIN
    -- 当状态变为quoted时，设置quoted_at时间戳
    IF NEW.status = 'quoted' AND OLD.status != 'quoted' THEN
        NEW.quoted_at = NOW();
    END IF;
    
    -- 当状态变为accepted时，设置accepted_at时间戳
    IF NEW.status = 'accepted' AND OLD.status != 'accepted' THEN
        NEW.accepted_at = NOW();
    END IF;
    
    -- 当状态变为expired时，设置expired_at时间戳
    IF NEW.status = 'expired' AND OLD.status != 'expired' THEN
        NEW.expired_at = NOW();
    END IF;
    
    -- 计算转换率（如果有最终成交价和预算范围）
    IF NEW.final_agreed_price IS NOT NULL AND NEW.user_budget_range IS NOT NULL THEN
        DECLARE
            budget_min NUMERIC;
            budget_max NUMERIC;
            budget_mid NUMERIC;
        BEGIN
            budget_min := (NEW.user_budget_range->>'min')::NUMERIC;
            budget_max := (NEW.user_budget_range->>'max')::NUMERIC;
            
            IF budget_min IS NOT NULL AND budget_max IS NOT NULL THEN
                budget_mid := (budget_min + budget_max) / 2;
                NEW.conversion_rate := NEW.final_agreed_price / budget_mid;
            END IF;
        END;
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER negotiation_status_change_trigger 
    BEFORE UPDATE ON public.negotiation_records 
    FOR EACH ROW EXECUTE FUNCTION handle_negotiation_status_change();

-- 创建议价过期自动处理触发器
CREATE OR REPLACE FUNCTION auto_expire_negotiations()
RETURNS void AS $$
BEGIN
    UPDATE public.negotiation_records 
    SET status = 'expired', expired_at = NOW()
    WHERE status IN ('pending', 'quoted', 'negotiating')
    AND quote_expires_at < NOW()
    AND status != 'expired';
END;
$$ language 'plpgsql';

-- =====================================================
-- 8. 创建议价统计视图
-- =====================================================

CREATE OR REPLACE VIEW negotiation_statistics AS
SELECT 
    DATE(created_at) as date,
    quote_type,
    status,
    COUNT(*) as count,
    AVG(
        CASE 
            WHEN final_agreed_price IS NOT NULL AND user_budget_range IS NOT NULL 
            THEN final_agreed_price / ((user_budget_range->>'min')::NUMERIC + (user_budget_range->>'max')::NUMERIC) * 2
            ELSE NULL 
        END
    ) as avg_conversion_rate,
    AVG(
        EXTRACT(EPOCH FROM (quoted_at - created_at)) / 3600
    ) as avg_response_time_hours
FROM public.negotiation_records
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(created_at), quote_type, status
ORDER BY date DESC, quote_type, status;

COMMENT ON VIEW negotiation_statistics IS '议价统计视图，提供议价活动的统计分析数据';

-- =====================================================
-- 9. 创建议价提醒函数
-- =====================================================

CREATE OR REPLACE FUNCTION get_pending_negotiations(provider_user_id uuid)
RETURNS TABLE (
    negotiation_id uuid,
    service_title text,
    customer_name text,
    quote_type text,
    created_at timestamptz,
    expires_at timestamptz,
    urgency_level text
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        nr.id,
        s.title->>'zh' as service_title,
        COALESCE(up.display_name->>'zh', up.display_name->>'en', 'Unknown') as customer_name,
        nr.quote_type,
        nr.created_at,
        nr.quote_expires_at,
        CASE 
            WHEN nr.quote_expires_at < NOW() + INTERVAL '2 hours' THEN 'urgent'
            WHEN nr.quote_expires_at < NOW() + INTERVAL '24 hours' THEN 'high'
            ELSE 'normal'
        END as urgency_level
    FROM public.negotiation_records nr
    JOIN public.services s ON nr.service_id = s.id
    JOIN public.provider_profiles pp ON nr.provider_id = pp.id
    LEFT JOIN auth.users up ON nr.user_id = up.id
    WHERE pp.user_id = provider_user_id
    AND nr.status = 'pending'
    AND nr.quote_expires_at > NOW()
    ORDER BY nr.quote_expires_at ASC;
END;
$$ language 'plpgsql';

COMMENT ON FUNCTION get_pending_negotiations IS '获取服务商待处理的议价请求，按紧急程度排序';

-- =====================================================
-- 10. 验证脚本
-- =====================================================

DO $$
DECLARE
    negotiation_tables_count INTEGER;
    negotiation_indexes_count INTEGER;
    negotiation_policies_count INTEGER;
    view_exists BOOLEAN;
BEGIN
    -- 检查表数量
    SELECT COUNT(*) INTO negotiation_tables_count 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name IN ('negotiation_records', 'negotiation_messages', 'negotiation_templates');
    
    -- 检查索引数量
    SELECT COUNT(*) INTO negotiation_indexes_count 
    FROM pg_indexes 
    WHERE schemaname = 'public' 
    AND indexname LIKE 'idx_negotiation%';
    
    -- 检查RLS策略数量
    SELECT COUNT(*) INTO negotiation_policies_count 
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename IN ('negotiation_records', 'negotiation_messages', 'negotiation_templates');
    
    -- 检查视图是否存在
    SELECT EXISTS (
        SELECT 1 FROM information_schema.views 
        WHERE table_schema = 'public' 
        AND table_name = 'negotiation_statistics'
    ) INTO view_exists;
    
    RAISE NOTICE '议价记录表创建完成！';
    RAISE NOTICE '表数量: % (预期: 3)', negotiation_tables_count;
    RAISE NOTICE '索引数量: % (预期: >= 18)', negotiation_indexes_count;
    RAISE NOTICE 'RLS策略数量: % (预期: 3)', negotiation_policies_count;
    RAISE NOTICE '统计视图已创建: %', view_exists;
    
    IF negotiation_tables_count = 3 AND negotiation_indexes_count >= 18 AND negotiation_policies_count = 3 THEN
        RAISE NOTICE '✅ 议价记录表创建成功！';
    ELSE
        RAISE WARNING '⚠️ 部分配置可能未正确创建，请检查日志';
    END IF;
END $$;
