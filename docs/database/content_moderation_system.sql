-- ================================================
-- 内容审核系统数据库架构
-- ================================================
-- 用途：支持评价、评论等UGC内容的自动审核和人工审核
-- 创建日期：2025-12-28
-- ================================================

-- ================================================
-- 1. 敏感词表
-- ================================================
-- 存储需要过滤的敏感词汇
CREATE TABLE IF NOT EXISTS sensitive_words (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    word VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50) DEFAULT 'custom', -- 分类：politics, porn, violence, fraud, abuse, spam, custom等
    severity INT DEFAULT 3, -- 严重程度：1-低, 2-中, 3-高
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),

    -- 索引
    CONSTRAINT word_lowercase CHECK (word = LOWER(word))
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_sensitive_words_word ON sensitive_words(word);
CREATE INDEX IF NOT EXISTS idx_sensitive_words_category ON sensitive_words(category);
CREATE INDEX IF NOT EXISTS idx_sensitive_words_is_active ON sensitive_words(is_active);

-- ================================================
-- 2. 审核日志表
-- ================================================
-- 记录所有内容的审核结果
CREATE TABLE IF NOT EXISTS moderation_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_type VARCHAR(50) NOT NULL, -- 'review', 'reply', 'comment', 'post'等
    content_id UUID NOT NULL, -- 关联的内容ID
    user_id UUID REFERENCES users(id),

    -- 自动审核结果
    is_approved BOOLEAN NOT NULL,
    reason VARCHAR(100), -- 审核不通过的原因代码
    details TEXT, -- 详细说明
    found_words TEXT[], -- 检测到的敏感词

    -- 人工审核
    requires_manual_review BOOLEAN DEFAULT false,
    manual_review_status VARCHAR(20) DEFAULT 'pending', -- pending, approved, rejected
    manual_reviewer_id UUID REFERENCES users(id),
    manual_review_note TEXT,
    manual_reviewed_at TIMESTAMP WITH TIME ZONE,

    -- 时间戳
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- 索引
    CONSTRAINT moderation_status_check CHECK (
        manual_review_status IN ('pending', 'approved', 'rejected', 'escalated')
    )
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_moderation_logs_content ON moderation_logs(content_type, content_id);
CREATE INDEX IF NOT EXISTS idx_moderation_logs_user ON moderation_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_moderation_logs_manual_review ON moderation_logs(requires_manual_review, manual_review_status);
CREATE INDEX IF NOT EXISTS idx_moderation_logs_created_at ON moderation_logs(created_at DESC);

-- ================================================
-- 3. 为 reviews 表添加审核字段
-- ================================================
-- 如果 reviews 表不存在 moderation_status 和 provider_response_status 字段，添加它们

-- 添加评价内容审核状态
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'reviews' AND column_name = 'moderation_status'
    ) THEN
        ALTER TABLE reviews ADD COLUMN moderation_status VARCHAR(30) DEFAULT 'approved';
        ALTER TABLE reviews ADD CONSTRAINT reviews_moderation_status_check
            CHECK (moderation_status IN ('pending', 'approved', 'rejected', 'pending_manual_review'));
    END IF;
END $$;

-- 添加服务商回复审核状态
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'reviews' AND column_name = 'provider_response_status'
    ) THEN
        ALTER TABLE reviews ADD COLUMN provider_response_status VARCHAR(30) DEFAULT 'published';
        ALTER TABLE reviews ADD CONSTRAINT reviews_provider_response_status_check
            CHECK (provider_response_status IN ('pending_review', 'published', 'rejected'));
    END IF;
END $$;

