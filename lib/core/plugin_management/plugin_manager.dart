import 'dart:async';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/app_plugin.dart';
import 'package:jinbeanpod_83904710/features/customer/auth/auth_plugin.dart';
import 'package:jinbeanpod_83904710/features/customer/home/home_plugin.dart';
import 'package:jinbeanpod_83904710/features/service_booking/service_booking_plugin.dart';
import 'package:jinbeanpod_83904710/features/community/community_plugin.dart';
import 'package:jinbeanpod_83904710/features/customer/profile/profile_plugin.dart';
import 'package:jinbeanpod_83904710/features/service_map/service_map_plugin.dart'; // Import ServiceMapPlugin
import 'package:jinbeanpod_83904710/features/customer/orders/orders_plugin.dart';
import 'package:jinbeanpod_83904710/app/shell_app_controller.dart';
import 'package:jinbeanpod_83904710/app/theme/app_theme_service.dart';
// TODO: 导入实际的插件文件，例如：
// import '../../features/service_booking/service_booking_plugin.dart';

class PluginManager extends GetxController {
  final RxList<AppPlugin> _registeredPlugins = <AppPlugin>[].obs;
  final RxList<PluginMetadata> _enabledPluginsMetadata = <PluginMetadata>[].obs;
  final RxBool _isInitialized = false.obs;
  final Completer<void> _initCompleter = Completer<void>();
  final RxBool isLoggedIn = false.obs;
  final RxString currentRole = 'customer'.obs;
  final RxList<PluginMetadata> enabledTabPluginsForCurrentRole =
      <PluginMetadata>[].obs;

  List<AppPlugin> get registeredPlugins => _registeredPlugins.toList();
  List<PluginMetadata> get enabledPluginsMetadata =>
      _enabledPluginsMetadata.toList();
  bool get isInitialized => _isInitialized.value;
  Future<void> get initializationComplete => _initCompleter.future;

  List<PluginMetadata> get enabledPluginsMetadataForCurrentRole =>
      _enabledPluginsMetadata
          .where((meta) => meta.role == currentRole.value)
          .toList();

  PluginManager() {
    print('[PluginManager] Constructor called. hash: [32m[1m[4m[7m${hashCode}[0m');
    ever<List<PluginMetadata>>(_enabledPluginsMetadata,
        (_) => _updateEnabledTabPluginsForCurrentRole());
    ever<String>(currentRole, (_) => _updateEnabledTabPluginsForCurrentRole());
  }

  @override
  void onInit() {
    super.onInit();
    print('[PluginManager] onInit called. hash: [32m[1m[4m[7m${hashCode}[0m');
    _fetchPluginsConfiguration();
  }

  void _registerStaticPlugins() {
    print('[PluginManager] _registerStaticPlugins called.');
    _registeredPlugins.assignAll([
      AuthPlugin(), // 注册认证插件
      HomePlugin(), // 注册 Home 插件
      ProfilePlugin(), // 注册 Profile 插件
      OrdersPlugin(), // 注册订单插件
      ServiceBookingPlugin(), // 注册服务预约插件
      CommunityPlugin(), // 注册社区插件
      ServiceMapPlugin(), // 注册服务地图插件
      // 不再注册任何 provider 端插件
    ]);
    print('[PluginManager] Static plugins registered: '
      '${_registeredPlugins.map((p) => p.metadata.id).join(', ')}');
  }

  void _updateEnabledTabPluginsForCurrentRole() {
    print('[PluginManager] _updateEnabledTabPluginsForCurrentRole called. currentRole: '
      '\x1b[33m${currentRole.value}\x1b[0m');
    if (_enabledPluginsMetadata.isEmpty) {
      print('[PluginManager] _enabledPluginsMetadata is empty, skipping update.');
      return;
    }
    print('[PluginManager] _enabledPluginsMetadata.length: ${_enabledPluginsMetadata.length}');
    final filtered = _enabledPluginsMetadata
        .where((meta) =>
            meta.role == currentRole.value && meta.type == PluginType.bottomTab)
        .toList();
    print('[PluginManager] enabledTabPluginsForCurrentRole.assignAll: '
      '${filtered.map((e) => e.id).join(',')}');
    enabledTabPluginsForCurrentRole.assignAll(filtered);
    print('[PluginManager] enabledTabPluginsForCurrentRole.length: '
      '${enabledTabPluginsForCurrentRole.length}');
    // 自动修正ShellAppController的tab index，防止越界
    try {
      final shellController = Get.find<ShellAppController>();
      shellController.setTabSafe(shellController.currentIndex, enabledTabPluginsForCurrentRole.length);
    } catch (e) {
      print('[PluginManager] ShellAppController not found or error in setTabSafe: $e');
    }
  }

