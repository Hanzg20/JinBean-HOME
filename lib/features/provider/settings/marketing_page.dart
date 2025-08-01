import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketingPage extends StatefulWidget {
  const MarketingPage({super.key});

  @override
  State<MarketingPage> createState() => _MarketingPageState();
}

class _MarketingPageState extends State<MarketingPage> {
  final RxString selectedTab = 'campaigns'.obs;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> campaigns = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> promotions = <Map<String, dynamic>>[].obs;

  @override
  void initState() {
    super.initState();
    _loadMarketingData();
  }

  Future<void> _loadMarketingData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    
    // 模拟推广活动数据
    campaigns.value = [
      {
        'id': '1',
        'name': '新客户优惠活动',
        'type': 'discount',
        'status': 'active',
        'budget': 500.0,
        'spent': 320.0,
        'impressions': 1250,
        'clicks': 89,
        'conversions': 23,
        'start_date': DateTime.now().subtract(const Duration(days: 15)),
        'end_date': DateTime.now().add(const Duration(days: 15)),
        'description': '新客户首次下单享受8折优惠',
      },
      {
        'id': '2',
        'name': '周末特价推广',
        'type': 'promotion',
        'status': 'paused',
        'budget': 300.0,
        'spent': 180.0,
        'impressions': 890,
        'clicks': 45,
        'conversions': 12,
        'start_date': DateTime.now().subtract(const Duration(days: 30)),
        'end_date': DateTime.now().add(const Duration(days: 30)),
        'description': '周末清洁服务特价优惠',
      },
    ];
    
