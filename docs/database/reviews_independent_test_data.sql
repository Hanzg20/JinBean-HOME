-- =====================================================
-- JinBean Platform - Reviews 独立测试数据脚本
-- 版本: v3.1.1
-- 创建日期: 2025-09-10
-- 描述: 创建独立的Reviews测试数据，不依赖订单
-- 功能: 像Yelp一样，用户可以直接对服务进行评价
-- =====================================================

-- =====================================================
-- 1. 检查基础数据
-- =====================================================

DO $$
DECLARE
    service_count INTEGER;
    user_count INTEGER;
    provider_count INTEGER;
    review_count INTEGER;
BEGIN
    RAISE NOTICE '🔍 检查基础数据...';
    
    -- 检查服务
    SELECT COUNT(*) INTO service_count FROM public.services;
    RAISE NOTICE '📊 服务数量: %', service_count;
    
    -- 检查用户
    SELECT COUNT(*) INTO user_count FROM public.user_profiles;
    RAISE NOTICE '📊 用户数量: %', user_count;
    
    -- 检查服务商
    SELECT COUNT(*) INTO provider_count FROM public.provider_profiles;
    RAISE NOTICE '📊 服务商数量: %', provider_count;
    
    -- 检查现有评价
    SELECT COUNT(*) INTO review_count FROM public.reviews;
    RAISE NOTICE '📊 现有评价数量: %', review_count;
    
    RAISE NOTICE '';
    
    IF service_count = 0 THEN
        RAISE WARNING '⚠️ 没有服务数据';
    END IF;
    
    IF user_count = 0 THEN
        RAISE WARNING '⚠️ 没有用户数据';
    END IF;
    
    IF provider_count = 0 THEN
        RAISE WARNING '⚠️ 没有服务商数据';
    END IF;
    
END $$;

-- =====================================================
-- 2. 插入独立的测试评价数据
-- =====================================================

DO $$
DECLARE
    sample_service_id UUID;
    sample_reviewer_id UUID;
    sample_reviewee_id UUID;
    new_review_id UUID;
    insert_count INTEGER := 0;
