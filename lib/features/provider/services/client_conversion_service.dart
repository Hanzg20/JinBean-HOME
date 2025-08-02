import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

class ClientConversionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 检查用户是否已经是客户
  Future<bool> isUserAlreadyClient(String customerUserId) async {
    try {
      final providerUserId = _supabase.auth.currentUser?.id;
      if (providerUserId == null) {
        AppLogger.warning('[ClientConversionService] No provider user ID available');
        return false;
      }

      final response = await _supabase
          .from('client_relationships')
          .select('id')
          .eq('provider_id', providerUserId)
          .eq('client_user_id', customerUserId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      AppLogger.error('[ClientConversionService] Error checking if user is client: $e');
      return false;
    }
  }

  /// 将订单用户转换为客户
  Future<bool> convertOrderUserToClient(String orderId, String customerUserId, String customerName, String? customerPhone, String? customerEmail) async {
    try {
      final providerUserId = _supabase.auth.currentUser?.id;
      if (providerUserId == null) {
        AppLogger.warning('[ClientConversionService] No provider user ID available');
        return false;
      }

      // 检查是否已经是客户
      final isAlreadyClient = await isUserAlreadyClient(customerUserId);
      if (isAlreadyClient) {
        AppLogger.info('[ClientConversionService] User $customerUserId is already a client');
        return true;
      }

      // 获取订单信息
      final orderResponse = await _supabase
          .from('orders')
          .select('amount, created_at')
          .eq('id', orderId)
          .single();

      // 创建客户关系
      await _supabase
          .from('client_relationships')
          .insert({
            'provider_id': providerUserId,
            'client_user_id': customerUserId,
            'display_name': customerName,
            'phone': customerPhone,
            'email': customerEmail,
            'status': 'active',
            'total_orders': 1,
            'total_spent': orderResponse['amount'] ?? 0,
            'first_order_date': orderResponse['created_at'],
            'last_order_date': orderResponse['created_at'],
            'last_contact_date': DateTime.now().toIso8601String(),
            'notes': 'Converted from order $orderId',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });

      AppLogger.info('[ClientConversionService] Successfully converted user $customerUserId to client');
      return true;
    } catch (e) {
      AppLogger.error('[ClientConversionService] Error converting user to client: $e');
      return false;
    }
  }

  /// 更新客户统计信息
  Future<bool> updateClientStats(String customerUserId, String orderId, double orderAmount) async {
    try {
      final providerUserId = _supabase.auth.currentUser?.id;
      if (providerUserId == null) {
        AppLogger.warning('[ClientConversionService] No provider user ID available');
        return false;
      }

      // 获取当前客户统计
      final currentStats = await _supabase
          .from('client_relationships')
          .select('total_orders, total_spent, last_order_date')
          .eq('provider_id', providerUserId)
          .eq('client_user_id', customerUserId)
          .single();

      // 更新统计信息
      await _supabase
          .from('client_relationships')
          .update({
            'total_orders': (currentStats['total_orders'] ?? 0) + 1,
            'total_spent': (currentStats['total_spent'] ?? 0) + orderAmount,
            'last_order_date': DateTime.now().toIso8601String(),
            'last_contact_date': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('provider_id', providerUserId)
          .eq('client_user_id', customerUserId);

      AppLogger.info('[ClientConversionService] Updated client stats for user $customerUserId');
      return true;
    } catch (e) {
      AppLogger.error('[ClientConversionService] Error updating client stats: $e');
      return false;
    }
  }

  /// 获取客户信息
  Future<Map<String, dynamic>?> getClientInfo(String customerUserId) async {
    try {
      final providerUserId = _supabase.auth.currentUser?.id;
      if (providerUserId == null) {
        AppLogger.warning('[ClientConversionService] No provider user ID available');
        return null;
      }

      final response = await _supabase
          .from('client_relationships')
          .select('*')
          .eq('provider_id', providerUserId)
          .eq('client_user_id', customerUserId)
          .maybeSingle();

      return response;
    } catch (e) {
      AppLogger.error('[ClientConversionService] Error getting client info: $e');
      return null;
    }
  }
} 