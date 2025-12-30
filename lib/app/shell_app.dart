import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/plugin_management/plugin_manager.dart';
import 'package:jinbeanpod_83904710/app/shell_app_controller.dart';

class ShellApp extends GetView<ShellAppController> {
  const ShellApp({super.key});

  @override
  Widget build(BuildContext context) {
    final PluginManager pluginManager = Get.find<PluginManager>();
    final theme = Theme.of(context);

    return Obx(() {
      // 移除所有阻塞性日志输出，只保留关键信息
      try {
        final role = pluginManager.currentRole.value;
        final enabledTabPluginsRx = pluginManager.enabledTabPluginsForCurrentRole;
        final enabledTabPlugins = enabledTabPluginsRx.toList(); // 强制触发响应式

        // 优化：只在数据准备好时渲染底部导航栏，否则显示 loading
        if (!pluginManager.isInitialized || enabledTabPlugins.isEmpty) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(), // Display a loading indicator
            ),
          );
        }

        final List<BottomNavigationBarItem> bottomNavItems =
            enabledTabPlugins.map((meta) {
          return BottomNavigationBarItem(
            icon: Icon(meta.icon),
            label: meta.nameKey.tr,
          );
        }).toList();

        final List<Widget> pluginWidgets = enabledTabPlugins.map((meta) {
          final plugin = pluginManager.registeredPlugins
              .firstWhere((p) => p.metadata.id == meta.id);
          return plugin.buildEntryWidget();
        }).toList();

        // 移除阻塞性日志输出
        final colorScheme = theme.colorScheme;

        // 安全获取tab index，防止越界
        final safeIndex = controller.currentIndex.clamp(0, pluginWidgets.length - 1);

        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: IndexedStack(
                index: safeIndex,
                children: pluginWidgets,
              ),
            ),
          ),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white.withValues(alpha: 0.7),
                backgroundColor: colorScheme.primary,
                elevation: 8,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: controller.currentIndex,
              onTap: controller.changeTab,
              items: bottomNavItems,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white.withValues(alpha: 0.7),
              backgroundColor: colorScheme.primary,
              elevation: 8,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
              showUnselectedLabels: true,
            ),
          ),
        );
      } catch (e, stackTrace) {
        // 只在真正发生错误时才输出日志
        AppLogger.error('[ShellApp] Error in build: $e', error: e, stackTrace: stackTrace);
        return const Scaffold(
          body: Center(
            child: Text('Error loading app'),
          ),
        );
      }
    });
  }
}
