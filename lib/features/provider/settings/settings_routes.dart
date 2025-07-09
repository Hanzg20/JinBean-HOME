import 'package:get/get.dart';
import 'theme_settings_page.dart';
import 'theme_settings_binding.dart';

final List<GetPage> providerSettingsRoutes = [
  GetPage(
    name: '/provider/theme_settings',
    page: () => const ProviderThemeSettingsPage(),
    binding: ProviderThemeSettingsBinding(),
  ),
]; 