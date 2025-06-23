import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/plugin_management/app_plugin.dart';
import 'package:jinbeanpod_83904710/features/auth/presentation/login_page.dart';
import 'package:jinbeanpod_83904710/features/auth/presentation/auth_binding.dart';
import 'package:jinbeanpod_83904710/features/auth/presentation/register_page.dart';

class AuthPlugin implements AppPlugin {
  @override
  PluginMetadata get metadata => PluginMetadata(
        id: 'auth',
        nameKey: 'auth_name', // 国际化key
        icon: Icons.person,
        enabled: true,
        order: 0,
        type: PluginType.standalonePage, // 认证作为独立页面
        routeName: '/auth',
      );

  @override
  Widget buildEntryWidget() {
    // 对于standalonePage类型，这个方法可能不会直接用于构建UI，
    // 而是通过路由跳转到其页面。
    return const LoginPage(); // 返回登录页作为入口（待实现）
  }

  @override
  List<GetPage> getRoutes() {
    return [
      GetPage(
        name: metadata.routeName!,
        page: () => const LoginPage(),
        binding: AuthBinding(),
      ),
      GetPage(name: '/auth/register', page: () => const RegisterPage()),
    ];
  }

  @override
  Bindings? get bindings => AuthBinding();

  @override
  void init() {
    print('AuthPlugin initialized!');
  }

  @override
  void dispose() {
    print('AuthPlugin disposed!');
  }
} 