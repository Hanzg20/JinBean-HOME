import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/entities/service_detail.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

/// 增强版服务详情卡片
/// 包含完整的服务信息展示和交互功能
class EnhancedServiceDetailCard extends StatelessWidget {
  final ServiceDetail serviceDetail;
  final VoidCallback? onTap;
  final VoidCallback? onBook;
  final VoidCallback? onConsult;
  final VoidCallback? onAddToCart;
  final bool showActions;

  const EnhancedServiceDetailCard({
    super.key,
    required this.serviceDetail,
    this.onTap,
    this.onBook,
    this.onConsult,
    this.onAddToCart,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部信息
              _buildHeader(context),
              const SizedBox(height: 12),

              // 服务描述
              if (serviceDetail.description != null) _buildDescription(context),

              // 价格和库存信息
              _buildPriceAndStock(context),

              // 标签
              if (serviceDetail.tags != null && serviceDetail.tags!.isNotEmpty)
                _buildTags(context),

              // 操作按钮
              if (showActions) ...[
                const SizedBox(height: 16),
                _buildActionButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 服务图片
        _buildServiceImage(context),
        const SizedBox(width: 12),

        // 服务信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 服务名称
              Text(
                _getServiceName(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // 子分类
              if (serviceDetail.subCategory != null) ...[
                const SizedBox(height: 4),
                Text(
                  '子分类: ${serviceDetail.subCategory}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],

              // 可用状态
              const SizedBox(height: 8),
              _buildAvailabilityStatus(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceImage(BuildContext context) {
    final images = serviceDetail.images;
    final hasImages = images != null && images.isNotEmpty;

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: hasImages
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                images!.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildImagePlaceholder();
                },
              ),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: const Icon(
        Icons.image,
        color: Colors.grey,
        size: 32,
      ),
    );
  }

  Widget _buildAvailabilityStatus(BuildContext context) {
    final isAvailable = serviceDetail.isAvailable;
    final stockInfo = _getStockInfo();

    return Row(
      children: [
        Icon(
          isAvailable ? Icons.check_circle : Icons.cancel,
          color: isAvailable ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          stockInfo,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isAvailable ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    final description = _getServiceDescription();
    if (description.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPriceAndStock(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // 价格信息
          if (serviceDetail.price != null) ...[
            Icon(
              Icons.attach_money,
              color: Colors.green[600],
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              '${serviceDetail.price!.toStringAsFixed(2)} ${serviceDetail.currency ?? 'CAD'}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green[600],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              serviceDetail.pricingType ?? 'fixed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],

          const Spacer(),

          // 库存信息
          if (serviceDetail.currentStock != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: serviceDetail.currentStock! > 0
                    ? Colors.green[50]
                    : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: serviceDetail.currentStock! > 0
                      ? Colors.green[200]!
                      : Colors.red[200]!,
                ),
              ),
              child: Text(
                '库存: ${serviceDetail.currentStock}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: serviceDetail.currentStock! > 0
                          ? Colors.green[700]
                          : Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    final tags = serviceDetail.tags!;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: tags
          .take(3)
          .map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  tag,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // 查看详情按钮
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.info_outline, size: 18),
            label: const Text('查看详情'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // 咨询按钮
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onConsult,
            icon: const Icon(Icons.chat, size: 18),
            label: const Text('咨询'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange[600],
              side: BorderSide(color: Colors.orange[600]!),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // 预订/加入购物车按钮
        Expanded(
          child: ElevatedButton.icon(
            onPressed: serviceDetail.isAvailable ? onBook : null,
            icon: const Icon(Icons.shopping_cart, size: 18),
            label: Text(serviceDetail.isAvailable ? '预订' : '已售罄'),
            style: ElevatedButton.styleFrom(
              backgroundColor: serviceDetail.isAvailable
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  String _getServiceName() {
    if (serviceDetail.name is Map<String, dynamic>) {
      final nameMap = serviceDetail.name as Map<String, dynamic>;
      return nameMap['zh'] ?? nameMap['en'] ?? 'Unknown Service';
    }
    return serviceDetail.name?.toString() ?? 'Unknown Service';
  }

  String _getServiceDescription() {
    if (serviceDetail.description is Map<String, dynamic>) {
      final descMap = serviceDetail.description as Map<String, dynamic>;
      return descMap['zh'] ?? descMap['en'] ?? '';
    }
    return serviceDetail.description?.toString() ?? '';
  }

  String _getStockInfo() {
    if (!serviceDetail.isAvailable) {
      return '不可用';
    }

    if (serviceDetail.currentStock != null) {
      if (serviceDetail.currentStock! <= 0) {
        return '已售罄';
      } else if (serviceDetail.currentStock! <= 5) {
        return '库存紧张 (${serviceDetail.currentStock})';
      } else {
        return '有库存 (${serviceDetail.currentStock})';
      }
    }

    return '可用';
  }
}
