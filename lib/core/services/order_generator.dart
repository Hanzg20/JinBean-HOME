/// 订单生成器
/// 负责从不同来源生成订单，包括购物车、直接预订、议价等

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../models/cart_models.dart';
import '../models/order_models.dart';
import '../models/payment_models.dart';
import '../../features/customer/domain/entities/service.dart';
import '../../features/customer/domain/entities/service_detail.dart';
import '../utils/app_logger.dart';

/// 订单偏好设置
class OrderPreferences {
  final bool splitByProvider;      // 按服务商拆分
  final bool splitByServiceType;   // 按服务类型拆分
  final bool splitByDeliveryTime;  // 按配送时间拆分
  final int maxItemsPerOrder;      // 每个订单最大商品数
  final bool autoAcceptOrders;     // 自动接受订单（针对特定服务商）
  
  const OrderPreferences({
    this.splitByProvider = true,
    this.splitByServiceType = false,
    this.splitByDeliveryTime = true,
    this.maxItemsPerOrder = 50,
    this.autoAcceptOrders = false,
  });
}

/// 订单选项
class OrderOptions {
  final int quantity;
  final DateTime? scheduledTime;
  final DateTime? endTime;
  final Map<String, dynamic> serviceAddress;
  final Map<String, dynamic>? customizations;
  final String? specialInstructions;
  final OrderPriority priority;
  final String? deliveryMethod;
  final String? deliveryInstructions;
  
  const OrderOptions({
    this.quantity = 1,
    this.scheduledTime,
    this.endTime,
    required this.serviceAddress,
    this.customizations,
    this.specialInstructions,
    this.priority = OrderPriority.normal,
    this.deliveryMethod,
    this.deliveryInstructions,
  });
}

/// 支付信息
class PaymentInfo {
  final String? paymentMethodId;
  final PaymentMethodType? paymentType;
  final Map<String, dynamic>? paymentData;
  final bool savePaymentMethod;
  
  const PaymentInfo({
    this.paymentMethodId,
    this.paymentType,
    this.paymentData,
    this.savePaymentMethod = false,
  });
}

/// 报价结果（用于议价订单）
class QuoteResult {
  final String id;
  final String serviceId;
  final String providerId;
  final double agreedPrice;
  final String currency;
  final DateTime validUntil;
  final Map<String, dynamic> terms;
  final DateTime? scheduledTime;
  final Map<String, dynamic> serviceAddress;
  
  const QuoteResult({
    required this.id,
    required this.serviceId,
    required this.providerId,
    required this.agreedPrice,
    this.currency = 'CAD',
    required this.validUntil,
    required this.terms,
    this.scheduledTime,
    required this.serviceAddress,
  });
}

/// 订单生成上下文
class OrderContext {
  final String userId;
  final String? billingAddressId;
  final Map<String, dynamic>? metadata;
  final String source;
  
  const OrderContext({
    required this.userId,
    this.billingAddressId,
    this.metadata,
    this.source = 'app',
  });
}

/// 订单拆分规则
class OrderSplitRule {
  final OrderPreferences preferences;
  
  const OrderSplitRule(this.preferences);
  
  /// 拆分购物车为多个订单
  List<List<CartItem>> split(Cart cart, OrderContext context) {
    List<List<CartItem>> orderGroups = [];
    
    if (preferences.splitByProvider) {
      // 按服务商分组
      final groupedByProvider = <String, List<CartItem>>{};
      for (final item in cart.items) {
        groupedByProvider.putIfAbsent(item.serviceId, () => []).add(item);
      }
      
      for (final group in groupedByProvider.values) {
        orderGroups.addAll(_splitBySize(group));
      }
    } else {
      // 不按服务商拆分，直接按大小拆分
      orderGroups.addAll(_splitBySize(cart.items));
    }
    
    return orderGroups;
  }
  
  /// 按订单大小拆分
  List<List<CartItem>> _splitBySize(List<CartItem> items) {
    final groups = <List<CartItem>>[];
    
    for (int i = 0; i < items.length; i += preferences.maxItemsPerOrder) {
      final end = (i + preferences.maxItemsPerOrder < items.length) 
          ? i + preferences.maxItemsPerOrder 
          : items.length;
      groups.add(items.sublist(i, end));
    }
    
    return groups;
  }
}

