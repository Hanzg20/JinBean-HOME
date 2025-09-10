import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:jinbeanpod_83904710/core/controllers/universal_order_controller.dart';
import 'package:jinbeanpod_83904710/core/models/order_models.dart';
import 'package:jinbeanpod_83904710/core/models/base_models.dart';

class MyOrdersController extends GetxController {
  // 集成UniversalOrderController
  late final UniversalOrderController _universalOrderController;
  
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // 使用统一的Order模型
  RxList<Order> get orders => _universalOrderController.orders;
  bool get hasError => _universalOrderController.hasError;
  String get error => _universalOrderController.errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('MyOrdersController initialized', tag: 'MyOrdersController');
    
    // 获取或创建UniversalOrderController实例
    try {
      _universalOrderController = Get.find<UniversalOrderController>();
    } catch (e) {
      _universalOrderController = Get.put(UniversalOrderController());
    }
    
    // 监听加载状态
    ever(_universalOrderController.isLoading, (loading) {
      isLoading.value = loading;
    });
    
    // 监听错误消息
    ever(_universalOrderController.errorMessage, (error) {
      errorMessage.value = error;
    });
    
    loadOrders();
  }

  Future<void> loadOrders() async {
    AppLogger.info('MyOrdersController: loadOrders called',
        tag: 'MyOrdersController');
    
    try {
      // 使用UniversalOrderController加载订单
      await _universalOrderController.loadOrders(refresh: true);
      
      AppLogger.info('MyOrdersController: Orders loaded successfully, count: ${orders.length}',
          tag: 'MyOrdersController');
          
    } catch (e, stack) {
      AppLogger.error('MyOrdersController: Failed to load orders',
          error: e, stackTrace: stack, tag: 'MyOrdersController');
      errorMessage.value = 'Failed to load orders: $e';
    }
  }

  Future<void> refreshOrders() async {
    AppLogger.info('MyOrdersController: refreshOrders called',
        tag: 'MyOrdersController');
    await loadOrders();
  }
  
  // 获取订单详情
  Future<void> getOrderDetails(String orderId) async {
    AppLogger.info('MyOrdersController: getOrderDetails called for $orderId',
        tag: 'MyOrdersController');
    await _universalOrderController.getOrderDetails(orderId);
  }
  
  // 取消订单
  Future<void> cancelOrder(String orderId, String reason) async {
    AppLogger.info('MyOrdersController: cancelOrder called for $orderId',
        tag: 'MyOrdersController');
    await _universalOrderController.cancelOrder(orderId: orderId, reason: reason);
  }
  
  // 更新订单状态
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus, {String? reason}) async {
    AppLogger.info('MyOrdersController: updateOrderStatus called for $orderId to ${newStatus.label}',
        tag: 'MyOrdersController');
    await _universalOrderController.updateOrderStatus(
      orderId: orderId, 
      newStatus: newStatus,
      reason: reason,
    );
  }
  
  // 按状态过滤订单
  void filterByStatus(OrderStatus? status) {
    AppLogger.info('MyOrdersController: filterByStatus called with ${status?.label ?? 'All'}',
        tag: 'MyOrdersController');
    _universalOrderController.setStatusFilter(status);
  }
  
  // 清除过滤条件
  void clearFilters() {
    AppLogger.info('MyOrdersController: clearFilters called',
        tag: 'MyOrdersController');
    _universalOrderController.clearFilters();
  }
  
  // 获取活跃订单
  List<Order> get activeOrders => _universalOrderController.activeOrders;
  
  // 获取已完成订单
  List<Order> get completedOrders => _universalOrderController.completedOrders;
  
  // 获取已取消订单
  List<Order> get cancelledOrders => _universalOrderController.cancelledOrders;
  
  // 获取订单统计
  Map<String, int> get orderStatistics => _universalOrderController.orderStatistics;
}