  Future<void> _fetchPluginsConfiguration() async {
    print('[PluginManager] _fetchPluginsConfiguration called.');
    try {
      print('[PluginManager] _fetchPluginsConfiguration start');
      // 实际应用中，这里会调用Supabase或其他后端API
      // 获取一个Map<String, dynamic>的列表，然后转换为List<PluginMetadata>
      await Future.delayed(const Duration(seconds: 1)); // 模拟网络请求

      // 假设后端返回的配置，这里是硬编码示例
      final List<Map<String, dynamic>> backendConfig = [
        {
          'id': 'auth',
          'nameKey': 'auth_name',
          'iconName': 'person',
          'enabled': true,
          'order': 0,
          'type': PluginType.standalonePage,
          'routeName': '/auth',
          'role': 'customer',
        },
        {
          'id': 'home',
          'nameKey': 'home',
          'iconName': 'home',
          'enabled': true,
          'order': 1,
          'type': PluginType.bottomTab,
          'routeName': '/home',
          'role': 'customer',
        },
        {
          'id': 'orders',
          'nameKey': 'orders',
          'iconName': 'shopping_bag',
          'enabled': true,
          'order': 2,
          'type': PluginType.standalonePage,
          'routeName': '/orders',
          'role': 'customer',
        },
        {
          'id': 'service_booking',
          'nameKey': 'service',
          'iconName': 'calendar_today',
          'enabled': true,
          'order': 3,
          'type': PluginType.bottomTab,
          'routeName': '/service_booking',
          'role': 'customer',
        },
        {
          'id': 'community',
          'nameKey': 'community',
          'iconName': 'groups',
          'enabled': true,
          'order': 4,
          'type': PluginType.bottomTab,
          'routeName': '/community',
          'role': 'customer',
        },
        {
          'id': 'profile',
          'nameKey': 'profile',
          'iconName': 'person',
          'enabled': true,
          'order': 5,
          'type': PluginType.bottomTab,
          'routeName': '/profile',
          'role': 'customer',
        },
        // 不再包含任何 provider 端 bottomTab 配置
      ];

      _registerStaticPlugins(); // 先注册所有已知的插件

      // 根据后端配置更新插件状态
      _enabledPluginsMetadata.assignAll(
        backendConfig
            .map((json) => PluginMetadata.fromJson(json))
            .where((meta) => meta.enabled)
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order)), // 按顺序排序
      );
      print(
          '[PluginManager] _enabledPluginsMetadata after assignAll: ${_enabledPluginsMetadata.map((e) => e.id).join(',')}');
      _updateEnabledTabPluginsForCurrentRole();

      // 初始化已启用的插件
      for (var meta in _enabledPluginsMetadata) {
        final plugin = _registeredPlugins
            .firstWhereOrNull((p) => p.metadata.id == meta.id);
        if (plugin != null) {
          print('PluginManager: Initializing plugin: ${plugin.metadata.id}');
          plugin.init();
          plugin.bindings?.dependencies(); // 确保绑定被执行
          print(
              'PluginManager: Binding dependencies called for ${plugin.metadata.id}');
        }
      }

      // 注册所有启用插件的路由
      final List<GetPage> appRoutes = [];
      for (var plugin in _registeredPlugins) {
        // Only add routes for standalone pages, as bottom tabs are handled by ShellApp
        if (plugin.metadata.type == PluginType.standalonePage &&
            _enabledPluginsMetadata
                .any((meta) => meta.id == plugin.metadata.id)) {
          appRoutes.addAll(plugin.getRoutes());
        }
      }
      Get.addPages(appRoutes); // 将插件路由添加到GetX

      print('PluginManager: About to set _isInitialized to true');
      _isInitialized.value = true;
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
      print('PluginManager: _isInitialized set to true');
      print('PluginManager: 当前role: ${currentRole.value}');
      print(
          'PluginManager: enabledPluginsMetadataForCurrentRole: ${enabledPluginsMetadataForCurrentRole.map((e) => e.id).join(',')}');
      for (var meta in enabledPluginsMetadataForCurrentRole) {
        print(
            'PluginManager: id=${meta.id}, type=${meta.type}, type.runtimeType=${meta.type.runtimeType}');
      }
    } catch (e) {
      print('PluginManager: Error during _fetchPluginsConfiguration: $e');
      if (!_initCompleter.isCompleted) {
        _initCompleter.completeError(e);
      }
    }
    print('[PluginManager] _fetchPluginsConfiguration finished.');
  }

  // 获取所有已注册插件的路由
  List<GetPage> getAllPluginRoutes() {
    final List<GetPage> routes = [];
    for (var plugin in _registeredPlugins) {
      routes.addAll(plugin.getRoutes());
    }
    return routes;
  }

  // 重新加载插件配置 (例如在App启动或后端配置更新后)
  Future<void> reloadPlugins() async {
    // 销毁旧插件
    for (var meta in _enabledPluginsMetadata) {
      final plugin =
          _registeredPlugins.firstWhereOrNull((p) => p.metadata.id == meta.id);
      plugin?.dispose();
    }
    // 移除旧路由
    Get.addPages([]); // 清空现有路由，然后重新添加
    _enabledPluginsMetadata.clear();
    // 不要在这里 assignAll 空列表，等数据加载完再 assignAll
    await _fetchPluginsConfiguration();
    // _updateEnabledTabPluginsForCurrentRole(); // 由 _fetchPluginsConfiguration 结尾统一调用
    print('PluginManager: reloadPlugins后，当前role: ${currentRole.value}');
    print(
        'PluginManager: enabledPluginsMetadataForCurrentRole: ${enabledPluginsMetadataForCurrentRole.map((e) => e.id).join(',')}');
    // _isInitialized.value = true; // 只在 _fetchPluginsConfiguration 结尾赋值
  }

  void setRole(String role) {
    if (currentRole.value != role) {
      print('[PluginManager] setRole called, switching to $role');
      currentRole.value = role;
      // 切换角色时重置 tab index，防止 IndexedStack 越界
      try {
        Get.find<ShellAppController>().changeTab(0);
      } catch (e) {
        print('PluginManager: ShellAppController not found or error: $e');
      }
      reloadPlugins();
      _updateEnabledTabPluginsForCurrentRole();
      // === 新增：切换 per-role 主题 ===
      final themeService = Get.find<AppThemeService>();
      final themeName = themeService.getThemeForRole(role) ?? (role == 'provider' ? 'golden' : 'dark_teal');
      themeService.setThemeByName(themeName);
    }
  }
}
