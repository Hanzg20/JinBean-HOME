import 'package:get/get.dart';
import '../models/base_models.dart';
import '../../features/customer/domain/entities/service.dart';

/// 智能路由引擎
/// 
/// 负责根据服务类型和用户上下文决定最佳的导航路径
class IntelligentRoutingEngine {
  /// 行业识别器
  static IndustryType identifyIndustry(String categoryId) {
    // 根据分类ID识别行业类型
    switch (categoryId) {
      case '1010000': // 美食天地
        return IndustryType.food;
      case '1020000': // 家居服务
        return IndustryType.home;
      case '1030000': // 出行交通
        return IndustryType.transport;
      case '1040000': // 租赁共享
        return IndustryType.rental;
      case '1050000': // 学习成长
        return IndustryType.learning;
      case '1060000': // 专业速帮
        return IndustryType.professional;
      default:
        // 如果无法识别，默认返回食品行业
        return IndustryType.food;
    }
  }

  /// 路由决策
  static RouteDecision makeRoutingDecision({
    required String categoryId,
    String? subCategoryId,
    Map<String, dynamic>? context,
    Map<String, dynamic>? userPreferences,
  }) {
    final industry = identifyIndustry(categoryId);
    
    return RouteDecision(
      targetRoute: _getTargetRoute(industry),
      industry: industry,
      parameters: {
        'categoryId': categoryId, // 使用原始的categoryId而不是subCategoryId
        'subCategoryId': subCategoryId,
        'initialFilters': context,
        'userPreferences': userPreferences,
      },
      shouldUseIntelligentRouting: true,
    );
  }

  /// 获取目标路由
  static String _getTargetRoute(IndustryType industry) {
    switch (industry) {
      case IndustryType.food:
        return '/food_order';
      case IndustryType.home:
        return '/home_service';
      case IndustryType.transport:
        return '/transport_booking';
      case IndustryType.rental:
        return '/rental_browse';
      case IndustryType.learning:
        return '/learning_hub';
      case IndustryType.professional:
        return '/professional_services';
    }
  }

  /// 检查路由是否可用
  static bool isRouteAvailable(String route) {
    // 检查路由是否已注册
    final availableRoutes = [
      '/food_order', // 已实现
      '/home_service', // 待实现
      '/transport_booking', // 待实现
      '/rental_browse', // 待实现
      '/learning_hub', // 待实现
      '/professional_services', // 待实现
    ];
    
    return availableRoutes.contains(route);
  }

  /// 获取备用路由（如果智能路由不可用）
  static String getFallbackRoute() {
    return '/service_detail'; // 默认的服务详情页
  }
}

/// 路由决策结果
class RouteDecision {
  final String targetRoute;
  final IndustryType industry;
  final Map<String, dynamic> parameters;
  final bool shouldUseIntelligentRouting;

  RouteDecision({
    required this.targetRoute,
    required this.industry,
    required this.parameters,
    required this.shouldUseIntelligentRouting,
  });

  @override
  String toString() {
    return 'RouteDecision(targetRoute: $targetRoute, industry: ${industry.displayName}, shouldUseIntelligentRouting: $shouldUseIntelligentRouting)';
  }
}

/// 导航上下文管理器
class ContextManager extends GetxService {
  static ContextManager get instance => Get.find<ContextManager>();

  final RxMap<String, dynamic> _currentContext = <String, dynamic>{}.obs;

  /// 保存导航上下文
  void saveNavigationContext({
    required String sourcePageId,
    Map<String, dynamic>? searchFilters,
    Map<String, dynamic>? userLocation,
    Map<String, dynamic>? userPreferences,
  }) {
    _currentContext.value = {
      'sourcePageId': sourcePageId,
      'searchFilters': searchFilters ?? {},
      'userLocation': userLocation ?? {},
      'userPreferences': userPreferences ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    print('🧭 导航上下文已保存: $sourcePageId');
  }

  /// 恢复导航上下文
  Map<String, dynamic>? restoreNavigationContext() {
    if (_currentContext.isEmpty) return null;
    
    final context = Map<String, dynamic>.from(_currentContext);
    print('🧭 导航上下文已恢复: ${context['sourcePageId']}');
    return context;
  }

  /// 清除导航上下文
  void clearNavigationContext() {
    _currentContext.clear();
    print('🧭 导航上下文已清除');
  }

  /// 获取当前上下文
  Map<String, dynamic> get currentContext => Map<String, dynamic>.from(_currentContext);

  /// 检查是否有上下文
  bool get hasContext => _currentContext.isNotEmpty;
}

/// 行业识别器
class IndustryIdentifier {
  /// 从分类ID识别行业
  static IndustryType identify(String categoryId) {
    return IntelligentRoutingEngine.identifyIndustry(categoryId);
  }

  /// 从服务对象识别行业
  static IndustryType identifyFromService(Service service) {
    if (service.categoryLevel1Id != null) {
      return identify(service.categoryLevel1Id.toString());
    }
    
    // 如果没有分类信息，尝试从其他字段推断
    final title = service.title.toString().toLowerCase();
    
    if (title.contains('food') || title.contains('restaurant') || title.contains('餐')) {
      return IndustryType.food;
    } else if (title.contains('clean') || title.contains('repair') || title.contains('家')) {
      return IndustryType.home;
    } else if (title.contains('transport') || title.contains('delivery') || title.contains('出行')) {
      return IndustryType.transport;
    } else if (title.contains('rental') || title.contains('share') || title.contains('租赁')) {
      return IndustryType.rental;
    } else if (title.contains('learn') || title.contains('education') || title.contains('学习')) {
      return IndustryType.learning;
    } else if (title.contains('professional') || title.contains('consulting') || title.contains('专业')) {
      return IndustryType.professional;
    }
    
    // 默认返回食品行业
    return IndustryType.food;
  }
}
