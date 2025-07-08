import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('收入与财务管理', style: TextStyle(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.primaryColor,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: Center(
        child: Text(
          '收入与财务管理内容 (Placeholder)',
          style: TextStyle(fontSize: 20, color: theme.primaryColor),
        ),
      ),
    );
  }
} 