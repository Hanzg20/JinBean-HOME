import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/plugin_manager.dart';
// Import the new ProfileDetailsPage
import '../profile/provider_profile_controller.dart'; // Corrected import path for controller

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderProfileController());

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.person,
            title: '个人资料与认证',
            onTap: () => Get.toNamed('/settings/profile'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.account_balance_wallet,
            title: '收入与财务管理',
            onTap: () => Get.toNamed('/settings/finance'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.star_border,
            title: '客户评价与信誉',
            onTap: () => Get.toNamed('/settings/reviews'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.description,
            title: '服务历史与报表',
            onTap: () => Get.toNamed('/settings/reports'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.campaign,
            title: '广告与推广',
            onTap: () => Get.toNamed('/settings/marketing'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.security,
            title: '安全与合规',
            onTap: () => Get.toNamed('/settings/legal'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.palette_outlined,
            title: '主题设置',
            onTap: () => Get.toNamed('/provider/theme_settings'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.language,
            title: '语言设置',
            onTap: () => Get.toNamed('/provider/language_settings'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('退出登录', style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      print('[SettingsPage] Direct logout started.');
      
      // Step 1: Sign out from Supabase
      await Supabase.instance.client.auth.signOut();
      print('[SettingsPage] Supabase sign out completed.');
      
      // Step 2: Clear local storage
      final storage = GetStorage();
      await storage.remove('userId');
      await storage.remove('userProfile');
      await storage.remove('lastRole');
      print('[SettingsPage] Local storage cleared.');
      
      // Step 3: Reset PluginManager role
      if (Get.isRegistered<PluginManager>()) {
        final pluginManager = Get.find<PluginManager>();
        pluginManager.currentRole.value = 'customer';
        print('[SettingsPage] PluginManager role reset to customer.');
      }
      
      // Step 4: Navigate to login page
      print('[SettingsPage] About to navigate to /auth');
      Get.offAllNamed('/auth');
      print('[SettingsPage] Navigation to /auth completed');
      
    } catch (e) {
      print('[SettingsPage] Logout error: $e');
      Get.snackbar('Error', 'Failed to logout. Please try again.');
    }
  }
} 