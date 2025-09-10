import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'interfaces/i_authentication_service.dart';
import 'interfaces/i_service_query_service.dart';
import 'interfaces/i_service_detail_service.dart';
import 'interfaces/i_provider_service.dart';
import 'implementations/service_query_service_impl.dart';
import 'implementations/service_detail_service_impl.dart';
import 'implementations/authentication_service_impl.dart';
import 'implementations/provider_service_impl.dart';
import 'dynamic_tab_config_service.dart';

// 服务管理器 - 单例模式
class ServiceManager {
  static final ServiceManager _instance = ServiceManager._internal();
  factory ServiceManager() => _instance;
  ServiceManager._internal();

  // 服务实例
  IAuthenticationService? authService;
  IServiceQueryService? serviceQueryService;
  IServiceDetailService? serviceDetailService;
  IProviderService? providerService;

  // 动态Tab配置服务
  DynamicTabConfigService? dynamicTabConfigService;

  // 状态管理
  bool _isInitialized = false;
  bool _isInitializing = false;

  // 错误处理
  String? _lastError;
  DateTime? _lastErrorTime;

  // 获取单例实例
  static ServiceManager get instance => _instance;

  // 检查是否已初始化
  bool get isInitialized => _isInitialized;

  // 检查是否正在初始化
  bool get isInitializing => _isInitializing;

  // 获取最后错误
  String? get lastError => _lastError;

  // 获取最后错误时间
  DateTime? get lastErrorTime => _lastErrorTime;

  /// 初始化所有服务
  Future<void> initializeServices() async {
    if (_isInitialized || _isInitializing) return;

    try {
      _isInitializing = true;
      _lastError = null;
      _lastErrorTime = null;

      print('ServiceManager: 开始初始化服务...');

      // 检查Supabase连接
      await _checkSupabaseConnection();

      // 初始化各个服务
      await _initializeAuthenticationService();
      await _initializeServiceQueryService();
      await _initializeServiceDetailService();
      await _initializeProviderService();
      await _initializeDynamicTabConfigService();

      // 等待所有服务就绪
      await _waitForServicesReady();

      _isInitialized = true;
      _isInitializing = false;

      print('ServiceManager: 所有服务初始化完成 ✅');

      // 触发初始化完成事件
      Get.find<ServiceManagerState>().updateInitializationStatus(true);
    } catch (e, stackTrace) {
      _isInitializing = false;
      _lastError = e.toString();
      _lastErrorTime = DateTime.now();

      print('ServiceManager: 服务初始化失败 ❌');
      print('错误: $e');
      print('堆栈: $stackTrace');

      // 触发初始化失败事件
      Get.find<ServiceManagerState>()
          .updateInitializationStatus(false, error: e.toString());

      rethrow;
    }
  }

  /// 检查Supabase连接
  Future<void> _checkSupabaseConnection() async {
    try {
      final supabase = Supabase.instance.client;
      // 尝试简单的查询来验证连接
      await supabase.from('services').select('id').limit(1);
      print('ServiceManager: Supabase连接正常 ✅');
    } catch (e) {
      throw Exception('Supabase连接失败: $e');
    }
  }

  /// 初始化认证服务
  Future<void> _initializeAuthenticationService() async {
    try {
      // 检查是否已经初始化，避免重复初始化
      if (authService != null) {
        print('ServiceManager: 认证服务已经初始化，跳过 ✅');
        return;
      }

      authService = AuthenticationService();
      await authService!.initialize();
      print('ServiceManager: 认证服务初始化完成 ✅');
    } catch (e) {
      throw Exception('认证服务初始化失败: $e');
    }
  }

  /// 初始化服务查询服务
  Future<void> _initializeServiceQueryService() async {
    try {
      // 检查是否已经初始化，避免重复初始化
      if (serviceQueryService != null) {
        print('ServiceManager: 服务查询服务已经初始化，跳过 ✅');
        return;
      }

      serviceQueryService = ServiceQueryService();
      await serviceQueryService!.initialize();
      print('ServiceManager: 服务查询服务初始化完成 ✅');
    } catch (e) {
      throw Exception('服务查询服务初始化失败: $e');
    }
  }

