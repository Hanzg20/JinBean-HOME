

/// 基础实体模型
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
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 地址类型枚举
enum AddressType {
  home('home', 'Home'),
  work('work', 'Work'),
  billing('billing', 'Billing'),
  delivery('delivery', 'Delivery'),
  other('other', 'Other');

  const AddressType(this.value, this.displayName);
  final String value;
  final String displayName;

  static AddressType fromString(String value) {
    return AddressType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AddressType.home,
    );
  }
}

/// 通用地址模型（适配数据库结构）
class Address {
  final String id;
  final String? standardAddressId;
  final String country;
  final String? province;
  final String? city;
  final String? district;
  final String? streetNumber;
  final String? streetName;
  final String? streetType;
  final String? streetDirection;
  final String? suiteUnit;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final int? geonamesId;
  final Map<String, dynamic>? extra;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // P1、P2 新增字段
  final String? userId;
  final AddressType addressType;
  final bool isDefault;

  Address({
    required this.id,
    this.standardAddressId,
    this.country = 'Canada',
    this.province,
    this.city,
    this.district,
    this.streetNumber,
    this.streetName,
    this.streetType,
    this.streetDirection,
    this.suiteUnit,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.geonamesId,
    this.extra,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.addressType = AddressType.home,
    this.isDefault = false,
  });

  String get fullAddress {
    final parts = <String>[];
    
    // 构建街道地址
    final streetParts = [
      streetNumber,
      streetName,
      streetType,
      streetDirection,
    ].where((part) => part?.isNotEmpty == true).join(' ');
    
    if (streetParts.isNotEmpty) parts.add(streetParts);
    if (suiteUnit?.isNotEmpty == true) parts.add('Unit $suiteUnit');
    if (city?.isNotEmpty == true) parts.add(city!);
    if (province?.isNotEmpty == true && postalCode?.isNotEmpty == true) {
      parts.add('$province $postalCode');
    } else if (province?.isNotEmpty == true) {
      parts.add(province!);
    }
    parts.add(country);
    
    return parts.join(', ');
  }

