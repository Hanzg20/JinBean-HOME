import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/orders/presentation/orders_binding.dart';
import 'package:jinbeanpod_83904710/features/orders/presentation/orders_page.dart';
import 'package:jinbeanpod_83904710/features/orders/presentation/order_detail_page.dart';
import 'package:jinbeanpod_83904710/features/orders/presentation/create_order_page.dart';

class OrdersPlugin {
  String get name => 'Orders';

  String get description => 'Order management and tracking';

  String get version => '1.0.0';

  bool get isEnabled => true;

  List<GetPage> get routes => [
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

  Widget? get icon => const Icon(Icons.shopping_bag);

  void initialize() {
    print('Orders plugin initialized');
  }

  void dispose() {
    print('Orders plugin disposed');
  }
} 