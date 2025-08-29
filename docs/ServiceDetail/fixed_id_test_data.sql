-- =====================================================
-- JinBean Platform - 固定ID测试数据脚本
-- 用于确保ServiceDetailPage能正确加载真实数据
-- =====================================================

-- 清理现有测试数据（可选）
-- DELETE FROM service_details WHERE service_id IN (
--   'test-service-001', 'test-service-002', 'test-service-003'
-- );
-- DELETE FROM services WHERE id IN (
--   'test-service-001', 'test-service-002', 'test-service-003'
-- );
-- DELETE FROM provider_profiles WHERE id IN (
--   'test-provider-001', 'test-provider-002', 'test-provider-003'
-- );

-- =====================================================
-- 第一部分：插入固定ID的提供商数据
-- =====================================================

INSERT INTO provider_profiles (
    id, display_name, bio, avatar_url, phone, email, 
    rating, review_count, status, provider_type, is_certified,
    experience_years, tags, custom_fields, created_at, updated_at
) VALUES 
-- 张妈妈川菜工坊
('550e8400-e29b-41d4-a716-446655440001', 
 '{"zh": "张妈妈川菜工坊", "en": "Auntie Zhang''s Sichuan Kitchen"}',
 '{"zh": "20年川菜制作经验，社区认证美食服务商，专注正宗川菜制作", "en": "20 years of Sichuan cuisine experience, community-certified food service provider, specializing in authentic Sichuan dishes"}',
 'https://picsum.photos/id/300/200/200',
 '+1-416-555-0101', 'zhangmama@jinbean.ca', 
 4.8, 156, 'active', 'individual', true,
 20, ARRAY['川菜', '麻辣', '家常菜'], 
 '{"specialties": ["川菜", "麻辣", "家常菜"], "certifications": ["社区认证", "食品安全"], "languages": ["中文", "英文"]}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- 龙腾中餐厅
('550e8400-e29b-41d4-a716-446655440002', 
 '{"zh": "龙腾中餐厅", "en": "Dragon Palace Chinese Restaurant"}',
 '{"zh": "高档中餐厅，专业服务团队，适合商务宴请和特殊场合", "en": "Fine Chinese restaurant, professional service team, perfect for business dinners and special occasions"}',
 'https://picsum.photos/id/302/200/200',
 '+1-416-555-0103', 'dragonpalace@jinbean.ca', 
 4.9, 234, 'active', 'corporate', true,
 25, ARRAY['粤菜', '商务宴请', '高档服务'], 
 '{"specialties": ["粤菜", "商务宴请", "高档服务"], "certifications": ["食品安全", "商务认证"], "languages": ["中文", "英文"]}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- 樱花日料
('550e8400-e29b-41d4-a716-446655440003', 
 '{"zh": "樱花日料", "en": "Sakura Japanese Restaurant"}',
 '{"zh": "正宗日式料理，新鲜寿司，专业日料师傅", "en": "Authentic Japanese cuisine, fresh sushi, professional Japanese chefs"}',
 'https://picsum.photos/id/303/200/200',
 '+1-416-555-0104', 'sakura@jinbean.ca', 
 4.6, 178, 'active', 'corporate', true,
 15, ARRAY['日料', '寿司', '新鲜'], 
 '{"specialties": ["日料", "寿司", "新鲜"], "certifications": ["食品安全", "日料认证"], "languages": ["中文", "英文", "日文"]}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)

ON CONFLICT (id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    bio = EXCLUDED.bio,
    avatar_url = EXCLUDED.avatar_url,
    phone = EXCLUDED.phone,
    email = EXCLUDED.email,
    rating = EXCLUDED.rating,
    review_count = EXCLUDED.review_count,
    status = EXCLUDED.status,
    provider_type = EXCLUDED.provider_type,
    is_certified = EXCLUDED.is_certified,
    experience_years = EXCLUDED.experience_years,
    tags = EXCLUDED.tags,
    custom_fields = EXCLUDED.custom_fields,
    updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 第二部分：插入固定ID的服务数据
-- =====================================================

INSERT INTO services (
    id, provider_id, title, description, category_level1_id, category_level2_id, 
    status, average_rating, review_count, service_delivery_method, 
    latitude, longitude, images_url, created_at, updated_at
) VALUES 
-- 张妈妈川菜工坊服务
('550e8400-e29b-41d4-a716-446655440101', '550e8400-e29b-41d4-a716-446655440001', 
 '{"zh": "张妈妈川菜工坊", "en": "Auntie Zhang''s Sichuan Kitchen"}', 
 '{"zh": "社区认证的川菜制作，正宗麻辣味道，温馨家常", "en": "Community-certified Sichuan cuisine, authentic spicy flavors, warm home-style"}', 
 '1010000', '1010100', 'active', 4.8, 156, 'delivery', 
 43.6532, -79.3832, 
 '["https://picsum.photos/id/300/800/600", "https://picsum.photos/id/301/800/600"]',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- 龙腾中餐厅服务
('550e8400-e29b-41d4-a716-446655440102', '550e8400-e29b-41d4-a716-446655440002', 
 '{"zh": "龙腾中餐厅", "en": "Dragon Palace Chinese Restaurant"}', 
 '{"zh": "高档中餐厅，专业服务，适合商务宴请", "en": "Fine Chinese restaurant, professional service, perfect for business dinners"}', 
 '1010000', '1010200', 'active', 4.9, 234, 'on_site', 
 43.6532, -79.3832, 
 '["https://picsum.photos/id/302/800/600", "https://picsum.photos/id/303/800/600"]',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- 樱花日料服务
('550e8400-e29b-41d4-a716-446655440103', '550e8400-e29b-41d4-a716-446655440003', 
 '{"zh": "樱花日料", "en": "Sakura Japanese Restaurant"}', 
 '{"zh": "正宗日式料理，新鲜寿司，专业日料师傅", "en": "Authentic Japanese cuisine, fresh sushi, professional Japanese chefs"}', 
 '1010000', '1010200', 'active', 4.6, 178, 'on_site', 
 43.6532, -79.3832, 
 '["https://picsum.photos/id/304/800/600", "https://picsum.photos/id/305/800/600"]',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)

ON CONFLICT (id) DO UPDATE SET
    provider_id = EXCLUDED.provider_id,
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    category_level1_id = EXCLUDED.category_level1_id,
    category_level2_id = EXCLUDED.category_level2_id,
    status = EXCLUDED.status,
    average_rating = EXCLUDED.average_rating,
    review_count = EXCLUDED.review_count,
    service_delivery_method = EXCLUDED.service_delivery_method,
    latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude,
    images_url = EXCLUDED.images_url,
    updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 第三部分：插入固定ID的服务详情数据
-- =====================================================

-- 为张妈妈川菜工坊添加服务详情
INSERT INTO service_details (
    service_id, pricing_type, price, currency, duration_type, duration,
    images_url, videos_url, tags, service_area_codes, name, category, sub_category,
    is_available, current_stock, max_stock, attributes, business_rules, created_at, updated_at
) VALUES 
-- 宫保鸡丁
('550e8400-e29b-41d4-a716-446655440101', 'fixed_price', 18.99, 'CAD', 'hours', '1 hour',
 ARRAY['https://picsum.photos/id/247/400/300'], ARRAY[]::text[],
 ARRAY['川菜', '辣', '鸡肉'], ARRAY['M5H', 'M5J', 'M5K'],
 '{"zh": "宫保鸡丁", "en": "Kung Pao Chicken"}', 'main_course', 'main_course',
 true, 10, 20,
 '{"spicy_level": "medium", "cooking_time": "15 minutes", "serving_size": "1 person"}',
 '{"ingredients": ["鸡肉", "花生", "干辣椒", "花椒"], "allergens": ["花生", "大豆"], "nutrition": {"calories": 350, "protein": 25, "carbs": 15}}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- 麻婆豆腐
('550e8400-e29b-41d4-a716-446655440101', 'fixed_price', 15.99, 'CAD', 'hours', '1 hour',
 ARRAY['https://picsum.photos/id/248/400/300'], ARRAY[]::text[],
 ARRAY['川菜', '辣', '豆腐'], ARRAY['M5H', 'M5J', 'M5K'],
 '{"zh": "麻婆豆腐", "en": "Mapo Tofu"}', 'main_course', 'main_course',
 true, 8, 15,
 '{"spicy_level": "high", "cooking_time": "10 minutes", "serving_size": "1 person"}',
 '{"ingredients": ["豆腐", "猪肉末", "豆瓣酱", "花椒"], "allergens": ["大豆"], "nutrition": {"calories": 280, "protein": 18, "carbs": 12}}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- 回锅肉
('550e8400-e29b-41d4-a716-446655440101', 'fixed_price', 22.99, 'CAD', 'hours', '1 hour',
 ARRAY['https://picsum.photos/id/249/400/300'], ARRAY[]::text[],
 ARRAY['川菜', '辣', '猪肉'], ARRAY['M5H', 'M5J', 'M5K'],
 '{"zh": "回锅肉", "en": "Twice-cooked Pork"}', 'main_course', 'main_course',
 true, 5, 12,
 '{"spicy_level": "medium", "cooking_time": "20 minutes", "serving_size": "1 person"}',
 '{"ingredients": ["五花肉", "青椒", "豆瓣酱", "甜面酱"], "allergens": ["大豆", "小麦"], "nutrition": {"calories": 420, "protein": 28, "carbs": 18}}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- 为龙腾中餐厅添加服务详情
-- 白切鸡
('550e8400-e29b-41d4-a716-446655440102', 'fixed_price', 28.99, 'CAD', 'hours', '1 hour',
 ARRAY['https://picsum.photos/id/250/400/300'], ARRAY[]::text[],
 ARRAY['粤菜', '清淡', '鸡肉'], ARRAY['M5H', 'M5J', 'M5K'],
 '{"zh": "白切鸡", "en": "White Cut Chicken"}', 'main_course', 'main_course',
 true, 6, 10,
 '{"spicy_level": "none", "cooking_time": "30 minutes", "serving_size": "1 person"}',
 '{"ingredients": ["鸡肉", "姜", "葱", "料酒"], "allergens": [], "nutrition": {"calories": 320, "protein": 35, "carbs": 5}}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- 清蒸鲈鱼
('550e8400-e29b-41d4-a716-446655440102', 'fixed_price', 35.99, 'CAD', 'hours', '1 hour',
 ARRAY['https://picsum.photos/id/251/400/300'], ARRAY[]::text[],
 ARRAY['粤菜', '清淡', '鱼类'], ARRAY['M5H', 'M5J', 'M5K'],
 '{"zh": "清蒸鲈鱼", "en": "Steamed Sea Bass"}', 'main_course', 'main_course',
 true, 4, 8,
 '{"spicy_level": "none", "cooking_time": "25 minutes", "serving_size": "1 person"}',
 '{"ingredients": ["鲈鱼", "姜丝", "葱丝", "蒸鱼豉油"], "allergens": ["鱼类"], "nutrition": {"calories": 280, "protein": 32, "carbs": 3}}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- 为樱花日料添加服务详情
-- 三文鱼寿司
('550e8400-e29b-41d4-a716-446655440103', 'fixed_price', 24.99, 'CAD', 'hours', '1 hour',
 ARRAY['https://picsum.photos/id/252/400/300'], ARRAY[]::text[],
 ARRAY['日料', '寿司', '三文鱼'], ARRAY['M5H', 'M5J', 'M5K'],
 '{"zh": "三文鱼寿司", "en": "Salmon Sushi"}', 'sushi', 'sushi',
 true, 12, 20,
 '{"spicy_level": "none", "cooking_time": "5 minutes", "serving_size": "1 person"}',
 '{"ingredients": ["三文鱼", "寿司米", "海苔", "芥末"], "allergens": ["鱼类", "大豆"], "nutrition": {"calories": 180, "protein": 15, "carbs": 25}}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- 天妇罗
('550e8400-e29b-41d4-a716-446655440103', 'fixed_price', 19.99, 'CAD', 'hours', '1 hour',
 ARRAY['https://picsum.photos/id/253/400/300'], ARRAY[]::text[],
 ARRAY['日料', '天妇罗', '炸物'], ARRAY['M5H', 'M5J', 'M5K'],
 '{"zh": "天妇罗", "en": "Tempura"}', 'appetizer', 'appetizer',
 true, 8, 15,
 '{"spicy_level": "none", "cooking_time": "8 minutes", "serving_size": "1 person"}',
 '{"ingredients": ["虾", "蔬菜", "天妇罗粉", "油"], "allergens": ["虾", "小麦"], "nutrition": {"calories": 220, "protein": 12, "carbs": 18}}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)

ON CONFLICT (service_id, category, name) DO UPDATE SET
    pricing_type = EXCLUDED.pricing_type,
    price = EXCLUDED.price,
    currency = EXCLUDED.currency,
    duration_type = EXCLUDED.duration_type,
    duration = EXCLUDED.duration,
    images_url = EXCLUDED.images_url,
    videos_url = EXCLUDED.videos_url,
    tags = EXCLUDED.tags,
    service_area_codes = EXCLUDED.service_area_codes,
    category = EXCLUDED.category,
    sub_category = EXCLUDED.sub_category,
    is_available = EXCLUDED.is_available,
    current_stock = EXCLUDED.current_stock,
    max_stock = EXCLUDED.max_stock,
    attributes = EXCLUDED.attributes,
    business_rules = EXCLUDED.business_rules,
    updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 完成提示
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '固定ID测试数据插入完成！';
    RAISE NOTICE '可用的测试服务ID:';
    RAISE NOTICE '  - 550e8400-e29b-41d4-a716-446655440101 (张妈妈川菜工坊)';
    RAISE NOTICE '  - 550e8400-e29b-41d4-a716-446655440102 (龙腾中餐厅)';
    RAISE NOTICE '  - 550e8400-e29b-41d4-a716-446655440103 (樱花日料)';
    RAISE NOTICE '每个服务都有多个服务详情，可以测试Menu Tab功能';
END $$;
