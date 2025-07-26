-- MessageHub SaaS 多租户数据库架构设计
-- 基于JinBean消息系统的标准化SaaS版本

-- ========================================
-- 1. 租户管理
-- ========================================

-- 租户表 (应用/客户)
CREATE TABLE IF NOT EXISTS public.tenants (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    app_id text UNIQUE NOT NULL, -- 对外公开的应用ID
    app_secret text NOT NULL, -- 应用密钥
    
    -- 基本信息
    name text NOT NULL, -- 应用名称
    company_name text,
    contact_email text NOT NULL,
    contact_phone text,
    
    -- 订阅信息
    plan_type text NOT NULL DEFAULT 'basic', -- 'basic', 'pro', 'enterprise', 'custom'
    subscription_status text DEFAULT 'active', -- 'active', 'suspended', 'cancelled'
    billing_cycle text DEFAULT 'monthly', -- 'monthly', 'annual'
    
    -- 配额设置
    quota_active_users integer DEFAULT 1000,
    quota_messages_per_month bigint DEFAULT 100000,
    quota_storage_gb integer DEFAULT 1,
    quota_api_calls_per_month bigint DEFAULT 100000,
    quota_websocket_connections integer DEFAULT 100,
    
    -- 使用统计 (当月)
    usage_active_users integer DEFAULT 0,
    usage_messages_sent bigint DEFAULT 0,
    usage_storage_used_mb bigint DEFAULT 0,
    usage_api_calls bigint DEFAULT 0,
    
    -- 配置设置
    settings jsonb DEFAULT '{
        "webhook_url": null,
        "encryption_enabled": false,
        "retention_days": 90,
        "allowed_message_types": ["text", "image", "file"],
        "rate_limits": {
            "messages_per_minute": 60,
            "api_calls_per_minute": 1000
        },
        "features": {
            "real_time": true,
            "file_upload": true,
            "message_history": true,
            "typing_indicators": true,
            "read_receipts": true,
            "user_presence": false,
            "message_reactions": false,
            "message_translation": false,
            "content_moderation": false
        }
    }',
    
    -- 时间戳
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    last_activity_at timestamptz DEFAULT now(),
    
    -- 约束
    CONSTRAINT valid_plan_type CHECK (plan_type IN ('basic', 'pro', 'enterprise', 'custom')),
    CONSTRAINT valid_subscription_status CHECK (subscription_status IN ('active', 'suspended', 'cancelled')),
    CONSTRAINT valid_billing_cycle CHECK (billing_cycle IN ('monthly', 'annual'))
);

-- 租户用户表 (客户系统的用户映射)
CREATE TABLE IF NOT EXISTS public.tenant_users (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    
    -- 用户标识 (来自客户系统)
    external_user_id text NOT NULL, -- 客户系统用户ID
    display_name text,
    avatar_url text,
    email text,
    phone text,
    
    -- 用户角色和权限
    roles text[] DEFAULT '{}', -- 客户系统定义的角色
    permissions jsonb DEFAULT '{}', -- 自定义权限
    
    -- 用户状态
    status text DEFAULT 'active', -- 'active', 'inactive', 'banned'
    is_online boolean DEFAULT false,
    last_seen_at timestamptz,
    
    -- 元数据
    metadata jsonb DEFAULT '{}', -- 客户系统自定义字段
    
    -- 时间戳
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    
    UNIQUE(tenant_id, external_user_id),
    CONSTRAINT valid_user_status CHECK (status IN ('active', 'inactive', 'banned'))
);

-- ========================================
-- 2. 会话管理 (基于租户隔离)
-- ========================================

CREATE TABLE IF NOT EXISTS public.conversations (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    
    -- 会话标识
    external_conversation_id text, -- 客户系统会话ID (可选)
    type text NOT NULL DEFAULT 'direct', -- 'direct', 'group', 'channel', 'support'
    
    -- 会话参与者
    participants jsonb NOT NULL, -- ["external_user_id1", "external_user_id2", ...]
    participant_count integer NOT NULL DEFAULT 2,
    
    -- 会话元数据
    title text,
    description text,
    avatar_url text,
    metadata jsonb DEFAULT '{}', -- 业务自定义字段 (如order_id, ticket_id等)
    
    -- 会话状态
    status text DEFAULT 'active', -- 'active', 'archived', 'deleted', 'blocked'
    
    -- 最后活动信息
    last_message_id uuid, -- 稍后添加外键
    last_message_at timestamptz,
    last_activity_at timestamptz DEFAULT now(),
    
    -- 会话设置
    settings jsonb DEFAULT '{
        "auto_archive_days": null,
        "message_retention_days": null,
        "allowed_message_types": null,
        "notifications_enabled": true,
        "typing_indicators": true,
        "read_receipts": true
    }',
    
    -- 时间戳
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by text NOT NULL, -- external_user_id
    updated_at timestamptz NOT NULL DEFAULT now(),
    
    CONSTRAINT valid_conversation_type CHECK (type IN ('direct', 'group', 'channel', 'support')),
    CONSTRAINT valid_conversation_status CHECK (status IN ('active', 'archived', 'deleted', 'blocked'))
);

