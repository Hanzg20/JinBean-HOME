import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/models/base_models.dart';
import '../../../../../core/models/order_models.dart';
import '../../../../../core/models/payment_models.dart';
import '../../../../../core/controllers/universal_order_controller.dart';

/// 餐饮结算组件
/// 
/// 基于通用模型系统构建的结算组件
/// 支持地址确认、价格计算、支付方式选择、下单等功能
class FoodCheckoutWidget extends StatefulWidget {
  final String serviceId;
  final String providerId;
  final RxList<OrderItemRequest> cartItems;
  final Address? deliveryAddress;
  final String customerNotes;
  final Function(Address) onAddressChanged;
  final VoidCallback onPlaceOrder;

  const FoodCheckoutWidget({
    super.key,
    required this.serviceId,
    required this.providerId,
    required this.cartItems,
    required this.deliveryAddress,
    required this.customerNotes,
    required this.onAddressChanged,
    required this.onPlaceOrder,
  });

  @override
  State<FoodCheckoutWidget> createState() => _FoodCheckoutWidgetState();
}

class _FoodCheckoutWidgetState extends State<FoodCheckoutWidget> {
  final UniversalOrderController _orderController = Get.find<UniversalOrderController>();
  
  final RxBool _isCalculatingPrice = false.obs;
  final Rx<PricingResult?> _pricingResult = Rx<PricingResult?>(null);
  final RxString _selectedPaymentMethodId = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
    _calculatePrice();
  }

  /// 加载支付方式
  Future<void> _loadPaymentMethods() async {
    await _orderController.loadPaymentMethods();
  }

  /// 计算价格
  Future<void> _calculatePrice() async {
    if (widget.cartItems.isEmpty) return;

    _isCalculatingPrice.value = true;
    
    try {
      final orderRequest = OrderRequest(
        serviceId: widget.serviceId,
        providerId: widget.providerId,
        industry: IndustryType.food,
        orderType: 'instant',
        items: widget.cartItems.toList(),
        serviceAddress: widget.deliveryAddress,
        customerNotes: widget.customerNotes.isNotEmpty ? widget.customerNotes : null,
        industrySpecificData: Configuration({
          'restaurant_id': widget.providerId,
          'delivery_type': 'standard',
        }),
      );

      await _orderController.calculateOrderPrice(orderRequest);
      _pricingResult.value = _orderController.pricingResult.value;

    } catch (e) {
      print('❌ 价格计算失败: $e');
      Get.snackbar('错误', '价格计算失败');
    } finally {
      _isCalculatingPrice.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.cartItems.isEmpty) {
        return _buildEmptyCheckout();
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 配送地址确认
          _buildDeliveryAddressSection(),
          
          const SizedBox(height: 16),
          
          // 订单商品明细
          _buildOrderSummarySection(),
          
          const SizedBox(height: 16),
          
          // 价格详情
          _buildPricingSection(),
          
          const SizedBox(height: 16),
          
          // 支付方式选择
          _buildPaymentMethodSection(),
          
          const SizedBox(height: 16),
          
          // 订单备注
          _buildOrderNotesSection(),
          
          const SizedBox(height: 32),
          
          // 下单按钮
          _buildPlaceOrderButton(),
          
          const SizedBox(height: 100), // 底部安全区域
        ],
      );
    });
  }

  /// 空结算界面
  Widget _buildEmptyCheckout() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '没有商品可以结算',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              DefaultTabController.of(context)?.animateTo(0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('去选购'),
          ),
        ],
      ),
    );
  }

  /// 配送地址区域
  Widget _buildDeliveryAddressSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  '配送地址',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.deliveryAddress != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.deliveryAddress!.fullAddress,
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (widget.deliveryAddress!.extra?['instructions']?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        '配送说明: ${widget.deliveryAddress!.extra?['instructions']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showAddressEditDialog,
                  child: const Text('修改地址'),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '请设置配送地址',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showAddressEditDialog,
                  child: const Text('设置地址'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 订单商品明细区域
  Widget _buildOrderSummarySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.receipt, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  '订单明细',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...widget.cartItems.map((item) => _buildOrderItem(item)),
          ],
        ),
      ),
    );
  }

  /// 订单商品项
  Widget _buildOrderItem(OrderItemRequest item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (item.customizations.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.customizations.entries
                        .map((e) => '${e.key}: ${e.value}')
                        .join(', '),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            'x${item.quantity}',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '\$${item.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// 价格详情区域
  Widget _buildPricingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calculate, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  '价格详情',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isCalculatingPrice.value) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else if (_pricingResult.value != null) ...[
              _buildPricingDetails(_pricingResult.value!),
            ] else ...[
              const Text('价格计算中...'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _calculatePrice,
                child: const Text('重新计算'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 价格详情内容
  Widget _buildPricingDetails(PricingResult pricing) {
    return Column(
      children: [
        // 商品小计
        _buildPriceRow(
          '商品小计',
          pricing.baseAmount.formatted,
          isSubtotal: true,
        ),
        
        // 各种费用
        ...pricing.fees.map((fee) => _buildPriceRow(
          fee.name,
          fee.amount.formatted,
          isPositive: true,
        )),
        
        // 优惠折扣
        if (pricing.discounts.isNotEmpty)
          ...pricing.discounts.map((discount) => _buildPriceRow(
            discount.name,
            '-${discount.amount.formatted}',
            isNegative: true,
          )),
        
        const Divider(height: 24),
        
        // 总计
        _buildPriceRow(
          '总计',
          pricing.totalAmount.formatted,
          isTotal: true,
        ),
        
        // 说明文字
        const SizedBox(height: 8),
        Text(
          '价格已包含所有税费',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 价格行
  Widget _buildPriceRow(
    String label,
    String amount, {
    bool isSubtotal = false,
    bool isTotal = false,
    bool isPositive = false,
    bool isNegative = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isNegative ? Colors.green : null,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal || isSubtotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal
                  ? Colors.red
                  : isNegative
                      ? Colors.green
                      : null,
            ),
          ),
        ],
      ),
    );
  }

  /// 支付方式选择区域
  Widget _buildPaymentMethodSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.payment, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  '支付方式',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              final paymentMethods = _orderController.paymentMethods;
              
              if (paymentMethods.isEmpty) {
                return Column(
                  children: [
                    const Text('暂无可用的支付方式'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: 跳转到添加支付方式页面
                        Get.snackbar('提示', '请先添加支付方式');
                      },
                      child: const Text('添加支付方式'),
                    ),
                  ],
                );
              }
              
              return Column(
                children: paymentMethods.map((method) => _buildPaymentMethodTile(method)).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 支付方式选项
  Widget _buildPaymentMethodTile(PaymentMethod method) {
    return Obx(() => RadioListTile<String>(
      value: method.id,
      groupValue: _selectedPaymentMethodId.value.isEmpty 
          ? (method.isDefault ? method.id : null)
          : _selectedPaymentMethodId.value,
      onChanged: (value) {
        if (value != null) {
          _selectedPaymentMethodId.value = value;
          _orderController.selectPaymentMethod(method);
        }
      },
      title: Text(method.displayName),
      subtitle: method.isExpired
          ? const Text('已过期', style: TextStyle(color: Colors.red))
          : null,
      secondary: Icon(_getPaymentMethodIcon(method.type)),
      dense: true,
    ));
  }

  /// 获取支付方式图标
  IconData _getPaymentMethodIcon(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        return Icons.credit_card;
      case PaymentMethodType.paypal:
        return Icons.account_balance_wallet;
      case PaymentMethodType.applePay:
        return Icons.phone_iphone;
      case PaymentMethodType.googlePay:
        return Icons.android;
      default:
        return Icons.payment;
    }
  }

  /// 订单备注区域
  Widget _buildOrderNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.note, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  '订单备注',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.customerNotes.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(widget.customerNotes),
              )
            else
              Text(
                '无特殊要求',
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }

  /// 下单按钮
  Widget _buildPlaceOrderButton() {
    return Obx(() {
      final canPlaceOrder = widget.deliveryAddress != null &&
                          _pricingResult.value != null &&
                          !_isCalculatingPrice.value &&
                          !_orderController.isCreatingOrder.value;

      final pricing = _pricingResult.value;
      final buttonText = pricing != null
          ? '确认下单 (${pricing.totalAmount.formatted})'
          : '确认下单';

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canPlaceOrder ? widget.onPlaceOrder : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: _orderController.isCreatingOrder.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(buttonText),
        ),
      );
    });
  }

  /// 显示地址编辑对话框
  void _showAddressEditDialog() {
    // TODO: 实现地址编辑对话框
    Get.snackbar('提示', '地址编辑功能待实现');
  }
}
