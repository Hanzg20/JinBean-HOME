-- ========================================
-- 基于最新订单创建评价测试数据 (简化版)
-- 包含：基于订单的评价 + 基于服务的评价
-- ========================================

-- 1. 获取最新订单信息并创建基于订单的评价
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
    o.id as order_id,
    o.user_id as reviewer_id,
    o.provider_id as reviewee_id,
    o.service_id,
    'order_based'::varchar,
    5 as overall_rating,
    5 as service_rating,
    '服务非常棒！超出了我的期望，强烈推荐！' as content,
    '[]'::jsonb as images,
    '["服务热情", "专业细致", "性价比高"]'::jsonb as tags,
    true as is_verified,
    false as is_anonymous,
    'published'::varchar as status,
    now() as created_at,
    now() as updated_at
FROM public.orders o
WHERE o.order_status IN ('completed', 'delivered', 'confirmed')
AND NOT EXISTS (
    SELECT 1 FROM public.reviews 
    WHERE order_id = o.id
)
ORDER BY o.created_at DESC
LIMIT 1;

-- 2. 创建基于服务的评价（非订单评价）
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
    o.user_id as reviewer_id,
    o.provider_id as reviewee_id,
    o.service_id,
    'visit_based'::varchar,
    4 as overall_rating,
    4 as service_rating,
    '虽然没有下单，但体验了服务咨询，服务态度很好，环境也不错。' as content,
    '[]'::jsonb as images,
    '["环境优雅", "服务热情"]'::jsonb as tags,
    false as is_verified,
    false as is_anonymous,
    'published'::varchar as status,
    now() as created_at,
    now() as updated_at
FROM public.orders o
WHERE o.order_status IN ('completed', 'delivered', 'confirmed')
AND NOT EXISTS (
    SELECT 1 FROM public.reviews 
    WHERE reviewer_id = o.user_id 
    AND service_id = o.service_id 
    AND order_id IS NULL
)
ORDER BY o.created_at DESC
LIMIT 1;

-- 3. 显示创建的评价统计
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