-- 会话参与者关系表
CREATE TABLE IF NOT EXISTS public.conversation_participants (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    conversation_id uuid NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    external_user_id text NOT NULL,
    
    -- 参与状态
    status text DEFAULT 'active', -- 'active', 'left', 'removed', 'muted'
    role text DEFAULT 'member', -- 'admin', 'moderator', 'member'
    
    -- 消息状态跟踪
    last_read_message_id uuid, -- 稍后添加外键
    last_read_at timestamptz,
    unread_count integer DEFAULT 0,
    mention_count integer DEFAULT 0,
    
    -- 个人设置
    notifications_enabled boolean DEFAULT true,
    nickname text, -- 在此会话中的昵称
    
    -- 时间戳
    joined_at timestamptz DEFAULT now(),
    left_at timestamptz,
    
    UNIQUE(tenant_id, conversation_id, external_user_id),
    CONSTRAINT valid_participant_status CHECK (status IN ('active', 'left', 'removed', 'muted')),
    CONSTRAINT valid_participant_role CHECK (role IN ('admin', 'moderator', 'member'))
);

-- ========================================
-- 3. 消息存储 (多租户版本)
-- ========================================

CREATE TABLE IF NOT EXISTS public.messages (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    conversation_id uuid NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    
    -- 消息发送者
    sender_external_id text NOT NULL, -- 发送者在客户系统中的ID
    
    -- 消息类型和内容
    message_type text NOT NULL DEFAULT 'text', -- 'text', 'image', 'file', 'location', 'system', 'card'
    content_text text,
    content_metadata jsonb, -- 富媒体内容元数据
    content_size_bytes integer DEFAULT 0,
    
    -- 消息回复和引用
    reply_to_message_id uuid REFERENCES public.messages(id),
    thread_id uuid, -- 消息线程ID
    
    -- 消息状态
    status text NOT NULL DEFAULT 'sent', -- 'sending', 'sent', 'delivered', 'failed'
    priority text DEFAULT 'normal', -- 'low', 'normal', 'high', 'urgent'
    
    -- 时间戳
    created_at timestamptz NOT NULL DEFAULT now(),
    sent_at timestamptz DEFAULT now(),
    edited_at timestamptz,
    
    -- 管理字段
    is_deleted boolean DEFAULT false,
    deleted_at timestamptz,
    deleted_by text, -- external_user_id
    is_system_message boolean DEFAULT false,
    
    -- 多语言支持
    language_code text DEFAULT 'en',
    translated_content jsonb, -- 翻译缓存
    
    -- 内容审核
    moderation_status text DEFAULT 'approved', -- 'pending', 'approved', 'rejected', 'flagged'
    moderation_score numeric,
    flagged_reason text,
    
    -- 归档管理
    is_archived boolean DEFAULT false,
    archived_at timestamptz,
    
    CONSTRAINT valid_message_type CHECK (message_type IN ('text', 'image', 'file', 'location', 'system', 'card')),
    CONSTRAINT valid_status CHECK (status IN ('sending', 'sent', 'delivered', 'failed')),
    CONSTRAINT valid_priority CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    CONSTRAINT valid_moderation_status CHECK (moderation_status IN ('pending', 'approved', 'rejected', 'flagged'))
);

