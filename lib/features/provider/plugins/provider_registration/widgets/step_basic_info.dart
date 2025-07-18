import 'package:flutter/material.dart';
import '../provider_registration_controller.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';

class StepBasicInfo extends StatelessWidget {
  final ProviderRegistrationController controller;
  const StepBasicInfo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).selectProviderType, style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: ProviderType.values
              .map((type) => Expanded(
                    child: RadioListTile<ProviderType>(
                      title: Text(type == ProviderType.individual
                          ? (AppLocalizations.of(context) ?? AppLocalizationsEn()).individual
                          : type == ProviderType.team
                              ? (AppLocalizations.of(context) ?? AppLocalizationsEn()).team
                              : (AppLocalizations.of(context) ?? AppLocalizationsEn()).enterprise),
                      value: type,
                      groupValue: controller.providerType,
                      onChanged: (val) => controller.setProviderType(val!),
                    ),
                  ))
              .toList(),
        ),
        TextField(
          decoration: InputDecoration(labelText: (AppLocalizations.of(context) ?? AppLocalizationsEn()).providerName),
          onChanged: (v) => controller.displayName = v,
        ),
        TextField(
          decoration: InputDecoration(labelText: (AppLocalizations.of(context) ?? AppLocalizationsEn()).phoneNumber),
          keyboardType: TextInputType.phone,
          onChanged: (v) => controller.phone = v,
        ),
        TextField(
          decoration: InputDecoration(labelText: (AppLocalizations.of(context) ?? AppLocalizationsEn()).email),
          keyboardType: TextInputType.emailAddress,
          onChanged: (v) => controller.email = v,
        ),
        TextField(
          decoration: InputDecoration(labelText: (AppLocalizations.of(context) ?? AppLocalizationsEn()).setPassword),
          obscureText: true,
          onChanged: (v) => controller.password = v,
        ),
      ],
    );
  }
}
