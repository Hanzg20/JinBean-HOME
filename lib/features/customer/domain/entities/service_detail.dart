import 'dart:convert';

/// 服务详情实体类 - 支持多子服务场景
class ServiceDetail {
  // 新的主键字段
  final String id;
  final String serviceId;
  
  // 子服务基本信息（新增）
  final Map<String, String> name; // 多语言名称
  final Map<String, String>? description; // 多语言描述
  final String category; // 分类：main, sub, appetizer, main_course, dessert等
  final String? subCategory; // 子分类：spicy, vegetarian, seafood等
  final bool isAvailable; // 是否可用
  final int sortOrder; // 排序
  final int? currentStock; // 当前库存
  final int? maxStock; // 最大库存
  final Map<String, dynamic>? industryAttributes; // 行业特定属性
  final String? parentId; // 父服务ID（用于子服务）
  
  // 原有字段
  final String? pricingType;
  final double? price;
  final String? currency;
  final String? negotiationDetails;
  final String? durationType;
  final int? duration;
  final List<String>? images;
  final List<String>? tags;
  final List<String>? serviceAreaCodes;
  final Map<String, dynamic>? serviceDetailsJson;
  final Map<String, dynamic>? details;

  ServiceDetail({
    required this.id,
    required this.serviceId,
    required this.name,
    this.description,
    required this.category,
    this.subCategory,
    this.isAvailable = true,
    this.sortOrder = 0,
    this.currentStock,
    this.maxStock,
    this.industryAttributes,
    this.parentId,
    this.pricingType,
    this.price,
    this.currency,
    this.negotiationDetails,
    this.durationType,
    this.duration,
    this.images,
    this.tags,
    this.serviceAreaCodes,
    this.serviceDetailsJson,
    this.details,
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    return ServiceDetail(
      id: json['id'] ?? '',
      serviceId: json['service_id'] ?? json['serviceId'] ?? '',
      name: _parseJsonbField(json['name']),
      description: _parseJsonbField(json['description']),
      category: json['category'] ?? 'main',
      subCategory: json['sub_category'] ?? json['subCategory'],
      isAvailable: json['is_active'] ?? json['isAvailable'] ?? true,
      sortOrder: json['sort_order'] ?? json['sortOrder'] ?? 0,
      currentStock: json['current_stock'] ?? json['currentStock'],
      maxStock: json['max_stock'] ?? json['maxStock'],
      industryAttributes: json['industry_attributes'] ?? json['industryAttributes'],
      parentId: json['parent_id'] ?? json['parentId'],
      pricingType: json['pricing_type'] ?? json['pricingType'],
      price: json['price']?.toDouble(),
      currency: json['currency'],
      negotiationDetails: json['negotiation_details'] ?? json['negotiationDetails'],
      durationType: json['duration_type'] ?? json['durationType'],
      duration: json['duration'],
      images: json['images_url'] != null 
          ? List<String>.from(json['images_url'])
          : json['images'] != null 
              ? List<String>.from(json['images'])
              : null,
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'])
          : null,
      serviceAreaCodes: json['service_area_codes'] != null 
          ? List<String>.from(json['service_area_codes'])
          : json['serviceAreaCodes'] != null 
              ? List<String>.from(json['serviceAreaCodes'])
              : null,
      serviceDetailsJson: json['service_details_json'] ?? json['serviceDetailsJson'],
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'name': name,
      'description': description,
      'category': category,
      'sub_category': subCategory,
      'is_active': isAvailable,
      'sort_order': sortOrder,
      'current_stock': currentStock,
      'max_stock': maxStock,
      'industry_attributes': industryAttributes,
      'parent_id': parentId,
      'pricing_type': pricingType,
      'price': price,
      'currency': currency,
      'negotiation_details': negotiationDetails,
      'duration_type': durationType,
      'duration': duration,
      'images_url': images,
      'tags': tags,
      'service_area_codes': serviceAreaCodes,
      'service_details_json': serviceDetailsJson,
      'details': details,
    };
  }

  /// 解析jsonb字段
  static Map<String, String> _parseJsonbField(dynamic value) {
    if (value == null) {
      return {'en': 'Main Service', 'zh': '主要服务'};
    }
    
    if (value is Map) {
      return Map<String, String>.from(value);
    }
    
    if (value is String) {
      try {
        final Map<String, dynamic> parsed = Map<String, dynamic>.from(
          jsonDecode(value)
        );
        return Map<String, String>.from(parsed);
      } catch (e) {
        return {'en': value, 'zh': value};
      }
    }
    
    return {'en': 'Main Service', 'zh': '主要服务'};
  }

  /// 获取多语言名称
  String getName(String language) {
    return name[language] ?? name['en'] ?? name['zh'] ?? 'Main Service';
  }

  /// 获取多语言描述
  String? getDescription(String language) {
    return description?[language] ?? description?['en'] ?? description?['zh'];
  }

  /// 检查是否为主服务
  bool get isMainService => category == 'main';

  /// 检查是否为子服务
  bool get isSubService => category == 'sub';

  /// 检查是否可用
  bool get isAvailableForBooking => isAvailable && (currentStock == null || currentStock! > 0);

  /// 复制并更新字段
  ServiceDetail copyWith({
    String? id,
    String? serviceId,
    Map<String, String>? name,
    Map<String, String>? description,
    String? category,
    String? subCategory,
    bool? isAvailable,
    int? sortOrder,
    int? currentStock,
    int? maxStock,
    Map<String, dynamic>? industryAttributes,
    String? parentId,
    String? pricingType,
    double? price,
    String? currency,
    String? negotiationDetails,
    String? durationType,
    int? duration,
    List<String>? images,
    List<String>? tags,
    List<String>? serviceAreaCodes,
    Map<String, dynamic>? serviceDetailsJson,
    Map<String, dynamic>? details,
  }) {
    return ServiceDetail(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      isAvailable: isAvailable ?? this.isAvailable,
      sortOrder: sortOrder ?? this.sortOrder,
      currentStock: currentStock ?? this.currentStock,
      maxStock: maxStock ?? this.maxStock,
      industryAttributes: industryAttributes ?? this.industryAttributes,
      parentId: parentId ?? this.parentId,
      pricingType: pricingType ?? this.pricingType,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      negotiationDetails: negotiationDetails ?? this.negotiationDetails,
      durationType: durationType ?? this.durationType,
      duration: duration ?? this.duration,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      serviceAreaCodes: serviceAreaCodes ?? this.serviceAreaCodes,
      serviceDetailsJson: serviceDetailsJson ?? this.serviceDetailsJson,
      details: details ?? this.details,
    );
  }

  @override
  String toString() {
    return 'ServiceDetail(id: $id, serviceId: $serviceId, name: $name, category: $category, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceDetail && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 