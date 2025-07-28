// 点评系统数据模型
// 支持多语言、评分、标签、匿名、回复等功能

import 'package:flutter/material.dart';

// ========================================
// 1. 点评模型 (Review)
// ========================================
class Review {
  final String id;
  final String serviceId;
  final String userId;
  final String providerId;
  final String? orderId;
  
  // 评分和内容
  final double overallRating;
  final Map<String, String> content; // 多语言内容
  final bool isAnonymous;
  
  // 详细评分维度
  final double? qualityRating;
  final double? punctualityRating;
  final double? communicationRating;
  final double? valueRating;
  
  // 标签和图片
  final List<String> tags;
  final List<String> images;
  
  // 状态和统计
  final String status;
  final int helpfulCount;
  final int reportCount;
  
  // 时间戳
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // 关联数据
  final String? serviceTitle;
  final String? providerName;
  final String? userEmail;
  final Map<String, dynamic>? userMetadata;
  
  // 用户投票状态
  final bool? userVotedHelpful;
  
  Review({
    required this.id,
    required this.serviceId,
    required this.userId,
    required this.providerId,
    this.orderId,
    required this.overallRating,
    required this.content,
    this.isAnonymous = false,
    this.qualityRating,
    this.punctualityRating,
    this.communicationRating,
    this.valueRating,
    this.tags = const [],
    this.images = const [],
    this.status = 'active',
    this.helpfulCount = 0,
    this.reportCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.serviceTitle,
    this.providerName,
    this.userEmail,
    this.userMetadata,
    this.userVotedHelpful,
  });

