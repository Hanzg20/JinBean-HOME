import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:jinbeanpod_83904710/core/services/services.dart'
    as core_services;

/// 统一查询服务
/// 为所有页面提供统一的数据查询接口
class UnifiedQueryService {
  static final UnifiedQueryService _instance = UnifiedQueryService._internal();
  factory UnifiedQueryService() => _instance;
  UnifiedQueryService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  core_services.ServiceManager? _serviceManager;
  bool _isInitialized = false;

  /// 检查是否已初始化
  bool get isInitialized => _isInitialized;

  /// 初始化服务管理器
  Future<void> initialize() async {
    try {
      _serviceManager = core_services.ServiceManager.instance;
      if (!_serviceManager!.isInitialized) {
        await _serviceManager!.initializeServices();
      }
      _isInitialized = true;
      AppLogger.info('UnifiedQueryService: 初始化成功');
    } catch (e) {
      _isInitialized = false;
      AppLogger.info('UnifiedQueryService: 初始化失败 - $e');
    }
  }

  // ========================================
  // 1. 服务查询相关
  // ========================================

  /// 获取推荐服务
  Future<List<core_services.Service>> getRecommendedServices(
      {int limit = 10}) async {
    try {
      if (_serviceManager?.serviceQueryService != null) {
        return await _serviceManager!.serviceQueryService!
            .getRecommendedServices(limit: limit);
      }
      throw Exception('ServiceQueryService not available');
    } catch (e) {
      AppLogger.info('UnifiedQueryService: 获取推荐服务失败 - $e');
      return [];
    }
  }

  /// 根据ID获取服务
  Future<core_services.Service?> getServiceById(String serviceId) async {
    try {
      if (_serviceManager?.serviceQueryService != null) {
        return await _serviceManager!.serviceQueryService!
            .getServiceById(serviceId);
      }
      throw Exception('ServiceQueryService not available');
    } catch (e) {
      AppLogger.info('UnifiedQueryService: 获取服务详情失败 - $e');
      return null;
    }
  }

  /// 获取服务详情
  Future<List<core_services.ServiceDetail>> getServiceDetails(
      String serviceId) async {
    try {
      if (_serviceManager?.serviceDetailService != null) {
        return await _serviceManager!.serviceDetailService!
            .getServiceDetails(serviceId);
      }
      throw Exception('ServiceDetailService not available');
    } catch (e) {
      AppLogger.info('UnifiedQueryService: 获取服务详情失败 - $e');
      return [];
    }
  }

  /// 获取相似服务
  Future<List<core_services.Service>> getSimilarServices(String serviceId,
      {int limit = 5}) async {
    try {
      if (_serviceManager?.serviceQueryService != null) {
        return await _serviceManager!.serviceQueryService!
            .getSimilarServices(serviceId, limit: limit);
      }
      throw Exception('ServiceQueryService not available');
    } catch (e) {
      AppLogger.info('UnifiedQueryService: 获取相似服务失败 - $e');
      return [];
    }
  }

  // ========================================
  // 2. 提供商查询相关
  // ========================================

  /// 获取提供商信息
  Future<core_services.Provider?> getProviderById(String providerId) async {
    try {
      if (_serviceManager?.providerService != null) {
        return await _serviceManager!.providerService!
            .getProviderById(providerId);
      }
      throw Exception('ProviderService not available');
    } catch (e) {
      AppLogger.info('UnifiedQueryService: 获取提供商信息失败 - $e');
      return null;
    }
  }

  // ========================================
  // 3. 评价查询相关
  // ========================================

