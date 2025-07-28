# 插件式架构设计

> 本文档描述了JinBean项目的插件式架构设计，包括共享组件、插件开发原则和模块化设计。

## 🎯 插件式架构原则

### 1. 核心原则
- **单一职责**: 每个插件只负责特定功能
- **高内聚低耦合**: 插件内部高内聚，插件间低耦合
- **可插拔**: 插件可以独立安装、卸载、启用、禁用
- **可扩展**: 支持新插件的动态添加
- **可复用**: 共享组件可在多个插件间复用

### 2. 设计目标
- **代码复用**: 避免重复代码，提高开发效率
- **维护性**: 模块化设计便于维护和更新
- **灵活性**: 支持不同客户端的定制化需求
- **可测试性**: 插件独立测试，提高测试覆盖率

## 🏗 架构层次

### 1. 基础层 (Base Layer)
```
┌─────────────────────────────────────────────────────────────┐
│                    基础层 (Base Layer)                       │
├─────────────────────────────────────────────────────────────┤
│  核心框架 (Core Framework)                                  │
│  ├── AppCore (应用核心)                                     │
│  ├── PluginManager (插件管理器)                             │
│  ├── EventBus (事件总线)                                    │
│  └── Logger (日志系统)                                      │
├─────────────────────────────────────────────────────────────┤
│  共享基础设施 (Shared Infrastructure)                        │
│  ├── NetworkManager (网络管理)                              │
│  ├── StorageManager (存储管理)                              │
│  ├── AuthManager (认证管理)                                 │
│  └── ConfigManager (配置管理)                               │
└─────────────────────────────────────────────────────────────┘
```

### 2. 共享层 (Shared Layer)
```
┌─────────────────────────────────────────────────────────────┐
│                    共享层 (Shared Layer)                     │
├─────────────────────────────────────────────────────────────┤
│  共享数据模型 (Shared Data Models)                          │
│  ├── User (用户模型)                                        │
│  ├── Order (订单模型)                                       │
│  ├── Service (服务模型)                                     │
│  ├── Address (地址模型)                                     │
│  └── Notification (通知模型)                                │
├─────────────────────────────────────────────────────────────┤
│  共享服务 (Shared Services)                                 │
│  ├── ApiService (API服务)                                   │
│  ├── DatabaseService (数据库服务)                           │
│  ├── FileService (文件服务)                                 │
│  └── CacheService (缓存服务)                                │
├─────────────────────────────────────────────────────────────┤
│  共享工具 (Shared Utils)                                    │
│  ├── Validators (验证器)                                    │
│  ├── Formatters (格式化器)                                  │
│  ├── Extensions (扩展方法)                                  │
│  └── Constants (常量定义)                                   │
└─────────────────────────────────────────────────────────────┘
```

### 3. 插件层 (Plugin Layer)
```
┌─────────────────────────────────────────────────────────────┐
│                    插件层 (Plugin Layer)                     │
├─────────────────────────────────────────────────────────────┤
│  Provider插件 (Provider Plugins)                            │
│  ├── OrderManagementPlugin (订单管理插件)                   │
│  ├── ClientManagementPlugin (客户管理插件)                  │
│  ├── ServiceManagementPlugin (服务管理插件)                 │
│  └── IncomeManagementPlugin (收入管理插件)                  │
├─────────────────────────────────────────────────────────────┤
│  Customer插件 (Customer Plugins)                            │
│  ├── ServiceBookingPlugin (服务预约插件)                    │
│  ├── OrderTrackingPlugin (订单跟踪插件)                     │
│  ├── PaymentPlugin (支付插件)                               │
│  └── ReviewPlugin (评价插件)                                │
├─────────────────────────────────────────────────────────────┤
│  通用插件 (Common Plugins)                                  │
│  ├── AuthPlugin (认证插件)                                  │
│  ├── NotificationPlugin (通知插件)                          │
│  ├── ChatPlugin (聊天插件)                                  │
│  └── SettingsPlugin (设置插件)                              │
└─────────────────────────────────────────────────────────────┘
```

