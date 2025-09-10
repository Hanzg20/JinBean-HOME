/// 灵活定价相关数据模型
/// 支持价格不固定订单、报价订单、评估等功能

import 'package:flutter/material.dart';

/// 定价类型枚举
enum PricingType {
  fixed,           // 固定价格
  range,           // 价格区间
  assessment,      // 现场评估
  customQuote,     // 定制报价
  hourly,          // 按小时计费
  projectBased,    // 按项目计费
}

/// 定价因素类型枚举
enum PricingFactorType {
  selection,       // 单选：房屋类型
  multiSelect,     // 多选：清洁项目
  range,          // 范围：面积大小
  boolean,        // 布尔：是否加急
  text,           // 文本：特殊要求
  number,         // 数字：楼层数
}

/// 评估类型枚举
enum AssessmentType {
  remote,          // 远程评估
  onSite,          // 现场评估
  hybrid,          // 混合评估
}

/// 评估状态枚举
enum AssessmentStatus {
  pending,         // 待评估
  scheduled,       // 已预约
  inProgress,      // 评估中
  completed,       // 已完成
  cancelled,       // 已取消
}

/// 报价状态枚举
enum QuoteStatus {
  draft,           // 草稿
  sent,            // 已发送
  viewed,          // 已查看
  underReview,     // 审查中
  revised,         // 已修改
  accepted,        // 已接受
  rejected,        // 已拒绝
  expired,         // 已过期
  cancelled,       // 已取消
}

/// 报价类型枚举
enum QuoteType {
  standard,        // 标准报价
  competitive,     // 竞争报价
  negotiated,      // 议价报价
  revised,         // 修改报价
}

/// 支付里程碑状态枚举
enum PaymentMilestoneStatus {
  pending,         // 待支付
  paid,           // 已支付
  overdue,        // 逾期
  cancelled,      // 已取消
}

/// 灵活定价服务详情模型
class FlexiblePricingServiceDetail {
  final String id;
  final String serviceId;
  final PricingType pricingType;
  
  // 价格信息
  final double? basePrice;           // 基础价格
  final double? minPrice;           // 最低价格
  final double? maxPrice;           // 最高价格
  final String priceUnit;           // 计价单位
  final String currency;
  
  // 定价因素
  final List<PricingFactor> pricingFactors;
  final Map<String, dynamic> pricingRules;
  
  // 评估设置
  final bool requiresAssessment;
  final double? assessmentFee;
  final bool assessmentFeeRefundable;
  final Duration? assessmentDuration;
  
  // 报价设置
  final bool allowsCustomQuote;
  final Duration? quoteValidDuration;
  final int maxQuoteRevisions;
  final bool requiresDeposit;
  final double? depositPercentage;
  
