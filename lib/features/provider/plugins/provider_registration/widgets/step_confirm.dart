import 'package:flutter/material.dart';
import '../provider_registration_controller.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations_en.dart';

class StepConfirm extends StatelessWidget {
  final ProviderRegistrationController controller;
  const StepConfirm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context) ?? AppLocalizationsEn();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.confirmInformation,
            style: TextStyle(fontWeight: FontWeight.bold)),
        Text('${localizations.providerType}: ${controller.providerType}'),
        Text('${localizations.name}: ${controller.displayName ?? ''}'),
        Text('${localizations.phoneNumber}: ${controller.phone ?? ''}'),
        Text('${localizations.email}: ${controller.email ?? ''}'),
        Text('${localizations.address}: ${controller.addressInput ?? ''}'),
        Text(
            '${localizations.serviceCategories}: ${controller.serviceCategories.join(", ")}'),
        Text(
            '${localizations.serviceAreas}: ${controller.serviceAreas.join(", ")}'),
        Text('${localizations.basePrice}: ${controller.basePrice ?? ''}'),
        Text(
            '${localizations.certificationFilesCount}: ${controller.certificationFiles.length}'),
        Text(
            '${localizations.complianceInfo}: GST/HST: ${controller.hasGstHst}, BN: ${controller.bnNumber ?? ''}'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // TODO: 提交注册
          },
          child: Text(localizations.submitRegistration),
        ),
      ],
    );
  }
}
