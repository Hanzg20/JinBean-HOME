import 'package:flutter/material.dart';
import '../components/navigation/jinbean_bottom_navigation.dart';
import '../design_system/colors.dart';

/// JinBean 底部导航栏示例页面
/// 展示 My Diary 风格的底部导航栏
class JinBeanBottomNavigationExample extends StatefulWidget {
  const JinBeanBottomNavigationExample({super.key});

  @override
  State<JinBeanBottomNavigationExample> createState() => _JinBeanBottomNavigationExampleState();
}

class _JinBeanBottomNavigationExampleState extends State<JinBeanBottomNavigationExample> {
  int _currentIndex = 0;
  bool _useFloatingAction = false;

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
      label: '社区',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
    ),
    const JinBeanBottomNavItem(
      label: '我的',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  final List<Widget> _pages = [
    _buildPage('首页', Icons.home, JinBeanColors.primary),
    _buildPage('服务', Icons.search, JinBeanColors.secondary),
    _buildPage('订单', Icons.shopping_cart, JinBeanColors.success),
    _buildPage('社区', Icons.people, JinBeanColors.warning),
    _buildPage('我的', Icons.person, JinBeanColors.info),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JinBean 底部导航栏示例'),
        backgroundColor: JinBeanColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_useFloatingAction ? Icons.list : Icons.add),
            onPressed: () {
              setState(() {
                _useFloatingAction = !_useFloatingAction;
              });
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: _useFloatingAction
          ? JinBeanFloatingBottomNavigation(
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
                _showFloatingActionDialog();
              },
            )
          : JinBeanBottomNavigation(
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

  static Widget _buildPage(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 60,
                color: color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '这是 $title 页面',
              style: TextStyle(
                fontSize: 16,
                color: color.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withOpacity(0.3),
                ),
              ),
              child: Text(
                'My Diary 风格设计',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFloatingActionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('浮动操作按钮'),
        content: const Text('您点击了中央的浮动操作按钮！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/// JinBean 底部导航栏演示页面
class JinBeanBottomNavigationDemo extends StatelessWidget {
  const JinBeanBottomNavigationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const JinBeanBottomNavigationExample();
  }
} 