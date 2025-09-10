import 'base_models.dart';

/// 通用订单项目模型
class OrderItem extends BaseEntity {
  final String orderId;
  final String? serviceDetailId;
  final MultiLanguageText name;
  final MultiLanguageText? description;
  final int quantity;
  final Price unitPrice;
  final Price totalPrice;
  final String? category;
  final Map<String, dynamic> options;
  final Map<String, dynamic> customizations;
  final List<String> tags;
  final String? imageUrl;
  final OrderStatus status;
  final bool isPackageItem;
  final String? parentItemId;

  OrderItem({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.orderId,
    this.serviceDetailId,
    required this.name,
    this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.category,
    this.options = const {},
    this.customizations = const {},
    this.tags = const [],
    this.imageUrl,
    this.status = OrderStatus.pending,
    this.isPackageItem = false,
    this.parentItemId,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'service_detail_id': serviceDetailId,
      'name': name.toJson(),
      'description': description?.toJson(),
      'quantity': quantity,
      'unit_price': unitPrice.toJson(),
      'total_price': totalPrice.toJson(),
      'category': category,
      'options': options,
      'customizations': customizations,
      'tags': tags,
      'image_url': imageUrl,
      'status': status.code,
      'is_package_item': isPackageItem,
      'parent_item_id': parentItemId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      serviceDetailId: json['service_detail_id'],
      name: MultiLanguageText.fromDynamic(json['name'] ?? json['item_name']),
      description: json['description'] != null 
          ? MultiLanguageText.fromDynamic(json['description'])
          : null,
      quantity: json['quantity'] ?? 1,
      unitPrice: Price.fromJson(json['unit_price'] is Map 
          ? json['unit_price'] 
          : {'amount': json['unit_price'] ?? 0.0}),
      totalPrice: Price.fromJson(json['total_price'] is Map 
          ? json['total_price'] 
          : {'amount': json['total_price'] ?? 0.0}),
      category: json['category'] ?? json['item_category'],
      options: json['options'] ?? json['item_options'] ?? {},
      customizations: json['customizations'] ?? {},
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      imageUrl: json['image_url'],
      status: OrderStatus.fromCode(json['status'] ?? 'pending'),
      isPackageItem: json['is_package_item'] ?? false,
      parentItemId: json['parent_item_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  OrderItem copyWith({
    String? orderId,
    String? serviceDetailId,
    MultiLanguageText? name,
    MultiLanguageText? description,
    int? quantity,
    Price? unitPrice,
    Price? totalPrice,
    String? category,
    Map<String, dynamic>? options,
    Map<String, dynamic>? customizations,
    List<String>? tags,
    String? imageUrl,
    OrderStatus? status,
    bool? isPackageItem,
    String? parentItemId,
  }) {
    return OrderItem(
      id: id,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      orderId: orderId ?? this.orderId,
      serviceDetailId: serviceDetailId ?? this.serviceDetailId,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      category: category ?? this.category,
      options: options ?? this.options,
      customizations: customizations ?? this.customizations,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      isPackageItem: isPackageItem ?? this.isPackageItem,
      parentItemId: parentItemId ?? this.parentItemId,
    );
  }
}

/// 通用订单模型
class Order extends BaseEntity {
  final String orderNumber;
  final String customerId;
  final String providerId;
  final String serviceId;
  final IndustryType industry;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String orderType; // 'instant', 'scheduled', 'negotiated'
  final String fulfillmentMode; // 'platform', 'external', 'self'
  
  // 价格信息
  final Price totalAmount;
  final Price? depositAmount;
  final Price? finalPaymentAmount;
  final Map<String, dynamic> pricingBreakdown;
  
  // 时间信息
  final TimeRange? scheduledTime;
  final TimeRange? actualTime;
  final DateTime? expiresAt;
  
  // 地址信息
  final Address? serviceAddress;
  final Map<String, dynamic>? locationMetadata;
  
  // 行业特定数据
  final Map<String, dynamic> industryMetadata;
  
  // 订单项目
  final List<OrderItem> items;
  
  // 备注信息
  final String? customerNotes;
  final String? providerNotes;
  final String? internalNotes;
  
  // 取消和争议
  final String? cancellationReason;
  final Price? cancellationFee;
  final String disputeStatus;
  final String? supportTicketId;

