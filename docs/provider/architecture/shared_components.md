# 共享组件设计

> 本文档描述了JinBean项目中Provider端和Customer端共享的组件设计，包括数据模型、服务、工具类等。

## 🎯 共享组件原则

### 1. 设计原则
- **可复用性**: 组件可在多个模块间复用
- **可扩展性**: 支持功能扩展而不破坏现有接口
- **一致性**: 保持接口和实现的一致性
- **可测试性**: 组件独立可测试

### 2. 共享范围
- **数据模型**: 基础实体和业务模型
- **服务层**: API服务、数据库服务、工具服务
- **工具类**: 验证器、格式化器、扩展方法
- **常量**: 应用常量、配置常量

## 📦 共享数据模型

### 1. 基础实体模型

#### BaseEntity
```dart
abstract class BaseEntity {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  BaseEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });
  
  Map<String, dynamic> toJson();
  factory BaseEntity.fromJson(Map<String, dynamic> json);
}
```

#### BaseUser
```dart
abstract class BaseUser extends BaseEntity {
  final String email;
  final String? phone;
  final String displayName;
  final String? avatar;
  final String status; // 'active', 'inactive', 'suspended'
  
  BaseUser({
    required super.id,
    required this.email,
    this.phone,
    required this.displayName,
    this.avatar,
    required this.status,
    required super.createdAt,
    required super.updatedAt,
  });
}
```

#### BaseOrder
```dart
abstract class BaseOrder extends BaseEntity {
  final String customerId;
  final String providerId;
  final String serviceId;
  final String status; // 'pending', 'accepted', 'in_progress', 'completed', 'cancelled'
  final double amount;
  final DateTime scheduledDate;
  final String? notes;
  
  BaseOrder({
    required super.id,
    required this.customerId,
    required this.providerId,
    required this.serviceId,
    required this.status,
    required this.amount,
    required this.scheduledDate,
    this.notes,
    required super.createdAt,
    required super.updatedAt,
  });
}
```

### 2. 具体实现模型

#### ProviderUser
```dart
class ProviderUser extends BaseUser {
  final String businessName;
  final String? businessDescription;
  final String? businessAddress;
  final List<String> serviceCategories;
  final List<String> serviceAreas;
  final double averageRating;
  final int totalReviews;
  final int totalOrders;
  final double totalIncome;
  final String verificationStatus;
  
  ProviderUser({
    required super.id,
    required super.email,
    super.phone,
    required super.displayName,
    super.avatar,
    required super.status,
    required this.businessName,
    this.businessDescription,
    this.businessAddress,
    required this.serviceCategories,
    required this.serviceAreas,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.totalOrders = 0,
    this.totalIncome = 0.0,
    this.verificationStatus = 'pending',
    required super.createdAt,
    required super.updatedAt,
  });
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'display_name': displayName,
      'avatar': avatar,
      'status': status,
      'business_name': businessName,
      'business_description': businessDescription,
      'business_address': businessAddress,
      'service_categories': serviceCategories,
      'service_areas': serviceAreas,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'total_orders': totalOrders,
      'total_income': totalIncome,
      'verification_status': verificationStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  factory ProviderUser.fromJson(Map<String, dynamic> json) {
    return ProviderUser(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      displayName: json['display_name'],
      avatar: json['avatar'],
      status: json['status'],
      businessName: json['business_name'],
      businessDescription: json['business_description'],
      businessAddress: json['business_address'],
      serviceCategories: List<String>.from(json['service_categories'] ?? []),
      serviceAreas: List<String>.from(json['service_areas'] ?? []),
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      totalIncome: (json['total_income'] ?? 0.0).toDouble(),
      verificationStatus: json['verification_status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
```

