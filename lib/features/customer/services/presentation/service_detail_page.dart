import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/services/presentation/service_detail_controller.dart';
import 'package:jinbeanpod_83904710/core/ui/components/customer_theme_components.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/customer_theme_utils.dart';
import 'package:jinbeanpod_83904710/features/customer/services/services/service_detail_api_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ServiceDetailPage extends StatefulWidget {
  const ServiceDetailPage({super.key});

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _getCachedTab(int index, ServiceDetailController controller, ThemeData theme) {
    // 直接返回Tab内容，不使用缓存
    return _buildTabContent(index, controller, theme);
  }

  Widget _buildTabContent(int index, ServiceDetailController controller, ThemeData theme) {
    switch (index) {
      case 0:
        return _buildOverviewTab(controller, theme);
      case 1:
        return _buildDetailsTab(controller, theme);
      case 2:
        return _buildReviewsTab(controller, theme);
      case 3:
        return _buildProviderTab(controller, theme);
      case 4:
        return _buildPersonalizedTab(controller, theme);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: GetBuilder<ServiceDetailController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading service details...'),
                ],
              ),
            );
          }

          if (controller.service == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Service not found'),
                ],
              ),
            );
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildSliverAppBar(controller, theme),
                _buildSliverTabBar(theme),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                GetBuilder<ServiceDetailController>(
                  builder: (controller) => _buildOverviewTab(controller, theme),
                ),
                GetBuilder<ServiceDetailController>(
                  builder: (controller) => _buildDetailsTab(controller, theme),
                ),
                GetBuilder<ServiceDetailController>(
                  builder: (controller) => _buildReviewsTab(controller, theme),
                ),
                GetBuilder<ServiceDetailController>(
                  builder: (controller) => _buildProviderTab(controller, theme),
                ),
                GetBuilder<ServiceDetailController>(
                  builder: (controller) => _buildPersonalizedTab(controller, theme),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildSliverAppBar(ServiceDetailController controller, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(
            controller.isFavorite.value ? Icons.favorite : Icons.favorite_border,
            color: controller.isFavorite.value ? Colors.red : null,
          ),
          onPressed: () {
            Get.find<ServiceDetailController>().toggleFavorite();
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            Get.find<ServiceDetailController>().shareService();
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeroSection(controller, theme),
      ),
    );
  }

  Widget _buildHeroSection(ServiceDetailController controller, ThemeData theme) {
    final images = controller.serviceDetail?.images ?? [];
    
    return Stack(
      children: [
        // 服务图片
        Container(
          width: double.infinity,
          height: 300,
          child: images.isNotEmpty
              ? PageView.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(64),
                          bottomLeft: const Radius.circular(16),
                          bottomRight: const Radius.circular(16),
                        ),
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 64,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(64),
                      bottomLeft: const Radius.circular(16),
                      bottomRight: const Radius.circular(16),
                    ),
                    color: Colors.grey[200],
                  ),
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: Colors.grey,
                  ),
                ),
        ),
        
        // 渐变遮罩
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ),
        
        // 服务信息覆盖层
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.service?.title ?? 'Service Title',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 20,
                    color: Colors.amber[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${controller.service?.averageRating.toStringAsFixed(1) ?? '0.0'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${controller.service?.reviewCount ?? 0} reviews)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      controller.service?.status ?? 'Active',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 快速操作按钮
              Row(
                children: [
                  // 报价按钮 - 突出显示
                  if (controller.serviceDetail?.pricingType == 'custom' || 
                      controller.serviceDetail?.pricingType == 'negotiable') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showQuickQuoteDialog(controller),
                        icon: const Icon(Icons.request_quote, size: 18),
                        label: const Text('Get Quote'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(8),
                              topRight: const Radius.circular(32),
                              bottomLeft: const Radius.circular(8),
                              bottomRight: const Radius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  
                  // 联系按钮
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _startChat(controller),
                      icon: const Icon(Icons.chat, size: 18),
                      label: const Text('Chat'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(8),
                            topRight: const Radius.circular(32),
                            bottomLeft: const Radius.circular(8),
                            bottomRight: const Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliverTabBar(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return SliverPersistentHeader(
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Details'),
            Tab(text: 'Reviews'),
            Tab(text: 'Provider'),
            Tab(text: 'For You'),
          ],
        ),
      ),
      pinned: true,
    );
  }

  Widget _buildOverviewTab(ServiceDetailController controller, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 价格信息
          _buildPricingSection(controller, theme),
          const SizedBox(height: 16),
          
          // 服务描述
          _buildDescriptionSection(controller, theme),
          const SizedBox(height: 16),
          
          // 服务时间
          _buildServiceTimeSection(controller, theme),
          const SizedBox(height: 16),
          
          // 增强的地图组件
          _buildEnhancedMapSection(controller, theme),
          const SizedBox(height: 16),
          
          // 服务区域信息
          _buildSimplifiedServiceAreaInfo(controller, theme),
          
          const SizedBox(height: 12),
          
          // 导航操作按钮
          _buildNavigationActions(controller, theme),
          
          const SizedBox(height: 24),
          
          // 核心操作区域 - 整合报价、预订、联系功能
          _buildCoreActionsSection(controller, theme),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(ServiceDetailController controller, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 服务详情
          _buildServiceDetails(controller, theme),
          const SizedBox(height: 16),
          
          // 标签 - 只在有数据时显示
          if (controller.serviceDetail?.tags.isNotEmpty == true) ...[
            _buildTagsSection(controller, theme),
            const SizedBox(height: 16),
          ],
          
          // 服务区域
          _buildServiceAreaSection(controller, theme),
          const SizedBox(height: 16),
          
          // 信任和安全信息
          _buildTrustAndSecuritySection(controller, theme),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(ServiceDetailController controller, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 评价统计
          _buildReviewStats(controller, theme),
          const SizedBox(height: 16),
          
          // 评价列表
          if (controller.isLoadingReviews.value && controller.reviews.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            _buildReviewList(controller, theme),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProviderTab(ServiceDetailController controller, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 提供商详细信息
          _buildDetailedProviderSection(controller, theme),
          const SizedBox(height: 16),
          
          // 提供商组合 - 只在有数据时显示
          if (controller.providerPortfolio.isNotEmpty) ...[
            _buildProviderPortfolio(controller, theme),
            const SizedBox(height: 16),
          ],
          
          // 信任和安全信息
          _buildTrustAndSecuritySection(controller, theme),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPersonalizedTab(ServiceDetailController controller, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 个性化推荐标题
          _buildPersonalizedHeader(theme),
          const SizedBox(height: 16),
          
          // 相似服务推荐 - 迁移到For you tab
          if (controller.similarServices.isNotEmpty) ...[
            _buildSimilarServicesSection(controller, theme),
            const SizedBox(height: 16),
          ],
          
          // 个性化洞察
          _buildPersonalizedInsights(controller, theme),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // 新增：个性化洞察组件
  Widget _buildPersonalizedInsights(ServiceDetailController controller, ThemeData theme) {
    return CustomerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Personalized Insights',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              'Service Quality',
              'High customer satisfaction rate: 96%',
              Icons.thumb_up,
              Colors.green,
              theme,
            ),
            const SizedBox(height: 8),
            _buildInsightItem(
              'Response Time',
              'Average response time: 2 hours',
              Icons.speed,
              Colors.blue,
              theme,
            ),
            const SizedBox(height: 8),
            _buildInsightItem(
              'Reliability',
              '99% on-time service completion rate',
              Icons.timer,
              Colors.orange,
              theme,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'More personalized recommendations coming soon!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicPersonalizedContent(ServiceDetailController controller, ThemeData theme) {
    return CustomerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Personalized Insights',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              'Service Quality',
              'High customer satisfaction rate: 96%',
              Icons.thumb_up,
              Colors.green,
              theme,
            ),
            const SizedBox(height: 8),
            _buildInsightItem(
              'Response Time',
              'Average response time: 2 hours',
              Icons.speed,
              Colors.blue,
              theme,
            ),
            const SizedBox(height: 8),
            _buildInsightItem(
              'Reliability',
              '99% on-time service completion rate',
              Icons.timer,
              Colors.orange,
              theme,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Personalized recommendations will be available soon!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedHeader(ThemeData theme) {
    return CustomerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Personalized for You',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Based on your preferences and browsing history, we\'ve curated these recommendations just for you.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryBasedRecommendations(ServiceDetailController controller, ThemeData theme) {
    return CustomerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Based on Your History',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRecommendationItem(
              'You frequently book cleaning services',
              'Consider our premium cleaning package',
              Icons.cleaning_services,
              Colors.blue,
              theme,
            ),
            const SizedBox(height: 8),
            _buildRecommendationItem(
              'You prefer eco-friendly options',
              'This provider uses 100% eco-friendly products',
              Icons.eco,
              Colors.green,
              theme,
            ),
            const SizedBox(height: 8),
            _buildRecommendationItem(
              'You often book during weekends',
              'Weekend availability confirmed',
              Icons.weekend,
              Colors.orange,
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection(ServiceDetailController controller, ThemeData theme) {
    final pricingType = controller.serviceDetail?.pricingType ?? 'custom';
    
    switch (pricingType) {
      case 'hourly':
      case 'fixed':
        return _buildFixedPriceCard(controller, theme);
      case 'custom':
      case 'negotiable':
      default:
        return _buildQuoteRequestCard(controller, theme);
    }
  }

  Widget _buildFixedPriceCard(ServiceDetailController controller, ThemeData theme) {
    return CustomerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pricing',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (controller.serviceDetail?.negotiationDetails != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Negotiable',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '\$${controller.serviceDetail?.price?.toStringAsFixed(2) ?? '0.00'}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  controller.serviceDetail?.pricingType == 'hourly' ? '/hour' : '/service',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (controller.serviceDetail?.duration != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Duration: ${_formatDuration(controller.serviceDetail!.duration!)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            if (controller.serviceDetail?.negotiationDetails != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.serviceDetail!.negotiationDetails!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteRequestCard(ServiceDetailController controller, ThemeData theme) {
    return CustomerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.request_quote, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Request Quote',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(6),
                      topRight: const Radius.circular(24),
                      bottomLeft: const Radius.circular(6),
                      bottomRight: const Radius.circular(6),
                    ),
                  ),
                  child: Text(
                    'Custom Quote',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Get a personalized quote for your specific requirements. The provider will review your request and respond within 24 hours.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            
            // 报价状态指示器
            if (controller.quoteRequestStatus != null) ...[
              _buildQuoteStatusIndicator(controller, theme),
              const SizedBox(height: 16),
            ],
            
            // 报价表单
            _buildQuoteForm(controller, theme),
            const SizedBox(height: 16),
            
            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _submitQuoteRequest(controller),
                    icon: const Icon(Icons.send),
                    label: const Text('Request Quote'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(8),
                          topRight: const Radius.circular(32),
                          bottomLeft: const Radius.circular(8),
                          bottomRight: const Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _startChat(controller),
                    icon: const Icon(Icons.chat),
                    label: const Text('Chat First'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(color: theme.colorScheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(8),
                          topRight: const Radius.circular(32),
                          bottomLeft: const Radius.circular(8),
                          bottomRight: const Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 报价说明
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Quote Process',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Provider will review your requirements\n• You\'ll receive a detailed quote within 24 hours\n• Quote includes service scope, timeline, and pricing\n• You can accept, negotiate, or decline the quote',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteStatusIndicator(ServiceDetailController controller, ThemeData theme) {
    final status = controller.quoteRequestStatus;
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'Quote request submitted. Provider will respond within 24 hours.';
        break;
      case 'reviewing':
        statusColor = Colors.blue;
        statusIcon = Icons.visibility;
        statusText = 'Provider is reviewing your request.';
        break;
      case 'quoted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Quote received! Check your notifications.';
        break;
      case 'expired':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Quote request expired. Please submit a new request.';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
        statusText = 'Quote request status unknown.';
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(8),
          topRight: const Radius.circular(32),
          bottomLeft: const Radius.circular(8),
          bottomRight: const Radius.circular(8),
        ),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (status == 'quoted')
            TextButton(
              onPressed: () => _viewQuote(controller),
              child: Text(
                'View Quote',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuoteForm(ServiceDetailController controller, ThemeData theme) {
    return Column(
      children: [
        // 服务日期
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Preferred Service Date',
            hintText: 'Select when you need the service',
            suffixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(48),
                bottomLeft: const Radius.circular(12),
                bottomRight: const Radius.circular(12),
              ),
            ),
          ),
          onTap: () => _selectDate(controller),
          readOnly: true,
        ),
        const SizedBox(height: 12),
        
        // 服务时间
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Preferred Time',
            hintText: 'Morning, Afternoon, Evening, or Specific time',
            suffixIcon: const Icon(Icons.access_time),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(48),
                bottomLeft: const Radius.circular(12),
                bottomRight: const Radius.circular(12),
              ),
            ),
          ),
          onTap: () => _selectTime(controller),
          readOnly: true,
        ),
        const SizedBox(height: 12),
        
        // 服务详情
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Service Requirements',
            hintText: 'Describe your specific needs, preferences, and any special requirements...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(48),
                bottomLeft: const Radius.circular(12),
                bottomRight: const Radius.circular(12),
              ),
            ),
          ),
          maxLines: 4,
          onChanged: (value) => controller.updateQuoteDetails('requirements', value),
        ),
        const SizedBox(height: 12),
        
        // 预算范围
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Budget Range (Optional)',
            hintText: 'e.g., \$50-\$150 or "Flexible"',
            prefixIcon: const Icon(Icons.attach_money),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(48),
                bottomLeft: const Radius.circular(12),
                bottomRight: const Radius.circular(12),
              ),
            ),
          ),
          onChanged: (value) => controller.updateQuoteDetails('budget', value),
        ),
        const SizedBox(height: 12),
        
        // 紧急程度
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(48),
              bottomLeft: const Radius.circular(12),
              bottomRight: const Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Urgency Level',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildUrgencyOption('Low', 'Flexible timeline', Icons.schedule, Colors.green, theme),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildUrgencyOption('Medium', 'Within a week', Icons.timer, Colors.orange, theme),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildUrgencyOption('High', 'ASAP', Icons.priority_high, Colors.red, theme),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUrgencyOption(String level, String description, IconData icon, Color color, ThemeData theme) {
    return GestureDetector(
      onTap: () => _selectUrgencyLevel(level),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.05),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              level,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate(ServiceDetailController controller) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((date) {
      if (date != null) {
        controller.updateQuoteDetails('serviceDate', date.toString().split(' ')[0]);
      }
    });
  }

  void _selectTime(ServiceDetailController controller) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((time) {
      if (time != null) {
        controller.updateQuoteDetails('serviceTime', '${time.hour}:${time.minute.toString().padLeft(2, '0')}');
      }
    });
  }

  void _selectUrgencyLevel(String level) {
    // TODO: 更新控制器的紧急程度
    Get.snackbar(
      'Urgency Level',
      'Set to: $level',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _submitQuoteRequest(ServiceDetailController controller) {
    // 验证表单
    if (controller.quoteDetails['requirements']?.isEmpty ?? true) {
      Get.snackbar(
        'Error',
        'Please describe your service requirements',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    // 显示确认对话框
    Get.dialog(
      AlertDialog(
        title: const Text('Submit Quote Request'),
        content: const Text(
          'Are you sure you want to submit this quote request? The provider will review your requirements and respond within 24 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _processQuoteRequest(controller);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _processQuoteRequest(ServiceDetailController controller) {
    // 显示加载状态
    Get.dialog(
      const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Submitting quote request...'),
          ],
        ),
      ),
    );
    
    // 使用控制器的方法提交报价请求
    controller.submitQuoteRequest().then((_) {
      Get.back(); // 关闭加载对话框
      
      if (controller.quoteError.isEmpty) {
        Get.snackbar(
          'Quote Request Submitted',
          'Your quote request has been sent to the provider. You\'ll receive a response within 24 hours.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        
        // 发送通知给提供商
        _notifyProvider(controller);
      } else {
        Get.snackbar(
          'Error',
          controller.quoteError,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
  }

  void _notifyProvider(ServiceDetailController controller) {
    // TODO: 实现提供商通知
    print('Notifying provider about new quote request');
  }

  void _viewQuote(ServiceDetailController controller) {
    // 获取报价详情
    controller.getQuoteDetails().then((_) {
      if (controller.receivedQuote != null) {
        _showQuoteDetailsDialog(controller);
      } else {
        Get.snackbar(
          'Error',
          'Failed to load quote details',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
  }

  void _showQuoteDetailsDialog(ServiceDetailController controller) {
    final quote = controller.receivedQuote!;
    final theme = Theme.of(context);
    
    Get.dialog(
      AlertDialog(
        title: const Text('Quote Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 报价金额
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.green[700], size: 24),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quote Amount',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '\$${quote['amount']?.toStringAsFixed(2) ?? '0.00'}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // 服务描述
              if (quote['description'] != null) ...[
                Text(
                  'Service Description',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  quote['description'],
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
              ],
              
              // 时间线
              if (quote['timeline'] != null) ...[
                _buildQuoteDetailRow('Timeline', quote['timeline'], Icons.schedule, theme),
                const SizedBox(height: 8),
              ],
              
              // 条款
              if (quote['terms'] != null) ...[
                _buildQuoteDetailRow('Terms', quote['terms'], Icons.description, theme),
                const SizedBox(height: 8),
              ],
              
              // 有效期
              if (quote['validUntil'] != null) ...[
                _buildQuoteDetailRow(
                  'Valid Until', 
                  _formatQuoteDate(quote['validUntil']),
                  Icons.access_time,
                  theme
                ),
                const SizedBox(height: 8),
              ],
              
              // 状态
              _buildQuoteDetailRow('Status', quote['status'] ?? 'Active', Icons.info, theme),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          OutlinedButton(
            onPressed: () {
              Get.back();
              controller.declineQuote();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red),
            ),
            child: const Text('Decline'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.acceptQuote();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept Quote'),
          ),
        ],
      ),
    );
  }

  String _formatQuoteDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.month}/${date.day}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  Widget _buildQuoteDetailRow(String label, String value, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  void _acceptQuote(ServiceDetailController controller) {
    Get.snackbar(
      'Quote Accepted',
      'You have accepted the quote. The provider will contact you soon.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Widget _buildDescriptionSection(ServiceDetailController controller, ThemeData theme) {
    return CustomerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.service?.description ?? 'No description available',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTimeSection(ServiceDetailController controller, ThemeData theme) {
    return CustomerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Availability',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 20, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available 24/7',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Response time: Within 2 hours',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarServicesSection(ServiceDetailController controller, ThemeData theme) {
    final similarServices = controller.similarServices;
    final colorScheme = theme.colorScheme;
    
    if (similarServices.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recommended for You',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => controller.viewAllSimilarServices(),
                  child: Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (controller.isLoadingSimilarServices)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Column(
                children: similarServices.take(3).map((service) {
                  return _buildSimilarServiceCard(service, controller, theme);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarServiceCard(SimilarService service, ServiceDetailController controller, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => controller.navigateToSimilarService(service.id),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(8),
          topRight: const Radius.circular(32),
          bottomLeft: const Radius.circular(8),
          bottomRight: const Radius.circular(8),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(8),
              topRight: const Radius.circular(32),
              bottomLeft: const Radius.circular(8),
              bottomRight: const Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              // 提供商头像
              CircleAvatar(
                backgroundImage: NetworkImage(service.providerAvatar),
                radius: 24,
                onBackgroundImageError: (exception, stackTrace) {
                  // 处理图片加载错误
                },
              ),
              const SizedBox(width: 12),
              
              // 服务信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.providerName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.serviceTitle,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${service.rating} (${service.reviewCount})',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${service.price}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 相似度标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(4),
                    topRight: const Radius.circular(16),
                    bottomLeft: const Radius.circular(4),
                    bottomRight: const Radius.circular(4),
                  ),
                ),
                child: Text(
                  '${(service.similarityScore * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedProviderSection(ServiceDetailController controller, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final provider = controller.provider;
    
    if (provider == null) {
      return CustomerCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.business, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Provider information not available',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return CustomerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 提供商头部信息
            Row(
              children: [
                // 提供商头像
                CircleAvatar(
                  radius: 30,
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  backgroundImage: provider.profileImageUrl != null 
                      ? NetworkImage(provider.profileImageUrl!)
                      : null,
                  child: provider.profileImageUrl == null
                      ? Icon(Icons.business, size: 30, color: colorScheme.primary)
                      : null,
                ),
                const SizedBox(width: 16),
                
                // 提供商基本信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.companyName ?? 'Provider Name',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${provider.ratingsAvg?.toStringAsFixed(1) ?? '0.0'}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${provider.reviewCount ?? 0} reviews)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Verified',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Professional',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 操作按钮
                Column(
                  children: [
                    IconButton(
                      onPressed: () => _showProviderDetails(controller, theme),
                      icon: Icon(Icons.info_outline, color: colorScheme.primary),
                    ),
                    IconButton(
                      onPressed: () => _startChat(controller),
                      icon: Icon(Icons.chat, color: colorScheme.primary),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 提供商描述
            if (provider.companyDescription != null) ...[
              Text(
                'About',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.companyDescription!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
            ],
            
            // 提供商统计信息
            Row(
              children: [
                _buildProviderStat(
                  Icons.star,
                  '${provider.ratingsAvg?.toStringAsFixed(1) ?? '0.0'}',
                  'Rating',
                  theme,
                ),
                _buildProviderStat(
                  Icons.rate_review,
                  '${provider.reviewCount ?? 0}',
                  'Reviews',
                  theme,
                ),
                _buildProviderStat(
                  Icons.work,
                  '${provider.serviceCategories?.length ?? 0}',
                  'Services',
                  theme,
                ),
                _buildProviderStat(
                  Icons.schedule,
                  '2-4h',
                  'Response',
                  theme,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 认证信息
            if (provider.businessLicense != null || provider.insuranceInfo != null) ...[
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Certifications & Insurance',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              if (provider.businessLicense != null)
                _buildCertificationRow(
                  Icons.verified,
                  'Business License',
                  provider.businessLicense!,
                  Colors.green,
                  theme,
                ),
              if (provider.insuranceInfo != null) ...[
                const SizedBox(height: 4),
                _buildCertificationRow(
                  Icons.security,
                  'Insurance',
                  provider.insuranceInfo!,
                  Colors.blue,
                  theme,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProviderStat(IconData icon, String value, String label, ThemeData theme) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationRow(IconData icon, String title, String description, Color color, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showProviderDetails(ServiceDetailController controller, ThemeData theme) {
    Get.dialog(
      AlertDialog(
        title: Text('Provider Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.provider?.companyName ?? 'Provider Name',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (controller.provider?.companyDescription != null) ...[
                Text(
                  controller.provider!.companyDescription!,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
              ],
              _buildDetailRow('Average Rating', '${controller.provider?.ratingsAvg.toStringAsFixed(1) ?? '0.0'} stars', theme),
              _buildDetailRow('Total Reviews', '${controller.provider?.reviewCount ?? 0}', theme),
              if (controller.serviceLocation != null && controller.serviceLocation!['radius'] != null)
                _buildDetailRow('Service Radius', '${controller.serviceLocation!['radius']} km', theme),
              if (controller.provider?.businessLicense != null)
                _buildDetailRow('Business License', controller.provider!.businessLicense!, theme),
              if (controller.provider?.insuranceInfo != null)
                _buildDetailRow('Insurance', controller.provider!.insuranceInfo!, theme),
              if (controller.provider?.contactPhone != null)
                _buildDetailRow('Phone', controller.provider!.contactPhone!, theme),
              if (controller.provider?.contactEmail != null)
                _buildDetailRow('Email', controller.provider!.contactEmail!, theme),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.contactProvider();
            },
            child: Text('Contact'),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderPortfolio(ServiceDetailController controller, ThemeData theme) {
    return CustomerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Provider Portfolio',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (controller.providerPortfolio.isNotEmpty)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: List.generate(
                  controller.providerPortfolio.length,
                  (index) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      controller.providerPortfolio[index]['images_url']?[0] ?? 'https://picsum.photos/100/100?random=$index',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            else
              Center(
                child: Text(
                  'No portfolio images available for this provider.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustAndSecuritySection(ServiceDetailController controller, ThemeData theme) {
    return CustomerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trust & Security',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.verified, size: 24, color: Colors.green[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verified Provider',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'This provider has been verified by our team to ensure reliability and quality.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.security, size: 24, color: Colors.blue[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Secure Payment',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'All transactions are protected by our secure payment system.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (controller.provider?.businessLicense != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.business, size: 24, color: Colors.orange[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Licensed Business',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'License: ${controller.provider!.businessLicense}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            if (controller.provider?.insuranceInfo != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.shield, size: 24, color: Colors.purple[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Insured & Bonded',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          controller.provider!.insuranceInfo!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStats(ServiceDetailController controller, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return CustomerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Review Statistics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    // 排序按钮
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.sort),
                      onSelected: (value) => controller.sortReviews(value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'newest',
                          child: Row(
                            children: [
                              Icon(Icons.access_time),
                              SizedBox(width: 8),
                              Text('Newest First'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'oldest',
                          child: Row(
                            children: [
                              Icon(Icons.access_time_filled),
                              SizedBox(width: 8),
                              Text('Oldest First'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'highest',
                          child: Row(
                            children: [
                              Icon(Icons.star),
                              SizedBox(width: 8),
                              Text('Highest Rated'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'lowest',
                          child: Row(
                            children: [
                              Icon(Icons.star_border),
                              SizedBox(width: 8),
                              Text('Lowest Rated'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // 筛选按钮
                    TextButton.icon(
                      onPressed: () => _showReviewFilterDialog(controller, theme),
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Filter'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 总体评分展示
            Row(
              children: [
                // 大评分显示
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          controller.service?.averageRating != null 
                              ? controller.service!.averageRating.toStringAsFixed(1) 
                              : '0.0',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '/ 5.0',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (index) {
                        final rating = controller.service?.averageRating ?? 0.0;
                        return Icon(
                          index < rating.floor() 
                              ? Icons.star 
                              : (index < rating ? Icons.star_half : Icons.star_border),
                          size: 20,
                          color: Colors.amber[600],
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${controller.service?.reviewCount ?? 0} reviews',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                
                // 统计信息
                Expanded(
                  child: Column(
                    children: [
                      _buildStatItem(
                        Icons.thumb_up, 
                        '${controller.reviews.where((r) => r.rating >= 4).length}', 
                        'Positive', 
                        theme,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      _buildStatItem(
                        Icons.comment, 
                        '${controller.reviews.where((r) => r.content.isNotEmpty).length}', 
                        'With Comments', 
                        theme,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      _buildStatItem(
                        Icons.star, 
                        '${controller.reviews.length}', 
                        'Total Reviews', 
                        theme,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 评分分布
            _buildRatingDistribution(controller, theme),
          ],
        ),
      ),
    );
  }

  // 新增：评分分布组件
  Widget _buildRatingDistribution(ServiceDetailController controller, ThemeData theme) {
    final totalReviews = controller.reviews.length;
    if (totalReviews == 0) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating Distribution',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(5, (index) {
          final rating = 5 - index;
          final count = controller.ratingDistribution[rating.toString()] ?? 0;
          final percentage = totalReviews > 0 ? (count / totalReviews * 100) : 0.0;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text(
                  '$rating',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      rating >= 4 ? Colors.green : rating >= 3 ? Colors.orange : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 30,
                  child: Text(
                    '$count',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, ThemeData theme, {Color? color}) {
    return Row(
      children: [
        Icon(
          icon, 
          size: 16, 
          color: color ?? theme.colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: color ?? theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  // 新增：显示评价筛选对话框
  void _showReviewFilterDialog(ServiceDetailController controller, ThemeData theme) {
    Get.dialog(
      AlertDialog(
        title: Text('Filter Reviews'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 星级筛选
                Text(
                  'Rating',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: controller.reviewFilters['all']!,
                      onSelected: (selected) {
                        setState(() {
                          controller.updateReviewFilter('all', selected);
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('5★'),
                      selected: controller.reviewFilters['5star']!,
                      onSelected: (selected) {
                        setState(() {
                          controller.updateReviewFilter('5star', selected);
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('4★'),
                      selected: controller.reviewFilters['4star']!,
                      onSelected: (selected) {
                        setState(() {
                          controller.updateReviewFilter('4star', selected);
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('3★'),
                      selected: controller.reviewFilters['3star']!,
                      onSelected: (selected) {
                        setState(() {
                          controller.updateReviewFilter('3star', selected);
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('2★'),
                      selected: controller.reviewFilters['2star']!,
                      onSelected: (selected) {
                        setState(() {
                          controller.updateReviewFilter('2star', selected);
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('1★'),
                      selected: controller.reviewFilters['1star']!,
                      onSelected: (selected) {
                        setState(() {
                          controller.updateReviewFilter('1star', selected);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 其他筛选选项
                Text(
                  'Other Filters',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('With Photos'),
                  value: controller.reviewFilters['withPhotos']!,
                  onChanged: (value) {
                    setState(() {
                      controller.updateReviewFilter('withPhotos', value!);
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text('Verified Purchase'),
                  value: controller.reviewFilters['verified']!,
                  onChanged: (value) {
                    setState(() {
                      controller.updateReviewFilter('verified', value!);
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.resetReviewFilters();
              Get.back();
            },
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewList(ServiceDetailController controller, ThemeData theme) {
    final reviews = controller.filteredReviews.isNotEmpty 
        ? controller.filteredReviews 
        : controller.reviews;
    
    if (reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              controller.filteredReviews.isNotEmpty && controller.reviews.isNotEmpty
                  ? 'No reviews match your filters'
                  : 'No reviews yet for this service',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.filteredReviews.isNotEmpty && controller.reviews.isNotEmpty
                  ? 'Try adjusting your filter criteria'
                  : 'Be the first to leave a review!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _showReviewDialog(controller, theme);
              },
              icon: const Icon(Icons.rate_review),
              label: const Text('Write Review'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 添加评价按钮和筛选结果信息
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${reviews.length} Reviews',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (controller.filteredReviews.isNotEmpty && controller.reviews.isNotEmpty)
                    Text(
                      'Showing ${reviews.length} of ${controller.reviews.length} reviews',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  _showReviewDialog(controller, theme);
                },
                icon: const Icon(Icons.rate_review),
                label: const Text('Write Review'),
              ),
            ],
          ),
        ),
        
        // 评价列表
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return _buildReviewCard(review, theme);
          },
        ),
      ],
    );
  }

  void _showReviewDialog(ServiceDetailController controller, ThemeData theme) {
    double overallRating = 0.0;
    double qualityRating = 0.0;
    double punctualityRating = 0.0;
    double communicationRating = 0.0;
    double valueRating = 0.0;
    final reviewController = TextEditingController();
    bool isAnonymous = false;
    List<String> selectedTags = [];

    Get.dialog(
      AlertDialog(
        title: Text('Write Review'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 总体评分
              _buildRatingSection('Overall Rating', overallRating, (rating) => overallRating = rating, theme),
              const SizedBox(height: 16),
              
              // 详细评分
              _buildRatingSection('Quality', qualityRating, (rating) => qualityRating = rating, theme),
              _buildRatingSection('Punctuality', punctualityRating, (rating) => punctualityRating = rating, theme),
              _buildRatingSection('Communication', communicationRating, (rating) => communicationRating = rating, theme),
              _buildRatingSection('Value for Money', valueRating, (rating) => valueRating = rating, theme),
              const SizedBox(height: 16),
              
              // 评价内容
              TextField(
                controller: reviewController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Your Review',
                  hintText: 'Share your experience with this service...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // 标签选择
              _buildTagSelection(selectedTags, theme),
              const SizedBox(height: 16),
              
              // 匿名选项
              CheckboxListTile(
                title: Text('Post anonymously'),
                value: isAnonymous,
                onChanged: (value) => isAnonymous = value ?? false,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (overallRating == 0) {
                Get.snackbar('Error', 'Please provide an overall rating');
                return;
              }
              if (reviewController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Please write a review');
                return;
              }
              
              // TODO: 提交评价到后端
              Get.back();
              Get.snackbar(
                'Success',
                'Review submitted successfully!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Text('Submit Review'),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(String title, double rating, Function(double) onRatingChanged, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => onRatingChanged(index + 1.0),
              child: Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: index < rating ? Colors.amber : Colors.grey,
                size: 32,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTagSelection(List<String> selectedTags, ThemeData theme) {
    final availableTags = [
      'Professional', 'Reliable', 'Good Value', 'Quick Service',
      'Friendly', 'Clean', 'On Time', 'Good Communication'
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Tags (Optional)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTags.map((tag) {
            final isSelected = selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  selectedTags.add(tag);
                } else {
                  selectedTags.remove(tag);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Review review, ThemeData theme) {
    return CustomerCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: review.userAvatar != null 
                      ? NetworkImage(review.userAvatar!)
                      : null,
                  child: review.userAvatar == null 
                      ? Text((review.userName.isNotEmpty ? review.userName[0] : 'U').toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            review.rating.toString(),
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(review.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  onSelected: (value) {
                    switch (value) {
                      case 'report':
                        _reportReview(review);
                        break;
                      case 'helpful':
                        _markReviewHelpful(review);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'helpful',
                      child: Row(
                        children: [
                          Icon(Icons.thumb_up, size: 16),
                          const SizedBox(width: 8),
                          Text('Mark as helpful'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag, size: 16),
                          const SizedBox(width: 8),
                          Text('Report review'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review.content,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            // 评价互动区域
            Row(
              children: [
                InkWell(
                  onTap: () => _likeReview(review),
                  child: Row(
                    children: [
                      Icon(
                        Icons.thumb_up_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Helpful',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () => _replyToReview(review),
                  child: Row(
                    children: [
                      Icon(
                        Icons.reply,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Reply',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (review.rating >= 4)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Verified',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _likeReview(Review review) {
    Get.snackbar(
      'Review',
      'Review marked as helpful!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _replyToReview(Review review) {
    Get.dialog(
      AlertDialog(
        title: Text('Reply to Review'),
        content: TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Write your reply...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Reply',
                'Reply sent successfully!',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  void _reportReview(Review review) {
    Get.dialog(
      AlertDialog(
        title: Text('Report Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Why are you reporting this review?'),
            const SizedBox(height: 16),
            ListTile(
              leading: Radio<String>(value: 'inappropriate', groupValue: '', onChanged: (value) {}),
              title: Text('Inappropriate content'),
            ),
            ListTile(
              leading: Radio<String>(value: 'spam', groupValue: '', onChanged: (value) {}),
              title: Text('Spam'),
            ),
            ListTile(
              leading: Radio<String>(value: 'fake', groupValue: '', onChanged: (value) {}),
              title: Text('Fake review'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Report',
                'Review reported successfully!',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Text('Report'),
          ),
        ],
      ),
    );
  }

  void _markReviewHelpful(Review review) {
    Get.snackbar(
      'Review',
      'Review marked as helpful!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildBottomActions() {
    return GetBuilder<ServiceDetailController>(
      builder: (controller) {
        final isQuoteService = controller.serviceDetail?.pricingType == 'custom' || 
                              controller.serviceDetail?.pricingType == 'negotiable';
        
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // 收藏按钮
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      controller.toggleFavorite();
                      Get.snackbar(
                        'Favorite',
                        controller.isFavorite.value ? 'Added to favorites!' : 'Removed from favorites!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: controller.isFavorite.value ? Colors.green : Colors.grey,
                        colorText: Colors.white,
                      );
                    },
                    icon: Icon(
                      controller.isFavorite.value ? Icons.favorite : Icons.favorite_border,
                      color: controller.isFavorite.value ? Colors.red : Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // 联系按钮
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showContactOptions(controller);
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Contact'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // 主要操作按钮 - 根据服务类型显示不同按钮
                Expanded(
                  flex: 2,
                  child: isQuoteService
                      ? ElevatedButton.icon(
                          onPressed: () => _showQuickQuoteDialog(controller),
                          icon: const Icon(Icons.request_quote),
                          label: const Text('Get Quote'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () {
                            _showBookingOptions(controller);
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Book Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showContactOptions(ServiceDetailController controller) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(80),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Row(
              children: [
                Icon(Icons.contact_support, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Contact Provider',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 联系选项
            Column(
              children: [
                // 1. 开始聊天
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.chat, color: Colors.green[700]),
                  ),
                  title: const Text('Start Chat'),
                  subtitle: const Text('Real-time messaging with the provider'),
                  onTap: () {
                    Get.back();
                    _startChat(controller);
                  },
                ),
                
                // 2. 电话联系
                if (controller.provider?.contactPhone != null)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.phone, color: Colors.blue[700]),
                    ),
                    title: const Text('Call Provider'),
                    subtitle: Text('Call ${controller.provider?.contactPhone}'),
                    onTap: () {
                      Get.back();
                      _callProvider(controller);
                    },
                  ),
                
                // 3. 邮件联系
                if (controller.provider?.contactEmail != null)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.email, color: Colors.orange[700]),
                    ),
                    title: const Text('Send Email'),
                    subtitle: Text('Email to ${controller.provider?.contactEmail}'),
                    onTap: () {
                      Get.back();
                      _emailProvider(controller);
                    },
                  ),
                
                // 4. 查看联系信息
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.info, color: Colors.purple[700]),
                  ),
                  title: const Text('View Contact Info'),
                  subtitle: const Text('See all contact details'),
                  onTap: () {
                    Get.back();
                    _showContactInfo(controller);
                  },
                ),
                
                
                // 5. 请求报价（如果服务需要报价）
                if (controller.serviceDetail?.pricingType == 'custom' || 
                    controller.serviceDetail?.pricingType == 'negotiable')
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.request_quote, color: Colors.red[700]),
                    ),
                    title: const Text('Request Quote'),
                    subtitle: const Text('Get a custom quote for your needs'),
                    onTap: () {
                      Get.back();
                      _showQuickQuoteDialog(controller);
                    },
                  ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 说明
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Choose your preferred way to contact the provider',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingOptions(ServiceDetailController controller) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final service = controller.service;
    final serviceDetail = controller.serviceDetail;
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(80),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Row(
              children: [
                Icon(Icons.calendar_today, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Book Service',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 服务信息
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service?.title ?? 'Service',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: Colors.green[600], size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '\$${serviceDetail?.price?.toStringAsFixed(2) ?? '0.00'}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.green[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (serviceDetail?.pricingType == 'hourly')
                        Text(
                          '/hour',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // 预订选项
            Column(
              children: [
                // 1. 立即预订
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.schedule, color: Colors.green[700]),
                  ),
                  title: const Text('Book Now'),
                  subtitle: const Text('Schedule service for a specific date and time'),
                  onTap: () {
                    Get.back();
                    _startBooking(controller);
                  },
                ),
                
                // 2. 查看可用时间
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.calendar_month, color: Colors.blue[700]),
                  ),
                  title: const Text('Check Availability'),
                  subtitle: const Text('View provider\'s available time slots'),
                  onTap: () {
                    Get.back();
                    _checkAvailability(controller);
                  },
                ),
                
                // 3. 请求报价（如果服务需要报价）
                if (serviceDetail?.pricingType == 'custom' || 
                    serviceDetail?.pricingType == 'negotiable')
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.request_quote, color: Colors.orange[700]),
                    ),
                    title: const Text('Request Quote'),
                    subtitle: const Text('Get a custom quote for your specific needs'),
                    onTap: () {
                      Get.back();
                      _showQuickQuoteDialog(controller);
                    },
                  ),
                
                // 4. 联系提供者
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.chat, color: Colors.purple[700]),
                  ),
                  title: const Text('Contact Provider'),
                  subtitle: const Text('Discuss details before booking'),
                  onTap: () {
                    Get.back();
                    _showContactOptions(controller);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 说明
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Choose your preferred booking method. You can book immediately or discuss details with the provider first.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startBooking(ServiceDetailController controller) {
    // 实现立即预订的逻辑
    Get.snackbar(
      'Booking',
      'Booking process started!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _checkAvailability(ServiceDetailController controller) {
    // 实现查看可用时间的逻辑
    Get.snackbar(
      'Availability',
      'Checking availability...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _makePhoneCall(String phoneNumber) {
    Get.snackbar(
      'Phone Call',
      'Calling $phoneNumber...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    // TODO: 实现实际的拨打电话功能
  }

  void _sendEmail(String email) {
    Get.snackbar(
      'Email',
      'Opening email app for $email...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
    // TODO: 实现实际的发送邮件功能
  }

  void _scheduleService(ServiceDetailController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('Schedule Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Service Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () {
                // TODO: 实现日期选择器
                Get.snackbar('Date Picker', 'Date picker will be implemented');
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Service Time',
                suffixIcon: Icon(Icons.access_time),
              ),
              readOnly: true,
              onTap: () {
                // TODO: 实现时间选择器
                Get.snackbar('Time Picker', 'Time picker will be implemented');
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Special Requirements',
                hintText: 'Any special requests or notes...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Booking',
                'Service scheduled successfully!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _requestQuote(ServiceDetailController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('Request Quote'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Service Description',
                hintText: 'Describe what you need...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Preferred Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () {
                // TODO: 实现日期选择器
                Get.snackbar('Date Picker', 'Date picker will be implemented');
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Budget Range (Optional)',
                hintText: 'e.g., \$50-\$100',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Quote Request',
                'Quote request sent successfully!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Text('Send Request'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  String _getCategoryName(String categoryId) {
    switch (categoryId) {
      case '1010000': return 'Food & Dining';
      case '1020000': return 'Home Services';
      case '1030000': return 'Transportation';
      case '1040000': return 'Entertainment';
      case '1050000': return 'Education';
      case '1060000': return 'Life Services';
      default: return 'Other';
    }
  }

  String _getDeliveryMethodName(String method) {
    switch (method) {
      case 'on_site': return 'On-site Service';
      case 'remote': return 'Remote Service';
      case 'hybrid': return 'Hybrid Service';
      default: return method;
    }
  }

  Widget _buildRecommendationItem(String title, String description, IconData icon, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem(String title, String description, IconData icon, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOfferItem(String title, String description, String code, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            code,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem(String category, String value, String source, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Text(
          source,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[500],
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  void _showQuickQuoteDialog(ServiceDetailController controller) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(64),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 头部
              Row(
                children: [
                  Icon(Icons.request_quote, color: colorScheme.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Request Quote',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Get a personalized quote for this service',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // 快速选项
              Text(
                'How would you like to proceed?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              // 选项按钮
              Column(
                children: [
                  // 快速报价
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.flash_on, color: colorScheme.primary),
                    ),
                    title: const Text('Quick Quote'),
                    subtitle: const Text('Submit basic requirements for a quick estimate'),
                    onTap: () {
                      Get.back();
                      _showQuickQuoteForm(controller);
                    },
                  ),
                  
                  // 详细报价
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.description, color: colorScheme.secondary),
                    ),
                    title: const Text('Detailed Quote'),
                    subtitle: const Text('Provide detailed requirements for accurate pricing'),
                    onTap: () {
                      Get.back();
                      _showDetailedQuoteForm(controller);
                    },
                  ),
                  
                  // 先聊天
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.chat, color: Colors.green),
                    ),
                    title: const Text('Chat First'),
                    subtitle: const Text('Discuss your needs with the provider'),
                    onTap: () {
                      Get.back();
                      _startChat(controller);
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // 说明
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Provider will respond within 24 hours with a detailed quote',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.blue[700],
                        ),
                      ),
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

  void _showQuickQuoteForm(ServiceDetailController controller) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final requirementsController = TextEditingController();
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(64),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Quick Quote Request',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: requirementsController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Brief Description',
                  hintText: 'Describe what you need (e.g., "House cleaning for 3-bedroom apartment")',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(48),
                      bottomLeft: const Radius.circular(12),
                      bottomRight: const Radius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (requirementsController.text.trim().isNotEmpty) {
                          controller.updateQuoteDetails('requirements', requirementsController.text.trim());
                          Get.back();
                          _submitQuickQuote(controller);
                        } else {
                          Get.snackbar(
                            'Error',
                            'Please describe your requirements',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailedQuoteForm(ServiceDetailController controller) {
    // 导航到Overview tab并显示完整的报价表单
    _tabController.animateTo(0); // 切换到Overview tab
    Get.back(); // 关闭对话框
    
    // 滚动到报价表单
    Future.delayed(const Duration(milliseconds: 500), () {
      // 这里可以添加滚动到报价表单的逻辑
    });
  }

  void _submitQuickQuote(ServiceDetailController controller) {
    // 显示加载状态
    Get.dialog(
      const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Submitting quick quote request...'),
          ],
        ),
      ),
    );
    
    // 提交快速报价
    controller.submitQuoteRequest().then((_) {
      Get.back(); // 关闭加载对话框
      
      if (controller.quoteError.isEmpty) {
        Get.snackbar(
          'Quick Quote Submitted',
          'Your quote request has been sent. You\'ll receive a response within 24 hours.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          'Error',
          controller.quoteError,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
  }

  void _callProvider(ServiceDetailController controller) {
    if (controller.provider?.contactPhone != null) {
      // 使用url_launcher包拨打电话
      // launchUrl(Uri.parse('tel:${controller.provider!.contactPhone}'));
      
      // 临时实现：显示确认对话框
      Get.dialog(
        AlertDialog(
          title: const Text('Call Provider'),
          content: Text('Call ${controller.provider?.contactPhone}?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Calling',
                  'Opening phone app...',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              child: const Text('Call'),
            ),
          ],
        ),
      );
    }
  }

  void _emailProvider(ServiceDetailController controller) {
    if (controller.provider?.contactEmail != null) {
      // 使用url_launcher包发送邮件
      // launchUrl(Uri.parse('mailto:${controller.provider!.contactEmail}'));
      
      // 临时实现：显示确认对话框
      Get.dialog(
        AlertDialog(
          title: const Text('Send Email'),
          content: Text('Send email to ${controller.provider?.contactEmail}?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Email',
                  'Opening email app...',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                );
              },
              child: const Text('Send'),
            ),
          ],
        ),
      );
    }
  }

  void _showContactInfo(ServiceDetailController controller) {
    final theme = Theme.of(context);
    final provider = controller.provider;
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(64),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.contact_phone, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Contact Information',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // 联系信息列表
              Column(
                children: [
                  if (provider?.companyName != null)
                    _buildContactInfoRow(
                      'Company',
                      provider!.companyName!,
                      Icons.business,
                      Colors.blue,
                    ),
                  if (provider?.contactPhone != null)
                    _buildContactInfoRow(
                      'Phone',
                      provider!.contactPhone!,
                      Icons.phone,
                      Colors.green,
                    ),
                  if (provider?.contactEmail != null)
                    _buildContactInfoRow(
                      'Email',
                      provider!.contactEmail!,
                      Icons.email,
                      Colors.orange,
                    ),
                  // 地址信息暂时移除，因为ProviderProfile模型中没有address属性
                ],
              ),
              
              const SizedBox(height: 20),
              
              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _startChat(controller);
                      },
                      child: const Text('Start Chat'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfoRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(ServiceDetailController controller, ThemeData theme) {
    if (controller.serviceDetail?.tags.isEmpty != false) {
      return const SizedBox.shrink();
    }

    return CustomerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Features',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.serviceDetail!.tags.map((tag) {
                return CustomerBadge(
                  text: tag,
                  type: CustomerBadgeType.secondary,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _sortReviews(ServiceDetailController controller, String sortType) {
    switch (sortType) {
      case 'newest':
        controller.reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        controller.reviews.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'highest':
        controller.reviews.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'lowest':
        controller.reviews.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }
    controller.update();
  }

  // 新增：增强的地图组件 - 移除重复的Get Quote功能
  Widget _buildEnhancedMapSection(ServiceDetailController controller, ThemeData theme) {
    return CustomerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 地图标题和操作按钮
          Row(
            children: [
              Icon(Icons.location_on, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Location & Route',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _toggleMapFullscreen(),
                icon: const Icon(Icons.fullscreen),
                tooltip: 'Fullscreen Map',
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 地图容器
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // 地图背景
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 48, color: Colors.blue),
                        const SizedBox(height: 8),
                        Text(
                          'Interactive Map',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Route visualization coming soon',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 地图控制按钮
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: () => _zoomIn(),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: () => _zoomOut(),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 路线信息 - 简化版本，移除重复内容
          _buildRouteInfo(controller, theme),
          const SizedBox(height: 12),
          
          // 导航操作按钮
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openNavigation(controller),
                  icon: const Icon(Icons.directions),
                  label: const Text('Navigate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyAddress(controller),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Address'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 新增：简化的路线信息组件 - 修复重复内容
  Widget _buildRouteInfo(ServiceDetailController controller, ThemeData theme) {
    // 使用模拟数据，避免重复内容
    final routeInfo = {
      'duration': '15 min',
      'distance': '4.7 km',
      'transportMode': 'TTC Bus 501',
      'estimatedCost': '3.25'
    };
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.route, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${routeInfo['duration']} • ${routeInfo['distance']} via ${routeInfo['transportMode']}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Estimated cost: \$${routeInfo['estimatedCost']}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _switchTransportMode(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'car',
                child: Row(
                  children: [
                    Icon(Icons.directions_car),
                    SizedBox(width: 8),
                    Text('Car'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'transit',
                child: Row(
                  children: [
                    Icon(Icons.directions_bus),
                    SizedBox(width: 8),
                    Text('Transit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'walking',
                child: Row(
                  children: [
                    Icon(Icons.directions_walk),
                    SizedBox(width: 8),
                    Text('Walking'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 新增：地图Widget
  Widget _buildMapWidget(ServiceDetailController controller, ThemeData theme) {
    return GetBuilder<ServiceDetailController>(
      builder: (controller) {
        final serviceMapController = controller.serviceMapController;
        
        // 检查是否全屏模式
        if (serviceMapController.isMapFullScreen.value) {
          return _buildFullScreenMap(controller, theme);
        }
        
        return Stack(
          children: [
            // 复用ServiceMapController的地图
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.currentServiceLocation ?? const LatLng(43.6532, -79.3832),
                zoom: 15.0,
              ),
              mapType: serviceMapController.currentMapType.value,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              markers: _buildMapMarkers(controller),
              circles: serviceMapController.serviceAreaCircles,
              polylines: serviceMapController.routePolylines, // 添加路线显示
              onMapCreated: (GoogleMapController mapController) {
                // 可以在这里进行地图初始化
              },
            ),
            
            // 加载指示器
            if (serviceMapController.isLoadingMapData.value || serviceMapController.isLoadingRoute.value)
              const Center(
                child: CircularProgressIndicator(),
              ),
            
            // 地图控制按钮
            Positioned(
              right: 8,
              top: 8,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    onPressed: () => controller.toggleMapType(),
                    heroTag: 'mapType',
                    child: Icon(
                      serviceMapController.currentMapType.value == MapType.normal
                          ? Icons.map
                          : serviceMapController.currentMapType.value == MapType.satellite
                              ? Icons.satellite
                              : Icons.terrain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    onPressed: () => controller.navigateToService(),
                    heroTag: 'navigate',
                    child: const Icon(Icons.navigation),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    onPressed: () => controller.calculateRouteToProvider(),
                    heroTag: 'route',
                    child: const Icon(Icons.route),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    onPressed: () {
                      print('[ServiceDetailPage] Toggling fullscreen mode');
                      controller.toggleMapFullScreen();
                    },
                    heroTag: 'fullscreen',
                    child: const Icon(Icons.fullscreen),
                  ),
                ],
              ),
            ),
            
            // 新增：地图交互控制
            _buildMapInteractionControls(controller, theme),
            
            // 路线信息显示 - 简化
            if (serviceMapController.getCurrentRouteInfo() != null)
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 180), // 减小最大宽度
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${serviceMapController.getCurrentRouteInfo()!['duration']} • ${serviceMapController.getCurrentRouteInfo()!['distance']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        serviceMapController.getCurrentRouteInfo()!['route'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            
            // 新增：地图状态指示器
            if (serviceMapController.markers.isEmpty && !serviceMapController.isLoadingMapData.value)
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No services found in this area. Try expanding search radius.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => serviceMapController.searchNearbyServices(radiusKm: 100.0),
                        icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                        tooltip: 'Expand Search',
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // 新增：全屏地图模式
  Widget _buildFullScreenMap(ServiceDetailController controller, ThemeData theme) {
    final serviceMapController = controller.serviceMapController;
    
    print('[ServiceDetailPage] Building fullscreen map');
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 全屏地图
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: controller.currentServiceLocation ?? const LatLng(43.6532, -79.3832),
              zoom: 15.0,
            ),
            mapType: serviceMapController.currentMapType.value,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            markers: _buildMapMarkers(controller),
            circles: serviceMapController.serviceAreaCircles,
            polylines: serviceMapController.routePolylines,
            onMapCreated: (GoogleMapController mapController) {
              print('[ServiceDetailPage] Fullscreen map created');
            },
          ),
          
          // 顶部控制栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      print('[ServiceDetailPage] Exiting fullscreen mode');
                      controller.toggleMapFullScreen();
                    },
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Exit Fullscreen',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Location & Route',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => controller.toggleMapType(),
                    icon: Icon(
                      serviceMapController.currentMapType.value == MapType.normal
                          ? Icons.map
                          : serviceMapController.currentMapType.value == MapType.satellite
                              ? Icons.satellite
                              : Icons.terrain,
                      color: Colors.white,
                    ),
                    tooltip: 'Map Type',
                  ),
                ],
              ),
            ),
          ),
          
          // 底部操作栏
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.navigateToService(),
                      icon: const Icon(Icons.navigation),
                      label: const Text('Navigate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.copyServiceAddress(),
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 路线信息显示
          if (serviceMapController.getCurrentRouteInfo() != null)
            Positioned(
              left: 16,
              top: 120,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${serviceMapController.getCurrentRouteInfo()!['duration']} • ${serviceMapController.getCurrentRouteInfo()!['distance']}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      serviceMapController.getCurrentRouteInfo()!['route'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
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

  // 新增：获取交通方式图标
  IconData _getTransportIcon(String mode) {
    switch (mode) {
      case 'car':
        return Icons.directions_car;
      case 'transit':
        return Icons.directions_bus;
      case 'walking':
        return Icons.directions_walk;
      case 'bicycle':
        return Icons.directions_bike;
      default:
        return Icons.directions;
    }
  }

  // 新增：构建地图标记
  Set<Marker> _buildMapMarkers(ServiceDetailController controller) {
    Set<Marker> markers = {};
    
    // 添加当前服务标记
    if (controller.currentServiceLocation != null) {
      markers.add(Marker(
        markerId: MarkerId('current_service_${controller.service?.id}'),
        position: controller.currentServiceLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: controller.service?.title ?? 'Service',
          snippet: 'Current service location',
        ),
      ));
    }
    
    // 添加附近服务标记
    final nearbyServices = controller.getNearbyServices();
    for (int i = 0; i < nearbyServices.length && i < 5; i++) {
      final service = nearbyServices[i];
      markers.add(Marker(
        markerId: MarkerId('nearby_service_${service.id}'),
        position: service.location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: service.name,
          snippet: '${service.rating}★ (${service.reviewCount} reviews)',
        ),
      ));
    }
    
    return markers;
  }

  // 新增：构建服务区域圆形
  Set<Circle> _buildServiceAreaCircles(ServiceDetailController controller) {
    Set<Circle> circles = {};
    
    if (controller.currentServiceLocation != null && controller.serviceRadiusKm != null) {
      circles.add(Circle(
        circleId: CircleId('service_area_${controller.service?.id}'),
        center: controller.currentServiceLocation!,
        radius: controller.serviceRadiusKm! * 1000, // 转换为米
        strokeWidth: 2,
        strokeColor: Colors.blue.withOpacity(0.5),
        fillColor: Colors.blue.withOpacity(0.1),
      ));
    }
    
    return circles;
  }

  // 新增：服务区域信息
  Widget _buildServiceAreaInfo(ServiceDetailController controller, ThemeData theme) {
    if (controller.serviceAreaInfo == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Coverage',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                Icons.radio_button_checked,
                '${controller.serviceRadiusKm?.toStringAsFixed(1)} km radius',
                theme,
              ),
            ),
            Expanded(
              child: _buildInfoItem(
                Icons.access_time,
                controller.serviceAreaInfo!['responseTime'] ?? '2-4 hours',
                theme,
              ),
            ),
            Expanded(
              child: _buildInfoItem(
                Icons.location_on,
                controller.serviceAreaInfo!['arrivalTime'] ?? '15-30 min',
                theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 新增：信息项组件
  Widget _buildInfoItem(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // 新增：导航操作按钮
  Widget _buildNavigationActions(ServiceDetailController controller, ThemeData theme) {
    final serviceMapController = controller.serviceMapController;
    final currentRoute = serviceMapController.getCurrentRouteInfo();
    final selectedTransportMode = serviceMapController.selectedTransportMode.value;
    
    return Column(
      children: [
        // 路线信息显示 - 简化
        if (currentRoute != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  serviceMapController.getTransportIcon(selectedTransportMode),
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${currentRoute['duration']} • ${currentRoute['distance']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        currentRoute['route'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => controller.showRouteSelectionDialog(),
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'Options',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // 操作按钮 - 简化文字
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => controller.navigateToService(),
                icon: const Icon(Icons.navigation),
                label: Text(
                  currentRoute != null ? 'Navigate' : 'Directions', // 简化文字
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.copyServiceAddress(),
                icon: const Icon(Icons.copy),
                label: const Text(
                  'Copy', // 简化文字
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        
        // 路线计算按钮 - 简化
        if (currentRoute == null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => controller.calculateRouteToProvider(),
              icon: const Icon(Icons.route),
              label: const Text('Get Route'), // 简化文字
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: BorderSide(color: Colors.orange),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // 新增：简化的服务区域信息
  Widget _buildSimplifiedServiceAreaInfo(ServiceDetailController controller, ThemeData theme) {
    final serviceAreaInfo = controller.serviceMapController.serviceAreaInfo.value;
    
    if (serviceAreaInfo == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // 第一行：服务半径和响应时间
          Row(
            children: [
              // 服务半径
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.radio_button_checked, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${serviceAreaInfo['radius']?.toStringAsFixed(0)}km',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // 响应时间
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        serviceAreaInfo['responseTime'] ?? 'N/A',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 第二行：到达时间
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.green),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Arrival: ${serviceAreaInfo['arrivalTime'] ?? 'N/A'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 新增：地图交互优化
  Widget _buildMapInteractionControls(ServiceDetailController controller, ThemeData theme) {
    final serviceMapController = controller.serviceMapController;
    
    return Positioned(
      left: 8,
      bottom: 8,
      child: Column(
        children: [
          // 定位到用户位置按钮
          FloatingActionButton.small(
            onPressed: () => serviceMapController.centerOnUserLocation(),
            heroTag: 'location',
            backgroundColor: Colors.white,
            child: const Icon(Icons.my_location, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          // 自动适应markers按钮
          FloatingActionButton.small(
            onPressed: () => serviceMapController.autoFitMapToMarkers(),
            heroTag: 'fit',
            backgroundColor: Colors.white,
            child: const Icon(Icons.fit_screen, color: Colors.green),
          ),
          const SizedBox(height: 8),
          // 搜索附近服务按钮
          FloatingActionButton.small(
            onPressed: () => serviceMapController.searchNearbyServices(),
            heroTag: 'search',
            backgroundColor: Colors.white,
            child: const Icon(Icons.search, color: Colors.orange),
          ),
        ],
      ),
    );
  }

  // 新增：报价系统UI组件
  Widget _buildQuoteSystem(ServiceDetailController controller, ThemeData theme) {
    return CustomerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 报价系统标题
            Row(
              children: [
                Icon(Icons.request_quote, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Get Quote',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 报价状态显示
            if (controller.quoteRequestStatus != null) ...[
              _buildQuoteStatus(controller, theme),
              const SizedBox(height: 16),
            ],
            
            // 报价表单
            if (controller.quoteRequestStatus == null || controller.quoteRequestStatus == 'pending') ...[
              _buildQuoteForm(controller, theme),
            ],
            
            // 已收到报价显示
            if (controller.receivedQuote != null) ...[
              _buildReceivedQuote(controller, theme),
            ],
          ],
        ),
      ),
    );
  }

  // 新增：报价状态显示
  Widget _buildQuoteStatus(ServiceDetailController controller, ThemeData theme) {
    final status = controller.quoteRequestStatus.value;
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'Quote request submitted';
        break;
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Quote accepted';
        break;
      case 'declined':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Quote declined';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
        statusText = 'Quote status: $status';
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 新增：已收到报价显示
  Widget _buildReceivedQuote(ServiceDetailController controller, ThemeData theme) {
    final quote = controller.receivedQuote!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Quote Received',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 报价金额
          Row(
            children: [
              Text(
                'Quote Amount:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '\$${quote['amount']?.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // 服务描述
          if (quote['description'] != null) ...[
            Text(
              'Service Description:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              quote['description'],
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
          ],
          
          // 时间线
          if (quote['timeline'] != null) ...[
            Row(
              children: [
                Text(
                  'Timeline:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  quote['timeline'],
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          
          // 有效期
          if (quote['validUntil'] != null) ...[
            Row(
              children: [
                Text(
                  'Valid Until:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  DateTime.parse(quote['validUntil']).toString().split(' ')[0],
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          // 操作按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.declineQuote(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.acceptQuote(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 新增：预订系统UI组件
  Widget _buildBookingSystem(ServiceDetailController controller, ThemeData theme) {
    return CustomerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 预订系统标题
            Row(
              children: [
                Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Book Service',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 价格信息
            _buildPricingInfo(controller, theme),
            const SizedBox(height: 16),
            
            // 预订表单
            _buildBookingForm(controller, theme),
          ],
        ),
      ),
    );
  }

  // 新增：价格信息显示
  Widget _buildPricingInfo(ServiceDetailController controller, ThemeData theme) {
    final serviceDetail = controller.serviceDetail;
    if (serviceDetail == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Service Price',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '\$${serviceDetail.price?.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // 价格类型
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${serviceDetail.pricingType.toUpperCase()} pricing',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          // 服务时长
          if (serviceDetail.duration != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Duration: ${serviceDetail.duration!.inHours}h ${serviceDetail.duration!.inMinutes % 60}m',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
          
          // 协商详情
          if (serviceDetail.negotiationDetails != null) ...[
            const SizedBox(height: 8),
            Text(
              serviceDetail.negotiationDetails!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 新增：预订表单
  Widget _buildBookingForm(ServiceDetailController controller, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 服务日期
        Text(
          'Service Date',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'Select service date',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap: () => _selectBookingDate(controller),
          readOnly: true,
          controller: TextEditingController(
            text: controller.bookingDetails['serviceDate'] ?? '',
          ),
        ),
        const SizedBox(height: 16),
        
        // 服务时间
        Text(
          'Service Time',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'Select service time',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            suffixIcon: Icon(Icons.access_time),
          ),
          onTap: () => _selectBookingTime(controller),
          readOnly: true,
          controller: TextEditingController(
            text: controller.bookingDetails['serviceTime'] ?? '',
          ),
        ),
        const SizedBox(height: 16),
        
        // 特殊要求
        Text(
          'Special Requirements (Optional)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Any special requirements or notes...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onChanged: (value) => controller.updateBookingDetails('specialRequirements', value),
        ),
        const SizedBox(height: 24),
        
        // 预订按钮
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isLoadingBooking.value ? null : () => controller.submitBooking(),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: controller.isLoadingBooking.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Book Now'),
          ),
        ),
      ],
    );
  }

  // 新增：选择预订日期
  void _selectBookingDate(ServiceDetailController controller) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((date) {
      if (date != null) {
        controller.updateBookingDetails('serviceDate', date.toString().split(' ')[0]);
      }
    });
  }

  // 新增：选择预订时间
  void _selectBookingTime(ServiceDetailController controller) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((time) {
      if (time != null) {
        controller.updateBookingDetails('serviceTime', '${time.hour}:${time.minute.toString().padLeft(2, '0')}');
      }
    });
  }

  // 新增：联系系统UI组件
  Widget _buildContactSystem(ServiceDetailController controller, ThemeData theme) {
    return CustomerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 联系系统标题
            Row(
              children: [
                Icon(Icons.contact_support, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Contact Provider',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 联系信息
            _buildContactInfo(controller, theme),
            const SizedBox(height: 16),
            
            // 联系选项
            _buildContactOptions(controller, theme),
          ],
        ),
      ),
    );
  }

  // 新增：联系信息显示
  Widget _buildContactInfo(ServiceDetailController controller, ThemeData theme) {
    final serviceDetail = controller.serviceDetail;
    if (serviceDetail == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 提供商名称
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: controller.provider?.profileImageUrl != null
                    ? NetworkImage(controller.provider!.profileImageUrl!)
                    : null,
                child: controller.provider?.profileImageUrl == null
                    ? Text(controller.provider?.companyName[0].toUpperCase() ?? 'P')
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.provider?.companyName ?? 'Provider',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Professional Service Provider',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 联系详情
          if (controller.provider?.contactPhone != null) ...[
            _buildContactItem(
              Icons.phone,
              'Phone',
              controller.provider!.contactPhone,
              () => controller.callProvider(),
              theme,
            ),
            const SizedBox(height: 8),
          ],
          
          if (controller.provider?.contactEmail != null) ...[
            _buildContactItem(
              Icons.email,
              'Email',
              controller.provider!.contactEmail,
              () => controller.emailProvider(),
              theme,
            ),
            const SizedBox(height: 8),
          ],
          
          if (controller.provider?.contactEmail != null) ...[
            _buildContactItem(
              Icons.language,
              'Website',
              'Visit Website',
              () => controller.visitWebsite(),
              theme,
            ),
          ],
        ],
      ),
    );
  }

  // 新增：联系项目
  Widget _buildContactItem(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // 新增：联系选项
  Widget _buildContactOptions(ServiceDetailController controller, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // 聊天按钮
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => controller.startChat(),
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Start Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // 其他联系选项
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.callProvider(),
                icon: const Icon(Icons.phone),
                label: const Text('Call'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.emailProvider(),
                icon: const Icon(Icons.email),
                label: const Text('Email'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 新增：整合的核心操作区域
  Widget _buildCoreActionsSection(ServiceDetailController controller, ThemeData theme) {
    return CustomerCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(Icons.work, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Service Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 主要操作按钮
            Row(
              children: [
                // 报价按钮 - 始终显示
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showQuickQuoteDialog(controller),
                    icon: const Icon(Icons.request_quote, size: 18),
                    label: const Text('Get Quote'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // 预订按钮 - 始终显示
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showQuickBookingDialog(controller),
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text('Book Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 联系选项
            _buildQuickContactOptions(controller, theme),
            
            const SizedBox(height: 16),
            
            // 状态信息
            if (controller.quoteRequestStatus.value.isNotEmpty) ...[
              _buildQuoteStatus(controller, theme),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  // 新增：快速联系选项
  Widget _buildQuickContactOptions(ServiceDetailController controller, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Contact',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (controller.provider?.contactPhone != null) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.callProvider(),
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (controller.provider?.contactEmail != null) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.emailProvider(),
                  icon: const Icon(Icons.email, size: 16),
                  label: const Text('Email'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.startChat(),
                icon: const Icon(Icons.chat, size: 16),
                label: const Text('Chat'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 新增：快速预订对话框
  void _showQuickBookingDialog(ServiceDetailController controller) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.calendar_today, color: colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Quick Booking'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Book this service quickly',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                controller.updateBookingDetails('serviceDate', DateTime.now().add(const Duration(days: 1)).toString().split(' ')[0]);
                controller.updateBookingDetails('serviceTime', '09:00');
                controller.submitBooking();
              },
              icon: const Icon(Icons.schedule),
              label: const Text('Book for Tomorrow 9 AM'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                Get.back();
                // 打开详细预订表单
                _showDetailedBookingDialog(controller);
              },
              icon: const Icon(Icons.edit_calendar),
              label: const Text('Custom Booking'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(color: colorScheme.primary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // 新增：详细预订对话框
  void _showDetailedBookingDialog(ServiceDetailController controller) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit_calendar, color: colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Custom Booking'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Service Date',
                hintText: 'Select date',
              ),
              onTap: () => _selectDate(controller),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Service Time',
                hintText: 'Select time',
              ),
              onTap: () => _selectTime(controller),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Special Requirements',
                hintText: 'Any special requests?',
              ),
              maxLines: 3,
              onChanged: (value) => controller.updateBookingDetails('specialRequirements', value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.submitBooking();
            },
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  // 新增：开始聊天方法
  void _startChat(ServiceDetailController controller) {
    controller.startChat();
  }

  // 新增：服务详情方法
  Widget _buildServiceDetails(ServiceDetailController controller, ThemeData theme) {
    return CustomerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Category', _getCategoryName(controller.service?.categoryLevel1Id ?? ''), theme),
            _buildDetailRow('Delivery Method', _getDeliveryMethodName(controller.service?.serviceDeliveryMethod ?? ''), theme),
            _buildDetailRow('Status', controller.service?.status ?? 'N/A', theme),
            if (controller.serviceDetail?.serviceAreaCodes.isNotEmpty == true)
              _buildDetailRow('Service Areas', controller.serviceDetail!.serviceAreaCodes.join(', '), theme),
            if (controller.serviceDetail?.duration != null)
              _buildDetailRow('Duration', _formatDuration(controller.serviceDetail!.duration!), theme),
            if (controller.serviceDetail?.pricingType != null)
              _buildDetailRow('Pricing Type', controller.serviceDetail!.pricingType, theme),
          ],
        ),
      ),
    );
  }

  // 新增：服务区域方法
  Widget _buildServiceAreaSection(ServiceDetailController controller, ThemeData theme) {
    return CustomerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Service Area',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (controller.serviceLocation != null) ...[
              _buildDetailRow('Coverage Radius', '${controller.serviceLocation!['radius'] ?? '5'} km', theme),
              _buildDetailRow('Response Time', '${controller.serviceLocation?['responseTime'] ?? '2-4'} hours', theme),
            ] else ...[
              Text(
                'Service area information not available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 新增：地图全屏切换
  void _toggleMapFullscreen() {
    Get.snackbar(
      'Map Fullscreen',
      'Fullscreen mode coming soon',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  // 新增：地图缩放功能
  void _zoomIn() {
    Get.snackbar(
      'Zoom In',
      'Map zoomed in',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _zoomOut() {
    Get.snackbar(
      'Zoom Out',
      'Map zoomed out',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // 新增：打开导航
  void _openNavigation(ServiceDetailController controller) {
    if (controller.serviceLocation != null) {
      final latitude = controller.serviceLocation!['latitude'];
      final longitude = controller.serviceLocation!['longitude'];
      final address = controller.serviceLocation!['address'];
      
      Get.snackbar(
        'Navigation',
        'Opening navigation to: $address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }
  }

  // 新增：复制地址
  void _copyAddress(ServiceDetailController controller) {
    if (controller.serviceLocation != null) {
      final address = controller.serviceLocation!['address'];
      
      Get.snackbar(
        'Address Copied',
        'Address copied to clipboard: $address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  // 新增：切换交通方式
  void _switchTransportMode(String mode) {
    Get.snackbar(
      'Transport Mode',
      'Switched to $mode mode',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return tabBar;
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar;
  }
}

