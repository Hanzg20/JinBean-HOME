import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/app_plugin.dart';
import 'package:jinbeanpod_83904710/features/customer/profile/presentation/profile_binding.dart';
import 'package:jinbeanpod_83904710/features/customer/profile/presentation/profile_page.dart';

class ProfilePlugin extends AppPlugin {
  @override
  PluginMetadata get metadata => PluginMetadata(
        id: 'profile',
        nameKey: 'profile',
        icon: Icons.person,
        enabled: true,
        order: 6, // Assuming order 6 for Profile
        type: PluginType.bottomTab,
        routeName: '/provider/profile',
        role: 'provider',
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