import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
// Import AppColors
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations_en.dart';
import 'package:jinbeanpod_83904710/core/controllers/location_controller.dart';
import 'package:jinbeanpod_83904710/app/shell_app_controller.dart';
import 'package:jinbeanpod_83904710/core/plugin_management/plugin_manager.dart';
import 'package:jinbeanpod_83904710/features/service_booking/presentation/service_booking_controller.dart';
import 'package:jinbeanpod_83904710/core/ui/components/customer_theme_components.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/customer_theme_utils.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  // Helper function to map string icon names to IconData
  IconData _getIconData(String iconName) {
    if (iconName.isEmpty) {
      return Icons.category;
    }
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'home': return Icons.home;
      case 'directions_car': return Icons.directions_car;
      case 'share': return Icons.share;
      case 'school': return Icons.school;
      case 'work': return Icons.work;
      case 'help_outline': return Icons.help_outline;
      case 'location_on': return Icons.location_on;
      case 'apps': return Icons.apps;
      case 'cleaning_services': return Icons.cleaning_services;
      case 'grass': return Icons.grass;
      case 'ramen_dining': return Icons.ramen_dining;
      case 'miscellaneous_services': return Icons.miscellaneous_services;
      case 'newspaper': return Icons.newspaper;
      case 'card_giftcard': return Icons.card_giftcard;
      default: return Icons.category; // Default icon
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchHomeServices();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 圆角装饰头部
              _buildRoundedHeader(context),
              
              // 搜索栏
              _buildSearchBar(context),
              
              // 轮播图
              _buildCarouselSection(context),
              
              // 服务分类网格
              _buildServicesGrid(context),
              
              // 推荐服务
              _buildRecommendationsSection(context),
              
              // 社区热点
              _buildCommunitySection(context),
              
              // 底部安全区域
              SizedBox(height: MediaQuery.of(context).padding.bottom + 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      height: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.7),
            colorScheme.primary.withOpacity(0.5),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Stack(
        children: [
          // 大型装饰圆角元素
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 60,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(70),
              ),
            ),
          ),
          // 欢迎文本和图标
          Positioned(
            bottom: 20,
            left: 20,
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(22.5),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.celebration,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '欢迎使用金豆服务',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '为您提供优质便捷的生活服务',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 13,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black26,
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
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final locationController = Get.find<LocationController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: colorScheme.primary,
      foregroundColor: Colors.white,
      title: Row(
        children: [
          // Logo Container with improved design
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.home_repair_service,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // App Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'JinBean',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Location Button with improved design
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () => _showLocationOptions(context, locationController),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      locationController.effectiveLocation.address.split(',').first,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Notification Button
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: InkWell(
            onTap: () {
              // Navigate to notifications
              Get.toNamed('/notifications');
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Stack(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                  // Notification badge
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLocationOptions(BuildContext context, LocationController locationController) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Service Location',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Current Location
            Obx(() => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Location',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: 14,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          locationController.effectiveLocation.address,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (locationController.isLoading.value)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            )),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: locationController.isLoading.value 
                      ? null 
                      : () {
                          locationController.getCurrentLocation();
                          Navigator.pop(context);
                        },
                    icon: const Icon(Icons.my_location),
                    label: const Text('Use Current Location'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to location settings
                      Get.toNamed('/location_settings');
                    },
                    icon: const Icon(Icons.edit_location),
                    label: const Text('Change Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: CustomerSearchField(
        hintText: '搜索您需要的服务...',
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        showClear: controller.searchQuery.value.isNotEmpty,
        onClear: controller.clearSearch,
      ),
    );
  }

  Widget _buildCarouselSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomerSectionHeader(
            title: 'Featured Services',
            action: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
              ),
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View All',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: Obx(() => PageView.builder(
              controller: controller.pageController,
              itemCount: controller.carouselItems.length,
              onPageChanged: controller.onCarouselPageChanged,
              itemBuilder: (context, index) {
                final item = controller.carouselItems[index];
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => controller.onBannerTap(index),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        colorScheme.primary.withOpacity(0.3),
                                        colorScheme.primary,
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.image,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.8),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      shadows: [
                                        Shadow(
                                          offset: const Offset(0, 1),
                                          blurRadius: 3,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.description,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      shadows: [
                                        Shadow(
                                          offset: const Offset(0, 1),
                                          blurRadius: 2,
                                          color: Colors.black54,
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
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Service Categories',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Obx(() => GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1, // 调整为更合适的宽高比
            ),
            itemCount: controller.services.length,
            itemBuilder: (context, index) {
              final service = controller.services[index];
              return _buildServiceCategoryCard(context, service);
            },
          )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildServiceCategoryCard(BuildContext context, dynamic service) {
    return CustomerServiceCard(
      title: service.name,
      icon: service.icon,
      onTap: () {
        if (service.typeCode == 'SERVICE_TYPE') {
          // 切换到service_booking标签页并传递参数
          final shellController = Get.find<ShellAppController>();
          final pluginManager = Get.find<PluginManager>();
          
          // 找到service_booking标签页的索引
          final serviceBookingIndex = pluginManager.enabledTabPluginsForCurrentRole
              .indexWhere((plugin) => plugin.id == 'service_booking');
          
          if (serviceBookingIndex != -1) {
            // 切换到service_booking标签页
            shellController.changeTab(serviceBookingIndex);
            
            // 延迟传递参数，确保页面已经加载
            Future.delayed(const Duration(milliseconds: 300), () {
              try {
                final serviceBookingController = Get.find<ServiceBookingController>();
                serviceBookingController.selectLevel1Category(service.id);
              } catch (e) {
                print('Error selecting category: $e');
              }
            });
          }
        } else if (service.typeCode == 'FUNCTION') {
          switch (service.name) {
            case '求助':
              break;
            case '服务地图':
              try {
                final route = controller.getServiceMapRoute();
                print('Navigating to service map route: $route');
                Get.toNamed(route);
              } catch (e) {
                print('Error navigating to service map: $e');
                // 备用方案：显示提示信息
                Get.snackbar(
                  '功能开发中',
                  '服务地图功能正在开发中，敬请期待！',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  colorText: Colors.blue,
                  duration: const Duration(seconds: 2),
                );
              }
              break;
          }
        }
      },
    );
  }

  Widget _buildRecommendationsSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomerSectionHeader(
          title: 'Recommended for You',
          action: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
            ),
            child: TextButton(
              onPressed: () {
                Get.toNamed('/service_booking');
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View All',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        Obx(() {
          if (controller.isLoadingRecommendations.value) {
            return const CustomerLoadingState(message: 'Loading recommendations...');
          }
          
          if (controller.recommendations.isEmpty) {
            return const CustomerEmptyState(
              icon: Icons.recommend,
              title: '暂无推荐',
              subtitle: '完成更多订单后将为您推荐个性化服务',
            );
          }
          
          return SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.recommendations.length,
              itemBuilder: (context, index) {
                final recommendation = controller.recommendations[index];
                return CustomerRecommendationCard(
                  title: controller.getSafeLocalizedText(recommendation.name),
                  subtitle: recommendation.providerName,
                  imageUrl: recommendation.imageUrl,
                  rating: recommendation.rating,
                  price: double.tryParse(recommendation.price) ?? 0.0,
                  distance: recommendation.distance,
                  isPopular: recommendation.isPopular,
                  isNearby: recommendation.isNearby,
                  onTap: () {
                    print('DEBUG: Navigating to service detail with serviceId: ${recommendation.id}');
                    print('DEBUG: recommendation object: $recommendation');
                    print('DEBUG: recommendation.id type: ${recommendation.id.runtimeType}');
                    print('DEBUG: recommendation.id length: ${recommendation.id.length}');
                    print('DEBUG: recommendation.id isEmpty: ${recommendation.id.isEmpty}');
                    print('DEBUG: recommendation.id == "": ${recommendation.id == ""}');
                    print('DEBUG: recommendation.id == null: ${recommendation.id == null}');
                    
                    // 使用Get.toNamed的正确方式传递参数
                    final parameters = {'serviceId': recommendation.id};
                    print('DEBUG: Navigation parameters: $parameters');
                    
                    Get.toNamed('/service_detail', parameters: parameters);
                  },
                );
              },
            ),
          );
        }),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildCommunitySection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Obx(() => controller.hotspots.isEmpty
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomerSectionHeader(
                title: 'Community Updates',
                action: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                  ),
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'View All',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.hotspots.length,
                  itemBuilder: (context, index) {
                    final hotspot = controller.hotspots[index];
                    return Container(
                      width: 240,
                      margin: const EdgeInsets.only(right: 16),
                      child: CustomerCard(
                        onTap: () {
                          // TODO: Navigate to Hotspot Detail Page
                        },
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomerBadge(
                                  text: _getTypeLabel(hotspot.type),
                                  type: _getBadgeType(hotspot.type),
                                ),
                                const Spacer(),
                                if (hotspot.time != null)
                                  Text(
                                    hotspot.time!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Text(
                                controller.getSafeLocalizedText(hotspot.title),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                  height: 1.3,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ));
  }

  CustomerBadgeType _getBadgeType(String type) {
    switch (type) {
      case 'NEWS':
        return CustomerBadgeType.primary;
      case 'JOB':
        return CustomerBadgeType.success;
      case 'WELFARE':
        return CustomerBadgeType.warning;
      default:
        return CustomerBadgeType.secondary;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'NEWS':
        return Colors.blue[600]!;
      case 'JOB':
        return Colors.green[600]!;
      case 'WELFARE':
        return Colors.orange[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'NEWS':
        return 'News';
      case 'JOB':
        return 'Job';
      case 'WELFARE':
        return 'Welfare';
      default:
        return 'Other';
    }
  }
} 