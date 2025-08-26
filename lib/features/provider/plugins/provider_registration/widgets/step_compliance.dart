import 'package:flutter/material.dart';
import '../provider_registration_controller.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations_en.dart';

class StepCompliance extends StatelessWidget {
  final ProviderRegistrationController controller;
  const StepCompliance({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.complianceInformation, style: TextStyle(fontWeight: FontWeight.bold)),
        CheckboxListTile(
          title: Text(localizations.hasGstHst),
          value: controller.hasGstHst,
          onChanged: (value) => controller.hasGstHst = value ?? false,
        ),
        TextField(
          decoration: InputDecoration(labelText: localizations.bnNumber),
          onChanged: (value) => controller.bnNumber = value,
        ),
        TextField(
          decoration: InputDecoration(labelText: localizations.annualIncomeEstimate),
          keyboardType: TextInputType.number,
          onChanged: (value) => controller.annualIncomeEstimate = double.tryParse(value),
        ),
        TextField(
          decoration: InputDecoration(labelText: localizations.licenseNumber),
          onChanged: (value) => controller.licenseNumber = value,
        ),
        Text(localizations.taxComplianceNotice, style: TextStyle(fontSize: 12, color: Colors.grey)),
        CheckboxListTile(
          title: Text(localizations.taxReportUploaded),
          value: controller.taxReportAvailable,
          onChanged: (value) => controller.taxReportAvailable = value ?? false,
        ),
      ],
    );
  }
}