  // 从JSON创建Review对象
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      serviceId: json['service_id'],
      userId: json['user_id'],
      providerId: json['provider_id'],
      orderId: json['order_id'],
      overallRating: (json['overall_rating'] as num).toDouble(),
      content: Map<String, String>.from(json['content'] ?? {}),
      isAnonymous: json['is_anonymous'] ?? false,
      qualityRating: json['quality_rating'] != null ? (json['quality_rating'] as num).toDouble() : null,
      punctualityRating: json['punctuality_rating'] != null ? (json['punctuality_rating'] as num).toDouble() : null,
      communicationRating: json['communication_rating'] != null ? (json['communication_rating'] as num).toDouble() : null,
      valueRating: json['value_rating'] != null ? (json['value_rating'] as num).toDouble() : null,
      tags: List<String>.from(json['tags'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      status: json['status'] ?? 'active',
      helpfulCount: json['helpful_count'] ?? 0,
      reportCount: json['report_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      serviceTitle: json['service_title']?['en'] ?? json['service_title']?['zh'],
      providerName: json['provider_name'],
      userEmail: json['user_email'],
      userMetadata: json['user_metadata'],
      userVotedHelpful: json['user_voted_helpful'],
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'user_id': userId,
      'provider_id': providerId,
      'order_id': orderId,
      'overall_rating': overallRating,
      'content': content,
      'is_anonymous': isAnonymous,
      'quality_rating': qualityRating,
      'punctuality_rating': punctualityRating,
      'communication_rating': communicationRating,
      'value_rating': valueRating,
      'tags': tags,
      'images': images,
      'status': status,
      'helpful_count': helpfulCount,
      'report_count': reportCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // 获取本地化内容
  String getLocalizedContent(String languageCode) {
    return content[languageCode] ?? content['en'] ?? content['zh'] ?? '';
  }

  // 获取显示名称
  String getDisplayName() {
    if (isAnonymous) {
      return 'Anonymous User';
    }
    return userEmail?.split('@').first ?? 'User';
  }

  // 复制并更新
  Review copyWith({
    String? id,
    String? serviceId,
    String? userId,
    String? providerId,
    String? orderId,
    double? overallRating,
    Map<String, String>? content,
    bool? isAnonymous,
    double? qualityRating,
    double? punctualityRating,
    double? communicationRating,
    double? valueRating,
    List<String>? tags,
    List<String>? images,
    String? status,
    int? helpfulCount,
    int? reportCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? serviceTitle,
    String? providerName,
    String? userEmail,
    Map<String, dynamic>? userMetadata,
    bool? userVotedHelpful,
  }) {
    return Review(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      userId: userId ?? this.userId,
      providerId: providerId ?? this.providerId,
      orderId: orderId ?? this.orderId,
      overallRating: overallRating ?? this.overallRating,
      content: content ?? this.content,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      qualityRating: qualityRating ?? this.qualityRating,
      punctualityRating: punctualityRating ?? this.punctualityRating,
      communicationRating: communicationRating ?? this.communicationRating,
      valueRating: valueRating ?? this.valueRating,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      status: status ?? this.status,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      reportCount: reportCount ?? this.reportCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      providerName: providerName ?? this.providerName,
      userEmail: userEmail ?? this.userEmail,
      userMetadata: userMetadata ?? this.userMetadata,
      userVotedHelpful: userVotedHelpful ?? this.userVotedHelpful,
    );
  }
}

// ========================================
// 2. 点评回复模型 (ReviewReply)
// ========================================
class ReviewReply {
  final String id;
  final String reviewId;
  final String replierId;
  final String replierType; // 'provider' or 'user'
  final Map<String, String> content;
  final bool isAnonymous;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewReply({
    required this.id,
    required this.reviewId,
    required this.replierId,
    required this.replierType,
    required this.content,
    this.isAnonymous = false,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewReply.fromJson(Map<String, dynamic> json) {
    return ReviewReply(
      id: json['id'],
      reviewId: json['review_id'],
      replierId: json['replier_id'],
      replierType: json['replier_type'],
      content: Map<String, String>.from(json['content'] ?? {}),
      isAnonymous: json['is_anonymous'] ?? false,
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'review_id': reviewId,
      'replier_id': replierId,
      'replier_type': replierType,
      'content': content,
      'is_anonymous': isAnonymous,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String getLocalizedContent(String languageCode) {
    return content[languageCode] ?? content['en'] ?? content['zh'] ?? '';
  }

  String getDisplayName() {
    if (isAnonymous) {
      return replierType == 'provider' ? 'Provider' : 'User';
    }
    return replierType == 'provider' ? 'Provider' : 'User';
  }
}

// ========================================
// 3. 点评标签模型 (ReviewTag)
// ========================================
class ReviewTag {
  final int id;
  final Map<String, String> name;
  final String category;
  final String? icon;
  final String? color;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  ReviewTag({
    required this.id,
    required this.name,
    required this.category,
    this.icon,
    this.color,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory ReviewTag.fromJson(Map<String, dynamic> json) {
    return ReviewTag(
      id: json['id'],
      name: Map<String, String>.from(json['name'] ?? {}),
      category: json['category'],
      icon: json['icon'],
      color: json['color'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'icon': icon,
      'color': color,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String getLocalizedName(String languageCode) {
    return name[languageCode] ?? name['en'] ?? name['zh'] ?? '';
  }

  IconData getIconData() {
    switch (icon) {
      case 'star': return Icons.star;
      case 'schedule': return Icons.schedule;
      case 'chat': return Icons.chat;
      case 'attach_money': return Icons.attach_money;
      case 'cleaning_services': return Icons.cleaning_services;
      case 'sentiment_satisfied': return Icons.sentiment_satisfied;
      case 'speed': return Icons.speed;
      case 'payments': return Icons.payments;
      default: return Icons.label;
    }
  }

  Color getColor() {
    if (color != null) {
      try {
        return Color(int.parse(color!.replaceAll('#', '0xFF')));
      } catch (e) {
        // 如果解析失败，返回默认颜色
      }
    }
    
    // 根据分类返回默认颜色
    switch (category) {
      case 'quality': return Colors.green;
      case 'service': return Colors.blue;
      case 'attitude': return Colors.orange;
      case 'value': return Colors.purple;
      default: return Colors.grey;
    }
  }
}

// ========================================
// 4. 点评创建请求模型 (CreateReviewRequest)
// ========================================
class CreateReviewRequest {
  final String serviceId;
  final String providerId;
  final String? orderId;
  final double overallRating;
  final Map<String, String> content;
  final bool isAnonymous;
  final double? qualityRating;
  final double? punctualityRating;
  final double? communicationRating;
  final double? valueRating;
  final List<String> tags;
  final List<String> images;

  CreateReviewRequest({
    required this.serviceId,
    required this.providerId,
    this.orderId,
    required this.overallRating,
    required this.content,
    this.isAnonymous = false,
    this.qualityRating,
    this.punctualityRating,
    this.communicationRating,
    this.valueRating,
    this.tags = const [],
    this.images = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'provider_id': providerId,
      'order_id': orderId,
      'overall_rating': overallRating,
      'content': content,
      'is_anonymous': isAnonymous,
      'quality_rating': qualityRating,
      'punctuality_rating': punctualityRating,
      'communication_rating': communicationRating,
      'value_rating': valueRating,
      'tags': tags,
      'images': images,
    };
  }
}

// ========================================
// 5. 点评回复创建请求模型 (CreateReviewReplyRequest)
// ========================================
class CreateReviewReplyRequest {
  final String reviewId;
  final String replierType;
  final Map<String, String> content;
  final bool isAnonymous;

  CreateReviewReplyRequest({
    required this.reviewId,
    required this.replierType,
    required this.content,
    this.isAnonymous = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'replier_type': replierType,
      'content': content,
      'is_anonymous': isAnonymous,
    };
  }
}

// ========================================
// 6. 点评投票请求模型 (ReviewVoteRequest)
// ========================================
class ReviewVoteRequest {
  final String reviewId;
  final bool isHelpful;

  ReviewVoteRequest({
    required this.reviewId,
    required this.isHelpful,
  });

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'is_helpful': isHelpful,
    };
  }
}

// ========================================
// 7. 点评举报请求模型 (ReviewReportRequest)
// ========================================
class ReviewReportRequest {
  final String reviewId;
  final String reason;
  final String? description;

  ReviewReportRequest({
    required this.reviewId,
    required this.reason,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'reason': reason,
      'description': description,
    };
  }
}

// ========================================
// 8. 服务评分统计模型 (ServiceRatingStats)
// ========================================
class ServiceRatingStats {
  final String serviceId;
  final int totalReviews;
  final double averageRating;
  final int positiveReviews;
  final int negativeReviews;
  final double? avgQualityRating;
  final double? avgPunctualityRating;
  final double? avgCommunicationRating;
  final double? avgValueRating;

  ServiceRatingStats({
    required this.serviceId,
    required this.totalReviews,
    required this.averageRating,
    required this.positiveReviews,
    required this.negativeReviews,
    this.avgQualityRating,
    this.avgPunctualityRating,
    this.avgCommunicationRating,
    this.avgValueRating,
  });

  factory ServiceRatingStats.fromJson(Map<String, dynamic> json) {
    return ServiceRatingStats(
      serviceId: json['service_id'],
      totalReviews: json['total_reviews'] ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      positiveReviews: json['positive_reviews'] ?? 0,
      negativeReviews: json['negative_reviews'] ?? 0,
      avgQualityRating: json['avg_quality_rating'] != null ? (json['avg_quality_rating'] as num).toDouble() : null,
      avgPunctualityRating: json['avg_punctuality_rating'] != null ? (json['avg_punctuality_rating'] as num).toDouble() : null,
      avgCommunicationRating: json['avg_communication_rating'] != null ? (json['avg_communication_rating'] as num).toDouble() : null,
      avgValueRating: json['avg_value_rating'] != null ? (json['avg_value_rating'] as num).toDouble() : null,
    );
  }

  // 获取评分百分比
  double getPositivePercentage() {
    if (totalReviews == 0) return 0.0;
    return (positiveReviews / totalReviews) * 100;
  }

  double getNegativePercentage() {
    if (totalReviews == 0) return 0.0;
    return (negativeReviews / totalReviews) * 100;
  }

  // 获取评分等级
  String getRatingLevel() {
    if (averageRating >= 4.5) return 'Excellent';
    if (averageRating >= 4.0) return 'Very Good';
    if (averageRating >= 3.5) return 'Good';
    if (averageRating >= 3.0) return 'Fair';
    return 'Poor';
  }
}

// ========================================
// 9. 点评筛选选项模型 (ReviewFilterOptions)
// ========================================
class ReviewFilterOptions {
  final double? minRating;
  final double? maxRating;
  final List<String> tags;
  final String? sortBy; // 'newest', 'oldest', 'rating', 'helpful'
  final bool? hasImages;
  final bool? hasReplies;

  ReviewFilterOptions({
    this.minRating,
    this.maxRating,
    this.tags = const [],
    this.sortBy,
    this.hasImages,
    this.hasReplies,
  });

  Map<String, dynamic> toJson() {
    return {
      'min_rating': minRating,
      'max_rating': maxRating,
      'tags': tags,
      'sort_by': sortBy,
      'has_images': hasImages,
      'has_replies': hasReplies,
    };
  }

  ReviewFilterOptions copyWith({
    double? minRating,
    double? maxRating,
    List<String>? tags,
    String? sortBy,
    bool? hasImages,
    bool? hasReplies,
  }) {
    return ReviewFilterOptions(
      minRating: minRating ?? this.minRating,
      maxRating: maxRating ?? this.maxRating,
      tags: tags ?? this.tags,
      sortBy: sortBy ?? this.sortBy,
      hasImages: hasImages ?? this.hasImages,
      hasReplies: hasReplies ?? this.hasReplies,
    );
  }
} 