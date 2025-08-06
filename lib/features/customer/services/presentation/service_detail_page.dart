import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';
import '../../../../core/ui/components/customer_theme_components.dart';
import '../../../../core/utils/app_logger.dart';
import 'service_detail_controller.dart';
import 'widgets/service_detail_loading.dart';
import 'sections/service_basic_info_section.dart';
import 'sections/service_actions_section.dart';
import 'sections/service_map_section.dart';
import 'models/service_detail_state.dart';
import 'sections/similar_services_section.dart';
import 'sections/service_reviews_section.dart';
import 'sections/provider_details_section.dart';
import 'dialogs/service_quote_dialog.dart';
import 'dialogs/service_schedule_dialog.dart';
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
  // 恢复原有的变量声明
  late TabController _tabController;
  late ServiceDetailController controller;
  final ServiceDetailState state = ServiceDetailState();
  final LoadingStateManager _loadingManager = LoadingStateManager();
  bool _isOnline = true;
  bool _useSkeleton = true; // 是否使用骨架屏

  @override
  void initState() {
    super.initState();
    
    // 获取最终的serviceId - 优先从Get.parameters获取，如果为空则使用widget.serviceId
    String finalServiceId = '';
    
    // 首先尝试从Get.parameters获取
    if (Get.parameters.containsKey('serviceId') && Get.parameters['serviceId'] != null && Get.parameters['serviceId']!.isNotEmpty) {
      finalServiceId = Get.parameters['serviceId']!;
      AppLogger.debug('Retrieved serviceId from Get.parameters: "$finalServiceId"', tag: 'ServiceDetailPage');
    }
    
    // 如果Get.parameters中没有，则使用widget.serviceId
    if (finalServiceId.isEmpty && widget.serviceId.isNotEmpty) {
      finalServiceId = widget.serviceId;
      AppLogger.debug('Using serviceId from widget: "$finalServiceId"', tag: 'ServiceDetailPage');
    }
    
    AppLogger.info('ServiceDetailPage initialized with serviceId: $finalServiceId', tag: 'ServiceDetailPage');
    AppLogger.debug('ServiceDetailPage final serviceId: "$finalServiceId"', tag: 'ServiceDetailPage');
    AppLogger.debug('serviceId length: ${finalServiceId.length}', tag: 'ServiceDetailPage');
    AppLogger.debug('serviceId isEmpty: ${finalServiceId.isEmpty}', tag: 'ServiceDetailPage');
    
    if (finalServiceId.isEmpty) {
      AppLogger.warning('ServiceId is still empty after all attempts', tag: 'ServiceDetailPage');
      AppLogger.warning('ServiceId is empty, showing error state', tag: 'ServiceDetailPage');
    } else {
      AppLogger.debug('SUCCESS - Final serviceId: "$finalServiceId"', tag: 'ServiceDetailPage');
    }
    
    controller = Get.put(ServiceDetailController());
    _tabController = TabController(length: 5, vsync: this);
    
    // 如果serviceId不为空，则加载服务详情
    if (finalServiceId.isNotEmpty) {
      _loadServiceDetailWithId(finalServiceId);
    } else {
      _loadingManager.setError('Service ID is required');
    }
    
    _checkNetworkStatus();
  }

  @override
  void dispose() {
    AppLogger.debug('ServiceDetailPage disposed', tag: 'ServiceDetailPage');
    _tabController.dispose();
    _loadingManager.dispose();
    super.dispose();
  }

  /// 检查网络状态
  void _checkNetworkStatus() {
    AppLogger.debug('Checking network status', tag: 'ServiceDetailPage');
    // TODO: 实现实际的网络状态检查
    // 这里可以集成connectivity_plus包或其他网络状态检测库
    
    // 模拟网络状态检查
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isOnline = DateTime.now().millisecond % 2 == 0;
        });
        if (_isOnline) {
          _loadingManager.setOnline();
          AppLogger.info('Network status: Online', tag: 'ServiceDetailPage');
        } else {
          _loadingManager.setOffline();
          AppLogger.warning('Network status: Offline', tag: 'ServiceDetailPage');
        }
      }
    });
  }

  Future<void> _loadServiceDetailWithId(String serviceId) async {
    if (serviceId.isEmpty) {
      AppLogger.warning('ServiceId is empty, showing error state', tag: 'ServiceDetailPage');
      _loadingManager.setError('Service ID is required');
      return;
    }

    try {
      _loadingManager.setLoading();
      await controller.loadServiceDetail(serviceId);
      _loadingManager.setSuccess();
      AppLogger.info('Service detail loaded successfully', tag: 'ServiceDetailPage');
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      AppLogger.error('Failed to load service detail: $e', tag: 'ServiceDetailPage');
      throw Exception(l10n?.serviceDetailsLoadFailed ?? 'Service details load failed: ${e.toString()}');
    }
  }

  // 保留原有的方法，但暂时不使用
  // Future<void> _loadServiceDetail() async {
  //   // 获取最终的serviceId
  //   String finalServiceId = widget.serviceId;
  //   if (finalServiceId.isEmpty && Get.parameters.containsKey('serviceId')) {
  //     finalServiceId = Get.parameters['serviceId'] ?? '';
  //     print('DEBUG: _loadServiceDetail - Retrieved serviceId from Get.parameters: "$finalServiceId"');
  //   }
  //   
  //   AppLogger.info('Loading service detail for serviceId: $finalServiceId', tag: 'ServiceDetailPage');
  //   
  //   // Check if serviceId is empty or null
  //   if (finalServiceId.isEmpty) {
  //     AppLogger.warning('ServiceId is empty, showing error state', tag: 'ServiceDetailPage');
  //     _loadingManager.setError('Service ID is required');
  //     return;
  //   }
  //   
  //   await _loadingManager.retry(() async {
  //     try {
  //       // 减少模拟延迟时间
  //       await Future.delayed(const Duration(milliseconds: 500));
  //       await controller.loadServiceDetail(finalServiceId);
  //       state.service.value = controller.service.value;
  //       state.serviceDetail.value = controller.serviceDetail.value;
  //       AppLogger.info('Service detail loaded successfully', tag: 'ServiceDetailPage');
  //     } catch (e) {
  //       AppLogger.error('Failed to load service detail: $e', tag: 'ServiceDetailPage');
  //       throw Exception(AppLocalizations.of(context)?.serviceDetailsLoadFailed ?? '服务详情加载失败: ${e.toString()}');
  //     }
  //   });
  // }

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
      body: ListenableBuilder(
        listenable: _loadingManager,
        builder: (context, child) {
          AppLogger.debug('DEBUG: ListenableBuilder called with state: ${_loadingManager.state}', tag: 'ServiceDetailPage');
          return ServiceDetailLoading(
            state: _loadingManager.state,
            loadingMessage: l10n?.loadingServiceDetails ?? 'Loading service details...',
            errorMessage: _loadingManager.errorMessage,
            onRetry: () => _loadServiceDetailWithId(widget.serviceId.isNotEmpty ? widget.serviceId : Get.parameters['serviceId'] ?? ''),
            onBack: () => Get.back(),
            showSkeleton: _useSkeleton, // 恢复骨架屏选项
            child: OfflineSupportWidget(
              isOnline: _isOnline,
              onRetry: () => _loadServiceDetailWithId(widget.serviceId.isNotEmpty ? widget.serviceId : Get.parameters['serviceId'] ?? ''),
              offlineMessage: 'Currently offline, showing cached data',
              child: _buildPageContent(), // 恢复原有的页面内容
            ),
          );
        },
      ),
    );
  }

  // 简化版本的内容
  Widget _buildSimplifiedPageContent() {
    AppLogger.debug('DEBUG: _buildSimplifiedPageContent() called', tag: 'ServiceDetailPage');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 服务基本信息 - 渐进式加载
          ProgressiveLoadingWidget(
            delay: const Duration(milliseconds: 100),
            child: _buildServiceBasicInfo(),
          ),
          const SizedBox(height: 24),
          
          // 服务描述 - 渐进式加载
          ProgressiveLoadingWidget(
            delay: const Duration(milliseconds: 200),
            child: _buildServiceDescription(),
          ),
          const SizedBox(height: 24),
          
          // 服务图片 - 渐进式加载
          ProgressiveLoadingWidget(
            delay: const Duration(milliseconds: 300),
            child: _buildServiceImages(),
          ),
          const SizedBox(height: 24),
          
          // 操作按钮 - 渐进式加载
          ProgressiveLoadingWidget(
            delay: const Duration(milliseconds: 400),
            child: _buildActionButtons(),
          ),
          const SizedBox(height: 24),
          
          // 服务详情 - 渐进式加载
          ProgressiveLoadingWidget(
            delay: const Duration(milliseconds: 500),
            child: _buildServiceDetails(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceBasicInfo() {
    final l10n = AppLocalizations.of(context);
    return Obx(() {
      final service = controller.service.value;
      if (service == null) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n?.loadingServiceDetails ?? 'Loading...'),
          ),
        );
      }
      
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.title ?? (l10n?.serviceName ?? 'Unknown Service'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${service.rating?.toStringAsFixed(1) ?? '0.0'} (${service.reviewCount ?? 0} ${l10n?.reviews ?? 'reviews'})',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${l10n?.price ?? 'Price'}: \$${service.price?.toStringAsFixed(2) ?? '0.00'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildServiceDescription() {
    final l10n = AppLocalizations.of(context);
    return Obx(() {
      final service = controller.service.value;
      if (service == null) return const SizedBox.shrink();
      
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.serviceDescription ?? 'Service Description',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                service.description ?? (l10n?.noData ?? 'No Data'),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildServiceImages() {
    final l10n = AppLocalizations.of(context);
    return Obx(() {
      final service = controller.service.value;
      if (service == null || service.images == null || service.images!.isEmpty) {
        return const SizedBox.shrink();
      }
      
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Service Images',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: service.images!.length,
                  itemBuilder: (context, index) {
                    final imageUrl = service.images![index];
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
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
                        AppLogger.debug('DEBUG: Image loading failed for URL: $imageUrl, error: $error', tag: 'ServiceDetailPage');
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActionButtons() {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.snackbar(
                    'Notification', 
                    'Booking feature coming soon'
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  l10n?.bookNow ?? 'Book Now',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.snackbar(
                        'Notification', 
                        'Contact service coming soon'
                      );
                    },
                    child: Text(l10n?.contactProvider ?? 'Contact Provider'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.snackbar(
                        'Notification', 
                        'Share feature coming soon'
                      );
                    },
                    child: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetails() {
    final l10n = AppLocalizations.of(context);
    return Obx(() {
      final serviceDetail = controller.serviceDetail.value;
      if (serviceDetail == null) return const SizedBox.shrink();
      
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.serviceInformation ?? 'Service Information',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailItem(l10n?.serviceDuration ?? 'Service Duration', '${serviceDetail.duration} ${serviceDetail.durationType}'),
              _buildDetailItem(l10n?.serviceArea ?? 'Service Area', serviceDetail.serviceAreaCodes?.join(', ') ?? (l10n?.noData ?? 'No Data')),
              _buildDetailItem(l10n?.tags ?? 'Tags', serviceDetail.tags?.join(', ') ?? (l10n?.noData ?? 'No Data')),
              if (serviceDetail.negotiationDetails != null)
                _buildDetailItem(l10n?.priceInformation ?? 'Price Information', serviceDetail.negotiationDetails!),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 原有业务逻辑（注释保留） ====================
  
  // 原有的复杂页面内容构建方法
  Widget _buildPageContent() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          _buildSliverAppBar(),
          _buildSliverTabBar(),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildDetailsTab(),
          _buildProviderTab(),
          _buildReviewsTab(),
          _buildPersonalizedTab(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Obx(() {
          final service = controller.service.value;
          if (service == null || service.images == null || service.images!.isEmpty) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 100, color: Colors.grey),
            );
          }
          
          return PageView.builder(
            itemCount: service.images!.length,
            itemBuilder: (context, index) {
              final imageUrl = service.images![index];
              return Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[300],
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
                  AppLogger.debug('DEBUG: Image loading failed for URL: $imageUrl, error: $error', tag: 'ServiceDetailPage');
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                  );
                },
              );
            },
          );
        }),
        title: Obx(() {
          final service = controller.service.value;
          return Text(
            service?.title ?? 'Service Details',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3,
                  color: Colors.black54,
                ),
              ],
            ),
          );
        }),
      ),
      actions: [
        IconButton(
          icon: Obx(() => Icon(
            controller.isFavorite.value ? Icons.favorite : Icons.favorite_border,
            color: controller.isFavorite.value ? Colors.red : Colors.white,
          )),
          onPressed: () => controller.toggleFavorite(),
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            Get.snackbar('Share', 'Share feature coming soon');
          },
        ),
      ],
    );
  }

  Widget _buildSliverTabBar() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: colorScheme.primary,
          indicatorWeight: 2,
          labelStyle: theme.textTheme.labelMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          labelPadding: const EdgeInsets.symmetric(vertical: 8),
          tabs: [
            Tab(text: l10n?.overview ?? 'Overview'),
            Tab(text: l10n?.details ?? 'Details'),
            Tab(text: l10n?.provider ?? 'Provider'),
            Tab(text: l10n?.reviews ?? 'Reviews'),
            Tab(text: l10n?.forYou ?? 'For You'),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 服务基本信息 - 渐进式加载
          ProgressiveLoadingWidget(
            delay: const Duration(milliseconds: 100),
            child: ServiceBasicInfoSection(controller: controller),
          ),
          const SizedBox(height: 16),
          
          // 操作按钮 - 渐进式加载
          ProgressiveLoadingWidget(
            delay: const Duration(milliseconds: 200),
            child: ServiceActionsSection(controller: controller),
          ),
          const SizedBox(height: 16),
          
          // 服务特色 - 渐进式加载
          ProgressiveLoadingWidget(
            delay: const Duration(milliseconds: 300),
            child: _buildServiceFeaturesSection(),
          ),
          const SizedBox(height: 16),
          
          // 质量保证 - 渐进式加载
          ProgressiveLoadingWidget(
            delay: const Duration(milliseconds: 400),
            child: _buildQualityAssuranceSection(),
          ),
          const SizedBox(height: 16),
          
          // 地图 - 渐进式加载
          ProgressiveLoadingWidget(
            delay: const Duration(milliseconds: 500),
            child: ServiceMapSection(controller: controller),
          ),
          const SizedBox(height: 16),
          
          // 相似服务 - 渐进式加载
          ProgressiveLoadingWidget(
            delay: const Duration(milliseconds: 600),
            child: SimilarServicesSection(controller: controller),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceFeaturesSection() {
    final l10n = AppLocalizations.of(context);
    return CustomerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.serviceFeatures ?? 'Service Features',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n?.noData ?? 'No Data'),
        ],
      ),
    );
  }

  Widget _buildQualityAssuranceSection() {
    final l10n = AppLocalizations.of(context);
    return CustomerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.qualityAssurance ?? 'Quality Assurance',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n?.noData ?? 'No Data'),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Service Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // 服务详情内容
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ProviderDetailsSection(controller: controller),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ServiceReviewsSection(controller: controller),
        ],
      ),
    );
  }

  Widget _buildPersonalizedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SimilarServicesSection(controller: controller),
        ],
      ),
    );
  }
}

class ServiceDetailError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ServiceDetailError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height + 16;

  @override
  double get maxExtent => _tabBar.preferredSize.height + 16;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
