import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Import the new SettingsPage
import 'package:jinbeanpod_83904710/features/provider/settings/settings_page.dart';
// Import the new shell pages
import 'package:jinbeanpod_83904710/features/provider/orders/presentation/orders_shell_page.dart'; // Orders Shell Page
import 'package:jinbeanpod_83904710/features/provider/clients/presentation/client_page.dart'; // Client Page
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

class ProviderShellApp extends StatefulWidget {
  const ProviderShellApp({super.key});

  @override
  State<ProviderShellApp> createState() => _ProviderShellAppState();
}

class _ProviderShellAppState extends State<ProviderShellApp> {
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
    AppLogger.info('[ProviderShellApp] initState called', tag: 'ProviderShellApp');
    _pages = [
      ProviderHomePage(onNavigateToTab: _onNavigateToTab), // Dashboard
      OrdersShellPage(), // Orders (包含了订单管理和抢单大厅)
      ClientPage(), // Clients
      SettingsPage(), // Settings/My - Updated to use the new SettingsPage
    ];
    AppLogger.info('[ProviderShellApp] _pages initialized: '
      '${_pages.map((w) => w.runtimeType).join(', ')}', tag: 'ProviderShellApp');
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('[ProviderShellApp] build called, _currentIndex: $_currentIndex', tag: 'ProviderShellApp');
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() {
            _currentIndex = i;
          });
          AppLogger.info('[ProviderShellApp] BottomNavigationBar tapped, index: $i', tag: 'ProviderShellApp');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: '订单'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '客户'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

// 下面是各页面的占位Widget（如已存在可省略）
class ProviderHomePage extends StatelessWidget {
  final Function(int) onNavigateToTab; // Add this line
  const ProviderHomePage({super.key, required this.onNavigateToTab}); // Modify constructor

  @override
  Widget build(BuildContext context) {
    // 获取当前主题以决定图标颜色等
    final theme = Theme.of(context);
    final isDarkTeal = theme.primaryColor == Colors.teal; // 判断当前是否为青色主题

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'JinBeanPod',
              style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Text(
              'Services Provider',
              style: TextStyle(color: theme.colorScheme.onPrimary.withOpacity(0.8), fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: theme.colorScheme.onPrimary),
            onPressed: () {
              Get.toNamed('/notifications');
            },
          ),
          Obx(() {
            final isOnline = true.obs;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.power_settings_new, color: isOnline.value ? theme.colorScheme.secondary : Colors.grey[400]),
                onPressed: () {
                  isOnline.value = !isOnline.value;
                  Get.snackbar(
                    '状态切换',
                    isOnline.value ? '您已上线，开始接收订单！' : '您已离线，将不再接收新订单。',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: isOnline.value ? Colors.green.shade700 : Colors.red.shade700,
                    colorText: Colors.white,
                  );
                },
              ),
            );
          }),
          const SizedBox(width: 8),
        ],
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '核心数据总览',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '核心数据一览无余',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildOverviewCard(context, '核心区块货', '186', '3', 'assets/images/chart_placeholder_1.png', theme.primaryColor),
                _buildOverviewCard(context, '电灯信息表', '16%', '6小时/天', 'assets/images/chart_placeholder_2.png', theme.primaryColor),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              '服务工作流中心',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.8,
              children: [
                _buildQuickAccessItem(context, Icons.build, '服务', () { Get.toNamed('/service_manage'); }),
                _buildQuickAccessItem(context, Icons.chat_bubble_outline, '消息', () { Get.toNamed('/message_center'); }),
                _buildQuickAccessItem(context, Icons.account_balance_wallet, '财务', () { Get.toNamed('/settings/finance'); }),
                _buildQuickAccessItem(context, Icons.star_border, '评价', () { Get.toNamed('/settings/reviews'); }),
                _buildQuickAccessItem(context, Icons.bar_chart, '报表', () { Get.toNamed('/settings/reports'); }),
                _buildQuickAccessItem(context, Icons.campaign, '推广', () { Get.toNamed('/settings/marketing'); }),
                _buildQuickAccessItem(context, Icons.security, '合规', () { Get.toNamed('/settings/legal'); }),
                _buildQuickAccessItem(context, Icons.more_horiz, '更多', () { /* TODO: Navigate to a comprehensive features page if needed */ }),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              '最新任务与活动',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLatestOrderItem(context, '新新订单', '3::18', 'Bomem', 'S6:10', 'Q mtiieons'),
                    const Divider(height: 24),
                    _buildLatestOrderItem(context, '新订单', '33Slc', 'Bomem', '', '+ +'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, String title, String value, String subValue, String chartImagePath, Color iconColor) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: iconColor.withOpacity(0.1), // Card background with slight opacity
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                ),
                Icon(Icons.more_horiz, size: 20, color: Colors.grey.shade600), // More options icon
              ],
            ),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: iconColor), // 主体数值颜色与主题色一致
            ),
            Text(
              subValue,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500), // 副数值颜色
            ),
            const Spacer(), // Pushes the chart placeholder to the bottom
            // Chart Placeholder
            Container(
              height: 50, // Height of the chart area
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2), // Light background for chart
                borderRadius: BorderRadius.circular(8),
              ),
              // You could use an Image.asset here if you have actual chart images
              // For now, it's just a colored box to represent the chart area
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(2),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                child: Icon(icon, size: 20, color: theme.primaryColor),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestOrderItem(BuildContext context, String title, String time, String location, String subTime, String actionText) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            child: Icon(Icons.person, color: theme.primaryColor), // Placeholder for avatar
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  time,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (actionText == 'Q mtiieons')
            OutlinedButton(
              onPressed: () {
                // TODO: Implement action
              },
              style: OutlinedButton.styleFrom(side: BorderSide(color: theme.primaryColor)),
              child: Text(actionText, style: TextStyle(color: theme.primaryColor)),
            )
          else if (actionText == '+ +')
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add, color: theme.primaryColor),
                  onPressed: () {
                    // TODO: Implement add action
                  },
                ),
                IconButton(
                  icon: Icon(Icons.add, color: theme.primaryColor),
                  onPressed: () {
                    // TODO: Implement another add action
                  },
                ),
              ],
            )
          else
            Text(
              actionText, // Fallback for other action texts
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.primaryColor),
            ),
        ],
      ),
    );
  }
}
