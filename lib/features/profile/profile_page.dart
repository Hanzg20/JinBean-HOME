import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/plugin_manager.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/provider_identity/provider_identity_service.dart';
import 'package:jinbeanpod_83904710/app/shell_app_controller.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:jinbeanpod_83904710/core/controllers/shell_app_controller.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';
// 如有 provider_home_plugin 也可 import
// import '../../provider/plugins/provider_home/provider_home_plugin.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n?.profile ?? 'Profile')),
      body: Column(
        children: [
          // ... 其它 profile 信息 ...
          FutureBuilder<ProviderStatus>(
            future: ProviderIdentityService.getProviderStatus(),
            builder: (context, snapshot) {
              final status = snapshot.data ?? ProviderStatus.notProvider;
              AppLogger.info('[ProfilePage] 当前用户 ProviderStatus: $status');
              if (status == ProviderStatus.approved) {
                AppLogger.info('[ProfilePage] 显示"切换到服务商"按钮');
                return ElevatedButton(
                  onPressed: () async {
                    AppLogger.info('[ProfilePage] 用户点击"切换到服务商"');
                    try {
                      await Get.find<PluginManager>().setRole('provider');
                      AppLogger.info('[ProfilePage] Role switched to provider successfully');
                    } catch (e) {
                      AppLogger.error('[ProfilePage] Error switching role: $e');
                    }
                    // 修复：切换角色后重置tab index，防止IndexedStack越界
                    try {
                      Get.find<ShellAppController>().changeTab(0);
                    } catch (e) {
                      AppLogger.info(
                          '[ProfilePage] ShellAppController not found or error: $e');
                    }
                    // 热重启App，彻底切换到provider端
                    if (context.mounted) {
                      Phoenix.rebirth(context);
                    }
                  },
                  child: Text(l10n?.switchToProvider ?? 'Switch to Provider'),
                );
              } else if (status == ProviderStatus.pending) {
                AppLogger.info('[ProfilePage] 显示"等待审核中"按钮');
                return ElevatedButton(
                  onPressed: null,
                  child:
                      Text(l10n?.waitingForApproval ?? 'Waiting for Approval'),
                );
              } else {
                AppLogger.info('[ProfilePage] 显示"注册服务商"按钮');
                return ElevatedButton(
                  onPressed: () {
                    AppLogger.info('[ProfilePage] 用户点击"注册服务商"');
                    Get.toNamed('/provider_registration');
                  },
                  child:
                      Text(l10n?.registerAsProvider ?? 'Register as Provider'),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
