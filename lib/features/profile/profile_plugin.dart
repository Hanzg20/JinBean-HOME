import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/app_plugin.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/profile_binding.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/profile_page.dart';

class ProfilePlugin extends AppPlugin {
  @override
  PluginMetadata get metadata => PluginMetadata(
        id: 'profile',
        nameKey: 'profile',
        icon: Icons.person,
        enabled: true,
        order: 4, // Assuming order 4 for Profile
        type: PluginType.bottomTab,
        routeName: '/profile',
      );

  @override
  Widget buildEntryWidget() {
    return const ProfilePage();
  }

  @override
  List<GetPage> getRoutes() {
    return [
      GetPage(
        name: metadata.routeName!,
        page: () => const ProfilePage(),
        binding: ProfileBinding(),
      ),
    ];
  }

  @override
  Bindings? get bindings => ProfileBinding();

  @override
  void init() {
    print('ProfilePlugin initialized');
  }

  @override
  void dispose() {
    print('ProfilePlugin disposed');
  }
} 