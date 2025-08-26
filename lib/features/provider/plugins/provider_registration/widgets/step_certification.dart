import 'package:flutter/material.dart';
import '../provider_registration_controller.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations_en.dart';

class StepCertification extends StatelessWidget {
  final ProviderRegistrationController controller;
  const StepCertification({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.certificationUpload, style: TextStyle(fontWeight: FontWeight.bold)),
        ElevatedButton(
          onPressed: () {
            // TODO: 实现文件选择与上传逻辑
          },
          child: Text(localizations.uploadCertification),
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
        Text('${localizations.currentStatus}: ${controller.certificationStatus}'),
      ],
    );
  }
}
