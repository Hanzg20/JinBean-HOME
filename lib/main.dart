import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/shell_app.dart';
import 'features/provider/provider_home_page.dart';
import 'package:jinbeanpod_83904710/features/customer/auth/presentation/login_page.dart';
import 'package:get/get.dart';
import 'features/customer/auth/presentation/auth_controller.dart';
import 'config/app_config.dart';
import 'package:jinbeanpod_83904710/app/theme/app_theme_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jinbeanpod_83904710/l10n/generated/app_localizations.dart';
import 'core/plugin_management/plugin_manager.dart';
import 'app/shell_app_controller.dart';
import 'core/controllers/location_controller.dart';
import 'features/demo/address_input_demo_page.dart';
import 'package:jinbeanpod_83904710/features/customer/splash/presentation/splash_page.dart';
import 'package:jinbeanpod_83904710/features/customer/splash/presentation/splash_binding.dart';
import 'package:jinbeanpod_83904710/features/provider/settings/settings_page.dart';
// New imports for Settings sub-pages
import 'package:jinbeanpod_83904710/features/provider/settings/profile_details_page.dart';
import 'package:jinbeanpod_83904710/features/provider/settings/finance_page.dart';
import 'package:jinbeanpod_83904710/features/provider/settings/reviews_page.dart';
import 'package:jinbeanpod_83904710/features/provider/settings/reports_page.dart';
import 'package:jinbeanpod_83904710/features/provider/settings/marketing_page.dart';
import 'package:jinbeanpod_83904710/features/provider/settings/legal_page.dart';

// New imports for provider pages
import 'package:jinbeanpod_83904710/features/provider/orders/presentation/orders_shell_page.dart';
import 'package:jinbeanpod_83904710/features/provider/clients/presentation/client_page.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/service_manage/presentation/service_manage_page.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/message_center/presentation/message_center_page.dart';
import 'package:jinbeanpod_83904710/features/customer/splash/presentation/splash_controller.dart';

void main() async {
  print('[main] App starting...');
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  print('[main] GetStorage initialized.');
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  print('[main] Supabase initialized.');

  // 注入 AuthController，确保 LoginPage 可用
  Get.put(AuthController());
  print('[main] AuthController put.');
  // 注入 PluginManager，确保 ShellApp 可用
  Get.put(PluginManager());
  print('[main] PluginManager put.');
  // 全局注入 ShellAppController，确保 ShellApp 不报错
  Get.put(ShellAppController(), permanent: true);
  print('[main] ShellAppController put.');
  // 注入 LocationController，确保地址功能可用
  Get.put(LocationController());
  print('[main] LocationController put.');
  // 注入 SplashController，确保 SplashPage 可用
  Get.put(SplashController());
  print('[main] SplashController put.');

  final box = GetStorage();
  final user = Supabase.instance.client.auth.currentUser;
  String? role;
  if (user != null) {
    print('[main] User found, fetching profile...');
    final profile = await Supabase.instance.client
        .from('user_profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();
    role = profile?['role'];
    // Set the PluginManager's current role based on the fetched user profile role
    if (role != null) {
      Get.find<PluginManager>().currentRole.value = role;
      print('[main] PluginManager current role set to: $role');
    } else {
      print('[main] User profile role not found, defaulting to customer.');
      Get.find<PluginManager>().currentRole.value = 'customer';
    }
  } else {
    print('[main] No user logged in.');
  }

  final lastRole = box.read('lastRole');
  print('[main] Last role from GetStorage: $lastRole');

  // Simplified: Always start at SplashPage, which handles routing based on login and role.
  // The previous complex if/else if logic for 'home' is now handled by SplashController.
  // Widget home; // Removed
  // if (user == null) { // Removed
  //   home = LoginPage(); // 未登录 // Removed
  // } else if (role == 'customer') { // Removed
  //   home = const ShellApp(); // Removed
  // } else if (role == 'customer+provider') { // Removed
  //   // 如果用户是'customer+provider'，则总是导航到角色选择页面 // Removed
  //   home = const RoleSelectPage(); // Removed
  // } else if (role == 'provider') { // Removed
  //   home = const ProviderShellApp(); // Removed
  // } else { // Removed
  //   home = const ShellApp(); // Removed
  // }

  runApp(
    Phoenix(
      child: Obx(() {
        final role = Get.find<PluginManager>().currentRole.value;
        final themeName = AppThemeService().currentThemeName;
        print('Current Role: $role');
        print('Current Theme Name: $themeName');
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: role == 'provider'
              ? (themeName == 'golden'
                  ? AppThemeService().darkTealTheme
                  : AppThemeService().goldenTheme)
              : (themeName == 'golden'
                  ? AppThemeService().goldenTheme
                  : AppThemeService().darkTealTheme),
          themeMode: ThemeMode.system,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('zh', ''), // Chinese
          ],
          locale: const Locale('zh', ''), // 默认语言设置为中文
          home: const SplashPage(), // Always start with SplashPage
          getPages: [
            GetPage(name: '/auth', page: () => const LoginPage()),
            GetPage(name: '/main_shell', page: () => ShellApp()),
            GetPage(name: '/address_demo', page: () => const AddressInputDemoPage()),
            GetPage(name: '/provider_home', page: () => const ProviderShellApp()),
            GetPage(name: '/settings', page: () => const SettingsPage()),
            GetPage(name: '/splash', page: () => const SplashPage(), binding: SplashBinding()),
            // 只保留 ProviderShellApp 相关静态路由，其它 provider 插件式页面全部移除
          ],
        );
      }),
    ),
  );
}