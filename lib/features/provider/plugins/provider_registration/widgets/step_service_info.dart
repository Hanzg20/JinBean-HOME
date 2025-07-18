import 'package:flutter/material.dart';
import '../provider_registration_controller.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';

class StepServiceInfo extends StatelessWidget {
  final ProviderRegistrationController controller;
  const StepServiceInfo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).serviceInformation, style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          decoration: InputDecoration(labelText: (AppLocalizations.of(context) ?? AppLocalizationsEn()).mainServiceCategories),
          onChanged: (v) => controller.serviceCategories =
              v.split(',').map((e) => e.trim()).toList(),
        ),
        TextField(
          decoration: InputDecoration(labelText: (AppLocalizations.of(context) ?? AppLocalizationsEn()).serviceAreas),
          onChanged: (v) => controller.serviceAreas =
              v.split(',').map((e) => e.trim()).toList(),
        ),
        TextField(
          decoration: InputDecoration(labelText: (AppLocalizations.of(context) ?? AppLocalizationsEn()).basePrice),
          keyboardType: TextInputType.number,
          onChanged: (v) => controller.basePrice = double.tryParse(v),
        ),
        // TODO: 工作时间、团队成员、支付方式等可用自定义组件
      ],
    );
  }
}
