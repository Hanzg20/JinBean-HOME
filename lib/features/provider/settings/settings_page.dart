import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/plugin_manager.dart';
import 'package:jinbeanpod_83904710/core/ui/components/provider_theme_components.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/provider_theme_utils.dart';
import 'package:jinbeanpod_83904710/core/ui/design_system/colors.dart';
import '../profile/provider_profile_controller.dart';
// Import platform components
import 'package:jinbeanpod_83904710/core/components/platform_core.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
// Import loading components
import 'package:jinbeanpod_83904710/features/customer/services/presentation/widgets/service_detail_loading.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final controller = Get.put(ProviderProfileController());
  
  // 平台组件状态管理
  final LoadingStateManager _loadingManager = LoadingStateManager();

  @override
  void initState() {
    super.initState();
    AppLogger.debug('[SettingsPage] initState called', tag: 'SettingsPage');
    
    // 初始化网络状态为在线
    _loadingManager.setOnline();
    // 数据已经在controller中加载完成，直接设置为成功状态
    _loadingManager.setSuccess();
  }

  @override
  void dispose() {
    _loadingManager.dispose();
    super.dispose();
  }

  /// 加载设置数据
  Future<void> _loadSettingsData() async {
    try {
      _loadingManager.setLoading();
      
      // 加载设置数据
      // 这里可以添加实际的设置数据加载逻辑
      
      _loadingManager.setSuccess();
    } catch (e) {
      _loadingManager.setError('加载设置数据失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '设置',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListenableBuilder(
        listenable: _loadingManager,
        builder: (context, child) {
          return ServiceDetailLoading(
            state: _loadingManager.state,
            errorMessage: _loadingManager.errorMessage,
            onRetry: () => _loadSettingsData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 个人资料卡片
                  _buildProfileCard(context),
                  
                  const SizedBox(height: 16),
                  
                  // 业务设置
                  _buildBusinessSection(context),
                  
                  const SizedBox(height: 16),
                  
                  // 账户设置
                  _buildAccountSection(context),
                  
                  const SizedBox(height: 16),
                  
                  // 应用设置
                  _buildAppSettingsSection(context),
                  
                  const SizedBox(height: 16),
                  
                  // 安全设置
                  _buildSecuritySection(context),
                  
                  const SizedBox(height: 16),
                  
                  // 退出登录
                  _buildLogoutSection(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [JinBeanColors.primary, JinBeanColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(64),
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
                // 用户信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '服务商',
                              style: TextStyle(
                          color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                          ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '管理您的账户设置',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // 箭头
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withValues(alpha: 0.7),
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
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: JinBeanColors.primaryDark,
        fontSize: 16,
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
        const SizedBox(height: 8),
        _buildSettingsCard(
          context,
          onTap: () => Get.toNamed('/provider/schedule'),
          icon: Icons.schedule_outlined,
          title: '日程安排',
          subtitle: '管理工作时间',
        ),
        const SizedBox(height: 8),
        _buildSettingsCard(
          context,
          onTap: () => Get.toNamed('/provider/reviews'),
          icon: Icons.star_outline,
          title: '评价管理',
          subtitle: '查看客户评价',
          badge: '12',
        ),
        const SizedBox(height: 8),
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
        const SizedBox(height: 8),
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
        const SizedBox(height: 8),
        _buildSettingsCard(
          context,
          onTap: () => Get.toNamed('/provider/language_settings'),
          icon: Icons.language_outlined,
          title: '语言设置',
          subtitle: '选择显示语言',
        ),
        const SizedBox(height: 8),
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
        const SizedBox(height: 8),
        _buildSettingsCard(
          context,
          onTap: () => Get.toNamed('/provider/security'),
          icon: Icons.security_outlined,
          title: '安全设置',
          subtitle: '账户安全配置',
        ),
        const SizedBox(height: 8),
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

  Widget _buildLogoutSection(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showLogoutDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '退出登录',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
            color: JinBeanColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
            color: JinBeanColors.primary,
            size: 24,
                  ),
                ),
        title: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
                              ),
                            ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
                          if (badge != null)
                            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeColor ?? JinBeanColors.primary,
                  borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                        ),
                      ),
            const SizedBox(width: 8),
            Icon(
                  Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
                ),
              ],
            ),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      Get.offAllNamed('/auth');
    } catch (e) {
      Get.snackbar(
        '错误',
        '退出登录失败，请重试',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
} 