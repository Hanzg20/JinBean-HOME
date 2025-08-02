import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/features/customer/auth/presentation/auth_controller.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/plugin_manager.dart';
import 'package:jinbeanpod_83904710/app/theme/app_theme_service.dart';
import 'package:get_storage/get_storage.dart';

class ProviderProfileController extends GetxController {
  final _storage = GetStorage();
  final RxString displayName = ''.obs;
  final RxString email = ''.obs;
  final RxString phone = ''.obs;
  final RxString avatarUrl = ''.obs;
  final RxString status = ''.obs;
  final RxString providerType = ''.obs;
  final RxList<String> serviceCategories = <String>[].obs;
  final RxString certificationStatus = ''.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadProviderProfile();
  }

  Future<void> loadProviderProfile() async {
    isLoading.value = true;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }
    try {
      final profile = await Supabase.instance.client
          .from('provider_profiles')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false) // Order by creation date to get the latest
          .limit(1) // Limit to one result
          .maybeSingle();

      if (profile != null) {
        displayName.value = profile['display_name'] ?? '';
        email.value = profile['email'] ?? '';
        phone.value = profile['phone'] ?? '';
        avatarUrl.value = (profile['avatar_url'] != null && profile['avatar_url'].toString().isNotEmpty)
            ? profile['avatar_url']
            : '';
        status.value = profile['status'] ?? '';
        providerType.value = profile['provider_type'] ?? '';
        serviceCategories.value = (profile['service_categories'] as List?)?.map((e) => e.toString()).toList() ?? [];
        certificationStatus.value = profile['certification_status'] ?? '';
      } else {
        print('[ProviderProfileController] No provider profile found for user ${user.id}');
        // Optionally set default empty values if no profile is found
      }
    } on PostgrestException catch (e) {
      print('[ProviderProfileController] PostgrestException loading profile: ${e.message}, details: ${e.details}');
      // Handle specific Postgrest errors, e.g., show a user-friendly message
    } catch (e, stack) {
      print('[ProviderProfileController] Unexpected error loading profile: $e\n$stack');
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    try {
      print('[ProviderProfileController] Provider logout started.');
      
      // Step 1: Reset ProviderProfileController states
      displayName.value = '';
      email.value = '';
      phone.value = '';
      avatarUrl.value = '';
      status.value = '';
      providerType.value = '';
      serviceCategories.clear();
      certificationStatus.value = '';
      isLoading.value = false;
      
      // Step 2: Reset PluginManager's currentRole to default 'customer'
      if (Get.isRegistered<PluginManager>()) {
        final pluginManager = Get.find<PluginManager>();
        print('[ProviderProfileController] logout: Resetting PluginManager currentRole to customer.');
        pluginManager.currentRole.value = 'customer';
        
        // 手动切换主题到Customer主题
        try {
          final themeService = Get.find<AppThemeService>();
          themeService.setThemeByName('dark_teal'); // Customer主题
          print('[ProviderProfileController] logout: Theme switched to Customer theme.');
        } catch (e) {
          print('[ProviderProfileController] logout: Error switching theme: $e');
        }
      }
      
      // Step 3: Reset AuthController states if available
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        authController.selectedLoginRole.value = 'customer';
        authController.userProfileRole.value = '';
        authController.errorMessage.value = '';
      }
      
      // Step 4: Dismiss any open dialogs or bottom sheets
      if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
        Get.back();
      }
      
      // Step 5: Clear stored data
      await _storage.remove('userId');
      await _storage.remove('userProfile');
      await _storage.remove('lastRole');
      print('[ProviderProfileController] Local storage cleared.');
      
      // Step 6: Sign out from Supabase
      await Supabase.instance.client.auth.signOut();
      print('[ProviderProfileController] User signed out successfully from Supabase.');
      
      // Step 7: Navigate to login page
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/auth');
      
    } catch (e, s) {
      print('[ProviderProfileController] Logout error: $e\nStackTrace: $s');
      Get.snackbar('Error', 'Failed to logout. Please try again.');
    }
  }
} 