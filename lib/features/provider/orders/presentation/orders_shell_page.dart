import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/order_manage/order_manage_page.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/rob_order_hall/rob_order_hall_page.dart';

class OrdersShellPage extends StatelessWidget {
  const OrdersShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2, // For "订单管理" and "抢单大厅"
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '订单中心', // Orders Center
            style: TextStyle(color: theme.colorScheme.onPrimary),
          ),
          backgroundColor: theme.primaryColor,
          bottom: TabBar(
            labelColor: theme.colorScheme.onPrimary,
            unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
            indicatorColor: theme.colorScheme.onPrimary,
            tabs: const [
              Tab(text: '订单管理'), // Order Management
              Tab(text: '抢单大厅'), // Rob Order Hall
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OrderManagePage(), // Existing Order Management Page
            RobOrderHallPage(), // Existing Rob Order Hall Page
          ],
        ),
      ),
    );
  }
} 