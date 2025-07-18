import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations_en.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).customerReviewsAndReputation, style: TextStyle(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.primaryColor,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: Center(
        child: Text(
          (AppLocalizations.of(context) ?? AppLocalizationsEn()).customerReviewsAndReputationContent,
          style: TextStyle(fontSize: 20, color: theme.primaryColor),
        ),
      ),
    );
  }
} 