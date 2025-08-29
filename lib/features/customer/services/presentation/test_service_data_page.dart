import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/services.dart';

// 服务数据测试页面
class TestServiceDataPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('服务数据测试'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 服务状态显示
            _buildServiceStatusCard(),
            SizedBox(height: 20),

            // 数据获取测试
            _buildDataTestCard(),
            SizedBox(height: 20),

            // 结果显示
            _buildResultsCard(),
          ],
        ),
      ),
    );
  }

  // 服务状态卡片
  Widget _buildServiceStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '服务状态',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 12),
            // 临时显示服务状态（等待ServiceManagerState注册）
            _buildStatusRow('初始化状态', '等待注册'),
            _buildStatusRow('初始化中', '否'),
            _buildStatusRow('最后错误', '无'),
            _buildStatusRow('错误时间', '无'),
          ],
        ),
      ),
    );
  }

  // 数据测试卡片
  Widget _buildDataTestCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '数据获取测试',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _testGetRecommendedServices();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('获取推荐服务'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _testGetServiceStatistics();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('获取统计信息'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _testSearchServices();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('搜索服务'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _testGetServicesByCategory();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('分类服务'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 结果显示卡片
  Widget _buildResultsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '测试结果',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 12),
            Text(
              '点击上方按钮开始测试，结果将显示在控制台中',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '请查看Flutter控制台输出以查看详细结果',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 状态行构建
  Widget _buildStatusRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isError ? Colors.red : Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 测试获取推荐服务
  void _testGetRecommendedServices() async {
    try {
      print('=== 开始测试获取推荐服务 ===');

      final serviceManager = ServiceManager.instance;
      if (!serviceManager.isInitialized) {
        print('❌ ServiceManager未初始化');
        Get.snackbar(
          '测试失败',
          'ServiceManager未初始化',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final services = await serviceManager.serviceQueryService
          .getRecommendedServices(limit: 5);

      print('✅ 成功获取 ${services.length} 个推荐服务');

      for (int i = 0; i < services.length; i++) {
        final service = services[i];
        print('服务 ${i + 1}:');
        print('  ID: ${service.id}');
        print('  标题(英文): ${service.getLocalizedTitle('en')}');
        print('  标题(中文): ${service.getLocalizedTitle('zh')}');
        print('  价格: ${service.priceDisplay}');
        print('  评分: ${service.ratingDisplay}');
        print('  分类ID: ${service.categoryId}');
        print('  服务商ID: ${service.providerId}');
        print('  状态: ${service.status}');
        print('  标签: ${service.tags.join(', ')}');
        print('  ---');
      }

      Get.snackbar(
        '测试成功',
        '获取到 ${services.length} 个推荐服务',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ 测试获取推荐服务失败: $e');
      Get.snackbar(
        '测试失败',
        '获取推荐服务失败: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 测试获取统计信息
  void _testGetServiceStatistics() async {
    try {
      print('=== 开始测试获取服务统计信息 ===');

      final serviceManager = ServiceManager.instance;
      if (!serviceManager.isInitialized) {
        print('❌ ServiceManager未初始化');
        Get.snackbar(
          '测试失败',
          'ServiceManager未初始化',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final stats =
          await serviceManager.serviceQueryService.getServiceStatistics();

      print('✅ 成功获取服务统计信息');
      print('总服务数: ${stats['total_services']}');
      print('活跃服务数: ${stats['active_services']}');
      print('非活跃服务数: ${stats['inactive_services']}');
      print('平均评分: ${stats['average_rating']}');
      print('最后更新: ${stats['last_updated']}');

      Get.snackbar(
        '测试成功',
        '获取到服务统计信息',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ 测试获取统计信息失败: $e');
      Get.snackbar(
        '测试失败',
        '获取统计信息失败: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 测试搜索服务
  void _testSearchServices() async {
    try {
      print('=== 开始测试搜索服务 ===');

      final serviceManager = ServiceManager.instance;
      if (!serviceManager.isInitialized) {
        print('❌ ServiceManager未初始化');
        Get.snackbar(
          '测试失败',
          'ServiceManager未初始化',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final params = core_services.ServiceQueryParams(
        searchQuery: 'restaurant',
        limit: 3,
        sortBy: 'rating',
        sortAscending: false,
      );

      final result =
          await serviceManager.serviceQueryService.searchServices(params);

      print('✅ 搜索服务成功');
      print('找到 ${result.services.length} 个服务');
      print('总数: ${result.totalCount}');
      print('当前页: ${result.currentPage}');
      print('总页数: ${result.totalPages}');
      print('是否有更多: ${result.hasMore}');

      for (int i = 0; i < result.services.length; i++) {
        final service = result.services[i];
        print('搜索结果 ${i + 1}:');
        print('  标题: ${service.getLocalizedTitle('en')}');
        print('  价格: ${service.priceDisplay}');
        print('  评分: ${service.ratingDisplay}');
        print('  ---');
      }

      Get.snackbar(
        '测试成功',
        '搜索服务成功，找到 ${result.services.length} 个结果',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ 测试搜索服务失败: $e');
      Get.snackbar(
        '测试失败',
        '搜索服务失败: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 测试按分类获取服务
  void _testGetServicesByCategory() async {
    try {
      print('=== 开始测试按分类获取服务 ===');

      final serviceManager = ServiceManager.instance;
      if (!serviceManager.isInitialized) {
        print('❌ ServiceManager未初始化');
        Get.snackbar(
          '测试失败',
          'ServiceManager未初始化',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // 使用一个可能存在的分类ID进行测试
      final categoryId = '1060000'; // 生活帮忙分类
      final services = await serviceManager.serviceQueryService
          .getServicesByCategory(categoryId, limit: 3);

      print('✅ 按分类获取服务成功');
      print('分类ID: $categoryId');
      print('找到 ${services.length} 个服务');

      for (int i = 0; i < services.length; i++) {
        final service = services[i];
        print('分类服务 ${i + 1}:');
        print('  标题: ${service.getLocalizedTitle('en')}');
        print('  价格: ${service.priceDisplay}');
        print('  评分: ${service.ratingDisplay}');
        print('  ---');
      }

      Get.snackbar(
        '测试成功',
        '按分类获取服务成功，找到 ${services.length} 个结果',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ 测试按分类获取服务失败: $e');
      Get.snackbar(
        '测试失败',
        '按分类获取服务失败: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
