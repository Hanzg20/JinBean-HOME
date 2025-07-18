import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/profile/presentation/profile_controller.dart';

class EditProfilePage extends GetView<ProfileController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: () => _saveProfile(),
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 头像与基本信息横向并排
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundImage: controller.avatarUrl.value.isNotEmpty
                                    ? NetworkImage(controller.avatarUrl.value)
                                    : null,
                                child: controller.avatarUrl.value.isEmpty
                                    ? const Icon(Icons.person, size: 36, color: Colors.grey)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _changeAvatar,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: TextEditingController(text: controller.userName.value),
                                        onChanged: (v) => controller.userName.value = v,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        decoration: const InputDecoration(
                                          labelText: 'Display Name',
                                          isDense: true,
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        controller.userLevel.value,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.card_giftcard, size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text('${controller.userPoints.value}', style: const TextStyle(fontSize: 13)),
                                    const SizedBox(width: 12),
                                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(controller.memberSince.value, style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      // 资料编辑表单（卡片分组，紧凑）
                      _buildCompactField(
                        label: 'Bio',
                        icon: Icons.info_outline,
                        initialValue: controller.userBio.value,
                        onChanged: (v) => controller.userBio.value = v,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      // 悬浮保存按钮
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('Save'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          onPressed: _saveProfile,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildCompactField({
    required String label,
    required IconData icon,
    required String initialValue,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: initialValue),
            onChanged: onChanged,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              labelText: label,
              isDense: true,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 6),
            ),
          ),
        ),
      ],
    );
  }

  void _changeAvatar() {
    // TODO: Implement avatar upload functionality
    Get.snackbar(
      'Coming Soon',
      'Avatar upload functionality will be implemented soon.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _saveProfile() async {
    try {
      await controller.updateUserProfile(
        displayName: controller.userName.value,
        bio: controller.userBio.value,
      );
      Get.back(); // Navigate back to profile page
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
} 