import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/app_plugin.dart';
import 'rob_order_hall_page.dart';

class RobOrderHallPlugin extends AppPlugin {
  @override
  PluginMetadata get metadata => PluginMetadata(
    id: 'rob_order_hall',
    nameKey: 'rob_order_hall',
    icon: Icons.campaign,
    enabled: true,
    order: 4,
    type: PluginType.bottomTab,
    routeName: '/provider/rob_order_hall',
    role: 'provider',
  );

  @override
  List<GetPage> getRoutes() => [
    GetPage(
      name: '/provider/rob_order_hall',
      page: () => const RobOrderHallPage(),
    ),
  ];

  @override
  Widget buildEntryWidget() => const RobOrderHallPage();

  @override
  void init() {}
  @override
  void dispose() {}
} 