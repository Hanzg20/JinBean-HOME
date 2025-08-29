/// 购物车项目数据模型
class CartItem {
  final String id;
  final String serviceId;
  final String serviceDetailId;
  final String itemType; // 'menu_item', 'appointment', 'package'
  final int quantity;
  final double unitPrice;
  final DateTime? scheduledStartTime;
  final DateTime? scheduledEndTime;
  final Map<String, dynamic> customizations;
  final String? specialInstructions;

  // 快照数据
  final Map<String, String> itemNameSnapshot; // 多语言名称
  final String? itemDescriptionSnapshot;
  final String? itemImageSnapshot;
  final String? providerNameSnapshot;

  // 时间戳
  final DateTime addedAt;
  final DateTime? updatedAt;

  // 计算属性
  double get subtotal => quantity * unitPrice;

  const CartItem({
    required this.id,
    required this.serviceId,
    required this.serviceDetailId,
    required this.itemType,
    required this.quantity,
    required this.unitPrice,
    this.scheduledStartTime,
    this.scheduledEndTime,
    this.customizations = const {},
    this.specialInstructions,
    required this.itemNameSnapshot,
    this.itemDescriptionSnapshot,
    this.itemImageSnapshot,
    this.providerNameSnapshot,
    required this.addedAt,
    this.updatedAt,
  });

