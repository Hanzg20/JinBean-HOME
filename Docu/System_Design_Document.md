# System Design Document for JinBean App

## Table of Contents
1. Introduction
2. Overall Architecture
3. Core Module Design
4. Internationalization & Localization
5. Service Booking Flow Design
6. Data Flow and Interactions
7. Development Environment & Tools
8. Deployment & Operations
9. Design Discussion & Q&A
10. Category ID Encoding Rules

---

## 1. Introduction

### 1.1 Purpose
详细描述金豆荚App的系统设计，包括架构、技术选型、模块划分及关键组件设计，为开发团队提供实现指导。

### 1.2 Scope
涵盖客户端核心架构、插件管理、状态管理、路由、国际化、本地数据存储等。

### 1.3 Terminology
- **Super App**: 集成多种独立服务或功能模块的移动应用。
- **Plugin**: 可独立开发、部署和管理的功能模块。
- **GetX**: Flutter状态管理、依赖注入和路由框架。
- **ARB**: Flutter国际化文本定义文件。

---

## 2. Overall Architecture

（此处插入架构分层图、模块划分、技术选型等内容，保留原文相关描述）

---

## 3. Core Module Design

（此处插入插件管理系统、认证模块、主应用壳、各业务模块等设计内容，保留原文相关描述）

---

## 4. Internationalization & Localization

本系统采用"静态文本国际化 + 动态内容多语言字段"混合方案：

### 4.1 界面静态文本
- 使用 Flutter 官方国际化（arb/json 文件），所有 UI 固定文本均支持多语言切换。
- 便于开发、维护和编译时检查。

### 4.2 动态内容多语言
- 数据库字段（如 title、description）采用 jsonb 结构，每种语言一个 key。
- 查询时根据当前语言动态取值，无对应语言时自动 fallback 到主语言。
- 后台支持多语言录入，或主语言+自动翻译补全。

### 4.3 方案优点与未来扩展
- 灵活扩展，支持任意语言。
- 查询高效，结构简单，Flutter 端处理方便。
- 易于后台批量管理和未来自动翻译集成。
- 新增语言只需在 jsonb 字段加新 key，可集成第三方翻译 API，运营人工校对。

### 4.4 数据字典与地区编码设计

#### 4.4.1 type_code 字段用法
- `type_code` 用于区分不同字典类型，如 `SERVICE_TYPE`（服务分类）、`AREA_CODE`（地区编码）、`TAG`（标签）等。
- 地区相关数据统一用 `type_code = 'AREA_CODE'`。

#### 4.4.2 地区ID编码规则
- 采用分层编码，结构与服务分类类似：
  - `20` + 3位国家 + 2位省/州 + 2位城市
  - 例如：`200020000`（加拿大），`200020100`（安大略省），`200020101`（多伦多）
- `parent_id` 指向上级地区，`level` 表示层级（1=国家，2=省，3=市）
- `extra_data` 字段可存储地区类型（如{"type":"country"}）

#### 4.4.3 示例结构
| id        | type_code  | parent_id   | code         | name (jsonb)           | level | status | sort_order | extra_data           |
|-----------|------------|-------------|--------------|------------------------|-------|--------|------------|----------------------|
| 200020000 | AREA_CODE  | NULL        | CA           | {"en":"Canada","zh":"加拿大"} | 1     | 1      | 1          | {"type":"country"} |
| 200020100 | AREA_CODE  | 200020000   | CA-ON        | {"en":"Ontario","zh":"安大略省"} | 2     | 1      | 1          | {"type":"province"} |
| 200020101 | AREA_CODE  | 200020100   | CA-ON-TOR    | {"en":"Toronto","zh":"多伦多"} | 3     | 1      | 1          | {"type":"city"}    |

#### 4.4.4 推荐做法
- 统一用 `AREA_CODE` 管理所有国家、省/州、市/区等地区数据。
- 便于多语言、层级管理、服务筛选和地址选择。
- 其他类型字典（如服务分类）继续用 `SERVICE_TYPE`。

---

### 4.5 加拿大地区数据示例

