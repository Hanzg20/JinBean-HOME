import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/services/service_management_controller.dart';
import 'package:jinbeanpod_83904710/features/provider/services/service_management_service.dart';
import 'package:jinbeanpod_83904710/core/ui/components/provider_theme_components.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/provider_theme_utils.dart';

class ServiceManagementPage extends GetView<ServiceManagementController> {
  const ServiceManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '服务管理',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: colorScheme.onSurface),
            onPressed: () => _showAddServiceDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 统计区域
          _buildStatisticsSection(context),
          
          // 服务列表
          Expanded(
            child: _buildServicesList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ProviderStatCard(
                  title: '总服务数',
                  value: controller.services.length.toString(),
                  icon: Icons.work,
                  iconColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProviderStatCard(
                  title: '活跃服务',
                  value: controller.services.where((s) => s.status == ServiceStatus.active).length.toString(),
                  icon: Icons.check_circle,
                  iconColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ProviderStatCard(
                  title: '暂停服务',
                  value: controller.services.where((s) => s.status == ServiceStatus.inactive).length.toString(),
                  icon: Icons.pause_circle,
                  iconColor: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProviderStatCard(
                  title: '总收入',
                  value: '¥${controller.services.fold(0.0, (sum, service) => sum + service.price).toStringAsFixed(2)}',
                  icon: Icons.attach_money,
                  iconColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }

  Widget _buildServicesList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const ProviderLoadingState(message: '加载服务数据...');
      }
      
      if (controller.services.isEmpty) {
        return const ProviderEmptyState(
          icon: Icons.work,
          title: '暂无服务',
          subtitle: '添加您的第一个服务以开始',
          actionText: '添加服务',
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.services.length,
        itemBuilder: (context, index) {
          final service = controller.services[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ProviderCard(
              onTap: () => _showServiceDetail(context, service),
              child: Row(
                children: [
                  // 服务图标
                  ProviderIconContainer(
                    icon: _getServiceIcon(service.categoryLevel1Id),
                    size: 48,
                    iconColor: _getServiceColor(context, service.status),
                  ),
                  const SizedBox(width: 12),
                  // 服务信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '¥${service.price.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${service.reviewCount}评价',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 状态和操作
                  Column(
                    children: [
                      ProviderBadge(
                        text: controller.getStatusDisplayText(service.status),
                        type: _getStatusBadgeType(service.status),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              size: 18,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () => _showEditServiceDialog(context, service),
                          ),
                          IconButton(
                            icon: Icon(
                              service.status == ServiceStatus.active ? Icons.pause : Icons.play_arrow,
                              size: 18,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () => _toggleServiceStatus(service),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showAddServiceDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    String selectedCategory = 'cleaning';
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.surface,
        title: Row(
          children: [
            ProviderIconContainer(
              icon: Icons.add_business,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              '添加服务',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: ProviderThemeUtils.getInputDecoration(
                      context,
                      labelText: '服务名称',
                      hintText: '请输入服务名称',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: ProviderThemeUtils.getInputDecoration(
                      context,
                      labelText: '服务描述',
                      hintText: '请输入服务描述',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: ProviderThemeUtils.getInputDecoration(
                      context,
                      labelText: '价格',
                      hintText: '0.00',
                    ).copyWith(
                      prefixText: '¥',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: ProviderThemeUtils.getInputDecoration(
                      context,
                      labelText: '服务类别',
                    ),
                    items: [
                      DropdownMenuItem(value: 'cleaning', child: Text('清洁服务')),
                      DropdownMenuItem(value: 'maintenance', child: Text('维护服务')),
                      DropdownMenuItem(value: 'repair', child: Text('维修服务')),
                      DropdownMenuItem(value: 'other', child: Text('其他服务')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              '取消',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          ProviderButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && priceController.text.isNotEmpty) {
                final service = Service(
                  id: '',
                  providerId: '',
                  title: titleController.text,
                  description: descriptionController.text,
                  categoryLevel1Id: selectedCategory,
                  categoryLevel2Id: selectedCategory,
                  status: ServiceStatus.active,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                controller.createService(service);
                Get.back();
              }
            },
            text: '添加',
            type: ProviderButtonType.primary,
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(BuildContext context, Service service) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final titleController = TextEditingController(text: service.title);
    final descriptionController = TextEditingController(text: service.description);
    final priceController = TextEditingController(text: service.price.toString());
    String selectedCategory = service.categoryLevel1Id;
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.surface,
        title: Row(
          children: [
            ProviderIconContainer(
              icon: Icons.edit,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              '编辑服务',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: ProviderThemeUtils.getInputDecoration(
                      context,
                      labelText: '服务名称',
                      hintText: '请输入服务名称',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: ProviderThemeUtils.getInputDecoration(
                      context,
                      labelText: '服务描述',
                      hintText: '请输入服务描述',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: ProviderThemeUtils.getInputDecoration(
                      context,
                      labelText: '价格',
                      hintText: '0.00',
                    ).copyWith(
                      prefixText: '¥',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: ProviderThemeUtils.getInputDecoration(
                      context,
                      labelText: '服务类别',
                    ),
                    items: [
                      DropdownMenuItem(value: 'cleaning', child: Text('清洁服务')),
                      DropdownMenuItem(value: 'maintenance', child: Text('维护服务')),
                      DropdownMenuItem(value: 'repair', child: Text('维修服务')),
                      DropdownMenuItem(value: 'other', child: Text('其他服务')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              '取消',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          ProviderButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && priceController.text.isNotEmpty) {
                final updatedService = Service(
                  id: service.id,
                  providerId: service.providerId,
                  title: titleController.text,
                  description: descriptionController.text,
                  categoryLevel1Id: selectedCategory,
                  categoryLevel2Id: selectedCategory,
                  status: service.status,
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
            text: '更新',
            type: ProviderButtonType.primary,
          ),
        ],
      ),
    );
  }

  void _showServiceDetail(BuildContext context, Service service) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.surface,
        title: Text(
          '服务详情',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(context, '名称', service.title),
            _buildDetailRow(context, '描述', service.description),
            _buildDetailRow(context, '价格', '¥${service.price.toStringAsFixed(2)}'),
            _buildDetailRow(context, '评分', '${service.averageRating.toStringAsFixed(1)}★'),
            _buildDetailRow(context, '评价数', '${service.reviewCount}'),
            _buildDetailRow(context, '类别', _getCategoryText(service.categoryLevel1Id)),
            _buildDetailRow(context, '状态', controller.getStatusDisplayText(service.status)),
            _buildDetailRow(context, '创建时间', service.createdAt.toString().substring(0, 19)),
          ],
        ),
        actions: [
          ProviderButton(
            onPressed: () => Get.back(),
            text: '关闭',
            type: ProviderButtonType.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleServiceStatus(Service service) {
    final newStatus = service.status == ServiceStatus.active ? ServiceStatus.inactive : ServiceStatus.active;
    controller.updateServiceStatus(service.id, newStatus);
  }

  IconData _getServiceIcon(String? category) {
    switch (category) {
      case 'cleaning':
        return Icons.cleaning_services;
      case 'maintenance':
        return Icons.build;
      case 'repair':
        return Icons.handyman;
      default:
        return Icons.work;
    }
  }

  Color _getServiceColor(BuildContext context, ServiceStatus status) {
    return controller.getStatusColor(status);
  }

  ProviderBadgeType _getStatusBadgeType(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.active:
        return ProviderBadgeType.primary;
      case ServiceStatus.inactive:
        return ProviderBadgeType.warning;
      case ServiceStatus.draft:
        return ProviderBadgeType.secondary;
      case ServiceStatus.archived:
        return ProviderBadgeType.error;
    }
  }

  String _getCategoryText(String? category) {
    switch (category) {
      case 'cleaning':
        return '清洁服务';
      case 'maintenance':
        return '维护服务';
      case 'repair':
        return '维修服务';
      case 'other':
        return '其他服务';
      default:
        return '未知类别';
    }
  }
} 