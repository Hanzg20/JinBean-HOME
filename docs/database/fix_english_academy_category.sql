-- 修复English Language Academy的category_level1_id
-- 从1010000 (Food) 改为 1050000 (Education)

-- 1. 检查当前值
SELECT
    id,
    title->>'en' as title,
    category_level1_id,
    category_level2_id
FROM services
WHERE id = '031f4b3b-6005-434a-9ba1-ed2af626a967';

-- 2. 更新category_level1_id为Education (1050000)
UPDATE services
SET
    category_level1_id = 1050000,
    category_level2_id = 1050100,  -- 也更新level2为教育培训
    updated_at = NOW()
WHERE id = '031f4b3b-6005-434a-9ba1-ed2af626a967';

-- 3. 验证更新
SELECT
    id,
    title->>'en' as title,
    category_level1_id,
    category_level2_id,
    CASE
        WHEN category_level1_id = 1010000 THEN 'Food (美食天地)'
        WHEN category_level1_id = 1020000 THEN 'Home Services (家政服务)'
        WHEN category_level1_id = 1040000 THEN 'Rental (共享乐园)'
        WHEN category_level1_id = 1050000 THEN 'Education (学习课堂)'
        WHEN category_level1_id = 1060000 THEN 'Health (生活帮忙)'
        ELSE 'Unknown'
    END as category_name
FROM services
WHERE id = '031f4b3b-6005-434a-9ba1-ed2af626a967';
