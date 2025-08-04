import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/order_manage/order_manage_page.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/rob_order_hall/presentation/rob_order_hall_page.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/order_manage/order_manage_controller.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/rob_order_hall/rob_order_hall_controller.dart';

class OrdersShellPage extends StatefulWidget {
  const OrdersShellPage({super.key});

  @override
  State<OrdersShellPage> createState() => _OrdersShellPageState();
}

class _OrdersShellPageState extends State<OrdersShellPage> {
  @override
  void initState() {
    super.initState();
    // 确保Controller被注册
    if (!Get.isRegistered<OrderManageController>()) {
      Get.put(OrderManageController());
    }
    if (!Get.isRegistered<RobOrderHallController>()) {
      Get.put(RobOrderHallController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'Orders Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Orders Shell Page',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 