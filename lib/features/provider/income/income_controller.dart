import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

class IncomeController extends GetxController {
  final _supabase = Supabase.instance.client;
  
  // Observable variables
  final RxList<Map<String, dynamic>> incomeRecords = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> settlements = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedPeriod = 'month'.obs;
  final RxString selectedYear = DateTime.now().year.toString().obs;
  final RxString selectedMonth = DateTime.now().month.toString().obs;
  
  // Period options
  final List<String> periodOptions = ['week', 'month', 'quarter', 'year'];
  
  // Statistics
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalSettled = 0.0.obs;
  final RxDouble totalPending = 0.0.obs;
  final RxInt totalOrders = 0.obs;
  
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
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[IncomeController] No user ID available', tag: 'Income');
        return;
      }
      
      // Calculate date range based on selected period
      final DateTime now = DateTime.now();
      DateTime startDate;
      DateTime endDate = now;
      
      switch (selectedPeriod.value) {
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        case 'quarter':
          startDate = DateTime(now.year, now.month - 3, now.day);
          break;
        case 'year':
          startDate = DateTime(now.year - 1, now.month, now.day);
          break;
        default:
          startDate = now.subtract(const Duration(days: 30));
      }
      
      // Load income records
      final incomeResponse = await _supabase
          .from('income')
          .select('''
            *,
            orders:orders(
              id,
              order_number,
              customer:users!orders_customer_id_fkey(
                full_name
              )
            )
          ''')
          .eq('provider_id', userId)
          .gte('income_date', startDate.toIso8601String())
          .lte('income_date', endDate.toIso8601String())
          .order('income_date', ascending: false);
      
      incomeRecords.value = List<Map<String, dynamic>>.from(incomeResponse);
      
      // Load settlements
      final settlementResponse = await _supabase
          .from('settlements')
          .select('*')
          .eq('provider_id', userId)
          .gte('settlement_date', startDate.toIso8601String())
          .lte('settlement_date', endDate.toIso8601String())
          .order('settlement_date', ascending: false);
      
      settlements.value = List<Map<String, dynamic>>.from(settlementResponse);
      
      // Calculate statistics
      _calculateStatistics();
      
      AppLogger.info('[IncomeController] Loaded ${incomeRecords.length} income records', tag: 'Income');
      
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
  
  /// Calculate income statistics
  void _calculateStatistics() {
    double total = 0.0;
    double settled = 0.0;
    double pending = 0.0;
    int orders = 0;
    
    for (final record in incomeRecords) {
      final amount = record['amount'] ?? 0.0;
      final status = record['status'] ?? 'pending';
      
      total += amount;
      orders++;
      
      if (status == 'settled') {
        settled += amount;
      } else {
        pending += amount;
      }
    }
    
    totalIncome.value = total;
    totalSettled.value = settled;
    totalPending.value = pending;
    totalOrders.value = orders;
  }
  
  /// Request settlement
  Future<void> requestSettlement(double amount, String paymentMethod) async {
    try {
      isLoading.value = true;
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[IncomeController] No user ID available', tag: 'Income');
        return;
      }
      
      await _supabase
          .from('settlements')
          .insert({
            'provider_id': userId,
            'amount': amount,
            'payment_method': paymentMethod,
            'status': 'pending',
            'settlement_date': DateTime.now().toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
          });
      
      // Refresh data
      await loadIncomeData();
      
      Get.snackbar(
        'Success',
        'Settlement request submitted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      AppLogger.info('[IncomeController] Settlement request submitted: $amount', tag: 'Income');
      
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
  
  /// Get income statistics for different periods
  Future<Map<String, dynamic>> getIncomeStatistics() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[IncomeController] No user ID available', tag: 'Income');
        return {};
      }
      
      final now = DateTime.now();
      final Map<String, dynamic> stats = {};
      
      // Monthly stats for current year
      final monthlyResponse = await _supabase
          .from('income_records')
          .select('amount, income_date')
          .eq('provider_id', userId)
          .gte('income_date', DateTime(now.year, 1, 1).toIso8601String())
          .lte('income_date', DateTime(now.year, 12, 31).toIso8601String());
      
      final Map<int, double> monthlyTotals = {};
      for (int i = 1; i <= 12; i++) {
        monthlyTotals[i] = 0.0;
      }
      
      for (final record in monthlyResponse) {
        final date = DateTime.parse(record['income_date']);
        final month = date.month;
        final amount = record['amount'] ?? 0.0;
        monthlyTotals[month] = (monthlyTotals[month] ?? 0.0) + amount;
      }
      
      stats['monthly'] = monthlyTotals;
      
      // Yearly stats
      final yearlyResponse = await _supabase
          .from('income_records')
          .select('amount, income_date')
          .eq('provider_id', userId);
      
      final Map<int, double> yearlyTotals = {};
      for (final record in yearlyResponse) {
        final date = DateTime.parse(record['income_date']);
        final year = date.year;
        final amount = record['amount'] ?? 0.0;
        yearlyTotals[year] = (yearlyTotals[year] ?? 0.0) + amount;
      }
      
      stats['yearly'] = yearlyTotals;
      
      return stats;
      
    } catch (e) {
      AppLogger.error('[IncomeController] Error getting statistics: $e', tag: 'Income');
      return {};
    }
  }
  
  /// Get payment methods
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[IncomeController] No user ID available', tag: 'Income');
        return [];
      }
      
      final response = await _supabase
          .from('payment_methods')
          .select('*')
          .eq('provider_id', userId)
          .eq('is_active', true)
          .order('created_at');
      
      return List<Map<String, dynamic>>.from(response);
      
    } catch (e) {
      AppLogger.error('[IncomeController] Error getting payment methods: $e', tag: 'Income');
      return [];
    }
  }
  
  /// Add payment method
  Future<void> addPaymentMethod(String methodType, String accountInfo, String accountName) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[IncomeController] No user ID available', tag: 'Income');
        return;
      }
      
      isLoading.value = true;
      
      await _supabase
          .from('payment_methods')
          .insert({
            'provider_id': userId,
            'method_type': methodType,
            'account_info': accountInfo,
            'account_name': accountName,
            'is_active': true,
            'created_at': DateTime.now().toIso8601String(),
          });
      
      Get.snackbar(
        'Success',
        'Payment method added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      AppLogger.info('[IncomeController] Payment method added: $methodType', tag: 'Income');
      
    } catch (e) {
      AppLogger.error('[IncomeController] Error adding payment method: $e', tag: 'Income');
      Get.snackbar(
        'Error',
        'Failed to add payment method. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Change period
  void changePeriod(String period) {
    selectedPeriod.value = period;
    loadIncomeData();
  }
  
  /// Change year
  void changeYear(String year) {
    selectedYear.value = year;
    loadIncomeData();
  }
  
  /// Change month
  void changeMonth(String month) {
    selectedMonth.value = month;
    loadIncomeData();
  }
  
  /// Get period display text
  String getPeriodDisplayText(String period) {
    switch (period) {
      case 'week':
        return 'This Week';
      case 'month':
        return 'This Month';
      case 'quarter':
        return 'This Quarter';
      case 'year':
        return 'This Year';
      default:
        return 'This Month';
    }
  }
  
  /// Get status display text
  String getStatusDisplayText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'settled':
        return 'Settled';
      case 'failed':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }
  
  /// Get status color
  int getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return 0xFFFFA500; // Orange
      case 'settled':
        return 0xFF4CAF50; // Green
      case 'failed':
        return 0xFFF44336; // Red
      default:
        return 0xFF9E9E9E; // Grey
    }
  }
  
  /// Get customer name
  String getCustomerName(Map<String, dynamic> record) {
    final order = record['orders'] as Map<String, dynamic>?;
    final customer = order?['customer'] as Map<String, dynamic>?;
    return customer?['full_name'] ?? 'Unknown Customer';
  }
  
  /// Get order amount
  String getOrderAmount(Map<String, dynamic> record) {
    final order = record['orders'] as Map<String, dynamic>?;
    final amount = order?['amount'];
    return formatPrice(amount);
  }
  
  /// Format price
  String formatPrice(dynamic price) {
    if (price == null) return '\$0.00';
    final double amount = price is int ? price.toDouble() : price;
    return '\$${amount.toStringAsFixed(2)}';
  }
  
  /// Format date time
  String formatDateTime(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final DateTime dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }
  
  /// Refresh income data
  Future<void> refreshIncomeData() async {
    await loadIncomeData();
  }
} 