import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/customer/domain/entities/service.dart';
import '../../features/customer/domain/entities/service_detail.dart';
import '../controllers/unified_cart_controller.dart';
import '../utils/app_logger.dart';
import 'local_data_manager.dart';
import '../../features/customer/services/presentation/service_detail_controller.dart';
import '../../features/customer/services/presentation/sections/service_reviews_section.dart';

/// 动态Tab配置服务
/// 根据服务类型和详情数据动态生成Tab配置
class DynamicTabConfigService {
  static final DynamicTabConfigService _instance =
      DynamicTabConfigService._internal();
  factory DynamicTabConfigService() => _instance;
  DynamicTabConfigService._internal();

  // 当前服务引用
  Service? _currentService;

  /// 获取Tab配置
  List<Map<String, dynamic>> getTabConfig(
      Service service, List<ServiceDetail> details) {
    // 更新当前服务引用
    _currentService = service;

    print('🚨 [DynamicTabConfig] getTabConfig CALLED - Service: ${service.title}, ID: ${service.id}');
    print('🚨 [DynamicTabConfig] categoryLevel1Id: ${service.categoryLevel1Id}, Details: ${details.length}');

    // 基础Tab配置
    final List<Map<String, dynamic>> tabs = [];

    // 1. 添加Overview Tab（固定第一位，信息性）
    tabs.add({
      'id': 'overview',
      'title': 'Overview',
      'title_zh': '概览',
      'icon': Icons.info_outline,
      'color': Colors.blue, // 蓝色调表示信息性
      'isDynamic': false,
      'isIndustrySpecific': false,
      'description': '查看服务基本信息',
      'isOperational': false, // 标记为信息性Tab
    });

    // 2. 添加动态Tab（如Menu，插入第二位）
    final dynamicTabs = _generateDynamicTabs(details);
    tabs.addAll(dynamicTabs);

    // 3. 添加其余固定Tab
    tabs.addAll([
      {
        'id': 'provider',
        'title': 'Provider',
        'title_zh': '服务商',
        'icon': Icons.person,
        'color': Colors.green,
        'isDynamic': false,
        'isIndustrySpecific': false,
      },
      {
        'id': 'reviews',
        'title': 'Reviews',
        'title_zh': '评价',
        'icon': Icons.star,
        'color': Colors.orange,
        'isDynamic': false,
        'isIndustrySpecific': false,
      },
      {
        'id': 'for_you',
        'title': 'For You',
        'title_zh': '推荐',
        'icon': Icons.favorite,
        'color': Colors.pink,
        'isDynamic': false,
        'isIndustrySpecific': false,
      },
    ]);

    // print('📋 最终Tab配置: ${tabs.length} 个Tab');
    for (int i = 0; i < tabs.length; i++) {
      final tab = tabs[i];
      // print('  Tab $i: ${tab['id']} - ${tab['title']} (${tab['isDynamic'] ? '动态' : '固定'})');
    }

    return tabs;
  }

  /// 生成动态Tab配置
  List<Map<String, dynamic>> _generateDynamicTabs(
      List<ServiceDetail> details) {
    final List<Map<String, dynamic>> dynamicTabs = [];

    print('🔧 [DynamicTabConfig] _generateDynamicTabs: 开始生成，详情数量: ${details.length}');
    print('🔧 [DynamicTabConfig] Service categoryLevel1Id: ${_currentService?.categoryLevel1Id}');
    if (details.isNotEmpty) {
      print('🔧 [DynamicTabConfig] First detail category: ${details.first.category}');
    }

    // 检查是否应该显示Menu Tab
    bool shouldShowMenu = _shouldShowMenuTab();
    print('🔧 [DynamicTabConfig] shouldShowMenu: $shouldShowMenu');

    if (shouldShowMenu) {
      // 如果应该显示Menu，创建一个强化的Menu Tab
      print('✅ [DynamicTabConfig] 生成强化Menu Tab (Food服务)');
      dynamicTabs.add({
        'id': 'menu',
        'title': '🍽️ Menu',
        'title_zh': '🍽️ 菜单',
        'icon': Icons.restaurant_menu,
        'color': Colors.green, // 绿色调表示操作性
        'category': 'all_menu_items', // 使用通用分类
        'isDynamic': true,
        'isIndustrySpecific': true,
        'itemCount': details.length,
        'description': '选择菜品并加入购物车',
        'isOperational': true, // 标记为操作性Tab
      });
    } else {
      // 如果不显示Menu，按category分组生成其他动态Tab
      print('✅ [DynamicTabConfig] 生成非Food服务的Tab');
      if (details.isNotEmpty) {
        final grouped = <String, List<ServiceDetail>>{};
        for (final detail in details) {
          final category = detail.category;
          grouped.putIfAbsent(category, () => []).add(detail);
        }

        print('📋 [DynamicTabConfig] Category分组结果: ${grouped.keys.toList()}');

        for (final entry in grouped.entries) {
          final category = entry.key;
          final categoryDetails = entry.value;
          final title = _getCategoryTitle(category);
          final icon = _getCategoryIcon(category);

          print('📌 [DynamicTabConfig] 创建Tab - category: $category, title: $title, itemCount: ${categoryDetails.length}');

          dynamicTabs.add({
            'id': 'menu_$category',
            'title': title,
            'title_zh': _getCategoryTitleZh(category),
            'icon': icon,
            'color': _getCategoryColor(category),
            'category': category,
            'isDynamic': true,
            'isIndustrySpecific': true,
            'itemCount': categoryDetails.length,
          });
        }
      }
    }

    print('✅ [DynamicTabConfig] 生成完成，共 ${dynamicTabs.length} 个动态Tab');
    for (var tab in dynamicTabs) {
      print('  - ${tab['title']} (id: ${tab['id']}, category: ${tab['category']})');
    }
    return dynamicTabs;
  }

