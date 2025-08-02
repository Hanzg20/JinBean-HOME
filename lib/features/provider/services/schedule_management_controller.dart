import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/services/schedule_management_service.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

class ScheduleManagementController extends GetxController {
  final _scheduleService = ScheduleManagementService();
  
  // Observable variables
  final RxList<Map<String, dynamic>> schedules = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> scheduleStats = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString selectedDate = ''.obs;
  final RxString selectedStatus = 'all'.obs;
  
  // Status options
  final List<String> statusOptions = ['all', 'scheduled', 'in_progress', 'completed', 'cancelled'];
  
  @override
  void onInit() {
    super.onInit();
    AppLogger.info('[ScheduleManagementController] Controller initialized', tag: 'ScheduleManagement');
    selectedDate.value = DateTime.now().toIso8601String().split('T')[0];
    loadSchedules();
    loadScheduleStats();
  }
  
  /// Load schedules
  Future<void> loadSchedules({bool refresh = false}) async {
    try {
      isLoading.value = true;
      
      final schedulesList = await _scheduleService.getSchedules(date: selectedDate.value);
      
      // Apply status filter
      var filteredSchedules = schedulesList;
      
      if (selectedStatus.value != 'all') {
        filteredSchedules = filteredSchedules.where((s) => s['status'] == selectedStatus.value).toList();
      }
      
      schedules.value = filteredSchedules;
      
      AppLogger.info('[ScheduleManagementController] Loaded ${schedules.length} schedules', tag: 'ScheduleManagement');
      
    } catch (e) {
      AppLogger.error('[ScheduleManagementController] Error loading schedules: $e', tag: 'ScheduleManagement');
      Get.snackbar(
        'Error',
        'Failed to load schedules. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Load schedule statistics
  Future<void> loadScheduleStats() async {
    try {
      final stats = await _scheduleService.getScheduleStatistics();
      scheduleStats.value = stats;
    } catch (e) {
      AppLogger.error('[ScheduleManagementController] Error loading schedule stats: $e', tag: 'ScheduleManagement');
    }
  }
  
  /// Create new schedule
  Future<bool> createSchedule(Map<String, dynamic> scheduleData) async {
    try {
      isLoading.value = true;
      
      final success = await _scheduleService.createSchedule(scheduleData);
      
      if (success) {
        await loadSchedules(refresh: true);
        await loadScheduleStats();
        
        Get.snackbar(
          'Success',
          'Schedule created successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        AppLogger.info('[ScheduleManagementController] Schedule created successfully', tag: 'ScheduleManagement');
      } else {
        Get.snackbar(
          'Error',
          'Failed to create schedule. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      
      return success;
    } catch (e) {
      AppLogger.error('[ScheduleManagementController] Error creating schedule: $e', tag: 'ScheduleManagement');
      Get.snackbar(
        'Error',
        'Failed to create schedule. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Update schedule
  Future<bool> updateSchedule(String scheduleId, Map<String, dynamic> scheduleData) async {
    try {
      isLoading.value = true;
      
      final success = await _scheduleService.updateSchedule(scheduleId, scheduleData);
      
      if (success) {
        await loadSchedules(refresh: true);
        await loadScheduleStats();
        
        Get.snackbar(
          'Success',
          'Schedule updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        AppLogger.info('[ScheduleManagementController] Schedule $scheduleId updated successfully', tag: 'ScheduleManagement');
      } else {
        Get.snackbar(
          'Error',
          'Failed to update schedule. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      
      return success;
    } catch (e) {
      AppLogger.error('[ScheduleManagementController] Error updating schedule: $e', tag: 'ScheduleManagement');
      Get.snackbar(
        'Error',
        'Failed to update schedule. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Delete schedule
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      isLoading.value = true;
      
      final success = await _scheduleService.deleteSchedule(scheduleId);
      
      if (success) {
        await loadSchedules(refresh: true);
        await loadScheduleStats();
        
        Get.snackbar(
          'Success',
          'Schedule deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        AppLogger.info('[ScheduleManagementController] Schedule $scheduleId deleted successfully', tag: 'ScheduleManagement');
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete schedule. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      
      return success;
    } catch (e) {
      AppLogger.error('[ScheduleManagementController] Error deleting schedule: $e', tag: 'ScheduleManagement');
      Get.snackbar(
        'Error',
        'Failed to delete schedule. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Update schedule status
  Future<bool> updateScheduleStatus(String scheduleId, String status) async {
    try {
      final success = await _scheduleService.updateScheduleStatus(scheduleId, status);
      
      if (success) {
        await loadSchedules(refresh: true);
        await loadScheduleStats();
        
        AppLogger.info('[ScheduleManagementController] Schedule $scheduleId status updated to $status', tag: 'ScheduleManagement');
      }
      
      return success;
    } catch (e) {
      AppLogger.error('[ScheduleManagementController] Error updating schedule status: $e', tag: 'ScheduleManagement');
      return false;
    }
  }
  
  /// Change date
  void changeDate(String date) {
    selectedDate.value = date;
    loadSchedules();
  }
  
  /// Filter by status
  void filterByStatus(String status) {
    selectedStatus.value = status;
    loadSchedules();
  }
  
  /// Get schedule details
  Future<Map<String, dynamic>?> getScheduleDetails(String scheduleId) async {
    try {
      return await _scheduleService.getScheduleDetails(scheduleId);
    } catch (e) {
      AppLogger.error('[ScheduleManagementController] Error getting schedule details: $e', tag: 'ScheduleManagement');
      return null;
    }
  }
  
  /// Refresh data
  Future<void> refreshData() async {
    await loadSchedules(refresh: true);
    await loadScheduleStats();
  }
  
  /// Get today's date
  String getTodayDate() {
    return DateTime.now().toIso8601String().split('T')[0];
  }
  
  /// Get formatted date
  String getFormattedDate(String date) {
    try {
      final DateTime dateTime = DateTime.parse(date);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return date;
    }
  }
  
  /// Get status display text
  String getStatusDisplayText(String status) {
    switch (status) {
      case 'scheduled':
        return '已安排';
      case 'in_progress':
        return '进行中';
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      default:
        return '全部';
    }
  }
  
  /// Get status color
  int getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return 0xFF2196F3; // Blue
      case 'in_progress':
        return 0xFFFF9800; // Orange
      case 'completed':
        return 0xFF4CAF50; // Green
      case 'cancelled':
        return 0xFFF44336; // Red
      default:
        return 0xFF9E9E9E; // Grey
    }
  }
} 