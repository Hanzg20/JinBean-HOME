import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/services/review_data_creation_service.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

/// 评价数据创建测试页面
class ReviewDataCreationPage extends StatefulWidget {
  const ReviewDataCreationPage({super.key});

  @override
  State<ReviewDataCreationPage> createState() => _ReviewDataCreationPageState();
}

class _ReviewDataCreationPageState extends State<ReviewDataCreationPage> {
  final ReviewDataCreationService _service = ReviewDataCreationService();
  bool _isLoading = false;
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  /// 加载统计信息
  Future<void> _loadStats() async {
    try {
      final stats = await _service.getReviewStats();
      setState(() {
        _stats = stats;
      });
    } catch (e) {
      AppLogger.error('[ReviewDataCreationPage] 加载统计信息失败: $e');
    }
  }

  /// 创建评价数据
  Future<void> _createReviews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _service.createReviewsFromLatestOrder();
      await _loadStats();
      
      Get.snackbar(
        '成功',
        '评价数据创建完成！',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      AppLogger.error('[ReviewDataCreationPage] 创建评价数据失败: $e');
      Get.snackbar(
        '错误',
        '创建评价数据失败: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('评价数据创建'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 统计信息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '评价统计',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('基于订单', _stats['orderBased'] ?? 0, Colors.blue),
                        _buildStatItem('基于服务', _stats['serviceBased'] ?? 0, Colors.green),
                        _buildStatItem('总计', _stats['total'] ?? 0, Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 操作按钮
            ElevatedButton(
              onPressed: _isLoading ? null : _createReviews,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('创建中...'),
                      ],
                    )
                  : const Text(
                      '基于最新订单创建评价数据',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // 说明文本
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '功能说明',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• 基于最新订单创建评价（已验证）\n'
                      '• 基于服务创建评价（未验证）\n'
                      '• 为同一服务商的其他服务创建评价\n'
                      '• 自动避免重复创建',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 刷新按钮
            OutlinedButton(
              onPressed: _loadStats,
              child: const Text('刷新统计'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
