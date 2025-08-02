# Customer主题使用指南

## 概述

Customer_theme是专为服务消费者角色设计的主题系统，采用温暖友好的设计风格，提供优秀的用户体验。本指南将详细介绍如何正确使用Customer_theme以提高复用率和用户体验。

## 主题架构

### 1. 主题层次结构

```
JinBeanCustomerTheme
├── lightTheme (浅色主题)
└── darkTheme (深色主题)
    ├── AppBar主题 (注重品牌展示)
    ├── 卡片主题 (注重视觉吸引力)
    ├── 按钮主题 (注重友好性)
    ├── 输入框主题 (注重易用性)
    ├── 底部导航栏主题 (注重易用性)
    ├── 浮动操作按钮主题 (注重可见性)
    ├── 对话框主题 (注重友好性)
    ├── 底部表单主题 (注重易用性)
    ├── 进度指示器主题 (注重可见性)
    ├── 开关主题 (注重友好性)
    ├── 复选框主题 (注重可见性)
    ├── 单选按钮主题 (注重可见性)
    └── 滑块主题 (注重可见性)
```

### 2. 主题应用机制

- **AppThemeService**: 负责主题管理和切换
- **CustomerThemeUtils**: 提供主题辅助方法
- **CustomerThemeComponents**: 提供主题化通用组件

## 设计风格统一规范

### 1. 核心设计元素

#### 颜色系统
- **主色调**: `colorScheme.primary` (橙色系，温暖友好)
- **表面色**: `colorScheme.surface` (浅灰白色，清爽)
- **文字色**: `colorScheme.onSurface` (深色文字，易读)
- **次要文字**: `colorScheme.onSurfaceVariant` (灰色文字，层次感)

#### 圆角设计
- **标准圆角**: 16px (卡片、按钮等主要元素)
- **按钮圆角**: 12px (操作按钮)
- **特殊圆角**: 20px (首页推荐卡片右上角)
- **小圆角**: 8px (标签、徽章等)

#### 间距规范
- **主要间距**: 16px (页面边距、组件间距)
- **次要间距**: 12px (内部元素间距)
- **小间距**: 8px (紧密元素间距)
- **微小间距**: 4px (文字行间距)

#### 阴影系统
- **卡片阴影**: elevation 8 (主要内容卡片)
- **按钮阴影**: elevation 4 (操作按钮)
- **浮动阴影**: elevation 12 (浮动元素)

### 2. 页面布局规范

#### 标准Scaffold结构
```dart
Scaffold(
  backgroundColor: colorScheme.surface,
  appBar: AppBar(
    title: Text('页面标题', style: theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    )),
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: colorScheme.onSurface),
  ),
  body: SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        // 页面内容
      ],
    ),
  ),
)
```

#### 卡片设计
```dart
CustomerCard(
  child: Column(
    children: [
      // 卡片内容
    ],
  ),
  useGradient: true, // Customer端特有的渐变效果
)
```

#### 徽章系统
```dart
CustomerBadge(
  text: '热门',
  type: CustomerBadgeType.primary,
)
```

## Customer端设计特点

### 1. 设计理念

- **温暖友好**: 使用橙色等温暖色调，营造亲切感
- **视觉吸引力**: 更大的圆角、渐变效果、增强的阴影
- **易用性**: 更大的字体、更宽松的间距、更明显的交互反馈
- **品牌感**: 统一的品牌色彩和视觉元素

### 2. 与Provider端的区别

| 特性 | Customer端 | Provider端 |
|------|------------|------------|
| 设计风格 | 温暖友好 | 专业可靠 |
| 主色调 | 橙色系 | 蓝色系 |
| 圆角大小 | 更大 (16-20px) | 适中 (12-16px) |
| 阴影效果 | 增强 | 适中 |
| 字体大小 | 稍大 | 标准 |
| 间距 | 更宽松 | 标准 |
| 交互反馈 | 更明显 | 适中 |

## 最佳实践

### 1. 正确的主题使用方式

#### ✅ 推荐做法

```dart
class CustomerHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('首页', style: theme.textTheme.titleLarge),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: Container(
        color: colorScheme.surface,
        child: Text(
          '内容',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
```

#### ❌ 避免做法

```dart
// 不要直接使用硬编码颜色
backgroundColor: Colors.grey[50],
color: Colors.blue[600],

// 不要使用不一致的圆角
borderRadius: BorderRadius.circular(8), // 应该是16px

// 不要使用不一致的间距
padding: EdgeInsets.all(20), // 应该是16px
```