-- 消息附件表
CREATE TABLE IF NOT EXISTS public.message_attachments (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    message_id uuid NOT NULL REFERENCES public.messages(id) ON DELETE CASCADE,
    
    -- 文件信息
    file_type text NOT NULL, -- 'image', 'video', 'audio', 'document'
    file_name text NOT NULL,
    file_url text NOT NULL,
    file_size_bytes integer NOT NULL,
    mime_type text NOT NULL,
    
    -- 预览信息
    thumbnail_url text,
    width integer,
    height integer,
    duration_seconds integer,
    
    -- 存储元数据
    storage_provider text DEFAULT 'internal', -- 'internal', 'aws', 'alicloud'
    storage_path text,
    cdn_url text,
    metadata jsonb DEFAULT '{}',
    
    -- 管理字段
    is_deleted boolean DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    
    CONSTRAINT valid_file_type CHECK (file_type IN ('image', 'video', 'audio', 'document'))
);

-- 消息状态跟踪表 (已读回执)
CREATE TABLE IF NOT EXISTS public.message_receipts (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    message_id uuid NOT NULL REFERENCES public.messages(id) ON DELETE CASCADE,
    external_user_id text NOT NULL,
    
    -- 状态类型
    receipt_type text NOT NULL, -- 'delivered', 'read'
    
    -- 时间戳
    created_at timestamptz NOT NULL DEFAULT now(),
    
    UNIQUE(tenant_id, message_id, external_user_id, receipt_type),
    CONSTRAINT valid_receipt_type CHECK (receipt_type IN ('delivered', 'read'))
);

-- ========================================
-- 4. 实时会话管理
-- ========================================

-- WebSocket连接跟踪
CREATE TABLE IF NOT EXISTS public.websocket_connections (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    external_user_id text NOT NULL,
    
    -- 连接信息
    connection_id text UNIQUE NOT NULL, -- WebSocket连接标识
    server_node text, -- 服务器节点标识
    
    -- 用户状态
    presence_status text DEFAULT 'online', -- 'online', 'away', 'busy', 'offline'
    last_activity_at timestamptz DEFAULT now(),
    
    -- 连接元数据
    user_agent text,
    ip_address inet,
    device_info jsonb,
    
    -- 时间戳
    connected_at timestamptz DEFAULT now(),
    disconnected_at timestamptz,
    
    CONSTRAINT valid_presence_status CHECK (presence_status IN ('online', 'away', 'busy', 'offline'))
);

-- 用户输入状态 (正在输入)
CREATE TABLE IF NOT EXISTS public.typing_indicators (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    conversation_id uuid NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    external_user_id text NOT NULL,
    
    -- 状态信息
    is_typing boolean DEFAULT true,
    started_at timestamptz DEFAULT now(),
    expires_at timestamptz DEFAULT (now() + INTERVAL '10 seconds'),
    
    UNIQUE(tenant_id, conversation_id, external_user_id)
);

-- ========================================
-- 5. API访问控制和审计
-- ========================================

-- API访问令牌
CREATE TABLE IF NOT EXISTS public.api_tokens (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    
    -- 令牌信息
    token_name text NOT NULL,
    token_hash text UNIQUE NOT NULL, -- 加密后的token
    token_prefix text NOT NULL, -- token前缀(用于识别)
    
    -- 权限和配置
    scopes text[] DEFAULT '{}', -- API权限范围
    rate_limit_per_minute integer DEFAULT 1000,
    
    -- 状态管理
    is_active boolean DEFAULT true,
    expires_at timestamptz,
    last_used_at timestamptz,
    
    -- 使用统计
    total_requests bigint DEFAULT 0,
    
    -- 时间戳
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by text, -- 创建者
    
    UNIQUE(tenant_id, token_name)
);

-- API调用日志
CREATE TABLE IF NOT EXISTS public.api_call_logs (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    token_id uuid REFERENCES public.api_tokens(id),
    
    -- 请求信息
    method text NOT NULL,
    endpoint text NOT NULL,
    user_agent text,
    ip_address inet,
    
    -- 响应信息
    status_code integer,
    response_time_ms integer,
    request_size_bytes integer,
    response_size_bytes integer,
    
    -- 错误信息
    error_message text,
    
    -- 时间戳
    created_at timestamptz NOT NULL DEFAULT now()
);

-- ========================================
-- 6. 数据归档和清理
-- ========================================

-- 归档消息表
CREATE TABLE IF NOT EXISTS public.messages_archive (
    LIKE public.messages INCLUDING ALL,
    archived_date timestamptz DEFAULT now(),
    archive_reason text DEFAULT 'retention_policy'
);

-- 归档附件表
CREATE TABLE IF NOT EXISTS public.message_attachments_archive (
    LIKE public.message_attachments INCLUDING ALL,
    archived_date timestamptz DEFAULT now(),
    archive_reason text DEFAULT 'retention_policy'
);