  /// 判断是否应该显示Menu Tab
  bool _shouldShowMenuTab() {
    // 检查当前服务是否属于餐饮相关的大类
    // 餐饮相关的一级分类ID: 1010000 (美食天地)
    if (_currentService != null) {
      final categoryId = _currentService!.categoryLevel1Id;
      print('🔍 [DynamicTabConfig] _shouldShowMenuTab - categoryLevel1Id: $categoryId');

      // 如果是一级分类1010000 (美食天地)，就显示Menu
      if (categoryId == '1010000') {
        print('✅ [DynamicTabConfig] 服务属于美食天地大类 (1010000)，显示Menu Tab');
        return true;
      } else {
        print('❌ [DynamicTabConfig] 服务不属于美食天地大类，categoryId=$categoryId');
      }
    } else {
      print('⚠️  [DynamicTabConfig] _currentService is null!');
    }

    return false;
  }

  /// 获取Tab内容构建器
  Widget Function(BuildContext, int) getTabContentBuilder(
      Service service, List<ServiceDetail> details) {
    return (context, index) {
      // print('🔧 getTabContentBuilder: 构建Tab $index，详情数量: ${details.length}');

      final tabConfig = getTabConfig(service, details);
      if (index >= tabConfig.length) {
        // print('❌ Tab索引超出范围: $index >= ${tabConfig.length}');
        return Center(child: Text('Tab不存在'));
      }

      final tab = tabConfig[index];
      final tabId = tab['id']?.toString() ?? 'unknown';
      final tabCategory = tab['category']?.toString() ?? 'unknown';

      // print('📋 Tab $index: ID=$tabId, Category=$tabCategory, isDynamic=${tab['isDynamic']}');

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
            // print('🎭 构建动态Tab: $tabId, 分类: $tabCategory');
            return _buildDynamicTab(context, tab, details);
          } else {
            // print('⚠️ 未知Tab类型: $tabId');
            return Center(child: Text('内容开发中...'));
          }
      }
    };
  }

  /// 构建动态Tab
  Widget _buildDynamicTab(BuildContext context, Map<String, dynamic> tab,
      List<ServiceDetail> details) {
    final category = tab['category']?.toString() ?? 'unknown';
    List<ServiceDetail> categoryDetails;

    // print('🎯 _buildDynamicTab: 开始构建，分类: $category，总详情数量: ${details.length}');

    if (category == 'all_menu_items') {
      // 如果是通用菜单Tab，显示所有详情数据
      categoryDetails = details;
      // print('✅ 通用菜单Tab，显示所有 ${details.length} 项数据');
    } else {
      // 按category过滤
      categoryDetails =
          details.where((d) => d.category == category).toList();
      // print('🔍 分类Tab $category，过滤后显示 ${categoryDetails.length} 项数据');

      // 打印所有详情的分类信息
      // print('📊 所有详情的分类: ${details.map((d) => d.category).toList()}');
    }

    // print('🎨 准备构建UI，categoryDetails数量: ${categoryDetails.length}');

    // 判断数据是否为真实数据（通过检查ID是否包含'test_'前缀）
    final isRealData = categoryDetails.isNotEmpty &&
        !categoryDetails.any((d) => d.id.contains('test_'));

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 数据源指示器
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isRealData ? Colors.green[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isRealData ? Colors.green[200]! : Colors.orange[200]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isRealData ? Icons.check_circle : Icons.sim_card,
                  color: isRealData ? Colors.green[600] : Colors.orange[600],
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isRealData
                      ? '🟢 真实数据 (${categoryDetails.length} 项)'
                      : '🟠 模拟数据 (${categoryDetails.length} 项)',
                  style: TextStyle(
                    color: isRealData ? Colors.green[700] : Colors.orange[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                if (isRealData) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 标题和统计信息
          Row(
            children: [
              Expanded(
                child: Text(
                  tab['title']?.toString() ?? category,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1), // 绿色操作主题
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${categoryDetails.length} 项服务',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),

          // Menu Tab 操作提示（仅对Menu Tab显示）
          if (tab['id'] == 'menu') ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    color: Colors.green[600],
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '💡 选择菜品并加入购物车，点击下方绿色按钮即可添加',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 16),

          if (categoryDetails.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    '暂无服务项目',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '该分类下暂时没有可用的服务',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                  SizedBox(height: 16),
                  // 添加调试信息
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '调试信息',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        SizedBox(height: 4),
                        Text('分类: $category', style: TextStyle(fontSize: 10)),
                        Text('总详情数: ${details.length}',
                            style: TextStyle(fontSize: 10)),
                        Text(
                            '详情分类: ${details.map((d) => d.category ?? 'unknown').toList()}',
                            style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            ...categoryDetails.map(
                (detail) => _buildEnhancedServiceDetailCard(context, detail)),
        ],
      ),
    );
  }

  /// 构建增强的服务详情卡片
  Widget _buildEnhancedServiceDetailCard(
      BuildContext context, ServiceDetail detail) {
    return GestureDetector(
      onTap: () {
        _showServiceDetailModal(context, detail);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区域
            if (detail.images != null && detail.images!.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    detail.images!.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.image,
                            size: 48, color: Colors.grey[400]),
                      );
                    },
                  ),
                ),
              ),

            // 内容区域
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题和价格
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          detail.name?['zh'] ?? detail.name?['en'] ?? '未知服务',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '¥${detail.price?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 分类和状态
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Text(
                          detail.category ?? '未分类',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: detail.isAvailable == true
                              ? Colors.green[50]
                              : Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: detail.isAvailable == true
                                ? Colors.green[200]!
                                : Colors.red[200]!,
                          ),
                        ),
                        child: Text(
                          detail.isAvailable == true ? '可用' : '不可用',
                          style: TextStyle(
                            color: detail.isAvailable == true
                                ? Colors.green[700]
                                : Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 库存信息（如果有）
                  if (detail.maxStock != null && detail.maxStock! > 0)
                    Row(
                      children: [
                        Icon(Icons.inventory,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '库存: ${detail.currentStock ?? 0}/${detail.maxStock}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: 实现预订功能
                          },
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: const Text('立即预订'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: detail.isAvailable == true
                              ? () => _addToCartFromMenu(context, detail)
                              : null,
                          icon: const Icon(Icons.add_shopping_cart, size: 16),
                          label: Text(
                              detail.isAvailable == true ? '加入购物车' : '暂不可用'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: detail.isAvailable == true
                                ? Colors.green
                                : Colors.grey.shade300,
                            foregroundColor: detail.isAvailable == true
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建概览Tab
  Widget _buildOverviewTab(BuildContext context, Service service) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 服务标题和评分
          _buildServiceHeader(context, service),
          const SizedBox(height: 20),

          // 价格信息
          _buildPriceSection(context, service),
          const SizedBox(height: 20),

          // 服务描述
          _buildDescriptionSection(context, service),
          const SizedBox(height: 20),

          // 服务特色和标签
          _buildFeaturesSection(context, service),
          const SizedBox(height: 20),

          // 服务详情
          _buildServiceDetails(context, service),
          const SizedBox(height: 20),

          // 操作按钮
          _buildActionButtons(context, service),
        ],
      ),
    );
  }

  Widget _buildServiceHeader(
      BuildContext context, Service service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 服务标题
        Text(
          service.title.isNotEmpty
              ? service.title
              : '服务详情',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
        ),
        const SizedBox(height: 8),

        // 评分和评价数
        Row(
          children: [
            // 星级评分
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < (service.rating ?? 0).floor()
                      ? Icons.star
                      : index < (service.rating ?? 0)
                          ? Icons.star_half
                          : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            const SizedBox(width: 8),
            Text(
              '${service.rating?.toStringAsFixed(1) ?? '0.0'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${service.reviewCount ?? 0} 评价)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context, Service service) {
    // 检查是否为真实数据
    final isRealData = _isPriceDataReal(service);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '价格信息',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isRealData ? Colors.green[100] : Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isRealData ? '🟢 真实数据' : '🟠 模拟数据',
                  style: TextStyle(
                    fontSize: 10,
                    color: isRealData ? Colors.green[700] : Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.attach_money,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '起价：',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                _getServiceStartingPrice(service),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getPriceDescription(service),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(
      BuildContext context, Service service) {
    final description = service.description.isNotEmpty
        ? service.description
        : '暂无描述';

    // 检查是否为真实数据
    final isRealData = _isRealDataHelper(service.id ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '服务介绍',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isRealData ? Colors.green[100] : Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isRealData ? '🟢 真实数据' : '🟠 模拟数据',
                style: TextStyle(
                  fontSize: 10,
                  color: isRealData ? Colors.green[700] : Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(
      BuildContext context, Service service) {
    // 根据服务类型生成特色标签
    final features = _getServiceFeatures(service);

    if (features.isEmpty) return const SizedBox.shrink();

    // 检查是否为真实数据
    final isRealData = _isFeaturesDataReal(service);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '服务特色',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isRealData ? Colors.green[100] : Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isRealData ? '🟢 真实数据' : '🟠 模拟数据',
                style: TextStyle(
                  fontSize: 10,
                  color: isRealData ? Colors.green[700] : Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: features.map((feature) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                ),
              ),
              child: Text(
                feature,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildServiceDetails(
      BuildContext context, Service service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '服务详情',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _buildDetailItem(context, '服务状态', _getServiceStatus(service.status),
            Icons.info_outline),
        _buildDetailItem(context, '服务区域', _getServiceArea(service),
            Icons.location_on_outlined),
        _buildDetailItem(context, '更新时间', _formatDate(service.updatedAt),
            Icons.update_outlined),
      ],
    );
  }

  Widget _buildDetailItem(
      BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Text(
            '$label：',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, Service service) {
    return Column(
      children: [
        // 主要操作按钮
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: 实现预约功能
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('立即预约'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: 实现咨询功能
                },
                icon: const Icon(Icons.chat_outlined),
                label: const Text('在线咨询'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 次要操作按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildIconButton(
              context,
              icon: Icons.favorite_outline,
              label: '收藏',
              onTap: () {
                // TODO: 实现收藏功能
              },
            ),
            _buildIconButton(
              context,
              icon: Icons.share_outlined,
              label: '分享',
              onTap: () {
                // TODO: 实现分享功能
              },
            ),
            _buildIconButton(
              context,
              icon: Icons.report_outlined,
              label: '举报',
              onTap: () {
                // TODO: 实现举报功能
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // 辅助方法
  List<String> _getServiceFeatures(Service service) {
    return _getRealServiceFeatures(service);
  }

  /// 检查服务特色数据是否为真实数据
  bool _isFeaturesDataReal(Service service) {
    // 如果service有真实的tags，则认为是真实数据
    return service.tags != null && service.tags!.isNotEmpty;
  }

  String _getServiceStatus(String? status) {
    switch (status) {
      case 'active':
        return '正常服务';
      case 'inactive':
        return '暂停服务';
      case 'pending':
        return '待审核';
      default:
        return '未知状态';
    }
  }

  String _getServiceArea(Service service) {
    if (service.latitude != null && service.longitude != null) {
      return '渥太华及周边地区';
    }
    return '全市范围';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '未知';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 构建服务商Tab
  Widget _buildProviderTab(BuildContext context, Service service) {
    // 如果有providerId，尝试获取真实数据
    if (service.providerId != null && service.providerId!.isNotEmpty) {
      return FutureBuilder<Map<String, dynamic>?>(
        future: _getProviderDataAsync(service.providerId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在获取服务商信息...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text('获取服务商信息失败: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // 触发重新构建
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          return _buildProviderContent(context, service, snapshot.data);
        },
      );
    }

    // 没有providerId，显示mock数据
    return _buildProviderContent(context, service, null);
  }

  Widget _buildProviderContent(BuildContext context,
      Service service, Map<String, dynamic>? providerData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 服务商基本信息
          _buildProviderHeader(context, service, providerData),
          const SizedBox(height: 20),

          // 认证信息
          _buildProviderCertifications(context, service, providerData),
          const SizedBox(height: 20),

          // 服务统计
          _buildProviderStats(context, service, providerData),
          const SizedBox(height: 20),

          // 联系方式
          _buildProviderContact(context, service, providerData),
        ],
      ),
    );
  }

  /// 构建评价Tab
  Widget _buildReviewsTab(BuildContext context, Service service) {
    // 使用真正的Reviews功能
    return ServiceReviewsSection(controller: Get.find<ServiceDetailController>());
  }

  /// 构建推荐Tab
  Widget _buildForYouTab(BuildContext context, Service service) {
    // 检查是否为真实数据
    final isRealData = _isRealDataHelper(service.id ?? '');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 数据源标识
          Row(
            children: [
              Text(
                '为您推荐',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isRealData ? Colors.green[100] : Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isRealData ? '🟢 真实数据' : '🟠 模拟数据',
                  style: TextStyle(
                    fontSize: 10,
                    color: isRealData ? Colors.green[700] : Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.recommend_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '推荐服务开发中...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '即将为您推荐相关优质服务',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 辅助方法
  String _getCategoryTitle(String category) {
    switch (category) {
      // Food subcategories
      case 'chinese':
        return 'Chinese Cuisine';
      case 'japanese':
        return 'Japanese Cuisine';
      case 'western':
        return 'Western Cuisine';
      case 'menu_item':
        return 'Menu';

      // Home Services
      case 'service_package':
        return 'Services';

      // Rental
      case 'rental_item':
        return 'Inventory';

      // Education
      case 'course':
        return 'Courses';

      // Health & Beauty
      case 'treatment':
        return 'Treatments';

      default:
        return category;
    }
  }

  String _getCategoryTitleZh(String category) {
    switch (category) {
      // Food subcategories
      case 'chinese':
        return '中餐';
      case 'japanese':
        return '日料';
      case 'western':
        return '西餐';
      case 'menu_item':
        return '菜单';

      // Home Services
      case 'service_package':
        return '服务项目';

      // Rental
      case 'rental_item':
        return '库存';

      // Education
      case 'course':
        return '课程';

      // Health & Beauty
      case 'treatment':
        return '疗程';

      default:
        return category;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      // Food subcategories
      case 'chinese':
        return Icons.restaurant;
      case 'japanese':
        return Icons.set_meal;
      case 'western':
        return Icons.local_dining;
      case 'menu_item':
        return Icons.restaurant_menu;

      // Home Services
      case 'service_package':
        return Icons.cleaning_services;

      // Rental
      case 'rental_item':
        return Icons.inventory;

      // Education
      case 'course':
        return Icons.school;

      // Health & Beauty
      case 'treatment':
        return Icons.medical_services;

      default:
        return Icons.fastfood;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      // Food subcategories
      case 'chinese':
        return Colors.red;
      case 'japanese':
        return Colors.orange;
      case 'western':
        return Colors.blue;
      case 'menu_item':
        return Colors.green;

      // Home Services
      case 'service_package':
        return Colors.teal;

      // Rental
      case 'rental_item':
        return Colors.purple;

      // Education
      case 'course':
        return Colors.indigo;

      // Health & Beauty
      case 'treatment':
        return Colors.pink;

      default:
        return Colors.grey;
    }
  }

  // Provider Tab 辅助方法
  Widget _buildProviderHeader(BuildContext context, Service service,
      [Map<String, dynamic>? providerData]) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 数据源标识
          Row(
            children: [
              Text(
                '服务商信息',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: providerData != null
                      ? Colors.green[100]
                      : Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  providerData != null ? '🟢 真实数据' : '🟠 模拟数据',
                  style: TextStyle(
                    fontSize: 10,
                    color: providerData != null
                        ? Colors.green[700]
                        : Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.store,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      providerData != null
                          ? _getDisplayName(providerData, service.providerId)
                          : _getProviderName(service),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '专业服务商',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '已认证',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            providerData != null
                ? _getBioDescription(providerData)
                : _getProviderDescription(service),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCertifications(
      BuildContext context, Service service,
      [Map<String, dynamic>? providerData]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '认证信息',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            children: [
              _buildCertificationItem(
                  context, '身份认证', '已通过', Icons.person_outline, true),
              _buildCertificationItem(
                  context, '资质认证', '已通过', Icons.verified_outlined, true),
              _buildCertificationItem(
                  context, '保险保障', '已投保', Icons.security_outlined, true),
              _buildCertificationItem(
                  context, '背景调查', '已完成', Icons.fact_check_outlined, true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCertificationItem(BuildContext context, String title,
      String status, IconData icon, bool isVerified) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isVerified ? Colors.green : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isVerified ? Colors.green : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isVerified ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderStats(BuildContext context, Service service,
      [Map<String, dynamic>? providerData]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '服务统计',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.star,
                title: '综合评分',
                value: providerData != null
                    ? '${(providerData['rating'] as num?)?.toStringAsFixed(1) ?? '暂无'}'
                    : '${service.rating?.toStringAsFixed(1) ?? '4.8'} (估算)',
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.people,
                title: '服务人次',
                value: providerData != null
                    ? '真实数据'
                    : '${(service.reviewCount ?? 0) * 3}+ (估算)',
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProviderContact(
      BuildContext context, Service service,
      [Map<String, dynamic>? providerData]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '联系方式',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildContactItem(context, Icons.phone, '电话咨询', '点击拨打', () {}),
              _buildContactItem(context, Icons.message, '在线消息', '立即咨询', () {}),
              _buildContactItem(
                  context, Icons.location_on, '服务区域', '渥太华及周边', null),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(BuildContext context, IconData icon, String label,
      String value, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: onTap != null
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: onTap != null
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[600],
                    fontWeight:
                        onTap != null ? FontWeight.w500 : FontWeight.normal,
                  ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getProviderName(Service service) {
    // 如果有providerId，尝试获取真实数据（这里需要异步调用，暂时显示ID）
    if (service.providerId != null && service.providerId!.isNotEmpty) {
      return 'Provider #${service.providerId!.substring(0, 8)}...';
    }

    // 默认mock数据
    if (service.categoryLevel1Id == '1010000') {
      return '美食专家工作室 (Mock)';
    } else if (service.categoryLevel1Id == '1020000') {
      return '专业家政服务中心 (Mock)';
    } else {
      return '专业服务提供商 (Mock)';
    }
  }

  String _getProviderDescription(Service service) {
    // 如果有providerId，显示加载提示
    if (service.providerId != null && service.providerId!.isNotEmpty) {
      return '正在加载服务商信息... Provider ID: ${service.providerId}';
    }

    // 默认mock数据
    if (service.categoryLevel1Id == '1010000') {
      return '[Mock数据] 专注于提供高品质美食服务，拥有专业厨师团队和丰富经验，致力于为客户提供美味健康的餐饮体验。';
    } else if (service.categoryLevel1Id == '1020000') {
      return '[Mock数据] 专业家政服务团队，提供保洁、维修、保养等全方位家庭服务，让您的生活更加舒适便捷。';
    } else {
      return '[Mock数据] 经验丰富的专业服务团队，致力于为客户提供优质、可靠的服务体验。';
    }
  }

  // Provider数据缓存 - 全局缓存机制
  static final Map<String, Map<String, dynamic>?> _providerCache = {};
  static final Map<String, DateTime> _providerCacheTimestamps = {};
  static const Duration _providerCacheExpiry = Duration(minutes: 10);

  // 全局Provider查询锁，防止重复查询
  static final Map<String, Future<Map<String, dynamic>?>> _providerQueryLocks = {};

  /// 异步获取Provider数据 - 本地优先，0ms响应
  Future<Map<String, dynamic>?> _getProviderDataAsync(String providerId) async {
    try {
      AppLogger.info('🔍 DynamicTabConfigService调用本地Provider查询: $providerId');
      
      // 首先尝试从本地数据管理器获取
      final providerProfile = LocalDataManager.getProvider(providerId);
      
      if (providerProfile == null) {
        AppLogger.warning('⚠️ 本地Provider数据未找到: $providerId');
        return null;
      }

      // 转换为Map格式以兼容现有代码
      final providerData = {
        'id': providerProfile.id,
        'display_name': providerProfile.name,
        'bio': providerProfile.description,
        'avatar_url': providerProfile.avatar,
        'phone': providerProfile.phone,
        'email': providerProfile.email,
        'rating': providerProfile.rating,
        'review_count': providerProfile.reviewCount,
        'certification_status': providerProfile.isVerified ? 'verified' : 'pending',
        'is_certified': providerProfile.isVerified,
        'experience_years': providerProfile.metadata?['experience_years'] ?? 0,
        'tags': providerProfile.metadata?['tags'] ?? [],
        'provider_type': providerProfile.metadata?['provider_type'] ?? 'individual',
        'created_at': providerProfile.createdAt?.toIso8601String(),
      };

      AppLogger.info('✅ DynamicTabConfigService本地Provider数据命中: $providerId (0ms)');
      return providerData;

    } catch (e) {
      AppLogger.error('❌ DynamicTabConfigService获取Provider失败: $providerId - $e');
      return null;
    }
  }

  /// 检查Provider数据是否为真实数据
  bool _isProviderDataReal(Service service) {
    // 如果service有真实的providerId，我们应该从数据库获取provider信息
    // 目前没有实现，所以返回false
    // TODO: 实现从provider_profiles表获取数据
    return false;
  }

  /// 从jsonb字段获取显示名称
  String _getDisplayName(
      Map<String, dynamic> providerData, String? providerId) {
    final displayName = providerData['display_name'];

    if (displayName != null) {
      if (displayName is Map) {
        // jsonb格式，尝试获取中文或英文
        final nameMap = displayName as Map<String, dynamic>;
        return nameMap['zh'] ??
            nameMap['en'] ??
            nameMap.values.first?.toString() ??
            'Unknown Provider';
      } else if (displayName is String && displayName.isNotEmpty) {
        return displayName;
      }
    }

    // 回退到Provider ID显示
    return 'Provider ${providerId?.substring(0, 8) ?? 'Unknown'}';
  }

  /// 从jsonb字段获取描述信息
  String _getBioDescription(Map<String, dynamic> providerData) {
    final bio = providerData['bio'];

    if (bio != null) {
      if (bio is Map) {
        // jsonb格式，尝试获取中文或英文
        final bioMap = bio as Map<String, dynamic>;
        return bioMap['zh'] ??
            bioMap['en'] ??
            bioMap.values.first?.toString() ??
            '暂无服务商描述';
      } else if (bio is String && bio.isNotEmpty) {
        return bio;
      }
    }

    // 生成基于Provider类型的描述
    final providerType = providerData['provider_type'] ?? 'individual';
    final certificationStatus =
        providerData['certification_status'] ?? 'pending';
    final experienceYears = providerData['experience_years'] ?? 0;

    String description = '';
    if (providerType == 'corporate') {
      description = '企业级服务提供商';
    } else {
      description = '个人服务提供商';
    }

    if (experienceYears > 0) {
      description += '，拥有${experienceYears}年从业经验';
    }

    if (certificationStatus == 'verified') {
      description += '，已通过平台认证';
    }

    return description.isNotEmpty ? description : '暂无服务商描述';
  }

  /// 获取真实的服务特色标签
  List<String> _getRealServiceFeatures(Service service) {
    // TODO: 从service表的tags字段或其他地方获取真实的特色标签
    // 目前使用service的tags字段，如果存在的话
    final features = <String>[];

    if (service.tags != null && service.tags!.isNotEmpty) {
      features.addAll(service.tags!);
    }

    // 如果没有tags，回退到mock数据
    if (features.isEmpty) {
      return _getMockServiceFeatures(service);
    }

    return features;
  }

  /// 获取mock的服务特色标签
  List<String> _getMockServiceFeatures(Service service) {
    final features = <String>[];

    if (service.categoryLevel1Id == '1010000') {
      features
          .addAll(['新鲜食材 (Mock)', '专业厨师 (Mock)', '健康美味 (Mock)', '快速配送 (Mock)']);
    } else if (service.categoryLevel1Id == '1020000') {
      features
          .addAll(['专业认证 (Mock)', '保险保障 (Mock)', '灵活时间 (Mock)', '优质服务 (Mock)']);
    } else {
      features
          .addAll(['专业服务 (Mock)', '品质保证 (Mock)', '价格合理 (Mock)', '用户好评 (Mock)']);
    }

    return features;
  }

  /// 显示服务详情弹窗
  void _showServiceDetailModal(
      BuildContext context, ServiceDetail detail) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 拖拽指示器
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 标题栏
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '服务详情',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 详情内容
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: _buildServiceDetailContent(context, detail),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建服务详情内容
  Widget _buildServiceDetailContent(
      BuildContext context, ServiceDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 服务图片轮播
        if (detail.images != null && detail.images!.isNotEmpty)
          _buildImageCarousel(context, detail.images!),

        const SizedBox(height: 20),

        // 服务标题和价格
        _buildDetailHeader(context, detail),

        const SizedBox(height: 20),

        // 服务描述
        _buildDetailDescription(context, detail),

        const SizedBox(height: 20),

        // 服务规格
        _buildDetailSpecifications(context, detail),

        const SizedBox(height: 20),

        // 服务属性
        if (detail.industryAttributes != null && detail.industryAttributes!.isNotEmpty)
          _buildDetailAttributes(context, detail),

        const SizedBox(height: 20),

        // 库存信息
        _buildStockInfo(context, detail),

        const SizedBox(height: 30),

        // 操作按钮
        _buildDetailActions(context, detail),
      ],
    );
  }

  /// 构建图片轮播
  Widget _buildImageCarousel(BuildContext context, List<String> images) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.image, size: 48, color: Colors.grey[400]),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建详情标题
  Widget _buildDetailHeader(
      BuildContext context, ServiceDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 服务名称
        Text(
          detail.name?['zh'] ?? detail.name?['en'] ?? '未知服务',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
        ),

        const SizedBox(height: 12),

        // 价格和分类
        Row(
          children: [
            // 价格标签
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                '¥${detail.price?.toStringAsFixed(2) ?? '0.00'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 分类标签
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                detail.category ?? '未分类',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建服务描述
  Widget _buildDetailDescription(
      BuildContext context, ServiceDetail detail) {
    // 使用真实的描述数据，如果没有则生成默认描述
    String description;

    // 尝试从serviceDetailsJson中获取描述信息
    if (detail.serviceDetailsJson != null && detail.serviceDetailsJson!.isNotEmpty) {
      final extraData = detail.serviceDetailsJson!;
      if (extraData['description'] != null) {
        // 如果extraData中有description
        if (extraData['description'] is Map) {
          final descMap = extraData['description'] as Map<String, dynamic>;
          description = descMap['zh'] ??
              descMap['en'] ??
              extraData['description'].toString();
        } else {
          description = extraData['description'].toString();
        }
      } else {
        // 回退到生成的描述
        description = _generateServiceDescription(detail);
      }
    } else {
      // 回退到生成的描述
      description = _generateServiceDescription(detail);
    }

    // 检查是否为真实数据
    final isRealData = _isRealDataHelper(detail.id ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '服务介绍',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isRealData ? Colors.green[100] : Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isRealData ? '🟢 真实数据' : '🟠 模拟数据',
                style: TextStyle(
                  fontSize: 10,
                  color: isRealData ? Colors.green[700] : Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
          ),
        ),
      ],
    );
  }

  /// 构建服务规格
  Widget _buildDetailSpecifications(
      BuildContext context, ServiceDetail detail) {
    // 检查是否为真实数据
    final isRealData = _isRealDataHelper(detail.id ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '服务规格',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isRealData ? Colors.green[100] : Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isRealData ? '🟢 真实数据' : '🟠 模拟数据',
                style: TextStyle(
                  fontSize: 10,
                  color: isRealData ? Colors.green[700] : Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSpecItem(
            context, '服务时长', _getFormattedDuration(detail), Icons.access_time),
        _buildSpecItem(context, '计价单位', detail.durationType ?? '份', Icons.straighten),
        _buildSpecItem(context, '服务类型', _getFormattedPricingType(detail),
            Icons.price_check),
        if (detail.currency != null)
          _buildSpecItem(
              context, '货币', detail.currency!, Icons.monetization_on),
      ],
    );
  }

  Widget _buildSpecItem(
      BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label：',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建服务属性
  Widget _buildDetailAttributes(
      BuildContext context, ServiceDetail detail) {
    final attributes = detail.industryAttributes as Map<String, dynamic>?;
    if (attributes == null || attributes.isEmpty)
      return const SizedBox.shrink();

    // 检查是否为真实数据
    final isRealData = _isRealDataHelper(detail.id ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '服务属性',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isRealData ? Colors.green[100] : Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isRealData ? '🟢 真实数据' : '🟠 模拟数据',
                style: TextStyle(
                  fontSize: 10,
                  color: isRealData ? Colors.green[700] : Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: attributes.entries.map((entry) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${entry.key}: ${entry.value}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 构建库存信息
  Widget _buildStockInfo(
      BuildContext context, ServiceDetail detail) {
    final currentStock = detail.currentStock ?? 0;
    final maxStock = detail.maxStock ?? 0;
    final stockPercentage = maxStock > 0 ? currentStock / maxStock : 0.0;

    // 检查是否为真实数据
    final isRealData = _isRealDataHelper(detail.id ?? '');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: stockPercentage > 0.5 ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              stockPercentage > 0.5 ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                stockPercentage > 0.5 ? Icons.inventory : Icons.warning,
                color: stockPercentage > 0.5
                    ? Colors.green[600]
                    : Colors.orange[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '库存状态',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: stockPercentage > 0.5
                          ? Colors.green[700]
                          : Colors.orange[700],
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isRealData ? Colors.green[100] : Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isRealData ? '🟢 真实数据' : '🟠 模拟数据',
                  style: TextStyle(
                    fontSize: 10,
                    color: isRealData ? Colors.green[700] : Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '当前库存：$currentStock / $maxStock',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: stockPercentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              stockPercentage > 0.5 ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildDetailActions(
      BuildContext context, ServiceDetail detail) {
    return Column(
      children: [
        // 主要操作
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: 实现预约功能
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('立即预约'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: 实现加入购物车功能
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text('加入购物车'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 次要操作
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: () {
                // TODO: 实现收藏功能
              },
              icon: const Icon(Icons.favorite_outline),
              label: const Text('收藏'),
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: 实现分享功能
              },
              icon: const Icon(Icons.share),
              label: const Text('分享'),
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: 实现咨询功能
              },
              icon: const Icon(Icons.chat),
              label: const Text('咨询'),
            ),
          ],
        ),
      ],
    );
  }

  /// 生成服务描述
  String _generateServiceDescription(ServiceDetail detail) {
    final name = detail.name?['zh'] ?? detail.name?['en'] ?? '服务';
    final category = detail.category ?? '通用';

    if (category.contains('chinese') || category.contains('中')) {
      return '精选优质${name}，采用传统工艺制作，口味正宗，营养丰富。我们严格把控食材质量，确保每一份都新鲜美味。适合家庭聚餐、朋友聚会等各种场合。';
    } else if (category.contains('japanese') || category.contains('日')) {
      return '正宗${name}，选用新鲜食材，遵循传统日式制作工艺。注重食材的原味和营养搭配，为您带来纯正的日式美食体验。';
    } else if (category.contains('western') || category.contains('西')) {
      return '精致${name}，融合西式烹饪技巧，选用优质食材制作。口感丰富，营养均衡，适合现代人的饮食需求。';
    } else {
      return '优质${name}服务，专业团队精心准备，注重品质和用户体验。我们致力于为您提供满意的服务，让您享受便捷优质的生活。';
    }
  }

  /// 检查是否为真实数据（辅助方法）
  bool _isRealDataHelper(String id) {
    return !id.contains('test_') &&
        !id.contains('mock_') &&
        !id.contains('sample_');
  }

  /// 格式化服务时长
  String _getFormattedDuration(ServiceDetail detail) {
    if (detail.duration != null) {
      final duration = detail.duration.toString();
      if (duration.isNotEmpty && duration != 'null') {
        // 如果包含冒号，可能是时间格式 (HH:MM:SS)
        if (duration.contains(':')) {
          final parts = duration.split(':');
          if (parts.length >= 2) {
            final hours = int.tryParse(parts[0]) ?? 0;
            final minutes = int.tryParse(parts[1]) ?? 0;
            if (hours > 0) {
              return minutes > 0 ? '${hours}小时${minutes}分钟' : '${hours}小时';
            } else if (minutes > 0) {
              return '${minutes}分钟';
            }
          }
          return duration;
        }

        // 尝试解析为数字（分钟）
        final minutes = int.tryParse(duration);
        if (minutes != null && minutes > 0) {
          if (minutes >= 60) {
            final hours = (minutes / 60).floor();
            final remainingMinutes = minutes % 60;
            if (remainingMinutes == 0) {
              return '${hours}小时';
            } else {
              return '${hours}小时${remainingMinutes}分钟';
            }
          } else {
            return '${minutes}分钟';
          }
        }

        // 直接返回字符串
        return duration;
      }
    }
    return '标准时长';
  }

  /// 格式化定价类型
  String _getFormattedPricingType(ServiceDetail detail) {
    final pricingType = detail.pricingType ?? 'fixed_price';
    switch (pricingType.toLowerCase()) {
      case 'fixed_price':
        return '固定价格';
      case 'hourly':
        return '按小时计费';
      case 'negotiable':
        return '价格面议';
      case 'per_item':
        return '按件计费';
      case 'subscription':
        return '订阅服务';
      default:
        return pricingType;
    }
  }

  /// 获取服务起始价格
  String _getServiceStartingPrice(Service service) {
    // 如果Service有price字段且不为空，使用真实价格
    if (service.price != null && service.price! > 0) {
      return '¥ ${service.price!.toStringAsFixed(2)}';
    }

    // TODO: 从service_details表查询最低价格
    // 暂时返回基于分类的估算价格
    if (service.categoryLevel1Id == '1010000') {
      return '¥ 25.00 起 (估算)';
    } else if (service.categoryLevel1Id == '1020000') {
      return '¥ 80.00 起 (估算)';
    } else {
      return '¥ 面议';
    }
  }

  /// 获取价格描述
  String _getPriceDescription(Service service) {
    // 如果有真实价格，显示更详细的描述
    if (service.price != null && service.price! > 0) {
      return '基础服务价格，具体费用根据实际需求确定。支持在线咨询和预约服务。';
    }

    // 默认描述
    if (service.categoryLevel1Id == '1010000') {
      return '美食服务价格根据菜品种类和数量确定，支持在线下单和电话咨询';
    } else if (service.categoryLevel1Id == '1020000') {
      return '家政服务价格根据服务类型和时长确定，支持在线预约和现场评估';
    } else {
      return '具体价格根据服务内容和要求确定，支持在线咨询获取准确报价';
    }
  }

  /// 检查价格数据是否为真实数据
  bool _isPriceDataReal(Service service) {
    return service.price != null && service.price! > 0;
  }

  /* 
   * 数据源状态总结:
   * 
   * 真实数据 (从数据库获取):
   * - Service基本信息 (id, title, description, rating, reviewCount)
   * - ServiceDetail信息 (Menu Tab中的服务项目详情)
   * 
   * Mock数据 (硬编码生成):
   * - Provider信息 (服务商名称、描述、认证等)
   * - 服务特色标签 (新鲜食材、专业认证等)
   * - 部分价格信息 (起始价格基于categoryLevel1Id生成)
   * 
   * TODO: 需要实现真实数据连接的部分:
   * 1. 从provider_profiles表获取服务商信息
   * 2. 从service_details或相关表获取真实的服务特色标签
   * 3. 从service_details表获取真实的价格范围信息
   * 4. 实现Reviews Tab的用户评价数据
   * 5. 实现For You Tab的推荐服务数据
   */

    /// Menu Tab中直接添加到购物车
  Future<void> _addToCartFromMenu(
      BuildContext context, ServiceDetail detail) async {
    bool hasError = false;
    final stopwatch = Stopwatch()..start();
    
    // 崩溃防护机制
    try {
      print('🛒 [MenuTab] 🚀 开始添加到购物车 - detail ID: ${detail.id}');
      print('🛒 [MenuTab] 📊 当前时间: ${DateTime.now()}');
      print('🛒 [MenuTab] 🔍 UI状态检查 - mounted: ${context.mounted}');

      // 获取购物车控制器
      print('🛒 [MenuTab] 🔍 开始获取购物车控制器 - ${stopwatch.elapsedMilliseconds}ms');
      final cartController = Get.find<UnifiedCartController>();
      print('🛒 [MenuTab] ✅ 购物车控制器获取成功 - ${stopwatch.elapsedMilliseconds}ms');

      print('🛒 [MenuTab] 📱 显示加载对话框 - ${stopwatch.elapsedMilliseconds}ms');
      // 显示加载指示器
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      print('🛒 [MenuTab] 📱 加载对话框已显示 - ${stopwatch.elapsedMilliseconds}ms');
      print('🛒 [MenuTab] 🔍 对话框状态验证: Get.isDialogOpen=${Get.isDialogOpen}');

      print('🛒 [MenuTab] 🔄 开始调用addServiceToCart - ${stopwatch.elapsedMilliseconds}ms');
      print('🛒 [MenuTab] 🔍 调用前UI状态: mounted=${context.mounted}, dialogOpen=${Get.isDialogOpen}');
      
      // 添加到购物车
      await cartController.addServiceToCart(
        serviceId: detail.serviceId,
        serviceDetailId: detail.id,
        quantity: 1,
      );
      print('🛒 [MenuTab] ✅ addServiceToCart完成 - ${stopwatch.elapsedMilliseconds}ms');
      print('🛒 [MenuTab] 🔍 调用后UI状态: mounted=${context.mounted}, dialogOpen=${Get.isDialogOpen}');

      print('✅ Menu Tab: 购物车添加成功');
    } catch (e) {
      hasError = true;
      print('❌ Menu Tab: 购物车添加失败: $e');

      // 显示错误消息
      Get.snackbar(
        '添加失败',
        '添加到购物车时出现错误，请稍后重试',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      print('🛒 [MenuTab] 🔄 进入finally块，开始关闭对话框 - ${stopwatch.elapsedMilliseconds}ms');
      print('🛒 [MenuTab] 📊 对话框状态检查: Get.isDialogOpen=${Get.isDialogOpen}');
      print('🛒 [MenuTab] 🔍 finally块UI状态: mounted=${context.mounted}');
      
      // 强制关闭对话框 - 崩溃防护版本
      try {
        print('🛒 [MenuTab] 📱 强制关闭对话框 - ${stopwatch.elapsedMilliseconds}ms');
        
        // 多次尝试关闭对话框，确保成功
        int attempts = 0;
        while (Get.isDialogOpen == true && attempts < 3) {
          attempts++;
          print('🛒 [MenuTab] 🔄 第${attempts}次尝试关闭对话框');
          
          Get.back();
          await Future.delayed(const Duration(milliseconds: 10));
          
          print('🛒 [MenuTab] 🔍 第${attempts}次尝试后状态: Get.isDialogOpen=${Get.isDialogOpen}');
          
          if (Get.isDialogOpen == false) {
            print('🛒 [MenuTab] ✅ 对话框成功关闭');
            break;
          }
        }
        
        // 如果仍然无法关闭，使用强制方法
        if (Get.isDialogOpen == true) {
          print('🛒 [MenuTab] ⚠️ 常规方法无法关闭，使用强制方法');
          try {
            Navigator.of(context, rootNavigator: true).pop();
            print('🛒 [MenuTab] 🔧 强制关闭完成');
          } catch (e) {
            print('🛒 [MenuTab] ❌ 强制关闭也失败: $e');
          }
        }
        
        print('🛒 [MenuTab] ✅ 对话框关闭流程完成 - ${stopwatch.elapsedMilliseconds}ms');
      } catch (e) {
        print('🛒 [MenuTab] ⚠️ 关闭对话框出错: $e');
        print('🛒 [MenuTab] 🔍 错误时UI状态: mounted=${context.mounted}, dialogOpen=${Get.isDialogOpen}');
      }

      // 最终UI状态验证
      print('🛒 [MenuTab] 🔍 最终UI状态验证 - ${stopwatch.elapsedMilliseconds}ms');
      print('🛒 [MenuTab] 🔍 - mounted: ${context.mounted}');
      print('🛒 [MenuTab] 🔍 - dialogOpen: ${Get.isDialogOpen}');
      print('🛒 [MenuTab] 🔍 - snackbarOpen: ${Get.isSnackbarOpen}');
      
      // 如果对话框仍然打开，这是崩溃的前兆
      if (Get.isDialogOpen == true) {
        print('🛒 [MenuTab] 🚨 警告：对话框仍然打开，可能导致崩溃！');
        print('🛒 [MenuTab] 🔧 尝试最后的紧急关闭...');
        
        try {
          // 紧急关闭所有可能的对话框
          while (Get.isDialogOpen == true) {
            Get.back();
            await Future.delayed(const Duration(milliseconds: 5));
          }
          print('🛒 [MenuTab] ✅ 紧急关闭成功');
        } catch (e) {
          print('🛒 [MenuTab] ❌ 紧急关闭失败: $e');
        }
      }

      // 等待购物车状态更新完成，确保UI同步
      print('🛒 [MenuTab] ⏳ 等待购物车状态同步 - ${stopwatch.elapsedMilliseconds}ms');
      await Future.delayed(const Duration(milliseconds: 150));

      // 只在成功时显示成功消息
      if (!hasError) {
        // 延迟显示成功消息，确保UI状态稳定
        print('🛒 [MenuTab] 🎉 准备延迟显示成功消息 - ${stopwatch.elapsedMilliseconds}ms');
        
        // 使用更安全的方式显示成功消息
        Future.microtask(() async {
          try {
            print('🛒 [MenuTab] 🎉 异步显示成功消息 - ${stopwatch.elapsedMilliseconds}ms');
            // 检查context是否仍然有效
            if (context.mounted) {
              print('🛒 [MenuTab] 🎉 context可用，显示成功snackbar');
              Get.snackbar(
                '添加成功',
                '商品已添加到购物车',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(milliseconds: 800),
                margin: const EdgeInsets.all(16),
                borderRadius: 8,
                icon: const Icon(Icons.check_circle, color: Colors.white),
              );
              print('🛒 [MenuTab] ✅ 成功消息已显示');
            } else {
              print('🛒 [MenuTab] ⚠️ context已卸载，跳过成功消息显示');
            }
          } catch (e) {
            print('🛒 [MenuTab] ⚠️ 显示成功消息时出错: $e');
          }
        });
      }
      
      stopwatch.stop();
      print('🛒 [MenuTab] 🏁 _addToCartFromMenu完成 - 总耗时: ${stopwatch.elapsedMilliseconds}ms');
      print('🛒 [MenuTab] 📊 修复版本 - 确保UI状态同步，防止卡顿');
    }
  }
}
