import 'package:flutter/material.dart';

class OrderManagePage extends StatelessWidget {
  const OrderManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    print('OrderManagePage build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('订单管理'),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.assignment, size: 64, color: Colors.green),
              SizedBox(height: 16),
              Text('这里是订单管理页面', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
