// import 'package:get/get.dart'; // 未使用的导入

// 服务模型
class Service {
  final String id;
  final Map<String, String> title; // jsonb: 国际化标题
  final Map<String, String> description; // jsonb: 国际化描述
  final double price;
  final String currency;
  final String pricingType;
  final String categoryId;
  final String categoryLevel1Id;
  final String categoryLevel2Id;
  final String providerId;
  final String serviceDeliveryMethod;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> images;
  final List<String> imagesUrl;
  final double rating;
  final int reviewCount;
  final bool isActive;
  final Map<String, dynamic> serviceDetailsJson;
  final double? latitude;
  final double? longitude;
  final List<String> serviceAreaCodes;
  final List<String> tags;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.pricingType,
    required this.categoryId,
    required this.categoryLevel1Id,
    required this.categoryLevel2Id,
    required this.providerId,
    required this.serviceDeliveryMethod,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
    required this.imagesUrl,
    required this.rating,
    required this.reviewCount,
    required this.isActive,
    required this.serviceDetailsJson,
    this.latitude,
    this.longitude,
    required this.serviceAreaCodes,
    required this.tags,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      title: Map<String, String>.from(json['title'] ?? {}),
      description: Map<String, String>.from(json['description'] ?? {}),
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'CAD',
      pricingType: json['pricing_type'] ?? 'fixed_price',
      categoryId: (json['category_id'] ?? '').toString(),
      categoryLevel1Id: (json['category_level1_id'] ?? '').toString(),
      categoryLevel2Id: (json['category_level2_id'] ?? '').toString(),
      providerId: json['provider_id'] ?? '',
      serviceDeliveryMethod: json['service_delivery_method'] ?? 'onsite',
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      images: List<String>.from(json['images'] ?? []),
      imagesUrl: List<String>.from(json['images_url'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      isActive: json['is_active'] ?? true,
      serviceDetailsJson: json['service_details_json'] ?? {},
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      serviceAreaCodes: List<String>.from(json['service_area_codes'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'pricing_type': pricingType,
      'category_id': categoryId,
      'category_level1_id': categoryLevel1Id,
      'category_level2_id': categoryLevel2Id,
      'provider_id': providerId,
      'service_delivery_method': serviceDeliveryMethod,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'images': images,
      'images_url': imagesUrl,
      'rating': rating,
      'review_count': reviewCount,
      'is_active': isActive,
      'service_details_json': serviceDetailsJson,
      'latitude': latitude,
      'longitude': longitude,
      'service_area_codes': serviceAreaCodes,
      'tags': tags,
    };
  }

  // 获取本地化标题
  String getLocalizedTitle(String languageCode) {
    return title[languageCode] ??
        title['en'] ??
        title.values.firstOrNull ??
        'Unknown';
  }

  // 获取本地化描述
  String getLocalizedDescription(String languageCode) {
    return description[languageCode] ??
        description['en'] ??
        description.values.firstOrNull ??
        '';
  }

  // 获取主要图片
  String? get mainImage => images.isNotEmpty
      ? images.first
      : imagesUrl.isNotEmpty
          ? imagesUrl.first
          : null;

  // 获取价格显示
  String get priceDisplay => '$currency ${price.toStringAsFixed(2)}';

  // 获取评分显示
  String get ratingDisplay => rating.toStringAsFixed(1);

  // 复制并修改
  Service copyWith({
    String? id,
    Map<String, String>? title,
    Map<String, String>? description,
    double? price,
    String? currency,
    String? pricingType,
    String? categoryId,
    String? categoryLevel1Id,
    String? categoryLevel2Id,
    String? providerId,
    String? serviceDeliveryMethod,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? images,
    List<String>? imagesUrl,
    double? rating,
    int? reviewCount,
    bool? isActive,
    Map<String, dynamic>? serviceDetailsJson,
    double? latitude,
    double? longitude,
    List<String>? serviceAreaCodes,
    List<String>? tags,
  }) {
    return Service(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      pricingType: pricingType ?? this.pricingType,
      categoryId: categoryId ?? this.categoryId,
      categoryLevel1Id: categoryLevel1Id ?? this.categoryLevel1Id,
      categoryLevel2Id: categoryLevel2Id ?? this.categoryLevel2Id,
      providerId: providerId ?? this.providerId,
      serviceDeliveryMethod:
          serviceDeliveryMethod ?? this.serviceDeliveryMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
      imagesUrl: imagesUrl ?? this.imagesUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isActive: isActive ?? this.isActive,
      serviceDetailsJson: serviceDetailsJson ?? this.serviceDetailsJson,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      serviceAreaCodes: serviceAreaCodes ?? this.serviceAreaCodes,
      tags: tags ?? this.tags,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Service && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Service(id: $id, title: ${title['en']}, price: $price, rating: $rating)';
  }
}
