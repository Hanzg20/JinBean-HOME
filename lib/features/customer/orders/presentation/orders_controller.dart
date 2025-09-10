import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/controllers/universal_order_controller.dart';
import 'package:jinbeanpod_83904710/core/models/order_models.dart';
import 'package:jinbeanpod_83904710/core/models/base_models.dart';

class OrdersController extends GetxController {
  // 集成UniversalOrderController
  late final UniversalOrderController _universalOrderController;
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedStatus = 'All'.obs;

  // 使用统一的Order模型
  RxList<Order> get orders => _universalOrderController.orders;
  bool get hasError => _universalOrderController.hasError;
  String get error => _universalOrderController.errorMessage.value;

  final List<String> statusFilters = [
    'All',
    'PendingAcceptance',
    'Accepted',
    'InProgress',
    'Completed',
    'Canceled',
  ];

  @override
  void onInit() {
    super.onInit();
    
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
    try {
      AppLogger.info('OrdersController: loadOrders called');
      
      // 使用UniversalOrderController加载订单
      await _universalOrderController.loadOrders(refresh: true);
      
      AppLogger.info('OrdersController: Orders loaded successfully, count: ${orders.length}');
      
    } catch (e) {
      AppLogger.info('OrdersController: Error loading orders: $e');
      errorMessage.value = 'Failed to load orders: $e';
    }
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    
    // 将字符串状态转换为OrderStatus枚举
    OrderStatus? orderStatus;
    switch (status) {
      case 'PendingAcceptance':
        orderStatus = OrderStatus.pending;
        break;
      case 'Accepted':
        orderStatus = OrderStatus.accepted;
        break;
      case 'InProgress':
        orderStatus = OrderStatus.inProgress;
        break;
      case 'Completed':
        orderStatus = OrderStatus.completed;
        break;
      case 'Canceled':
        orderStatus = OrderStatus.cancelled;
        break;
      default:
        orderStatus = null; // All
    }
    
    _universalOrderController.setStatusFilter(orderStatus);
  }

  String getStatusColor(String status) {
    switch (status) {
      case 'PendingAcceptance':
        return '#FFA500'; // Orange
      case 'Accepted':
        return '#4CAF50'; // Green
      case 'InProgress':
        return '#2196F3'; // Blue
      case 'Completed':
        return '#4CAF50'; // Green
      case 'Canceled':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'PendingAcceptance':
        return 'Pending Acceptance';
      case 'Accepted':
        return 'Accepted';
      case 'InProgress':
        return 'In Progress';
      case 'Completed':
        return 'Completed';
      case 'Canceled':
        return 'Canceled';
      default:
        return status;
    }
  }

  String getPaymentStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return '#4CAF50'; // Green
      case 'Pending':
        return '#FFA500'; // Orange
      case 'Failed':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  void navigateToOrderDetail(String orderId) {
    Get.toNamed('/order_detail', arguments: orderId);
  }

  void navigateToCreateOrder() {
    Get.toNamed('/create_order');
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      AppLogger.info('OrdersController: cancelOrder called for $orderId');
      
      // 使用UniversalOrderController取消订单
      await _universalOrderController.cancelOrder(
        orderId: orderId, 
        reason: 'Cancelled by user'
      );

      Get.snackbar(
        'Success',
        'Order cancelled successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (e) {
      AppLogger.info('OrdersController: Error cancelling order: $e');
      Get.snackbar(
        'Error',
        'Failed to cancel order',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // 获取订单详情
  Future<void> getOrderDetails(String orderId) async {
    AppLogger.info('OrdersController: getOrderDetails called for $orderId');
    await _universalOrderController.getOrderDetails(orderId);
  }
  
  // 更新订单状态
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus, {String? reason}) async {
    AppLogger.info('OrdersController: updateOrderStatus called for $orderId to ${newStatus.label}');
    await _universalOrderController.updateOrderStatus(
      orderId: orderId, 
      newStatus: newStatus,
      reason: reason,
    );
  }
  
  // 清除过滤条件
  void clearFilters() {
    selectedStatus.value = 'All';
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
