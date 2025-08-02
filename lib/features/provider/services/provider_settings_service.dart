import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

class ProviderSettingsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 获取Provider设置
  Future<Map<String, dynamic>?> getSetting(String settingKey) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ProviderSettingsService] No user ID available');
        return null;
      }

      final response = await _supabase
          .from('provider_settings')
          .select('setting_value')
          .eq('provider_id', userId)
          .eq('setting_key', settingKey)
          .maybeSingle();

      return response?['setting_value'] as Map<String, dynamic>?;
    } catch (e) {
      AppLogger.error('[ProviderSettingsService] Error getting setting: $e');
      return null;
    }
  }

  /// 设置Provider设置
  Future<bool> setSetting(String settingKey, Map<String, dynamic> settingValue) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ProviderSettingsService] No user ID available');
        return false;
      }

      await _supabase
          .from('provider_settings')
          .upsert({
            'provider_id': userId,
            'setting_key': settingKey,
            'setting_value': settingValue,
            'updated_at': DateTime.now().toIso8601String(),
          });

      AppLogger.info('[ProviderSettingsService] Setting $settingKey updated successfully');
      return true;
    } catch (e) {
      AppLogger.error('[ProviderSettingsService] Error setting setting: $e');
      return false;
    }
  }

  /// 获取自动转换客户设置
  Future<bool> getAutoConvertToClient() async {
    final setting = await getSetting('auto_convert_to_client');
    return setting?['enabled'] ?? false;
  }

  /// 设置自动转换客户设置
  Future<bool> setAutoConvertToClient(bool enabled) async {
    return await setSetting('auto_convert_to_client', {
      'enabled': enabled,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// 获取所有Provider设置
  Future<Map<String, dynamic>> getAllSettings() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ProviderSettingsService] No user ID available');
        return {};
      }

      final response = await _supabase
          .from('provider_settings')
          .select('setting_key, setting_value')
          .eq('provider_id', userId);

      final Map<String, dynamic> settings = {};
      for (final row in response) {
        settings[row['setting_key']] = row['setting_value'];
      }

      return settings;
    } catch (e) {
      AppLogger.error('[ProviderSettingsService] Error getting all settings: $e');
      return {};
    }
  }
} 