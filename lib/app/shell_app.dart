import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/plugin_management/plugin_manager.dart';
import '../core/plugin_management/app_plugin.dart';
import 'package:jinbeanpod_83904710/app/shell_app_controller.dart';

class ShellApp extends GetView<ShellAppController> {
  const ShellApp({super.key});

  @override
  Widget build(BuildContext context) {
    final PluginManager pluginManager = Get.find<PluginManager>();

    return Obx(() {
      // Check if PluginManager is initialized and has enabled plugins
      if (!pluginManager.isInitialized || pluginManager.enabledPluginsMetadata.isEmpty) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(), // Display a loading indicator
          ),
        );
      }

      final enabledTabPlugins = pluginManager.enabledPluginsMetadata
          .where((meta) => meta.type == PluginType.bottomTab)
          .toList();

      if (enabledTabPlugins.isEmpty) {
        return const Scaffold(
          body: Center(
            child: Text('No bottom tab plugins available after initialization.'), // More specific message
          ),
        );
      }

      final List<BottomNavigationBarItem> bottomNavItems = enabledTabPlugins.map((meta) {
        return BottomNavigationBarItem(
          icon: Icon(meta.icon),
          label: meta.nameKey.tr,
        );
      }).toList();

      final List<Widget> pluginWidgets = enabledTabPlugins.map((meta) {
        final plugin = pluginManager.registeredPlugins.firstWhere(
            (p) => p.metadata.id == meta.id);
        return plugin.buildEntryWidget();
      }).toList();

      return Scaffold(
        body: IndexedStack(
          index: controller.currentIndex,
          children: pluginWidgets,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex,
          onTap: controller.changeTab,
          items: bottomNavItems,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          showUnselectedLabels: true,
          elevation: 8,
        ),
      );
    });
  }
} 