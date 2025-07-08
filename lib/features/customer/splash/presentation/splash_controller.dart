import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/plugin_manager.dart'; // Corrected import for PluginManager

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
    print('[SplashController] onInit called.');
    pageController = PageController();
    print('[SplashController] PageController initialized.');
    print('[SplashController] Initializing. Checking login status...');
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    print('[SplashController] _initializeApp called.');
    final session = Supabase.instance.client.auth.currentSession;
    print('[SplashController] Supabase session: $session');
    if (session != null) {
      // 拉取 profile
      final user = Supabase.instance.client.auth.currentUser;
      final profile = await Supabase.instance.client
          .from('user_profiles')
          .select('role')
          .eq('id', user?.id ?? '')
          .maybeSingle();
      final role = profile?['role'] ?? 'customer';
      print('[SplashController] User profile role: $role');
      if (role == 'customer+provider') {
        print('[SplashController] User is customer+provider, navigating to /auth with showRoleSwitch');
        Get.offAllNamed('/auth', arguments: {'showRoleSwitch': true});
      } else if (role == 'provider') {
        print('[SplashController] Navigating to /provider_home');
        Get.offAllNamed('/provider_home');
      } else {
        print('[SplashController] Navigating to /main_shell');
        Get.offAllNamed('/main_shell');
      }
    } else {
      print('[SplashController] No session, staying on splash.');
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
    print('SplashController: Navigating to /auth');
    Get.offAllNamed('/auth');
  }

  void navigateToRegister() {
    print('SplashController: Navigating to /register');
    Get.offAllNamed('/register');
  }

  @override
  void onClose() {
    pageController.dispose();
    print('SplashController disposed');
    super.onClose();
  }
} 