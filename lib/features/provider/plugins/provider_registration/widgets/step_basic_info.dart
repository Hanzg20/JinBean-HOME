import 'package:flutter/material.dart';
import '../provider_registration_controller.dart';

class StepBasicInfo extends StatelessWidget {
  final ProviderRegistrationController controller;
  const StepBasicInfo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('选择服务商类型', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: ProviderType.values
              .map((type) => Expanded(
                    child: RadioListTile<ProviderType>(
                      title: Text(type == ProviderType.individual
                          ? '个人'
                          : type == ProviderType.team
                              ? '团队'
                              : '企业'),
                      value: type,
                      groupValue: controller.providerType,
                      onChanged: (val) => controller.setProviderType(val!),
                    ),
                  ))
              .toList(),
        ),
        TextField(
          decoration: const InputDecoration(labelText: '服务商名称'),
          onChanged: (v) => controller.displayName = v,
        ),
        TextField(
          decoration: const InputDecoration(labelText: '手机号'),
          keyboardType: TextInputType.phone,
          onChanged: (v) => controller.phone = v,
        ),
        TextField(
          decoration: const InputDecoration(labelText: '邮箱'),
          keyboardType: TextInputType.emailAddress,
          onChanged: (v) => controller.email = v,
        ),
        TextField(
          decoration: const InputDecoration(labelText: '设置密码'),
          obscureText: true,
          onChanged: (v) => controller.password = v,
        ),
      ],
    );
  }
}