-- ================================================
-- 4. 插入默认敏感词数据
-- ================================================
-- 插入常见敏感词（示例数据）
INSERT INTO sensitive_words (word, category, severity) VALUES
    -- 政治类
    ('政治敏感词1', 'politics', 3),
    ('政治敏感词2', 'politics', 3),

    -- 色情低俗类
    ('色情', 'porn', 3),
    ('低俗', 'porn', 2),
    ('裸体', 'porn', 3),
    ('性交', 'porn', 3),

    -- 暴力恐怖类
    ('暴力', 'violence', 3),
    ('恐怖', 'violence', 3),
    ('杀人', 'violence', 3),
    ('自杀', 'violence', 3),
    ('爆炸', 'violence', 3),

    -- 欺诈违法类
    ('诈骗', 'fraud', 3),
    ('赌博', 'fraud', 3),
    ('毒品', 'fraud', 3),
    ('走私', 'fraud', 3),
    ('洗钱', 'fraud', 3),
    ('传销', 'fraud', 3),

    -- 侮辱谩骂类
    ('傻逼', 'abuse', 2),
    ('操你', 'abuse', 2),
    ('妈的', 'abuse', 2),
    ('去死', 'abuse', 3),
    ('垃圾', 'abuse', 1),
    ('傻b', 'abuse', 2),
    ('煞笔', 'abuse', 2),
    ('sb', 'abuse', 2),
    ('cnm', 'abuse', 3),
    ('nmsl', 'abuse', 3),

    -- 广告垃圾类
    ('加微信', 'spam', 2),
    ('加qq', 'spam', 2),
    ('联系方式', 'spam', 2),
    ('私聊', 'spam', 2),
    ('代办', 'spam', 2),
    ('办证', 'spam', 3),
    ('刷单', 'spam', 3),
    ('兼职', 'spam', 2),
    ('贷款', 'spam', 2),
    ('发票', 'spam', 2)
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
-- 6. 创建视图：待人工审核内容
-- ================================================
CREATE OR REPLACE VIEW pending_manual_reviews AS
SELECT
    ml.id,
    ml.content_type,
    ml.content_id,
    ml.user_id,
    u.email AS user_email,
    ml.reason,
    ml.details,
    ml.found_words,
    ml.manual_review_status,
    ml.created_at,
    -- 根据内容类型关联具体内容
    CASE
        WHEN ml.content_type = 'review' THEN r.content
        ELSE NULL
    END AS review_content,
    CASE
        WHEN ml.content_type = 'review' THEN r.title
        ELSE NULL
    END AS review_title
FROM moderation_logs ml
LEFT JOIN users u ON ml.user_id = u.id
LEFT JOIN reviews r ON ml.content_type = 'review' AND ml.content_id = r.id
WHERE ml.requires_manual_review = true
  AND ml.manual_review_status = 'pending'
ORDER BY ml.created_at DESC;

-- ================================================
-- 7. 创建RLS（行级安全）策略
-- ================================================

-- 启用RLS
ALTER TABLE sensitive_words ENABLE ROW LEVEL SECURITY;
ALTER TABLE moderation_logs ENABLE ROW LEVEL SECURITY;

-- sensitive_words 策略：只有管理员可以修改
DROP POLICY IF EXISTS "管理员可以管理敏感词" ON sensitive_words;
CREATE POLICY "管理员可以管理敏感词" ON sensitive_words
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid()
            AND role IN ('admin', 'super_admin')
        )
    );

-- sensitive_words 策略：所有认证用户可以读取（用于审核）
DROP POLICY IF EXISTS "认证用户可以读取敏感词" ON sensitive_words;
CREATE POLICY "认证用户可以读取敏感词" ON sensitive_words
    FOR SELECT
    USING (auth.uid() IS NOT NULL);

-- moderation_logs 策略：只有管理员可以查看所有日志
DROP POLICY IF EXISTS "管理员可以查看所有审核日志" ON moderation_logs;
CREATE POLICY "管理员可以查看所有审核日志" ON moderation_logs
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid()
            AND role IN ('admin', 'super_admin', 'moderator')
        )
    );

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
END;
$$ LANGUAGE plpgsql;

-- 拒绝待审核内容
CREATE OR REPLACE FUNCTION reject_pending_content(
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
        manual_review_status = 'rejected',
        manual_reviewer_id = p_reviewer_id,
        manual_review_note = p_note,
        manual_reviewed_at = NOW()
    WHERE id = p_log_id;

    -- 根据内容类型更新相应的表
    IF v_content_type = 'review' THEN
        UPDATE reviews
        SET status = 'rejected', moderation_status = 'rejected'
        WHERE id = v_content_id;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql;

-- ================================================
-- 9. 创建统计视图
-- ================================================
CREATE OR REPLACE VIEW moderation_statistics AS
SELECT
    content_type,
    COUNT(*) AS total_reviews,
    SUM(CASE WHEN is_approved THEN 1 ELSE 0 END) AS auto_approved,
    SUM(CASE WHEN NOT is_approved THEN 1 ELSE 0 END) AS auto_rejected,
    SUM(CASE WHEN requires_manual_review THEN 1 ELSE 0 END) AS manual_review_required,
    SUM(CASE WHEN manual_review_status = 'approved' THEN 1 ELSE 0 END) AS manual_approved,
    SUM(CASE WHEN manual_review_status = 'rejected' THEN 1 ELSE 0 END) AS manual_rejected,
    SUM(CASE WHEN manual_review_status = 'pending' THEN 1 ELSE 0 END) AS pending_review
FROM moderation_logs
GROUP BY content_type;

-- ================================================
-- 完成
-- ================================================
COMMENT ON TABLE sensitive_words IS '敏感词库表';
COMMENT ON TABLE moderation_logs IS '内容审核日志表';
COMMENT ON VIEW pending_manual_reviews IS '待人工审核内容视图';
COMMENT ON VIEW moderation_statistics IS '审核统计视图';
