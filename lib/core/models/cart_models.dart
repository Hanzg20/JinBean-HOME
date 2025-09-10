import 'base_models.dart';

/// 简化的购物车模型
class UnifiedCart {
  final String id;
  final String userId;
  final CartType cartType;
  final String status;
  final IndustryType? industryType;
  final int totalItems;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final String currency;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;

  UnifiedCart({
    required this.id,
    required this.userId,
    required this.cartType,
    required this.status,
    this.industryType,
    required this.totalItems,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    required this.currency,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
  });

  factory UnifiedCart.fromJson(Map<String, dynamic> json) {
    return UnifiedCart(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      cartType: CartType.fromString(json['cart_type'] as String),
      status: json['status'] as String,
      industryType: json['industry_type'] != null 
          ? IndustryType.fromString(json['industry_type'] as String)
          : null,
      totalItems: json['total_items'] as int? ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'CAD',
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList()
          : [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'cart_type': cartType.value,
      'status': status,
      'industry_type': industryType?.value,
      'total_items': totalItems,
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}

/// 简化的购物车商品模型
class CartItem {
  final String id;
  final String cartId;
  final String serviceId;
  final String? serviceDetailId;
  final CartItemType itemType;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final Map<String, dynamic> itemNameSnapshot;
  final String? itemDescriptionSnapshot;
  final String? itemImageSnapshot;
  final String? providerNameSnapshot;
  final Map<String, dynamic> customizations;
  final List<String>? dietaryRestrictions;
  final String? specialInstructions;
  final String currency;
  final DateTime addedAt;
  final DateTime updatedAt;
  
  // 预约时间信息
  final DateTime? scheduledStartTime;
  final DateTime? scheduledEndTime;

  CartItem({
    required this.id,
    required this.cartId,
    required this.serviceId,
    this.serviceDetailId,
    required this.itemType,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.itemNameSnapshot,
    this.itemDescriptionSnapshot,
    this.itemImageSnapshot,
    this.providerNameSnapshot,
    this.customizations = const {},
    this.dietaryRestrictions,
    this.specialInstructions,
    required this.currency,
    required this.addedAt,
    required this.updatedAt,
    this.scheduledStartTime,
    this.scheduledEndTime,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String? ?? '',
      cartId: json['cart_id'] as String? ?? '',
      serviceId: json['service_id'] as String? ?? '',
      serviceDetailId: json['service_detail_id'] as String?,
      itemType: CartItemType.fromString(json['item_type'] as String? ?? 'menu_item'),
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      itemNameSnapshot: json['item_name_snapshot'] as Map<String, dynamic>? ?? {},
      itemDescriptionSnapshot: json['item_description_snapshot'] as String?,
      itemImageSnapshot: json['item_image_snapshot'] as String?,
      providerNameSnapshot: json['provider_name_snapshot'] as String?,
      customizations: json['customizations'] as Map<String, dynamic>? ?? {},
      dietaryRestrictions: json['dietary_restrictions'] != null
          ? List<String>.from(json['dietary_restrictions'] as List)
          : null,
      specialInstructions: json['special_instructions'] as String?,
      currency: json['currency'] as String? ?? 'CAD',
      addedAt: json['added_at'] != null 
          ? DateTime.parse(json['added_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      scheduledStartTime: json['scheduled_start_time'] != null
          ? DateTime.parse(json['scheduled_start_time'] as String)
          : null,
      scheduledEndTime: json['scheduled_end_time'] != null
          ? DateTime.parse(json['scheduled_end_time'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'service_id': serviceId,
      'service_detail_id': serviceDetailId,
      'item_type': itemType.value,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'item_name_snapshot': itemNameSnapshot,
      'item_description_snapshot': itemDescriptionSnapshot,
      'item_image_snapshot': itemImageSnapshot,
      'provider_name_snapshot': providerNameSnapshot,
      'customizations': customizations,
      'dietary_restrictions': dietaryRestrictions,
      'special_instructions': specialInstructions,
      'currency': currency,
      'added_at': addedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'scheduled_start_time': scheduledStartTime?.toIso8601String(),
      'scheduled_end_time': scheduledEndTime?.toIso8601String(),
    };
  }

  /// 创建 CartItem 的副本并可选择性地修改某些属性
  CartItem copyWith({
    String? id,
    String? cartId,
    String? serviceId,
    String? serviceDetailId,
    CartItemType? itemType,
    int? quantity,
    double? unitPrice,
    double? subtotal,
    Map<String, dynamic>? itemNameSnapshot,
    String? itemDescriptionSnapshot,
    String? itemImageSnapshot,
    String? providerNameSnapshot,
    Map<String, dynamic>? customizations,
    List<String>? dietaryRestrictions,
    String? specialInstructions,
    String? currency,
    DateTime? addedAt,
    DateTime? updatedAt,
    DateTime? scheduledStartTime,
    DateTime? scheduledEndTime,
  }) {
    return CartItem(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      serviceId: serviceId ?? this.serviceId,
      serviceDetailId: serviceDetailId ?? this.serviceDetailId,
      itemType: itemType ?? this.itemType,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? (quantity != null || unitPrice != null 
          ? (quantity ?? this.quantity) * (unitPrice ?? this.unitPrice)
          : this.subtotal),
      itemNameSnapshot: itemNameSnapshot ?? this.itemNameSnapshot,
      itemDescriptionSnapshot: itemDescriptionSnapshot ?? this.itemDescriptionSnapshot,
      itemImageSnapshot: itemImageSnapshot ?? this.itemImageSnapshot,
      providerNameSnapshot: providerNameSnapshot ?? this.providerNameSnapshot,
      customizations: customizations ?? this.customizations,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      currency: currency ?? this.currency,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      scheduledEndTime: scheduledEndTime ?? this.scheduledEndTime,
    );
  }
}