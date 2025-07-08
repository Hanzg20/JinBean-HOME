import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/profile/presentation/profile_controller.dart';
import 'package:jinbeanpod_83904710/app/theme/app_colors.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/plugin_manager.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/provider_identity/provider_identity_service.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/provider_registration/provider_registration_plugin.dart';

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
            expandedHeight: 220.0, // Increased height for more content
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Obx(() { // This Obx block
                  print('[ProfilePage] Obx 1 (header) rebuild.'); // Added log
                  return Stack(
                      children: [
                        Positioned.fill(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              // Avatar with verification badges
                              Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () => _showFullScreenAvatar(context),
                                    child: Obx(() { // Inner Obx for avatar
                                      final imageUrl =
                                          controller.avatarUrl.value;
                                      print(
                                          '[ProfilePage] CircleAvatar imageUrl before use: $imageUrl');
                                      return CircleAvatar(
                                        radius: 50,
                                        backgroundImage: (imageUrl.isNotEmpty &&
                                                imageUrl.startsWith('http'))
                                            ? NetworkImage(imageUrl)
                                            : const AssetImage(
                                                    'assets/images/default_avatar.png')
                                                as ImageProvider,
                                      );
                                    }),
                                  ),
                                  if (controller.isEmailVerified.value) // Obx for email verified
                                    Obx(() { // Added Obx here for logging purposes
                                      print('[ProfilePage] isEmailVerified Obx rebuild. Value: ${controller.isEmailVerified.value}');
                                      return Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppColors.successColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                              width: 2),
                                        ),
                                        child: Icon(Icons.verified,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            size: 16),
                                      ),
                                    );
                                    }),
                                  if (controller.isPhoneVerified.value) // Obx for phone verified
                                    Obx(() { // Added Obx here for logging purposes
                                      print('[ProfilePage] isPhoneVerified Obx rebuild. Value: ${controller.isPhoneVerified.value}');
                                      return Positioned(
                                      left: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                              width: 2),
                                        ),
                                        child: const Icon(Icons.phone_android,
                                            color: Colors.white, size: 16),
                                      ),
                                    );
                                    }),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // User Name and Level
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Obx(() { // Obx for user name
                                    print('[ProfilePage] userName Obx rebuild. Value: ${controller.userName.value}');
                                    return Text(
                                    controller.userName.value,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                  }),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.warningColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Obx(() { // Obx for user level
                                      print('[ProfilePage] userLevel Obx rebuild. Value: ${controller.userLevel.value}');
                                      return Text(
                                      controller.userLevel.value,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                    }),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // User Bio
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: FittedBox( // Use FittedBox to prevent overflow for user bio
                                  fit: BoxFit.scaleDown,
                                  child: Obx(() { // Obx for user bio
                                    print('[ProfilePage] userBio Obx rebuild. Value: ${controller.userBio.value}');
                                    return Text(
                                    controller.userBio.value,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                }), // End of Obx 1
              ),
            ),
          ),

          // User Stats
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Obx(() { // Obx for user stats
                    print('[ProfilePage] userRating Obx rebuild. Value: ${controller.userRating.value}');
                    return _buildStatItem(
                    context,
                    Icons.star,
                    '${controller.userRating.value}',
                    'Rating',
                  );
                  }),
                  Obx(() { // Obx for user stats
                    print('[ProfilePage] userPoints Obx rebuild. Value: ${controller.userPoints.value}');
                    return _buildStatItem(
                    context,
                    Icons.monetization_on,
                    '${controller.userPoints.value}',
                    '金豆 (JinBean)',
                  );
                  }),
                  Obx(() { // Obx for user stats
                    print('[ProfilePage] memberSince Obx rebuild. Value: ${controller.memberSince.value}');
                    return _buildStatItem(
                    context,
                    Icons.calendar_today,
                    controller.memberSince.value,
                    'Member Since',
                  );
                  }),
                ],
              ),
            ),
          ),

          // Account Management
          _buildSectionHeader(context, '账户管理'),
          _buildSectionGrid(
            context,
            [controller.accountMenuItems[0]], // Edit Profile
          ),
          _buildSectionGrid(
            context,
            controller.accountMenuItems
                .sublist(1, 6), // My Orders to Payment Methods
          ),
          _buildSectionGrid(
            context,
            [controller.accountMenuItems[6]], // Switch to Provider
          ),

          // App Preferences
          _buildSectionHeader(context, '应用设置'),
          _buildSectionGrid(
            context,
            controller.settingsMenuItems
                .sublist(0, 5), // Notifications to Location Settings
          ),

          // Help & Legal
          _buildSectionHeader(context, '帮助与法律'),
          _buildSectionGrid(
            context,
            controller.settingsMenuItems
                .sublist(6, 10), // About Us to Privacy Policy
          ),

          // Other Actions
          _buildSectionHeader(context, '其他操作'),
          _buildSectionGrid(
            context,
            [
              controller.settingsMenuItems[5],
              controller.settingsMenuItems.last
            ], // Clear Cache and Logout
          ),

          // Bottom Padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: FutureBuilder<ProviderStatus>(
                future: ProviderIdentityService.getProviderStatus(),
                builder: (context, snapshot) {
                  final status = snapshot.data ?? ProviderStatus.notProvider;
                  if (status == ProviderStatus.approved) {
                    // 只保留按钮点击时才切换角色和跳转，移除自动切换逻辑
                    return ElevatedButton.icon(
                      icon: const Icon(Icons.switch_account),
                      label: const Text('切换到服务商'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: () {
                        Get.find<PluginManager>().setRole('provider');
                        Get.offAllNamed('/provider_home');
                      },
                    );
                  } else if (status == ProviderStatus.pending) {
                    return ElevatedButton.icon(
                      icon: const Icon(Icons.hourglass_empty),
                      label: const Text('等待审核中'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: null,
                    );
                  } else {
                    return ElevatedButton.icon(
                      icon: const Icon(Icons.app_registration),
                      label: const Text('注册服务商'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProviderRegistrationPlugin().entryPage,
                          ),
                        );
                        if (result == true)
                          controller.loadUserProfile(); // 注册后自动刷新
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
    );
  }

  Widget _buildSectionGrid(BuildContext context, List<ProfileMenuItem> items) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 1.1,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: item.onTap,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon,
                          size: 24, color: Theme.of(context).primaryColor),
                      if (item.badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.errorColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.badge!,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 9),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  void _showFullScreenAvatar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            InteractiveViewer(
              child: Obx(() {
                final imageUrl = controller.avatarUrl.value;
                print(
                    '[ProfilePage] _showFullScreenAvatar imageUrl before use: $imageUrl');
                if (imageUrl.startsWith('http') && imageUrl.isNotEmpty) {
                  return Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  );
                } else {
                  return Image(
                    image: const AssetImage('assets/images/default_avatar.png'),
                    fit: BoxFit.contain,
                  );
                }
              }),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(Icons.close,
                    color: Theme.of(context).colorScheme.onSurface),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
