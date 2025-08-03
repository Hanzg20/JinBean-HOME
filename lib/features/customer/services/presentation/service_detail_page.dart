import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/services/presentation/service_detail_controller.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';
import 'package:jinbeanpod_83904710/core/ui/components/customer_theme_components.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/customer_theme_utils.dart';

class ServiceDetailPage extends GetView<ServiceDetailController> {
  const ServiceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (controller.service.value == null) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(
              title: Text('Service Detail', style: theme.textTheme.titleLarge),
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
            ),
            body: const Center(
              child: CustomerEmptyState(
                icon: Icons.error_outline,
                title: 'Service not found',
                subtitle: 'The requested service could not be found',
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: CustomScrollView(
            slivers: [
              // 优化的SliverAppBar
              _buildSliverAppBar(context),
              
              // 内容区域 - 卡片化布局
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 服务标题和评分卡片
                      _buildServiceHeaderCard(),
                      const SizedBox(height: 16),
                      
                      // 服务提供商信息卡片
                      _buildProviderInfoCard(),
                      const SizedBox(height: 16),
                      
                      // 价格和规格选择卡片
                      _buildPricingCard(),
                      const SizedBox(height: 16),
                      
                      // 服务详情卡片
                      _buildServiceDetailsCard(),
                      const SizedBox(height: 16),
                      
                      // 服务图片卡片
                      _buildServiceImagesCard(),
                      const SizedBox(height: 16),
                      
                      // 服务区域卡片
                      _buildServiceAreaCard(),
                      const SizedBox(height: 16),
                      
                      // 用户留言区域卡片
                      _buildMessageCard(),
                      const SizedBox(height: 80), // 为底部操作栏留空间
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(),
        );
      }),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 服务图片
            Obx(() => controller.serviceDetail.value?.images.isNotEmpty == true
                ? Image.network(
                    controller.serviceDetail.value!.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: colorScheme.surfaceVariant,
                        child: Icon(Icons.image, size: 80, color: colorScheme.onSurfaceVariant),
                      );
                    },
                  )
                : Container(
                    color: colorScheme.surfaceVariant,
                    child: Icon(Icons.image, size: 80, color: colorScheme.onSurfaceVariant),
                  )),
            // 渐变遮罩
            Container(
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
            // 操作按钮
            Positioned(
              top: 50,
              right: 16,
              child: Row(
                children: [
                  _buildActionButton(
                    icon: Icons.share,
                    onTap: controller.shareService,
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.favorite_border,
                    onTap: controller.addToFavorites,
                  ),
                ],
              ),
            ),
          ],
        ),
        title: Obx(() => Text(
          controller.service.value?.title ?? 'Service',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        )),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildServiceHeaderCard() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return CustomerCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => Text(
                        controller.service.value?.title ?? 'Service Name',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      )),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Obx(() => Text(
                          '${controller.service.value?.averageRating ?? 0.0}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        )),
                        Obx(() => Text(
                          ' (${controller.service.value?.reviewCount ?? 0})',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(() => Text(
                  controller.service.value?.description ?? 'Service description',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                )),
                const SizedBox(height: 12),
                // 添加写点评按钮
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showWriteReviewDialog(),
                    icon: Icon(Icons.edit, size: 18, color: colorScheme.primary),
                    label: Text(
                      'Write a Review',
                      style: TextStyle(color: colorScheme.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: colorScheme.primary),
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

  void _showWriteReviewDialog() {
    final TextEditingController reviewController = TextEditingController();
    final RxDouble rating = 5.0.obs;
    final RxBool isAnonymous = false.obs;
    final RxList<String> selectedTags = <String>[].obs;
    
    final availableTags = [
      'Professional', 'On Time', 'Fair Price', 'Quality Work',
      'Friendly', 'Clean', 'Fast', 'Reliable', 'Recommended'
    ];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.rate_review, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  const Text(
                    'Write Review',
                    style: TextStyle(
                      fontSize: 20,
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
              
              // Rating Stars
              const Text(
                'Rating',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => rating.value = index + 1.0,
                    child: Icon(
                      index < rating.value ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  );
                }),
              )),
              const SizedBox(height: 20),
              
              // Review Text
              const Text(
                'Your Review',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reviewController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Share your experience with this service...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Tags
              const Text(
                'Tags (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableTags.map((tag) {
                  return Obx(() => FilterChip(
                    label: Text(tag),
                    selected: selectedTags.contains(tag),
                    onSelected: (selected) {
                      if (selected) {
                        selectedTags.add(tag);
                      } else {
                        selectedTags.remove(tag);
                      }
                    },
                  ));
                }).toList(),
              ),
              const SizedBox(height: 20),
              
              // Anonymous Option
              Obx(() => CheckboxListTile(
                title: const Text('Post anonymously'),
                value: isAnonymous.value,
                onChanged: (value) => isAnonymous.value = value ?? false,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              )),
              const SizedBox(height: 20),
              
              // Action Buttons
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
                        // TODO: Submit review
                        Get.back();
                        Get.snackbar(
                          'Review Submitted',
                          'Thank you for your feedback!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green[100],
                          colorText: Colors.green[800],
                        );
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

  Widget _buildProviderInfoCard() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return CustomerCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.business, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Service Provider',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() => Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: colorScheme.surfaceVariant,
                      child: Icon(Icons.person, size: 30, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.provider.value?.companyName ?? 'Provider Name',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${controller.provider.value?.ratingsAvg ?? 0.0}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                ' • ${controller.provider.value?.reviewCount ?? 0} reviews',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildContactButton(colorScheme),
                  ],
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactButton(ColorScheme colorScheme) {
    return ElevatedButton.icon(
      icon: Icon(Icons.phone, size: 16, color: colorScheme.onPrimary),
      label: Text(
        'Contact',
        style: TextStyle(color: colorScheme.onPrimary),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: controller.contactProvider,
    );
  }

  Widget _buildPricingCard() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return CustomerCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Pricing',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final serviceDetail = controller.serviceDetail.value;
                  if (serviceDetail?.pricingType == 'negotiable') {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Price is negotiable. Contact provider for quote.',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Row(
                      children: [
                        Text(
                          '\$',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          serviceDetail?.price?.toStringAsFixed(2) ?? '75',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          '/hour',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Text(
                            'Best Value',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                }),
                const SizedBox(height: 8),
                Text(
                  'Free consultation • No hidden fees • Satisfaction guaranteed',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceDetailsCard() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return CustomerCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Service Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final serviceDetail = controller.serviceDetail.value;
                  return Column(
                    children: [
                      _buildDetailRow('Duration', serviceDetail?.duration?.toString() ?? '2-3 hours', colorScheme),
                      _buildDetailRow('Service Type', serviceDetail?.durationType ?? 'On-site', colorScheme),
                      _buildDetailRow('Availability', 'Mon-Sun, 8AM-8PM', colorScheme),
                      _buildDetailRow('Response Time', 'Within 2 hours', colorScheme),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceImagesCard() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return CustomerCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.photo_library, color: Colors.purple, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Service Photos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final images = controller.serviceDetail.value?.images ?? [];
                  if (images.isEmpty) {
                    return Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: colorScheme.surfaceVariant,
                      ),
                      child: Icon(Icons.image, size: 40, color: colorScheme.onSurfaceVariant),
                    );
                  }
                  return SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: colorScheme.surfaceVariant,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.image, size: 40, color: colorScheme.onSurfaceVariant);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceAreaCard() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return CustomerCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Service Area',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.surfaceVariant,
                  ),
                  child: Icon(Icons.map, size: 40, color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final areas = controller.serviceDetail.value?.serviceAreaCodes ?? [];
                  if (areas.isEmpty) {
                    return Text(
                      'Serving Toronto, Mississauga, Brampton, and surrounding areas',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    );
                  }
                  return Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: areas.map((area) => Chip(
                      label: Text(area),
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      side: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
                      labelStyle: TextStyle(color: colorScheme.primary),
                    )).toList(),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageCard() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return CustomerCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.message, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Send Message',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller.messageController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Ask about availability, pricing, or special requirements...',
                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.chat, size: 16, color: colorScheme.primary),
                        label: Text(
                          'Start Chat',
                          style: TextStyle(color: colorScheme.primary),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: colorScheme.primary),
                        ),
                        onPressed: controller.startChat,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.send, size: 16, color: colorScheme.onPrimary),
                        label: Text(
                          'Send',
                          style: TextStyle(color: colorScheme.onPrimary),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: controller.sendMessage,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.favorite_border, color: colorScheme.primary),
                    label: Text(
                      'Save',
                      style: TextStyle(color: colorScheme.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: colorScheme.primary),
                    ),
                    onPressed: controller.addToFavorites,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.calendar_today, color: colorScheme.onPrimary),
                    label: Text(
                      'Book Now',
                      style: TextStyle(color: colorScheme.onPrimary),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      // TODO: Navigate to booking page
                      Get.snackbar(
                        'Booking',
                        'Redirecting to booking page...',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 