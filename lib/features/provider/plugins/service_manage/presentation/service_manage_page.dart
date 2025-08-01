import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/service_manage/service_manage_controller.dart';

class ServiceManagePage extends StatefulWidget {
  const ServiceManagePage({super.key});

  @override
  State<ServiceManagePage> createState() => _ServiceManagePageState();
}

class _ServiceManagePageState extends State<ServiceManagePage> {
  late final ServiceManageController controller;
  final RxString selectedView = 'grid'.obs;
  final RxBool showFavorites = false.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ServiceManageController());
    // Ensure services are loaded when page is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadServices(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Icon(Icons.build, color: theme.colorScheme.onPrimary, size: 24),
            const SizedBox(width: 8),
            Text(
              '服务管理',
              style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.view_list, color: theme.colorScheme.onPrimary),
            onPressed: () => selectedView.value = selectedView.value == 'grid' ? 'list' : 'grid',
          ),
          IconButton(
            icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
            onPressed: () => _showAddServiceDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshServices(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 服务概览统计
              _buildServiceOverview(),
              
              // 搜索和筛选
              _buildSearchAndFilter(),
              
              // 服务列表
              _buildServicesContent(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceOverview() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '服务概览',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh, size: 18),
                    onPressed: () => controller.refreshServices(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<Map<String, dynamic>>(
                future: controller.getServiceStatistics(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final stats = snapshot.data ?? {};
                  
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildOverviewCard(
                              '总服务',
                              stats['total']?.toString() ?? '0',
                              Colors.blue,
                              Icons.work,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildOverviewCard(
                              '活跃',
                              stats['active']?.toString() ?? '0',
                              Colors.green,
                              Icons.check_circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildOverviewCard(
                              '草稿',
                              stats['draft']?.toString() ?? '0',
                              Colors.orange,
                              Icons.edit,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildOverviewCard(
                              '可预约',
                              stats['active']?.toString() ?? '0',
                              Colors.green,
                              Icons.schedule,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildOverviewCard(
                              '暂停',
                              stats['paused']?.toString() ?? '0',
                              Colors.red,
                              Icons.pause,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildOverviewCard(
                              '收入',
                              '\$${stats['total_revenue']?.toString() ?? '0'}',
                              Colors.purple,
                              Icons.attach_money,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 搜索栏
              TextField(
                onChanged: (value) => controller.searchServices(value),
                decoration: InputDecoration(
                  hintText: '搜索服务名称或描述...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => controller.searchServices(''),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              
              // 筛选器
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...controller.categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Obx(() => FilterChip(
                          label: Text(_getCategoryDisplayText(category)),
                          selected: controller.selectedCategory.value == category,
                          onSelected: (selected) {
                            if (selected) {
                              controller.filterByCategory(category);
                            }
                          },
                          backgroundColor: Colors.grey[100],
                          selectedColor: Colors.blue[100],
                          checkmarkColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: controller.selectedCategory.value == category 
                                ? Colors.blue[700] 
                                : Colors.grey[700],
                          ),
                        )),
                      );
                    }),
                    
                    // 视图切换
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Obx(() => FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              selectedView.value == 'grid' ? Icons.grid_view : Icons.view_list,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(selectedView.value == 'grid' ? '网格' : '列表'),
                          ],
                        ),
                        selected: true,
                        onSelected: (_) {
                          selectedView.value = selectedView.value == 'grid' ? 'list' : 'grid';
                        },
                        backgroundColor: Colors.blue[100],
                        selectedColor: Colors.blue[100],
                        checkmarkColor: Colors.blue,
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesContent() {
    return Obx(() {
      if (controller.isLoading.value && controller.services.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        );
      }
      
      if (controller.services.isEmpty) {
        return _buildEmptyState();
      }
      
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: selectedView.value == 'grid' 
            ? _buildGridView() 
            : _buildListView(),
      );
    });
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.work_outline,
              size: 64,
              color: Colors.blue[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '还没有服务',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '创建您的第一个服务开始接单',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddServiceDialog(),
            icon: const Icon(Icons.add),
            label: const Text('创建服务'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: controller.services.length + (controller.hasMoreData.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == controller.services.length) {
          if (controller.hasMoreData.value) {
            controller.loadServices();
            return const Center(child: CircularProgressIndicator());
          }
          return const SizedBox.shrink();
        }
        
        final service = controller.services[index];
        return _buildServiceGridCard(service);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.services.length + (controller.hasMoreData.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == controller.services.length) {
          if (controller.hasMoreData.value) {
            controller.loadServices();
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return const SizedBox.shrink();
        }
        
        final service = controller.services[index];
        return _buildServiceListCard(service);
      },
    );
  }

  Widget _buildServiceGridCard(Map<String, dynamic> service) {
    final status = service['status'] as String;
    final statusColor = controller.getStatusColor(status);
    final isAvailable = controller.isServiceAvailable(service);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showServiceDetails(service),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 服务图标和状态
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.work,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusDisplayText(status),
                      style: TextStyle(
                        fontSize: 10,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 服务名称
              Text(
                controller.getServiceName(service),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // 分类
              Text(
                controller.getServiceCategory(service),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // 价格
              Text(
                controller.getServicePrice(service),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[600],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 可用性开关
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isAvailable ? '可预约' : '暂停',
                      style: TextStyle(
                        fontSize: 10,
                        color: isAvailable ? Colors.green[600] : Colors.red[600],
                      ),
                    ),
                  ),
                  Switch(
                    value: isAvailable,
                    onChanged: (value) => controller.toggleServiceAvailability(service['id'], value),
                    activeColor: Colors.green,
                  ),
                ],
              ),
              
              const Spacer(),
              
              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: IconButton(
                      onPressed: () => _showEditServiceDialog(service),
                      icon: Icon(Icons.edit, size: 16, color: Colors.blue[600]),
                      tooltip: '编辑',
                    ),
                  ),
                  if (controller.canDeleteService(service))
                    Expanded(
                      child: IconButton(
                        onPressed: () => _showDeleteServiceDialog(service),
                        icon: Icon(Icons.delete, size: 16, color: Colors.red[600]),
                        tooltip: '删除',
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceListCard(Map<String, dynamic> service) {
    final status = service['status'] as String;
    final statusColor = controller.getStatusColor(status);
    final isAvailable = controller.isServiceAvailable(service);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showServiceDetails(service),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 服务图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.work,
                  color: statusColor,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // 服务信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.getServiceName(service),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.getServiceCategory(service),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          controller.getServicePrice(service),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          controller.getServiceDuration(service),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusDisplayText(status),
                      style: TextStyle(
                        fontSize: 10,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Switch(
                    value: isAvailable,
                    onChanged: (value) => controller.toggleServiceAvailability(service['id'], value),
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusDisplayText(String status) {
    switch (status) {
      case 'active':
        return '活跃';
      case 'draft':
        return '草稿';
      case 'inactive':
        return '暂停';
      case 'paused':
        return '暂停';
      case 'archived':
        return '已归档';
      default:
        return status;
    }
  }

  String _getCategoryDisplayText(String category) {
    switch (category) {
      case 'all':
        return '全部';
      case 'active':
        return '活跃';
      case 'inactive':
        return '暂停';
      case 'draft':
        return '草稿';
      case 'paused':
        return '暂停';
      case 'archived':
        return '已归档';
      default:
        return category;
    }
  }

  void _showAddServiceDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();
    String selectedCategory = '';
    String selectedStatus = 'draft';
    String selectedDeliveryMethod = 'on_site';
    String selectedPricingType = 'fixed_price';
    String selectedDurationType = 'hours';
    
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_circle, color: Colors.blue[600]),
            const SizedBox(width: 8),
            const Text('创建新服务'),
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
                    decoration: const InputDecoration(
                      labelText: '服务名称',
                      hintText: '输入服务名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: '服务描述',
                      hintText: '详细描述您的服务',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: controller.getServiceCategories(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      
                      final categories = snapshot.data ?? [];
                      
                      return DropdownButtonFormField<String>(
                        value: selectedCategory.isEmpty && categories.isNotEmpty ? categories.first['code_value'].toString() : selectedCategory,
                        decoration: const InputDecoration(
                          labelText: '服务分类',
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) => DropdownMenuItem<String>(
                          value: category['code_value'].toString(),
                          child: Text(category['code_description'].toString()),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          decoration: const InputDecoration(
                            labelText: '基础价格',
                            hintText: '50.00',
                            prefixText: '\$',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: durationController,
                          decoration: const InputDecoration(
                            labelText: '服务时长',
                            hintText: '2',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedPricingType,
                          decoration: const InputDecoration(
                            labelText: '定价类型',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'fixed_price', child: Text('固定价格')),
                            DropdownMenuItem(value: 'hourly', child: Text('按小时')),
                            DropdownMenuItem(value: 'by_project', child: Text('按项目')),
                            DropdownMenuItem(value: 'negotiable', child: Text('可协商')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedPricingType = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedDurationType,
                          decoration: const InputDecoration(
                            labelText: '时长单位',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'hours', child: Text('小时')),
                            DropdownMenuItem(value: 'minutes', child: Text('分钟')),
                            DropdownMenuItem(value: 'days', child: Text('天')),
                            DropdownMenuItem(value: 'visits', child: Text('次')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedDurationType = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedDeliveryMethod,
                    decoration: const InputDecoration(
                      labelText: '服务交付方式',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'on_site', child: Text('上门服务')),
                      DropdownMenuItem(value: 'remote', child: Text('远程服务')),
                      DropdownMenuItem(value: 'online', child: Text('在线服务')),
                      DropdownMenuItem(value: 'pickup', child: Text('自取服务')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedDeliveryMethod = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: '服务状态',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'draft', child: Text('草稿')),
                      DropdownMenuItem(value: 'active', child: Text('活跃')),
                      DropdownMenuItem(value: 'paused', child: Text('暂停')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
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
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && 
                  descriptionController.text.isNotEmpty && 
                  priceController.text.isNotEmpty &&
                  durationController.text.isNotEmpty &&
                  selectedCategory.isNotEmpty) {
                controller.createService({
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'category_id': selectedCategory,
                  'category_level2_id': selectedCategory, // Using same as level1 for now
                  'status': selectedStatus,
                  'service_delivery_method': selectedDeliveryMethod,
                  'details': {
                    'pricing_type': selectedPricingType,
                    'price': double.tryParse(priceController.text) ?? 0.0,
                    'currency': 'USD',
                    'duration_type': selectedDurationType,
                    'duration': '${durationController.text} $selectedDurationType',
                  },
                });
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(Map<String, dynamic> service) {
    final nameController = TextEditingController(text: controller.getServiceName(service));
    final descriptionController = TextEditingController(text: controller.getServiceDescription(service));
    final priceController = TextEditingController();
    final durationController = TextEditingController();
    String selectedCategory = service['category_level1_id']?.toString() ?? '';
    String selectedStatus = service['status'] ?? 'draft';
    String selectedDeliveryMethod = service['service_delivery_method'] ?? 'on_site';
    String selectedPricingType = 'fixed_price';
    String selectedDurationType = 'hours';
    
    // Extract price and duration from service_details
    final serviceDetails = service['service_details'] as List<dynamic>?;
    if (serviceDetails != null && serviceDetails.isNotEmpty) {
      final details = serviceDetails.first as Map<String, dynamic>;
      priceController.text = details['price']?.toString() ?? '';
      selectedPricingType = details['pricing_type'] ?? 'fixed_price';
      selectedDurationType = details['duration_type'] ?? 'hours';
      final duration = details['duration']?.toString() ?? '';
      if (duration.isNotEmpty) {
        final parts = duration.split(' ');
        if (parts.length >= 2) {
          durationController.text = parts[0];
        }
      }
    }
    
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.blue[600]),
            const SizedBox(width: 8),
            Text('编辑服务'),
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
                    decoration: const InputDecoration(
                      labelText: '服务名称',
                      hintText: '输入服务名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: '服务描述',
                      hintText: '详细描述您的服务',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: controller.getServiceCategories(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      
                      final categories = snapshot.data ?? [];
                      
                      return DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: '服务分类',
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) => DropdownMenuItem<String>(
                          value: category['code_value'].toString(),
                          child: Text(category['code_description'].toString()),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          decoration: const InputDecoration(
                            labelText: '基础价格',
                            hintText: '50.00',
                            prefixText: '\$',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: durationController,
                          decoration: const InputDecoration(
                            labelText: '服务时长',
                            hintText: '2',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedPricingType,
                          decoration: const InputDecoration(
                            labelText: '定价类型',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'fixed_price', child: Text('固定价格')),
                            DropdownMenuItem(value: 'hourly', child: Text('按小时')),
                            DropdownMenuItem(value: 'by_project', child: Text('按项目')),
                            DropdownMenuItem(value: 'negotiable', child: Text('可协商')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedPricingType = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedDurationType,
                          decoration: const InputDecoration(
                            labelText: '时长单位',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'hours', child: Text('小时')),
                            DropdownMenuItem(value: 'minutes', child: Text('分钟')),
                            DropdownMenuItem(value: 'days', child: Text('天')),
                            DropdownMenuItem(value: 'visits', child: Text('次')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedDurationType = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedDeliveryMethod,
                    decoration: const InputDecoration(
                      labelText: '服务交付方式',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'on_site', child: Text('上门服务')),
                      DropdownMenuItem(value: 'remote', child: Text('远程服务')),
                      DropdownMenuItem(value: 'online', child: Text('在线服务')),
                      DropdownMenuItem(value: 'pickup', child: Text('自取服务')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedDeliveryMethod = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: '服务状态',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'draft', child: Text('草稿')),
                      DropdownMenuItem(value: 'active', child: Text('活跃')),
                      DropdownMenuItem(value: 'paused', child: Text('暂停')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
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
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && 
                  descriptionController.text.isNotEmpty && 
                  priceController.text.isNotEmpty &&
                  durationController.text.isNotEmpty &&
                  selectedCategory.isNotEmpty) {
                controller.updateService(service['id'], {
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'category_id': selectedCategory,
                  'category_level2_id': selectedCategory, // Using same as level1 for now
                  'status': selectedStatus,
                  'service_delivery_method': selectedDeliveryMethod,
                  'details': {
                    'pricing_type': selectedPricingType,
                    'price': double.tryParse(priceController.text) ?? 0.0,
                    'currency': 'USD',
                    'duration_type': selectedDurationType,
                    'duration': '${durationController.text} $selectedDurationType',
                  },
                });
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('更新'),
          ),
        ],
      ),
    );
  }

  void _showDeleteServiceDialog(Map<String, dynamic> service) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text('删除服务'),
          ],
        ),
        content: Text('确定要删除"${controller.getServiceName(service)}"吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteService(service['id']);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showServiceDetails(Map<String, dynamic> service) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Colors.blue[600]),
            const SizedBox(width: 8),
            Text(controller.getServiceName(service)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('分类', controller.getServiceCategory(service)),
              _buildDetailRow('描述', controller.getServiceDescription(service)),
              _buildDetailRow('价格', controller.getServicePrice(service)),
              _buildDetailRow('时长', controller.getServiceDuration(service)),
              _buildDetailRow('状态', _getStatusDisplayText(service['status'])),
              _buildDetailRow('交付方式', _getDeliveryMethodText(service['service_delivery_method'])),
              _buildDetailRow('创建时间', controller.formatDateTime(service['created_at'])),
              _buildDetailRow('更新时间', controller.formatDateTime(service['updated_at'])),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('编辑'),
          ),
        ],
      ),
    );
  }
  
  String _getDeliveryMethodText(String? deliveryMethod) {
    switch (deliveryMethod) {
      case 'on_site':
        return '上门服务';
      case 'remote':
        return '远程服务';
      case 'online':
        return '在线服务';
      case 'pickup':
        return '自取服务';
      default:
        return '未知';
    }
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
} 