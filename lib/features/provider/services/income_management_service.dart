import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

class IncomeManagementService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 获取收入统计
  Future<Map<String, dynamic>> getIncomeStatistics({String? period}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[IncomeManagementService] No user ID available');
        return {};
      }

      // 构建时间范围查询
      String dateFilter = '';
      if (period == 'today') {
        dateFilter = "AND created_at >= CURRENT_DATE";
      } else if (period == 'week') {
        dateFilter = "AND created_at >= CURRENT_DATE - INTERVAL '7 days'";
      } else if (period == 'month') {
        dateFilter = "AND created_at >= CURRENT_DATE - INTERVAL '30 days'";
      } else if (period == 'year') {
        dateFilter = "AND created_at >= CURRENT_DATE - INTERVAL '1 year'";
      }

      // 获取总收入
      final totalIncomeResponse = await _supabase
          .rpc('get_provider_income_stats', params: {
            'provider_user_id': userId,
            'date_filter': dateFilter,
          });

      // 获取收入记录
      final incomeRecordsResponse = await _supabase
          .from('income_records')
          .select('*')
          .eq('provider_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return {
        'total_income': totalIncomeResponse['total_income'] ?? 0,
        'pending_amount': totalIncomeResponse['pending_amount'] ?? 0,
        'settled_amount': totalIncomeResponse['settled_amount'] ?? 0,
        'total_orders': totalIncomeResponse['total_orders'] ?? 0,
        'income_records': incomeRecordsResponse,
      };
    } catch (e) {
      AppLogger.error('[IncomeManagementService] Error getting income statistics: $e');
      return {};
    }
  }

  /// 创建收入记录
  Future<bool> createIncomeRecord(String orderId, double amount, String incomeType, String notes) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[IncomeManagementService] No user ID available');
        return false;
      }

      await _supabase
          .from('income_records')
          .insert({
            'provider_id': userId,
            'order_id': orderId,
            'amount': amount,
            'income_type': incomeType,
            'status': 'pending',
            'notes': notes,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });

      AppLogger.info('[IncomeManagementService] Income record created for order $orderId');
      return true;
    } catch (e) {
      AppLogger.error('[IncomeManagementService] Error creating income record: $e');
      return false;
    }
  }

  /// 更新收入记录状态
  Future<bool> updateIncomeRecordStatus(String recordId, String status) async {
    try {
      await _supabase
          .from('income_records')
          .update({
            'status': status,
            'settlement_date': status == 'settled' ? DateTime.now().toIso8601String() : null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', recordId);

      AppLogger.info('[IncomeManagementService] Income record $recordId status updated to $status');
      return true;
    } catch (e) {
      AppLogger.error('[IncomeManagementService] Error updating income record status: $e');
      return false;
    }
  }

  /// 获取收入趋势数据
  Future<List<Map<String, dynamic>>> getIncomeTrend({String period = 'month'}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[IncomeManagementService] No user ID available');
        return [];
      }

      final response = await _supabase
          .rpc('get_provider_income_trend', params: {
            'provider_user_id': userId,
            'period': period,
          });

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.error('[IncomeManagementService] Error getting income trend: $e');
      return [];
    }
  }

  /// 获取收入类型统计
  Future<Map<String, dynamic>> getIncomeTypeStatistics() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[IncomeManagementService] No user ID available');
        return {};
      }

      final response = await _supabase
          .from('income_records')
          .select('income_type, amount, status')
          .eq('provider_id', userId);

      final Map<String, double> typeStats = {};
      for (final record in response) {
        final type = record['income_type'] as String;
        final amount = (record['amount'] ?? 0).toDouble();
        typeStats[type] = (typeStats[type] ?? 0) + amount;
      }

      return typeStats;
    } catch (e) {
      AppLogger.error('[IncomeManagementService] Error getting income type statistics: $e');
      return {};
    }
  }

  /// 申请结算
  Future<bool> requestSettlement(double amount, String notes) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[IncomeManagementService] No user ID available');
        return false;
      }

      // 检查是否有足够的待结算金额
      final pendingAmount = await _getPendingAmount();
      if (pendingAmount < amount) {
        AppLogger.warning('[IncomeManagementService] Insufficient pending amount');
        return false;
      }

      // 创建结算记录
      await _supabase
          .from('income_records')
          .insert({
            'provider_id': userId,
            'amount': amount,
            'income_type': 'settlement',
            'status': 'pending',
            'notes': notes,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });

      AppLogger.info('[IncomeManagementService] Settlement request created for amount $amount');
      return true;
    } catch (e) {
      AppLogger.error('[IncomeManagementService] Error requesting settlement: $e');
      return false;
    }
  }

  /// 获取待结算金额
  Future<double> _getPendingAmount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;

      final response = await _supabase
          .from('income_records')
          .select('amount')
          .eq('provider_id', userId)
          .eq('status', 'pending')
          .neq('income_type', 'settlement');

      double total = 0;
      for (final record in response) {
        total += (record['amount'] ?? 0).toDouble();
      }

      return total;
    } catch (e) {
      AppLogger.error('[IncomeManagementService] Error getting pending amount: $e');
      return 0;
    }
  }
} 