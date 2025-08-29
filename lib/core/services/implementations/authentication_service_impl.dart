import 'package:supabase_flutter/supabase_flutter.dart' hide User, AuthState;
import '../interfaces/i_authentication_service.dart';

// 认证服务实现
class AuthenticationService implements IAuthenticationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isInitialized = false;
  User? _currentUser;
  AuthState _authState = AuthState.initial;

  @override
  Future<void> initialize() async {
    try {
      // 验证Supabase连接
      await _supabase.auth.getUser();
      _isInitialized = true;

      // 设置认证状态监听
      _supabase.auth.onAuthStateChange.listen((data) {
        _handleAuthStateChange(data);
      });

      // 获取当前用户
      final supabaseUser = _supabase.auth.currentUser;
      if (supabaseUser != null) {
        _currentUser = _convertSupabaseUser(supabaseUser);
        _updateAuthState();
      }

      print('AuthenticationService: 初始化完成 ✅');
    } catch (e) {
      print('AuthenticationService: 初始化失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<AuthResult> signIn(String email, String password) async {
    if (!_isInitialized) {
      throw Exception('AuthenticationService未初始化');
    }

    try {
      print('AuthenticationService: 用户登录 - $email');

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = _convertSupabaseUser(response.user!);
        _updateAuthState();
        print('AuthenticationService: 用户登录成功 ✅');
        return AuthResult.success(user: _currentUser);
      } else {
        print('AuthenticationService: 用户登录失败 ❌');
        return AuthResult.failure(message: '登录失败');
      }
    } catch (e) {
      print('AuthenticationService: 用户登录异常 ❌ - $e');
      return AuthResult.failure(message: e.toString());
    }
  }

  @override
  Future<AuthResult> signUp(String email, String password, String name) async {
    if (!_isInitialized) {
      throw Exception('AuthenticationService未初始化');
    }

    try {
      print('AuthenticationService: 用户注册 - $email');

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user != null) {
        _currentUser = _convertSupabaseUser(response.user!);
        _updateAuthState();
        print('AuthenticationService: 用户注册成功 ✅');
        return AuthResult.success(user: _currentUser);
      } else {
        print('AuthenticationService: 用户注册失败 ❌');
        return AuthResult.failure(message: '注册失败');
      }
    } catch (e) {
      print('AuthenticationService: 用户注册异常 ❌ - $e');
      return AuthResult.failure(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    if (!_isInitialized) {
      throw Exception('AuthenticationService未初始化');
    }

    try {
      print('AuthenticationService: 用户登出');

      await _supabase.auth.signOut();
      _currentUser = null;
      _updateAuthState();

      print('AuthenticationService: 用户登出成功 ✅');
    } catch (e) {
      print('AuthenticationService: 用户登出失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return _currentUser != null;
  }

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Stream<AuthState> get authStateChanges {
    return Stream.value(_authState);
  }

  @override
  Future<void> refreshUser() async {
    if (!_isInitialized) {
      throw Exception('AuthenticationService未初始化');
    }

    try {
      print('AuthenticationService: 刷新用户信息');

      final response = await _supabase.auth.refreshSession();
      if (response.user != null) {
        _currentUser = _convertSupabaseUser(response.user!);
        _updateAuthState();
        print('AuthenticationService: 用户信息刷新成功 ✅');
      }
    } catch (e) {
      print('AuthenticationService: 用户信息刷新失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<bool> resetPassword(String email) async {
    if (!_isInitialized) {
      throw Exception('AuthenticationService未初始化');
    }

    try {
      print('AuthenticationService: 重置密码 - $email');

      await _supabase.auth.resetPasswordForEmail(email);
      print('AuthenticationService: 密码重置邮件发送成功 ✅');
      return true;
    } catch (e) {
      print('AuthenticationService: 密码重置失败 ❌ - $e');
      return false;
    }
  }

  @override
  Future<bool> updateUser(User user) async {
    if (!_isInitialized) {
      throw Exception('AuthenticationService未初始化');
    }

    try {
      print('AuthenticationService: 更新用户信息');

      final response = await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'name': user.name,
            'avatar_url': user.avatarUrl,
          },
        ),
      );

      if (response.user != null) {
        _currentUser = _convertSupabaseUser(response.user!);
        _updateAuthState();
        print('AuthenticationService: 用户信息更新成功 ✅');
        return true;
      } else {
        print('AuthenticationService: 用户信息更新失败 ❌');
        return false;
      }
    } catch (e) {
      print('AuthenticationService: 用户信息更新异常 ❌ - $e');
      return false;
    }
  }

  // 处理认证状态变化
  void _handleAuthStateChange(dynamic data) {
    print('AuthenticationService: 认证状态变化 - $data');

    // 简化处理，直接更新状态
    final supabaseUser = _supabase.auth.currentUser;
    if (supabaseUser != null) {
      _currentUser = _convertSupabaseUser(supabaseUser);
    } else {
      _currentUser = null;
    }

    _updateAuthState();
  }

  // 更新认证状态
  void _updateAuthState() {
    if (_currentUser != null) {
      _authState = AuthState.authenticated;
    } else {
      _authState = AuthState.unauthenticated;
    }

    print('AuthenticationService: 认证状态更新 - $_authState');
  }

  // 转换Supabase用户到我们的User模型
  User _convertSupabaseUser(dynamic supabaseUser) {
    return User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      name: supabaseUser.userMetadata?['name'] as String?,
      avatarUrl: supabaseUser.userMetadata?['avatar_url'] as String?,
      createdAt: supabaseUser.createdAt ?? DateTime.now(),
      updatedAt: supabaseUser.updatedAt ?? DateTime.now(),
    );
  }

  // 获取服务是否已初始化
  bool get isInitialized => _isInitialized;

  // 获取当前认证状态
  AuthState get currentAuthState => _authState;

  // 获取用户会话
  Session? get currentSession => _supabase.auth.currentSession;

  // 获取用户元数据
  Map<String, dynamic>? get userMetadata {
    final supabaseUser = _supabase.auth.currentUser;
    return supabaseUser?.userMetadata;
  }

  // 检查用户是否有特定角色
  bool hasRole(String role) {
    final metadata = userMetadata;
    if (metadata != null && metadata['role'] != null) {
      return metadata['role'] == role;
    }
    return false;
  }

  // 检查用户是否有特定权限
  bool hasPermission(String permission) {
    final metadata = userMetadata;
    if (metadata != null && metadata['permissions'] != null) {
      final permissions = metadata['permissions'] as List;
      return permissions.contains(permission);
    }
    return false;
  }

  // 获取用户邮箱验证状态
  bool get isEmailVerified {
    final supabaseUser = _supabase.auth.currentUser;
    return supabaseUser?.emailConfirmedAt != null;
  }

  // 获取用户最后登录时间
  DateTime? get lastSignInAt {
    final supabaseUser = _supabase.auth.currentUser;
    final lastSignIn = supabaseUser?.lastSignInAt;
    if (lastSignIn != null) {
      return DateTime.tryParse(lastSignIn);
    }
    return null;
  }
}
