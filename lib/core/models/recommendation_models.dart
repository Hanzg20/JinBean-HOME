// 推荐系统数据模型
// 支持用户行为分析、推荐算法、A/B测试等功能


// ========================================
// 1. 用户行为模型 (UserBehavior)
// ========================================
class UserBehavior {
  final String id;
  final String userId;
  final String serviceId;
  final String behaviorType; // 'view', 'search', 'bookmark', 'book', 'review'
  final Map<String, dynamic> metadata; // 行为相关的元数据
  final DateTime createdAt;

  UserBehavior({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.behaviorType,
    this.metadata = const {},
    required this.createdAt,
  });

  factory UserBehavior.fromJson(Map<String, dynamic> json) {
    return UserBehavior(
      id: json['id'],
      userId: json['user_id'],
      serviceId: json['service_id'],
      behaviorType: json['behavior_type'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'service_id': serviceId,
      'behavior_type': behaviorType,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// ========================================
// 2. 用户画像模型 (UserProfile)
// ========================================
class UserProfile {
  final String userId;
  final Map<String, double> categoryPreferences; // 分类偏好权重
  final Map<String, double> tagPreferences; // 标签偏好权重
  final Map<String, double> pricePreferences; // 价格偏好
  final Map<String, double> locationPreferences; // 位置偏好
  final List<String> favoriteCategories; // 最喜欢的分类
  final List<String> favoriteTags; // 最喜欢的标签
  final double averageRatingPreference; // 平均评分偏好
  final DateTime lastUpdated;

  UserProfile({
    required this.userId,
    this.categoryPreferences = const {},
    this.tagPreferences = const {},
    this.pricePreferences = const {},
    this.locationPreferences = const {},
    this.favoriteCategories = const [],
    this.favoriteTags = const [],
    this.averageRatingPreference = 0.0,
    required this.lastUpdated,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'],
      categoryPreferences: Map<String, double>.from(json['category_preferences'] ?? {}),
      tagPreferences: Map<String, double>.from(json['tag_preferences'] ?? {}),
      pricePreferences: Map<String, double>.from(json['price_preferences'] ?? {}),
      locationPreferences: Map<String, double>.from(json['location_preferences'] ?? {}),
      favoriteCategories: List<String>.from(json['favorite_categories'] ?? []),
      favoriteTags: List<String>.from(json['favorite_tags'] ?? []),
      averageRatingPreference: (json['average_rating_preference'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'category_preferences': categoryPreferences,
      'tag_preferences': tagPreferences,
      'price_preferences': pricePreferences,
      'location_preferences': locationPreferences,
      'favorite_categories': favoriteCategories,
      'favorite_tags': favoriteTags,
      'average_rating_preference': averageRatingPreference,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

// ========================================
// 3. 推荐结果模型 (Recommendation)
// ========================================
class Recommendation {
  final String id;
  final String userId;
  final String serviceId;
  final String algorithmType; // 'collaborative', 'content', 'hybrid', 'popularity'
  final double score; // 推荐分数
  final Map<String, dynamic> metadata; // 推荐相关的元数据
  final DateTime createdAt;
  final DateTime expiresAt;

  Recommendation({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.algorithmType,
    required this.score,
    this.metadata = const {},
    required this.createdAt,
    required this.expiresAt,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'],
      userId: json['user_id'],
      serviceId: json['service_id'],
      algorithmType: json['algorithm_type'],
      score: (json['score'] as num).toDouble(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'service_id': serviceId,
      'algorithm_type': algorithmType,
      'score': score,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}

// ========================================
// 4. A/B测试模型 (ABTest)
// ========================================
class ABTest {
  final String id;
  final String name;
  final String description;
  final String testType; // 'recommendation_algorithm', 'ui_variant', 'content'
  final Map<String, dynamic> variantA; // 对照组配置
  final Map<String, dynamic> variantB; // 实验组配置
  final double trafficSplit; // 流量分配比例 (0.0-1.0)
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'draft', 'running', 'paused', 'completed'
  final Map<String, dynamic> metrics; // 测试指标

  ABTest({
    required this.id,
    required this.name,
    required this.description,
    required this.testType,
    required this.variantA,
    required this.variantB,
    required this.trafficSplit,
    required this.startDate,
    required this.endDate,
    this.status = 'draft',
    this.metrics = const {},
  });

  factory ABTest.fromJson(Map<String, dynamic> json) {
    return ABTest(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      testType: json['test_type'],
      variantA: Map<String, dynamic>.from(json['variant_a'] ?? {}),
      variantB: Map<String, dynamic>.from(json['variant_b'] ?? {}),
      trafficSplit: (json['traffic_split'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: json['status'] ?? 'draft',
      metrics: Map<String, dynamic>.from(json['metrics'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'test_type': testType,
      'variant_a': variantA,
      'variant_b': variantB,
      'traffic_split': trafficSplit,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'metrics': metrics,
    };
  }
}

// ========================================
// 5. 推荐配置模型 (RecommendationConfig)
// ========================================
class RecommendationConfig {
  final String id;
  final String name;
  final String algorithmType;
  final Map<String, dynamic> parameters; // 算法参数
  final List<String> enabledFeatures; // 启用的特征
  final Map<String, double> featureWeights; // 特征权重
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecommendationConfig({
    required this.id,
    required this.name,
    required this.algorithmType,
    this.parameters = const {},
    this.enabledFeatures = const [],
    this.featureWeights = const {},
    this.isActive = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecommendationConfig.fromJson(Map<String, dynamic> json) {
    return RecommendationConfig(
      id: json['id'],
      name: json['name'],
      algorithmType: json['algorithm_type'],
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      enabledFeatures: List<String>.from(json['enabled_features'] ?? []),
      featureWeights: Map<String, double>.from(json['feature_weights'] ?? {}),
      isActive: json['is_active'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'algorithm_type': algorithmType,
      'parameters': parameters,
      'enabled_features': enabledFeatures,
      'feature_weights': featureWeights,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// ========================================
// 6. 推荐请求模型 (RecommendationRequest)
// ========================================
class RecommendationRequest {
  final String userId;
  final String? categoryId;
  final String? location;
  final double? maxPrice;
  final double? minRating;
  final int limit;
  final String algorithmType;
  final Map<String, dynamic> context; // 上下文信息

  RecommendationRequest({
    required this.userId,
    this.categoryId,
    this.location,
    this.maxPrice,
    this.minRating,
    this.limit = 10,
    this.algorithmType = 'hybrid',
    this.context = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'category_id': categoryId,
      'location': location,
      'max_price': maxPrice,
      'min_rating': minRating,
      'limit': limit,
      'algorithm_type': algorithmType,
      'context': context,
    };
  }
}

// ========================================
// 7. 推荐响应模型 (RecommendationResponse)
// ========================================
class RecommendationResponse {
  final List<Recommendation> recommendations;
  final String algorithmType;
  final Map<String, dynamic> metadata;
  final DateTime generatedAt;

  RecommendationResponse({
    required this.recommendations,
    required this.algorithmType,
    this.metadata = const {},
    required this.generatedAt,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationResponse(
      recommendations: (json['recommendations'] as List)
          .map((item) => Recommendation.fromJson(item))
          .toList(),
      algorithmType: json['algorithm_type'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      generatedAt: DateTime.parse(json['generated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'algorithm_type': algorithmType,
      'metadata': metadata,
      'generated_at': generatedAt.toIso8601String(),
    };
  }
}

// ========================================
// 8. 推荐指标模型 (RecommendationMetrics)
// ========================================
class RecommendationMetrics {
  final String userId;
  final String recommendationId;
  final String metricType; // 'click', 'book', 'view', 'dismiss'
  final double value;
  final Map<String, dynamic> metadata;
  final DateTime recordedAt;

  RecommendationMetrics({
    required this.userId,
    required this.recommendationId,
    required this.metricType,
    required this.value,
    this.metadata = const {},
    required this.recordedAt,
  });

  factory RecommendationMetrics.fromJson(Map<String, dynamic> json) {
    return RecommendationMetrics(
      userId: json['user_id'],
      recommendationId: json['recommendation_id'],
      metricType: json['metric_type'],
      value: (json['value'] as num).toDouble(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      recordedAt: DateTime.parse(json['recorded_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'recommendation_id': recommendationId,
      'metric_type': metricType,
      'value': value,
      'metadata': metadata,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }
} 