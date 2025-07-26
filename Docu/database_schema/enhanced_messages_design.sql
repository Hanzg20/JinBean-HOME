-- Enhanced Message Storage Design for JinBean
-- 增强版消息存储设计

-- ========================================
-- 1. 主消息表 (优化版)
-- ========================================
CREATE TABLE IF NOT EXISTS public.messages (
    -- 基础字段
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id uuid NOT NULL, -- 会话ID (订单ID或用户间会话ID)
    conversation_type text NOT NULL DEFAULT 'order', -- 'order', 'general', 'community'
    
    -- 消息参与者
    sender_id uuid NOT NULL REFERENCES auth.users(id),
    receiver_id uuid NOT NULL REFERENCES auth.users(id),
    
    -- 消息内容
    message_type text NOT NULL DEFAULT 'text', -- 'text', 'image', 'file', 'location', 'system'
    content_text text, -- 文本内容
    content_metadata jsonb, -- 富媒体元数据
    content_size_bytes integer DEFAULT 0, -- 内容大小(字节)
    
    -- 消息状态
    status text NOT NULL DEFAULT 'sent', -- 'sending', 'sent', 'delivered', 'read', 'failed'
    
    -- 时间戳
    created_at timestamptz NOT NULL DEFAULT now(),
    sent_at timestamptz,
    delivered_at timestamptz,
    read_at timestamptz,
    
    -- 管理字段
    is_deleted boolean DEFAULT false, -- 软删除
    deleted_at timestamptz,
    deleted_by uuid REFERENCES auth.users(id),
    is_system_message boolean DEFAULT false, -- 系统消息标记
    priority text DEFAULT 'normal', -- 'low', 'normal', 'high', 'urgent'
    
    -- 多语言支持
    language_code text DEFAULT 'en',
    translated_content jsonb, -- 翻译内容缓存
    
    -- 审核和合规
    is_flagged boolean DEFAULT false,
    flagged_reason text,
    moderation_status text DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
    
    -- 归档标记
    is_archived boolean DEFAULT false,
    archived_at timestamptz,
    
    CONSTRAINT valid_conversation_type CHECK (conversation_type IN ('order', 'general', 'community')),
    CONSTRAINT valid_message_type CHECK (message_type IN ('text', 'image', 'file', 'location', 'system')),
    CONSTRAINT valid_status CHECK (status IN ('sending', 'sent', 'delivered', 'read', 'failed')),
    CONSTRAINT valid_priority CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    CONSTRAINT valid_moderation_status CHECK (moderation_status IN ('pending', 'approved', 'rejected'))
);

-- ========================================
-- 2. 消息附件表
-- ========================================
CREATE TABLE IF NOT EXISTS public.message_attachments (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    message_id uuid NOT NULL REFERENCES public.messages(id) ON DELETE CASCADE,
    
    -- 文件信息
    file_type text NOT NULL, -- 'image', 'video', 'audio', 'document'
    file_name text NOT NULL,
    file_url text NOT NULL,
    file_size_bytes integer NOT NULL,
    mime_type text NOT NULL,
    
    -- 预览信息 (图片/视频)
    thumbnail_url text,
    width integer,
    height integer,
    duration_seconds integer, -- 音频/视频时长
    
    -- 元数据
    metadata jsonb, -- 额外元数据 (EXIF, 压缩信息等)
    storage_provider text DEFAULT 'supabase', -- 'supabase', 'aws', 'local'
    cdn_url text, -- CDN加速链接
    
    -- 管理字段
    is_deleted boolean DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    
    CONSTRAINT valid_file_type CHECK (file_type IN ('image', 'video', 'audio', 'document'))
);

-- ========================================
-- 3. 会话表 (Conversation Management)
-- ========================================
CREATE TABLE IF NOT EXISTS public.conversations (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    type text NOT NULL, -- 'order', 'general', 'group'
    
    -- 关联信息
    order_id uuid REFERENCES public.orders(id), -- 订单会话关联
    
    -- 参与者 (JSON数组存储用户ID)
    participants jsonb NOT NULL, -- ["user1_id", "user2_id", ...]
    participant_count integer NOT NULL DEFAULT 2,
    
    -- 会话状态
    status text DEFAULT 'active', -- 'active', 'archived', 'blocked'
    
    -- 最后消息信息
    last_message_id uuid REFERENCES public.messages(id),
    last_message_at timestamptz,
    last_activity_at timestamptz DEFAULT now(),
    
    -- 管理字段
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid NOT NULL REFERENCES auth.users(id),
    
    -- 设置
    settings jsonb DEFAULT '{}', -- 会话设置 (通知开关等)
    
    CONSTRAINT valid_conversation_type CHECK (type IN ('order', 'general', 'group')),
    CONSTRAINT valid_conversation_status CHECK (status IN ('active', 'archived', 'blocked'))
);

-- ========================================
-- 4. 用户会话关系表
-- ========================================
CREATE TABLE IF NOT EXISTS public.conversation_participants (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id uuid NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- 参与状态
    status text DEFAULT 'active', -- 'active', 'left', 'removed', 'blocked'
    role text DEFAULT 'member', -- 'admin', 'member'
    
    -- 消息状态
    last_read_message_id uuid REFERENCES public.messages(id),
    last_read_at timestamptz,
    unread_count integer DEFAULT 0,
    
    -- 通知设置
    notifications_enabled boolean DEFAULT true,
    
    -- 时间戳
    joined_at timestamptz DEFAULT now(),
    left_at timestamptz,
    
    UNIQUE(conversation_id, user_id),
    CONSTRAINT valid_participant_status CHECK (status IN ('active', 'left', 'removed', 'blocked')),
    CONSTRAINT valid_participant_role CHECK (role IN ('admin', 'member'))
);

