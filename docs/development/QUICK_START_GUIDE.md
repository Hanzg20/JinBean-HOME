# JinBean MVP开发快速启动指南

> 为开发团队准备的快速上手文档
> 更新日期：2025-12-15

## 🚀 今日开始任务

### 如果你是前端开发

#### 立即可以开始的任务：

**1. 评价系统-服务商回复功能（T001）**
```dart
// 文件位置：lib/features/customer/reviews/presentation/widgets/
// 需要修改：review_card.dart

任务清单：
□ 添加"商家回复"按钮（仅服务商可见）
□ 创建回复对话框组件
□ 实现回复API调用
□ 添加回复内容展示
□ 实时刷新回复内容

相关文件：
- lib/core/services/review_service.dart
- lib/core/models/review_models.dart
- lib/features/customer/reviews/presentation/reviews_controller.dart
```

**2. 订单列表性能优化（T006）**
```dart
// 文件位置：lib/features/customer/orders/
// 优化重点：列表渲染性能

快速诊断：
1. 打开订单列表页面
2. 快速上下滑动
3. 观察是否有卡顿

优化方案：
- 使用 ListView.builder 替代 ListView
- 添加 itemExtent 固定高度
- 实现图片懒加载
- 减少 setState 调用
```

### 如果你是后端开发

#### 立即可以开始的任务：

**1. 退款API开发（T003）**
```sql
-- 需要创建的API端点
POST /api/refunds/apply         -- 申请退款
GET  /api/refunds/:id           -- 查询退款状态
POST /api/refunds/:id/approve   -- 审批退款
POST /api/refunds/:id/reject    -- 拒绝退款

-- 数据库相关表
- refunds (已存在)
- payments (已存在)
- orders (已存在)

-- Stripe集成
Stripe.refunds.create({
  payment_intent: 'pi_xxx',
  amount: 1000, // 分为单位
  reason: 'requested_by_customer'
})
```

**2. 支付失败处理（T004）**
```javascript
// Supabase Edge Function
// 位置：supabase/functions/payment-retry/

重试策略：
- 第1次：立即重试
- 第2次：5秒后重试
- 第3次：30秒后重试
- 超过3次：标记失败，通知用户
```

### 如果你是全栈开发

#### 立即可以开始的任务：

**1. iOS图片上传修复（T005）**
```dart
// 问题定位：
// ios/Runner/Info.plist 权限配置
// lib/core/services/image_upload_service.dart

调试步骤：
1. 检查 Info.plist 权限配置
2. 测试 image_picker 版本兼容性
3. 添加错误日志
4. 实现降级方案

测试设备：
- iPhone 12 (iOS 15)
- iPhone 14 (iOS 17)
```

---

## 📁 项目结构速览

```
lib/
├── main.dart                    # 入口文件
├── core/                        # 核心模块
│   ├── controllers/            # 全局控制器（重要）
│   │   ├── unified_cart_controller.dart
│   │   └── universal_order_controller.dart
│   ├── services/               # 业务服务（重要）
│   │   ├── review_service.dart         ⭐ 本周重点
│   │   ├── payment_manager.dart        ⭐ 本周重点
│   │   └── ...
│   └── models/                 # 数据模型
│       └── review_models.dart
├── features/                    # 功能模块
│   ├── customer/               # 客户端功能
│   │   ├── reviews/           ⭐ 本周重点
│   │   ├── orders/            ⭐ 本周重点
│   │   └── ...
│   └── provider/               # 服务商功能
│       └── ...
└── config/                      # 配置文件
    └── app_config.dart
```

---

## 🔧 开发环境配置

### 1. 拉取最新代码
```bash
git checkout main
git pull origin main
git checkout -b feature/mvp-sprint1
```

### 2. 安装依赖
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..  # iOS only
```

### 3. 环境变量配置
```bash
# .env 文件（如果不存在请创建）
SUPABASE_URL=https://aszwrrrcbzrthqfsiwrd.supabase.co
SUPABASE_ANON_KEY=your_anon_key
STRIPE_PUBLISHABLE_KEY=your_stripe_key
```

### 4. 运行项目
```bash
# iOS
flutter run -d iPhone

# Android
flutter run -d emulator

# 热重载
r - 热重载
R - 热重启
q - 退出
```

---

## 🛠️ 常用命令

### Flutter命令
```bash
# 检查环境
flutter doctor

