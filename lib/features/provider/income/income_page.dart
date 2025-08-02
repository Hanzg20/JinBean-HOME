import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/income/income_controller.dart';

class IncomePage extends GetView<IncomeController> {
  const IncomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshIncomeData(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Period Filter
          _buildPeriodFilter(),
          
          // Statistics Cards
          _buildStatisticsSection(),
          
          // Income Records
          Expanded(
            child: _buildIncomeRecords(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSettlementDialog(),
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
        label: const Text('Request Settlement', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildPeriodFilter() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Income Period',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.periodOptions.map((period) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Obx(() => FilterChip(
                    label: Text(_getPeriodDisplayName(period)),
                    selected: controller.selectedPeriod.value == period,
                    onSelected: (selected) {
                      if (selected) {
                        controller.changePeriod(period);
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
      child: Obx(() {
        return Column(
          children: [
            // Main Statistics Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Income',
                    controller.formatCurrency(controller.totalIncome),
                    Colors.green,
                    Icons.attach_money,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Pending',
                    controller.formatCurrency(controller.pendingAmount),
                    Colors.orange,
                    Icons.pending,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Settled',
                    controller.formatCurrency(controller.settledAmount),
                    Colors.blue,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Total Orders',
                    controller.totalOrders.toString(),
                    Colors.purple,
                    Icons.receipt,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
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

  Widget _buildIncomeRecords() {
    return Obx(() {
      if (controller.isLoading.value && controller.incomeRecords.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.incomeRecords.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No income records found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Income records will appear here when you complete orders',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }
      
      return RefreshIndicator(
        onRefresh: () => controller.refreshIncomeData(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.incomeRecords.length,
          itemBuilder: (context, index) {
            final record = controller.incomeRecords[index];
            return _buildIncomeRecordCard(record);
          },
        ),
      );
    });
  }

  Widget _buildIncomeRecordCard(Map<String, dynamic> record) {
    final status = record['status'] as String;
    final statusColor = Color(controller.getStatusColor(status));
    final amount = record['amount'] as num? ?? 0;
    final incomeType = record['income_type'] as String? ?? 'unknown';
    
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.getIncomeTypeDisplayName(incomeType),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.formatDate(record['created_at']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      controller.formatCurrency(amount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        controller.getStatusDisplayName(status),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Notes
            if (record['notes'] != null && record['notes'].isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  record['notes'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSettlementDialog() {
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Request Settlement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => Text(
              'Available for settlement: ${controller.formatCurrency(controller.pendingAmount)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Get.back();
                controller.requestSettlement(amount, notesController.text);
              } else {
                Get.snackbar(
                  'Error',
                  'Please enter a valid amount',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  String _getPeriodDisplayName(String period) {
    switch (period) {
      case 'today':
        return 'Today';
      case 'week':
        return 'This Week';
      case 'month':
        return 'This Month';
      case 'year':
        return 'This Year';
      default:
        return period;
    }
  }
} 