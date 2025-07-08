import 'package:flutter/material.dart';
import '../provider_registration_controller.dart';

class StepCertification extends StatelessWidget {
  final ProviderRegistrationController controller;
  const StepCertification({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('资质/证照上传', style: TextStyle(fontWeight: FontWeight.bold)),
        ElevatedButton(
          onPressed: () {
            // TODO: 实现文件选择与上传逻辑
          },
          child: const Text('上传资质/证照'),
        ),
        const SizedBox(height: 8),
        if (controller.certificationFiles.isNotEmpty)
          ...controller.certificationFiles.map((f) => ListTile(
                title: Text(f),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // TODO: 删除文件逻辑
                  },
                ),
              )),
        const SizedBox(height: 8),
        Text('当前状态：${controller.certificationStatus}'),
      ],
    );
  }
}
