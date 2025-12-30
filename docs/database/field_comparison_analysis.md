# 评价系统字段对比分析

## 代码中使用的字段 vs 数据库表中存在的字段

### ✅ 数据库表中存在的字段（从脚本中确认）

**基础字段：**
- `id` - 主键
- `service_id` - 服务ID
- `reviewer_id` - 评价者ID
- `reviewee_id` - 被评价者ID
- `order_id` - 订单ID（可为空）
- `overall_rating` - 整体评分
- `title` - 评价标题
- `content` - 评价内容
- `status` - 状态
- `is_verified` - 是否验证
- `helpful_count` - 有用数
- `total_votes` - 总投票数
- `provider_response` - 服务商回复
- `provider_response_at` - 服务商回复时间
- `created_at` - 创建时间
- `updated_at` - 更新时间

**新增字段（从脚本中确认）：**
- `review_type` - 评价类型
- `service_rating` - 服务评分
- `tags` - 标签（jsonb类型）
- `is_anonymous` - 是否匿名
- `images` - 图片（jsonb类型）

### ❌ 代码中使用但数据库表中不存在的字段

**评分字段：**
- `quality_rating` - 质量评分
- `value_rating` - 性价比评分
- `atmosphere_rating` - 环境评分

**内容字段：**
- `source_description` - 评价来源描述
- `videos` - 视频列表
- `categories` - 分类标签

**时间字段：**
- `published_at` - 发布时间

**统计字段：**
- `report_count` - 举报次数

**关联数据字段：**
- `reviewer` - 评价者信息
- `service_title` - 服务标题
- `provider_name` - 服务商名称

## 修复建议

### 1. 立即修复（必需字段）
需要添加到数据库的字段：
```sql
-- 添加缺失的评分字段
ALTER TABLE public.reviews ADD COLUMN quality_rating integer CHECK (quality_rating >= 1 AND quality_rating <= 5);
ALTER TABLE public.reviews ADD COLUMN value_rating integer CHECK (value_rating >= 1 AND value_rating <= 5);
ALTER TABLE public.reviews ADD COLUMN atmosphere_rating integer CHECK (atmosphere_rating >= 1 AND atmosphere_rating <= 5);

-- 添加其他必需字段
ALTER TABLE public.reviews ADD COLUMN source_description text;
ALTER TABLE public.reviews ADD COLUMN videos jsonb DEFAULT '[]'::jsonb;
ALTER TABLE public.reviews ADD COLUMN categories jsonb DEFAULT '[]'::jsonb;
ALTER TABLE public.reviews ADD COLUMN published_at timestamptz;
ALTER TABLE public.reviews ADD COLUMN report_count integer DEFAULT 0;
```

### 2. 代码修改（可选字段）
对于关联数据字段，建议在代码中处理，而不是存储在数据库中：
- `reviewer` - 通过JOIN查询获取
- `service_title` - 通过JOIN查询获取
- `provider_name` - 通过JOIN查询获取

### 3. 当前状态
- ✅ 已修复：`videos`, `categories`, `source_description`, `atmosphere_rating`, `published_at`
- ❌ 仍需修复：`quality_rating`, `value_rating`, `report_count`

## 下一步行动
1. 添加缺失的必需字段到数据库
2. 更新代码以使用正确的字段
3. 测试评价提交功能






