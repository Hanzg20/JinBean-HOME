import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Import JinBean UI components
import 'package:jinbeanpod_83904710/core/ui/jinbean_ui.dart';
// Import actual provider pages
import 'orders/presentation/orders_shell_page.dart';
import 'clients/presentation/client_page.dart';
import 'settings/settings_page.dart';

class ProviderShellApp extends StatefulWidget {
  const ProviderShellApp({super.key});

  @override
  State<ProviderShellApp> createState() => _ProviderShellAppState();
}

class _ProviderShellAppState extends State<ProviderShellApp> with TickerProviderStateMixin {
  int _currentIndex = 0;

  void _onNavigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    print('[INFO][ProviderShellApp] ${DateTime.now().toIso8601String()} [ProviderShellApp] initState called');
    
    // 初始化页面列表 - 根据设计文档的正确顺序
    _pages = [
      ProviderHomePage(onNavigateToTab: _onNavigateToTab), // Dashboard
      OrdersShellPage(), // 订单管理页面
      ClientPage(), // 客户管理页面
      SettingsPage(), // 设置页面
    ];
    
    print('[INFO][ProviderShellApp] ${DateTime.now().toIso8601String()} [ProviderShellApp] _pages initialized');
  }

  @override
  Widget build(BuildContext context) {
    print('[DEBUG][ProviderShellApp] ${DateTime.now().toIso8601String()} [ProviderShellApp] build called, _currentIndex: $_currentIndex');
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: JinBeanColors.backgroundGradient,
        ),
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: _buildSimpleBottomBar(),
    );
  }

  Widget _buildSimpleBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: JinBeanColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildTabIcon(
                icon: Icons.dashboard,
                label: '首页',
                isSelected: _currentIndex == 0,
                onTap: () => _onTabTap(0),
              ),
              _buildTabIcon(
                icon: Icons.list_alt,
                label: '订单',
                isSelected: _currentIndex == 1,
                onTap: () => _onTabTap(1),
              ),
              _buildTabIcon(
                icon: Icons.people,
                label: '客户',
                isSelected: _currentIndex == 2,
                onTap: () => _onTabTap(2),
              ),
              _buildTabIcon(
                icon: Icons.settings,
                label: '设置',
                isSelected: _currentIndex == 3,
                onTap: () => _onTabTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabIcon({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? JinBeanColors.primary : JinBeanColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? JinBeanColors.primary : JinBeanColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTabTap(int index) {
    print('[DEBUG][ProviderShellApp] Tab tapped, index: $index');
    setState(() {
      _currentIndex = index;
    });
  }
}

class ProviderHomePage extends StatefulWidget {
  final Function(int) onNavigateToTab;

  const ProviderHomePage({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  State<ProviderHomePage> createState() => _ProviderHomePageState();
}

class _ProviderHomePageState extends State<ProviderHomePage> {
  // 响应式状态变量
  final RxBool isOnline = true.obs;
  final RxInt todayEarnings = 320.obs;
  final RxInt completedOrders = 8.obs;
  final RxDouble rating = 4.8.obs;

  @override
  void initState() {
    super.initState();
    print('[DEBUG][ProviderHomePage] ${DateTime.now().toIso8601String()} [ProviderHomePage] initState called');
  }

  @override
  Widget build(BuildContext context) {
    print('[DEBUG][ProviderHomePage] ${DateTime.now().toIso8601String()} [ProviderHomePage] build called');
    
    return Scaffold(
      backgroundColor: JinBeanColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 20),
                _buildOverviewCard(),
                const SizedBox(height: 20),
                _buildQuickActionsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Provider Dashboard',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: JinBeanColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: JinBeanColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, size: 16, color: JinBeanColors.primary),
              const SizedBox(width: 6),
              Text(
                'Today',
                style: TextStyle(
                  color: JinBeanColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      decoration: BoxDecoration(
        color: JinBeanColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.0),
          bottomLeft: Radius.circular(8.0),
          bottomRight: Radius.circular(8.0),
          topRight: Radius.circular(68.0),
        ),
        boxShadow: [
          BoxShadow(
            color: JinBeanColors.shadow.withOpacity(0.2),
            offset: Offset(1.1, 1.1),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: JinBeanColors.success,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '今日收入',
                            style: TextStyle(
                              color: JinBeanColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                        '\$${todayEarnings.value}',
                        style: TextStyle(
                          color: JinBeanColors.success,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: JinBeanColors.warning,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '完成订单',
                            style: TextStyle(
                              color: JinBeanColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                        '${completedOrders.value}',
                        style: TextStyle(
                          color: JinBeanColors.warning,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: 0.7,
                        strokeWidth: 8,
                        backgroundColor: JinBeanColors.primary.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(JinBeanColors.primary),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Obx(() => Text(
                              '${rating.value}',
                              style: TextStyle(
                                color: JinBeanColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                            Text(
                              '评分',
                              style: TextStyle(
                                color: JinBeanColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildProgressBar('接单率', 0.8, JinBeanColors.success),
            const SizedBox(height: 8),
            _buildProgressBar('完成率', 0.9, JinBeanColors.primary),
            const SizedBox(height: 8),
            _buildProgressBar('满意度', 0.95, JinBeanColors.warning),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: JinBeanColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Text(
          '${(value * 100).toInt()}%',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '快速操作',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: JinBeanColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              'Customize →',
              style: TextStyle(
                color: JinBeanColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildActionCard('接单', Icons.add_shopping_cart, 'Bread, Peanut butter, Apple', '525', JinBeanColors.success, () {
                print('[DEBUG][ProviderHomePage] 接单按钮被点击');
                widget.onNavigateToTab(1);
              }),
              const SizedBox(width: 12),
              _buildActionCard('发布服务', Icons.add_business, 'Salmon, Mixed veggies, Avocado', '602', JinBeanColors.primary, () {
                print('[DEBUG][ProviderHomePage] 发布服务按钮被点击');
              }),
              const SizedBox(width: 12),
              _buildActionCard('查看收入', Icons.account_balance_wallet, 'Recommended 800', '+', JinBeanColors.warning, () {
                print('[DEBUG][ProviderHomePage] 查看收入按钮被点击');
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, String description, String value, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(8.0),
            bottomLeft: Radius.circular(8.0),
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(54.0),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (value == '+')
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.add,
                    color: color,
                    size: 20,
                  ),
                )
              else
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 