import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

/// 轮播图数据模型
class CarouselItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? actionType; // 'service', 'category', 'url'
  final String? serviceId;
  final String? categoryId;
  final String? url;
  final bool isActive;
  final int sortOrder;
  final DateTime? startDate;
  final DateTime? endDate;

  CarouselItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.actionType,
    this.serviceId,
    this.categoryId,
    this.url,
    this.isActive = true,
    this.sortOrder = 0,
    this.startDate,
    this.endDate,
  });

  factory CarouselItem.fromJson(Map<String, dynamic> json) {
    return CarouselItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      actionType: json['action_type'],
      serviceId: json['service_id'],
      categoryId: json['category_id'],
      url: json['url'],
      isActive: json['is_active'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
    );
  }
}

/// 轮播图服务
class CarouselService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// 获取活跃的轮播图列表
  static Future<List<CarouselItem>> getActiveCarousels({int limit = 10}) async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('carousels')
          .select('*')
          .eq('is_active', true)
          .lte('start_date', now)
          .gte('end_date', now)
          .order('sort_order', ascending: true)
          .limit(limit);

      return (response as List)
          .map((json) => CarouselItem.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.info('Error fetching carousels: $e');
      // 返回默认轮播图数据
      return _getDefaultCarousels();
    }
  }

  /// 获取默认轮播图数据（当数据库查询失败时使用）
  static List<CarouselItem> _getDefaultCarousels() {
    return [
      CarouselItem(
        id: 'default_1',
        title: 'Summer Service Discount!',
        description: 'Get 20% off all cleaning services this July.',
        imageUrl: 'https://picsum.photos/id/237/800/450',
        actionType: 'category',
        categoryId: '1020000', // 家政到家
      ),
      CarouselItem(
        id: 'default_2',
        title: 'New Electrician Onboard',
        description: 'Certified electricians now available 24/7.',
        imageUrl: 'https://picsum.photos/id/1015/800/450',
        actionType: 'category',
        categoryId: '1060000', // 生活帮忙
      ),
      CarouselItem(
        id: 'default_3',
        title: 'Refer a Friend, Get \$10!',
        description: 'Invite friends to JinBean and earn rewards.',
        imageUrl: 'https://picsum.photos/id/1016/800/450',
        actionType: 'url',
        url: 'https://jinbean.com/referral',
      ),
    ];
  }
}
