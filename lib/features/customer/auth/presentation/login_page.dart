import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/auth/presentation/auth_controller.dart';
import 'package:jinbeanpod_83904710/app/theme/app_colors.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/plugin_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showRoleSwitch = false;

  @override
  void initState() {
    super.initState();
    // 初始化时判断是否显示角色选择项
    _showRoleSwitch = Get.arguments?['showRoleSwitch'] == true;
    print('[LoginPage] initState: _showRoleSwitch = $_showRoleSwitch');
  }

  @override
  Widget build(BuildContext context) {
    // 自动填充测试账号密码
    final controller = Get.find<AuthController>();
    controller.emailController.text = '111@111.com';
    controller.passwordController.text = '111111';
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'JB',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Welcome Text
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Email Field
                TextField(
                  controller: controller.emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, color: Theme.of(context).colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Password Field
                Obx(() => TextField(
                  controller: controller.passwordController,
                  obscureText: !controller.isPasswordVisible.value,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )),
                const SizedBox(height: 24),
                if (_showRoleSwitch)
                  Obx(() => Center(
                        child: AnimatedToggleSwitch.dual(
                          current: controller.selectedLoginRole.value,
                          first: 'customer',
                          second: 'provider',
                          spacing: 8.0,
                          styleBuilder: (role) => ToggleStyle(
                            borderRadius: const BorderRadius.all(Radius.circular(30)),
                            indicatorColor: Colors.white,
                            backgroundColor: Colors.transparent,
                            borderColor: role == 'provider'
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary,
                            indicatorBorderRadius: const BorderRadius.all(Radius.circular(30)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          onChanged: (val) {
                            print('[LoginPage] Role changed to: $val');
                            controller.selectedLoginRole.value = val;
                          },
                          iconBuilder: (role) => role == 'provider'
                              ? Icon(Icons.engineering, color: Theme.of(context).colorScheme.primary)
                              : Icon(Icons.person, color: Theme.of(context).colorScheme.secondary),
                          textBuilder: (role) => Text(
                            role == 'provider' ? '服务者' : '客户',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          indicatorSize: const Size(56, 40),
                          height: 48,
                          loading: false,
                        ),
                      )),
                // Login Button
                ElevatedButton(
                  onPressed: () async {
                    if (!_showRoleSwitch) {
                      // 未显示角色选择项，执行登录流程
                      final loginSuccess = await controller.login();
                      if (!loginSuccess) return;
                      
                      // 登录成功后，重新判断是否显示角色选择项
                      final userRole = controller.userProfileRole.value;
                      print('[LoginPage] Login successful, user role: $userRole');
                      
                      if (userRole == 'customer+provider') {
                        // 多角色用户，显示角色选择项
                        print('[LoginPage] User is customer+provider, showing role switch');
                        setState(() {
                          _showRoleSwitch = true;
                        });
                        return; // 不跳转，让用户选择角色
                      } else {
                        // 单一角色用户，直接跳转
                        print('[LoginPage] User is single role: $userRole, navigating directly');
                        Get.find<PluginManager>().currentRole.value = userRole;
                        if (userRole == 'provider') {
                          Get.offAllNamed('/provider_shell');
                        } else {
                          Get.offAllNamed('/main_shell');
                        }
                      }
                    } else {
                      // 已显示角色选择项，直接使用选择的角色进行跳转
                      final selectedRole = controller.selectedLoginRole.value;
                      print('[LoginPage] User selected role: $selectedRole');
                      
                      // 确保selectedRole不为空
                      if (selectedRole.isEmpty) {
                        controller.selectedLoginRole.value = 'customer';
                        print('[LoginPage] Selected role was empty, defaulting to customer');
                      }
                      
                      // 使用选择的角色进行跳转
                      final finalRole = controller.selectedLoginRole.value;
                      Get.find<PluginManager>().currentRole.value = finalRole;
                      print('[LoginPage] Navigating with final role: $finalRole');
                      
                      if (finalRole == 'provider') {
                        Get.offAllNamed('/provider_shell');
                      } else {
                        Get.offAllNamed('/main_shell');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _showRoleSwitch ? '继续' : 'Sign In',
                    style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                const SizedBox(height: 16),
                // Register Link
                TextButton(
                  onPressed: () => Get.toNamed('/register'),
                  child: Text(
                    'Don\'t have an account? Sign Up',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 16),
                // 临时测试按钮：将当前用户设置为customer+provider角色
                if (controller.userProfileRole.value.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      await controller.setUserAsCustomerProvider();
                      setState(() {
                        _showRoleSwitch = true;
                      });
                      Get.snackbar(
                        '测试',
                        '用户角色已设置为 customer+provider',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: Text(
                      '测试：设置为多角色用户',
                      style: TextStyle(color: Colors.orange),
                  ),
                ),
                const SizedBox(height: 40),
                // Divider with "or" text
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.dividerColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.dividerColor)),
                  ],
                ),
                const SizedBox(height: 40),
                // Social Login Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Google Sign In Button
                    OutlinedButton.icon(
                      onPressed: controller.signInWithGoogle,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: AppColors.dividerColor),
                      ),
                      icon: Image.network(
                        'https://www.google.com/favicon.ico',
                        height: 24,
                      ),
                      label: Text('Google', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                    ),
                    // Apple Sign In Button
                    OutlinedButton.icon(
                      onPressed: controller.signInWithApple,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: AppColors.dividerColor),
                      ),
                      icon: Icon(Icons.apple, color: Theme.of(context).textTheme.bodyMedium?.color),
                      label: Text('Apple', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 