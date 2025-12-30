-- ============================================
-- 更新测试数据 - 添加真实图片URL
-- ============================================
-- 此脚本为现有的测试服务和服务详情添加Unsplash图片URL
-- 使用真实可访问的图片URL替代placeholder

-- ============================================
-- STEP 1: 更新Services的图片
-- ============================================

-- 1. 餐饮服务 (Golden Wok Restaurant)
UPDATE services
SET images_url = '["https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800", "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800", "https://images.unsplash.com/photo-1552566626-52f8b828add9?w=800"]'::jsonb
WHERE title->>'en' = 'Golden Wok Restaurant';

-- 2. 家政服务 (Sparkle Clean Services)
UPDATE services
SET images_url = '["https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800", "https://images.unsplash.com/photo-1585421514738-01798e348b17?w=800", "https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?w=800"]'::jsonb
WHERE title->>'en' = 'Sparkle Clean Services';

-- 3. 租赁服务 (Tool Rental Pro)
UPDATE services
SET images_url = '["https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=800", "https://images.unsplash.com/photo-1530124566582-a618bc2615dc?w=800", "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800"]'::jsonb
WHERE title->>'en' = 'Tool Rental Pro';

-- 4. 教育服务 (English Language Academy)
UPDATE services
SET images_url = '["https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=800", "https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800", "https://images.unsplash.com/photo-1488190211105-8b0e65b80b4e?w=800"]'::jsonb
WHERE title->>'en' = 'English Language Academy';

-- 5. 健康服务 (Wellness Clinic)
UPDATE services
SET images_url = '["https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800", "https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=800", "https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800"]'::jsonb
WHERE title->>'en' = 'Wellness Clinic';

-- ============================================
-- STEP 2: 更新Service Details的图片
-- ============================================

-- 2.1 餐饮菜单项图片 (Menu Items)
DO $$
DECLARE
    v_service_id uuid;
BEGIN
    SELECT id INTO v_service_id
    FROM services
    WHERE title->>'en' = 'Golden Wok Restaurant'
    LIMIT 1;

    IF v_service_id IS NOT NULL THEN
        -- Spring Rolls
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Spring Rolls';

        -- Fried Dumplings
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Fried Dumplings';

        -- Edamame
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1609501676725-7186f017a4b7?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Edamame';

        -- Beef Noodle Soup
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Beef Noodle Soup';

        -- Kung Pao Chicken
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1603073477867-e4d1eb87e120?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Kung Pao Chicken';

        -- Sweet and Sour Pork
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Sweet and Sour Pork';

        -- Mango Sticky Rice
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1519915028121-7d3463d20b13?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Mango Sticky Rice';

        -- Sesame Balls
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1563379091339-03b2cb2f39b7?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Sesame Balls';

        RAISE NOTICE 'Updated images for Food Service menu items';
    END IF;
END $$;

-- 2.2 家政服务套餐图片 (Cleaning Service Packages)
DO $$
DECLARE
    v_service_id uuid;
BEGIN
    SELECT id INTO v_service_id
    FROM services
    WHERE title->>'en' = 'Sparkle Clean Services'
    LIMIT 1;

    IF v_service_id IS NOT NULL THEN
        -- Regular Cleaning
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Regular Cleaning';

        -- Deep Cleaning
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Deep Cleaning';

        -- Window Cleaning
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1585421514738-01798e348b17?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Window Cleaning';

        -- Carpet Cleaning
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1558317374-067fb5f30001?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Carpet Cleaning';

        -- Move-in/Move-out Cleaning
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Move-in/Move-out Cleaning';

        RAISE NOTICE 'Updated images for Home Service packages';
    END IF;
END $$;

-- 2.3 租赁工具图片 (Rental Items)
DO $$
DECLARE
    v_service_id uuid;