```sql
-- 加拿大国家
INSERT INTO ref_codes (id, type_code, parent_id, code, name, level, status, sort_order, extra_data)
VALUES
('200020000', 'AREA_CODE', NULL, 'CA', '{"en":"Canada","zh":"加拿大"}', 1, 1, 1, '{"type":"country"}');

-- 加拿大省份
INSERT INTO ref_codes (id, type_code, parent_id, code, name, level, status, sort_order, extra_data)
VALUES
('200020100', 'AREA_CODE', '200020000', 'CA-ON', '{"en":"Ontario","zh":"安大略省"}', 2, 1, 1, '{"type":"province"}'),
('200020200', 'AREA_CODE', '200020000', 'CA-BC', '{"en":"British Columbia","zh":"不列颠哥伦比亚省"}', 2, 1, 2, '{"type":"province"}'),
('200020300', 'AREA_CODE', '200020000', 'CA-QC', '{"en":"Quebec","zh":"魁北克省"}', 2, 1, 3, '{"type":"province"}'),
('200020400', 'AREA_CODE', '200020000', 'CA-AB', '{"en":"Alberta","zh":"阿尔伯塔省"}', 2, 1, 4, '{"type":"province"}');

-- 主要城市
INSERT INTO ref_codes (id, type_code, parent_id, code, name, level, status, sort_order, extra_data)
VALUES
('200020101', 'AREA_CODE', '200020100', 'CA-ON-TOR', '{"en":"Toronto","zh":"多伦多"}', 3, 1, 1, '{"type":"city"}'),
('200020102', 'AREA_CODE', '200020100', 'CA-ON-OTT', '{"en":"Ottawa","zh":"渥太华"}', 3, 1, 2, '{"type":"city"}'),
('200020201', 'AREA_CODE', '200020200', 'CA-BC-VAN', '{"en":"Vancouver","zh":"温哥华"}', 3, 1, 1, '{"type":"city"}'),
('200020202', 'AREA_CODE', '200020200', 'CA-BC-VIC', '{"en":"Victoria","zh":"维多利亚"}', 3, 1, 2, '{"type":"city"}'),
('200020301', 'AREA_CODE', '200020300', 'CA-QC-MTL', '{"en":"Montreal","zh":"蒙特利尔"}', 3, 1, 1, '{"type":"city"}'),
('200020302', 'AREA_CODE', '200020300', 'CA-QC-QC', '{"en":"Quebec City","zh":"魁北克市"}', 3, 1, 2, '{"type":"city"}'),
('200020401', 'AREA_CODE', '200020400', 'CA-AB-CGY', '{"en":"Calgary","zh":"卡尔加里"}', 3, 1, 1, '{"type":"city"}'),
('200020402', 'AREA_CODE', '200020400', 'CA-AB-EDM', '{"en":"Edmonton","zh":"埃德蒙顿"}', 3, 1, 2, '{"type":"city"}');
```

---

## 5. Service Booking Flow Design

### 5.1 位置管理系统设计

#### 5.1.1 位置管理架构
```
LocationController (全局单例)
├── 用户当前位置 (GPS/网络定位)
├── 用户选择位置 (手动选择)
├── 位置权限管理
├── 距离计算服务
└── 位置持久化存储
```

#### 5.1.2 位置数据模型
```dart
class UserLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String district;
  final String country;
  final LocationSource source; // GPS, MANUAL, DEFAULT
  final DateTime lastUpdated;
  final bool isGlobalService;

  bool get isInternational => country != '中国';
  String get displayLocation => isInternational ? '$city, $country' : address;
}

enum LocationSource {
  gps,
  manual,
  default
}
```

#### 5.1.3 位置管理功能
- **自动定位**: 应用启动时获取用户当前位置
- **手动选择**: 用户可手动选择或搜索地址
- **距离计算**: 计算用户位置到服务提供商的距离
- **服务筛选**: 根据距离筛选附近的服务
- **订单地址**: 自动填充订单地址信息

#### 5.1.4 位置权限处理
- 首次使用时请求位置权限
- 权限被拒绝时提供手动选择选项
- 支持权限状态监听和重新请求

### 5.2 服务预订流程设计

