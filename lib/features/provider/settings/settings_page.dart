import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/settings/provider_settings_page.dart';
import 'package:jinbeanpod_83904710/features/provider/settings/profile_settings_page.dart';
import 'package:jinbeanpod_83904710/features/provider/settings/app_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('设置', style: theme.textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        )),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, '账户设置'),
          _buildSettingsTile(
            context,
            icon: Icons.person,
            title: '个人资料与认证',
            subtitle: '管理您的个人信息和认证状态',
            onTap: () => Get.to(() => const ProfileSettingsPage()),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.person_add,
            title: '客户管理设置',
            subtitle: '管理客户转换和关系设置',
            onTap: () => Get.to(() => const ProviderSettingsPage()),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader(context, '应用设置'),
          _buildSettingsTile(
            context,
            icon: Icons.palette_outlined,
            title: '主题设置',
            subtitle: '自定义应用主题和外观',
            onTap: () => Get.to(() => const AppSettingsPage()),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.language,
            title: '语言设置',
            subtitle: '选择应用显示语言',
            onTap: () => Get.to(() => const AppSettingsPage()),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.security,
            title: '安全与合规',
            subtitle: '管理账户安全和隐私设置',
            onTap: () => Get.to(() => const AppSettingsPage()),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader(context, '其他'),
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: '帮助与支持',
            subtitle: '获取帮助和联系客服',
            onTap: () => _showComingSoon(context),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: '关于应用',
            subtitle: '查看应用版本和更新信息',
            onTap: () => _showComingSoon(context),
          ),
          
          const SizedBox(height: 32),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red.shade600,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red.shade200),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 8),
            Text('退出登录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Get.snackbar(
      '功能开发中',
      '此功能正在开发中，敬请期待！',
      snackPosition: SnackPosition.TOP,
      backgroundColor: colorScheme.primary.withOpacity(0.1),
      colorText: colorScheme.primary,
      duration: const Duration(seconds: 2),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text('确认退出', style: theme.textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        )),
        content: Text('您确定要退出登录吗？', style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        )),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消', style: TextStyle(color: colorScheme.primary)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // 这里可以添加退出登录的逻辑
              Get.snackbar(
                '退出成功',
                '您已成功退出登录',
                snackPosition: SnackPosition.TOP,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                colorText: colorScheme.primary,
              );
            },
            child: const Text('确认', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 