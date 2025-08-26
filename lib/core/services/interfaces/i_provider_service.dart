import 'package:get/get.dart';

// 服务商模型
class Provider {
  final String id;
  final Map<String, String> displayName;    // jsonb: 国际化显示名称
  final Map<String, String> bio;            // jsonb: 国际化简介
  final String? avatarUrl;
  final String? phone;
  final String? email;
  final String? businessAddress;
  final String? providerType;               // 'individual' or 'corporate'
  final String? status;
  final double? rating;
  final int? reviewCount;
  final int? orderCount;
  final bool? isVerified;
  final List<String>? serviceCategories;
  final List<String>? serviceAreaCodes;
  final Map<String, dynamic>? businessHours;
  final Map<String, dynamic>? contactInfo;
  final Map<String, dynamic>? verificationDocuments;
  final DateTime createdAt;
  final DateTime updatedAt;

  Provider({
    required this.id,
    required this.displayName,
    required this.bio,
    this.avatarUrl,
    this.phone,
    this.email,
    this.businessAddress,
    this.providerType,
    this.status,
    this.rating,
    this.reviewCount,
    this.orderCount,
    this.isVerified,
    this.serviceCategories,
    this.serviceAreaCodes,
    this.businessHours,
    this.contactInfo,
    this.verificationDocuments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id'],
      displayName: Map<String, String>.from(json['display_name'] ?? {}),
      bio: Map<String, String>.from(json['bio'] ?? {}),
      avatarUrl: json['avatar_url'],
      phone: json['phone'],
      email: json['email'],
      businessAddress: json['business_address'],
      providerType: json['provider_type'],
      status: json['status'],
      rating: json['rating']?.toDouble(),
      reviewCount: json['review_count'],
      orderCount: json['order_count'],
      isVerified: json['is_verified'],
      serviceCategories: json['service_categories'] != null ? List<String>.from(json['service_categories']) : null,
      serviceAreaCodes: json['service_area_codes'] != null ? List<String>.from(json['service_area_codes']) : null,
      businessHours: json['business_hours'] != null ? Map<String, dynamic>.from(json['business_hours']) : null,
      contactInfo: json['contact_info'] != null ? Map<String, dynamic>.from(json['contact_info']) : null,
      verificationDocuments: json['verification_documents'] != null ? Map<String, dynamic>.from(json['verification_documents']) : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'bio': bio,
      'avatar_url': avatarUrl,
      'phone': phone,
      'email': email,
      'business_address': businessAddress,
      'provider_type': providerType,
      'status': status,
      'rating': rating,
      'review_count': reviewCount,
      'order_count': orderCount,
      'is_verified': isVerified,
      'service_categories': serviceCategories,
      'service_area_codes': serviceAreaCodes,
      'business_hours': businessHours,
      'contact_info': contactInfo,
      'verification_documents': verificationDocuments,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// 服务商查询参数
class ProviderQueryParams {
  final String? providerType;
  final String? status;
  final List<String>? serviceCategories;
  final List<String>? serviceAreaCodes;
  final bool? isVerified;
  final double? minRating;
  final String? searchQuery;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final bool? sortAscending;

  ProviderQueryParams({
    this.providerType,
    this.status,
    this.serviceCategories,
    this.serviceAreaCodes,
    this.isVerified,
    this.minRating,
    this.searchQuery,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortAscending,
  });

  Map<String, dynamic> toJson() {
    return {
      'provider_type': providerType,
      'status': status,
      'service_categories': serviceCategories,
      'service_area_codes': serviceAreaCodes,
      'is_verified': isVerified,
      'min_rating': minRating,
      'search_query': searchQuery,
      'limit': limit,
      'offset': offset,
      'sort_by': sortBy,
      'sort_ascending': sortAscending,
    };
  }
}

// 服务商服务接口
abstract class IProviderService {
  /// 初始化服务
  Future<void> initialize();
  
  /// 根据ID获取服务商
  Future<Provider?> getProviderById(String providerId);
  
  /// 根据查询参数获取服务商列表
  Future<List<Provider>> getProviders(ProviderQueryParams params);
  
  /// 搜索服务商
  Future<List<Provider>> searchProviders(String query, {int limit = 20});
  
  /// 获取推荐服务商
  Future<List<Provider>> getRecommendedProviders({int limit = 10});
  
  /// 获取附近服务商
  Future<List<Provider>> getNearbyProviders(double latitude, double longitude, {double radius = 10.0, int limit = 20});
  
  /// 获取服务商统计信息
  Future<Map<String, dynamic>> getProviderStatistics(String providerId);
  
  /// 更新服务商信息
  Future<bool> updateProvider(Provider provider);
  
  /// 更新服务商状态
  Future<bool> updateProviderStatus(String providerId, String status);
  
  /// 验证服务商
  Future<bool> verifyProvider(String providerId);
  
  /// 获取服务商服务列表
  Future<List<dynamic>> getProviderServices(String providerId, {int limit = 20});
  
  /// 获取服务商评价
  Future<List<Review>> getProviderReviews(String providerId, {int limit = 20});
  
  /// 刷新服务商缓存
  Future<void> refreshCache(String providerId);
  
  /// 清除服务商缓存
  Future<void> clearCache(String providerId);
}

// 临时引用，稍后会创建完整模型
class Review {
  final String id;
  final String userId;
  final String serviceId;
  final String providerId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.providerId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['user_id'],
      serviceId: json['service_id'],
      providerId: json['provider_id'],
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
