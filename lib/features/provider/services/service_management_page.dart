import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/ui/design_system/colors.dart';
import 'package:jinbeanpod_83904710/features/provider/services/service_management_controller.dart';
import 'package:jinbeanpod_83904710/features/provider/services/service_management_service.dart';

class ServiceManagementPage extends GetView<ServiceManagementController> {
  const ServiceManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JinBeanColors.background,
      appBar: AppBar(
        title: const Text(
          '服务管理',
          style: TextStyle(
            color: JinBeanColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: JinBeanColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: JinBeanColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshData(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddServiceDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchAndFilterSection(),
          
          // Statistics Section
          _buildStatisticsSection(),
          
          // Services List
          Expanded(
            child: _buildServicesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: JinBeanColors.surface,
        border: Border(
          bottom: BorderSide(color: JinBeanColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) => controller.searchServices(value),
            decoration: InputDecoration(
              hintText: '搜索服务名称或描述...',
              prefixIcon: const Icon(Icons.search, color: JinBeanColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: JinBeanColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: JinBeanColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: JinBeanColors.primary, width: 2),
              ),
              filled: true,
              fillColor: JinBeanColors.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          
          // Status Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // All services option
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Obx(() => FilterChip(
                    label: const Text('全部'),
                    selected: controller.selectedStatus.value == null,
                    onSelected: (selected) {
                      if (selected) {
                        controller.filterByStatus(null);
                      }
                    },
                    backgroundColor: JinBeanColors.surface,
                    selectedColor: JinBeanColors.primaryLight,
                    checkmarkColor: JinBeanColors.primary,
                  )),
                ),
                // Status options
                ...controller.statusOptions.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Obx(() => FilterChip(
                      label: Text(controller.getStatusDisplayText(status)),
                      selected: controller.selectedStatus.value == status,
                      onSelected: (selected) {
                        if (selected) {
                          controller.filterByStatus(status);
                        }
                      },
                      backgroundColor: JinBeanColors.surface,
                      selectedColor: JinBeanColors.primaryLight,
                      checkmarkColor: JinBeanColors.primary,
                    )),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final stats = controller.serviceStats;
        
        return Row(
          children: [
            Expanded(
              child: _buildStatCard('总服务', stats['total_services']?.toString() ?? '0', JinBeanColors.primary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard('活跃服务', stats['active_services']?.toString() ?? '0', JinBeanColors.success),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard('热门服务', '${(stats['top_services'] as List?)?.length ?? 0}', JinBeanColors.warning),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: JinBeanColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList() {
    return Obx(() {
      if (controller.isLoading.value && controller.services.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.services.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business,
                size: 64,
                color: JinBeanColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                '暂无服务',
                style: TextStyle(
                  fontSize: 18,
                  color: JinBeanColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '创建您的第一个服务以开始',
                style: TextStyle(
                  fontSize: 14,
                  color: JinBeanColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddServiceDialog(),
                icon: const Icon(Icons.add),
                label: const Text('添加服务'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: JinBeanColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }
      
      return RefreshIndicator(
        onRefresh: () => controller.refreshData(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.services.length,
          itemBuilder: (context, index) {
            final service = controller.services[index];
            return _buildServiceCard(service);
          },
        ),
      );
    });
  }

  Widget _buildServiceCard(Service service) {
    final statusColor = controller.getStatusColor(service.status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    service.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    controller.getStatusDisplayText(service.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Description
            if (service.description.isNotEmpty) ...[
              Text(
                service.description,
                style: TextStyle(
                  fontSize: 14,
                  color: JinBeanColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],
            
            // Price and Stats
            Row(
              children: [
                Text(
                  '\$${service.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                if (service.reviewCount > 0) ...[
                  Icon(Icons.shopping_cart, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${service.reviewCount}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (service.averageRating > 0) ...[
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${service.averageRating.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showServiceDetails(service),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('查看详情'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showEditServiceDialog(service),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('编辑'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showDeleteServiceDialog(service),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('删除'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddServiceDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    ServiceStatus selectedStatus = ServiceStatus.active;
    
    Get.dialog(
      AlertDialog(
        title: const Text('添加新服务'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '服务名称',
                    hintText: '请输入服务名称',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '服务描述',
                    hintText: '请输入服务描述',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: '价格',
                    hintText: '请输入服务价格',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ServiceStatus>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: '状态',
                  ),
                  items: ServiceStatus.values.map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(controller.getStatusDisplayText(status)),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                final newService = Service(
                  id: '', // Will be generated by database
                  providerId: '', // Will be set by service
                  title: nameController.text,
                  description: descriptionController.text,
                  categoryLevel1Id: '1010000', // Default category
                  categoryLevel2Id: '1010100', // Default subcategory
                  status: selectedStatus,
                  averageRating: 0.0,
                  reviewCount: 0,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  location: null,
                  imagesUrl: [],
                  extraData: null,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                controller.createService(newService);
                Get.back();
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(Service service) {
    final nameController = TextEditingController(text: service.title);
    final descriptionController = TextEditingController(text: service.description);
    final priceController = TextEditingController(text: service.price.toString());
    ServiceStatus selectedStatus = service.status;
    
    Get.dialog(
      AlertDialog(
        title: const Text('编辑服务'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '服务名称',
                    hintText: '请输入服务名称',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '服务描述',
                    hintText: '请输入服务描述',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: '价格',
                    hintText: '请输入服务价格',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ServiceStatus>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: '状态',
                  ),
                  items: ServiceStatus.values.map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(controller.getStatusDisplayText(status)),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                final updatedService = Service(
                  id: service.id,
                  providerId: service.providerId,
                  title: nameController.text,
                  description: descriptionController.text,
                  categoryLevel1Id: service.categoryLevel1Id,
                  categoryLevel2Id: service.categoryLevel2Id,
                  status: selectedStatus,
                  averageRating: service.averageRating,
                  reviewCount: service.reviewCount,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  location: service.location,
                  imagesUrl: service.imagesUrl,
                  extraData: service.extraData,
                  createdAt: service.createdAt,
                  updatedAt: DateTime.now(),
                );
                controller.updateService(updatedService);
                Get.back();
              }
            },
            child: const Text('更新'),
          ),
        ],
      ),
    );
  }

  void _showDeleteServiceDialog(Service service) {
    Get.dialog(
      AlertDialog(
        title: const Text('删除服务'),
        content: Text('确定要删除服务"${service.title}"吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteService(service.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showServiceDetails(Service service) {
    Get.dialog(
      AlertDialog(
        title: Text(service.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('描述', service.description),
              _buildDetailRow('价格', '\$${service.price.toStringAsFixed(2)}'),
              _buildDetailRow('状态', controller.getStatusDisplayText(service.status)),
              _buildDetailRow('评论数', '${service.reviewCount}'),
              _buildDetailRow('平均评分', '${service.averageRating.toStringAsFixed(1)}'),
              _buildDetailRow('创建时间', _formatDateTime(service.createdAt.toIso8601String())),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showEditServiceDialog(service);
            },
            child: const Text('编辑'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }
} 