### 4. 应用层 (Application Layer)
```
┌─────────────────────────────────────────────────────────────┐
│                    应用层 (Application Layer)                │
├─────────────────────────────────────────────────────────────┤
│  Provider应用 (Provider App)                                │
│  ├── ProviderApp (Provider应用入口)                         │
│  ├── ProviderRouter (Provider路由)                          │
│  └── ProviderTheme (Provider主题)                           │
├─────────────────────────────────────────────────────────────┤
│  Customer应用 (Customer App)                                │
│  ├── CustomerApp (Customer应用入口)                         │
│  ├── CustomerRouter (Customer路由)                          │
│  └── CustomerTheme (Customer主题)                           │
└─────────────────────────────────────────────────────────────┘
```

## 📦 共享组件设计

### 1. 共享数据模型

#### 基础模型抽象
```dart
// 基础实体模型
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

// 基础用户模型
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

// 基础订单模型
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

// 基础服务模型
abstract class BaseService extends BaseEntity {
  final String providerId;
  final String name;
  final String description;
  final String category;
  final double price;
  final String priceType; // 'fixed', 'hourly', 'negotiable'
  final bool isAvailable;
  
  BaseService({
    required super.id,
    required this.providerId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.priceType,
    required this.isAvailable,
    required super.createdAt,
    required super.updatedAt,
  });
}
```

#### 具体实现模型
```dart
// Provider用户模型
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
  final String verificationStatus; // 'pending', 'verified', 'rejected'
  
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

// Customer用户模型
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

### 2. 共享服务

#### 基础API服务
```dart
// 基础API服务抽象
abstract class BaseApiService {
  final Dio _dio;
  final String _baseUrl;
  
  BaseApiService(this._dio, this._baseUrl);
  
  // 通用GET请求
  Future<T> get<T>(String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  });
  
  // 通用POST请求
  Future<T> post<T>(String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });
  
  // 通用PUT请求
  Future<T> put<T>(String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });
  
  // 通用DELETE请求
  Future<T> delete<T>(String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  });
  
  // 错误处理
  void handleError(dynamic error);
}

// 具体API服务实现
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
  Future<T> post<T>(String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl$endpoint',
        data: data,
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
    // 统一的错误处理逻辑
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          throw Exception('连接超时');
        case DioExceptionType.sendTimeout:
          throw Exception('发送超时');
        case DioExceptionType.receiveTimeout:
          throw Exception('接收超时');
        case DioExceptionType.badResponse:
          throw Exception('服务器错误: ${error.response?.statusCode}');
        case DioExceptionType.cancel:
          throw Exception('请求被取消');
        default:
          throw Exception('网络错误');
      }
    }
    throw Exception('未知错误: $error');
  }
}
```

#### 共享数据库服务
```dart
// 基础数据库服务抽象
abstract class BaseDatabaseService {
  final SupabaseClient _supabase;
  
  BaseDatabaseService(this._supabase);
  
  // 通用查询方法
  Future<List<Map<String, dynamic>>> query(String table, {
    String? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    int? limit,
    int? offset,
  });
  
  // 通用插入方法
  Future<Map<String, dynamic>> insert(String table, Map<String, dynamic> data);
  
  // 通用更新方法
  Future<void> update(String table, Map<String, dynamic> data, Map<String, dynamic> filters);
  
  // 通用删除方法
  Future<void> delete(String table, Map<String, dynamic> filters);
  
  // 事务处理
  Future<T> transaction<T>(Future<T> Function() callback);
}

// 具体数据库服务实现
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
  
  @override
  Future<T> transaction<T>(Future<T> Function() callback) async {
    // Supabase不支持传统事务，这里可以实现自定义的事务逻辑
    try {
      return await callback();
    } catch (e) {
      throw Exception('事务执行失败: $e');
    }
  }
}
```

### 3. 共享工具类

#### 验证器
```dart
// 基础验证器
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

// 扩展验证器
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

#### 格式化器
```dart
// 基础格式化器
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
  
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }
}

// 扩展格式化器
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

## 🔌 插件开发规范

### 1. 插件结构
```
lib/plugins/
├── plugin_name/
│   ├── models/              # 插件特定模型
│   │   ├── plugin_model.dart
│   │   └── plugin_model.g.dart
│   ├── services/            # 插件特定服务
│   │   ├── plugin_service.dart
│   │   └── plugin_api_service.dart
│   ├── controllers/         # 插件控制器
│   │   └── plugin_controller.dart
│   ├── views/               # 插件视图
│   │   ├── plugin_page.dart
│   │   └── widgets/
│   ├── bindings/            # 插件绑定
│   │   └── plugin_binding.dart
│   ├── routes/              # 插件路由
│   │   └── plugin_routes.dart
│   └── plugin.dart          # 插件入口
```

### 2. 插件接口
```dart
// 插件接口定义
abstract class IPlugin {
  String get name;
  String get version;
  String get description;
  List<String> get dependencies;
  
