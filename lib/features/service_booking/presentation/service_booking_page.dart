import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/service_booking/presentation/service_booking_controller.dart';
import 'package:jinbeanpod_83904710/l10n/generated/app_localizations.dart'; // 导入国际化类
import 'package:jinbeanpod_83904710/app/theme/app_colors.dart'; // Import AppColors
import 'package:jinbeanpod_83904710/core/controllers/location_controller.dart'; // 导入LocationController
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/ui/components/customer_theme_components.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/customer_theme_utils.dart';

class ServiceBookingPage extends GetView<ServiceBookingController> {
  const ServiceBookingPage({super.key});

  // Helper function to map string icon names to IconData
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'home_outlined': return Icons.home_outlined;
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'share': return Icons.share;
      case 'school': return Icons.school;
      case 'work': return Icons.work;
      case 'cleaning_services': return Icons.cleaning_services;
      case 'plumbing': return Icons.plumbing;
      case 'electrical_services': return Icons.electrical_services;
      case 'ramen_dining': return Icons.ramen_dining;
      case 'cake': return Icons.cake;
      case 'newspaper': return Icons.newspaper;
      case 'card_giftcard': return Icons.card_giftcard;
      case 'miscellaneous_services': return Icons.miscellaneous_services; // General service icon
      default: return Icons.category; // Default icon
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context, locationController),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchLevel1Categories();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 搜索栏
              _buildSearchBar(),
              
              // 一级分类选择
              _buildLevel1Categories(),
              
              // 二级分类网格
              _buildLevel2Categories(),
              
              // 推荐服务
              _buildRecommendedServices(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, LocationController locationController) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppBar(
      elevation: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      // 移除标题，节省空间
      title: const SizedBox.shrink(),
      centerTitle: false,
      // 减少高度
      toolbarHeight: 48, // 进一步减少高度
      // 移除所有actions，让设计更简洁
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildLocationCard(LocationController locationController) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.blue[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Location',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      locationController.effectiveLocation.address,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                  ],
                ),
              ),
              Obx(() => locationController.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: Icon(Icons.refresh, color: Colors.grey[600], size: 20),
                    onPressed: () => locationController.getCurrentLocation(),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12), // 进一步减少间距
      child: CustomerSearchField(
        hintText: 'Search for services...',
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        showClear: controller.searchQuery.value.isNotEmpty,
        onClear: controller.clearSearch,
      ),
    );
  }

  Widget _buildLevel1Categories() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return Container(
          height: 56, // 减少高度，参考Yelp
          margin: const EdgeInsets.symmetric(vertical: 4), // 减少垂直间距
          child: Obx(() {
            if (controller.isLoadingLevel1.value) {
              return const Center(child: CircularProgressIndicator());
            }
            
            // 强制刷新UI
            final selectedId = controller.selectedLevel1CategoryId.value;
            print('=== Obx Rebuild === Selected ID: $selectedId');
            
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.level1Categories.length,
              itemBuilder: (context, index) {
                final category = controller.level1Categories[index];
                final isSelected = selectedId == category.id;
                
                // 添加调试信息
                print('=== UI Debug ===');
                print('Category: ${category.displayName()}, ID: ${category.id}');
                print('Selected ID: $selectedId');
                print('Is Selected: $isSelected');
                
                return Container(
                  margin: const EdgeInsets.only(right: 8), // 减少间距
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // 添加触觉反馈
                        HapticFeedback.lightImpact();
                        print('=== Tapping Category: ${category.displayName()} (ID: ${category.id}) ===');
                        controller.selectLevel1Category(category.id);
                      },
                      borderRadius: BorderRadius.circular(20), // 减少圆角
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200), // 减少动画时间
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 减少内边距
                        decoration: BoxDecoration(
                          color: isSelected ? colorScheme.primary : colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected 
                            ? Border.all(color: colorScheme.primary, width: 1)
                            : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              ServiceBookingController.iconFromString(category.extraData['icon']),
                              size: 18, // 减小图标
                              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8), // 减少间距
                            Text(
                              controller.getSafeLocalizedText(category.displayName()),
                              style: TextStyle(
                                fontSize: 14, // 减小字体
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }

  Widget _buildLevel2Categories() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return Obx(() {
          if (controller.selectedLevel1CategoryId.value == null) {
            return const SizedBox.shrink();
          }
          
          if (controller.isLoadingLevel2.value) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(16), // 减少内边距
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    const SizedBox(height: 4), // 减少间距
                    Text(
                      'Loading services...',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          if (controller.level2Categories.isEmpty) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(12), // 减少内边距
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.grid_view,
                    size: 24, // 减小图标
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 4), // 减少间距
                  Text(
                    'No services available',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 简化的header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // 减少垂直间距
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${controller.level2Categories.length} Services',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 紧凑的网格布局
              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 改为3列，参考Yelp
                  crossAxisSpacing: 8, // 减少间距
                  mainAxisSpacing: 8, // 减少间距
                  childAspectRatio: 0.8, // 调整比例
                ),
                itemCount: controller.level2Categories.length,
                itemBuilder: (context, index) {
                  final category = controller.level2Categories[index];
                  return _buildLevel2CategoryCard(category, colorScheme);
                },
              ),
              const SizedBox(height: 12), // 减少底部间距
            ],
          );
        });
      },
    );
  }

  Widget _buildLevel2CategoryCard(dynamic category, ColorScheme colorScheme) {
    return Card(
      elevation: 0, // 移除阴影
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: colorScheme.surface,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to service detail page
          Get.snackbar('Service', 'Opening service details...', snackPosition: SnackPosition.BOTTOM);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8), // 减少内边距
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 简化的图标容器
              Container(
                width: 32, // 减小图标容器
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1), // 简化背景
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.category,
                  color: colorScheme.primary,
                  size: 18, // 减小图标
                ),
              ),
              const SizedBox(height: 6), // 减少间距
              // 简化的文本
              Flexible(
                child: Text(
                  category.displayName(),
                  style: TextStyle(
                    fontSize: 11, // 减小字体
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedServices() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomerSectionHeader(
              title: 'Recommended Services',
              action: TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.isLoadingSearch.value) {
                return const CustomerLoadingState(message: 'Loading services...');
              }
              
              if (controller.services.isNotEmpty) {
                return SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.services.length,
                    itemBuilder: (context, index) {
                      final service = controller.services[index];
                      return _buildEnhancedServiceCard(service, colorScheme);
                    },
                  ),
                );
              } else if (controller.recommendedServices.isNotEmpty) {
                return SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.recommendedServices.length,
                    itemBuilder: (context, index) {
                      final service = controller.recommendedServices[index];
                      return _buildEnhancedRecommendedServiceCard(service, colorScheme);
                    },
                  ),
                );
              } else {
                return const CustomerEmptyState(
                  icon: Icons.search_off,
                  title: 'No Services Found',
                  subtitle: 'Try adjusting your search or browse our categories',
                  actionText: 'Browse Categories',
                  onAction: null, // TODO: Implement action
                );
              }
            }),
          ],
        );
      },
    );
  }

  Widget _buildEnhancedServiceCard(ServiceItem service, ColorScheme colorScheme) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Get.toNamed('/service_detail', arguments: {'serviceId': service.id});
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Image.network(
                    service.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.home_repair_service,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Name
                      Text(
                        controller.getSafeLocalizedText(service.name),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Service Description
                      Text(
                        controller.getSafeLocalizedText(service.description),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      
                      // Rating and Reviews
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            '${service.rating}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            ' (${service.reviews})',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      // Price and Action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${service.price}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedRecommendedServiceCard(RecommendedService service, ColorScheme colorScheme) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Get.toNamed('/service_detail', arguments: {'serviceId': service.id});
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Image with Recommendation Badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: Image.network(
                        service.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.home_repair_service,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Recommended',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Name
                      Text(
                        controller.getSafeLocalizedText(service.name),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Recommendation Reason
                      Text(
                        service.recommendationReason,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange[700],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      
                      // Rating and Reviews
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            '${service.rating}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            ' (${service.reviews})',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      // Price and Action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${service.price}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationDialog(BuildContext context, LocationController locationController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Location'),
        content: const Text('Location selection dialog will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}