import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/ui/design_system/colors.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  final _supabase = Supabase.instance.client;
  
  bool _isLoading = true;
  Map<String, dynamic>? _appSettings;
  
  // 主题设置
  String _currentTheme = 'system';
  final List<String> _themeOptions = ['system', 'light', 'dark'];
  
  // 语言设置
  String _currentLanguage = 'zh';
  final List<Map<String, String>> _languageOptions = [
    {'code': 'zh', 'name': '中文', 'native': '中文'},
    {'code': 'en', 'name': 'English', 'native': 'English'},
  ];
  
  // 通知设置
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _orderNotifications = true;
  bool _paymentNotifications = true;
  bool _systemNotifications = true;
  
  @override
  void initState() {
    super.initState();
    _loadAppSettings();
  }
  
  Future<void> _loadAppSettings() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[AppSettingsPage] No user ID available');
        return;
      }
      
      // 获取应用设置
      final response = await _supabase
          .from('provider_settings')
          .select('*')
          .eq('provider_id', userId)
          .inFilter('setting_key', ['app_settings', 'notification_settings']);
      
      final Map<String, dynamic> settings = {};
      for (final item in response) {
        settings[item['setting_key']] = item['setting_value'];
      }
      
      setState(() {
        _appSettings = settings;
        
        // 加载主题设置
        _currentTheme = settings['app_settings']?['theme'] ?? 'system';
        
        // 加载语言设置
        _currentLanguage = settings['app_settings']?['language'] ?? 'zh';
        
        // 加载通知设置
        final notificationSettings = settings['notification_settings'] ?? {};
        _pushNotifications = notificationSettings['push_notifications'] ?? true;
        _emailNotifications = notificationSettings['email_notifications'] ?? true;
        _smsNotifications = notificationSettings['sms_notifications'] ?? false;
        _orderNotifications = notificationSettings['order_notifications'] ?? true;
        _paymentNotifications = notificationSettings['payment_notifications'] ?? true;
        _systemNotifications = notificationSettings['system_notifications'] ?? true;
        
        _isLoading = false;
      });
      
    } catch (e) {
      AppLogger.error('[AppSettingsPage] Error loading app settings: $e');
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load app settings',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  Future<void> _saveAppSettings() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      // 保存应用设置
      await _supabase
          .from('provider_settings')
          .upsert({
            'provider_id': userId,
            'setting_key': 'app_settings',
            'setting_value': {
              'theme': _currentTheme,
              'language': _currentLanguage,
            },
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      // 保存通知设置
      await _supabase
          .from('provider_settings')
          .upsert({
            'provider_id': userId,
            'setting_key': 'notification_settings',
            'setting_value': {
              'push_notifications': _pushNotifications,
              'email_notifications': _emailNotifications,
              'sms_notifications': _smsNotifications,
              'order_notifications': _orderNotifications,
              'payment_notifications': _paymentNotifications,
              'system_notifications': _systemNotifications,
            },
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      Get.snackbar(
        'Success',
        'Settings saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: JinBeanColors.success.withOpacity(0.1),
        colorText: JinBeanColors.success,
      );
      
    } catch (e) {
      AppLogger.error('[AppSettingsPage] Error saving app settings: $e');
      Get.snackbar(
        'Error',
        'Failed to save settings',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JinBeanColors.background,
      appBar: AppBar(
        title: const Text('应用设置', style: TextStyle(color: JinBeanColors.textPrimary)),
        backgroundColor: JinBeanColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: JinBeanColors.textPrimary),
        actions: [
          TextButton(
            onPressed: _saveAppSettings,
            child: const Text('保存', style: TextStyle(color: JinBeanColors.primary)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('外观设置'),
                  _buildThemeSettingsCard(),
                  
                  const SizedBox(height: 24),
                  _buildSectionHeader('语言设置'),
                  _buildLanguageSettingsCard(),
                  
                  const SizedBox(height: 24),
                  _buildSectionHeader('通知设置'),
                  _buildNotificationSettingsCard(),
                  
                  const SizedBox(height: 24),
                  _buildSectionHeader('隐私设置'),
                  _buildPrivacySettingsCard(),
                  
                  const SizedBox(height: 24),
                  _buildSectionHeader('数据管理'),
                  _buildDataManagementCard(),
                ],
              ),
            ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: JinBeanColors.textPrimary,
        ),
      ),
    );
  }
  
  Widget _buildThemeSettingsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '主题设置',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 主题选择
            Column(
              children: _themeOptions.map((theme) => RadioListTile<String>(
                title: Text(_getThemeDisplayName(theme)),
                subtitle: Text(_getThemeDescription(theme)),
                value: theme,
                groupValue: _currentTheme,
                onChanged: (value) {
                  setState(() {
                    _currentTheme = value!;
                  });
                },
                activeColor: JinBeanColors.primary,
              )).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // 主题预览
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getThemePreviewColor(),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.palette,
                    color: _getThemePreviewIconColor(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '主题预览',
                    style: TextStyle(
                      color: _getThemePreviewIconColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLanguageSettingsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '语言设置',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 语言选择
            Column(
              children: _languageOptions.map((language) => RadioListTile<String>(
                title: Text(language['native']!),
                subtitle: Text(language['name']!),
                value: language['code']!,
                groupValue: _currentLanguage,
                onChanged: (value) {
                  setState(() {
                    _currentLanguage = value!;
                  });
                },
                activeColor: JinBeanColors.primary,
              )).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // 语言说明
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '语言设置将在下次启动应用时生效',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNotificationSettingsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '通知设置',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 通知渠道
            const Text(
              '通知渠道',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            SwitchListTile(
              title: const Text('推送通知'),
              subtitle: const Text('接收应用内推送通知'),
              value: _pushNotifications,
              onChanged: (value) {
                setState(() {
                  _pushNotifications = value;
                });
              },
              activeColor: JinBeanColors.primary,
            ),
            
            SwitchListTile(
              title: const Text('邮件通知'),
              subtitle: const Text('接收邮件通知'),
              value: _emailNotifications,
              onChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
              activeColor: JinBeanColors.primary,
            ),
            
            SwitchListTile(
              title: const Text('短信通知'),
              subtitle: const Text('接收短信通知'),
              value: _smsNotifications,
              onChanged: (value) {
                setState(() {
                  _smsNotifications = value;
                });
              },
              activeColor: JinBeanColors.primary,
            ),
            
            const Divider(),
            
            // 通知类型
            const Text(
              '通知类型',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            SwitchListTile(
              title: const Text('订单通知'),
              subtitle: const Text('新订单、订单状态变更'),
              value: _orderNotifications,
              onChanged: (value) {
                setState(() {
                  _orderNotifications = value;
                });
              },
              activeColor: JinBeanColors.primary,
            ),
            
            SwitchListTile(
              title: const Text('支付通知'),
              subtitle: const Text('收入、结算相关通知'),
              value: _paymentNotifications,
              onChanged: (value) {
                setState(() {
                  _paymentNotifications = value;
                });
              },
              activeColor: JinBeanColors.primary,
            ),
            
            SwitchListTile(
              title: const Text('系统通知'),
              subtitle: const Text('系统维护、更新通知'),
              value: _systemNotifications,
              onChanged: (value) {
                setState(() {
                  _systemNotifications = value;
                });
              },
              activeColor: JinBeanColors.primary,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPrivacySettingsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '隐私设置',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.blue),
              title: const Text('位置权限'),
              subtitle: const Text('管理位置信息访问权限'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showPrivacyDialog('location'),
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('相机权限'),
              subtitle: const Text('管理相机访问权限'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showPrivacyDialog('camera'),
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.purple),
              title: const Text('相册权限'),
              subtitle: const Text('管理相册访问权限'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showPrivacyDialog('photos'),
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.analytics, color: Colors.orange),
              title: const Text('数据分析'),
              subtitle: const Text('允许收集使用数据以改善服务'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // 数据分析开关逻辑
                },
                activeColor: JinBeanColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDataManagementCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '数据管理',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.download, color: Colors.blue),
              title: const Text('导出数据'),
              subtitle: const Text('导出您的个人数据'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showDataDialog('export'),
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('删除数据'),
              subtitle: const Text('删除您的个人数据'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showDataDialog('delete'),
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.cached, color: Colors.green),
              title: const Text('清除缓存'),
              subtitle: const Text('清除应用缓存数据'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showDataDialog('cache'),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'system':
        return '跟随系统';
      case 'light':
        return '浅色主题';
      case 'dark':
        return '深色主题';
      default:
        return theme;
    }
  }
  
  String _getThemeDescription(String theme) {
    switch (theme) {
      case 'system':
        return '根据系统设置自动切换';
      case 'light':
        return '使用浅色背景';
      case 'dark':
        return '使用深色背景';
      default:
        return '';
    }
  }
  
  Color _getThemePreviewColor() {
    switch (_currentTheme) {
      case 'dark':
        return Colors.grey[800]!;
      case 'light':
        return Colors.grey[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
  
  Color _getThemePreviewIconColor() {
    switch (_currentTheme) {
      case 'dark':
        return Colors.white;
      case 'light':
        return Colors.black;
      default:
        return Colors.black;
    }
  }
  
  void _showPrivacyDialog(String type) {
    Get.dialog(
      AlertDialog(
        title: Text('${_getPrivacyTypeName(type)}权限'),
        content: Text('${_getPrivacyTypeName(type)}权限管理功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  void _showDataDialog(String type) {
    Get.dialog(
      AlertDialog(
        title: Text('${_getDataTypeName(type)}数据'),
        content: Text('${_getDataTypeName(type)}数据功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  String _getPrivacyTypeName(String type) {
    switch (type) {
      case 'location':
        return '位置';
      case 'camera':
        return '相机';
      case 'photos':
        return '相册';
      default:
        return '隐私';
    }
  }
  
  String _getDataTypeName(String type) {
    switch (type) {
      case 'export':
        return '导出';
      case 'delete':
        return '删除';
      case 'cache':
        return '清除缓存';
      default:
        return '数据';
    }
  }
} 