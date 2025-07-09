import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/auth/presentation/auth_controller.dart';
import 'package:jinbeanpod_83904710/app/theme/app_colors.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/plugin_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:jinbeanpod_83904710/app/theme/app_theme_service.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';

const Color customerColor = Color(0xFF006D77); // dark teal
const Color providerColor = Color(0xFFFFC300); // golden

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
    _showRoleSwitch = Get.arguments?['showRoleSwitch'] == true || 
                     Get.find<AuthController>().userProfileRole.value == 'customer+provider';
    AppLogger.info('LoginPage initState, showRoleSwitch=[200m$_showRoleSwitch[0m', tag: 'LoginPage');
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
                Text(
                  AppLocalizations.of(context)!.welcomeBack,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.signInToContinue,
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
                    labelText: AppLocalizations.of(context)!.usernameHint,
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
                    labelText: AppLocalizations.of(context)!.passwordHint,
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
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () async {
                    AppLogger.info('Login button pressed, showRoleSwitch=$_showRoleSwitch, selectedRole=[200m${controller.selectedLoginRole.value}[0m', tag: 'LoginPage');
                    // 登录逻辑保持不变
                    if (!_showRoleSwitch) {
                      final loginSuccess = await controller.login();
                      AppLogger.info('Login result: $loginSuccess', tag: 'LoginPage');
                      if (!loginSuccess) return;
                      final userRole = controller.userProfileRole.value;
                      AppLogger.info('User role after login: $userRole', tag: 'LoginPage');
                      if (userRole == 'customer+provider') {
                        setState(() {
                          _showRoleSwitch = true;
                        });
                        AppLogger.info('Switching to role selection UI', tag: 'LoginPage');
                        return;
                      } else {
                        // 登录成功后，保存 per-role 主题
                        final themeService = Get.find<AppThemeService>();
                        final themeName = userRole == 'provider' ? 'golden' : 'dark_teal';
                        themeService.setThemeForRole(userRole, themeName);
                        Get.find<PluginManager>().currentRole.value = userRole;
                        AppLogger.info('Login success, navigating to main page, role=$userRole', tag: 'LoginPage');
                        if (userRole == 'provider') {
                          Get.offAllNamed('/provider_home');
                        } else {
                          Get.offAllNamed('/main_shell');
                        }
                      }
                    } else {
                      final selectedRole = controller.selectedLoginRole.value;
                      // 登录成功后，保存 per-role 主题
                      final themeService = Get.find<AppThemeService>();
                      final themeName = selectedRole == 'provider' ? 'golden' : 'dark_teal';
                      themeService.setThemeForRole(selectedRole, themeName);
                      Get.find<PluginManager>().currentRole.value = selectedRole;
                      AppLogger.info('Login success, navigating to main page, selectedRole=$selectedRole', tag: 'LoginPage');
                      if (selectedRole == 'provider') {
                        Get.offAllNamed('/provider_home');
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
                    backgroundColor: controller.selectedLoginRole.value == 'provider'
                        ? providerColor
                        : customerColor,
                    foregroundColor: controller.selectedLoginRole.value == 'provider'
                        ? Colors.black
                        : Colors.white,
                  ),
                  child: controller.isLoading.value
                      ? CircularProgressIndicator(
                          color: controller.selectedLoginRole.value == 'provider'
                              ? Colors.black
                              : Colors.white,
                        )
                      : Text(_showRoleSwitch ? AppLocalizations.of(context)!.continueText : AppLocalizations.of(context)!.loginButton),
                )),
                const SizedBox(height: 16),
                // Register Link
                TextButton(
                  onPressed: () {
                    print('[LoginPage] 跳转注册页: /register');
                    Get.toNamed('/register');
                  },
                  child: Text(
                    AppLocalizations.of(context)!.noAccountPrompt,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
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