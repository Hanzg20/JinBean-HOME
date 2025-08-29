-- =====================================================
-- JinBean Platform - 简单修复美食分类脚本
-- 避免复杂语法，直接执行更新
-- =====================================================

-- 1. 更新 1010100: 居家美食 -> 社区美食
UPDATE ref_codes 
SET 
    name = '{"zh": "社区美食", "en": "Community Food"}',
    extra_data = '{"icon": "community", "color": "#FF9800", "description_zh": "社区认证的美食服务，温馨家常，符合食品安全标准", "description_en": "Community-certified food services, warm and home-style, meeting food safety standards"}',
    sort_order = 1,
    updated_at = CURRENT_TIMESTAMP
WHERE id = 1010100;

-- 2. 更新 1010200: 定制美食 -> 餐厅预订
UPDATE ref_codes 
SET 
    name = '{"zh": "餐厅预订", "en": "Restaurant Booking"}',
    extra_data = '{"icon": "restaurant_menu", "color": "#9C27B0", "description_zh": "专业餐厅预订服务，品质保证，适合商务宴请和特殊场合", "description_en": "Professional restaurant booking services, quality guaranteed, perfect for business dinners and special occasions"}',
    sort_order = 2,
    updated_at = CURRENT_TIMESTAMP
WHERE id = 1010200;

-- 3. 更新 1010300: 世界美食 -> 团体餐饮
UPDATE ref_codes 
SET 
    name = '{"zh": "团体餐饮", "en": "Group Catering"}',
    extra_data = '{"icon": "event", "color": "#E91E63", "description_zh": "专业团体餐饮服务，适合婚礼、年会、生日派对等大型活动", "description_en": "Professional group catering services, perfect for weddings, corporate events, birthday parties and large gatherings"}',
    sort_order = 3,
    updated_at = CURRENT_TIMESTAMP
WHERE id = 1010300;

-- 4. 更新 1010400: 速食代购 -> 食材采购
UPDATE ref_codes 
SET 
    name = '{"zh": "食材采购", "en": "Ingredient Shopping"}',
    extra_data = '{"icon": "shopping_cart", "color": "#FF5722", "description_zh": "新鲜食材采购服务，包括进口食品、地方特产、生鲜配送等", "description_en": "Fresh ingredient shopping services, including imported foods, local specialties, fresh delivery and more"}',
    sort_order = 4,
    updated_at = CURRENT_TIMESTAMP
WHERE id = 1010400;

-- 5. 更新 1010500: 其它 -> 其它
UPDATE ref_codes 
SET 
    name = '{"zh": "其它", "en": "Others"}',
    extra_data = '{"icon": "more_horiz", "color": "#9E9E9E", "description_zh": "其他美食相关服务", "description_en": "Other food-related services"}',
    sort_order = 5,
    updated_at = CURRENT_TIMESTAMP
WHERE id = 1010500;

-- 6. 验证更新结果
SELECT 
    rc1.name->>'zh' as "一级分类",
    rc2.id as "分类ID",
    rc2.code as "分类代码",
    rc2.name->>'zh' as "二级分类",
    rc2.name->>'en' as "英文名称",
    rc2.sort_order as "排序",
    rc2.status as "状态",
    rc2.extra_data->>'icon' as "图标",
    rc2.extra_data->>'color' as "颜色"
FROM ref_codes rc1
LEFT JOIN ref_codes rc2 ON rc1.id = rc2.parent_id
WHERE rc1.type_code = 'SERVICE_TYPE' 
    AND rc1.level = 1 
    AND (rc1.name->>'zh' = '美食天地' OR rc1.name->>'en' = 'Food World')
ORDER BY rc2.sort_order;

-- 7. 最终统计
SELECT 
    '修复完成' as status,
    COUNT(*) as total_categories,
    COUNT(CASE WHEN level = 1 THEN 1 END) as level1_count,
    COUNT(CASE WHEN level = 2 THEN 1 END) as level2_count,
    COUNT(CASE WHEN status = 1 THEN 1 END) as active_count
FROM ref_codes 
WHERE type_code = 'SERVICE_TYPE' 
    AND (name->>'zh' LIKE '%美食%' OR name->>'en' LIKE '%Food%');
