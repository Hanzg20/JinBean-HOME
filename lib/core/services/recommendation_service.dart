// 推荐系统服务层
// 实现推荐算法、用户行为分析、A/B测试等功能

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recommendation_models.dart';

class RecommendationService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ========================================
  // 1. 用户行为记录
  // ========================================
  
  /// 记录用户行为
  Future<void> recordUserBehavior(UserBehavior behavior) async {
    try {
      await _supabase
          .from('user_behaviors')
          .insert(behavior.toJson());
    } catch (e) {
      print('Error recording user behavior: $e');
      throw Exception('Failed to record user behavior: $e');
    }
  }

  /// 批量记录用户行为
  Future<void> recordUserBehaviors(List<UserBehavior> behaviors) async {
    try {
      final behaviorsJson = behaviors.map((b) => b.toJson()).toList();
      await _supabase
          .from('user_behaviors')
          .insert(behaviorsJson);
    } catch (e) {
      print('Error recording user behaviors: $e');
      throw Exception('Failed to record user behaviors: $e');
    }
  }

  /// 获取用户行为历史
  Future<List<UserBehavior>> getUserBehaviors(
    String userId, {
    String? behaviorType,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      dynamic query = _supabase
          .from('user_behaviors')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      if (behaviorType != null) {
        query = query.eq('behavior_type', behaviorType);
      }

      final response = await query;
      return (response as List)
          .map((json) => UserBehavior.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching user behaviors: $e');
      throw Exception('Failed to fetch user behaviors: $e');
    }
  }

  // ========================================
  // 2. 用户画像管理
  // ========================================
  
  /// 获取用户画像
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select('*')
          .eq('user_id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      if (e.toString().contains('No rows found')) {
        return null;
      }
      print('Error fetching user profile: $e');
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// 更新用户画像
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _supabase
          .from('user_profiles')
          .upsert(profile.toJson());
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// 计算用户画像（基于行为数据）
  Future<UserProfile> calculateUserProfile(String userId) async {
    try {
      // 获取用户行为数据
      final behaviors = await getUserBehaviors(userId, limit: 1000);
      
      // 分析行为数据，计算偏好
      final categoryPreferences = <String, double>{};
      final tagPreferences = <String, double>{};
      final pricePreferences = <String, double>{};
      final locationPreferences = <String, double>{};
      
      // 统计行为权重
      for (final behavior in behaviors) {
        final weight = _getBehaviorWeight(behavior.behaviorType);
        final metadata = behavior.metadata;
        
        // 分类偏好
        if (metadata['category_id'] != null) {
          final categoryId = metadata['category_id'] as String;
          categoryPreferences[categoryId] = 
              (categoryPreferences[categoryId] ?? 0) + weight;
        }
        
        // 标签偏好
        if (metadata['tags'] != null) {
          final tags = List<String>.from(metadata['tags']);
          for (final tag in tags) {
            tagPreferences[tag] = (tagPreferences[tag] ?? 0) + weight;
          }
        }
        
        // 价格偏好
        if (metadata['price'] != null) {
          final price = (metadata['price'] as num).toDouble();
          final priceRange = _getPriceRange(price);
          pricePreferences[priceRange] = 
              (pricePreferences[priceRange] ?? 0) + weight;
        }
        
        // 位置偏好
        if (metadata['location'] != null) {
          final location = metadata['location'] as String;
          locationPreferences[location] = 
              (locationPreferences[location] ?? 0) + weight;
        }
      }
      
      // 计算最喜欢的分类和标签
      final favoriteCategories = categoryPreferences.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      
      final favoriteTags = tagPreferences.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      
      // 计算平均评分偏好
      double totalRating = 0;
      int ratingCount = 0;
      for (final behavior in behaviors) {
        if (behavior.behaviorType == 'review' && 
            behavior.metadata['rating'] != null) {
          totalRating += (behavior.metadata['rating'] as num).toDouble();
          ratingCount++;
        }
      }
      
      final averageRatingPreference = ratingCount > 0 ? totalRating / ratingCount : 0.0;
      
      return UserProfile(
        userId: userId,
        categoryPreferences: categoryPreferences,
        tagPreferences: tagPreferences,
        pricePreferences: pricePreferences,
        locationPreferences: locationPreferences,
        favoriteCategories: favoriteCategories.take(5).map((e) => e.key).toList(),
        favoriteTags: favoriteTags.take(10).map((e) => e.key).toList(),
        averageRatingPreference: averageRatingPreference,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('Error calculating user profile: $e');
      throw Exception('Failed to calculate user profile: $e');
    }
  }

  // ========================================
  // 3. 推荐算法
  // ========================================
  
  /// 获取推荐服务
  Future<RecommendationResponse> getRecommendations(
    RecommendationRequest request,
  ) async {
    try {
      // 根据算法类型选择推荐策略
      switch (request.algorithmType) {
        case 'collaborative':
          return await _getCollaborativeRecommendations(request);
        case 'content':
          return await _getContentBasedRecommendations(request);
        case 'hybrid':
          return await _getHybridRecommendations(request);
        case 'popularity':
          return await _getPopularityRecommendations(request);
        default:
          return await _getHybridRecommendations(request);
      }
    } catch (e) {
      print('Error getting recommendations: $e');
      throw Exception('Failed to get recommendations: $e');
    }
  }

  /// 协同过滤推荐
  Future<RecommendationResponse> _getCollaborativeRecommendations(
    RecommendationRequest request,
  ) async {
    try {
      // 获取相似用户
      final similarUsers = await _findSimilarUsers(request.userId);
      
      // 获取相似用户喜欢的服务
      final recommendedServices = <String, double>{};
      for (final similarUser in similarUsers) {
        final userBehaviors = await getUserBehaviors(
          similarUser['user_id'],
          behaviorType: 'book',
          limit: 50,
        );
        
        for (final behavior in userBehaviors) {
          final similarity = similarUser['similarity'] as double;
          recommendedServices[behavior.serviceId] = 
              (recommendedServices[behavior.serviceId] ?? 0) + similarity;
        }
      }
      
      // 转换为推荐结果
      final recommendations = recommendedServices.entries
          .map((entry) => Recommendation(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                userId: request.userId,
                serviceId: entry.key,
                algorithmType: 'collaborative',
                score: entry.value,
                metadata: {'similarity_score': entry.value},
                createdAt: DateTime.now(),
                expiresAt: DateTime.now().add(const Duration(days: 7)),
              ))
          .toList()
        ..sort((a, b) => b.score.compareTo(a.score));
      
      return RecommendationResponse(
        recommendations: recommendations.take(request.limit).toList(),
        algorithmType: 'collaborative',
        metadata: {'similar_users_count': similarUsers.length},
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      print('Error getting collaborative recommendations: $e');
      throw Exception('Failed to get collaborative recommendations: $e');
    }
  }

  /// 基于内容的推荐
  Future<RecommendationResponse> _getContentBasedRecommendations(
    RecommendationRequest request,
  ) async {
    try {
      // 获取用户画像
      final userProfile = await getUserProfile(request.userId);
      if (userProfile == null) {
        return RecommendationResponse(
          recommendations: [],
          algorithmType: 'content',
          metadata: {'error': 'No user profile found'},
          generatedAt: DateTime.now(),
        );
      }
      
      // 构建查询条件
      dynamic query = _supabase
          .from('services')
          .select('*')
          .eq('status', 'active');
      
      // 应用筛选条件
      if (request.categoryId != null) {
        query = query.eq('category_id', request.categoryId!);
      }
      if (request.maxPrice != null) {
        query = query.lte('price', request.maxPrice!);
      }
      if (request.minRating != null) {
        query = query.gte('average_rating', request.minRating!);
      }
      
      final services = await query.limit(request.limit);
      
      // 计算内容相似度分数
      final recommendations = <Recommendation>[];
      for (final service in services) {
        final score = _calculateContentSimilarity(userProfile, service);
        if (score > 0) {
          recommendations.add(Recommendation(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: request.userId,
            serviceId: service['id'],
            algorithmType: 'content',
            score: score,
            metadata: {'content_similarity': score},
            createdAt: DateTime.now(),
            expiresAt: DateTime.now().add(const Duration(days: 7)),
          ));
        }
      }
      
      recommendations.sort((a, b) => b.score.compareTo(a.score));
      
      return RecommendationResponse(
        recommendations: recommendations.take(request.limit).toList(),
        algorithmType: 'content',
        metadata: {'user_profile_updated': userProfile.lastUpdated.toIso8601String()},
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      print('Error getting content-based recommendations: $e');
      throw Exception('Failed to get content-based recommendations: $e');
    }
  }

  /// 混合推荐
  Future<RecommendationResponse> _getHybridRecommendations(
    RecommendationRequest request,
  ) async {
    try {
      // 获取多种推荐结果
      final collaborative = await _getCollaborativeRecommendations(request);
      final content = await _getContentBasedRecommendations(request);
      
      // 合并推荐结果
      final allRecommendations = <String, Recommendation>{};
      
      // 添加协同过滤推荐
      for (final rec in collaborative.recommendations) {
        allRecommendations[rec.serviceId] = rec;
      }
      
      // 添加内容推荐，如果已存在则合并分数
      for (final rec in content.recommendations) {
        if (allRecommendations.containsKey(rec.serviceId)) {
          final existing = allRecommendations[rec.serviceId]!;
          allRecommendations[rec.serviceId] = Recommendation(
            id: existing.id,
            userId: existing.userId,
            serviceId: existing.serviceId,
            algorithmType: 'hybrid',
            score: (existing.score + rec.score) / 2,
            metadata: {
              'collaborative_score': existing.score,
              'content_score': rec.score,
              'hybrid_score': (existing.score + rec.score) / 2,
            },
            createdAt: existing.createdAt,
            expiresAt: existing.expiresAt,
          );
        } else {
          allRecommendations[rec.serviceId] = rec;
        }
      }
      
      final recommendations = allRecommendations.values.toList()
        ..sort((a, b) => b.score.compareTo(a.score));
      
      return RecommendationResponse(
        recommendations: recommendations.take(request.limit).toList(),
        algorithmType: 'hybrid',
        metadata: {
          'collaborative_count': collaborative.recommendations.length,
          'content_count': content.recommendations.length,
          'hybrid_count': recommendations.length,
        },
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      print('Error getting hybrid recommendations: $e');
      throw Exception('Failed to get hybrid recommendations: $e');
    }
  }

  /// 热门推荐
  Future<RecommendationResponse> _getPopularityRecommendations(
    RecommendationRequest request,
  ) async {
    try {
      final query = _supabase
          .from('services')
          .select('*')
          .eq('status', 'active')
          .order('view_count', ascending: false)
          .limit(request.limit);
      
      final services = await query;
      
      final recommendations = services.asMap().entries.map((entry) {
        final index = entry.key;
        final service = entry.value;
        return Recommendation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: request.userId,
          serviceId: service['id'],
          algorithmType: 'popularity',
          score: 1.0 / (index + 1), // 排名越靠前分数越高
          metadata: {
            'popularity_rank': index + 1,
            'view_count': service['view_count'],
          },
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 1)),
        );
      }).toList();
      
      return RecommendationResponse(
        recommendations: recommendations,
        algorithmType: 'popularity',
        metadata: {'total_services': services.length},
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      print('Error getting popularity recommendations: $e');
      throw Exception('Failed to get popularity recommendations: $e');
    }
  }

  // ========================================
  // 4. A/B测试
  // ========================================
  
  /// 获取A/B测试配置
  Future<ABTest?> getABTest(String testId) async {
    try {
      final response = await _supabase
          .from('ab_tests')
          .select('*')
          .eq('id', testId)
          .single();

      return ABTest.fromJson(response);
    } catch (e) {
      if (e.toString().contains('No rows found')) {
        return null;
      }
      print('Error fetching AB test: $e');
      throw Exception('Failed to fetch AB test: $e');
    }
  }

  /// 获取用户应该看到的测试变体
  Future<Map<String, dynamic>?> getUserVariant(
    String userId,
    String testId,
  ) async {
    try {
      final test = await getABTest(testId);
      if (test == null || test.status != 'running') {
        return null;
      }
      
      // 基于用户ID确定变体
      final userHash = userId.hashCode.abs();
      final variant = userHash % 100 < (test.trafficSplit * 100) 
          ? test.variantB 
          : test.variantA;
      
      return variant;
    } catch (e) {
      print('Error getting user variant: $e');
      return null;
    }
  }

  /// 记录A/B测试指标
  Future<void> recordABTestMetric(
    String testId,
    String userId,
    String metricType,
    double value, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _supabase
          .from('ab_test_metrics')
          .insert({
            'test_id': testId,
            'user_id': userId,
            'metric_type': metricType,
            'value': value,
            'metadata': metadata ?? {},
            'recorded_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('Error recording AB test metric: $e');
      // 不抛出异常，避免影响用户体验
    }
  }

  // ========================================
  // 5. 工具方法
  // ========================================
  
  /// 获取行为权重
  double _getBehaviorWeight(String behaviorType) {
    switch (behaviorType) {
      case 'book':
        return 5.0;
      case 'review':
        return 4.0;
      case 'bookmark':
        return 3.0;
      case 'search':
        return 2.0;
      case 'view':
        return 1.0;
      default:
        return 0.5;
    }
  }

  /// 获取价格范围
  String _getPriceRange(double price) {
    if (price < 50) return 'low';
    if (price < 200) return 'medium';
    return 'high';
  }

  /// 查找相似用户
  Future<List<Map<String, dynamic>>> _findSimilarUsers(String userId) async {
    try {
      // 获取目标用户的行为
      final targetBehaviors = await getUserBehaviors(userId, limit: 100);
      final targetServiceIds = targetBehaviors.map((b) => b.serviceId).toSet();
      
      // 查找有相似行为的用户
      final similarUsers = <Map<String, dynamic>>[];
      
      // 这里简化实现，实际应该使用更复杂的相似度算法
      for (final behavior in targetBehaviors) {
        final otherBehaviors = await _supabase
            .from('user_behaviors')
            .select('user_id')
            .eq('service_id', behavior.serviceId)
            .neq('user_id', userId);
        
        for (final otherBehavior in otherBehaviors) {
          final otherUserId = otherBehavior['user_id'];
          final otherUserBehaviors = await getUserBehaviors(otherUserId, limit: 50);
          final otherServiceIds = otherUserBehaviors.map((b) => b.serviceId).toSet();
          
          // 计算Jaccard相似度
          final intersection = targetServiceIds.intersection(otherServiceIds).length;
          final union = targetServiceIds.union(otherServiceIds).length;
          final similarity = union > 0 ? intersection / union : 0.0;
          
          if (similarity > 0.1) { // 相似度阈值
            similarUsers.add({
              'user_id': otherUserId,
              'similarity': similarity,
            });
          }
        }
      }
      
      // 去重并排序
      final uniqueUsers = <String, double>{};
      for (final user in similarUsers) {
        final existingSimilarity = uniqueUsers[user['user_id']] ?? 0.0;
        uniqueUsers[user['user_id']] = 
            existingSimilarity > user['similarity'] 
                ? existingSimilarity 
                : user['similarity'];
      }
      
      return uniqueUsers.entries
          .map((e) => {'user_id': e.key, 'similarity': e.value})
          .toList()
        ..sort((a, b) => (b['similarity'] as double).compareTo(a['similarity'] as double));
    } catch (e) {
      print('Error finding similar users: $e');
      return [];
    }
  }

  /// 计算内容相似度
  double _calculateContentSimilarity(UserProfile profile, Map<String, dynamic> service) {
    double score = 0.0;
    
    // 分类相似度
    if (profile.categoryPreferences.containsKey(service['category_id'])) {
      score += profile.categoryPreferences[service['category_id']]! * 0.3;
    }
    
    // 标签相似度
    final serviceTags = List<String>.from(service['tags'] ?? []);
    for (final tag in serviceTags) {
      if (profile.tagPreferences.containsKey(tag)) {
        score += profile.tagPreferences[tag]! * 0.2;
      }
    }
    
    // 价格相似度
    final servicePrice = (service['price'] as num?)?.toDouble() ?? 0.0;
    if (servicePrice > 0) {
      final priceRange = _getPriceRange(servicePrice);
      if (profile.pricePreferences.containsKey(priceRange)) {
        score += profile.pricePreferences[priceRange]! * 0.2;
      }
    }
    
    // 评分相似度
    final serviceRating = (service['average_rating'] as num?)?.toDouble() ?? 0.0;
    if (serviceRating > 0 && profile.averageRatingPreference > 0) {
      final ratingDiff = (serviceRating - profile.averageRatingPreference).abs();
      score += (5.0 - ratingDiff) * 0.3;
    }
    
    return score;
  }
} 