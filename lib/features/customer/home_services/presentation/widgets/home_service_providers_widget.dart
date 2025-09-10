import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_logger.dart';

/// 家居服务提供商Widget
class HomeServiceProvidersWidget extends StatefulWidget {
  final String categoryId;
  final RxString selectedProvider;
  final Function(String) onProviderSelected;

  const HomeServiceProvidersWidget({
    super.key,
    required this.categoryId,
    required this.selectedProvider,
    required this.onProviderSelected,
  });

  @override
  State<HomeServiceProvidersWidget> createState() => _HomeServiceProvidersWidgetState();
}

class _HomeServiceProvidersWidgetState extends State<HomeServiceProvidersWidget> {
  final RxList<HomeServiceProvider> _providers = <HomeServiceProvider>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _sortBy = 'rating'.obs;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  @override
  void didUpdateWidget(HomeServiceProvidersWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryId != widget.categoryId) {
      _loadProviders();
    }
  }

  Future<void> _loadProviders() async {
    if (widget.categoryId.isEmpty) return;

    try {
      _isLoading.value = true;
      
      // 模拟加载服务提供商数据
      await Future.delayed(const Duration(milliseconds: 800));
      
      final providers = _generateMockProviders(widget.categoryId);
      _providers.assignAll(providers);
      _sortProviders();
      
    } catch (e) {
      AppLogger.error('🏠 加载服务提供商失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  List<HomeServiceProvider> _generateMockProviders(String categoryId) {
    final baseProviders = [
      HomeServiceProvider(
        id: 'provider_1',
        name: '专业家居服务团队',
        rating: 4.8,
        reviewCount: 156,
        distance: 2.3,
        profileImage: 'https://picsum.photos/seed/provider1/100/100',
        description: '拥有10年经验的专业团队，提供高质量服务',
        services: _getServicesForCategory(categoryId),
        priceRange: '\$50-150',
        responseTime: '30分钟内',
        isVerified: true,
        completedJobs: 234,
      ),
      HomeServiceProvider(
        id: 'provider_2',
        name: '快速响应服务',
        rating: 4.6,
        reviewCount: 89,
        distance: 1.8,
        profileImage: 'https://picsum.photos/seed/provider2/100/100',
        description: '快速响应，24小时服务',
        services: _getServicesForCategory(categoryId),
        priceRange: '\$40-120',
        responseTime: '15分钟内',
        isVerified: true,
        completedJobs: 167,
      ),
      HomeServiceProvider(
        id: 'provider_3',
        name: '优质家居护理',
        rating: 4.9,
        reviewCount: 203,
        distance: 3.1,
        profileImage: 'https://picsum.photos/seed/provider3/100/100',
        description: '注重细节，客户满意度第一',
        services: _getServicesForCategory(categoryId),
        priceRange: '\$60-180',
        responseTime: '45分钟内',
        isVerified: true,
        completedJobs: 312,
      ),
      HomeServiceProvider(
        id: 'provider_4',
        name: '经济实惠服务',
        rating: 4.3,
        reviewCount: 67,
        distance: 4.2,
        profileImage: 'https://picsum.photos/seed/provider4/100/100',
        description: '价格实惠，服务可靠',
        services: _getServicesForCategory(categoryId),
        priceRange: '\$30-100',
        responseTime: '60分钟内',
        isVerified: false,
        completedJobs: 98,
      ),
    ];

    return baseProviders;
  }

  List<String> _getServicesForCategory(String categoryId) {
    switch (categoryId) {
      case 'cleaning':
        return ['深度清洁', '定期清洁', '地毯清洗'];
      case 'repair':
        return ['水管维修', '电路维修', '家电维修'];
      case 'installation':
        return ['家具组装', '电视挂装', '灯具安装'];
      case 'gardening':
        return ['草坪修剪', '花园维护', '树木修剪'];
      default:
        return ['通用服务'];
    }
  }

  void _sortProviders() {
    switch (_sortBy.value) {
      case 'rating':
        _providers.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'distance':
        _providers.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case 'price':
        // 简单按价格范围排序（实际应该解析价格）
        _providers.sort((a, b) => a.priceRange.compareTo(b.priceRange));
        break;
      case 'reviews':
        _providers.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.categoryId.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_search,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                '请先选择服务分类',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }

      if (_isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return Column(
        children: [
          // 排序选择器
          _buildSortSelector(),
          
          // 服务商列表
          Expanded(
            child: _buildProvidersList(),
          ),
        ],
      );
    });
  }

  Widget _buildSortSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            '排序方式:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortChip('rating', '评分'),
                  _buildSortChip('distance', '距离'),
                  _buildSortChip('price', '价格'),
                  _buildSortChip('reviews', '评价数'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _sortBy.value == value;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            _sortBy.value = value;
            _sortProviders();
          }
        },
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue,
      ),
    );
  }

  Widget _buildProvidersList() {
    if (_providers.isEmpty) {
      return const Center(
        child: Text('该分类暂无服务提供商'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _providers.length,
      itemBuilder: (context, index) {
        final provider = _providers[index];
        final isSelected = widget.selectedProvider.value == provider.id;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: isSelected ? 4 : 1,
          child: InkWell(
            onTap: () => widget.onProviderSelected(provider.id),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 服务商基本信息
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(provider.profileImage),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    provider.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (provider.isVerified)
                                  const Icon(
                                    Icons.verified,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${provider.rating}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  ' (${provider.reviewCount})',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.location_on,
                                  color: Colors.grey[600],
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${provider.distance}km',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 服务商描述
                  Text(
                    provider.description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 服务信息
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '价格范围: ${provider.priceRange}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '响应时间: ${provider.responseTime}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '已完成 ${provider.completedJobs} 单',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '已选择',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 提供的服务
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: provider.services.map((service) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          service,
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 家居服务提供商模型
class HomeServiceProvider {
  final String id;
  final String name;
  final double rating;
  final int reviewCount;
  final double distance;
  final String profileImage;
  final String description;
  final List<String> services;
  final String priceRange;
  final String responseTime;
  final bool isVerified;
  final int completedJobs;

  HomeServiceProvider({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.profileImage,
    required this.description,
    required this.services,
    required this.priceRange,
    required this.responseTime,
    required this.isVerified,
    required this.completedJobs,
  });
}