#### CustomerUser
```dart
class CustomerUser extends BaseUser {
  final String? defaultAddress;
  final List<String> preferredCategories;
  final double totalSpent;
  final int totalOrders;
  final double averageRating;
  
  CustomerUser({
    required super.id,
    required super.email,
    super.phone,
    required super.displayName,
    super.avatar,
    required super.status,
    this.defaultAddress,
    this.preferredCategories = const [],
    this.totalSpent = 0.0,
    this.totalOrders = 0,
    this.averageRating = 0.0,
    required super.createdAt,
    required super.updatedAt,
  });
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'display_name': displayName,
      'avatar': avatar,
      'status': status,
      'default_address': defaultAddress,
      'preferred_categories': preferredCategories,
      'total_spent': totalSpent,
      'total_orders': totalOrders,
      'average_rating': averageRating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  factory CustomerUser.fromJson(Map<String, dynamic> json) {
    return CustomerUser(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      displayName: json['display_name'],
      avatar: json['avatar'],
      status: json['status'],
      defaultAddress: json['default_address'],
      preferredCategories: List<String>.from(json['preferred_categories'] ?? []),
      totalSpent: (json['total_spent'] ?? 0.0).toDouble(),
      totalOrders: json['total_orders'] ?? 0,
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
```

## 🔧 共享服务

### 1. 基础API服务

#### BaseApiService
```dart
abstract class BaseApiService {
  final Dio _dio;
  final String _baseUrl;
  
  BaseApiService(this._dio, this._baseUrl);
  
  Future<T> get<T>(String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  });
  
  Future<T> post<T>(String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });
  
  Future<T> put<T>(String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });
  
  Future<T> delete<T>(String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  });
  
  void handleError(dynamic error);
}
```

#### ApiService实现
```dart
class ApiService extends BaseApiService {
  ApiService(Dio dio, String baseUrl) : super(dio, baseUrl);
  
  @override
  Future<T> get<T>(String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl$endpoint',
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } catch (e) {
      handleError(e);
      rethrow;
    }
  }
  
  @override
  void handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          throw Exception('连接超时');
        case DioExceptionType.badResponse:
          throw Exception('服务器错误: ${error.response?.statusCode}');
        default:
          throw Exception('网络错误');
      }
    }
    throw Exception('未知错误: $error');
  }
}
```

### 2. 数据库服务

#### BaseDatabaseService
```dart
abstract class BaseDatabaseService {
  final SupabaseClient _supabase;
  
  BaseDatabaseService(this._supabase);
  
  Future<List<Map<String, dynamic>>> query(String table, {
    String? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    int? limit,
    int? offset,
  });
  
  Future<Map<String, dynamic>> insert(String table, Map<String, dynamic> data);
  
  Future<void> update(String table, Map<String, dynamic> data, Map<String, dynamic> filters);
  
  Future<void> delete(String table, Map<String, dynamic> filters);
}
```

#### DatabaseService实现
```dart
class DatabaseService extends BaseDatabaseService {
  DatabaseService(SupabaseClient supabase) : super(supabase);
  
  @override
  Future<List<Map<String, dynamic>>> query(String table, {
    String? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _supabase.from(table).select(select ?? '*');
      
      if (filters != null) {
        filters.forEach((key, value) {
          if (value is List) {
            query = query.inFilter(key, value);
          } else {
            query = query.eq(key, value);
          }
        });
      }
      
      if (orderBy != null) {
        query = query.order(orderBy);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 50) - 1);
      }
      
      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('数据库查询失败: $e');
    }
  }
  
  @override
  Future<Map<String, dynamic>> insert(String table, Map<String, dynamic> data) async {
    try {
      final response = await _supabase.from(table).insert(data).select().single();
      return response;
    } catch (e) {
      throw Exception('数据库插入失败: $e');
    }
  }
  
  @override
  Future<void> update(String table, Map<String, dynamic> data, Map<String, dynamic> filters) async {
    try {
      var query = _supabase.from(table).update(data);
      
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
      
      await query;
    } catch (e) {
      throw Exception('数据库更新失败: $e');
    }
  }
  
  @override
  Future<void> delete(String table, Map<String, dynamic> filters) async {
    try {
      var query = _supabase.from(table).delete();
      
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
      
      await query;
    } catch (e) {
      throw Exception('数据库删除失败: $e');
    }
  }
}
```

