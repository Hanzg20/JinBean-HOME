-- =====================================================
-- JinBean Platform - 数据库状态检查脚本
-- 版本: v3.1.1
-- 创建日期: 2025-09-10
-- 描述: 检查数据库状态，诊断Reviews功能问题
-- =====================================================

-- =====================================================
-- 1. 检查基础表数据
-- =====================================================

DO $$
DECLARE
    service_count INTEGER;
    order_count INTEGER;
    user_count INTEGER;
    provider_count INTEGER;
    review_count INTEGER;
BEGIN
    RAISE NOTICE '🔍 检查数据库基础数据...';
    
    -- 检查服务
    SELECT COUNT(*) INTO service_count FROM public.services;
    RAISE NOTICE '📊 服务数量: %', service_count;
    
    -- 检查订单
    SELECT COUNT(*) INTO order_count FROM public.orders;
    RAISE NOTICE '📊 订单数量: %', order_count;
    
    -- 检查用户
    SELECT COUNT(*) INTO user_count FROM public.user_profiles;
    RAISE NOTICE '📊 用户数量: %', user_count;
    
    -- 检查服务商
    SELECT COUNT(*) INTO provider_count FROM public.provider_profiles;
    RAISE NOTICE '📊 服务商数量: %', provider_count;
    
    -- 检查评价
    SELECT COUNT(*) INTO review_count FROM public.reviews;
    RAISE NOTICE '📊 评价数量: %', review_count;
    
    RAISE NOTICE '';
    
    IF service_count = 0 THEN
        RAISE WARNING '⚠️ 没有服务数据';
    END IF;
    
    IF order_count = 0 THEN
        RAISE WARNING '⚠️ 没有订单数据 - 这是Reviews功能无法工作的主要原因';
    END IF;
    
    IF user_count = 0 THEN
        RAISE WARNING '⚠️ 没有用户数据';
    END IF;
    
    IF provider_count = 0 THEN
        RAISE WARNING '⚠️ 没有服务商数据';
    END IF;
    
    IF review_count = 0 THEN
        RAISE NOTICE 'ℹ️ 没有评价数据 - 这是正常的（新功能）';
    END IF;
    
END $$;

-- =====================================================
-- 2. 检查最新订单详情
-- =====================================================

DO $$
DECLARE
    latest_order RECORD;
BEGIN
    RAISE NOTICE '🔍 检查最新订单详情...';
    
    SELECT o.id, o.user_id, o.provider_id, o.service_id, o.created_at,
           s.title as service_title,
           up.display_name as user_name,
           pp.business_name as provider_name
    INTO latest_order
    FROM public.orders o
    LEFT JOIN public.services s ON o.service_id = s.id
    LEFT JOIN public.user_profiles up ON o.user_id = up.id
    LEFT JOIN public.provider_profiles pp ON o.provider_id = pp.id
    ORDER BY o.created_at DESC
    LIMIT 1;
    
    IF latest_order.id IS NOT NULL THEN
        RAISE NOTICE '✅ 找到最新订单:';
        RAISE NOTICE '  - 订单ID: %', latest_order.id;
        RAISE NOTICE '  - 用户: %', COALESCE(latest_order.user_name, 'Unknown');
        RAISE NOTICE '  - 服务商: %', COALESCE(latest_order.provider_name, 'Unknown');
        RAISE NOTICE '  - 服务: %', COALESCE(latest_order.service_title, 'Unknown');
        RAISE NOTICE '  - 创建时间: %', latest_order.created_at;
    ELSE
        RAISE WARNING '⚠️ 没有找到任何订单';
    END IF;
    
END $$;

-- =====================================================
-- 3. 检查reviews表结构
-- =====================================================

DO $$
DECLARE
    table_exists BOOLEAN;
    column_count INTEGER;
BEGIN
    RAISE NOTICE '🔍 检查reviews表结构...';
    
    -- 检查表是否存在
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'reviews' AND table_schema = 'public'
    ) INTO table_exists;
    
    IF table_exists THEN
        RAISE NOTICE '✅ reviews表存在';
        
        -- 检查列数量
        SELECT COUNT(*) INTO column_count
        FROM information_schema.columns 
        WHERE table_name = 'reviews' AND table_schema = 'public';
        
        RAISE NOTICE '📊 reviews表列数量: %', column_count;
    ELSE
        RAISE EXCEPTION '❌ reviews表不存在！';
    END IF;
    
