import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderDetailPage extends GetView {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orderId = Get.arguments as String?;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Detail'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Order Detail Page',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Order ID: ${orderId ?? 'N/A'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'This page will show detailed order information,\nincluding service details, provider info, and status updates.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 