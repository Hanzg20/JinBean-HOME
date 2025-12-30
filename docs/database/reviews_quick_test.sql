-- =====================================================
-- JinBean Platform - Reviews 功能快速测试脚本
-- 版本: v3.1.1
-- 创建日期: 2025-09-10
-- 描述: 快速测试Reviews功能是否正常工作
-- =====================================================

-- =====================================================
-- 1. 检查reviews表是否存在
-- =====================================================

DO $$
DECLARE
    table_exists BOOLEAN;
    column_count INTEGER;
BEGIN
    RAISE NOTICE '🔍 检查reviews表状态...';
    
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
-- 2. 检查基础数据
-- =====================================================

DO $$
DECLARE
    service_count INTEGER;
    order_count INTEGER;
    user_count INTEGER;
    provider_count INTEGER;
BEGIN
    RAISE NOTICE '🔍 检查基础数据...';
    
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
    
    IF service_count = 0 THEN
        RAISE WARNING '⚠️ 没有服务数据';
    END IF;
    
    IF order_count = 0 THEN
        RAISE WARNING '⚠️ 没有订单数据';
    END IF;
    
    IF user_count = 0 THEN
        RAISE WARNING '⚠️ 没有用户数据';
    END IF;
    
    IF provider_count = 0 THEN
        RAISE WARNING '⚠️ 没有服务商数据';
    END IF;
    
END $$;

-- =====================================================
-- 3. 检查现有评价数据
-- =====================================================

DO $$
DECLARE
    review_count INTEGER;
    published_count INTEGER;
BEGIN
    RAISE NOTICE '🔍 检查现有评价数据...';
    
    -- 检查总评价数
    SELECT COUNT(*) INTO review_count FROM public.reviews;
    RAISE NOTICE '📊 总评价数量: %', review_count;
    
    -- 检查已发布评价数
    SELECT COUNT(*) INTO published_count FROM public.reviews WHERE status = 'published';
    RAISE NOTICE '📊 已发布评价数量: %', published_count;
    
    IF review_count = 0 THEN
        RAISE NOTICE '📝 没有评价数据，这是正常的（新功能）';
    ELSE
        RAISE NOTICE '✅ 已有评价数据';
    END IF;
    
END $$;

-- =====================================================
-- 4. 插入一条测试评价（如果有基础数据）
-- =====================================================

DO $$
DECLARE
    sample_service_id UUID;
    sample_order_id UUID;
    sample_reviewer_id UUID;
    sample_reviewee_id UUID;
    new_review_id UUID;
BEGIN
    RAISE NOTICE '🔍 尝试插入测试评价...';
    
    -- 获取第一个服务
    SELECT id INTO sample_service_id FROM public.services LIMIT 1;
    
    -- 获取第一个订单
    SELECT id INTO sample_order_id FROM public.orders LIMIT 1;
    
    -- 获取第一个用户
    SELECT id INTO sample_reviewer_id FROM public.user_profiles LIMIT 1;
    
    -- 获取第一个服务商
    SELECT id INTO sample_reviewee_id FROM public.provider_profiles LIMIT 1;
    
    IF sample_service_id IS NOT NULL AND sample_order_id IS NOT NULL AND 
       sample_reviewer_id IS NOT NULL AND sample_reviewee_id IS NOT NULL THEN
        
        RAISE NOTICE '✅ 找到基础数据，插入测试评价...';
        
        -- 插入测试评价
        INSERT INTO public.reviews (
            order_id, reviewer_id, reviewee_id, service_id,
            overall_rating, quality_rating, communication_rating, 
            timeliness_rating, value_rating,
            title, content, status, is_verified
        ) VALUES (
            sample_order_id, sample_reviewer_id, sample_reviewee_id, sample_service_id,
            5, 5, 4, 5, 5,
            'Test Review', 'This is a test review for the Reviews feature.', 
            'published', true
        ) RETURNING id INTO new_review_id;
        
        RAISE NOTICE '✅ 测试评价插入成功，ID: %', new_review_id;
        
    ELSE
        RAISE WARNING '⚠️ 缺少基础数据，无法插入测试评价';
        RAISE NOTICE '需要的数据:';
        IF sample_service_id IS NULL THEN RAISE NOTICE '  - 服务数据'; END IF;
        IF sample_order_id IS NULL THEN RAISE NOTICE '  - 订单数据'; END IF;
        IF sample_reviewer_id IS NULL THEN RAISE NOTICE '  - 用户数据'; END IF;
        IF sample_reviewee_id IS NULL THEN RAISE NOTICE '  - 服务商数据'; END IF;
    END IF;
    
END $$;

-- =====================================================
-- 5. 验证插入结果
-- =====================================================

DO $$
DECLARE
    final_review_count INTEGER;
    test_review_exists BOOLEAN;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '📊 =====================================================';
    RAISE NOTICE '📊 Reviews功能测试结果';
    RAISE NOTICE '📊 =====================================================';
    
    -- 检查最终评价数
    SELECT COUNT(*) INTO final_review_count FROM public.reviews;
    RAISE NOTICE '📊 最终评价数量: %', final_review_count;
    
    -- 检查测试评价是否存在
    SELECT EXISTS (
        SELECT 1 FROM public.reviews 
        WHERE title = 'Test Review'
    ) INTO test_review_exists;
    
    IF test_review_exists THEN
        RAISE NOTICE '✅ 测试评价存在';
    ELSE
        RAISE NOTICE '⚠️ 测试评价不存在';
    END IF;
    
    RAISE NOTICE '📊 =====================================================';
    
    IF final_review_count > 0 THEN
        RAISE NOTICE '✅ Reviews功能测试完成！';
        RAISE NOTICE '📋 现在可以在应用中查看Reviews功能';
        RAISE NOTICE '🔄 请刷新应用并查看Reviews标签页';
    ELSE
        RAISE NOTICE '⚠️ Reviews功能测试未完成';
        RAISE NOTICE '📋 请检查基础数据是否存在';
    END IF;
    
END $$;

-- =====================================================
-- 测试完成
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🎉 Reviews功能快速测试完成！';
    RAISE NOTICE '📋 如果看到测试评价，说明Reviews功能正常工作';
    RAISE NOTICE '🔄 请刷新应用查看结果';
END $$;






