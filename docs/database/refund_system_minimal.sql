-- ================================================
-- 退款系统数据库架构（最小安全版本）
-- ================================================
-- 用途：支持完整的退款申请、审核、处理流程
-- 创建日期：2025-12-28
-- 注意：此版本不依赖orders表，可以独立运行
-- ================================================

-- ================================================
-- 1. 退款表（独立版本 - 无外键约束）
-- ================================================
CREATE TABLE IF NOT EXISTS refunds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL,  -- 引用订单ID，但不使用外键约束
    user_id UUID NOT NULL,
    provider_id UUID NOT NULL,

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
    reviewed_by UUID,
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
    refund_id UUID NOT NULL,  -- 引用退款ID，但不使用外键约束
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
-- 3. 创建触发器：自动更新 updated_at
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
-- 4. 创建视图：待审核退款（简化版）
-- ================================================
CREATE OR REPLACE VIEW pending_refunds_simple AS
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
    r.created_at
FROM refunds r
WHERE r.status = 'pending'
ORDER BY r.created_at ASC;

-- ================================================
-- 5. 创建视图：退款统计（简化版）
-- ================================================
CREATE OR REPLACE VIEW refund_statistics_simple AS
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
-- 6. 创建RLS（行级安全）策略 - 基础版本
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

-- refunds 策略：用户可以申请退款
DROP POLICY IF EXISTS "用户可以申请退款" ON refunds;
CREATE POLICY "用户可以申请退款" ON refunds
    FOR INSERT
    WITH CHECK (user_id = auth.uid());

-- refunds 策略：服务商可以更新退款状态
DROP POLICY IF EXISTS "服务商可以更新退款" ON refunds;
CREATE POLICY "服务商可以更新退款" ON refunds
    FOR UPDATE
    USING (provider_id = auth.uid());

-- refunds 策略：服务角色可以全部操作
DROP POLICY IF EXISTS "服务角色可以操作所有退款" ON refunds;
CREATE POLICY "服务角色可以操作所有退款" ON refunds
    FOR ALL
    USING (auth.role() = 'service_role');

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
        )
    );

-- refund_logs 策略：服务角色可以查看所有日志
DROP POLICY IF EXISTS "服务角色可以查看所有退款日志" ON refund_logs;
CREATE POLICY "服务角色可以查看所有退款日志" ON refund_logs
    FOR SELECT
    USING (auth.role() = 'service_role');

-- ================================================
-- 7. 创建管理函数（简化版）
-- ================================================

-- 获取退款率（简化版 - 不依赖orders表）
CREATE OR REPLACE FUNCTION get_provider_refund_stats(p_provider_id UUID)
RETURNS TABLE(
    total_refunds BIGINT,
    completed_refunds BIGINT,
    total_amount DECIMAL,
    avg_processing_time_hours DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*) as total_refunds,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_refunds,
        SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END) as total_amount,
        AVG(
            CASE WHEN status = 'completed' AND completed_at IS NOT NULL
            THEN EXTRACT(EPOCH FROM (completed_at - created_at)) / 3600
            ELSE NULL END
        ) as avg_processing_time_hours
    FROM refunds
    WHERE provider_id = p_provider_id;
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
-- 8. 创建通知触发器（简化版）
-- ================================================

-- 退款状态变更日志函数
CREATE OR REPLACE FUNCTION log_refund_status_change()
RETURNS TRIGGER AS $$
BEGIN
    -- 如果状态发生变化，记录日志
    IF (TG_OP = 'UPDATE' AND OLD.status != NEW.status) THEN
        INSERT INTO refund_logs (refund_id, event, details)
        VALUES (
            NEW.id,
            'status_changed',
            jsonb_build_object(
                'old_status', OLD.status,
                'new_status', NEW.status,
                'changed_at', NOW()
            )
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_log_refund_status_change ON refunds;
CREATE TRIGGER trigger_log_refund_status_change
    AFTER UPDATE ON refunds
    FOR EACH ROW
    EXECUTE FUNCTION log_refund_status_change();

-- ================================================
-- 完成
-- ================================================
COMMENT ON TABLE refunds IS '退款申请表（独立版本）';
COMMENT ON TABLE refund_logs IS '退款日志表';
COMMENT ON VIEW pending_refunds_simple IS '待审核退款视图（简化版）';
COMMENT ON VIEW refund_statistics_simple IS '全局退款统计视图（简化版）';
COMMENT ON FUNCTION get_provider_refund_stats(UUID) IS '获取服务商的退款统计';
COMMENT ON FUNCTION cleanup_old_failed_refunds() IS '清理过期的失败退款记录';

-- 输出成功消息
DO $$
BEGIN
    RAISE NOTICE '退款系统数据库架构创建成功（最小版本）！';
    RAISE NOTICE '已创建表：refunds, refund_logs';
    RAISE NOTICE '已创建视图：pending_refunds_simple, refund_statistics_simple';
    RAISE NOTICE '已创建函数：get_provider_refund_stats, cleanup_old_failed_refunds';
    RAISE NOTICE '';
    RAISE NOTICE '注意：此版本不使用外键约束，不依赖orders表';
    RAISE NOTICE '如果您的数据库有完整的orders表，可以稍后添加外键约束';
END $$;