  /// 初始化服务详情服务
  Future<void> _initializeServiceDetailService() async {
    try {
      print('ServiceManager: 开始初始化服务详情服务...');

      // 检查是否已经初始化，避免重复初始化
      if (serviceDetailService != null) {
        print('ServiceManager: 服务详情服务已经初始化，跳过 ✅');
        return;
      }

      serviceDetailService = ServiceDetailService();
      await serviceDetailService!.initialize();
      print('ServiceManager: 服务详情服务初始化完成 ✅');
    } catch (e) {
      print('ServiceManager: 服务详情服务初始化失败 ❌ - $e');
      throw Exception('服务详情服务初始化失败: $e');
    }
  }

  /// 初始化服务商服务
  Future<void> _initializeProviderService() async {
    try {
      // 检查是否已经初始化，避免重复初始化
      if (providerService != null) {
        print('ServiceManager: 服务商服务已经初始化，跳过 ✅');
        return;
      }

      providerService = ProviderService();
      await providerService!.initialize();
      print('ServiceManager: 服务商服务初始化完成 ✅');
    } catch (e) {
      throw Exception('服务商服务初始化失败: $e');
    }
  }

  /// 初始化动态Tab配置服务
  Future<void> _initializeDynamicTabConfigService() async {
    try {
      dynamicTabConfigService = DynamicTabConfigService();
      print('ServiceManager: 动态Tab配置服务初始化完成 ✅');
    } catch (e) {
      throw Exception('动态Tab配置服务初始化失败: $e');
    }
  }

  /// 等待所有服务就绪
  Future<void> _waitForServicesReady() async {
    // 这里可以添加服务就绪检查逻辑
    await Future.delayed(Duration(milliseconds: 100));
  }

  /// 重新初始化服务
  Future<void> reinitializeServices() async {
    _isInitialized = false;
    _isInitializing = false;
    _lastError = null;
    _lastErrorTime = null;

    await initializeServices();
  }

  /// 获取服务状态
  Map<String, dynamic> getServiceStatus() {
    return {
      'isInitialized': _isInitialized,
      'isInitializing': _isInitializing,
      'lastError': _lastError,
      'lastErrorTime': _lastErrorTime?.toIso8601String(),
      'services': {
        'authentication': _isInitialized,
        'serviceQuery': _isInitialized,
        'serviceDetail': _isInitialized,
        'provider': _isInitialized,
        'dynamicTabConfig': _isInitialized,
      }
    };
  }

  /// 健康检查
  Future<bool> healthCheck() async {
    if (!_isInitialized) return false;

    try {
      // 这里可以添加具体的健康检查逻辑
      // 例如检查数据库连接、API响应等
      return true;
    } catch (e) {
      _lastError = e.toString();
      _lastErrorTime = DateTime.now();
      return false;
    }
  }

  /// 清理资源
  Future<void> dispose() async {
    try {
      // 清理各个服务的资源
      // await authService.dispose();
      // await serviceQueryService.dispose();
      // await serviceDetailService.dispose();
      // await providerService.dispose();

      _isInitialized = false;
      _isInitializing = false;

      print('ServiceManager: 资源清理完成 ✅');
    } catch (e) {
      print('ServiceManager: 资源清理失败: $e');
    }
  }
}

// 服务管理器状态控制器
class ServiceManagerState extends GetxController {
  final _isInitialized = false.obs;
  final _isInitializing = false.obs;
  final _lastError = RxString('');
  final _lastErrorTime = Rx<DateTime?>(null);

  bool get isInitialized => _isInitialized.value;
  bool get isInitializing => _isInitializing.value;
  String get lastError => _lastError.value;
  DateTime? get lastErrorTime => _lastErrorTime.value;

  void updateInitializationStatus(bool isInitialized, {String? error}) {
    _isInitialized.value = isInitialized;
    _isInitializing.value = false;

    if (error != null) {
      _lastError.value = error;
      _lastErrorTime.value = DateTime.now();
    } else {
      _lastError.value = '';
      _lastErrorTime.value = null;
    }
  }

  void setInitializing(bool isInitializing) {
    _isInitializing.value = isInitializing;
  }

  @override
  void onInit() {
    super.onInit();
    // 自动初始化服务管理器
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ServiceManager.instance.initializeServices().catchError((error) {
        print('ServiceManagerState: 自动初始化失败 - $error');
        updateInitializationStatus(false, error: error.toString());
      });
    });
  }
}