  Order({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.orderNumber,
    required this.customerId,
    required this.providerId,
    required this.serviceId,
    required this.industry,
    required this.status,
    required this.paymentStatus,
    required this.orderType,
    this.fulfillmentMode = 'platform',
    required this.totalAmount,
    this.depositAmount,
    this.finalPaymentAmount,
    this.pricingBreakdown = const {},
    this.scheduledTime,
    this.actualTime,
    this.expiresAt,
    this.serviceAddress,
    this.locationMetadata,
    Map<String, dynamic>? industryMetadata,
    this.items = const [],
    this.customerNotes,
    this.providerNotes,
    this.internalNotes,
    this.cancellationReason,
    this.cancellationFee,
    this.disputeStatus = 'none',
    this.supportTicketId,
  }) : industryMetadata = industryMetadata ?? <String, dynamic>{};

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'provider_id': providerId,
      'service_id': serviceId,
      'industry': industry.code,
      'order_status': status.code,
      'payment_status': paymentStatus.code,
      'order_type': orderType,
      'fulfillment_mode': fulfillmentMode,
      'total_amount': totalAmount.toJson(),
      'deposit_amount': depositAmount?.toJson(),
      'final_payment_amount': finalPaymentAmount?.toJson(),
      'pricing_breakdown': pricingBreakdown,
      'scheduled_start_time': scheduledTime?.start.toIso8601String(),
      'scheduled_end_time': scheduledTime?.end.toIso8601String(),
      'actual_start_time': actualTime?.start.toIso8601String(),
      'actual_end_time': actualTime?.end.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'service_address': serviceAddress?.toJson(),
      'location_metadata': locationMetadata,
      'industry_metadata': industryMetadata,
      'items': items.map((item) => item.toJson()).toList(),
      'customer_notes': customerNotes,
      'provider_notes': providerNotes,
      'internal_notes': internalNotes,
      'cancellation_reason': cancellationReason,
      'cancellation_fee': cancellationFee?.toJson(),
      'dispute_status': disputeStatus,
      'support_ticket_id': supportTicketId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['order_number'],
      customerId: json['customer_id'] ?? json['user_id'],
      providerId: json['provider_id'],
      serviceId: json['service_id'],
      industry: IndustryType.fromCode(json['industry'] ?? 'food'),
      status: OrderStatus.fromCode(json['order_status'] ?? 'pending'),
      paymentStatus: PaymentStatus.fromCode(json['payment_status'] ?? 'pending'),
      orderType: json['order_type'] ?? 'instant',
      fulfillmentMode: json['fulfillment_mode'] ?? json['fulfillment_mode_snapshot'] ?? 'platform',
      totalAmount: Price.fromJson(json['total_amount'] is Map 
          ? json['total_amount'] 
          : {'amount': json['total_amount'] ?? json['total_price'] ?? 0.0}),
      depositAmount: json['deposit_amount'] != null 
          ? Price.fromJson(json['deposit_amount'] is Map 
              ? json['deposit_amount'] 
              : {'amount': json['deposit_amount']})
          : null,
      finalPaymentAmount: json['final_payment_amount'] != null 
          ? Price.fromJson(json['final_payment_amount'] is Map 
              ? json['final_payment_amount'] 
              : {'amount': json['final_payment_amount']})
          : null,
      pricingBreakdown: json['pricing_breakdown'] ?? {},
      scheduledTime: json['scheduled_start_time'] != null && json['scheduled_end_time'] != null
          ? TimeRange(
              start: DateTime.parse(json['scheduled_start_time']),
              end: DateTime.parse(json['scheduled_end_time']),
            )
          : null,
      actualTime: json['actual_start_time'] != null && json['actual_end_time'] != null
          ? TimeRange(
              start: DateTime.parse(json['actual_start_time']),
              end: DateTime.parse(json['actual_end_time']),
            )
          : null,
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at'])
          : null,
      serviceAddress: json['service_address'] != null 
          ? Address.fromJson(json['service_address'])
          : json['delivery_address'] != null
              ? Address.fromJson(json['delivery_address'])
              : null,
      locationMetadata: json['location_metadata'],
      industryMetadata: json['industry_metadata'] as Map<String, dynamic>? ?? <String, dynamic>{},
      items: (json['items'] as List?)?.map((item) => OrderItem.fromJson(item)).toList() ??
             (json['order_items'] as List?)?.map((item) => OrderItem.fromJson(item)).toList() ??
             [],
      customerNotes: json['customer_notes'] ?? json['user_notes'],
      providerNotes: json['provider_notes'],
      internalNotes: json['internal_notes'],
      cancellationReason: json['cancellation_reason'],
      cancellationFee: json['cancellation_fee'] != null 
          ? Price.fromJson(json['cancellation_fee'] is Map 
              ? json['cancellation_fee'] 
              : {'amount': json['cancellation_fee']})
          : null,
      disputeStatus: json['dispute_status'] ?? 'none',
      supportTicketId: json['support_ticket_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // 计算属性
  Price get itemsTotal {
    return items.fold(
      Price(amount: 0.0, currency: totalAmount.currency),
      (sum, item) => sum + item.totalPrice,
    );
  }

  bool get isActive => status.isActive;
  bool get isCompleted => status.isCompleted;
  bool get isCancelled => status.isCancelled;
  bool get canCancel => status.canCancel;
  bool get isPaid => paymentStatus.isPaid;
  bool get canRefund => paymentStatus.canRefund;

  bool get isExpired {
    return expiresAt != null && DateTime.now().isAfter(expiresAt!);
  }

  Duration? get estimatedDuration => scheduledTime?.duration;
  Duration? get actualDuration => actualTime?.duration;

  // 根据行业获取特定数据
  T? getIndustryData<T>(String key, [T? defaultValue]) {
    final value = industryMetadata[key];
    if (value is T) {
      return value;
    }
    return defaultValue;
  }

  // 设置行业特定数据
  void setIndustryData<T>(String key, T value) {
    industryMetadata[key] = value;
  }

  Order copyWith({
    String? orderNumber,
    String? customerId,
    String? providerId,
    String? serviceId,
    IndustryType? industry,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? orderType,
    String? fulfillmentMode,
    Price? totalAmount,
    Price? depositAmount,
    Price? finalPaymentAmount,
    Map<String, dynamic>? pricingBreakdown,
    TimeRange? scheduledTime,
    TimeRange? actualTime,
    DateTime? expiresAt,
    Address? serviceAddress,
    Map<String, dynamic>? locationMetadata,
    Map<String, dynamic>? industryMetadata,
    List<OrderItem>? items,
    String? customerNotes,
    String? providerNotes,
    String? internalNotes,
    String? cancellationReason,
    Price? cancellationFee,
    String? disputeStatus,
    String? supportTicketId,
  }) {
    return Order(
      id: id,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      serviceId: serviceId ?? this.serviceId,
      industry: industry ?? this.industry,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderType: orderType ?? this.orderType,
      fulfillmentMode: fulfillmentMode ?? this.fulfillmentMode,
      totalAmount: totalAmount ?? this.totalAmount,
      depositAmount: depositAmount ?? this.depositAmount,
      finalPaymentAmount: finalPaymentAmount ?? this.finalPaymentAmount,
      pricingBreakdown: pricingBreakdown ?? this.pricingBreakdown,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      actualTime: actualTime ?? this.actualTime,
      expiresAt: expiresAt ?? this.expiresAt,
      serviceAddress: serviceAddress ?? this.serviceAddress,
      locationMetadata: locationMetadata ?? this.locationMetadata,
      industryMetadata: industryMetadata ?? this.industryMetadata,
      items: items ?? this.items,
      customerNotes: customerNotes ?? this.customerNotes,
      providerNotes: providerNotes ?? this.providerNotes,
      internalNotes: internalNotes ?? this.internalNotes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancellationFee: cancellationFee ?? this.cancellationFee,
      disputeStatus: disputeStatus ?? this.disputeStatus,
      supportTicketId: supportTicketId ?? this.supportTicketId,
    );
  }
}

/// 通用订单请求模型
class OrderRequest {
  final String serviceId;
  final String providerId;
  final IndustryType industry;
  final String orderType;
  final List<OrderItemRequest> items;
  final Address? serviceAddress;
  final TimeRange? scheduledTime;
  final String? customerNotes;
  final String? couponCode;
  final Configuration industrySpecificData;
  final UserPreferences? userPreferences;

