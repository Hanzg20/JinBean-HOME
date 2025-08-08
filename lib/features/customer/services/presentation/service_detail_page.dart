import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/service.dart';
import 'service_detail_controller.dart';
import 'widgets/service_detail_error.dart';
import 'widgets/service_detail_card.dart';
import 'utils/professional_remarks_templates.dart';
import 'sections/service_basic_info_section.dart';
import 'sections/service_actions_section.dart';
import 'sections/service_map_section.dart';
import 'sections/similar_services_section.dart';
import 'sections/service_reviews_section.dart';
import 'sections/provider_details_section.dart';

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

  @override
  void initState() {
    super.initState();
    
    String finalServiceId = Get.parameters['serviceId'] ?? widget.serviceId;
    controller = Get.put(ServiceDetailController());
    _tabController = TabController(length: 5, vsync: this);
    
    if (finalServiceId.isNotEmpty) {
      _loadServiceDetail(finalServiceId);
    }
  }

  Future<void> _loadServiceDetail(String serviceId) async {
    try {
      await controller.loadServiceDetail(serviceId);
      AppLogger.info('Service detail loaded successfully');
    } catch (e) {
      AppLogger.error('Failed to load service detail: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        // 统一状态检查，避免多重嵌套Obx
        final isLoading = controller.isLoading.value;
        final hasError = controller.hasError.value;
        final service = controller.service.value;
        
        if (hasError) {
          return ServiceDetailError(
            message: controller.errorMessage.value,
            onRetry: () => _loadServiceDetail(widget.serviceId),
          );
        }

        if (isLoading || service == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildPageContent();
      }),
    );
  }

  Widget _buildPageContent() {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          // 简化的图片展示区域
          _buildSimpleImageHeader(),
          // 简化的TabBar
          _buildSimpleTabBar(),
          // TabBarView内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildOverviewTab(),
                _buildDetailsTab(),
                _buildProviderTab(),
                _buildReviewsTab(),
                _buildPersonalizedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleImageHeader() {
    final service = controller.service.value;
    
    return Container(
      height: 200,
      width: double.infinity,
      child: _buildServiceImages(service),
    );
  }

  Widget _buildSimpleTabBar() {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
        indicatorWeight: 2,
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

  Widget _buildServiceImages(Service? service) {
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
        
        // 如果是placeholder图片或网络不可达，显示默认图片
        if (imageUrl.contains('via.placeholder.com') || imageUrl.isEmpty) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
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
        
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // 记录错误但不让应用崩溃
            AppLogger.warning('Image loading failed: $imageUrl - $error');
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Image not available', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ServiceBasicInfoSection(controller: controller),
          const SizedBox(height: 16),
          ServiceActionsSection(controller: controller),
          const SizedBox(height: 16),
          _buildServiceFeaturesSection(),
          const SizedBox(height: 16),
          _buildQualityAssuranceSection(),
          const SizedBox(height: 16),
          ServiceMapSection(controller: controller),
          const SizedBox(height: 16),
          SimilarServicesSection(controller: controller),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildServiceDetailsSection(),
          const SizedBox(height: 16),
          _buildProfessionalQualificationSection(),
          const SizedBox(height: 16),
          _buildServiceExperienceSection(),
          const SizedBox(height: 16),
          _buildServiceTermsSection(),
          const SizedBox(height: 16),
          _buildServiceProcessSection(),
        ],
      ),
    );
  }

  // 服务特色说明 (专业模板系统)  
  Widget _buildServiceFeaturesSection() {
    // 提前获取值，避免嵌套Obx
    final serviceType = _getServiceType();
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
  }

  // 质量保证说明 (专业模板系统)
  Widget _buildQualityAssuranceSection() {
    // 提前获取值，避免嵌套Obx
    final serviceType = _getServiceType();
    final providerData = _getProviderData();
    final qualityAssurance = ProfessionalRemarksTemplates.getQualityAssurance(serviceType, providerData);
    
    return ServiceDetailSection(
      title: 'Quality Assurance',
      icon: Icons.verified_user,
      iconColor: Colors.green[600],
      content: Text(
        qualityAssurance,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  // 服务详细信息
  Widget _buildServiceDetailsSection() {
    // 提前获取数据，避免在复杂组件中嵌套Obx
    final service = controller.service.value;
    final serviceDetail = controller.serviceDetail.value;
    
    return ServiceDetailSection(
      title: 'Service Details',
      icon: Icons.info_outline,
      content: _buildServiceDetailsContent(service, serviceDetail),
    );
  }

  Widget _buildServiceDetailsContent(Service? service, serviceDetail) {
    if (service == null) {
      return const Text('Loading service details...');
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ServiceDetailRow(
          label: 'Category',
          value: _getCategoryName(service.categoryId?.toString() ?? '0'),
          icon: Icons.category,
        ),
        if (service.description?.isNotEmpty == true)
          ServiceDetailRow(
            label: 'Description',
            value: service.description!,
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
            value: '${service.rating!.toStringAsFixed(1)} ⭐',
            icon: Icons.star,
          ),
        if (service.reviewCount != null && service.reviewCount! > 0)
          ServiceDetailRow(
            label: 'Reviews',
            value: '${service.reviewCount} reviews',
            icon: Icons.reviews,
          ),
        if (service.price != null)
          ServiceDetailRow(
            label: 'Price',
            value: '\$${service.price!.toStringAsFixed(2)}',
            icon: Icons.attach_money,
          ),
        if (serviceDetail?.currency != null)
          ServiceDetailRow(
            label: 'Currency',
            value: serviceDetail?.currency ?? 'CAD',
            icon: Icons.monetization_on,
          ),
      ],
    );
  }

  // 专业资质说明 (专业模板系统)
  Widget _buildProfessionalQualificationSection() {
    // 提前获取值，避免嵌套Obx
    final serviceType = _getServiceType();
    final providerData = _getProviderData();
    final qualification = ProfessionalRemarksTemplates.getProfessionalQualification(serviceType, providerData);
    
    return ServiceDetailSection(
      title: 'Professional Qualifications',
      icon: Icons.workspace_premium,
      iconColor: Colors.amber[700],
      content: Text(
        qualification,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  // 服务经验说明 (专业模板系统)
  Widget _buildServiceExperienceSection() {
    // 提前获取值，避免嵌套Obx
    final serviceType = _getServiceType();
    final providerData = _getProviderData();
    final experience = ProfessionalRemarksTemplates.getServiceExperience(serviceType, providerData);
    
    return ServiceDetailSection(
      title: 'Service Experience',
      icon: Icons.history,
      iconColor: Colors.blue[600],
      content: Text(
        experience,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  // 服务条款
  Widget _buildServiceTermsSection() {
    return ServiceDetailSection(
      title: 'Service Terms',
      icon: Icons.policy,
      content: Column(
        children: [
          ServiceDetailRow(
            label: 'Cancellation Policy',
            value: 'Standard 24-hour cancellation policy',
            icon: Icons.cancel,
          ),
          ServiceDetailRow(
            label: 'Refund Policy',
            value: 'Full refund within 48 hours if not satisfied',
            icon: Icons.money,
          ),
          ServiceDetailRow(
            label: 'Insurance Coverage',
            value: 'Fully insured and bonded',
            icon: Icons.security,
          ),
          ServiceDetailRow(
            label: 'Quality Guarantee',
            value: '100% satisfaction guarantee',
            icon: Icons.verified,
          ),
        ],
      ),
    );
  }

  // 服务流程
  Widget _buildServiceProcessSection() {
    return ServiceDetailSection(
      title: 'Service Process',
      icon: Icons.route,
      content: Column(
        children: [
          _buildProcessStep(1, 'Book Service', 'Choose your preferred time and date'),
          _buildProcessStep(2, 'Confirmation', 'Receive booking confirmation and provider details'),
          _buildProcessStep(3, 'Service Delivery', 'Professional service at your location'),
          _buildProcessStep(4, 'Payment', 'Secure payment after service completion'),
          _buildProcessStep(5, 'Review', 'Rate and review your experience'),
        ],
      ),
    );
  }

  Widget _buildProcessStep(int step, String title, String description) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
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
      ),
    );
  }

  // Helper methods for professional remarks templates
  String _getServiceType() {
    final service = controller.service.value;
    if (service?.categoryId != null) {
      final categoryId = service!.categoryId!;
      switch (categoryId) {
        case '1010000': return ProfessionalRemarksTemplates.FOOD_SERVICE;
        case '1020000': return ProfessionalRemarksTemplates.CLEANING_SERVICE;
        case '1030000': return ProfessionalRemarksTemplates.TRANSPORTATION_SERVICE;
        case '1040000': return ProfessionalRemarksTemplates.TECHNOLOGY_SERVICE;
        case '1050000': return ProfessionalRemarksTemplates.EDUCATION_SERVICE;
        case '1060000': return ProfessionalRemarksTemplates.HEALTH_SERVICE;
        default: return ProfessionalRemarksTemplates.GENERAL_SERVICE;
      }
    }
    return ProfessionalRemarksTemplates.GENERAL_SERVICE;
  }

  Map<String, dynamic>? _getProviderData() {
    final provider = controller.providerProfile.value;
    if (provider == null) return null;
    
    return {
      'completedOrders': provider.completedOrders,
      'rating': provider.rating,
      'reviewCount': provider.reviewCount,
      'isVerified': provider.isVerified,
      'businessLicense': provider.businessLicense,
    };
  }

  String _getCategoryName(String categoryId) {
    switch (categoryId) {
      case '1010000': return 'Food Court';
      case '1020000': return 'Home Services';
      case '1030000': return 'Transportation';
      case '1040000': return 'Shared Services';
      case '1050000': return 'Education';
      case '1060000': return 'Life Assistance';
      default: return 'General Service';
    }
  }

  String _getDeliveryMethodName(String method) {
    switch (method) {
      case 'on_site': return 'On-site Service';
      case 'online': return 'Online Service';
      case 'remote': return 'Remote Service';
      default: return 'Standard Delivery';
    }
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours hour${hours > 1 ? 's' : ''}';
      } else {
        return '$hours hour${hours > 1 ? 's' : ''} $remainingMinutes minutes';
      }
    }
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
