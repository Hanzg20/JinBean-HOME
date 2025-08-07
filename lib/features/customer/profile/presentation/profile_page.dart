import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/profile/presentation/profile_controller.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/plugin_manager.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/provider_identity/provider_identity_service.dart';
import 'package:jinbeanpod_83904710/features/customer/auth/presentation/auth_controller.dart';
import 'package:jinbeanpod_83904710/core/ui/components/customer_theme_components.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/customer_theme_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Import platform components
import 'package:jinbeanpod_83904710/core/components/platform_core.dart';
import 'package:jinbeanpod_83904710/features/customer/services/presentation/widgets/service_detail_loading.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 平台组件状态管理
  final LoadingStateManager _loadingManager = LoadingStateManager();
  
  @override
  void initState() {
    super.initState();
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

  /// 加载用户资料数据
  Future<void> _loadProfileData() async {
    try {
      _loadingManager.setLoading();
      
      // 加载用户资料
      final controller = Get.put(ProfileController());
      await controller.loadUserProfile();
      
      _loadingManager.setSuccess();
    } catch (e) {
      _loadingManager.setError('加载用户资料失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    print('[ProfilePage] build method called.'); // Added log

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: ListenableBuilder(
        listenable: _loadingManager,
        builder: (context, child) {
          return ServiceDetailLoading(
            state: _loadingManager.state,
            loadingMessage: '加载用户资料...',
            errorMessage: _loadingManager.errorMessage,
            onRetry: () => _loadProfileData(),
            onBack: () => Get.back(),
            showSkeleton: true,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(context, controller, theme, colorScheme),
                  
                  // Profile Content
                  _buildProfileContent(context, controller, theme, colorScheme),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileController controller, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      height: 200.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 头像和用户信息横向布局
              Row(
                children: [
                  // 头像
                  GestureDetector(
                    onTap: () => _showAvatarOptions(context),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.onPrimary, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 37,
                        backgroundColor: colorScheme.surfaceVariant,
                        backgroundImage: controller.avatarUrl.value.isNotEmpty
                            ? NetworkImage(controller.avatarUrl.value)
                            : null,
                        child: controller.avatarUrl.value.isEmpty
                            ? Icon(Icons.person, size: 40, color: colorScheme.onSurfaceVariant)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 用户信息
                  Expanded(
                    child: Obx(() {
                      print('[ProfilePage] Obx 1 (header) rebuild.'); // Added log
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.userName.value.isNotEmpty
                                ? controller.userName.value
                                : 'User Name',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.userBio.value.isNotEmpty
                                ? controller.userBio.value
                                : 'No bio yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimary.withOpacity(0.8),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileController controller, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // 账户管理卡片组
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Account Management'),
              const SizedBox(height: 8),
              _buildAccountCard(),
              const SizedBox(height: 16),

              // 服务管理卡片组
              _buildSectionTitle('Service Management'),
              const SizedBox(height: 8),
              _buildServiceCard(),
              const SizedBox(height: 16),

              // 设置卡片组
              _buildSectionTitle('Settings'),
              const SizedBox(height: 8),
              _buildSettingsCard(),
              const SizedBox(height: 16),

              // 帮助与支持卡片组
              _buildSectionTitle('Help & Support'),
              const SizedBox(height: 8),
              _buildHelpCard(),
              const SizedBox(height: 16),

              // 角色切换按钮
              _buildRoleSwitchCard(),
              const SizedBox(height: 80), // 为底部留空间
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimary.withOpacity(0.8),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        );
      },
    );
  }

  Widget _buildAccountCard() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return CustomerCard(
          margin: EdgeInsets.zero, // 移除默认margin
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                onTap: () => Get.toNamed('/edit_profile'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.location_on_outlined,
                title: 'My Addresses',
                subtitle: 'Manage your delivery addresses',
                onTap: () => Get.toNamed('/addresses'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.payment_outlined,
                title: 'Payment Methods',
                subtitle: 'Manage your payment options',
                onTap: () => Get.toNamed('/payment_methods'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.favorite_outline,
                title: 'Saved Services',
                subtitle: 'View your favorite services',
                onTap: () => Get.toNamed('/saved_services'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceCard() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return CustomerCard(
          margin: EdgeInsets.zero, // 移除默认margin
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.receipt_long_outlined,
                title: 'My Orders',
                subtitle: 'View and manage your orders',
                onTap: () => Get.toNamed('/orders'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.rate_review_outlined,
                title: 'My Reviews',
                subtitle: 'View your service reviews',
                onTap: () => Get.toNamed('/my_reviews'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.message_outlined,
                title: 'Messages',
                subtitle: 'Chat with service providers',
                onTap: () => Get.toNamed('/messages'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsCard() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return CustomerCard(
          margin: EdgeInsets.zero, // 移除默认margin
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage your notification preferences',
                onTap: () => Get.toNamed('/notifications'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: _getCurrentLanguageText(),
                onTap: () => _showLanguageDialog(),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.security_outlined,
                title: 'Privacy & Security',
                subtitle: 'Manage your privacy settings',
                onTap: () => Get.toNamed('/privacy'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.palette_outlined,
                title: 'Theme Settings',
                subtitle: 'Switch app color theme',
                onTap: () => Get.toNamed('/theme_settings'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Sign Out',
                subtitle: 'Log out of your account',
                onTap: () async {
                  await Get.find<AuthController>().logout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 获取当前语言显示文本
  String _getCurrentLanguageText() {
    final currentLocale = Get.locale ?? const Locale('en');
    switch (currentLocale.languageCode) {
      case 'zh':
        return '当前语言: 简体中文';
      case 'en':
      default:
        return 'Current Language: English';
    }
  }

  Widget _buildHelpCard() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return CustomerCard(
          margin: EdgeInsets.zero, // 移除默认margin
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Help Center',
                subtitle: 'Get help and support',
                onTap: () => Get.toNamed('/help'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.contact_support_outlined,
                title: 'Contact Us',
                subtitle: 'Reach out to our support team',
                onTap: () => _contactSupport(),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'Read our terms and conditions',
                onTap: () => Get.toNamed('/terms'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Learn about our privacy practices',
                onTap: () => Get.toNamed('/privacy_policy'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleSwitchCard() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return CustomerCard(
          margin: EdgeInsets.zero, // 移除默认margin
          child: FutureBuilder<ProviderStatus>(
            future: ProviderIdentityService.getProviderStatus(),
            builder: (context, snapshot) {
              final status = snapshot.data ?? ProviderStatus.notProvider;
              if (status == ProviderStatus.approved) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.business, color: colorScheme.primary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Provider Mode',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'You are currently in provider mode',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.business, color: colorScheme.primary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Become a Provider',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Start offering your services',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.add_business, color: colorScheme.primary),
                        label: Text(
                          'Apply Now',
                          style: TextStyle(color: colorScheme.primary),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Get.toNamed('/provider_application');
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 减少内边距
          leading: Container(
            width: 36, // 减小图标容器大小
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(24), // 右上角半径是其他角的4倍
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: Icon(icon, size: 18, color: colorScheme.onSurfaceVariant), // 减小图标大小
          ),
          title: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith( // 使用更小的字体
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith( // 使用更小的字体
              color: colorScheme.onSurfaceVariant,
              fontSize: 12, // 明确指定字体大小
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant, size: 16), // 减小图标大小
          onTap: onTap,
        );
      },
    );
  }

  Widget _buildDivider() {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Divider(
          height: 1,
          indent: 72,
          endIndent: 16,
          color: colorScheme.outline.withOpacity(0.2),
        );
      },
    );
  }

  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement camera functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement gallery functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('Remove Photo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement remove photo functionality
              },
            ),
          ],
        ),
            ),
    );
  }

  void _showLanguageDialog() {
    final currentLocale = Get.locale ?? const Locale('en');
    
    Get.dialog(
      AlertDialog(
        title: const Text('Select Language / 选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale>(
              title: const Text('English'),
              subtitle: const Text('English'),
              value: const Locale('en'),
              groupValue: currentLocale,
              onChanged: (locale) {
                if (locale != null) {
                Get.back();
                  _changeLanguage(locale);
                }
              },
            ),
            RadioListTile<Locale>(
              title: const Text('简体中文'),
              subtitle: const Text('Simplified Chinese'),
              value: const Locale('zh'),
              groupValue: currentLocale,
              onChanged: (locale) {
                if (locale != null) {
                Get.back();
                  _changeLanguage(locale);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel / 取消'),
          ),
        ],
      ),
    );
  }

  // 切换语言的方法
  void _changeLanguage(Locale locale) {
    Get.updateLocale(locale);
    
    // 显示切换成功的提示
    Get.snackbar(
      'Language Changed / 语言已切换',
      locale.languageCode == 'zh' ? '已切换到简体中文' : 'Switched to English',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
    
    // 使用GetX的方式刷新UI
    Get.forceAppUpdate();
  }

  void _contactSupport() {
    Get.snackbar(
      'Contact Support',
      'Opening support chat...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