-- ========================================
-- 5. 消息归档表 (历史数据冷存储)
-- ========================================
CREATE TABLE IF NOT EXISTS public.messages_archive (
    LIKE public.messages INCLUDING ALL,
    archive_date timestamptz DEFAULT now(),
    original_table text DEFAULT 'messages'
);

-- ========================================
-- 6. 索引优化
-- ========================================

-- 主消息表索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_conversation_id ON public.messages (conversation_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_sender_id ON public.messages (sender_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_receiver_id ON public.messages (receiver_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_created_at ON public.messages (created_at DESC);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_status ON public.messages (status);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_conversation_created ON public.messages (conversation_id, created_at DESC);

-- 复合索引 (查询优化)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_active_conversation 
ON public.messages (conversation_id, created_at DESC) 
WHERE is_deleted = false AND is_archived = false;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_unread 
ON public.messages (receiver_id, created_at DESC) 
WHERE status IN ('sent', 'delivered') AND is_deleted = false;

-- 会话表索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_conversations_participants ON public.conversations USING GIN (participants);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_conversations_last_activity ON public.conversations (last_activity_at DESC);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_conversations_order_id ON public.conversations (order_id) WHERE order_id IS NOT NULL;

-- 会话参与者索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_conversation_participants_user ON public.conversation_participants (user_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_conversation_participants_conversation ON public.conversation_participants (conversation_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_conversation_participants_unread ON public.conversation_participants (user_id, unread_count) WHERE unread_count > 0;

-- 附件表索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_message_attachments_message ON public.message_attachments (message_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_message_attachments_type ON public.message_attachments (file_type);

-- ========================================
-- 7. 分区表设计 (大数据量优化)
-- ========================================

-- 按月分区的消息表 (可选，大规模使用时启用)
/*
CREATE TABLE messages_partitioned (
    LIKE public.messages INCLUDING ALL
) PARTITION BY RANGE (created_at);

-- 创建月度分区
CREATE TABLE messages_2024_01 PARTITION OF messages_partitioned
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE messages_2024_02 PARTITION OF messages_partitioned
FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
*/

-- ========================================
-- 8. 数据生命周期管理函数
-- ========================================

-- 自动归档旧消息函数
CREATE OR REPLACE FUNCTION archive_old_messages(days_old INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
    archived_count INTEGER;
BEGIN
    -- 移动旧消息到归档表
    WITH archived_messages AS (
        INSERT INTO public.messages_archive 
        SELECT *, now(), 'messages'
        FROM public.messages 
        WHERE created_at < (now() - INTERVAL '1 day' * days_old)
          AND is_archived = false
          AND conversation_type != 'order' -- 保留订单消息
        RETURNING id
    )
    SELECT COUNT(*) INTO archived_count FROM archived_messages;
    
    -- 标记原表消息为已归档
    UPDATE public.messages 
    SET is_archived = true, archived_at = now()
    WHERE created_at < (now() - INTERVAL '1 day' * days_old)
      AND is_archived = false
      AND conversation_type != 'order';
    
    RETURN archived_count;
END;
$$ LANGUAGE plpgsql;

-- 清理软删除消息函数
CREATE OR REPLACE FUNCTION cleanup_deleted_messages(days_old INTEGER DEFAULT 30)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    -- 物理删除长期软删除的消息
    WITH deleted_messages AS (
        DELETE FROM public.messages 
        WHERE is_deleted = true 
          AND deleted_at < (now() - INTERVAL '1 day' * days_old)
        RETURNING id
    )
    SELECT COUNT(*) INTO deleted_count FROM deleted_messages;
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- 压缩图片附件函数
CREATE OR REPLACE FUNCTION compress_old_attachments(days_old INTEGER DEFAULT 30)
RETURNS INTEGER AS $$
DECLARE
    compressed_count INTEGER := 0;
    attachment_record RECORD;
BEGIN
    -- 查找需要压缩的大图片附件
    FOR attachment_record IN
        SELECT id, file_url, file_size_bytes
        FROM public.message_attachments ma
        JOIN public.messages m ON ma.message_id = m.id
        WHERE m.created_at < (now() - INTERVAL '1 day' * days_old)
          AND ma.file_type = 'image'
          AND ma.file_size_bytes > 1048576 -- 1MB以上
          AND ma.thumbnail_url IS NULL
    LOOP
        -- 这里可以触发后台任务来压缩图片
        -- 实际实现需要与图片处理服务集成
        compressed_count := compressed_count + 1;
    END LOOP;
    
    RETURN compressed_count;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 9. 定时任务设置 (使用 pg_cron 扩展)
-- ========================================

/*
-- 启用 pg_cron 扩展 (需要超级用户权限)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- 每天凌晨2点运行归档任务
SELECT cron.schedule('archive-old-messages', '0 2 * * *', 'SELECT archive_old_messages(90);');

-- 每周日凌晨3点清理软删除消息
SELECT cron.schedule('cleanup-deleted-messages', '0 3 * * 0', 'SELECT cleanup_deleted_messages(30);');

-- 每月1号凌晨4点压缩旧附件
SELECT cron.schedule('compress-old-attachments', '0 4 1 * *', 'SELECT compress_old_attachments(30);');
*/ 