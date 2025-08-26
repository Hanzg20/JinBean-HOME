import 'package:flutter/material.dart';
import '../models/service.dart';
import '../models/service_detail.dart';

// 动态Tab配置服务
class DynamicTabConfigService {
  static final DynamicTabConfigService _instance = DynamicTabConfigService._internal();
  factory DynamicTabConfigService() => _instance;
  DynamicTabConfigService._internal();

  // 核心Tab配置（固定不变）
  static const List<Map<String, dynamic>> _coreTabs = [
    {
      'id': 'overview',
      'title': 'Overview',
      'title_zh': '概览',
      'icon': Icons.info_outline,
      'color': Colors.blue,
      'isFixed': true,
    },
    {
      'id': 'provider',
      'title': 'Provider',
      'title_zh': '服务商',
      'icon': Icons.person,
      'color': Colors.green,
      'isFixed': true,
    },
    {
      'id': 'reviews',
      'title': 'Reviews',
      'title_zh': '评价',
      'icon': Icons.star,
      'color': Colors.orange,
      'isFixed': true,
    },
    {
      'id': 'for_you',
      'title': 'For You',
      'title_zh': '为你推荐',
      'icon': Icons.favorite,
      'color': Colors.pink,
      'isFixed': true,
    },
  ];

  // 行业特定的Tab配置
  static const Map<String, List<Map<String, dynamic>>> _industryTabs = {
    'restaurant': [
      {
        'id': 'menu',
        'title': 'Menu',
        'title_zh': '菜单',
        'icon': Icons.restaurant_menu,
        'color': Colors.red,
        'category': 'restaurant',
      },
      {
        'id': 'nutrition',
        'title': 'Nutrition',
        'title_zh': '营养信息',
        'icon': Icons.monitor_heart,
        'color': Colors.green,
        'category': 'nutrition',
      },
      {
        'id': 'reservation',
        'title': 'Reservation',
        'title_zh': '预订',
        'icon': Icons.calendar_today,
        'color': Colors.blue,
        'category': 'reservation',
      },
    ],
    'cleaning': [
      {
        'id': 'services',
        'title': 'Services',
        'title_zh': '服务项目',
        'icon': Icons.cleaning_services,
        'color': Colors.blue,
        'category': 'cleaning',
      },
      {
        'id': 'schedule',
        'title': 'Schedule',
        'title_zh': '时间安排',
        'icon': Icons.schedule,
        'color': Colors.orange,
        'category': 'schedule',
      },
      {
        'id': 'equipment',
        'title': 'Equipment',
        'title_zh': '设备工具',
        'icon': Icons.build,
        'color': Colors.grey,
        'category': 'equipment',
      },
    ],
    'education': [
      {
        'id': 'curriculum',
        'title': 'Curriculum',
        'title_zh': '课程大纲',
        'icon': Icons.book,
        'color': Colors.indigo,
        'category': 'education',
      },
      {
        'id': 'certificates',
        'title': 'Certificates',
        'title_zh': '证书',
        'icon': Icons.verified,
        'color': Colors.green,
        'category': 'certificates',
      },
      {
        'id': 'prerequisites',
        'title': 'Prerequisites',
        'title_zh': '先修要求',
        'icon': Icons.checklist,
        'color': Colors.orange,
        'category': 'prerequisites',
      },
    ],
    'transportation': [
      {
        'id': 'routes',
        'title': 'Routes',
        'title_zh': '路线',
        'icon': Icons.route,
        'color': Colors.blue,
        'category': 'transportation',
      },
      {
        'id': 'vehicles',
        'title': 'Vehicles',
        'title_zh': '车辆信息',
        'icon': Icons.directions_car,
        'color': Colors.grey,
        'category': 'vehicles',
      },
      {
        'id': 'pricing',
        'title': 'Pricing',
        'title_zh': '价格详情',
        'icon': Icons.attach_money,
        'color': Colors.green,
        'category': 'pricing',
      },
    ],
    'beauty': [
      {
        'id': 'treatments',
        'title': 'Treatments',
        'title_zh': '护理项目',
        'icon': Icons.face,
        'color': Colors.pink,
        'category': 'beauty',
      },
      {
        'id': 'products',
        'title': 'Products',
        'title_zh': '产品',
        'icon': Icons.shopping_bag,
        'color': Colors.purple,
        'category': 'products',
      },
      {
        'id': 'appointments',
        'title': 'Appointments',
        'title_zh': '预约',
        'icon': Icons.calendar_month,
        'color': Colors.blue,
        'category': 'appointments',
      },
    ],
    'professional': [
      {
        'id': 'expertise',
        'title': 'Expertise',
        'title_zh': '专业领域',
        'icon': Icons.psychology,
        'color': Colors.indigo,
        'category': 'professional',
      },
      {
        'id': 'experience',
        'title': 'Experience',
        'title_zh': '经验',
        'icon': Icons.work_history,
        'color': Colors.orange,
        'category': 'experience',
      },
      {
        'id': 'consultation',
        'title': 'Consultation',
        'title_zh': '咨询',
        'icon': Icons.chat,
        'color': Colors.green,
        'category': 'consultation',
      },
    ],
  };

