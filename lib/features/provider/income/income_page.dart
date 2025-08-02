import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/income/income_controller.dart';
import 'package:jinbeanpod_83904710/core/ui/components/provider_theme_components.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/provider_theme_utils.dart';

class IncomePage extends GetView<IncomeController> {
  const IncomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '收入管理',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onSurface),
            onPressed: () => controller.refreshIncomeData(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 时间段筛选
          _buildPeriodFilter(),
          
          // 统计卡片
          _buildStatisticsSection(),
          
          // 收入记录
          Expanded(
            child: _buildIncomeRecords(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSettlementDialog(),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 8,
        icon: const Icon(Icons.account_balance_wallet),
        label: const Text('申请结算'),
      ),
    );
  }

  Widget _buildPeriodFilter() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '收入周期',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
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
                    backgroundColor: colorScheme.surfaceVariant,
                    selectedColor: colorScheme.primary.withOpacity(0.1),
                    checkmarkColor: colorScheme.primary,
                    labelStyle: TextStyle(
                      color: controller.selectedPeriod.value == period
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
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
      child: Obx(() {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ProviderStatCard(
                    title: '总收入',
                    value: controller.formatCurrency(controller.totalIncome),
                    icon: Icons.account_balance_wallet,
                    iconColor: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ProviderStatCard(
                    title: '订单数',
                    value: controller.totalOrders.toString(),
                    icon: Icons.receipt_long,
                    iconColor: colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ProviderStatCard(
                    title: '已结算',
                    value: controller.formatCurrency(controller.settledAmount),
                    icon: Icons.trending_up,
                    iconColor: colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ProviderStatCard(
                    title: '待结算',
                    value: controller.formatCurrency(controller.pendingAmount),
                    icon: Icons.pending_actions,
                    iconColor: colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildIncomeRecords() {
    return Obx(() {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      
      if (controller.isLoading.value) {
        return const ProviderLoadingState(message: '加载收入记录...');
      }
      
      if (controller.incomeRecords.isEmpty) {
        return const ProviderEmptyState(
          icon: Icons.account_balance_wallet,
          title: '暂无收入记录',
          subtitle: '完成订单后将显示收入记录',
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.incomeRecords.length,
        itemBuilder: (context, index) {
          final record = controller.incomeRecords[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ProviderCard(
              onTap: () => _showIncomeDetail(record),
              child: Row(
                children: [
                  ProviderIconContainer(
                    icon: _getStatusIcon(record['status']),
                    size: 40,
                    iconColor: _getStatusColor(record['status']),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.getIncomeTypeDisplayName(record['income_type'] ?? 'unknown'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          record['customer_name'] ?? '未知客户',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.formatDate(record['created_at']),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        controller.formatCurrency(record['amount']),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ProviderBadge(
                        text: controller.getStatusDisplayName(record['status']),
                        type: _getBadgeType(record['status']),
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

  void _showSettlementDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.surface,
        title: Row(
          children: [
            ProviderIconContainer(
              icon: Icons.account_balance_wallet,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              '申请结算',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Text(
          '确定要申请结算当前周期的收入吗？',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
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
              Get.back();
              controller.requestSettlement(controller.pendingAmount, '');
            },
            text: '确认申请',
            type: ProviderButtonType.primary,
          ),
        ],
      ),
    );
  }

  void _showIncomeDetail(Map<String, dynamic> record) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.surface,
        title: Text(
          '收入详情',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('类型', controller.getIncomeTypeDisplayName(record['income_type'] ?? 'unknown')),
            _buildDetailRow('客户', record['customer_name'] ?? '未知'),
            _buildDetailRow('金额', controller.formatCurrency(record['amount'])),
            _buildDetailRow('状态', controller.getStatusDisplayName(record['status'])),
            _buildDetailRow('创建时间', controller.formatDate(record['created_at'])),
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

  String _getPeriodDisplayName(String period) {
    switch (period) {
      case 'today':
        return '今天';
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

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'failed':
        return Icons.error;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color _getStatusColor(String? status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'settled':
        return colorScheme.primary;
      case 'pending':
        return colorScheme.tertiary;
      case 'cancelled':
        return colorScheme.error;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'paid':
        return '已结算';
      case 'pending':
        return '待结算';
      case 'failed':
        return '结算失败';
      default:
        return '未知';
    }
  }

  ProviderBadgeType _getBadgeType(String? status) {
    switch (status) {
      case 'settled':
        return ProviderBadgeType.primary;
      case 'pending':
        return ProviderBadgeType.warning;
      case 'cancelled':
        return ProviderBadgeType.error;
      default:
        return ProviderBadgeType.secondary;
    }
  }
} 