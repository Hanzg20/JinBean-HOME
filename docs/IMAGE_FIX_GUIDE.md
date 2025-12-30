# 图片显示问题修复指南

## 问题诊断结果

从app日志中发现：
- **Sparkle Clean Services** (c46e45a3-6315-493c-b217-ac50622c03c9) 的所有5个service_details的`images_url`都是**空数组`[]`**
- **Golden Wok Restaurant** (76be73fa-4d2c-4580-81b4-2808f56f701d) 的service_details需要更新为Unsplash真实图片
- 之前执行的SQL脚本没有成功更新这些数据

## 修复步骤

### 步骤 1: 执行修正的SQL脚本

在Supabase SQL Editor中执行以下脚本：

```bash
# 在项目根目录执行
cat docs/database/fix_images_by_service_id.sql
```

然后将输出的SQL代码复制到Supabase SQL Editor并执行。

**或者**，如果你有psql命令行访问权限：

```bash
# 使用psql执行（需要数据库连接信息）
psql <your-database-connection-string> < docs/database/fix_images_by_service_id.sql
```

### 步骤 2: 验证数据库更新

执行后，你应该看到类似的输出：
- Services表: 2条记录更新
- Service Details表: 至少13条记录更新（5个Sparkle Clean + 8个Golden Wok）

### 步骤 3: 在App中触发热重载

有3种方式让App重新加载数据：

#### 方式A: 热重载 (最快)
在Flutter运行的终端中按 `r` 键，然后在app中重新进入Service Detail页面

#### 方式B: 热重启 (推荐)
在Flutter运行的终端中按 `R` 键（大写），这会完全重启app并重新加载所有数据

#### 方式C: 完全重启 (最彻底)
```bash
# 停止所有Flutter进程
killall Runner
sleep 2

# 重新启动app
flutter run -d 0AFF8177-4194-4F27-BF97-2D903E392225
```

### 步骤 4: 验证图片显示

1. 打开App，登录后选择customer角色
2. 进入"服务预订"页面
3. 点击"家政到家"分类
4. 选择"Sparkle Clean Services"
5. 进入Service Detail页面，应该能看到：
   - Services Tab: 显示5个清洁套餐，每个都有真实的Unsplash图片
   - 不再显示"精美图片即将呈现"的占位符

## 验证检查清单

- [ ] SQL脚本成功执行，没有错误
- [ ] Services表的2个服务更新了images_url (jsonb类型)
- [ ] Service Details表的至少13个项目更新了images_url (text[]类型)
- [ ] App完成热重启或重新启动
- [ ] 在Console中看到大量🖼️开头的日志（表示图片解析正在工作）
- [ ] Service Detail页面显示真实图片，不再显示占位符

## 调试日志

如果重启后还是没有看到图片，检查Console日志中的🖼️标记：

```
🖼️ [ServiceDetail.fromJson] ID: xxx, service_id: c46e45a3-6315-493c-b217-ac50622c03c9, images_url type: _GrowableList, value: [https://images.unsplash.com/...]
🖼️ [ServiceDetail.fromJson] Parsed 1 images: [https://images.unsplash.com/...]
```

如果看到：
```
⚠️ [ServiceDetail.fromJson] No images found!
```

说明数据库还没有正确更新，需要重新执行SQL脚本。

## 已修改的文件

1. **[lib/features/customer/domain/entities/service_detail.dart](lib/features/customer/domain/entities/service_detail.dart:92-108)**
   - 添加了调试日志来追踪图片URL解析过程

2. **[docs/database/fix_images_by_service_id.sql](docs/database/fix_images_by_service_id.sql)**
   - 新创建的SQL修复脚本，直接使用service ID更新图片

3. **[docs/database/check_images_status.sql](docs/database/check_images_status.sql)**
   - 检查当前数据库中图片状态的查询脚本

## 涉及的Service IDs

- **c46e45a3-6315-493c-b217-ac50622c03c9**: Sparkle Clean Services (家政服务)
- **76be73fa-4d2c-4580-81b4-2808f56f701d**: Golden Wok Restaurant (餐饮服务)

## 图片来源

所有图片都来自Unsplash，使用的是真实可访问的URL：
- 家政服务: 清洁相关的高质量图片
- 餐饮服务: 美食相关的高质量图片

所有图片都经过优化，宽度为600px或800px。
