import '../../features/customer/domain/entities/service.dart';
import '../models/base_models.dart';
import '../models/cart_models.dart';
import '../utils/app_logger.dart';

/// 服务预订类型解析器
/// 负责根据服务特征判断应该使用哪种预订模式
class ServiceBookingTypeResolver {
  // 私有构造函数，使用单例模式
  ServiceBookingTypeResolver._();
  static final ServiceBookingTypeResolver _instance =
      ServiceBookingTypeResolver._();
  static ServiceBookingTypeResolver get instance => _instance;

  /// 解析服务的预订类型
  static ServiceBookingType resolve(Service service) {
    try {
      final categoryId = service.categoryLevel1Id?.toString();
      final tags = service.tags ?? [];
      final title = service.title?.toLowerCase() ?? '';

      AppLogger.debug(
          '[BookingTypeResolver] Analyzing service: ${service.id}, category: $categoryId, tags: $tags');

      // 1. 餐饮服务强制购物车模式
      if (_isRestaurantService(service)) {
        AppLogger.debug(
            '[BookingTypeResolver] Restaurant service detected -> CartOnly');
        return ServiceBookingType.cartOnly;
      }

      // 2. 紧急或即时服务直接下单
      if (_isEmergencyService(service) || _isInstantService(service)) {
        AppLogger.debug(
            '[BookingTypeResolver] Emergency/Instant service detected -> DirectOnly');
        return ServiceBookingType.directBooking;
      }

      // 3. 咨询类服务直接下单
      if (_isConsultationService(service)) {
        AppLogger.debug(
            '[BookingTypeResolver] Consultation service detected -> DirectOnly');
        return ServiceBookingType.directBooking;
      }

      // 4. 预约类服务提供双选项
      if (_isAppointmentService(service)) {
        AppLogger.debug(
            '[BookingTypeResolver] Appointment service detected -> Both');
        return ServiceBookingType.hybrid;
      }

      // 5. 默认情况：根据分类判断
      final defaultType = _getDefaultTypeByCategory(categoryId);
      AppLogger.debug(
          '[BookingTypeResolver] Using default type for category $categoryId -> $defaultType');
      return defaultType;
    } catch (e) {
      AppLogger.error('[BookingTypeResolver] Error resolving booking type: $e');
      // 发生错误时返回直接下单模式
      return ServiceBookingType.directBooking;
    }
  }

  /// 判断是否为餐饮服务
  static bool _isRestaurantService(Service service) {
    final categoryId = service.categoryLevel1Id?.toString();
    return categoryId == '1010000'; // 美食天地
  }

  /// 判断是否为紧急服务
  static bool _isEmergencyService(Service service) {
    final tags = service.tags ?? [];
    final title = service.title?.toLowerCase() ?? '';

    return tags.any((tag) =>
            tag.toLowerCase().contains('emergency') ||
            tag.toLowerCase().contains('urgent') ||
            tag.toLowerCase().contains('紧急') ||
            tag.toLowerCase().contains('急诊')) ||
        title.contains('emergency') ||
        title.contains('紧急');
  }

  /// 判断是否为即时服务
  static bool _isInstantService(Service service) {
    final tags = service.tags ?? [];
    final title = service.title?.toLowerCase() ?? '';

    return tags.any((tag) =>
            tag.toLowerCase().contains('instant') ||
            tag.toLowerCase().contains('immediate') ||
            tag.toLowerCase().contains('即时') ||
            tag.toLowerCase().contains('立即') ||
            tag.toLowerCase().contains('real-time')) ||
        title.contains('instant') ||
        title.contains('即时');
  }

  /// 判断是否为咨询服务
  static bool _isConsultationService(Service service) {
    final title = service.title?.toLowerCase() ?? '';
    final tags = service.tags ?? [];
    final description = service.description?.toString().toLowerCase() ?? '';

    return title.contains('consultation') ||
        title.contains('咨询') ||
        title.contains('advice') ||
        title.contains('counsel') ||
        tags.any((tag) =>
            tag.toLowerCase().contains('consultation') ||
            tag.toLowerCase().contains('咨询') ||
            tag.toLowerCase().contains('advice')) ||
        description.contains('consultation') ||
        description.contains('咨询');
  }

