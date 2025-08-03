import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/profile/presentation/profile_controller.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/plugin_manager.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/provider_identity/provider_identity_service.dart';
import 'package:jinbeanpod_83904710/features/customer/auth/presentation/auth_controller.dart';
import 'package:jinbeanpod_83904710/core/ui/components/customer_theme_components.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/customer_theme_utils.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    print('[ProfilePage] build method called.'); // Added log

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
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
                child: Obx(() {
                  print('[ProfilePage] Obx 1 (header) rebuild.'); // Added log
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.userName.value,
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    controller.userBio.value.isNotEmpty ? controller.userBio.value : 'No bio yet',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onPrimary.withOpacity(0.8),
                                    ),
                                    ),
                                  const SizedBox(height: 8),
                                  // 用户统计信息
                                  Row(
                                    children: [
                                      Expanded(child: _buildStatItem('Rating', '${controller.userRating.value}')),
                                      const SizedBox(width: 16),
                                      Expanded(child: _buildStatItem('Points', '${controller.userPoints.value}')),
                                      const SizedBox(width: 16),
                                      Expanded(child: _buildStatItem('Member', controller.memberSince.value)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // 编辑按钮
                            IconButton(
                              onPressed: () => Get.toNamed('/edit_profile'),
                              icon: Icon(Icons.edit, color: colorScheme.onPrimary, size: 20),
                              style: IconButton.styleFrom(
                                backgroundColor: colorScheme.onPrimary.withOpacity(0.2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                  }),
              ),
            ),
          ),

          // 账户管理卡片组
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle('Account Management'),
                const SizedBox(height: 8), // 减少间距
                _buildAccountCard(),
                const SizedBox(height: 16), // 减少间距

                // 服务管理卡片组
                _buildSectionTitle('Service Management'),
                const SizedBox(height: 8), // 减少间距
                _buildServiceCard(),
                const SizedBox(height: 16), // 减少间距

                // 设置卡片组
                _buildSectionTitle('Settings'),
                const SizedBox(height: 8), // 减少间距
                _buildSettingsCard(),
                const SizedBox(height: 16), // 减少间距

                // 帮助与支持卡片组
                _buildSectionTitle('Help & Support'),
                const SizedBox(height: 8), // 减少间距
                _buildHelpCard(),
                const SizedBox(height: 16), // 减少间距

                // 角色切换按钮
                _buildRoleSwitchCard(),
                const SizedBox(height: 80), // 为底部留空间
              ]),
            ),
          ),
        ],
      ),
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
                subtitle: 'Change app language',
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
                        Icon(Icons.switch_account, color: colorScheme.primary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Switch to Provider Mode',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Manage your services and orders',
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
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.switch_account, color: colorScheme.onPrimary),
                        label: Text(
                          'Switch to Provider',
                          style: TextStyle(color: colorScheme.onPrimary),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Get.find<PluginManager>().setRole('provider');
                          Get.offAllNamed('/provider_home');
                        },
                      ),
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
              borderRadius: BorderRadius.circular(8), // 减小圆角
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
    Get.dialog(
      AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                Get.back();
                // TODO: Implement language change
              },
            ),
            ListTile(
              title: const Text('中文'),
              onTap: () {
                Get.back();
                // TODO: Implement language change
              },
            ),
          ],
        ),
      ),
    );
  }

  void _contactSupport() {
    Get.snackbar(
      'Contact Support',
      'Opening support chat...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