  /// 获取完整的Tab配置
  List<Map<String, dynamic>> getTabConfig(Service service, List<ServiceDetail> details) {
    try {
      print('DynamicTabConfigService: 生成Tab配置 - 服务: ${service.getLocalizedTitle('en')}');
      
      final List<Map<String, dynamic>> tabConfig = [];
      
      // 1. 添加核心Tab（固定不变）
      tabConfig.addAll(_coreTabs);
      
      // 2. 根据服务分类添加行业特定Tab
      final industryTabs = _getIndustryTabs(service);
      if (industryTabs.isNotEmpty) {
        // 替换"Details" tab（如果存在的话）
        _replaceDetailsTab(tabConfig, industryTabs);
      }
      
      // 3. 根据实际的服务详情动态调整
      final dynamicTabs = _generateDynamicTabs(details);
      if (dynamicTabs.isNotEmpty) {
        tabConfig.addAll(dynamicTabs);
      }
      
      print('DynamicTabConfigService: 生成完成，共 ${tabConfig.length} 个Tab ✅');
      return tabConfig;
      
    } catch (e) {
      print('DynamicTabConfigService: 生成Tab配置失败 ❌ - $e');
      // 返回默认配置
      return _getDefaultTabConfig();
    }
  }

  /// 获取行业特定Tab
  List<Map<String, dynamic>> _getIndustryTabs(Service service) {
    // 根据服务分类确定行业
    final categoryId = service.categoryId;
    final categoryLevel1Id = service.categoryLevel1Id;
    final categoryLevel2Id = service.categoryLevel2Id;
    
    // 简化的行业判断逻辑
    String industry = 'general';
    
    if (categoryId.contains('restaurant') || categoryId.contains('food')) {
      industry = 'restaurant';
    } else if (categoryId.contains('cleaning') || categoryId.contains('home')) {
      industry = 'cleaning';
    } else if (categoryId.contains('education') || categoryId.contains('learning')) {
      industry = 'education';
    } else if (categoryId.contains('transport') || categoryId.contains('car')) {
      industry = 'transportation';
    } else if (categoryId.contains('beauty') || categoryId.contains('salon')) {
      industry = 'beauty';
    } else if (categoryId.contains('professional') || categoryId.contains('consulting')) {
      industry = 'professional';
    }
    
    return _industryTabs[industry] ?? [];
  }

  /// 替换Details Tab
  void _replaceDetailsTab(List<Map<String, dynamic>> tabConfig, List<Map<String, dynamic>> industryTabs) {
    // 查找并替换Details tab
    final detailsIndex = tabConfig.indexWhere((tab) => tab['id'] == 'details');
    if (detailsIndex != -1) {
      // 移除Details tab
      tabConfig.removeAt(detailsIndex);
      
      // 在相同位置插入行业特定Tab
      for (int i = 0; i < industryTabs.length; i++) {
        final industryTab = Map<String, dynamic>.from(industryTabs[i]);
        industryTab['isDynamic'] = true;
        industryTab['isIndustrySpecific'] = true;
        
        tabConfig.insert(detailsIndex + i, industryTab);
      }
    }
  }

