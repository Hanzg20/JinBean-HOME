import 'dart:async';
import 'package:get/get.dart';
import '../models/base_models.dart';
import '../models/order_models.dart';
import '../models/payment_models.dart';
import '../services/universal_order_service.dart';
import '../services/universal_payment_service.dart';
import '../services/notification_service.dart';

/// 通用订单控制器
/// 
/// 提供跨行业的统一订单管理功能：
/// - 订单创建和管理
/// - 支付处理和状态跟踪
/// - 用户界面状态管理
/// - 错误处理和消息提示
class UniversalOrderController extends GetxController {
  final UniversalOrderService _orderService = Get.find<UniversalOrderService>();
  final UniversalPaymentService _paymentService = Get.find<UniversalPaymentService>();

  // ========================================
  // 响应式状态管理
  // ========================================

  /// 订单列表
  final RxList<Order> orders = <Order>[].obs;

  /// 当前订单
  final Rx<Order?> currentOrder = Rx<Order?>(null);

  /// 分页信息
  final Rx<Pagination?> pagination = Rx<Pagination?>(null);

  /// 支付意图
  final Rx<PaymentIntent?> paymentIntent = Rx<PaymentIntent?>(null);

  /// 支付方式列表
  final RxList<PaymentMethod> paymentMethods = <PaymentMethod>[].obs;

  /// 当前选择的支付方式
  final Rx<PaymentMethod?> selectedPaymentMethod = Rx<PaymentMethod?>(null);

  /// 定价结果
  final Rx<PricingResult?> pricingResult = Rx<PricingResult?>(null);

  /// 加载状态
  final RxBool isLoading = false.obs;
  final RxBool isCreatingOrder = false.obs;
  final RxBool isProcessingPayment = false.obs;
  final RxBool isCalculatingPrice = false.obs;
  final RxBool isRefreshing = false.obs;

  /// 错误和成功消息
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  /// 过滤条件
  final Rx<IndustryType?> filterIndustry = Rx<IndustryType?>(null);
  final Rx<OrderStatus?> filterStatus = Rx<OrderStatus?>(null);

  // ========================================
  // 生命周期方法
  // ========================================

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  void _initializeController() {
    print('🔄 通用订单控制器初始化');
    loadOrders();
    loadPaymentMethods();
  }

  @override
  void onClose() {
    _clearMessages();
    super.onClose();
  }

  // ========================================
  // 订单管理
  // ========================================

