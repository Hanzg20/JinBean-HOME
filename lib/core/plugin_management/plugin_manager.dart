import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_plugin.dart';
import 'package:jinbeanpod_83904710/features/auth/auth_plugin.dart'; // 导入 AuthPlugin
import 'package:jinbeanpod_83904710/features/home/home_plugin.dart'; // 导入 HomePlugin
import 'package:jinbeanpod_83904710/features/service_booking/service_booking_plugin.dart'; // 导入 ServiceBookingPlugin
import 'package:jinbeanpod_83904710/features/community/community_plugin.dart'; // 导入 CommunityPlugin
import 'package:jinbeanpod_83904710/features/profile/profile_plugin.dart'; // 导入 ProfilePlugin
// TODO: 导入实际的插件文件，例如：
// import '../../features/service_booking/service_booking_plugin.dart';

class PluginManager extends GetxController {
  final RxList<AppPlugin> _registeredPlugins = <AppPlugin>[].obs;
  final RxList<PluginMetadata> _enabledPluginsMetadata = <PluginMetadata>[].obs;
  final RxBool _isInitialized = false.obs;
  final Completer<void> _initCompleter = Completer<void>();
  final RxBool isLoggedIn = false.obs;

  List<AppPlugin> get registeredPlugins => _registeredPlugins.toList();
  List<PluginMetadata> get enabledPluginsMetadata => _enabledPluginsMetadata.toList();
  bool get isInitialized => _isInitialized.value;
  Future<void> get initializationComplete => _initCompleter.future;

  @override
  void onInit() {
    super.onInit();
    // 假设这里从后端获取插件配置
    _fetchPluginsConfiguration();
  }

  // 注册所有静态定义的插件
  void _registerStaticPlugins() {
    _registeredPlugins.assignAll([
      AuthPlugin(), // 注册认证插件
      HomePlugin(), // 注册 Home 插件
      ServiceBookingPlugin(), // 注册 Service Booking 插件
      CommunityPlugin(), // 注册 Community 插件
      ProfilePlugin(), // 注册 Profile 插件
      // TODO: 在这里添加你的其他插件实例
      // ToolRentalPlugin(),
    ]);
  }

  // 从后端获取插件配置
  Future<void> _fetchPluginsConfiguration() async {
    try {
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
          'type': 'standalonePage',
          'routeName': '/auth',
        },
        {
          'id': 'home',
          'nameKey': 'home',
          'iconName': 'home',
          'enabled': true,
          'order': 1,
          'type': 'bottomTab',
          'routeName': '/home',
        },
        {
          'id': 'service_booking',
          'nameKey': 'service',
          'iconName': 'calendar_today',
          'enabled': true,
          'order': 2,
          'type': 'bottomTab',
          'routeName': '/service_booking',
        },
        {
          'id': 'community',
          'nameKey': 'community',
          'iconName': 'groups',
          'enabled': true,
          'order': 3,
          'type': 'bottomTab',
          'routeName': '/community',
        },
        {
          'id': 'profile',
          'nameKey': 'profile',
          'iconName': 'person',
          'enabled': true,
          'order': 4,
          'type': 'bottomTab',
          'routeName': '/profile',
        },
        // ... 其他插件配置
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

      // 初始化已启用的插件
      for (var meta in _enabledPluginsMetadata) {
        final plugin = _registeredPlugins.firstWhereOrNull((p) => p.metadata.id == meta.id);
        if (plugin != null) {
          print('PluginManager: Initializing plugin: ${plugin.metadata.id}');
          plugin.init();
          plugin.bindings?.dependencies(); // 确保绑定被执行
          print('PluginManager: Binding dependencies called for ${plugin.metadata.id}');
        }
      }

      // 注册所有启用插件的路由
      final List<GetPage> appRoutes = [];
      for (var plugin in _registeredPlugins) {
        // Only add routes for standalone pages, as bottom tabs are handled by ShellApp
        if (plugin.metadata.type == PluginType.standalonePage && _enabledPluginsMetadata.any((meta) => meta.id == plugin.metadata.id)) {
          appRoutes.addAll(plugin.getRoutes());
        }
      }
      Get.addPages(appRoutes); // 将插件路由添加到GetX

      print('PluginManager: About to set _isInitialized to true');
      _isInitialized.value = true;
      _initCompleter.complete();
      print('PluginManager: _isInitialized set to true');
    } catch (e) {
      print('PluginManager: Error during _fetchPluginsConfiguration: $e');
      _initCompleter.completeError(e);
    }
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
      final plugin = _registeredPlugins.firstWhereOrNull((p) => p.metadata.id == meta.id);
      plugin?.dispose();
    }
    // 移除旧路由
    Get.addPages([]); // 清空现有路由，然后重新添加
    _enabledPluginsMetadata.clear();
    await _fetchPluginsConfiguration();
  }
} 