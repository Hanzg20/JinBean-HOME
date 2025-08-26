import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/services.dart';

// 测试新服务架构集成的页面
class TestIntegrationPage extends StatefulWidget {
  const TestIntegrationPage({Key? key}) : super(key: key);

  @override
  State<TestIntegrationPage> createState() => _TestIntegrationPageState();
}

class _TestIntegrationPageState extends State<TestIntegrationPage> {
  late ServiceManager _serviceManager;
  late DynamicTabConfigService _dynamicTabService;
  
  bool _isInitialized = false;
  bool _isLoading = false;
  String _errorMessage = '';
  
  // 测试数据
  List<Service> _testServices = [];
  List<ServiceDetail> _testServiceDetails = [];
  
  // 测试结果
  Map<String, dynamic> _testResults = {};

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      _serviceManager = ServiceManager.instance;
      _dynamicTabService = DynamicTabConfigService();
      
      // 初始化服务管理器
      if (!_serviceManager.isInitialized) {
        await _serviceManager.initializeServices();
      }
      
      // 创建测试数据
      await _createTestData();
      
      // 运行测试
      await _runIntegrationTests();
      
      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
      
      print('服务架构集成测试完成 ✅');
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      print('服务架构集成测试失败 ❌ - $e');
    }
  }

  Future<void> _createTestData() async {
    // 创建测试服务
    _testServices = [
      Service(
        id: 'test-service-001',
        title: {'en': 'Italian Restaurant', 'zh': '意大利餐厅'},
        description: {'en': 'Authentic Italian cuisine', 'zh': '正宗意大利美食'},
        price: 99.99,
        currency: 'USD',
        pricingType: 'fixed',
        categoryId: 'restaurant',
        categoryLevel1Id: '1060000',
        categoryLevel2Id: '1060100',
        providerId: 'test-provider-001',
        serviceDeliveryMethod: 'onsite',
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        images: ['restaurant_1.jpg'],
        imagesUrl: ['https://example.com/restaurant_1.jpg'],
        rating: 4.5,
        reviewCount: 25,
        isActive: true,
        serviceDetailsJson: null,
        latitude: 43.6532,
        longitude: -79.3832,
        serviceAreaCodes: ['M5V'],
        tags: ['Italian', 'restaurant', 'food'],
      ),
      Service(
        id: 'test-service-002',
        title: {'en': 'Professional Cleaning', 'zh': '专业清洁'},
        description: {'en': 'Professional home cleaning service', 'zh': '专业家居清洁服务'},
        price: 150.00,
        currency: 'USD',
        pricingType: 'hourly',
        categoryId: 'cleaning',
        categoryLevel1Id: '1060000',
        categoryLevel2Id: '1060200',
        providerId: 'test-provider-002',
        serviceDeliveryMethod: 'onsite',
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        images: ['cleaning_1.jpg'],
        imagesUrl: ['https://example.com/cleaning_1.jpg'],
        rating: 4.8,
        reviewCount: 18,
        isActive: true,
        serviceDetailsJson: null,
        latitude: 43.6532,
        longitude: -79.3832,
        serviceAreaCodes: ['M5V'],
        tags: ['cleaning', 'professional', 'home'],
      ),
    ];

    // 创建测试服务详情
    _testServiceDetails = [
      ServiceDetail(
        id: 'detail-001',
        serviceId: 'test-service-001',
        category: 'restaurant',
        name: {'en': 'Margherita Pizza', 'zh': '玛格丽特披萨'},
        subCategory: 'main_course',
        isAvailable: true,
        sortOrder: 1,
        currentStock: 50,
        maxStock: 100,
        attributes: {'cuisine': 'Italian', 'spice_level': 'mild'},
        businessRules: {'min_order': 1, 'max_order': 10},
        pricingType: 'fixed',
        price: 18.99,
        currency: 'USD',
        duration: 25,
        unit: 'minutes',
        images: ['pizza_1.jpg'],
        videos: [],
        tags: ['pizza', 'Italian'],
        serviceAreaCodes: ['M5V'],
        platformServiceFeeRate: 0.05,
        minPlatformServiceFee: 0.50,
        extraData: null,
        promotionStart: null,
        promotionEnd: null,
        viewCount: 150,
        favoriteCount: 25,
        orderCount: 75,
        verificationStatus: 'verified',
        documents: [],
        type: 'food',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceDetail(
        id: 'detail-002',
        serviceId: 'test-service-001',
        category: 'restaurant',
        name: {'en': 'Caesar Salad', 'zh': '凯撒沙拉'},
        subCategory: 'appetizer',
        isAvailable: true,
        sortOrder: 2,
        currentStock: 30,
        maxStock: 60,
        attributes: {'diet': 'vegetarian', 'allergens': ['nuts']},
        businessRules: {'min_order': 1, 'max_order': 5},
        pricingType: 'fixed',
        price: 12.99,
        currency: 'USD',
        duration: 15,
        unit: 'minutes',
        images: ['salad_1.jpg'],
        videos: [],
        tags: ['salad', 'healthy'],
        serviceAreaCodes: ['M5V'],
        platformServiceFeeRate: 0.05,
        minPlatformServiceFee: 0.50,
        extraData: null,
        promotionStart: null,
        promotionEnd: null,
        viewCount: 120,
        favoriteCount: 18,
        orderCount: 45,
        verificationStatus: 'verified',
        documents: [],
        type: 'food',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceDetail(
        id: 'detail-003',
        serviceId: 'test-service-002',
        category: 'cleaning',
        name: {'en': 'Deep Cleaning', 'zh': '深度清洁'},
        subCategory: 'service',
        isAvailable: true,
        sortOrder: 1,
        currentStock: 10,
        maxStock: 20,
        attributes: {'area': '100sqm', 'duration': '2 hours'},
        businessRules: {'advance_booking': 24, 'cancellation': 2},
        pricingType: 'hourly',
        price: 25.00,
        currency: 'USD',
        duration: 2,
        unit: 'hours',
        images: ['cleaning_1.jpg'],
        videos: [],
        tags: ['cleaning', 'professional'],
        serviceAreaCodes: ['M5V'],
        platformServiceFeeRate: 0.08,
        minPlatformServiceFee: 1.00,
        extraData: null,
        promotionStart: null,
        promotionEnd: null,
        viewCount: 80,
        favoriteCount: 12,
        orderCount: 30,
        verificationStatus: 'verified',
        documents: [],
        type: 'service',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  Future<void> _runIntegrationTests() async {
    _testResults.clear();
    
    try {
      // 测试1: 服务管理器初始化
      _testResults['service_manager'] = {
        'status': _serviceManager.isInitialized ? 'success' : 'failed',
        'message': _serviceManager.isInitialized ? '服务管理器初始化成功' : '服务管理器初始化失败',
        'details': _serviceManager.getServiceStatus(),
      };

      // 测试2: 动态Tab配置服务
      if (_testServices.isNotEmpty && _testServiceDetails.isNotEmpty) {
        final testService = _testServices[0];
        final testDetails = _testServiceDetails.where((d) => d.serviceId == testService.id).toList();
        
        final tabConfig = _dynamicTabService.getTabConfig(testService, testDetails);
        
        _testResults['dynamic_tab_config'] = {
          'status': 'success',
          'message': '动态Tab配置生成成功',
          'details': {
            'service_name': testService.getLocalizedTitle('en'),
            'service_category': testService.categoryId,
            'tab_count': tabConfig.length,
            'tabs': tabConfig.map((tab) => tab['title']).toList(),
          },
        };
      }

      // 测试3: 服务查询服务
      if (_serviceManager.serviceQueryService != null) {
        try {
          final services = await _serviceManager.serviceQueryService!.getRecommendedServices();
          _testResults['service_query'] = {
            'status': 'success',
            'message': '服务查询成功',
            'details': {
              'recommended_count': services.length,
              'services': services.take(3).map((s) => s.getLocalizedTitle('en')).toList(),
            },
          };
        } catch (e) {
          _testResults['service_query'] = {
            'status': 'failed',
            'message': '服务查询失败: $e',
            'details': null,
          };
        }
      }

      // 测试4: 服务详情服务
      if (_serviceManager.serviceDetailService != null) {
        try {
          final details = await _serviceManager.serviceDetailService!.getServiceDetails('test-service-001');
          _testResults['service_detail'] = {
            'status': 'success',
            'message': '服务详情查询成功',
            'details': {
              'details_count': details.length,
              'categories': details.map((d) => d.category).toSet().toList(),
            },
          };
        } catch (e) {
          _testResults['service_detail'] = {
            'status': 'failed',
            'message': '服务详情查询失败: $e',
            'details': null,
          };
        }
      }

      // 测试5: 认证服务
      if (_serviceManager.authService != null) {
        try {
          final isAuthenticated = await _serviceManager.authService!.isAuthenticated();
          _testResults['authentication'] = {
            'status': 'success',
            'message': '认证服务可用',
            'details': {
              'is_authenticated': isAuthenticated,
            },
          };
        } catch (e) {
          _testResults['authentication'] = {
            'status': 'failed',
            'message': '认证服务测试失败: $e',
            'details': null,
          };
        }
      }

      // 测试6: 服务商服务
      if (_serviceManager.providerService != null) {
        try {
          final providers = await _serviceManager.providerService!.getProviders(
            core_services.ProviderQueryParams(limit: 5)
          );
          _testResults['provider'] = {
            'status': 'success',
            'message': '服务商服务可用',
            'details': {
              'providers_count': providers.length,
              'sample_providers': providers.take(3).map((p) => p.displayName['en'] ?? 'Unknown').toList(),
            },
          };
        } catch (e) {
          _testResults['provider'] = {
            'status': 'failed',
            'message': '服务商服务测试失败: $e',
            'details': null,
          };
        }
      }

    } catch (e) {
      _testResults['integration_test'] = {
        'status': 'failed',
        'message': '集成测试失败: $e',
        'details': null,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('服务架构集成测试'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('错误: $_errorMessage'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeServices,
                        child: Text('重试'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 测试状态概览
                      _buildTestOverview(),
                      SizedBox(height: 24),
                      
                      // 详细测试结果
                      _buildDetailedResults(),
                      SizedBox(height: 24),
                      
                      // 测试数据展示
                      _buildTestDataDisplay(),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _runIntegrationTests,
        child: Icon(Icons.refresh),
        tooltip: '重新运行测试',
      ),
    );
  }

  Widget _buildTestOverview() {
    final successCount = _testResults.values.where((r) => r['status'] == 'success').length;
    final totalCount = _testResults.length;
    final successRate = totalCount > 0 ? (successCount / totalCount * 100).round() : 0;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '集成测试概览',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  successRate >= 80 ? Icons.check_circle : 
                  successRate >= 60 ? Icons.warning : Icons.error,
                  color: successRate >= 80 ? Colors.green : 
                         successRate >= 60 ? Colors.orange : Colors.red,
                  size: 32,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '成功率: $successRate%',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text('成功: $successCount / 总数: $totalCount'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedResults() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '详细测试结果',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            ..._testResults.entries.map((entry) {
              final testName = entry.key;
              final result = entry.value;
              final isSuccess = result['status'] == 'success';
              
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSuccess ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSuccess ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isSuccess ? Icons.check_circle : Icons.error,
                          color: isSuccess ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          _getTestName(testName),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(result['message']),
                    if (result['details'] != null) ...[
                      SizedBox(height: 8),
                      Text(
                        '详情: ${result['details']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTestDataDisplay() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '测试数据',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            
            // 测试服务
            Text(
              '测试服务 (${_testServices.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            ..._testServices.map((service) => ListTile(
              title: Text(service.getLocalizedTitle('en')),
              subtitle: Text('分类: ${service.categoryId}'),
              trailing: Text('\$${service.price}'),
            )),
            
            SizedBox(height: 16),
            
            // 测试服务详情
            Text(
              '测试服务详情 (${_testServiceDetails.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            ..._testServiceDetails.map((detail) => ListTile(
              title: Text(detail.getLocalizedName('en')),
              subtitle: Text('分类: ${detail.category}'),
              trailing: Text('\$${detail.price}'),
            )),
          ],
        ),
      ),
    );
  }

  String _getTestName(String key) {
    switch (key) {
      case 'service_manager':
        return '服务管理器';
      case 'dynamic_tab_config':
        return '动态Tab配置';
      case 'service_query':
        return '服务查询';
      case 'service_detail':
        return '服务详情';
      case 'authentication':
        return '认证服务';
      case 'provider':
        return '服务商服务';
      default:
        return key;
    }
  }
}
