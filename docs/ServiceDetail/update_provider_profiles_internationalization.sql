-- =====================================================
-- 更新 provider_profiles 表支持国际化
-- 将 display_name 和 bio 字段从 text 改为 jsonb 类型
-- =====================================================

-- 1. 备份现有数据
CREATE TABLE provider_profiles_backup AS 
SELECT * FROM provider_profiles;

-- 2. 创建临时列来存储转换后的数据
ALTER TABLE provider_profiles 
ADD COLUMN display_name_jsonb jsonb,
ADD COLUMN bio_jsonb jsonb;

-- 3. 将现有数据转换为JSON格式
-- 假设现有数据是英文，我们将其转换为多语言JSON格式
UPDATE provider_profiles 
SET 
    display_name_jsonb = CASE 
        WHEN display_name IS NOT NULL THEN 
            jsonb_build_object(
                'en', display_name,
                'zh', display_name,  -- 暂时使用英文作为中文，后续可以手动更新
                'fr', display_name   -- 暂时使用英文作为法文，后续可以手动更新
            )
        ELSE NULL
    END,
    bio_jsonb = CASE 
        WHEN bio IS NOT NULL THEN 
            jsonb_build_object(
                'en', bio,
                'zh', bio,  -- 暂时使用英文作为中文，后续可以手动更新
                'fr', bio   -- 暂时使用英文作为法文，后续可以手动更新
            )
        ELSE NULL
    END;

-- 4. 删除旧列
ALTER TABLE provider_profiles 
DROP COLUMN display_name,
DROP COLUMN bio;

-- 5. 重命名新列为原列名
ALTER TABLE provider_profiles 
RENAME COLUMN display_name_jsonb TO display_name;

ALTER TABLE provider_profiles 
RENAME COLUMN bio_jsonb TO bio;

-- 6. 验证数据转换结果
SELECT 
    'Data Conversion Verification' as check_type,
    id,
    display_name,
    bio
FROM provider_profiles 
LIMIT 5;

-- 7. 检查数据类型
SELECT 
    'Column Type Verification' as check_type,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'provider_profiles'
  AND column_name IN ('display_name', 'bio')
ORDER BY column_name;

