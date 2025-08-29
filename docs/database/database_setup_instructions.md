# 数据库设置说明

## 问题描述
应用测试不顺利，因为数据库中缺少必要的表结构。

## 解决方案
需要在Supabase中创建所有必要的表。

## 操作步骤

### 1. 登录Supabase
1. 打开浏览器，访问 [https://supabase.com](https://supabase.com)
2. 登录你的账户
3. 选择你的JinBeanPod项目

### 2. 打开SQL编辑器
1. 在左侧导航栏中点击 "SQL Editor"
2. 点击 "New query" 创建新的查询

### 3. 运行SQL脚本
1. 复制 `DOCU/database_schema/create_all_tables.sql` 文件中的所有内容
2. 粘贴到SQL编辑器中
3. 点击 "Run" 按钮执行脚本

### 4. 验证结果
脚本执行完成后，你应该看到：
- 所有表都已创建
- 基础数据已插入
- RLS策略已配置
- 触发器已设置

### 5. 检查表是否创建成功
在SQL编辑器中运行以下查询来验证：

```sql
-- 检查表是否存在
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('user_profiles', 'provider_profiles', 'services', 'service_details', 'orders', 'order_items', 'ref_codes');

-- 检查数据是否插入
SELECT COUNT(*) as user_profiles_count FROM user_profiles;
SELECT COUNT(*) as orders_count FROM orders;
SELECT COUNT(*) as services_count FROM services;
```

## 创建的表

1. **ref_codes** - 服务类别参考表
2. **user_profiles** - 用户个人资料表
3. **provider_profiles** - 服务商资料表
4. **services** - 服务主表
5. **service_details** - 服务详情表
6. **orders** - 订单主表
7. **order_items** - 订单明细表

## 插入的示例数据

- 6个主要服务类别（美食天地、家政到家、出行广场等）
- 3个示例服务商
- 4个示例服务
- 3个示例订单
- 2个示例用户资料

## 注意事项

1. 脚本使用了 `IF NOT EXISTS` 和 `ON CONFLICT DO NOTHING`，可以安全地重复运行
2. 所有表都启用了RLS（行级安全）
3. 外键关系已正确设置
4. 索引已创建以提高查询性能

## 完成后的测试

设置完成后，重新运行应用，现在应该能够：
- 正常加载个人资料
- 查看订单列表
- 编辑个人资料
- 所有功能正常工作

如果仍有问题，请检查：
1. SQL脚本是否完全执行成功
2. 是否有任何错误信息
3. 网络连接是否正常 