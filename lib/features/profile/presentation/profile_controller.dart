import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/auth/presentation/auth_controller.dart'; // 导入AuthController

class ProfileMenuItem {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final String? badge;

  ProfileMenuItem({
    required this.title,
    required this.icon,
    this.onTap,
    this.badge,
  });
}

class ProfileController extends GetxController {
  // User Information
  RxString userName = 'Sophia Chen'.obs;
  RxString memberSince = 'Member since 2022'.obs;
  RxString avatarUrl = 'https://picsum.photos/200/300'.obs;
  RxString userBio = 'Welcome to my profile!'.obs;
  RxString userLevel = 'Gold Member'.obs;
  RxInt userPoints = 1250.obs;
  RxDouble userRating = 4.8.obs;
  RxBool isEmailVerified = true.obs;
  RxBool isPhoneVerified = false.obs;

  // Menu Items
  RxList<ProfileMenuItem> accountMenuItems = <ProfileMenuItem>[
    ProfileMenuItem(
      title: 'Edit Profile',
      icon: Icons.person_outline,
      onTap: () => Get.toNamed('/edit_profile'),
    ),
    ProfileMenuItem(
      title: 'My Orders',
      icon: Icons.shopping_bag_outlined,
      badge: '2',
      onTap: () => Get.toNamed('/my_orders'),
    ),
    ProfileMenuItem(
      title: 'Saved Services',
      icon: Icons.bookmark_border,
      onTap: () => Get.toNamed('/saved_services'),
    ),
    ProfileMenuItem(
      title: 'My Reviews',
      icon: Icons.rate_review_outlined,
      onTap: () => Get.toNamed('/my_reviews'),
    ),
    ProfileMenuItem(
      title: 'My Addresses',
      icon: Icons.location_on_outlined,
      onTap: () => Get.toNamed('/my_addresses'),
    ),
    ProfileMenuItem(
      title: 'Payment Methods',
      icon: Icons.payment_outlined,
      onTap: () => Get.toNamed('/payment_methods'),
    ),
    ProfileMenuItem(
      title: 'Switch to Provider',
      icon: Icons.switch_account,
      onTap: () => Get.toNamed('/provider_switch'),
    ),
  ].obs;

  RxList<ProfileMenuItem> settingsMenuItems = <ProfileMenuItem>[].obs;

  // Add an AuthController instance
  late final AuthController _authController;

  @override
  void onInit() {
    super.onInit();
    _authController = Get.find<AuthController>(); // Get the AuthController instance
    print('ProfileController initialized');

    settingsMenuItems.addAll([
      ProfileMenuItem(
        title: 'Notifications',
        icon: Icons.notifications_outlined,
        onTap: () => Get.toNamed('/notification_settings'),
      ),
      ProfileMenuItem(
        title: 'Privacy Settings',
        icon: Icons.privacy_tip_outlined,
        onTap: () => Get.toNamed('/privacy_settings'),
      ),
      ProfileMenuItem(
        title: 'Theme Settings',
        icon: Icons.palette_outlined,
        onTap: () => Get.toNamed('/theme_settings'),
      ),
      ProfileMenuItem(
        title: 'Language',
        icon: Icons.language,
        onTap: () => Get.toNamed('/language_settings'),
      ),
      ProfileMenuItem(
        title: 'Location Settings',
        icon: Icons.location_on,
        onTap: () => Get.toNamed('/location_settings'),
      ),
      ProfileMenuItem(
        title: 'Clear Cache',
        icon: Icons.cleaning_services_outlined,
        onTap: () => _clearCache(),
      ),
      ProfileMenuItem(
        title: 'About Us',
        icon: Icons.info_outline,
        onTap: () => Get.toNamed('/about'),
      ),
      ProfileMenuItem(
        title: 'Help Center',
        icon: Icons.help_outline,
        onTap: () => Get.toNamed('/help'),
      ),
      ProfileMenuItem(
        title: 'Terms of Service',
        icon: Icons.description_outlined,
        onTap: () => Get.toNamed('/terms'),
      ),
      ProfileMenuItem(
        title: 'Privacy Policy',
        icon: Icons.policy_outlined,
        onTap: () => Get.toNamed('/privacy'),
      ),
    ]);

    // Add Logout option to settingsMenuItems
    settingsMenuItems.add(
      ProfileMenuItem(
        title: 'Logout',
        icon: Icons.logout,
        onTap: () {
          _authController.logout();
        },
      ),
    );
  }

  void _clearCache() {
    // TODO: Implement cache clearing logic
    Get.snackbar(
      'Cache Cleared',
      'Application cache has been cleared successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    print('ProfileController disposed');
    super.onClose();
  }
} 