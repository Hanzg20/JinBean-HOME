import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../themes/customer_theme_components.dart';

/// 智能推荐组件
/// 
/// 基于用户行为和偏好提供个性化服务推荐
class SmartRecommendationsWidget extends StatelessWidget {
  final List<SmartRecommendation> recommendations;
  final Function(String serviceId) onRecommendationTap;
  final String title;
  final String? subtitle;

  const SmartRecommendationsWidget({
    super.key,
    required this.recommendations,
    required this.onRecommendationTap,
    this.title = '为您推荐',
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return CustomerThemeComponents.buildCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          CustomerThemeComponents.buildSectionHeader(
            context: context,
            title: title,
            subtitle: subtitle ?? '基于您的偏好智能推荐',
            icon: Icons.auto_awesome,
          ),
          
          const SizedBox(height: 16),
          
          // 推荐列表
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final recommendation = recommendations[index];
                return Container(
                  width: 200,
                  margin: EdgeInsets.only(
                    right: index < recommendations.length - 1 ? 12 : 0,
                  ),
                  child: _buildRecommendationCard(context, recommendation),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, SmartRecommendation recommendation) {
    return CustomerThemeComponents.buildCard(
      context: context,
      onTap: () => onRecommendationTap(recommendation.serviceId),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 服务图片
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.8),
                    Theme.of(context).primaryColor.withOpacity(0.6),
                  ],
                ),
              ),
              child: recommendation.imageUrl != null
                  ? Image.network(
                      recommendation.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(context, recommendation),
                    )
                  : _buildPlaceholderImage(context, recommendation),
            ),
          ),
          
          // 内容区域
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 推荐标签
                  if (recommendation.reason != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        recommendation.reason!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // 服务标题
                  Text(
                    recommendation.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // 服务描述
                  Text(
                    recommendation.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const Spacer(),
                  
                  // 价格和评分
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 价格
                      Text(
                        recommendation.price,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      // 评分
                      if (recommendation.rating != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              recommendation.rating!.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context, SmartRecommendation recommendation) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.8),
            Theme.of(context).primaryColor.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          recommendation.icon ?? Icons.star,
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// 智能推荐数据模型
class SmartRecommendation {
  final String serviceId;
  final String title;
  final String description;
  final String price;
  final String? imageUrl;
  final IconData? icon;
  final double? rating;
  final String? reason; // 推荐理由
  final RecommendationType type;
  final Map<String, dynamic>? metadata;

  const SmartRecommendation({
    required this.serviceId,
    required this.title,
    required this.description,
    required this.price,
    this.imageUrl,
    this.icon,
    this.rating,
    this.reason,
    required this.type,
    this.metadata,
  });
}

/// 推荐类型枚举
enum RecommendationType {
  popular,      // 热门推荐
  personalized, // 个性化推荐
  seasonal,     // 季节性推荐
  location,     // 位置推荐
  history,      // 历史偏好
  trending,     // 趋势推荐
}

/// 推荐理由生成器
class RecommendationReasonGenerator {
  static String generateReason(RecommendationType type, {Map<String, dynamic>? context}) {
    switch (type) {
      case RecommendationType.popular:
        return '🔥 热门推荐';
      case RecommendationType.personalized:
        return '💡 为您推荐';
      case RecommendationType.seasonal:
        return '🌟 当季热门';
      case RecommendationType.location:
        return '📍 附近优质';
      case RecommendationType.history:
        return '🔄 再次预订';
      case RecommendationType.trending:
        return '📈 趋势推荐';
    }
  }
}

/// 智能推荐服务
class SmartRecommendationService {
  /// 获取个性化推荐
  static Future<List<SmartRecommendation>> getPersonalizedRecommendations({
    required String userId,
    required String industryType,
    int limit = 10,
  }) async {
    // TODO: 实现基于用户行为的推荐算法
    // 1. 分析用户历史预订
    // 2. 考虑用户偏好设置
    // 3. 结合位置和时间因素
    // 4. 应用协同过滤算法
    
    return _getMockRecommendations(industryType, limit);
  }

  /// 获取热门推荐
  static Future<List<SmartRecommendation>> getPopularRecommendations({
    required String industryType,
    int limit = 10,
  }) async {
    // TODO: 实现基于统计数据的热门推荐
    return _getMockRecommendations(industryType, limit);
  }

  /// 模拟推荐数据 (临时实现)
  static List<SmartRecommendation> _getMockRecommendations(String industryType, int limit) {
    final Map<String, List<SmartRecommendation>> mockData = {
      'home': [
        SmartRecommendation(
          serviceId: 'home_1',
          title: '专业家庭清洁',
          description: '深度清洁，让家焕然一新',
          price: '¥120起',
          rating: 4.8,
          reason: RecommendationReasonGenerator.generateReason(RecommendationType.popular),
          type: RecommendationType.popular,
          icon: Icons.cleaning_services,
        ),
        SmartRecommendation(
          serviceId: 'home_2',
          title: '水电维修服务',
          description: '专业师傅，快速上门维修',
          price: '¥80起',
          rating: 4.6,
          reason: RecommendationReasonGenerator.generateReason(RecommendationType.personalized),
          type: RecommendationType.personalized,
          icon: Icons.build,
        ),
      ],
      'transport': [
        SmartRecommendation(
          serviceId: 'transport_1',
          title: '机场专线',
          description: '舒适安全，准时到达',
          price: '¥85起',
          rating: 4.9,
          reason: RecommendationReasonGenerator.generateReason(RecommendationType.location),
          type: RecommendationType.location,
          icon: Icons.flight,
        ),
      ],
      'learning': [
        SmartRecommendation(
          serviceId: 'learning_1',
          title: '英语口语提升',
          description: '外教一对一，快速提升',
          price: '¥200/小时',
          rating: 4.7,
          reason: RecommendationReasonGenerator.generateReason(RecommendationType.trending),
          type: RecommendationType.trending,
          icon: Icons.school,
        ),
      ],
    };

    return mockData[industryType]?.take(limit).toList() ?? [];
  }
}