  /// 获取服务评价
  Future<List<Map<String, dynamic>>> getServiceReviews(String serviceId,
      {int limit = 10}) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('''
            *,
            user_profiles!reviews_user_id_fkey(
              id,
              display_name,
              avatar_url
            )
          ''')
          .eq('service_id', serviceId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.info('UnifiedQueryService: 获取服务评价失败 - $e');
      return [];
    }
  }

  // ========================================
  // 4. 分类查询相关
  // ========================================

  /// 获取一级分类
  Future<List<Map<String, dynamic>>> getLevel1Categories() async {
    try {
      final response = await _supabase
          .from('ref_codes')
          .select('id, name, extra_data, sort_order')
          .eq('type_code', 'SERVICE_TYPE')
          .eq('level', 1)
          .eq('status', 1)
          .order('sort_order', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.info('UnifiedQueryService: 获取一级分类失败 - $e');
      return [];
    }
  }

  /// 获取二级分类
  Future<List<Map<String, dynamic>>> getLevel2Categories(int parentId) async {
    try {
      final response = await _supabase
          .from('ref_codes')
          .select('id, name, extra_data, sort_order')
          .eq('type_code', 'SERVICE_TYPE')
          .eq('level', 2)
          .eq('parent_id', parentId)
          .eq('status', 1)
          .order('sort_order', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.info('UnifiedQueryService: 获取二级分类失败 - $e');
      return [];
    }
  }

  // ========================================
  // 5. 轮播图和热点查询
  // ========================================

  /// 获取轮播图
  Future<List<Map<String, dynamic>>> getCarousels({int limit = 5}) async {
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

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.info('UnifiedQueryService: 获取轮播图失败 - $e');
      return [];
    }
  }

  /// 获取社区热点
  Future<List<Map<String, dynamic>>> getCommunityHotspots(
      {int limit = 8}) async {
    try {
      final response = await _supabase
          .from('community_hotspots')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.info('UnifiedQueryService: 获取社区热点失败 - $e');
      return [];
    }
  }

  // ========================================
  // 6. 用户相关查询
  // ========================================

  /// 获取用户收藏服务
  Future<List<Map<String, dynamic>>> getUserSavedServices(String userId,
      {int limit = 20}) async {
    try {
      final response = await _supabase
          .from('saved_services')
          .select('''
            *,
            services!saved_services_service_id_fkey(
              id,
              title,
              description,
              price,
              currency,
              rating,
              review_count,
              images
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.info('UnifiedQueryService: 获取用户收藏服务失败 - $e');
      return [];
    }
  }

  /// 获取用户订单
  Future<List<Map<String, dynamic>>> getUserOrders(String userId,
      {int limit = 20}) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            *,
            services!orders_service_id_fkey(
              id,
              title,
              description,
              price,
              currency
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.info('UnifiedQueryService: 获取用户订单失败 - $e');
      return [];
    }
  }

  /// 获取用户评价
  Future<List<Map<String, dynamic>>> getUserReviews(String userId,
      {int limit = 20}) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('''
            *,
            services!reviews_service_id_fkey(
              id,
              title,
              description
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.info('UnifiedQueryService: 获取用户评价失败 - $e');
      return [];
    }
  }

  // ========================================
  // 7. 搜索相关
  // ========================================

  /// 搜索服务
  Future<List<core_services.Service>> searchServices(String query,
      {int limit = 20}) async {
    try {
      if (_serviceManager?.serviceQueryService != null) {
        final params = core_services.ServiceQueryParams(
          searchQuery: query,
          limit: limit,
        );
        final result =
            await _serviceManager!.serviceQueryService!.searchServices(params);
        return result.services;
      }
      throw Exception('ServiceQueryService not available');
    } catch (e) {
      AppLogger.info('UnifiedQueryService: 搜索服务失败 - $e');
      return [];
    }
  }

  // ========================================
  // 8. 工具方法
  // ========================================

  /// 获取本地化文本
  static String getLocalizedText(dynamic value, {String? locale}) {
    if (value is Map<String, dynamic>) {
      final lang = locale ?? 'zh';
      return value[lang] ?? value['zh'] ?? value['en'] ?? '';
    } else if (value is String) {
      return value;
    }
    return '';
  }

  /// 格式化日期
  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 格式化价格
  static String formatPrice(double? price, {String currency = 'CAD'}) {
    if (price == null) return 'N/A';
    return '$currency ${price.toStringAsFixed(2)}';
  }
}
