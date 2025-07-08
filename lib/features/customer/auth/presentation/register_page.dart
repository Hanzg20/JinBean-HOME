import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/auth/presentation/auth_controller.dart';
import 'package:jinbeanpod_83904710/l10n/generated/app_localizations.dart'; // 导入国际化类
import 'package:jinbeanpod_83904710/app/theme/app_colors.dart'; // Import AppColors

class RegisterPage extends GetView<AuthController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // Use global background color
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.registerPageTitle),
        backgroundColor: Theme.of(context).colorScheme.primary, // Changed from AppColors.primaryColor
        foregroundColor: Theme.of(context).colorScheme.onPrimary, // Changed from AppColors.cardColor
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: controller.emailController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.usernameHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Apply consistent border radius
                ),
                prefixIcon: Icon(Icons.email, color: Theme.of(context).colorScheme.primary), // Changed from AppColors.primaryColor
              ),
              onChanged: (value) => controller.errorMessage.value = '', // 清除错误信息
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.passwordHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Apply consistent border radius
                ),
                prefixIcon: Icon(Icons.lock, color: Theme.of(context).colorScheme.primary), // Changed from AppColors.primaryColor
              ),
              onChanged: (value) => controller.errorMessage.value = '', // 清除错误信息
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Apply consistent border radius
                ),
                prefixIcon: Icon(Icons.lock_reset, color: Theme.of(context).colorScheme.primary), // Changed from AppColors.primaryColor
              ),
              onChanged: (value) => controller.errorMessage.value = '', // 清除错误信息
            ),
            const SizedBox(height: 16),
            Obx(() => Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: AppColors.errorColor), // Use error color
                )),
            const SizedBox(height: 16),
            Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          // 获取邮箱和密码，调用controller.register()
                          final password = controller.passwordController.text;
                          final confirmPassword = controller.confirmPasswordController.text;
                          if (password != confirmPassword) {
                            controller.errorMessage.value = 'Passwords do not match';
                            return;
                          }
                          controller.register();
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16), // Apply consistent padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Apply consistent border radius
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary, // Changed from AppColors.primaryColor
                    foregroundColor: Theme.of(context).colorScheme.onPrimary, // Changed to onPrimary
                  ),
                  child: controller.isLoading.value
                      ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary) // Changed color to onPrimary
                      : Text(AppLocalizations.of(context)!.registerButton),
                )),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // 返回登录页面
                Get.back();
              },
              child: Text(
                AppLocalizations.of(context)!.alreadyHaveAccountPrompt,
                style: TextStyle(color: Theme.of(context).colorScheme.primary), // Changed to primary
              ),
            ),
          ],
        ),
      ),
    );
  }
} 