  /// 根据服务详情生成动态Tab
  List<Map<String, dynamic>> _generateDynamicTabs(List<ServiceDetail> details) {
    final List<Map<String, dynamic>> dynamicTabs = [];
    
    // 按category分组
    final grouped = <String, List<ServiceDetail>>{};
    for (final detail in details) {
      final category = detail.category;
      grouped.putIfAbsent(category, () => []).add(detail);
    }
    
    // 为每个category生成Tab
    for (final entry in grouped.entries) {
      final category = entry.key;
      final categoryDetails = entry.value;
      
      // 检查是否已经有对应的Tab
      if (!_hasTabForCategory(category)) {
        final dynamicTab = {
          'id': 'dynamic_$category',
          'title': _getCategoryTitle(category),
          'title_zh': _getCategoryTitleZh(category),
          'icon': _getCategoryIcon(category),
          'color': _getCategoryColor(category),
          'category': category,
          'isDynamic': true,
          'isGenerated': true,
          'details': categoryDetails,
        };
        
        dynamicTabs.add(dynamicTab);
      }
    }
    
    return dynamicTabs;
  }

  /// 检查是否已经有对应category的Tab
  bool _hasTabForCategory(String category) {
    // 检查核心Tab
    for (final tab in _coreTabs) {
      if (tab['id'] == category) return true;
    }
    
    // 检查行业特定Tab
    for (final industryTabs in _industryTabs.values) {
      for (final tab in industryTabs) {
        if (tab['category'] == category) return true;
      }
    }
    
    return false;
  }

  /// 获取默认Tab配置
  List<Map<String, dynamic>> _getDefaultTabConfig() {
    return [
      {
        'id': 'overview',
        'title': 'Overview',
        'title_zh': '概览',
        'icon': Icons.info_outline,
        'color': Colors.blue,
        'isFixed': true,
      },
      {
        'id': 'details',
        'title': 'Details',
        'title_zh': '详情',
        'icon': Icons.description,
        'color': Colors.grey,
        'isFixed': true,
      },
      {
        'id': 'provider',
        'title': 'Provider',
        'title_zh': '服务商',
        'icon': Icons.person,
        'color': Colors.green,
        'isFixed': true,
      },
      {
        'id': 'reviews',
        'title': 'Reviews',
        'title_zh': '评价',
        'icon': Icons.star,
        'color': Colors.orange,
        'isFixed': true,
      },
      {
        'id': 'for_you',
        'title': 'For You',
        'title_zh': '为你推荐',
        'icon': Icons.favorite,
        'color': Colors.pink,
        'isFixed': true,
      },
    ];
  }

