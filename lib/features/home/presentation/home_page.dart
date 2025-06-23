import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import 'package:jinbeanpod_83904710/l10n/generated/app_localizations.dart';
import 'package:jinbeanpod_83904710/app/theme/app_colors.dart'; // Import AppColors

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  // Helper function to map string icon names to IconData
  IconData _getIconData(String iconName) {
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface, // Changed from AppColors.backgroundColor
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            'JinBeanPod',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary, // Changed from AppColors.cardColor
            ),
          ),
        ),
        actions: [
          // Removed search icon as per user request
          IconButton(
            icon: Icon(Icons.notifications_none, color: Theme.of(context).colorScheme.onPrimary), // Changed from AppColors.cardColor
            onPressed: () {
              // TODO: Implement navigation to a dedicated notifications page
              print('Notifications icon tapped');
            },
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary, // Changed from AppColors.primaryColor
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Adjusted overall padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Card (Removed as per user request)
              // Obx(() => Card(...)),
              // SizedBox(height: 16), // Removed corresponding SizedBox

              // Carousel for Ads and Hot Events
              SizedBox(
                height: 180, // Increased height for better visual impact
                child: Obx(() => PageView.builder(
                  controller: controller.pageController,
                  itemCount: controller.carouselItems.length,
                  onPageChanged: controller.onCarouselPageChanged,
                  itemBuilder: (context, index) {
                    final item = controller.carouselItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 5), // Added horizontal margin
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image, 
                                  color: Colors.grey, 
                                  size: 48
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Theme.of(context).colorScheme.onSurface.withOpacity(0.7), Colors.transparent], // Changed from AppColors.textColor
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface, // Changed from AppColors.cardColor
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), // Changed from AppColors.cardColor.withOpacity(0.7)
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )),
              ),
              const SizedBox(height: 10),
              Center(
                child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(controller.carouselItems.length, (index) {
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: controller.currentCarouselIndex.value == index
                            ? Theme.of(context).colorScheme.primary // Changed from AppColors.primaryColor
                            : Theme.of(context).textTheme.bodySmall?.color, // Changed from AppColors.lightTextColor
                      ),
                    );
                  }),
                )),
              ),
              const SizedBox(height: 20),

              // Search Bar (New position)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0), // Match overall padding
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for services...',
                    hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color), // Changed from AppColors.lightTextColor
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary), // Changed from AppColors.primaryColor
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface, // Changed from AppColors.cardColor
                  ),
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color), // Changed from AppColors.textColor
                ),
              ),
              const SizedBox(height: 20),

              // Services Grid Section (updated for 2x4 layout, title removed)
              // Text('Categories & Functions', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).textTheme.titleLarge?.color)),
              // const SizedBox(height: 10),
              Obx(() => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 2x4布局
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: controller.services.length,
                itemBuilder: (context, index) {
                  final service = controller.services[index];
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Theme.of(context).colorScheme.surface,
                    child: InkWell(
                      onTap: () {
                        print('=== Service Item Tapped ===');
                        print('Service: ${service.id} - ${service.name} - ${service.typeCode}');
                        
                        if (service.typeCode == 'SERVICE_TYPE') {
                          print('Navigating to service booking with category ID: ${service.id}');
                          Get.toNamed('/service_booking', arguments: {'level1CategoryId': service.id});
                        } else if (service.typeCode == 'FUNCTION') {
                          print('Function item tapped: ${service.name}');
                          // Handle function-specific navigation
                          switch (service.name) {
                            case '求助':
                              // Get.toNamed('/help');
                              break;
                            case '服务地图':
                              // Get.toNamed('/service_map');
                              break;
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(service.icon, size: 36, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(height: 8),
                            Text(
                              service.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )),
              const SizedBox(height: 20),

              // Community Hotspots Section
              Obx(() => controller.hotspots.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0.0), // Consistent padding
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '社区热点',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).textTheme.titleLarge?.color),
                              ),
                              GestureDetector(
                                onTap: () {
                                  print('View All Community Hotspots tapped');
                                  // TODO: Navigate to Community Hotspots List Page
                                },
                                child: Text(
                                  '查看全部',
                                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 120.0, // Height for horizontal cards
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.hotspots.length,
                            itemBuilder: (context, index) {
                              final hotspot = controller.hotspots[index];
                              return Card(
                                margin: const EdgeInsets.only(right: 10.0),
                                elevation: 1.0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                color: Theme.of(context).colorScheme.surface,
                                child: InkWell(
                                  onTap: () {
                                    print('Hotspot ${hotspot.title} tapped');
                                    // TODO: Navigate to Hotspot Detail Page
                                  },
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Container(
                                    width: 200.0,
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(_getIconData(hotspot.type == 'NEWS' ? 'newspaper' : (hotspot.type == 'JOB' ? 'work' : 'card_giftcard')), size: 18.0, color: Colors.grey[600]),
                                            const SizedBox(width: 4.0),
                                            Text(
                                              hotspot.type == 'NEWS' ? '新闻' : (hotspot.type == 'JOB' ? '招聘' : '福利'),
                                              style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8.0),
                                        Text(
                                          hotspot.title,
                                          style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (hotspot.time != null) ...[
                                          const SizedBox(height: 4.0),
                                          Text(
                                            hotspot.time!,
                                            style: TextStyle(fontSize: 10.0, color: Colors.grey[500]),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
              ),
              const SizedBox(height: 20),

              // Recommended Services Section
              Obx(() {
                if (controller.isLoadingRecommendations.value) {
                  return const Center(child: CircularProgressIndicator());
                } else if (controller.recommendations.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('暂无推荐服务', style: TextStyle(color: Colors.grey)),
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          '推荐服务',
                          style: Get.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          itemCount: controller.recommendations.length,
                          itemBuilder: (context, index) {
                            final service = controller.recommendations[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                              child: Container(
                                width: 150,
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      _getIconData(service.serviceIcon),
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 30,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      controller.getLocalizedText(service.serviceName),
                                      style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Expanded(
                                      child: Text(
                                        controller.getLocalizedText(service.serviceDescription),
                                        style: Get.textTheme.bodySmall,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      service.recommendationReason,
                                      style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
} 