import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/ui/design_system/colors.dart';
import 'package:jinbeanpod_83904710/features/provider/clients/presentation/client_controller.dart';

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
    return Scaffold(
      backgroundColor: JinBeanColors.background,
      appBar: AppBar(
        title: const Text(
          '客户管理',
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
            onPressed: () => controller.refreshClients(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddClientDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchAndFilterSection(),
          
          // Statistics Section
          _buildStatisticsSection(),
          
          // Clients List
          Expanded(
            child: _buildClientsList(),
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
            onChanged: (value) => controller.searchClients(value),
            decoration: InputDecoration(
              hintText: '搜索客户姓名或邮箱...',
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

          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Obx(() => FilterChip(
                    label: Text(controller.getCategoryDisplayText(category)),
                    selected: controller.selectedCategory.value == category,
                    onSelected: (selected) {
                      if (selected) {
                        controller.filterByCategory(category);
                      }
                    },
                    backgroundColor: JinBeanColors.surface,
                    selectedColor: JinBeanColors.primaryLight,
                    checkmarkColor: JinBeanColors.primary,
                  )),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<Map<String, dynamic>>(
        future: controller.getClientStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final stats = snapshot.data ?? {};
          
          return Row(
                children: [
                  Expanded(
                child: _buildStatCard('总客户', stats['total']?.toString() ?? '0', JinBeanColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('已服务', stats['served']?.toString() ?? '0', JinBeanColors.success),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('谈判中', stats['in_negotiation']?.toString() ?? '0', JinBeanColors.warning),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('潜在客户', stats['potential']?.toString() ?? '0', JinBeanColors.info),
              ),
            ],
          );
        },
      ),
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

  Widget _buildClientsList() {
    return Obx(() {
      if (controller.isLoading.value && controller.clients.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.clients.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people,
                size: 64,
                color: JinBeanColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                '暂无客户',
                style: TextStyle(
                  fontSize: 18,
                  color: JinBeanColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '添加您的第一个客户以开始',
                style: TextStyle(
                  fontSize: 14,
                  color: JinBeanColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddClientDialog(),
                icon: const Icon(Icons.add),
                label: const Text('添加客户'),
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
        onRefresh: () => controller.refreshClients(),
        child: ListView.builder(
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
            return _buildClientCard(client);
          },
        ),
      );
    });
  }

  Widget _buildClientCard(Map<String, dynamic> client) {
    final relationshipType = client['relationship_type'] as String;
    final categoryColor = Color(controller.getCategoryColor(relationshipType));
    
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
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: categoryColor.withOpacity(0.1),
                  child: Text(
                    controller.getClientName(client)[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                    ),
                    ),
                  ),
                const SizedBox(width: 12),
                
                // Client Info
                  Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.getClientName(client),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.getClientEmail(client),
                        style: TextStyle(
                          fontSize: 14,
                          color: JinBeanColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

                // Category Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: categoryColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    controller.getCategoryDisplayText(relationshipType),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: categoryColor,
                    ),
            ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Stats Row
            Row(
                  children: [
                Expanded(
                  child: _buildClientStat('订单数', controller.getTotalOrders(client).toString()),
                    ),
                Expanded(
                  child: _buildClientStat('总金额', controller.formatPrice(controller.getTotalAmount(client))),
                ),
                Expanded(
                  child: _buildClientStat('最后联系', controller.formatDateTime(client['last_contact_date'])),
              ),
              ],
            ),

            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
                  children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showClientDetails(client),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('查看'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCommunicationDialog(client),
                    icon: const Icon(Icons.message, size: 16),
                    label: const Text('消息'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditClientDialog(client),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('编辑'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: JinBeanColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showAddClientDialog() {
    final clientIdController = TextEditingController();
    final notesController = TextEditingController();
    String selectedCategory = 'potential';
    
    Get.dialog(
      AlertDialog(
        title: const Text('添加新客户'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: clientIdController,
                  decoration: const InputDecoration(
                    labelText: '客户ID',
                    hintText: '请输入客户用户ID',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
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
                  decoration: const InputDecoration(
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
            child: const Text('取消'),
          ),
          ElevatedButton(
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
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showEditClientDialog(Map<String, dynamic> client) {
    final notesController = TextEditingController(text: client['notes'] ?? '');
    String selectedCategory = client['relationship_type'] as String;
    
    Get.dialog(
      AlertDialog(
        title: Text('编辑 ${controller.getClientName(client)}'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
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
                  decoration: const InputDecoration(
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
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateClient(
                client['id'],
                selectedCategory,
                notesController.text,
              );
              Get.back();
            },
            child: const Text('更新'),
          ),
        ],
      ),
    );
  }

  void _showCommunicationDialog(Map<String, dynamic> client) {
    final contentController = TextEditingController();
    String selectedType = 'message';
    
    Get.dialog(
      AlertDialog(
        title: Text('添加沟通 - ${controller.getClientName(client)}'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: '沟通类型',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'message', child: Text('消息')),
                    DropdownMenuItem(value: 'call', child: Text('电话')),
                    DropdownMenuItem(value: 'email', child: Text('邮件')),
                    DropdownMenuItem(value: 'meeting', child: Text('会议')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: '内容',
                    hintText: '请输入沟通详情',
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
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (contentController.text.isNotEmpty) {
                controller.addCommunication(
                  client['client_id'],
                  selectedType,
                  contentController.text,
                );
                Get.back();
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showClientDetails(Map<String, dynamic> client) {
    Get.dialog(
      AlertDialog(
        title: Text(controller.getClientName(client)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
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
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showCommunicationDialog(client);
            },
            child: const Text('添加沟通'),
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
            width: 100,
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
} 