  // JSON序列化
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      serviceId: json['service_id'] as String,
      serviceDetailId: json['service_detail_id'] as String,
      itemType: json['item_type'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      scheduledStartTime: json['scheduled_start_time'] != null
          ? DateTime.parse(json['scheduled_start_time'] as String)
          : null,
      scheduledEndTime: json['scheduled_end_time'] != null
          ? DateTime.parse(json['scheduled_end_time'] as String)
          : null,
      customizations: Map<String, dynamic>.from(json['customizations'] ?? {}),
      specialInstructions: json['special_instructions'] as String?,
      itemNameSnapshot:
          Map<String, String>.from(json['item_name_snapshot'] ?? {}),
      itemDescriptionSnapshot: json['item_description_snapshot'] as String?,
      itemImageSnapshot: json['item_image_snapshot'] as String?,
      providerNameSnapshot: json['provider_name_snapshot'] as String?,
      addedAt: DateTime.parse(json['added_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'service_detail_id': serviceDetailId,
      'item_type': itemType,
      'quantity': quantity,
      'unit_price': unitPrice,
      'scheduled_start_time': scheduledStartTime?.toIso8601String(),
      'scheduled_end_time': scheduledEndTime?.toIso8601String(),
      'customizations': customizations,
      'special_instructions': specialInstructions,
      'item_name_snapshot': itemNameSnapshot,
      'item_description_snapshot': itemDescriptionSnapshot,
      'item_image_snapshot': itemImageSnapshot,
      'provider_name_snapshot': providerNameSnapshot,
      'added_at': addedAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // 复制方法
  CartItem copyWith({
    String? id,
    String? serviceId,
    String? serviceDetailId,
    String? itemType,
    int? quantity,
    double? unitPrice,
    DateTime? scheduledStartTime,
    DateTime? scheduledEndTime,
    Map<String, dynamic>? customizations,
    String? specialInstructions,
    Map<String, String>? itemNameSnapshot,
    String? itemDescriptionSnapshot,
    String? itemImageSnapshot,
    String? providerNameSnapshot,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      serviceDetailId: serviceDetailId ?? this.serviceDetailId,
      itemType: itemType ?? this.itemType,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      scheduledEndTime: scheduledEndTime ?? this.scheduledEndTime,
      customizations: customizations ?? this.customizations,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      itemNameSnapshot: itemNameSnapshot ?? this.itemNameSnapshot,
      itemDescriptionSnapshot:
          itemDescriptionSnapshot ?? this.itemDescriptionSnapshot,
      itemImageSnapshot: itemImageSnapshot ?? this.itemImageSnapshot,
      providerNameSnapshot: providerNameSnapshot ?? this.providerNameSnapshot,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // 比较方法
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CartItem(id: $id, serviceId: $serviceId, quantity: $quantity, unitPrice: $unitPrice)';
  }
}

/// 购物车数据模型
class Cart {
  final String id;
  final String userId;
  final String cartType; // 'restaurant', 'appointment', 'mixed'
  final String status; // 'active', 'converting', 'converted', 'expired'
  final List<CartItem> items;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 餐饮专用字段
  final String? deliveryMethod; // 'delivery', 'pickup', 'dine_in'
  final String? deliveryAddressId;
  final DateTime? estimatedDeliveryTime;
  final String? specialInstructions;

  // 计算属性
  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.subtotal);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  // 按服务分组
  Map<String, List<CartItem>> get itemsByService {
    final grouped = <String, List<CartItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.serviceId, () => []).add(item);
    }
    return grouped;
  }

  const Cart({
    required this.id,
    required this.userId,
    required this.cartType,
    required this.status,
    required this.items,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.deliveryMethod,
    this.deliveryAddressId,
    this.estimatedDeliveryTime,
    this.specialInstructions,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      cartType: json['cart_type'] as String,
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deliveryMethod: json['delivery_method'] as String?,
      deliveryAddressId: json['delivery_address_id'] as String?,
      estimatedDeliveryTime: json['estimated_delivery_time'] != null
          ? DateTime.parse(json['estimated_delivery_time'] as String)
          : null,
      specialInstructions: json['special_instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'cart_type': cartType,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'delivery_method': deliveryMethod,
      'delivery_address_id': deliveryAddressId,
      'estimated_delivery_time': estimatedDeliveryTime?.toIso8601String(),
      'special_instructions': specialInstructions,
    };
  }

  Cart copyWith({
    String? id,
    String? userId,
    String? cartType,
    String? status,
    List<CartItem>? items,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deliveryMethod,
    String? deliveryAddressId,
    DateTime? estimatedDeliveryTime,
    String? specialInstructions,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cartType: cartType ?? this.cartType,
      status: status ?? this.status,
      items: items ?? this.items,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      deliveryAddressId: deliveryAddressId ?? this.deliveryAddressId,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}

/// 价格计算结果数据模型
class PricingResult {
  final double basePrice;
  final double itemsTotal;
  final double deliveryFee;
  final double serviceFee;
  final double urgencyFee;
  final double distanceFee;
  final double taxAmount;
  final double subtotal;
  final double total;
  final double? suggestedTip;
  final String currency;
  final Map<String, double> breakdown; // 详细费用分解

  const PricingResult({
    this.basePrice = 0,
    required this.itemsTotal,
    this.deliveryFee = 0,
    this.serviceFee = 0,
    this.urgencyFee = 0,
    this.distanceFee = 0,
    required this.taxAmount,
    required this.subtotal,
    required this.total,
    this.suggestedTip,
    this.currency = 'CAD',
    this.breakdown = const {},
  });

  factory PricingResult.fromJson(Map<String, dynamic> json) {
    return PricingResult(
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0,
      itemsTotal: (json['items_total'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
      serviceFee: (json['service_fee'] as num?)?.toDouble() ?? 0,
      urgencyFee: (json['urgency_fee'] as num?)?.toDouble() ?? 0,
      distanceFee: (json['distance_fee'] as num?)?.toDouble() ?? 0,
      taxAmount: (json['tax_amount'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      suggestedTip: (json['suggested_tip'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'CAD',
      breakdown: Map<String, double>.from(json['breakdown'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_price': basePrice,
      'items_total': itemsTotal,
      'delivery_fee': deliveryFee,
      'service_fee': serviceFee,
      'urgency_fee': urgencyFee,
      'distance_fee': distanceFee,
      'tax_amount': taxAmount,
      'subtotal': subtotal,
      'total': total,
      'suggested_tip': suggestedTip,
      'currency': currency,
      'breakdown': breakdown,
    };
  }

  /// 获取格式化的价格字符串
  String getFormattedTotal() {
    return '\$${total.toStringAsFixed(2)} $currency';
  }

  /// 获取费用明细
  Map<String, String> getFormattedBreakdown() {
    final formatted = <String, String>{};
    if (itemsTotal > 0)
      formatted['商品总价'] = '\$${itemsTotal.toStringAsFixed(2)}';
    if (deliveryFee > 0)
      formatted['配送费'] = '\$${deliveryFee.toStringAsFixed(2)}';
    if (serviceFee > 0) formatted['服务费'] = '\$${serviceFee.toStringAsFixed(2)}';
    if (urgencyFee > 0) formatted['加急费'] = '\$${urgencyFee.toStringAsFixed(2)}';
    if (distanceFee > 0)
      formatted['距离费'] = '\$${distanceFee.toStringAsFixed(2)}';
    if (taxAmount > 0) formatted['税费'] = '\$${taxAmount.toStringAsFixed(2)}';
    if (suggestedTip != null && suggestedTip! > 0) {
      formatted['建议小费'] = '\$${suggestedTip!.toStringAsFixed(2)}';
    }
    return formatted;
  }
}

/// 订单数据模型

class Order {
  final String id;
  final String orderNumber;
  final String userId;
  final String providerId;
  final String serviceId;
  final String orderType;
  final String orderStatus;
  final String orderSource; // 'direct', 'cart', 'quote'
  final double totalPrice;
  final String currency;
  final String paymentStatus;
  final DateTime? scheduledStartTime;
  final DateTime? scheduledEndTime;
  final Map<String, dynamic>? serviceAddressSnapshot;
  final String? userNotes;
  final String? deliveryMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.providerId,
    required this.serviceId,
    required this.orderType,
    required this.orderStatus,
    required this.orderSource,
    required this.totalPrice,
    required this.currency,
    required this.paymentStatus,
    this.scheduledStartTime,
    this.scheduledEndTime,
    this.serviceAddressSnapshot,
    this.userNotes,
    this.deliveryMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      userId: json['user_id'] as String,
      providerId: json['provider_id'] as String,
      serviceId: json['service_id'] as String,
      orderType: json['order_type'] as String,
      orderStatus: json['order_status'] as String,
      orderSource: json['order_source'] as String,
      totalPrice: (json['total_price'] as num).toDouble(),
      currency: json['currency'] as String,
      paymentStatus: json['payment_status'] as String,
      scheduledStartTime: json['scheduled_start_time'] != null
          ? DateTime.parse(json['scheduled_start_time'] as String)
          : null,
      scheduledEndTime: json['scheduled_end_time'] != null
          ? DateTime.parse(json['scheduled_end_time'] as String)
          : null,
      serviceAddressSnapshot:
          json['service_address_snapshot'] as Map<String, dynamic>?,
      userNotes: json['user_notes'] as String?,
      deliveryMethod: json['delivery_method'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'user_id': userId,
      'provider_id': providerId,
      'service_id': serviceId,
      'order_type': orderType,
      'order_status': orderStatus,
      'order_source': orderSource,
      'total_price': totalPrice,
      'currency': currency,
      'payment_status': paymentStatus,
      'scheduled_start_time': scheduledStartTime?.toIso8601String(),
      'scheduled_end_time': scheduledEndTime?.toIso8601String(),
      'service_address_snapshot': serviceAddressSnapshot,
      'user_notes': userNotes,
      'delivery_method': deliveryMethod,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 获取格式化的订单号
  String get formattedOrderNumber {
    return '#$orderNumber';
  }

  /// 获取格式化的总价
  String get formattedTotalPrice {
    return '\$${totalPrice.toStringAsFixed(2)} $currency';
  }

  /// 判断是否为餐饮订单
  bool get isRestaurantOrder {
    return orderType == 'restaurant' || deliveryMethod != null;
  }

  /// 判断是否为预约订单
  bool get isAppointmentOrder {
    return scheduledStartTime != null;
  }
}

/// 批量订单数据模型

class BatchOrder {
  final String id;
  final String batchNumber;
  final String userId;
  final String? cartId;
  final int totalOrdersCount;
  final int completedOrdersCount;
  final double totalAmount;
  final String currency;
  final String paymentStatus;
  final List<Order> orders;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? paidAt;
  final DateTime? completedAt;

  // 计算属性
  double get completionPercentage {
    if (totalOrdersCount == 0) return 0;
    return (completedOrdersCount / totalOrdersCount) * 100;
  }

  bool get isCompleted => completedOrdersCount == totalOrdersCount;
  bool get isPaid => paymentStatus == 'completed';

  const BatchOrder({
    required this.id,
    required this.batchNumber,
    required this.userId,
    this.cartId,
    required this.totalOrdersCount,
    required this.completedOrdersCount,
    required this.totalAmount,
    required this.currency,
    required this.paymentStatus,
    required this.orders,
    required this.createdAt,
    required this.updatedAt,
    this.paidAt,
    this.completedAt,
  });

  factory BatchOrder.fromJson(Map<String, dynamic> json) {
    // 简化实现
    throw UnimplementedError('BatchOrder.fromJson not implemented yet');
  }

  Map<String, dynamic> toJson() {
    // 简化实现
    throw UnimplementedError('BatchOrder.toJson not implemented yet');
  }
}

/// 服务预订类型枚举
enum ServiceBookingType {
  directOnly, // 只支持直接下单
  cartOnly, // 只支持购物车
  both, // 两者都支持
}

/// 服务预订类型扩展方法
extension ServiceBookingTypeExtension on ServiceBookingType {
  String get description {
    switch (this) {
      case ServiceBookingType.directOnly:
        return '立即预订，快速下单';
      case ServiceBookingType.cartOnly:
        return '添加到购物车，统一结算';
      case ServiceBookingType.both:
        return '立即预订或加入购物车';
    }
  }

  String get recommendedAction {
    switch (this) {
      case ServiceBookingType.directOnly:
        return '立即预订';
      case ServiceBookingType.cartOnly:
        return '加入购物车';
      case ServiceBookingType.both:
        return '立即预订'; // 默认推荐立即预订
    }
  }

  bool get supportsDirectBooking {
    return this == ServiceBookingType.directOnly ||
        this == ServiceBookingType.both;
  }

  bool get supportsCart {
    return this == ServiceBookingType.cartOnly ||
        this == ServiceBookingType.both;
  }
}

/// 购物车操作日志数据模型

class CartOperationLog {
  final String id;
  final String cartId;
  final String userId;
  final String operationType; // 'add', 'remove', 'update_quantity', etc.
  final String? itemId;
  final Map<String, dynamic>? operationData;
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;
  final DateTime createdAt;

  const CartOperationLog({
    required this.id,
    required this.cartId,
    required this.userId,
    required this.operationType,
    this.itemId,
    this.operationData,
    this.oldValue,
    this.newValue,
    required this.createdAt,
  });

  factory CartOperationLog.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('CartOperationLog.fromJson not implemented yet');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError('CartOperationLog.toJson not implemented yet');
  }
}

/// 预约详情数据模型（用于预约服务）

class AppointmentDetails {
  final DateTime scheduledTime;
  final DateTime? estimatedEndTime;
  final Map<String, dynamic> serviceAddress;
  final bool isUrgent;
  final String? specialRequirements;
  final Map<String, dynamic>? customizations;

  const AppointmentDetails({
    required this.scheduledTime,
    this.estimatedEndTime,
    required this.serviceAddress,
    this.isUrgent = false,
    this.specialRequirements,
    this.customizations,
  });

  factory AppointmentDetails.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('AppointmentDetails.fromJson not implemented yet');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError('AppointmentDetails.toJson not implemented yet');
  }
}

/// 配送信息数据模型（用于餐饮服务）

class DeliveryInfo {
  final String method; // 'delivery', 'pickup', 'dine_in'
  final Map<String, dynamic>? deliveryAddress;
  final DateTime? requestedDeliveryTime;
  final String? deliveryInstructions;
  final double? deliveryFee;

  const DeliveryInfo({
    required this.method,
    this.deliveryAddress,
    this.requestedDeliveryTime,
    this.deliveryInstructions,
    this.deliveryFee,
  });

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  Map<String, dynamic> toJson() => throw UnimplementedError();

  bool get isDelivery => method == 'delivery';
  bool get isPickup => method == 'pickup';
  bool get isDineIn => method == 'dine_in';
}

/// 购物车异常类
class CartException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const CartException(this.message, {this.code, this.originalError});

  @override
  String toString() {
    return 'CartException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

/// 订单创建异常类
class OrderCreationException implements Exception {
  final String message;
  final String? orderSource;
  final List<String>? failedOrderIds;
  final dynamic originalError;

  const OrderCreationException(
    this.message, {
    this.orderSource,
    this.failedOrderIds,
    this.originalError,
  });

  @override
  String toString() {
    return 'OrderCreationException: $message${orderSource != null ? ' (Source: $orderSource)' : ''}';
  }
}
