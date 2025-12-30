import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/entities/service_detail.dart';
import '../service_detail_controller.dart';
import '../sections/service_reviews_section.dart';

/// 服务详情详情页面
/// 展示完整的服务详情信息，包含预订、咨询等功能
class ServiceDetailModal extends StatefulWidget {
  final ServiceDetail serviceDetail;
  final VoidCallback? onBook;
  final VoidCallback? onConsult;
  final VoidCallback? onAddToCart;

  const ServiceDetailModal({
    super.key,
    required this.serviceDetail,
    this.onBook,
    this.onConsult,
    this.onAddToCart,
  });

  @override
  State<ServiceDetailModal> createState() => _ServiceDetailModalState();
}

class _ServiceDetailModalState extends State<ServiceDetailModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedQuantity = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getServiceName()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: 实现收藏功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已添加到收藏')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: 实现分享功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('分享功能开发中')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 服务图片轮播
          _buildImageCarousel(),

          // Tab栏
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: const [
                Tab(text: '详情'),
                Tab(text: '规格'),
                Tab(text: '评价'),
              ],
            ),
          ),

          // Tab内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(),
                _buildSpecificationsTab(),
                _buildReviewsTab(),
              ],
            ),
          ),

          // 底部操作栏
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    final images = widget.serviceDetail.images;
    final hasImages = images != null && images.isNotEmpty;

    if (!hasImages) {
      return Container(
        height: 200,
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 64, color: Colors.grey),
              SizedBox(height: 8),
              Text('暂无图片', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 200,
      child: PageView.builder(
        itemCount: images!.length,
        itemBuilder: (context, index) {
          return Image.network(
            images[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 基本信息
          _buildBasicInfo(),
          const SizedBox(height: 24),

          // 服务描述
          _buildDescription(),
          const SizedBox(height: 24),

          // 服务特色
          _buildServiceFeatures(),
          const SizedBox(height: 24),

          // 服务区域
          _buildServiceAreas(),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '基本信息',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('服务名称', _getServiceName()),
            _buildInfoRow('子分类', widget.serviceDetail.subCategory ?? '无'),
            _buildInfoRow('价格类型', widget.serviceDetail.pricingType ?? '固定价格'),
            _buildInfoRow(
                '可用状态', widget.serviceDetail.isAvailable ? '可用' : '不可用'),
            if (widget.serviceDetail.currentStock != null)
              _buildInfoRow('库存数量', '${widget.serviceDetail.currentStock}'),
            if (widget.serviceDetail.duration != null)
              _buildInfoRow('服务时长', '${widget.serviceDetail.duration} 小时'),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    final description = _getServiceDescription();
    if (description.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '服务描述',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceFeatures() {
    final tags = widget.serviceDetail.tags;
    if (tags == null || tags.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '服务特色',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.blue[50],
                        side: BorderSide(color: Colors.blue[200]!),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceAreas() {
    final areas = widget.serviceDetail.serviceAreaCodes;
    if (areas == null || areas.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '服务区域',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: areas
                  .map((area) => Chip(
                        label: Text(area),
                        backgroundColor: Colors.green[50],
                        side: BorderSide(color: Colors.green[200]!),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 价格信息
          _buildPriceInfo(),
          const SizedBox(height: 24),

          // 数量选择
          _buildQuantitySelector(),
          const SizedBox(height: 24),

          // 其他规格
          _buildOtherSpecifications(),
        ],
      ),
    );
  }

  Widget _buildPriceInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '价格信息',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (widget.serviceDetail.price != null) ...[
              Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.green[600], size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.serviceDetail.price!.toStringAsFixed(2)} ${widget.serviceDetail.currency ?? 'CAD'}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.green[600],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '价格类型: ${widget.serviceDetail.pricingType ?? '固定价格'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ] else ...[
              const Text('价格面议'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '数量选择',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: _selectedQuantity > 1
                      ? () {
                          setState(() {
                            _selectedQuantity--;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_selectedQuantity',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedQuantity++;
                    });
                  },
                  icon: const Icon(Icons.add),
                ),
                const Spacer(),
                if (widget.serviceDetail.price != null)
                  Text(
                    '小计: ${(widget.serviceDetail.price! * _selectedQuantity).toStringAsFixed(2)} ${widget.serviceDetail.currency ?? 'CAD'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.green[600],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherSpecifications() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '其他规格',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (widget.serviceDetail.duration != null)
              _buildInfoRow('服务时长', '${widget.serviceDetail.duration} 小时'),
            if (widget.serviceDetail.negotiationDetails != null)
              _buildInfoRow('议价说明', widget.serviceDetail.negotiationDetails!),
            _buildInfoRow(
                '服务状态', widget.serviceDetail.isAvailable ? '可用' : '不可用'),
            if (widget.serviceDetail.currentStock != null)
              _buildInfoRow('库存状态', '${widget.serviceDetail.currentStock} 件可用'),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    // 使用真正的Reviews功能
    return ServiceReviewsSection(controller: Get.find<ServiceDetailController>());
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 咨询按钮
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.onConsult,
              icon: const Icon(Icons.chat, size: 18),
              label: const Text('咨询'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange[600],
                side: BorderSide(color: Colors.orange[600]!),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 预订按钮
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: widget.serviceDetail.isAvailable
                  ? () {
                      // 传递数量信息
                      if (widget.onBook != null) {
                        widget.onBook!();
                      }
                    }
                  : null,
              icon: const Icon(Icons.shopping_cart, size: 18),
              label: Text(
                widget.serviceDetail.isAvailable
                    ? '立即预订 ($_selectedQuantity)'
                    : '已售罄',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.serviceDetail.isAvailable
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _getServiceName() {
    if (widget.serviceDetail.name is Map<String, dynamic>) {
      final nameMap = widget.serviceDetail.name as Map<String, dynamic>;
      return nameMap['zh'] ?? nameMap['en'] ?? 'Unknown Service';
    }
    return widget.serviceDetail.name?.toString() ?? 'Unknown Service';
  }

  String _getServiceDescription() {
    if (widget.serviceDetail.description is Map<String, dynamic>) {
      final descMap = widget.serviceDetail.description as Map<String, dynamic>;
      return descMap['zh'] ?? descMap['en'] ?? '';
    }
    return widget.serviceDetail.description?.toString() ?? '';
  }
}