  OrderRequest({
    required this.serviceId,
    required this.providerId,
    required this.industry,
    this.orderType = 'instant',
    required this.items,
    this.serviceAddress,
    this.scheduledTime,
    this.customerNotes,
    this.couponCode,
    Configuration? industrySpecificData,
    this.userPreferences,
  }) : industrySpecificData = industrySpecificData ?? Configuration({});

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'provider_id': providerId,
      'industry': industry.code,
      'order_type': orderType,
      'items': items.map((item) => item.toJson()).toList(),
      'service_address': serviceAddress?.toJson(),
      'scheduled_time': scheduledTime?.toJson(),
      'customer_notes': customerNotes,
      'coupon_code': couponCode,
      'industry_specific_data': industrySpecificData.toJson(),
      'user_preferences': userPreferences?.toJson(),
    };
  }

  factory OrderRequest.fromJson(Map<String, dynamic> json) {
    return OrderRequest(
      serviceId: json['service_id'],
      providerId: json['provider_id'],
      industry: IndustryType.fromCode(json['industry']),
      orderType: json['order_type'] ?? 'instant',
      items: (json['items'] as List)
          .map((item) => OrderItemRequest.fromJson(item))
          .toList(),
      serviceAddress: json['service_address'] != null
          ? Address.fromJson(json['service_address'])
          : null,
      scheduledTime: json['scheduled_time'] != null
          ? TimeRange.fromJson(json['scheduled_time'])
          : null,
      customerNotes: json['customer_notes'],
      couponCode: json['coupon_code'],
      industrySpecificData: Configuration.fromJson(json['industry_specific_data'] ?? {}),
      userPreferences: json['user_preferences'] != null
          ? UserPreferences.fromJson(json['user_preferences'])
          : null,
    );
  }

