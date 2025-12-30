-- ========================================
-- 基于最新订单创建评价测试数据
-- 包含：基于订单的评价 + 基于服务的评价
-- ========================================

-- 1. 获取最新订单信息
WITH latest_order_info AS (
    SELECT 
        o.id as order_id,
        o.user_id as customer_id,
        o.provider_id,
        o.service_id,
        o.order_status,
        o.total_amount,
        o.created_at as order_created_at,
        -- 客户信息
        up.display_name as customer_name,
        up.avatar_url as customer_avatar,
        -- 服务商信息
        pp.display_name as provider_name,
        pp.avatar_url as provider_avatar,
        -- 服务信息
        s.title as service_title,
        s.description as service_description,
        s.base_price as service_price
    FROM public.orders o
    LEFT JOIN public.user_profiles up ON o.user_id = up.user_id
    LEFT JOIN public.provider_profiles pp ON o.provider_id = pp.id
    LEFT JOIN public.services s ON o.service_id = s.id
    WHERE o.order_status IN ('completed', 'delivered', 'confirmed')
    ORDER BY o.created_at DESC
    LIMIT 1
)

-- 2. 插入基于订单的评价
INSERT INTO public.reviews (
    id,
    order_id,
    reviewer_id,
    reviewee_id,
    service_id,
    review_type,
    overall_rating,
    service_rating,
    content,
    images,
    tags,
    is_verified,
    is_anonymous,
    status,
    created_at,
    updated_at
)
SELECT 
    uuid_generate_v4(),
    loi.order_id,
    loi.customer_id,
    loi.provider_id,
    loi.service_id,
    'order_based'::varchar,
    CASE 
        WHEN loi.order_status = 'completed' THEN 5
        WHEN loi.order_status = 'delivered' THEN 4
        ELSE 3
    END as overall_rating,
    CASE 
        WHEN loi.order_status = 'completed' THEN 5
        WHEN loi.order_status = 'delivered' THEN 4
        ELSE 3
    END as service_rating,
    CASE 
        WHEN loi.order_status = 'completed' THEN 
            CASE 
                WHEN jsonb_typeof(loi.service_title) = 'string' THEN 
                    '服务非常棒！' || loi.service_title::text || ' 超出了我的期望，强烈推荐！'
                WHEN jsonb_typeof(loi.service_title) = 'object' THEN 
                    '服务非常棒！' || COALESCE(loi.service_title->>'en', loi.service_title->>'zh', '服务') || ' 超出了我的期望，强烈推荐！'
                ELSE '服务非常棒！超出了我的期望，强烈推荐！'
            END
        WHEN loi.order_status = 'delivered' THEN 
            CASE 
                WHEN jsonb_typeof(loi.service_title) = 'string' THEN 
                    '服务很好，' || loi.service_title::text || ' 质量不错，值得推荐。'
                WHEN jsonb_typeof(loi.service_title) = 'object' THEN 
                    '服务很好，' || COALESCE(loi.service_title->>'en', loi.service_title->>'zh', '服务') || ' 质量不错，值得推荐。'
                ELSE '服务很好，质量不错，值得推荐。'
            END
        ELSE 
            CASE 
                WHEN jsonb_typeof(loi.service_title) = 'string' THEN 
                    loi.service_title::text || ' 服务还可以，有改进空间。'
                WHEN jsonb_typeof(loi.service_title) = 'object' THEN 
                    COALESCE(loi.service_title->>'en', loi.service_title->>'zh', '服务') || ' 还可以，有改进空间。'
                ELSE '服务还可以，有改进空间。'
            END
    END as content,
    '[]'::jsonb as images,
    CASE 
        WHEN loi.order_status = 'completed' THEN '["服务热情", "专业细致", "性价比高"]'::jsonb
        WHEN loi.order_status = 'delivered' THEN '["服务热情", "响应迅速"]'::jsonb
        ELSE '["服务热情"]'::jsonb
    END as tags,
    true as is_verified,
    false as is_anonymous,
    'published'::varchar as status,
    now() as created_at,
    now() as updated_at
FROM latest_order_info loi
WHERE NOT EXISTS (
    SELECT 1 FROM public.reviews 
    WHERE order_id = loi.order_id
);

-- 3. 插入基于服务的评价（非订单评价）
INSERT INTO public.reviews (
    id,
    order_id,
    reviewer_id,
    reviewee_id,
    service_id,
    review_type,
    overall_rating,
    service_rating,
    content,
    images,
    tags,
    is_verified,
    is_anonymous,
    status,
    created_at,
    updated_at
)
SELECT 
    uuid_generate_v4(),
    NULL as order_id, -- 非订单评价
    loi.customer_id,
    loi.provider_id,
    loi.service_id,
    'visit_based'::varchar,
    CASE 
        WHEN loi.order_status = 'completed' THEN 4
        WHEN loi.order_status = 'delivered' THEN 3
        ELSE 2
    END as overall_rating,
    CASE 
        WHEN loi.order_status = 'completed' THEN 4
        WHEN loi.order_status = 'delivered' THEN 3
        ELSE 2
    END as service_rating,
    CASE 
        WHEN jsonb_typeof(loi.service_title) = 'string' THEN 
            '虽然没有下单，但体验了' || loi.service_title::text || '的服务咨询，服务态度很好，环境也不错。'
        WHEN jsonb_typeof(loi.service_title) = 'object' THEN 
            '虽然没有下单，但体验了' || COALESCE(loi.service_title->>'en', loi.service_title->>'zh', '服务') || '的服务咨询，服务态度很好，环境也不错。'
        ELSE '虽然没有下单，但体验了服务咨询，服务态度很好，环境也不错。'
    END as content,
    '[]'::jsonb as images,
    '["环境优雅", "服务热情"]'::jsonb as tags,
    false as is_verified, -- 非订单评价未验证
    false as is_anonymous,
    'published'::varchar as status,
    now() as created_at,
    now() as updated_at
