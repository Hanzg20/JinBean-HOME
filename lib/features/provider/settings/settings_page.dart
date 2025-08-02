import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/plugin_manager.dart';
import 'package:jinbeanpod_83904710/core/ui/components/provider_theme_components.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/provider_theme_utils.dart';
import 'package:jinbeanpod_83904710/core/ui/design_system/colors.dart';
// Import the new ProfileDetailsPage
import '../profile/provider_profile_controller.dart'; // Corrected import path for controller

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderProfileController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: JinBeanColors.background,
      appBar: AppBar(
        title: Text(
          '设置',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: JinBeanColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: JinBeanColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider信息卡片
            _buildProviderInfoCard(context),
            const SizedBox(height: 20),
            
            // 业务管理
            _buildSectionHeader(context, '业务管理'),
            const SizedBox(height: 8),
            _buildBusinessSection(context),
            const SizedBox(height: 16),
            
            // 账户设置
            _buildSectionHeader(context, '账户设置'),
            const SizedBox(height: 8),
            _buildAccountSection(context),
            const SizedBox(height: 16),
            
            // 应用设置
            _buildSectionHeader(context, '应用设置'),
            const SizedBox(height: 8),
            _buildAppSettingsSection(context),
            const SizedBox(height: 16),
            
            // 数据与安全
            _buildSectionHeader(context, '数据与安全'),
            const SizedBox(height: 8),
            _buildSecuritySection(context),
            const SizedBox(height: 16),
            
            // 退出登录
            _buildLogoutSection(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderInfoCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [JinBeanColors.primary, JinBeanColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(64), // 右上角圆角半径比其他三个角大4倍
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: JinBeanColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed('/settings/profile'),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(64),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // 头像
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                
                // 信息区域
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '张师傅',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // 编辑按钮
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '专业服务提供者',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '已认证',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '4.8★',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 箭头
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: JinBeanColors.primaryDark,
        fontSize: 14,
      ),
    );
  }

  Widget _buildBusinessSection(BuildContext context) {
    return Column(
      children: [
        _buildSettingsCard(
          context,
          onTap: () => Get.toNamed('/provider/services'),
          icon: Icons.work_outline,
          title: '服务管理',
          subtitle: '管理您的服务项目',
          badge: '6',
        ),
        const SizedBox(height: 6),
        _buildSettingsCard(
          context,
          onTap: () => Get.toNamed('/provider/schedule'),
          icon: Icons.schedule_outlined,
          title: '日程安排',
          subtitle: '管理工作时间',
        ),
        const SizedBox(height: 6),
        _buildSettingsCard(
          context,
          onTap: () => Get.toNamed('/provider/reviews'),
          icon: Icons.star_outline,
          title: '评价管理',
          subtitle: '查看客户评价',
          badge: '12',
        ),
        const SizedBox(height: 6),
        _buildSettingsCard(
          context,
          onTap: () => Get.toNamed('/provider/promotions'),
          icon: Icons.campaign_outlined,
          title: '推广活动',
          subtitle: '营销推广设置',
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Column(
      children: [
        _buildSettingsCard(
          context,
          onTap: () => Get.toNamed('/settings/finance'),
          icon: Icons.account_balance_wallet_outlined,
          title: '财务管理',
          subtitle: '收入统计与设置',
          badge: 'NEW',
        ),
        const SizedBox(height: 6),
        _buildSettingsCard(
          context,
          onTap: () => Get.toNamed('/provider/verification'),
          icon: Icons.verified_outlined,
          title: '身份认证',
          subtitle: '完成实名认证',
          badge: '待认证',
          badgeColor: JinBeanColors.warning,
        ),
      ],
    );
  }

  Widget _buildAppSettingsSection(BuildContext context) {
    return Column(
      children: [
        _buildSettingsCard(
          context,
          onTap: () => Get.toNamed('/provider/theme_settings'),
          icon: Icons.palette_outlined,
          title: '主题设置',
          subtitle: '自定义外观',
        ),
        const SizedBox(height: 6),
        _buildSettingsCard(
          context,
          onTap: () => Get.toNamed('/provider/language_settings'),
          icon: Icons.language_outlined,
          title: '语言设置',
          subtitle: '选择显示语言',
        ),
        const SizedBox(height: 6),
        _buildSettingsCard(
          context,
          onTap: () => Get.toNamed('/provider/notifications'),
          icon: Icons.notifications_outlined,
          title: '通知设置',
          subtitle: '管理推送通知',
          badge: '3',
        ),
      ],
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    return Column(
      children: [
        _buildSettingsCard(
          context,
          onTap: () => Get.toNamed('/provider/privacy'),
          icon: Icons.privacy_tip_outlined,
          title: '隐私设置',
          subtitle: '数据隐私管理',
        ),
        const SizedBox(height: 6),
        _buildSettingsCard(
          context,
          onTap: () => Get.toNamed('/provider/security'),
          icon: Icons.security_outlined,
          title: '安全设置',
          subtitle: '账户安全配置',
        ),
        const SizedBox(height: 6),
        _buildSettingsCard(
          context,
          onTap: () => Get.toNamed('/provider/data_export'),
          icon: Icons.download_outlined,
          title: '数据导出',
          subtitle: '导出个人数据',
        ),
      ],
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required VoidCallback onTap,
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: JinBeanColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: JinBeanColors.shadow.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [JinBeanColors.primary, JinBeanColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: JinBeanColors.primary.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: JinBeanColors.textPrimary,
                              ),
                            ),
                          ),
                          if (badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: badgeColor ?? JinBeanColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: JinBeanColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: JinBeanColors.textTertiary,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [JinBeanColors.error, JinBeanColors.errorLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: JinBeanColors.error.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '退出登录',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '安全退出账户',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: JinBeanColors.surface,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [JinBeanColors.error, JinBeanColors.errorLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '确认退出',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: JinBeanColors.textPrimary,
              ),
            ),
          ],
        ),
        content: const Text(
          '您确定要退出登录吗？',
          style: TextStyle(
            fontSize: 14,
            color: JinBeanColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              '取消',
              style: TextStyle(
                fontSize: 14,
                color: JinBeanColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _logout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: JinBeanColors.error,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: JinBeanColors.error.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              '退出登录',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
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
      Get.snackbar(
        '退出失败',
        '退出登录时发生错误，请重试',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: JinBeanColors.error,
        colorText: Colors.white,
      );
    }
  }
} 