END $$;

-- =====================================================
-- 4. 尝试插入测试数据（如果有订单）
-- =====================================================

DO $$
DECLARE
    sample_order_id UUID;
    sample_reviewer_id UUID;
    sample_reviewee_id UUID;
    sample_service_id UUID;
    new_review_id UUID;
    insert_count INTEGER := 0;
BEGIN
    RAISE NOTICE '🔍 尝试插入测试评价数据...';
    
    -- 获取最新的订单信息
    SELECT id, user_id, provider_id, service_id 
    INTO sample_order_id, sample_reviewer_id, sample_reviewee_id, sample_service_id
    FROM public.orders 
    ORDER BY created_at DESC 
    LIMIT 1;
    
    IF sample_order_id IS NOT NULL AND sample_reviewer_id IS NOT NULL AND 
       sample_reviewee_id IS NOT NULL AND sample_service_id IS NOT NULL THEN
        
        RAISE NOTICE '✅ 找到订单数据，插入测试评价...';
        
        -- 插入测试评价
        BEGIN
            INSERT INTO public.reviews (
                order_id, reviewer_id, reviewee_id, service_id,
                overall_rating, quality_rating, communication_rating, 
                timeliness_rating, value_rating,
                title, content, status, is_verified
            ) VALUES (
                sample_order_id, sample_reviewer_id, sample_reviewee_id, sample_service_id,
                5, 5, 4, 5, 5,
                'Reviews功能测试', '这是一个测试评价，用于验证Reviews功能是否正常工作。', 
                'published', true
            ) RETURNING id INTO new_review_id;
            
            insert_count := insert_count + 1;
            RAISE NOTICE '✅ 测试评价插入成功，ID: %', new_review_id;
            
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE '❌ 插入测试评价失败: %', SQLERRM;
        END;
        
        RAISE NOTICE '📊 成功插入 % 条测试评价', insert_count;
        
    ELSE
        RAISE WARNING '⚠️ 没有找到完整的订单数据，无法插入测试评价';
        RAISE NOTICE '需要的数据:';
        IF sample_order_id IS NULL THEN RAISE NOTICE '  - 订单ID'; END IF;
        IF sample_reviewer_id IS NULL THEN RAISE NOTICE '  - 用户ID'; END IF;
        IF sample_reviewee_id IS NULL THEN RAISE NOTICE '  - 服务商ID'; END IF;
        IF sample_service_id IS NULL THEN RAISE NOTICE '  - 服务ID'; END IF;
    END IF;
    
END $$;

-- =====================================================
-- 5. 最终状态报告
-- =====================================================

DO $$
DECLARE
    final_review_count INTEGER;
    published_count INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '📊 =====================================================';
    RAISE NOTICE '📊 数据库状态检查报告';
    RAISE NOTICE '📊 =====================================================';
    
    -- 检查最终评价数
    SELECT COUNT(*) INTO final_review_count FROM public.reviews;
    SELECT COUNT(*) INTO published_count FROM public.reviews WHERE status = 'published';
    
    RAISE NOTICE '📊 总评价数量: %', final_review_count;
    RAISE NOTICE '📊 已发布评价数量: %', published_count;
    
    RAISE NOTICE '📊 =====================================================';
    
    IF final_review_count > 0 THEN
        RAISE NOTICE '✅ Reviews功能应该可以正常工作！';
        RAISE NOTICE '📋 请刷新应用并查看Reviews标签页';
    ELSE
        RAISE NOTICE '⚠️ Reviews功能可能无法正常工作';
        RAISE NOTICE '📋 请检查是否有订单数据';
    END IF;
    
END $$;

-- =====================================================
-- 检查完成
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🎉 数据库状态检查完成！';
    RAISE NOTICE '📋 如果看到测试评价，说明Reviews功能正常工作';
    RAISE NOTICE '🔄 请刷新应用查看结果';
END $$;