#### 5.2.1 完整预订流程
```
1. 服务列表页面 (ServiceBookingPage)
   ├── 分类筛选
   ├── 距离筛选
   ├── 价格筛选
   └── 服务卡片展示

2. 服务详情页面 (ServiceDetailPage)
   ├── 服务基本信息
   ├── 提供商信息
   ├── 服务图片展示
   ├── 价格详情
   ├── 服务区域
   ├── 用户评价
   ├── 联系提供商
   └── 立即预订按钮

3. 订单创建页面 (CreateOrderPage)
   ├── 服务信息确认
   ├── 日期时间选择
   ├── 地址信息
   ├── 服务规格选择
   ├── 备注信息
   ├── 价格计算
   └── 提交订单

4. 订单管理页面 (OrdersPage)
   ├── 订单状态筛选
   ├── 订单列表展示
   ├── 订单详情查看
   └── 订单操作 (取消、确认等)
```

#### 5.2.2 服务详情页面设计

**页面结构**:
```
ServiceDetailPage
├── AppBar (返回、分享、收藏)
├── 服务图片轮播
├── 服务基本信息
│   ├── 服务标题 (多语言)
│   ├── 提供商信息
│   ├── 评分和评价数
│   └── 价格信息
├── 服务详细描述 (多语言)
├── 服务规格选项
├── 服务区域信息
├── 提供商详细信息
│   ├── 头像和名称
│   ├── 联系方式
│   ├── 服务统计
│   └── 其他服务
├── 用户评价列表
├── 操作按钮区域
│   ├── 联系提供商
│   └── 立即预订
```

**数据加载逻辑**:
```dart
class ServiceDetailController extends GetxController {
  final serviceId = ''.obs;
  final service = Rxn<Service>();
  final provider = Rxn<ProviderProfile>();
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadServiceDetails();
  }
  
  Future<void> loadServiceDetails() async {
    try {
      isLoading.value = true;
      // 1. 加载服务详情
      final serviceData = await SupabaseService.instance
          .getServiceById(serviceId.value);
      service.value = serviceData;
      
      // 2. 加载提供商信息
      if (serviceData != null) {
        final providerData = await SupabaseService.instance
            .getProviderProfile(serviceData.providerId);
        provider.value = providerData;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
```

#### 5.2.3 订单创建页面设计

**页面结构**:
```
CreateOrderPage
├── AppBar (返回、标题)
├── 服务信息确认区域
│   ├── 服务图片和标题
│   ├── 提供商信息
│   └── 基础价格
├── 服务规格选择
│   ├── 数量选择
│   ├── 附加服务选项
│   └── 自定义要求
├── 时间安排
│   ├── 日期选择器
│   ├── 时间段选择
│   └── 紧急程度
├── 地址信息
│   ├── 当前位置
│   ├── 地址选择/输入
│   └── 详细地址
├── 备注信息
│   └── 特殊要求输入
├── 价格计算
│   ├── 基础价格
│   ├── 附加费用
│   ├── 服务费
│   └── 总价
└── 提交按钮
```

**订单创建逻辑**:
```dart
class CreateOrderController extends GetxController {
  final service = Rxn<Service>();
  final provider = Rxn<ProviderProfile>();
  final selectedDate = Rxn<DateTime>();
  final selectedTime = Rxn<String>();
  final address = ''.obs;
  final notes = ''.obs;
  final quantity = 1.obs;
  final additionalServices = <String>[].obs;
  final totalPrice = 0.0.obs;
  final isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    calculateTotalPrice();
  }
  
  void calculateTotalPrice() {
    if (service.value == null) return;
    
    double basePrice = service.value!.price * quantity.value;
    double additionalCost = 0.0;
    double serviceFee = basePrice * 0.1; // 10% 服务费
    
    totalPrice.value = basePrice + additionalCost + serviceFee;
  }
  
  Future<void> createOrder() async {
    try {
      isLoading.value = true;
      
      final orderData = {
        'service_id': service.value!.id,
        'provider_id': service.value!.providerId,
        'user_id': Get.find<AuthController>().currentUser!.id,
        'scheduled_date': selectedDate.value!.toIso8601String(),
        'scheduled_time': selectedTime.value,
        'address': address.value,
        'notes': notes.value,
        'quantity': quantity.value,
        'additional_services': additionalServices,
        'total_price': totalPrice.value,
        'status': 'pending'
      };
      
      final result = await SupabaseService.instance.createOrder(orderData);
      
      if (result != null) {
        Get.snackbar('Success', 'Order created successfully');
        Get.offAllNamed('/orders');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create order: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
```

