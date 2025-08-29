-- =====================================================
-- 订单生成流程数据库迁移 - 主执行脚本
-- 执行环境: Supabase PostgreSQL
-- 创建日期: 2025-01-08
-- 版本: v1.0
-- 说明: 按顺序执行所有数据库迁移脚本
-- =====================================================

-- 开始事务
BEGIN;

-- 记录开始时间
DO $$
BEGIN
    RAISE NOTICE '🚀 开始执行订单生成流程数据库迁移...';
    RAISE NOTICE '⏰ 开始时间: %', NOW();
END $$;

-- =====================================================
-- 第一步: 创建购物车相关表
-- =====================================================
\echo '📦 第一步: 创建购物车相关表结构...'

-- 执行购物车表创建脚本
\i 01_cart_tables_creation.sql

RAISE NOTICE '✅ 购物车表创建完成';

-- =====================================================
-- 第二步: 扩展订单表
-- =====================================================
\echo '📋 第二步: 扩展订单表支持多种来源...'

-- 执行订单表扩展脚本
\i 02_order_tables_extension.sql

RAISE NOTICE '✅ 订单表扩展完成';

-- =====================================================
-- 第三步: 创建议价记录表
-- =====================================================
\echo '💬 第三步: 创建议价记录表...'

-- 执行议价表创建脚本
\i 03_negotiation_tables_creation.sql

RAISE NOTICE '✅ 议价记录表创建完成';

-- =====================================================
-- 第四步: 性能优化和数据验证
-- =====================================================
\echo '⚡ 第四步: 性能优化和数据验证...'

-- 更新统计信息
ANALYZE public.unified_carts;
ANALYZE public.cart_items;
ANALYZE public.cart_operation_logs;
ANALYZE public.orders;
ANALYZE public.order_items;
ANALYZE public.batch_orders;
ANALYZE public.order_status_history;
ANALYZE public.negotiation_records;
ANALYZE public.negotiation_messages;
ANALYZE public.negotiation_templates;

-- 创建额外的复合索引
CREATE INDEX IF NOT EXISTS idx_cart_items_service_scheduled_time ON public.cart_items(service_id, scheduled_start_time) 
WHERE scheduled_start_time IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_orders_user_source_status ON public.orders(user_id, order_source, status);

CREATE INDEX IF NOT EXISTS idx_negotiation_provider_status_created ON public.negotiation_records(provider_id, status, created_at);

-- 验证关键约束
DO $$
DECLARE
    error_count INTEGER := 0;
BEGIN
    -- 检查是否有违反约束的数据
    
    -- 检查购物车项目的价格是否都 >= 0
    SELECT COUNT(*) INTO error_count FROM public.cart_items WHERE unit_price < 0;
    IF error_count > 0 THEN
        RAISE WARNING '⚠️ 发现 % 个购物车项目价格为负数', error_count;
    END IF;
    
    -- 检查议价记录的状态是否有效
    SELECT COUNT(*) INTO error_count FROM public.negotiation_records 
    WHERE status NOT IN ('pending', 'quoted', 'negotiating', 'accepted', 'rejected', 'expired');
    IF error_count > 0 THEN
        RAISE WARNING '⚠️ 发现 % 个议价记录状态无效', error_count;
    END IF;
    
    RAISE NOTICE '✅ 数据验证完成，无严重错误';
END $$;

RAISE NOTICE '✅ 性能优化完成';

-- =====================================================
-- 第五步: 创建监控视图和函数
-- =====================================================
\echo '📊 第五步: 创建监控视图和函数...'

-- 创建购物车使用统计视图
CREATE OR REPLACE VIEW cart_usage_daily AS
SELECT 
    DATE(created_at) as date,
    cart_type,
    COUNT(*) as carts_created,
    COUNT(CASE WHEN status = 'converted' THEN 1 END) as carts_converted,
    ROUND(
        COUNT(CASE WHEN status = 'converted' THEN 1 END)::NUMERIC / 
        NULLIF(COUNT(*), 0) * 100, 2
    ) as conversion_rate_percent,
    AVG(
        EXTRACT(EPOCH FROM (updated_at - created_at)) / 3600
    ) as avg_lifetime_hours
