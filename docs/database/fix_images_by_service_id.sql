-- ============================================
-- 修复图片URL - 使用实际的Service ID
-- ============================================
-- 此脚本直接使用从app日志中看到的service ID来更新图片

-- ============================================
-- 更新Sparkle Clean Services的图片
-- Service ID: c46e45a3-6315-493c-b217-ac50622c03c9
-- ============================================

-- 首先验证这个service存在
SELECT id, title->>'en' as title, category_level1_id
FROM services
WHERE id = 'c46e45a3-6315-493c-b217-ac50622c03c9';

-- 更新Services表的images_url (jsonb类型)
UPDATE services
SET images_url = '[
  "https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800",
  "https://images.unsplash.com/photo-1585421514738-01798e348b17?w=800",
  "https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?w=800"
]'::jsonb
WHERE id = 'c46e45a3-6315-493c-b217-ac50622c03c9';

-- 查看该服务的所有service_details
SELECT id, name->>'en' as item_name, category, sort_order, images_url
FROM service_details
WHERE service_id = 'c46e45a3-6315-493c-b217-ac50622c03c9'
ORDER BY sort_order;

-- 更新Service Details的images_url (text[]类型)
-- Regular Cleaning (第1个 - sort_order=1)
UPDATE service_details
SET images_url = ARRAY['https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=600']
WHERE service_id = 'c46e45a3-6315-493c-b217-ac50622c03c9'
AND sort_order = 1;

-- Deep Cleaning (第2个 - sort_order=2)
UPDATE service_details
SET images_url = ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?w=600']
WHERE service_id = 'c46e45a3-6315-493c-b217-ac50622c03c9'
AND sort_order = 2;

-- Window Cleaning (第3个 - sort_order=3)
UPDATE service_details
SET images_url = ARRAY['https://images.unsplash.com/photo-1585421514738-01798e348b17?w=600']
WHERE service_id = 'c46e45a3-6315-493c-b217-ac50622c03c9'
AND sort_order = 3;

-- Carpet Cleaning (第4个 - sort_order=4)
UPDATE service_details
SET images_url = ARRAY['https://images.unsplash.com/photo-1558317374-067fb5f30001?w=600']
WHERE service_id = 'c46e45a3-6315-493c-b217-ac50622c03c9'
AND sort_order = 4;

-- Move-in/Move-out Cleaning (第5个 - sort_order=5)
UPDATE service_details
SET images_url = ARRAY['https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600']
WHERE service_id = 'c46e45a3-6315-493c-b217-ac50622c03c9'
AND sort_order = 5;

-- ============================================
-- 更新Golden Wok Restaurant的图片
-- Service ID: 76be73fa-4d2c-4580-81b4-2808f56f701d
-- ============================================

-- 验证service存在
SELECT id, title->>'en' as title, category_level1_id
FROM services
WHERE id = '76be73fa-4d2c-4580-81b4-2808f56f701d';

-- 更新Services表的images_url
UPDATE services
SET images_url = '[
  "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800",
  "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800",
  "https://images.unsplash.com/photo-1552566626-52f8b828add9?w=800"
]'::jsonb
WHERE id = '76be73fa-4d2c-4580-81b4-2808f56f701d';

-- 查看该服务的所有service_details
SELECT id, name->>'en' as item_name, category, sort_order, images_url
FROM service_details
WHERE service_id = '76be73fa-4d2c-4580-81b4-2808f56f701d'
ORDER BY sort_order;

-- 更新Golden Wok的菜单项图片
UPDATE service_details sd
SET images_url = CASE
    WHEN sd.name->>'en' LIKE '%Spring Roll%' THEN ARRAY['https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?w=600']
    WHEN sd.name->>'en' LIKE '%Dumpling%' THEN ARRAY['https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=600']
    WHEN sd.name->>'en' LIKE '%Edamame%' THEN ARRAY['https://images.unsplash.com/photo-1609501676725-7186f017a4b7?w=600']
    WHEN sd.name->>'en' LIKE '%Noodle%' THEN ARRAY['https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600']
    WHEN sd.name->>'en' LIKE '%Chicken%' THEN ARRAY['https://images.unsplash.com/photo-1603073477867-e4d1eb87e120?w=600']
    WHEN sd.name->>'en' LIKE '%Pork%' THEN ARRAY['https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=600']
    WHEN sd.name->>'en' LIKE '%Mango%' THEN ARRAY['https://images.unsplash.com/photo-1519915028121-7d3463d20b13?w=600']
    WHEN sd.name->>'en' LIKE '%Sesame%' THEN ARRAY['https://images.unsplash.com/photo-1563379091339-03b2cb2f39b7?w=600']
    ELSE sd.images_url
END
WHERE service_id = '76be73fa-4d2c-4580-81b4-2808f56f701d'
AND category = 'menu_item';

-- ============================================
-- 验证更新结果
-- ============================================

-- 检查Services的图片
SELECT
    id,
    title->>'en' as service_title,
    category_level1_id,
    jsonb_array_length(images_url) as image_count,
    images_url->0 as first_image
FROM services
WHERE id IN (
    'c46e45a3-6315-493c-b217-ac50622c03c9',
    '76be73fa-4d2c-4580-81b4-2808f56f701d'
);

-- 检查Service Details的图片
SELECT
    s.title->>'en' as service_title,
    sd.name->>'en' as item_name,
    sd.sort_order,
    CASE
        WHEN sd.images_url IS NULL THEN 'NULL'
        WHEN array_length(sd.images_url, 1) > 0 THEN 'HAS IMAGES (' || array_length(sd.images_url, 1)::text || ')'
        ELSE 'EMPTY ARRAY'
    END as image_status,
    sd.images_url[1] as first_image_url
FROM service_details sd
JOIN services s ON s.id = sd.service_id
WHERE sd.service_id IN (
    'c46e45a3-6315-493c-b217-ac50622c03c9',
    '76be73fa-4d2c-4580-81b4-2808f56f701d'
)
ORDER BY s.title->>'en', sd.sort_order;

-- ============================================
-- 完成！
-- ============================================
