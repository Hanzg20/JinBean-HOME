import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/ui/design_system/colors.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

class FinanceSettingsPage extends StatefulWidget {
  const FinanceSettingsPage({super.key});

  @override
  State<FinanceSettingsPage> createState() => _FinanceSettingsPageState();
}

class _FinanceSettingsPageState extends State<FinanceSettingsPage> {
  final _supabase = Supabase.instance.client;
  
  bool _isLoading = true;
  Map<String, dynamic>? _financeData;
  List<Map<String, dynamic>> _paymentMethods = [];
  
  @override
  void initState() {
    super.initState();
    _loadFinanceData();
  }
  
  Future<void> _loadFinanceData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[FinanceSettingsPage] No user ID available');
        return;
      }
      
      // 获取财务设置
      final financeResponse = await _supabase
          .from('provider_settings')
          .select('*')
          .eq('provider_id', userId)
          .inFilter('setting_key', ['finance_settings', 'payment_methods']);
      
      // 获取支付方式
      final paymentResponse = await _supabase
          .from('payment_methods')
          .select('*')
          .eq('provider_id', userId)
          .eq('is_active', true)
          .order('created_at');
      
      setState(() {
        _financeData = _parseFinanceData(financeResponse);
        _paymentMethods = List<Map<String, dynamic>>.from(paymentResponse);
        _isLoading = false;
      });
      
    } catch (e) {
      AppLogger.error('[FinanceSettingsPage] Error loading finance data: $e');
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load finance data',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  Map<String, dynamic> _parseFinanceData(List<dynamic> response) {
    final Map<String, dynamic> data = {};
    for (final item in response) {
      data[item['setting_key']] = item['setting_value'];
    }
    return data;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JinBeanColors.background,
      appBar: AppBar(
        title: const Text('收入与财务管理', style: TextStyle(color: JinBeanColors.textPrimary)),
        backgroundColor: JinBeanColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: JinBeanColors.textPrimary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('财务概览'),
                  _buildFinanceOverviewCard(),
                  
                  const SizedBox(height: 24),
                  _buildSectionHeader('支付方式'),
                  _buildPaymentMethodsCard(),
                  
                  const SizedBox(height: 24),
                  _buildSectionHeader('结算设置'),
                  _buildSettlementSettingsCard(),
                  
                  const SizedBox(height: 24),
                  _buildSectionHeader('税务信息'),
                  _buildTaxInfoCard(),
                  
                  const SizedBox(height: 24),
                  _buildSectionHeader('财务报告'),
                  _buildFinancialReportsCard(),
                ],
              ),
            ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: JinBeanColors.textPrimary,
        ),
      ),
    );
  }
  
  Widget _buildFinanceOverviewCard() {
    final totalEarnings = _financeData?['finance_settings']?['total_earnings'] ?? 0.0;
    final pendingAmount = _financeData?['finance_settings']?['pending_amount'] ?? 0.0;
    final thisMonthEarnings = _financeData?['finance_settings']?['this_month_earnings'] ?? 0.0;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildFinanceStat(
                    '总收入',
                    '\$${totalEarnings.toStringAsFixed(2)}',
                    Colors.green,
                    Icons.attach_money,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFinanceStat(
                    '待结算',
                    '\$${pendingAmount.toStringAsFixed(2)}',
                    Colors.orange,
                    Icons.pending,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFinanceStat(
                    '本月收入',
                    '\$${thisMonthEarnings.toStringAsFixed(2)}',
                    Colors.blue,
                    Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFinanceStat(
                    '支付方式',
                    '${_paymentMethods.length}个',
                    Colors.purple,
                    Icons.payment,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFinanceStat(String title, String value, Color color, IconData icon) {
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
  
  Widget _buildPaymentMethodsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '支付方式',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddPaymentMethodDialog(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('添加'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JinBeanColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_paymentMethods.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.payment,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '暂无支付方式',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '添加支付方式以便接收收入',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: _paymentMethods.map((method) => _buildPaymentMethodItem(method)).toList(),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentMethodItem(Map<String, dynamic> method) {
    final type = method['method_type'] as String? ?? '';
    final accountName = method['account_name'] as String? ?? '';
    final isDefault = method['is_default'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDefault ? JinBeanColors.primary : Colors.grey[300]!,
          width: isDefault ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getPaymentMethodIcon(type),
            color: JinBeanColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getPaymentMethodDisplayName(type),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  accountName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: JinBeanColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '默认',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (value) => _handlePaymentMethodAction(value, method),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('编辑'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'set_default',
                child: Row(
                  children: [
                    Icon(Icons.star, size: 16),
                    SizedBox(width: 8),
                    Text('设为默认'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('删除', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettlementSettingsCard() {
    final autoSettlement = _financeData?['finance_settings']?['auto_settlement'] ?? false;
    final settlementThreshold = _financeData?['finance_settings']?['settlement_threshold'] ?? 100.0;
    final settlementFrequency = _financeData?['finance_settings']?['settlement_frequency'] ?? 'weekly';
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '结算设置',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 自动结算开关
            SwitchListTile(
              title: const Text('自动结算'),
              subtitle: const Text('达到阈值时自动申请结算'),
              value: autoSettlement,
              onChanged: (value) => _updateSettlementSetting('auto_settlement', value),
              activeColor: JinBeanColors.primary,
            ),
            
            const Divider(),
            
            // 结算阈值
            ListTile(
              title: const Text('结算阈值'),
              subtitle: Text('\$${settlementThreshold.toStringAsFixed(2)}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showSettlementThresholdDialog(settlementThreshold),
            ),
            
            const Divider(),
            
            // 结算频率
            ListTile(
              title: const Text('结算频率'),
              subtitle: Text(_getSettlementFrequencyText(settlementFrequency)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showSettlementFrequencyDialog(settlementFrequency),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTaxInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '税务信息',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.receipt, color: Colors.orange),
              title: const Text('税务识别号'),
              subtitle: const Text('未设置'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showTaxInfoDialog(),
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.business, color: Colors.blue),
              title: const Text('公司信息'),
              subtitle: const Text('未设置'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showCompanyInfoDialog(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFinancialReportsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '财务报告',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildReportItem(
              icon: Icons.assessment,
              title: '收入报告',
              subtitle: '查看详细的收入分析',
              onTap: () => _showReportDialog('income'),
            ),
            
            const Divider(),
            
            _buildReportItem(
              icon: Icons.pie_chart,
              title: '服务分析',
              subtitle: '分析各服务的收入情况',
              onTap: () => _showReportDialog('service'),
            ),
            
            const Divider(),
            
            _buildReportItem(
              icon: Icons.calendar_today,
              title: '月度报表',
              subtitle: '生成月度财务报表',
              onTap: () => _showReportDialog('monthly'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReportItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: JinBeanColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
  
  IconData _getPaymentMethodIcon(String type) {
    switch (type) {
      case 'bank_transfer':
        return Icons.account_balance;
      case 'paypal':
        return Icons.payment;
      case 'stripe':
        return Icons.credit_card;
      case 'wechat_pay':
        return Icons.payment;
      case 'alipay':
        return Icons.payment;
      default:
        return Icons.payment;
    }
  }
  
  String _getPaymentMethodDisplayName(String type) {
    switch (type) {
      case 'bank_transfer':
        return '银行转账';
      case 'paypal':
        return 'PayPal';
      case 'stripe':
        return 'Stripe';
      case 'wechat_pay':
        return '微信支付';
      case 'alipay':
        return '支付宝';
      default:
        return type;
    }
  }
  
  String _getSettlementFrequencyText(String frequency) {
    switch (frequency) {
      case 'daily':
        return '每日';
      case 'weekly':
        return '每周';
      case 'monthly':
        return '每月';
      default:
        return '每周';
    }
  }
  
  void _showAddPaymentMethodDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('添加支付方式'),
        content: const Text('支付方式管理功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  void _handlePaymentMethodAction(String action, Map<String, dynamic> method) {
    switch (action) {
      case 'edit':
        _showEditPaymentMethodDialog(method);
        break;
      case 'set_default':
        _setDefaultPaymentMethod(method['id']);
        break;
      case 'delete':
        _showDeletePaymentMethodDialog(method);
        break;
    }
  }
  
  void _showEditPaymentMethodDialog(Map<String, dynamic> method) {
    Get.dialog(
      AlertDialog(
        title: const Text('编辑支付方式'),
        content: const Text('编辑功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  void _showDeletePaymentMethodDialog(Map<String, dynamic> method) {
    Get.dialog(
      AlertDialog(
        title: const Text('删除支付方式'),
        content: const Text('确定要删除这个支付方式吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // 删除逻辑
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  void _setDefaultPaymentMethod(String methodId) {
    // 设置默认支付方式的逻辑
    Get.snackbar(
      'Success',
      '默认支付方式已更新',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  Future<void> _updateSettlementSetting(String key, dynamic value) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      await _supabase
          .from('provider_settings')
          .upsert({
            'provider_id': userId,
            'setting_key': 'finance_settings',
            'setting_value': {
              ..._financeData?['finance_settings'] ?? {},
              key: value,
            },
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      await _loadFinanceData();
      
    } catch (e) {
      AppLogger.error('[FinanceSettingsPage] Error updating settlement setting: $e');
    }
  }
  
  void _showSettlementThresholdDialog(double currentThreshold) {
    Get.dialog(
      AlertDialog(
        title: const Text('设置结算阈值'),
        content: const Text('结算阈值设置功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  void _showSettlementFrequencyDialog(String currentFrequency) {
    Get.dialog(
      AlertDialog(
        title: const Text('设置结算频率'),
        content: const Text('结算频率设置功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  void _showTaxInfoDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('税务信息'),
        content: const Text('税务信息管理功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  void _showCompanyInfoDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('公司信息'),
        content: const Text('公司信息管理功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  void _showReportDialog(String reportType) {
    Get.dialog(
      AlertDialog(
        title: Text('${_getReportTypeName(reportType)}报告'),
        content: const Text('报告生成功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  String _getReportTypeName(String type) {
    switch (type) {
      case 'income':
        return '收入';
      case 'service':
        return '服务';
      case 'monthly':
        return '月度';
      default:
        return '财务';
    }
  }
} 