-- ================================================
-- 内容审核系统数据库架构（安全版本）
-- ================================================
-- 用途：自动审核用户生成内容（UGC），防止违规内容发布
-- 创建日期：2025-12-28
-- 注意：此版本不依赖users表，可以独立运行
-- ================================================

-- ================================================
-- 1. 敏感词表
-- ================================================
CREATE TABLE IF NOT EXISTS sensitive_words (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    word VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50) NOT NULL, -- political, pornographic, violent, fraud, insult, spam, custom
    severity INT NOT NULL DEFAULT 1 CHECK (severity >= 1 AND severity <= 5), -- 1-5，5最严重
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_sensitive_words_word ON sensitive_words(word);
CREATE INDEX IF NOT EXISTS idx_sensitive_words_category ON sensitive_words(category);
CREATE INDEX IF NOT EXISTS idx_sensitive_words_active ON sensitive_words(is_active);

-- ================================================
-- 2. 审核日志表
-- ================================================
CREATE TABLE IF NOT EXISTS moderation_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_type VARCHAR(50) NOT NULL, -- review, review_reply, comment, post
    content_id UUID,
    user_id UUID,

    -- 审核结果
    is_approved BOOLEAN NOT NULL DEFAULT false,
    reason VARCHAR(100), -- sensitive_words, spam, rating_mismatch, etc.
    details TEXT,
    found_words TEXT[], -- 检测到的敏感词列表

    -- 人工审核
    requires_manual_review BOOLEAN NOT NULL DEFAULT false,
    manual_review_status VARCHAR(20) DEFAULT 'pending', -- pending, approved, rejected
    manual_reviewer_id UUID,
    manual_review_note TEXT,
    manual_reviewed_at TIMESTAMP WITH TIME ZONE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_moderation_logs_content_type ON moderation_logs(content_type);
CREATE INDEX IF NOT EXISTS idx_moderation_logs_content_id ON moderation_logs(content_id);
CREATE INDEX IF NOT EXISTS idx_moderation_logs_user_id ON moderation_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_moderation_logs_created_at ON moderation_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_moderation_logs_manual_review ON moderation_logs(requires_manual_review, manual_review_status);

-- ================================================
-- 3. 为 reviews 表添加审核相关字段
-- ================================================
DO $$
BEGIN
    -- 添加审核状态字段
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'reviews' AND column_name = 'moderation_status'
    ) THEN
        ALTER TABLE reviews ADD COLUMN moderation_status VARCHAR(20) DEFAULT 'pending';
    END IF;

    -- 添加服务商回复审核状态字段
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'reviews' AND column_name = 'provider_response_status'
    ) THEN
        ALTER TABLE reviews ADD COLUMN provider_response_status VARCHAR(20) DEFAULT 'pending_review';
    END IF;
END $$;

-- ================================================
-- 4. 插入默认敏感词
-- ================================================
INSERT INTO sensitive_words (word, category, severity) VALUES
    -- 政治敏感词（示例，实际应用中需要更完整的词库）
    ('政治敏感词1', 'political', 5),
    ('政治敏感词2', 'political', 5),

    -- 色情词汇（示例）
    ('色情词1', 'pornographic', 5),
    ('色情词2', 'pornographic', 5),

    -- 暴力词汇（示例）
    ('暴力词1', 'violent', 4),
    ('暴力词2', 'violent', 4),

    -- 欺诈词汇（示例）
    ('欺诈词1', 'fraud', 4),
    ('骗子', 'fraud', 3),
    ('诈骗', 'fraud', 4),

    -- 侮辱词汇（示例）
    ('傻逼', 'insult', 3),
    ('白痴', 'insult', 2),
    ('垃圾', 'insult', 2),

    -- 垃圾信息（示例）
    ('加微信', 'spam', 2),
    ('加QQ', 'spam', 2),
    ('点击链接', 'spam', 3)
ON CONFLICT (word) DO NOTHING;

-- ================================================
-- 5. 创建触发器：自动更新 updated_at
-- ================================================
CREATE OR REPLACE FUNCTION update_sensitive_words_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_sensitive_words_updated_at ON sensitive_words;
CREATE TRIGGER trigger_update_sensitive_words_updated_at
    BEFORE UPDATE ON sensitive_words
    FOR EACH ROW
    EXECUTE FUNCTION update_sensitive_words_updated_at();

-- ================================================
-- 6. 创建视图：待人工审核的内容
-- ================================================
CREATE OR REPLACE VIEW pending_manual_reviews AS
SELECT
    ml.id AS log_id,
    ml.content_type,
    ml.content_id,
    ml.user_id,
    ml.reason,
    ml.details,
    ml.found_words,
    ml.created_at,
    ml.manual_review_status,
    CASE
        WHEN ml.content_type = 'review' THEN r.content
        ELSE NULL
    END AS review_content,
    CASE
        WHEN ml.content_type = 'review' THEN r.title
        ELSE NULL
    END AS review_title
FROM moderation_logs ml
LEFT JOIN reviews r ON ml.content_type = 'review' AND ml.content_id = r.id
WHERE ml.requires_manual_review = true
  AND ml.manual_review_status = 'pending'
ORDER BY ml.created_at DESC;

-- ================================================
-- 7. 创建基础RLS策略（不依赖users表）
-- ================================================

-- 启用RLS
ALTER TABLE sensitive_words ENABLE ROW LEVEL SECURITY;
ALTER TABLE moderation_logs ENABLE ROW LEVEL SECURITY;

