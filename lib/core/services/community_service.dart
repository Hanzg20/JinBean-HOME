import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

/// 社区热点数据模型
class HotspotItem {
  final String id;
  final String type; // 'NEWS', 'JOB', 'BENEFIT', 'EVENT'
  final String title;
  final String? description;
  final String? time;
  final String? publisher;
  final String? imageUrl;
  final String? actionUrl;
  final bool isActive;
  final DateTime createdAt;

  HotspotItem({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.time,
    this.publisher,
    this.imageUrl,
    this.actionUrl,
    this.isActive = true,
    required this.createdAt,
  });

  factory HotspotItem.fromJson(Map<String, dynamic> json) {
    return HotspotItem(
      id: json['id'] ?? '',
      type: json['type'] ?? 'NEWS',
      title: json['title'] ?? '',
      description: json['description'],
      time: json['time'],
      publisher: json['publisher'],
      imageUrl: json['image_url'],
      actionUrl: json['action_url'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  /// 获取相对时间显示
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

/// 社区热点服务
class CommunityService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// 获取社区热点列表
  static Future<List<HotspotItem>> getHotspots({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('community_hotspots')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => HotspotItem.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.info('Error fetching community hotspots: $e');
      // 返回默认热点数据
      return _getDefaultHotspots();
    }
  }

  /// 获取默认热点数据（当数据库查询失败时使用）
  static List<HotspotItem> _getDefaultHotspots() {
    final now = DateTime.now();
    return [
      HotspotItem(
        id: 'default_1',
        type: 'NEWS',
        title: 'XXX社区：本周末举行亲子活动',
        description: '社区将举办亲子互动活动，欢迎家长和孩子们参加',
        publisher: '社区管理委员会',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      HotspotItem(
        id: 'default_2',
        type: 'JOB',
        title: '急聘！社区保安，待遇从优',
        description: '招聘社区保安，要求身体健康，责任心强',
        publisher: '物业公司',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      HotspotItem(
        id: 'default_3',
        type: 'BENEFIT',
        title: '长者免费体检活动即将开始',
        description: '为社区65岁以上长者提供免费健康体检',
        publisher: '社区卫生服务中心',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      HotspotItem(
        id: 'default_4',
        type: 'NEWS',
        title: '社区图书馆扩建通知',
        description: '社区图书馆将进行扩建，预计工期3个月',
        publisher: '社区管理委员会',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ];
  }

  /// 记录热点点击
  static Future<void> recordHotspotClick(String hotspotId) async {
    try {
      await _supabase.from('hotspot_clicks').insert({
        'hotspot_id': hotspotId,
        'clicked_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      AppLogger.info('Error recording hotspot click: $e');
      // 不抛出异常，避免影响用户体验
    }
  }
}
