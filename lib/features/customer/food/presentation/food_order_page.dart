import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/models/base_models.dart';
import '../../../../core/models/order_models.dart';
import '../../../../core/models/payment_models.dart';
import '../../../../core/controllers/universal_order_controller.dart';
import 'widgets/food_menu_widget.dart';
import 'widgets/food_cart_widget.dart';
import 'widgets/food_checkout_widget.dart';
import 'widgets/food_payment_widget.dart';

/// 餐饮订单页面
/// 
/// 基于通用模型系统构建的餐饮订单界面
/// 支持完整的餐饮订购流程：浏览菜单 → 添加到购物车 → 结算 → 支付
class FoodOrderPage extends StatefulWidget {
  final String serviceId;
  final String providerId;

  const FoodOrderPage({
    super.key,
    required this.serviceId,
    required this.providerId,
  });

  @override
  State<FoodOrderPage> createState() => _FoodOrderPageState();
}

class _FoodOrderPageState extends State<FoodOrderPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController();
  
  late final UniversalOrderController _orderController;
  
  // 购物车相关状态
  final RxList<OrderItemRequest> _cartItems = <OrderItemRequest>[].obs;
  final RxDouble _cartTotal = 0.0.obs;
  final Rx<Address?> _deliveryAddress = Rx<Address?>(null);
  final RxString _customerNotes = ''.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeController();
    _initializePage();
  }

  /// 安全初始化控制器
  void _initializeController() {
    try {
      if (Get.isRegistered<UniversalOrderController>()) {
        _orderController = Get.find<UniversalOrderController>();
      } else {
        // 如果控制器未注册，则注册它
        _orderController = Get.put(UniversalOrderController(), permanent: true);
      }
    } catch (e) {
      // 如果仍然失败，创建一个新实例
      _orderController = Get.put(UniversalOrderController(), permanent: true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _initializePage() {
    // 设置行业过滤
    _orderController.setIndustryFilter(IndustryType.food);
    
    // 加载用户的历史订单
    _orderController.loadOrders(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('美食订餐'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.restaurant_menu), text: '菜单'),
            Tab(icon: Icon(Icons.shopping_cart), text: '购物车'),
            Tab(icon: Icon(Icons.payment), text: '结算'),
          ],
        ),
        actions: [
          // 购物车图标和数量
          Obx(() => Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => _tabController.animateTo(1),
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_cartItems.length}',
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
      body: Column(
        children: [
          // 配送地址栏
          _buildDeliveryAddressBar(),
          
          // 主内容区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 菜单页面
                FoodMenuWidget(
                  serviceId: widget.serviceId,
                  providerId: widget.providerId,
                  onAddToCart: _addToCart,
                  onRemoveFromCart: _removeFromCart,
                  cartItems: _cartItems,
                ),
                
                // 购物车页面
                FoodCartWidget(
                  cartItems: _cartItems,
                  onUpdateQuantity: _updateCartItemQuantity,
                  onRemoveItem: _removeFromCart,
                  onUpdateNotes: (notes) => _customerNotes.value = notes,
                  onProceedToCheckout: () => _tabController.animateTo(2),
                ),
                
                // 结算页面
                FoodCheckoutWidget(
                  serviceId: widget.serviceId,
                  providerId: widget.providerId,
                  cartItems: _cartItems,
                  deliveryAddress: _deliveryAddress.value,
                  customerNotes: _customerNotes.value,
                  onAddressChanged: (address) => _deliveryAddress.value = address,
                  onPlaceOrder: _placeOrder,
                ),
              ],
            ),
          ),
          
          // 底部购物车摘要
          _buildCartSummaryBar(),
        ],
      ),
    );
  }

  /// 配送地址栏
  Widget _buildDeliveryAddressBar() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: _deliveryAddress.value != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '配送地址',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        _deliveryAddress.value!.fullAddress,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                : const Text(
                    '请设置配送地址',
                    style: TextStyle(color: Colors.grey),
                  ),
          ),
          TextButton(
            onPressed: _showAddressDialog,
            child: Text(_deliveryAddress.value != null ? '更改' : '设置'),
          ),
        ],
      ),
    ));
  }

  /// 底部购物车摘要栏
  Widget _buildCartSummaryBar() {
    return Obx(() {
      if (_cartItems.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -2),
              blurRadius: 8,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '共${_cartItems.length}件商品',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '\$${_cartTotal.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _cartItems.isNotEmpty
                    ? () => _tabController.animateTo(2)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('去结算'),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ========================================
  // 购物车操作
  // ========================================

  /// 添加到购物车
  void _addToCart(OrderItemRequest item) {
    // 检查是否已存在相同商品
    final existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.serviceDetailId == item.serviceDetailId &&
                   _areCustomizationsEqual(cartItem.customizations, item.customizations),
    );

    if (existingIndex >= 0) {
      // 更新数量
      final existingItem = _cartItems[existingIndex];
      _cartItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + item.quantity,
      );
    } else {
      // 添加新商品
      _cartItems.add(item);
    }

    _updateCartTotal();
    
    // 显示添加成功提示
    Get.snackbar(
      '添加成功',
      '${item.name} 已添加到购物车',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// 从购物车移除
  void _removeFromCart(String serviceDetailId, [Map<String, dynamic>? customizations]) {
    _cartItems.removeWhere((item) => 
        item.serviceDetailId == serviceDetailId &&
        (customizations == null || _areCustomizationsEqual(item.customizations, customizations)));
    
    _updateCartTotal();
  }

  /// 更新购物车商品数量
  void _updateCartItemQuantity(String serviceDetailId, int newQuantity, [Map<String, dynamic>? customizations]) {
    final index = _cartItems.indexWhere((item) => 
        item.serviceDetailId == serviceDetailId &&
        (customizations == null || _areCustomizationsEqual(item.customizations, customizations)));
    
    if (index >= 0) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
      }
      _updateCartTotal();
    }
  }

  /// 更新购物车总价
  void _updateCartTotal() {
    double total = 0.0;
    for (final item in _cartItems) {
      total += item.totalPrice;
    }
    _cartTotal.value = total;
  }

  /// 比较定制选项是否相等
  bool _areCustomizationsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) {
        return false;
      }
    }
    
    return true;
  }

  // ========================================
  // 地址管理
  // ========================================

  /// 显示地址设置对话框
  void _showAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddressDialog(
        currentAddress: _deliveryAddress.value,
        onAddressSelected: (address) => _deliveryAddress.value = address,
      ),
    );
  }

  // ========================================
  // 下单流程
  // ========================================

  /// 下单
  Future<void> _placeOrder() async {
    try {
      // 验证必要信息
      if (_cartItems.isEmpty) {
        Get.snackbar('错误', '购物车为空');
        return;
      }

      if (_deliveryAddress.value == null) {
        Get.snackbar('错误', '请设置配送地址');
        return;
      }

      // 创建订单请求
      final orderRequest = OrderRequest(
        serviceId: widget.serviceId,
        providerId: widget.providerId,
        industry: IndustryType.food,
        orderType: 'instant',
        items: _cartItems.toList(),
        serviceAddress: _deliveryAddress.value,
        customerNotes: _customerNotes.value.isNotEmpty ? _customerNotes.value : null,
        industrySpecificData: Configuration({
          'restaurant_id': widget.providerId,
          'delivery_type': 'standard',
          'estimated_delivery_time': '30-45 minutes',
        }),
      );

      // 先计算价格
      await _orderController.calculateOrderPrice(orderRequest);
      
      final pricing = _orderController.pricingResult.value;
      if (pricing == null) {
        Get.snackbar('错误', '价格计算失败');
        return;
      }

      // 显示价格确认对话框
      final confirmed = await _showPriceConfirmationDialog(pricing);
      if (!confirmed) return;

      // 创建订单
      final order = await _orderController.createOrder(orderRequest);
      if (order != null) {
        // 清空购物车
        _cartItems.clear();
        _updateCartTotal();

        // 跳转到支付页面
        Get.to(() => FoodPaymentWidget(
          order: order,
          onPaymentSuccess: () {
            // 支付成功后的处理
            Get.back(); // 返回到上一页
            Get.snackbar('订单成功', '订单已确认，正在处理中...');
          },
          onPaymentFailed: () {
            // 支付失败后的处理
            print('支付失败');
          },
        ));
      }

    } catch (e) {
      Get.snackbar('下单失败', e.toString());
    }
  }

  /// 显示价格确认对话框
  Future<bool> _showPriceConfirmationDialog(PricingResult pricing) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认订单'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('商品总价: ${pricing.baseAmount.formatted}'),
            ...pricing.fees.map((fee) => Text('${fee.name}: ${fee.amount.formatted}')),
            if (pricing.discounts.isNotEmpty)
              ...pricing.discounts.map((discount) => Text('${discount.name}: -${discount.amount.formatted}')),
            const Divider(),
            Text(
              '总计: ${pricing.totalAmount.formatted}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认下单'),
          ),
        ],
      ),
    ) ?? false;
  }
}

