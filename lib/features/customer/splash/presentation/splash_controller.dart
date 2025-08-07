import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Corrected import for PluginManager
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/plugin_manager.dart';

class OnboardingPageModel {
  final String imagePath;
  final String title;
  final String description;

  OnboardingPageModel({required this.imagePath, required this.title, required this.description});
}

class SplashController extends GetxController {
  final RxBool isReadyToNavigate = false.obs;

  final RxInt currentPageIndex = 0.obs;
  late PageController pageController;

  final List<OnboardingPageModel> onboardingPages = [
    OnboardingPageModel(
      imagePath: 'assets/images/onboarding_1.png',
      title: 'Welcome to JinBean Home',
      description: 'Your ultimate Super App for all home-related services.',
    ),
    OnboardingPageModel(
      imagePath: 'assets/images/onboarding_2.png',
      title: 'Discover Local Services',
      description: 'Find trusted professionals for cleaning, repair, and more.',
    ),
    OnboardingPageModel(
      imagePath: 'assets/images/onboarding_3.png',
      title: 'Connect with Community',
      description: 'Engage with neighbors, share tips, and attend local events.',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('[SplashController] onInit called.', tag: 'SplashController');
    pageController = PageController();
    AppLogger.info('[SplashController] PageController initialized.', tag: 'SplashController');
    AppLogger.info('[SplashController] Initializing. Checking login status...', tag: 'SplashController');
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
    AppLogger.info('[SplashController] _initializeApp called.', tag: 'SplashController');
    final session = Supabase.instance.client.auth.currentSession;
    AppLogger.debug('[SplashController] Supabase session: $session', tag: 'SplashController');
      
    if (session != null) {
      // 拉取 profile
      final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          try {
      final profile = await Supabase.instance.client
          .from('user_profiles')
          .select('role')
                .eq('id', user.id)
          .maybeSingle();
      final role = profile?['role'] ?? 'customer';
      AppLogger.info('[SplashController] User profile role: $role', tag: 'SplashController');
            
      if (role == 'customer+provider') {
        AppLogger.info('[SplashController] User is customer+provider, navigating to /auth with showRoleSwitch', tag: 'SplashController');
        Get.offAllNamed('/auth', arguments: {'showRoleSwitch': true});
      } else if (role == 'provider') {
              AppLogger.info('[SplashController] User is provider, navigating to /provider_shell', tag: 'SplashController');
              // 设置PluginManager的角色为provider
              try {
                final pluginManager = Get.find<PluginManager>();
                pluginManager.setRole('provider');
              } catch (e) {
                AppLogger.error('[SplashController] Error setting provider role: $e', tag: 'SplashController');
              }
              Get.offAllNamed('/provider_shell');
      } else {
              AppLogger.info('[SplashController] User is customer, navigating to /main_shell', tag: 'SplashController');
              // 设置PluginManager的角色为customer
              try {
                final pluginManager = Get.find<PluginManager>();
                pluginManager.setRole('customer');
              } catch (e) {
                AppLogger.error('[SplashController] Error setting customer role: $e', tag: 'SplashController');
              }
              Get.offAllNamed('/main_shell');
            }
          } catch (e) {
            AppLogger.error('[SplashController] Error fetching profile: $e', tag: 'SplashController');
            // 如果获取profile失败，默认导航到main_shell
        Get.offAllNamed('/main_shell');
          }
        } else {
          AppLogger.info('[SplashController] No user found, staying on splash.', tag: 'SplashController');
          isReadyToNavigate.value = true;
      }
    } else {
      AppLogger.info('[SplashController] No session, staying on splash.', tag: 'SplashController');
        isReadyToNavigate.value = true;
      }
    } catch (e) {
      AppLogger.error('[SplashController] Error in _initializeApp: $e', tag: 'SplashController');
      // 如果出现错误，确保用户可以继续使用应用
      isReadyToNavigate.value = true;
    }
  }

  void onPageChanged(int index) {
    currentPageIndex.value = index;
  }

  void goToNextPage() {
    if (currentPageIndex.value < onboardingPages.length - 1) {
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      // If on the last page and user clicks next, assume they are ready for login/register
      isReadyToNavigate.value = true; // Or directly navigate to login/register if no skip button
    }
  }

  void navigateToLogin() {
    AppLogger.info('SplashController: Navigating to /auth', tag: 'SplashController');
    Get.offAllNamed('/auth');
  }

  void navigateToRegister() {
    AppLogger.info('SplashController: Navigating to /register', tag: 'SplashController');
    Get.offAllNamed('/register');
  }

  // 新增：兼容 Map 和 String 的多语言安全取值方法
  String getSafeLocalizedText(dynamic value) {
    if (value is Map<String, dynamic>) {
      final lang = Get.locale?.languageCode ?? 'zh';
      return value[lang] ?? value['zh'] ?? value['en'] ?? '';
    } else if (value is String) {
      return value;
    }
    return '';
  }

  @override
  void onClose() {
    pageController.dispose();
    AppLogger.info('SplashController disposed', tag: 'SplashController');
    super.onClose();
  }
} 