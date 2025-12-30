import 'package:flutter/foundation.dart';
import '../../../../core/utils/image_parser.dart';

/// 服务实体类
class Service {
  final String id;
  final String title;
  final String description;
  final double? price;
  final String? currency;
  final String? pricingType;
  final String? categoryId;
  final String? categoryLevel1Id;
  final String? categoryLevel2Id;
  final String? providerId;
  final String? serviceDeliveryMethod;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String>? images;
  final List<String>? images_url;
  final double? rating;
  final int? reviewCount;
  final bool? isActive;
  final Map<String, dynamic>? serviceDetailsJson;
  final double? latitude;
  final double? longitude;
  final List<String>? serviceAreaCodes;
  final List<String>? tags;

  Service({
    required this.id,
    required this.title,
    required this.description,
    this.price,
    this.currency,
    this.pricingType,
    this.categoryId,
    this.categoryLevel1Id,
    this.categoryLevel2Id,
    this.providerId,
    this.serviceDeliveryMethod,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.images,
    this.images_url,
    this.rating,
    this.reviewCount,
    this.isActive,
    this.serviceDetailsJson,
    this.latitude,
    this.longitude,
    this.serviceAreaCodes,
    this.tags,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    // 使用ImageParser解析并验证图片URL
    final imagesList = ImageParser.parseImagesUrl(json['images_url']);

    if (kDebugMode && imagesList != null) {
      debugPrint('✓ Service[${json['id']}] loaded with ${imagesList.length} images');
    }

    return Service(
      id: json['id'] ?? '',
      title: json['title']?['en'] ?? json['title'] ?? '',
      description: json['description']?['en'] ?? json['description'] ?? '',
      price: json['price']?.toDouble(),
      currency: json['currency'],
      pricingType: json['pricingType'],
      categoryId: json['category_level1_id']?.toString(),
      categoryLevel1Id: json['category_level1_id']?.toString(),
      categoryLevel2Id: json['category_level2_id']?.toString(),
      providerId: json['provider_id']?.toString(),
      serviceDeliveryMethod: json['service_delivery_method'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      images: imagesList,
      images_url: imagesList,
      rating: json['average_rating']?.toDouble(),
      reviewCount: json['review_count'],
      isActive: json['status'] == 'active',
      serviceDetailsJson: json['serviceDetailsJson'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      serviceAreaCodes: json['service_area_codes'] != null
          ? List<String>.from(json['service_area_codes'])
          : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
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
      'categoryLevel1Id': categoryLevel1Id,
      'categoryLevel2Id': categoryLevel2Id,
      'providerId': providerId,
      'serviceDeliveryMethod': serviceDeliveryMethod,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'images': images,
      'images_url': images_url,
      'rating': rating,
      'reviewCount': reviewCount,
      'isActive': isActive,
      'serviceDetailsJson': serviceDetailsJson,
      'latitude': latitude,
      'longitude': longitude,
      'serviceAreaCodes': serviceAreaCodes,
      'tags': tags,
    };
  }
}
