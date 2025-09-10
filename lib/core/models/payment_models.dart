import 'base_models.dart';

/// 通用支付方式模型
class PaymentMethod extends BaseEntity {
  final String userId;
  final PaymentMethodType type;
  final String providerId; // 'stripe', 'square', 'paypal'
  final String externalTokenId;
  final String? cardLast4;
  final String? cardBrand;
  final int? cardExpMonth;
  final int? cardExpYear;
  final String? cardHolderName;
  final String? email; // for PayPal
  final bool isDefault;
  final bool isActive;
  final Map<String, dynamic> metadata;

  PaymentMethod({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.userId,
    required this.type,
    required this.providerId,
    required this.externalTokenId,
    this.cardLast4,
    this.cardBrand,
    this.cardExpMonth,
    this.cardExpYear,
    this.cardHolderName,
    this.email,
    required this.isDefault,
    required this.isActive,
    this.metadata = const {},
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.code,
      'provider_id': providerId,
      'external_token_id': externalTokenId,
      'card_last4': cardLast4,
      'card_brand': cardBrand,
      'card_exp_month': cardExpMonth,
      'card_exp_year': cardExpYear,
      'card_holder_name': cardHolderName,
      'email': email,
      'is_default': isDefault,
      'is_active': isActive,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      userId: json['user_id'],
      type: PaymentMethodType.fromCode(json['type']),
      providerId: json['provider_id'],
      externalTokenId: json['external_token_id'],
      cardLast4: json['card_last4'],
      cardBrand: json['card_brand'],
      cardExpMonth: json['card_exp_month'],
      cardExpYear: json['card_exp_year'],
      cardHolderName: json['card_holder_name'],
      email: json['email'],
      isDefault: json['is_default'] ?? false,
      isActive: json['is_active'] ?? true,
      metadata: json['metadata'] ?? {},
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  String get displayName {
    switch (type) {
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        if (cardBrand != null && cardLast4 != null) {
          return '${cardBrand!.toUpperCase()} •••• $cardLast4';
        }
        return type.label;
      case PaymentMethodType.paypal:
        return email ?? 'PayPal';
      default:
        return type.label;
    }
  }

  bool get isExpired {
    if (cardExpMonth == null || cardExpYear == null) return false;
    final now = DateTime.now();
    final expiry = DateTime(cardExpYear!, cardExpMonth!);
    return now.isAfter(expiry);
  }

  PaymentMethod copyWith({
    String? userId,
    PaymentMethodType? type,
    String? providerId,
    String? externalTokenId,
    String? cardLast4,
    String? cardBrand,
    int? cardExpMonth,
    int? cardExpYear,
    String? cardHolderName,
    String? email,
    bool? isDefault,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentMethod(
      id: id,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      userId: userId ?? this.userId,
      type: type ?? this.type,
      providerId: providerId ?? this.providerId,
      externalTokenId: externalTokenId ?? this.externalTokenId,
      cardLast4: cardLast4 ?? this.cardLast4,
      cardBrand: cardBrand ?? this.cardBrand,
      cardExpMonth: cardExpMonth ?? this.cardExpMonth,
      cardExpYear: cardExpYear ?? this.cardExpYear,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      email: email ?? this.email,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// 通用支付记录模型
class Payment extends BaseEntity {
  final String paymentId; // 外部支付系统ID
  final String orderId;
  final String paymentType; // 'charge', 'refund', 'transfer', 'payout'
  final PaymentMethodType paymentMethod;
  final String paymentProvider; // 'stripe', 'square', 'paypal'
  final Price amount;
  final Price processingFee;
  final Price netAmount;
  final PaymentStatus status;
  final String? failureReason;
  final Map<String, dynamic> paymentMethodDetails;
  final String? externalTransactionId;
  final String? externalReference;
  final Map<String, dynamic> providerResponse;
  final DateTime? processedAt;

  Payment({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.paymentId,
    required this.orderId,
    required this.paymentType,
    required this.paymentMethod,
    required this.paymentProvider,
    required this.amount,
    required this.processingFee,
    required this.netAmount,
    required this.status,
    this.failureReason,
    this.paymentMethodDetails = const {},
    this.externalTransactionId,
    this.externalReference,
    this.providerResponse = const {},
    this.processedAt,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_id': paymentId,
      'order_id': orderId,
      'payment_type': paymentType,
      'payment_method': paymentMethod.code,
      'payment_provider': paymentProvider,
      'amount': amount.toJson(),
      'processing_fee': processingFee.toJson(),
      'net_amount': netAmount.toJson(),
      'status': status.code,
      'failure_reason': failureReason,
      'payment_method_details': paymentMethodDetails,
      'external_transaction_id': externalTransactionId,
      'external_reference': externalReference,
      'provider_response': providerResponse,
      'processed_at': processedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      paymentId: json['payment_id'],
      orderId: json['order_id'],
      paymentType: json['payment_type'],
      paymentMethod: PaymentMethodType.fromCode(json['payment_method']),
      paymentProvider: json['payment_provider'],
      amount: Price.fromJson(json['amount'] is Map 
          ? json['amount'] 
          : {'amount': json['amount'] ?? 0.0}),
      processingFee: Price.fromJson(json['processing_fee'] is Map 
          ? json['processing_fee'] 
          : {'amount': json['processing_fee'] ?? 0.0}),
      netAmount: Price.fromJson(json['net_amount'] is Map 
          ? json['net_amount'] 
          : {'amount': json['net_amount'] ?? 0.0}),
      status: PaymentStatus.fromCode(json['status']),
      failureReason: json['failure_reason'],
      paymentMethodDetails: json['payment_method_details'] ?? {},
      externalTransactionId: json['external_transaction_id'],
      externalReference: json['external_reference'],
      providerResponse: json['provider_response'] ?? {},
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  bool get isSuccessful => status == PaymentStatus.completed;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isPending => status == PaymentStatus.pending || status == PaymentStatus.processing;
  bool get isRefund => paymentType == 'refund';
  bool get isCharge => paymentType == 'charge';

  Payment copyWith({
    String? paymentId,
    String? orderId,
    String? paymentType,
    PaymentMethodType? paymentMethod,
    String? paymentProvider,
    Price? amount,
    Price? processingFee,
    Price? netAmount,
    PaymentStatus? status,
    String? failureReason,
    Map<String, dynamic>? paymentMethodDetails,
    String? externalTransactionId,
    String? externalReference,
    Map<String, dynamic>? providerResponse,
    DateTime? processedAt,
  }) {
    return Payment(
      id: id,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      paymentId: paymentId ?? this.paymentId,
      orderId: orderId ?? this.orderId,
      paymentType: paymentType ?? this.paymentType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentProvider: paymentProvider ?? this.paymentProvider,
      amount: amount ?? this.amount,
      processingFee: processingFee ?? this.processingFee,
      netAmount: netAmount ?? this.netAmount,
      status: status ?? this.status,
      failureReason: failureReason ?? this.failureReason,
      paymentMethodDetails: paymentMethodDetails ?? this.paymentMethodDetails,
      externalTransactionId: externalTransactionId ?? this.externalTransactionId,
      externalReference: externalReference ?? this.externalReference,
      providerResponse: providerResponse ?? this.providerResponse,
      processedAt: processedAt ?? this.processedAt,
    );
  }
}

/// 支付意图模型
class PaymentIntent extends BaseEntity {
  final String orderId;
  final Price amount;
  final String paymentProvider;
  final PaymentStatus status;
  final String? clientSecret;
  final String? confirmationMethod;
  final Map<String, dynamic> metadata;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;

  PaymentIntent({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.orderId,
    required this.amount,
    required this.paymentProvider,
    required this.status,
    this.clientSecret,
    this.confirmationMethod,
    this.metadata = const {},
    this.confirmedAt,
    this.cancelledAt,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'amount': amount.toJson(),
      'payment_provider': paymentProvider,
      'status': status.code,
      'client_secret': clientSecret,
      'confirmation_method': confirmationMethod,
      'metadata': metadata,
      'confirmed_at': confirmedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(
      id: json['id'],
      orderId: json['order_id'],
      amount: Price.fromJson(json['amount'] is Map 
          ? json['amount'] 
          : {'amount': json['amount'] ?? 0.0}),
      paymentProvider: json['payment_provider'],
      status: PaymentStatus.fromCode(json['status']),
      clientSecret: json['client_secret'],
      confirmationMethod: json['confirmation_method'],
      metadata: json['metadata'] ?? {},
      confirmedAt: json['confirmed_at'] != null 
          ? DateTime.parse(json['confirmed_at'])
          : null,
      cancelledAt: json['cancelled_at'] != null 
          ? DateTime.parse(json['cancelled_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  bool get requiresConfirmation => status == PaymentStatus.pending;
  bool get isConfirmed => confirmedAt != null;
  bool get isCancelled => cancelledAt != null;
}

/// 定价规则模型
class PricingRule extends BaseEntity {
  final String serviceId;
  final IndustryType industry;
  final String ruleType; // 'base', 'delivery', 'packaging', 'peak', 'distance', 'time'
  final String ruleName;
  final Configuration ruleConfig;
  final Price? minOrderAmount;
  final Price? maxOrderAmount;
  final List<String> applicableAreas;
  final Map<String, dynamic> timeRestrictions;
  final bool isActive;
  final int priority;

  PricingRule({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.serviceId,
    required this.industry,
    required this.ruleType,
    required this.ruleName,
    required this.ruleConfig,
    this.minOrderAmount,
    this.maxOrderAmount,
    this.applicableAreas = const [],
    this.timeRestrictions = const {},
    required this.isActive,
    this.priority = 0,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'industry': industry.code,
      'rule_type': ruleType,
      'rule_name': ruleName,
      'rule_config': ruleConfig.toJson(),
      'min_order_amount': minOrderAmount?.toJson(),
      'max_order_amount': maxOrderAmount?.toJson(),
      'applicable_areas': applicableAreas,
      'time_restrictions': timeRestrictions,
      'is_active': isActive,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PricingRule.fromJson(Map<String, dynamic> json) {
    return PricingRule(
      id: json['id'],
      serviceId: json['service_id'],
      industry: IndustryType.fromCode(json['industry'] ?? 'food'),
      ruleType: json['rule_type'],
      ruleName: json['rule_name'],
      ruleConfig: Configuration.fromJson(json['rule_config'] ?? {}),
      minOrderAmount: json['min_order_amount'] != null 
          ? Price.fromJson(json['min_order_amount'] is Map 
              ? json['min_order_amount'] 
              : {'amount': json['min_order_amount']})
          : null,
      maxOrderAmount: json['max_order_amount'] != null 
          ? Price.fromJson(json['max_order_amount'] is Map 
              ? json['max_order_amount'] 
              : {'amount': json['max_order_amount']})
          : null,
      applicableAreas: (json['applicable_areas'] as List?)?.cast<String>() ?? [],
      timeRestrictions: json['time_restrictions'] ?? {},
      isActive: json['is_active'] ?? true,
      priority: json['priority'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // 检查规则是否适用
  bool isApplicable({
    required Price orderAmount,
    String? area,
    DateTime? time,
  }) {
    if (!isActive) return false;
    
    // 检查金额限制
    if (minOrderAmount != null && orderAmount < minOrderAmount!) return false;
    if (maxOrderAmount != null && orderAmount > maxOrderAmount!) return false;
    
    // 检查区域限制
    if (applicableAreas.isNotEmpty && area != null && !applicableAreas.contains(area)) {
      return false;
    }
    
    // 检查时间限制
    if (timeRestrictions.isNotEmpty && time != null) {
      // TODO: 实现时间限制检查逻辑
    }
    
    return true;
  }

  // 计算规则价格
  Price calculatePrice({
    required Price baseAmount,
    Map<String, dynamic>? context,
  }) {
    final config = ruleConfig;
    
    switch (ruleType) {
      case 'percentage':
        final rate = config.get<double>('rate', 0.0) ?? 0.0;
        return baseAmount * rate;
      
      case 'fixed':
        final amount = config.get<double>('amount', 0.0) ?? 0.0;
        return Price(amount: amount, currency: baseAmount.currency);
      
      case 'tiered':
        final tiers = config.get<List>('tiers', []) ?? [];
        for (final tier in tiers) {
          final threshold = tier['threshold'] as double;
          if (baseAmount.amount >= threshold) {
            final rate = tier['rate'] as double;
            return baseAmount * rate;
          }
        }
        return Price(amount: 0.0, currency: baseAmount.currency);
      
      default:
        return Price(amount: 0.0, currency: baseAmount.currency);
    }
  }
}

/// 优惠券模型
class Coupon extends BaseEntity {
  final String code;
  final MultiLanguageText title;
  final MultiLanguageText? description;
  final IndustryType? industry; // null表示通用
  final String discountType; // 'percentage', 'fixed_amount', 'free_shipping'
  final double discountValue;
  final Price? minOrderAmount;
  final Price? maxDiscountAmount;
  final List<String> applicableServices;
  final List<String> applicableCategories;
  final TimeRange validPeriod;
  final int? usageLimit;
  final int? usageLimitPerUser;
  final int usedCount;
  final bool isActive;
  final Configuration restrictions;

  Coupon({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.code,
    required this.title,
    this.description,
    this.industry,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount,
    this.maxDiscountAmount,
    this.applicableServices = const [],
    this.applicableCategories = const [],
    required this.validPeriod,
    this.usageLimit,
    this.usageLimitPerUser,
    required this.usedCount,
    required this.isActive,
    Configuration? restrictions,
  }) : restrictions = restrictions ?? Configuration({});

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title.toJson(),
      'description': description?.toJson(),
      'industry': industry?.code,
      'discount_type': discountType,
      'discount_value': discountValue,
      'min_order_amount': minOrderAmount?.toJson(),
      'max_discount_amount': maxDiscountAmount?.toJson(),
      'applicable_services': applicableServices,
      'applicable_categories': applicableCategories,
      'valid_from': validPeriod.start.toIso8601String(),
      'valid_until': validPeriod.end.toIso8601String(),
      'usage_limit': usageLimit,
      'usage_limit_per_user': usageLimitPerUser,
      'used_count': usedCount,
      'is_active': isActive,
      'restrictions': restrictions.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      code: json['code'],
      title: MultiLanguageText.fromDynamic(json['title']),
      description: json['description'] != null 
          ? MultiLanguageText.fromDynamic(json['description'])
          : null,
      industry: json['industry'] != null 
          ? IndustryType.fromCode(json['industry'])
          : null,
      discountType: json['discount_type'],
      discountValue: (json['discount_value'] as num).toDouble(),
      minOrderAmount: json['min_order_amount'] != null 
          ? Price.fromJson(json['min_order_amount'] is Map 
              ? json['min_order_amount'] 
              : {'amount': json['min_order_amount']})
          : null,
      maxDiscountAmount: json['max_discount_amount'] != null 
          ? Price.fromJson(json['max_discount_amount'] is Map 
              ? json['max_discount_amount'] 
              : {'amount': json['max_discount_amount']})
          : null,
      applicableServices: (json['applicable_services'] as List?)?.cast<String>() ?? [],
      applicableCategories: (json['applicable_categories'] as List?)?.cast<String>() ?? [],
      validPeriod: TimeRange(
        start: DateTime.parse(json['valid_from']),
        end: DateTime.parse(json['valid_until']),
      ),
      usageLimit: json['usage_limit'],
      usageLimitPerUser: json['usage_limit_per_user'],
      usedCount: json['used_count'] ?? 0,
      isActive: json['is_active'] ?? true,
      restrictions: Configuration.fromJson(json['restrictions'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        validPeriod.contains(now) &&
        (usageLimit == null || usedCount < usageLimit!);
  }

  bool isApplicableTo({
    required IndustryType orderIndustry,
    required Price orderAmount,
    String? serviceId,
    String? categoryId,
    String? userId,
  }) {
    if (!isValid) return false;
    
    // 检查行业限制
    if (industry != null && industry != orderIndustry) return false;
    
    // 检查最小订单金额
    if (minOrderAmount != null && orderAmount < minOrderAmount!) return false;
    
    // 检查服务限制
    if (applicableServices.isNotEmpty && serviceId != null && !applicableServices.contains(serviceId)) {
      return false;
    }
    
    // 检查分类限制
    if (applicableCategories.isNotEmpty && categoryId != null && !applicableCategories.contains(categoryId)) {
      return false;
    }
    
    // TODO: 检查用户使用次数限制
    
    return true;
  }

  Price calculateDiscount(Price orderAmount) {
    Price discount;
    
    switch (discountType) {
      case 'percentage':
        discount = orderAmount * (discountValue / 100);
        break;
      case 'fixed_amount':
        discount = Price(amount: discountValue, currency: orderAmount.currency);
        break;
      case 'free_shipping':
        // 需要从订单中获取配送费
        discount = Price(amount: 0.0, currency: orderAmount.currency);
        break;
      default:
        discount = Price(amount: 0.0, currency: orderAmount.currency);
    }
    
    // 应用最大折扣限制
    if (maxDiscountAmount != null && discount > maxDiscountAmount!) {
      discount = maxDiscountAmount!;
    }
    
    return discount;
  }
}

/// 定价计算结果
class PricingResult {
  final Price baseAmount;
  final List<PricingFee> fees;
  final List<PricingDiscount> discounts;
  final Price totalAmount;
  final String currency;
  final Map<String, dynamic> breakdown;
  final List<PricingRule> appliedRules;
  final Coupon? appliedCoupon;

  PricingResult({
    required this.baseAmount,
    required this.fees,
    required this.discounts,
    required this.totalAmount,
    required this.currency,
    this.breakdown = const {},
    this.appliedRules = const [],
    this.appliedCoupon,
  });

  Price get feesTotal {
    return fees.fold(
      Price(amount: 0.0, currency: currency),
      (sum, fee) => sum + fee.amount,
    );
  }

  Price get discountsTotal {
    return discounts.fold(
      Price(amount: 0.0, currency: currency),
      (sum, discount) => sum + discount.amount,
    );
  }

  Price get subtotal => baseAmount + feesTotal;

  Map<String, dynamic> toJson() {
    return {
      'base_amount': baseAmount.toJson(),
      'fees': fees.map((fee) => fee.toJson()).toList(),
      'discounts': discounts.map((discount) => discount.toJson()).toList(),
      'fees_total': feesTotal.toJson(),
      'discounts_total': discountsTotal.toJson(),
      'subtotal': subtotal.toJson(),
      'total_amount': totalAmount.toJson(),
      'currency': currency,
      'breakdown': breakdown,
      'applied_rules': appliedRules.map((rule) => rule.toJson()).toList(),
      'applied_coupon': appliedCoupon?.toJson(),
    };
  }

  factory PricingResult.fromJson(Map<String, dynamic> json) {
    return PricingResult(
      baseAmount: Price.fromJson(json['base_amount']),
      fees: (json['fees'] as List?)?.map((fee) => PricingFee.fromJson(fee)).toList() ?? [],
      discounts: (json['discounts'] as List?)?.map((discount) => PricingDiscount.fromJson(discount)).toList() ?? [],
      totalAmount: Price.fromJson(json['total_amount']),
      currency: json['currency'] ?? 'CAD',
      breakdown: json['breakdown'] ?? {},
      appliedRules: (json['applied_rules'] as List?)?.map((rule) => PricingRule.fromJson(rule)).toList() ?? [],
      appliedCoupon: json['applied_coupon'] != null ? Coupon.fromJson(json['applied_coupon']) : null,
    );
  }
}

/// 定价费用项目
class PricingFee {
  final String type;
  final String name;
  final Price amount;
  final String? description;

  PricingFee({
    required this.type,
    required this.name,
    required this.amount,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'amount': amount.toJson(),
      'description': description,
    };
  }

  factory PricingFee.fromJson(Map<String, dynamic> json) {
    return PricingFee(
      type: json['type'],
      name: json['name'],
      amount: Price.fromJson(json['amount'] is Map 
          ? json['amount'] 
          : {'amount': json['amount'] ?? 0.0}),
      description: json['description'],
    );
  }
}

/// 定价折扣项目
class PricingDiscount {
  final String type;
  final String name;
  final Price amount;
  final String? description;

  PricingDiscount({
    required this.type,
    required this.name,
    required this.amount,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'amount': amount.toJson(),
      'description': description,
    };
  }

  factory PricingDiscount.fromJson(Map<String, dynamic> json) {
    return PricingDiscount(
      type: json['type'],
      name: json['name'],
      amount: Price.fromJson(json['amount'] is Map 
          ? json['amount'] 
          : {'amount': json['amount'] ?? 0.0}),
      description: json['description'],
    );
  }
}

/// 支付结果
class PaymentResult {
  final bool success;
  final String paymentId;
  final String? transactionId;
  final String message;
  final PaymentStatus status;
  final Map<String, dynamic> details;

  PaymentResult({
    required this.success,
    required this.paymentId,
    this.transactionId,
    required this.message,
    required this.status,
    this.details = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payment_id': paymentId,
      'transaction_id': transactionId,
      'message': message,
      'status': status.code,
      'details': details,
    };
  }

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      success: json['success'],
      paymentId: json['payment_id'],
      transactionId: json['transaction_id'],
      message: json['message'],
      status: PaymentStatus.fromCode(json['status']),
      details: json['details'] ?? {},
    );
  }

  factory PaymentResult.success({
    required String paymentId,
    String? transactionId,
    String message = '支付成功',
    Map<String, dynamic>? details,
  }) {
    return PaymentResult(
      success: true,
      paymentId: paymentId,
      transactionId: transactionId,
      message: message,
      status: PaymentStatus.completed,
      details: details ?? {},
    );
  }

  factory PaymentResult.failure({
    required String paymentId,
    required String message,
    PaymentStatus status = PaymentStatus.failed,
    Map<String, dynamic>? details,
  }) {
    return PaymentResult(
      success: false,
      paymentId: paymentId,
      message: message,
      status: status,
      details: details ?? {},
    );
  }
}

/// 退款结果
class RefundResult {
  final bool success;
  final String refundId;
  final Price amount;
  final String message;
  final Map<String, dynamic> details;

  RefundResult({
    required this.success,
    required this.refundId,
    required this.amount,
    required this.message,
    this.details = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'refund_id': refundId,
      'amount': amount.toJson(),
      'message': message,
      'details': details,
    };
  }

  factory RefundResult.fromJson(Map<String, dynamic> json) {
    return RefundResult(
      success: json['success'],
      refundId: json['refund_id'],
      amount: Price.fromJson(json['amount'] is Map 
          ? json['amount'] 
          : {'amount': json['amount'] ?? 0.0}),
      message: json['message'],
      details: json['details'] ?? {},
    );
  }
}