BEGIN
    RAISE NOTICE '🔍 开始插入独立的Reviews测试数据...';
    
    -- 获取第一个服务
    SELECT id INTO sample_service_id FROM public.services LIMIT 1;
    
    -- 获取第一个用户
    SELECT id INTO sample_reviewer_id FROM public.user_profiles LIMIT 1;
    
    -- 获取第一个服务商
    SELECT id INTO sample_reviewee_id FROM public.provider_profiles LIMIT 1;
    
    IF sample_service_id IS NOT NULL AND sample_reviewer_id IS NOT NULL AND 
       sample_reviewee_id IS NOT NULL THEN
        
        RAISE NOTICE '✅ 找到基础数据，开始插入测试评价...';
        RAISE NOTICE '📋 基础信息:';
        RAISE NOTICE '  - 服务ID: %', sample_service_id;
        RAISE NOTICE '  - 用户ID: %', sample_reviewer_id;
        RAISE NOTICE '  - 服务商ID: %', sample_reviewee_id;
        
        -- 插入测试评价1 - 5星评价
        BEGIN
            INSERT INTO public.reviews (
                reviewer_id, reviewee_id, service_id,
                overall_rating, quality_rating, communication_rating, 
                timeliness_rating, value_rating,
                title, content, status, is_verified
            ) VALUES (
                sample_reviewer_id, sample_reviewee_id, sample_service_id,
                5, 5, 4, 5, 5,
                'Excellent Service!', 'The service was outstanding. Highly recommend!', 
                'published', true
            ) RETURNING id INTO new_review_id;
            
            insert_count := insert_count + 1;
            RAISE NOTICE '✅ 插入5星评价成功，ID: %', new_review_id;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE '⚠️ 插入5星评价失败: %', SQLERRM;
        END;
        
        -- 插入测试评价2 - 4星评价
        BEGIN
            INSERT INTO public.reviews (
                reviewer_id, reviewee_id, service_id,
                overall_rating, quality_rating, communication_rating, 
                timeliness_rating, value_rating,
                title, content, status, is_verified
            ) VALUES (
                sample_reviewer_id, sample_reviewee_id, sample_service_id,
                4, 4, 5, 4, 4,
                'Good Service', 'Very satisfied with the quality and communication.', 
                'published', true
            ) RETURNING id INTO new_review_id;
            
            insert_count := insert_count + 1;
            RAISE NOTICE '✅ 插入4星评价成功，ID: %', new_review_id;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE '⚠️ 插入4星评价失败: %', SQLERRM;
        END;
        
        -- 插入测试评价3 - 3星评价
        BEGIN
            INSERT INTO public.reviews (
                reviewer_id, reviewee_id, service_id,
                overall_rating, quality_rating, communication_rating, 
                timeliness_rating, value_rating,
                title, content, status, is_verified
            ) VALUES (
                sample_reviewer_id, sample_reviewee_id, sample_service_id,
                3, 3, 3, 3, 3,
                'Average Service', 'The service was okay, room for improvement.', 
                'published', false
            ) RETURNING id INTO new_review_id;
            
            insert_count := insert_count + 1;
            RAISE NOTICE '✅ 插入3星评价成功，ID: %', new_review_id;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE '⚠️ 插入3星评价失败: %', SQLERRM;
        END;
        
        -- 插入测试评价4 - 2星评价
        BEGIN
            INSERT INTO public.reviews (
                reviewer_id, reviewee_id, service_id,
                overall_rating, quality_rating, communication_rating, 
                timeliness_rating, value_rating,
                title, content, status, is_verified
            ) VALUES (
                sample_reviewer_id, sample_reviewee_id, sample_service_id,
                2, 2, 2, 2, 2,
                'Below Average', 'Not satisfied with the service quality.', 
                'published', false
            ) RETURNING id INTO new_review_id;
            
            insert_count := insert_count + 1;
            RAISE NOTICE '✅ 插入2星评价成功，ID: %', new_review_id;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE '⚠️ 插入2星评价失败: %', SQLERRM;
        END;
        
        -- 插入测试评价5 - 1星评价
        BEGIN
            INSERT INTO public.reviews (
                reviewer_id, reviewee_id, service_id,
                overall_rating, quality_rating, communication_rating, 
                timeliness_rating, value_rating,
                title, content, status, is_verified
            ) VALUES (
                sample_reviewer_id, sample_reviewee_id, sample_service_id,
                1, 1, 1, 1, 1,
                'Poor Service', 'Very disappointed with the service.', 
                'published', false
            ) RETURNING id INTO new_review_id;
            
            insert_count := insert_count + 1;
            RAISE NOTICE '✅ 插入1星评价成功，ID: %', new_review_id;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE '⚠️ 插入1星评价失败: %', SQLERRM;
        END;
        
        RAISE NOTICE '📊 成功插入 % 条测试评价', insert_count;
        
    ELSE
        RAISE WARNING '⚠️ 缺少基础数据，无法插入测试评价';
        RAISE NOTICE '需要的数据:';
        IF sample_service_id IS NULL THEN RAISE NOTICE '  - 服务数据'; END IF;
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
    rating_stats RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '📊 =====================================================';
    RAISE NOTICE '📊 Reviews独立测试数据验证报告';
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
    
    -- 统计评分分布
    SELECT 
        AVG(overall_rating) as avg_rating,
        COUNT(CASE WHEN overall_rating = 5 THEN 1 END) as five_star,
        COUNT(CASE WHEN overall_rating = 4 THEN 1 END) as four_star,
        COUNT(CASE WHEN overall_rating = 3 THEN 1 END) as three_star,
        COUNT(CASE WHEN overall_rating = 2 THEN 1 END) as two_star,
        COUNT(CASE WHEN overall_rating = 1 THEN 1 END) as one_star
    INTO rating_stats
    FROM public.reviews 
    WHERE status = 'published';
    
    RAISE NOTICE '📊 平均评分: %', ROUND(rating_stats.avg_rating, 2);
    RAISE NOTICE '📊 5星评价: %', rating_stats.five_star;
    RAISE NOTICE '📊 4星评价: %', rating_stats.four_star;
    RAISE NOTICE '📊 3星评价: %', rating_stats.three_star;
    RAISE NOTICE '📊 2星评价: %', rating_stats.two_star;
    RAISE NOTICE '📊 1星评价: %', rating_stats.one_star;
    
    RAISE NOTICE '📊 =====================================================';
    
    IF total_reviews > 0 THEN
        RAISE NOTICE '✅ Reviews独立测试数据插入完成！';
        RAISE NOTICE '📋 现在可以在应用中查看Reviews功能';
        RAISE NOTICE '🔄 请刷新应用并查看Reviews标签页';
        RAISE NOTICE '💡 用户现在可以直接对服务进行评价，无需订单';
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
    RAISE NOTICE '🎉 Reviews独立测试数据脚本执行完成！';
    RAISE NOTICE '📋 如果成功插入数据，请刷新应用查看Reviews功能';
    RAISE NOTICE '💡 现在Reviews功能像Yelp一样独立工作！';
END $$;
