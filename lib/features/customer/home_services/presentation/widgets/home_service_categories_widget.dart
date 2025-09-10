import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/models/order_models.dart';
import '../../../../../core/utils/app_logger.dart';

/// 家居服务分类Widget
class HomeServiceCategoriesWidget extends StatefulWidget {
  final RxString selectedCategory;
  final Function(String) onCategorySelected;
  final Function(OrderItemRequest) onServiceSelected;

  const HomeServiceCategoriesWidget({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onServiceSelected,
  });

  @override
  State<HomeServiceCategoriesWidget> createState() => _HomeServiceCategoriesWidgetState();
}

class _HomeServiceCategoriesWidgetState extends State<HomeServiceCategoriesWidget> {
  final RxList<HomeServiceCategory> _categories = <HomeServiceCategory>[].obs;
  final RxList<HomeServiceItem> _services = <HomeServiceItem>[].obs;
  final RxBool _isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      _isLoading.value = true;
      
      // 模拟加载家居服务分类数据
      await Future.delayed(const Duration(milliseconds: 500));
      
      final categories = [
        HomeServiceCategory(
          id: 'cleaning',
          name: '清洁服务',
          icon: Icons.cleaning_services,
          description: '专业清洁服务，让您的家焕然一新',
          services: [
            HomeServiceItem(
              id: 'deep_cleaning',
              name: '深度清洁',
              description: '全面深度清洁服务，包括厨房、浴室、客厅等',
              price: 120.0,
              duration: 180,
              icon: Icons.cleaning_services,
            ),
            HomeServiceItem(
              id: 'regular_cleaning',
              name: '定期清洁',
              description: '定期维护清洁，保持家居整洁',
              price: 80.0,
              duration: 120,
              icon: Icons.home_filled,
            ),
            HomeServiceItem(
              id: 'carpet_cleaning',
              name: '地毯清洗',
              description: '专业地毯清洗服务，去除污渍和异味',
              price: 60.0,
              duration: 90,
              icon: Icons.cleaning_services,
            ),
          ],
        ),
        HomeServiceCategory(
          id: 'repair',
          name: '维修服务',
          icon: Icons.build,
          description: '专业维修服务，解决家居维修问题',
          services: [
            HomeServiceItem(
              id: 'plumbing',
              name: '水管维修',
              description: '专业水管维修，解决漏水、堵塞等问题',
              price: 100.0,
              duration: 120,
              icon: Icons.plumbing,
            ),
            HomeServiceItem(
              id: 'electrical',
              name: '电路维修',
              description: '安全电路维修，解决电路故障',
              price: 150.0,
              duration: 180,
              icon: Icons.electrical_services,
            ),
            HomeServiceItem(
              id: 'appliance_repair',
              name: '家电维修',
              description: '各类家电维修服务',
              price: 80.0,
              duration: 90,
              icon: Icons.home_repair_service,
            ),
          ],
        ),
        HomeServiceCategory(
          id: 'installation',
          name: '安装服务',
          icon: Icons.construction,
          description: '专业安装服务，家具、电器安装',
          services: [
            HomeServiceItem(
              id: 'furniture_assembly',
              name: '家具组装',
              description: '专业家具组装服务',
              price: 50.0,
              duration: 60,
              icon: Icons.chair,
            ),
            HomeServiceItem(
              id: 'tv_mounting',
              name: '电视挂装',
              description: '安全电视挂装服务',
              price: 70.0,
              duration: 90,
              icon: Icons.tv,
            ),
            HomeServiceItem(
              id: 'fixture_installation',
              name: '灯具安装',
              description: '各类灯具安装服务',
              price: 60.0,
              duration: 75,
              icon: Icons.lightbulb,
            ),
          ],
        ),
        HomeServiceCategory(
          id: 'gardening',
          name: '园艺服务',
          icon: Icons.grass,
          description: '专业园艺服务，美化您的花园',
          services: [
            HomeServiceItem(
              id: 'lawn_mowing',
              name: '草坪修剪',
              description: '定期草坪修剪服务',
              price: 40.0,
              duration: 60,
              icon: Icons.grass,
            ),
            HomeServiceItem(
              id: 'garden_maintenance',
              name: '花园维护',
              description: '花园整体维护服务',
              price: 80.0,
              duration: 120,
              icon: Icons.local_florist,
            ),
            HomeServiceItem(
              id: 'tree_trimming',
              name: '树木修剪',
              description: '专业树木修剪服务',
              price: 120.0,
              duration: 180,
              icon: Icons.park,
            ),
          ],
        ),
      ];
      
      _categories.assignAll(categories);
      
      // 如果有预选分类，加载对应服务
      if (widget.selectedCategory.value.isNotEmpty) {
        _loadServicesForCategory(widget.selectedCategory.value);
      }
      
    } catch (e) {
      AppLogger.error('🏠 加载家居服务分类失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void _loadServicesForCategory(String categoryId) {
    final category = _categories.firstWhereOrNull((cat) => cat.id == categoryId);
    if (category != null) {
      _services.assignAll(category.services);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return Column(
        children: [
          // 分类选择器
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = widget.selectedCategory.value == category.id;
                
                return GestureDetector(
                  onTap: () {
                    widget.onCategorySelected(category.id);
                    _loadServicesForCategory(category.id);
                  },
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category.icon,
                          size: 32,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 服务列表
          Expanded(
            child: widget.selectedCategory.value.isEmpty
                ? _buildCategoryOverview()
                : _buildServicesList(),
          ),
        ],
      );
    });
  }

  Widget _buildCategoryOverview() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Icon(
                category.icon,
                color: Colors.blue,
              ),
            ),
            title: Text(
              category.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(category.description),
            trailing: Text(
              '${category.services.length} 项服务',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            onTap: () {
              widget.onCategorySelected(category.id);
              _loadServicesForCategory(category.id);
            },
          ),
        );
      },
    );
  }

  Widget _buildServicesList() {
    if (_services.isEmpty) {
      return const Center(
        child: Text('该分类暂无服务'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      service.icon,
                      color: Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${service.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          '约 ${service.duration} 分钟',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _addServiceToBooking(service),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('选择服务'),
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

  void _addServiceToBooking(HomeServiceItem service) {
    final orderItem = OrderItemRequest(
      serviceDetailId: service.id,
      name: service.name,
      description: service.description,
      quantity: 1,
      unitPrice: service.price,
      customizations: {},
      specialInstructions: null,
    );

    widget.onServiceSelected(orderItem);
  }
}

/// 家居服务分类模型
class HomeServiceCategory {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final List<HomeServiceItem> services;

  HomeServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.services,
  });
}

/// 家居服务项目模型
class HomeServiceItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final int duration; // 分钟
  final IconData icon;

  HomeServiceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.icon,
  });
}
