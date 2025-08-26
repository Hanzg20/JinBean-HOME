-- =====================================================
-- 添加美容美发分类到 ref_codes 表
-- 基于现有的分类结构，添加专门的美容美发分类
-- =====================================================

-- 开始事务
BEGIN;

-- 1. 添加美容美发二级分类 (在健康支持下)
INSERT INTO ref_codes (id, type_code, code, name, description, parent_id, level, sort_order, status, extra_data, created_at, updated_at)
VALUES (
    1060404, 
    'SERVICE_TYPE', 
    'BEAUTY_SALON', 
    '{"en": "Beauty & Salon", "zh": "美容美发", "fr": "Beauté & Salon"}', 
    '{"en": "Professional beauty and salon services", "zh": "专业美容美发服务", "fr": "Services professionnels de beauté et de salon"}', 
    1060000,  -- 父级：生活帮忙
    4,        -- 层级：二级
    5,        -- 排序：在健康支持(4)之后
    1,        -- 状态：启用
    '{"icon": "face", "color": "#FF69B4"}',  -- 图标和颜色
    CURRENT_TIMESTAMP, 
    CURRENT_TIMESTAMP
);

-- 2. 添加美容美发三级分类
INSERT INTO ref_codes (id, type_code, code, name, description, parent_id, level, sort_order, status, extra_data, created_at, updated_at)
VALUES 
-- 2.1 美发服务
(
    106040401, 
    'SERVICE_TYPE', 
    'HAIR_STYLING', 
    '{"en": "Hair Styling", "zh": "美发造型", "fr": "Coiffure"}', 
    '{"en": "Professional hair cutting, styling and coloring", "zh": "专业美发、造型和染发服务", "fr": "Coupe, coiffure et coloration professionnelles"}', 
    1060404,  -- 父级：美容美发
    3,        -- 层级：三级
    1,        -- 排序
    1,        -- 状态：启用
    '{"icon": "content_cut", "services": ["haircut", "styling", "coloring", "highlights"]}', 
    CURRENT_TIMESTAMP, 
    CURRENT_TIMESTAMP
),

-- 2.2 美容护理
(
    106040402, 
    'SERVICE_TYPE', 
    'SKIN_CARE', 
    '{"en": "Skin Care", "zh": "美容护理", "fr": "Soins de la Peau"}', 
    '{"en": "Professional skin care and facial treatments", "zh": "专业美容护理和面部护理", "fr": "Soins de la peau et traitements faciaux professionnels"}', 
    1060404,  -- 父级：美容美发
    3,        -- 层级：三级
    2,        -- 排序
    1,        -- 状态：启用
    '{"icon": "face", "services": ["facial", "cleansing", "moisturizing", "anti_aging"]}', 
    CURRENT_TIMESTAMP, 
    CURRENT_TIMESTAMP
),

-- 2.3 美甲服务
(
    106040403, 
    'SERVICE_TYPE', 
    'NAIL_SERVICES', 
    '{"en": "Nail Services", "zh": "美甲服务", "fr": "Services de Manucure"}', 
    '{"en": "Professional nail care and nail art", "zh": "专业美甲护理和指甲艺术", "fr": "Soins des ongles et art des ongles professionnels"}', 
    1060404,  -- 父级：美容美发
    3,        -- 层级：三级
    3,        -- 排序
    1,        -- 状态：启用
    '{"icon": "pan_tool", "services": ["manicure", "pedicure", "nail_art", "gel_nails"]}', 
    CURRENT_TIMESTAMP, 
    CURRENT_TIMESTAMP
),

-- 2.4 化妆服务
(
    106040404, 
    'SERVICE_TYPE', 
    'MAKEUP_SERVICES', 
    '{"en": "Makeup Services", "zh": "化妆服务", "fr": "Services de Maquillage"}', 
    '{"en": "Professional makeup for special occasions", "zh": "专业化妆服务，适用于特殊场合", "fr": "Maquillage professionnel pour occasions spéciales"}', 
    1060404,  -- 父级：美容美发
    3,        -- 层级：三级
    4,        -- 排序
    1,        -- 状态：启用
    '{"icon": "palette", "services": ["bridal_makeup", "party_makeup", "photography_makeup", "makeup_lessons"]}', 
    CURRENT_TIMESTAMP, 
    CURRENT_TIMESTAMP
),

-- 2.5 美体服务
(
    106040405, 
    'SERVICE_TYPE', 
    'BODY_TREATMENTS', 
    '{"en": "Body Treatments", "zh": "美体服务", "fr": "Soins du Corps"}', 
    '{"en": "Professional body care and wellness treatments", "zh": "专业美体护理和健康护理", "fr": "Soins du corps et traitements de bien-être professionnels"}', 
    1060404,  -- 父级：美容美发
    3,        -- 层级：三级
    5,        -- 排序
    1,        -- 状态：启用
    '{"icon": "accessibility", "services": ["massage", "body_wraps", "cellulite_treatment", "body_contouring"]}', 
    CURRENT_TIMESTAMP, 
    CURRENT_TIMESTAMP
);

-- 3. 验证插入结果
SELECT 
    'New Beauty Categories Added' as summary,
    COUNT(*) as total_categories_added
FROM ref_codes 
WHERE id IN (1060404, 106040401, 106040402, 106040403, 106040404, 106040405);

-- 4. 显示新添加的分类结构
SELECT 
    'Beauty Categories Structure' as check_type,
    id,
    name->>'en' as name_en,
    name->>'zh' as name_zh,
    level,
    parent_id,
    CASE 
        WHEN level = 2 THEN 'Secondary Category'
        WHEN level = 3 THEN 'Tertiary Category'
        ELSE 'Unknown Level'
    END as category_type
FROM ref_codes 
WHERE id IN (1060404, 106040401, 106040402, 106040403, 106040404, 106040405)
ORDER BY level, sort_order;

-- 5. 验证外键约束
SELECT 
    'Foreign Key Validation' as check_type,
    rc.id,
    rc.name->>'en' as category_name,
    rc.parent_id,
    parent.name->>'en' as parent_name,
    CASE 
        WHEN parent.id IS NOT NULL THEN 'Valid'
        ELSE 'Invalid - Parent not found'
    END as validation_status
FROM ref_codes rc
LEFT JOIN ref_codes parent ON rc.parent_id = parent.id
WHERE rc.id IN (1060404, 106040401, 106040402, 106040403, 106040404, 106040405)
ORDER BY rc.level, rc.id;

-- 提交事务
COMMIT;

-- =====================================================
-- 使用说明
-- =====================================================
/*
这个脚本添加了以下美容美发分类：

二级分类：
- 1060404: Beauty & Salon (美容美发)

三级分类：
- 106040401: Hair Styling (美发造型)
- 106040402: Skin Care (美容护理)  
- 106040403: Nail Services (美甲服务)
- 106040404: Makeup Services (化妆服务)
- 106040405: Body Treatments (美体服务)

现在您可以在测试数据中使用 1060404 作为美容美发的分类ID了！
*/
