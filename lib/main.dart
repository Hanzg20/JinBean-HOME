import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 导入GetX的MaterialApp
        import 'package:jinbeanpod_83904710_f2f/figma_to_flutter.dart' as f2f;
import 'package:jinbeanpod_83904710/core/plugin_management/plugin_manager.dart'; // 导入PluginManager
import 'package:jinbeanpod_83904710/app/shell_app.dart'; // 导入ShellApp
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jinbeanpod_83904710/l10n/generated/app_localizations.dart'; // 导入生成的国际化类
import 'package:get_storage/get_storage.dart'; // 导入GetStorage
import 'package:jinbeanpod_83904710/features/auth/presentation/auth_controller.dart'; // 导入AuthController
import 'package:jinbeanpod_83904710/features/splash/presentation/splash_binding.dart';
import 'package:jinbeanpod_83904710/features/splash/presentation/splash_page.dart';
import 'package:jinbeanpod_83904710/features/splash/presentation/splash_controller.dart';
import 'package:jinbeanpod_83904710/app/shell_app_binding.dart'; // Import ShellAppBinding
import 'package:jinbeanpod_83904710/features/auth/presentation/login_page.dart';
import 'package:jinbeanpod_83904710/features/auth/presentation/auth_binding.dart';
import 'package:jinbeanpod_83904710/features/auth/presentation/register_page.dart'; // Import RegisterPage
import 'package:jinbeanpod_83904710/features/auth/presentation/register_binding.dart'; // Import RegisterBinding
import 'package:jinbeanpod_83904710/core/plugin_management/app_plugin.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 导入supabase_flutter
import 'package:jinbeanpod_83904710/features/profile/presentation/edit_profile_page.dart'; // Import EditProfilePage
import 'package:jinbeanpod_83904710/features/profile/presentation/edit_profile_binding.dart'; // Import EditProfileBinding
import 'package:jinbeanpod_83904710/features/profile/presentation/location_settings/location_settings_page.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/location_settings/location_settings_binding.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/my_orders/my_orders_page.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/my_orders/my_orders_binding.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/saved_services/saved_services_page.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/saved_services/saved_services_binding.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/my_reviews/my_reviews_page.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/my_reviews/my_reviews_binding.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/my_addresses/my_addresses_page.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/my_addresses/my_addresses_binding.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/payment_methods/payment_methods_page.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/payment_methods/payment_methods_binding.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/notification_settings/notification_settings_page.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/notification_settings/notification_settings_binding.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/privacy_settings/privacy_settings_page.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/privacy_settings/privacy_settings_binding.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/theme_settings/theme_settings_page.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/theme_settings/theme_settings_binding.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/language_settings/language_settings_page.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/language_settings/language_settings_binding.dart';
import 'package:jinbeanpod_83904710/app/theme/app_colors.dart'; // Import AppColors
import 'package:jinbeanpod_83904710/app/theme/app_theme_service.dart'; // Import AppThemeService

void main() async {
  // 确保GetX服务在WidgetsBinding初始化前可用
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化Supabase
  await Supabase.initialize(
    url: 'https://aszwrrrcbzrthqfsiwrd.supabase.co', // <<< 已替换为您的Supabase项目URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFzendycnJjYnpydGhxZnNpd3JkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2MzE2ODQsImV4cCI6MjA2NDIwNzY4NH0.C5JbWTmtpfHV9hSUmNB5BH978VxmLDpPJ5yqayU3zws', // <<< 已替换为您的Supabase Anon Key
  );

  // 初始化GetStorage
  await GetStorage.init();

  // 初始化PluginManager并等待完成
  final pluginManager = Get.put(PluginManager());
  await pluginManager.initializationComplete;

  // AuthController will be initialized globally
  Get.put(AuthController());

  // Explicitly put SplashController so it's available when SplashPage is built as home
  Get.put(SplashController());

  Get.put(AppThemeService()); // Initialize AppThemeService

  // 获取所有插件路由
  final List<GetPage> allRoutes = [
    GetPage(
      name: '/auth',
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/register',
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: '/splash',
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: '/main_shell',
      page: () => const ShellApp(),
      binding: ShellAppBinding(),
    ),
    GetPage(
      name: '/edit_profile',
      page: () => const EditProfilePage(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: '/location_settings',
      page: () => const LocationSettingsPage(),
      binding: LocationSettingsBinding(),
    ),
    GetPage(
      name: '/my_orders',
      page: () => const MyOrdersPage(),
      binding: MyOrdersBinding(),
    ),
    GetPage(
      name: '/saved_services',
      page: () => const SavedServicesPage(),
      binding: SavedServicesBinding(),
    ),
    GetPage(
      name: '/my_reviews',
      page: () => const MyReviewsPage(),
      binding: MyReviewsBinding(),
    ),
    GetPage(
      name: '/my_addresses',
      page: () => const MyAddressesPage(),
      binding: MyAddressesBinding(),
    ),
    GetPage(
      name: '/payment_methods',
      page: () => const PaymentMethodsPage(),
      binding: PaymentMethodsBinding(),
    ),
    GetPage(
      name: '/notification_settings',
      page: () => const NotificationSettingsPage(),
      binding: NotificationSettingsBinding(),
    ),
    GetPage(
      name: '/privacy_settings',
      page: () => const PrivacySettingsPage(),
      binding: PrivacySettingsBinding(),
    ),
    GetPage(
      name: '/theme_settings',
      page: () => const ThemeSettingsPage(),
      binding: ThemeSettingsBinding(),
    ),
    GetPage(
      name: '/language_settings',
      page: () => const LanguageSettingsPage(),
      binding: LanguageSettingsBinding(),
    ),
    ...pluginManager.getAllPluginRoutes(), // 从PluginManager添加所有插件路由
  ];

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      themeMode: ThemeMode.system,
      theme: Get.find<AppThemeService>().darkTealTheme,
      builder: (context, child) {
        return Obx(() => Theme(
              data: Get.find<AppThemeService>().currentTheme.value,
              child: child!,
            ));
      },
      getPages: allRoutes, // 使用包含所有路由的列表
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
    ),
  );

  // Original f2f initialization logic is removed from here.
  // f2f.getApp(withInit: (){
  //     print('Figma to Flutter initialized!');
  //     f2f.subscribeToEvent('pageLoaded', (e) async {
  //         String pageName = e.payload;
  //         print('$pageName loaded');
  //     });
  // })
}