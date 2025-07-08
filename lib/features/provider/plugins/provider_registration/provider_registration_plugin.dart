import 'package:flutter/material.dart';
import 'provider_registration_page.dart';

/// 插件主入口，注册到 PluginManager
class ProviderRegistrationPlugin {
  static const String pluginName = 'provider_registration';

  Widget get entryPage => const ProviderRegistrationPage();
} 