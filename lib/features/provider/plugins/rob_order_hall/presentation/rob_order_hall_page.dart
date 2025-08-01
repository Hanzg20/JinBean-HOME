import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/rob_order_hall/rob_order_hall_controller.dart';

class RobOrderHallPage extends StatefulWidget {
  const RobOrderHallPage({super.key});

  @override
  State<RobOrderHallPage> createState() => _RobOrderHallPageState();
}

class _RobOrderHallPageState extends State<RobOrderHallPage> {
  late final RobOrderHallController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(RobOrderHallController());
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
            Icon(Icons.flash_on, color: theme.colorScheme.onPrimary, size: 24),
            const SizedBox(width: 8),
            Text(
              '接单大厅',
              style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.onPrimary),
            onPressed: () => controller.refreshData(),
          ),
          IconButton(
            icon: Icon(Icons.settings, color: theme.colorScheme.onPrimary),
            onPressed: () => _showSettings(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 抢单统计概览
              _buildOrderStatistics(),
              
              // 筛选器
              _buildFilterSection(),
              
              // 可用订单列表
              _buildAvailableOrdersList(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStatistics() {
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
                  Icon(Icons.analytics, color: Colors.blue[600], size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    '接单统计',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '今日可用订单',
                      '${controller.totalOrders.value}',
                      '较昨日 +12',
                      Colors.blue,
                      Icons.shopping_cart,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '我的排名',
                      '#${controller.myRanking.value}',
                      '前10%',
                      Colors.green,
                      Icons.leaderboard,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '成功接单',
                      '${controller.successCount.value}',
                      '成功率 95%',
                      Colors.orange,
                      Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '平均响应',
                      '${controller.averageResponseTime.value.toStringAsFixed(1)}分钟',
                      '行业平均 3.2分钟',
                      Colors.purple,
                      Icons.speed,
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

  Widget _buildStatCard(String title, String value, String subtitle, Color color, IconData icon) {
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
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 8,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.filter_list, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '筛选条件',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...controller.filters.map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Obx(() => FilterChip(
                          label: Text(_getFilterDisplayText(filter)),
                          selected: controller.selectedFilter.value == filter,
                          onSelected: (selected) {
                            if (selected) {
                              controller.filterByUrgency(filter);
                            }
                          },
                          backgroundColor: Colors.grey[100],
                          selectedColor: Colors.blue[100],
                          checkmarkColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: controller.selectedFilter.value == filter 
                                ? Colors.blue[700] 
                                : Colors.grey[700],
                          ),
                        )),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFilterDisplayText(String filter) {
    switch (filter) {
      case 'all':
        return '全部';
      case 'high':
        return '紧急';
      case 'medium':
        return '普通';
      case 'low':
        return '不急';
      default:
        return filter;
    }
  }

  Widget _buildAvailableOrdersList() {
    return Obx(() {
      if (controller.isLoading.value && controller.availableOrders.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        );
      }
      
      if (controller.availableOrders.isEmpty) {
        return _buildEmptyState();
      }
      
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.availableOrders.length + (controller.hasMoreData.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.availableOrders.length) {
              if (controller.hasMoreData.value) {
                controller.loadAvailableOrders();
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return const SizedBox.shrink();
            }
            
            final order = controller.availableOrders[index];
            return _buildOrderCard(order);
          },
        ),
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
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.blue[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '暂无可用订单',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '当前没有可抢的订单，请稍后再试',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.refreshData(),
            icon: const Icon(Icons.refresh),
            label: const Text('刷新'),
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

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final urgency = order['urgency_level'] ?? 'medium';
    final urgencyColor = controller.getUrgencyColor(urgency);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 订单标题和紧急程度
            Row(
              children: [
                Expanded(
                  child: Text(
                    controller.getServiceTitle(order),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: urgencyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    controller.getUrgencyDisplayText(urgency),
                    style: TextStyle(
                      fontSize: 10,
                      color: urgencyColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 价格和时长
            Row(
              children: [
                Text(
                  controller.formatPrice(order['total_amount']),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[600],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${order['estimated_duration'] ?? '2'}小时',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 客户信息
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[200],
                  child: Text(
                    controller.getCustomerName(order).substring(0, 1),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.getCustomerName(order),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, size: 12, color: Colors.amber[600]),
                          const SizedBox(width: 2),
                          Text(
                            '${controller.getCustomerRating(order).toStringAsFixed(1)} (${controller.getCustomerOrderCount(order)}单)',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 2),
                          Text(
                            '${order['distance'] ?? '2.5'}km',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 服务时间和要求
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  controller.formatRelativeTime(order['created_at']),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            if (order['requirements'] != null) ...[
              const SizedBox(height: 8),
              Text(
                order['requirements'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            const SizedBox(height: 16),
            
            // 抢单按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showGrabOrderDialog(order),
                icon: const Icon(Icons.flash_on, size: 16),
                label: const Text('立即接单'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGrabOrderDialog(Map<String, dynamic> order) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.flash_on, color: Colors.orange[600]),
            const SizedBox(width: 8),
            const Text('确认接单'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('确定要接取这个订单吗？'),
            const SizedBox(height: 8),
            Text(
              controller.getServiceTitle(order),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('价格: ${controller.formatPrice(order['total_amount'])}'),
            const SizedBox(height: 8),
            Text(
              '接单成功后，您需要及时联系客户并安排服务时间。',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.grabOrder(order['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('确认接单'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  '接单设置',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSettingItem('通知设置', '接收新订单通知', Icons.notifications),
            _buildSettingItem('距离设置', '最大接单距离 5km', Icons.location_on),
            _buildSettingItem('价格设置', '最低接单价格 \$50', Icons.attach_money),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('确定'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // TODO: 实现具体设置功能
      },
    );
  }
} 