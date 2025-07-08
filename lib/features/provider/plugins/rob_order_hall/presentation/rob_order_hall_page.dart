import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RobOrderHallPage extends StatelessWidget {
  const RobOrderHallPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '抢单大厅', // Rob Order Hall
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
        backgroundColor: theme.primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '这里是抢单大厅，可以查看并抢取新订单。',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // TODO: Add list of available orders to be robbed, filters, and actions here.
          ],
        ),
      ),
    );
  }
} 