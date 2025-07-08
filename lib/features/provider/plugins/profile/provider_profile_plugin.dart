import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/app_plugin.dart';

class ProviderProfilePlugin extends AppPlugin {
  @override
  PluginMetadata get metadata => PluginMetadata(
        id: 'profile',
        nameKey: 'profile',
        icon: Icons.person,
        enabled: true,
        order: 6,
        type: PluginType.bottomTab,
        routeName: '/provider/profile',
        role: 'provider',
      );

  @override
  Widget buildEntryWidget() => const ProviderProfilePage();

  @override
  List<GetPage> getRoutes() => [
        GetPage(
          name: '/provider/profile',
          page: () => const ProviderProfilePage(),
        ),
      ];

  @override
  void init() {}
  @override
  void dispose() {}
}

class ProviderProfilePage extends StatelessWidget {
  const ProviderProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Provider Profile Page'));
  }
}