  Future<void> initialize();
  Future<void> dispose();
  
  List<GetPage> get routes;
  List<Bindings> get bindings;
}

// 插件基类
abstract class BasePlugin implements IPlugin {
  @override
  Future<void> initialize() async {
    // 基础初始化逻辑
    await _registerBindings();
    await _registerRoutes();
    await _initializeServices();
  }
  
  @override
  Future<void> dispose() async {
    // 基础清理逻辑
    await _disposeServices();
    await _unregisterBindings();
  }
  
  Future<void> _registerBindings();
  Future<void> _registerRoutes();
  Future<void> _initializeServices();
  Future<void> _disposeServices();
  Future<void> _unregisterBindings();
}

// 具体插件实现
class OrderManagementPlugin extends BasePlugin {
  @override
  String get name => 'order_management';
  
  @override
  String get version => '1.0.0';
  
  @override
  String get description => '订单管理插件';
  
  @override
  List<String> get dependencies => ['auth', 'database'];
  
  @override
  List<GetPage> get routes => [
    GetPage(
      name: '/orders',
      page: () => OrderPage(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: '/order/:id',
      page: () => OrderDetailPage(),
      binding: OrderDetailBinding(),
    ),
  ];
  
  @override
  List<Bindings> get bindings => [
    OrderBinding(),
    OrderDetailBinding(),
  ];
  
  @override
  Future<void> _registerBindings() async {
    // 注册订单管理相关的依赖注入
  }
  
  @override
  Future<void> _registerRoutes() async {
    // 注册订单管理相关的路由
  }
  
  @override
  Future<void> _initializeServices() async {
    // 初始化订单管理相关的服务
  }
  
  @override
  Future<void> _disposeServices() async {
    // 清理订单管理相关的服务
  }
  
  @override
  Future<void> _unregisterBindings() async {
    // 注销订单管理相关的依赖注入
  }
}
```

### 3. 插件管理器
```dart
// 插件管理器
class PluginManager {
  static final PluginManager _instance = PluginManager._internal();
  factory PluginManager() => _instance;
  PluginManager._internal();
  
  final Map<String, IPlugin> _plugins = {};
  final Map<String, bool> _pluginStates = {};
  
  // 注册插件
  Future<void> registerPlugin(IPlugin plugin) async {
    if (_plugins.containsKey(plugin.name)) {
      throw Exception('插件 ${plugin.name} 已存在');
    }
    
    // 检查依赖
    await _checkDependencies(plugin);
    
    // 注册插件
    _plugins[plugin.name] = plugin;
    _pluginStates[plugin.name] = false;
    
    print('插件 ${plugin.name} 注册成功');
  }
  
  // 初始化插件
  Future<void> initializePlugin(String pluginName) async {
    final plugin = _plugins[pluginName];
    if (plugin == null) {
      throw Exception('插件 $pluginName 不存在');
    }
    
    if (_pluginStates[pluginName] == true) {
      print('插件 $pluginName 已经初始化');
      return;
    }
    
    try {
      await plugin.initialize();
      _pluginStates[pluginName] = true;
      print('插件 $pluginName 初始化成功');
    } catch (e) {
      print('插件 $pluginName 初始化失败: $e');
      rethrow;
    }
  }
  
  // 初始化所有插件
  Future<void> initializeAllPlugins() async {
    for (final plugin in _plugins.values) {
      await initializePlugin(plugin.name);
    }
  }
  
  // 禁用插件
  Future<void> disablePlugin(String pluginName) async {
    final plugin = _plugins[pluginName];
    if (plugin == null) {
      throw Exception('插件 $pluginName 不存在');
    }
    
    if (_pluginStates[pluginName] == false) {
      print('插件 $pluginName 已经禁用');
      return;
    }
    
    try {
      await plugin.dispose();
      _pluginStates[pluginName] = false;
      print('插件 $pluginName 禁用成功');
    } catch (e) {
      print('插件 $pluginName 禁用失败: $e');
      rethrow;
    }
  }
  
