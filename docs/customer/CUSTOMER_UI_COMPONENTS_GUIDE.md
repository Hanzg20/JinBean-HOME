# Customer端主题组件使用指南

## 概述

`CustomerThemeComponents` 是一个公共UI组件库，抽取自HomePage中可复用的UI元素，为Customer端提供统一的UI风格和组件。该组件库与Customer主题系统集成，确保所有组件都遵循相同的设计语言。

## 导入方式

```dart
import 'package:jinbeanpod_83904710/core/ui/themes/customer_theme_components.dart';
```

## 组件列表

### 1. 圆角装饰头部组件 (buildRoundedHeader)

**功能**: 创建带有渐变背景、装饰元素和欢迎文本的圆角头部

**参数**:
- `context`: BuildContext
- `title`: 主标题文本
- `subtitle`: 副标题文本
- `icon`: 图标 (可选，默认: Icons.celebration)
- `height`: 高度 (可选，默认: 110)
- `gradientColors`: 自定义渐变颜色 (可选)

**使用示例**:
```dart
CustomerThemeComponents.buildRoundedHeader(
  context: context,
  title: '欢迎使用金豆服务',
  subtitle: '为您提供优质便捷的生活服务',
  icon: Icons.celebration,
)
```

### 2. 搜索栏组件 (buildSearchBar)

**功能**: 创建带有搜索图标、清除按钮和语音按钮的搜索栏

**参数**:
- `context`: BuildContext
- `controller`: TextEditingController
- `onChanged`: 文本变化回调
- `onSubmitted`: 提交回调
- `onClear`: 清除按钮回调
- `onMicTap`: 语音按钮回调
- `hintText`: 提示文本 (可选，默认: '搜索您需要的服务...')
- `showClearButton`: 是否显示清除按钮 (可选，默认: true)
- `showMicButton`: 是否显示语音按钮 (可选，默认: true)

**使用示例**:
```dart
CustomerThemeComponents.buildSearchBar(
  context: context,
  controller: searchController,
  onChanged: (value) => print('搜索: $value'),
  onSubmitted: (value) => print('提交: $value'),
  onClear: () => searchController.clear(),
  onMicTap: () => print('语音搜索'),
)
```

### 3. 章节标题组件 (buildSectionHeader)

**功能**: 创建带有左侧装饰条、标题和可选操作按钮的章节标题

**参数**:
- `context`: BuildContext
- `title`: 标题文本
- `actionText`: 操作按钮文本 (可选)
- `onActionTap`: 操作按钮回调 (可选)
- `verticalPadding`: 垂直内边距 (可选，默认: 20)

**使用示例**:
```dart
CustomerThemeComponents.buildSectionHeader(
  context: context,
  title: '推荐服务',
  actionText: '查看全部',
  onActionTap: () => Get.toNamed('/service_booking'),
)
```

### 4. 服务分类卡片组件 (buildServiceCategoryCard)

**功能**: 创建带有图标、渐变背景和装饰元素的服务分类卡片

**参数**:
- `context`: BuildContext
- `name`: 服务名称
- `icon`: 服务图标
- `onTap`: 点击回调
- `typeCode`: 类型代码 (可选)
- `id`: 服务ID (可选)

**使用示例**:
```dart
CustomerThemeComponents.buildServiceCategoryCard(
  context: context,
  name: '家政服务',
  icon: Icons.cleaning_services,
  onTap: () => print('点击家政服务'),
)
```

### 5. 推荐服务卡片组件 (buildRecommendationCard)

**功能**: 创建带有图片、评分、价格等信息的推荐服务卡片

**参数**:
- `context`: BuildContext
- `title`: 服务标题
- `providerName`: 服务商名称
- `imageUrl`: 服务图片URL
- `rating`: 评分
- `price`: 价格
- `distance`: 距离 (可选)
- `isPopular`: 是否热门 (可选，默认: false)
- `isNearby`: 是否附近 (可选，默认: false)
- `onTap`: 点击回调
- `width`: 卡片宽度 (可选，默认: 220)
- `imageHeight`: 图片高度 (可选，默认: 120)