BEGIN
    SELECT id INTO v_service_id
    FROM services
    WHERE title->>'en' = 'Tool Rental Pro'
    LIMIT 1;

    IF v_service_id IS NOT NULL THEN
        -- Power Drill
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1504148455328-c376907d081c?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Power Drill';

        -- Circular Saw
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1572981779307-38b8cabb2407?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Circular Saw';

        -- Ladder - 6ft
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Ladder - 6ft';

        -- Ladder - 12ft
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Ladder - 12ft';

        -- Professional Tool Set
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1530124566582-a618bc2615dc?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Professional Tool Set';

        -- Pressure Washer
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Pressure Washer';

        RAISE NOTICE 'Updated images for Rental Service items';
    END IF;
END $$;

-- 2.4 教育课程图片 (Education Courses)
DO $$
DECLARE
    v_service_id uuid;
BEGIN
    SELECT id INTO v_service_id
    FROM services
    WHERE title->>'en' = 'English Language Academy'
    LIMIT 1;

    IF v_service_id IS NOT NULL THEN
        -- English Beginner Level
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'English Beginner Level';

        -- English Intermediate Level
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'English Intermediate Level';

        -- English Advanced Level
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1488190211105-8b0e65b80b4e?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'English Advanced Level';

        -- Business English
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1552581234-26160f608093?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Business English';

        -- IELTS Preparation
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'IELTS Preparation';

        RAISE NOTICE 'Updated images for Education Service courses';
    END IF;
END $$;

-- 2.5 健康治疗图片 (Health Treatments)
DO $$
DECLARE
    v_service_id uuid;
BEGIN
    SELECT id INTO v_service_id
    FROM services
    WHERE title->>'en' = 'Wellness Clinic'
    LIMIT 1;

    IF v_service_id IS NOT NULL THEN
        -- Initial Consultation
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Initial Consultation';

        -- Massage Therapy
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Massage Therapy';

        -- Acupuncture Session
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1519824145371-296894a0daa9?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Acupuncture Session';

        -- Follow-up Visit
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1538108149393-fbbd81895907?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Follow-up Visit';

        -- Physiotherapy Session
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Physiotherapy Session';

        -- Chiropractic Adjustment
        UPDATE service_details
        SET images_url = ARRAY['https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=600']
        WHERE service_id = v_service_id AND name->>'en' = 'Chiropractic Adjustment';

        RAISE NOTICE 'Updated images for Health Service treatments';
    END IF;
END $$;

-- ============================================
-- STEP 3: 验证更新
-- ============================================

-- 检查Services图片
SELECT
    title->>'en' as service_title,
    category_level1_id,
    CASE
        WHEN category_level1_id = 1010000 THEN 'Food'
        WHEN category_level1_id = 1020000 THEN 'Home Services'
        WHEN category_level1_id = 1040000 THEN 'Rental'
        WHEN category_level1_id = 1050000 THEN 'Education'
        WHEN category_level1_id = 1060000 THEN 'Health'
    END as category_name,
    jsonb_array_length(images_url) as image_count,
    images_url->0 as first_image
FROM services
WHERE title->>'en' IN (
    'Golden Wok Restaurant',
    'Sparkle Clean Services',
    'Tool Rental Pro',
    'English Language Academy',
    'Wellness Clinic'
)
ORDER BY category_level1_id;

-- 检查Service Details图片
SELECT
    s.title->>'en' as service_title,
    sd.category,
    sd.name->>'en' as item_name,
    CASE
        WHEN sd.images_url IS NULL THEN 'NO IMAGES'
        WHEN array_length(sd.images_url, 1) > 0 THEN 'HAS IMAGES (' || array_length(sd.images_url, 1)::text || ')'
        ELSE 'EMPTY ARRAY'
    END as image_status,
    sd.images_url[1] as first_image_url
FROM service_details sd
JOIN services s ON s.id = sd.service_id
WHERE sd.category IN ('menu_item', 'service_package', 'rental_item', 'course', 'treatment')
ORDER BY s.category_level1_id, sd.category, sd.sort_order;

-- ============================================
-- 完成！
-- ============================================
-- 所有测试数据现在都有真实的Unsplash图片URL
-- 这些图片URL可以在App中正常显示
