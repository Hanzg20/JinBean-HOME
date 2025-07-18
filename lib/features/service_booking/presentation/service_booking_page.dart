import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'service_booking_controller.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface, // Use theme background color
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.serviceBookingPageTitle, // Use localized title
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          // 位置选择按钮
          Obx(() => IconButton(
            icon: Icon(
              Icons.location_on,
              color: locationController.isLoading.value 
                ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.5)
                : Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: locationController.isLoading.value 
              ? null 
              : () => _showLocationDialog(context, locationController),
          )),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 位置信息显示
              Obx(() => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '当前位置',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            locationController.effectiveLocation.address,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (locationController.isLoading.value)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        onPressed: () => locationController.getCurrentLocation(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              )),
              const SizedBox(height: 16),

              // Global Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜索服务...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Level 1 Categories
              Obx(() {
                print('=== Level 1 Categories Build ===');
                print('Loading state: ${controller.isLoadingLevel1.value}');
                print('Categories count: ${controller.level1Categories.length}');
                print('Selected category ID: ${controller.selectedLevel1CategoryId.value}');
                
                if (controller.isLoadingLevel1.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (controller.level1Categories.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        const Icon(Icons.category_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text('暂无服务分类', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return Container(
                  height: 64,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.level1Categories.length,
                    itemBuilder: (context, index) {
                      final category = controller.level1Categories[index];
                      final isSelected = controller.selectedLevel1CategoryId.value == category.id;
                      
                      print('=== Category Item Build ===');
                      print('Category: ${category.id} - ${category.displayName()}');
                      print('Is Selected: $isSelected');
                      print('Current Theme: ${Theme.of(context).colorScheme.primary}');
                      print('Selected Color: ${isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface}');
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Material(
                          elevation: isSelected ? 4 : 0,
                          color: Colors.transparent,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected 
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ] : null,
                            ),
                            child: InkWell(
                              onTap: () {
                                print('=== Category Tap ===');
                                print('Tapped category: ${category.id} - ${category.displayName()}');
                                print('Current selected ID: ${controller.selectedLevel1CategoryId.value}');
                                controller.selectLevel1Category(category.id);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    category.icon,
                                    size: 24,
                                    color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    controller.getSafeLocalizedText(category.name),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isSelected
                                        ? Theme.of(context).colorScheme.onPrimary
                                        : Theme.of(context).colorScheme.onSurface,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Level 2 Categories and Services List (Accordion style)
              Obx(() => controller.isLoadingLevel2.value
                ? const Center(child: CircularProgressIndicator())
                : controller.level2Categories.isEmpty
                  ? Center(
                      child: Column(
                        children: [
                          const Icon(Icons.category_outlined, size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text('请选择一个服务分类', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.level2Categories.length,
                      itemBuilder: (context, index) {
                        final level2Category = controller.level2Categories[index];
                        final isLevel2Selected = controller.selectedLevel2CategoryId.value == level2Category.id;

                        return ExpansionTile(
                          key: ValueKey('category_${level2Category.id}'),
                          title: Text(controller.getSafeLocalizedText(level2Category.name), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleMedium?.color)),
                          leading: Icon(level2Category.icon, color: Theme.of(context).colorScheme.primary),
                          onExpansionChanged: (isExpanded) {
                            if (isExpanded && controller.selectedLevel2CategoryId.value != level2Category.id) {
                              controller.selectLevel2Category(level2Category.id);
                            }
                          },
                          initiallyExpanded: isLevel2Selected,
                          maintainState: true,
                          children: [
                            Obx(() => controller.isLoadingServices.value
                              ? const Center(child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ))
                              : controller.services.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(Icons.info_outline, size: 48, color: Colors.grey),
                                          SizedBox(height: 8),
                                          Text('该分类下暂无服务', style: TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: controller.services.length,
                                    itemBuilder: (context, serviceIndex) {
                                      final service = controller.services[serviceIndex];
                                      
                                      // 计算距离
                                      double distance = 0.0;
                                      String distanceText = '';
                                      if (service.latitude != null && service.longitude != null) {
                                        distance = locationController.calculateDistance(
                                          service.latitude!,
                                          service.longitude!,
                                        );
                                        distanceText = locationController.formatDistance(distance);
                                      }
                                      
                                      return Card(
                                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        color: Theme.of(context).colorScheme.surface,
                                        child: InkWell(
                                          onTap: () {
                                            print('Service ${service.name} tapped');
                                            // Navigate to Service Detail Page
                                            Get.toNamed('/service_detail', parameters: {
                                              'serviceId': service.id,
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(12),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 80,
                                                  height: 80,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(8.0),
                                                    child: Image.network(
                                                      service.imageUrl,
                                                      width: 80,
                                                      height: 80,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) => 
                                                        const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                                      loadingBuilder: (context, child, progress) =>
                                                        progress == null ? child : const Center(child: CircularProgressIndicator()),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 15),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        controller.getSafeLocalizedText(service.name),
                                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleMedium?.color),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        controller.getSafeLocalizedText(service.description),
                                                        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.star, color: AppColors.warningColor, size: 16),
                                                          Text('${service.rating} (${service.reviews} reviews)', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                                                          if (distanceText.isNotEmpty) ...[
                                                            const SizedBox(width: 8),
                                                            Icon(Icons.location_on, color: Colors.grey, size: 14),
                                                            Text(distanceText, style: TextStyle(fontSize: 12, color: Colors.grey)),
                                                          ],
                                                        ],
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(service.price, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                            ),
                          ],
                        );
                      },
                    ),
                ),
                const SizedBox(height: 20),

                // Recommended Services Section
                Obx(() => controller.recommendedServices.isEmpty
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0.0), // Consistent padding
                            child: Text(
                              '为您推荐',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).textTheme.titleLarge?.color),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.recommendedServices.length,
                            itemBuilder: (context, index) {
                              final recommendation = controller.recommendedServices[index];
                              
                              // 计算距离
                              double distance = 0.0;
                              String distanceText = '';
                              if (recommendation.latitude != null && recommendation.longitude != null) {
                                distance = locationController.calculateDistance(
                                  recommendation.latitude!,
                                  recommendation.longitude!,
                                );
                                distanceText = locationController.formatDistance(distance);
                              }
                              
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                elevation: 1.0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                color: Theme.of(context).colorScheme.surface,
                                child: InkWell(
                                  onTap: () {
                                    print('Recommended service ${recommendation.name} tapped');
                                    // Navigate to Service Detail Page
                                    Get.toNamed('/service_detail', parameters: {
                                      'serviceId': recommendation.id,
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8.0),
                                            child: Image.network(
                                              recommendation.imageUrl,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => 
                                                const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                              loadingBuilder: (context, child, progress) =>
                                                progress == null ? child : const Center(child: CircularProgressIndicator()),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                recommendation.name,
                                                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4.0),
                                              Text(
                                                recommendation.description,
                                                style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8.0),
                                              Row(
                                                children: [
                                                  Text(
                                                    recommendation.recommendationReason,
                                                    style: TextStyle(fontSize: 12.0, color: Theme.of(context).colorScheme.primary, fontStyle: FontStyle.italic),
                                                  ),
                                                  if (distanceText.isNotEmpty) ...[
                                                    const SizedBox(width: 8),
                                                    Icon(Icons.location_on, color: Colors.grey, size: 14),
                                                    Text(distanceText, style: TextStyle(fontSize: 12, color: Colors.grey)),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
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

  // 显示位置选择对话框
  void _showLocationDialog(BuildContext context, LocationController locationController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择位置'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.my_location),
                title: const Text('使用当前位置'),
                subtitle: const Text('获取GPS定位'),
                onTap: () {
                  Navigator.of(context).pop();
                  locationController.getCurrentLocation();
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('搜索地址'),
                subtitle: const Text('手动输入地址'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showAddressSearchDialog(context, locationController);
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_city),
                title: const Text('常用城市'),
                subtitle: const Text('选择常用城市'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showCitySelectionDialog(context, locationController);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  // 显示地址搜索对话框
  void _showAddressSearchDialog(BuildContext context, LocationController locationController) {
    final TextEditingController searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('搜索地址'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: '输入地址或地点名称',
              prefixIcon: Icon(Icons.search),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                final address = searchController.text.trim();
                if (address.isNotEmpty) {
                  Navigator.of(context).pop();
                  final location = await locationController.searchLocationByAddress(address);
                  if (location != null) {
                    await locationController.selectLocation(location);
                    Get.snackbar('成功', '位置已更新');
                  } else {
                    Get.snackbar('错误', '未找到该地址');
                  }
                }
              },
              child: const Text('搜索'),
            ),
          ],
        );
      },
    );
  }

  // 显示城市选择对话框
  void _showCitySelectionDialog(BuildContext context, LocationController locationController) async {
    // 动态加载城市列表
    final supabase = Supabase.instance.client;
    final locale = Get.locale?.languageCode ?? 'zh';
    final List<Map<String, dynamic>> cityData = await supabase
        .from('ref_codes')
        .select('id, name, code, latitude, longitude')
        .eq('type_code', 'AREA_CODE')
        .inFilter('level', [3, 4]) // 3=城市, 4=直辖市/特殊城市
        .eq('status', 1)
        .order('sort_order', ascending: true);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择城市'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: cityData.length,
              itemBuilder: (context, index) {
                final city = cityData[index];
                final cityName = (city['name'] as Map<String, dynamic>)[locale] ?? (city['name'] as Map<String, dynamic>)['zh'] ?? (city['name'] as Map<String, dynamic>)['en'] ?? '';
                return ListTile(
                  title: Text(cityName),
                  subtitle: Text(city['code'] ?? ''),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final location = UserLocation(
                      latitude: city['latitude'] is num ? city['latitude'].toDouble() : 0.0,
                      longitude: city['longitude'] is num ? city['longitude'].toDouble() : 0.0,
                      address: cityName,
                      city: cityName,
                      district: '',
                      source: LocationSource.manual,
                      lastUpdated: DateTime.now(),
                    );
                    await locationController.selectLocation(location);
                    Get.snackbar('成功', '位置已更新为$cityName');
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }
}