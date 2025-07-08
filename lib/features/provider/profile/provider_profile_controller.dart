import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/features/customer/auth/presentation/auth_controller.dart';

class ProviderProfileController extends GetxController {
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

  void logout() {
    Get.find<AuthController>().logout();
  }
} 