**使用示例**:
```dart
CustomerThemeComponents.buildRecommendationCard(
  context: context,
  title: '专业保洁服务',
  providerName: '清洁专家',
  imageUrl: 'https://example.com/image.jpg',
  rating: 4.8,
  price: 99.0,
  distance: 2.5,
  isPopular: true,
  onTap: () => Get.toNamed('/service_detail'),
)
```

### 6. 加载状态组件 (buildLoadingState)

**功能**: 创建带有加载动画和提示文本的加载状态

**参数**:
- `context`: BuildContext
- `message`: 加载提示文本
- `containerSize`: 容器大小 (可选，默认: 50)

**使用示例**:
```dart
CustomerThemeComponents.buildLoadingState(
  context: context,
  message: '正在加载推荐服务...',
)
```

### 7. 空状态组件 (buildEmptyState)

**功能**: 创建带有图标、文本和操作按钮的空状态

**参数**:
- `context`: BuildContext
- `title`: 标题文本
- `subtitle`: 副标题文本
- `buttonText`: 按钮文本
- `onButtonTap`: 按钮点击回调
- `icon`: 图标 (可选，默认: Icons.lightbulb_outline)
- `iconSize`: 图标大小 (可选，默认: 80)

**使用示例**:
```dart
CustomerThemeComponents.buildEmptyState(
  context: context,
  title: '暂无推荐服务',
  subtitle: '浏览我们的分类来找到您附近的服务',
  buttonText: '浏览服务',
  onButtonTap: () => Get.toNamed('/service_booking'),
)
```

## 在HomePage中的使用示例

```dart
// 使用圆角装饰头部
CustomerThemeComponents.buildRoundedHeader(
  context: context,
  title: '欢迎使用金豆服务',
  subtitle: '为您提供优质便捷的生活服务',
),

// 使用搜索栏
CustomerThemeComponents.buildSearchBar(
  context: context,
  controller: controller.searchController,
  onChanged: controller.onSearchChanged,
  onSubmitted: controller.onSearchSubmitted,
  onClear: controller.clearSearch,
  onMicTap: () => print('语音搜索'),
),

// 使用章节标题
CustomerThemeComponents.buildSectionHeader(
  context: context,
  title: '推荐服务',
  actionText: '查看全部',
  onActionTap: () => Get.toNamed('/service_booking'),
),

// 使用服务分类卡片
CustomerThemeComponents.buildServiceCategoryCard(
  context: context,
  name: service.name,
  icon: service.icon,
  onTap: () => handleServiceTap(service),
),

// 使用推荐服务卡片
CustomerThemeComponents.buildRecommendationCard(
  context: context,
  title: recommendation.title,
  providerName: recommendation.providerName,
  imageUrl: recommendation.imageUrl,
  rating: recommendation.rating,
  price: recommendation.price,
  distance: recommendation.distance,
  isPopular: recommendation.isPopular,
  onTap: () => Get.toNamed('/service_detail'),
),
```

## 与Customer主题系统的集成

该组件库与现有的Customer主题系统完全集成：

- **主题一致性**: 所有组件都使用 `CustomerThemeUtils` 中定义的颜色和样式
- **响应式设计**: 组件会根据当前主题自动调整外观
- **统一体验**: 与 `JinBeanCustomerTheme` 保持一致的视觉风格

## 设计原则

1. **一致性**: 所有组件都遵循相同的设计语言和视觉风格
2. **可定制性**: 提供合理的默认值，同时支持自定义参数
3. **可复用性**: 组件设计为可在多个页面中复用
4. **响应式**: 组件会根据主题和屏幕尺寸自动调整
5. **主题集成**: 与Customer主题系统深度集成

## 主题集成

所有组件都会自动使用当前主题的颜色方案：
- `colorScheme.primary`: 主色调
- `colorScheme.onSurface`: 文本颜色
- `colorScheme.onSurfaceVariant`: 次要文本颜色
- `colorScheme.surface`: 背景色

## 注意事项

1. 确保在使用组件前导入 `CustomerThemeComponents`
2. 所有回调函数都应该处理异常情况
3. 图片URL应该进行有效性验证
4. 在列表中使用组件时注意性能优化
5. 组件与Customer主题系统集成，确保主题切换时组件外观正确更新 