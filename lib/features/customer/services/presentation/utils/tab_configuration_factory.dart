import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service_detail_controller.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:jinbeanpod_83904710/core/models/review_models.dart';

/// Tab配置模型
class TabConfiguration {
  final String key;
  final String label;
  final IconData icon;
  final Widget Function(BuildContext context, dynamic service) builder;
  final bool isVisible;
  final bool isIndustrySpecific;
  final String? industryType;

  const TabConfiguration({
    required this.key,
    required this.label,
    required this.icon,
    required this.builder,
    this.isVisible = true,
    this.isIndustrySpecific = false,
    this.industryType,
  });
}

/// Tab配置工厂
class TabConfigurationFactory {
  /// 根据服务类型生成Tab配置
  static List<TabConfiguration> generateTabsForService(String categoryId) {
    final baseTabs = [
      TabConfiguration(
        key: 'overview',
        label: 'Overview',
        icon: Icons.info_outline,
        builder: (context, service) => _buildOverviewTab(context, service),
      ),
      TabConfiguration(
        key: 'details',
        label: 'Details',
        icon: Icons.description,
        builder: (context, service) => _buildDetailsTab(context, service),
      ),
      TabConfiguration(
        key: 'provider',
        label: 'Provider',
        icon: Icons.person,
        builder: (context, service) => _buildProviderTab(context, service),
      ),
      TabConfiguration(
        key: 'reviews',
        label: 'Reviews',
        icon: Icons.star,
        builder: (context, service) => _buildReviewsTab(context, service),
      ),
      TabConfiguration(
        key: 'recommendations',
        label: 'For You',
        icon: Icons.recommend,
        builder: (context, service) =>
            _buildRecommendationsTab(context, service),
      ),
    ];

    // 根据服务类型替换Details tab为行业特定tab
    final industrySpecificTab = _getIndustrySpecificTab(categoryId);

    return baseTabs.map((tab) {
      if (tab.key == 'details') {
        return industrySpecificTab; // 🔥 关键：动态替换Details
      }
      return tab;
    }).toList();
  }

  /// 根据服务类别获取行业特定Tab（替换Details）
  static TabConfiguration _getIndustrySpecificTab(String categoryId) {
    debugPrint('🏷️  [TabFactory] _getIndustrySpecificTab called with categoryId: "$categoryId"');

    switch (categoryId) {
      case '1010000': // 餐饮服务
        debugPrint('✅ [TabFactory] Matched Food category (1010000) - returning Menu tab');
        return TabConfiguration(
          key: 'menu',
          label: 'Menu',
          icon: Icons.restaurant_menu,
          builder: (context, service) => _buildMenuTab(context, service),
          isIndustrySpecific: true,
          industryType: 'food',
        );

      case '1020000': // 家政服务
        debugPrint('✅ [TabFactory] Matched Home Services category (1020000) - returning Services tab');
        return TabConfiguration(
          key: 'services',
          label: 'Services',
          icon: Icons.cleaning_services,
          builder: (context, service) => _buildServicesTab(context, service),
          isIndustrySpecific: true,
          industryType: 'cleaning',
        );

      case '1040000': // 共享租赁
        debugPrint('✅ [TabFactory] Matched Rental category (1040000) - returning Inventory tab');
        return TabConfiguration(
          key: 'inventory',
          label: 'Inventory',
          icon: Icons.inventory,
          builder: (context, service) => _buildInventoryTab(context, service),
          isIndustrySpecific: true,
          industryType: 'rental',
        );

      case '1050000': // 教育培训
        debugPrint('✅ [TabFactory] Matched Education category (1050000) - returning Courses tab');
        return TabConfiguration(
          key: 'courses',
          label: 'Courses',
          icon: Icons.school,
          builder: (context, service) => _buildCoursesTab(context, service),
          isIndustrySpecific: true,
          industryType: 'education',
        );

      case '1060000': // 健康医疗
        debugPrint('✅ [TabFactory] Matched Health category (1060000) - returning Treatments tab');
        return TabConfiguration(
          key: 'treatments',
          label: 'Treatments',
          icon: Icons.medical_services,
          builder: (context, service) => _buildTreatmentsTab(context, service),
          isIndustrySpecific: true,
          industryType: 'health',
        );

      default: // 通用服务 - 保持Details tab
        debugPrint('⚠️  [TabFactory] No match found for categoryId "$categoryId" - using default Details tab');
        return TabConfiguration(
          key: 'details',
          label: 'Details',
          icon: Icons.description,
          builder: (context, service) => _buildDetailsTab(context, service),
        );
    }
  }

