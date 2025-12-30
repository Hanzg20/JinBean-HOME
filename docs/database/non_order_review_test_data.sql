-- ========================================
-- 非订单评价系统测试数据
-- 验证Yelp模式的评价功能
-- ========================================

-- 1. 插入评价标签数据
INSERT INTO public.review_tags (name, category) VALUES
-- 环境类
('环境优雅', 'environment'),
('装修精美', 'environment'),
('空间宽敞', 'environment'),
('氛围温馨', 'environment'),
('干净整洁', 'environment'),

-- 服务类
('服务热情', 'service'),
('响应迅速', 'service'),
('专业细致', 'service'),
('态度友好', 'service'),
('效率很高', 'service'),

-- 价格类
('性价比高', 'price'),
('价格合理', 'price'),
('物有所值', 'price'),
('价格实惠', 'price'),
('价格偏贵', 'price'),

-- 食物类
('味道不错', 'food'),
('食材新鲜', 'food'),
('分量充足', 'food'),
('口味独特', 'food'),
('健康营养', 'food')

ON CONFLICT (name) DO NOTHING;

-- 2. 创建测试用户信任度数据
INSERT INTO public.user_trust_metrics (
    user_id, 
    total_reviews, 
    helpful_votes_received,
    profile_completeness,
    trust_score,
    verification_level
) VALUES
-- 高信任度用户
('00000000-0000-0000-0000-000000000001', 25, 15, 0.9, 0.85, 'verified'),
('00000000-0000-0000-0000-000000000002', 18, 12, 0.8, 0.75, 'verified'),
-- 中等信任度用户
('00000000-0000-0000-0000-000000000003', 8, 5, 0.7, 0.65, 'basic'),
('00000000-0000-0000-0000-000000000004', 12, 8, 0.6, 0.60, 'basic'),
-- 新用户
('00000000-0000-0000-0000-000000000005', 2, 1, 0.5, 0.45, 'basic')

ON CONFLICT (user_id) DO UPDATE SET
    total_reviews = EXCLUDED.total_reviews,
    helpful_votes_received = EXCLUDED.helpful_votes_received,
    profile_completeness = EXCLUDED.profile_completeness,
    trust_score = EXCLUDED.trust_score,
    verification_level = EXCLUDED.verification_level;

-- 3. 插入非订单评价测试数据
-- 场景1：到店体验评价
INSERT INTO public.reviews (
    service_id, 
    reviewer_id, 
    reviewee_id, 
    order_id, -- 非订单评价，设为NULL
    review_type,
    source_description,
    overall_rating,
    title,
    content,
    service_rating,
    value_rating,
    atmosphere_rating,
    images,
    tags,
    categories,
    is_anonymous,
    is_verified,
    status,
    published_at
) VALUES (
    (SELECT id FROM public.services LIMIT 1),
    '00000000-0000-0000-0000-000000000001',
    (SELECT id FROM public.provider_profiles LIMIT 1),
    NULL, -- 非订单评价
    'visit_based',
    '到店咨询了服务内容和价格，店员很热情，环境也很不错',
    4,
    '环境和服务都很棒',
    '路过这家店，进去咨询了一下服务。店员态度很好，详细介绍了服务内容，价格也很透明。店面装修很有特色，环境干净整洁，给人感觉很专业。虽然没有实际消费，但整体印象很好，推荐给大家。',
    4,
    4,
    5,
    '[]'::jsonb,
    '["环境优雅", "服务热情", "价格合理"]'::jsonb,
    '["环境", "服务", "价格"]'::jsonb,
    false,
    false, -- 非订单评价不验证
    'published',
    now()
);

-- 场景2：咨询体验评价
INSERT INTO public.reviews (
    service_id, 
    reviewer_id, 
    reviewee_id, 
    order_id,
    review_type,
    source_description,
    overall_rating,
    title,
    content,
    service_rating,
    value_rating,
    atmosphere_rating,
    images,
    tags,
    categories,
    is_anonymous,
    is_verified,
    status,
    published_at
) VALUES (
    (SELECT id FROM public.services LIMIT 1),
    '00000000-0000-0000-0000-000000000002',
    (SELECT id FROM public.provider_profiles LIMIT 1),
    NULL,
    'consultation',
    '电话咨询了服务详情，客服很专业，回答很详细',
    5,
    '电话咨询体验很好',
    '通过电话咨询了服务详情，客服人员非常专业，回答了我的所有问题，态度也很友好。服务介绍很详细，价格也很透明，没有隐藏费用。虽然还没有实际使用服务，但咨询体验已经让我很满意了。',
    5,
    5,
    NULL, -- 电话咨询没有环境评分
    '[]'::jsonb,
    '["服务热情", "专业细致", "价格透明"]'::jsonb,
    '["服务", "价格"]'::jsonb,
    false,
    false,
    'published',
    now()
);

