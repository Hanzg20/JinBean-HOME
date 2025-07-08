import 'package:flutter/material.dart';
import '../provider_registration_controller.dart';

class StepCompliance extends StatelessWidget {
  final ProviderRegistrationController controller;
  const StepCompliance({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('合规信息', style: TextStyle(fontWeight: FontWeight.bold)),
        SwitchListTile(
          title: const Text('是否已注册GST/HST'),
          value: controller.hasGstHst ?? false,
          onChanged: (v) => controller.hasGstHst = v,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'BN号（如有）'),
          onChanged: (v) => controller.bnNumber = v,
        ),
        TextField(
          decoration: const InputDecoration(labelText: '年收入预估（加元）'),
          keyboardType: TextInputType.number,
          onChanged: (v) =>
              controller.annualIncomeEstimate = double.tryParse(v),
        ),
        TextField(
          decoration: const InputDecoration(labelText: '执照编号（如有）'),
          onChanged: (v) => controller.licenseNumber = v,
        ),
        CheckboxListTile(
          title: const Text('我已阅读并知晓税务合规须知'),
          value: controller.taxStatusNoticeShown,
          onChanged: (v) => controller.taxStatusNoticeShown = v ?? false,
        ),
        CheckboxListTile(
          title: const Text('我已上传税务报表/证明'),
          value: controller.taxReportAvailable,
          onChanged: (v) => controller.taxReportAvailable = v ?? false,
        ),
      ],
    );
  }
}
