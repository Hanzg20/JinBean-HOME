import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/clients/presentation/client_controller.dart';

class ClientPage extends GetView<ClientController> {
  const ClientPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
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
            onChanged: (value) => controller.searchClients(value),
                decoration: InputDecoration(
              hintText: 'Search clients by name or email...',
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
        future: controller.getClientStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final stats = snapshot.data ?? {};
          
          return Row(
                children: [
                  Expanded(
                child: _buildStatCard('Total', stats['total']?.toString() ?? '0', Colors.blue),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('Served', stats['served']?.toString() ?? '0', Colors.green),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('In Negotiation', stats['in_negotiation']?.toString() ?? '0', Colors.orange),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('Potential', stats['potential']?.toString() ?? '0', Colors.purple),
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
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No clients found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first client to get started',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddClientDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Client'),
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
                          color: Colors.grey[600],
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
                  child: _buildClientStat('Orders', controller.getTotalOrders(client).toString()),
                    ),
                Expanded(
                  child: _buildClientStat('Total', controller.formatPrice(controller.getTotalAmount(client))),
                ),
                Expanded(
                  child: _buildClientStat('Last Contact', controller.formatDateTime(client['last_contact_date'])),
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
                    label: const Text('View'),
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
                    label: const Text('Message'),
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
                    label: const Text('Edit'),
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
            color: Colors.grey[600],
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
        title: const Text('Add New Client'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: clientIdController,
                  decoration: const InputDecoration(
                    labelText: 'Client ID',
                    hintText: 'Enter client user ID',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Relationship Type',
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
                    labelText: 'Notes',
                    hintText: 'Add any notes about this client',
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
            child: const Text('Cancel'),
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
            child: const Text('Add'),
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
        title: Text('Edit ${controller.getClientName(client)}'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Relationship Type',
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
                    labelText: 'Notes',
                    hintText: 'Add any notes about this client',
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
            child: const Text('Cancel'),
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
            child: const Text('Update'),
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
        title: Text('Add Communication - ${controller.getClientName(client)}'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Communication Type',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'message', child: Text('Message')),
                    DropdownMenuItem(value: 'call', child: Text('Phone Call')),
                    DropdownMenuItem(value: 'email', child: Text('Email')),
                    DropdownMenuItem(value: 'meeting', child: Text('Meeting')),
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
                    labelText: 'Content',
                    hintText: 'Enter communication details',
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
            child: const Text('Cancel'),
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
            child: const Text('Add'),
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
              _buildDetailRow('Email', controller.getClientEmail(client)),
              _buildDetailRow('Phone', controller.getClientPhone(client)),
              _buildDetailRow('Relationship', controller.getCategoryDisplayText(client['relationship_type'])),
              _buildDetailRow('Total Orders', controller.getTotalOrders(client).toString()),
              _buildDetailRow('Total Amount', controller.formatPrice(controller.getTotalAmount(client))),
              _buildDetailRow('Last Contact', controller.formatDateTime(client['last_contact_date'])),
              if (client['notes'] != null && client['notes'].isNotEmpty)
                _buildDetailRow('Notes', client['notes']),
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
              _showCommunicationDialog(client);
            },
            child: const Text('Add Communication'),
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