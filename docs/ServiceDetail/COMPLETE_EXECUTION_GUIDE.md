# 美食分类完整测试数据执行指南

## ⚠️ 重要提示

由于数据库表可能不存在，我们需要按以下顺序执行：

## 📋 执行顺序

### 第一步：检查数据库表结构
```sql
-- 在Supabase SQL编辑器中执行
\i docs/ServiceDetail/check_database_tables.sql
```

**预期结果：**
- 显示所有现有表
- 检查关键表是否存在

### 第二步：创建必要的表（如果需要）
```sql
-- 在Supabase SQL编辑器中执行
\i docs/ServiceDetail/create_required_tables.sql
```

**预期结果：**
- 创建 provider_profiles 表
- 创建 services 表
- 创建 service_details 表
- 创建 ref_codes 表（如果不存在）

### 第三步：执行美食分类更新（如果还没执行）
```sql
-- 在Supabase SQL编辑器中执行
\i docs/ServiceDetail/final_community_food_categories_update.sql
```

**预期结果：**
- 更新美食分类结构
- 创建5个二级分类

### 第四步：执行完整测试数据
```sql
-- 在Supabase SQL编辑器中执行
\i docs/ServiceDetail/complete_food_test_data_fixed.sql
```

**预期结果：**
- 插入10个Provider
- 插入10个Services
- 插入20个Service Details
- 自动验证数据

## 🔍 故障排除

### 如果遇到 "relation does not exist" 错误：

1. **检查表是否存在**：
   ```sql
   SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
   ```

2. **如果表不存在，执行创建脚本**：
   ```sql
   \i docs/ServiceDetail/create_required_tables.sql
   ```

3. **如果表已存在但结构不同，检查字段**：
   ```sql
   \d provider_profiles
   \d services
   \d service_details
   ```

### 如果遇到外键约束错误：

1. **检查 ref_codes 表是否有美食分类数据**
2. **确保先执行了分类更新脚本**

## 📊 验证步骤

执行完成后，运行以下查询验证：

```sql
-- 1. 检查Provider数量
SELECT COUNT(*) as provider_count FROM provider_profiles;

-- 2. 检查Services数量
SELECT COUNT(*) as services_count FROM services;

-- 3. 检查Service Details数量
SELECT COUNT(*) as service_details_count FROM service_details;

-- 4. 检查分类分布
SELECT 
    rc2.name->>'zh' as "分类名称",
    COUNT(s.id) as "服务数量"
FROM ref_codes rc1
JOIN ref_codes rc2 ON rc1.id = rc2.parent_id
LEFT JOIN services s ON rc2.id = s.category_level2_id
WHERE rc1.type_code = 'SERVICE_TYPE' 
    AND rc1.level = 1 
    AND (rc1.name->>'zh' = '美食天地' OR rc1.name->>'en' = 'Food World')
GROUP BY rc2.id, rc2.name->>'zh', rc2.sort_order
ORDER BY rc2.sort_order;
```

## 🎯 预期结果

执行完成后，您将拥有：
- ✅ **10个Provider**：完整的美食服务提供商
- ✅ **10个Services**：每个分类2个服务
- ✅ **20个Service Details**：每个服务2条详情
- ✅ **5个美食分类**：社区美食、餐厅预订、团体餐饮、食材采购、其它
- ✅ **完整关联**：所有数据正确关联

## 📝 注意事项

1. **执行顺序很重要**：必须先创建表，再插入数据
2. **分类依赖**：Services依赖ref_codes中的分类数据
3. **外键约束**：确保所有外键引用的数据都存在
4. **数据验证**：执行后运行验证查询确保数据完整性

按照这个指南执行，应该可以成功创建完整的美食分类测试数据！
