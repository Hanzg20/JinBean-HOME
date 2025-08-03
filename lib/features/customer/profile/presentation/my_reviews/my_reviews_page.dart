import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './my_reviews_controller.dart';
import 'package:jinbeanpod_83904710/core/ui/components/customer_theme_components.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/customer_theme_utils.dart';

class MyReviewsPage extends GetView<MyReviewsController> {
  const MyReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('My Reviews', style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.onSurface)),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const CustomerLoadingState(message: 'Loading your reviews...');
        }
        
        if (controller.reviews.isEmpty) {
          return const CustomerEmptyState(
            icon: Icons.rate_review,
            title: 'No Reviews Yet',
            subtitle: 'Your reviews will appear here once you write them',
            actionText: 'Write Your First Review',
            onAction: null, // TODO: Navigate to service booking
          );
        }
        
        return RefreshIndicator(
          onRefresh: controller.loadReviews,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.reviews.length,
            itemBuilder: (context, index) {
              final review = controller.reviews[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CustomerCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 服务名称和评分
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                review.serviceName ?? 'Service',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${review.rating}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // 评价内容
                        Text(
                          review.comment,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // 评价时间
                        Text(
                          'Reviewed on ${review.date}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
} 