    // 模拟促销活动数据
    promotions.value = [
      {
        'id': '1',
        'name': '首次下单立减20元',
        'type': 'first_order',
        'discount': 20.0,
        'min_amount': 100.0,
        'status': 'active',
        'usage_count': 45,
        'max_usage': 100,
        'start_date': DateTime.now().subtract(const Duration(days: 10)),
        'end_date': DateTime.now().add(const Duration(days: 20)),
      },
      {
        'id': '2',
        'name': '满200减30',
        'type': 'amount_discount',
        'discount': 30.0,
        'min_amount': 200.0,
        'status': 'active',
        'usage_count': 23,
        'max_usage': 50,
        'start_date': DateTime.now().subtract(const Duration(days: 5)),
        'end_date': DateTime.now().add(const Duration(days: 25)),
      },
    ];
    
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
        title: const Text('广告推广'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadMarketingData(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateCampaignDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadMarketingData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 推广概览
              _buildMarketingOverview(),
              
              // 标签页选择器
              _buildTabSelector(),
              
              // 标签页内容
              _buildTabContent(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketingOverview() {
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
                '推广概览',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard('总预算', '\$800', Colors.blue, Icons.account_balance_wallet),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOverviewCard('已花费', '\$500', Colors.orange, Icons.money_off),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard('展示次数', '2,140', Colors.green, Icons.visibility),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOverviewCard('转化次数', '35', Colors.purple, Icons.trending_up),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '推广活动可以帮助您获得更多客户和订单',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
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

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Obx(() => Row(
            children: [
              'campaigns',
              'promotions',
              'analytics',
            ].map((tab) {
              final isSelected = selectedTab.value == tab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => selectedTab.value = tab,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getTabText(tab),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Obx(() {
      if (isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        );
      }

      switch (selectedTab.value) {
        case 'campaigns':
          return _buildCampaignsTab();
        case 'promotions':
          return _buildPromotionsTab();
        case 'analytics':
          return _buildAnalyticsTab();
        default:
          return _buildCampaignsTab();
      }
    });
  }

  Widget _buildCampaignsTab() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '推广活动',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showCreateCampaignDialog(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('创建活动'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (campaigns.isEmpty)
            _buildEmptyState('暂无推广活动', '创建您的第一个推广活动来吸引更多客户')
          else
            ...campaigns.map((campaign) => _buildCampaignCard(campaign)),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(Map<String, dynamic> campaign) {
    final status = campaign['status'] as String;
    final budget = campaign['budget'] as double;
    final spent = campaign['spent'] as double;
    final progress = spent / budget;
    
    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'active':
        statusColor = Colors.green;
        statusText = '进行中';
        break;
      case 'paused':
        statusColor = Colors.orange;
        statusText = '已暂停';
        break;
      case 'ended':
        statusColor = Colors.grey;
        statusText = '已结束';
        break;
      default:
        statusColor = Colors.grey;
        statusText = '未知';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campaign['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        campaign['description'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
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
                    statusText,
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
            Row(
              children: [
                Expanded(
                  child: _buildCampaignStat('预算', '\$${budget.toStringAsFixed(0)}'),
                ),
                Expanded(
                  child: _buildCampaignStat('已花费', '\$${spent.toStringAsFixed(0)}'),
                ),
                Expanded(
                  child: _buildCampaignStat('展示', '${campaign['impressions']}'),
                ),
                Expanded(
                  child: _buildCampaignStat('转化', '${campaign['conversions']}'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showCampaignDetail(campaign),
                  child: const Text('详情'),
                ),
                const SizedBox(width: 8),
                if (status == 'active')
                  TextButton(
                    onPressed: () => _pauseCampaign(campaign),
                    child: const Text('暂停'),
                  )
                else if (status == 'paused')
                  TextButton(
                    onPressed: () => _resumeCampaign(campaign),
                    child: const Text('恢复'),
                  ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _editCampaign(campaign),
                  child: const Text('编辑'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionsTab() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '促销活动',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showCreatePromotionDialog(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('创建促销'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (promotions.isEmpty)
            _buildEmptyState('暂无促销活动', '创建促销活动来吸引客户下单')
          else
            ...promotions.map((promotion) => _buildPromotionCard(promotion)),
        ],
      ),
    );
  }

  Widget _buildPromotionCard(Map<String, dynamic> promotion) {
    final status = promotion['status'] as String;
    final usageCount = promotion['usage_count'] as int;
    final maxUsage = promotion['max_usage'] as int;
    final progress = usageCount / maxUsage;
    
    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'active':
        statusColor = Colors.green;
        statusText = '进行中';
        break;
      case 'paused':
        statusColor = Colors.orange;
        statusText = '已暂停';
        break;
      case 'ended':
        statusColor = Colors.grey;
        statusText = '已结束';
        break;
      default:
        statusColor = Colors.grey;
        statusText = '未知';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promotion['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getPromotionDescription(promotion),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
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
                    statusText,
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
            Row(
              children: [
                Expanded(
                  child: _buildPromotionStat('已使用', '$usageCount'),
                ),
                Expanded(
                  child: _buildPromotionStat('总数量', '$maxUsage'),
                ),
                Expanded(
                  child: _buildPromotionStat('剩余', '${maxUsage - usageCount}'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showPromotionDetail(promotion),
                  child: const Text('详情'),
                ),
                const SizedBox(width: 8),
                if (status == 'active')
                  TextButton(
                    onPressed: () => _pausePromotion(promotion),
                    child: const Text('暂停'),
                  )
                else if (status == 'paused')
                  TextButton(
                    onPressed: () => _resumePromotion(promotion),
                    child: const Text('恢复'),
                  ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _editPromotion(promotion),
                  child: const Text('编辑'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '推广分析',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '效果统计',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAnalyticsItem('点击率', '4.2%', Colors.blue),
                  _buildAnalyticsItem('转化率', '2.8%', Colors.green),
                  _buildAnalyticsItem('平均点击成本', '\$2.15', Colors.orange),
                  _buildAnalyticsItem('投资回报率', '3.2x', Colors.purple),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '趋势分析',
                    style: TextStyle(
                      fontSize: 16,
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
                            Icons.analytics,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '分析图表功能开发中',
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
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsItem(String label, String value, Color color) {
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

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.campaign,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _getTabText(String tab) {
    switch (tab) {
      case 'campaigns':
        return '推广活动';
      case 'promotions':
        return '促销活动';
      case 'analytics':
        return '数据分析';
      default:
        return tab;
    }
  }

  String _getPromotionDescription(Map<String, dynamic> promotion) {
    final type = promotion['type'] as String;
    final discount = promotion['discount'] as double;
    final minAmount = promotion['min_amount'] as double;
    
    switch (type) {
      case 'first_order':
        return '首次下单立减\$${discount.toStringAsFixed(0)}';
      case 'amount_discount':
        return '满\$${minAmount.toStringAsFixed(0)}减\$${discount.toStringAsFixed(0)}';
      default:
        return '促销活动';
    }
  }

  void _showCreateCampaignDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('创建推广活动'),
        content: const Text('推广活动创建功能正在开发中...'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showCreatePromotionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('创建促销活动'),
        content: const Text('促销活动创建功能正在开发中...'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showCampaignDetail(Map<String, dynamic> campaign) {
    Get.dialog(
      AlertDialog(
        title: Text(campaign['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('状态', campaign['status']),
            _buildDetailRow('预算', '\$${campaign['budget']}'),
            _buildDetailRow('已花费', '\$${campaign['spent']}'),
            _buildDetailRow('展示次数', '${campaign['impressions']}'),
            _buildDetailRow('点击次数', '${campaign['clicks']}'),
            _buildDetailRow('转化次数', '${campaign['conversions']}'),
            _buildDetailRow('描述', campaign['description']),
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

  void _showPromotionDetail(Map<String, dynamic> promotion) {
    Get.dialog(
      AlertDialog(
        title: Text(promotion['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('状态', promotion['status']),
            _buildDetailRow('折扣', '\$${promotion['discount']}'),
            _buildDetailRow('最低金额', '\$${promotion['min_amount']}'),
            _buildDetailRow('已使用', '${promotion['usage_count']}'),
            _buildDetailRow('总数量', '${promotion['max_usage']}'),
            _buildDetailRow('剩余', '${promotion['max_usage'] - promotion['usage_count']}'),
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

  void _pauseCampaign(Map<String, dynamic> campaign) {
    Get.snackbar('暂停活动', '推广活动已暂停');
  }

  void _resumeCampaign(Map<String, dynamic> campaign) {
    Get.snackbar('恢复活动', '推广活动已恢复');
  }

  void _editCampaign(Map<String, dynamic> campaign) {
    Get.snackbar('编辑活动', '编辑功能正在开发中...');
  }

  void _pausePromotion(Map<String, dynamic> promotion) {
    Get.snackbar('暂停促销', '促销活动已暂停');
  }

  void _resumePromotion(Map<String, dynamic> promotion) {
    Get.snackbar('恢复促销', '促销活动已恢复');
  }

  void _editPromotion(Map<String, dynamic> promotion) {
    Get.snackbar('编辑促销', '编辑功能正在开发中...');
  }
} 