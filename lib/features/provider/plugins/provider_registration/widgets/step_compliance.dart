import 'package:flutter/material.dart';
import '../provider_registration_controller.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';

class StepCompliance extends StatelessWidget {
  final ProviderRegistrationController controller;
  const StepCompliance({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).complianceInformation, style: TextStyle(fontWeight: FontWeight.bold)),
        SwitchListTile(
          title: Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).hasGstHst),
          value: controller.hasGstHst ?? false,
          onChanged: (v) => controller.hasGstHst = v,
        ),
        TextField(
          decoration: InputDecoration(labelText: (AppLocalizations.of(context) ?? AppLocalizationsEn()).bnNumber),
          onChanged: (v) => controller.bnNumber = v,
        ),
        TextField(
          decoration: InputDecoration(labelText: (AppLocalizations.of(context) ?? AppLocalizationsEn()).annualIncomeEstimate),
          keyboardType: TextInputType.number,
          onChanged: (v) =>
              controller.annualIncomeEstimate = double.tryParse(v),
        ),
        TextField(
          decoration: InputDecoration(labelText: (AppLocalizations.of(context) ?? AppLocalizationsEn()).licenseNumber),
          onChanged: (v) => controller.licenseNumber = v,
        ),
        CheckboxListTile(
          title: Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).taxComplianceNotice),
          value: controller.taxStatusNoticeShown,
          onChanged: (v) => controller.taxStatusNoticeShown = v ?? false,
        ),
        CheckboxListTile(
          title: Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).taxReportUploaded),
          value: controller.taxReportAvailable,
          onChanged: (v) => controller.taxReportAvailable = v ?? false,
        ),
      ],
    );
  }
}
