import 'package:get/get.dart';

// 认证结果模型
class AuthResult {
  final bool success;
  final String? message;
  final User? user;
  final String? token;

  AuthResult({
    required this.success,
    this.message,
    this.user,
    this.token,
  });

  factory AuthResult.success({User? user, String? token}) {
    return AuthResult(
      success: true,
      user: user,
      token: token,
    );
  }

  factory AuthResult.failure({required String message}) {
    return AuthResult(
      success: false,
      message: message,
    );
  }
}

// 用户模型
class User {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// 认证状态
enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

// 认证服务接口
abstract class IAuthenticationService {
  /// 初始化服务
  Future<void> initialize();

  /// 用户登录
  Future<AuthResult> signIn(String email, String password);

  /// 用户注册
  Future<AuthResult> signUp(String email, String password, String name);

  /// 用户登出
  Future<void> signOut();

  /// 检查是否已认证
  Future<bool> isAuthenticated();

  /// 获取当前用户
  Future<User?> getCurrentUser();

  /// 获取认证状态变化流
  Stream<AuthState> get authStateChanges;

  /// 刷新用户信息
  Future<void> refreshUser();

  /// 重置密码
  Future<bool> resetPassword(String email);

  /// 更新用户信息
  Future<bool> updateUser(User user);
}
