-- ================================================
-- 退款系统数据库架构
-- ================================================
-- 用途：支持完整的退款申请、审核、处理流程
-- 创建日期：2025-12-28
-- ================================================

-- ================================================
-- 1. 退款表（优化版）
-- ================================================
CREATE TABLE IF NOT EXISTS refunds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    provider_id UUID NOT NULL REFERENCES users(id),

    -- 退款信息
    refund_type VARCHAR(20) NOT NULL DEFAULT 'full', -- full（全额）, partial（部分）
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    original_amount DECIMAL(10, 2) NOT NULL,

    -- 退款原因
    reason TEXT NOT NULL,
    reason_type VARCHAR(50), -- quality_issue, unsatisfied, order_mistake, cancellation, service_delay, other
    description TEXT,
    images TEXT[], -- 证明图片URL数组

    -- 审核信息
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    -- pending（待审核）, approved（已批准）, rejected（已拒绝）,
    -- processing（处理中）, completed（已完成）, failed（失败）
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    review_note TEXT,

    -- Stripe退款信息
    stripe_refund_id VARCHAR(255),
    provider_response JSONB, -- Stripe API响应

    -- 错误信息
    error_message TEXT,

    -- 时间戳
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processing_started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    failed_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- 约束
    CONSTRAINT refund_type_check CHECK (refund_type IN ('full', 'partial')),
    CONSTRAINT refund_status_check CHECK (
        status IN ('pending', 'approved', 'rejected', 'processing', 'completed', 'failed')
    ),
    CONSTRAINT refund_amount_check CHECK (amount <= original_amount)
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_refunds_order_id ON refunds(order_id);
CREATE INDEX IF NOT EXISTS idx_refunds_user_id ON refunds(user_id);
CREATE INDEX IF NOT EXISTS idx_refunds_provider_id ON refunds(provider_id);
CREATE INDEX IF NOT EXISTS idx_refunds_status ON refunds(status);
CREATE INDEX IF NOT EXISTS idx_refunds_created_at ON refunds(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_refunds_stripe_refund_id ON refunds(stripe_refund_id);

-- ================================================
-- 2. 退款日志表
-- ================================================
CREATE TABLE IF NOT EXISTS refund_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    refund_id UUID NOT NULL REFERENCES refunds(id) ON DELETE CASCADE,
    event VARCHAR(50) NOT NULL,
    -- refund_applied, refund_approved, refund_rejected,
    -- refund_processing, refund_completed, refund_failed
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_refund_logs_refund_id ON refund_logs(refund_id);
CREATE INDEX IF NOT EXISTS idx_refund_logs_event ON refund_logs(event);
CREATE INDEX IF NOT EXISTS idx_refund_logs_created_at ON refund_logs(created_at DESC);

-- ================================================
-- 3. 为 orders 表添加退款相关字段
-- ================================================
DO $$
BEGIN
    -- 添加退款时间字段
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'orders' AND column_name = 'refunded_at'
    ) THEN
        ALTER TABLE orders ADD COLUMN refunded_at TIMESTAMP WITH TIME ZONE;
    END IF;

    -- 添加支付意图ID字段（如果不存在）
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'orders' AND column_name = 'payment_intent_id'
    ) THEN
        ALTER TABLE orders ADD COLUMN payment_intent_id VARCHAR(255);
    END IF;
END $$;

-- ================================================
-- 4. 创建触发器：自动更新 updated_at
-- ================================================
CREATE OR REPLACE FUNCTION update_refunds_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_refunds_updated_at ON refunds;
CREATE TRIGGER trigger_update_refunds_updated_at
    BEFORE UPDATE ON refunds
    FOR EACH ROW
    EXECUTE FUNCTION update_refunds_updated_at();

-- ================================================
-- 5. 创建视图：待审核退款
-- ================================================
CREATE OR REPLACE VIEW pending_refunds AS
SELECT
    r.id,
    r.order_id,
    r.user_id,
    r.provider_id,
    r.refund_type,
    r.amount,
    r.original_amount,
    r.reason,
    r.reason_type,
    r.description,
    r.status,
    r.created_at,
    o.order_number,
    o.total_price AS order_total,
    u.email AS user_email,
    p.email AS provider_email
FROM refunds r
INNER JOIN orders o ON r.order_id = o.id
INNER JOIN users u ON r.user_id = u.id
INNER JOIN users p ON r.provider_id = p.id
WHERE r.status = 'pending'
ORDER BY r.created_at ASC;

