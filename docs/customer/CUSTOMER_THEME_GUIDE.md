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

## 性能优化

### 1. 主题缓存

- 使用GetX的响应式主题管理
- 避免重复创建主题对象
- 利用Flutter的主题继承机制

### 2. 组件优化

- 使用const构造函数
- 避免不必要的重建
- 合理使用Obx和GetBuilder

### 3. 内存管理

- 及时释放主题相关资源
- 避免主题对象泄漏
- 合理使用dispose方法

## 测试策略

### 1. 主题一致性测试

```dart
testWidgets('Customer theme consistency test', (WidgetTester tester) async {
  await tester.pumpWidget(
    GetMaterialApp(
      theme: JinBeanCustomerTheme.lightTheme,
      home: CustomerHomePage(),
    ),
  );
  
  // 验证主题颜色一致性
  final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
  expect(scaffold.backgroundColor, JinBeanCustomerTheme.lightTheme.colorScheme.surface);
});
```

### 2. 深色模式测试

```dart
testWidgets('Customer dark theme test', (WidgetTester tester) async {
  await tester.pumpWidget(
    GetMaterialApp(
      theme: JinBeanCustomerTheme.darkTheme,
      home: CustomerHomePage(),
    ),
  );
  
  // 验证深色主题正确应用
  final appBar = tester.widget<AppBar>(find.byType(AppBar));
  expect(appBar.backgroundColor, JinBeanCustomerTheme.darkTheme.colorScheme.primary);
});
```

## 维护指南

### 1. 主题更新

当需要更新主题时：

1. 修改`JinBeanCustomerTheme`中的相关配置
2. 更新`CustomerThemeUtils`中的辅助方法
3. 更新`CustomerThemeComponents`中的组件
4. 运行测试确保一致性
5. 更新文档

### 2. 新组件添加

添加新组件时：

1. 在`CustomerThemeComponents`中定义
2. 使用`Theme.of(context)`获取主题
3. 支持浅色/深色模式
4. 添加相应的测试
5. 更新使用指南

### 3. 问题排查

常见问题：

- **主题不生效**: 检查是否正确使用`Theme.of(context)`
- **颜色不一致**: 检查是否使用了硬编码颜色
- **深色模式问题**: 检查是否支持深色主题
- **性能问题**: 检查是否过度使用Obx

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