import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/entities/similar_service.dart';
import '../service_detail_controller.dart';

/// 相似服务推荐组件
class SimilarServicesSection extends StatelessWidget {
  final ServiceDetailController controller;

  const SimilarServicesSection({
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
                Icon(Icons.recommend, color: Colors.purple[600]),
                const SizedBox(width: 8),
                const Text(
                  '相似服务推荐',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showAllSimilarServices(),
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              final similarServices = controller.similarServices;
              if (similarServices.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          '暂无相似服务',
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
                children: similarServices.take(3).map((service) => 
                  _buildSimilarServiceCard(context, service)
                ).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarServiceCard(BuildContext context, SimilarService service) {
    return InkWell(
      onTap: () => _navigateToService(service.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // 服务图片
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: service.images != null && service.images!.isNotEmpty
                ? Image.network(
                    service.images!.first,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image),
                  ),
            ),
            const SizedBox(width: 12),
            
            // 服务信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ...List.generate(5, (index) => Icon(
                        index < (service.rating ?? 0) ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 14,
                      )),
                      const SizedBox(width: 4),
                      Text(
                        '(${service.reviewCount ?? 0})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      if (service.similarityScore != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(service.similarityScore! * 100).toInt()}% 匹配',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.purple[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // 价格
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  service.price != null ? '\$${service.price}' : '价格面议',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service.currency ?? 'USD',
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
    );
  }

  void _navigateToService(String serviceId) {
    Get.toNamed('/service_detail', parameters: {'serviceId': serviceId});
  }

  void _showAllSimilarServices() {
    Get.dialog(
      AlertDialog(
        title: const Text('所有相似服务'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Obx(() {
            final similarServices = controller.similarServices;
            return ListView.builder(
              itemCount: similarServices.length,
              itemBuilder: (context, index) {
                final service = similarServices[index];
                return ListTile(
                  leading: service.images != null && service.images!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          service.images!.first,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported, size: 20),
                            );
                          },
                        ),
                      )
                    : Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 20),
                      ),
                  title: Text(service.title),
                  subtitle: Text(
                    service.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    service.price != null ? '\$${service.price}' : '价格面议',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    _navigateToService(service.id);
                  },
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