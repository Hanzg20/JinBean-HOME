import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/income/income_controller.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  late IncomeController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<IncomeController>()) {
      Get.put(IncomeController());
    }
    controller = Get.find<IncomeController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('收入与财务管理'),
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
      body: RefreshIndicator(
        onRefresh: () => controller.refreshIncomeData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 收入统计卡片
              _buildIncomeStatistics(),
              
              // 时间段选择器
              _buildPeriodSelector(),
              
              // 收入记录列表
              _buildIncomeRecords(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeStatistics() {
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
              const Text(
                '收入统计',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '总收入',
                      '\$${controller.totalIncome.value.toStringAsFixed(2)}',
                      Colors.green,
                      Icons.attach_money,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '已结算',
                      '\$${controller.totalSettled.value.toStringAsFixed(2)}',
                      Colors.blue,
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '待结算',
                      '\$${controller.totalPending.value.toStringAsFixed(2)}',
                      Colors.orange,
                      Icons.pending,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '订单数',
                      '${controller.totalOrders.value}',
                      Colors.purple,
                      Icons.shopping_cart,
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

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
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
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '时间段选择',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => Row(
                children: controller.periodOptions.map((period) {
                  final isSelected = controller.selectedPeriod.value == period;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.selectedPeriod.value = period,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getPeriodDisplayText(period),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
            ],
          ),
        ),
      ),
    );
  }

  String _getPeriodDisplayText(String period) {
    switch (period) {
      case 'week':
        return '本周';
      case 'month':
        return '本月';
      case 'quarter':
        return '本季度';
      case 'year':
        return '本年';
      default:
        return period;
    }
  }

  Widget _buildIncomeRecords() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '收入记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.isLoading.value && controller.incomeRecords.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (controller.incomeRecords.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '暂无收入记录',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '完成订单后将显示收入记录',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.incomeRecords.length,
              itemBuilder: (context, index) {
                final record = controller.incomeRecords[index];
                return _buildIncomeRecordCard(record);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildIncomeRecordCard(Map<String, dynamic> record) {
    final amount = record['amount'] ?? 0.0;
    final status = record['status'] ?? 'pending';
    final incomeType = record['income_type'] ?? 'service_fee';
    final createdAt = record['created_at'];
    
    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'settled':
        statusColor = Colors.green;
        statusText = '已结算';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = '待结算';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = '已取消';
        break;
      default:
        statusColor = Colors.grey;
        statusText = '未知';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(
            _getIncomeTypeIcon(incomeType),
            color: statusColor,
          ),
        ),
        title: Text(
          _getIncomeTypeText(incomeType),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          createdAt != null ? _formatDate(createdAt) : '未知时间',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showIncomeDetailDialog(record),
      ),
    );
  }

  IconData _getIncomeTypeIcon(String incomeType) {
    switch (incomeType) {
      case 'service_fee':
        return Icons.work;
      case 'tip':
        return Icons.favorite;
      case 'bonus':
        return Icons.star;
      case 'refund':
        return Icons.undo;
      default:
        return Icons.attach_money;
    }
  }

  String _getIncomeTypeText(String incomeType) {
    switch (incomeType) {
      case 'service_fee':
        return '服务费';
      case 'tip':
        return '小费';
      case 'bonus':
        return '奖金';
      case 'refund':
        return '退款';
      default:
        return '其他收入';
    }
  }

  String _formatDate(dynamic date) {
    if (date is String) {
      return DateTime.parse(date).toString().substring(0, 10);
    } else if (date is DateTime) {
      return date.toString().substring(0, 10);
    }
    return '未知日期';
  }

  void _showIncomeDetailDialog(Map<String, dynamic> record) {
    Get.dialog(
      AlertDialog(
        title: Text(_getIncomeTypeText(record['income_type'] ?? '')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('金额', '\$${(record['amount'] ?? 0.0).toStringAsFixed(2)}'),
            _buildDetailRow('状态', record['status'] ?? '未知'),
            _buildDetailRow('创建时间', _formatDate(record['created_at'])),
            if (record['notes'] != null)
              _buildDetailRow('备注', record['notes']),
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

  void _showAddPaymentMethodDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('添加支付方式'),
        content: const Text('支付方式管理功能正在开发中...'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
} 