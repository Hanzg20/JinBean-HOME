import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/ui/design_system/colors.dart';
import 'package:jinbeanpod_83904710/features/provider/clients/presentation/client_controller.dart';
import 'package:jinbeanpod_83904710/core/ui/components/provider_theme_components.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/provider_theme_utils.dart';
// Import platform components
import 'package:jinbeanpod_83904710/core/components/platform_core.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
// Import loading components
import 'package:jinbeanpod_83904710/features/customer/services/presentation/widgets/service_detail_loading.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  late ClientController controller;
  
  // 平台组件状态管理
  final LoadingStateManager _loadingManager = LoadingStateManager();

  @override
  void initState() {
    super.initState();
    AppLogger.debug('[ClientPage] initState called', tag: 'ClientPage');
    
    // 初始化网络状态为在线
    _loadingManager.setOnline();
    
    // 确保Controller被注册
    if (!Get.isRegistered<ClientController>()) {
      Get.put(ClientController());
    }
    controller = Get.find<ClientController>();
    
    // 数据已经在controller中加载完成，直接设置为成功状态
    _loadingManager.setSuccess();
  }

  @override
  void dispose() {
    _loadingManager.dispose();
    super.dispose();
  }

  /// 加载客户数据
  Future<void> _loadClientsData() async {
    try {
      _loadingManager.setLoading();
      
      // 加载客户数据
      await controller.loadClients();
      
      _loadingManager.setSuccess();
      AppLogger.info('Clients data loaded successfully', tag: 'ClientPage');
    } catch (e) {
      AppLogger.error('Error loading clients data: $e', tag: 'ClientPage');
      _loadingManager.setError('Failed to load clients data: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '客户管理',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddClientDialog(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _loadingManager,
        builder: (context, child) {
          return ServiceDetailLoading(
            state: _loadingManager.state,
            loadingMessage: '加载客户数据...',
            errorMessage: _loadingManager.errorMessage,
            onRetry: () => _loadClientsData(),
            onBack: () => Get.back(),
            showSkeleton: true,
            child: Column(
              children: [
                // 搜索筛选区域
                _buildSearchAndFilterSection(),
                
                const SizedBox(height: 16),
                
                // 统计概览区域
                _buildStatisticsSection(),
                
                const SizedBox(height: 16),
                
                // 客户列表区域
                Expanded(
                  child: _buildClientsList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        children: [
          // 搜索栏
          TextField(
            onChanged: (value) => controller.searchClients(value),
            decoration: InputDecoration(
              hintText: '搜索客户姓名或邮箱...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          // 筛选器
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
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: Colors.blue.shade100,
                    labelStyle: TextStyle(
                      color: controller.selectedCategory.value == category 
                          ? Colors.blue 
                          : Colors.grey.shade700,
                    ),
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
      child: Obx(() => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '总客户数',
                  controller.clients.length.toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '已服务',
                  controller.clients.where((c) => c['relationship_type'] == 'served').length.toString(),
                  Icons.person_add,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '谈判中',
                  controller.clients.where((c) => c['relationship_type'] == 'in_negotiation').length.toString(),
                  Icons.person_add_alt,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '潜在客户',
                  controller.clients.where((c) => c['relationship_type'] == 'potential').length.toString(),
                  Icons.star,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientsList() {
    return Obx(() {
      if (controller.isLoading.value) {
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
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                '暂无客户数据',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '完成订单后将自动添加客户',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      }
      
      return RefreshIndicator(
        onRefresh: () => controller.loadClients(refresh: true),
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
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                    child: Text(
                      controller.getClientName(client)[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                title: Text(
                  controller.getClientName(client),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(controller.getClientEmail(client)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(client['relationship_type']),
                        borderRadius: BorderRadius.circular(12),
                        ),
                      child: Text(
                        controller.getCategoryDisplayText(client['relationship_type']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                          ),
                        ),
                        const SizedBox(height: 4),
                            Text(
                      '${controller.getTotalOrders(client)} 订单',
                      style: TextStyle(
                                fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      ),
                    ],
                  ),
                onTap: () => _showClientDetail(client),
            ),
          );
        },
        ),
      );
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'served':
        return Colors.green;
      case 'in_negotiation':
        return Colors.orange;
      case 'potential':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showAddClientDialog() {
    final clientIdController = TextEditingController();
    final notesController = TextEditingController();
    String selectedCategory = 'potential';
    
    Get.dialog(
      AlertDialog(
        title: const Text('添加客户'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: clientIdController,
              decoration: const InputDecoration(
                    labelText: '客户ID',
                hintText: '输入客户用户ID',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
              decoration: const InputDecoration(
                    labelText: '关系类型',
                  ),
                  items: controller.categories
                  .where((c) => c != 'all')
                      .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(controller.getCategoryDisplayText(category)),
                      ))
                      .toList(),
                  onChanged: (value) {
                if (value != null) {
                  selectedCategory = value;
                }
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

  void _showClientDetail(Map<String, dynamic> client) {
    Get.dialog(
      AlertDialog(
        title: const Text('客户详情'),
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
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
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
              style: const TextStyle(fontWeight: FontWeight.w600),
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