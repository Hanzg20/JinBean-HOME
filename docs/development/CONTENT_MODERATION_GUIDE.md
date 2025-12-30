# 内容审核系统使用指南

> 版本：1.0
> 创建日期：2025-12-28
> 用途：说明如何使用内容审核系统

## 📋 概述

内容审核系统用于自动审核用户生成的内容（UGC），包括评价、评论、回复等，防止违规内容发布。

## 🎯 功能特性

### 1. 敏感词过滤
- ✅ 自动检测敏感词汇
- ✅ 支持多种分类（政治、色情、暴力、欺诈、侮辱、垃圾信息）
- ✅ 可配置的敏感词严重程度
- ✅ 敏感词缓存机制（1小时有效期）

### 2. 自动审核规则
- ✅ 内容长度检查
- ✅ 垃圾内容检测（重复字符、特殊符号）
- ✅ 联系方式检测（手机号、微信、QQ、邮箱）
- ✅ URL链接检测
- ✅ 评分有效性检查
- ✅ 评分与内容一致性检查

### 3. 人工审核
- ✅ 自动标记需要人工审核的内容
- ✅ 审核日志记录
- ✅ 管理后台支持

## 🚀 快速开始

### 数据库设置

1. 执行数据库迁移脚本：

```bash
# 在 Supabase SQL Editor 中执行
psql -h your-db-host -U postgres -d your-db-name -f docs/database/content_moderation_system.sql
```

2. 验证表创建成功：
   - `sensitive_words` - 敏感词库
   - `moderation_logs` - 审核日志
   - `reviews` 表应包含新字段：`moderation_status`, `provider_response_status`

### 代码集成

审核系统已自动集成到以下功能：

#### 1. 评价创建
```dart
// 在 ReviewService.createReview() 中自动执行审核
final review = await reviewService.createReview(request);
// 如果审核不通过，会抛出异常
```

#### 2. 服务商回复
```dart
// 在 ReviewService.replyToReview() 中自动执行审核
await reviewService.replyToReview(reviewId, replyContent);
// 如果审核不通过，会抛出异常
```

## 📝 使用示例

### 检测敏感词

```dart
final moderationService = Get.find<ContentModerationService>();

// 检测文本中的敏感词
final result = await moderationService.checkSensitiveWords("这是测试文本");

if (!result.isApproved) {
  print('检测到敏感词: ${result.foundWords.join(", ")}');
  print('详情: ${result.details}');
}
```

### 审核评价内容

```dart
final moderationService = Get.find<ContentModerationService>();

// 综合审核评价
final result = await moderationService.moderateReviewContent(
  title: "服务很好",
  content: "非常满意，推荐大家使用",
  overallRating: 5,
  serviceRating: 5,
  valueRating: 5,
);

if (result.isApproved) {
  print('审核通过');
} else {
  print('审核失败: ${result.details}');
}

if (result.requiresManualReview) {
  print('需要人工审核');
}
```

### 添加自定义敏感词

```dart
final moderationService = Get.find<ContentModerationService>();

await moderationService.addSensitiveWord(
  '新敏感词',
  category: 'custom',
);
```

### 获取待审核内容

```dart
final moderationService = Get.find<ContentModerationService>();

final pendingReviews = await moderationService.getPendingManualReviews(
  contentType: 'review',
  limit: 50,
);

for (final item in pendingReviews) {
  print('内容ID: ${item['content_id']}');
  print('原因: ${item['reason']}');
  print('详情: ${item['details']}');
}
```

## 🔧 配置选项

### 内容长度限制

```dart
// 在 ContentModerationService 中配置
final lengthCheck = moderationService.checkContentLength(
  content,
  minLength: 10,  // 最小长度
  maxLength: 1000, // 最大长度
);
```

### 评分范围

```dart
final ratingCheck = moderationService.checkRatingValidity(
  rating,
  minRating: 1,  // 最小评分
  maxRating: 5,  // 最大评分
);
```

## 📊 审核规则详解

### 1. 敏感词检测
- 检查内容是否包含敏感词库中的词汇
- 不区分大小写
- 返回所有检测到的敏感词

### 2. 垃圾内容检测

#### 重复字符检测
```
示例：aaaaaaaaaaaa（10个或更多重复字符）
结果：spam_repeated_chars
```