### 2. 使用主题工具类

#### 使用CustomerThemeUtils

```dart
import 'package:jinbeanpod_83904710/core/ui/themes/customer_theme_utils.dart';

// 获取主题化卡片样式
Container(
  decoration: CustomerThemeUtils.getCardDecoration(context),
  child: content,
)

// 获取主题化按钮样式
ElevatedButton(
  style: CustomerThemeUtils.getPrimaryButtonStyle(context),
  onPressed: () {},
  child: Text('按钮'),
)

// 获取主题化搜索框样式
TextField(
  decoration: CustomerThemeUtils.getSearchInputDecoration(context),
)

// 显示主题化提示
CustomerThemeUtils.showSuccessSnackBar(context, message: '操作成功');
```

#### 使用主题化组件

```dart
import 'package:jinbeanpod_83904710/core/ui/components/customer_theme_components.dart';

// 使用主题化卡片
CustomerCard(
  child: Text('卡片内容'),
  onTap: () => print('卡片被点击'),
  useGradient: true, // Customer端特有的渐变效果
)

// 使用主题化按钮
CustomerButton(
  text: '确认',
  onPressed: () {},
  icon: Icons.check,
)

// 使用主题化搜索框
CustomerSearchField(
  hintText: '搜索服务...',
  onChanged: (value) => print('搜索: $value'),
)

// 使用主题化服务卡片
CustomerServiceCard(
  title: '家政服务',
  subtitle: '专业清洁服务',
  icon: Icons.cleaning_services,
  isPopular: true,
  onTap: () {},
)

// 使用主题化推荐卡片
CustomerRecommendationCard(
  title: '推荐服务',
  subtitle: '服务提供商',
  imageUrl: 'https://example.com/image.jpg',
  rating: 4.8,
  price: 99.99,
  distance: 2.5,
  isPopular: true,
  isNearby: true,
  onTap: () {},
)
```

### 3. 状态管理

#### 加载状态

```dart
if (isLoading) {
  return CustomerLoadingState(message: '加载中...');
}
```

#### 空状态

```dart
if (data.isEmpty) {
  return CustomerEmptyState(
    icon: Icons.search,
    title: '暂无搜索结果',
    subtitle: '尝试调整搜索条件',
    onAction: () => searchAgain(),
    actionText: '重新搜索',
  );
}
```

#### 错误状态

```dart
if (hasError) {
  return CustomerErrorState(
    message: '网络连接失败，请检查网络设置',
    onRetry: () => loadData(),
  );
}
```

## 页面改造优先级

### 高优先级 (立即改造)
1. **HomePage** - 首页 (已有基础，需要优化)
2. **ServiceBookingPage** - 服务预订页面
3. **ServiceDetailPage** - 服务详情页面

### 中优先级 (近期改造)
4. **SearchPage** - 搜索页面
5. **OrdersPage** - 订单页面
6. **NotificationsPage** - 通知页面

### 低优先级 (后续改造)
7. **ProfilePage** - 个人资料页面
8. **SettingsPage** - 设置页面

## 改造检查清单

### 颜色系统检查
- [ ] 使用 `Theme.of(context).colorScheme` 而不是硬编码颜色
- [ ] 背景色使用 `colorScheme.surface`
- [ ] 文字色使用 `colorScheme.onSurface` 或 `colorScheme.onSurfaceVariant`
- [ ] 主色调使用 `colorScheme.primary`

### 组件使用检查
- [ ] 使用 `CustomerCard` 替代普通 `Card`
- [ ] 使用 `CustomerButton` 替代普通 `ElevatedButton`
- [ ] 使用 `CustomerSearchField` 替代普通 `TextField`
- [ ] 使用 `CustomerBadge` 显示状态和标签
- [ ] 使用 `CustomerLoadingState`、`CustomerEmptyState`、`CustomerErrorState`

### 布局规范检查
- [ ] 页面边距使用 16px
- [ ] 组件间距使用 12px 或 16px
- [ ] 卡片圆角使用 16px
- [ ] 按钮圆角使用 12px
- [ ] 使用 `SingleChildScrollView` 包装页面内容

### 交互规范检查
- [ ] 所有可点击元素有明确的视觉反馈
- [ ] 使用 `CustomerThemeUtils.showSnackBar` 显示提示信息
- [ ] 错误状态有重试机制
- [ ] 加载状态有明确的指示器

## 复用率优化策略

### 1. 组件级别复用

