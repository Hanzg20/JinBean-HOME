import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jinbeanpod_83904710/features/customer/auth/presentation/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final _storage = GetStorage();

  // User Information - Now using RxString for reactive updates
  RxString userName = ''.obs;
  RxString memberSince = ''.obs;
  RxString avatarUrl = ''.obs;
  RxString userBio = ''.obs;
  RxString userLevel = 'Member'.obs;
  RxInt userPoints = 0.obs;
  RxDouble userRating = 0.0.obs;
  RxBool isEmailVerified = false.obs;
  RxBool isPhoneVerified = false.obs;
  RxBool isLoading = true.obs;

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
      badge: '0',
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
    _authController = Get.find<AuthController>();
    print('ProfileController initialized');

    // Initialize settings menu items
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
        title: 'Address Input Demo',
        icon: Icons.location_city,
        onTap: () => Get.toNamed('/address_demo'),
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
      ProfileMenuItem(
        title: 'Logout',
        icon: Icons.logout,
        onTap: () {
          _authController.logout();
        },
      ),
    ]);

    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    isLoading.value = true;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      // Added user.id == null check for robustness
      print(
          '[ProfileController] No authenticated user or user ID found. Returning.');
      isLoading.value = false;
      return;
    }
    print('[ProfileController] Loading profile for user ID: ${user.id}');

    try {
      // Load user profile from Supabase
      final profileResponse = await Supabase.instance.client
          .from('user_profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (profileResponse != null) {
        print('[ProfileController] Profile found for user ${user.id}');
        // Update UI with real user data
        userName.value = profileResponse['display_name'] ?? 'User';
        userBio.value = profileResponse['bio'] ?? '';

        final originalAvatarUrl = profileResponse['avatar_url'];
        print(
            '[ProfileController] Original avatar_url from DB: $originalAvatarUrl');
        avatarUrl.value = (originalAvatarUrl != null &&
                originalAvatarUrl.toString().isNotEmpty)
            ? originalAvatarUrl
            : ''; // Set to empty string if empty or null
        print(
            '[ProfileController] Final avatarUrl.value after processing: ${avatarUrl.value}');

        // Set member since date
        try {
          final createdAt = user.createdAt;
          if (createdAt.isNotEmpty) {
            // Try to parse the createdAt string to get the year
            final dateTime = DateTime.tryParse(createdAt);
            if (dateTime != null) {
              memberSince.value = 'Member since ${dateTime.year}';
            } else {
              memberSince.value = 'Member since ${DateTime.now().year}';
            }
          } else {
            memberSince.value = 'Member since ${DateTime.now().year}';
          }
        } catch (e) {
          // Fallback to current year if createdAt is not available
          memberSince.value = 'Member since ${DateTime.now().year}';
        }

        // Set user level based on points (you can customize this logic)
        final points = profileResponse['points'] ?? 0;
        userPoints.value = points;

        if (points >= 1000) {
          userLevel.value = 'Gold Member';
        } else if (points >= 500) {
          userLevel.value = 'Silver Member';
        } else {
          userLevel.value = 'Bronze Member';
        }

        // Set verification status
        isEmailVerified.value = user.emailConfirmedAt != null;
        isPhoneVerified.value = profileResponse['phone_verified'] ?? false;

        // Update order badge count
        await _updateOrderBadgeCount();

        print('User profile loaded successfully');
      } else {
        print('No profile found for user ${user.id}');
        // Set default values
        userName.value = user.email?.split('@')[0] ?? 'User';
        memberSince.value = 'Member since ${DateTime.now().year}';
      }
    } catch (e) {
      print('Error loading user profile: $e');
      Get.snackbar(
        'Error',
        'Failed to load user profile',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateOrderBadgeCount() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Count pending orders (assuming you have an orders table)
      // This is a placeholder - implement when orders table is created
      final orderCount =
          0; // TODO: Replace with actual query when orders table exists

      // Update the badge in the menu items
      final orderMenuItem = accountMenuItems.firstWhere(
        (item) => item.title == 'My Orders',
        orElse: () => accountMenuItems[1], // My Orders is at index 1
      );

      // Create a new menu item with updated badge
      final updatedMenuItem = ProfileMenuItem(
        title: orderMenuItem.title,
        icon: orderMenuItem.icon,
        onTap: orderMenuItem.onTap,
        badge: orderCount > 0 ? orderCount.toString() : null,
      );

      // Update the menu item in the list
      final index = accountMenuItems.indexOf(orderMenuItem);
      if (index != -1) {
        accountMenuItems[index] = updatedMenuItem;
      }
    } catch (e) {
      print('Error updating order badge count: $e');
    }
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final updateData = <String, dynamic>{};
      if (displayName != null) updateData['display_name'] = displayName;
      if (bio != null) updateData['bio'] = bio;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      await Supabase.instance.client
          .from('user_profiles')
          .update(updateData)
          .eq('user_id', user.id);

      // Update local data
      if (displayName != null) userName.value = displayName;
      if (bio != null) userBio.value = bio;
      if (avatarUrl != null) this.avatarUrl.value = avatarUrl;

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error updating user profile: $e');
      Get.snackbar(
        'Error',
        'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
    print('[ProfileController] onClose called.');
    userName.close();
    memberSince.close();
    avatarUrl.close();
    userBio.close();
    userLevel.close();
    userPoints.close();
    userRating.close();
    isEmailVerified.close();
    isPhoneVerified.close();
    isLoading.close();
    accountMenuItems.close();
    settingsMenuItems.close();
    super.onClose();
  }
}
