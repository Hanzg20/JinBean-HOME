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
      print('[ShellApp] Obx build triggered.');
      try {
        final role = pluginManager.currentRole.value;
        print('[ShellApp] PluginManager hash: ${pluginManager.hashCode}');
        final enabledTabPluginsRx =
            pluginManager.enabledTabPluginsForCurrentRole;
        final enabledTabPlugins = enabledTabPluginsRx.toList(); // 强制触发响应式
        final rxHash = enabledTabPluginsRx.hashCode;
        final len = enabledTabPluginsRx.length;
        print('[ShellApp] Obx build, enabledTabPluginsRx.hashCode: $rxHash, .length: $len, ids: ${enabledTabPlugins.map((e) => e.id).join(',')}');
        print('[ShellApp] 当前role: $role');
        print('[ShellApp] enabledTabPlugins.length: ${enabledTabPlugins.length}');
        for (var meta in enabledTabPlugins) {
          print('[ShellApp] enabledTabPlugin: id=${meta.id}, route=${meta.routeName ?? 'null'}, role=${meta.role ?? 'null'}');
        }

        // 优化：只在数据准备好时渲染底部导航栏，否则显示 loading
        if (!pluginManager.isInitialized || enabledTabPlugins.isEmpty) {
          print('[ShellApp] PluginManager not initialized or no enabledTabPlugins, showing loading.');
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

        print(
            '[ShellApp] BottomNavigationBar build, items: ${bottomNavItems.map((e) => e.label).join(',')}');
        final colorScheme = theme.colorScheme;
        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: IndexedStack(
                index: controller.currentIndex,
                children: pluginWidgets,
              ),
            ),
          ),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white.withOpacity(0.7),
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
              unselectedItemColor: Colors.white.withOpacity(0.7),
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
        print('[ShellApp] Error in build: $e');
        print('[ShellApp] Stack trace: $stackTrace');
        return const Scaffold(
          body: Center(
            child: Text('Error loading app'),
          ),
        );
      }
    });
  }
}
