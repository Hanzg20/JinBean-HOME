import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketingPage extends StatelessWidget {
  const MarketingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('广告与推广', style: TextStyle(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.primaryColor,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: Center(
        child: Text(
          '广告与推广内容 (Placeholder)',
          style: TextStyle(fontSize: 20, color: theme.primaryColor),
        ),
      ),
    );
  }
} 