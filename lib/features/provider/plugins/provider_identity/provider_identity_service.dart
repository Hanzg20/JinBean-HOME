import 'package:supabase_flutter/supabase_flutter.dart';

enum ProviderStatus { notProvider, pending, approved }

class ProviderIdentityService {
  static Future<ProviderStatus> getProviderStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    print('[ProviderIdentityService] 当前用户ID: ${user?.id}');
    if (user == null) return ProviderStatus.notProvider;
    
    try {
      // 直接查询 user_profiles 表的 role 字段
      final profile = await Supabase.instance.client
          .from('user_profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      
      print('[ProviderIdentityService] user_profiles 查询结果: ${profile?.toString()}');
      if (profile == null) return ProviderStatus.notProvider;
      
      final role = profile['role'] as String?;
      print('[ProviderIdentityService] user_profiles.role: $role');
      
      // 根据 role 判断 provider 状态
      if (role == 'provider') {
        return ProviderStatus.approved; // 直接是 provider
      } else if (role == 'customer+provider') {
        return ProviderStatus.approved; // 多角色用户，也是 provider
      } else {
        return ProviderStatus.notProvider; // customer 或其他
      }
    } catch (e) {
      print('[ProviderIdentityService] 查询 user_profiles 时出错: $e');
      return ProviderStatus.notProvider;
    }
  }
}
