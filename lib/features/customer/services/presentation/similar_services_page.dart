import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/services/presentation/service_detail_controller.dart';
import 'package:jinbeanpod_83904710/core/ui/components/customer_theme_components.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/customer_theme_utils.dart';
import '../../domain/entities/similar_service.dart';

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
        title: 'Professional Home Cleaning',
        description: 'Complete home cleaning service with professional equipment',
        price: 42.0,
        currency: 'USD',
        categoryId: 'cleaning',
        providerId: 'provider_789',
        images: ['https://picsum.photos/300/200?random=1'],
        rating: 4.7,
        reviewCount: 89,
        similarityScore: 0.92,
      ),
      SimilarService(
        id: 'similar_2',
        title: 'Complete Home Cleaning Service',
        description: 'Comprehensive cleaning service for all areas of your home',
        price: 48.0,
        currency: 'USD',
        categoryId: 'cleaning',
        providerId: 'provider_101',
        images: ['https://picsum.photos/300/200?random=2'],
        rating: 4.9,
        reviewCount: 156,
        similarityScore: 0.88,
      ),
      SimilarService(
        id: 'similar_3',
        title: 'Eco-Friendly Home Cleaning',
        description: 'Environmentally friendly cleaning service using green products',
        price: 45.0,
        currency: 'USD',
        categoryId: 'cleaning',
        providerId: 'provider_202',
        images: ['https://picsum.photos/300/200?random=3'],
        rating: 4.6,
        reviewCount: 67,
        similarityScore: 0.85,
      ),
      SimilarService(
        id: 'similar_4',
        title: 'Fast & Efficient Cleaning',
        description: 'Quick and efficient cleaning service for busy households',
        price: 38.0,
        currency: 'USD',
        categoryId: 'cleaning',
        providerId: 'provider_303',
        images: ['https://picsum.photos/300/200?random=4'],
        rating: 4.4,
        reviewCount: 45,
        similarityScore: 0.82,
      ),
      SimilarService(
        id: 'similar_5',
        title: 'Luxury Home Cleaning',
        description: 'Premium cleaning service with attention to detail',
        price: 55.0,
        currency: 'USD',
        categoryId: 'cleaning',
        providerId: 'provider_404',
        images: ['https://picsum.photos/300/200?random=5'],
        rating: 4.8,
        reviewCount: 203,
        similarityScore: 0.80,
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
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => Get.toNamed('/service_detail', parameters: {'serviceId': service.id}),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (service.images != null && service.images!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        service.images!.first,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.image,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${service.price}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      if (service.similarityScore != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(service.similarityScore! * 100).toInt()}% match',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 