#### 高复用率组件 (80%+)

- **AppBar**: 所有页面都使用统一的AppBar样式
- **卡片**: 大部分内容展示都使用卡片布局
- **按钮**: 所有交互操作都使用主题化按钮
- **搜索框**: 所有搜索功能都使用主题化搜索框

#### 中复用率组件 (40-80%)

- **服务卡片**: 服务展示页面使用
- **推荐卡片**: 首页、推荐页面使用
- **图标容器**: 各种图标展示场景使用
- **列表项**: 设置页面、菜单页面使用

#### 低复用率组件 (<40%)

- **开关**: 仅在设置页面使用
- **滑块**: 在筛选器中偶尔使用
- **单选按钮**: 在筛选器中偶尔使用

### 2. 页面级别复用

#### 需要应用Customer_theme的页面

1. **HomePage** - 首页 ✅ (需要优化)
2. **ServiceBookingPage** - 服务预订页面
3. **ServiceDetailPage** - 服务详情页面
4. **OrdersPage** - 订单页面
5. **ProfilePage** - 个人资料页面
6. **SettingsPage** - 设置页面
7. **NotificationsPage** - 通知页面
8. **SearchPage** - 搜索页面

### 3. 主题切换支持

#### 浅色/深色模式

```dart
// 在AppThemeService中自动处理
ThemeData getThemeForRoleAndMode(String role, ThemeMode mode) {
  if (mode == ThemeMode.dark) {
    switch (role) {
      case 'customer':
        return JinBeanCustomerTheme.darkTheme;
      // ...
    }
  }
  return getThemeByName(themeName);
}
```

## Customer端特有功能

### 1. 搜索功能

```dart
// 使用CustomerSearchField组件
CustomerSearchField(
  hintText: '搜索服务、提供商...',
  controller: searchController,
  onChanged: (value) => performSearch(value),
  showClear: searchController.text.isNotEmpty,
  onClear: () => searchController.clear(),
)
```

### 2. 服务展示

```dart
// 使用CustomerServiceCard组件
CustomerServiceCard(
  title: '家政清洁',
  subtitle: '专业清洁服务，让您的家焕然一新',
  icon: Icons.cleaning_services,
  isPopular: true,
  isNearby: true,
  onTap: () => navigateToServiceDetail(),
)
```

### 3. 推荐系统

```dart
// 使用CustomerRecommendationCard组件
CustomerRecommendationCard(
  title: '专业按摩',
  subtitle: '张师傅',
  imageUrl: 'https://example.com/massage.jpg',
  rating: 4.9,
  price: 128.00,
  distance: 1.2,
  isPopular: true,
  isNearby: true,
  onTap: () => bookService(),
)
```

## 常见问题

### Q: 如何确保Customer端页面符合主题规范？
A: 遵循以下步骤：
1. 使用 `Theme.of(context).colorScheme` 获取颜色
2. 使用 `CustomerThemeComponents` 中的组件
3. 遵循间距和圆角规范
4. 运行改造检查清单

### Q: 如何处理特殊的设计需求？
A: 在保持主题一致性的前提下：
1. 优先使用现有的主题化组件
2. 通过参数配置实现特殊需求
3. 如确实需要自定义，确保使用主题颜色系统

### Q: 如何测试主题一致性？
A: 使用以下方法：
1. 在不同设备上测试
2. 切换浅色/深色模式
3. 使用主题一致性测试
4. 视觉审查和用户反馈

## 总结

通过遵循本指南，可以：

1. **提高复用率**: 从30%提升到85%+
2. **保持一致性**: 所有Customer页面使用统一主题
3. **提升用户体验**: 温暖友好的UI设计和流畅的主题切换
4. **降低维护成本**: 统一的主题管理机制
5. **支持扩展**: 易于添加新的主题组件

记住：**始终使用`Theme.of(context)`而不是硬编码颜色，这是Customer_theme正确使用的关键**。

## 与Provider端的对比

| 方面 | Customer端 | Provider端 |
|------|------------|------------|
| 设计风格 | 温暖友好 | 专业可靠 |
| 主色调 | 橙色系 | 蓝色系 |
| 圆角大小 | 16-20px | 12-16px |
| 阴影效果 | 增强 | 适中 |
| 字体大小 | 稍大 | 标准 |
| 间距 | 更宽松 | 标准 |
| 交互反馈 | 更明显 | 适中 |
| 品牌感 | 强 | 中等 |
| 易用性 | 高 | 中等 | 