  // 获取插件
  IPlugin? getPlugin(String pluginName) {
    return _plugins[pluginName];
  }
  
  // 获取所有插件
  List<IPlugin> getAllPlugins() {
    return _plugins.values.toList();
  }
  
  // 获取已启用的插件
  List<IPlugin> getEnabledPlugins() {
    return _plugins.entries
        .where((entry) => _pluginStates[entry.key] == true)
        .map((entry) => entry.value)
        .toList();
  }
  
  // 检查依赖
  Future<void> _checkDependencies(IPlugin plugin) async {
    for (final dependency in plugin.dependencies) {
      if (!_plugins.containsKey(dependency)) {
        throw Exception('插件 ${plugin.name} 依赖的插件 $dependency 不存在');
      }
    }
  }
}
```

## 🔄 事件系统

### 1. 事件总线
```dart
// 事件总线
class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();
  
  final Map<String, List<Function>> _listeners = {};
  
  // 注册事件监听器
  void on(String event, Function callback) {
    if (!_listeners.containsKey(event)) {
      _listeners[event] = [];
    }
    _listeners[event]!.add(callback);
  }
  
  // 注销事件监听器
  void off(String event, Function callback) {
    if (_listeners.containsKey(event)) {
      _listeners[event]!.remove(callback);
    }
  }
  
  // 触发事件
  void emit(String event, [dynamic data]) {
    if (_listeners.containsKey(event)) {
      for (final callback in _listeners[event]!) {
        callback(data);
      }
    }
  }
  
  // 清除所有监听器
  void clear() {
    _listeners.clear();
  }
}

// 事件定义
class AppEvents {
  static const String userLogin = 'user_login';
  static const String userLogout = 'user_logout';
  static const String orderCreated = 'order_created';
  static const String orderUpdated = 'order_updated';
  static const String orderCompleted = 'order_completed';
  static const String notificationReceived = 'notification_received';
  static const String networkStatusChanged = 'network_status_changed';
}
```

### 2. 事件使用示例
```dart
// 在插件中监听事件
class OrderManagementPlugin extends BasePlugin {
  @override
  Future<void> _initializeServices() async {
    // 监听订单相关事件
    EventBus().on(AppEvents.orderCreated, _handleOrderCreated);
    EventBus().on(AppEvents.orderUpdated, _handleOrderUpdated);
    EventBus().on(AppEvents.orderCompleted, _handleOrderCompleted);
  }
  
  void _handleOrderCreated(dynamic data) {
    // 处理订单创建事件
    print('订单创建: $data');
  }
  
  void _handleOrderUpdated(dynamic data) {
    // 处理订单更新事件
    print('订单更新: $data');
  }
  
  void _handleOrderCompleted(dynamic data) {
    // 处理订单完成事件
    print('订单完成: $data');
  }
  
  @override
  Future<void> _disposeServices() async {
    // 注销事件监听
    EventBus().off(AppEvents.orderCreated, _handleOrderCreated);
    EventBus().off(AppEvents.orderUpdated, _handleOrderUpdated);
    EventBus().off(AppEvents.orderCompleted, _handleOrderCompleted);
  }
}

// 在服务中触发事件
class OrderService {
  Future<void> createOrder(Order order) async {
    // 创建订单逻辑
    await _saveOrder(order);
    
    // 触发订单创建事件
    EventBus().emit(AppEvents.orderCreated, order);
  }
  
  Future<void> updateOrder(Order order) async {
    // 更新订单逻辑
    await _updateOrder(order);
    
    // 触发订单更新事件
    EventBus().emit(AppEvents.orderUpdated, order);
  }
}
```

## 📋 开发指南

### 1. 创建新插件
1. 在 `lib/plugins/` 目录下创建插件目录
2. 实现 `IPlugin` 接口或继承 `BasePlugin`
3. 定义插件特定的模型、服务、控制器
4. 注册路由和依赖注入
5. 在应用启动时注册插件

### 2. 使用共享组件
1. 导入共享组件库
2. 继承基础模型或使用基础服务
3. 复用验证器和格式化器
4. 使用事件总线进行模块间通信

### 3. 测试插件
1. 为每个插件编写单元测试
2. 测试插件间的集成
3. 测试事件系统
4. 测试依赖注入

---

**最后更新**: 2024年12月
**维护者**: 架构设计团队 