# 清理缓存
flutter clean

# 获取依赖
flutter pub get

# 运行测试
flutter test

# 构建APK
flutter build apk

# 构建iOS
flutter build ios
```

### Git工作流
```bash
# 创建功能分支
git checkout -b feature/功能名称

# 提交代码
git add .
git commit -m "feat: 添加评价回复功能"

# 推送代码
git push origin feature/功能名称

# 创建PR
# 在GitHub上创建Pull Request
```

### 数据库操作
```bash
# 连接Supabase数据库
psql postgresql://postgres:[password]@db.aszwrrrcbzrthqfsiwrd.supabase.co:5432/postgres

# 常用查询
SELECT * FROM reviews WHERE service_id = 'xxx';
SELECT * FROM orders WHERE user_id = 'xxx' ORDER BY created_at DESC;
```

---

## 🐛 常见问题解决

### 1. 购物车相关问题
```dart
// 问题：购物车更新不及时
// 解决：检查 unified_cart_controller.dart

// 强制刷新购物车
Get.find<UnifiedCartController>().forceRefresh();

// 清空购物车
Get.find<UnifiedCartController>().clearCart();
```

### 2. GetX状态管理问题
```dart
// 问题：状态更新UI不刷新
// 解决：确保使用Obx包裹

Obx(() => Text(controller.value.value))

// 或使用GetBuilder
GetBuilder<MyController>(
  builder: (controller) => Text(controller.value)
)
```

### 3. Supabase连接问题
```dart
// 问题：Supabase连接失败
// 解决：检查网络和配置

// 测试连接
final response = await Supabase.instance.client
  .from('services')
  .select()
  .limit(1);

print('Connection test: $response');
```

### 4. iOS构建问题
```bash
# 问题：iOS构建失败
# 解决步骤：

# 1. 清理构建
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all

# 2. 重新安装
pod install

# 3. 清理Flutter
cd ..
flutter clean
flutter pub get

# 4. 重新构建
flutter build ios
```

---

## 📊 关键性能指标

### 需要关注的性能指标：

| 指标 | 目标值 | 测试方法 |
|------|--------|---------|
| 购物车响应 | <50ms | 添加商品到购物车的时间 |
| 页面加载 | <1s | 首屏渲染时间 |
| 列表滚动 | 60fps | 使用Flutter Performance工具 |
| 内存占用 | <200MB | 使用Flutter DevTools |
| API响应 | <500ms | 网络请求时间 |

### 性能测试工具：
```bash
# 启动性能分析
flutter run --profile

# 打开DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

---

## 📞 联系方式

### 技术支持

| 角色 | 负责领域 | 联系方式 |
|------|---------|---------|
| 技术负责人 | 整体架构 | - |
| 前端Leader | Flutter/UI | - |
| 后端Leader | API/数据库 | - |
| 测试负责人 | 质量保证 | - |
| 产品经理 | 需求确认 | - |

### 重要文档链接

- [需求文档](../REQUIREMENTS_v2.0.md)
- [开发计划](./NEXT_DEVELOPMENT_PLAN.md)
- [任务看板](./TASK_BOARD.md)
- [API文档](../api/api_rest_spec.md)
- [数据库设计](../database/schema_master.sql)

---

## ✅ 今日检查清单

开始工作前，请确认：

- [ ] 已拉取最新代码
- [ ] 开发环境正常运行
- [ ] 了解本周Sprint目标
- [ ] 明确今日任务
- [ ] 知道任务负责人
- [ ] 清楚任务优先级
- [ ] 了解相关代码位置
- [ ] 知道测试要求
- [ ] 参加了早会

结束工作前，请确认：

- [ ] 代码已提交
- [ ] 更新了任务状态
- [ ] 编写了必要注释
- [ ] 通过了本地测试
- [ ] 更新了相关文档
- [ ] 同步了进度

---

## 🎯 本周冲刺目标

**Sprint 1（12/16-12/22）核心目标：**

1. **完成所有P0任务** - 解决阻塞问题
2. **推进P1任务50%** - 核心功能完善
3. **0严重Bug** - 保证稳定性
4. **代码评审100%** - 保证质量

**关键交付物：**
- 可运行的MVP版本
- 完整的测试报告
- 更新的文档

---

*祝开发顺利！有问题随时在团队群里沟通 💪*

*最后更新：2025-12-15*