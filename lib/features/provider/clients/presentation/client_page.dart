import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/ui/design_system/colors.dart';
import 'package:jinbeanpod_83904710/features/provider/clients/presentation/client_controller.dart';
import 'package:jinbeanpod_83904710/core/ui/components/provider_theme_components.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/provider_theme_utils.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  late ClientController controller;

  @override
  void initState() {
    super.initState();
    // 确保Controller被注册
    if (!Get.isRegistered<ClientController>()) {
      Get.put(ClientController());
    }
    controller = Get.find<ClientController>();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'Client Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Client Page',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withOpacity(0.1), width: 1),
        ),
      ),
      child: Column(
        children: [
          // 搜索栏
          TextField(
            onChanged: (value) => controller.searchClients(value),
            decoration: ProviderThemeUtils.getInputDecoration(
              context,
              hintText: '搜索客户姓名或邮箱...',
              prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 12),
          // 筛选器
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('全部', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('活跃', 'active'),
                const SizedBox(width: 8),
                _buildFilterChip('新客户', 'new'),
                const SizedBox(width: 8),
                _buildFilterChip('VIP', 'vip'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Obx(() => FilterChip(
      label: Text(label),
      selected: controller.selectedCategory.value == value,
      onSelected: (selected) {
        if (selected) {
          controller.selectedCategory.value = value;
          controller.loadClients(refresh: true);
        }
      },
      backgroundColor: colorScheme.surfaceVariant,
      selectedColor: colorScheme.primary.withOpacity(0.1),
      checkmarkColor: colorScheme.primary,
      labelStyle: TextStyle(
        color: controller.selectedCategory.value == value
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant,
      ),
    ));
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ProviderStatCard(
                  title: '总客户数',
                  value: controller.clients.length.toString(),
                  icon: Icons.people,
                  iconColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProviderStatCard(
                  title: '已服务',
                  value: controller.clients.where((c) => c['relationship_type'] == 'served').length.toString(),
                  icon: Icons.person_add,
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
                  title: '谈判中',
                  value: controller.clients.where((c) => c['relationship_type'] == 'in_negotiation').length.toString(),
                  icon: Icons.person_add_alt,
                  iconColor: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProviderStatCard(
                  title: '潜在客户',
                  value: controller.clients.where((c) => c['relationship_type'] == 'potential').length.toString(),
                  icon: Icons.star,
                  iconColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }

  Widget _buildClientsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const ProviderLoadingState(message: '加载客户数据...');
      }
      
      if (controller.clients.isEmpty) {
        return const ProviderEmptyState(
          icon: Icons.people,
          title: '暂无客户数据',
          subtitle: '完成订单后将自动添加客户',
          actionText: '添加客户',
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.clients.length + (controller.hasMoreData.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == controller.clients.length) {
            // Load more indicator
            if (controller.hasMoreData.value) {
              controller.loadClients();
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return const SizedBox.shrink();
          }
          
          final client = controller.clients[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ProviderCard(
              onTap: () => _showClientDetail(client),
              child: Row(
                children: [
                  // 客户头像
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      controller.getClientName(client)[0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 客户信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.getClientName(client),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.getClientEmail(client),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '订单: ${controller.getTotalOrders(client)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '消费: ${controller.formatPrice(controller.getTotalAmount(client))}',
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
                  // 状态徽章
                  Column(
                    children: [
                      ProviderBadge(
                        text: controller.getCategoryDisplayText(client['relationship_type']),
                        type: _getClientBadgeType(client),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 14,
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

  void _showAddClientDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final clientIdController = TextEditingController();
    final notesController = TextEditingController();
    String selectedCategory = 'potential';
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.surface,
        title: Row(
          children: [
            ProviderIconContainer(
              icon: Icons.person_add,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              '添加客户',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: clientIdController,
                  decoration: ProviderThemeUtils.getInputDecoration(
                    context,
                    labelText: '客户ID',
                    hintText: '请输入客户用户ID',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: ProviderThemeUtils.getInputDecoration(
                    context,
                    labelText: '关系类型',
                  ),
                  items: controller.categories
                      .where((cat) => cat != 'all')
                      .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(controller.getCategoryDisplayText(category)),
                      ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: ProviderThemeUtils.getInputDecoration(
                    context,
                    labelText: '备注',
                    hintText: '添加关于此客户的任何备注',
                  ),
                  maxLines: 3,
                ),
              ],
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
              if (clientIdController.text.isNotEmpty) {
                controller.addClient(
                  clientIdController.text,
                  selectedCategory,
                  notesController.text,
                );
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

  void _showClientDetail(Map<String, dynamic> client) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.surface,
        title: Text(
          '客户详情',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('姓名', controller.getClientName(client)),
            _buildDetailRow('邮箱', controller.getClientEmail(client)),
            _buildDetailRow('电话', controller.getClientPhone(client)),
            _buildDetailRow('关系', controller.getCategoryDisplayText(client['relationship_type'])),
            _buildDetailRow('总订单', controller.getTotalOrders(client).toString()),
            _buildDetailRow('总金额', controller.formatPrice(controller.getTotalAmount(client))),
            _buildDetailRow('最后联系', controller.formatDateTime(client['last_contact_date'])),
            if (client['notes'] != null && client['notes'].isNotEmpty)
              _buildDetailRow('备注', client['notes']),
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

  Widget _buildDetailRow(String label, String value) {
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

  String _getClientStatus(Map<String, dynamic> client) {
    final orderCount = client['order_count'] ?? 0;
    final totalSpent = client['total_spent'] ?? 0;
    
    if (totalSpent > 1000) return 'VIP';
    if (orderCount > 5) return '活跃';
    if (orderCount > 0) return '普通';
    return '新客户';
  }

  ProviderBadgeType _getClientBadgeType(Map<String, dynamic> client) {
    final status = _getClientStatus(client);
    switch (status) {
      case 'VIP':
        return ProviderBadgeType.error;
      case '活跃':
        return ProviderBadgeType.primary;
      case '普通':
        return ProviderBadgeType.secondary;
      case '新客户':
        return ProviderBadgeType.warning;
      default:
        return ProviderBadgeType.secondary;
    }
  }
} 