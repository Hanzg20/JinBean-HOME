import 'package:get/get.dart';
import 'theme_settings_page.dart';
import 'theme_settings_binding.dart';
import 'finance_page.dart';
import 'reviews_page.dart';
import 'reports_page.dart';
import 'marketing_page.dart';
import 'legal_page.dart';
import '../plugins/message_center/message_center_page.dart';

final List<GetPage> providerSettingsRoutes = [
  GetPage(
    name: '/provider/theme_settings',
    page: () => const ProviderThemeSettingsPage(),
    binding: ProviderThemeSettingsBinding(),
  ),
  GetPage(
    name: '/settings/finance',
    page: () => const FinancePage(),
  ),
  GetPage(
    name: '/settings/reviews',
    page: () => const ReviewsPage(),
  ),
  GetPage(
    name: '/settings/reports',
    page: () => const ReportsPage(),
  ),
  GetPage(
    name: '/settings/marketing',
    page: () => const MarketingPage(),
  ),
  GetPage(
    name: '/settings/legal',
    page: () => const LegalPage(),
  ),
  GetPage(
    name: '/message_center',
    page: () => const MessageCenterPage(),
  ),
]; 