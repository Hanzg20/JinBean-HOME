import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/app_plugin.dart';
import 'order_manage_page.dart';

class OrderManagePlugin extends AppPlugin {
  @override
  PluginMetadata get metadata => PluginMetadata(
    id: 'order_manage',
    nameKey: 'order_manage',
    icon: Icons.assignment,
    enabled: true,
    order: 3,
    type: PluginType.bottomTab,
    routeName: '/provider/order_manage',
    role: 'provider',
  );

  @override
  List<GetPage> getRoutes() => [
    GetPage(
      name: '/provider/order_manage',
      page: () => const OrderManagePage(),
    ),
  ];

  @override
  Widget buildEntryWidget() => const OrderManagePage();

  @override
  void init() {}
  @override
  void dispose() {}
} 