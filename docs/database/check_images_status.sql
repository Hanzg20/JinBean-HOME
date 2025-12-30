-- 检查服务的图片状态
SELECT
    s.id as service_id,
    s.title->>'en' as service_title,
    s.category_level1_id,
    CASE
        WHEN s.images_url IS NOT NULL THEN
            CASE
                WHEN jsonb_array_length(s.images_url) > 0 THEN 'HAS IMAGES (' || jsonb_array_length(s.images_url)::text || ')'
                ELSE 'EMPTY ARRAY'
            END
        ELSE 'NULL'
    END as images_status,
    s.images_url->0 as first_image
FROM services s
WHERE s.title->>'en' IN (
    'Golden Wok Restaurant',
    'Sparkle Clean Services',
    'Tool Rental Pro',
    'English Language Academy',
    'Wellness Clinic'
)
ORDER BY s.category_level1_id;

-- 检查Service Details的图片状态
SELECT
    s.title->>'en' as service_title,
    sd.id as detail_id,
    sd.category,
    sd.name->>'en' as item_name,
    CASE
        WHEN sd.images_url IS NULL THEN 'NULL'
        WHEN array_length(sd.images_url, 1) > 0 THEN 'HAS IMAGES (' || array_length(sd.images_url, 1)::text || ')'
        ELSE 'EMPTY ARRAY'
    END as image_status,
    sd.images_url[1] as first_image_url
FROM service_details sd
JOIN services s ON s.id = sd.service_id
WHERE s.title->>'en' IN (
    'Golden Wok Restaurant',
    'Sparkle Clean Services',
    'Tool Rental Pro',
    'English Language Academy',
    'Wellness Clinic'
)
AND sd.category IN ('menu_item', 'service_package', 'rental_item', 'course', 'treatment')
ORDER BY s.category_level1_id, sd.category, sd.sort_order;