FROM public.unified_carts
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(created_at), cart_type
ORDER BY date DESC, cart_type;

-- 创建订单来源统计视图  
CREATE OR REPLACE VIEW order_source_statistics AS
SELECT 
    DATE(created_at) as date,
    order_source,
    COUNT(*) as order_count,
    SUM(total_price) as total_revenue,
    AVG(total_price) as avg_order_value,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_orders
FROM public.orders
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(created_at), order_source
ORDER BY date DESC, order_source;

-- 创建议价转换漏斗视图
CREATE OR REPLACE VIEW negotiation_funnel AS
WITH funnel_data AS (
    SELECT
        COUNT(*) as total_negotiations,
        COUNT(CASE WHEN status = 'quoted' THEN 1 END) as quoted_count,
        COUNT(CASE WHEN status = 'accepted' THEN 1 END) as accepted_count,
        COUNT(CASE WHEN converted_to_order_id IS NOT NULL THEN 1 END) as converted_count
    FROM public.negotiation_records
    WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
)
SELECT 
    'Step 1: 提交询价' as step,
    total_negotiations as count,
    100.0 as percentage
FROM funnel_data
UNION ALL
SELECT 
    'Step 2: 收到报价',
    quoted_count,
    ROUND(quoted_count::NUMERIC / NULLIF(total_negotiations, 0) * 100, 2)
FROM funnel_data
UNION ALL
SELECT 
    'Step 3: 接受报价',
    accepted_count,
    ROUND(accepted_count::NUMERIC / NULLIF(total_negotiations, 0) * 100, 2)
FROM funnel_data
UNION ALL
SELECT 
    'Step 4: 转换为订单',
    converted_count,
    ROUND(converted_count::NUMERIC / NULLIF(total_negotiations, 0) * 100, 2)
FROM funnel_data;

-- 创建系统健康检查函数
CREATE OR REPLACE FUNCTION system_health_check()
RETURNS TABLE (
    check_name text,
    status text,
    message text,
    details jsonb
) AS $$
BEGIN
    -- 检查购物车表
    RETURN QUERY
    SELECT 
        'cart_tables_status' as check_name,
        CASE WHEN COUNT(*) = 3 THEN 'healthy' ELSE 'warning' END as status,
        CASE WHEN COUNT(*) = 3 THEN 'All cart tables exist' ELSE 'Some cart tables missing' END as message,
        jsonb_build_object('expected', 3, 'actual', COUNT(*)) as details
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name IN ('unified_carts', 'cart_items', 'cart_operation_logs');
    
    -- 检查订单表扩展
    RETURN QUERY
    SELECT 
        'order_tables_extension' as check_name,
        CASE WHEN COUNT(*) >= 7 THEN 'healthy' ELSE 'warning' END as status,
        CASE WHEN COUNT(*) >= 7 THEN 'Order tables properly extended' ELSE 'Order table extensions incomplete' END as message,
        jsonb_build_object('new_columns_found', COUNT(*)) as details
    FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'orders'
    AND column_name IN ('order_source', 'source_cart_id', 'source_quote_id', 'batch_order_id', 'delivery_method', 'estimated_completion_time', 'cart_snapshot');
    
    -- 检查议价表
    RETURN QUERY
    SELECT 
        'negotiation_tables_status' as check_name,
        CASE WHEN COUNT(*) = 3 THEN 'healthy' ELSE 'warning' END as status,
        CASE WHEN COUNT(*) = 3 THEN 'All negotiation tables exist' ELSE 'Some negotiation tables missing' END as message,
        jsonb_build_object('expected', 3, 'actual', COUNT(*)) as details
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name IN ('negotiation_records', 'negotiation_messages', 'negotiation_templates');
    
    -- 检查索引数量
    RETURN QUERY
    SELECT 
        'indexes_status' as check_name,
        CASE WHEN COUNT(*) >= 30 THEN 'healthy' ELSE 'warning' END as status,
        CASE WHEN COUNT(*) >= 30 THEN 'Sufficient indexes created' ELSE 'Some indexes may be missing' END as message,
        jsonb_build_object('total_indexes', COUNT(*)) as details
    FROM pg_indexes 
    WHERE schemaname = 'public' 
    AND (indexname LIKE 'idx_cart%' OR indexname LIKE 'idx_unified_carts%' OR indexname LIKE 'idx_order%' OR indexname LIKE 'idx_negotiation%');
    
