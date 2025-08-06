import 'dart:math';
import 'package:jinbeanpod_83904710/features/customer/domain/entities/service.dart';
import 'package:jinbeanpod_83904710/features/customer/domain/entities/service_detail.dart';
import 'package:jinbeanpod_83904710/features/customer/domain/entities/similar_service.dart';
import 'package:jinbeanpod_83904710/features/customer/services/presentation/service_detail_controller.dart';

class SimilarityCalculatorService {
  /// 计算两个服务之间的相似度
  /// 返回0-1之间的相似度分数
  static double calculateSimilarity(Service service1, Service service2) {
    double score = 0.0;
    
    // 分类相似度 (40%)
    score += _calculateCategorySimilarity(service1, service2) * 0.4;
    
    // 价格相似度 (20%)
    score += _calculatePriceSimilarity(service1, service2) * 0.2;
    
    // 位置相似度 (20%)
    score += _calculateLocationSimilarity(service1, service2) * 0.2;
    
    // 标签相似度 (20%)
    score += _calculateTagSimilarity(service1, service2) * 0.2;
    
    return score.clamp(0.0, 1.0);
  }
  
  /// 计算分类相似度
  static double _calculateCategorySimilarity(Service service1, Service service2) {
    double score = 0.0;
    
    // 一级分类匹配
    if (service1.categoryId == service2.categoryId) {
      score += 0.4;
    }
    
    // 二级分类匹配
    if (service1.categoryLevel2Id == service2.categoryLevel2Id) {
      score += 0.3;
    }
    
    return score;
  }
  
  /// 计算价格相似度
  static double _calculatePriceSimilarity(Service service1, Service service2) {
    // 这里需要从ServiceDetail中获取价格信息
    // 暂时返回默认值
    return 0.5;
  }
  
  /// 计算位置相似度
  static double _calculateLocationSimilarity(Service service1, Service service2) {
    // 这里需要从ProviderProfile中获取位置信息
    // 暂时返回默认值
    return 0.5;
  }
  
  /// 计算标签相似度
  static double _calculateTagSimilarity(Service service1, Service service2) {
    // 这里需要从ServiceDetail中获取标签信息
    // 暂时返回默认值
    return 0.5;
  }
  
  /// 计算评分相似度
  static double _calculateRatingSimilarity(Service service1, Service service2) {
    double score = 0.0;
    
    // 评分差异计算
    final rating1 = service1.rating ?? 0.0;
    final rating2 = service2.rating ?? 0.0;
    
    final ratingDiff = (rating1 - rating2).abs();
    if (ratingDiff <= 0.5) {
      score += 0.3;
    } else if (ratingDiff <= 1.0) {
      score += 0.2;
    }
    
    // 状态匹配
    final isActive1 = service1.isActive ?? false;
    final isActive2 = service2.isActive ?? false;
    if (isActive1 == isActive2) {
      score += 0.1;
    }
    
    return score;
  }
  
  /// 计算距离（使用Haversine公式）
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // 地球半径（公里）
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
               cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
               sin(dLon / 2) * sin(dLon / 2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  /// 角度转弧度
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
  
  /// 获取相似服务的优势和劣势
  static Map<String, List<String>> getAdvantagesAndDisadvantages(
    Service currentService, 
    Service similarService,
    ServiceDetail? currentDetail,
    ServiceDetail? similarDetail,
  ) {
    List<String> advantages = [];
    List<String> disadvantages = [];
    
    // 价格比较
    if (currentDetail?.price != null && similarDetail?.price != null) {
      if (similarDetail!.price! < currentDetail!.price!) {
        advantages.add('Lower price');
      } else if (similarDetail.price! > currentDetail.price!) {
        disadvantages.add('Higher price');
      }
    }
    
    // 评分比较
    final currentRating = currentService.rating ?? 0.0;
    final similarRating = similarService.rating ?? 0.0;
    if (similarRating > currentRating) {
      advantages.add('Higher rating');
    } else if (similarRating < currentRating) {
      disadvantages.add('Lower rating');
    }
    
    // 评价数量比较
    final currentReviewCount = currentService.reviewCount ?? 0;
    final similarReviewCount = similarService.reviewCount ?? 0;
    if (similarReviewCount > currentReviewCount) {
      advantages.add('More reviews');
    } else if (similarReviewCount < currentReviewCount) {
      disadvantages.add('Fewer reviews');
    }
    
    // 服务状态比较
    final currentIsActive = currentService.isActive ?? false;
    final similarIsActive = similarService.isActive ?? false;
    if (similarIsActive && !currentIsActive) {
      advantages.add('Currently available');
    }
    
    return {
      'advantages': advantages,
      'disadvantages': disadvantages,
    };
  }
  
  /// 根据相似度分数排序服务列表
  static List<SimilarService> sortBySimilarity(List<SimilarService> services) {
    services.sort((a, b) => (b.similarityScore ?? 0.0).compareTo(a.similarityScore ?? 0.0));
    return services;
  }
  
  /// 过滤相似度分数低于阈值的服务
  static List<SimilarService> filterBySimilarityThreshold(
    List<SimilarService> services, 
    double threshold
  ) {
    return services.where((service) => (service.similarityScore ?? 0.0) >= threshold).toList();
  }
} 