/// 地址设置对话框
class _AddressDialog extends StatefulWidget {
  final Address? currentAddress;
  final Function(Address) onAddressSelected;

  const _AddressDialog({
    this.currentAddress,
    required this.onAddressSelected,
  });

  @override
  State<_AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<_AddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.currentAddress != null) {
      final address = widget.currentAddress!;
      _streetController.text = address.streetName ?? '';
      _apartmentController.text = address.suiteUnit ?? '';
      _cityController.text = address.city ?? '';
      _provinceController.text = address.province ?? '';
      _postalCodeController.text = address.postalCode ?? '';
      _instructionsController.text = address.extra?['instructions'] ?? '';
    } else {
      // 设置默认值
      _cityController.text = 'Vancouver';
      _provinceController.text = 'BC';
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _apartmentController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('设置配送地址'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(
                  labelText: '街道地址 *',
                  hintText: '如：123 Main St',
                ),
                validator: (value) => value?.isEmpty == true ? '请输入街道地址' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _apartmentController,
                decoration: const InputDecoration(
                  labelText: '单元/楼层',
                  hintText: '如：Apt 2B, Floor 5',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: '城市 *'),
                      validator: (value) => value?.isEmpty == true ? '请输入城市' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _provinceController,
                      decoration: const InputDecoration(labelText: '省份 *'),
                      validator: (value) => value?.isEmpty == true ? '请输入省份' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(
                  labelText: '邮政编码 *',
                  hintText: '如：V6B 2W9',
                ),
                validator: (value) {
                  if (value?.isEmpty == true) return '请输入邮政编码';
                  // 简单的加拿大邮政编码验证
                  final regex = RegExp(r'^[A-Za-z]\d[A-Za-z] ?\d[A-Za-z]\d$');
                  if (!regex.hasMatch(value!)) return '邮政编码格式不正确';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: '配送说明',
                  hintText: '如：请按门铃，注意小狗',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _saveAddress,
          child: const Text('保存'),
        ),
      ],
    );
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final address = Address(
        id: const Uuid().v4(), // 生成新的 UUID
        streetName: _streetController.text.trim(),
        suiteUnit: _apartmentController.text.trim().isEmpty 
            ? null 
            : _apartmentController.text.trim(),
        city: _cityController.text.trim(),
        province: _provinceController.text.trim(),
        postalCode: _postalCodeController.text.trim().toUpperCase(),
        extra: _instructionsController.text.trim().isEmpty 
            ? null 
            : {'instructions': _instructionsController.text.trim()},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onAddressSelected(address);
      Navigator.of(context).pop();
    }
  }
}


