import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Import JinBean UI components
import 'package:jinbeanpod_83904710/core/ui/jinbean_ui.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
// Import platform components
import 'package:jinbeanpod_83904710/core/components/platform_core.dart';
// Import loading components
import 'package:jinbeanpod_83904710/features/customer/services/presentation/widgets/service_detail_loading.dart';

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
  final _supabase = Supabase.instance.client;
  
  // 平台组件状态管理
  final LoadingStateManager _loadingManager = LoadingStateManager();
  
  // 响应式状态变量
  final RxBool isOnline = true.obs;
  final RxInt todayEarnings = 320.obs;
  final RxInt completedOrders = 8.obs;
  final RxDouble rating = 4.8.obs;
  final RxInt pendingOrders = 3.obs;
  final RxInt totalClients = 45.obs;
  final RxInt thisMonthEarnings = 2840.obs;
  
  // 数据状态
  final RxList<Map<String, dynamic>> recentOrders = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> topServices = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> weeklyStats = <String, dynamic>{}.obs;
  
  @override
  void initState() {
    super.initState();
    AppLogger.debug('[ProviderHomePage] initState called', tag: 'ProviderHomePage');
    
    // 初始化网络状态为在线
    _loadingManager.setOnline();
    // 数据已经在controller中加载完成，直接设置为成功状态
    _loadingManager.setSuccess();
  }

  @override
  void dispose() {
    _loadingManager.dispose();
    super.dispose();
  }
  
  /// 加载仪表板数据
  Future<void> _loadDashboardData() async {
    try {
      _loadingManager.setLoading();
      
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await Future.wait([
          _loadRecentOrders(user.id),
          _loadTopServices(user.id),
          _loadWeeklyStats(user.id),
        ]);
        _loadingManager.setSuccess();
        AppLogger.info('Dashboard data loaded successfully', tag: 'ProviderHomePage');
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      AppLogger.error('Error loading dashboard data: $e', tag: 'ProviderHomePage');
      _loadingManager.setError('Failed to load dashboard data: ${e.toString()}');
    }
  }
  
  /// 加载最近订单
  Future<void> _loadRecentOrders(String userId) async {
    try {
      // 模拟最近订单数据
      recentOrders.value = [
        {
          'id': '1',
          'order_number': 'ORD-001',
          'customer_name': '张三',
          'service_name': '清洁服务',
          'amount': 150.0,
          'status': 'completed',
          'created_at': DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          'id': '2',
          'order_number': 'ORD-002',
          'customer_name': '李四',
          'service_name': '维修服务',
          'amount': 200.0,
          'status': 'in_progress',
          'created_at': DateTime.now().subtract(const Duration(hours: 2)),
        },
      ];
    } catch (e) {
      AppLogger.error('Error loading recent orders: $e', tag: 'ProviderHomePage');
      throw e;
    }
  }
  
  /// 加载热门服务
  Future<void> _loadTopServices(String userId) async {
    try {
      // 模拟热门服务数据
      topServices.value = [
        {
          'id': '1',
          'name': '清洁服务',
          'earnings': 1200.0,
          'orders': 15,
          'rating': 4.8,
        },
        {
          'id': '2',
          'name': '维修服务',
          'earnings': 800.0,
          'orders': 8,
          'rating': 4.6,
        },
      ];
    } catch (e) {
      AppLogger.error('Error loading top services: $e', tag: 'ProviderHomePage');
      throw e;
    }
  }
  
  /// 加载周统计数据
  Future<void> _loadWeeklyStats(String userId) async {
    try {
      // 模拟周统计数据
      weeklyStats.value = {
        'total_earnings': 2840,
        'total_orders': 25,
        'completed_orders': 22,
        'pending_orders': 3,
        'average_rating': 4.7,
      };
    } catch (e) {
      AppLogger.error('Error loading weekly stats: $e', tag: 'ProviderHomePage');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListenableBuilder(
        listenable: _loadingManager,
        builder: (context, child) {
          return ServiceDetailLoading(
            state: _loadingManager.state,
            loadingMessage: '加载仪表板数据...',
            errorMessage: _loadingManager.errorMessage,
            onRetry: () => _loadDashboardData(),
            onBack: () => Get.back(),
            showSkeleton: true,
            child: _buildDashboardContent(),
          );
        },
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部区域
          _buildHeaderSection(),
          
          const SizedBox(height: 24),
          
          // 概览卡片
          _buildOverviewCards(),
          
          const SizedBox(height: 24),
          
          // 快速操作
          _buildQuickActionsSection(),
          
          const SizedBox(height: 24),
          
          // 最近订单
          _buildRecentOrdersSection(),
          
          const SizedBox(height: 24),
          
          // 热门服务
          _buildTopServicesSection(),
          
          const SizedBox(height: 24),
          
          // 周统计
          _buildWeeklyStatsSection(),
        ],
      ),
    );
  }

  Widget _buildWeeklyStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: JinBeanColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: JinBeanColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本周统计',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: JinBeanColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '总收入',
                  '\$${weeklyStats['total_earnings'] ?? 0}',
                  Icons.attach_money,
                  JinBeanColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '总订单',
                  '${weeklyStats['total_orders'] ?? 0}',
                  Icons.shopping_cart,
                  JinBeanColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '已完成',
                  '${weeklyStats['completed_orders'] ?? 0}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '待处理',
                  '${weeklyStats['pending_orders'] ?? 0}',
                  Icons.pending,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Provider Dashboard',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: JinBeanColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome back! Here\'s your business overview',
                style: TextStyle(
                  color: JinBeanColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
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

  Widget _buildOverviewCards() {
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
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('待处理订单', '${pendingOrders.value}', Icons.pending, JinBeanColors.warning),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem('总客户数', '${totalClients.value}', Icons.people, JinBeanColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem('本月收入', '\$${thisMonthEarnings.value}', Icons.trending_up, JinBeanColors.success),
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: JinBeanColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: JinBeanColors.textSecondary,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
            GestureDetector(
              onTap: () => widget.onNavigateToTab(3),
              child: Text(
                '更多设置 →',
                style: TextStyle(
                  color: JinBeanColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildActionCard('接单', Icons.shopping_cart, '查看新订单', '5', JinBeanColors.primary, () {
                // 跳转到订单管理页面
                Get.toNamed('/provider/orders');
              }),
              const SizedBox(width: 12),
              _buildActionCard('服务管理', Icons.build, '管理服务项目', '+', JinBeanColors.primary, () {
                _showComingSoon('服务管理');
              }),
              const SizedBox(width: 12),
              _buildActionCard('查看收入', Icons.account_balance_wallet, '收入统计', '\$${thisMonthEarnings.value}', JinBeanColors.warning, () {
                _showComingSoon('查看收入');
              }),
              const SizedBox(width: 12),
              _buildActionCard('通知', Icons.notifications, '消息中心', '3', JinBeanColors.error, () {
                _showComingSoon('通知');
              }),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // 第二行功能入口
        Text(
          '业务管理',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: JinBeanColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildActionCard('日常安排', Icons.calendar_today, '日程管理', '5', Colors.blue, () {
                _showComingSoon('日常安排');
              }),
              const SizedBox(width: 12),
              _buildActionCard('评价管理', Icons.star, '客户评价', '4.8', Colors.amber, () {
                _showComingSoon('评价管理');
              }),
              const SizedBox(width: 12),
              _buildActionCard('推广', Icons.campaign, '广告推广', '2', Colors.purple, () {
                _showComingSoon('推广');
              }),
              const SizedBox(width: 12),
              _buildActionCard('报表', Icons.assessment, '数据报表', '+', Colors.teal, () {
                _showComingSoon('报表');
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
  
  Widget _buildRecentOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '最近订单',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: JinBeanColors.textPrimary,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => widget.onNavigateToTab(1),
              child: Text(
                '查看全部 →',
                style: TextStyle(
                  color: JinBeanColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentOrders.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: JinBeanColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '暂无订单',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: recentOrders.map((order) => _buildOrderCard(order)).toList(),
          ),
      ],
    );
  }
  
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String? ?? 'pending';
    final customerName = order['customer_name'] as String? ?? 'Unknown Customer';
    final serviceName = order['service_name'] as String? ?? 'Unknown Service';
    final amount = order['amount'] as num? ?? 0;
    final createdAt = order['created_at'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: JinBeanColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: JinBeanColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(status),
              color: _getStatusColor(status),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: JinBeanColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customerName,
                  style: TextStyle(
                    fontSize: 14,
                    color: JinBeanColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusText(status),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: JinBeanColors.success,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: JinBeanColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildWeeklyEarningsChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '本周收入趋势',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: JinBeanColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: JinBeanColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: JinBeanColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildChartBar('Mon', weeklyStats['monday'] ?? 0, 300),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildChartBar('Tue', weeklyStats['tuesday'] ?? 0, 300),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildChartBar('Wed', weeklyStats['wednesday'] ?? 0, 300),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildChartBar('Thu', weeklyStats['thursday'] ?? 0, 300),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildChartBar('Fri', weeklyStats['friday'] ?? 0, 300),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildChartBar('Sat', weeklyStats['saturday'] ?? 0, 300),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildChartBar('Sun', weeklyStats['sunday'] ?? 0, 300),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '本周总收入',
                    style: TextStyle(
                      color: JinBeanColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '\$${_calculateWeeklyTotal()}',
                    style: TextStyle(
                      color: JinBeanColors.success,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildChartBar(String label, int value, int maxValue) {
    final height = (value / maxValue) * 100;
    return Column(
      children: [
        Container(
          width: 20,
          height: 100,
          decoration: BoxDecoration(
            color: JinBeanColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 20,
                height: height,
                decoration: BoxDecoration(
                  color: JinBeanColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '\$${value}',
          style: TextStyle(
            fontSize: 10,
            color: JinBeanColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: JinBeanColors.textSecondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTopServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '热门服务',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: JinBeanColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (topServices.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: JinBeanColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.business,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '暂无服务',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: topServices.map((service) => _buildServiceCard(service)).toList(),
          ),
      ],
    );
  }
  
  Widget _buildServiceCard(Map<String, dynamic> service) {
    final name = service['name'] as String? ?? 'Unknown Service';
    final price = service['price'] as num? ?? 0;
    final rating = service['rating'] as num? ?? 0;
    final reviewCount = service['review_count'] as num? ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: JinBeanColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: JinBeanColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: JinBeanColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.business,
              color: JinBeanColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: JinBeanColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${rating.toStringAsFixed(1)} (${reviewCount})',
                      style: TextStyle(
                        fontSize: 14,
                        color: JinBeanColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: JinBeanColors.success,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPerformanceMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '性能指标',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: JinBeanColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                '响应时间',
                '2.3s',
                Icons.speed,
                JinBeanColors.success,
                '平均响应时间',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                '客户满意度',
                '4.8',
                Icons.thumb_up,
                JinBeanColors.primary,
                '平均评分',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                '完成率',
                '95%',
                Icons.check_circle,
                JinBeanColors.warning,
                '订单完成率',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                '复购率',
                '78%',
                Icons.repeat,
                JinBeanColors.error,
                '客户复购率',
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: JinBeanColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: JinBeanColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: JinBeanColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: JinBeanColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper methods
  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return JinBeanColors.success;
      case 'in_progress':
        return JinBeanColors.primary;
      case 'pending':
        return JinBeanColors.warning;
      case 'cancelled':
        return JinBeanColors.error;
      default:
        return JinBeanColors.textSecondary;
    }
  }
  
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.pending;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.receipt;
    }
  }
  
  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return '已完成';
      case 'in_progress':
        return '进行中';
      case 'pending':
        return '待处理';
      case 'cancelled':
        return '已取消';
      default:
        return '未知状态';
    }
  }
  
  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'N/A';
    
    try {
      DateTime date;
      
      if (dateValue is DateTime) {
        date = dateValue;
      } else if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else {
        return 'N/A';
      }
      
      return '${date.month}/${date.day}';
    } catch (e) {
      return 'N/A';
    }
  }
  
  String _calculateWeeklyTotal() {
    int total = 0;
    weeklyStats.forEach((key, value) {
      total += value as int;
    });
    return total.toString();
  }

  void _showComingSoon(String featureName) {
    Get.snackbar(
      '功能待开发',
      '「$featureName」功能正在开发中，敬请期待！',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: JinBeanColors.warning.withOpacity(0.8),
      colorText: Colors.white,
      borderRadius: 8,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }
} 