  String get shortAddress {
    final parts = [streetNumber, streetName, city].where((part) => part?.isNotEmpty == true);
    return parts.join(' ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'standard_address_id': standardAddressId,
      'country': country,
      'province': province,
      'city': city,
      'district': district,
      'street_number': streetNumber,
      'street_name': streetName,
      'street_type': streetType,
      'street_direction': streetDirection,
      'suite_unit': suiteUnit,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'geonames_id': geonamesId,
      'extra': extra,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
      'address_type': addressType.value,
      'is_default': isDefault,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      standardAddressId: json['standard_address_id'] as String?,
      country: json['country'] as String? ?? 'Canada',
      province: json['province'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      streetNumber: json['street_number'] as String?,
      streetName: json['street_name'] as String?,
      streetType: json['street_type'] as String?,
      streetDirection: json['street_direction'] as String?,
      suiteUnit: json['suite_unit'] as String?,
      postalCode: json['postal_code'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      geonamesId: json['geonames_id'] as int?,
      extra: json['extra'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userId: json['user_id'] as String?,
      addressType: AddressType.fromString(json['address_type'] as String? ?? 'home'),
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Address copyWith({
    String? id,
    String? standardAddressId,
    String? country,
    String? province,
    String? city,
    String? district,
    String? streetNumber,
    String? streetName,
    String? streetType,
    String? streetDirection,
    String? suiteUnit,
    String? postalCode,
    double? latitude,
    double? longitude,
    int? geonamesId,
    Map<String, dynamic>? extra,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    AddressType? addressType,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      standardAddressId: standardAddressId ?? this.standardAddressId,
      country: country ?? this.country,
      province: province ?? this.province,
      city: city ?? this.city,
      district: district ?? this.district,
      streetNumber: streetNumber ?? this.streetNumber,
      streetName: streetName ?? this.streetName,
      streetType: streetType ?? this.streetType,
      streetDirection: streetDirection ?? this.streetDirection,
      suiteUnit: suiteUnit ?? this.suiteUnit,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geonamesId: geonamesId ?? this.geonamesId,
      extra: extra ?? this.extra,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      addressType: addressType ?? this.addressType,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

/// 通用价格模型
class Price {
  final double amount;
  final String currency;

  Price({
    required this.amount,
    this.currency = 'CAD',
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
    };
  }

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'CAD',
    );
  }

  String get formatted {
    return '\$${amount.toStringAsFixed(2)} $currency';
  }

  Price operator +(Price other) {
    if (currency != other.currency) {
      throw ArgumentError('Cannot add prices with different currencies');
    }
    return Price(amount: amount + other.amount, currency: currency);
  }

  Price operator -(Price other) {
    if (currency != other.currency) {
      throw ArgumentError('Cannot subtract prices with different currencies');
    }
    return Price(amount: amount - other.amount, currency: currency);
  }

  Price operator *(double multiplier) {
    return Price(amount: amount * multiplier, currency: currency);
  }

  bool operator >(Price other) {
    if (currency != other.currency) {
      throw ArgumentError('Cannot compare prices with different currencies');
    }
    return amount > other.amount;
  }

  bool operator <(Price other) {
    if (currency != other.currency) {
      throw ArgumentError('Cannot compare prices with different currencies');
    }
    return amount < other.amount;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Price &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          currency == other.currency;

  @override
  int get hashCode => amount.hashCode ^ currency.hashCode;
}

/// 多语言文本模型
class MultiLanguageText {
  final Map<String, String> translations;

  MultiLanguageText(this.translations);

  factory MultiLanguageText.single(String text, {String language = 'en'}) {
    return MultiLanguageText({language: text});
  }

  String getText([String? languageCode]) {
    final code = languageCode ?? 'zh';
    return translations[code] ?? 
           translations['en'] ?? 
           translations.values.first;
  }

  String get chinese => getText('zh');
  String get english => getText('en');

  Map<String, dynamic> toJson() => translations;

  factory MultiLanguageText.fromJson(Map<String, dynamic> json) {
    return MultiLanguageText(Map<String, String>.from(json));
  }

  factory MultiLanguageText.fromDynamic(dynamic data) {
    if (data is String) {
      return MultiLanguageText.single(data);
    } else if (data is Map<String, dynamic>) {
      return MultiLanguageText.fromJson(data);
    } else {
      return MultiLanguageText.single('');
    }
  }

  MultiLanguageText copyWith(Map<String, String> newTranslations) {
    return MultiLanguageText({...translations, ...newTranslations});
  }

  @override
  String toString() => getText();
}

/// 通用状态枚举基类
abstract class BaseStatus {
  final String code;
  final String label;

  const BaseStatus(this.code, this.label);

  @override
  String toString() => label;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseStatus && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}

/// 通用订单状态
enum OrderStatus implements BaseStatus {
  pending('pending', '待处理'),
  accepted('accepted', '已接受'),
  inProgress('in_progress', '进行中'),
  completed('completed', '已完成'),
  cancelled('cancelled', '已取消'),
  disputed('disputed', '有争议');

  const OrderStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }

  // 向后兼容
  @override
  String get code => value;
  
  @override
  String get label => displayName;

  static OrderStatus fromCode(String code) => fromString(code);

  bool get isActive => this == accepted || this == inProgress;
  bool get isCompleted => this == completed;
  bool get isCancelled => this == cancelled;
  bool get canCancel => this == pending || this == accepted;
}

/// 通用支付状态
enum PaymentStatus implements BaseStatus {
  pending('pending', '待支付'),
  processing('processing', '处理中'),
  completed('completed', '支付成功'),
  failed('failed', '支付失败'),
  cancelled('cancelled', '已取消'),
  refunded('refunded', '已退款'),
  partiallyRefunded('partially_refunded', '部分退款');

  const PaymentStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }

  // 向后兼容
  @override
  String get code => value;
  
  @override
  String get label => displayName;

  static PaymentStatus fromCode(String code) => fromString(code);

  bool get isPaid => this == completed;
  bool get canRefund => this == completed;
  bool get isFailed => this == failed || this == cancelled;
}

/// 购物车类型
enum CartType {
  restaurant('restaurant', '餐厅'),
  appointment('appointment', '预约'),
  mixed('mixed', '混合'),
  service('service', '服务'),
  rental('rental', '租赁');

  const CartType(this.value, this.displayName);

  final String value;
  final String displayName;

  String get code => value;
  String get label => displayName;

  static CartType fromString(String value) {
    return CartType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CartType.service,
    );
  }
}

/// 购物车商品类型
enum CartItemType {
  menuItem('menu_item', '菜品'),
  appointment('appointment', '预约'),
  package('package', '套餐'),
  mainService('main_service', '主要服务'),
  additionalService('additional_service', '附加服务');

  const CartItemType(this.value, this.displayName);

  final String value;
  final String displayName;

  String get code => value;
  String get label => displayName;

  static CartItemType fromString(String value) {
    return CartItemType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CartItemType.mainService,
    );
  }
}

/// 通用行业类型
enum IndustryType {
  food('food', '餐饮美食'),
  home('home', '家居服务'),
  transport('transport', '出行交通'),
  rental('rental', '租赁共享'),
  learning('learning', '学习成长'),
  professional('professional', '专业速帮');

  const IndustryType(this.value, this.displayName);

  final String value;
  final String displayName;

  static IndustryType fromString(String value) {
    return IndustryType.values.firstWhere(
      (industry) => industry.value == value,
      orElse: () => IndustryType.food,
    );
  }

  // 保持向后兼容
  String get code => value;
  String get label => displayName;
  
  static IndustryType fromCode(String code) => fromString(code);
}

/// 通用定价类型
enum PricingType {
  fixedPrice('fixed_price', '固定价格'),
  hourlyRate('hourly_rate', '按小时计费'),
  perItem('per_item', '按项目计费'),
  tieredPricing('tiered_pricing', '阶梯定价'),
  dynamicPricing('dynamic_pricing', '动态定价'),
  packageDeal('package_deal', '套餐价格'),
  customQuote('custom_quote', '自定义报价');

  const PricingType(this.value, this.displayName);

  final String value;
  final String displayName;

  static PricingType fromString(String value) {
    return PricingType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PricingType.fixedPrice,
    );
  }

  // 向后兼容
  String get code => value;
  String get label => displayName;

  static PricingType fromCode(String code) => fromString(code);
}

/// 服务预订类型
enum ServiceBookingType {
  cartOnly('cart_only', '仅购物车'),
  directBooking('direct_booking', '直接预订'),
  hybrid('hybrid', '混合模式');

  const ServiceBookingType(this.value, this.displayName);

  final String value;
  final String displayName;

  /// 是否支持购物车功能
  bool get supportsCart {
    switch (this) {
      case ServiceBookingType.cartOnly:
      case ServiceBookingType.hybrid:
        return true;
      case ServiceBookingType.directBooking:
        return false;
    }
  }

  /// 是否支持直接预订
  bool get supportsDirectBooking {
    switch (this) {
      case ServiceBookingType.directBooking:
      case ServiceBookingType.hybrid:
        return true;
      case ServiceBookingType.cartOnly:
        return false;
    }
  }

  static ServiceBookingType fromString(String value) {
    return ServiceBookingType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ServiceBookingType.directBooking,
    );
  }
}

/// 通用支付方式类型
enum PaymentMethodType {
  creditCard('credit_card', '信用卡'),
  debitCard('debit_card', '借记卡'),
  paypal('paypal', 'PayPal'),
  applePay('apple_pay', 'Apple Pay'),
  googlePay('google_pay', 'Google Pay'),
  bankTransfer('bank_transfer', '银行转账'),
  cash('cash', '现金'),
  other('other', '其他');