  /// 获取分类标题（英文）
  String _getCategoryTitle(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return 'Restaurant';
      case 'cleaning':
        return 'Cleaning';
      case 'education':
        return 'Education';
      case 'transportation':
        return 'Transportation';
      case 'beauty':
        return 'Beauty';
      case 'professional':
        return 'Professional';
      default:
        return category.substring(0, 1).toUpperCase() + category.substring(1);
    }
  }

  /// 获取分类标题（中文）
  String _getCategoryTitleZh(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return '餐厅';
      case 'cleaning':
        return '清洁';
      case 'education':
        return '教育';
      case 'transportation':
        return '交通';
      case 'beauty':
        return '美容';
      case 'professional':
        return '专业服务';
      default:
        return category;
    }
  }

  /// 获取分类图标
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'education':
        return Icons.school;
      case 'transportation':
        return Icons.directions_car;
      case 'beauty':
        return Icons.face;
      case 'professional':
        return Icons.work;
      default:
        return Icons.category;
    }
  }

  /// 获取分类颜色
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return Colors.orange;
      case 'cleaning':
        return Colors.blue;
      case 'education':
        return Colors.green;
      case 'transportation':
        return Colors.purple;
      case 'beauty':
        return Colors.pink;
      case 'professional':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  /// 获取Tab内容构建器
  Widget Function(BuildContext, int) getTabContentBuilder(Service service, List<ServiceDetail> details) {
    return (context, index) {
      final tabConfig = getTabConfig(service, details);
      if (index >= tabConfig.length) {
        return Center(child: Text('Tab不存在'));
      }
      
      final tab = tabConfig[index];
      final tabId = tab['id'] as String;
      
      // 根据Tab ID构建内容
      switch (tabId) {
        case 'overview':
          return _buildOverviewTab(context, service);
        case 'provider':
          return _buildProviderTab(context, service);
        case 'reviews':
          return _buildReviewsTab(context, service);
        case 'for_you':
          return _buildForYouTab(context, service);
        default:
          // 动态Tab内容
          if (tab['isDynamic'] == true) {
            return _buildDynamicTab(context, tab, details);
          } else {
            return Center(child: Text('内容开发中...'));
          }
      }
    };
  }

  /// 构建概览Tab
  Widget _buildOverviewTab(BuildContext context, Service service) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '服务概览',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                                     Text(
                     service.getLocalizedTitle('en'),
                     style: Theme.of(context).textTheme.titleLarge,
                   ),
                   SizedBox(height: 8),
                   Text(
                     service.getLocalizedDescription('en'),
                     style: Theme.of(context).textTheme.bodyMedium,
                   ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 20),
                      SizedBox(width: 4),
                      Text(service.ratingDisplay),
                      SizedBox(width: 16),
                      Icon(Icons.attach_money, color: Colors.green, size: 20),
                      SizedBox(width: 4),
                      Text(service.priceDisplay),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建服务商Tab
  Widget _buildProviderTab(BuildContext context, Service service) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '服务商信息',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text('服务商ID: ${service.providerId}'),
          Text('开发中...'),
        ],
      ),
    );
  }

  /// 构建评价Tab
  Widget _buildReviewsTab(BuildContext context, Service service) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            '用户评价',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text('评分: ${service.ratingDisplay}'),
          Text('评价数: ${service.reviewCount}'),
          Text('开发中...'),
        ],
      ),
    );
  }

  /// 构建为你推荐Tab
  Widget _buildForYouTab(BuildContext context, Service service) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite, size: 64, color: Colors.pink),
          SizedBox(height: 16),
          Text(
            '为你推荐',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text('基于你的偏好'),
          Text('开发中...'),
        ],
      ),
    );
  }

  /// 构建动态Tab
  Widget _buildDynamicTab(BuildContext context, Map<String, dynamic> tab, List<ServiceDetail> details) {
    final category = tab['category'] as String;
    final categoryDetails = details.where((d) => d.category == category).toList();
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tab['title'] ?? category,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
          if (categoryDetails.isEmpty)
            Center(
              child: Text('暂无数据'),
            )
          else
            ...categoryDetails.map((detail) => Card(
              margin: EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                                         Text(
                       detail.getLocalizedName('en'),
                       style: Theme.of(context).textTheme.titleLarge,
                     ),
                    if (detail.subCategory != null) ...[
                      SizedBox(height: 8),
                                             Text(
                         '子分类: ${detail.subCategory}',
                         style: Theme.of(context).textTheme.bodySmall,
                       ),
                    ],
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          detail.isAvailable ? Icons.check_circle : Icons.cancel,
                          color: detail.isAvailable ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(detail.stockStatus),
                        if (detail.price != null) ...[
                          Spacer(),
                                                     Text(
                             detail.priceDisplay,
                             style: Theme.of(context).textTheme.titleMedium?.copyWith(
                               color: Colors.green,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            )),
        ],
      ),
    );
  }
}
