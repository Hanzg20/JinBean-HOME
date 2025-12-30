-- =====================================================
-- JinBean Platform - Reviews 表结构更新脚本
-- 版本: v3.1.1
-- 创建日期: 2025-09-10
-- 描述: 更新reviews表结构，使order_id变为可选
-- 功能: 像Yelp一样，用户可以直接对服务进行评价
-- =====================================================

-- =====================================================
-- 1. 备份现有数据
-- =====================================================

DO $$
DECLARE
    review_count INTEGER;
BEGIN
    RAISE NOTICE '🔍 检查现有reviews数据...';
    
    SELECT COUNT(*) INTO review_count FROM public.reviews;
    RAISE NOTICE '📊 现有评价数量: %', review_count;
    
    IF review_count > 0 THEN
        RAISE NOTICE '✅ 发现现有评价数据，将进行备份';
    ELSE
        RAISE NOTICE 'ℹ️ 没有现有评价数据';
    END IF;
    
END $$;

-- =====================================================
-- 2. 删除现有约束
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '🔍 删除现有约束...';
    
    -- 删除唯一约束
    BEGIN
        ALTER TABLE public.reviews DROP CONSTRAINT IF EXISTS reviews_order_id_reviewer_id_key;
        RAISE NOTICE '✅ 删除旧唯一约束成功';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'ℹ️ 旧唯一约束不存在或已删除';
    END;
    
    -- 删除外键约束
    BEGIN
        ALTER TABLE public.reviews DROP CONSTRAINT IF EXISTS reviews_order_id_fkey;
        RAISE NOTICE '✅ 删除order_id外键约束成功';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'ℹ️ order_id外键约束不存在或已删除';
    END;
    
END $$;

-- =====================================================
-- 3. 修改order_id字段为可选
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '🔍 修改order_id字段为可选...';
    
    -- 修改order_id字段为可选
    BEGIN
        ALTER TABLE public.reviews ALTER COLUMN order_id DROP NOT NULL;
        RAISE NOTICE '✅ order_id字段修改为可选成功';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '⚠️ 修改order_id字段失败: %', SQLERRM;
    END;
    
END $$;

-- =====================================================
-- 4. 重新添加外键约束（可选）
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '🔍 重新添加order_id外键约束（可选）...';
    
    -- 重新添加外键约束
    BEGIN
        ALTER TABLE public.reviews 
        ADD CONSTRAINT reviews_order_id_fkey 
        FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;
        RAISE NOTICE '✅ order_id外键约束添加成功';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '⚠️ 添加order_id外键约束失败: %', SQLERRM;
    END;
    
END $$;

-- =====================================================
-- 5. 添加新的唯一约束
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '🔍 添加新的唯一约束...';
    
    -- 添加新的唯一约束：每个用户对每个服务只能评价一次
    BEGIN
        ALTER TABLE public.reviews 
        ADD CONSTRAINT reviews_reviewer_service_unique 
        UNIQUE (reviewer_id, service_id);
        RAISE NOTICE '✅ 新唯一约束添加成功';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '⚠️ 添加新唯一约束失败: %', SQLERRM;
    END;
    
END $$;

-- =====================================================
-- 6. 验证更新结果
-- =====================================================

DO $$
DECLARE
    table_exists BOOLEAN;
    column_info RECORD;
    constraint_count INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '📊 =====================================================';
    RAISE NOTICE '📊 Reviews表结构更新验证报告';
    RAISE NOTICE '📊 =====================================================';
    
    -- 检查表是否存在
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'reviews' AND table_schema = 'public'
    ) INTO table_exists;
    
    IF table_exists THEN
        RAISE NOTICE '✅ reviews表存在';
        
        -- 检查order_id字段是否可选
        SELECT is_nullable INTO column_info
        FROM information_schema.columns 
        WHERE table_name = 'reviews' AND table_schema = 'public' AND column_name = 'order_id';
        
        IF column_info.is_nullable = 'YES' THEN
            RAISE NOTICE '✅ order_id字段已修改为可选';
        ELSE
            RAISE NOTICE '⚠️ order_id字段仍为必填';
        END IF;
        
        -- 检查约束数量
        SELECT COUNT(*) INTO constraint_count
        FROM information_schema.table_constraints 
        WHERE table_name = 'reviews' AND table_schema = 'public';
        
        RAISE NOTICE '📊 约束数量: %', constraint_count;
        
    ELSE
        RAISE EXCEPTION '❌ reviews表不存在！';
    END IF;
    
    RAISE NOTICE '📊 =====================================================';
    RAISE NOTICE '✅ Reviews表结构更新完成！';
    RAISE NOTICE '📋 现在用户可以直接对服务进行评价，无需订单';
    RAISE NOTICE '💡 像Yelp一样，Reviews功能独立工作！';
    
END $$;

-- =====================================================
-- 更新完成
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🎉 Reviews表结构更新完成！';
    RAISE NOTICE '📋 现在可以运行reviews_independent_test_data.sql插入测试数据';
    RAISE NOTICE '🔄 请刷新应用查看Reviews功能';
END $$;