  const PaymentMethodType(this.code, this.label);

  final String code;
  final String label;

  static PaymentMethodType fromCode(String code) {
    return PaymentMethodType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => PaymentMethodType.creditCard,
    );
  }

  bool get isCard => this == creditCard || this == debitCard;
  bool get isDigitalWallet => this == paypal || this == applePay || this == googlePay;
}

/// 退款状态枚举
enum RefundStatus implements BaseStatus {
  pending('pending', '待退款'),
  processing('processing', '退款处理中'),
  completed('completed', '退款完成'),
  failed('failed', '退款失败'),
  canceled('canceled', '退款取消');

  const RefundStatus(this.code, this.label);

  @override
  final String code;
  
  @override
  final String label;

  static RefundStatus fromCode(String code) {
    return RefundStatus.values.firstWhere(
      (status) => status.code == code,
      orElse: () => RefundStatus.pending,
    );
  }

  bool get isCompleted => this == completed;
  bool get isFailed => this == failed || this == canceled;
  bool get isPending => this == pending || this == processing;
}

/// 通用业务规则配置
class BusinessRule {
  final String key;
  final dynamic value;
  final String? description;

  BusinessRule({
    required this.key,
    required this.value,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'description': description,
    };
  }

  factory BusinessRule.fromJson(Map<String, dynamic> json) {
    return BusinessRule(
      key: json['key'],
      value: json['value'],
      description: json['description'],
    );
  }
}

/// 通用配置集合
class Configuration {
  final Map<String, dynamic> _config;

  Configuration(this._config);

