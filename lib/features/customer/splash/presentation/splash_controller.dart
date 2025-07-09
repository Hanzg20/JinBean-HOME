import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/plugin_manager.dart'; // Corrected import for PluginManager
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

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
    AppLogger.info('[SplashController] _initializeApp called.', tag: 'SplashController');
    final session = Supabase.instance.client.auth.currentSession;
    AppLogger.debug('[SplashController] Supabase session: $session', tag: 'SplashController');
    if (session != null) {
      // 拉取 profile
      final user = Supabase.instance.client.auth.currentUser;
      final profile = await Supabase.instance.client
          .from('user_profiles')
          .select('role')
          .eq('id', user?.id ?? '')
          .maybeSingle();
      final role = profile?['role'] ?? 'customer';
      AppLogger.info('[SplashController] User profile role: $role', tag: 'SplashController');
      if (role == 'customer+provider') {
        AppLogger.info('[SplashController] User is customer+provider, navigating to /auth with showRoleSwitch', tag: 'SplashController');
        Get.offAllNamed('/auth', arguments: {'showRoleSwitch': true});
      } else if (role == 'provider') {
        AppLogger.info('[SplashController] Navigating to /provider_home', tag: 'SplashController');
        Get.offAllNamed('/provider_home');
      } else {
        AppLogger.info('[SplashController] Navigating to /main_shell', tag: 'SplashController');
        Get.offAllNamed('/main_shell');
      }
    } else {
      AppLogger.info('[SplashController] No session, staying on splash.', tag: 'SplashController');
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

  @override
  void onClose() {
    pageController.dispose();
    AppLogger.info('SplashController disposed', tag: 'SplashController');
    super.onClose();
  }
} 