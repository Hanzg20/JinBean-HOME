import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/app_plugin.dart';
import 'message_center_page.dart';

class MessageCenterPlugin extends AppPlugin {
  @override
  PluginMetadata get metadata => PluginMetadata(
    id: 'message_center',
    nameKey: 'message_center',
    icon: Icons.message,
    enabled: true,
    order: 5,
    type: PluginType.bottomTab,
    routeName: '/provider/message_center',
    role: 'provider',
  );

  @override
  List<GetPage> getRoutes() => [
    GetPage(
      name: '/provider/message_center',
      page: () => const MessageCenterPage(),
    ),
  ];

  @override
  Widget buildEntryWidget() => const MessageCenterPage();

  @override
  void init() {}
  @override
  void dispose() {}
} 