import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/service_manage/service_manage_controller.dart';

class ServiceManagePage extends GetView<ServiceManageController> {
  const ServiceManagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshServices(),
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) => controller.searchServices(value),
            decoration: InputDecoration(
              hintText: 'Search services by name or description...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          
          // Status Filter
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
                    backgroundColor: Colors.grey[100],
                    selectedColor: Colors.blue[100],
                    checkmarkColor: Colors.blue,
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
        future: controller.getServiceStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final stats = snapshot.data ?? {};
          
          return Column(
            children: [
              // First row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Total', stats['total']?.toString() ?? '0', Colors.blue),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard('Active', stats['active']?.toString() ?? '0', Colors.green),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard('Draft', stats['draft']?.toString() ?? '0', Colors.orange),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Second row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Available', stats['available']?.toString() ?? '0', Colors.green),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard('Unavailable', stats['unavailable']?.toString() ?? '0', Colors.red),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard('Inactive', stats['inactive']?.toString() ?? '0', Colors.grey),
                  ),
                ],
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
              color: Colors.grey[600],
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
                Icons.work,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No services found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first service to get started',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddServiceDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Create Service'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }
      
      return RefreshIndicator(
        onRefresh: () => controller.refreshServices(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.services.length + (controller.hasMoreData.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.services.length) {
              // Load more indicator
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
            return _buildServiceCard(service);
          },
      ),
      );
    });
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final status = service['status'] as String;
    final statusColor = Color(controller.getStatusColor(status));
    final isAvailable = service['is_available'] as bool;
    
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
                // Service Icon
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
                
                // Service Info
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
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    controller.getStatusDisplayText(status),
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
            Text(
              controller.getServiceDescription(service),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 12),
            
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildServiceStat('Price', controller.getServicePrice(service)),
                ),
                Expanded(
                  child: _buildServiceStat('Duration', controller.getServiceDuration(service)),
            ),
                Expanded(
                  child: _buildServiceStat('Status', isAvailable ? 'Available' : 'Unavailable'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showServiceDetails(service),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.canEditService(service) 
                        ? () => _showEditServiceDialog(service)
                        : null,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Switch(
                    value: isAvailable,
                    onChanged: (value) => controller.toggleServiceAvailability(service['id'], value),
                    activeColor: Colors.green,
                  ),
                ),
                if (controller.canDeleteService(service)) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeleteServiceDialog(service),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceStat(String label, String value) {
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
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showAddServiceDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();
    String selectedCategory = '';
    String selectedStatus = 'draft';
    bool isAvailable = true;
    
    Get.dialog(
      AlertDialog(
        title: const Text('Create New Service'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Service Name',
                      hintText: 'Enter service name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter service description',
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
                        value: selectedCategory.isEmpty && categories.isNotEmpty ? categories.first['code_value'] : selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: categories.map((category) => DropdownMenuItem(
                          value: category['code_value'],
                          child: Text(category['code_description']),
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
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Base Price',
                      hintText: 'Enter price (e.g., 50.00)',
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                      hintText: 'Enter duration in minutes',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'draft', child: Text('Draft')),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: isAvailable,
                        onChanged: (value) {
                          setState(() {
                            isAvailable = value!;
                          });
                        },
                      ),
                      const Text('Available for booking'),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
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
                  'base_price': double.tryParse(priceController.text) ?? 0.0,
                  'duration_minutes': int.tryParse(durationController.text) ?? 60,
                  'status': selectedStatus,
                  'is_available': isAvailable,
                });
                Get.back();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(Map<String, dynamic> service) {
    final nameController = TextEditingController(text: service['name']);
    final descriptionController = TextEditingController(text: service['description']);
    final priceController = TextEditingController(text: service['base_price']?.toString() ?? '');
    final durationController = TextEditingController(text: service['duration_minutes']?.toString() ?? '');
    String selectedCategory = service['category_id'] ?? '';
    String selectedStatus = service['status'] ?? 'draft';
    bool isAvailable = service['is_available'] ?? true;
    
    Get.dialog(
      AlertDialog(
        title: Text('Edit ${service['name']}'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Service Name',
                      hintText: 'Enter service name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter service description',
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
                          labelText: 'Category',
                        ),
                        items: categories.map((category) => DropdownMenuItem(
                          value: category['code_value'],
                          child: Text(category['code_description']),
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
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Base Price',
                      hintText: 'Enter price (e.g., 50.00)',
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                      hintText: 'Enter duration in minutes',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'draft', child: Text('Draft')),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: isAvailable,
                        onChanged: (value) {
                          setState(() {
                            isAvailable = value!;
                          });
                        },
                      ),
                      const Text('Available for booking'),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
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
                  'base_price': double.tryParse(priceController.text) ?? 0.0,
                  'duration_minutes': int.tryParse(durationController.text) ?? 60,
                  'status': selectedStatus,
                  'is_available': isAvailable,
                });
                Get.back();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteServiceDialog(Map<String, dynamic> service) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service['name']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteService(service['id']);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showServiceDetails(Map<String, dynamic> service) {
    Get.dialog(
      AlertDialog(
        title: Text(controller.getServiceName(service)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Category', controller.getServiceCategory(service)),
              _buildDetailRow('Description', controller.getServiceDescription(service)),
              _buildDetailRow('Price', controller.getServicePrice(service)),
              _buildDetailRow('Duration', controller.getServiceDuration(service)),
              _buildDetailRow('Status', controller.getStatusDisplayText(service['status'])),
              _buildDetailRow('Available', service['is_available'] ? 'Yes' : 'No'),
              _buildDetailRow('Created', controller.formatDateTime(service['created_at'])),
              _buildDetailRow('Updated', controller.formatDateTime(service['updated_at'])),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showEditServiceDialog(service);
            },
            child: const Text('Edit'),
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
} 