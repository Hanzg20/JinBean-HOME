import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/plugin_management/app_plugin.dart';
import 'package:jinbeanpod_83904710/features/home/presentation/home_page.dart';
import 'package:jinbeanpod_83904710/features/home/presentation/home_binding.dart';

class HomePlugin implements AppPlugin {
  @override
  PluginMetadata get metadata => PluginMetadata(
        id: 'home',
        nameKey: 'homePageTitle', // 国际化key
        icon: Icons.home,
        enabled: true,
        order: 1, // 首页通常排在底部导航栏的第一个
        type: PluginType.bottomTab,
        routeName: '/home',
      );

  @override
  Widget buildEntryWidget() {
    return const HomePage();
  }

  @override
  List<GetPage> getRoutes() {
    return [
      GetPage(
        name: metadata.routeName!,
        page: () => const HomePage(),
        binding: HomeBinding(),
      ),
    ];
  }

  @override
  Bindings? get bindings => HomeBinding();

  @override
  void init() {
    print('HomePlugin initialized!');
  }

  @override
  void dispose() {
    print('HomePlugin disposed!');
  }
} 