/// 主订单生成器
class OrderGenerator extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();
  
  /// 从购物车生成订单
  Future<BatchOrder> generateFromCart(
    Cart cart,
    PaymentInfo paymentInfo,
    OrderPreferences preferences,
    {Map<String, dynamic>? deliveryInfo}
  ) async {
    try {
      AppLogger.info('[OrderGenerator] Generating orders from cart: ${cart.id}');
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw OrderException('用户未认证');
      }
      
      // 1. 验证购物车
      if (cart.items.isEmpty) {
        throw OrderException('购物车为空');
      }
      
      if (cart.status != 'active') {
        throw OrderException('购物车状态无效');
      }
      
      // 2. 创建订单上下文
      final context = OrderContext(
        userId: userId,
        source: 'cart',
        metadata: {
          'cart_id': cart.id,
          'cart_type': cart.cartType,
        },
      );
      
      // 3. 拆分购物车
      final splitRule = OrderSplitRule(preferences);
      final orderGroups = splitRule.split(cart, context);
      
      // 4. 生成批次号
      final batchNumber = _generateBatchNumber();
      
      // 5. 创建批量订单记录
      final batchOrder = await _createBatchOrder(
        batchNumber: batchNumber,
        userId: userId,
        cartId: cart.id,
        totalAmount: cart.totalAmount,
        orderGroupsCount: orderGroups.length,
        deliveryInfo: deliveryInfo,
      );
      
      // 6. 为每个组生成订单
      final orders = <EnhancedOrder>[];
      for (int i = 0; i < orderGroups.length; i++) {
        final group = orderGroups[i];
        final order = await _generateOrderFromItems(
          items: group,
          context: context,
          batchId: batchOrder.id,
          orderIndex: i + 1,
          deliveryInfo: deliveryInfo,
        );
        orders.add(order);
      }
      
      // 7. 更新购物车状态
      await _updateCartStatus(cart.id, 'converting');
      
      // 8. 返回完整的批量订单
      return batchOrder.copyWith(
        orders: orders,
        totalOrdersCount: orders.length,
      );
      
    } catch (e) {
      AppLogger.error('[OrderGenerator] Failed to generate orders from cart: $e');
      if (e is OrderException) {
        rethrow;
      }
      throw OrderException('从购物车生成订单失败', originalError: e);
    }
  }
  
  /// 直接服务预订生成订单
  Future<EnhancedOrder> generateDirectOrder(
    Service service,
    ServiceDetail serviceDetail,
    OrderOptions options,
    PaymentInfo paymentInfo,
  ) async {
    try {
      AppLogger.info('[OrderGenerator] Generating direct order for service: ${service.id}');
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw OrderException('用户未认证');
      }
      
      // 1. 验证服务可用性
      if (!service.isActive) {
        throw OrderException('服务不可用');
      }
      
      // 2. 验证时间冲突（如果是预约服务）
      if (options.scheduledTime != null) {
        final hasConflict = await _checkTimeConflict(
          service.providerId,
          options.scheduledTime!,
          options.endTime,
        );
        if (hasConflict) {
          throw OrderException('预约时间冲突，请选择其他时间');
        }
      }
      
      // 3. 计算价格
      final pricing = await _calculateDirectOrderPricing(
        serviceDetail: serviceDetail,
        quantity: options.quantity,
        deliveryMethod: options.deliveryMethod,
        serviceAddress: options.serviceAddress,
        isUrgent: options.priority == OrderPriority.urgent,
      );
      
      // 4. 生成订单号
      final orderNumber = _generateOrderNumber();
      
      // 5. 创建订单数据
      final orderData = {
        'order_number': orderNumber,
        'user_id': userId,
        'provider_id': service.providerId,
        'service_id': service.id,
        'order_type': OrderType.direct.name,
        'order_status': OrderStatus.pendingPayment.name,
        'order_source': OrderSource.app.name,
        'priority': options.priority.name,
        'total_price': pricing.total,
        'currency': pricing.currency,
        'payment_status': 'pending',
        'payment_method_id': paymentInfo.paymentMethodId,
        'pricing_breakdown': pricing.toJson(),
        'scheduled_start_time': options.scheduledTime?.toIso8601String(),
        'scheduled_end_time': options.endTime?.toIso8601String(),
        'service_address_snapshot': options.serviceAddress,
        'user_notes': options.specialInstructions,
        'delivery_method': options.deliveryMethod,
        'delivery_instructions': options.deliveryInstructions,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // 6. 插入订单
      final orderResponse = await _supabase
          .from('orders')
          .insert(orderData)
          .select()
          .single();
      
      final order = EnhancedOrder.fromJson(orderResponse);
      
      // 7. 创建订单项目
      await _createOrderItem(
        orderId: order.id,
        serviceId: service.id,
        serviceDetailId: serviceDetail.id,
        quantity: options.quantity,
        unitPrice: serviceDetail.price,
        totalPrice: pricing.itemsTotal,
        customizations: options.customizations ?? {},
        specialInstructions: options.specialInstructions,
        scheduledStartTime: options.scheduledTime,
        scheduledEndTime: options.endTime,
        itemNameSnapshot: serviceDetail.name,
        itemDescriptionSnapshot: serviceDetail.description,
        providerNameSnapshot: service.title,
      );
      
      AppLogger.info('[OrderGenerator] Direct order created: ${order.orderNumber}');
      return order;
      
    } catch (e) {
      AppLogger.error('[OrderGenerator] Failed to generate direct order: $e');
      if (e is OrderException) {
        rethrow;
      }
      throw OrderException('生成直接预订订单失败', originalError: e);
    }
  }
  
  /// 议价订单生成
  Future<EnhancedOrder> generateNegotiatedOrder(
    QuoteResult quote,
    PaymentInfo paymentInfo,
  ) async {
    try {
      AppLogger.info('[OrderGenerator] Generating negotiated order from quote: ${quote.id}');
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw OrderException('用户未认证');
      }
      
      // 1. 验证报价有效性
      if (DateTime.now().isAfter(quote.validUntil)) {
        throw OrderException('报价已过期');
      }
      
      // 2. 生成订单号
      final orderNumber = _generateOrderNumber();
      
      // 3. 创建订单数据
      final orderData = {
        'order_number': orderNumber,
        'user_id': userId,
        'provider_id': quote.providerId,
        'service_id': quote.serviceId,
        'order_type': OrderType.negotiated.name,
        'order_status': OrderStatus.pendingPayment.name,
        'order_source': OrderSource.app.name,
        'priority': OrderPriority.normal.name,
        'total_price': quote.agreedPrice,
        'currency': quote.currency,
        'payment_status': 'pending',
        'payment_method_id': paymentInfo.paymentMethodId,
        'scheduled_start_time': quote.scheduledTime?.toIso8601String(),
        'service_address_snapshot': quote.serviceAddress,
        'metadata': {
          'quote_id': quote.id,
          'negotiated_terms': quote.terms,
        },
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // 4. 插入订单
      final orderResponse = await _supabase
          .from('orders')
          .insert(orderData)
          .select()
          .single();
      
      final order = EnhancedOrder.fromJson(orderResponse);
      
      AppLogger.info('[OrderGenerator] Negotiated order created: ${order.orderNumber}');
      return order;
      
    } catch (e) {
      AppLogger.error('[OrderGenerator] Failed to generate negotiated order: $e');
      if (e is OrderException) {
        rethrow;
      }
      throw OrderException('生成议价订单失败', originalError: e);
    }
  }
  
  /// 生成订单号
  String _generateOrderNumber() {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final timeStr = DateFormat('HHmmss').format(now);
    final randomSuffix = (now.millisecondsSinceEpoch % 1000).toString().padLeft(3, '0');
    return 'ORD-$dateStr-$timeStr-$randomSuffix';
  }
  
  /// 生成批次号
  String _generateBatchNumber() {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final timeStr = DateFormat('HHmmss').format(now);
    final randomSuffix = (now.millisecondsSinceEpoch % 1000).toString().padLeft(3, '0');
    return 'BATCH-$dateStr-$timeStr-$randomSuffix';
  }
  
  /// 创建批量订单
  Future<BatchOrder> _createBatchOrder({
    required String batchNumber,
    required String userId,
    required String cartId,
    required double totalAmount,
    required int orderGroupsCount,
    Map<String, dynamic>? deliveryInfo,
  }) async {
    final batchData = {
      'batch_number': batchNumber,
      'user_id': userId,
      'cart_id': cartId,
      'total_orders_count': orderGroupsCount,
      'completed_orders_count': 0,
      'total_amount': totalAmount,
      'currency': 'CAD',
      'payment_status': 'pending',
      'delivery_method': deliveryInfo?['method'],
      'delivery_address': deliveryInfo?['address'],
      'special_instructions': deliveryInfo?['instructions'],
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    final response = await _supabase
        .from('batch_orders')
        .insert(batchData)
        .select()
        .single();
    
    return BatchOrder.fromJson(response);
  }
  
  /// 从购物车项目生成订单
  Future<EnhancedOrder> _generateOrderFromItems({
    required List<CartItem> items,
    required OrderContext context,
    required String batchId,
    required int orderIndex,
    Map<String, dynamic>? deliveryInfo,
  }) async {
    // 1. 获取第一个商品的服务信息作为主要服务
    final firstItem = items.first;
    final service = await _getService(firstItem.serviceId);
    
    // 2. 计算订单总价
    final itemsTotal = items.fold<double>(0, (sum, item) => sum + item.subtotal);
    final pricing = await _calculateCartOrderPricing(
      itemsTotal: itemsTotal,
      deliveryMethod: deliveryInfo?['method'],
      serviceAddress: deliveryInfo?['address'],
    );
    
    // 3. 生成订单号
    final orderNumber = '${_generateOrderNumber()}-$orderIndex';
    
    // 4. 创建订单数据
    final orderData = {
      'order_number': orderNumber,
      'user_id': context.userId,
      'provider_id': service.providerId,
      'service_id': firstItem.serviceId,
      'order_type': OrderType.cart.name,
      'order_status': OrderStatus.pendingPayment.name,
      'order_source': OrderSource.app.name,
      'priority': OrderPriority.normal.name,
      'total_price': pricing.total,
      'currency': pricing.currency,
      'payment_status': 'pending',
      'pricing_breakdown': pricing.toJson(),
      'batch_id': batchId,
      'cart_id': context.metadata?['cart_id'],
      'delivery_method': deliveryInfo?['method'],
      'delivery_instructions': deliveryInfo?['instructions'],
      'service_address_snapshot': deliveryInfo?['address'],
      'metadata': context.metadata,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    // 5. 插入订单
    final orderResponse = await _supabase
        .from('orders')
        .insert(orderData)
        .select()
        .single();
    
    final order = EnhancedOrder.fromJson(orderResponse);
    
    // 6. 创建订单项目
    for (final item in items) {
      await _createOrderItemFromCart(order.id, item);
    }
    
    return order;
  }
  
  /// 从购物车项目创建订单项目
  Future<void> _createOrderItemFromCart(String orderId, CartItem cartItem) async {
    final itemData = {
      'order_id': orderId,
      'service_id': cartItem.serviceId,
      'service_detail_id': cartItem.serviceDetailId,
      'item_type': cartItem.itemType,
      'quantity': cartItem.quantity,
      'unit_price': cartItem.unitPrice,
      'total_price': cartItem.subtotal,
      'item_name_snapshot': cartItem.itemNameSnapshot,
      'item_description_snapshot': cartItem.itemDescriptionSnapshot,
      'item_image_snapshot': cartItem.itemImageSnapshot,
      'provider_name_snapshot': cartItem.providerNameSnapshot,
      'customizations': cartItem.customizations,
      'special_instructions': cartItem.specialInstructions,
      'scheduled_start_time': cartItem.scheduledStartTime?.toIso8601String(),
      'scheduled_end_time': cartItem.scheduledEndTime?.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    await _supabase.from('order_items').insert(itemData);
  }
  
  /// 创建订单项目
  Future<void> _createOrderItem({
    required String orderId,
    required String serviceId,
    required String serviceDetailId,
    required int quantity,
    required double unitPrice,
    required double totalPrice,
    required Map<String, dynamic> customizations,
    String? specialInstructions,
    DateTime? scheduledStartTime,
    DateTime? scheduledEndTime,
    required Map<String, String> itemNameSnapshot,
    String? itemDescriptionSnapshot,
    String? providerNameSnapshot,
  }) async {
    final itemData = {
      'order_id': orderId,
      'service_id': serviceId,
      'service_detail_id': serviceDetailId,
      'item_type': 'direct_booking',
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'item_name_snapshot': itemNameSnapshot,
      'item_description_snapshot': itemDescriptionSnapshot,
      'provider_name_snapshot': providerNameSnapshot,
      'customizations': customizations,
      'special_instructions': specialInstructions,
      'scheduled_start_time': scheduledStartTime?.toIso8601String(),
      'scheduled_end_time': scheduledEndTime?.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    await _supabase.from('order_items').insert(itemData);
  }
  
  /// 计算直接预订价格
  Future<PricingResult> _calculateDirectOrderPricing({
    required ServiceDetail serviceDetail,
    required int quantity,
    String? deliveryMethod,
    required Map<String, dynamic> serviceAddress,
    bool isUrgent = false,
  }) async {
    final basePrice = serviceDetail.price * quantity;
    
    // 计算各种费用
    double deliveryFee = 0.0;
    double serviceFee = basePrice * 0.05; // 5% 服务费
    double urgencyFee = isUrgent ? basePrice * 0.15 : 0.0; // 15% 加急费
    double distanceFee = 0.0; // TODO: 根据距离计算
    
    if (deliveryMethod == 'delivery') {
      deliveryFee = 5.0; // 基础配送费
    }
    
    final subtotal = basePrice + deliveryFee + serviceFee + urgencyFee + distanceFee;
    final taxAmount = subtotal * 0.13; // 13% HST (Ontario)
    final total = subtotal + taxAmount;
    
    return PricingResult(
      itemsTotal: basePrice,
      deliveryFee: deliveryFee,
      serviceFee: serviceFee,
      urgencyFee: urgencyFee,
      distanceFee: distanceFee,
      taxAmount: taxAmount,
      subtotal: subtotal,
      total: total,
      currency: 'CAD',
      breakdown: {
        'base_price': basePrice,
        'delivery_fee': deliveryFee,
        'service_fee': serviceFee,
        'urgency_fee': urgencyFee,
        'distance_fee': distanceFee,
        'hst': taxAmount,
      },
    );
  }
  
  /// 计算购物车订单价格
  Future<PricingResult> _calculateCartOrderPricing({
    required double itemsTotal,
    String? deliveryMethod,
    Map<String, dynamic>? serviceAddress,
  }) async {
    // 计算各种费用
    double deliveryFee = 0.0;
    double serviceFee = itemsTotal * 0.03; // 3% 服务费（购物车订单更低）
    double distanceFee = 0.0; // TODO: 根据距离计算
    
    if (deliveryMethod == 'delivery') {
      deliveryFee = 3.0; // 购物车订单配送费更低
    }
    
    final subtotal = itemsTotal + deliveryFee + serviceFee + distanceFee;
    final taxAmount = subtotal * 0.13; // 13% HST
    final total = subtotal + taxAmount;
    
    return PricingResult(
      itemsTotal: itemsTotal,
      deliveryFee: deliveryFee,
      serviceFee: serviceFee,
      distanceFee: distanceFee,
      taxAmount: taxAmount,
      subtotal: subtotal,
      total: total,
      currency: 'CAD',
      breakdown: {
        'items_total': itemsTotal,
        'delivery_fee': deliveryFee,
        'service_fee': serviceFee,
        'distance_fee': distanceFee,
        'hst': taxAmount,
      },
    );
  }
  
  /// 检查时间冲突
  Future<bool> _checkTimeConflict(
    String providerId,
    DateTime startTime,
    DateTime? endTime,
  ) async {
    try {
      final actualEndTime = endTime ?? startTime.add(const Duration(hours: 2));
      
      final response = await _supabase
          .from('orders')
          .select('id')
          .eq('provider_id', providerId)
          .in_('order_status', ['accepted', 'preparing', 'inProgress'])
          .gte('scheduled_start_time', startTime.toIso8601String())
          .lte('scheduled_end_time', actualEndTime.toIso8601String())
          .limit(1);
      
      return response.isNotEmpty;
    } catch (e) {
      AppLogger.error('[OrderGenerator] Failed to check time conflict: $e');
      return false; // 如果检查失败，允许预订
    }
  }
  
  /// 获取服务信息
  Future<Service> _getService(String serviceId) async {
    final response = await _supabase
        .from('services')
        .select('*')
        .eq('id', serviceId)
        .single();
    
    return Service.fromJson(response);
  }
  
  /// 更新购物车状态
  Future<void> _updateCartStatus(String cartId, String status) async {
    await _supabase
        .from('carts')
        .update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', cartId);
  }
}
