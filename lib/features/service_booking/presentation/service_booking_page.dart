import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/service_booking/presentation/service_booking_controller.dart';
import 'package:jinbeanpod_83904710/l10n/generated/app_localizations.dart'; // 导入国际化类
import 'package:jinbeanpod_83904710/app/theme/app_colors.dart'; // Import AppColors
import 'package:jinbeanpod_83904710/core/controllers/location_controller.dart'; // 导入LocationController
import 'package:supabase_flutter/supabase_flutter.dart';

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
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
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
      child: Card(
        elevation: 1, // 进一步减少阴影
        shadowColor: Colors.black.withOpacity(0.04),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // 减少内边距
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white, // 简化背景，移除渐变
            border: Border.all(color: Colors.grey[100] ?? Colors.grey, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: Colors.grey[500],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller.searchController,
                  onChanged: controller.onSearchChanged,
                  onSubmitted: controller.onSearchSubmitted,
                  decoration: InputDecoration(
                    hintText: 'Search for services...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Obx(() => controller.searchQuery.value.isNotEmpty
                ? GestureDetector(
                    onTap: controller.clearSearch,
                    child: Icon(
                      Icons.clear,
                      color: Colors.grey[500],
                      size: 20,
                    ),
                  )
                : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevel1Categories() {
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
                      color: isSelected ? Colors.blue[600] : Colors.grey[100], // 简化设计
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected 
                        ? Border.all(color: Colors.blue[600] ?? Colors.blue, width: 1)
                        : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          ServiceBookingController.iconFromString(category.extraData['icon']),
                          size: 18, // 减小图标
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                        const SizedBox(width: 8), // 减少间距
                        Text(
                          controller.getSafeLocalizedText(category.displayName()),
                          style: TextStyle(
                            fontSize: 14, // 减小字体
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey[800],
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
  }

  Widget _buildLevel2Categories() {
    return Obx(() {
      if (controller.selectedLevel1CategoryId.value == null) {
        return const SizedBox.shrink();
      }
      
      if (controller.isLoadingLevel2.value) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(16), // 减少内边距
          child: const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 4), // 减少间距
                Text(
                  'Loading services...',
                  style: TextStyle(
                    color: Colors.grey,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[100] ?? Colors.grey),
          ),
          child: Column(
            children: [
              Icon(
                Icons.grid_view,
                size: 24, // 减小图标
                color: Colors.grey[400],
              ),
              const SizedBox(height: 4), // 减少间距
              Text(
                'No services available',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
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
                      color: Colors.blue[600],
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
              return _buildLevel2CategoryCard(category);
            },
          ),
          const SizedBox(height: 12), // 减少底部间距
        ],
      );
    });
  }

  Widget _buildLevel2CategoryCard(dynamic category) {
    return Card(
      elevation: 0, // 移除阴影
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  color: Colors.blue[50], // 简化背景
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.category,
                  color: Colors.blue[600],
                  size: 18, // 减小图标
                ),
              ),
              const SizedBox(height: 6), // 减少间距
              // 简化的文本
              Flexible(
                child: Text(
                  category.displayName(),
                  style: const TextStyle(
                    fontSize: 11, // 减小字体
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recommended Services',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isLoadingSearch.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
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
                  return _buildEnhancedServiceCard(service);
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
                  return _buildEnhancedRecommendedServiceCard(service);
                },
              ),
            );
          } else {
            return _buildEmptyServicesState();
          }
        }),
      ],
    );
  }

  Widget _buildEnhancedServiceCard(ServiceItem service) {
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
                              color: Colors.blue[600],
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

  Widget _buildEnhancedRecommendedServiceCard(RecommendedService service) {
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
                              color: Colors.blue[600],
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

  Widget _buildEmptyServicesState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.search_off,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Services Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or browse our categories',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              controller.clearSearch();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Browse Categories'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
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