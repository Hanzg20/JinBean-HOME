import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/services.dart';

// 测试动态Tab配置服务的页面
class TestDynamicTabPage extends StatefulWidget {
  const TestDynamicTabPage({Key? key}) : super(key: key);

  @override
  State<TestDynamicTabPage> createState() => _TestDynamicTabPageState();
}

class _TestDynamicTabPageState extends State<TestDynamicTabPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late DynamicTabConfigService _dynamicTabService;
  
  // 模拟服务数据
  late Service _mockService;
  late List<ServiceDetail> _mockDetails;
  
  List<Map<String, dynamic>> _tabConfig = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // 创建模拟服务数据
    _mockService = Service(
      id: 'test-service-001',
      title: {'en': 'Test Service', 'zh': '测试服务'},
      description: {'en': 'A test service for dynamic tab configuration', 'zh': '用于测试动态Tab配置的测试服务'},
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
      images: ['test_image_1.jpg'],
      imagesUrl: ['https://example.com/test_image_1.jpg'],
      rating: 4.5,
      reviewCount: 25,
      isActive: true,
      serviceDetailsJson: null,
      latitude: 43.6532,
      longitude: -79.3832,
      serviceAreaCodes: ['M5V'],
      tags: ['test', 'demo'],
    );

    // 创建模拟服务详情数据
    _mockDetails = [
      ServiceDetail(
        id: 'detail-001',
        serviceId: 'test-service-001',
        category: 'restaurant',
        name: {'en': 'Italian Pasta', 'zh': '意大利面'},
        subCategory: 'main_course',
        isAvailable: true,
        sortOrder: 1,
        currentStock: 50,
        maxStock: 100,
        attributes: {'cuisine': 'Italian', 'spice_level': 'mild'},
        businessRules: {'min_order': 1, 'max_order': 10},
        pricingType: 'fixed',
        price: 15.99,
        currency: 'USD',
        duration: 30,
        unit: 'minutes',
        images: ['pasta_1.jpg'],
        videos: [],
        tags: ['pasta', 'Italian'],
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
        serviceId: 'test-service-001',
        category: 'cleaning',
        name: {'en': 'Deep Cleaning', 'zh': '深度清洁'},
        subCategory: 'service',
        isAvailable: true,
        sortOrder: 3,
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

    _generateTabConfig();
  }

  void _generateTabConfig() {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      _dynamicTabService = DynamicTabConfigService();
      _tabConfig = _dynamicTabService.getTabConfig(_mockService, _mockDetails);
      
      // 初始化TabController
      _tabController = TabController(
        length: _tabConfig.length,
        vsync: this,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      print('生成的Tab配置: $_tabConfig');
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      print('生成Tab配置失败: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('测试动态Tab配置'),
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
                        onPressed: _generateTabConfig,
                        child: Text('重试'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Tab配置信息
                    Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.grey[100],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tab配置信息',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SizedBox(height: 8),
                          Text('服务: ${_mockService.getLocalizedTitle('en')}'),
                          Text('分类: ${_mockService.categoryId}'),
                          Text('Tab数量: ${_tabConfig.length}'),
                        ],
                      ),
                    ),
                    
                    // Tab栏
                    Container(
                      color: Colors.white,
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabs: _tabConfig.map((tab) {
                          return Tab(
                            icon: Icon(
                              tab['icon'] as IconData,
                              color: tab['color'] as Color,
                            ),
                            text: tab['title'] as String,
                          );
                        }).toList(),
                      ),
                    ),
                    
                    // Tab内容
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: _tabConfig.asMap().entries.map((entry) {
                          final index = entry.key;
                          final tab = entry.value;
                          
                          return _buildTabContent(tab, index);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generateTabConfig,
        child: Icon(Icons.refresh),
        tooltip: '重新生成Tab配置',
      ),
    );
  }

  Widget _buildTabContent(Map<String, dynamic> tab, int index) {
    final tabId = tab['id'] as String;
    
    // 使用DynamicTabConfigService的内容构建器
    final contentBuilder = _dynamicTabService.getTabContentBuilder(_mockService, _mockDetails);
    
    return contentBuilder(context, index);
  }
}
