-- =====================================================
-- JinBean Platform - Reviews 测试数据快速插入脚本
-- 版本: v3.1.1
-- 创建日期: 2025-09-10
-- 描述: 基于最新订单数据插入Reviews测试数据
-- 功能: 自动获取最新的订单信息，为其创建相关的评价数据
-- =====================================================

-- =====================================================
-- 1. 插入测试评价数据
-- =====================================================

DO $$
DECLARE
    sample_service_id UUID;
    sample_order_id UUID;
    sample_reviewer_id UUID;
    sample_reviewee_id UUID;
    new_review_id UUID;
    insert_count INTEGER := 0;
BEGIN
    RAISE NOTICE '🔍 开始插入Reviews测试数据...';
    
    -- 获取最新的订单信息
    SELECT id, user_id, provider_id, service_id 
    INTO sample_order_id, sample_reviewer_id, sample_reviewee_id, sample_service_id
    FROM public.orders 
    ORDER BY created_at DESC 
    LIMIT 1;
    
    IF sample_service_id IS NOT NULL AND sample_order_id IS NOT NULL AND 
       sample_reviewer_id IS NOT NULL AND sample_reviewee_id IS NOT NULL THEN
        
        RAISE NOTICE '✅ 找到最新订单数据，开始插入测试评价...';
        RAISE NOTICE '📋 订单信息:';
        RAISE NOTICE '  - 订单ID: %', sample_order_id;
        RAISE NOTICE '  - 用户ID: %', sample_reviewer_id;
        RAISE NOTICE '  - 服务商ID: %', sample_reviewee_id;
        RAISE NOTICE '  - 服务ID: %', sample_service_id;
        
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
            ) RETURNING id INTO new_review_id;
            
            insert_count := insert_count + 1;
            RAISE NOTICE '✅ 插入评价1成功，ID: %', new_review_id;
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
            ) RETURNING id INTO new_review_id;
            
            insert_count := insert_count + 1;
            RAISE NOTICE '✅ 插入评价2成功，ID: %', new_review_id;
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
            ) RETURNING id INTO new_review_id;
            
            insert_count := insert_count + 1;
            RAISE NOTICE '✅ 插入评价3成功，ID: %', new_review_id;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE '⚠️ 插入评价3失败: %', SQLERRM;
        END;
        
        RAISE NOTICE '📊 成功插入 % 条测试评价', insert_count;
        
    ELSE
        RAISE WARNING '⚠️ 没有找到最新的订单数据，无法插入测试评价';
        RAISE NOTICE '需要的数据:';
        IF sample_order_id IS NULL THEN RAISE NOTICE '  - 订单数据'; END IF;
        IF sample_reviewer_id IS NULL THEN RAISE NOTICE '  - 订单中的用户ID'; END IF;
        IF sample_reviewee_id IS NULL THEN RAISE NOTICE '  - 订单中的服务商ID'; END IF;
        IF sample_service_id IS NULL THEN RAISE NOTICE '  - 订单中的服务ID'; END IF;
        RAISE NOTICE '💡 请确保orders表中有完整的订单数据';
    END IF;
    
END $$;

-- =====================================================
-- 2. 验证插入结果
-- =====================================================

DO $$
DECLARE
    total_reviews INTEGER;
    published_reviews INTEGER;
    verified_reviews INTEGER;
    latest_order_info RECORD;
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
    
    -- 显示最新订单信息
    SELECT o.id, o.user_id, o.provider_id, o.service_id, o.created_at
    INTO latest_order_info
    FROM public.orders o
    ORDER BY o.created_at DESC
    LIMIT 1;
    
    IF latest_order_info.id IS NOT NULL THEN
        RAISE NOTICE '📋 最新订单信息:';
        RAISE NOTICE '  - 订单ID: %', latest_order_info.id;
        RAISE NOTICE '  - 用户ID: %', latest_order_info.user_id;
        RAISE NOTICE '  - 服务商ID: %', latest_order_info.provider_id;
        RAISE NOTICE '  - 服务ID: %', latest_order_info.service_id;
        RAISE NOTICE '  - 创建时间: %', latest_order_info.created_at;
    END IF;
    
    RAISE NOTICE '📊 =====================================================';
    
    IF total_reviews > 0 THEN
        RAISE NOTICE '✅ Reviews测试数据插入完成！';
        RAISE NOTICE '📋 现在可以在应用中查看Reviews功能';
        RAISE NOTICE '🔄 请刷新应用并查看Reviews标签页';
    ELSE
        RAISE NOTICE '⚠️ 没有评价数据，请检查订单数据是否存在';
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
