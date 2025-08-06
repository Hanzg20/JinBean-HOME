import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service_detail_controller.dart';
import '../widgets/service_detail_card.dart';
import '../utils/service_detail_formatters.dart';

class ServiceBasicInfoSection extends StatelessWidget {
  final ServiceDetailController controller;

  const ServiceBasicInfoSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final service = controller.service.value;
      if (service == null) return const SizedBox.shrink();

      return ServiceDetailCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Service Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Category', _getCategoryName(service.categoryId)),
            _buildInfoRow('Status', service.isActive == true ? 'Active' : 'Inactive'),
            if (service.description != null)
              _buildInfoRow('Description', service.description),
            _buildInfoRow('Rating', ServiceDetailFormatters.formatRating(service.rating)),
            _buildInfoRow('Reviews', '${service.reviewCount} reviews'),
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String? categoryId) {
    // TODO: 实现分类名称获取逻辑
    return 'Service Category';
  }
}