  // Tab构建方法
  static Widget _buildOverviewTab(BuildContext context, dynamic service) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 服务基本信息
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                  if (service.description?.isNotEmpty == true)
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
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${service.reviewCount ?? 0} reviews)',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 服务特性
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Service Features',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 这里可以添加动态服务特性
                  _buildServiceFeatures(context, service),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailsTab(BuildContext context, dynamic service) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // 服务详细信息
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Service ID', service.id ?? 'N/A'),
                  _buildDetailRow(
                      'Category', _getCategoryName(service.categoryLevel1Id)),
                  _buildDetailRow('Sub-Category',
                      _getSubCategoryName(service.categoryLevel2Id)),
                  _buildDetailRow('Status', service.status ?? 'Active'),
                  _buildDetailRow('Created', _formatDate(service.createdAt)),
                  _buildDetailRow('Updated', _formatDate(service.updatedAt)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 服务区域
          if (service.serviceAreaCodes?.isNotEmpty == true)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Areas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: service.serviceAreaCodes!
                          .map((area) => Chip(label: Text(area)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // 标签
          if (service.tags?.isNotEmpty == true)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Tags',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: service.tags!
                          .map((tag) => Chip(
                                label: Text(tag),
                                backgroundColor: Colors.blue[100],
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Widget _buildProviderTab(BuildContext context, dynamic service) {
    final controller = Get.find<ServiceDetailController>();

    return Obx(() {
      final provider = controller.providerProfile.value;
      final isLoading = controller.isLoadingProvider.value;
      
      // 减少日志输出频率，避免UI重建时的日志噪音
      // AppLogger.info('[ProviderUI] 🔄 UI状态检查 - isLoading: $isLoading, provider: ${provider != null ? 'exists' : 'null'}');

      if (isLoading) {
        // AppLogger.info('[ProviderUI] 🔄 显示loading状态 - CircularProgressIndicator');
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (provider == null) {
        // AppLogger.info('[ProviderUI] ❌ Provider为null，显示无数据状态');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Provider information not available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        );
      }

      // AppLogger.info('[ProviderUI] ✅ Provider数据存在，显示详细信息 - Provider ID: ${provider.id}');
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Provider',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // 提供商基本信息
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue[100],
                          backgroundImage: provider.avatar != null
                              ? NetworkImage(provider.avatar!)
                              : null,
                          child: provider.avatar == null
                              ? Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.blue[600],
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (provider.isVerified)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Verified',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                  if (provider.isVerified)
                                    const SizedBox(width: 8),
                                  Text(
                                    'Provider',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.amber[600], size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${provider.rating ?? 0.0}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${provider.reviewCount ?? 0} reviews)',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (provider.description != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'About',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 联系信息
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (provider.phone != null)
                      _buildContactRow(Icons.phone, 'Phone', provider.phone!),
                    if (provider.email != null)
                      _buildContactRow(Icons.email, 'Email', provider.email!),
                    if (provider.address != null)
                      _buildContactRow(
                          Icons.location_on, 'Location', provider.address!),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 服务统计
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Statistics',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('Total Orders',
                              '${provider.completedOrders ?? 0}', Icons.work),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard('Rating',
                              '${provider.rating ?? 0.0}', Icons.star),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                              'Reviews',
                              '${provider.reviewCount ?? 0}',
                              Icons.rate_review),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  static Widget _buildReviewsTab(BuildContext context, dynamic service) {
    final controller = Get.find<ServiceDetailController>();

    // 确保加载评价数据
    if (service?.id != null && controller.reviews.isEmpty && !controller.isLoadingReviews.value) {
      AppLogger.info('Reviews标签页: 开始加载评价数据 - Service ID: ${service.id}');
      controller.loadReviews(service.id);
    }

    return Obx(() {
      final reviews = controller.reviews;
      final isLoading = controller.isLoadingReviews.value;

      AppLogger.info('Reviews标签页: 状态更新 - 加载中: $isLoading, 评价数量: ${reviews.length}');

      if (isLoading) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading reviews...'),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Reviews',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // 评分概览
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overall Rating',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '${service.rating?.toStringAsFixed(1) ?? '0.0'}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (index) => Icon(
                                        index < (service.rating ?? 0).floor()
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${service.reviewCount ?? 0}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Total Reviews',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
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
            ),

            const SizedBox(height: 16),

            // 评分分布
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rating Distribution',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildRatingBar(5, 0.6, '5 Stars'),
                    _buildRatingBar(4, 0.25, '4 Stars'),
                    _buildRatingBar(3, 0.1, '3 Stars'),
                    _buildRatingBar(2, 0.03, '2 Stars'),
                    _buildRatingBar(1, 0.02, '1 Star'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 最新评论
            if (reviews.isEmpty)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No reviews yet',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to review this service!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (service?.id != null) {
                            controller.loadReviews(service.id, refresh: true);
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Service ID: ${service?.id ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[400],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reviews Count: ${reviews.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[400],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Loading: ${isLoading}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[400],
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Reviews',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      ...reviews.take(5).map((review) => _buildReviewItem(
                            review.getDisplayName(),
                            review.overallRating,
                            review.content ?? '',
                            review.createdAt,
                          )),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  static Widget _buildRecommendationsTab(
      BuildContext context, dynamic service) {
    final controller = Get.find<ServiceDetailController>();

    return Obx(() {
      final similarServices = controller.similarServices;
      final isLoading = controller.isLoadingSimilar.value;

      if (isLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personalized Recommendations',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (similarServices.isEmpty)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.recommend_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No recommendations available',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check back later for personalized recommendations!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.recommend, color: Colors.purple, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'For You',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Based on your preferences and browsing history, we recommend these related services:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),

                      // 推荐服务列表
                      ...similarServices
                          .take(5)
                          .map((similarService) => _buildRecommendationItem(
                                context,
                                similarService.title,
                                '${similarService.rating ?? 0.0}',
                                '${similarService.price ?? '0'}',
                              )),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  // 行业特定Tab页内容

  // 餐饮服务 - Menu Tab
  static Widget _buildMenuTab(BuildContext context, dynamic service) {
    // 获取Controller实例
    final controller = Get.find<ServiceDetailController>();

    // 首次加载数据
    if (controller.menuItems.isEmpty && !controller.isLoadingMenuItems.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadMenuItems(service.id);
      });
    }

    return Obx(() {
      // 加载状态
      if (controller.isLoadingMenuItems.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading menu items...'),
              ],
            ),
          ),
        );
      }

      // 空状态
      if (controller.menuItems.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No menu items available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This restaurant hasn\'t added any menu items yet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      // 数据展示
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Restaurant Menu',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${controller.menuItems.length} items available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Menu Items',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // 动态生成菜单项
                    ...controller.menuItems.map((item) {
                      // 获取名称（优先英文，否则取第一个可用语言）
                      final itemName = item.name['en'] ??
                          item.name['zh'] ??
                          item.name.values.firstOrNull ??
                          'Unnamed Item';

                      // 获取分类（使用sub_category）
                      final category = item.subCategory ?? 'General';

                      // 格式化价格
                      final priceText =
                          '${item.currency ?? 'CAD'} ${item.price?.toStringAsFixed(2) ?? '0.00'}';

                      return _buildMenuItem(
                        context,
                        category,
                        itemName,
                        priceText,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // 家政服务 - Services Tab
  static Widget _buildServicesTab(BuildContext context, dynamic service) {
    // 获取Controller实例
    final controller = Get.find<ServiceDetailController>();

    // 首次加载数据
    if (controller.servicePackages.isEmpty &&
        !controller.isLoadingServicePackages.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadServicePackages(service.id);
      });
    }

    return Obx(() {
      // 加载状态
      if (controller.isLoadingServicePackages.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading service packages...'),
              ],
            ),
          ),
        );
      }

      // 空状态
      if (controller.servicePackages.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cleaning_services,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No service packages available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This provider hasn\'t added any service packages yet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      // 数据展示
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Packages',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${controller.servicePackages.length} packages available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Services',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // 动态生成服务套餐
                    ...controller.servicePackages.map((item) {
                      // 获取名称
                      final itemName = item.name['en'] ??
                          item.name['zh'] ??
                          item.name.values.firstOrNull ??
                          'Unnamed Service';

                      // 格式化价格
                      final priceText =
                          '${item.currency ?? 'CAD'} ${item.price?.toStringAsFixed(2) ?? '0.00'}';

                      // 获取时长
                      final duration = item.duration?.toString() ?? 'Duration not specified';

                      return _buildServiceItem(
                        context,
                        itemName,
                        priceText,
                        duration,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // 共享租赁 - Inventory Tab
  static Widget _buildInventoryTab(BuildContext context, dynamic service) {
    // 获取Controller实例
    final controller = Get.find<ServiceDetailController>();

    // 首次加载数据
    if (controller.inventoryItems.isEmpty &&
        !controller.isLoadingInventoryItems.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadInventoryItems(service.id);
      });
    }

    return Obx(() {
      // 加载状态
      if (controller.isLoadingInventoryItems.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading inventory...'),
              ],
            ),
          ),
        );
      }

      // 空状态
      if (controller.inventoryItems.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No rental items available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This provider hasn\'t added any rental items yet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      // 数据展示
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rental Inventory',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${controller.inventoryItems.length} items available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Items',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // 动态生成库存项
                    ...controller.inventoryItems.map((item) {
                      // 获取名称
                      final itemName = item.name['en'] ??
                          item.name['zh'] ??
                          item.name.values.firstOrNull ??
                          'Unnamed Item';

                      // 确定库存状态
                      final currentStock = item.currentStock ?? 0;
                      final status =
                          currentStock > 0 ? 'Available ($currentStock)' : 'Rented Out';

                      // 格式化价格
                      final priceText =
                          '${item.currency ?? 'CAD'} ${item.price?.toStringAsFixed(2) ?? '0.00'}/day';

                      return _buildInventoryItem(
                        context,
                        itemName,
                        status,
                        priceText,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // 教育培训 - Courses Tab
  static Widget _buildCoursesTab(BuildContext context, dynamic service) {
    // 获取Controller实例
    final controller = Get.find<ServiceDetailController>();

    // 首次加载数据
    if (controller.courses.isEmpty && !controller.isLoadingCourses.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadCourses(service.id);
      });
    }

    return Obx(() {
      // 加载状态
      if (controller.isLoadingCourses.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading courses...'),
              ],
            ),
          ),
        );
      }

      // 空状态
      if (controller.courses.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No courses available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This provider hasn\'t added any courses yet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      // 数据展示
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Courses',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${controller.courses.length} courses available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Courses',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // 动态生成课程
                    ...controller.courses.map((item) {
                      // 获取课程名称
                      final courseName = item.name['en'] ??
                          item.name['zh'] ??
                          item.name.values.firstOrNull ??
                          'Unnamed Course';

                      // 获取课程级别（使用sub_category）
                      final level = item.subCategory ?? 'General Level';

                      // 获取课程描述（使用duration）
                      final description = item.duration?.toString() ?? 'Duration not specified';

                      // 格式化价格
                      final priceText =
                          '${item.currency ?? 'CAD'} ${item.price?.toStringAsFixed(2) ?? '0.00'}';

                      return _buildCourseItem(
                        context,
                        '$level - $courseName',
                        description,
                        priceText,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // 健康医疗 - Treatments Tab
  static Widget _buildTreatmentsTab(BuildContext context, dynamic service) {
    // 获取Controller实例
    final controller = Get.find<ServiceDetailController>();

    // 首次加载数据
    if (controller.treatments.isEmpty && !controller.isLoadingTreatments.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadTreatments(service.id);
      });
    }

    return Obx(() {
      // 加载状态
      if (controller.isLoadingTreatments.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading treatments...'),
              ],
            ),
          ),
        );
      }

      // 空状态
      if (controller.treatments.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medical_services,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No treatments available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This provider hasn\'t added any treatments yet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      // 数据展示
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medical Treatments',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${controller.treatments.length} treatments available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Treatments',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // 动态生成治疗项目
                    ...controller.treatments.map((item) {
                      // 获取治疗项目名称
                      final treatmentName = item.name['en'] ??
                          item.name['zh'] ??
                          item.name.values.firstOrNull ??
                          'Unnamed Treatment';

                      // 格式化价格
                      final priceText =
                          '${item.currency ?? 'CAD'} ${item.price?.toStringAsFixed(2) ?? '0.00'}';

                      // 获取时长
                      final duration = item.duration?.toString() ?? 'Duration not specified';

                      return _buildTreatmentItem(
                        context,
                        treatmentName,
                        priceText,
                        duration,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // 辅助方法
  static Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Widget _buildRatingBar(int stars, double percentage, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text('${(percentage * 100).toInt()}%'),
          ),
        ],
      ),
    );
  }

  static Widget _buildRecommendationItem(
      BuildContext context, String title, String rating, String price) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title),
          ),
          Text('$rating ⭐'),
          const SizedBox(width: 16),
          Text(price,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }

  static Widget _buildMenuItem(
      BuildContext context, String category, String name, String price) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text(name, style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text(price,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }

  static Widget _buildServiceItem(
      BuildContext context, String name, String price, String duration) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(name, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Text(duration, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(width: 16),
          Text(price,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }

  static Widget _buildInventoryItem(
      BuildContext context, String name, String status, String price) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(name, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status,
                style: TextStyle(color: Colors.green[800], fontSize: 12)),
          ),
          const SizedBox(width: 16),
          Text(price,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }

  static Widget _buildCourseItem(
      BuildContext context, String level, String description, String price) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(level, style: TextStyle(fontWeight: FontWeight.w600)),
                Text(description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Text(price,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
        ],
      ),
    );
  }

  static Widget _buildTreatmentItem(
      BuildContext context, String name, String price, String duration) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(name, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Text(duration, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(width: 16),
          Text(price,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        ],
      ),
    );
  }

  /// 构建服务特性
  static Widget _buildServiceFeatures(BuildContext context, dynamic service) {
    // 根据服务类型显示不同的特性
    final categoryId = service.categoryLevel1Id ?? '0';

    switch (categoryId) {
      case '1020000': // 家政服务
        return Column(
          children: [
            _buildFeatureItem(context, 'Professional Team',
                'Experienced cleaning professionals'),
            _buildFeatureItem(context, 'Eco-friendly Products',
                'Safe and environmentally friendly cleaning supplies'),
            _buildFeatureItem(context, 'Flexible Scheduling',
                'Available 7 days a week, flexible time slots'),
            _buildFeatureItem(
                context, 'Quality Guarantee', '100% satisfaction guarantee'),
          ],
        );

      case '1010000': // 餐饮服务
        return Column(
          children: [
            _buildFeatureItem(context, 'Fresh Ingredients',
                'Daily fresh ingredients from local suppliers'),
            _buildFeatureItem(context, 'Customizable Menu',
                'Personalized menu options available'),
            _buildFeatureItem(context, 'Dietary Options',
                'Vegetarian, vegan, and allergy-friendly options'),
            _buildFeatureItem(
                context, 'Fast Delivery', 'Quick delivery within 30 minutes'),
          ],
        );

      case '1030000': // 运输服务
        return Column(
          children: [
            _buildFeatureItem(context, 'Professional Drivers',
                'Licensed and experienced drivers'),
            _buildFeatureItem(
                context, 'GPS Tracking', 'Real-time location tracking'),
            _buildFeatureItem(
                context, '24/7 Service', 'Available round the clock'),
            _buildFeatureItem(context, 'Safe Vehicles',
                'Well-maintained and insured vehicles'),
          ],
        );

      default: // 通用服务
        return Column(
          children: [
            _buildFeatureItem(context, 'Professional Service',
                'High-quality professional service'),
            _buildFeatureItem(
                context, 'Customer Support', '24/7 customer support available'),
            _buildFeatureItem(
                context, 'Flexible Options', 'Customizable service options'),
            _buildFeatureItem(context, 'Quality Assurance',
                'Guaranteed quality and satisfaction'),
          ],
        );
    }
  }

  /// 构建特性项
  static Widget _buildFeatureItem(
      BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _getCategoryName(String? categoryId) {
    switch (categoryId) {
      case '1010000':
        return 'Food & Beverage';
      case '1020000':
        return 'Home Services';
      case '1030000':
        return 'Transportation';
      case '1040000':
        return 'Rental Services';
      case '1050000':
        return 'Education';
      case '1060000':
        return 'Technical Services';
      default:
        return 'General Service';
    }
  }

  static String _getSubCategoryName(String? subCategoryId) {
    switch (subCategoryId) {
      case '1010100':
        return 'Restaurant';
      case '1010200':
        return 'Catering';
      case '1020100':
        return 'Cleaning';
      case '1020200':
        return 'Maintenance';
      case '1030100':
        return 'Delivery';
      case '1030200':
        return 'Passenger Transport';
      case '1040100':
        return 'Equipment Rental';
      case '1040200':
        return 'Vehicle Rental';
      case '1050100':
        return 'Language Learning';
      case '1050200':
        return 'Skill Training';
      case '1060100':
        return 'IT Support';
      case '1060200':
        return 'Consulting';
      default:
        return 'General';
    }
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 辅助方法：获取本地化文本
  static String _getLocalizedText(dynamic value) {
    if (value is Map<String, dynamic>) {
      final lang = Get.locale?.languageCode ?? 'zh';
      return value[lang] ?? value['zh'] ?? value['en'] ?? '';
    } else if (value is String) {
      return value;
    }
    return '';
  }

  // 辅助方法：构建评价项（支持日期）
  static Widget _buildReviewItem(
      String customerName, int rating, String comment,
      [DateTime? date]) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  customerName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 16,
                  ),
                ),
              ),
              if (date != null) ...[
                const SizedBox(width: 8),
                Text(
                  _formatDate(date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
