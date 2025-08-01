import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/app_plugin.dart';
import 'presentation/service_manage_page.dart';

class ServiceManagePlugin extends AppPlugin {
  @override
  PluginMetadata get metadata => PluginMetadata(
    id: 'service_manage',
    nameKey: 'service_manage',
    icon: Icons.build,
    enabled: true,
    order: 2,
    type: PluginType.standalonePage,
    routeName: '/provider/service_manage',
    role: 'provider',
  );

  @override
  List<GetPage> getRoutes() => [
    GetPage(
      name: '/provider/service_manage',
      page: () => const ServiceManagePage(),
    ),
  ];

  @override
  Widget buildEntryWidget() => const ServiceManagePage();

  @override
  void init() {}
  @override
  void dispose() {}
} 