### 5.3 数据模型设计

#### 5.3.1 服务数据模型
```dart
class Service {
  final String id;
  final String providerId;
  final String categoryId;
  final Map<String, String> title; // 多语言标题
  final Map<String, String> description; // 多语言描述
  final double price;
  final String currency;
  final List<String> images;
  final Map<String, dynamic> specifications; // 服务规格
  final Map<String, dynamic> serviceArea; // 服务区域
  final double rating;
  final int reviewCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

#### 5.3.2 订单数据模型
```dart
class Order {
  final String id;
  final String serviceId;
  final String providerId;
  final String userId;
  final DateTime scheduledDate;
  final String scheduledTime;
  final String address;
  final String notes;
  final int quantity;
  final List<String> additionalServices;
  final double totalPrice;
  final String status; // pending, confirmed, in_progress, completed, cancelled
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 5.4 状态管理设计

#### 5.4.1 全局状态管理
```dart
// 位置管理
class LocationController extends GetxController {
  final currentLocation = Rxn<UserLocation>();
  final selectedLocation = Rxn<UserLocation>();
  final locationPermission = LocationPermission.denied.obs;
  
  Future<void> getCurrentLocation() async {
    // 获取当前位置逻辑
  }
  
  Future<void> selectLocation(UserLocation location) async {
    selectedLocation.value = location;
    await _saveLocation(location);
  }
}

// 购物车管理 (可选)
class CartController extends GetxController {
  final cartItems = <CartItem>[].obs;
  
  void addToCart(Service service, {int quantity = 1}) {
    // 添加到购物车逻辑
  }
  
  void removeFromCart(String serviceId) {
    // 从购物车移除逻辑
  }
}
```

#### 5.4.2 页面级状态管理
每个页面都有对应的Controller管理其状态：
- `ServiceBookingController`: 服务列表状态
- `ServiceDetailController`: 服务详情状态
- `CreateOrderController`: 订单创建状态
- `OrdersController`: 订单列表状态

### 5.5 路由设计

```dart
// 服务预订相关路由
class ServiceBookingRoutes {
  static const String serviceList = '/service-booking';
  static const String serviceDetail = '/service-detail';
  static const String createOrder = '/create-order';
  static const String orders = '/orders';
  static const String orderDetail = '/order-detail';
}

// 路由参数传递
Get.toNamed('/service-detail', arguments: {'serviceId': '123'});
Get.toNamed('/create-order', arguments: {
  'serviceId': '123',
  'providerId': '456'
});
```

### 5.6 错误处理和用户体验

#### 5.6.1 错误处理策略
- **网络错误**: 显示重试按钮和离线提示
- **数据加载失败**: 显示错误信息和重试选项
- **表单验证错误**: 实时验证和错误提示
- **权限错误**: 引导用户开启必要权限

#### 5.6.2 用户体验优化
- **加载状态**: 骨架屏和加载动画
- **空状态**: 友好的空状态提示
- **操作反馈**: 成功/失败提示和确认对话框
- **数据缓存**: 本地缓存减少重复请求

### 5.7 跨国服务功能设计（未来版本）

> **注意：** 跨国服务功能计划在后续版本中实现，当前版本不包含此功能。

#### 5.7.1 功能概述
跨国服务功能允许用户为海外朋友提供本地化服务，如鲜花配送、礼物代购等。该功能解决了用户跨地域服务需求的问题。

#### 5.7.2 功能入口设计
**主要入口位置**：
1. **首页**：在服务网格中添加"全球服务"卡片，用户一打开应用就能看到
2. **服务预订页面**：在位置选择器中添加"跨国服务"选项
3. **独立页面**：专门的全球服务页面，提供完整的跨国服务体验

#### 5.7.3 位置管理扩展
```dart
// 扩展UserLocation模型支持跨国服务
class UserLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String district;
  final String country;
  final LocationSource source;
  final DateTime lastUpdated;
  final bool isGlobalService;

  bool get isInternational => country != '中国';
  String get displayLocation => isInternational ? '$city, $country' : address;
}
```

#### 5.7.4 服务类型设计
**支持的跨国服务**：
- **鲜花配送**：为海外朋友送花
- **礼物代购**：精选当地特色礼物
- **本地化服务**：当地特色服务
- **餐饮配送**：当地美食配送

#### 5.7.5 用户体验设计
**位置选择流程**：
1. 用户选择"跨国服务"
2. 显示国家列表（加拿大、美国、澳大利亚等）
3. 选择具体城市
4. 显示可用服务和注意事项

**服务说明**：
- 服务价格以目标地区货币显示
- 配送时间根据距离和当地情况而定
- 支持国际信用卡和支付宝支付
- 提供订单跟踪和配送状态更新

#### 5.7.6 技术实现要点
**数据库设计**：
```sql
-- 扩展services表支持跨国服务
ALTER TABLE services ADD COLUMN is_global_service BOOLEAN DEFAULT FALSE;
ALTER TABLE services ADD COLUMN target_country TEXT;
ALTER TABLE services ADD COLUMN target_city TEXT;
ALTER TABLE services ADD COLUMN currency TEXT DEFAULT 'CNY';
ALTER TABLE services ADD COLUMN international_shipping_fee DECIMAL(10,2);
```

**API设计**：
```dart
// 跨国服务API
class GlobalServiceAPI {
  // 获取支持的国家列表
  Future<List<Country>> getSupportedCountries();
  
  // 获取指定国家的城市列表
  Future<List<City>> getCitiesByCountry(String countryCode);
  
  // 获取跨国服务列表
  Future<List<Service>> getGlobalServices(String country, String city);
  
  // 计算国际配送费用
  Future<double> calculateInternationalShipping(String fromCountry, String toCountry);
}
```

#### 5.7.7 最佳实践总结
**功能放置策略**：
1. **首页入口**：提高功能发现性，用户容易找到
2. **服务预订集成**：在现有流程中自然引入，降低学习成本
3. **独立页面**：提供完整的跨国服务体验

**用户体验优化**：
- 清晰的位置选择流程
- 透明的价格和费用说明
- 详细的配送时间预期
- 多语言支持
- 24小时客服支持

**技术考虑**：
- 时区处理
- 货币转换
- 国际支付集成
- 物流跟踪
- 多语言内容管理

---

## 6. Data Flow and Interactions

（此处插入应用启动、插件初始化、认证、主壳加载、插件间数据共享等内容，保留原文相关描述）

---

## 7. Development Environment & Tools

（此处插入IDE、版本控制、包管理、模拟器/设备等内容，保留原文相关描述）

---

## 8. Deployment & Operations

（此处插入iOS/Android配置、CI/CD、后端集成等内容，保留原文相关描述）

---

## 9. Design Discussion & Q&A

（将所有"如何.../解决思路"问题清单及其解答，全部移到本章节，按主题分组整理，便于查阅）

---

## 10. Category ID Encoding Rules

为实现多级服务分类的高效管理与扩展，JinBean App采用统一的分类ID编码规则：

### 1. 规则结构
- **ID格式**：10 + 3位一级分类 + 2位二级分类 + 2位三级分类（共7位数字，字符串类型存储）
  - 10：前缀，标识分类类型（如服务类）
  - XXX：一级分类（3位，支持001-999）
  - YY：二级分类（2位，支持01-99）
  - ZZ：三级分类（2位，支持01-99）
- 例如：
  - 1010000：美食天地（一级分类，二三级为00）
  - 1010100：居家美食（一级+二级，三级为00）
  - 1010101：家常菜送到家（完整三级分类）

### 2. 设计原则
- **层级清晰**：ID前缀即可判断所属层级和父级。
- **排序友好**：数字排序即为分类顺序。
- **扩展性强**：每级预留足够空间，便于后续插入新分类。
- **查询方便**：可通过ID前缀快速筛选同一大类/子类。
- **主键类型**：建议用字符串（varchar），避免前导0丢失。

### 3. 示例
| ID      | 中文名         | 英文名              | 备注                |
| ------- | -------------- | ------------------- | ------------------- |
| 1010000 | 美食天地       | Food Court          | 一级                |
| 1010100 | 居家美食       | Home-cooked         | 二级                |
| 1010101 | 家常菜送到家   | Homestyle Delivery  | 三级                |
| 1010102 | 家庭小灶       | Home Kitchen        | 三级                |
| 1010103 | 私人厨师上门   | Private Chef        | 三级                |
| 1010200 | 定制美食       | Custom Catering     | 二级                |
| 1010201 | 聚会大餐       | Party Catering      | 三级                |

### 4. 其它说明
- 若某级分类下暂未细分下级，可用00占位。
- 后续如需四级分类，可再加两位。
- 该规则适用于所有服务分类、标签等多级结构。

---













# 金豆荚App - 系统设计文档\n\n## 1. 引言\n\n### 1.1 目的\n本文档旨在详细描述金豆荚App的系统设计，包括其架构、技术选型、模块划分以及关键组件的设计思路，为开发团队提供清晰的实现指导。\n\n### 1.2 范围\n本设计文档涵盖金豆荚App客户端的核心架构、插件管理系统、状态管理、路由、国际化和本地数据存储。\n\n### 1.3 术语与定义\n*   **超级App (Super App)**: 一个集成多种独立服务或功能模块的移动应用。\n*   **插件 (Plugin)**: 金豆荚App中可独立开发、部署和管理的功能模块。\n*   **GetX**: Flutter中用于状态管理、依赖注入和路由的框架。\n*   **ARBs (.arb files)**: Application Resource Bundle 文件，用于Flutter国际化文本定义。\n\n## 2. 总体架构 (Overall Architecture)\n\n金豆荚App采用**插件化架构**，核心是一个轻量级的应用壳（ShellApp），通过**插件管理器 (Plugin Manager)** 动态加载和管理各个独立的功能模块（Plugins）。每个功能模块内部遵循**MVVM (Model-View-ViewModel)** 模式，通过GetX进行状态管理和依赖注入。\n\n### 2.1 架构分层\n\n```\n+-------------------------------------------------------------+\n|                          金豆荚 App                         |\n|                                                             |\n| +---------------------------------------------------------+ |\n| |                         UI / 视图层                       | |\n| | +-----------------------------------------------------+ | |\n| | |                       ShellApp (应用壳)               | | |\n| | |  - 底部导航栏                                         | | |\n| | |  - 页面容器                                           | | |\n| | +-----------------------------------------------------+ | |\n| | +-----------------------------------------------------+ | |\n| | |                  功能模块 (Plugins)                   | | |\n| | |  - Auth Plugin                                        | | |\n| | |  - Home Plugin                                        | | |\n| | |  - Service Booking Plugin                             | | |\n| | |  - Community Plugin                                   | | |\n| | |  - Profile Plugin                                     | | |\n| | |  (各模块内部遵循 MVVM: Page -> Controller -> Service/Repository) |\n| | +-----------------------------------------------------+ | |\n| +---------------------------------------------------------+ |\n|                                                             |\n| +---------------------------------------------------------+ |\n| |                     业务逻辑 / 控制器层                     | |\n| | +-----------------------------------------------------+ | |\
| | |                     GetX Controllers                    | | |\n| | |  - 处理业务逻辑                                       | | |\n| | |  - 管理响应式状态 (Rx variables)                      | | |\
| | +-----------------------------------------------------+ | |\
| +---------------------------------------------------------+ |\
|                                                             |\
| +---------------------------------------------------------+ |\
| |                      数据 / 服务层                        | |\
| | +-----------------------------------------------------+ | |\
| | |                  本地数据存储 (GetStorage)              | | |\
| | |  - 用户偏好设置                                       | | |\
| | |  - 登录状态                                           | | |\
| | +-----------------------------------------------------+ | |\
| | +-----------------------------------------------------+ | |\
| | |                  插件管理系统 (Plugin Manager)          | | |\
| | |  - 插件注册与生命周期管理                             | | |\
| | |  - 动态路由注册                                       | | |\
| | +-----------------------------------------------------+ | |\
| | +-----------------------------------------------------+ | |\
| | |                  API 服务 / Mock 数据                  | | |\
| | |  - 认证服务 (Mock)                                    | | |\
| | |  - 各业务模块数据 (Mock)                              | | |\
| | +-----------------------------------------------------+ | |\
| +---------------------------------------------------------+ |\
+-------------------------------------------------------------+\n```\n\n### 2.2 模块划分 (Modularization)\n\n项目代码按照功能模块进行划分，主要体现在 `lib/features` 目录下。每个功能模块（例如 `auth`, `home` 等）被视为一个独立的插件，内部结构如下：\n\n```\nfeatures/\n└── [plugin_name]/\n    ├── [plugin_name]_plugin.dart  # 插件入口定义 (AppPlugin 的实现)\n    └── presentation/             # 模块的UI和状态管理层\n        ├── [plugin_name]_binding.dart    # GetX 依赖绑定\n        ├── [plugin_name]_controller.dart # GetX 状态控制器\n        └── [plugin_name]_page.dart       # UI 页面\n```\n\n这种划分方式的好处：\n*   **高内聚低耦合**: 每个模块专注于自身功能，减少与其他模块的直接依赖。\n*   **易于扩展**: 添加新功能只需创建新的插件模块，无需修改核心代码。\n*   **团队协作**: 不同团队或开发者可以并行开发不同的模块。\n*   **可维护性**: 模块化结构使代码更易于理解、测试和调试。\n\n## 3. 技术选型 (Technology Stack)\n\n*   **前端框架**: Flutter (Dart)\n*   **状态管理 / 依赖注入 / 路由**: GetX\n*   **本地数据存储**: GetStorage\n*   **国际化**: Flutter 自带国际化机制 (.arb 文件)\n*   **社交登录**: `google_sign_in` 和 `sign_in_with_apple` 包\n*   **后端**: 当前阶段为 Mock 数据和 Mock 认证逻辑，未来可扩展至 Supabase、Firebase 或自定义后端。\n\n## 4. 核心组件设计\n\n### 4.1 插件管理系统 (Plugin Management System)\n\n*   **`AppPlugin` (lib/core/plugin_management/app_plugin.dart)**:\n    *   抽象基类，定义了所有插件必须实现的接口。\n    *   包含 `PluginMetadata` (插件ID, 名称Key, 图标, 启用状态, 顺序, 类型, 路由名) 来描述插件属性。\n    *   定义了 `buildEntryWidget()`, `getRoutes()`, `init()`, `dispose()` 等方法，用于插件的UI构建、路由注册和生命周期管理。\n\n*   **`PluginManager` (lib/core/plugin_management/plugin_manager.dart)**:\n    *   单例模式 (`Get.put` 全局初始化)。\n    *   负责注册所有可用的 `AppPlugin` 实例。\n    *   模拟从后端获取插件配置（`_fetchPluginsConfiguration()`），根据配置动态启用/禁用插件。\n    *   在插件初始化时调用其 `init()` 方法和 `bindings?.dependencies()` 来注入控制器。\n    *   根据插件类型 (如 `standalonePage`) 动态注册 GetX 路由。\n    *   维护 `isInitialized` 状态，确保其他模块在插件系统就绪后才进行操作。\n    *   维护 `isLoggedIn` 状态，与 `AuthController` 联动，控制导航逻辑。\n\n### 4.2 认证模块 (Auth Plugin)\n\n*   **`AuthController` (lib/features/auth/presentation/auth_controller.dart)**:\n    *   管理用户认证状态 (登录/未登录)。\n    *   处理邮箱/密码登录和注册逻辑 (当前为Mock实现)。\n    *   集成 `google_sign_in` 和 `sign_in_with_apple` 包，提供社交登录入口 (当前UI可见，功能暂时禁用并返回提示)。\n    *   管理UI相关的状态（如 `isLoading`, `errorMessage`, `isPasswordVisible`）。\n    *   成功登录后，更新 `PluginManager` 的 `isLoggedIn` 状态，并导航至主应用壳。\n    *   通过 `GetStorage` 持久化用户登录信息（如邮箱）。\n\n*   **页面**:\n    *   `LoginPage` / `RegisterPage` (lib/features/auth/presentation/):\n        *   使用 `GetView<AuthController>` 访问 `AuthController` 的状态和方法。\n        *   UI设计遵循Figma，包含文本输入框、按钮、以及社交登录按钮的占位。\n        *   `RegisterPage` 包含密码确认逻辑。\n\n### 4.3 主应用壳 (ShellApp)\n\n*   **`ShellApp` (lib/app/shell_app.dart)**:\n    *   作为应用程序的根部Widget，负责构建底部导航栏 (`BottomNavigationBar`)。\n    *   通过 `PluginManager` 获取所有启用的 `bottomTab` 类型插件的元数据，并动态生成导航栏项和对应的页面内容。\n    *   使用 `PageView` 来管理底部导航栏页面的切换，并通过 `IndexedStack` 保持页面状态。\n\n*   **`ShellAppController` (lib/app/shell_app_controller.dart)**:\n    *   管理 `ShellApp` 内部的状态，例如当前选中的底部导航栏索引。\n\n### 4.4 国际化 (Internationalization)\n\n*   **`.arb` 文件 (lib/l10n/)**:\n    *   使用 JSON 格式定义不同语言的字符串资源。\n    *   包含描述性元数据 (`@key` 语法) 提升可维护性。\n*   **`flutter gen-l10n`**: 命令行工具，根据 `.arb` 文件自动生成 `AppLocalizations` 类，提供类型安全的字符串访问。\n*   **`GetMaterialApp`**: 配置 `localizationsDelegates` 和 `supportedLocales` 来启用多语言支持。\n\n## 5. 数据流与交互 (Data Flow and Interactions)\n\n1.  **应用启动**: `main.dart` -> `WidgetsFlutterBinding.ensureInitialized()` -> `GetStorage.init()` -> `Get.put(PluginManager())` -> `Get.put(AuthController())` -> `Get.put(SplashController())` -> `runApp(GetMaterialApp(initialRoute: '/splash'))`。\n2.  **Splash页面加载**: `SplashPage` 构建，`SplashController` 初始化并开始加载插件（通过 `PluginManager`）。\n3.  **插件初始化**: `PluginManager` 异步加载配置，注册插件，并调用各插件的 `init()` 和 `bindings?.dependencies()`。\n4.  **导航至登录/注册**: `SplashPage` 动画完成后，用户点击"Sign In"或"Sign Up"按钮，触发 `SplashController` 中的 `navigateToLogin()` 或 `navigateToRegister()`，通过 `Get.offAllNamed()` 导航至 `/auth` 或 `/register` 路由。\n5.  **用户认证**: 在 `LoginPage` 或 `RegisterPage` 中，用户输入凭据或点击社交登录按钮。`AuthController` 处理这些请求：\n    *   普通登录/注册: 验证凭据 (Mock)，成功则调用 `_handleSuccessfulLogin()`。\n    *   社交登录: 调用对应的SDK (当前为UI占位)。\n6.  **登录成功**: `_handleSuccessfulLogin()` 方法更新 `GetStorage` 和 `PluginManager.isLoggedIn` 状态，并通过 `Get.offAllNamed('/main_shell')` 导航到主应用壳。\n7.  **ShellApp 加载**: `ShellApp` 构建，通过 `PluginManager` 获取启用的底部标签页插件，动态构建 `BottomNavigationBar` 和对应的 `PageView`。各标签页的控制器由各自的 `_binding.dart` 在页面首次加载时 `lazyPut`。\n8.  **插件间数据共享**: 通过 `Get.find<Controller>()` 或 `Get.put<Controller>()` 实现控制器间的通信和数据共享。\n\n## 6. 开发环境与工具\n\n*   **IDE**: VS Code (推荐使用 Flutter 和 Dart 扩展)\n*   **版本控制**: Git\n*   **包管理**: pub (Flutter)\n*   **模拟器/设备**: iOS Simulator / Android Emulator / 真实设备\n\n## 7. 部署考虑 (Deployment Considerations)\n\n*   **iOS/Android 配置**: 需要根据具体平台进行额外的配置（如 Info.plist, AndroidManifest.xml），尤其是社交登录和推送通知。\n*   **CI/CD**: 未来可集成持续集成/持续部署管道，自动化构建、测试和发布流程。\n*   **后端集成**: 当前为Mock，未来需要与真实的后端服务（如Supabase、Firebase）进行API集成，实现数据持久化和安全性。 