-- ================================================
-- 6. 创建视图：退款统计
-- ================================================
CREATE OR REPLACE VIEW refund_statistics_by_provider AS
SELECT
    provider_id,
    COUNT(*) AS total_refunds,
    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending_count,
    SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) AS approved_count,
    SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) AS rejected_count,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed_count,
    SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) AS failed_count,
    SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END) AS total_refunded_amount,
    AVG(CASE WHEN status = 'completed' THEN amount ELSE NULL END) AS avg_refund_amount,
    AVG(
        CASE WHEN status = 'completed' AND completed_at IS NOT NULL
        THEN EXTRACT(EPOCH FROM (completed_at - created_at)) / 3600
        ELSE NULL END
    ) AS avg_processing_hours
FROM refunds
GROUP BY provider_id;

CREATE OR REPLACE VIEW refund_statistics_global AS
SELECT
    COUNT(*) AS total_refunds,
    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending_count,
    SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) AS approved_count,
    SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) AS rejected_count,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed_count,
    SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) AS failed_count,
    SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END) AS total_refunded_amount,
    AVG(CASE WHEN status = 'completed' THEN amount ELSE NULL END) AS avg_refund_amount,
    ROUND(
        (SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END)::DECIMAL /
         NULLIF(COUNT(*), 0) * 100), 2
    ) AS completion_rate_percentage
FROM refunds;

-- ================================================
-- 7. 创建RLS（行级安全）策略
-- ================================================

-- 启用RLS
ALTER TABLE refunds ENABLE ROW LEVEL SECURITY;
ALTER TABLE refund_logs ENABLE ROW LEVEL SECURITY;

-- refunds 策略：用户可以查看自己的退款
DROP POLICY IF EXISTS "用户可以查看自己的退款" ON refunds;
CREATE POLICY "用户可以查看自己的退款" ON refunds
    FOR SELECT
    USING (user_id = auth.uid());

-- refunds 策略：服务商可以查看相关的退款
DROP POLICY IF EXISTS "服务商可以查看相关的退款" ON refunds;
CREATE POLICY "服务商可以查看相关的退款" ON refunds
    FOR SELECT
    USING (provider_id = auth.uid());

-- refunds 策略：管理员可以查看所有退款
DROP POLICY IF EXISTS "管理员可以查看所有退款" ON refunds;
CREATE POLICY "管理员可以查看所有退款" ON refunds
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid()
            AND role IN ('admin', 'super_admin')
        )
    );

-- refunds 策略：用户可以申请退款
DROP POLICY IF EXISTS "用户可以申请退款" ON refunds;
CREATE POLICY "用户可以申请退款" ON refunds
    FOR INSERT
    WITH CHECK (user_id = auth.uid());

-- refunds 策略：服务商和管理员可以更新退款状态
DROP POLICY IF EXISTS "服务商和管理员可以更新退款" ON refunds;
CREATE POLICY "服务商和管理员可以更新退款" ON refunds
    FOR UPDATE
    USING (
        provider_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid()
            AND role IN ('admin', 'super_admin')
        )
    );

-- refund_logs 策略：系统可以插入日志
DROP POLICY IF EXISTS "系统可以插入退款日志" ON refund_logs;
CREATE POLICY "系统可以插入退款日志" ON refund_logs
    FOR INSERT
    WITH CHECK (true);

-- refund_logs 策略：相关用户可以查看日志
DROP POLICY IF EXISTS "相关用户可以查看退款日志" ON refund_logs;
CREATE POLICY "相关用户可以查看退款日志" ON refund_logs
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM refunds
            WHERE id = refund_logs.refund_id
            AND (user_id = auth.uid() OR provider_id = auth.uid())
        ) OR
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid()
            AND role IN ('admin', 'super_admin')
        )
    );

-- ================================================
-- 8. 创建管理函数
-- ================================================

-- 自动批准符合条件的退款
CREATE OR REPLACE FUNCTION auto_approve_eligible_refunds()
RETURNS INTEGER AS $$
DECLARE
    approved_count INTEGER := 0;
    refund_record RECORD;
