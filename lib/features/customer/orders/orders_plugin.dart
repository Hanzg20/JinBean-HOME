import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/app_plugin.dart';
import 'package:jinbeanpod_83904710/features/customer/orders/presentation/orders_binding.dart';
import 'package:jinbeanpod_83904710/features/customer/orders/presentation/orders_page.dart';
import 'package:jinbeanpod_83904710/features/customer/orders/presentation/order_detail_page.dart';
import 'package:jinbeanpod_83904710/features/customer/orders/presentation/create_order_page.dart';

class OrdersPlugin extends AppPlugin {
  @override
  PluginMetadata get metadata => PluginMetadata(
        id: 'orders',
        nameKey: 'orders',
        icon: Icons.shopping_bag,
        enabled: true,
        order: 5,
        type: PluginType.standalonePage, // 保持为独立页面，不在底部导航
        routeName: '/orders',
        role: 'customer',
      );

  @override
  Widget buildEntryWidget() {
    return const OrdersPage();
  }

  @override
  List<GetPage> getRoutes() => [
        GetPage(
          name: '/orders',
          page: () => const OrdersPage(),
          binding: OrdersBinding(),
        ),
        GetPage(
          name: '/order_detail',
          page: () => const OrderDetailPage(),
          binding: OrdersBinding(),
        ),
        GetPage(
          name: '/create_order',
          page: () => const CreateOrderPage(),
          binding: OrdersBinding(),
        ),
      ];

  @override
  void init() {
    AppLogger.info('Orders plugin initialized');
  }

  @override
  void dispose() {
    AppLogger.info('Orders plugin disposed');
  }

  @override
  Bindings? get bindings => OrdersBinding();
}