-- sensitive_words 策略：所有认证用户可以读取（用于审核）
DROP POLICY IF EXISTS "认证用户可以读取敏感词" ON sensitive_words;
CREATE POLICY "认证用户可以读取敏感词" ON sensitive_words
    FOR SELECT
    USING (auth.uid() IS NOT NULL);

-- sensitive_words 策略：服务角色可以全部操作（用于系统管理）
DROP POLICY IF EXISTS "服务角色可以管理敏感词" ON sensitive_words;
CREATE POLICY "服务角色可以管理敏感词" ON sensitive_words
    FOR ALL
    USING (auth.role() = 'service_role');

-- moderation_logs 策略：用户可以查看自己的审核日志
DROP POLICY IF EXISTS "用户可以查看自己的审核日志" ON moderation_logs;
CREATE POLICY "用户可以查看自己的审核日志" ON moderation_logs
    FOR SELECT
    USING (user_id = auth.uid());

-- moderation_logs 策略：系统可以插入审核日志
DROP POLICY IF EXISTS "系统可以插入审核日志" ON moderation_logs;
CREATE POLICY "系统可以插入审核日志" ON moderation_logs
    FOR INSERT
    WITH CHECK (true);

-- moderation_logs 策略：服务角色可以查看所有日志
DROP POLICY IF EXISTS "服务角色可以查看所有日志" ON moderation_logs;
CREATE POLICY "服务角色可以查看所有日志" ON moderation_logs
    FOR SELECT
    USING (auth.role() = 'service_role');

-- ================================================
-- 8. 创建管理函数
-- ================================================

-- 批准待审核内容
CREATE OR REPLACE FUNCTION approve_pending_content(
    p_log_id UUID,
    p_reviewer_id UUID,
    p_note TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_content_type VARCHAR;
    v_content_id UUID;
BEGIN
    -- 获取内容信息
    SELECT content_type, content_id
    INTO v_content_type, v_content_id
    FROM moderation_logs
    WHERE id = p_log_id;

    -- 更新审核日志
    UPDATE moderation_logs
    SET
        manual_review_status = 'approved',
        manual_reviewer_id = p_reviewer_id,
        manual_review_note = p_note,
        manual_reviewed_at = NOW()
    WHERE id = p_log_id;

    -- 根据内容类型更新相应的表
    IF v_content_type = 'review' THEN
        UPDATE reviews
        SET status = 'published', moderation_status = 'approved'
        WHERE id = v_content_id;
    END IF;

    RETURN true;
EXCEPTION
    WHEN OTHERS THEN
        RETURN false;
END;
$$ LANGUAGE plpgsql;

-- 拒绝待审核内容
CREATE OR REPLACE FUNCTION reject_pending_content(
    p_log_id UUID,
    p_reviewer_id UUID,
    p_reason TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
    v_content_type VARCHAR;
    v_content_id UUID;
BEGIN
    -- 获取内容信息
    SELECT content_type, content_id
    INTO v_content_type, v_content_id
    FROM moderation_logs
    WHERE id = p_log_id;

    -- 更新审核日志
    UPDATE moderation_logs
    SET
        manual_review_status = 'rejected',
        manual_reviewer_id = p_reviewer_id,
        manual_review_note = p_reason,
        manual_reviewed_at = NOW()
    WHERE id = p_log_id;

    -- 根据内容类型更新相应的表
    IF v_content_type = 'review' THEN
        UPDATE reviews
        SET status = 'rejected', moderation_status = 'rejected'
        WHERE id = v_content_id;
    END IF;

    RETURN true;
EXCEPTION
    WHEN OTHERS THEN
        RETURN false;
END;
$$ LANGUAGE plpgsql;

-- ================================================
-- 9. 创建统计视图
-- ================================================
CREATE OR REPLACE VIEW moderation_statistics AS
SELECT
    COUNT(*) AS total_checks,
    SUM(CASE WHEN is_approved THEN 1 ELSE 0 END) AS approved_count,
    SUM(CASE WHEN NOT is_approved THEN 1 ELSE 0 END) AS rejected_count,
    SUM(CASE WHEN requires_manual_review THEN 1 ELSE 0 END) AS manual_review_count,
    SUM(CASE WHEN requires_manual_review AND manual_review_status = 'pending' THEN 1 ELSE 0 END) AS pending_manual_review_count,
    COUNT(DISTINCT content_type) AS content_types_count,
    COUNT(DISTINCT user_id) AS unique_users_count
FROM moderation_logs;

-- ================================================
-- 完成
-- ================================================
COMMENT ON TABLE sensitive_words IS '敏感词表 - 用于内容审核';
COMMENT ON TABLE moderation_logs IS '审核日志表 - 记录所有内容审核历史';
COMMENT ON VIEW pending_manual_reviews IS '待人工审核的内容视图';
COMMENT ON VIEW moderation_statistics IS '审核统计视图';
COMMENT ON FUNCTION approve_pending_content(UUID, UUID, TEXT) IS '批准待审核内容';
COMMENT ON FUNCTION reject_pending_content(UUID, UUID, TEXT) IS '拒绝待审核内容';

-- 输出成功消息
DO $$
BEGIN
    RAISE NOTICE '内容审核系统数据库架构创建成功！';
    RAISE NOTICE '已创建表：sensitive_words, moderation_logs';
    RAISE NOTICE '已创建视图：pending_manual_reviews, moderation_statistics';
    RAISE NOTICE '已创建函数：approve_pending_content, reject_pending_content';
    RAISE NOTICE '';
    RAISE NOTICE '注意：此版本使用基础RLS策略（不依赖users表）';
    RAISE NOTICE '如果您的数据库有user_profiles表，可以运行content_moderation_system_with_users.sql以启用完整的RLS策略';
END $$;
