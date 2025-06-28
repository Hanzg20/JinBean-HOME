import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/plugin_management/app_plugin.dart';
import 'service_map_page.dart';

class ServiceMapPlugin implements AppPlugin {
  @override
  PluginMetadata get metadata => PluginMetadata(
        id: 'service_map',
        nameKey: 'service_map', // 需在多语言文件中添加
        icon: Icons.map,
        enabled: true,
        order: 5, // 可根据实际顺序调整
        type: PluginType.bottomTab,
        routeName: '/service_map',
      );

  @override
  Widget buildEntryWidget() {
    return const ServiceMapPage();
  }

  @override
  List<GetPage> getRoutes() {
    return [
      GetPage(
        name: metadata.routeName!,
        page: () => const ServiceMapPage(),
      ),
    ];
  }

  @override
  Bindings? get bindings => null;

  @override
  void init() {
    print('ServiceMapPlugin initialized!');
  }

  @override
  void dispose() {
    print('ServiceMapPlugin disposed!');
  }
} 