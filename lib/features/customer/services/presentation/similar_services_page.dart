import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/services/presentation/service_detail_controller.dart';
import 'package:jinbeanpod_83904710/core/ui/components/customer_theme_components.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/customer_theme_utils.dart';

class SimilarServicesPage extends StatelessWidget {
  final String currentServiceId;
  final String categoryId;
  
  const SimilarServicesPage({
    super.key,
    required this.currentServiceId,
    required this.categoryId,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Similar Services'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 筛选器
          _buildFilters(theme),
          // 服务列表
          Expanded(
            child: _buildServicesList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: Text('Price: \$0-\$50'),
                selected: true,
                onSelected: (selected) {},
                backgroundColor: colorScheme.surface,
                selectedColor: colorScheme.primary.withOpacity(0.1),
                checkmarkColor: colorScheme.primary,
              ),
              FilterChip(
                label: Text('Rating: 4.0+'),
                selected: false,
                onSelected: (selected) {},
                backgroundColor: colorScheme.surface,
                selectedColor: colorScheme.primary.withOpacity(0.1),
                checkmarkColor: colorScheme.primary,
              ),
              FilterChip(
                label: Text('Distance: <10km'),
                selected: false,
                onSelected: (selected) {},
                backgroundColor: colorScheme.surface,
                selectedColor: colorScheme.primary.withOpacity(0.1),
                checkmarkColor: colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(ThemeData theme) {
    // 模拟相似服务数据
    final similarServices = [
      SimilarService(
        id: 'similar_1',
        providerId: 'provider_789',
        providerName: 'CleanMaster Pro',
        serviceTitle: 'Professional Home Cleaning',
        price: 42.0,
        rating: 4.7,
        reviewCount: 89,
        similarityScore: 0.92,
        providerAvatar: 'https://picsum.photos/80/80?random=1',
        advantages: ['Lower price', 'Faster response'],
        disadvantages: ['Smaller service area'],
      ),
      SimilarService(
        id: 'similar_2',
        providerId: 'provider_101',
        providerName: 'Sparkle & Shine',
        serviceTitle: 'Complete Home Cleaning Service',
        price: 48.0,
        rating: 4.9,
        reviewCount: 156,
        similarityScore: 0.88,
        providerAvatar: 'https://picsum.photos/80/80?random=2',
        advantages: ['Higher rating', 'More reviews'],
        disadvantages: ['Higher price'],
      ),
      SimilarService(
        id: 'similar_3',
        providerId: 'provider_202',
        providerName: 'EcoClean Solutions',
        serviceTitle: 'Eco-Friendly Home Cleaning',
        price: 45.0,
        rating: 4.6,
        reviewCount: 67,
        similarityScore: 0.85,
        providerAvatar: 'https://picsum.photos/80/80?random=3',
        advantages: ['Eco-friendly', 'Same price'],
        disadvantages: ['Fewer reviews'],
      ),
      SimilarService(
        id: 'similar_4',
        providerId: 'provider_303',
        providerName: 'QuickClean Express',
        serviceTitle: 'Fast & Efficient Cleaning',
        price: 38.0,
        rating: 4.4,
        reviewCount: 45,
        similarityScore: 0.82,
        providerAvatar: 'https://picsum.photos/80/80?random=4',
        advantages: ['Lowest price', 'Quick service'],
        disadvantages: ['Lower rating'],
      ),
      SimilarService(
        id: 'similar_5',
        providerId: 'provider_404',
        providerName: 'Premium Clean Co',
        serviceTitle: 'Luxury Home Cleaning',
        price: 55.0,
        rating: 4.8,
        reviewCount: 203,
        similarityScore: 0.80,
        providerAvatar: 'https://picsum.photos/80/80?random=5',
        advantages: ['Premium service', 'High rating'],
        disadvantages: ['Higher price'],
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: similarServices.length,
      itemBuilder: (context, index) {
        final service = similarServices[index];
        return _buildServiceCard(service, theme);
      },
    );
  }

  Widget _buildServiceCard(SimilarService service, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return CustomerCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => Get.toNamed('/service_detail', parameters: {'serviceId': service.id}),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(64),
          bottomLeft: const Radius.circular(16),
          bottomRight: const Radius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 提供商头像
                  CircleAvatar(
                    backgroundImage: NetworkImage(service.providerAvatar),
                    radius: 32,
                    onBackgroundImageError: (exception, stackTrace) {
                      // 处理图片加载错误
                    },
                  ),
                  const SizedBox(width: 16),
                  
                  // 服务信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.providerName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.serviceTitle,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${service.rating} (${service.reviewCount} reviews)',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 相似度标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(6),
                        topRight: const Radius.circular(24),
                        bottomLeft: const Radius.circular(6),
                        bottomRight: const Radius.circular(6),
                      ),
                    ),
                    child: Text(
                      '${(service.similarityScore * 100).toInt()}% Match',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 价格和优势信息
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${service.price}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (service.advantages.isNotEmpty)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Advantages:',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            service.advantages.join(', '),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green[600],
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              if (service.disadvantages.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Note: ${service.disadvantages.join(', ')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.orange[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 