  // 服务配置
  final Duration estimatedServiceDuration;
  final List<String> includedServices;
  final List<String> optionalServices;
  final Map<String, dynamic> serviceTerms;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  const FlexiblePricingServiceDetail({
    required this.id,
    required this.serviceId,
    required this.pricingType,
    this.basePrice,
    this.minPrice,
    this.maxPrice,
    this.priceUnit = '次',
    this.currency = 'CAD',
    this.pricingFactors = const [],
    this.pricingRules = const {},
    this.requiresAssessment = false,
    this.assessmentFee,
    this.assessmentFeeRefundable = true,
    this.assessmentDuration,
    this.allowsCustomQuote = false,
    this.quoteValidDuration,
    this.maxQuoteRevisions = 3,
    this.requiresDeposit = false,
    this.depositPercentage,
    required this.estimatedServiceDuration,
    this.includedServices = const [],
    this.optionalServices = const [],
    this.serviceTerms = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory FlexiblePricingServiceDetail.fromJson(Map<String, dynamic> json) {
    return FlexiblePricingServiceDetail(
      id: json['id'] as String,
      serviceId: json['service_id'] as String,
      pricingType: PricingType.values.firstWhere(
        (e) => e.name == json['pricing_type'],
        orElse: () => PricingType.fixed,
      ),
      basePrice: (json['base_price'] as num?)?.toDouble(),
      minPrice: (json['min_price'] as num?)?.toDouble(),
      maxPrice: (json['max_price'] as num?)?.toDouble(),
      priceUnit: json['price_unit'] as String? ?? '次',
      currency: json['currency'] as String? ?? 'CAD',
      pricingFactors: (json['pricing_factors'] as List<dynamic>?)
          ?.map((factor) => PricingFactor.fromJson(factor as Map<String, dynamic>))
          .toList() ?? [],
      pricingRules: Map<String, dynamic>.from(json['pricing_rules'] ?? {}),
      requiresAssessment: json['requires_assessment'] as bool? ?? false,
      assessmentFee: (json['assessment_fee'] as num?)?.toDouble(),
      assessmentFeeRefundable: json['assessment_fee_refundable'] as bool? ?? true,
      assessmentDuration: json['assessment_duration'] != null
          ? Duration(minutes: json['assessment_duration'] as int)
          : null,
      allowsCustomQuote: json['allows_custom_quote'] as bool? ?? false,
      quoteValidDuration: json['quote_valid_duration'] != null
          ? Duration(days: json['quote_valid_duration'] as int)
          : null,
      maxQuoteRevisions: json['max_quote_revisions'] as int? ?? 3,
      requiresDeposit: json['requires_deposit'] as bool? ?? false,
      depositPercentage: (json['deposit_percentage'] as num?)?.toDouble(),
      estimatedServiceDuration: Duration(
        minutes: json['estimated_service_duration'] as int? ?? 60,
      ),
      includedServices: List<String>.from(json['included_services'] ?? []),
      optionalServices: List<String>.from(json['optional_services'] ?? []),
      serviceTerms: Map<String, dynamic>.from(json['service_terms'] ?? {}),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'pricing_type': pricingType.name,
      'base_price': basePrice,
      'min_price': minPrice,
      'max_price': maxPrice,
      'price_unit': priceUnit,
      'currency': currency,
      'pricing_factors': pricingFactors.map((f) => f.toJson()).toList(),
      'pricing_rules': pricingRules,
      'requires_assessment': requiresAssessment,
      'assessment_fee': assessmentFee,
      'assessment_fee_refundable': assessmentFeeRefundable,
      'assessment_duration': assessmentDuration?.inMinutes,
      'allows_custom_quote': allowsCustomQuote,
      'quote_valid_duration': quoteValidDuration?.inDays,
      'max_quote_revisions': maxQuoteRevisions,
      'requires_deposit': requiresDeposit,
      'deposit_percentage': depositPercentage,
      'estimated_service_duration': estimatedServiceDuration.inMinutes,
      'included_services': includedServices,
      'optional_services': optionalServices,
      'service_terms': serviceTerms,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 获取格式化的价格范围
  String get formattedPriceRange {
    if (minPrice != null && maxPrice != null) {
      return '\$${minPrice!.toStringAsFixed(2)} - \$${maxPrice!.toStringAsFixed(2)}';
    } else if (basePrice != null) {
      return '\$${basePrice!.toStringAsFixed(2)}';
    }
    return '价格面议';
  }

  /// 是否支持在线预订
  bool get supportsOnlineBooking {
    return pricingType == PricingType.fixed || 
           (pricingType == PricingType.range && !requiresAssessment);
  }
}

/// 定价因素模型
class PricingFactor {
  final String id;
  final String name;
  final String description;
  final PricingFactorType type;
  final Map<String, dynamic> options;
  final double impactWeight;        // 影响权重 0-1
  final bool isRequired;
  final int sortOrder;

  const PricingFactor({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.options,
    this.impactWeight = 0.1,
    this.isRequired = false,
    this.sortOrder = 0,
  });

  factory PricingFactor.fromJson(Map<String, dynamic> json) {
    return PricingFactor(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: PricingFactorType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PricingFactorType.selection,
      ),
      options: Map<String, dynamic>.from(json['options'] ?? {}),
      impactWeight: (json['impact_weight'] as num?)?.toDouble() ?? 0.1,
      isRequired: json['is_required'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'options': options,
      'impact_weight': impactWeight,
      'is_required': isRequired,
      'sort_order': sortOrder,
    };
  }

  /// 获取选项列表
  List<PricingFactorOption> get optionsList {
    if (type == PricingFactorType.selection || type == PricingFactorType.multiSelect) {
      final optionsList = options['options'] as List<dynamic>? ?? [];
      return optionsList.map<PricingFactorOption>((option) {
        return PricingFactorOption.fromJson(option as Map<String, dynamic>);
      }).toList();
    }
    return [];
  }

  /// 获取范围配置
  PricingFactorRange? get rangeConfig {
    if (type == PricingFactorType.range || type == PricingFactorType.number) {
      return PricingFactorRange.fromJson(options);
    }
    return null;
  }
}

/// 定价因素选项
class PricingFactorOption {
  final String value;
  final String label;
  final String? description;
  final double priceMultiplier;     // 价格倍数
  final double priceAdjustment;     // 价格调整
  final bool isDefault;

  const PricingFactorOption({
    required this.value,
    required this.label,
    this.description,
    this.priceMultiplier = 1.0,
    this.priceAdjustment = 0.0,
    this.isDefault = false,
  });

  factory PricingFactorOption.fromJson(Map<String, dynamic> json) {
    return PricingFactorOption(
      value: json['value'] as String,
      label: json['label'] as String,
      description: json['description'] as String?,
      priceMultiplier: (json['price_multiplier'] as num?)?.toDouble() ?? 1.0,
      priceAdjustment: (json['price_adjustment'] as num?)?.toDouble() ?? 0.0,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
      'description': description,
      'price_multiplier': priceMultiplier,
      'price_adjustment': priceAdjustment,
      'is_default': isDefault,
    };
  }
}

/// 定价因素范围
class PricingFactorRange {
  final double min;
  final double max;
  final double step;
  final String unit;
  final double pricePerUnit;

  const PricingFactorRange({
    required this.min,
    required this.max,
    this.step = 1.0,
    this.unit = '',
    this.pricePerUnit = 0.0,
  });

  factory PricingFactorRange.fromJson(Map<String, dynamic> json) {
    return PricingFactorRange(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      step: (json['step'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] as String? ?? '',
      pricePerUnit: (json['price_per_unit'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
      'step': step,
      'unit': unit,
      'price_per_unit': pricePerUnit,
    };
  }
}

/// 价格范围模型
class PriceRange {
  final double min;
  final double max;
  final String currency;
  final List<PriceFactorExplanation> factors;

  const PriceRange({
    required this.min,
    required this.max,
    required this.currency,
    required this.factors,
  });

  String get formattedRange {
    return '\$${min.toStringAsFixed(2)} - \$${max.toStringAsFixed(2)} $currency';
  }

  double get averagePrice {
    return (min + max) / 2;
  }

  String get formattedAverage {
    return '\$${averagePrice.toStringAsFixed(2)} $currency';
  }
}

/// 价格因素说明
class PriceFactorExplanation {
  final String factorName;
  final String userChoice;
  final String impact;
  final double priceChange;

  const PriceFactorExplanation({
    required this.factorName,
    required this.userChoice,
    required this.impact,
    required this.priceChange,
  });
}

/// 需求评估模型
class ServiceAssessment {
  final String id;
  final String orderId;
  final String serviceId;
  final String providerId;
  final String userId;
  
  // 评估信息
  final AssessmentType assessmentType;
  final AssessmentStatus status;
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  final Duration? actualDuration;
  
  // 用户需求
  final Map<String, dynamic> userRequirements;
  final List<String> userImages;
  final String? userNotes;
  
  // 服务商评估
  final Map<String, dynamic>? providerAssessment;
  final List<String>? providerImages;
  final String? providerNotes;
  final double? assessedPrice;
  final Map<String, dynamic>? pricingBreakdown;
  
  // 评估结果
  final AssessmentResult? result;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceAssessment({
    required this.id,
    required this.orderId,
    required this.serviceId,
    required this.providerId,
    required this.userId,
    required this.assessmentType,
    required this.status,
    this.scheduledAt,
    this.completedAt,
    this.actualDuration,
    required this.userRequirements,
    this.userImages = const [],
    this.userNotes,
    this.providerAssessment,
    this.providerImages,
    this.providerNotes,
    this.assessedPrice,
    this.pricingBreakdown,
    this.result,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceAssessment.fromJson(Map<String, dynamic> json) {
    return ServiceAssessment(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      serviceId: json['service_id'] as String,
      providerId: json['provider_id'] as String,
      userId: json['user_id'] as String,
      assessmentType: AssessmentType.values.firstWhere(
        (e) => e.name == json['assessment_type'],
        orElse: () => AssessmentType.remote,
      ),
      status: AssessmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AssessmentStatus.pending,
      ),
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      actualDuration: json['actual_duration'] != null
          ? Duration(minutes: json['actual_duration'] as int)
          : null,
      userRequirements: Map<String, dynamic>.from(json['user_requirements'] ?? {}),
      userImages: List<String>.from(json['user_images'] ?? []),
      userNotes: json['user_notes'] as String?,
      providerAssessment: json['provider_assessment'] as Map<String, dynamic>?,
      providerImages: json['provider_images'] != null
          ? List<String>.from(json['provider_images'])
          : null,
      providerNotes: json['provider_notes'] as String?,
      assessedPrice: (json['assessed_price'] as num?)?.toDouble(),
      pricingBreakdown: json['pricing_breakdown'] as Map<String, dynamic>?,
      result: json['result'] != null
          ? AssessmentResult.fromJson(json['result'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'service_id': serviceId,
      'provider_id': providerId,
      'user_id': userId,
      'assessment_type': assessmentType.name,
      'status': status.name,
      'scheduled_at': scheduledAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'actual_duration': actualDuration?.inMinutes,
      'user_requirements': userRequirements,
      'user_images': userImages,
      'user_notes': userNotes,
      'provider_assessment': providerAssessment,
      'provider_images': providerImages,
      'provider_notes': providerNotes,
      'assessed_price': assessedPrice,
      'pricing_breakdown': pricingBreakdown,
      'result': result?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 获取状态颜色
  Color get statusColor {
    switch (status) {
      case AssessmentStatus.pending:
        return Colors.orange;
      case AssessmentStatus.scheduled:
        return Colors.blue;
      case AssessmentStatus.inProgress:
        return Colors.purple;
      case AssessmentStatus.completed:
        return Colors.green;
      case AssessmentStatus.cancelled:
        return Colors.grey;
    }
  }

  /// 获取状态描述
  String get statusDescription {
    switch (status) {
      case AssessmentStatus.pending:
        return '待评估';
      case AssessmentStatus.scheduled:
        return '已预约';
      case AssessmentStatus.inProgress:
        return '评估中';
      case AssessmentStatus.completed:
        return '已完成';
      case AssessmentStatus.cancelled:
        return '已取消';
    }
  }
}

/// 评估结果模型
class AssessmentResult {
  final double finalPrice;
  final String currency;
  final Map<String, dynamic> pricingDetails;
  final Duration estimatedDuration;
  final DateTime? earliestStartDate;
  final DateTime? latestStartDate;
  final List<String> includedServices;
  final List<String> additionalOptions;
  final String? specialNotes;

  const AssessmentResult({
    required this.finalPrice,
    this.currency = 'CAD',
    required this.pricingDetails,
    required this.estimatedDuration,
    this.earliestStartDate,
    this.latestStartDate,
    this.includedServices = const [],
    this.additionalOptions = const [],
    this.specialNotes,
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      finalPrice: (json['final_price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'CAD',
      pricingDetails: Map<String, dynamic>.from(json['pricing_details'] ?? {}),
      estimatedDuration: Duration(minutes: json['estimated_duration'] as int),
      earliestStartDate: json['earliest_start_date'] != null
          ? DateTime.parse(json['earliest_start_date'] as String)
          : null,
      latestStartDate: json['latest_start_date'] != null
          ? DateTime.parse(json['latest_start_date'] as String)
          : null,
      includedServices: List<String>.from(json['included_services'] ?? []),
      additionalOptions: List<String>.from(json['additional_options'] ?? []),
      specialNotes: json['special_notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'final_price': finalPrice,
      'currency': currency,
      'pricing_details': pricingDetails,
      'estimated_duration': estimatedDuration.inMinutes,
      'earliest_start_date': earliestStartDate?.toIso8601String(),
      'latest_start_date': latestStartDate?.toIso8601String(),
      'included_services': includedServices,
      'additional_options': additionalOptions,
      'special_notes': specialNotes,
    };
  }

  /// 获取格式化价格
  String get formattedPrice {
    return '\$${finalPrice.toStringAsFixed(2)} $currency';
  }
}

/// 服务报价模型
class ServiceQuote {
  final String id;
  final String orderId;
  final String serviceId;
  final String providerId;
  final String userId;
  
  // 报价基本信息
  final String quoteNumber;
  final QuoteStatus status;
  final QuoteType quoteType;
  final int revisionNumber;
  
  // 价格信息
  final double totalPrice;
  final String currency;
  final Map<String, dynamic> pricingBreakdown;
  final double? depositAmount;
  final List<PaymentMilestone> paymentMilestones;
  
  // 服务信息
  final String serviceDescription;
  final Duration estimatedDuration;
  final DateTime? proposedStartDate;
  final DateTime? proposedEndDate;
  final List<String> includedServices;
  final List<QuoteOption> additionalOptions;
  
  // 条款信息
  final Map<String, dynamic> terms;
  final DateTime validUntil;
  final String? cancellationPolicy;
  final String? refundPolicy;
  
  // 沟通记录
  final List<QuoteMessage> messages;
  final List<String> attachments;
  
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastUpdatedBy;

  const ServiceQuote({
    required this.id,
    required this.orderId,
    required this.serviceId,
    required this.providerId,
    required this.userId,
    required this.quoteNumber,
    required this.status,
    required this.quoteType,
    this.revisionNumber = 1,
    required this.totalPrice,
    this.currency = 'CAD',
    required this.pricingBreakdown,
    this.depositAmount,
    this.paymentMilestones = const [],
    required this.serviceDescription,
    required this.estimatedDuration,
    this.proposedStartDate,
    this.proposedEndDate,
    this.includedServices = const [],
    this.additionalOptions = const [],
    this.terms = const {},
    required this.validUntil,
    this.cancellationPolicy,
    this.refundPolicy,
    this.messages = const [],
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
    this.lastUpdatedBy,
  });

  factory ServiceQuote.fromJson(Map<String, dynamic> json) {
    return ServiceQuote(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      serviceId: json['service_id'] as String,
      providerId: json['provider_id'] as String,
      userId: json['user_id'] as String,
      quoteNumber: json['quote_number'] as String,
      status: QuoteStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => QuoteStatus.draft,
      ),
      quoteType: QuoteType.values.firstWhere(
        (e) => e.name == json['quote_type'],
        orElse: () => QuoteType.standard,
      ),
      revisionNumber: json['revision_number'] as int? ?? 1,
      totalPrice: (json['total_price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'CAD',
      pricingBreakdown: Map<String, dynamic>.from(json['pricing_breakdown'] ?? {}),
      depositAmount: (json['deposit_amount'] as num?)?.toDouble(),
      paymentMilestones: (json['payment_milestones'] as List<dynamic>?)
          ?.map((milestone) => PaymentMilestone.fromJson(milestone as Map<String, dynamic>))
          .toList() ?? [],
      serviceDescription: json['service_description'] as String,
      estimatedDuration: Duration(minutes: json['estimated_duration'] as int),
      proposedStartDate: json['proposed_start_date'] != null
          ? DateTime.parse(json['proposed_start_date'] as String)
          : null,
      proposedEndDate: json['proposed_end_date'] != null
          ? DateTime.parse(json['proposed_end_date'] as String)
          : null,
      includedServices: List<String>.from(json['included_services'] ?? []),
      additionalOptions: (json['additional_options'] as List<dynamic>?)
          ?.map((option) => QuoteOption.fromJson(option as Map<String, dynamic>))
          .toList() ?? [],
      terms: Map<String, dynamic>.from(json['terms'] ?? {}),
      validUntil: DateTime.parse(json['valid_until'] as String),
      cancellationPolicy: json['cancellation_policy'] as String?,
      refundPolicy: json['refund_policy'] as String?,
      messages: (json['messages'] as List<dynamic>?)
          ?.map((message) => QuoteMessage.fromJson(message as Map<String, dynamic>))
          .toList() ?? [],
      attachments: List<String>.from(json['attachments'] ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastUpdatedBy: json['last_updated_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'service_id': serviceId,
      'provider_id': providerId,
      'user_id': userId,
      'quote_number': quoteNumber,
      'status': status.name,
      'quote_type': quoteType.name,
      'revision_number': revisionNumber,
      'total_price': totalPrice,
      'currency': currency,
      'pricing_breakdown': pricingBreakdown,
      'deposit_amount': depositAmount,
      'payment_milestones': paymentMilestones.map((m) => m.toJson()).toList(),
      'service_description': serviceDescription,
      'estimated_duration': estimatedDuration.inMinutes,
      'proposed_start_date': proposedStartDate?.toIso8601String(),
      'proposed_end_date': proposedEndDate?.toIso8601String(),
      'included_services': includedServices,
      'additional_options': additionalOptions.map((o) => o.toJson()).toList(),
      'terms': terms,
      'valid_until': validUntil.toIso8601String(),
      'cancellation_policy': cancellationPolicy,
      'refund_policy': refundPolicy,
      'messages': messages.map((m) => m.toJson()).toList(),
      'attachments': attachments,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_updated_by': lastUpdatedBy,
    };
  }

  /// 获取格式化的报价号
  String get formattedQuoteNumber {
    return '#$quoteNumber';
  }

  /// 获取格式化的总价
  String get formattedTotalPrice {
    return '\$${totalPrice.toStringAsFixed(2)} $currency';
  }

  /// 获取状态颜色
  Color get statusColor {
    switch (status) {
      case QuoteStatus.draft:
        return Colors.grey;
      case QuoteStatus.sent:
        return Colors.blue;
      case QuoteStatus.viewed:
        return Colors.lightBlue;
      case QuoteStatus.underReview:
        return Colors.orange;
      case QuoteStatus.revised:
        return Colors.purple;
      case QuoteStatus.accepted:
        return Colors.green;
      case QuoteStatus.rejected:
        return Colors.red;
      case QuoteStatus.expired:
        return Colors.brown;
      case QuoteStatus.cancelled:
        return Colors.grey;
    }
  }

  /// 是否已过期
  bool get isExpired {
    return DateTime.now().isAfter(validUntil);
  }

  /// 是否可以修改
  bool get canBeRevised {
    return [QuoteStatus.sent, QuoteStatus.viewed, QuoteStatus.underReview].contains(status) &&
           !isExpired;
  }
}

/// 支付里程碑模型
class PaymentMilestone {
  final String id;
  final String name;
  final String description;
  final double amount;
  final double percentage;
  final DateTime? dueDate;
  final String? triggerCondition;
  final PaymentMilestoneStatus status;

  const PaymentMilestone({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.percentage,
    this.dueDate,
    this.triggerCondition,
    this.status = PaymentMilestoneStatus.pending,
  });

  factory PaymentMilestone.fromJson(Map<String, dynamic> json) {
    return PaymentMilestone(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      triggerCondition: json['trigger_condition'] as String?,
      status: PaymentMilestoneStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentMilestoneStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'amount': amount,
      'percentage': percentage,
      'due_date': dueDate?.toIso8601String(),
      'trigger_condition': triggerCondition,
      'status': status.name,
    };
  }

  /// 获取格式化金额
  String get formattedAmount {
    return '\$${amount.toStringAsFixed(2)}';
  }
}

/// 报价选项模型
class QuoteOption {
  final String id;
  final String name;
  final String description;
  final double price;
  final bool isRequired;
  final bool isSelected;
  final int? quantity;

  const QuoteOption({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.isRequired = false,
    this.isSelected = false,
    this.quantity,
  });

  factory QuoteOption.fromJson(Map<String, dynamic> json) {
    return QuoteOption(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      isRequired: json['is_required'] as bool? ?? false,
      isSelected: json['is_selected'] as bool? ?? false,
      quantity: json['quantity'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'is_required': isRequired,
      'is_selected': isSelected,
      'quantity': quantity,
    };
  }

  /// 获取总价
  double get totalPrice {
    return price * (quantity ?? 1);
  }

  /// 获取格式化价格
  String get formattedPrice {
    return '\$${price.toStringAsFixed(2)}';
  }
}

/// 报价消息模型
class QuoteMessage {
  final String id;
  final String senderId;
  final String senderType;     // 'user', 'provider', 'system'
  final String message;
  final List<String>? attachments;
  final DateTime createdAt;

  const QuoteMessage({
    required this.id,
    required this.senderId,
    required this.senderType,
    required this.message,
    this.attachments,
    required this.createdAt,
  });

  factory QuoteMessage.fromJson(Map<String, dynamic> json) {
    return QuoteMessage(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      senderType: json['sender_type'] as String,
      message: json['message'] as String,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'sender_type': senderType,
      'message': message,
      'attachments': attachments,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 是否为用户发送的消息
  bool get isFromUser {
    return senderType == 'user';
  }

  /// 是否为服务商发送的消息
  bool get isFromProvider {
    return senderType == 'provider';
  }

  /// 是否为系统消息
  bool get isFromSystem {
    return senderType == 'system';
  }
}
