import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/services/presentation/service_detail_controller.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';

class ServiceDetailPage extends GetView<ServiceDetailController> {
  const ServiceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (controller.service.value == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Service Detail')),
            body: const Center(
              child: Text('Service not found'),
            ),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // 优化的SliverAppBar
              _buildSliverAppBar(context),
              
              // 内容区域 - 卡片化布局
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 服务标题和评分卡片
                      _buildServiceHeaderCard(),
                      const SizedBox(height: 16),
                      
                      // 服务提供商信息卡片
                      _buildProviderInfoCard(),
                      const SizedBox(height: 16),
                      
                      // 价格和规格选择卡片
                      _buildPricingCard(),
                      const SizedBox(height: 16),
                      
                      // 服务详情卡片
                      _buildServiceDetailsCard(),
                      const SizedBox(height: 16),
                      
                      // 服务图片卡片
                      _buildServiceImagesCard(),
                      const SizedBox(height: 16),
                      
                      // 服务区域卡片
                      _buildServiceAreaCard(),
                      const SizedBox(height: 16),
                      
                      // 用户留言区域卡片
                      _buildMessageCard(),
                      const SizedBox(height: 80), // 为底部操作栏留空间
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(),
        );
      }),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 服务图片
            Obx(() => controller.serviceDetail.value?.images.isNotEmpty == true
                ? Image.network(
                    controller.serviceDetail.value!.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 80, color: Colors.grey),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 80, color: Colors.grey),
                  )),
            // 渐变遮罩
            Container(
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
            ),
            // 操作按钮
            Positioned(
              top: 50,
              right: 16,
              child: Row(
                children: [
                  _buildActionButton(
                    icon: Icons.share,
                    onTap: controller.shareService,
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.favorite_border,
                    onTap: controller.addToFavorites,
                  ),
                ],
              ),
            ),
          ],
        ),
        title: Obx(() => Text(
          controller.service.value?.title ?? 'Service',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        )),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildServiceHeaderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Obx(() => Text(
                    controller.service.value?.title ?? 'Service Name',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Obx(() => Text(
                      '${controller.service.value?.averageRating ?? 0.0}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    )),
                    Obx(() => Text(
                      ' (${controller.service.value?.reviewCount ?? 0})',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    )),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
              controller.service.value?.description ?? 'Service description',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Service Provider',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() => Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, size: 30, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.provider.value?.companyName ?? 'Provider Name',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${controller.provider.value?.ratingsAvg ?? 0.0}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            ' • ${controller.provider.value?.reviewCount ?? 0} reviews',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildContactButton(),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.phone, size: 16),
      label: const Text('Contact'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: controller.contactProvider,
    );
  }

  Widget _buildPricingCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Pricing',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              final serviceDetail = controller.serviceDetail.value;
              if (serviceDetail?.pricingType == 'negotiable') {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Price is negotiable. Contact provider for quote.',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Row(
                  children: [
                    Text(
                      '\$',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    Text(
                      '${serviceDetail?.price?.toStringAsFixed(2) ?? '75'}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    Text(
                      '/hour',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Text(
                        'Best Value',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                );
              }
            }),
            const SizedBox(height: 8),
            Text(
              'Free consultation • No hidden fees • Satisfaction guaranteed',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Service Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              final serviceDetail = controller.serviceDetail.value;
              return Column(
                children: [
                  _buildDetailRow('Duration', serviceDetail?.duration?.toString() ?? '2-3 hours'),
                  _buildDetailRow('Service Type', serviceDetail?.durationType ?? 'On-site'),
                  _buildDetailRow('Availability', 'Mon-Sun, 8AM-8PM'),
                  _buildDetailRow('Response Time', 'Within 2 hours'),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceImagesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.photo_library, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Service Photos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              final images = controller.serviceDetail.value?.images ?? [];
              if (images.isEmpty) {
                return Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: const Center(
                    child: Icon(Icons.image, size: 40, color: Colors.grey),
                  ),
                );
              }
              return SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[300],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image, size: 40, color: Colors.grey);
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceAreaCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Service Area',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: const Center(
                child: Icon(Icons.map, size: 40, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final areas = controller.serviceDetail.value?.serviceAreaCodes ?? [];
              if (areas.isEmpty) {
                return Text(
                  'Serving Toronto, Mississauga, Brampton, and surrounding areas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                );
              }
              return Wrap(
                spacing: 8,
                runSpacing: 4,
                children: areas.map((area) => Chip(
                  label: Text(area),
                  backgroundColor: Colors.blue[50],
                  side: BorderSide(color: Colors.blue[200]!),
                )).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.message, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Send Message',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ask about availability, pricing, or special requirements...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.chat, size: 16),
                    label: const Text('Start Chat'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: controller.startChat,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('Send'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: controller.sendMessage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.favorite_border),
                label: const Text('Save'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: controller.addToFavorites,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: const Text('Book Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // TODO: Navigate to booking page
                  Get.snackbar(
                    'Booking',
                    'Redirecting to booking page...',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 