FROM latest_order_info loi
WHERE NOT EXISTS (
    SELECT 1 FROM public.reviews 
    WHERE reviewer_id = loi.customer_id 
    AND service_id = loi.service_id 
    AND order_id IS NULL
);

-- 4. 为同一个服务商的其他服务创建评价（模拟其他用户的评价）
INSERT INTO public.reviews (
    id,
    order_id,
    reviewer_id,
    reviewee_id,
    service_id,
    review_type,
    overall_rating,
    service_rating,
    content,
    images,
    tags,
    is_verified,
    is_anonymous,
    status,
    created_at,
    updated_at
)
SELECT 
    uuid_generate_v4(),
    NULL as order_id,
    up.id as reviewer_id,
    loi.provider_id,
    s.id as service_id,
    CASE 
        WHEN random() > 0.7 THEN 'consultation'::varchar
        WHEN random() > 0.4 THEN 'environmental'::varchar
        ELSE 'visit_based'::varchar
    END as review_type,
    (random() * 2 + 3)::integer as overall_rating, -- 3-5星
    (random() * 2 + 3)::integer as service_rating, -- 3-5星
    CASE 
        WHEN jsonb_typeof(s.title) = 'string' THEN 
            CASE (random() * 4)::integer
                WHEN 0 THEN s.title::text || ' 服务很棒，推荐！'
                WHEN 1 THEN '体验了' || s.title::text || '，服务专业，环境舒适。'
                WHEN 2 THEN s.title::text || ' 性价比很高，值得尝试。'
                ELSE '对' || s.title::text || '很满意，会再次光顾。'
            END
        WHEN jsonb_typeof(s.title) = 'object' THEN 
            CASE (random() * 4)::integer
                WHEN 0 THEN COALESCE(s.title->>'en', s.title->>'zh', '服务') || ' 服务很棒，推荐！'
                WHEN 1 THEN '体验了' || COALESCE(s.title->>'en', s.title->>'zh', '服务') || '，服务专业，环境舒适。'
                WHEN 2 THEN COALESCE(s.title->>'en', s.title->>'zh', '服务') || ' 性价比很高，值得尝试。'
                ELSE '对' || COALESCE(s.title->>'en', s.title->>'zh', '服务') || '很满意，会再次光顾。'
            END
        ELSE '服务很棒，推荐！'
    END as content,
    '[]'::jsonb as images,
    CASE (random() * 3)::integer
        WHEN 0 THEN '["服务热情", "专业细致"]'::jsonb
        WHEN 1 THEN '["环境优雅", "性价比高"]'::jsonb
        ELSE '["响应迅速", "味道不错"]'::jsonb
    END as tags,
    false as is_verified,
    (random() > 0.8) as is_anonymous, -- 20%匿名评价
    'published'::varchar as status,
    now() - (random() * interval '30 days') as created_at, -- 随机30天内的时间
    now() as updated_at
FROM latest_order_info loi
CROSS JOIN public.services s
CROSS JOIN (
    SELECT id FROM public.user_profiles 
    WHERE id != loi.customer_id 
    ORDER BY random() 
    LIMIT 3
) up
WHERE s.provider_id = loi.provider_id 
AND s.id != loi.service_id -- 不同的服务
AND NOT EXISTS (
    SELECT 1 FROM public.reviews 
    WHERE reviewer_id = up.id 
    AND service_id = s.id
)
LIMIT 6; -- 最多6个额外评价

-- 5. 显示创建的评价统计
DO $$
DECLARE
    order_based_count integer;
    service_based_count integer;
    total_count integer;
BEGIN
    SELECT COUNT(*) INTO order_based_count FROM public.reviews WHERE order_id IS NOT NULL;
    SELECT COUNT(*) INTO service_based_count FROM public.reviews WHERE order_id IS NULL;
    SELECT COUNT(*) INTO total_count FROM public.reviews;
    
    RAISE NOTICE '=== 评价数据创建完成 ===';
    RAISE NOTICE '基于订单的评价: %', order_based_count;
    RAISE NOTICE '基于服务的评价: %', service_based_count;
    RAISE NOTICE '总评价数量: %', total_count;
    RAISE NOTICE '评价数据已准备就绪！';
END $$;

-- ========================================
-- 完成
-- ========================================






