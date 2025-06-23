import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'package:jinbeanpod_83904710/core/plugin_management/plugin_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  
  // Remove Mock user database
  // final Map<String, String> _mockUsers = {
  //   'test@example.com': 'password123',
  // };

  @override
  void onInit() {
    super.onInit();
    print('AuthController initialized');
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please enter email and password';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final AuthResponse response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Login successful
        await _handleSuccessfulLogin(response.user!); // Pass the Supabase User object
      } else {
        errorMessage.value = 'Login failed. Please check your credentials.';
      }
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      print('Login error: ${e.message}');
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred. Please try again.';
      print('Login error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      errorMessage.value = 'Please fill all fields';
      return;
    }
    if (password != confirmPassword) {
      errorMessage.value = 'Passwords do not match';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final AuthResponse response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Registration successful. Supabase automatically logs in the user after signup.
        // Now, save additional user profile data to your 'user_profiles' table.
        try {
          await Supabase.instance.client.from('user_profiles').insert({
            'id': response.user!.id,
            'user_id': response.user!.id,
            'display_name': email.split('@')[0], // Use email prefix as default display name
            'avatar_url': null,
            'gender': null,
            'birthday': null,
            'language': 'en',
            'timezone': 'UTC',
            'bio': '',
            'preferences': { // Default preferences
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
            // Add other user_profiles fields as null or default values if they are nullable
          });
          print('User profile created successfully for ${response.user!.id}');
        } catch (profileError) {
          print('Error creating user profile: $profileError');
          // Optionally, handle this error (e.g., delete the user from auth.users, or log for manual intervention)
          Get.snackbar('Profile Error', 'Failed to create user profile. Please try again.', snackPosition: SnackPosition.BOTTOM);
        }

        Get.snackbar('Success', 'Registration successful! You are now logged in.', snackPosition: SnackPosition.BOTTOM);
        await _handleSuccessfulLogin(response.user!); // Treat registration as immediate login
      } else if (response.session == null) {
        // User needs email confirmation
        Get.snackbar(
          'Verification Needed',
          'Please check your email for a verification link to complete registration.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
        Get.offAllNamed('/auth'); // Navigate to login page
      }
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      print('Registration error: ${e.message}');
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred during registration. Please try again.';
      print('Registration error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Modified to accept a Supabase User object
  Future<void> _handleSuccessfulLogin(User user) async {
    try {
      // Store user ID for session persistence
      await _storage.write('userId', user.id);
      
      // Fetch user profile data
      final profileResponse = await Supabase.instance.client
          .from('user_profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();
      
      if (profileResponse != null) {
        // Store profile data in local storage for quick access
        await _storage.write('userProfile', profileResponse);
        print('User profile loaded successfully');
      } else {
        print('No profile found for user ${user.id}');
        // Optionally create a default profile if none exists
        await _createDefaultProfile(user);
      }

      Get.offAllNamed('/main_shell');
    } catch (e) {
      print('Error handling successful login: $e');
      Get.snackbar(
        'Error',
        'Failed to load user profile. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _createDefaultProfile(User user) async {
    try {
      await Supabase.instance.client.from('user_profiles').insert({
        'id': user.id,
        'user_id': user.id,
        'display_name': user.email?.split('@')[0] ?? 'User',
        'avatar_url': null,
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
      await Supabase.instance.client.auth.signOut();
      await _storage.remove('userId'); // Clear stored user ID
      // _pluginManager.isLoggedIn.value = false; // Not needed
      Get.offAllNamed('/splash'); // Navigate to splash page after logout
    } catch (e) {
      print('Logout error: $e');
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
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
} 