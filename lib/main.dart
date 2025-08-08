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

// New imports for provider pages
import 'package:jinbeanpod_83904710/features/customer/splash/presentation/splash_controller.dart';
import 'package:jinbeanpod_83904710/features/customer/auth/presentation/register_page.dart';
import 'package:jinbeanpod_83904710/features/customer/auth/presentation/register_binding.dart';
import 'package:jinbeanpod_83904710/features/service_map/service_map_page.dart';
import 'features/customer/profile/presentation/theme_settings/theme_settings_page.dart';
import 'features/customer/profile/presentation/theme_settings/theme_settings_binding.dart';
import 'package:jinbeanpod_83904710/features/customer/profile/presentation/language_settings/language_settings_page.dart';
import 'package:jinbeanpod_83904710/features/customer/profile/presentation/language_settings/language_settings_binding.dart';
import 'package:jinbeanpod_83904710/features/provider/settings/language_settings_page.dart';
import 'package:jinbeanpod_83904710/features/provider/settings/language_settings_binding.dart';
import 'package:jinbeanpod_83904710/simulator/simulator_launcher.dart';
import 'package:jinbeanpod_83904710/features/demo/provider_theme_demo_page.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/customer_theme.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/provider_theme.dart';
// Add service detail imports
import 'package:jinbeanpod_83904710/features/customer/services/presentation/service_detail_page.dart';
import 'package:jinbeanpod_83904710/features/customer/services/presentation/service_detail_binding.dart';
import 'package:jinbeanpod_83904710/app/provider_shell_app.dart';
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

  // 注入 AppThemeService，确保全局主题可用
  Get.put(AppThemeService());
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

  String? preferredLocaleCode = box.read('preferredLocale');
  Locale? initialLocale;
  if (preferredLocaleCode != null) {
    initialLocale = Locale(preferredLocaleCode);
    print('[main] Preferred locale from storage: \\$preferredLocaleCode');
  } else {
    initialLocale = null;
    print('[main] No preferred locale found, will use system default.');
  }

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
        final themeService = AppThemeService();
        print('Current Role: $role');
        
        // 根据角色选择主题
        ThemeData theme;
        try {
          if (role == 'provider') {
            // Provider角色使用ProviderTheme
            theme = JinBeanProviderTheme.lightTheme;
            print('Applying Provider Theme');
          } else if (role == 'customer') {
            // Customer角色使用CustomerTheme
            theme = JinBeanCustomerTheme.lightTheme;
            print('Applying Customer Theme');
          } else {
            // 默认使用Customer主题
            theme = JinBeanCustomerTheme.lightTheme;
            print('Applying Default Customer Theme');
          }
        } catch (e) {
          print('Error applying theme: $e');
          // 如果主题应用失败，使用默认主题
          theme = ThemeData.light();
        }
        
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
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
          locale: initialLocale, // 优先用本地持久化语言，否则用系统
          home: const SplashPage(), // 从启动页面开始，让SplashController处理路由逻辑
          getPages: [
            GetPage(name: '/auth', page: () => const LoginPage()),
            GetPage(name: '/register', page: () => RegisterPage(), binding: RegisterBinding()),
            GetPage(name: '/main_shell', page: () => ShellApp()),
            GetPage(name: '/address_demo', page: () => const AddressInputDemoPage()),
            GetPage(name: '/settings', page: () => const SettingsPage()),
            GetPage(name: '/splash', page: () => const SplashPage(), binding: SplashBinding()),
            GetPage(name: '/service_map', page: () => const ServiceMapPage()),
            GetPage(name: '/theme_settings', page: () => const ThemeSettingsPage(), binding: ThemeSettingsBinding()),
            GetPage(name: '/language_settings', page: () => const LanguageSettingsPage(), binding: LanguageSettingsBinding()),
            GetPage(name: '/provider/language_settings', page: () => const ProviderLanguageSettingsPage(), binding: ProviderLanguageSettingsBinding()),
            GetPage(name: '/simulator', page: () => const SimulatorLauncher()),
            GetPage(name: '/provider_theme_demo', page: () => const ProviderThemeDemoPage()),
            GetPage(name: '/service_detail', page: () => ServiceDetailPageNew(serviceId: Get.parameters['serviceId'] ?? ''), binding: ServiceDetailBinding()),
            // 只保留 ProviderShellApp 相关静态路由，其它 provider 插件式页面全部移除
            GetPage(name: '/provider_shell', page: () => const ProviderShellApp()),
            GetPage(name: '/provider_home', page: () => ProviderHomePage(onNavigateToTab: (index) {})),          ],
        );
      }),
    ),
  );
}
