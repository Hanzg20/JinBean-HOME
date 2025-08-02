import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/ui/design_system/colors.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _profileData;
  
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }
  
  Future<void> _loadProfileData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ProfileSettingsPage] No user ID available');
        return;
      }
      
      // 获取用户基本信息
      final userResponse = await _supabase.auth.getUser();
      final user = userResponse.user;
      
      // 获取Provider档案信息
      final profileResponse = await _supabase
          .from('provider_profiles')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();
      
      setState(() {
        _profileData = profileResponse;
        
        // 填充表单数据
        _nameController.text = user?.userMetadata?['full_name'] ?? '';
        _phoneController.text = user?.phone ?? '';
        _emailController.text = user?.email ?? '';
        _bioController.text = profileResponse?['bio'] ?? '';
        
        _isLoading = false;
      });
      
    } catch (e) {
      AppLogger.error('[ProfileSettingsPage] Error loading profile data: $e');
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load profile data',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    try {
      setState(() {
        _isSaving = true;
      });
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ProfileSettingsPage] No user ID available');
        return;
      }
      
      // 更新用户元数据
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': _nameController.text,
          },
        ),
      );
      
      // 更新Provider档案
      await _supabase
          .from('provider_profiles')
          .upsert({
            'user_id': userId,
            'bio': _bioController.text,
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: JinBeanColors.success.withOpacity(0.1),
        colorText: JinBeanColors.success,
      );
      
      // 重新加载数据
      await _loadProfileData();
      
    } catch (e) {
      AppLogger.error('[ProfileSettingsPage] Error saving profile: $e');
      Get.snackbar(
        'Error',
        'Failed to save profile',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JinBeanColors.background,
      appBar: AppBar(
        title: const Text('个人资料设置', style: TextStyle(color: JinBeanColors.textPrimary)),
        backgroundColor: JinBeanColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: JinBeanColors.textPrimary),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存', style: TextStyle(color: JinBeanColors.primary)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('基本信息'),
                    _buildProfileCard(),
                    
                    const SizedBox(height: 24),
                    _buildSectionHeader('联系信息'),
                    _buildContactInfoCard(),
                    
                    const SizedBox(height: 24),
                    _buildSectionHeader('认证状态'),
                    _buildVerificationCard(),
                    
                    const SizedBox(height: 24),
                    _buildSectionHeader('账户安全'),
                    _buildSecurityCard(),
                  ],
                ),
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
  
  Widget _buildProfileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 头像
            CircleAvatar(
              radius: 40,
              backgroundColor: JinBeanColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 40,
                color: JinBeanColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            // 姓名
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '姓名',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入姓名';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // 个人简介
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: '个人简介',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContactInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '邮箱地址',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              enabled: false, // 邮箱通常不允许修改
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '手机号码',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              enabled: false, // 手机号通常不允许修改
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVerificationCard() {
    final isVerified = _profileData?['is_verified'] ?? false;
    final verificationStatus = _profileData?['verification_status'] ?? 'pending';
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isVerified ? Icons.verified : Icons.pending,
                  color: isVerified ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isVerified ? '已认证' : '未认证',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getVerificationStatusText(verificationStatus),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!isVerified)
              ElevatedButton.icon(
                onPressed: () => _showVerificationDialog(),
                icon: const Icon(Icons.verified_user),
                label: const Text('申请认证'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: JinBeanColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSecurityCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSecurityItem(
              icon: Icons.lock,
              title: '修改密码',
              subtitle: '更新您的登录密码',
              onTap: () => _showChangePasswordDialog(),
            ),
            const Divider(),
            _buildSecurityItem(
              icon: Icons.security,
              title: '两步验证',
              subtitle: '启用额外的安全保护',
              onTap: () => _showTwoFactorDialog(),
            ),
            const Divider(),
            _buildSecurityItem(
              icon: Icons.devices,
              title: '设备管理',
              subtitle: '管理已登录的设备',
              onTap: () => _showDeviceManagementDialog(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSecurityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: JinBeanColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
  
  String _getVerificationStatusText(String status) {
    switch (status) {
      case 'verified':
        return '您的账户已通过认证';
      case 'pending':
        return '认证申请正在审核中';
      case 'rejected':
        return '认证申请被拒绝，请重新申请';
      default:
        return '请完成认证申请';
    }
  }
  
  void _showVerificationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('申请认证'),
        content: const Text('认证功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  void _showChangePasswordDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('修改密码'),
        content: const Text('密码修改功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  void _showTwoFactorDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('两步验证'),
        content: const Text('两步验证功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  void _showDeviceManagementDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('设备管理'),
        content: const Text('设备管理功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
} 