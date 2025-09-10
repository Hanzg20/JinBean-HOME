import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_logger.dart';
import '../../features/customer/domain/entities/provider_profile.dart';

/// 全局Provider查询管理器
/// 确保所有Provider查询都通过同一个公共方法，避免重复查询
class ProviderQueryManager {
  static final ProviderQueryManager _instance = ProviderQueryManager._internal();
  factory ProviderQueryManager() => _instance;
  ProviderQueryManager._internal();

  // 静态缓存
  static final Map<String, ProviderProfile> _providerCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 10);

  // 查询锁，防止重复查询
  static final Map<String, Future<ProviderProfile?>> _queryLocks = {};

  /// 全局Provider查询入口 - 唯一查询方法
  /// 所有Provider查询都必须通过这个方法
  static Future<ProviderProfile?> getProviderProfile(String providerId) async {
    // 1. 检查缓存
    final cachedProfile = _providerCache[providerId];
    final cacheTimestamp = _cacheTimestamps[providerId];
    
    if (cachedProfile != null && cacheTimestamp != null) {
      final isExpired = DateTime.now().difference(cacheTimestamp) > _cacheExpiry;
      if (!isExpired) {
        AppLogger.info('🚀 Provider全局缓存命中: $providerId');
        return cachedProfile;
      } else {
        AppLogger.info('⏰ Provider缓存过期，重新获取: $providerId');
      }
    }

    // 2. 检查查询锁
    if (_queryLocks.containsKey(providerId)) {
      AppLogger.info('🔒 Provider查询已在进行中，等待结果: $providerId');
      return await _queryLocks[providerId]!;
    }

    // 3. 创建新的查询Future
    final queryFuture = _executeProviderQuery(providerId);
    _queryLocks[providerId] = queryFuture;

    try {
      final result = await queryFuture;
      return result;
    } finally {
      // 查询完成后移除锁
      _queryLocks.remove(providerId);
    }
  }

  /// 执行实际的Provider查询
  static Future<ProviderProfile?> _executeProviderQuery(String providerId) async {
    try {
      AppLogger.info('🔍 开始全局Provider查询: $providerId');
      
      final supabase = Supabase.instance.client;
      
      // 根据实际表结构查询
      final response = await supabase
          .from('provider_profiles')
          .select('''
            id,
            user_id,
            display_name,
            bio,
            avatar_url,
            phone,
            email,
            rating,
            review_count,
            is_verified,
            experience_years,
            tags,
            provider_type,
            created_at,
            updated_at
          ''')
          .eq('id', providerId)
          .maybeSingle();

      if (response == null) {
        AppLogger.warning('⚠️ Provider未找到: $providerId');
        return null;
      }

      AppLogger.info('✅ Provider查询成功: $providerId');

      // 转换为ProviderProfile对象
      final providerProfile = ProviderProfile(
        id: response['id'] as String,
        name: _extractDisplayName(response['display_name']),
        description: _extractBio(response['bio']),
        avatar: response['avatar_url'] as String?,
        phone: response['phone'] as String?,
        email: response['email'] as String?,
        rating: (response['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: response['review_count'] as int? ?? 0,
        isVerified: response['is_verified'] as bool? ?? false,
        metadata: {
          'experience_years': response['experience_years'] as int? ?? 0,
          'tags': response['tags'] as List<dynamic>? ?? [],
          'provider_type': response['provider_type'] as String? ?? 'individual',
        },
        createdAt: response['created_at'] != null 
            ? DateTime.parse(response['created_at'].toString())
            : null,
      );

      // 更新缓存
      _providerCache[providerId] = providerProfile;
      _cacheTimestamps[providerId] = DateTime.now();

      AppLogger.info('💾 Provider数据已缓存: $providerId');
      return providerProfile;

    } catch (e) {
      AppLogger.error('❌ Provider查询失败: $providerId - $e');
      return null;
    }
  }

  /// 提取显示名称
  static String _extractDisplayName(dynamic displayName) {
    if (displayName is Map<String, dynamic>) {
      return displayName['zh'] ?? displayName['en'] ?? 'Unknown Provider';
    }
    return displayName?.toString() ?? 'Unknown Provider';
  }

  /// 提取简介
  static String? _extractBio(dynamic bio) {
    if (bio is Map<String, dynamic>) {
      return bio['zh'] ?? bio['en'];
    }
    return bio?.toString();
  }

  /// 清除缓存
  static void clearCache() {
    _providerCache.clear();
    _cacheTimestamps.clear();
    AppLogger.info('🧹 Provider缓存已清除');
  }

  /// 获取缓存统计
  static Map<String, dynamic> getCacheStats() {
    return {
      'cache_size': _providerCache.length,
      'lock_size': _queryLocks.length,
      'cached_providers': _providerCache.keys.toList(),
    };
  }
}
