import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';

import '../../../../core/services/services.dart' as core_services;
import '../../domain/entities/service.dart';
import 'widgets/service_detail_card.dart';
import 'widgets/service_detail_error.dart';
import 'widgets/provider_info_card.dart';
import 'widgets/review_list_card.dart';
import 'widgets/dynamic_tab_builder.dart';
import 'service_detail_controller.dart';
import 'utils/professional_remarks_templates.dart';

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
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ServiceDetailController controller;
  
  // 新服务架构集成
  late core_services.ServiceManager _serviceManager;
  late core_services.DynamicTabConfigService _dynamicTabService;
  List<core_services.ServiceDetail> _serviceDetails = [];
  bool _isNewServiceInitialized = false;

  @override
  void initState() {
    super.initState();
    // 初始化TabController，使用固定的5个Tab页长度
    _tabController = TabController(length: 5, vsync: this);
    
    // 安全初始化controller
    controller = Get.put(ServiceDetailController());
    
    // 初始化新服务架构
    _initializeNewServices();
    
    // 延迟加载数据，避免初始化冲突
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
      _serviceManager = core_services.ServiceManager.instance;
      _dynamicTabService = core_services.DynamicTabConfigService();
      
      // 初始化服务管理器
      if (!_serviceManager.isInitialized) {
        await _serviceManager.initializeServices();
      }
      
      _isNewServiceInitialized = true;
      debugPrint('New services initialized successfully');
    } catch (e) {
      debugPrint('Error initializing new services: $e');
    }
  }

  Future<void> _loadServiceDetail(String serviceId) async {
    try {
      await controller.loadServiceDetail(serviceId);
      
      // 如果新服务已初始化，加载服务详情
      if (_isNewServiceInitialized) {
        await _loadServiceDetails(serviceId);
      }
    } catch (e) {
      debugPrint('Error loading service detail: $e');
    }
  }

  Future<void> _loadServiceDetails(String serviceId) async {
    try {
      if (_serviceManager.serviceDetailService != null) {
        _serviceDetails = await _serviceManager.serviceDetailService!.getServiceDetails(serviceId);
        debugPrint('Loaded ${_serviceDetails.length} service details');
        
        // 更新TabController长度以匹配动态Tab数量
        _updateTabControllerLength();
      }
    } catch (e) {
      debugPrint('Error loading service details: $e');
    }
  }

  void _updateTabControllerLength() {
    if (_isNewServiceInitialized && _serviceDetails.isNotEmpty) {
      final service = controller.service.value;
      if (service != null) {
        // 转换Service到core_services.Service
        final coreService = _convertToCoreService(service);
        final tabConfig = _dynamicTabService.getTabConfig(coreService, _serviceDetails);
        
        if (tabConfig.length != _tabController.length) {
          setState(() {
            _tabController = TabController(
              length: tabConfig.length,
              vsync: this,
            );
          });
        }
      }
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
      categoryId: service.categoryLevel1Id ?? '',
      categoryLevel1Id: service.categoryLevel1Id ?? '',
      categoryLevel2Id: service.categoryLevel2Id ?? '',
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
    );
  }

  Widget _buildPageContent(Service service, AppLocalizations? l10n) {
    return Column(
      children: [
        // 简化的图片头部
        _buildSimpleImageHeader(service),
        
        // 使用新的动态Tab系统
        Expanded(
          child: _buildNewDynamicTabSystem(service),
        ),
      ],
    );
  }

  Widget _buildNewDynamicTabSystem(Service service) {
    if (!_isNewServiceInitialized || _serviceDetails.isEmpty) {
      // 回退到旧的Tab系统
      return DynamicTabBuilder(
        service: service,
        tabController: _tabController,
      );
    }

    // 使用新的动态Tab配置服务
    final coreService = _convertToCoreService(service);
    final tabConfig = _dynamicTabService.getTabConfig(coreService, _serviceDetails);
    
    return Column(
      children: [
        // 动态Tab栏
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 2,
            tabAlignment: TabAlignment.start,
            tabs: tabConfig.map((tab) {
              return Tab(
                icon: Icon(tab['icon'] as IconData, size: 20),
                text: tab['title'] as String,
              );
            }).toList(),
          ),
        ),
        
        // 动态Tab内容
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: tabConfig.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              
              // 使用DynamicTabConfigService的内容构建器
              final contentBuilder = _dynamicTabService.getTabContentBuilder(coreService, _serviceDetails);
              return contentBuilder(context, index);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleImageHeader(Service service) {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey[300],
      child: service.images?.isNotEmpty == true
          ? _buildServiceImages(service)
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 80, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Service Image', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
    );
  }

  Widget _buildServiceImages(Service service) {
    if (service.images == null || service.images!.isEmpty) {
      return const Center(
        child: Icon(Icons.image, size: 80, color: Colors.grey),
      );
    }

    return PageView.builder(
      itemCount: service.images!.length,
      itemBuilder: (context, index) {
        final imageUrl = service.images![index];
        
        // 检查并处理问题URL
        if (imageUrl.isEmpty || 
            imageUrl.contains('via.placeholder.com') ||
            imageUrl.contains('example.com')) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 80, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Image not available', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }
        
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }

  Widget _buildSimpleTabBar(AppLocalizations? l10n) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
        indicatorWeight: 2,
        tabAlignment: TabAlignment.start,
        tabs: [
          Tab(text: l10n?.overview ?? 'Overview'),
          Tab(text: l10n?.details ?? 'Details'),
          Tab(text: l10n?.provider ?? 'Provider'),
          Tab(text: l10n?.reviews ?? 'Reviews'),
          Tab(text: l10n?.forYou ?? 'For You'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(Service service) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 基本信息
          ServiceDetailCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title ?? 'Untitled Service',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (service.description.isNotEmpty == true)
                  Text(
                    service.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: 16),
                
                // 价格信息
                Row(
                  children: [
                    const Icon(Icons.attach_money, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      '\$${service.price?.toStringAsFixed(2) ?? '0.00'}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      service.pricingType ?? 'fixed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 评分信息
                if (service.rating != null)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        service.rating!.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${service.reviewCount ?? 0} reviews)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          _buildServiceFeaturesSection(service),
        ],
      ),
    );
  }

  Widget _buildServiceFeaturesSection(Service service) {
    try {
      final serviceType = _getServiceType(service);
      final providerData = _getProviderData();
      final features = ProfessionalRemarksTemplates.getServiceFeatures(serviceType, providerData);

      return ServiceDetailSection(
        title: 'Service Features',
        icon: Icons.star,
        iconColor: Colors.orange[600],
        content: Column(
          children: features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  feature.icon,
                  color: feature.color,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feature.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      );
    } catch (e) {
      debugPrint('Error building service features: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildDetailsTab(Service service) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceDetailsSection(service),
        ],
      ),
    );
  }

  Widget _buildServiceDetailsSection(Service service) {
    return ServiceDetailSection(
      title: 'Service Details',
      icon: Icons.info_outline,
      iconColor: Colors.blue[600],
      content: Column(
        children: [
          ServiceDetailRow(
            label: 'Category',
            value: _getCategoryName(service.categoryId ?? '0'),
            icon: Icons.category,
          ),
          if (service.description.isNotEmpty == true)
            ServiceDetailRow(
              label: 'Description',
              value: service.description,
              icon: Icons.description,
            ),
          ServiceDetailRow(
            label: 'Delivery Method',
            value: _getDeliveryMethodName(service.serviceDeliveryMethod ?? 'unknown'),
            icon: Icons.local_shipping,
          ),
          if (service.rating != null)
            ServiceDetailRow(
              label: 'Rating',
              value: '${service.rating!.toStringAsFixed(1)} stars',
              icon: Icons.star,
            ),
        ],
      ),
    );
  }

  Widget _buildProviderTab() {
    return Obx(() {
      if (controller.isLoadingProvider.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      final provider = controller.providerProfile.value;
      if (provider == null) {
        return const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: ServiceDetailCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Provider Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Provider information not available.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }
      
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ProviderInfoCard(
          provider: provider,
          onContact: () {
            // TODO: 实现联系提供商功能
            Get.snackbar(
              'Contact',
              'Contacting provider...',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          onViewProfile: () {
            // TODO: 实现查看提供商资料功能
            Get.snackbar(
              'View Profile',
              'Opening provider profile...',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      );
    });
  }

  Widget _buildReviewsTab() {
    return Obx(() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ReviewListCard(
          reviews: controller.reviews,
          currentSort: controller.currentReviewSort.value,
          filters: controller.reviewFilters,
          onSortChanged: controller.updateReviewSort,
          onFilterChanged: controller.updateReviewFilter,
          onWriteReview: () {
            // TODO: 实现写评价功能
            Get.snackbar(
              'Write Review',
              'Opening review form...',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          isLoading: controller.isLoadingReviews.value,
        ),
      );
    });
  }

  Widget _buildPersonalizedTab() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ServiceDetailCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personalized Recommendations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Personalized content will be displayed here.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 辅助方法
  String _getServiceType(Service service) {
    final categoryId = service.categoryId ?? '0';
    switch (categoryId) {
      case '1020000':
        return 'cleaning';
      case '1010000':
        return 'food';
      case '1030000':
        return 'transportation';
      case '1040000':
        return 'general';
      case '1050000':
        return 'education';
      case '1060000':
        return 'technology';
      default:
        return 'general';
    }
  }

  Map<String, dynamic>? _getProviderData() {
    try {
      return controller.providerProfile.value?.toJson();
    } catch (e) {
      debugPrint('Error getting provider data: $e');
      return null;
    }
  }

  String _getCategoryName(String categoryId) {
    switch (categoryId) {
      case '1020000':
        return 'Home Services';
      case '1010000':
        return 'Food Services';
      case '1030000':
        return 'Transportation';
      case '1040000':
        return 'General Services';
      case '1050000':
        return 'Education';
      case '1060000':
        return 'Technology';
      default:
        return 'Unknown Category';
    }
  }

  String _getDeliveryMethodName(String method) {
    switch (method.toLowerCase()) {
      case 'on_site':
        return 'On-site Service';
      case 'online':
        return 'Online Service';
      case 'remote':
        return 'Remote Service';
      default:
        return 'Standard Delivery';
    }
  }
}
