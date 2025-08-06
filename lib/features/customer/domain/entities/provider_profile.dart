/// 服务提供商档案实体类
class ProviderProfile {
  final String id;
  final String name;
  final String? description;
  final String? avatar;
  final String? phone;
  final String? email;
  final String? address;
  final double? rating;
  final int? reviewCount;
  final int? completedOrders;
  final String? businessLicense;
  final bool isVerified;
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata;

  ProviderProfile({
    required this.id,
    required this.name,
    this.description,
    this.avatar,
    this.phone,
    this.email,
    this.address,
    this.rating,
    this.reviewCount,
    this.completedOrders,
    this.businessLicense,
    this.isVerified = false,
    this.createdAt,
    this.metadata,
  });

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    return ProviderProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      avatar: json['avatar'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'],
      completedOrders: json['completedOrders'],
      businessLicense: json['businessLicense'],
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatar': avatar,
      'phone': phone,
      'email': email,
      'address': address,
      'rating': rating,
      'reviewCount': reviewCount,
      'completedOrders': completedOrders,
      'businessLicense': businessLicense,
      'isVerified': isVerified,
      'createdAt': createdAt?.toIso8601String(),
      'metadata': metadata,
    };
  }
} 