#### 特殊符号检测
```
规则：特殊符号占比 > 30%
示例：!!!!!!@@@@@#####
结果：spam_special_chars
```

#### 联系方式检测
```
检测模式：
- 11位数字（手机号）
- QQ号：qq:123456
- 微信号：微信:abc123
- 邮箱：example@email.com
结果：spam_contact_info
```

#### URL链接检测
```
检测模式：http://、https://、www.
结果：spam_url
```

### 3. 评分一致性检测

#### 高分+负面评价
```
评分：4-5星
内容包含：差、烂、垃圾、失望等
结果：rating_content_mismatch (需要人工审核)
```

#### 低分+正面评价
```
评分：1-2星
内容包含：好、棒、优秀、推荐等
结果：rating_content_mismatch (需要人工审核)
```

## 🎨 审核状态说明

### 评价审核状态 (moderation_status)
- `pending` - 待审核
- `approved` - 审核通过
- `rejected` - 审核拒绝
- `pending_manual_review` - 待人工审核

### 回复审核状态 (provider_response_status)
- `pending_review` - 待审核
- `published` - 已发布
- `rejected` - 审核拒绝

## 🔐 权限管理

### RLS（行级安全）策略

#### 敏感词表
- 管理员：完全访问
- 认证用户：只读访问

#### 审核日志表
- 管理员/审核员：查看所有日志
- 普通用户：只能查看自己的审核日志
- 系统：可以插入日志

## 🛠️ 管理功能

### 批准待审核内容

```sql
-- 在数据库中执行
SELECT approve_pending_content(
    'log_id_here',      -- 审核日志ID
    'reviewer_id_here', -- 审核员ID
    '审核通过'          -- 审核备注
);
```

### 拒绝待审核内容

```sql
SELECT reject_pending_content(
    'log_id_here',      -- 审核日志ID
    'reviewer_id_here', -- 审核员ID
    '内容违规'          -- 拒绝原因
);
```

### 查看审核统计

```sql
SELECT * FROM moderation_statistics;
```

## 📈 监控与分析

### 审核日志查询

```sql
-- 查看最近的审核日志
SELECT
    content_type,
    is_approved,
    reason,
    details,
    created_at
FROM moderation_logs
ORDER BY created_at DESC
LIMIT 100;
```

### 待审核内容查询

```sql
SELECT * FROM pending_manual_reviews
ORDER BY created_at DESC;
```

### 敏感词使用统计

```sql
SELECT
    unnest(found_words) as word,
    COUNT(*) as hit_count
FROM moderation_logs
WHERE found_words IS NOT NULL
GROUP BY word
ORDER BY hit_count DESC;
```

## 🚨 常见问题

### Q1: 如何添加新的敏感词？

**方法1：通过代码**
```dart
await moderationService.addSensitiveWord('新词', category: 'custom');
```

**方法2：直接在数据库中添加**
```sql
INSERT INTO sensitive_words (word, category, severity)
VALUES ('新词', 'custom', 2);
```

### Q2: 如何临时禁用某个敏感词？

```sql
UPDATE sensitive_words
SET is_active = false
WHERE word = '要禁用的词';
```

### Q3: 审核缓存多久更新一次？

敏感词缓存每1小时自动刷新，也可以通过重启应用强制刷新。

### Q4: 如何自定义审核规则？

编辑 `lib/core/services/content_moderation_service.dart`，在相应方法中添加自定义规则。

## 🔄 后续优化建议

### 短期（1-2周）
- [ ] 添加图片内容审核（OCR识别）
- [ ] 添加审核规则配置界面
- [ ] 优化敏感词匹配算法（支持同音字、拼音等）

### 中期（1个月）
- [ ] 集成第三方内容审核API（如阿里云、腾讯云）
- [ ] 机器学习模型训练（垃圾内容识别）
- [ ] 审核效率分析报表

### 长期（3个月）
- [ ] AI智能审核系统
- [ ] 用户行为分析（识别恶意用户）
- [ ] 多语言内容审核支持

## 📚 相关文档

- [评价系统设计文档](../architecture/review_system_design_assessment.md)
- [数据库架构文档](../database/schema_master.sql)
- [开发计划](./NEXT_DEVELOPMENT_PLAN.md)

---

*最后更新：2025-12-28*
