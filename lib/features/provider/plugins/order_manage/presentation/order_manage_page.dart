import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderManagePage extends StatelessWidget {
  const OrderManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '订单管理', // Order Management
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
        backgroundColor: theme.primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '这里是订单管理页面，可以查看、处理所有订单。',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // TODO: Add order list, filters, and actions here.
          ],
        ),
      ),
    );
  }
} 