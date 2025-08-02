import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/services/income_management_service.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

class IncomeController extends GetxController {
  final _incomeService = IncomeManagementService();
  
  // Observable variables
  final RxMap<String, dynamic> incomeStats = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> incomeRecords = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> incomeTrend = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> incomeTypeStats = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString selectedPeriod = 'month'.obs;
  
  // Period options
  final List<String> periodOptions = ['today', 'week', 'month', 'year'];
  
  @override
  void onInit() {
    super.onInit();
    AppLogger.info('[IncomeController] Controller initialized', tag: 'Income');
    loadIncomeData();
  }
  
  /// Load income data
  Future<void> loadIncomeData() async {
    try {
      isLoading.value = true;
      
      // Load income statistics
      final stats = await _incomeService.getIncomeStatistics(period: selectedPeriod.value);
      incomeStats.value = stats;
      
      // Load income records
      final records = stats['income_records'] as List<dynamic>? ?? [];
      incomeRecords.value = List<Map<String, dynamic>>.from(records);
      
      // Load income trend
      final trend = await _incomeService.getIncomeTrend(period: selectedPeriod.value);
      incomeTrend.value = trend;
      
      // Load income type statistics
      final typeStats = await _incomeService.getIncomeTypeStatistics();
      incomeTypeStats.value = typeStats;
      
      AppLogger.info('[IncomeController] Income data loaded successfully', tag: 'Income');
      
    } catch (e) {
      AppLogger.error('[IncomeController] Error loading income data: $e', tag: 'Income');
      Get.snackbar(
        'Error',
        'Failed to load income data. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Change period filter
  void changePeriod(String period) {
    selectedPeriod.value = period;
    loadIncomeData();
  }
  
  /// Request settlement
  Future<void> requestSettlement(double amount, String notes) async {
    try {
      isLoading.value = true;
      
      final success = await _incomeService.requestSettlement(amount, notes);
      
      if (success) {
        Get.snackbar(
          'Success',
          'Settlement request submitted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        // Refresh income data
        await loadIncomeData();
      } else {
        Get.snackbar(
          'Error',
          'Failed to submit settlement request. Please check your pending amount.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      
    } catch (e) {
      AppLogger.error('[IncomeController] Error requesting settlement: $e', tag: 'Income');
      Get.snackbar(
        'Error',
        'Failed to submit settlement request. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Format currency
  String formatCurrency(dynamic amount) {
    if (amount == null) return '\$0.00';
    final double value = amount is int ? amount.toDouble() : amount;
    return '\$${value.toStringAsFixed(2)}';
  }
  
  /// Format date
  String formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }
  
  /// Get income type display name
  String getIncomeTypeDisplayName(String type) {
    switch (type) {
      case 'service_fee':
        return 'Service Fee';
      case 'tip':
        return 'Tip';
      case 'bonus':
        return 'Bonus';
      case 'refund':
        return 'Refund';
      case 'settlement':
        return 'Settlement';
      default:
        return type;
    }
  }
  
  /// Get status display name
  String getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'settled':
        return 'Settled';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
  
  /// Get status color
  int getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return 0xFFFFA500; // Orange
      case 'settled':
        return 0xFF4CAF50; // Green
      case 'cancelled':
        return 0xFFF44336; // Red
      default:
        return 0xFF9E9E9E; // Grey
    }
  }
  
  /// Refresh income data
  Future<void> refreshIncomeData() async {
    await loadIncomeData();
  }
  
  /// Get total income
  double get totalIncome => (incomeStats['total_income'] ?? 0).toDouble();
  
  /// Get pending amount
  double get pendingAmount => (incomeStats['pending_amount'] ?? 0).toDouble();
  
  /// Get settled amount
  double get settledAmount => (incomeStats['settled_amount'] ?? 0).toDouble();
  
  /// Get total orders
  int get totalOrders => (incomeStats['total_orders'] ?? 0).toInt();
} 