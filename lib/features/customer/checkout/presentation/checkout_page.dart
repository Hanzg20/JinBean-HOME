import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/controllers/unified_cart_controller.dart';
import '../../../../core/controllers/universal_order_controller.dart';
import '../../../../core/services/address_service.dart';
import '../../../../core/models/base_models.dart';
import '../../../../core/models/cart_models.dart';
import '../../../../core/models/order_models.dart';

/// 结算页面
/// 
/// 提供完整的结算流程：地址选择、支付方式、订单确认
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late final UnifiedCartController _cartController;
  late final AddressService _addressService;
  
  final RxList<Address> _addresses = <Address>[].obs;
  final Rxn<Address> _selectedAddress = Rxn<Address>();
  final RxString _selectedPaymentMethod = 'credit_card'.obs;
  final RxString _orderNotes = ''.obs;
  final RxBool _isLoading = false.obs;
  
  // 从路由参数获取的数据
  List<CartItem> cartItems = [];
  double totalAmount = 0.0;
  double subtotal = 0.0;
  double taxAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initializeData();
    _loadAddresses();
  }

  void _initializeServices() {
    try {
      _cartController = Get.find<UnifiedCartController>();
    } catch (e) {
      _cartController = Get.put(UnifiedCartController());
    }
    
    try {
      _addressService = Get.find<AddressService>();
    } catch (e) {
      _addressService = Get.put(AddressService());
    }
  }

  void _initializeData() {
    // 从路由参数获取数据
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      cartItems = arguments['cartItems'] as List<CartItem>? ?? [];
      totalAmount = arguments['totalAmount'] as double? ?? 0.0;
      subtotal = arguments['subtotal'] as double? ?? 0.0;
      taxAmount = arguments['taxAmount'] as double? ?? 0.0;
    }
    
    // 如果没有参数，从购物车控制器获取
    if (cartItems.isEmpty) {
      cartItems = _cartController.cartItems.toList();
      subtotal = _cartController.totalAmount.value;
      taxAmount = subtotal * 0.13; // 13% HST
      totalAmount = subtotal + taxAmount;
    }
  }

  Future<void> _loadAddresses() async {
    try {
      _isLoading.value = true;
      final addresses = await _addressService.getUserAddresses();
      _addresses.value = addresses;
      
      // 自动选择默认地址
      final defaultAddress = addresses.firstWhereOrNull((addr) => addr.isDefault);
      if (defaultAddress != null) {
        _selectedAddress.value = defaultAddress;
      } else if (addresses.isNotEmpty) {
        _selectedAddress.value = addresses.first;
      }
    } catch (e) {
      Get.snackbar(
        '加载地址失败',
        '无法加载收货地址: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _submitOrder() async {
    if (_selectedAddress.value == null) {
      Get.snackbar(
        '请选择收货地址',
        '请先选择或添加收货地址',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      _isLoading.value = true;
      
      // 验证必要数据
      if (_selectedAddress.value == null) {
        throw Exception('请选择收货地址');
      }
      
      if (cartItems.isEmpty) {
        throw Exception('购物车为空');
      }
      
      // 真实订单提交
      List<Order> createdOrders = [];
      bool ordersCreated = false;
      
      try {
        print('🛒 开始创建订单...');
        // 调用购物车控制器的创建订单方法
        createdOrders = await _cartController.createOrdersFromCart();
        ordersCreated = createdOrders.isNotEmpty;
        
        if (!ordersCreated) {
          print('❌ 订单创建失败：没有创建任何订单');
          throw Exception('订单创建失败，请重试');
        }
        print('✅ 订单创建成功：创建了${createdOrders.length}个订单');
      } catch (orderError) {
        print('❌ 订单创建失败: $orderError');
        throw Exception('订单创建失败: ${orderError.toString()}');
      }
      
      // 显示成功消息
      print('🔍 [Checkout] 开始处理订单创建成功后的逻辑');
      print('🔍 [Checkout] createdOrders.length: ${createdOrders.length}');
      
      try {
        final orderNumbers = createdOrders.map((order) {
          print('🔍 [Checkout] 处理订单: ${order.id}');
          print('🔍 [Checkout] order.orderNumber: ${order.orderNumber}');
          return order.orderNumber;
        }).join(', ');
        
        print('🔍 [Checkout] orderNumbers: $orderNumbers');
        print('📱 显示成功消息：创建了${createdOrders.length}个订单');
        
        Get.snackbar(
          '订单提交成功',
          '创建了${createdOrders.length}个订单${orderNumbers.isNotEmpty ? '\\n订单号: $orderNumbers' : ''}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        print('✅ 成功消息显示完成');
      } catch (e) {
        print('❌ [Checkout] 处理订单号时出错: $e');
        print('❌ [Checkout] createdOrders: $createdOrders');
        rethrow;
      }
      
      // 等待UI更新完成，防止空指针异常
      await Future.delayed(const Duration(milliseconds: 200));
      
      // 确保UniversalOrderController可用
      try {
        print('🔍 [Checkout] 检查UniversalOrderController注册状态...');
        print('🔍 [Checkout] Get.isRegistered<UniversalOrderController>(): ${Get.isRegistered<UniversalOrderController>()}');
        
        if (!Get.isRegistered<UniversalOrderController>()) {
          print('⚠️ [Checkout] UniversalOrderController未注册，正在注册...');
          try {
            Get.put(UniversalOrderController(), permanent: true);
            print('✅ [Checkout] UniversalOrderController注册成功');
          } catch (putError) {
            print('❌ [Checkout] UniversalOrderController注册失败: $putError');
            throw putError;
          }
        } else {
          print('✅ [Checkout] UniversalOrderController已注册');
          try {
            final controller = Get.find<UniversalOrderController>();
            print('✅ [Checkout] UniversalOrderController实例获取成功: ${controller.runtimeType}');
          } catch (findError) {
            print('❌ [Checkout] UniversalOrderController实例获取失败: $findError');
            throw findError;
          }
        }
      } catch (e) {
        print('❌ [Checkout] UniversalOrderController初始化失败: $e');
        print('❌ [Checkout] 错误类型: ${e.runtimeType}');
        print('❌ [Checkout] 错误堆栈: ${e.toString()}');
        rethrow;
      }
      
      // 返回首页
      try {
        print('🏠 [Checkout] 准备跳转到首页...');
        print('🏠 [Checkout] 当前路由: ${Get.currentRoute}');
        print('🏠 [Checkout] 调用Get.offAllNamed("/main_shell")...');
        
        // 修复：使用正确的主界面路由
        Get.offAllNamed('/main_shell');
        
        print('✅ [Checkout] 首页跳转完成');
        print('✅ [Checkout] 跳转后路由: ${Get.currentRoute}');
      } catch (navigationError) {
        print('❌ [Checkout] 页面跳转失败: $navigationError');
        print('❌ [Checkout] 跳转错误类型: ${navigationError.runtimeType}');
        throw navigationError;
      }
      
    } catch (e) {
      print('❌ [Checkout] 订单提交过程中发生错误');
      print('❌ [Checkout] 错误类型: ${e.runtimeType}');
      print('❌ [Checkout] 错误信息: ${e.toString()}');
      print('❌ [Checkout] 错误堆栈: ${e is Error ? e.stackTrace : 'No stack trace available'}');
      
      // 检查是否是null check错误
      if (e.toString().contains('Null check operator used on a null value')) {
        print('🚨 [Checkout] 检测到Null check错误！');
        print('🚨 [Checkout] 这通常意味着某个变量为null但被强制访问');
      }
      
      Get.snackbar(
        '订单提交失败',
        '请稍后重试: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      print('🔚 [Checkout] 订单提交流程结束，设置loading为false');
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('结算'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Obx(() => _isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderSummary(),
                  const SizedBox(height: 20),
                  _buildAddressSection(),
                  const SizedBox(height: 20),
                  _buildPaymentSection(),
                  const SizedBox(height: 20),
                  _buildNotesSection(),
                  const SizedBox(height: 30),
                  _buildPriceBreakdown(),
                  const SizedBox(height: 30),
                  _buildSubmitButton(),
                ],
              ),
            )),
    );
  }

  String _getItemDisplayName(CartItem item) {
    try {
      if (item.itemNameSnapshot != null) {
        return item.itemNameSnapshot!['zh'] ?? 
               item.itemNameSnapshot!['en'] ?? 
               'Unknown Item';
      }
      return 'Unknown Item';
    } catch (e) {
      return 'Unknown Item';
    }
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '订单商品',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...cartItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${_getItemDisplayName(item)} x${item.quantity}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        '¥${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '收货地址',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => _showAddressSelector(),
                  child: const Text('更换地址'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              final address = _selectedAddress.value;
              return address != null
                  ? _buildAddressCard(address)
                  : const Text('请选择收货地址', style: TextStyle(color: Colors.grey));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(Address address) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${address.streetNumber ?? ''} ${address.streetName ?? ''} ${address.streetType ?? ''}'.trim(),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            '${address.city ?? ''}, ${address.province ?? ''} ${address.postalCode ?? ''}'.trim(),
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '支付方式',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Obx(() => Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('信用卡'),
                      value: 'credit_card',
                      groupValue: _selectedPaymentMethod.value,
                      onChanged: (value) => _selectedPaymentMethod.value = value!,
                    ),
                    RadioListTile<String>(
                      title: const Text('借记卡'),
                      value: 'debit_card',
                      groupValue: _selectedPaymentMethod.value,
                      onChanged: (value) => _selectedPaymentMethod.value = value!,
                    ),
                    RadioListTile<String>(
                      title: const Text('现金支付'),
                      value: 'cash',
                      groupValue: _selectedPaymentMethod.value,
                      onChanged: (value) => _selectedPaymentMethod.value = value!,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '订单备注',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '请输入订单备注（可选）',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _orderNotes.value = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('商品小计'),
                Text('¥${subtotal.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('税费 (13% HST)'),
                Text('¥${taxAmount.toStringAsFixed(2)}'),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '总计',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '¥${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Obx(() => ElevatedButton(
            onPressed: _isLoading.value ? null : _submitOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: _isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    '提交订单 (¥${totalAmount.toStringAsFixed(2)})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          )),
    );
  }

  void _showAddressSelector() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '选择收货地址',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
                  children: _addresses.map((address) => ListTile(
                        title: Text('${address.streetNumber} ${address.streetName}'),
                        subtitle: Text('${address.city}, ${address.province}'),
                        trailing: _selectedAddress.value?.id == address.id
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () {
                          _selectedAddress.value = address;
                          Get.back();
                        },
                      )).toList(),
                )),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.toNamed('/my_addresses');
              },
              child: const Text('添加新地址'),
            ),
          ],
        ),
      ),
    );
  }
}