BEGIN
    -- 查找符合自动批准条件的退款
    -- 条件：金额 < $50, 订单完成时间 < 7天
    FOR refund_record IN
        SELECT r.id
        FROM refunds r
        INNER JOIN orders o ON r.order_id = o.id
        WHERE r.status = 'pending'
          AND r.amount < 50
          AND o.created_at > NOW() - INTERVAL '7 days'
    LOOP
        -- 批准退款
        UPDATE refunds
        SET
            status = 'approved',
            reviewed_by = NULL, -- 系统自动批准
            reviewed_at = NOW(),
            review_note = 'Automatically approved (amount < $50, within 7 days)'
        WHERE id = refund_record.id;

        -- 记录日志
        INSERT INTO refund_logs (refund_id, event, details)
        VALUES (
            refund_record.id,
            'refund_auto_approved',
            '{"reason": "automatic_approval"}'::JSONB
        );

        approved_count := approved_count + 1;
    END LOOP;

    RETURN approved_count;
END;
$$ LANGUAGE plpgsql;

-- 获取退款率（按服务商）
CREATE OR REPLACE FUNCTION get_refund_rate(p_provider_id UUID, p_days INTEGER DEFAULT 30)
RETURNS DECIMAL AS $$
DECLARE
    total_orders INTEGER;
    refunded_orders INTEGER;
    refund_rate DECIMAL;
BEGIN
    -- 统计总订单数
    SELECT COUNT(*)
    INTO total_orders
    FROM orders
    WHERE provider_id = p_provider_id
      AND created_at > NOW() - INTERVAL '1 day' * p_days;

    -- 统计退款订单数
    SELECT COUNT(DISTINCT order_id)
    INTO refunded_orders
    FROM refunds
    WHERE provider_id = p_provider_id
      AND status = 'completed'
      AND created_at > NOW() - INTERVAL '1 day' * p_days;

    -- 计算退款率
    IF total_orders > 0 THEN
        refund_rate := (refunded_orders::DECIMAL / total_orders) * 100;
    ELSE
        refund_rate := 0;
    END IF;

    RETURN ROUND(refund_rate, 2);
END;
$$ LANGUAGE plpgsql;

-- 清理过期的失败退款记录（超过90天）
CREATE OR REPLACE FUNCTION cleanup_old_failed_refunds()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM refunds
    WHERE status = 'failed'
      AND failed_at < NOW() - INTERVAL '90 days';

    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- ================================================
-- 9. 创建通知触发器
-- ================================================

-- 退款状态变更通知函数
CREATE OR REPLACE FUNCTION notify_refund_status_change()
RETURNS TRIGGER AS $$
BEGIN
    -- 如果状态发生变化
    IF (TG_OP = 'UPDATE' AND OLD.status != NEW.status) THEN
        -- 插入通知记录（需要notifications表）
        -- TODO: 集成通知系统

        -- 记录日志
        INSERT INTO refund_logs (refund_id, event, details)
        VALUES (
            NEW.id,
            'status_changed',
            jsonb_build_object(
                'old_status', OLD.status,
                'new_status', NEW.status
            )
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_notify_refund_status_change ON refunds;
CREATE TRIGGER trigger_notify_refund_status_change
    AFTER UPDATE ON refunds
    FOR EACH ROW
    EXECUTE FUNCTION notify_refund_status_change();

-- ================================================
-- 10. 测试数据（仅用于开发环境）
-- ================================================

-- 注意：生产环境中应该注释掉以下部分

-- 示例：插入测试退款数据
-- INSERT INTO refunds (order_id, user_id, provider_id, refund_type, amount, original_amount, reason, reason_type)
-- SELECT
--     o.id,
--     o.user_id,
--     o.provider_id,
--     'full',
--     o.total_price,
--     o.total_price,
--     '服务质量不符合预期',
--     'quality_issue'
-- FROM orders o
-- WHERE o.order_status = 'completed'
-- LIMIT 5;

-- ================================================
-- 完成
-- ================================================
COMMENT ON TABLE refunds IS '退款申请表';
COMMENT ON TABLE refund_logs IS '退款日志表';
COMMENT ON VIEW pending_refunds IS '待审核退款视图';
COMMENT ON VIEW refund_statistics_by_provider IS '按服务商统计退款视图';
COMMENT ON VIEW refund_statistics_global IS '全局退款统计视图';
COMMENT ON FUNCTION auto_approve_eligible_refunds() IS '自动批准符合条件的退款';
COMMENT ON FUNCTION get_refund_rate(UUID, INTEGER) IS '获取服务商的退款率';
COMMENT ON FUNCTION cleanup_old_failed_refunds() IS '清理过期的失败退款记录';
