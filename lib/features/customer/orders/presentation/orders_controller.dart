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

  // 分页相关
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxBool isLoadingMore = false.obs;
  static const int pageSize = 20; // 每页加载20条

  // 过滤后的订单列表（缓存）
  final RxList<Order> _filteredOrders = <Order>[].obs;

  // 使用统一的Order模型
  RxList<Order> get orders => selectedStatus.value == 'All'
      ? _universalOrderController.orders
      : _filteredOrders;

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

  Future<void> loadOrders({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        hasMore.value = true;
      }

      AppLogger.info('OrdersController: loadOrders called (page: ${currentPage.value})');

      // 使用UniversalOrderController加载订单
      await _universalOrderController.loadOrders(refresh: refresh);

      // 应用当前过滤
      _applyCurrentFilter();

      AppLogger.info('OrdersController: Orders loaded successfully, count: ${orders.length}');

    } catch (e) {
      AppLogger.info('OrdersController: Error loading orders: $e');
      errorMessage.value = 'Failed to load orders: $e';
    }
  }

  /// 加载更多订单（分页）
  Future<void> loadMoreOrders() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      // TODO: 实现真正的分页加载
      // 目前先模拟分页效果
      await Future.delayed(const Duration(milliseconds: 500));

      // 如果已经加载所有订单，设置hasMore为false
      if (orders.length >= _universalOrderController.orders.length) {
        hasMore.value = false;
      }

    } catch (e) {
      AppLogger.error('Error loading more orders: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 应用过滤（优化版本，使用缓存）
  void filterByStatus(String status) {
    if (selectedStatus.value == status) return; // 避免重复过滤

    selectedStatus.value = status;
    _applyCurrentFilter();
  }

  /// 应用当前过滤条件
  void _applyCurrentFilter() {
    if (selectedStatus.value == 'All') {
      // 如果是'All'，直接使用原始列表，不需要过滤
      return;
    }

    // 将字符串状态转换为OrderStatus枚举
    OrderStatus? orderStatus = _getOrderStatusFromString(selectedStatus.value);

    if (orderStatus == null) {
      _filteredOrders.value = _universalOrderController.orders.toList();
    } else {
      // 过滤订单
      _filteredOrders.value = _universalOrderController.orders
          .where((order) => order.status == orderStatus)
          .toList();
    }
  }

  /// 字符串转OrderStatus枚举（提取为独立方法）
  OrderStatus? _getOrderStatusFromString(String status) {
    switch (status) {
      case 'PendingAcceptance':
        return OrderStatus.pending;
      case 'Accepted':
        return OrderStatus.accepted;
      case 'InProgress':
        return OrderStatus.inProgress;
      case 'Completed':
        return OrderStatus.completed;
      case 'Canceled':
        return OrderStatus.cancelled;
      default:
        return null; // All
    }
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
