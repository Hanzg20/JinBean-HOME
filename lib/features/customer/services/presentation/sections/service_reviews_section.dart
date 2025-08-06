import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/entities/review.dart';
import '../service_detail_controller.dart';

/// 服务评价组件
class ServiceReviewsSection extends StatelessWidget {
  final ServiceDetailController controller;

  const ServiceReviewsSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[600]),
                const SizedBox(width: 8),
                const Text(
                  '用户评价',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showAllReviews(),
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 评价统计
            Obx(() {
              final service = controller.service.value;
              return Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${service?.rating?.toStringAsFixed(1) ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      Row(
                        children: List.generate(5, (index) {
                          final rating = service?.rating ?? 0;
                          return Icon(
                            index < rating.floor() ? Icons.star : 
                            (index < rating ? Icons.star_half : Icons.star_border),
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${service?.reviewCount ?? 0} 条评价',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '基于真实用户评价',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // 评价列表
            Obx(() {
              final reviews = controller.reviews;
              if (reviews.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          '暂无评价',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return Column(
                children: reviews.take(3).map((review) => 
                  _buildReviewCard(review)
                ).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: review.userAvatar != null 
                  ? NetworkImage(review.userAvatar!) 
                  : null,
                child: review.userAvatar == null 
                  ? Text(review.userName?.substring(0, 1).toUpperCase() ?? 'U')
                  : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName ?? '匿名用户',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) => Icon(
                          index < review.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        )),
                        const SizedBox(width: 8),
                        Text(
                          review.createdAt.toString().substring(0, 10),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (review.isVerified)
                Icon(Icons.verified, color: Colors.blue, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.comment),
          if (review.images != null && review.images!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.images!.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        review.images![index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAllReviews() {
    Get.dialog(
      AlertDialog(
        title: const Text('所有评价'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: Obx(() {
            final reviews = controller.reviews;
            return ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: review.userAvatar != null 
                      ? NetworkImage(review.userAvatar!) 
                      : null,
                    child: review.userAvatar == null 
                      ? Text(review.userName?.substring(0, 1).toUpperCase() ?? 'U')
                      : null,
                  ),
                  title: Text(review.userName ?? '匿名用户'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ...List.generate(5, (index) => Icon(
                            index < review.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 14,
                          )),
                          const SizedBox(width: 8),
                          Text(
                            review.createdAt.toString().substring(0, 10),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        review.comment,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  trailing: review.isVerified 
                    ? const Icon(Icons.verified, color: Colors.blue, size: 16)
                    : null,
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
} 