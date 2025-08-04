import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/app_plugin.dart';
import 'package:jinbeanpod_83904710/app/shell_app_controller.dart';
import '../../provider_home_page.dart';

class ProviderHomePlugin extends AppPlugin {
  @override
  PluginMetadata get metadata => PluginMetadata(
    id: 'provider_home',
    nameKey: 'provider_home',
    icon: Icons.dashboard,
    enabled: true,
    order: 1,
    type: PluginType.bottomTab,
    routeName: '/provider/home',
    role: 'provider',
  );

  @override
  List<GetPage> getRoutes() => [
    GetPage(
      name: '/provider/home',
      page: () => ProviderHomePage(onNavigateToTab: (index) {
        // 使用GetX的tab控制器来切换页面
        final controller = Get.find<ShellAppController>();
        controller.changeTab(index);
      }),
    ),
  ];

  @override
  Widget buildEntryWidget() => ProviderHomePage(onNavigateToTab: (index) {
    // 使用GetX的tab控制器来切换页面
    final controller = Get.find<ShellAppController>();
    controller.changeTab(index);
  });

  @override
  void init() {
    print('ProviderHomePlugin initialized');
  }

  @override
  void dispose() {
    print('ProviderHomePlugin disposed');
  }
} 