## 🛠 共享工具类

### 1. 验证器

#### BaseValidator
```dart
abstract class BaseValidator {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s-()]{10,}$').hasMatch(phone);
  }
  
  static bool isValidPassword(String password) {
    return password.length >= 8;
  }
  
  static bool isValidName(String name) {
    return name.trim().length >= 2;
  }
  
  static bool isValidPrice(double price) {
    return price >= 0;
  }
  
  static bool isValidDate(DateTime date) {
    return date.isAfter(DateTime.now().subtract(Duration(days: 365 * 100)));
  }
}
```

#### ExtendedValidator
```dart
class ExtendedValidator extends BaseValidator {
  static bool isValidBusinessName(String name) {
    return name.trim().length >= 3 && name.trim().length <= 100;
  }
  
  static bool isValidServiceDescription(String description) {
    return description.trim().length >= 10 && description.trim().length <= 1000;
  }
  
  static bool isValidAddress(String address) {
    return address.trim().length >= 10;
  }
  
  static bool isValidRating(double rating) {
    return rating >= 0 && rating <= 5;
  }
}
```

### 2. 格式化器

#### BaseFormatter
```dart
abstract class BaseFormatter {
  static String formatCurrency(double amount, {String currency = 'USD'}) {
    return '\$${amount.toStringAsFixed(2)}';
  }
  
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  static String formatPhone(String phone) {
    if (phone.length == 11) {
      return '${phone.substring(0, 3)}-${phone.substring(3, 7)}-${phone.substring(7)}';
    }
    return phone;
  }
  
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}分钟';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}小时';
      } else {
        return '${hours}小时${remainingMinutes}分钟';
      }
    }
  }
}
```

#### ExtendedFormatter
```dart
class ExtendedFormatter extends BaseFormatter {
  static String formatOrderStatus(String status) {
    switch (status) {
      case 'pending':
        return '待处理';
      case 'accepted':
        return '已接受';
      case 'in_progress':
        return '进行中';
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      default:
        return '未知状态';
    }
  }
  
  static String formatUserStatus(String status) {
    switch (status) {
      case 'active':
        return '活跃';
      case 'inactive':
        return '不活跃';
      case 'suspended':
        return '已暂停';
      default:
        return '未知状态';
    }
  }
  
  static String formatRating(double rating) {
    return '${rating.toStringAsFixed(1)}/5.0';
  }
}
```

## 📋 使用指南

### 1. 在Provider端使用共享组件

#### 导入共享组件
```dart
import 'package:jinbean/shared/models/base_user.dart';
import 'package:jinbean/shared/models/provider_user.dart';
import 'package:jinbean/shared/services/api_service.dart';
import 'package:jinbean/shared/services/database_service.dart';
import 'package:jinbean/shared/utils/validators.dart';
import 'package:jinbean/shared/utils/formatters.dart';
```

#### 使用共享模型
```dart
class ProviderController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  
  final Rx<ProviderUser?> currentUser = Rx<ProviderUser?>(null);
  
  Future<void> loadUserProfile() async {
    try {
      final userId = Get.find<AuthService>().currentUser?.id;
      if (userId == null) throw Exception('用户未登录');
      
      final response = await _apiService.get<Map<String, dynamic>>('/users/$userId');
      currentUser.value = ProviderUser.fromJson(response);
    } catch (e) {
      Get.snackbar('错误', '加载用户信息失败: $e');
    }
  }
  
  Future<void> updateProfile(ProviderUser user) async {
    try {
      // 验证数据
      if (!ExtendedValidator.isValidBusinessName(user.businessName)) {
        throw Exception('商家名称格式不正确');
      }
      
      if (!ExtendedValidator.isValidServiceDescription(user.businessDescription ?? '')) {
        throw Exception('商家描述格式不正确');
      }
      
      // 更新数据
      await _apiService.put('/users/${user.id}', data: user.toJson());
      
      // 更新本地数据
      currentUser.value = user;
      
      Get.snackbar('成功', '个人信息更新成功');
    } catch (e) {
      Get.snackbar('错误', '更新失败: $e');
    }
  }
}
```

