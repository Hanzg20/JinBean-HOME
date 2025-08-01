import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final RxString selectedPeriod = 'month'.obs;
  final RxString selectedReportType = 'overview'.obs;
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('数据分析报表'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadReportData(),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportReport(),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReport(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadReportData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 时间段选择器
              _buildPeriodSelector(),
              
              // 报表类型选择器
              _buildReportTypeSelector(),
              
              // 报表内容
              _buildReportContent(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '时间段',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => Row(
                children: [
                  'week',
                  'month',
                  'quarter',
                  'year',
                ].map((period) {
                  final isSelected = selectedPeriod.value == period;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => selectedPeriod.value = period,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getPeriodText(period),
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

  Widget _buildReportTypeSelector() {
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
                '报表类型',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'overview',
                  'revenue',
                  'orders',
                  'customers',
                  'services',
                  'performance',
                ].map((type) {
                  final isSelected = selectedReportType.value == type;
                  return GestureDetector(
                    onTap: () => selectedReportType.value = type,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        _getReportTypeText(type),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildReportContent() {
    return Obx(() {
      if (isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        );
      }

      switch (selectedReportType.value) {
        case 'overview':
          return _buildOverviewReport();
        case 'revenue':
          return _buildRevenueReport();
        case 'orders':
          return _buildOrdersReport();
        case 'customers':
          return _buildCustomersReport();
        case 'services':
          return _buildServicesReport();
        case 'performance':
          return _buildPerformanceReport();
        default:
          return _buildOverviewReport();
      }
    });
  }

  Widget _buildOverviewReport() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 关键指标卡片
          _buildKeyMetricsCard(),
          
          // 趋势图表
          _buildTrendChart(),
          
          // 服务分布
          _buildServiceDistribution(),
          
          // 客户分析
          _buildCustomerAnalysis(),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '关键指标',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem('总收入', '\$12,450', '+15%', Colors.green, Icons.attach_money),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricItem('订单数', '156', '+8%', Colors.blue, Icons.shopping_cart),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem('新客户', '23', '+12%', Colors.orange, Icons.person_add),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricItem('平均评分', '4.2', '+0.3', Colors.purple, Icons.star),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String title, String value, String change, Color color, IconData icon) {
    final isPositive = change.startsWith('+');
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
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
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '收入趋势',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '图表功能开发中',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDistribution() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '服务分布',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildServiceItem('家庭清洁', 45, Colors.blue),
            _buildServiceItem('深度清洁', 28, Colors.green),
            _buildServiceItem('日常清洁', 18, Colors.orange),
            _buildServiceItem('其他服务', 9, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(String service, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              service,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAnalysis() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '客户分析',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCustomerStat('新客户', '23', Colors.green),
                ),
                Expanded(
                  child: _buildCustomerStat('回头客', '89', Colors.blue),
                ),
                Expanded(
                  child: _buildCustomerStat('流失客户', '12', Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
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

  Widget _buildRevenueReport() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '收入报表',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRevenueItem('服务费收入', '\$10,200', '+18%'),
                  _buildRevenueItem('小费收入', '\$1,800', '+12%'),
                  _buildRevenueItem('平台补贴', '\$450', '+5%'),
                  const Divider(),
                  _buildRevenueItem('总收入', '\$12,450', '+15%', isTotal: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueItem(String label, String amount, String change, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.blue : Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              change,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersReport() {
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
                '订单报表',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildOrderStat('总订单数', '156', Icons.shopping_cart),
              _buildOrderStat('已完成', '142', Icons.check_circle, color: Colors.green),
              _buildOrderStat('进行中', '8', Icons.pending, color: Colors.orange),
              _buildOrderStat('已取消', '6', Icons.cancel, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStat(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersReport() {
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
                '客户报表',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildCustomerStatItem('总客户数', '124', Icons.people),
              _buildCustomerStatItem('活跃客户', '89', Icons.person, color: Colors.green),
              _buildCustomerStatItem('新客户', '23', Icons.person_add, color: Colors.blue),
              _buildCustomerStatItem('流失客户', '12', Icons.person_remove, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerStatItem(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesReport() {
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
                '服务报表',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildServiceStatItem('家庭清洁', '70', '\$8,400'),
              _buildServiceStatItem('深度清洁', '44', '\$2,640'),
              _buildServiceStatItem('日常清洁', '28', '\$1,120'),
              _buildServiceStatItem('其他服务', '14', '\$290'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceStatItem(String service, String orders, String revenue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
        child: Text(
              service,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '$orders 单',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            revenue,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceReport() {
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
                '绩效报表',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildPerformanceItem('平均响应时间', '2.3分钟', Colors.green),
              _buildPerformanceItem('准时率', '96%', Colors.blue),
              _buildPerformanceItem('客户满意度', '4.2/5', Colors.orange),
              _buildPerformanceItem('复购率', '72%', Colors.purple),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getPeriodText(String period) {
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

  String _getReportTypeText(String type) {
    switch (type) {
      case 'overview':
        return '概览';
      case 'revenue':
        return '收入';
      case 'orders':
        return '订单';
      case 'customers':
        return '客户';
      case 'services':
        return '服务';
      case 'performance':
        return '绩效';
      default:
        return type;
    }
  }

  void _exportReport() {
    Get.snackbar(
      '导出报表',
      '报表导出功能正在开发中...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _shareReport() {
    Get.snackbar(
      '分享报表',
      '报表分享功能正在开发中...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
} 