-- =====================================================
-- JinBean Platform - Reviews 测试数据插入脚本
-- 版本: v3.1.1
-- 创建日期: 2025-09-10
-- 描述: 为测试Reviews功能插入示例数据
-- =====================================================

-- =====================================================
-- 1. 检查现有数据
-- =====================================================

DO $$
DECLARE
    service_count INTEGER;
    order_count INTEGER;
    review_count INTEGER;
BEGIN
    RAISE NOTICE '🔍 检查现有数据...';
    
    -- 检查服务数量
    SELECT COUNT(*) INTO service_count FROM public.services;
    RAISE NOTICE '📊 服务数量: %', service_count;
    
    -- 检查订单数量
    SELECT COUNT(*) INTO order_count FROM public.orders;
    RAISE NOTICE '📊 订单数量: %', order_count;
    
    -- 检查评价数量
    SELECT COUNT(*) INTO review_count FROM public.reviews;
    RAISE NOTICE '📊 评价数量: %', review_count;
    
    IF service_count = 0 THEN
        RAISE WARNING '⚠️ 没有服务数据，无法创建评价';
    END IF;
    
    IF order_count = 0 THEN
        RAISE WARNING '⚠️ 没有订单数据，无法创建评价';
    END IF;
    
END $$;

-- =====================================================
-- 2. 插入测试评价数据（如果有基础数据）
-- =====================================================

-- 首先检查是否有可用的服务和订单
DO $$
DECLARE
    sample_service_id UUID;
    sample_order_id UUID;
    sample_reviewer_id UUID;
    sample_reviewee_id UUID;
    insert_count INTEGER := 0;
BEGIN
    -- 获取第一个服务
    SELECT id INTO sample_service_id FROM public.services LIMIT 1;
    
    -- 获取第一个订单
    SELECT id INTO sample_order_id FROM public.orders LIMIT 1;
    
    -- 获取第一个用户（从user_profiles）
    SELECT id INTO sample_reviewer_id FROM public.user_profiles LIMIT 1;
    
    -- 获取第一个服务商
    SELECT id INTO sample_reviewee_id FROM public.provider_profiles LIMIT 1;
    
    IF sample_service_id IS NOT NULL AND sample_order_id IS NOT NULL AND 
       sample_reviewer_id IS NOT NULL AND sample_reviewee_id IS NOT NULL THEN
        
        RAISE NOTICE '✅ 找到基础数据，开始插入测试评价...';
        
        -- 插入测试评价1
        BEGIN
            INSERT INTO public.reviews (
                order_id, reviewer_id, reviewee_id, service_id,
                overall_rating, quality_rating, communication_rating, 
                timeliness_rating, value_rating,
                title, content, status, is_verified
            ) VALUES (
                sample_order_id, sample_reviewer_id, sample_reviewee_id, sample_service_id,
                5, 5, 4, 5, 5,
                'Excellent Service!', 'The service was outstanding. Highly recommend!', 
                'published', true
            );
            insert_count := insert_count + 1;
            RAISE NOTICE '✅ 插入评价1成功';
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE '⚠️ 插入评价1失败: %', SQLERRM;
        END;
        
        -- 插入测试评价2
        BEGIN
            INSERT INTO public.reviews (
                order_id, reviewer_id, reviewee_id, service_id,
                overall_rating, quality_rating, communication_rating, 
                timeliness_rating, value_rating,
                title, content, status, is_verified
            ) VALUES (
                sample_order_id, sample_reviewer_id, sample_reviewee_id, sample_service_id,
                4, 4, 5, 4, 4,
                'Good Service', 'Very satisfied with the quality and communication.', 
                'published', true
            );
            insert_count := insert_count + 1;
            RAISE NOTICE '✅ 插入评价2成功';
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE '⚠️ 插入评价2失败: %', SQLERRM;
        END;
        
        -- 插入测试评价3
        BEGIN
            INSERT INTO public.reviews (
                order_id, reviewer_id, reviewee_id, service_id,
                overall_rating, quality_rating, communication_rating, 
                timeliness_rating, value_rating,
                title, content, status, is_verified
            ) VALUES (
                sample_order_id, sample_reviewer_id, sample_reviewee_id, sample_service_id,
                3, 3, 3, 3, 3,
                'Average Service', 'The service was okay, room for improvement.', 
                'published', false
            );
            insert_count := insert_count + 1;
            RAISE NOTICE '✅ 插入评价3成功';
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE '⚠️ 插入评价3失败: %', SQLERRM;
        END;
        
        RAISE NOTICE '📊 成功插入 % 条测试评价', insert_count;
        
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
-- 3. 验证插入结果
-- =====================================================

DO $$
DECLARE
    total_reviews INTEGER;
    published_reviews INTEGER;
    verified_reviews INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '📊 =====================================================';
    RAISE NOTICE '📊 Reviews测试数据验证报告';
    RAISE NOTICE '📊 =====================================================';
    
    -- 统计总评价数
    SELECT COUNT(*) INTO total_reviews FROM public.reviews;
   RAISE NOTICE '📊 总评价数量: %', total_reviews;
    
    -- 统计已发布评价数
    SELECT COUNT(*) INTO published_reviews FROM public.reviews WHERE status = 'published';
    RAISE NOTICE '📊 已发布评价数量: %', published_reviews;
    
    -- 统计已验证评价数
    SELECT COUNT(*) INTO verified_reviews FROM public.reviews WHERE is_verified = true;
    RAISE NOTICE '📊 已验证评价数量: %', verified_reviews;
    
    RAISE NOTICE '📊 =====================================================';
    
    IF total_reviews > 0 THEN
        RAISE NOTICE '✅ Reviews测试数据插入完成！';
        RAISE NOTICE '📋 现在可以在应用中查看Reviews功能';
    ELSE
        RAISE NOTICE '⚠️ 没有评价数据，请检查基础数据是否存在';
    END IF;
    
END $$;

-- =====================================================
-- 脚本执行完成
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🎉 Reviews测试数据脚本执行完成！';
    RAISE NOTICE '📋 如果成功插入数据，请刷新应用查看Reviews功能';
END $$;

