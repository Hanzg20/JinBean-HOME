import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/income/income_controller.dart';

class IncomePage extends GetView<IncomeController> {
  const IncomePage({Key? key}) : super(key: key);

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
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () => _showAddPaymentMethodDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Period Selector
          _buildPeriodSelector(),
          
          // Income Statistics
          _buildIncomeStatistics(),
          
          // Income Records
          Expanded(
            child: _buildIncomeRecords(),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
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
          // Period Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.periodOptions.map((period) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Obx(() => FilterChip(
                    label: Text(controller.getPeriodDisplayText(period)),
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
          
          // Year and Month Selector (for monthly view)
          if (controller.selectedPeriod.value == 'month') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: controller.selectedYear.value,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: List.generate(5, (index) {
                      final year = DateTime.now().year - 2 + index;
                      return DropdownMenuItem(
                        value: year.toString(),
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        controller.changeYear(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: controller.selectedMonth.value,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: List.generate(12, (index) {
                      final month = index + 1;
                      return DropdownMenuItem(
                        value: month.toString(),
                        child: Text(_getMonthName(month)),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        controller.changeMonth(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIncomeStatistics() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() => Column(
        children: [
          // Main Statistics
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Income', controller.formatPrice(controller.totalIncome.value), Colors.green),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('Settled', controller.formatPrice(controller.totalSettled.value), Colors.blue),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('Pending', controller.formatPrice(controller.totalPending.value), Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Orders', controller.totalOrders.value.toString(), Colors.purple),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('Settlements', controller.settlements.length.toString(), Colors.teal),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('Avg/Order', controller.totalOrders.value > 0 
                    ? controller.formatPrice(controller.totalIncome.value / controller.totalOrders.value)
                    : '\$0.00', Colors.indigo),
              ),
            ],
          ),
        ],
      )),
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
              fontSize: 18,
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
                'Income will appear here when orders are completed',
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
                  child: Text(
                    controller.getCustomerName(record),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
            
            // Income Details
            Row(
              children: [
                Expanded(
                  child: _buildIncomeDetail('Amount', controller.formatPrice(record['amount'])),
                ),
                Expanded(
                  child: _buildIncomeDetail('Order Amount', controller.getOrderAmount(record)),
                ),
                Expanded(
                  child: _buildIncomeDetail('Date', controller.formatDateTime(record['income_date'])),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Action Buttons
            if (status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showSettlementDialog(record),
                      icon: const Icon(Icons.payment, size: 16),
                      label: const Text('Request Settlement'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showSettlementDialog(Map<String, dynamic> record) {
    final amountController = TextEditingController(text: record['amount']?.toString() ?? '');
    String selectedPaymentMethod = '';
    
    Get.dialog(
      AlertDialog(
        title: const Text('Request Settlement'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: controller.getPaymentMethods(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    
                    final paymentMethods = snapshot.data ?? [];
                    
                    if (paymentMethods.isEmpty) {
                      return const Text('No payment methods found. Please add a payment method first.');
                    }
                    
                    return DropdownButtonFormField<String>(
                      value: selectedPaymentMethod.isEmpty && paymentMethods.isNotEmpty 
                          ? paymentMethods.first['id'] 
                          : selectedPaymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                      ),
                      items: paymentMethods.map((method) => DropdownMenuItem(
                        value: method['id'],
                        child: Text('${method['method_type']} - ${method['account_name']}'),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value!;
                        });
                      },
                    );
                  },
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
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0 && selectedPaymentMethod.isNotEmpty) {
                controller.requestSettlement(amount, selectedPaymentMethod);
                Get.back();
              }
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentMethodDialog() {
    final accountNameController = TextEditingController();
    final accountInfoController = TextEditingController();
    String selectedMethodType = 'bank_transfer';
    
    Get.dialog(
      AlertDialog(
        title: const Text('Add Payment Method'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedMethodType,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method Type',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                    DropdownMenuItem(value: 'paypal', child: Text('PayPal')),
                    DropdownMenuItem(value: 'stripe', child: Text('Stripe')),
                    DropdownMenuItem(value: 'wechat_pay', child: Text('WeChat Pay')),
                    DropdownMenuItem(value: 'alipay', child: Text('Alipay')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedMethodType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: accountNameController,
                  decoration: const InputDecoration(
                    labelText: 'Account Name',
                    hintText: 'Enter account holder name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: accountInfoController,
                  decoration: const InputDecoration(
                    labelText: 'Account Information',
                    hintText: 'Enter account number or email',
                  ),
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
              if (accountNameController.text.isNotEmpty && accountInfoController.text.isNotEmpty) {
                controller.addPaymentMethod(
                  selectedMethodType,
                  accountInfoController.text,
                  accountNameController.text,
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

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
} 