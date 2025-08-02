# Provider主题使用指南

## 概述

Provider_theme是专为服务提供者角色设计的主题系统，采用"My Diary"风格，提供现代化的UI体验。本指南将详细介绍如何正确使用Provider_theme以提高复用率和用户体验。

## 设计风格统一规范

### 1. 核心设计元素

基于首页和Settings页面的成功设计，Provider端所有页面应遵循以下统一规范：

#### 🎨 颜色系统
- **主色调**: 使用`Theme.of(context).colorScheme.primary` (JinBeanColors.primaryDark)
- **背景色**: 使用`Theme.of(context).colorScheme.surface` (Color(0xFFF5F7FA))
- **变体背景**: 使用`Theme.of(context).colorScheme.surfaceVariant` (Color(0xFFE8EAED))
- **文本色**: 使用`Theme.of(context).colorScheme.onSurface` 和 `onSurfaceVariant`

#### 🔄 圆角设计
- **标准卡片**: `BorderRadius.circular(16)`
- **按钮**: `BorderRadius.circular(12)`
- **输入框**: `BorderRadius.circular(12)`
- **特殊圆角**: 右上角64px，其他角16px (用于重要信息卡片)

#### 📐 间距规范
- **主间距**: 16px (页面边距、卡片间距)
- **次间距**: 8px (组件内部间距)
- **小间距**: 4px (文字间距)

#### 🎯 阴影系统
- **卡片阴影**: `elevation: 8`, `shadowColor: colorScheme.shadow.withValues(alpha: 0.08)`
- **按钮阴影**: `elevation: 4`, `shadowColor: colorScheme.shadow.withValues(alpha: 0.2)`

### 2. 页面布局规范

#### 📱 页面结构
```dart
Scaffold(
  backgroundColor: colorScheme.surface,
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    title: Text('页面标题', style: theme.textTheme.titleLarge),
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

#### 🃏 卡片设计
```dart
ProviderCard(
  onTap: () => onTap(),
  child: Row(
    children: [
      ProviderIconContainer(
        icon: Icons.example,
        size: 36,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('标题', style: theme.textTheme.titleMedium),
            Text('副标题', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
      Icon(Icons.arrow_forward_ios, size: 14),
    ],
  ),
)
```

#### 🏷️ 徽章系统
```dart
// 数量徽章
Container(
  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  decoration: BoxDecoration(
    color: colorScheme.primary,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(
    '12',
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: colorScheme.onPrimary,
    ),
  ),
)

// 状态徽章
Container(
  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  decoration: BoxDecoration(
    color: colorScheme.error,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(
    '待认证',
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: colorScheme.onError,
    ),
  ),
)
```

## 主题架构

### 1. 主题层次结构

```
JinBeanProviderTheme
├── lightTheme (浅色主题)
└── darkTheme (深色主题)
    ├── AppBar主题
    ├── 卡片主题
    ├── 按钮主题
    ├── 输入框主题
    ├── 底部导航栏主题
    ├── 浮动操作按钮主题
    ├── 对话框主题
    ├── 底部表单主题
    ├── 进度指示器主题
    ├── 开关主题
    ├── 复选框主题
    ├── 单选按钮主题
    └── 滑块主题
```

### 2. 主题应用机制

- **AppThemeService**: 负责主题管理和切换
- **ProviderThemeUtils**: 提供主题辅助方法
- **ProviderThemeComponents**: 提供主题化通用组件

## 最佳实践

### 1. 正确的主题使用方式

#### ✅ 推荐做法

```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('页面标题', style: theme.textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionHeader(context, '区块标题'),
            const SizedBox(height: 8),
            _buildContentSection(context),
          ],
        ),
      ),
    );
  }
}
```

#### ❌ 避免做法

```dart
// 不要直接使用硬编码颜色
backgroundColor: JinBeanColors.background,
color: JinBeanColors.textPrimary,

// 不要使用不一致的圆角
borderRadius: BorderRadius.circular(8), // 应该使用12或16

// 不要使用不一致的间距
padding: const EdgeInsets.all(20), // 应该使用16
```

### 2. 使用主题工具类

#### 使用ProviderThemeUtils

```dart
import 'package:jinbeanpod_83904710/core/ui/themes/provider_theme_utils.dart';

// 获取主题化卡片样式
Container(
  decoration: ProviderThemeUtils.getCardDecoration(context),
  child: content,
)

// 获取主题化按钮样式
ElevatedButton(
  style: ProviderThemeUtils.getPrimaryButtonStyle(context),
  onPressed: () {},
  child: Text('按钮'),
)

// 获取主题化输入框样式
TextField(
  decoration: ProviderThemeUtils.getInputDecoration(
    context,
    hintText: '请输入...',
    prefixIcon: Icon(Icons.search),
  ),
)

// 显示主题化提示
ProviderThemeUtils.showSuccessSnackBar(context, message: '操作成功');
```

### 3. 使用主题组件库

#### 使用ProviderThemeComponents

```dart
import 'package:jinbeanpod_83904710/core/ui/components/provider_theme_components.dart';

// 使用主题化卡片
ProviderCard(
  onTap: () => onTap(),
  child: content,
)

// 使用主题化图标容器
ProviderIconContainer(
  icon: Icons.example,
  size: 36,
)

// 使用主题化按钮
ProviderButton(
  onPressed: () => onPressed(),
  text: '按钮文本',
  type: ProviderButtonType.primary,
)
```

## 页面改造优先级

### 高优先级 (立即修改)
1. **收入管理页面** - 核心业务功能
2. **订单管理页面** - 核心业务功能

### 中优先级 (近期修改)
3. **客户管理页面** - 业务支持功能
4. **服务管理页面** - 业务支持功能

### 低优先级 (后续优化)
5. **通知页面** - 辅助功能
6. **其他插件页面** - 扩展功能

## 改造检查清单

### ✅ 颜色系统检查
- [ ] 使用`Theme.of(context).colorScheme`替代硬编码颜色
- [ ] 背景色使用`colorScheme.surface`
- [ ] 文本色使用`colorScheme.onSurface`
- [ ] 主色调使用`colorScheme.primary`

### ✅ 组件使用检查
- [ ] 使用`ProviderCard`替代自定义卡片
- [ ] 使用`ProviderIconContainer`替代自定义图标容器
- [ ] 使用`ProviderThemeUtils`提供的方法
- [ ] 使用`ProviderButton`替代标准按钮

### ✅ 布局规范检查
- [ ] 页面边距使用16px
- [ ] 卡片圆角使用16px
- [ ] 按钮圆角使用12px
- [ ] 组件间距使用8px

### ✅ 交互规范检查
- [ ] 使用主题化的SnackBar
- [ ] 使用主题化的对话框
- [ ] 使用主题化的加载指示器
- [ ] 使用主题化的错误处理

## 常见问题

### Q: 如何确保页面符合Provider主题？
A: 使用`ProviderThemeUtils`和`ProviderThemeComponents`，避免直接使用硬编码颜色和样式。

### Q: 如何处理特殊的设计需求？
A: 在`ProviderThemeUtils`中添加新的工具方法，或在`ProviderThemeComponents`中添加新的组件。

### Q: 如何保持与其他页面的一致性？
A: 严格遵循本指南的设计规范，使用统一的组件库和工具类。

---

**注意**: 所有Provider端页面都应严格遵循本指南，确保用户体验的一致性和专业性。 