import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/base_models.dart';
import '../models/order_models.dart';
import '../models/payment_models.dart';

/// 通用订单服务
/// 
/// 提供跨行业的统一订单管理功能：
/// - 订单创建、查询、更新
/// - 状态管理和流程控制
/// - 行业特定逻辑的抽象接口
/// - 数据库操作的统一封装
class UniversalOrderService extends GetxService {
  final _supabase = Supabase.instance.client;

  /// 行业特定处理器注册表
  final Map<IndustryType, IndustryOrderHandler> _industryHandlers = {};

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  void _initializeService() {
    print('🔄 通用订单服务初始化');
  }

  /// 注册行业特定处理器
  void registerIndustryHandler(IndustryType industry, IndustryOrderHandler handler) {
    _industryHandlers[industry] = handler;
    print('📋 注册${industry.label}行业处理器');
  }

  /// 获取行业处理器
  IndustryOrderHandler? getIndustryHandler(IndustryType industry) {
    return _industryHandlers[industry];
  }

  // ========================================
  // 订单创建
  // ========================================

  /// 创建订单
  Future<Order> createOrder(OrderRequest request) async {
    try {
      print('🆕 创建${request.industry.label}订单');

      // 1. 验证订单请求
      final validation = await validateOrderRequest(request);
      if (!validation.isValid) {
        throw OrderException('订单验证失败: ${validation.firstError}');
      }

      // 2. 生成订单基础信息
      final orderId = _generateOrderId();
      final orderNumber = _generateOrderNumber(request.industry);

      // 3. 调用行业处理器进行预处理
      final handler = getIndustryHandler(request.industry);
      if (handler != null) {
        await handler.preprocessOrder(request);
      }

      // 4. 计算价格
      final pricingResult = await calculateOrderPricing(request);

      // 5. 创建订单记录
      final order = Order(
        id: orderId,
        orderNumber: orderNumber,
        customerId: _getCurrentUserId(),
        providerId: request.providerId,
        serviceId: request.serviceId,
        industry: request.industry,
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.pending,
        orderType: request.orderType,
        totalAmount: pricingResult.totalAmount,
        pricingBreakdown: pricingResult.toJson(),
        scheduledTime: request.scheduledTime,
        serviceAddress: request.serviceAddress,
        industryMetadata: request.industrySpecificData.toJson(),
        items: [],
        customerNotes: request.customerNotes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 6. 保存到数据库
      await _saveOrderToDatabase(order);

      // 7. 创建订单项目
      for (final itemRequest in request.items) {
        final orderItem = await _createOrderItem(orderId, itemRequest);
        order.items.add(orderItem);
      }

      // 8. 调用行业处理器进行后处理
      if (handler != null) {
        await handler.postprocessOrder(order);
      }

      print('✅ 订单创建成功: ${order.orderNumber}');
      return order;

    } catch (e) {
      print('❌ 订单创建失败: $e');
      rethrow;
    }
  }

  /// 验证订单请求
  Future<ValidationResult> validateOrderRequest(OrderRequest request) async {
    final errors = <String>[];
    final fieldErrors = <String, String>{};

    // 基础验证
    if (request.serviceId.isEmpty) {
      fieldErrors['service_id'] = '服务ID不能为空';
    }

    if (request.providerId.isEmpty) {
      fieldErrors['provider_id'] = '服务商ID不能为空';
    }

    if (request.items.isEmpty) {
      fieldErrors['items'] = '订单项目不能为空';
    }

    // 验证订单项目
    for (int i = 0; i < request.items.length; i++) {
      final item = request.items[i];
      if (item.quantity <= 0) {
        fieldErrors['items[$i].quantity'] = '商品数量必须大于0';
      }
      if (item.unitPrice < 0) {
        fieldErrors['items[$i].unit_price'] = '商品价格不能为负数';
      }
    }

    // 行业特定验证
    final handler = getIndustryHandler(request.industry);
    if (handler != null) {
      final industryValidation = await handler.validateOrder(request);
      if (!industryValidation.isValid) {
        errors.addAll(industryValidation.errors);
        fieldErrors.addAll(industryValidation.fieldErrors);
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty && fieldErrors.isEmpty,
      errors: errors,
      fieldErrors: fieldErrors,
    );
  }

  /// 计算订单价格
  Future<PricingResult> calculateOrderPricing(OrderRequest request) async {
    try {
      print('🧮 计算订单价格');

      // 1. 计算基础金额
      final baseAmount = _calculateBaseAmount(request.items);

      // 2. 获取定价规则
      final pricingRules = await _getPricingRules(request.serviceId, request.industry);

      // 3. 应用定价规则
      final fees = <PricingFee>[];
      final appliedRules = <PricingRule>[];

      for (final rule in pricingRules) {
        if (rule.isApplicable(orderAmount: baseAmount)) {
          final fee = _applyPricingRule(rule, baseAmount, request);
          if (fee.amount.amount > 0) {
            fees.add(fee);
            appliedRules.add(rule);
          }
        }
      }

      // 4. 处理优惠券
      final discounts = <PricingDiscount>[];
      Coupon? appliedCoupon;
      if (request.couponCode != null) {
        final couponResult = await _applyCoupon(request.couponCode!, baseAmount, request);
        if (couponResult != null) {
          discounts.add(couponResult.discount);
          appliedCoupon = couponResult.coupon;
        }
      }

      // 5. 计算总金额
      final feesTotal = fees.fold(
        Price(amount: 0.0, currency: baseAmount.currency),
        (sum, fee) => sum + fee.amount,
      );

      final discountsTotal = discounts.fold(
        Price(amount: 0.0, currency: baseAmount.currency),
        (sum, discount) => sum + discount.amount,
      );

      final totalAmount = baseAmount + feesTotal - discountsTotal;

      // 6. 调用行业处理器进行价格调整
      final handler = getIndustryHandler(request.industry);
      if (handler != null) {
        final adjustedResult = await handler.adjustPricing(
          baseAmount: baseAmount,
          fees: fees,
          discounts: discounts,
          request: request,
        );
        if (adjustedResult != null) {
          return adjustedResult;
        }
      }

      return PricingResult(
        baseAmount: baseAmount,
        fees: fees,
        discounts: discounts,
        totalAmount: totalAmount,
        currency: baseAmount.currency,
        appliedRules: appliedRules,
        appliedCoupon: appliedCoupon,
      );

    } catch (e) {
      print('❌ 价格计算失败: $e');
      throw OrderException('价格计算失败: $e');
    }
  }

  // ========================================
  // 订单查询
  // ========================================

  /// 获取用户订单列表
  Future<PagedResult<Order>> getUserOrders({
    String? userId,
    IndustryType? industry,
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final targetUserId = userId ?? _getCurrentUserId();
      print('📋 获取用户订单列表: $targetUserId');

      var query = _supabase
          .from('orders')
          .select(_getOrderSelectQuery())
          .eq('user_id', targetUserId);

      // 应用过滤条件
      if (industry != null) {
        query = query.eq('industry_type', industry.code);
      }

      if (status != null) {
        query = query.eq('order_status', status.code);
      }

      // 分页
      final offset = (page - 1) * limit;
      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // 获取总数
      final countResponse = await _supabase
          .from('orders')
          .select('id')
          .eq('user_id', targetUserId);

      final total = countResponse.length;
      final totalPages = (total / limit).ceil();

      final orders = response.map((data) => Order.fromJson(data)).toList();

      return PagedResult(
        items: orders,
        pagination: Pagination(
          page: page,
          limit: limit,
          total: total,
          totalPages: totalPages,
        ),
      );

    } catch (e) {
      print('❌ 获取订单列表失败: $e');
      throw OrderException('获取订单列表失败: $e');
    }
  }

  /// 获取订单详情
  Future<Order> getOrderById(String orderId) async {
    try {
      print('🔍 获取订单详情: $orderId');

      final response = await _supabase
          .from('orders')
          .select(_getOrderSelectQuery())
          .eq('id', orderId)
          .single();

      return Order.fromJson(response);

    } catch (e) {
      print('❌ 获取订单详情失败: $e');
      throw OrderException('订单不存在或获取失败: $e');
    }
  }

  // ========================================
  // 订单状态管理
  // ========================================

  /// 更新订单状态
  Future<Order> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? reason,
    String? updatedBy,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('🔄 更新订单状态: $orderId -> ${newStatus.label}');

      // 1. 获取当前订单
      final currentOrder = await getOrderById(orderId);

      // 2. 验证状态转换
      final validation = _validateStatusTransition(currentOrder.status, newStatus);
      if (!validation.isValid) {
        throw OrderException('状态转换无效: ${validation.firstError}');
      }

      // 3. 调用行业处理器
      final handler = getIndustryHandler(currentOrder.industry);
      if (handler != null) {
        await handler.onStatusChange(currentOrder, newStatus, reason);
      }

      // 4. 更新数据库
      await _supabase
          .from('orders')
          .update({
            'order_status': newStatus.code,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);

      // 5. 记录状态变更历史
      await _createStatusChangeRecord(
        orderId: orderId,
        fromStatus: currentOrder.status,
        toStatus: newStatus,
        reason: reason,
        changedBy: updatedBy ?? _getCurrentUserId(),
        metadata: metadata,
      );

      // 6. 返回更新后的订单
      return await getOrderById(orderId);

    } catch (e) {
      print('❌ 更新订单状态失败: $e');
      rethrow;
    }
  }

  /// 取消订单
  Future<Order> cancelOrder({
    required String orderId,
    required String reason,
    String? cancelledBy,
  }) async {
    try {
      print('❌ 取消订单: $orderId');

      final order = await getOrderById(orderId);

      if (!order.canCancel) {
        throw OrderException('订单当前状态不允许取消');
      }

      // 调用行业处理器处理取消逻辑
      final handler = getIndustryHandler(order.industry);
      if (handler != null) {
        await handler.onOrderCancellation(order, reason);
      }

      return await updateOrderStatus(
        orderId: orderId,
        newStatus: OrderStatus.cancelled,
        reason: reason,
        updatedBy: cancelledBy,
      );

    } catch (e) {
      print('❌ 取消订单失败: $e');
      rethrow;
    }
  }

  // ========================================
  // 私有方法
  // ========================================

  /// 计算基础金额
  Price _calculateBaseAmount(List<OrderItemRequest> items) {
    double total = 0.0;
    for (final item in items) {
      total += item.totalPrice;
    }
    return Price(amount: total);
  }

  /// 获取定价规则
  Future<List<PricingRule>> _getPricingRules(String serviceId, IndustryType industry) async {
    try {
      final response = await _supabase
          .from('pricing_rules')
          .select()
          .eq('service_id', serviceId)
          .eq('industry_type', industry.code)
          .eq('is_active', true)
          .order('priority', ascending: false);

      return response.map((data) => PricingRule.fromJson(data)).toList();
    } catch (e) {
      print('⚠️ 获取定价规则失败: $e');
      return [];
    }
  }

  /// 应用定价规则
  PricingFee _applyPricingRule(
    PricingRule rule,
    Price baseAmount,
    OrderRequest request,
  ) {
    final calculatedPrice = rule.calculatePrice(
      baseAmount: baseAmount,
      context: {
        'request': request.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    return PricingFee(
      type: rule.ruleType,
      name: rule.ruleName,
      amount: calculatedPrice,
      description: rule.ruleConfig.get<String>('description'),
    );
  }

  /// 应用优惠券
  Future<({Coupon coupon, PricingDiscount discount})?> _applyCoupon(
    String couponCode,
    Price orderAmount,
    OrderRequest request,
  ) async {
    try {
      final response = await _supabase
          .from('coupons')
          .select()
          .eq('code', couponCode)
          .eq('is_active', true)
          .single();

      final coupon = Coupon.fromJson(response);

      if (!coupon.isApplicableTo(
        orderIndustry: request.industry,
        orderAmount: orderAmount,
        serviceId: request.serviceId,
      )) {
        return null;
      }

      final discountAmount = coupon.calculateDiscount(orderAmount);

      return (
        coupon: coupon,
        discount: PricingDiscount(
          type: coupon.discountType,
          name: coupon.title.getText(),
          amount: discountAmount,
          description: coupon.description?.getText(),
        )
      );

    } catch (e) {
      print('⚠️ 优惠券处理失败: $e');
      return null;
    }
  }

  /// 保存订单到数据库
  Future<void> _saveOrderToDatabase(Order order) async {
    await _supabase.from('orders').insert(order.toJson());
  }

  /// 创建订单项目
  Future<OrderItem> _createOrderItem(String orderId, OrderItemRequest itemRequest) async {
    final orderItem = OrderItem(
      id: _generateOrderItemId(),
      orderId: orderId,
      serviceDetailId: itemRequest.serviceDetailId,
      name: MultiLanguageText.single(itemRequest.name),
      description: itemRequest.description != null
          ? MultiLanguageText.single(itemRequest.description!)
          : null,
      quantity: itemRequest.quantity,
      unitPrice: Price(amount: itemRequest.unitPrice),
      totalPrice: Price(amount: itemRequest.totalPrice),
      options: itemRequest.options,
      customizations: itemRequest.customizations,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _supabase.from('order_items').insert(orderItem.toJson());
    return orderItem;
  }

  /// 验证状态转换
  ValidationResult _validateStatusTransition(OrderStatus from, OrderStatus to) {
    // 基础状态转换规则
    final allowedTransitions = <OrderStatus, List<OrderStatus>>{
      OrderStatus.pending: [OrderStatus.accepted, OrderStatus.cancelled],
      OrderStatus.accepted: [OrderStatus.inProgress, OrderStatus.cancelled],
      OrderStatus.inProgress: [OrderStatus.completed, OrderStatus.cancelled, OrderStatus.disputed],
      OrderStatus.completed: [OrderStatus.disputed],
      OrderStatus.cancelled: [],
      OrderStatus.disputed: [OrderStatus.completed, OrderStatus.cancelled],
    };

    final allowed = allowedTransitions[from] ?? [];
    if (!allowed.contains(to)) {
      return ValidationResult.invalid(['不允许从${from.label}转换到${to.label}']);
    }

    return ValidationResult.valid();
  }

  /// 创建状态变更记录
  Future<void> _createStatusChangeRecord({
    required String orderId,
    required OrderStatus fromStatus,
    required OrderStatus toStatus,
    String? reason,
    required String changedBy,
    Map<String, dynamic>? metadata,
  }) async {
    final record = OrderStatusChange(
      id: _generateOrderStatusChangeId(),
      orderId: orderId,
      fromStatus: fromStatus,
      toStatus: toStatus,
      reason: reason,
      changedBy: changedBy,
      metadata: metadata ?? {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _supabase.from('order_status_changes').insert(record.toJson());
  }

  /// 获取订单查询字段
  String _getOrderSelectQuery() {
    return '''
      id,
      order_number,
      user_id,
      provider_id,
      service_id,
      industry_type,
      order_status,
      payment_status,
      order_type,
      fulfillment_mode_snapshot,
      total_price,
      deposit_amount,
      final_payment_amount,
      currency,
      scheduled_start_time,
      scheduled_end_time,
      actual_start_time,
      actual_end_time,
      expires_at,
      service_address_snapshot,
      service_latitude,
      service_longitude,
      industry_specific_data,
      user_notes,
      provider_notes,
      cancellation_reason,
      cancellation_fee,
      dispute_status,
      support_ticket_id,
      created_at,
      updated_at
    ''';
  }

  /// 生成订单ID
  String _generateOrderId() {
    return 'ord_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomSuffix()}';
  }

  /// 生成订单编号
  String _generateOrderNumber(IndustryType industry) {
    final now = DateTime.now();
    final prefix = industry.code.toUpperCase().substring(0, 3);
    return '$prefix-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  }

  /// 生成订单项目ID
  String _generateOrderItemId() {
    return 'item_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomSuffix()}';
  }

  /// 生成状态变更记录ID
  String _generateOrderStatusChangeId() {
    return 'status_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomSuffix()}';
  }

  /// 生成随机后缀
  String _generateRandomSuffix() {
    return (1000 + (DateTime.now().microsecond % 9000)).toString();
  }

  /// 获取当前用户ID
  String _getCurrentUserId() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw OrderException('用户未登录');
    }
    return user.id;
  }
}

/// 行业特定订单处理器接口
abstract class IndustryOrderHandler {
  /// 订单预处理
  Future<void> preprocessOrder(OrderRequest request);

  /// 订单后处理
  Future<void> postprocessOrder(Order order);

  /// 订单验证
  Future<ValidationResult> validateOrder(OrderRequest request);

  /// 价格调整
  Future<PricingResult?> adjustPricing({
    required Price baseAmount,
    required List<PricingFee> fees,
    required List<PricingDiscount> discounts,
    required OrderRequest request,
  });

  /// 状态变更处理
  Future<void> onStatusChange(Order order, OrderStatus newStatus, String? reason);

  /// 订单取消处理
  Future<void> onOrderCancellation(Order order, String reason);
}

/// 订单异常
// OrderException moved to base_models.dart to avoid duplication
