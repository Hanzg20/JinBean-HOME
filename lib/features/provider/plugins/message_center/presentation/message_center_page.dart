import 'package:flutter/material.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations_en.dart';

class MessageCenterPage extends StatelessWidget {
  const MessageCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (AppLocalizations.of(context) ?? AppLocalizationsEn()).messageCenter,
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
        backgroundColor: theme.primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              (AppLocalizations.of(context) ?? AppLocalizationsEn()).messageCenterDescription,
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // TODO: Add message list, chat interfaces, and notification views here.
          ],
        ),
      ),
    );
  }
} 