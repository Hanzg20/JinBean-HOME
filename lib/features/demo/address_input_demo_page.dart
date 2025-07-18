import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/shared/widgets/smart_address_input.dart';
import 'package:jinbeanpod_83904710/core/controllers/location_controller.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';

class AddressInputDemoPage extends StatefulWidget {
  const AddressInputDemoPage({super.key});

  @override
  State<AddressInputDemoPage> createState() => _AddressInputDemoPageState();
}

class _AddressInputDemoPageState extends State<AddressInputDemoPage> {
  final TextEditingController _addressController = TextEditingController();
  final LocationController _locationController = Get.find<LocationController>();

  @override
  void initState() {
    super.initState();
    _addressController.text = _locationController.selectedLocation.value?.address ?? '';
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addressInputDemo),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 当前定位信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.currentLocation,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      final location = _locationController.selectedLocation.value;
                      if (location == null) {
                        return Text(
                          AppLocalizations.of(context)!.noLocationSelected,
                          style: TextStyle(color: Colors.grey[600]),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${AppLocalizations.of(context)!.address}: ${location.address}'),
                          const SizedBox(height: 4),
                          Text('${AppLocalizations.of(context)!.latitude}: ${location.latitude.toStringAsFixed(6)}'),
                          const SizedBox(height: 4),
                          Text('${AppLocalizations.of(context)!.longitude}: ${location.longitude.toStringAsFixed(6)}'),
                          const SizedBox(height: 4),
                          Text('${AppLocalizations.of(context)!.city}: ${location.city}'),
                          const SizedBox(height: 4),
                          Text('${AppLocalizations.of(context)!.province}: ${location.district}'),
                          const SizedBox(height: 4),
                          Text('${AppLocalizations.of(context)!.postalCode}: ${location.district}'),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 智能地址输入组件
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.smartAddressInput,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SmartAddressInput(
                      initialValue: _addressController.text,
                      onAddressChanged: (address) {
                        _addressController.text = address;
                        _addressController.selection = TextSelection.fromPosition(
                          TextPosition(offset: address.length),
                        );
                      },
                      onAddressParsed: (parsedData) {
                        print('[AddressInputDemoPage] Address parsed: $parsedData');
                        if (parsedData['position'] != null) {
                          print('[AddressInputDemoPage] Location: ${parsedData['position']}');
                        }
                      },
                      labelText: AppLocalizations.of(context)!.address,
                      hintText: AppLocalizations.of(context)!.addressInputHint,
                      isRequired: true,
                      showSuggestions: true,
                      showMapButton: true,
                      showHelpButton: true,
                      enableLocationDetection: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 使用说明
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.usageInstructions,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.addressInputInstructions,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
