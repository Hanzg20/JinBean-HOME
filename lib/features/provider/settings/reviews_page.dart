import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final RxString selectedFilter = 'all'.obs;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> reviews = <Map<String, dynamic>>[].obs;
  final RxDouble averageRating = 0.0.obs;
  final RxInt totalReviews = 0.obs;

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _loadStatistics();
  }

  Future<void> _loadReviews() async {
    isLoading.value = true;
    // 模拟加载数据
    await Future.delayed(const Duration(seconds: 1));
    
    // 模拟评价数据
    reviews.value = [
      {
        'id': '1',
        'customer_name': '张先生',
        'rating': 5,
        'comment': '服务非常专业，态度很好，准时到达，强烈推荐！',
        'service_name': '家庭清洁',
        'created_at': DateTime.now().subtract(const Duration(days: 2)),
        'is_verified': true,
        'response': null,
      },
      {
        'id': '2',
        'customer_name': '李女士',
        'rating': 4,
        'comment': '工作认真负责，清洁效果不错，价格合理。',
        'service_name': '深度清洁',
        'created_at': DateTime.now().subtract(const Duration(days: 5)),
        'is_verified': true,
        'response': '感谢您的评价，我们会继续努力提供更好的服务！',
      },
      {
        'id': '3',
        'customer_name': '王先生',
        'rating': 3,
        'comment': '服务还可以，但是时间有点晚。',
        'service_name': '日常清洁',
        'created_at': DateTime.now().subtract(const Duration(days: 8)),
        'is_verified': false,
        'response': null,
      },
    ];
    isLoading.value = false;
  }

  Future<void> _loadStatistics() async {
    // 模拟统计数据
    averageRating.value = 4.2;
    totalReviews.value = 156;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('客户评价'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadReviews();
              _loadStatistics();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showReviewSettings(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadReviews();
          await _loadStatistics();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 评价统计卡片
              _buildReviewStatistics(),
              
              // 筛选器
              _buildFilterSection(),
              
              // 评价列表
              _buildReviewsList(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewStatistics() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Obx(() => Text(
                          averageRating.value.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        )),
                        const SizedBox(height: 8),
                        _buildStarRating(averageRating.value),
                        const SizedBox(height: 8),
                        Obx(() => Text(
                          '${totalReviews.value} 条评价',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        _buildRatingDistribution(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('回复率', '85%', Colors.green, Icons.reply),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('好评率', '92%', Colors.blue, Icons.thumb_up),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('认证评价', '78%', Colors.purple, Icons.verified),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.orange, size: 20);
        } else if (index == rating.floor() && rating % 1 > 0) {
          return Icon(Icons.star_half, color: Colors.orange, size: 20);
        } else {
          return Icon(Icons.star_border, color: Colors.grey[400], size: 20);
        }
      }),
    );
  }

  Widget _buildRatingDistribution() {
    final ratings = [5, 4, 3, 2, 1];
    final counts = [45, 32, 15, 3, 1]; // 模拟数据
    final total = counts.reduce((a, b) => a + b);
    
    return Column(
      children: ratings.map((rating) {
        final count = counts[rating - 1];
        final percentage = total > 0 ? (count / total * 100).round() : 0;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Text(
                '$rating',
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: total > 0 ? count / total : 0,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    rating >= 4 ? Colors.green : rating >= 3 ? Colors.orange : Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
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
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '筛选',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => Row(
                children: [
                  'all',
                  '5',
                  '4',
                  '3',
                  '2',
                  '1',
                ].map((filter) {
                  final isSelected = selectedFilter.value == filter;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => selectedFilter.value = filter,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getFilterText(filter),
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

  String _getFilterText(String filter) {
    switch (filter) {
      case 'all':
        return '全部';
      case '5':
        return '5星';
      case '4':
        return '4星';
      case '3':
        return '3星';
      case '2':
        return '2星';
      case '1':
        return '1星';
      default:
        return filter;
    }
  }

  Widget _buildReviewsList() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '评价列表',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (reviews.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '暂无评价',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '完成服务后将显示客户评价',
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
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return _buildReviewCard(review);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = review['rating'] as int;
    final customerName = review['customer_name'] as String;
    final comment = review['comment'] as String;
    final serviceName = review['service_name'] as String;
    final createdAt = review['created_at'] as DateTime;
    final isVerified = review['is_verified'] as bool;
    final response = review['response'] as String?;
    
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
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
        child: Text(
                    customerName.substring(0, 1),
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            customerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.blue[600],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            if (index < rating) {
                              return const Icon(Icons.star, color: Colors.orange, size: 16);
                            } else {
                              return Icon(Icons.star_border, color: Colors.grey[400], size: 16);
                            }
                          }),
                          const SizedBox(width: 8),
                          Text(
                            serviceName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              comment,
              style: const TextStyle(fontSize: 14),
            ),
            if (response != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.reply,
                          size: 16,
                          color: Colors.blue[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '商家回复',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      response,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (response == null)
                  TextButton(
                    onPressed: () => _showReplyDialog(review),
                    child: const Text('回复'),
                  ),
                TextButton(
                  onPressed: () => _showReviewDetail(review),
                  child: const Text('详情'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return '今天';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${date.month}-${date.day}';
    }
  }

  void _showReplyDialog(Map<String, dynamic> review) {
    final TextEditingController replyController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: Text('回复 ${review['customer_name']}'),
        content: TextField(
          controller: replyController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: '请输入回复内容...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 发送回复
              Get.back();
              Get.snackbar('成功', '回复已发送');
            },
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }

  void _showReviewDetail(Map<String, dynamic> review) {
    Get.dialog(
      AlertDialog(
        title: Text('评价详情'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('客户', review['customer_name']),
            _buildDetailRow('服务', review['service_name']),
            _buildDetailRow('评分', '${review['rating']}星'),
            _buildDetailRow('评价', review['comment']),
            _buildDetailRow('时间', _formatDate(review['created_at'])),
            if (review['response'] != null)
              _buildDetailRow('回复', review['response']),
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
            width: 60,
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

  void _showReviewSettings() {
    Get.dialog(
      AlertDialog(
        title: const Text('评价设置'),
        content: const Text('评价管理设置功能正在开发中...'),
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