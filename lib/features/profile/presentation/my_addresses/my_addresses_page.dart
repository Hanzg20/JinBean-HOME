import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './my_addresses_controller.dart';

class MyAddressesPage extends GetView<MyAddressesController> {
  const MyAddressesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
      ),
      body: const Center(
        child: Text('My Addresses Page Content'),
      ),
    );
  }
} 