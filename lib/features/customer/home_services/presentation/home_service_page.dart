import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/models/base_models.dart';
import '../../../../core/models/order_models.dart';
import '../../../../core/controllers/universal_order_controller.dart';
import '../../../../core/services/address_service.dart';
import '../../../../core/utils/app_logger.dart';
import 'widgets/home_service_categories_widget.dart';
import 'widgets/home_service_providers_widget.dart';
import 'widgets/home_service_booking_widget.dart';

/// 家居服务页面
/// 
/// 基于通用模型系统构建的家居服务界面
/// 支持完整的家居服务预订流程：浏览服务 → 选择提供商 → 预订服务 → 支付
class HomeServicePage extends StatefulWidget {
  final String? categoryId;
  final String? serviceId;
  final String? source;

  const HomeServicePage({
    super.key,
    this.categoryId,
    this.serviceId,
    this.source,
  });

  @override
  State<HomeServicePage> createState() => _HomeServicePageState();
}

class _HomeServicePageState extends State<HomeServicePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController();
  
  late final UniversalOrderController _orderController;
  late final AddressService _addressService;
  
  // 服务预订相关状态
  final RxList<OrderItemRequest> _selectedServices = <OrderItemRequest>[].obs;
  final RxDouble _totalCost = 0.0.obs;
  final Rx<Address?> _serviceAddress = Rx<Address?>(null);
  final RxString _serviceNotes = ''.obs;
  final RxString _selectedCategory = ''.obs;
  final RxString _selectedProvider = ''.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeServices();
    _initializePage();
  }
  
  void _initializeServices() {
    try {
      _orderController = Get.find<UniversalOrderController>();
    } catch (e) {
      _orderController = Get.put(UniversalOrderController());
    }
    
    try {
      _addressService = Get.find<AddressService>();
    } catch (e) {
      _addressService = Get.put(AddressService());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _initializePage() {
    AppLogger.info('🏠 初始化家居服务页面');
    
    // 设置行业过滤
    _orderController.setIndustryFilter(IndustryType.home);
    
    // 设置初始分类
    if (widget.categoryId != null) {
      _selectedCategory.value = widget.categoryId!;
    }
    
    // 加载用户地址
    _loadUserAddresses();
    
    // 加载用户的历史订单
    _orderController.loadOrders(refresh: true);
  }

  Future<void> _loadUserAddresses() async {
    try {
      await _addressService.getUserAddresses();
      final defaultAddress = _addressService.getDefaultAddress();
      if (defaultAddress != null) {
        _serviceAddress.value = defaultAddress;
      }
    } catch (e) {
      AppLogger.error('🏠 加载用户地址失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('家居服务'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home_repair_service), text: '服务分类'),
            Tab(icon: Icon(Icons.person), text: '服务商'),
            Tab(icon: Icon(Icons.calendar_today), text: '预订'),
          ],
        ),
        actions: [
          // 服务购物车图标和数量
          Obx(() => Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_basket),
                onPressed: () => _tabController.animateTo(2),
              ),
              if (_selectedServices.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_selectedServices.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          )),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 服务分类页面
          HomeServiceCategoriesWidget(
            selectedCategory: _selectedCategory,
            onCategorySelected: _onCategorySelected,
            onServiceSelected: _onServiceSelected,
          ),
          
          // 服务商页面
          HomeServiceProvidersWidget(
            categoryId: _selectedCategory.value,
            selectedProvider: _selectedProvider,
            onProviderSelected: _onProviderSelected,
          ),
          
          // 预订页面
          HomeServiceBookingWidget(
            selectedServices: _selectedServices,
            totalCost: _totalCost,
            serviceAddress: _serviceAddress,
            serviceNotes: _serviceNotes,
            onAddressChanged: _onAddressChanged,
            onNotesChanged: _onNotesChanged,
            onRemoveService: _onRemoveService,
            onProceedToPayment: _onProceedToPayment,
          ),
        ],
      ),
      
      // 底部操作栏
      bottomNavigationBar: Obx(() => _buildBottomActionBar()),
    );
  }

  Widget _buildBottomActionBar() {
    if (_selectedServices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '已选服务: ${_selectedServices.length}项',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                '总计: \$${_totalCost.value.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => _tabController.animateTo(2),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('立即预订'),
          ),
        ],
      ),
    );
  }

  // ========================================
  // 事件处理方法
  // ========================================

  void _onCategorySelected(String categoryId) {
    AppLogger.info('🏠 选择服务分类: $categoryId');
    _selectedCategory.value = categoryId;
    
    // 自动切换到服务商页面
    Future.delayed(const Duration(milliseconds: 300), () {
      _tabController.animateTo(1);
    });
  }

  void _onServiceSelected(OrderItemRequest serviceItem) {
    AppLogger.info('🏠 选择服务: ${serviceItem.name}');
    
    // 检查是否已经添加过相同服务
    final existingIndex = _selectedServices.indexWhere(
      (item) => item.serviceDetailId == serviceItem.serviceDetailId,
    );

    if (existingIndex != -1) {
      // 如果已存在，增加数量
      final existingItem = _selectedServices[existingIndex];
      final updatedItem = OrderItemRequest(
        serviceDetailId: existingItem.serviceDetailId,
        name: existingItem.name,
        description: existingItem.description,
        quantity: existingItem.quantity + 1,
        unitPrice: existingItem.unitPrice,
        options: existingItem.options,
        customizations: existingItem.customizations,
        specialInstructions: existingItem.specialInstructions,
      );
      _selectedServices[existingIndex] = updatedItem;
    } else {
      // 如果不存在，添加新服务
      _selectedServices.add(serviceItem);
    }

    _updateTotalCost();
    
    // 显示添加成功提示
    Get.snackbar(
      '服务已添加',
      '${serviceItem.name} 已添加到预订列表',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green,
      duration: const Duration(seconds: 2),
    );
  }

  void _onProviderSelected(String providerId) {
    AppLogger.info('🏠 选择服务商: $providerId');
    _selectedProvider.value = providerId;
  }

  void _onAddressChanged(Address address) {
    AppLogger.info('🏠 更改服务地址: ${address.shortAddress}');
    _serviceAddress.value = address;
  }

  void _onNotesChanged(String notes) {
    _serviceNotes.value = notes;
  }

  void _onRemoveService(int index) {
    if (index >= 0 && index < _selectedServices.length) {
      final removedService = _selectedServices[index];
      _selectedServices.removeAt(index);
      _updateTotalCost();
      
      AppLogger.info('🏠 移除服务: ${removedService.name}');
      
      Get.snackbar(
        '服务已移除',
        '${removedService.name} 已从预订列表中移除',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _updateTotalCost() {
    double total = 0.0;
    for (final service in _selectedServices) {
      total += service.unitPrice * service.quantity;
    }
    _totalCost.value = total;
  }

  Future<void> _onProceedToPayment() async {
    if (_selectedServices.isEmpty) {
      Get.snackbar(
        '无法继续',
        '请先选择要预订的服务',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    if (_serviceAddress.value == null) {
      Get.snackbar(
        '无法继续',
        '请先选择服务地址',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      AppLogger.info('🏠 开始创建家居服务订单');

      // 创建订单请求
      final orderRequest = OrderRequest(
        serviceId: 'home_service_${const Uuid().v4()}',
        providerId: _selectedProvider.value.isNotEmpty 
            ? _selectedProvider.value 
            : 'default_provider',
        industry: IndustryType.home,
        orderType: 'service',
        items: _selectedServices.toList(),
        serviceAddress: _serviceAddress.value!,
        customerNotes: _serviceNotes.value,
      );

      // 使用UniversalOrderController创建订单
      final createdOrder = await _orderController.createOrder(orderRequest);

      if (createdOrder != null) {
        AppLogger.info('🏠 家居服务订单创建成功: ${createdOrder.id}');
        
        // 导航到支付页面
        Get.toNamed('/payment', arguments: {
          'orderId': createdOrder.id,
          'amount': _totalCost.value,
          'currency': 'CAD',
          'orderType': 'home_service',
        });
        
        // 清空当前选择
        _selectedServices.clear();
        _totalCost.value = 0.0;
        _serviceNotes.value = '';
        
      } else {
        throw Exception('订单创建失败');
      }

    } catch (e) {
      AppLogger.error('🏠 创建家居服务订单失败: $e');
      
      Get.snackbar(
        '订单创建失败',
        '无法创建订单，请稍后重试: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
