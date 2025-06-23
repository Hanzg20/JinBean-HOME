import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/app_plugin.dart';
import 'package:jinbeanpod_83904710/features/community/presentation/community_binding.dart';
import 'package:jinbeanpod_83904710/features/community/presentation/community_page.dart';

class CommunityPlugin extends AppPlugin {
  @override
  PluginMetadata get metadata => PluginMetadata(
        id: 'community',
        nameKey: 'community_name',
        icon: Icons.groups,
        enabled: true,
        order: 3, // Assuming order 3 for Community, after Home (1) and Service Booking (2)
        type: PluginType.bottomTab,
        routeName: '/community',
      );

  @override
  Widget buildEntryWidget() {
    return const CommunityPage();
  }

  @override
  List<GetPage> getRoutes() {
    return [
      GetPage(
        name: metadata.routeName!,
        page: () => const CommunityPage(),
        binding: CommunityBinding(),
      ),
    ];
  }

  @override
  Bindings? get bindings => CommunityBinding();

  @override
  void init() {
    print('CommunityPlugin initialized');
  }

  @override
  void dispose() {
    print('CommunityPlugin disposed');
  }
} 