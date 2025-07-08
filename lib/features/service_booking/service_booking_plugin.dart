import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/app_plugin.dart';
import 'package:jinbeanpod_83904710/features/service_booking/presentation/service_booking_page.dart';
import 'package:jinbeanpod_83904710/features/service_booking/presentation/service_booking_binding.dart';

class ServiceBookingPlugin implements AppPlugin {
  @override
  PluginMetadata get metadata => PluginMetadata(
        id: 'service_booking',
        nameKey: 'service_booking_name', // 国际化key
        icon: Icons.calendar_today,
        enabled: true,
        order: 2, // 确保顺序与PluginManager中的配置一致
        type: PluginType.bottomTab,
        routeName: '/service_booking',
        role: 'customer',
      );

  @override
  Widget buildEntryWidget() {
    return const ServiceBookingPage();
  }

  @override
  List<GetPage> getRoutes() {
    return [
      GetPage(
        name: metadata.routeName!,
        page: () => const ServiceBookingPage(),
        binding: ServiceBookingBinding(),
      ),
    ];
  }

  @override
  Bindings? get bindings => ServiceBookingBinding();

  @override
  void init() {
    print('ServiceBookingPlugin initialized!');
  }

  @override
  void dispose() {
    print('ServiceBookingPlugin disposed!');
  }
} 