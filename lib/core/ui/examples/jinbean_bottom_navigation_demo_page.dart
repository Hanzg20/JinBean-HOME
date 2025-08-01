import 'package:flutter/material.dart';
import '../components/navigation/jinbean_bottom_navigation.dart';
import '../design_system/colors.dart';

/// JinBean 底部导航栏演示页面
class JinBeanBottomNavigationDemoPage extends StatefulWidget {
  const JinBeanBottomNavigationDemoPage({super.key});

  @override
  State<JinBeanBottomNavigationDemoPage> createState() => _JinBeanBottomNavigationDemoPageState();
}

class _JinBeanBottomNavigationDemoPageState extends State<JinBeanBottomNavigationDemoPage> {
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
      appBar: AppBar(
        title: const Text('JinBean 底部导航栏演示'),
        backgroundColor: JinBeanColors.primary,
        foregroundColor: Colors.white,
      ),
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
            JinBeanColors.primary.withValues(alpha: 0.1),
            JinBeanColors.secondary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home,
              size: 80,
              color: JinBeanColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              '首页',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: JinBeanColors.primary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'My Diary 风格设计',
              style: TextStyle(
                fontSize: 16,
                color: JinBeanColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicePage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            JinBeanColors.secondary.withValues(alpha: 0.1),
            JinBeanColors.primary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: JinBeanColors.secondary,
            ),
            SizedBox(height: 16),
            Text(
              '服务',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: JinBeanColors.secondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '发现优质服务',
              style: TextStyle(
                fontSize: 16,
                color: JinBeanColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderPage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            JinBeanColors.success.withValues(alpha: 0.1),
            JinBeanColors.warning.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart,
              size: 80,
              color: JinBeanColors.success,
            ),
            SizedBox(height: 16),
            Text(
              '订单',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: JinBeanColors.success,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '管理您的订单',
              style: TextStyle(
                fontSize: 16,
                color: JinBeanColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            JinBeanColors.info.withValues(alpha: 0.1),
            JinBeanColors.primary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 80,
              color: JinBeanColors.info,
            ),
            SizedBox(height: 16),
            Text(
              '我的',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: JinBeanColors.info,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '个人中心',
              style: TextStyle(
                fontSize: 16,
                color: JinBeanColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 