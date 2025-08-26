-- =====================================================
-- 检查现有表结构的脚本
-- =====================================================

-- 1. 检查现有的表
SELECT 
    'Existing Tables' as check_type,
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('provider_profiles', 'services', 'service_details', 'ref_codes')
ORDER BY table_name;

-- 2. 检查 provider_profiles 表结构
SELECT 
    'Provider Profiles Structure' as check_type,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'provider_profiles'
ORDER BY ordinal_position;

-- 3. 检查 services 表结构
SELECT 
    'Services Structure' as check_type,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'services'
ORDER BY ordinal_position;

-- 4. 检查 service_details 表结构
SELECT 
    'Service Details Structure' as check_type,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'service_details'
ORDER BY ordinal_position;

-- 5. 检查 ref_codes 表结构
SELECT 
    'Ref Codes Structure' as check_type,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'ref_codes'
ORDER BY ordinal_position;

-- 6. 检查约束
SELECT 
    'Constraints' as check_type,
    constraint_name,
    constraint_type,
    table_name
FROM information_schema.table_constraints 
WHERE table_schema = 'public' 
  AND table_name IN ('provider_profiles', 'services', 'service_details')
ORDER BY table_name, constraint_type;
