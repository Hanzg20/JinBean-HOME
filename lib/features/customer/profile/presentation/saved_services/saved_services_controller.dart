import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

class SavedService {
  final String id;
  final String name;
  final String description;

  SavedService({
    required this.id,
    required this.name,
    required this.description,
  });
}

class SavedServicesController extends GetxController {
  final isLoading = false.obs;
  final savedServices = <SavedService>[].obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('SavedServicesController initialized', tag: 'SavedServicesController');
    loadSavedServices();
  }

  Future<void> loadSavedServices() async {
    AppLogger.info('SavedServicesController: loadSavedServices called', tag: 'SavedServicesController');
    isLoading.value = true;
    try {
      // TODO: Implement actual API call to fetch saved services
      // For now, using mock data
      await Future.delayed(const Duration(seconds: 1));
      savedServices.value = [
        SavedService(
          id: 's001',
          name: 'Plumbing Repair',
          description: 'Expert plumbing services for leaks and clogs.',
        ),
        SavedService(
          id: 's002',
          name: 'Electrical Services',
          description: 'Certified electricians for home and office.',
        ),
        SavedService(
          id: 's003',
          name: 'AC Maintenance',
          description: 'Routine maintenance to keep your AC running smoothly.',
        ),
      ];
    } catch (e, stack) {
      AppLogger.error('SavedServicesController: Failed to load saved services', error: e, stackTrace: stack, tag: 'SavedServicesController');
    } finally {
      isLoading.value = false;
    }
  }

  void removeService(String id) {
    savedServices.removeWhere((service) => service.id == id);
    // TODO: Implement API call to remove service from backend
    Get.snackbar(
      'Removed',
      'Service removed from saved list.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> refreshSavedServices() async {
    AppLogger.info('SavedServicesController: refreshSavedServices called', tag: 'SavedServicesController');
    await loadSavedServices();
  }
} 