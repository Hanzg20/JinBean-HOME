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
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '客户管理',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onSurface),
            onPressed: () => controller.refreshClients(),
          ),
          IconButton(
            icon: Icon(Icons.add, color: colorScheme.onSurface),
            onPressed: () => _showAddClientDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索和筛选区域
          _buildSearchAndFilterSection(),
          
          // 统计区域
          _buildStatisticsSection(),
          
          // 客户列表
          Expanded(
            child: _buildClientsList(),
          ),
        ],
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
      selected: controller.selectedFilter.value == value,
      onSelected: (selected) {
        if (selected) {
          controller.filterClients(value);
        }
      },
      backgroundColor: colorScheme.surfaceVariant,
      selectedColor: colorScheme.primary.withOpacity(0.1),
      checkmarkColor: colorScheme.primary,
      labelStyle: TextStyle(
        color: controller.selectedFilter.value == value
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
                  value: controller.totalClients.toString(),
                  icon: Icons.people,
                  iconColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProviderStatCard(
                  title: '活跃客户',
                  value: controller.activeClients.toString(),
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
                  title: '新客户',
                  value: controller.newClients.toString(),
                  icon: Icons.person_add_alt,
                  iconColor: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProviderStatCard(
                  title: 'VIP客户',
                  value: controller.vipClients.toString(),
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
      
      if (controller.filteredClients.isEmpty) {
        return const ProviderEmptyState(
          icon: Icons.people,
          title: '暂无客户数据',
          subtitle: '完成订单后将自动添加客户',
          actionText: '添加客户',
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredClients.length,
        itemBuilder: (context, index) {
          final client = controller.filteredClients[index];
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
                      (client['name'] ?? 'C')[0].toUpperCase(),
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
                          client['name'] ?? '未知客户',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          client['email'] ?? '无邮箱',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '订单: ${client['order_count'] ?? 0}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '消费: ¥${(client['total_spent'] ?? 0).toStringAsFixed(2)}',
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
                        text: _getClientStatus(client),
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
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: ProviderThemeUtils.getInputDecoration(
                context,
                labelText: '客户姓名',
                hintText: '请输入客户姓名',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: ProviderThemeUtils.getInputDecoration(
                context,
                labelText: '邮箱地址',
                hintText: '请输入邮箱地址',
              ),
            ),
          ],
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
              if (nameController.text.isNotEmpty) {
                controller.addClient(nameController.text, emailController.text);
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
            _buildDetailRow('姓名', client['name'] ?? '未知'),
            _buildDetailRow('邮箱', client['email'] ?? '无邮箱'),
            _buildDetailRow('订单数', '${client['order_count'] ?? 0}'),
            _buildDetailRow('总消费', '¥${(client['total_spent'] ?? 0).toStringAsFixed(2)}'),
            _buildDetailRow('状态', _getClientStatus(client)),
            _buildDetailRow('创建时间', client['created_at'] ?? '未知'),
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