  /// 判断是否为预约类服务
  static bool _isAppointmentService(Service service) {
    final categoryId = service.categoryLevel1Id?.toString();

    // 明确的预约类服务分类
    final appointmentCategories = [
      '1020000', // 家政服务
      '1050000', // 教育培训
      '1060000', // 生活帮忙
      '1070000', // 美容美发
      '1080000', // 健康医疗
      '1090000', // 维修服务
    ];

    return appointmentCategories.contains(categoryId);
  }

  /// 根据分类获取默认预订类型
  static ServiceBookingType _getDefaultTypeByCategory(String? categoryId) {
    if (categoryId == null) return ServiceBookingType.directBooking;

    // 确保categoryId是字符串格式
    final categoryStr = categoryId.toString();

    switch (categoryStr) {
      case '1010000': // 美食天地
        return ServiceBookingType.cartOnly;

      case '1020000': // 家政服务
      case '1050000': // 教育培训
      case '1060000': // 生活帮忙
      case '1070000': // 美容美发
      case '1080000': // 健康医疗
      case '1090000': // 维修服务
        return ServiceBookingType.hybrid;

      case '1030000': // 交通出行
      case '1040000': // 配送服务
        return ServiceBookingType.directBooking;

      default:
        return ServiceBookingType.directBooking;
    }
  }

  /// 获取UI提示文本
  static String getBookingModeDescription(ServiceBookingType type) {
    return type.displayName;
  }

  /// 获取默认建议操作
  static String getRecommendedAction(ServiceBookingType type) {
    switch (type) {
      case ServiceBookingType.cartOnly:
        return '添加到购物车';
      case ServiceBookingType.directBooking:
        return '立即预订';
      case ServiceBookingType.hybrid:
        return '选择预订方式';
    }
  }

  /// 获取详细的预订说明
  static String getDetailedDescription(
      Service service, ServiceBookingType type) {
    final serviceType = _getServiceTypeDescription(service);

    switch (type) {
      case ServiceBookingType.directBooking:
        if (_isEmergencyService(service)) {
          return '这是紧急服务，建议立即预订以获得最快响应';
        } else if (_isConsultationService(service)) {
          return '咨询服务支持即时沟通，点击立即预订开始对话';
        } else {
          return '${serviceType}服务，支持快速预订，无需等待';
        }

      case ServiceBookingType.cartOnly:
        return '餐饮服务需要先选择具体菜品，请在Menu菜单中添加到购物车';

      case ServiceBookingType.hybrid:
        return '${serviceType}服务支持立即预订或加入购物车对比。立即预订可快速完成，购物车可对比多个服务';
    }
  }

  /// 获取服务类型描述
  static String _getServiceTypeDescription(Service service) {
    final categoryId = service.categoryLevel1Id?.toString();

    switch (categoryId) {
      case '1010000':
        return '餐饮';
      case '1020000':
        return '家政';
      case '1030000':
        return '交通';
      case '1040000':
        return '配送';
      case '1050000':
        return '教育';
      case '1060000':
        return '生活帮忙';
      case '1070000':
        return '美容美发';
      case '1080000':
        return '健康医疗';
      case '1090000':
        return '维修';
      default:
        return '通用';
    }
  }

  /// 获取预订按钮图标
  static String getBookingIcon(Service service, ServiceBookingType type) {
    if (_isEmergencyService(service)) {
      return 'emergency';
    } else if (_isConsultationService(service)) {
      return 'chat';
    } else if (type == ServiceBookingType.cartOnly) {
      return 'shopping_cart';
    } else {
      return 'event_available';
    }
  }

  /// 获取预订按钮标签
  static String getBookingLabel(Service service, ServiceBookingType type) {
    if (_isEmergencyService(service)) {
      return '紧急预订';
    } else if (_isConsultationService(service)) {
      return '立即咨询';
    } else if (type == ServiceBookingType.cartOnly) {
      return '选择菜品';
    } else {
      return '立即预订';
    }
  }

  /// 获取预订按钮颜色主题
  static String getBookingColorTheme(Service service) {
    if (_isEmergencyService(service)) {
      return 'red'; // 红色主题，表示紧急
    } else if (_isConsultationService(service)) {
      return 'green'; // 绿色主题，表示沟通
    } else if (_isRestaurantService(service)) {
      return 'orange'; // 橙色主题，表示美食
    } else {
      return 'blue'; // 蓝色主题，通用
    }
  }