#### 使用共享工具类
```dart
class ProviderUtils {
  static String formatProviderInfo(ProviderUser user) {
    return '''
商家名称: ${user.businessName}
评分: ${ExtendedFormatter.formatRating(user.averageRating)}
总订单: ${user.totalOrders}
总收入: ${BaseFormatter.formatCurrency(user.totalIncome)}
状态: ${ExtendedFormatter.formatUserStatus(user.status)}
    ''';
  }
  
  static bool validateProviderData(ProviderUser user) {
    return ExtendedValidator.isValidBusinessName(user.businessName) &&
           ExtendedValidator.isValidServiceDescription(user.businessDescription ?? '') &&
           BaseValidator.isValidEmail(user.email) &&
           (user.phone == null || BaseValidator.isValidPhone(user.phone));
  }
}
```

### 2. 在Customer端使用共享组件

#### 使用共享模型
```dart
class CustomerController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  
  final Rx<CustomerUser?> currentUser = Rx<CustomerUser?>(null);
  
  Future<void> loadUserProfile() async {
    try {
      final userId = Get.find<AuthService>().currentUser?.id;
      if (userId == null) throw Exception('用户未登录');
      
      final response = await _apiService.get<Map<String, dynamic>>('/users/$userId');
      currentUser.value = CustomerUser.fromJson(response);
    } catch (e) {
      Get.snackbar('错误', '加载用户信息失败: $e');
    }
  }
  
  Future<void> updateProfile(CustomerUser user) async {
    try {
      // 验证数据
      if (!BaseValidator.isValidName(user.displayName)) {
        throw Exception('姓名格式不正确');
      }
      
      if (!BaseValidator.isValidEmail(user.email)) {
        throw Exception('邮箱格式不正确');
      }
      
      // 更新数据
      await _apiService.put('/users/${user.id}', data: user.toJson());
      
      // 更新本地数据
      currentUser.value = user;
      
      Get.snackbar('成功', '个人信息更新成功');
    } catch (e) {
      Get.snackbar('错误', '更新失败: $e');
    }
  }
}
```

#### 使用共享工具类
```dart
class CustomerUtils {
  static String formatCustomerInfo(CustomerUser user) {
    return '''
姓名: ${user.displayName}
邮箱: ${user.email}
总消费: ${BaseFormatter.formatCurrency(user.totalSpent)}
总订单: ${user.totalOrders}
评分: ${ExtendedFormatter.formatRating(user.averageRating)}
状态: ${ExtendedFormatter.formatUserStatus(user.status)}
    ''';
  }
  
  static bool validateCustomerData(CustomerUser user) {
    return BaseValidator.isValidName(user.displayName) &&
           BaseValidator.isValidEmail(user.email) &&
           (user.phone == null || BaseValidator.isValidPhone(user.phone));
  }
}
```

## 🔄 扩展指南

### 1. 添加新的共享模型
1. 继承基础模型类
2. 实现 `toJson()` 和 `fromJson()` 方法
3. 添加必要的验证逻辑
4. 更新文档

### 2. 添加新的共享服务
1. 继承基础服务类
2. 实现具体的业务逻辑
3. 添加错误处理
4. 编写测试用例

### 3. 添加新的工具类
1. 继承基础工具类
2. 实现具体的功能
3. 添加参数验证
4. 编写使用示例

---

**最后更新**: 2024年12月
**维护者**: 共享组件开发团队 