END;
$$ language 'plpgsql';

RAISE NOTICE '✅ 监控视图和函数创建完成';

-- =====================================================
-- 第六步: 最终验证和总结
-- =====================================================
\echo '🔍 第六步: 最终验证和总结...'

-- 执行系统健康检查
DO $$
DECLARE
    health_record RECORD;
    total_issues INTEGER := 0;
BEGIN
    RAISE NOTICE '🏥 执行系统健康检查...';
    
    FOR health_record IN 
        SELECT * FROM system_health_check()
    LOOP
        IF health_record.status != 'healthy' THEN
            total_issues := total_issues + 1;
            RAISE WARNING '⚠️ %: %', health_record.check_name, health_record.message;
        ELSE
            RAISE NOTICE '✅ %: %', health_record.check_name, health_record.message;
        END IF;
    END LOOP;
    
    IF total_issues = 0 THEN
        RAISE NOTICE '🎉 系统健康检查通过，所有组件正常！';
    ELSE
        RAISE WARNING '⚠️ 发现 % 个问题，请检查上述警告', total_issues;
    END IF;
END $$;

-- 显示迁移总结
DO $$
DECLARE
    cart_tables_count INTEGER;
    order_extensions_count INTEGER;
    negotiation_tables_count INTEGER;
    total_indexes_count INTEGER;
    total_policies_count INTEGER;
BEGIN
    -- 统计创建的对象数量
    SELECT COUNT(*) INTO cart_tables_count 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name IN ('unified_carts', 'cart_items', 'cart_operation_logs', 'batch_orders', 'order_status_history');
    
    SELECT COUNT(*) INTO order_extensions_count
    FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name IN ('orders', 'order_items')
    AND column_name IN ('order_source', 'source_cart_id', 'item_type', 'customizations_snapshot', 'scheduled_start_time');
    
    SELECT COUNT(*) INTO negotiation_tables_count 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name IN ('negotiation_records', 'negotiation_messages', 'negotiation_templates');
    
    SELECT COUNT(*) INTO total_indexes_count 
    FROM pg_indexes 
    WHERE schemaname = 'public' 
    AND (indexname LIKE 'idx_cart%' OR indexname LIKE 'idx_unified_carts%' OR indexname LIKE 'idx_order%' OR indexname LIKE 'idx_negotiation%');
    
    SELECT COUNT(*) INTO total_policies_count 
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename IN ('unified_carts', 'cart_items', 'cart_operation_logs', 'batch_orders', 'order_status_history', 'negotiation_records', 'negotiation_messages', 'negotiation_templates');
    
    RAISE NOTICE '📊 === 迁移总结 ===';
    RAISE NOTICE '📦 购物车相关表: % 个', cart_tables_count;
    RAISE NOTICE '📋 订单表扩展字段: % 个', order_extensions_count;
    RAISE NOTICE '💬 议价相关表: % 个', negotiation_tables_count;
    RAISE NOTICE '⚡ 新增索引: % 个', total_indexes_count;
    RAISE NOTICE '🔒 RLS策略: % 个', total_policies_count;
    RAISE NOTICE '✅ 数据库迁移完成！';
    RAISE NOTICE '⏰ 完成时间: %', NOW();
END $$;

-- 提交事务
COMMIT;

RAISE NOTICE '🎉 订单生成流程数据库迁移成功完成！';
RAISE NOTICE '📚 接下来请参考实施指南继续进行Phase 2的开发工作';
RAISE NOTICE '🔗 文档路径: docs/ServiceDetail/Order_Generation_Implementation_Guide.md';
