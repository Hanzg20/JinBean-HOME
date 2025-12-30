-- ========================================
-- 非订单评价系统 - 简化版测试数据
-- 验证核心功能
-- ========================================

-- 1. 插入评价标签数据
INSERT INTO public.review_tags (name, category) VALUES
-- 环境类
('环境优雅', 'environment'),
('装修精美', 'environment'),
('干净整洁', 'environment'),

-- 服务类
('服务热情', 'service'),
('响应迅速', 'service'),
('专业细致', 'service'),

-- 价格类
('性价比高', 'price'),
('价格合理', 'price'),
('物有所值', 'price'),

-- 食物类
('味道不错', 'food'),
('食材新鲜', 'food'),
('分量充足', 'food')

ON CONFLICT (name) DO NOTHING;

-- 2. 插入非订单评价测试数据
-- 场景1：到店体验评价
INSERT INTO public.reviews (
    service_id, 
    reviewer_id, 
    reviewee_id, 
    order_id, -- 非订单评价，设为NULL
    review_type,
    overall_rating,
    title,
    content,
    service_rating,
    value_rating,
    images,
    tags,
    is_anonymous,
    is_verified,
    status
) VALUES (
    (SELECT id FROM public.services LIMIT 1),
    '00000000-0000-0000-0000-000000000001',
    (SELECT id FROM public.provider_profiles LIMIT 1),
    NULL, -- 非订单评价
    'visit_based',
    4,
    '环境和服务都很棒',
    '路过这家店，进去咨询了一下服务。店员态度很好，详细介绍了服务内容，价格也很透明。店面装修很有特色，环境干净整洁，给人感觉很专业。虽然没有实际消费，但整体印象很好，推荐给大家。',
    4,
    4,
    '[]'::jsonb,
    '["环境优雅", "服务热情", "价格合理"]'::jsonb,
    false,
    false, -- 非订单评价不验证
    'published'
);

-- 场景2：咨询体验评价
INSERT INTO public.reviews (
    service_id, 
    reviewer_id, 
    reviewee_id, 
    order_id,
    review_type,
    overall_rating,
    title,
    content,
    service_rating,
    value_rating,
    images,
    tags,
    is_anonymous,
    is_verified,
    status
) VALUES (
    (SELECT id FROM public.services LIMIT 1),
    '00000000-0000-0000-0000-000000000002',
    (SELECT id FROM public.provider_profiles LIMIT 1),
    NULL,
    'consultation',
    5,
    '电话咨询体验很好',
    '通过电话咨询了服务详情，客服人员非常专业，回答了我的所有问题，态度也很友好。服务介绍很详细，价格也很透明，没有隐藏费用。虽然还没有实际使用服务，但咨询体验已经让我很满意了。',
    5,
    5,
    '[]'::jsonb,
    '["服务热情", "专业细致", "价格透明"]'::jsonb,
    false,
    false,
    'published'
);

-- 场景3：环境感知评价
INSERT INTO public.reviews (
    service_id, 
    reviewer_id, 
    reviewee_id, 
    order_id,
    review_type,
    overall_rating,
    title,
    content,
    service_rating,
    value_rating,
    images,
    tags,
    is_anonymous,
    is_verified,
    status
) VALUES (
    (SELECT id FROM public.services LIMIT 1),
    '00000000-0000-0000-0000-000000000003',
    (SELECT id FROM public.provider_profiles LIMIT 1),
    NULL,
    'environmental',
    3,
    '店面环境不错',
    '路过这家店，从外面看店面很干净整洁，装修风格很有特色，给人感觉很专业。虽然没有进去，但从外观来看，应该是一家不错的店。',
    NULL, -- 环境感知评价没有服务评分
    NULL,
    '[]'::jsonb,
    '["环境优雅", "装修精美"]'::jsonb,
    false,
    false,
    'published'
);

-- 场景4：匿名评价
INSERT INTO public.reviews (
    service_id, 
    reviewer_id, 
    reviewee_id, 
    order_id,
    review_type,
    overall_rating,
    title,
    content,
    service_rating,
    value_rating,
    images,
    tags,
    is_anonymous,
    is_verified,
    status
) VALUES (
    (SELECT id FROM public.services LIMIT 1),
    '00000000-0000-0000-0000-000000000004',
    (SELECT id FROM public.provider_profiles LIMIT 1),
    NULL,
    'visit_based',
    4,
    '整体体验不错',
    '到店体验了一下服务，整体感觉不错。环境很舒适，服务人员态度也很好。价格方面也比较合理。',
    4,
    4,
    '[]'::jsonb,
    '["环境优雅", "服务热情", "价格合理"]'::jsonb,
    true, -- 匿名评价
    false,
    'published'
);

-- 3. 插入一些评价互动数据
INSERT INTO public.review_interactions (
    review_id,
    user_id,
    interaction_type
) VALUES
-- 有用投票
((SELECT id FROM public.reviews WHERE review_type = 'visit_based' AND is_anonymous = false LIMIT 1),
 '00000000-0000-0000-0000-000000000002',
 'helpful'),

((SELECT id FROM public.reviews WHERE review_type = 'consultation' LIMIT 1),
 '00000000-0000-0000-0000-000000000003',
 'helpful'),

((SELECT id FROM public.reviews WHERE review_type = 'environmental' LIMIT 1),
 '00000000-0000-0000-0000-000000000004',
 'helpful');

-- 4. 更新评价统计
UPDATE public.reviews 
SET helpful_count = (
    SELECT COUNT(*) 
    FROM public.review_interactions 
    WHERE review_id = reviews.id AND interaction_type = 'helpful'
)
WHERE id IN (SELECT id FROM public.reviews WHERE status = 'published');

-- 5. 验证数据
DO $$
DECLARE
    review_count integer;
    non_order_count integer;
    verified_count integer;
    anonymous_count integer;
    helpful_count integer;
BEGIN
    -- 统计评价数量
    SELECT COUNT(*) INTO review_count FROM public.reviews WHERE status = 'published';
    SELECT COUNT(*) INTO non_order_count FROM public.reviews WHERE order_id IS NULL AND status = 'published';
    SELECT COUNT(*) INTO verified_count FROM public.reviews WHERE is_verified = true AND status = 'published';
    SELECT COUNT(*) INTO anonymous_count FROM public.reviews WHERE is_anonymous = true AND status = 'published';
    SELECT COUNT(*) INTO helpful_count FROM public.review_interactions WHERE interaction_type = 'helpful';
    
    RAISE NOTICE '=== 简化版非订单评价系统测试数据统计 ===';
    RAISE NOTICE '总评价数: %', review_count;
    RAISE NOTICE '非订单评价数: %', non_order_count;
    RAISE NOTICE '认证评价数: %', verified_count;
    RAISE NOTICE '匿名评价数: %', anonymous_count;
    RAISE NOTICE '有用投票数: %', helpful_count;
    RAISE NOTICE '非订单评价占比: %', ROUND((non_order_count::decimal / review_count) * 100, 2) || '%';
    
    -- 按评价类型统计
    RAISE NOTICE '=== 按评价类型统计 ===';
    FOR review_count IN 
        SELECT review_type, COUNT(*) 
        FROM public.reviews 
        WHERE status = 'published' 
        GROUP BY review_type 
        ORDER BY COUNT(*) DESC
    LOOP
        RAISE NOTICE '评价类型: %', review_count;
    END LOOP;
    
    RAISE NOTICE '=== 简化版测试数据插入完成 ===';
END $$;






