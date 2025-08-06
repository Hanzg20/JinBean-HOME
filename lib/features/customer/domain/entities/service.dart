/// 服务实体类
class Service {
  final String id;
  final String title;
  final String description;
  final double? price;
  final String? currency;
  final String? pricingType;
  final String? categoryId;
  final String? categoryLevel2Id;
  final String? providerId;
  final String? serviceDeliveryMethod;
  final DateTime? createdAt;
  final List<String>? images;
  final double? rating;
  final int? reviewCount;
  final bool? isActive;
  final Map<String, dynamic>? serviceDetailsJson;
  final double? latitude;
  final double? longitude;

  Service({
    required this.id,
    required this.title,
    required this.description,
    this.price,
    this.currency,
    this.pricingType,
    this.categoryId,
    this.categoryLevel2Id,
    this.providerId,
    this.serviceDeliveryMethod,
    this.createdAt,
    this.images,
    this.rating,
    this.reviewCount,
    this.isActive,
    this.serviceDetailsJson,
    this.latitude,
    this.longitude,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toDouble(),
      currency: json['currency'],
      pricingType: json['pricingType'],
      categoryId: json['categoryId'],
      categoryLevel2Id: json['categoryLevel2Id'],
      providerId: json['providerId'],
      serviceDeliveryMethod: json['serviceDeliveryMethod'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      images: json['images'] != null 
          ? List<String>.from(json['images'])
          : null,
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'],
      isActive: json['isActive'],
      serviceDetailsJson: json['serviceDetailsJson'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'pricingType': pricingType,
      'categoryId': categoryId,
      'categoryLevel2Id': categoryLevel2Id,
      'providerId': providerId,
      'serviceDeliveryMethod': serviceDeliveryMethod,
      'createdAt': createdAt?.toIso8601String(),
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'isActive': isActive,
      'serviceDetailsJson': serviceDetailsJson,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
} 