import 'package:flutter/material.dart';

class ServiceManagePage extends StatelessWidget {
  const ServiceManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    print('ServiceManagePage build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('服务管理'),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.build, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text('这里是服务管理页面', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
