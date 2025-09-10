import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';

import '../../../../core/services/services.dart' as core_services;
import '../../../../core/utils/app_logger.dart';
import '../../../../core/controllers/unified_cart_controller.dart';
import '../../../../core/models/cart_models.dart';
import '../../../../core/services/service_booking_type_resolver.dart';
// import '../../../../core/services/pricing_calculators.dart'; // Will be used for pricing calculations
// Removed unused imports
import 'widgets/flexible_tabbar_layout.dart';
import '../../cart/presentation/enhanced_cart_page.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/service_detail.dart' as domain_models;
import '../services/service_detail_api_service.dart' as api;
import 'widgets/service_detail_error.dart';
import 'widgets/dynamic_tab_builder.dart';
import 'service_detail_controller.dart';
// Removed unused imports

class ServiceDetailPageNew extends StatefulWidget {
  final String serviceId;

  const ServiceDetailPageNew({
    super.key,
    required this.serviceId,
  });

  @override
  State<ServiceDetailPageNew> createState() => _ServiceDetailPageNewState();
}

class _ServiceDetailPageNewState extends State<ServiceDetailPageNew>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ServiceDetailController controller;

  // New service architecture integration
  late core_services.ServiceManager _serviceManager;
  late core_services.DynamicTabConfigService _dynamicTabService;
  RxList<core_services.ServiceDetail> _serviceDetails =
      <core_services.ServiceDetail>[].obs;
  bool _isNewServiceInitialized = false;

  // Cart controller
  late UnifiedCartController _cartController;

  // Tab Bar layout configuration
  TabBarLayoutConfig _tabBarLayoutConfig = TabBarLayoutConfig.defaultConfig;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with fixed 5 tabs length
    _tabController = TabController(length: 5, vsync: this);

    // Safe controller initialization
    controller = Get.put(ServiceDetailController());

    // Initialize cart controller
    _cartController = Get.put(UnifiedCartController());

    // Initialize new service architecture
    _initializeNewServices();

    // Delayed data loading to avoid initialization conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final serviceId = Get.parameters['serviceId'] ?? widget.serviceId;
      if (serviceId.isNotEmpty) {
        _loadServiceDetail(serviceId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeNewServices() async {
    try {
      // // debugPrint('🚀 ========== _initializeNewServices 开始 ==========');

      // debugPrint('🔧 获取 ServiceManager 实例...');
      _serviceManager = core_services.ServiceManager.instance;
      // debugPrint('✅ ServiceManager 实例获取成功');

      // debugPrint('🔧 创建 DynamicTabConfigService...');
      _dynamicTabService = core_services.DynamicTabConfigService();
      // debugPrint('✅ DynamicTabConfigService 创建成功');

      // Initialize service manager
      // debugPrint('🔍 检查 ServiceManager 是否已初始化: ${_serviceManager.isInitialized}');
      if (!_serviceManager.isInitialized) {
        // debugPrint('🔧 ServiceManager 未初始化，开始初始化...');
        await _serviceManager.initializeServices();
        // debugPrint('✅ ServiceManager 初始化完成');
      } else {
        // debugPrint('ℹ️ ServiceManager 已经初始化');
      }

      // debugPrint('🔍 ServiceManager 最终状态:');
      // debugPrint('  - isInitialized: ${_serviceManager.isInitialized}');
      // debugPrint('  - serviceQueryService: ${_serviceManager.serviceQueryService != null}');
      // debugPrint('  - serviceDetailService: ${_serviceManager.serviceDetailService != null}');
      // debugPrint('  - authService: ${_serviceManager.authService != null}');
      // debugPrint('  - providerService: ${_serviceManager.providerService != null}');

      _isNewServiceInitialized = true;
      // debugPrint('✅ _isNewServiceInitialized 设置为 true');
      // debugPrint('🚀 ========== _initializeNewServices 完成 ==========');
    } catch (e) {
      // debugPrint('❌ ========== _initializeNewServices 异常 ==========');
      // debugPrint('❌ 异常详情: $e');
      // debugPrint('❌ 堆栈信息: $stackTrace');
      // debugPrint('❌ _isNewServiceInitialized 保持为 false');
    }
  }

  Future<void> _loadServiceDetail(String serviceId) async {
    try {
      // 预加载服务数据 - 新增
      await _preloadServiceData(serviceId);
      
      await controller.loadServiceDetail(serviceId);

      // Load service details if new service is initialized
      if (_isNewServiceInitialized) {
        await _loadServiceDetails(serviceId);
      }
    } catch (e) {
      // debugPrint('Error loading service detail: $e');
    }
  }

  /// 预加载服务数据 - 新增
  Future<void> _preloadServiceData(String serviceId) async {
    try {
      AppLogger.info('[ServiceDetailPage] 🚀 开始预加载服务数据: $serviceId');
      
      // 获取服务详情列表
      final serviceDetails = await api.ServiceDetailApiService.getAllServiceDetails(serviceId);
      
      // 提取服务详情ID列表
      final serviceDetailIds = serviceDetails.map((detail) => detail.id).toList();
      
      // 批量预加载
      await UnifiedCartController.preloadMultipleServices(
        [serviceId], // 服务ID列表
        serviceDetailIds, // 服务详情ID列表
      );
      
      AppLogger.info('[ServiceDetailPage] ✅ 预加载完成 - 服务: $serviceId, 详情数量: ${serviceDetailIds.length}');
    } catch (e) {
      AppLogger.warning('[ServiceDetailPage] ⚠️ 预加载失败: $e');
    }
  }

  Future<void> _loadServiceDetails(String serviceId) async {
    try {
      // debugPrint('🎯 ========== _loadServiceDetails 开始 ==========');
      // debugPrint('🔍 输入参数: serviceId=$serviceId');
      // debugPrint('🔍 _serviceManager 是否存在: ${_serviceManager != null}');
      // debugPrint('🔍 _serviceManager.isInitialized: ${_serviceManager.isInitialized}');
      // debugPrint('🔍 _serviceManager.serviceDetailService 是否存在: ${_serviceManager.serviceDetailService != null}');

      if (_serviceManager.serviceDetailService != null) {
        // debugPrint('📡 ========== 开始调用真实API ==========');
        // debugPrint('📡 调用 _serviceManager.serviceDetailService!.getServiceDetails($serviceId)');
        final details = await _serviceManager.serviceDetailService!
            .getServiceDetails(serviceId);
        // debugPrint('📊 API返回结果数量: ${details.length}');

        if (details.isNotEmpty) {
          // debugPrint('✅ ========== 真实数据加载成功 ==========');
          // debugPrint('✅ 成功加载 ${details.length} 条真实服务详情');
          for (int i = 0; i < details.length && i < 3; i++) {
            final detail = details[i];
            // debugPrint('📋 记录${i+1}: ID=${detail.id}, 名称=${detail.name}, 分类=${detail.category}');
          }
          if (details.length > 3) {
            // debugPrint('📋 ... 还有 ${details.length - 3} 条记录');
          }
          _serviceDetails.assignAll(details);
          // debugPrint('✅ _serviceDetails 已设置为真实数据');
        } else {
          // debugPrint('⚠️ ========== API返回空数据，使用模拟数据 ==========');
          _serviceDetails.assignAll(_createTestServiceDetails());
          // debugPrint('⚠️ _serviceDetails 已设置为模拟数据，数量: ${_serviceDetails.length}');
        }

        // Update TabController length to match dynamic tab count
        // debugPrint('🔧 调用 _updateTabControllerLength()');
        _updateTabControllerLength();
      } else {
        // debugPrint('❌ ========== ServiceDetailService 不可用，使用模拟数据 ==========');
        // debugPrint('❌ _serviceManager.serviceDetailService is null');
        _serviceDetails.assignAll(_createTestServiceDetails());
        // debugPrint('❌ _serviceDetails 已设置为模拟数据，数量: ${_serviceDetails.length}');
        _updateTabControllerLength();
      }

      // debugPrint('🎯 ========== _loadServiceDetails 完成 ==========');
      // debugPrint('🎯 最终 _serviceDetails 数量: ${_serviceDetails.length}');
      // debugPrint('🎯 是否为真实数据: ${_isRealData()}');
    } catch (e) {
      // debugPrint('❌ ========== _loadServiceDetails 异常 ==========');
      // debugPrint('❌ 异常详情: $e');
      // debugPrint('❌ 堆栈信息: $stackTrace');
      _serviceDetails.assignAll(_createTestServiceDetails());
      // debugPrint('❌ 异常处理: _serviceDetails 已设置为模拟数据，数量: ${_serviceDetails.length}');
      _updateTabControllerLength();
    }
  }

  void _updateTabControllerLength() {
    // debugPrint('🔄 _updateTabControllerLength: 开始更新Tab长度');
    // debugPrint('🔍 _isNewServiceInitialized: $_isNewServiceInitialized');
    // debugPrint('🔍 _serviceDetails长度: ${_serviceDetails.length}');

    if (_isNewServiceInitialized && _serviceDetails.isNotEmpty) {
      final service = controller.service.value;
      // debugPrint('🔍 controller.service.value: ${service != null ? '存在' : 'null'}');

      if (service != null) {
        // debugPrint('🔧 开始转换Service到core_services.Service...');
        // Convert Service to core_services.Service
        final coreService = _convertToCoreService(service);
        // debugPrint('✅ Service转换完成: ID=${coreService.id}, 大类=${coreService.categoryLevel1Id}');

        // debugPrint('🔧 开始转换_serviceDetails到core_services.ServiceDetail...');
        // Convert _serviceDetails to correct type
        final coreServiceDetails = _serviceDetails
            .map((detail) => core_services.ServiceDetail(
                  id: detail.id,
                  serviceId: detail.serviceId,
                  category: detail.category,
                  name: detail.name,
                  subCategory: detail.subCategory,
                  isAvailable: detail.isAvailable,
                  sortOrder: detail.sortOrder ?? 0,
                  currentStock: detail.currentStock,
                  maxStock: detail.maxStock,
                  attributes: detail.attributes,
                  businessRules: detail.businessRules,
                  pricingType: detail.pricingType,
                  price: detail.price,
                  currency: detail.currency,
                  duration: detail.duration,
                  unit: detail.unit,
                  images: detail.images,
                  videos: detail.videos,
                  tags: detail.tags,
                  serviceAreaCodes: detail.serviceAreaCodes,
                  platformServiceFeeRate: detail.platformServiceFeeRate,
                  minPlatformServiceFee: detail.minPlatformServiceFee,
                  extraData: detail.extraData,
                  promotionStart: detail.promotionStart,
                  promotionEnd: detail.promotionEnd,
                  viewCount: detail.viewCount,
                  favoriteCount: detail.favoriteCount,
                  orderCount: detail.orderCount,
                  verificationStatus: detail.verificationStatus,
                  documents: detail.documents,
                  type: detail.type,
                  createdAt: detail.createdAt,
                  updatedAt: detail.updatedAt,
                ))
            .toList();
        // debugPrint('✅ ServiceDetail转换完成: ${coreServiceDetails.length} 条记录');

        // debugPrint('🔧 调用_dynamicTabService.getTabConfig...');
        final tabConfig =
            _dynamicTabService.getTabConfig(coreService, coreServiceDetails);
        // debugPrint('📋 Tab配置生成完成: ${tabConfig.length} 个Tab');

        if (tabConfig.length != _tabController.length) {
          // debugPrint('🔄 需要更新TabController长度: ${_tabController.length} -> ${tabConfig.length}');
          setState(() {
            _tabController = TabController(
              length: tabConfig.length,
              vsync: this,
            );
          });
          // debugPrint('✅ TabController长度更新完成');
        } else {
          // debugPrint('ℹ️ TabController长度无需更新');
        }
      } else {
        // debugPrint('❌ controller.service.value 为 null');
      }
    } else {
      // debugPrint('⚠️ 条件不满足: _isNewServiceInitialized=$_isNewServiceInitialized, _serviceDetails长度=${_serviceDetails.length}');
    }
  }

  core_services.Service _convertToCoreService(Service service) {
    return core_services.Service(
      id: service.id,
      title: {'en': service.title, 'zh': service.title},
      description: {'en': service.description, 'zh': service.description},
      price: service.price ?? 0.0,
      currency: service.currency ?? 'USD',
      pricingType: service.pricingType ?? 'fixed',
      categoryId: '1010000', // Force set to food category
      categoryLevel1Id: '1010000', // Food World
      categoryLevel2Id: '1010100', // Community Food
      providerId: service.providerId ?? '',
      serviceDeliveryMethod: service.serviceDeliveryMethod ?? 'on_site',
      status: service.status ?? 'active',
      createdAt: service.createdAt ?? DateTime.now(),
      updatedAt: service.updatedAt ?? DateTime.now(),
      images: service.images ?? [],
      imagesUrl: service.images_url ?? [],
      rating: service.rating ?? 0.0,
      reviewCount: service.reviewCount ?? 0,
      isActive: service.isActive ?? true,
      serviceDetailsJson: service.serviceDetailsJson ?? {},
      latitude: service.latitude,
      longitude: service.longitude,
      serviceAreaCodes: service.serviceAreaCodes ?? [],
      tags: service.tags ?? [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.serviceDetailPageTitle ?? 'Service Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Tab Bar layout switcher button
          TabBarLayoutSwitcher(
            config: _tabBarLayoutConfig,
            onModeChanged: _switchToLayoutMode,
          ),

          // Global cart icon
          Obx(() {
            final stopwatch = Stopwatch()..start();
            final cartCount = _cartController.cartItems.length;
            AppLogger.info('[UI] 🎨 AppBar购物车图标开始重建 - 商品数: $cartCount');
            
            final widget = Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => Get.to(() => const EnhancedCartPage()),
                  iconSize: 22,
                ),
                if (cartCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '$cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
            
            stopwatch.stop();
            AppLogger.info('[UI] 🎨 AppBar购物车图标重建完成 - 耗时: ${stopwatch.elapsedMilliseconds}ms');
            
            // 添加下一帧回调监控
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AppLogger.info('[UI] 🎨 AppBar购物车图标PostFrame完成');
            });
            
            return widget;
          }),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value) {
          return ServiceDetailError(
            message: controller.errorMessage.value,
            onRetry: () => _loadServiceDetail(widget.serviceId),
          );
        }

        final service = controller.service.value;
        if (service == null) {
          return const Center(child: Text('Service not found'));
        }

        return _buildPageContent(service, l10n);
      }),
      // Remove bottomNavigationBar to avoid overflow, action buttons are built into page content
    );
  }

  Widget _buildPageContent(Service service, AppLocalizations? l10n) {
    return FutureBuilder<Widget>(
      future: _buildNewDynamicTabSystem(service),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          // Use FlexibleTabBarLayout to restore gesture functionality
          // Extract TabBar and TabBarView from snapshot.data
          final tabWidget = snapshot.data! as Column;
          final tabBar = tabWidget.children
              .firstWhere((child) => child is TabBar) as TabBar;
          final expandedChild = tabWidget.children
              .firstWhere((child) => child is Expanded) as Expanded;
          final tabBarView = expandedChild.child as Widget;

          return FlexibleTabBarLayout(
            imageCarousel: _buildServiceImageCarousel(service),
            tabBar: tabBar,
            tabBarView: tabBarView,
            config: _tabBarLayoutConfig,
            onModeChanged: (mode) {
              setState(() {
                _tabBarLayoutConfig = _tabBarLayoutConfig.copyWith(mode: mode);
              });
            },
          );
        } else {
          return const Center(child: Text('No tabs available'));
        }
      },
    );
  }

  /// 创建测试服务详情数据
  List<core_services.ServiceDetail> _createTestServiceDetails() {
    return [
      core_services.ServiceDetail(
        id: '550e8400-e29b-41d4-a716-446655440201',
        serviceId: widget.serviceId,
        name: {'en': 'Main Service', 'zh': '主要服务'},
        price: 25.00,
        category: 'main',
        isAvailable: true,
        sortOrder: 1,
        attributes: {},
        businessRules: {},
        duration: '60',
        unit: 'minutes',
        currency: 'CAD',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      core_services.ServiceDetail(
        id: '550e8400-e29b-41d4-a716-446655440202',
        serviceId: widget.serviceId,
        name: {'en': 'Premium Service', 'zh': '优质服务'},
        price: 35.00,
        category: 'premium',
        isAvailable: true,
        sortOrder: 2,
        attributes: {},
        businessRules: {},
        duration: '90',
        unit: 'minutes',
        currency: 'CAD',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Removed unnecessary extraction methods (inlined into code)

  /// 切换到指定布局模式
  void _switchToLayoutMode(TabBarLayoutMode mode) {
    setState(() {
      _tabBarLayoutConfig = _tabBarLayoutConfig.copyWith(mode: mode);
    });
  }

  Future<Widget> _buildNewDynamicTabSystem(Service service) async {
    // debugPrint('🔄 _buildNewDynamicTabSystem: _isNewServiceInitialized=$_isNewServiceInitialized, _serviceDetails.length=${_serviceDetails.length}');

    // Temporarily force use of new dynamic tab system for testing
    if (false && (!_isNewServiceInitialized || _serviceDetails.isEmpty)) {
      // debugPrint('回退到旧的Tab系统');
      // Fallback to old tab system
      return DynamicTabBuilder(
        service: service,
        tabController: _tabController,
      );
    }

    // debugPrint('✅ 使用新的动态Tab系统');

    // Use new dynamic tab configuration service
    final coreService = _convertToCoreService(service);

    // Prefer real data, create test data if none available
    List<core_services.ServiceDetail> testServiceDetails = _serviceDetails;
    if (testServiceDetails.isEmpty) {
      // debugPrint('🔴 没有真实数据，尝试从API加载');
      // Try to load real data from API
      try {
        // debugPrint('🔄 尝试从API加载真实数据，serviceId: ${service.id}');
        final realServiceDetails =
            await api.ServiceDetailApiService.getAllServiceDetails(service.id);
        // debugPrint('📊 API返回数据: ${realServiceDetails.length} 个服务详情');

        if (realServiceDetails.isNotEmpty) {
          // Convert to core_services.ServiceDetail format
          testServiceDetails = realServiceDetails
              .map((detail) => _convertToCoreServiceDetail(detail))
              .toList();
          // 🔧 重要修复：更新全局的_serviceDetails变量！
          _serviceDetails.assignAll(testServiceDetails);
          // debugPrint('✅ 从API加载到 ${testServiceDetails.length} 个真实服务详情');
          // debugPrint('🔧 已更新全局_serviceDetails变量，长度: ${_serviceDetails.length}');
          for (var detail in testServiceDetails) {
            // debugPrint('📋 服务详情: ${detail.name} - ${detail.price} ${detail.currency} - 分类: ${detail.category}');
            // debugPrint('🔍 真实数据ID: ${detail.id} (是否包含test_: ${detail.id.contains('test_')})');
          }

          // 🔥 强制UI更新，让数据源指示器重新计算
          // debugPrint('🔄 强制UI更新以刷新数据源指示器');
          if (mounted) {
            setState(() {
              // Force re-render, especially data source indicator
            });
          }
        } else {
          // debugPrint('⚠️ API没有返回数据，使用测试数据');
          testServiceDetails = _createTestServiceDetails();
          // debugPrint('🟠 创建了 ${testServiceDetails.length} 个测试服务详情');
          for (var detail in testServiceDetails) {
            // debugPrint('📋 测试详情: ${detail.name} - ${detail.price} ${detail.currency} - 分类: ${detail.category}');
          }
        }
      } catch (e) {
        // debugPrint('❌ API加载失败: $e，使用测试数据');
        testServiceDetails = _createTestServiceDetails();
        // debugPrint('🟠 创建了 ${testServiceDetails.length} 个测试服务详情');
        for (var detail in testServiceDetails) {
          // debugPrint('📋 测试详情: ${detail.name} - ${detail.price} ${detail.currency} - 分类: ${detail.category}');
        }
      }
    } else {
      // debugPrint('🟢 使用已加载的真实数据: ${testServiceDetails.length} 个服务详情');
      for (var detail in testServiceDetails) {
        // debugPrint('📋 已加载详情: ${detail.name} - ${detail.price} ${detail.currency} - 分类: ${detail.category}');
      }
    }

    // debugPrint('🎯 准备生成Tab配置，服务详情数量: ${testServiceDetails.length}');
    final tabConfig =
        _dynamicTabService.getTabConfig(coreService, testServiceDetails);
    // debugPrint('📋 生成的Tab配置: ${tabConfig.map((t) => '${t['title']}(${t['category']})').toList()}');

    // 创建新的TabController以匹配动态Tab数量
    final dynamicTabController =
        TabController(length: tabConfig.length, vsync: this);

    // 构建Tab列表，支持颜色主题
    final tabs = tabConfig.map((tab) {
      final isOperational = tab['isOperational'] == true;
      return Tab(
        icon: Icon(
          tab['icon'] as IconData? ?? Icons.info,
          size: 20,
          color: isOperational ? Colors.green[600] : null, // 操作性Tab用绿色
        ),
        text: tab['title']?.toString() ?? 'Tab',
      );
    }).toList();

    // 构建Tab视图内容
    final tabBarView = TabBarView(
      controller: dynamicTabController,
      children: tabConfig.asMap().entries.map((entry) {
        final index = entry.key;
        final tab = entry.value;

        // debugPrint('🎭 构建Tab ${index + 1}: ${tab['title']} (${tab['category']})');

        // 使用DynamicTabConfigService的内容构建器
        final contentBuilder = _dynamicTabService.getTabContentBuilder(
            coreService, testServiceDetails);
        return contentBuilder(context, index);
      }).toList(),
    );

    // 返回完整的Tab组件 (包含TabBar和TabBarView)
    return Column(
      children: [
        // Tab Bar
        TabBar(
          controller: dynamicTabController,
          isScrollable: true,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 2,
          tabAlignment: TabAlignment.start,
          tabs: tabs,
        ),
        // Tab内容
        Expanded(
          child: tabBarView,
        ),
      ],
    );
  }

  // 删除重复的方法定义

  /// Check if Service has real images
  bool _hasRealImages(Service service) {
    // Prioritize checking images_url field
    if (service.images_url != null && service.images_url!.isNotEmpty) {
      return service.images_url!.any((url) =>
          url.isNotEmpty &&
          !url.contains('via.placeholder.com') &&
          !url.contains('example.com') &&
          !url.contains('test') &&
          url.startsWith('http'));
    }

    // 检查images字段
    if (service.images != null && service.images!.isNotEmpty) {
      return service.images!.any((url) =>
          url.isNotEmpty &&
          !url.contains('via.placeholder.com') &&
          !url.contains('example.com') &&
          !url.contains('test') &&
          url.startsWith('http'));
    }

    return false;
  }

  /// 构建占位图片
  Widget _buildPlaceholderImage(Service service) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[50]!,
            Colors.blue[100]!,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_menu,
              size: 60,
              color: Colors.blue[600],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  service.title ?? '美食服务',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '精美图片即将呈现',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceImages(Service service) {
    // Get real image URLs
    List<String> imageUrls = [];

    // Prioritize using images_url
    if (service.images_url != null && service.images_url!.isNotEmpty) {
      imageUrls = service.images_url!
          .where((url) =>
              url.isNotEmpty &&
              !url.contains('via.placeholder.com') &&
              !url.contains('example.com') &&
              url.startsWith('http'))
          .toList();
    }

    // If no images_url, use images
    if (imageUrls.isEmpty &&
        service.images != null &&
        service.images!.isNotEmpty) {
      imageUrls = service.images!
          .where((url) =>
              url.isNotEmpty &&
              !url.contains('via.placeholder.com') &&
              !url.contains('example.com') &&
              url.startsWith('http'))
          .toList();
    }

    if (imageUrls.isEmpty) {
      return _buildPlaceholderImage(service);
    }

    return Stack(
      children: [
        PageView.builder(
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            final imageUrl = imageUrls[index];

            return Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                // 尝试使用备用图片源
                return FutureBuilder<Widget>(
                  future: _buildFallbackImage(imageUrl, error),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!;
                    }
                    return Container(
                      color: Colors.grey[300],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 60, color: Colors.grey[600]),
                          const SizedBox(height: 8),
                          Text(
                            '正在加载图片...',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),

        // Image indicator (if multiple images)
        if (imageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imageUrls.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.8),
                  ),
                );
              }).toList(),
            ),
          ),

        // 图片数量标签
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${imageUrls.length} 张图片',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods

  /// 转换domain.ServiceDetail到core_services.ServiceDetail
  core_services.ServiceDetail _convertToCoreServiceDetail(
      domain_models.ServiceDetail domainDetail) {
    return core_services.ServiceDetail(
      id: domainDetail.id,
      serviceId: domainDetail.serviceId,
      category: domainDetail.category,
      name: domainDetail.name is Map<String, dynamic>
          ? Map<String, String>.from(domainDetail.name as Map<String, dynamic>)
          : {
              'en': domainDetail.name?.toString() ?? 'Service',
              'zh': domainDetail.name?.toString() ?? '服务'
            },
      subCategory: domainDetail.subCategory,
      isAvailable: domainDetail.isAvailable,
      sortOrder: domainDetail.sortOrder,
      currentStock: domainDetail.currentStock,
      maxStock: domainDetail.maxStock,
      attributes: domainDetail.industryAttributes ?? {},
      businessRules: {},
      pricingType: domainDetail.pricingType,
      price: domainDetail.price,
      currency: domainDetail.currency,
      duration: domainDetail.duration?.toString(),
      unit: 'minutes',
      images: domainDetail.images,
      videos: [],
      tags: domainDetail.tags,
      serviceAreaCodes: domainDetail.serviceAreaCodes,
      platformServiceFeeRate: 0.1,
      minPlatformServiceFee: 2.0,
      extraData: domainDetail.serviceDetailsJson,
      promotionStart: null,
      promotionEnd: null,
      viewCount: 0,
      favoriteCount: 0,
      orderCount: 0,
      verificationStatus: 'pending',
      documents: [],
      type: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // ===== 新增的订单生成UI方法 =====

  /// 构建底部操作区域

  /// 构建操作按钮

  /// 直接下单按钮

  /// 购物车专用按钮（餐饮服务）- 只显示价格和智能引导信息

  /// 双选项按钮（预约服务）

  /// 价格显示组件

  // ===== 事件处理方法 =====

  /// 处理直接预订

  /// 处理添加到购物车
  Future<void> _handleAddToCart(Service service) async {
    try {
      // debugPrint('🛒 _handleAddToCart called for service: ${service.id}');
      // debugPrint('🛒 Service title: ${service.title}');
      // debugPrint('🛒 Service categoryLevel1Id: ${service.categoryLevel1Id}');

      final bookingType = ServiceBookingTypeResolver.resolve(service);
      // debugPrint('🛒 Resolved booking type: $bookingType');
      // debugPrint('🛒 Supports cart: ${bookingType.supportsCart}');

      final canAdd = _cartController.canAddToCart(service);
      // debugPrint('🛒 canAddToCart result: $canAdd');

      if (!canAdd) {
        // debugPrint('🛒 Cannot add to cart - showing error snackbar');
        Get.snackbar(
          '无法添加',
          '该服务不支持购物车',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // debugPrint('🛒 Showing add to cart dialog');
      await _showAddToCartDialog(service);
    } catch (e) {
      // debugPrint('🛒 Error in _handleAddToCart: $e');
      // debugPrint('🛒 Stack trace: $stackTrace');
      Get.snackbar(
        '添加失败',
        '请稍后重试: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// 显示询价对话框
  void _showQuoteDialog(Service service) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '获取报价',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.flash_on, color: Colors.green),
              title: Text('快速报价'),
              subtitle: Text('24小时内回复'),
              onTap: () {
                Get.back();
                _requestQuickQuote(service);
              },
            ),
            ListTile(
              leading: Icon(Icons.description, color: Colors.blue),
              title: Text('详细报价'),
              subtitle: Text('48小时内回复'),
              onTap: () {
                Get.back();
                _requestDetailedQuote(service);
              },
            ),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.purple),
              title: Text('即时咨询'),
              subtitle: Text('与服务商直接沟通'),
              onTap: () {
                Get.back();
                _startNegotiationChat(service);
              },
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.back(),
              child: Text('取消'),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示添加到购物车对话框
  Future<void> _showAddToCartDialog(Service service) async {
    // debugPrint('🛒🎯 _showAddToCartDialog called');
    // debugPrint('🛒🎯 Service ID: ${service.id}');

    // 🔧 重要修复：确保我们有最新的service details
    if (_serviceDetails.isEmpty) {
      // debugPrint('🔄 _serviceDetails为空，尝试从API加载最新数据...');
      try {
        final realServiceDetails =
            await api.ServiceDetailApiService.getAllServiceDetails(service.id);
        if (realServiceDetails.isNotEmpty) {
          _serviceDetails.assignAll(realServiceDetails
              .map((detail) => _convertToCoreServiceDetail(detail))
              .toList());
          // debugPrint('🔧 紧急更新_serviceDetails变量，长度: ${_serviceDetails.length}');
        }
      } catch (e) {
        // debugPrint('❌ 紧急加载失败: $e');
      }
    }

    // debugPrint('🛒🎯 最终Service Details count: ${_serviceDetails.length}');
    // debugPrint('🛒🎯 Service Details list: $_serviceDetails');

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '添加到购物车',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // 如果有service details，显示选择界面
            if (_serviceDetails.isNotEmpty) ...[
              Text('📋 显示Service Details选择界面 (${_serviceDetails.length}项)',
                  style: TextStyle(color: Colors.green, fontSize: 12)),
              SizedBox(height: 8),
              _buildServiceDetailsSelection(service),
            ] else ...[
              Text('⚠️ 没有Service Details，显示简单界面',
                  style: TextStyle(color: Colors.orange, fontSize: 12)),
              SizedBox(height: 8),
              _buildSimpleAddToCart(service),
            ],

            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text('取消'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _addMainServiceToCart(service),
                    child: Text('添加主服务'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建service details选择界面
  Widget _buildServiceDetailsSelection(Service service) {
    return Container(
      constraints: BoxConstraints(maxHeight: 300),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择具体服务项目：',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            ..._serviceDetails
                .map((detail) => _buildServiceDetailItem(service, detail))
                .toList(),
          ],
        ),
      ),
    );
  }

  /// 构建单个service detail项
  Widget _buildServiceDetailItem(
      Service service, core_services.ServiceDetail detail) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(detail.name['zh'] ?? detail.name['en'] ?? '未知项目'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (detail.price != null)
              Text(
                  '\$${detail.price!.toStringAsFixed(2)} ${detail.currency ?? 'CAD'}'),
            if (detail.attributes.containsKey('description'))
              Text(
                (detail.attributes['description']
                        as Map<String, dynamic>?)?['zh'] ??
                    (detail.attributes['description']
                        as Map<String, dynamic>?)?['en'] ??
                    '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: detail.isAvailable
              ? () => _addServiceDetailToCart(service, detail)
              : null,
          child: Text('添加'),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(60, 32),
          ),
        ),
        isThreeLine: detail.attributes.containsKey('description'),
      ),
    );
  }

  /// 构建简单添加界面（无service details时）
  Widget _buildSimpleAddToCart(Service service) {
    return Column(
      children: [
        Text(
          '将 ${_getServiceTitle(service)} 添加到购物车',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        if (service.price != null)
          Text(
            '价格: \$${service.price!.toStringAsFixed(2)} CAD',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
      ],
    );
  }

  /// 添加主服务到购物车
  Future<void> _addMainServiceToCart(Service service) async {
    bool isDialogShowing = false;
    try {
      Get.back(); // 关闭对话框

      // 显示加载指示器
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      isDialogShowing = true;
      // debugPrint('🔄 显示加载对话框');

      await _cartController.addServiceToCart(
        serviceId: service.id,
        serviceDetailId: 'main_service', // 使用特殊ID表示主服务
        quantity: 1,
      );

      if (isDialogShowing) {
        Get.back(); // 关闭加载对话框
        isDialogShowing = false;
        // debugPrint('✅ 关闭加载对话框 - 成功');
      }

      Get.snackbar(
        '添加成功',
        '${_getServiceTitle(service)} 已添加到购物车',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      if (isDialogShowing) {
        Get.back(); // 关闭加载对话框
        isDialogShowing = false;
        // debugPrint('❌ 关闭加载对话框 - 异常: $e');
      }

      Get.snackbar(
        '添加失败',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  /// 添加具体service detail到购物车
  Future<void> _addServiceDetailToCart(
      Service service, core_services.ServiceDetail detail) async {
    bool isDialogShowing = false;
    try {
      Get.back(); // 关闭对话框

      // 显示加载指示器
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      isDialogShowing = true;
      // debugPrint('🔄 显示加载对话框 - Service Detail');

      await _cartController.addServiceToCart(
        serviceId: service.id,
        serviceDetailId: detail.id,
        quantity: 1,
      );

      if (isDialogShowing) {
        Get.back(); // 关闭加载对话框
        isDialogShowing = false;
        // debugPrint('✅ 关闭加载对话框 - 成功');
      }

      Get.snackbar(
        '添加成功',
        '${detail.name['zh'] ?? detail.name['en'] ?? '服务项目'} 已添加到购物车',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      if (isDialogShowing) {
        Get.back(); // 关闭加载对话框
        isDialogShowing = false;
        // debugPrint('❌ 关闭加载对话框 - 异常: $e');
      }

      Get.snackbar(
        '添加失败',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  // ===== 辅助方法 =====

  /// 获取预订图标

  /// 获取预订标签

  /// 获取预订颜色

  /// 获取格式化价格
  String _getFormattedPrice(Service service) {
    final price = service.price;
    if (price != null && price > 0) {
      return '\$${price.toStringAsFixed(2)}';
    } else {
      return '询价';
    }
  }

  /// 获取服务标题
  String _getServiceTitle(Service service) {
    if (service.title is Map) {
      final titleMap = service.title as Map<String, dynamic>;
      return titleMap['zh'] ?? titleMap['en'] ?? 'Unknown Service';
    } else if (service.title is String) {
      return service.title as String;
    } else {
      return 'Unknown Service';
    }
  }

  // ===== 购物车相关方法 =====

  // 移除未使用的方法 _showCartOverview
  /*
  void _showCartOverview() {
    // debugPrint('🛒 点击全局购物车图标');
    
    // 获取当前购物车数据
    final cartItems = _cartController.cartItems;
    // debugPrint('🛒 当前购物车商品数量: ${cartItems.length}');
    
    if (cartItems.isEmpty) {
      Get.snackbar(
        '购物车',
        '购物车是空的，请先在菜单中添加商品',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    
    // 显示购物车内容的底部对话框
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
              color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 拖拽指示器
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // 标题栏
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '购物车 (${cartItems.length})',
                      style: const TextStyle(
                        fontSize: 18,
              fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        // TODO: 导航到完整的购物车页面
                        Get.snackbar('开发中', '完整购物车页面正在开发中');
                      },
                      child: const Text('查看全部'),
                  ),
                ],
              ),
              ),
              
              // 购物车商品列表
              Expanded(
                child: Obx(() => ListView.builder(
                  controller: scrollController,
                  itemCount: _cartController.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = _cartController.cartItems[index];
                    return _buildCartItemTile(item);
                  },
                )),
              ),
              
              // 底部操作栏
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '小计: \$${_calculateCartTotal().toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '共 ${cartItems.length} 件商品',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
          onPressed: () {
                        Get.back();
                        // TODO: 导航到结账页面
                        Get.snackbar('开发中', '结账功能正在开发中');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('去结账'),
                    ),
                  ],
                ),
              ),
            ],
          ),
            ),
      ),
    );
  }

  /// 构建购物车商品条目
  Widget _buildCartItemTile(CartItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
                children: [
          // 商品图片占位符
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.restaurant, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          
          // 商品信息
          Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              Text(
                  _getItemDisplayName(item),
            style: const TextStyle(
                    fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.unitPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // 数量和操作
          Column(
            children: [
              Text(
                '数量: ${item.quantity}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
              fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
            ],
          ),
    );
  }

  */

  String _getItemDisplayName(CartItem item) {
    try {
      if (item.itemNameSnapshot != null && item.itemNameSnapshot.isNotEmpty) {
        return item.itemNameSnapshot['zh'] ?? 
               item.itemNameSnapshot['en'] ?? 
               '服务项目';
      }
      return '服务项目';
    } catch (e) {
      return '服务项目';
    }
  }

  /// 计算购物车总价

  // ===== 待实现的方法（占位符） =====

  void _requestQuickQuote(Service service) {
    // TODO: 实现快速询价
    Get.snackbar('开发中', '快速询价功能正在开发中');
  }

  // ===== Tab Bar布局相关方法 =====

  // 暂时注释掉布局切换功能
  /*
  /// 获取当前布局模式对应的图标
  IconData _getLayoutIcon() {
    switch (_tabBarLayoutConfig.mode) {
      case TabBarLayoutMode.belowImage:
        return Icons.layers;
      case TabBarLayoutMode.overlayOnImage:
        return Icons.layers_outlined;
      case TabBarLayoutMode.compact:
        return Icons.compress;
    }
  }
  */

  /*
  /// 显示布局选项对话框
  void _showLayoutOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                const Text(
              'Tab栏布局模式',
                  style: TextStyle(
                    fontSize: 18,
                          fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildLayoutOptionTile(
              context,
              TabBarLayoutMode.belowImage,
              Icons.layers,
              '默认模式',
              '轮播图在上，Tab栏在下方',
            ),
            
            _buildLayoutOptionTile(
              context,
              TabBarLayoutMode.overlayOnImage,
              Icons.layers_outlined,
              '覆盖模式',
              'Tab栏浮动在轮播图上方',
            ),
            
            _buildLayoutOptionTile(
              context,
              TabBarLayoutMode.compact,
              Icons.compress,
              '紧凑模式',
              '减少轮播图高度，节省空间',
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// 构建布局选项列表项
  Widget _buildLayoutOptionTile(
    BuildContext context,
    TabBarLayoutMode mode,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = _tabBarLayoutConfig.mode == mode;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected 
            ? Theme.of(context).primaryColor 
            : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.black87,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected 
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).primaryColor,
            )
          : null,
      onTap: () {
        Navigator.of(context).pop();
        _switchToLayoutMode(mode);
      },
    );
  }

  /// 切换到指定布局模式
  void _switchToLayoutMode(TabBarLayoutMode mode) {
    setState(() {
      switch (mode) {
        case TabBarLayoutMode.belowImage:
          _tabBarLayoutConfig = TabBarLayoutConfig.defaultConfig;
          break;
        case TabBarLayoutMode.overlayOnImage:
          _tabBarLayoutConfig = TabBarLayoutConfig.overlayConfig;
          break;
        case TabBarLayoutMode.compact:
          _tabBarLayoutConfig = TabBarLayoutConfig.compactConfig;
          break;
      }
    });
    
    // debugPrint('🎨 切换到布局模式: ${mode.toString()}');
  }
  */

  /// 构建服务图片轮播组件
  Widget _buildServiceImageCarousel(Service service) {
    return Stack(
      children: [
        // Carousel images
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey[300],
          child: _hasRealImages(service)
              ? _buildServiceImages(service)
              : _buildPlaceholderImage(service),
        ),

        // Data source indicator (simplified logic)
        Positioned(
          top: 16,
          left: 16,
          child: Obx(() {
            // Use more direct detection logic
            final hasRealData = _serviceDetails.isNotEmpty &&
                _serviceDetails.any((detail) => !detail.id.contains('test_'));

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: hasRealData
                    ? Colors.green[100]!.withOpacity(0.9)
                    : Colors.orange[100]!.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: hasRealData ? Colors.green[300]! : Colors.orange[300]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasRealData ? Icons.check_circle : Icons.sim_card,
                    color: hasRealData ? Colors.green[700] : Colors.orange[700],
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    hasRealData ? '🟢 真实数据' : '🟠 模拟数据',
                    style: TextStyle(
                      color:
                          hasRealData ? Colors.green[700] : Colors.orange[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),

        // Image count indicator
        if (_hasRealImages(service)) ...[
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_getImageCount(service)} 张图片',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _requestDetailedQuote(Service service) {
    // TODO: 实现详细询价
    Get.snackbar('开发中', '详细询价功能正在开发中');
  }

  /// 获取图片数量
  int _getImageCount(Service service) {
    // TODO: 从service或service_details获取真实图片数量
    return 2; // 暂时返回固定值
  }

  /// 构建备用图片（当主图片加载失败时）
  Future<Widget> _buildFallbackImage(String originalUrl, Object error) async {
    // Generate fallback image URL list
    final fallbackUrls = _generateFallbackUrls(originalUrl);

    for (String fallbackUrl in fallbackUrls) {
      try {
        // Try to preload fallback image
        await precacheImage(NetworkImage(fallbackUrl), context);

        return Image.network(
          fallbackUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => _buildDefaultPlaceholder(),
        );
      } catch (e) {
        // Continue trying next fallback URL
        continue;
      }
    }

    // All fallback images failed, show default placeholder
    return _buildDefaultPlaceholder();
  }

  /// 生成备用图片URL
  List<String> _generateFallbackUrls(String originalUrl) {
    final List<String> fallbackUrls = [];

    // If original URL is picsum.photos, try different parameters
    if (originalUrl.contains('picsum.photos')) {
      final uri = Uri.parse(originalUrl);
      final pathSegments = uri.pathSegments;

      if (pathSegments.length >= 3) {
        final width = pathSegments[pathSegments.length - 2];
        final height = pathSegments[pathSegments.length - 1];

        // Try different seed values
        for (int i = 1; i <= 5; i++) {
          fallbackUrls
              .add('https://picsum.photos/seed/fallback$i/$width/$height');
        }

        // Try different sizes
        fallbackUrls.add('https://picsum.photos/$width/$height');
        fallbackUrls.add('https://picsum.photos/400/300');
      }
    }

    // Use available local resources as last resort
    // Temporarily not using local resources, use default placeholder

    return fallbackUrls;
  }

  /// 构建默认占位符
  Widget _buildDefaultPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '美食图片',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '精美图片加载中...',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _startNegotiationChat(Service service) {
    // TODO: 实现议价聊天
    Get.snackbar('开发中', '议价聊天功能正在开发中');
  }
}
