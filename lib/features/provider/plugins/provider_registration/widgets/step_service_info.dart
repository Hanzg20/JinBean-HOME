import 'package:flutter/material.dart';
import '../provider_registration_controller.dart';

class StepServiceInfo extends StatelessWidget {
  final ProviderRegistrationController controller;
  const StepServiceInfo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('服务信息', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          decoration: const InputDecoration(labelText: '主营服务类别（逗号分隔）'),
          onChanged: (v) => controller.serviceCategories =
              v.split(',').map((e) => e.trim()).toList(),
        ),
        TextField(
          decoration: const InputDecoration(labelText: '服务区域（逗号分隔）'),
          onChanged: (v) => controller.serviceAreas =
              v.split(',').map((e) => e.trim()).toList(),
        ),
        TextField(
          decoration: const InputDecoration(labelText: '起步价/上门费'),
          keyboardType: TextInputType.number,
          onChanged: (v) => controller.basePrice = double.tryParse(v),
        ),
        // TODO: 工作时间、团队成员、支付方式等可用自定义组件
      ],
    );
  }
}
