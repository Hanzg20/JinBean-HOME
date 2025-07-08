import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/plugin_management/plugin_manager.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/app_plugin.dart';
import 'package:jinbeanpod_83904710/app/shell_app_controller.dart';

class ShellApp extends GetView<ShellAppController> {
  const ShellApp({super.key});

  @override
  Widget build(BuildContext context) {
    final PluginManager pluginManager = Get.find<PluginManager>();

    return Obx(() {
      print('[ShellApp] Obx build triggered.');
      try {
        final role = pluginManager.currentRole.value;
        print('[ShellApp] PluginManager hash: [36m[1m[4m[7m${pluginManager.hashCode}[0m');
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
        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: controller.currentIndex,
              children: pluginWidgets,
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex,
            onTap: controller.changeTab,
            items: bottomNavItems,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            showUnselectedLabels: true,
            elevation: 8,
          ),
        );
      } catch (e, stack) {
        print('[ShellApp] Obx build error: '
            '[31m$e\n$stack[0m');
        return Scaffold(
          body: Center(
            child: Text('Build error: '
                '[31m$e\n$stack[0m'),
          ),
        );
      }
    });
  }
}