  double get estimatedTotal {
    return items.fold(0.0, (sum, item) => sum + (item.unitPrice * item.quantity));
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}

/// 通用订单项目请求模型
class OrderItemRequest {
  final String serviceDetailId;
  final String name;
  final String? description;
  final int quantity;
  final double unitPrice;
  final Map<String, dynamic> options;
  final Map<String, dynamic> customizations;
  final String? specialInstructions;

  OrderItemRequest({
    required this.serviceDetailId,
    required this.name,
    this.description,
    required this.quantity,
    required this.unitPrice,
    this.options = const {},
    this.customizations = const {},
    this.specialInstructions,
  });

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson() {
    return {
      'service_detail_id': serviceDetailId,
      'name': name,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'options': options,
      'customizations': customizations,
      'special_instructions': specialInstructions,
    };
  }

  factory OrderItemRequest.fromJson(Map<String, dynamic> json) {
    return OrderItemRequest(
      serviceDetailId: json['service_detail_id'],
      name: json['name'],
      description: json['description'],
      quantity: json['quantity'],
      unitPrice: (json['unit_price'] as num).toDouble(),
      options: json['options'] ?? {},
      customizations: json['customizations'] ?? {},
      specialInstructions: json['special_instructions'],
    );
  }

  OrderItemRequest copyWith({
    String? serviceDetailId,
    String? name,
    String? description,
    int? quantity,
    double? unitPrice,
    Map<String, dynamic>? options,
    Map<String, dynamic>? customizations,
    String? specialInstructions,
  }) {
    return OrderItemRequest(
      serviceDetailId: serviceDetailId ?? this.serviceDetailId,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      options: options ?? this.options,
      customizations: customizations ?? this.customizations,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}

/// 订单状态变更记录
class OrderStatusChange extends BaseEntity {
  final String orderId;
  final OrderStatus fromStatus;
  final OrderStatus toStatus;
  final String? reason;
  final String? changedBy;
  final String changeType; // 'automatic', 'manual', 'system'
  final Map<String, dynamic> metadata;

  OrderStatusChange({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.orderId,
    required this.fromStatus,
    required this.toStatus,
    this.reason,
    this.changedBy,
    this.changeType = 'manual',
    this.metadata = const {},
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'from_status': fromStatus.code,
      'to_status': toStatus.code,
      'reason': reason,
      'changed_by': changedBy,
      'change_type': changeType,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory OrderStatusChange.fromJson(Map<String, dynamic> json) {
    return OrderStatusChange(
      id: json['id'],
      orderId: json['order_id'],
      fromStatus: OrderStatus.fromCode(json['from_status']),
      toStatus: OrderStatus.fromCode(json['to_status']),
      reason: json['reason'],
      changedBy: json['changed_by'],
      changeType: json['change_type'] ?? 'manual',
      metadata: json['metadata'] ?? {},
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}