import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/services/service_management_controller.dart';
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
                  value: controller.services.where((s) => s['status'] == 'active').length.toString(),
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
                  value: controller.services.where((s) => s['status'] == 'paused').length.toString(),
                  icon: Icons.pause_circle,
                  iconColor: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProviderStatCard(
                  title: '总收入',
                  value: controller.formatCurrency(controller.totalRevenue),
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
                    icon: _getServiceIcon(service['category']),
                    size: 48,
                    iconColor: _getServiceColor(context, service['status']),
                  ),
                  const SizedBox(width: 12),
                  // 服务信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['name'] ?? '未知服务',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service['description'] ?? '无描述',
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
                              controller.formatCurrency(service['price'] ?? 0),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${service['duration'] ?? 0}分钟',
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
                        text: _getStatusText(service['status']),
                        type: _getStatusBadgeType(service['status']),
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
                              service['status'] == 'active' ? Icons.pause : Icons.play_arrow,
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
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();
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
                    controller: nameController,
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
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
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
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          decoration: ProviderThemeUtils.getInputDecoration(
                            context,
                            labelText: '时长(分钟)',
                            hintText: '60',
                          ),
                        ),
                      ),
                    ],
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
              if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                controller.addService({
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'duration': int.tryParse(durationController.text) ?? 60,
                  'category': selectedCategory,
                  'status': 'active',
                });
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

  void _showEditServiceDialog(BuildContext context, Map<String, dynamic> service) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final nameController = TextEditingController(text: service['name']);
    final descriptionController = TextEditingController(text: service['description']);
    final priceController = TextEditingController(text: service['price'].toString());
    final durationController = TextEditingController(text: service['duration'].toString());
    String selectedCategory = service['category'] ?? 'cleaning';
    
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
                    controller: nameController,
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
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
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
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          decoration: ProviderThemeUtils.getInputDecoration(
                            context,
                            labelText: '时长(分钟)',
                            hintText: '60',
                          ),
                        ),
                      ),
                    ],
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
              if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                controller.updateService(service['id'], {
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'duration': int.tryParse(durationController.text) ?? 60,
                  'category': selectedCategory,
                });
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

  void _showServiceDetail(BuildContext context, Map<String, dynamic> service) {
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
            _buildDetailRow(context, '名称', service['name'] ?? '未知'),
            _buildDetailRow(context, '描述', service['description'] ?? '无描述'),
            _buildDetailRow(context, '价格', controller.formatCurrency(service['price'] ?? 0)),
            _buildDetailRow(context, '时长', '${service['duration'] ?? 0}分钟'),
            _buildDetailRow(context, '类别', _getCategoryText(service['category'])),
            _buildDetailRow(context, '状态', _getStatusText(service['status'])),
            _buildDetailRow(context, '创建时间', service['created_at'] ?? '未知'),
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

  void _toggleServiceStatus(Map<String, dynamic> service) {
    final newStatus = service['status'] == 'active' ? 'paused' : 'active';
    controller.updateService(service['id'], {'status': newStatus});
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

  Color _getServiceColor(BuildContext context, String? status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'active':
        return colorScheme.primary;
      case 'paused':
        return colorScheme.tertiary;
      case 'inactive':
        return colorScheme.error;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'active':
        return '活跃';
      case 'paused':
        return '暂停';
      case 'inactive':
        return '停用';
      default:
        return '未知';
    }
  }

  ProviderBadgeType _getStatusBadgeType(String? status) {
    switch (status) {
      case 'active':
        return ProviderBadgeType.primary;
      case 'paused':
        return ProviderBadgeType.warning;
      case 'inactive':
        return ProviderBadgeType.error;
      default:
        return ProviderBadgeType.secondary;
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