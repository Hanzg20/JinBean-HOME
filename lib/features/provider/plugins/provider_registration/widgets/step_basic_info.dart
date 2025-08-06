import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';
import '../provider_registration_controller.dart';

class StepBasicInfo extends StatelessWidget {
  final ProviderRegistrationController controller;
  const StepBasicInfo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n?.selectProviderType ?? 'Select Provider Type', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: ProviderType.values
              .map((type) => Expanded(
                    child: RadioListTile<ProviderType>(
                      title: Text(type == ProviderType.individual
                          ? l10n?.individual ?? 'Individual'
                          : type == ProviderType.team
                              ? l10n?.team ?? 'Team'
                              : l10n?.enterprise ?? 'Enterprise'),
                      value: type,
                      groupValue: controller.providerType,
                      onChanged: (val) => controller.setProviderType(val!),
                    ),
                  ))
              .toList(),
        ),
        TextField(
          decoration: InputDecoration(labelText: l10n?.providerName ?? 'Provider Name'),
          onChanged: (v) => controller.displayName = v,
        ),
        TextField(
          decoration: InputDecoration(labelText: l10n?.phoneNumber ?? 'Phone Number'),
          keyboardType: TextInputType.phone,
          onChanged: (v) => controller.phone = v,
        ),
        TextField(
          decoration: InputDecoration(labelText: l10n?.email ?? 'Email'),
          keyboardType: TextInputType.emailAddress,
          onChanged: (v) => controller.email = v,
        ),
        TextField(
          decoration: InputDecoration(labelText: l10n?.setPassword ?? 'Set Password'),
          obscureText: true,
          onChanged: (v) => controller.password = v,
        ),
      ],
    );
  }
}
