import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './payment_methods_controller.dart';

class PaymentMethodsPage extends GetView<PaymentMethodsController> {
  const PaymentMethodsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
      ),
      body: const Center(
        child: Text('Payment Methods Page Content'),
      ),
    );
  }
} 