-- 场景3：在线互动评价
INSERT INTO public.reviews (
    service_id, 
    reviewer_id, 
    reviewee_id, 
    order_id,
    review_type,
    source_description,
    overall_rating,
    title,
    content,
    service_rating,
    value_rating,
    atmosphere_rating,
    images,
    tags,
    categories,
    is_anonymous,
    is_verified,
    status,
    published_at
) VALUES (
    (SELECT id FROM public.services LIMIT 1),
    '00000000-0000-0000-0000-000000000003',
    (SELECT id FROM public.provider_profiles LIMIT 1),
    NULL,
    'online_interaction',
    '在网站上浏览了服务信息，界面很友好，信息很全面',
    4,
    '网站体验不错',
    '在网站上浏览了这家店的服务信息，网站设计很友好，信息展示很全面，价格也很清晰。在线客服响应很快，回答了我的问题。整体来说，在线体验很好，让我对这家店有了初步的了解。',
    4,
    4,
    NULL,
    '[]'::jsonb,
    '["响应迅速", "信息全面"]'::jsonb,
    '["服务"]'::jsonb,
    false,
    false,
    'published',
    now()
);

-- 场景4：环境感知评价
INSERT INTO public.reviews (
    service_id, 
    reviewer_id, 
    reviewee_id, 
    order_id,
    review_type,
    source_description,
    overall_rating,
    title,
    content,
    service_rating,
    value_rating,
    atmosphere_rating,
    images,
    tags,
    categories,
    is_anonymous,
    is_verified,
    status,
    published_at
) VALUES (
    (SELECT id FROM public.services LIMIT 1),
    '00000000-0000-0000-0000-000000000004',
    (SELECT id FROM public.provider_profiles LIMIT 1),
    NULL,
    'environmental',
    '路过看到店面很干净，装修很有特色',
    3,
    '店面环境不错',
    '路过这家店，从外面看店面很干净整洁，装修风格很有特色，给人感觉很专业。虽然没有进去，但从外观来看，应该是一家不错的店。',
    NULL, -- 环境感知评价没有服务评分
    NULL,
    4,
    '[]'::jsonb,
    '["环境优雅", "装修精美"]'::jsonb,
    '["环境"]'::jsonb,
    false,
    false,
    'published',
    now()
);

-- 场景5：匿名评价
INSERT INTO public.reviews (
    service_id, 
    reviewer_id, 
    reviewee_id, 
    order_id,
    review_type,
    source_description,
    overall_rating,
    title,
    content,
    service_rating,
    value_rating,
    atmosphere_rating,
    images,
    tags,
    categories,
    is_anonymous,
    is_verified,
    status,
    published_at
) VALUES (
    (SELECT id FROM public.services LIMIT 1),
    '00000000-0000-0000-0000-000000000005',
    (SELECT id FROM public.provider_profiles LIMIT 1),
    NULL,
    'visit_based',
    '到店体验了服务，整体感觉不错',
    4,
    '整体体验不错',
    '到店体验了一下服务，整体感觉不错。环境很舒适，服务人员态度也很好。价格方面也比较合理。',
    4,
    4,
    4,
    '[]'::jsonb,
    '["环境优雅", "服务热情", "价格合理"]'::jsonb,
    '["环境", "服务", "价格"]'::jsonb,
    true, -- 匿名评价
    false,
    'published',
    now()
);

-- 4. 插入评价来源数据
INSERT INTO public.review_sources (
    review_id,
    source_type,
    source_description,
    visit_date,
    interaction_channel,
    experience_duration,
    interaction_quality,
    environment_rating
) VALUES
-- 到店体验
((SELECT id FROM public.reviews WHERE review_type = 'visit_based' AND is_anonymous = false LIMIT 1),
 'visit_based',
 '到店咨询了服务内容和价格',
 CURRENT_DATE,
 'in-person',
 30,
 4,
 5),

