# 美食分类完整测试数据执行指南

## 📋 执行顺序

### 第一步：执行Provider数据脚本
```sql
-- 在Supabase SQL编辑器中执行
\i docs/ServiceDetail/food_providers_data.sql
```

**预期结果：**
- 插入10个美食服务提供商
- 每个provider都有完整的profile信息
- 包含联系方式、地址、认证状态等

### 第二步：执行Services和Service Details数据脚本
```sql
-- 在Supabase SQL编辑器中执行
\i docs/ServiceDetail/comprehensive_food_services_data.sql
```

**预期结果：**
- 插入10个美食服务（每个分类2个）
- 每个服务有2条service_details（主服务+子服务）
- 总共20条service_details记录

## 📊 数据规模总览

### Provider数据（10个）
1. **张妈妈川菜工坊** - 社区美食
2. **李师傅饺子屋** - 社区美食
3. **龙腾中餐厅** - 餐厅预订
4. **樱花日料** - 餐厅预订
5. **皇家婚礼宴席** - 团体餐饮
6. **企业年会餐饮** - 团体餐饮
7. **新鲜蔬菜直供** - 食材采购
8. **进口食品代购** - 食材采购
9. **美食摄影服务** - 其它
10. **美食课程教学** - 其它

### Services数据（10个）
- 每个分类2个服务
- 覆盖5个二级分类
- 包含不同的定价模式（fixed, per_person, hourly）

### Service Details数据（20个）
- 每个服务2条详情
- 主服务详情（标准服务）
- 子服务详情（增值服务）

## 🔍 验证查询

执行完成后，可以运行以下查询验证数据：

```sql
-- 1. 验证分类分布
SELECT 
    rc2.name->>'zh' as "分类名称",
    COUNT(s.id) as "服务数量",
    COUNT(sd.id) as "详情数量"
FROM ref_codes rc1
JOIN ref_codes rc2 ON rc1.id = rc2.parent_id
LEFT JOIN services s ON rc2.id = s.category_level2_id
LEFT JOIN service_details sd ON s.id = sd.service_id
WHERE rc1.type_code = 'SERVICE_TYPE' 
    AND rc1.level = 1 
    AND (rc1.name->>'zh' = '美食天地' OR rc1.name->>'en' = 'Food World')
GROUP BY rc2.id, rc2.name->>'zh', rc2.sort_order
ORDER BY rc2.sort_order;

-- 2. 验证Provider和Service关联
SELECT 
    pp.display_name->>'zh' as "提供商名称",
    s.title->>'zh' as "服务名称",
    rc2.name->>'zh' as "分类",
    s.rating as "服务评分"
FROM provider_profiles pp
JOIN services s ON pp.id = s.provider_id
JOIN ref_codes rc2 ON s.category_level2_id = rc2.id
WHERE s.category_level1_id IN (
    SELECT id FROM ref_codes 
    WHERE type_code = 'SERVICE_TYPE' 
        AND level = 1 
        AND (name->>'zh' = '美食天地' OR name->>'en' = 'Food World')
)
ORDER BY rc2.sort_order, pp.display_name->>'zh';

-- 3. 统计信息
SELECT 
    '总Provider数量' as "统计项目",
    COUNT(*) as "数量"
FROM provider_profiles 
WHERE id IN (
    SELECT DISTINCT provider_id 
    FROM services 
    WHERE category_level1_id IN (
        SELECT id FROM ref_codes 
        WHERE type_code = 'SERVICE_TYPE' 
            AND level = 1 
            AND (name->>'zh' = '美食天地' OR name->>'en' = 'Food World')
    )
);
```

## ⚠️ 注意事项

1. **执行顺序**：必须先执行provider脚本，再执行services脚本
2. **数据依赖**：services脚本依赖provider数据中的display_name字段
3. **分类ID**：确保美食分类已经正确更新（执行过final_community_food_categories_update.sql）
4. **验证**：执行后运行验证查询确保数据完整性

## 🎯 预期结果

执行完成后，您将拥有：
- ✅ 10个完整的美食服务提供商
- ✅ 10个美食服务（每个分类2个）
- ✅ 20个service_details记录
- ✅ 完整的数据关联关系
- ✅ 丰富的测试数据用于应用开发

这些数据将为您的美食分类功能提供全面的测试支持！
