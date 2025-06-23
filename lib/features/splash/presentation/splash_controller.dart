import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    pageController = PageController();
    print('SplashController: Initializing. Checking login status...');
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Check if there is an active Supabase session
    final session = Supabase.instance.client.auth.currentSession;
    
    // Use addPostFrameCallback to ensure navigation context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (session != null) {
        // User is logged in, navigate to main shell
        print('SplashController: User is logged in. Navigating to /main_shell');
        Get.offAllNamed('/main_shell');
      } else {
        // User is not logged in, stay on splash/onboarding page
        print('SplashController: User is not logged in. Staying on splash page.');
        isReadyToNavigate.value = true; // Indicate that UI is ready for interaction (buttons)
      }
    });
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