import 'package:flutter/material.dart';
import '../provider_registration_controller.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations_en.dart';

class StepServiceInfo extends StatelessWidget {
  final ProviderRegistrationController controller;
  const StepServiceInfo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.serviceInformation, style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          decoration: InputDecoration(labelText: localizations.mainServiceCategories),
          onChanged: (value) => controller.serviceCategories = value.split(',').map((e) => e.trim()).toList(),
        ),
        TextField(
          decoration: InputDecoration(labelText: localizations.serviceAreas),
          onChanged: (value) => controller.serviceAreas = value.split(',').map((e) => e.trim()).toList(),
        ),
        TextField(
          decoration: InputDecoration(labelText: localizations.basePrice),
          keyboardType: TextInputType.number,
          onChanged: (value) => controller.basePrice = double.tryParse(value),
        ),
      ],
    );
  }
}
