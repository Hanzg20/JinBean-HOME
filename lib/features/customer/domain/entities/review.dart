/// 评价实体类
class Review {
  final String id;
  final String serviceId;
  final String userId;
  final String? userName;
  final String? userAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String>? images;
  final bool isVerified;
  final Map<String, dynamic>? metadata;

  Review({
    required this.id,
    required this.serviceId,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.images,
    this.isVerified = false,
    this.metadata,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      serviceId: json['serviceId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      images: json['images'] != null 
          ? List<String>.from(json['images'])
          : null,
      isVerified: json['isVerified'] ?? false,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'images': images,
      'isVerified': isVerified,
      'metadata': metadata,
    };
  }
} 