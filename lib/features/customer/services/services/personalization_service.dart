import 'package:supabase_flutter/supabase_flutter.dart';

/// 用户行为类型
enum UserBehaviorType {
  view,      // 查看服务
  favorite,  // 收藏服务
  book,      // 预订服务
  review,    // 评价服务
  search,    // 搜索服务
  share,     // 分享服务
  quoteRequest, // 请求报价
}

/// 个性化推荐服务
class PersonalizationService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// 用户行为记录
  static Future<void> logUserBehavior({
    required String userId,
    required String serviceId,
    required UserBehaviorType behaviorType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _supabase
          .from('user_behaviors')
          .insert({
            'user_id': userId,
            'service_id': serviceId,
            'behavior_type': behaviorType.name,
            'metadata': metadata,
            'created_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('Error logging user behavior: $e');
    }
  }

  /// 获取用户偏好分析
  static Future<Map<String, dynamic>> getUserPreferences(String userId) async {
    try {
      // 分析用户历史行为
      final behaviors = await _supabase
          .from('user_behaviors')
          .select('''
            *,
            services!user_behaviors_service_id_fkey(
              category_level1_id,
              category_level2_id,
              average_rating,
              price
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(100);

      // 分析服务类型偏好
      final categoryPreferences = _analyzeCategoryPreferences(behaviors);
      
      // 分析价格偏好
      final pricePreferences = _analyzePricePreferences(behaviors);
      
      // 分析评分偏好
      final ratingPreferences = _analyzeRatingPreferences(behaviors);
      
      // 分析时间偏好
      final timePreferences = _analyzeTimePreferences(behaviors);

      return {
        'category_preferences': categoryPreferences,
        'price_preferences': pricePreferences,
        'rating_preferences': ratingPreferences,
        'time_preferences': timePreferences,
        'total_bookings': behaviors.where((b) => b['behavior_type'] == 'book').length,
        'favorite_services': behaviors.where((b) => b['behavior_type'] == 'favorite').length,
        'reviewed_services': behaviors.where((b) => b['behavior_type'] == 'review').length,
      };
    } catch (e) {
      print('Error getting user preferences: $e');
      return {};
    }
  }

  /// 获取基于用户历史的推荐
  static Future<List<Map<String, dynamic>>> getHistoryBasedRecommendations(
    String userId, 
    String currentServiceId,
  ) async {
    try {
      final userPreferences = await getUserPreferences(userId);
      final currentService = await _supabase
          .from('services')
          .select('*')
          .eq('id', currentServiceId)
          .single();

      // 基于用户偏好推荐相似服务
      final recommendations = await _supabase
          .from('services')
          .select('''
            *,
            service_details(*),
            provider_profiles!services_provider_id_fkey(
              company_name,
              ratings_avg,
              review_count
            )
          ''')
          .eq('status', 'active')
          .neq('id', currentServiceId)
          .limit(5);

      // 计算推荐分数
      final scoredRecommendations = recommendations.map((service) {
        double score = 0.0;
        
        // 分类匹配分数
        if (service['category_level1_id'] == currentService['category_level1_id']) {
          score += 0.4;
        }
        
        // 价格偏好匹配
        final priceRange = userPreferences['price_preferences']?['preferred_range'];
        if (priceRange != null) {
          final servicePrice = service['service_details']?[0]?['price'] ?? 0;
          if (servicePrice >= priceRange['min'] && servicePrice <= priceRange['max']) {
            score += 0.3;
          }
        }
        
        // 评分偏好匹配
        final ratingPreference = userPreferences['rating_preferences']?['min_rating'] ?? 0;
        if (service['average_rating'] >= ratingPreference) {
          score += 0.2;
        }
        
        // 提供商评分
        final providerRating = service['provider_profiles']?['ratings_avg'] ?? 0;
        if (providerRating >= 4.0) {
          score += 0.1;
        }

        return {
          ...service,
          'recommendation_score': score,
        };
      }).toList();

      // 按推荐分数排序
      scoredRecommendations.sort((a, b) => 
          (b['recommendation_score'] as double).compareTo(a['recommendation_score'] as double));

      return scoredRecommendations;
    } catch (e) {
      print('Error getting history-based recommendations: $e');
      return [];
    }
  }

  /// 获取基于相似用户的推荐
  static Future<List<Map<String, dynamic>>> getSimilarUserRecommendations(
    String userId, 
    String currentServiceId,
  ) async {
    try {
      // 找到相似用户（基于行为模式）
      final similarUsers = await _findSimilarUsers(userId);
      
      if (similarUsers.isEmpty) {
        return [];
      }

      // 获取相似用户喜欢的服务
      final similarUserBehaviors = await _supabase
          .from('user_behaviors')
          .select('''
            service_id,
            behavior_type,
            services!user_behaviors_service_id_fkey(
              *,
              service_details(*),
              provider_profiles!services_provider_id_fkey(
                company_name,
                ratings_avg,
                review_count
              )
            )
          ''')
          .inFilter('user_id', similarUsers)
          .eq('behavior_type', 'book')
          .neq('service_id', currentServiceId)
          .limit(10);

      // 统计服务受欢迎程度
      final serviceCounts = <String, int>{};
      final serviceDetails = <String, Map<String, dynamic>>{};
      
      for (final behavior in similarUserBehaviors) {
        final serviceId = behavior['service_id'];
        serviceCounts[serviceId] = (serviceCounts[serviceId] ?? 0) + 1;
        serviceDetails[serviceId] = behavior['services'];
      }

      // 转换为推荐列表
      final recommendations = serviceCounts.entries.map((entry) {
        final service = serviceDetails[entry.key]!;
        return {
          ...service,
          'similar_user_count': entry.value,
          'popularity_percentage': (entry.value / similarUsers.length * 100).round(),
        };
      }).toList();

      // 按受欢迎程度排序
      recommendations.sort((a, b) => 
          (b['similar_user_count'] as int).compareTo(a['similar_user_count'] as int));

      return recommendations.take(5).toList();
    } catch (e) {
      print('Error getting similar user recommendations: $e');
      return [];
    }
  }

  /// 获取个性化优惠
  static Future<List<Map<String, dynamic>>> getPersonalizedOffers(String userId) async {
    try {
      final userPreferences = await getUserPreferences(userId);
      final offers = <Map<String, dynamic>>[];

      // 新用户优惠
      if (userPreferences['total_bookings'] == 0) {
        offers.add({
          'type': 'first_time',
          'title': 'First-time customer discount',
          'description': 'Get 15% off your first booking',
          'code': 'WELCOME15',
          'discount_percentage': 15,
          'valid_until': DateTime.now().add(Duration(days: 30)).toIso8601String(),
        });
      }

      // 忠诚度优惠
      final totalBookings = userPreferences['total_bookings'] ?? 0;
      if (totalBookings >= 2) {
        offers.add({
          'type': 'loyalty',
          'title': 'Loyalty reward',
          'description': 'Book 3 services, get 1 free',
          'progress': totalBookings,
          'target': 3,
          'remaining': 3 - totalBookings,
        });
      }

      // 季节性优惠
      final currentMonth = DateTime.now().month;
      if (currentMonth >= 3 && currentMonth <= 5) {
        offers.add({
          'type': 'seasonal',
          'title': 'Spring cleaning special',
          'description': '20% off all cleaning services',
          'code': 'SPRING20',
          'discount_percentage': 20,
          'valid_until': DateTime.now().add(Duration(days: 60)).toIso8601String(),
        });
      }

      return offers;
    } catch (e) {
      print('Error getting personalized offers: $e');
      return [];
    }
  }

  /// 分析分类偏好
  static Map<String, dynamic> _analyzeCategoryPreferences(List<dynamic> behaviors) {
    final categoryCounts = <String, int>{};
    
    for (final behavior in behaviors) {
      final categoryId = behavior['services']?['category_level1_id']?.toString();
      if (categoryId != null) {
        categoryCounts[categoryId] = (categoryCounts[categoryId] ?? 0) + 1;
      }
    }

    if (categoryCounts.isEmpty) return {};

    final sortedCategories = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'preferred_category': sortedCategories.first.key,
      'category_distribution': categoryCounts,
    };
  }

  /// 分析价格偏好
  static Map<String, dynamic> _analyzePricePreferences(List<dynamic> behaviors) {
    final prices = <double>[];
    
    for (final behavior in behaviors) {
      final price = behavior['services']?['service_details']?[0]?['price'];
      if (price != null) {
        prices.add(price.toDouble());
      }
    }

    if (prices.isEmpty) return {};

    prices.sort();
    final avgPrice = prices.reduce((a, b) => a + b) / prices.length;
    final minPrice = prices.first;
    final maxPrice = prices.last;

    return {
      'average_price': avgPrice,
      'preferred_range': {
        'min': (avgPrice * 0.7).roundToDouble(),
        'max': (avgPrice * 1.3).roundToDouble(),
      },
      'price_range': {
        'min': minPrice,
        'max': maxPrice,
      },
    };
  }

  /// 分析评分偏好
  static Map<String, dynamic> _analyzeRatingPreferences(List<dynamic> behaviors) {
    final ratings = <double>[];
    
    for (final behavior in behaviors) {
      final rating = behavior['services']?['average_rating'];
      if (rating != null) {
        ratings.add(rating.toDouble());
      }
    }

    if (ratings.isEmpty) return {};

    final avgRating = ratings.reduce((a, b) => a + b) / ratings.length;
    final minRating = ratings.reduce((a, b) => a < b ? a : b);

    return {
      'average_rating': avgRating,
      'min_rating': minRating,
      'preferred_min_rating': (avgRating * 0.9).roundToDouble(),
    };
  }

  /// 分析时间偏好
  static Map<String, dynamic> _analyzeTimePreferences(List<dynamic> behaviors) {
    final weekdayCounts = <int, int>{};
    final hourCounts = <int, int>{};
    
    for (final behavior in behaviors) {
      final createdAt = DateTime.parse(behavior['created_at']);
      final weekday = createdAt.weekday;
      final hour = createdAt.hour;
      
      weekdayCounts[weekday] = (weekdayCounts[weekday] ?? 0) + 1;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    if (weekdayCounts.isEmpty) return {};

    final preferredWeekday = weekdayCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b).key;
    final preferredHour = hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b).key;

    return {
      'preferred_weekday': preferredWeekday,
      'preferred_hour': preferredHour,
      'weekday_distribution': weekdayCounts,
      'hour_distribution': hourCounts,
    };
  }

  /// 找到相似用户
  static Future<List<String>> _findSimilarUsers(String userId) async {
    try {
      // 获取当前用户的行为模式
      final userBehaviors = await _supabase
          .from('user_behaviors')
          .select('service_id, behavior_type')
          .eq('user_id', userId);

      if (userBehaviors.isEmpty) return [];

      // 找到有相似行为的其他用户
      final similarUsers = await _supabase
          .from('user_behaviors')
          .select('user_id')
          .inFilter('service_id', userBehaviors.map((b) => b['service_id']).toList())
          .neq('user_id', userId)
          .limit(10);

      return similarUsers.map((u) => u['user_id'] as String).toList();
    } catch (e) {
      print('Error finding similar users: $e');
      return [];
    }
  }
} 