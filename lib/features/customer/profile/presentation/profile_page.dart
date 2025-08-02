import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/profile/presentation/profile_controller.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/plugin_manager.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/provider_identity/provider_identity_service.dart';
import 'package:jinbeanpod_83904710/features/customer/auth/presentation/auth_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    print('[ProfilePage] build method called.'); // Added log

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
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
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                      ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 37,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: controller.avatarUrl.value.isNotEmpty
                                      ? NetworkImage(controller.avatarUrl.value)
                                      : null,
                                  child: controller.avatarUrl.value.isEmpty
                                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
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
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    controller.userBio.value.isNotEmpty ? controller.userBio.value : 'No bio yet',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
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
                              icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Account Management'),
                  const SizedBox(height: 12),
                  _buildAccountCard(),
                  const SizedBox(height: 24),

                  // 服务管理卡片组
                  _buildSectionTitle('Service Management'),
                  const SizedBox(height: 12),
                  _buildServiceCard(),
                  const SizedBox(height: 24),

                  // 设置卡片组
                  _buildSectionTitle('Settings'),
                  const SizedBox(height: 12),
                  _buildSettingsCard(),
                  const SizedBox(height: 24),

                  // 帮助与支持卡片组
                  _buildSectionTitle('Help & Support'),
                  const SizedBox(height: 12),
                  _buildHelpCard(),
                  const SizedBox(height: 24),

                  // 角色切换按钮
                  _buildRoleSwitchCard(),
                  const SizedBox(height: 80), // 为底部留空间
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
          title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildAccountCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  }

  Widget _buildServiceCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  }

  Widget _buildSettingsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  }

  Widget _buildHelpCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  }

  Widget _buildRoleSwitchCard() {
            return Card(
              elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<ProviderStatus>(
          future: ProviderIdentityService.getProviderStatus(),
          builder: (context, snapshot) {
            final status = snapshot.data ?? ProviderStatus.notProvider;
            if (status == ProviderStatus.approved) {
              return Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.switch_account, color: Colors.blue, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                  child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Switch to Provider Mode',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage your services and orders',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
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
                      icon: const Icon(Icons.switch_account),
                      label: const Text('Switch to Provider'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
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
            } else if (status == ProviderStatus.pending) {
              return Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.hourglass_empty, color: Colors.orange, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Provider Application Pending',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your application is under review',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
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
                      icon: const Icon(Icons.hourglass_empty),
                      label: const Text('Waiting for Approval'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: null,
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.business, color: Colors.green, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Become a Service Provider',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                              'Start offering your services',
                        style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
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
                      icon: const Icon(Icons.business),
                      label: const Text('Apply Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Get.toNamed('/provider_registration'),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.grey[700]),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: Colors.grey[200],
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
