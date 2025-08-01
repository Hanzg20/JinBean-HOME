# JinBean 底部导航栏使用指南

## 📱 概述

JinBean底部导航栏组件高仿My Diary的设计风格，提供现代化、渐变色彩、圆角设计的底部导航体验。

## 🎨 设计特点

### 1. **My Diary风格**
- **渐变背景**：蓝色到紫色的渐变色彩
- **圆角设计**：现代化的圆角卡片风格
- **动画效果**：流畅的选中状态动画
- **徽章支持**：支持数字徽章显示

### 2. **交互体验**
- **选中状态**：半透明背景和边框高亮
- **图标切换**：选中/未选中状态不同图标
- **触摸反馈**：流畅的动画过渡
- **徽章提醒**：红色徽章显示未读数量

## 🚀 使用方法

### 1. **基础底部导航栏**

```dart
import 'package:jinbeanpod_83904710/core/ui/jinbean_ui.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  int _currentIndex = 0;

  final List<JinBeanBottomNavItem> _navItems = [
    const JinBeanBottomNavItem(
      label: '首页',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    const JinBeanBottomNavItem(
      label: '服务',
      icon: Icons.search_outlined,
      selectedIcon: Icons.search,
      badge: '3',
    ),
    const JinBeanBottomNavItem(
      label: '订单',
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart,
      badge: '5',
    ),
    const JinBeanBottomNavItem(
      label: '我的',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(_currentIndex),
      bottomNavigationBar: JinBeanBottomNavigation(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        enableGradient: true,
      ),
    );
  }

  Widget _buildPage(int index) {
    // 返回对应的页面内容
    return Center(child: Text('页面 $index'));
  }
}
```

