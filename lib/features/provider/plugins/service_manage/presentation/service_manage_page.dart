import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServiceManagePage extends StatelessWidget {
  const ServiceManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '服务管理', // Service Management
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
        backgroundColor: theme.primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '这里是服务管理页面，即将推出更详细功能。',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // TODO: Add service listing, creation, and editing functionalities here.
          ],
        ),
      ),
    );
  }
} 