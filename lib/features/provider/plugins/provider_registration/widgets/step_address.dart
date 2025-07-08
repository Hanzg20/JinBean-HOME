import 'package:flutter/material.dart';
import '../provider_registration_controller.dart';
import '../../../../../shared/widgets/smart_address_input.dart';

class StepAddress extends StatelessWidget {
  final ProviderRegistrationController controller;
  const StepAddress({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('服务地址',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        SmartAddressInput(
          initialValue: controller.addressInput,
          onAddressChanged: (address) => controller.addressInput = address,
          onAddressParsed: (parsedData) {
            // 可以在这里处理解析后的地址数据
            print('[StepAddress] Address parsed: $parsedData');
            if (parsedData['position'] != null) {
              print('[StepAddress] Location: ${parsedData['position']}');
            }
          },
          labelText: '详细地址*',
          hintText: '点击定位图标自动获取地址，或手动输入',
          isRequired: true,
          enableLocationDetection: true,
        ),
      ],
    );
  }
}
