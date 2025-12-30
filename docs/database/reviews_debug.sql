-- =====================================================
-- JinBean Platform - Reviews 调试脚本
-- 版本: v3.1.1
-- 创建日期: 2025-09-10
-- 描述: 调试Reviews功能问题
-- =====================================================

-- =====================================================
-- 1. 检查reviews表结构
-- =====================================================

DO $$
DECLARE
    column_info RECORD;
BEGIN
    RAISE NOTICE '🔍 检查reviews表结构...';
    
    FOR column_info IN 
        SELECT column_name, data_type, is_nullable, column_default
        FROM information_schema.columns 
        WHERE table_name = 'reviews' AND table_schema = 'public'
        ORDER BY ordinal_position
    LOOP
        RAISE NOTICE '📋 %: % (%) - 默认值: %', 
            column_info.column_name, 
            column_info.data_type, 
            CASE WHEN column_info.is_nullable = 'YES' THEN '可空' ELSE '非空' END,
            COALESCE(column_info.column_default, '无');
    END LOOP;
    
END $$;

-- =====================================================
-- 2. 检查索引
-- =====================================================

DO $$
DECLARE
    index_info RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔍 检查reviews表索引...';
    
    FOR index_info IN 
        SELECT indexname, indexdef
        FROM pg_indexes 
        WHERE tablename = 'reviews' AND schemaname = 'public'
    LOOP
        RAISE NOTICE '📋 索引: %', index_info.indexname;
    END LOOP;
    
END $$;

-- =====================================================
-- 3. 检查RLS策略
-- =====================================================

DO $$
DECLARE
    policy_info RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔍 检查reviews表RLS策略...';
    
    FOR policy_info IN 
        SELECT policyname, cmd, qual
        FROM pg_policies 
        WHERE tablename = 'reviews' AND schemaname = 'public'
    LOOP
        RAISE NOTICE '📋 策略: % (%s)', policy_info.policyname, policy_info.cmd;
    END LOOP;
    
END $$;

-- =====================================================
-- 4. 检查现有数据
-- =====================================================

DO $$
DECLARE
    service_count INTEGER;
    order_count INTEGER;
    user_count INTEGER;
    provider_count INTEGER;
    review_count INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔍 检查现有数据...';
    
    SELECT COUNT(*) INTO service_count FROM public.services;
    SELECT COUNT(*) INTO order_count FROM public.orders;
    SELECT COUNT(*) INTO user_count FROM public.user_profiles;
    SELECT COUNT(*) INTO provider_count FROM public.provider_profiles;
    SELECT COUNT(*) INTO review_count FROM public.reviews;
    
    RAISE NOTICE '📊 服务数量: %', service_count;
    RAISE NOTICE '📊 订单数量: %', order_count;
    RAISE NOTICE '📊 用户数量: %', user_count;
    RAISE NOTICE '📊 服务商数量: %', provider_count;
    RAISE NOTICE '📊 评价数量: %', review_count;
    
END $$;

-- =====================================================
-- 5. 插入测试数据（如果可能）
-- =====================================================

DO $$
DECLARE
    sample_service_id UUID;
    sample_order_id UUID;
    sample_reviewer_id UUID;
    sample_reviewee_id UUID;
    new_review_id UUID;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔍 尝试插入测试数据...';
    
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
        
        RAISE NOTICE '✅ 找到基础数据:';
        RAISE NOTICE '  - 服务ID: %', sample_service_id;
        RAISE NOTICE '  - 订单ID: %', sample_order_id;
        RAISE NOTICE '  - 用户ID: %', sample_reviewer_id;
        RAISE NOTICE '  - 服务商ID: %', sample_reviewee_id;
        
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
            
            RAISE NOTICE '✅ 测试评价插入成功，ID: %', new_review_id;
            
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE '❌ 插入测试评价失败: %', SQLERRM;
        END;
        
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
-- 6. 最终验证
-- =====================================================

DO $$
DECLARE
    final_review_count INTEGER;
    published_count INTEGER;
    test_review_exists BOOLEAN;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '📊 =====================================================';
    RAISE NOTICE '📊 Reviews功能调试结果';
    RAISE NOTICE '📊 =====================================================';
    
    -- 检查最终评价数
    SELECT COUNT(*) INTO final_review_count FROM public.reviews;
    SELECT COUNT(*) INTO published_count FROM public.reviews WHERE status = 'published';
    
    RAISE NOTICE '📊 总评价数量: %', final_review_count;
    RAISE NOTICE '📊 已发布评价数量: %', published_count;
    
    -- 检查测试评价是否存在
    SELECT EXISTS (
        SELECT 1 FROM public.reviews 
        WHERE title = 'Reviews功能测试'
    ) INTO test_review_exists;
    
    IF test_review_exists THEN
        RAISE NOTICE '✅ 测试评价存在';
    ELSE
        RAISE NOTICE '⚠️ 测试评价不存在';
    END IF;
    
    RAISE NOTICE '📊 =====================================================';
    
    IF final_review_count > 0 THEN
        RAISE NOTICE '✅ Reviews功能调试完成！';
        RAISE NOTICE '📋 现在可以在应用中查看Reviews功能';
        RAISE NOTICE '🔄 请刷新应用并查看Reviews标签页';
    ELSE
        RAISE NOTICE '⚠️ Reviews功能调试未完成';
        RAISE NOTICE '📋 请检查基础数据是否存在';
    END IF;
    
END $$;

-- =====================================================
-- 调试完成
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🎉 Reviews功能调试完成！';
    RAISE NOTICE '📋 如果看到测试评价，说明Reviews功能正常工作';
    RAISE NOTICE '🔄 请刷新应用查看结果';
END $$;






