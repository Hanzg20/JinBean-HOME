import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../profile/provider_profile_controller.dart'; // Corrected import path

class ProfileDetailsPage extends StatelessWidget {
  const ProfileDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderProfileController());
    return Scaffold(
      appBar: AppBar(title: const Text('个人资料')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundImage: (controller.avatarUrl.value.isNotEmpty && controller.avatarUrl.value.startsWith('http'))
                    ? NetworkImage(controller.avatarUrl.value)
                    : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                controller.displayName.value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Chip(
                label: Text('认证状态：${controller.certificationStatus.value}'),
                backgroundColor: controller.certificationStatus.value == 'approved'
                    ? Colors.green[100]
                    : controller.certificationStatus.value == 'pending'
                        ? Colors.orange[100]
                        : Colors.red[100],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(controller.email.value),
              subtitle: const Text('邮箱'),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(controller.phone.value),
              subtitle: const Text('手机号'),
            ),
            ListTile(
              leading: const Icon(Icons.business_center),
              title: Text(controller.providerType.value),
              subtitle: const Text('服务商类型'),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: Text(controller.serviceCategories.join(', ')),
              subtitle: const Text('主营服务类别'),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('退出登录'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              onPressed: controller.logout,
            ),
          ],
        );
      }),
    );
  }
} 