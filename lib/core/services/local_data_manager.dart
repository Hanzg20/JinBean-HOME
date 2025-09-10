import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_logger.dart';
import '../../features/customer/domain/entities/service.dart';
import '../../features/customer/domain/entities/service_detail.dart';
import '../../features/customer/domain/entities/provider_profile.dart';

/// 本地数据管理器 - 本地优先架构
/// 完全避免网络请求延迟，提供即时响应
class LocalDataManager {
  static final LocalDataManager _instance = LocalDataManager._internal();
  factory LocalDataManager() => _instance;
  LocalDataManager._internal();

  // 本地数据存储
  static final Map<String, Service> _localServices = {};
  static final Map<String, ServiceDetail> _localServiceDetails = {};
  static final Map<String, ProviderProfile> _localProviders = {};

  // 数据加载状态
  static final Map<String, bool> _loadingStates = {};
  static final Map<String, Future<void>> _loadingFutures = {};

  /// 初始化本地数据 - 预加载所有必要数据
  static Future<void> initializeLocalData() async {
    try {
      AppLogger.info('[LocalDataManager] 🚀 开始初始化本地数据');
      
      // 预加载所有服务数据
      AppLogger.info('[LocalDataManager] 📦 开始预加载服务数据...');
      await _preloadAllServices();
      
      // 预加载所有服务详情
      AppLogger.info('[LocalDataManager] 📦 开始预加载服务详情数据...');
      await _preloadAllServiceDetails();
      
      // 预加载所有提供商数据
      AppLogger.info('[LocalDataManager] 📦 开始预加载提供商数据...');
      await _preloadAllProviders();
      
      AppLogger.info('[LocalDataManager] ✅ 本地数据初始化完成 - 服务: ${_localServices.length}, 详情: ${_localServiceDetails.length}, 提供商: ${_localProviders.length}');
    } catch (e) {
      AppLogger.error('[LocalDataManager] ❌ 本地数据初始化失败: $e');
      rethrow;
    }
  }

  /// 预加载所有服务数据
  static Future<void> _preloadAllServices() async {
    try {
      final response = await Supabase.instance.client
          .from('services')
          .select('id, title, description, category_level1_id, provider_id, status, created_at, updated_at')
          .limit(100); // 限制数量避免内存过大

      for (final data in response) {
        final service = Service.fromJson(data);
        _localServices[service.id] = service;
      }
      
      AppLogger.info('[LocalDataManager] ✅ 预加载服务数据完成: ${_localServices.length} 个');
    } catch (e) {
      AppLogger.error('[LocalDataManager] ❌ 预加载服务数据失败: $e');
    }
  }

  /// 预加载所有服务详情数据
  static Future<void> _preloadAllServiceDetails() async {
    try {
      final response = await Supabase.instance.client
          .from('service_details')
          .select('id, service_id, name, description, price, duration, is_active, created_at, updated_at, category, sub_category, current_stock, max_stock')
          .limit(500); // 限制数量避免内存过大

      for (final data in response) {
        final serviceDetail = ServiceDetail.fromJson(data);
        _localServiceDetails[serviceDetail.id] = serviceDetail;
      }
      
      AppLogger.info('[LocalDataManager] ✅ 预加载服务详情数据完成: ${_localServiceDetails.length} 个');
    } catch (e) {
      AppLogger.error('[LocalDataManager] ❌ 预加载服务详情数据失败: $e');
    }
  }

  /// 预加载所有提供商数据
  static Future<void> _preloadAllProviders() async {
    try {
      final response = await Supabase.instance.client
          .from('provider_profiles')
          .select('id, display_name, description, avatar_url, is_certified, metadata, created_at, updated_at')
          .limit(50); // 限制数量避免内存过大

      for (final data in response) {
        final provider = ProviderProfile.fromJson(data);
        _localProviders[provider.id] = provider;
      }
      
      AppLogger.info('[LocalDataManager] ✅ 预加载提供商数据完成: ${_localProviders.length} 个');
    } catch (e) {
      AppLogger.error('[LocalDataManager] ❌ 预加载提供商数据失败: $e');
    }
  }

  /// 获取服务数据 - 本地优先
  static Service? getService(String serviceId) {
    final service = _localServices[serviceId];
    if (service != null) {
      AppLogger.info('[LocalDataManager] 🚀 本地服务数据命中: $serviceId');
      return service;
    }
    
    AppLogger.warning('[LocalDataManager] ⚠️ 本地服务数据未找到: $serviceId');
    return null;
  }

  /// 获取服务详情数据 - 本地优先
  static ServiceDetail? getServiceDetail(String serviceDetailId) {
    final serviceDetail = _localServiceDetails[serviceDetailId];
    if (serviceDetail != null) {
      AppLogger.info('[LocalDataManager] 🚀 本地服务详情数据命中: $serviceDetailId');
      return serviceDetail;
    }
    
    AppLogger.warning('[LocalDataManager] ⚠️ 本地服务详情数据未找到: $serviceDetailId');
    return null;
  }

  /// 获取提供商数据 - 本地优先
  static ProviderProfile? getProvider(String providerId) {
    final provider = _localProviders[providerId];
    if (provider != null) {
      AppLogger.info('[LocalDataManager] 🚀 本地提供商数据命中: $providerId');
      return provider;
    }
    
    AppLogger.warning('[LocalDataManager] ⚠️ 本地提供商数据未找到: $providerId');
    return null;
  }

  /// 检查数据是否可用
  static bool hasService(String serviceId) => _localServices.containsKey(serviceId);
  static bool hasServiceDetail(String serviceDetailId) => _localServiceDetails.containsKey(serviceDetailId);
  static bool hasProvider(String providerId) => _localProviders.containsKey(providerId);

  /// 获取所有服务ID列表
  static List<String> getAllServiceIds() => _localServices.keys.toList();
  
  /// 获取所有服务详情ID列表
  static List<String> getAllServiceDetailIds() => _localServiceDetails.keys.toList();
  
  /// 获取所有提供商ID列表
  static List<String> getAllProviderIds() => _localProviders.keys.toList();

  /// 刷新本地数据
  static Future<void> refreshLocalData() async {
    AppLogger.info('[LocalDataManager] 🔄 开始刷新本地数据');
    
    // 清空现有数据
    _localServices.clear();
    _localServiceDetails.clear();
    _localProviders.clear();
    
    // 重新加载
    await initializeLocalData();
    
    AppLogger.info('[LocalDataManager] ✅ 本地数据刷新完成');
  }

  /// 测试本地数据状态
  static void testLocalDataStatus() {
    AppLogger.info('[LocalDataManager] 🧪 本地数据状态测试');
    AppLogger.info('[LocalDataManager] 📊 服务数据: ${_localServices.length} 个');
    AppLogger.info('[LocalDataManager] 📊 服务详情数据: ${_localServiceDetails.length} 个');
    AppLogger.info('[LocalDataManager] 📊 提供商数据: ${_localProviders.length} 个');
    
    if (_localServices.isNotEmpty) {
      final firstServiceId = _localServices.keys.first;
      AppLogger.info('[LocalDataManager] 🎯 示例服务ID: $firstServiceId');
    }
    
    if (_localServiceDetails.isNotEmpty) {
      final firstDetailId = _localServiceDetails.keys.first;
      AppLogger.info('[LocalDataManager] 🎯 示例服务详情ID: $firstDetailId');
    }
    
    if (_localProviders.isNotEmpty) {
      final firstProviderId = _localProviders.keys.first;
      AppLogger.info('[LocalDataManager] 🎯 示例提供商ID: $firstProviderId');
    }
  }
}
