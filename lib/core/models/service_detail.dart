import 'package:get/get.dart';

// 服务详情模型
class ServiceDetail {
  final String id;
  final String serviceId;
  final String category;
  final Map<String, String> name;           // jsonb: 国际化名称
  final String? subCategory;
  final bool isAvailable;
  final int sortOrder;
  final int? currentStock;
  final int? maxStock;
  final Map<String, dynamic> attributes;    // jsonb: 自定义属性
  final Map<String, dynamic> businessRules; // jsonb: 业务规则
  final String? pricingType;
  final double? price;
  final String? currency;
  final String? duration;
  final String? unit;
  final List<String>? images;
  final List<String>? videos;
  final List<String>? tags;
  final List<String>? serviceAreaCodes;
  final double? platformServiceFeeRate;
  final double? minPlatformServiceFee;
  final Map<String, dynamic>? extraData;
  final DateTime? promotionStart;
  final DateTime? promotionEnd;
  final int? viewCount;
  final int? favoriteCount;
  final int? orderCount;
  final String? verificationStatus;
  final List<String>? documents;
  final String? type;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceDetail({
    required this.id,
    required this.serviceId,
    required this.category,
    required this.name,
    this.subCategory,
    required this.isAvailable,
    required this.sortOrder,
    this.currentStock,
    this.maxStock,
    required this.attributes,
    required this.businessRules,
    this.pricingType,
    this.price,
    this.currency,
    this.duration,
    this.unit,
    this.images,
    this.videos,
    this.tags,
    this.serviceAreaCodes,
    this.platformServiceFeeRate,
    this.minPlatformServiceFee,
    this.extraData,
    this.promotionStart,
    this.promotionEnd,
    this.viewCount,
    this.favoriteCount,
    this.orderCount,
    this.verificationStatus,
    this.documents,
    this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    return ServiceDetail(
      id: json['id'],
      serviceId: json['service_id'],
      category: json['category'] ?? '',
      name: Map<String, String>.from(json['name'] ?? {}),
      subCategory: json['sub_category'],
      isAvailable: json['is_available'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
      currentStock: json['current_stock'],
      maxStock: json['max_stock'],
      attributes: Map<String, dynamic>.from(json['attributes'] ?? {}),
      businessRules: Map<String, dynamic>.from(json['business_rules'] ?? {}),
      pricingType: json['pricing_type'],
      price: json['price']?.toDouble(),
      currency: json['currency'],
      duration: json['duration'],
      unit: json['unit'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      videos: json['videos'] != null ? List<String>.from(json['videos']) : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      serviceAreaCodes: json['service_area_codes'] != null ? List<String>.from(json['service_area_codes']) : null,
      platformServiceFeeRate: json['platform_service_fee_rate']?.toDouble(),
      minPlatformServiceFee: json['min_platform_service_fee']?.toDouble(),
      extraData: json['extra_data'] != null ? Map<String, dynamic>.from(json['extra_data']) : null,
      promotionStart: json['promotion_start'] != null ? DateTime.parse(json['promotion_start']) : null,
      promotionEnd: json['promotion_end'] != null ? DateTime.parse(json['promotion_end']) : null,
      viewCount: json['view_count'],
      favoriteCount: json['favorite_count'],
      orderCount: json['order_count'],
      verificationStatus: json['verification_status'],
      documents: json['documents'] != null ? List<String>.from(json['documents']) : null,
      type: json['type'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'category': category,
      'name': name,
      'sub_category': subCategory,
      'is_available': isAvailable,
      'sort_order': sortOrder,
      'current_stock': currentStock,
      'max_stock': maxStock,
      'attributes': attributes,
      'business_rules': businessRules,
      'pricing_type': pricingType,
      'price': price,
      'currency': currency,
      'duration': duration,
      'unit': unit,
      'images': images,
      'videos': videos,
      'tags': tags,
      'service_area_codes': serviceAreaCodes,
      'platform_service_fee_rate': platformServiceFeeRate,
      'min_platform_service_fee': minPlatformServiceFee,
      'extra_data': extraData,
      'promotion_start': promotionStart?.toIso8601String(),
      'promotion_end': promotionEnd?.toIso8601String(),
      'view_count': viewCount,
      'favorite_count': favoriteCount,
      'order_count': orderCount,
      'verification_status': verificationStatus,
      'documents': documents,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // 获取本地化名称
  String getLocalizedName(String languageCode) {
    return name[languageCode] ?? name['en'] ?? name.values.firstOrNull ?? 'Unknown';
  }

  // 获取主要图片
  String? get mainImage => images?.isNotEmpty == true ? images!.first : null;

  // 获取价格显示
  String get priceDisplay {
    if (price == null) return 'Price on request';
    return '${currency ?? 'CAD'} ${price!.toStringAsFixed(2)}';
  }

  // 获取库存状态
  String get stockStatus {
    if (maxStock == null) return 'Unlimited';
    if (currentStock == null) return 'Unknown';
    if (currentStock! <= 0) return 'Out of stock';
    if (currentStock! < maxStock! * 0.2) return 'Low stock';
    return 'In stock';
  }

  // 检查是否有库存
  bool get hasStock {
    if (maxStock == null) return true;
    if (currentStock == null) return false;
    return currentStock! > 0;
  }

  // 获取库存百分比
  double get stockPercentage {
    if (maxStock == null || currentStock == null) return 0.0;
    if (maxStock! <= 0) return 0.0;
    return (currentStock! / maxStock!) * 100;
  }

  // 检查是否在促销期间
  bool get isOnPromotion {
    if (promotionStart == null || promotionEnd == null) return false;
    final now = DateTime.now();
    return now.isAfter(promotionStart!) && now.isBefore(promotionEnd!);
  }

  // 获取属性值
  dynamic getAttribute(String key) {
    return attributes[key];
  }

  // 获取业务规则值
  dynamic getBusinessRule(String key) {
    return businessRules[key];
  }

  // 复制并修改
  ServiceDetail copyWith({
    String? id,
    String? serviceId,
    String? category,
    Map<String, String>? name,
    String? subCategory,
    bool? isAvailable,
    int? sortOrder,
    int? currentStock,
    int? maxStock,
    Map<String, dynamic>? attributes,
    Map<String, dynamic>? businessRules,
    String? pricingType,
    double? price,
    String? currency,
    String? duration,
    String? unit,
    List<String>? images,
    List<String>? videos,
    List<String>? tags,
    List<String>? serviceAreaCodes,
    double? platformServiceFeeRate,
    double? minPlatformServiceFee,
    Map<String, dynamic>? extraData,
    DateTime? promotionStart,
    DateTime? promotionEnd,
    int? viewCount,
    int? favoriteCount,
    int? orderCount,
    String? verificationStatus,
    List<String>? documents,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceDetail(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      category: category ?? this.category,
      name: name ?? this.name,
      subCategory: subCategory ?? this.subCategory,
      isAvailable: isAvailable ?? this.isAvailable,
      sortOrder: sortOrder ?? this.sortOrder,
      currentStock: currentStock ?? this.currentStock,
      maxStock: maxStock ?? this.maxStock,
      attributes: attributes ?? this.attributes,
      businessRules: businessRules ?? this.businessRules,
      pricingType: pricingType ?? this.pricingType,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      duration: duration ?? this.duration,
      unit: unit ?? this.unit,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      tags: tags ?? this.tags,
      serviceAreaCodes: serviceAreaCodes ?? this.serviceAreaCodes,
      platformServiceFeeRate: platformServiceFeeRate ?? this.platformServiceFeeRate,
      minPlatformServiceFee: minPlatformServiceFee ?? this.minPlatformServiceFee,
      extraData: extraData ?? this.extraData,
      promotionStart: promotionStart ?? this.promotionStart,
      promotionEnd: promotionEnd ?? this.promotionEnd,
      viewCount: viewCount ?? this.viewCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      orderCount: orderCount ?? this.orderCount,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      documents: documents ?? this.documents,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceDetail && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ServiceDetail(id: $id, name: ${name['en']}, category: $category, available: $isAvailable)';
  }
}
