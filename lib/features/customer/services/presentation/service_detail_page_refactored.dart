import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/service_detail_controller.dart';
import 'widgets/service_detail_card.dart';
import 'widgets/service_detail_loading.dart';
import 'utils/service_detail_formatters.dart';
import 'utils/service_detail_constants.dart';
import 'models/service_detail_state.dart';

/// 重构后的服务详情页面
class ServiceDetailPageRefactored extends StatefulWidget {
  final String serviceId;

  const ServiceDetailPageRefactored({
    Key? key,
    required this.serviceId,
  }) : super(key: key);

  @override
  State<ServiceDetailPageRefactored> createState() => _ServiceDetailPageRefactoredState();
}

class _ServiceDetailPageRefactoredState extends State<ServiceDetailPageRefactored>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ServiceDetailController controller;
  final ServiceDetailState state = ServiceDetailState();

  @override
  void initState() {
    super.initState();
    controller = Get.put(ServiceDetailController());
    _tabController = TabController(length: 4, vsync: this);
    _loadServiceDetail();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadServiceDetail() async {
    state.isLoading.value = true;
    state.hasError.value = false;
    
    try {
      await controller.loadServiceDetail(widget.serviceId);
      state.service.value = controller.service;
      state.serviceDetail.value = controller.serviceDetail;
    } catch (e) {
      state.errorMessage.value = e.toString();
      state.hasError.value = true;
    } finally {
      state.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (state.isLoading.value) {
          return const ServiceDetailLoading(
            message: 'Loading service details...',
          );
        }

        if (state.hasError.value) {
          return ServiceDetailError(
            message: state.errorMessage.value,
            onRetry: _loadServiceDetail,
          );
        }

        return _buildPageContent();
      }),
    );
  }

  Widget _buildPageContent() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          _buildSliverAppBar(),
          _buildSliverTabBar(),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildDetailsTab(),
          _buildReviewsTab(),
          _buildPersonalizedTab(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeroSection(),
      ),
      actions: _buildAppBarActions(),
    );
  }

  Widget _buildSliverTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Details'),
            Tab(text: 'Reviews'),
            Tab(text: 'For You'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    final service = state.service.value;
    if (service == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 服务图片
          if (service.images.isNotEmpty)
            PageView.builder(
              itemCount: service.images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  service.images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                );
              },
            ),
          
          // 服务信息
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title['en'] ?? 'Service Title',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      ServiceDetailFormatters.formatRating(service.averageRating),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${service.reviewCount} reviews)',
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      Obx(() => IconButton(
        icon: Icon(
          state.isFavorite.value ? Icons.favorite : Icons.favorite_border,
          color: state.isFavorite.value ? Colors.red : null,
        ),
        onPressed: () => _toggleFavorite(),
      )),
      IconButton(
        icon: const Icon(Icons.share),
        onPressed: () => _shareService(),
      ),
    ];
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildBasicInfoSection(),
          const SizedBox(height: ServiceDetailConstants.sectionSpacing),
          _buildActionsSection(),
          const SizedBox(height: ServiceDetailConstants.sectionSpacing),
          _buildMapSection(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    final service = state.service.value;
    if (service == null) return const SizedBox.shrink();

    return ServiceDetailTitleCard(
      title: 'Service Information',
      leading: const Icon(Icons.info_outline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Category', _getCategoryName(service.categoryLevel1Id)),
          _buildInfoRow('Status', service.status ?? 'N/A'),
          if (service.description != null)
            _buildInfoRow('Description', service.description!),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return ServiceDetailTitleCard(
      title: 'Service Actions',
      leading: const Icon(Icons.work),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _requestQuote(),
                  icon: const Icon(Icons.request_quote),
                  label: const Text('Get Quote'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _bookService(),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Book Now'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _contactProvider('chat'),
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _contactProvider('call'),
                  icon: const Icon(Icons.phone),
                  label: const Text('Call'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return ServiceDetailTitleCard(
      title: 'Location & Route',
      leading: const Icon(Icons.location_on),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('Map will be implemented here'),
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return const Center(
      child: Text('Details tab content'),
    );
  }

  Widget _buildReviewsTab() {
    return const Center(
      child: Text('Reviews tab content'),
    );
  }

  Widget _buildPersonalizedTab() {
    return const Center(
      child: Text('Personalized tab content'),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
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

  String _getCategoryName(String categoryId) {
    // TODO: 实现分类名称获取逻辑
    return 'Service Category';
  }

  void _toggleFavorite() {
    state.isFavorite.value = !state.isFavorite.value;
    // TODO: 调用API更新收藏状态
  }

  void _shareService() {
    // TODO: 实现分享功能
  }

  void _requestQuote() {
    // TODO: 实现报价请求
  }

  void _bookService() {
    // TODO: 实现服务预订
  }

  void _contactProvider(String type) {
    // TODO: 实现联系提供商
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