-- 咨询体验
((SELECT id FROM public.reviews WHERE review_type = 'consultation' LIMIT 1),
 'consultation',
 '电话咨询了服务详情',
 CURRENT_DATE,
 'phone',
 15,
 5,
 NULL),

-- 在线互动
((SELECT id FROM public.reviews WHERE review_type = 'online_interaction' LIMIT 1),
 'online_interaction',
 '在网站上浏览了服务信息',
 CURRENT_DATE,
 'online',
 20,
 4,
 NULL),

-- 环境感知
((SELECT id FROM public.reviews WHERE review_type = 'environmental' LIMIT 1),
 'environmental',
 '路过看到店面很干净',
 CURRENT_DATE,
 'walk-by',
 5,
 NULL,
 4),

-- 匿名评价
((SELECT id FROM public.reviews WHERE is_anonymous = true LIMIT 1),
 'visit_based',
 '到店体验了服务',
 CURRENT_DATE,
 'in-person',
 45,
 4,
 4);

-- 5. 插入评价质量评估数据
INSERT INTO public.review_quality_metrics (
    review_id,
    content_length,
    has_images,
    has_videos,
    tag_count,
    helpful_votes,
    total_votes,
    reply_count,
    content_quality_score,
    engagement_score,
    overall_quality_score
) 
SELECT 
    r.id,
    LENGTH(r.content),
    (r.images != '[]'::jsonb),
    (r.videos != '[]'::jsonb),
    jsonb_array_length(r.tags),
    r.helpful_count,
    r.total_votes,
    0, -- 暂时没有回复
    CASE 
        WHEN LENGTH(r.content) > 100 THEN 0.9
        WHEN LENGTH(r.content) > 50 THEN 0.7
        ELSE 0.5
    END,
    CASE 
        WHEN r.helpful_count > 5 THEN 0.9
        WHEN r.helpful_count > 2 THEN 0.7
        ELSE 0.5
    END,
    CASE 
        WHEN LENGTH(r.content) > 100 AND r.helpful_count > 2 THEN 0.9
        WHEN LENGTH(r.content) > 50 AND r.helpful_count > 0 THEN 0.7
        ELSE 0.5
    END
FROM public.reviews r
WHERE r.status = 'published';

-- 6. 插入一些评价互动数据
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

((SELECT id FROM public.reviews WHERE review_type = 'online_interaction' LIMIT 1),
 '00000000-0000-0000-0000-000000000004',
 'helpful'),

-- 点赞
((SELECT id FROM public.reviews WHERE review_type = 'visit_based' AND is_anonymous = false LIMIT 1),
 '00000000-0000-0000-0000-000000000003',
 'like'),

((SELECT id FROM public.reviews WHERE review_type = 'consultation' LIMIT 1),
 '00000000-0000-0000-0000-000000000004',
 'like');

-- 7. 更新评价统计
UPDATE public.reviews 
SET helpful_count = (
    SELECT COUNT(*) 
    FROM public.review_interactions 
    WHERE review_id = reviews.id AND interaction_type = 'helpful'
),
total_votes = (
    SELECT COUNT(*) 
    FROM public.review_interactions 
    WHERE review_id = reviews.id AND interaction_type IN ('helpful', 'not_helpful')
)
WHERE id IN (SELECT id FROM public.reviews WHERE status = 'published');

-- 8. 验证数据
DO $$
DECLARE
    review_count integer;
    non_order_count integer;
    verified_count integer;
    anonymous_count integer;
BEGIN
    -- 统计评价数量
    SELECT COUNT(*) INTO review_count FROM public.reviews WHERE status = 'published';
    SELECT COUNT(*) INTO non_order_count FROM public.reviews WHERE order_id IS NULL AND status = 'published';
    SELECT COUNT(*) INTO verified_count FROM public.reviews WHERE is_verified = true AND status = 'published';
    SELECT COUNT(*) INTO anonymous_count FROM public.reviews WHERE is_anonymous = true AND status = 'published';
    
    RAISE NOTICE '=== 非订单评价系统测试数据统计 ===';
    RAISE NOTICE '总评价数: %', review_count;
    RAISE NOTICE '非订单评价数: %', non_order_count;
    RAISE NOTICE '认证评价数: %', verified_count;
    RAISE NOTICE '匿名评价数: %', anonymous_count;
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
    
    RAISE NOTICE '=== 测试数据插入完成 ===';
END $$;