-- 8. 更新测试数据为真正的多语言内容
UPDATE provider_profiles 
SET 
    display_name = CASE 
        WHEN email = 'info@bellaitalia.com' THEN 
            '{"en": "Bella Italia Restaurant", "zh": "贝拉意大利餐厅", "fr": "Restaurant Bella Italia"}'
        WHEN email = 'info@cleanpro.com' THEN 
            '{"en": "CleanPro Services", "zh": "清洁专家服务", "fr": "Services CleanPro"}'
        WHEN email = 'info@techprosolutions.com' THEN 
            '{"en": "TechPro Solutions", "zh": "科技专家解决方案", "fr": "Solutions TechPro"}'
        WHEN email = 'info@goldendragon.com' THEN 
            '{"en": "Golden Dragon Restaurant", "zh": "金龙餐厅", "fr": "Restaurant Dragon d''Or"}'
        WHEN email = 'info@sushimaster.com' THEN 
            '{"en": "Sushi Master", "zh": "寿司大师", "fr": "Maître Sushi"}'
        WHEN email = 'info@handymanexpress.com' THEN 
            '{"en": "Handyman Express", "zh": "万能手艺人", "fr": "Bricoleur Express"}'
        WHEN email = 'info@gardencareplus.com' THEN 
            '{"en": "Garden Care Plus", "zh": "花园护理专家", "fr": "Expert Jardinage Plus"}'
        WHEN email = 'info@petparadise.com' THEN 
            '{"en": "Pet Paradise", "zh": "宠物天堂", "fr": "Paradis des Animaux"}'
        WHEN email = 'info@protoolsrental.com' THEN 
            '{"en": "Pro Tools Rental", "zh": "专业工具租赁", "fr": "Location d''Outils Pro"}'
        WHEN email = 'info@webdevacademy.com' THEN 
            '{"en": "WebDev Academy", "zh": "网页开发学院", "fr": "Académie WebDev"}'
        WHEN email = 'info@languagecenter.com' THEN 
            '{"en": "Language Learning Center", "zh": "语言学习中心", "fr": "Centre d''Apprentissage des Langues"}'
        WHEN email = 'info@fitnesspro.com' THEN 
            '{"en": "Fitness Pro", "zh": "健身专家", "fr": "Expert Fitness"}'
        WHEN email = 'info@beautysalonelite.com' THEN 
            '{"en": "Beauty Salon Elite", "zh": "精英美容沙龙", "fr": "Salon de Beauté Elite"}'
        WHEN email = 'info@legalconsultpro.com' THEN 
            '{"en": "Legal Consult Pro", "zh": "法律咨询专家", "fr": "Expert Consultation Juridique"}'
        WHEN email = 'info@financialadvisorplus.com' THEN 
            '{"en": "Financial Advisor Plus", "zh": "理财顾问专家", "fr": "Expert Conseiller Financier"}'
        ELSE display_name
    END,
    bio = CASE 
        WHEN email = 'info@bellaitalia.com' THEN 
            '{"en": "Authentic Italian cuisine with traditional recipes and modern presentation", "zh": "正宗意大利美食，传统配方现代呈现", "fr": "Cuisine italienne authentique avec des recettes traditionnelles et une présentation moderne"}'
        WHEN email = 'info@cleanpro.com' THEN 
            '{"en": "Professional home cleaning with eco-friendly products", "zh": "使用环保产品的专业家庭清洁服务", "fr": "Nettoyage professionnel à domicile avec des produits écologiques"}'
        WHEN email = 'info@techprosolutions.com' THEN 
            '{"en": "Expert IT support for businesses and individuals", "zh": "为企业和个人提供专业IT技术支持", "fr": "Support IT expert pour les entreprises et les particuliers"}'
        WHEN email = 'info@goldendragon.com' THEN 
            '{"en": "Authentic Chinese cuisine with traditional flavors and modern presentation", "zh": "正宗中式料理，传统风味现代呈现", "fr": "Cuisine chinoise authentique avec des saveurs traditionnelles et une présentation moderne"}'
        WHEN email = 'info@sushimaster.com' THEN 
            '{"en": "Premium Japanese sushi and sashimi with fresh ingredients", "zh": "使用新鲜食材的高级日本寿司和刺身", "fr": "Sushi et sashimi japonais premium avec des ingrédients frais"}'
        WHEN email = 'info@handymanexpress.com' THEN 
            '{"en": "Professional handyman services for all your home repair needs", "zh": "专业的万能手艺人服务，满足您的所有家居维修需求", "fr": "Services de bricolage professionnels pour tous vos besoins de réparation à domicile"}'
        WHEN email = 'info@gardencareplus.com' THEN 
            '{"en": "Professional gardening and outdoor maintenance services", "zh": "专业的花园护理和户外维护服务", "fr": "Services professionnels de jardinage et d''entretien extérieur"}'
        WHEN email = 'info@petparadise.com' THEN 
            '{"en": "Comprehensive pet care services including sitting, walking, and grooming", "zh": "全面的宠物护理服务，包括托管、遛狗和美容", "fr": "Services complets de soins pour animaux de compagnie incluant la garde, la promenade et le toilettage"}'
        WHEN email = 'info@protoolsrental.com' THEN 
            '{"en": "Professional tools and equipment rental for DIY projects", "zh": "为DIY项目提供专业工具和设备租赁", "fr": "Location d''outils et d''équipements professionnels pour les projets DIY"}'
        WHEN email = 'info@webdevacademy.com' THEN 
            '{"en": "Comprehensive web development training programs for all skill levels", "zh": "为所有技能水平提供全面的网页开发培训课程", "fr": "Programmes de formation complets en développement web pour tous les niveaux de compétence"}'
        WHEN email = 'info@languagecenter.com' THEN 
            '{"en": "Professional language learning services in multiple languages", "zh": "多语言专业语言学习服务", "fr": "Services professionnels d''apprentissage des langues en plusieurs langues"}'
        WHEN email = 'info@fitnesspro.com' THEN 
            '{"en": "Personal fitness training and wellness coaching services", "zh": "个人健身训练和健康指导服务", "fr": "Services de formation fitness personnelle et de coaching bien-être"}'
        WHEN email = 'info@beautysalonelite.com' THEN 
            '{"en": "Premium beauty and salon services for all your beauty needs", "zh": "为您的所有美容需求提供优质美容和沙龙服务", "fr": "Services de beauté et de salon premium pour tous vos besoins de beauté"}'
        WHEN email = 'info@legalconsultpro.com' THEN 
            '{"en": "Professional legal consultation and advisory services", "zh": "专业法律咨询和顾问服务", "fr": "Services professionnels de consultation et de conseil juridiques"}'
        WHEN email = 'info@financialadvisorplus.com' THEN 
            '{"en": "Professional financial planning and investment advisory services", "zh": "专业财务规划和投资顾问服务", "fr": "Services professionnels de planification financière et de conseil en investissement"}'
        ELSE bio
    END;

-- 9. 最终验证
SELECT 
    'Final Verification' as check_type,
    email,
    display_name->>'en' as english_name,
    display_name->>'zh' as chinese_name,
    display_name->>'fr' as french_name,
    bio->>'en' as english_bio,
    bio->>'zh' as chinese_bio
FROM provider_profiles 
ORDER BY email;

-- 10. 清理备份表（可选，确认无误后执行）
-- DROP TABLE provider_profiles_backup;

COMMIT;

-- 显示更新结果摘要
SELECT 
    'Internationalization Update Summary' as summary,
    COUNT(*) as total_providers,
    COUNT(CASE WHEN display_name IS NOT NULL THEN 1 END) as with_multilingual_names,
    COUNT(CASE WHEN bio IS NOT NULL THEN 1 END) as with_multilingual_bios
FROM provider_profiles;