  T? get<T>(String key, [T? defaultValue]) {
    final value = _config[key];
    if (value is T) return value;
    return defaultValue;
  }

  void set<T>(String key, T value) {
    _config[key] = value;
  }

  bool has(String key) => _config.containsKey(key);

  Map<String, dynamic> toJson() => Map.from(_config);

  factory Configuration.fromJson(Map<String, dynamic> json) {
    return Configuration(Map.from(json));
  }

  Configuration copyWith(Map<String, dynamic> updates) {
    return Configuration({..._config, ...updates});
  }
}

/// 通用用户偏好设置
class UserPreferences {
  final String userId;
  final String language;
  final String currency;
  final String timezone;
  final Map<String, dynamic> notificationSettings;
  final Map<String, dynamic> privacySettings;
  final Map<String, dynamic> customSettings;

  UserPreferences({
    required this.userId,
    this.language = 'zh',
    this.currency = 'CAD',
    this.timezone = 'America/Vancouver',
    this.notificationSettings = const {},
    this.privacySettings = const {},
    this.customSettings = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'language': language,
      'currency': currency,
      'timezone': timezone,
      'notification_settings': notificationSettings,
      'privacy_settings': privacySettings,
      'custom_settings': customSettings,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['user_id'],
      language: json['language'] ?? 'zh',
      currency: json['currency'] ?? 'CAD',
      timezone: json['timezone'] ?? 'America/Vancouver',
      notificationSettings: json['notification_settings'] ?? {},
      privacySettings: json['privacy_settings'] ?? {},
      customSettings: json['custom_settings'] ?? {},
    );
  }

  UserPreferences copyWith({
    String? language,
    String? currency,
    String? timezone,
    Map<String, dynamic>? notificationSettings,
    Map<String, dynamic>? privacySettings,
    Map<String, dynamic>? customSettings,
  }) {
    return UserPreferences(
      userId: userId,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      privacySettings: privacySettings ?? this.privacySettings,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}

/// 通用时间范围
class TimeRange {
  final DateTime start;
  final DateTime end;

  TimeRange({
    required this.start,
    required this.end,
  });

  Duration get duration => end.difference(start);
  
  bool contains(DateTime dateTime) {
    return dateTime.isAfter(start) && dateTime.isBefore(end);
  }

  bool overlaps(TimeRange other) {
    return start.isBefore(other.end) && end.isAfter(other.start);
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    return TimeRange(
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
    );
  }
}

/// 通用验证结果
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final Map<String, String> fieldErrors;

  ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.fieldErrors = const {},
  });

  factory ValidationResult.valid() {
    return ValidationResult(isValid: true);
  }

  factory ValidationResult.invalid(List<String> errors, [Map<String, String>? fieldErrors]) {
    return ValidationResult(
      isValid: false,
      errors: errors,
      fieldErrors: fieldErrors ?? {},
    );
  }

  factory ValidationResult.fieldError(String field, String error) {
    return ValidationResult(
      isValid: false,
      fieldErrors: {field: error},
    );
  }

  String get firstError => errors.isNotEmpty ? errors.first : fieldErrors.values.first;
  
  bool hasFieldError(String field) => fieldErrors.containsKey(field);
  String? getFieldError(String field) => fieldErrors[field];
}

/// 通用分页信息
class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  bool get hasNext => page < totalPages;
  bool get hasPrevious => page > 1;
  int get nextPage => hasNext ? page + 1 : page;
  int get previousPage => hasPrevious ? page - 1 : page;
  int get offset => (page - 1) * limit;

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'total_pages': totalPages,
      'has_next': hasNext,
      'has_previous': hasPrevious,
    };
  }

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      totalPages: json['total_pages'],
    );
  }
}

/// 通用分页结果
class PagedResult<T> {
  final List<T> items;
  final Pagination pagination;

  PagedResult({
    required this.items,
    required this.pagination,
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get length => items.length;

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) itemToJson) {
    return {
      'items': items.map(itemToJson).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

/// 购物车异常类
class CartException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const CartException(
    this.message, {
    this.code,
    this.details,
  });

  @override
  String toString() => 'CartException: $message';
}

/// 订单异常类
class OrderException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const OrderException(
    this.message, {
    this.code,
    this.details,
  });

  @override
  String toString() => 'OrderException: $message';
}

/// 支付异常类
class PaymentException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const PaymentException(
    this.message, {
    this.code,
    this.details,
  });

  @override
  String toString() => 'PaymentException: $message';
}