  /// 加载订单列表
  Future<void> loadOrders({
    int page = 1,
    int limit = 20,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        isRefreshing.value = true;
      } else {
        isLoading.value = true;
      }
      
      errorMessage.value = '';

      print('📋 加载订单列表 - 页码: $page');

      final result = await _orderService.getUserOrders(
        industry: filterIndustry.value,
        status: filterStatus.value,
        page: page,
        limit: limit,
      );

      if (page == 1 || refresh) {
        orders.clear();
      }
      
      orders.addAll(result.items);
      pagination.value = result.pagination;

      print('✅ 订单列表加载完成，共${result.items.length}个订单');

    } catch (e) {
      print('❌ 加载订单列表失败: $e');
      errorMessage.value = '加载订单列表失败: $e';
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// 获取订单详情
  Future<void> getOrderDetails(String orderId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('🔍 获取订单详情: $orderId');

      final order = await _orderService.getOrderById(orderId);
      currentOrder.value = order;

      // 同时获取支付记录
      await loadOrderPayments(orderId);

      print('✅ 订单详情获取成功');

    } catch (e) {
      print('❌ 获取订单详情失败: $e');
      errorMessage.value = '获取订单详情失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 创建订单
  Future<Order?> createOrder(OrderRequest request) async {
    try {
      isCreatingOrder.value = true;
      errorMessage.value = '';

      print('🆕 创建订单: ${request.industry.label}');

      final order = await _orderService.createOrder(request);
      
      // 添加到订单列表的开头
      orders.insert(0, order);
      currentOrder.value = order;

      successMessage.value = '订单创建成功';
      print('✅ 订单创建成功: ${order.orderNumber}');

      return order;

    } catch (e) {
      print('❌ 订单创建失败: $e');
      errorMessage.value = '订单创建失败: $e';
      return null;
    } finally {
      isCreatingOrder.value = false;
    }
  }

  /// 更新订单状态
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? reason,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('🔄 更新订单状态: $orderId -> ${newStatus.label}');

      final updatedOrder = await _orderService.updateOrderStatus(
        orderId: orderId,
        newStatus: newStatus,
        reason: reason,
      );

      // 更新本地订单列表
      final index = orders.indexWhere((order) => order.id == orderId);
      if (index >= 0) {
        orders[index] = updatedOrder;
      }

      // 如果是当前订单，也更新当前订单
      if (currentOrder.value?.id == orderId) {
        currentOrder.value = updatedOrder;
      }

      successMessage.value = '订单状态已更新';
      print('✅ 订单状态更新成功');

      // 发送通知
      try {
        final notificationService = Get.find<NotificationService>();
        await notificationService.showOrderNotification(
          '订单状态更新',
          '您的订单已更新为：${newStatus.label}',
          orderId,
        );
      } catch (e) {
        print('通知发送失败: $e');
      }

    } catch (e) {
      print('❌ 更新订单状态失败: $e');
      errorMessage.value = '更新订单状态失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 取消订单
  Future<void> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('❌ 取消订单: $orderId');

      final cancelledOrder = await _orderService.cancelOrder(
        orderId: orderId,
        reason: reason,
      );

      // 更新本地订单列表
      final index = orders.indexWhere((order) => order.id == orderId);
      if (index >= 0) {
        orders[index] = cancelledOrder;
      }

      // 如果是当前订单，也更新当前订单
      if (currentOrder.value?.id == orderId) {
        currentOrder.value = cancelledOrder;
      }

      successMessage.value = '订单已取消';
      print('✅ 订单取消成功');

    } catch (e) {
      print('❌ 取消订单失败: $e');
      errorMessage.value = '取消订单失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // 定价计算
  // ========================================

  /// 计算订单价格
  Future<void> calculateOrderPrice(OrderRequest request) async {
    try {
      isCalculatingPrice.value = true;
      errorMessage.value = '';

      print('🧮 计算订单价格');

      final result = await _orderService.calculateOrderPricing(request);
      pricingResult.value = result;

      print('✅ 价格计算完成，总金额: ${result.totalAmount.formatted}');

    } catch (e) {
      print('❌ 价格计算失败: $e');
      errorMessage.value = '价格计算失败: $e';
      pricingResult.value = null;
    } finally {
      isCalculatingPrice.value = false;
    }
  }

  // ========================================
  // 支付管理
  // ========================================

  /// 加载支付方式列表
  Future<void> loadPaymentMethods() async {
    try {
      print('💳 加载支付方式列表');

      // TODO: 获取当前用户ID
      const userId = 'current_user_id';
      final methods = await _paymentService.getUserPaymentMethods(userId);
      
      paymentMethods.clear();
      paymentMethods.addAll(methods);

      // 设置默认支付方式
      final defaultMethod = methods.firstWhereOrNull((method) => method.isDefault);
      if (defaultMethod != null) {
        selectedPaymentMethod.value = defaultMethod;
      }

      print('✅ 支付方式列表加载完成，共${methods.length}个');

    } catch (e) {
      print('❌ 加载支付方式列表失败: $e');
    }
  }

  /// 选择支付方式
  void selectPaymentMethod(PaymentMethod paymentMethod) {
    selectedPaymentMethod.value = paymentMethod;
    print('💳 选择支付方式: ${paymentMethod.displayName}');
  }

  /// 创建支付意图
  Future<PaymentIntent?> createPaymentIntent(Order order) async {
    try {
      isProcessingPayment.value = true;
      errorMessage.value = '';

      if (selectedPaymentMethod.value == null) {
        errorMessage.value = '请选择支付方式';
        return null;
      }

      print('💳 创建支付意图: ${order.orderNumber}');

      final intent = await _paymentService.createPaymentIntent(
        order: order,
        paymentMethod: selectedPaymentMethod.value!,
      );

      paymentIntent.value = intent;
      print('✅ 支付意图创建成功: ${intent.id}');

      return intent;

    } catch (e) {
      print('❌ 创建支付意图失败: $e');
      errorMessage.value = '创建支付意图失败: $e';
      return null;
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// 确认支付
  Future<bool> confirmPayment({
    required String paymentIntentId,
    String? confirmationToken,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      isProcessingPayment.value = true;
      errorMessage.value = '';

      print('🔍 确认支付: $paymentIntentId');

      final result = await _paymentService.confirmPayment(
        paymentIntentId: paymentIntentId,
        confirmationToken: confirmationToken,
        additionalData: additionalData,
      );

      if (result.success) {
        successMessage.value = '支付成功';
        print('✅ 支付确认成功');
        
        // 重新加载订单以获取最新状态
        if (currentOrder.value != null) {
          await getOrderDetails(currentOrder.value!.id);
        }
        
        return true;
      } else {
        errorMessage.value = result.message;
        print('❌ 支付确认失败: ${result.message}');
        return false;
      }

    } catch (e) {
      print('❌ 确认支付失败: $e');
      errorMessage.value = '确认支付失败: $e';
      return false;
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// 处理退款
  Future<bool> processRefund({
    required String orderId,
    Price? amount,
    required String reason,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('💸 处理退款: $orderId');

      final result = await _paymentService.processRefund(
        orderId: orderId,
        amount: amount,
        reason: reason,
      );

      if (result.success) {
        successMessage.value = '退款处理成功';
        print('✅ 退款处理成功');
        
        // 重新加载订单以获取最新状态
        await getOrderDetails(orderId);
        
        return true;
      } else {
        errorMessage.value = result.message;
        print('❌ 退款处理失败: ${result.message}');
        return false;
      }

    } catch (e) {
      print('❌ 退款处理失败: $e');
      errorMessage.value = '退款处理失败: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载订单支付记录
  Future<void> loadOrderPayments(String orderId) async {
    try {
      print('💳 加载订单支付记录: $orderId');

      final payments = await _paymentService.getOrderPayments(orderId);
      
      // 将支付记录添加到订单元数据中
      if (currentOrder.value?.id == orderId) {
        currentOrder.value?.setIndustryData('payments', payments.map((p) => p.toJson()).toList());
      }

      print('✅ 支付记录加载完成，共${payments.length}条');

    } catch (e) {
      print('❌ 加载支付记录失败: $e');
    }
  }

  // ========================================
  // 过滤和搜索
  // ========================================

  /// 设置行业过滤
  void setIndustryFilter(IndustryType? industry) {
    filterIndustry.value = industry;
    print('🔍 设置行业过滤: ${industry?.label ?? '全部'}');
    
    // 重新加载订单
    loadOrders(refresh: true);
  }

  /// 设置状态过滤
  void setStatusFilter(OrderStatus? status) {
    filterStatus.value = status;
    print('🔍 设置状态过滤: ${status?.label ?? '全部'}');
    
    // 重新加载订单
    loadOrders(refresh: true);
  }

  /// 清除所有过滤条件
  void clearFilters() {
    filterIndustry.value = null;
    filterStatus.value = null;
    print('🔍 清除所有过滤条件');
    
    // 重新加载订单
    loadOrders(refresh: true);
  }

  // ========================================
  // 消息管理
  // ========================================

  /// 清除所有消息
  void _clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  /// 清除错误消息
  void clearError() {
    errorMessage.value = '';
  }

  /// 清除成功消息
  void clearSuccess() {
    successMessage.value = '';
  }

  /// 显示成功消息
  void showSuccess(String message) {
    successMessage.value = message;
    print('✅ $message');
  }

  /// 显示错误消息
  void showError(String message) {
    errorMessage.value = message;
    print('❌ $message');
  }

  // ========================================
  // 计算属性
  // ========================================

  /// 获取活跃订单列表
  List<Order> get activeOrders {
    return orders.where((order) => order.isActive).toList();
  }

  /// 获取已完成订单列表
  List<Order> get completedOrders {
    return orders.where((order) => order.isCompleted).toList();
  }

  /// 获取已取消订单列表
  List<Order> get cancelledOrders {
    return orders.where((order) => order.isCancelled).toList();
  }

  /// 是否有活跃订单
  bool get hasActiveOrders => activeOrders.isNotEmpty;

  /// 是否可以加载更多
  bool get canLoadMore {
    final p = pagination.value;
    return p != null && p.hasNext;
  }

  /// 当前页码
  int get currentPage => pagination.value?.page ?? 1;

  /// 总页数
  int get totalPages => pagination.value?.totalPages ?? 1;

  /// 总订单数
  int get totalOrders => pagination.value?.total ?? 0;

  /// 是否有错误
  bool get hasError => errorMessage.value.isNotEmpty;

  /// 是否有成功消息
  bool get hasSuccess => successMessage.value.isNotEmpty;

  /// 是否正在处理任何操作
  bool get isProcessing => 
      isLoading.value || 
      isCreatingOrder.value || 
      isProcessingPayment.value || 
      isCalculatingPrice.value;

  // ========================================
  // 实用方法
  // ========================================

  /// 按行业分组订单
  Map<IndustryType, List<Order>> get ordersByIndustry {
    final grouped = <IndustryType, List<Order>>{};
    
    for (final order in orders) {
      if (!grouped.containsKey(order.industry)) {
        grouped[order.industry] = [];
      }
      grouped[order.industry]!.add(order);
    }
    
    return grouped;
  }

  /// 按状态分组订单
  Map<OrderStatus, List<Order>> get ordersByStatus {
    final grouped = <OrderStatus, List<Order>>{};
    
    for (final order in orders) {
      if (!grouped.containsKey(order.status)) {
        grouped[order.status] = [];
      }
      grouped[order.status]!.add(order);
    }
    
    return grouped;
  }

  /// 获取订单统计信息
  Map<String, int> get orderStatistics {
    return {
      'total': orders.length,
      'active': activeOrders.length,
      'completed': completedOrders.length,
      'cancelled': cancelledOrders.length,
      'pending_payment': orders.where((o) => o.paymentStatus == PaymentStatus.pending).length,
      'paid': orders.where((o) => o.paymentStatus == PaymentStatus.completed).length,
    };
  }

  /// 重置控制器状态
  void reset() {
    orders.clear();
    currentOrder.value = null;
    pagination.value = null;
    paymentIntent.value = null;
    pricingResult.value = null;
    selectedPaymentMethod.value = null;
    filterIndustry.value = null;
    filterStatus.value = null;
    _clearMessages();
    
    print('🔄 订单控制器状态已重置');
  }

  /// 刷新数据
  Future<void> refresh() async {
    await loadOrders(refresh: true);
    await loadPaymentMethods();
  }

  /// 加载下一页
  Future<void> loadNextPage() async {
    if (canLoadMore && !isLoading.value) {
      await loadOrders(page: currentPage + 1);
    }
  }
}
