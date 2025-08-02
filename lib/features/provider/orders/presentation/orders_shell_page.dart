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
    
    return DefaultTabController(
      length: 2, // For "订单管理" and "抢单大厅"
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            '订单中心',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: colorScheme.onSurface),
          bottom: TabBar(
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            indicatorWeight: 3,
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
            tabs: const [
              Tab(text: '订单管理'),
              Tab(text: '接单大厅'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OrderManagePage(),
            RobOrderHallPage(),
          ],
        ),
      ),
    );
  }
} 