  /// 获取购物车相关配置
  static CartConfig getCartConfig(Service service) {
    final bookingType = resolve(service);

    return CartConfig(
      isRequired: bookingType == ServiceBookingType.cartOnly,
      isSupported: bookingType.supportsCart,
      showFloatingButton: bookingType == ServiceBookingType.cartOnly,
      allowMultipleItems: _isRestaurantService(service),
      supportsCustomizations: _isRestaurantService(service),
      supportsScheduling: _isAppointmentService(service),
      expirationHours:
          _isRestaurantService(service) ? 2 : 24, // 餐饮购物车2小时过期，其他24小时
    );
  }

  /// 判断服务是否支持批量预订
  static bool supportsBatchBooking(Service service) {
    final bookingType = resolve(service);
    return bookingType.supportsCart && _isAppointmentService(service);
  }

  /// 获取推荐的预订时间窗口
  static Duration getRecommendedBookingWindow(Service service) {
    if (_isEmergencyService(service)) {
      return Duration(minutes: 30); // 紧急服务30分钟内
    } else if (_isConsultationService(service)) {
      return Duration(hours: 1); // 咨询服务1小时内
    } else if (_isRestaurantService(service)) {
      return Duration(hours: 2); // 餐饮服务2小时内
    } else {
      return Duration(days: 1); // 其他服务1天内
    }
  }
}

/// 购物车配置类
class CartConfig {
  final bool isRequired; // 是否必须使用购物车
  final bool isSupported; // 是否支持购物车
  final bool showFloatingButton; // 是否显示浮动购物车按钮
  final bool allowMultipleItems; // 是否允许多个商品
  final bool supportsCustomizations; // 是否支持定制选项
  final bool supportsScheduling; // 是否支持时间安排
  final int expirationHours; // 购物车过期时间（小时）

  const CartConfig({
    required this.isRequired,
    required this.isSupported,
    required this.showFloatingButton,
    required this.allowMultipleItems,
    required this.supportsCustomizations,
    required this.supportsScheduling,
    required this.expirationHours,
  });
}

/// 预订类型解析器扩展工具类
class BookingTypeUtils {
  /// 批量解析多个服务的预订类型
  static Map<String, ServiceBookingType> resolveMultiple(
      List<Service> services) {
    final result = <String, ServiceBookingType>{};

    for (final service in services) {
      if (service.id != null) {
        result[service.id!] = ServiceBookingTypeResolver.resolve(service);
      }
    }

    return result;
  }

  /// 获取预订类型统计
  static Map<ServiceBookingType, int> getTypeStatistics(
      List<Service> services) {
    final stats = <ServiceBookingType, int>{
      ServiceBookingType.directBooking: 0,
      ServiceBookingType.cartOnly: 0,
      ServiceBookingType.hybrid: 0,
    };

    for (final service in services) {
      final type = ServiceBookingTypeResolver.resolve(service);
      stats[type] = (stats[type] ?? 0) + 1;
    }

    return stats;
  }

  /// 过滤支持特定预订类型的服务
  static List<Service> filterByBookingType(
    List<Service> services,
    ServiceBookingType targetType,
  ) {
    return services.where((service) {
      final type = ServiceBookingTypeResolver.resolve(service);
      return type == targetType;
    }).toList();
  }

  /// 获取推荐的预订流程
  static List<String> getRecommendedFlow(Service service) {
    final type = ServiceBookingTypeResolver.resolve(service);

    switch (type) {
      case ServiceBookingType.directBooking:
        return [
          '查看服务详情',
          '确认价格和时间',
          '填写预约信息',
          '创建订单',
          '等待服务商确认',
        ];

      case ServiceBookingType.cartOnly:
        return [
          '浏览菜单分类',
          '选择具体菜品',
          '调整数量和定制',
          '添加到购物车',
          '确认订单信息',
          '选择配送方式',
          '完成支付',
        ];

      case ServiceBookingType.hybrid:
        return [
          '选择预订方式',
          '方式1: 立即预订 → 快速完成',
          '方式2: 购物车 → 对比选择',
          '填写相关信息',
          '创建订单',
        ];
    }
  }
}
