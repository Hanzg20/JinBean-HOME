import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

class ScheduleManagementService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 获取Provider的日程安排
  Future<List<Map<String, dynamic>>> getSchedules({String? date}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ScheduleManagementService] No user ID available');
        return [];
      }

      var query = _supabase
          .from('provider_schedules')
          .select('*')
          .eq('provider_id', userId)
          .order('scheduled_date', ascending: true);

      if (date != null) {
        query = _supabase
            .from('provider_schedules')
            .select('*')
            .eq('provider_id', userId)
            .gte('scheduled_date', '$date 00:00:00')
            .lte('scheduled_date', '$date 23:59:59')
            .order('scheduled_date', ascending: true);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.error('[ScheduleManagementService] Error getting schedules: $e');
      return [];
    }
  }

  /// 创建日程安排
  Future<bool> createSchedule(Map<String, dynamic> scheduleData) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ScheduleManagementService] No user ID available');
        return false;
      }

      await _supabase
          .from('provider_schedules')
          .insert({
            ...scheduleData,
            'provider_id': userId,
            'status': 'scheduled',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });

      AppLogger.info('[ScheduleManagementService] Schedule created successfully');
      return true;
    } catch (e) {
      AppLogger.error('[ScheduleManagementService] Error creating schedule: $e');
      return false;
    }
  }

  /// 更新日程安排
  Future<bool> updateSchedule(String scheduleId, Map<String, dynamic> scheduleData) async {
    try {
      await _supabase
          .from('provider_schedules')
          .update({
            ...scheduleData,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', scheduleId);

      AppLogger.info('[ScheduleManagementService] Schedule $scheduleId updated successfully');
      return true;
    } catch (e) {
      AppLogger.error('[ScheduleManagementService] Error updating schedule: $e');
      return false;
    }
  }

  /// 删除日程安排
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      await _supabase
          .from('provider_schedules')
          .delete()
          .eq('id', scheduleId);

      AppLogger.info('[ScheduleManagementService] Schedule $scheduleId deleted successfully');
      return true;
    } catch (e) {
      AppLogger.error('[ScheduleManagementService] Error deleting schedule: $e');
      return false;
    }
  }

  /// 获取日程统计信息
  Future<Map<String, dynamic>> getScheduleStatistics() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ScheduleManagementService] No user ID available');
        return {};
      }

      // 获取今日日程
      final today = DateTime.now().toIso8601String().split('T')[0];
      final todaySchedules = await _supabase
          .from('provider_schedules')
          .select('id, status')
          .eq('provider_id', userId)
          .gte('scheduled_date', '$today 00:00:00')
          .lt('scheduled_date', '$today 23:59:59');

      // 获取本周日程
      final weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));
      final weekSchedules = await _supabase
          .from('provider_schedules')
          .select('id, status')
          .eq('provider_id', userId)
          .gte('scheduled_date', weekStart.toIso8601String())
          .lt('scheduled_date', weekEnd.toIso8601String());

      // 获取本月日程
      final monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
      final monthEnd = DateTime(DateTime.now().year, DateTime.now().month + 1, 1);
      final monthSchedules = await _supabase
          .from('provider_schedules')
          .select('id, status')
          .eq('provider_id', userId)
          .gte('scheduled_date', monthStart.toIso8601String())
          .lt('scheduled_date', monthEnd.toIso8601String());

      return {
        'today_total': todaySchedules.length,
        'today_completed': todaySchedules.where((s) => s['status'] == 'completed').length,
        'week_total': weekSchedules.length,
        'week_completed': weekSchedules.where((s) => s['status'] == 'completed').length,
        'month_total': monthSchedules.length,
        'month_completed': monthSchedules.where((s) => s['status'] == 'completed').length,
      };
    } catch (e) {
      AppLogger.error('[ScheduleManagementService] Error getting schedule statistics: $e');
      return {};
    }
  }

  /// 更新日程状态
  Future<bool> updateScheduleStatus(String scheduleId, String status) async {
    try {
      await _supabase
          .from('provider_schedules')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', scheduleId);

      AppLogger.info('[ScheduleManagementService] Schedule $scheduleId status updated to $status');
      return true;
    } catch (e) {
      AppLogger.error('[ScheduleManagementService] Error updating schedule status: $e');
      return false;
    }
  }

  /// 获取日程详情
  Future<Map<String, dynamic>?> getScheduleDetails(String scheduleId) async {
    try {
      final response = await _supabase
          .from('provider_schedules')
          .select('*')
          .eq('id', scheduleId)
          .single();

      return response;
    } catch (e) {
      AppLogger.error('[ScheduleManagementService] Error getting schedule details: $e');
      return null;
    }
  }
} 