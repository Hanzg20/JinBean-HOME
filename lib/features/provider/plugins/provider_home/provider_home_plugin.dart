import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/app_plugin.dart';
import '../../provider_home_page.dart';

class ProviderHomePlugin extends AppPlugin {
  @override
  PluginMetadata get metadata => PluginMetadata(
    id: 'provider_home',
    nameKey: 'provider_home',
    icon: Icons.home,
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
      page: () => ProviderHomePage(onNavigateToTab: (index) {}), // Provide empty function
    ),
  ];

  @override
  Widget buildEntryWidget() => ProviderHomePage(onNavigateToTab: (index) {}); // Provide empty function

  @override
  void init() {
    print('ProviderHomePlugin initialized');
  }

  @override
  void dispose() {
    print('ProviderHomePlugin disposed');
  }
} 