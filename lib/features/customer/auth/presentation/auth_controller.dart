import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/features/customer/profile/presentation/profile_controller.dart'; // Corrected import for ProfileController
import 'package:jinbeanpod_83904710/core/plugin_management/plugin_manager.dart'; // Corrected import for PluginManager
import 'package:jinbeanpod_83904710/features/provider/plugins/provider_identity/provider_identity_service.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:jinbeanpod_83904710/app/theme/app_theme_service.dart'; // Corrected import for AppThemeService

class AuthController extends GetxController {
  final _storage = GetStorage();
  // final _pluginManager = Get.find<PluginManager>(); // Not directly used in auth flow anymore, SplashController will handle nav

  // Text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // UI state
  final isPasswordVisible = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedLoginRole = 'customer'.obs; // New: Observable for selected login role
  final userProfileRole = ''.obs; // New: Observable for the user's role from DB

  // Remove Mock user database
  // final Map<String, String> _mockUsers = {
  //   'test@example.com': 'password123',
  // };

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('AuthController initialized', tag: 'AuthController');
  }

  @override
  void onClose() {
    AppLogger.info('[AuthController] onClose called.', tag: 'AuthController');
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    isPasswordVisible.close();
    isLoading.close();
    errorMessage.close();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
    AppLogger.debug('Password visibility toggled: ${isPasswordVisible.value}', tag: 'AuthController');
  }

  Future<bool> login() async {
    print('[AuthController] login called.');
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please enter email and password';
      print('[AuthController] Login: Email or password empty.');
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';
    print('[AuthController] Attempting login...');
    try {
      final AuthResponse response =
          await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('[AuthController] Login successful for user: ${response.user?.id ?? ''}');
        
        // 立即检查并打印 provider 角色状态
        try {
          final providerStatus = await ProviderIdentityService.getProviderStatus();
          print('[AuthController] 登录后 provider 角色状态: $providerStatus');
        } catch (e) {
          print('[AuthController] 获取 provider 角色状态时出错: $e');
        }
        
        // 拉取用户 profile
        final profile = await Supabase.instance.client
            .from('user_profiles')
            .select('role')
            .eq('id', response.user?.id ?? '')
            .maybeSingle();
        print('[AuthController] User profile fetched: $profile');
        final String userProfileRoleFromDb = profile?['role'] ?? 'customer';
        userProfileRole.value = userProfileRoleFromDb;
        String finalRole = userProfileRoleFromDb;
        if (userProfileRoleFromDb == 'customer+provider') {
          finalRole = selectedLoginRole.value;
        }
        Get.find<PluginManager>().currentRole.value = finalRole;
        print('User ${response.user?.id ?? ''} logged in with final role: $finalRole');
        return true;
      } else {
        errorMessage.value = 'Login failed. Please check your credentials.';
        print('[AuthController] Login failed: User is null.');
        return false;
      }
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      print('[AuthController] Login AuthException: ${e.message}');
      return false;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred. Please try again.';
      print('[AuthController] Login unexpected error: $e');
      return false;
    } finally {
      isLoading.value = false;
      print('[AuthController] Login process finished.');
    }
  }

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    print('[Register] 用户输入: email=$email, password.length=${password.length}, confirmPassword.length=${confirmPassword.length}');
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      errorMessage.value = 'Please fill all fields';
      print('[Register] 有字段为空，注册终止');
      return;
    }
    if (password != confirmPassword) {
      errorMessage.value = 'Passwords do not match';
      print('[Register] 两次密码不一致，注册终止');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    print('[Register] 开始注册流程');

    try {
      print('[Register] 调用 Supabase signUp, email=$email');
      final AuthResponse response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      print('[Register] signUp 返回: user=${response.user}, session=${response.session}');

      final user = response.user ?? Supabase.instance.client.auth.currentUser;
      print('[Register] 注册接口返回 user: ${user?.id}, response: ${response.user}, currentUser: ${Supabase.instance.client.auth.currentUser}');
      if (user != null) {
        // 等待 session 切换到新用户
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          final profileInsert = {
            'id': user.id,
            'user_id': user.id,
            'display_name': email.split('@')[0],
            'role': 'customer',
            'avatar_url': null,
            'gender': null,
            'birthday': null,
            'language': 'en',
            'timezone': 'UTC',
            'bio': '',
            'preferences': jsonEncode({
              'notification': {
                'push_enabled': true,
                'email_enabled': true,
                'sms_enabled': true,
              },
              'privacy': {
                'profile_visible': true,
                'show_online': false,
              },
            }),
            'verification': jsonEncode({
              'is_verified': false,
              'documents': [],
            }),
            'service_preferences': jsonEncode({
              'favorite_categories': [],
              'preferred_providers': [],
            }),
            'social_links': jsonEncode({
              'facebook': null,
              'twitter': null,
              'instagram': null,
            }),
          };
          print('[Register] 插入 user_profiles 参数: $profileInsert');
          final insertResp = await Supabase.instance.client
              .from('user_profiles')
              .insert(profileInsert)
              .select()
              .single();
          print('[Register] user_profiles 插入返回: $insertResp');
          if (insertResp['id'] == null) {
            print('[Register] user_profiles 插入失败，返回为 null 或无 id');
            errorMessage.value = 'Profile creation failed: insert returned null';
            return;
          }
          print('[Register] User profile created successfully for ${user.id}');
          // 注册成功后，自动初始化 profile、PluginManager、ProfileController 状态
          await _handleSuccessfulLogin(user);
        } catch (profileError, stack) {
          print('[Register] Error creating user profile: $profileError\nStack: $stack');
          Get.snackbar('Profile Error',
              'Failed to create user profile. Please try again.',
              snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        print('[Register] Registration failed: user is null');
        errorMessage.value = 'Registration failed: user is null';
      }
    } catch (e, stack) {
      print('[Register] Registration error: $e\nStack: $stack');
      errorMessage.value = 'Registration error: $e';
    } finally {
      isLoading.value = false;
      print('[Register] 注册流程结束');
    }
  }

  // Modified to accept a Supabase User object
  Future<void> _handleSuccessfulLogin(User user) async {
    print('[AuthController] _handleSuccessfulLogin called for user: ${user.id}');
    try {
      // Store user ID for session persistence
      await _storage.write('userId', user.id);
      print('[AuthController] userId stored: ${user.id}');

      // Fetch user profile data
      print('[AuthController] Fetching user profile...');
      final profileResponse = await Supabase.instance.client
          .from('user_profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (profileResponse != null) {
        print('[AuthController] User profile fetched: $profileResponse');
        final Map<String, dynamic> cleanedProfile = Map.from(profileResponse);
        // Ensure the fetched role is respected if user has an existing role
        final String userProfileRoleFromDb = cleanedProfile['role'] ?? 'customer';
        userProfileRole.value = userProfileRoleFromDb; // Update the observable with fetched role
        print('[AuthController] userProfileRoleFromDb: $userProfileRoleFromDb');
        
        // Use the explicitly selected role if available, otherwise use profile role
        // This logic allows the user to select 'customer' or 'provider' even if their DB role is 'customer+provider'
        // or to choose the specific role if they are 'customer+provider' and haven't selected yet.
        final String finalRole = selectedLoginRole.value;
        print('[AuthController] selectedLoginRole: $selectedLoginRole, finalRole for PluginManager: $finalRole');

        // Update PluginManager's current role
        Get.find<PluginManager>().currentRole.value = finalRole;
        print('User ${user.id} logged in with final role: $finalRole');

        // Ensure avatar_url is an empty string if it's null or an empty string from the database
        if (cleanedProfile.containsKey('avatar_url') &&
            (cleanedProfile['avatar_url'] == null ||
                cleanedProfile['avatar_url'] == '')) {
          cleanedProfile['avatar_url'] = ''; // Always store as empty string
        }
        AppLogger.info('[AuthController] _handleSuccessfulLogin: Cleaned avatar_url before storing: \\${cleanedProfile['avatar_url']}', tag: 'AuthController');

        // Store profile data in local storage for quick access
        await _storage.write('userProfile', cleanedProfile);
        AppLogger.info('[AuthController] User profile stored locally.', tag: 'AuthController');
        AppLogger.info('User profile loaded successfully', tag: 'AuthController');
      } else {
        print('[AuthController] No user profile found. Defaulting role to customer.');
      }
      final profileController = Get.find<ProfileController>();
      profileController.loadUserProfile();
      // 登录成功后直接根据 UI 选择的角色跳转主页面
      final String selectedRole = selectedLoginRole.value;
      Get.find<PluginManager>().currentRole.value = selectedRole;
      AppLogger.info('[AuthController] 跳转主页面，selectedRole: $selectedRole', tag: 'AuthController');
      if (selectedRole == 'provider') {
        Get.offAllNamed('/provider_home');
      } else {
        Get.offAllNamed('/main_shell');
      }
    } catch (e, stack) {
      AppLogger.error('[AuthController] Error in _handleSuccessfulLogin', error: e, stackTrace: stack, tag: 'AuthController');
      errorMessage.value = 'Failed to process login: $e';
    }
  }

  Future<void> _createDefaultProfile(User user) async {
    try {
      await Supabase.instance.client.from('user_profiles').insert({
        'id': user.id,
        'user_id': user.id,
        'display_name': user.email?.split('@')[0] ?? 'User',
        'avatar_url': '', // Store as empty string instead of null
        'gender': null,
        'birthday': null,
        'language': 'en',
        'timezone': 'UTC',
        'bio': '',
        'preferences': {
          'notification': {
            'push_enabled': true,
            'email_enabled': true,
            'sms_enabled': true,
          },
          'privacy': {
            'profile_visible': true,
            'show_online': false,
          },
        },
      });
      print('Default profile created for user ${user.id}');
    } catch (e) {
      print('Error creating default profile: $e');
    }
  }

  void logout() async {
    try {
      // Step 1: Immediately reset ProfileController's states to default safe values
      // This ensures any active UI listeners bound to ProfileController see safe empty values
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        print('[AuthController] logout: Resetting ProfileController states.');
        profileController.userName.value = '';
        profileController.memberSince.value = '';
        profileController.avatarUrl.value = '';
        profileController.userBio.value = '';
        profileController.userLevel.value = 'Member';
        profileController.userPoints.value = 0;
        profileController.userRating.value = 0.0;
        profileController.isEmailVerified.value = false;
        profileController.isPhoneVerified.value = false;
        profileController.isLoading.value =
            false; // Set to false, as we are not loading.
        print(
            '[AuthController] logout: ProfileController avatarUrl after reset: ${profileController.avatarUrl.value}');
      } else {
        print('[AuthController] logout: ProfileController not registered.');
      }

      // Step 2: Reset PluginManager's currentRole to default 'customer'
      if (Get.isRegistered<PluginManager>()) {
        final pluginManager = Get.find<PluginManager>();
        print('[AuthController] logout: Resetting PluginManager currentRole to customer.');
        // 直接设置currentRole，避免调用setRole方法触发插件重新加载
        pluginManager.currentRole.value = 'customer';
        
        // 手动切换主题到Customer主题
        try {
          final themeService = Get.find<AppThemeService>();
          themeService.setThemeByName('dark_teal'); // Customer主题
          print('[AuthController] logout: Theme switched to Customer theme.');
        } catch (e) {
          print('[AuthController] logout: Error switching theme: $e');
        }
      } else {
        print('[AuthController] logout: PluginManager not registered.');
      }

      // Step 3: Reset AuthController's own states
      selectedLoginRole.value = 'customer';
      userProfileRole.value = '';
      errorMessage.value = '';

      // Step 4: Dismiss any open dialogs or bottom sheets
      if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
        Get.back();
      }

      // Step 5: Clear stored user ID and user profile from local storage
      await _storage.remove('userId');
      await _storage.remove('userProfile');
      await _storage.remove('lastRole'); // Clear last role as well
      print('Local storage userId, userProfile, and lastRole cleared.');

      // Step 6: Sign out from Supabase
      await Supabase.instance.client.auth.signOut();
      print('User signed out successfully from Supabase.');

      // Step 7: Give a small delay for UI repainting and then navigate
      await Future.delayed(const Duration(milliseconds: 500));

      Get.offAllNamed('/auth');
    } catch (e, s) { // Added StackTrace s
      print('Logout error: $e\nStackTrace: $s'); // Print StackTrace
      Get.snackbar('Error', 'Failed to logout. Please try again.');
    }
  }

  // Social login methods remain as placeholders for now
  Future<void> signInWithGoogle() async {
    print('Google Sign In button pressed (functionality disabled for now)');
    errorMessage.value = 'Google Sign-In is not yet implemented.';
    // await Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.google);
    return;
  }

  Future<void> signInWithApple() async {
    print('Apple Sign In button pressed (functionality disabled for now)');
    errorMessage.value = 'Apple Sign-In is not yet implemented.';
    // await Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.apple);
    return;
  }

  // These nonce and sha256 methods are typically for Apple Sign-In and might be used later
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
