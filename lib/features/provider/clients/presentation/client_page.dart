import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/clients/presentation/client_controller.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations_en.dart';

class ClientPage extends StatelessWidget {
  const ClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ClientController controller = Get.put(ClientController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          (AppLocalizations.of(context) ?? AppLocalizationsEn()).clients,
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
        backgroundColor: theme.primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
            onPressed: () {
              controller.addNewClient();
            },
            tooltip: '添加新客户',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar Placeholder
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '搜索客户...', // Search clients...
                  prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.primaryColor.withOpacity(0.1),
                ),
              ),
            ),

            // Tab/Segmented Control for Served/Potential Clients (Placeholder)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Switch to Served Clients
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor.withOpacity(0.2),
                        foregroundColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).servedClients),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Switch to Potential Clients
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        foregroundColor: theme.colorScheme.onSurface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).potentialClients),
                    ),
                  ),
                ],
              ),
            ),

            // Client List Placeholder
            Text(
              (AppLocalizations.of(context) ?? AppLocalizationsEn()).clientList,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (AppLocalizations.of(context) ?? AppLocalizationsEn()).clientListPlaceholder,
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                    ),
                    // TODO: Populate with actual client list
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Client Statistics Placeholder
            Text(
              (AppLocalizations.of(context) ?? AppLocalizationsEn()).clientStatistics,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (AppLocalizations.of(context) ?? AppLocalizationsEn()).statisticsToBeAdded,
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                    ),
                    // TODO: Implement charts/stats for client data
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
} 