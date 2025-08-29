import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/services.dart';

// 服务架构测试页面
class TestServiceArchitecturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('服务架构测试'),
        backgroundColor: Colors.blue,
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

            // 服务初始化控制
            _buildServiceControlCard(),
            SizedBox(height: 20),

            // 数据模型测试
            _buildDataModelTestCard(),
            SizedBox(height: 20),

            // 接口测试
            _buildInterfaceTestCard(),
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
                color: Colors.blue[800],
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

  // 服务控制卡片
  Widget _buildServiceControlCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '服务控制',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ServiceManager.instance.initializeServices();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('初始化服务'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ServiceManager.instance.reinitializeServices();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('重新初始化'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final status =
                          await ServiceManager.instance.healthCheck();
                      Get.snackbar(
                        '健康检查',
                        status ? '服务正常' : '服务异常',
                        backgroundColor: status ? Colors.green : Colors.red,
                        colorText: Colors.white,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('健康检查'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final status = ServiceManager.instance.getServiceStatus();
                      print('服务状态: $status');
                      Get.snackbar(
                        '服务状态',
                        '状态已打印到控制台',
                        backgroundColor: Colors.blue,
                        colorText: Colors.white,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('获取状态'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 数据模型测试卡片
  Widget _buildDataModelTestCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '数据模型测试',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                _testServiceModel();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: Text('测试Service模型'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                _testServiceDetailModel();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: Text('测试ServiceDetail模型'),
            ),
          ],
        ),
      ),
    );
  }

  // 接口测试卡片
  Widget _buildInterfaceTestCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '接口测试',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 12),
            Text(
              '接口定义已完成，等待具体实现...',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• IAuthenticationService - 认证服务接口',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              '• IServiceQueryService - 服务查询接口',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              '• IServiceDetailService - 服务详情接口',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              '• IProviderService - 服务商接口',
              style: TextStyle(fontSize: 12),
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

  // 测试Service模型
  void _testServiceModel() {
    try {
      final service = core_services.Service(
        id: 'test-service-001',
        title: {'en': 'Test Service', 'zh': '测试服务'},
        description: {'en': 'This is a test service', 'zh': '这是一个测试服务'},
        price: 99.99,
        currency: 'CAD',
        pricingType: 'fixed_price',
        categoryId: 'test-category',
        categoryLevel1Id: 'test-level1',
        categoryLevel2Id: 'test-level2',
        providerId: 'test-provider',
        serviceDeliveryMethod: 'onsite',
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        images: ['https://example.com/image1.jpg'],
        imagesUrl: ['https://example.com/image1.jpg'],
        rating: 4.5,
        reviewCount: 10,
        isActive: true,
        serviceDetailsJson: {'test': 'data'},
        serviceAreaCodes: ['M5V'],
        tags: ['test', 'demo'],
      );

      print('Service模型测试成功 ✅');
      print('标题(英文): ${service.getLocalizedTitle('en')}');
      print('标题(中文): ${service.getLocalizedTitle('zh')}');
      print('价格: ${service.priceDisplay}');
      print('评分: ${service.ratingDisplay}');
      print('主要图片: ${service.mainImage}');

      Get.snackbar(
        '模型测试',
        'Service模型测试成功！',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Service模型测试失败: $e');
      Get.snackbar(
        '模型测试',
        'Service模型测试失败: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 测试ServiceDetail模型
  void _testServiceDetailModel() {
    try {
      final serviceDetail = core_services.ServiceDetail(
        id: 'test-detail-001',
        serviceId: 'test-service-001',
        category: 'test-category',
        name: {'en': 'Test Detail', 'zh': '测试详情'},
        isAvailable: true,
        sortOrder: 1,
        attributes: {'test_attr': 'test_value'},
        businessRules: {'test_rule': 'test_value'},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('ServiceDetail模型测试成功 ✅');
      print('名称(英文): ${serviceDetail.getLocalizedName('en')}');
      print('名称(中文): ${serviceDetail.getLocalizedName('zh')}');
      print('库存状态: ${serviceDetail.stockStatus}');
      print('是否有库存: ${serviceDetail.hasStock}');

      Get.snackbar(
        '模型测试',
        'ServiceDetail模型测试成功！',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('ServiceDetail模型测试失败: $e');
      Get.snackbar(
        '模型测试',
        'ServiceDetail模型测试失败: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
