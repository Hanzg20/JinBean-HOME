import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/order_manage/order_manage_page.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/rob_order_hall/presentation/rob_order_hall_page.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/order_manage/order_manage_controller.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/rob_order_hall/rob_order_hall_controller.dart';
// Import platform components
import 'package:jinbeanpod_83904710/core/components/platform_core.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
// Import loading components
import 'package:jinbeanpod_83904710/features/customer/services/presentation/widgets/service_detail_loading.dart';

class OrdersShellPage extends StatefulWidget {
  const OrdersShellPage({super.key});

  @override
  State<OrdersShellPage> createState() => _OrdersShellPageState();
}

class _OrdersShellPageState extends State<OrdersShellPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // 平台组件状态管理
  final LoadingStateManager _loadingManager = LoadingStateManager();

  @override
  void initState() {
    super.initState();
    AppLogger.debug('[OrdersShellPage] initState called', tag: 'OrdersShellPage');
    
    // 初始化网络状态为在线
    _loadingManager.setOnline();
    
    // 确保Controller被注册
    if (!Get.isRegistered<OrderManageController>()) {
      Get.put(OrderManageController());
    }
    if (!Get.isRegistered<RobOrderHallController>()) {
      Get.put(RobOrderHallController());
    }
    
    _tabController = TabController(length: 2, vsync: this);
    
    // 数据已经在controller中加载完成，直接设置为成功状态
    _loadingManager.setSuccess();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loadingManager.dispose();
    super.dispose();
  }

  /// 加载订单数据
  Future<void> _loadOrdersData() async {
    try {
      _loadingManager.setLoading();
      
      // 加载订单数据
      await Get.find<OrderManageController>().loadOrders();
      await Get.find<RobOrderHallController>().loadStatistics();
      
      _loadingManager.setSuccess();
    } catch (e) {
      _loadingManager.setError('加载订单数据失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '订单管理',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(
              icon: Icon(Icons.assignment),
              text: '订单管理',
            ),
            Tab(
              icon: Icon(Icons.flash_on),
              text: '抢单大厅',
            ),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _loadingManager,
        builder: (context, child) {
          return ServiceDetailLoading(
            state: _loadingManager.state,
            errorMessage: _loadingManager.errorMessage,
            onRetry: () => _loadOrdersData(),
            child: TabBarView(
              controller: _tabController,
              children: [
                // 订单管理
                Expanded(
                  child: OrderManagePage(),
                ),
                // 抢单大厅页面
                Expanded(
                  child: RobOrderHallPage(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 