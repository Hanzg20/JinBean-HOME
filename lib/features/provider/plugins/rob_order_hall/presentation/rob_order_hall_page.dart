import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';

class RobOrderHallPage extends StatelessWidget {
  const RobOrderHallPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.robOrderHall,
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
        backgroundColor: theme.primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.robOrderHallDescription,
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // TODO: Add list of available orders to be robbed, filters, and actions here.
          ],
        ),
      ),
    );
  }
} 