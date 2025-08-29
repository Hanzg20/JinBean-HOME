import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/order_manage/order_manage_controller.dart';
import 'package:jinbeanpod_83904710/features/provider/clients/presentation/client_controller.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/service_manage/service_manage_controller.dart';
import 'package:jinbeanpod_83904710/features/provider/income/income_controller.dart';
import 'package:jinbeanpod_83904710/features/provider/notifications/notification_controller.dart';

class ProviderSimulator extends StatefulWidget {
  const ProviderSimulator({super.key});

  @override
  State<ProviderSimulator> createState() => _ProviderSimulatorState();
}

class _ProviderSimulatorState extends State<ProviderSimulator> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeControllers();
  }

  void _initializeControllers() {
    // 初始化所有控制器
    Get.put(OrderManageController());
    Get.put(ClientController());
    Get.put(ServiceManageController());
    Get.put(IncomeController());
    Get.put(NotificationController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider端模拟器'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSimulatorSettings(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 模拟器状态栏
          _buildStatusBar(),

          // 主内容区域
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                _buildOrderSimulator(),
                _buildClientSimulator(),
                _buildServiceSimulator(),
                _buildIncomeSimulator(),
                _buildNotificationSimulator(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        children: [
          Icon(Icons.sim_card, color: Colors.green[600]),
          const SizedBox(width: 8),
          const Text(
            '模拟器运行中',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '在线',
              style: TextStyle(color: Colors.green[700], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSimulator() {
    final orderController = Get.find<OrderManageController>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📦 订单管理模拟器',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
          ),
          const SizedBox(height: 16),

          // 模拟数据生成
          _buildSimulatorCard(
            title: '生成模拟订单',
            content: Column(
              children: [
                _buildSimulatorButton(
                  '生成待处理订单',
                  () => _generateMockOrders(orderController, 'pending'),
                  Colors.orange,
                ),
                const SizedBox(height: 8),
                _buildSimulatorButton(
                  '生成进行中订单',
                  () => _generateMockOrders(orderController, 'in_progress'),
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildSimulatorButton(
                  '生成已完成订单',
                  () => _generateMockOrders(orderController, 'completed'),
                  Colors.green,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 订单统计
          _buildSimulatorCard(
            title: '订单统计',
            content: Obx(() => Column(
                  children: [
                    _buildStatRow('总订单数', '${orderController.orders.length}'),
                    _buildStatRow('待处理',
                        '${orderController.orders.where((o) => o['status'] == 'pending').length}'),
                    _buildStatRow('进行中',
                        '${orderController.orders.where((o) => o['status'] == 'in_progress').length}'),
                    _buildStatRow('已完成',
                        '${orderController.orders.where((o) => o['status'] == 'completed').length}'),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildClientSimulator() {
    final clientController = Get.find<ClientController>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '👥 客户管理模拟器',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
          ),
          const SizedBox(height: 16),

          // 模拟客户生成
          _buildSimulatorCard(
            title: '生成模拟客户',
            content: Column(
              children: [
                _buildSimulatorButton(
                  '生成已服务客户',
                  () => _generateMockClients(clientController, 'served'),
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _buildSimulatorButton(
                  '生成洽谈中客户',
                  () => _generateMockClients(clientController, 'negotiating'),
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildSimulatorButton(
                  '生成潜在客户',
                  () => _generateMockClients(clientController, 'potential'),
                  Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 客户统计
          _buildSimulatorCard(
            title: '客户统计',
            content: Obx(() => Column(
                  children: [
                    _buildStatRow('总客户数', '${clientController.clients.length}'),
                    _buildStatRow('已服务',
                        '${clientController.clients.where((c) => c['category'] == 'served').length}'),
                    _buildStatRow('洽谈中',
                        '${clientController.clients.where((c) => c['category'] == 'negotiating').length}'),
                    _buildStatRow('潜在',
                        '${clientController.clients.where((c) => c['category'] == 'potential').length}'),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSimulator() {
    final serviceController = Get.find<ServiceManageController>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🛠️ 服务管理模拟器',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
          ),
          const SizedBox(height: 16),

          // 模拟服务生成
          _buildSimulatorCard(
            title: '生成模拟服务',
            content: Column(
              children: [
                _buildSimulatorButton(
                  '生成活跃服务',
                  () => _generateMockServices(serviceController, 'active'),
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _buildSimulatorButton(
                  '生成暂停服务',
                  () => _generateMockServices(serviceController, 'paused'),
                  Colors.orange,
                ),
                const SizedBox(height: 8),
                _buildSimulatorButton(
                  '生成下架服务',
                  () => _generateMockServices(serviceController, 'inactive'),
                  Colors.red,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 服务统计
          _buildSimulatorCard(
            title: '服务统计',
            content: Obx(() => Column(
                  children: [
                    _buildStatRow(
                        '总服务数', '${serviceController.services.length}'),
                    _buildStatRow('活跃',
                        '${serviceController.services.where((s) => s['status'] == 'active').length}'),
                    _buildStatRow('暂停',
                        '${serviceController.services.where((s) => s['status'] == 'paused').length}'),
                    _buildStatRow('下架',
                        '${serviceController.services.where((s) => s['status'] == 'inactive').length}'),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeSimulator() {
    final incomeController = Get.find<IncomeController>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💰 收入管理模拟器',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[700],
                ),
          ),
          const SizedBox(height: 16),

          // 模拟收入生成
          _buildSimulatorCard(
            title: '生成模拟收入',
            content: Column(
              children: [
                _buildSimulatorButton(
                  '生成今日收入',
                  () => _generateMockIncome(incomeController, 'today'),
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _buildSimulatorButton(
                  '生成本周收入',
                  () => _generateMockIncome(incomeController, 'week'),
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildSimulatorButton(
                  '生成本月收入',
                  () => _generateMockIncome(incomeController, 'month'),
                  Colors.purple,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 收入统计
          _buildSimulatorCard(
            title: '收入统计',
            content: Obx(() => Column(
                  children: [
                    _buildStatRow(
                        '总收入', '\$${_calculateTotalIncome(incomeController)}'),
                    _buildStatRow(
                        '今日收入', '\$${_calculateTodayIncome(incomeController)}'),
                    _buildStatRow(
                        '本周收入', '\$${_calculateWeekIncome(incomeController)}'),
                    _buildStatRow(
                        '本月收入', '\$${_calculateMonthIncome(incomeController)}'),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSimulator() {
    final notificationController = Get.find<NotificationController>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔔 通知系统模拟器',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
          ),
          const SizedBox(height: 16),

          // 模拟通知生成
          _buildSimulatorCard(
            title: '生成模拟通知',
            content: Column(
              children: [
                _buildSimulatorButton(
                  '生成订单通知',
                  () => _generateMockNotifications(
                      notificationController, 'order'),
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildSimulatorButton(
                  '生成支付通知',
                  () => _generateMockNotifications(
                      notificationController, 'payment'),
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _buildSimulatorButton(
                  '生成系统通知',
                  () => _generateMockNotifications(
                      notificationController, 'system'),
                  Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 通知统计
          _buildSimulatorCard(
            title: '通知统计',
            content: Obx(() => Column(
                  children: [
                    _buildStatRow('总通知数',
                        '${notificationController.notifications.length}'),
                    _buildStatRow('未读通知',
                        '${notificationController.notifications.where((n) => n['is_read'] == false).length}'),
                    _buildStatRow('已读通知',
                        '${notificationController.notifications.where((n) => n['is_read'] == true).length}'),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatorCard({required String title, required Widget content}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildSimulatorButton(
      String text, VoidCallback onPressed, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue[600],
      unselectedItemColor: Colors.grey[600],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: '订单',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: '客户',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.build),
          label: '服务',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.attach_money),
          label: '收入',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: '通知',
        ),
      ],
    );
  }

  void _showSimulatorSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('模拟器设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('重置所有数据'),
              onTap: () {
                _resetAllData();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('导出模拟数据'),
              onTap: () {
                _exportSimulatorData();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('关于模拟器'),
              onTap: () {
                _showAboutDialog();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  // 模拟数据生成方法
  void _generateMockOrders(OrderManageController controller, String status) {
    final mockOrders = [
      {
        'id': 'ORD${DateTime.now().millisecondsSinceEpoch}',
        'customer_name': '张三',
        'service_name': '清洁服务',
        'status': status,
        'amount': 150.0,
        'created_at': DateTime.now().toString(),
        'scheduled_time':
            DateTime.now().add(const Duration(hours: 2)).toString(),
      },
      {
        'id': 'ORD${DateTime.now().millisecondsSinceEpoch + 1}',
        'customer_name': '李四',
        'service_name': '维修服务',
        'status': status,
        'amount': 200.0,
        'created_at': DateTime.now().toString(),
        'scheduled_time':
            DateTime.now().add(const Duration(hours: 3)).toString(),
      },
    ];

    controller.orders.addAll(mockOrders);
    Get.snackbar(
      '成功',
      '生成了${mockOrders.length}个${_getStatusText(status)}订单',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[800],
    );
  }

  void _generateMockClients(ClientController controller, String category) {
    final mockClients = [
      {
        'id': 'CLI${DateTime.now().millisecondsSinceEpoch}',
        'name': '王五',
        'email': 'wangwu@example.com',
        'phone': '13800138000',
        'category': category,
        'last_contact': DateTime.now().toString(),
        'total_orders': 5,
      },
      {
        'id': 'CLI${DateTime.now().millisecondsSinceEpoch + 1}',
        'name': '赵六',
        'email': 'zhaoliu@example.com',
        'phone': '13800138001',
        'category': category,
        'last_contact': DateTime.now().toString(),
        'total_orders': 3,
      },
    ];

    controller.clients.addAll(mockClients);
    Get.snackbar(
      '成功',
      '生成了${mockClients.length}个${_getCategoryText(category)}客户',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[800],
    );
  }

  void _generateMockServices(
      ServiceManageController controller, String status) {
    final mockServices = [
      {
        'id': 'SRV${DateTime.now().millisecondsSinceEpoch}',
        'name': '专业清洁服务',
        'description': '提供高质量的家庭清洁服务',
        'base_price': 100.0,
        'status': status,
        'category': 'cleaning',
        'duration_minutes': 120,
      },
      {
        'id': 'SRV${DateTime.now().millisecondsSinceEpoch + 1}',
        'name': '设备维修服务',
        'description': '专业维修各种家用设备',
        'base_price': 150.0,
        'status': status,
        'category': 'repair',
        'duration_minutes': 180,
      },
    ];

    controller.services.addAll(mockServices);
    Get.snackbar(
      '成功',
      '生成了${mockServices.length}个${_getStatusText(status)}服务',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[800],
    );
  }

  void _generateMockIncome(IncomeController controller, String period) {
    final mockIncome = [
      {
        'id': 'INC${DateTime.now().millisecondsSinceEpoch}',
        'amount': 150.0,
        'order_id': 'ORD123',
        'payment_method': 'online',
        'status': 'completed',
        'created_at': DateTime.now().toString(),
      },
      {
        'id': 'INC${DateTime.now().millisecondsSinceEpoch + 1}',
        'amount': 200.0,
        'order_id': 'ORD124',
        'payment_method': 'cash',
        'status': 'completed',
        'created_at': DateTime.now().toString(),
      },
    ];

    controller.incomeRecords.addAll(mockIncome);
    Get.snackbar(
      '成功',
      '生成了${mockIncome.length}条${_getPeriodText(period)}收入记录',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[800],
    );
  }

  void _generateMockNotifications(
      NotificationController controller, String type) {
    final mockNotifications = [
      {
        'id': 'NOT${DateTime.now().millisecondsSinceEpoch}',
        'title': _getNotificationTitle(type),
        'message': _getNotificationMessage(type),
        'type': type,
        'is_read': false,
        'created_at': DateTime.now().toString(),
      },
      {
        'id': 'NOT${DateTime.now().millisecondsSinceEpoch + 1}',
        'title': _getNotificationTitle(type),
        'message': _getNotificationMessage(type),
        'type': type,
        'is_read': false,
        'created_at': DateTime.now().toString(),
      },
    ];

    controller.notifications.addAll(mockNotifications);
    Get.snackbar(
      '成功',
      '生成了${mockNotifications.length}条${_getTypeText(type)}通知',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[800],
    );
  }

  // 辅助方法
  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return '待处理';
      case 'in_progress':
        return '进行中';
      case 'completed':
        return '已完成';
      case 'active':
        return '活跃';
      case 'paused':
        return '暂停';
      case 'inactive':
        return '下架';
      default:
        return status;
    }
  }

  String _getCategoryText(String category) {
    switch (category) {
      case 'served':
        return '已服务';
      case 'negotiating':
        return '洽谈中';
      case 'potential':
        return '潜在';
      default:
        return category;
    }
  }

  String _getPeriodText(String period) {
    switch (period) {
      case 'today':
        return '今日';
      case 'week':
        return '本周';
      case 'month':
        return '本月';
      default:
        return period;
    }
  }

  String _getTypeText(String type) {
    switch (type) {
      case 'order':
        return '订单';
      case 'payment':
        return '支付';
      case 'system':
        return '系统';
      default:
        return type;
    }
  }

  String _getNotificationTitle(String type) {
    switch (type) {
      case 'order':
        return '新订单通知';
      case 'payment':
        return '支付成功通知';
      case 'system':
        return '系统维护通知';
      default:
        return '通知';
    }
  }

  String _getNotificationMessage(String type) {
    switch (type) {
      case 'order':
        return '您有一个新的订单，请及时处理。';
      case 'payment':
        return '您的收入已到账，请查收。';
      case 'system':
        return '系统将在今晚进行维护，请提前做好准备。';
      default:
        return '您有一条新消息。';
    }
  }

  // 统计计算方法
  String _calculateTotalIncome(IncomeController controller) {
    double total = 0;
    for (var record in controller.incomeRecords) {
      total += record['amount'] ?? 0;
    }
    return total.toStringAsFixed(2);
  }

  String _calculateTodayIncome(IncomeController controller) {
    double total = 0;
    final today = DateTime.now();
    for (var record in controller.incomeRecords) {
      final recordDate = DateTime.parse(record['created_at']);
      if (recordDate.day == today.day &&
          recordDate.month == today.month &&
          recordDate.year == today.year) {
        total += record['amount'] ?? 0;
      }
    }
    return total.toStringAsFixed(2);
  }

  String _calculateWeekIncome(IncomeController controller) {
    double total = 0;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    for (var record in controller.incomeRecords) {
      final recordDate = DateTime.parse(record['created_at']);
      if (recordDate.isAfter(weekStart)) {
        total += record['amount'] ?? 0;
      }
    }
    return total.toStringAsFixed(2);
  }

  String _calculateMonthIncome(IncomeController controller) {
    double total = 0;
    final now = DateTime.now();
    for (var record in controller.incomeRecords) {
      final recordDate = DateTime.parse(record['created_at']);
      if (recordDate.month == now.month && recordDate.year == now.year) {
        total += record['amount'] ?? 0;
      }
    }
    return total.toStringAsFixed(2);
  }

  // 设置方法
  void _resetAllData() {
    final orderController = Get.find<OrderManageController>();
    final clientController = Get.find<ClientController>();
    final serviceController = Get.find<ServiceManageController>();
    final incomeController = Get.find<IncomeController>();
    final notificationController = Get.find<NotificationController>();

    orderController.orders.clear();
    clientController.clients.clear();
    serviceController.services.clear();
    incomeController.incomeRecords.clear();
    notificationController.notifications.clear();

    Get.snackbar(
      '重置完成',
      '所有模拟数据已清空',
      backgroundColor: Colors.orange[100],
      colorText: Colors.orange[800],
    );
  }

  void _exportSimulatorData() {
    // 这里可以实现数据导出功能
    Get.snackbar(
      '导出功能',
      '数据导出功能开发中...',
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[800],
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于Provider端模拟器'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本: 1.0.0'),
            SizedBox(height: 8),
            Text('功能: 模拟Provider端所有核心功能'),
            SizedBox(height: 8),
            Text('用途: 测试和演示Provider端功能'),
            SizedBox(height: 8),
            Text('开发者: Provider端开发团队'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