### 2. **带浮动操作按钮的底部导航栏**

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: _buildPage(_currentIndex),
    bottomNavigationBar: JinBeanFloatingBottomNavigation(
      currentIndex: _currentIndex,
      items: _navItems,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      floatingActionButton: const Icon(
        Icons.add,
        color: Colors.white,
        size: 28,
      ),
      onFloatingActionTap: () {
        // 处理浮动按钮点击
        print('浮动按钮被点击');
      },
    ),
  );
}
```

### 3. **使用包装器组件**

```dart
@override
Widget build(BuildContext context) {
  return JinBeanBottomNavigationWrapper(
    currentIndex: _currentIndex,
    items: _navItems,
    onTap: (index) {
      setState(() {
        _currentIndex = index;
      });
    },
    child: _buildPage(_currentIndex),
    useFloatingAction: true,
    floatingActionButton: const Icon(
      Icons.add,
      color: Colors.white,
      size: 28,
    ),
    onFloatingActionTap: () {
      print('浮动按钮被点击');
    },
  );
}
```

## 🎯 组件属性

### JinBeanBottomNavigation

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `currentIndex` | `int` | 必需 | 当前选中的索引 |
| `items` | `List<JinBeanBottomNavItem>` | 必需 | 导航项列表 |
| `onTap` | `ValueChanged<int>?` | `null` | 点击回调 |
| `showLabels` | `bool` | `true` | 是否显示标签 |
| `backgroundColor` | `Color?` | `null` | 背景颜色 |
| `selectedItemColor` | `Color?` | `Colors.white` | 选中项颜色 |
| `unselectedItemColor` | `Color?` | `Colors.white.withOpacity(0.7)` | 未选中项颜色 |
| `elevation` | `double` | `8.0` | 阴影高度 |
| `enableGradient` | `bool` | `true` | 是否启用渐变背景 |

### JinBeanFloatingBottomNavigation

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `currentIndex` | `int` | 必需 | 当前选中的索引 |
| `items` | `List<JinBeanBottomNavItem>` | 必需 | 导航项列表 |
| `onTap` | `ValueChanged<int>?` | `null` | 点击回调 |
| `floatingActionButton` | `Widget?` | `null` | 浮动操作按钮 |
| `onFloatingActionTap` | `VoidCallback?` | `null` | 浮动按钮点击回调 |
| `backgroundColor` | `Color?` | `null` | 背景颜色 |
| `selectedItemColor` | `Color?` | `Colors.white` | 选中项颜色 |
| `unselectedItemColor` | `Color?` | `Colors.white.withOpacity(0.7)` | 未选中项颜色 |

### JinBeanBottomNavItem

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `label` | `String` | 必需 | 导航项标签 |
| `icon` | `IconData` | 必需 | 未选中状态图标 |
| `selectedIcon` | `IconData?` | `null` | 选中状态图标 |
| `badge` | `String?` | `null` | 徽章文本 |
| `onTap` | `VoidCallback?` | `null` | 点击回调 |

## 🎨 自定义样式

### 1. **自定义颜色**

```dart
JinBeanBottomNavigation(
  currentIndex: _currentIndex,
  items: _navItems,
  onTap: (index) => setState(() => _currentIndex = index),
  backgroundColor: Colors.purple,
  selectedItemColor: Colors.white,
  unselectedItemColor: Colors.white.withOpacity(0.6),
  enableGradient: false, // 禁用渐变，使用纯色背景
)
```

### 2. **自定义高度和间距**

```dart
JinBeanBottomNavigation(
  currentIndex: _currentIndex,
  items: _navItems,
  onTap: (index) => setState(() => _currentIndex = index),
  elevation: 12.0, // 增加阴影
)
```

### 3. **动态徽章**

```dart
final List<JinBeanBottomNavItem> _navItems = [
  JinBeanBottomNavItem(
    label: '消息',
    icon: Icons.message_outlined,
    selectedIcon: Icons.message,
    badge: _unreadCount > 0 ? _unreadCount.toString() : null,
  ),
  // ... 其他导航项
];
```

## 📱 最佳实践

### 1. **导航项数量**
- 建议使用3-5个导航项
- 避免超过5个，影响用户体验

### 2. **图标选择**
- 使用Material Design图标
- 提供选中和未选中两种状态
- 图标含义要清晰明确

### 3. **徽章使用**
- 只在有未读内容时显示徽章
- 徽章数字不要超过99
- 超过99时显示"99+"

### 4. **性能优化**
- 使用`const`构造函数创建导航项
- 避免在`onTap`回调中进行复杂操作
- 合理使用`setState`更新状态

## 🔧 示例代码

### 完整的页面示例

```dart
import 'package:flutter/material.dart';
import 'package:jinbeanpod_83904710/core/ui/jinbean_ui.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  int _unreadMessages = 3;
  int _pendingOrders = 5;

  final List<JinBeanBottomNavItem> _navItems = [
    const JinBeanBottomNavItem(
      label: '首页',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    const JinBeanBottomNavItem(
      label: '服务',
      icon: Icons.search_outlined,
      selectedIcon: Icons.search,
    ),
    const JinBeanBottomNavItem(
      label: '订单',
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart,
    ),
    const JinBeanBottomNavItem(
      label: '消息',
      icon: Icons.message_outlined,
      selectedIcon: Icons.message,
    ),
    const JinBeanBottomNavItem(
      label: '我的',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 动态更新徽章
    _navItems[3] = JinBeanBottomNavItem(
      label: '消息',
      icon: Icons.message_outlined,
      selectedIcon: Icons.message,
      badge: _unreadMessages > 0 ? _unreadMessages.toString() : null,
    );

    _navItems[2] = JinBeanBottomNavItem(
      label: '订单',
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart,
      badge: _pendingOrders > 0 ? _pendingOrders.toString() : null,
    );

    return Scaffold(
      body: _buildPage(_currentIndex),
      bottomNavigationBar: JinBeanBottomNavigation(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        enableGradient: true,
      ),
    );
  }

  Widget _buildPage(int index) {
    final pages = [
      _buildHomePage(),
      _buildServicePage(),
      _buildOrderPage(),
      _buildMessagePage(),
      _buildProfilePage(),
    ];
    return pages[index];
  }

  Widget _buildHomePage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            JinBeanColors.primary.withOpacity(0.1),
            JinBeanColors.secondary.withOpacity(0.05),
          ],
        ),
      ),
      child: const Center(
        child: Text(
          '首页',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ... 其他页面构建方法
}
```

## 🎉 总结

JinBean底部导航栏组件提供了：

1. **现代化设计**：基于My Diary风格的渐变色彩和圆角设计
2. **丰富的功能**：支持徽章、浮动按钮、自定义样式
3. **良好的体验**：流畅的动画和交互反馈
4. **易于使用**：简单的API和丰富的自定义选项

通过使用这个组件，可以为JinBean应用提供一致、美观、现代化的底部导航体验。 