-- ========================================
-- 7. 索引优化 (多租户)
-- ========================================

-- 租户相关索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tenants_app_id ON public.tenants (app_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tenants_plan_type ON public.tenants (plan_type);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tenants_subscription_status ON public.tenants (subscription_status);

-- 用户相关索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tenant_users_tenant_external ON public.tenant_users (tenant_id, external_user_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tenant_users_status ON public.tenant_users (tenant_id, status);

-- 会话相关索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_conversations_tenant_id ON public.conversations (tenant_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_conversations_tenant_status ON public.conversations (tenant_id, status);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_conversations_last_activity ON public.conversations (tenant_id, last_activity_at DESC);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_conversations_participants ON public.conversations USING GIN (participants);

-- 会话参与者索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_conversation_participants_tenant_user ON public.conversation_participants (tenant_id, external_user_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_conversation_participants_conversation ON public.conversation_participants (conversation_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_conversation_participants_unread ON public.conversation_participants (tenant_id, external_user_id) WHERE unread_count > 0;

-- 消息相关索引 (重点优化)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_tenant_id ON public.messages (tenant_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_conversation_created ON public.messages (conversation_id, created_at DESC);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_tenant_conversation_created ON public.messages (tenant_id, conversation_id, created_at DESC);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_sender ON public.messages (tenant_id, sender_external_id);

-- 活跃消息查询优化
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_active ON public.messages (tenant_id, conversation_id, created_at DESC) 
WHERE is_deleted = false AND is_archived = false;

-- 附件相关索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_message_attachments_tenant_message ON public.message_attachments (tenant_id, message_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_message_attachments_file_type ON public.message_attachments (tenant_id, file_type);

-- 实时功能索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_websocket_connections_tenant_user ON public.websocket_connections (tenant_id, external_user_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_websocket_connections_connection_id ON public.websocket_connections (connection_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_typing_indicators_conversation ON public.typing_indicators (conversation_id);

-- API相关索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_api_tokens_tenant ON public.api_tokens (tenant_id, is_active);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_api_call_logs_tenant_created ON public.api_call_logs (tenant_id, created_at DESC);

-- ========================================
-- 8. 行级安全策略 (RLS)
-- ========================================

-- 启用RLS
ALTER TABLE public.tenant_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversation_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.websocket_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.typing_indicators ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.api_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.api_call_logs ENABLE ROW LEVEL SECURITY;

-- 创建获取当前租户ID的函数
CREATE OR REPLACE FUNCTION current_tenant_id() RETURNS uuid AS $$
BEGIN
    RETURN current_setting('app.current_tenant_id', true)::uuid;
EXCEPTION
    WHEN others THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 租户隔离策略 (示例)
CREATE POLICY tenant_isolation_policy ON public.messages
    FOR ALL
    TO authenticated
    USING (tenant_id = current_tenant_id());

CREATE POLICY tenant_isolation_policy ON public.conversations
    FOR ALL
    TO authenticated
    USING (tenant_id = current_tenant_id());

-- ========================================
-- 9. 统计和分析视图
-- ========================================

-- 租户使用统计视图
CREATE OR REPLACE VIEW public.tenant_usage_stats AS
SELECT 
    t.id as tenant_id,
    t.app_id,
    t.name as tenant_name,
    t.plan_type,
    
    -- 用户统计
    COUNT(DISTINCT tu.id) as total_users,
    COUNT(DISTINCT CASE WHEN tu.status = 'active' THEN tu.id END) as active_users,
    COUNT(DISTINCT CASE WHEN tu.last_seen_at > NOW() - INTERVAL '24 hours' THEN tu.id END) as daily_active_users,
    
    -- 会话统计
    COUNT(DISTINCT c.id) as total_conversations,
    COUNT(DISTINCT CASE WHEN c.status = 'active' THEN c.id END) as active_conversations,
    
    -- 消息统计
    COUNT(DISTINCT m.id) as total_messages,
    COUNT(DISTINCT CASE WHEN m.created_at > DATE_TRUNC('month', NOW()) THEN m.id END) as monthly_messages,
    COUNT(DISTINCT CASE WHEN m.created_at > NOW() - INTERVAL '24 hours' THEN m.id END) as daily_messages,
    
    -- 存储统计
    COALESCE(SUM(ma.file_size_bytes), 0) / 1024 / 1024 as storage_used_mb,
    
    t.quota_active_users,
    t.quota_messages_per_month,
    t.quota_storage_gb * 1024 as quota_storage_mb,
    
    t.created_at as tenant_created_at,
    t.last_activity_at

FROM public.tenants t
LEFT JOIN public.tenant_users tu ON t.id = tu.tenant_id
LEFT JOIN public.conversations c ON t.id = c.tenant_id
LEFT JOIN public.messages m ON t.id = m.tenant_id
LEFT JOIN public.message_attachments ma ON t.id = ma.tenant_id
GROUP BY t.id, t.app_id, t.name, t.plan_type, t.quota_active_users, t.quota_messages_per_month, t.quota_storage_gb, t.created_at, t.last_activity_at;

-- 消息活动统计视图
CREATE OR REPLACE VIEW public.message_activity_stats AS
SELECT 
    tenant_id,
    DATE_TRUNC('hour', created_at) as hour_bucket,
    COUNT(*) as message_count,
    COUNT(DISTINCT sender_external_id) as unique_senders,
    COUNT(DISTINCT conversation_id) as active_conversations,
    AVG(content_size_bytes) as avg_message_size
FROM public.messages
WHERE created_at > NOW() - INTERVAL '7 days'
  AND is_deleted = false
GROUP BY tenant_id, DATE_TRUNC('hour', created_at)
ORDER BY hour_bucket DESC;

-- ========================================
-- 10. 数据生命周期管理函数
-- ========================================

-- 租户专用归档函数
CREATE OR REPLACE FUNCTION archive_tenant_messages(
    p_tenant_id uuid,
    p_days_old INTEGER DEFAULT 90
) RETURNS INTEGER AS $$
DECLARE
    archived_count INTEGER;
BEGIN
    -- 归档旧消息
    WITH archived AS (
        INSERT INTO public.messages_archive 
        SELECT *, now(), 'auto_archive'
        FROM public.messages 
        WHERE tenant_id = p_tenant_id
          AND created_at < (now() - INTERVAL '1 day' * p_days_old)
          AND is_archived = false
          AND is_deleted = false
        RETURNING id
    )
    SELECT COUNT(*) INTO archived_count FROM archived;
    
    -- 标记原表消息为已归档
    UPDATE public.messages 
    SET is_archived = true, archived_at = now()
    WHERE tenant_id = p_tenant_id
      AND created_at < (now() - INTERVAL '1 day' * p_days_old)
      AND is_archived = false
      AND is_deleted = false;
    
    RETURN archived_count;
END;
$$ LANGUAGE plpgsql;

-- 租户配额检查函数
CREATE OR REPLACE FUNCTION check_tenant_quota(
    p_tenant_id uuid,
    p_quota_type text
) RETURNS boolean AS $$
DECLARE
    tenant_record public.tenants%ROWTYPE;
    current_usage bigint;
    quota_limit bigint;
BEGIN
    -- 获取租户信息
    SELECT * INTO tenant_record FROM public.tenants WHERE id = p_tenant_id;
    
    IF NOT FOUND THEN
        RETURN false;
    END IF;
    
    CASE p_quota_type
        WHEN 'messages' THEN
            SELECT COUNT(*) INTO current_usage 
            FROM public.messages 
            WHERE tenant_id = p_tenant_id 
              AND created_at >= DATE_TRUNC('month', NOW());
            quota_limit := tenant_record.quota_messages_per_month;
            
        WHEN 'api_calls' THEN
            SELECT COUNT(*) INTO current_usage 
            FROM public.api_call_logs 
            WHERE tenant_id = p_tenant_id 
              AND created_at >= DATE_TRUNC('month', NOW());
            quota_limit := tenant_record.quota_api_calls_per_month;
            
        WHEN 'storage' THEN
            SELECT COALESCE(SUM(file_size_bytes), 0) / 1024 / 1024 / 1024 INTO current_usage 
            FROM public.message_attachments 
            WHERE tenant_id = p_tenant_id;
            quota_limit := tenant_record.quota_storage_gb;
            
        ELSE
            RETURN false;
    END CASE;
    
    RETURN current_usage < quota_limit;
END;
$$ LANGUAGE plpgsql;

-- 清理过期的输入状态
CREATE OR REPLACE FUNCTION cleanup_expired_typing_indicators() 
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    WITH deleted AS (
        DELETE FROM public.typing_indicators 
        WHERE expires_at < NOW()
        RETURNING id
    )
    SELECT COUNT(*) INTO deleted_count FROM deleted;
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql; 