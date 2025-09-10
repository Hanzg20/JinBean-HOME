import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/models/base_models.dart';
import '../../../../../core/models/order_models.dart';
import '../../../../../core/models/payment_models.dart';
import '../../../../../core/services/universal_payment_service.dart';
import '../../../../../core/controllers/universal_order_controller.dart';
import '../../../../../core/widgets/enhanced_payment_form.dart';

/// 餐饮支付组件
/// 
/// 集成Stripe支付系统，提供完整的支付体验
/// 包括支付方式选择、支付处理、支付结果反馈
class FoodPaymentWidget extends StatefulWidget {
  final Order order;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentFailed;

  const FoodPaymentWidget({
    super.key,
    required this.order,
    this.onPaymentSuccess,
    this.onPaymentFailed,
  });

  @override
  State<FoodPaymentWidget> createState() => _FoodPaymentWidgetState();
}

class _FoodPaymentWidgetState extends State<FoodPaymentWidget> {
  final UniversalPaymentService _paymentService = Get.find<UniversalPaymentService>();
  final UniversalOrderController _orderController = Get.find<UniversalOrderController>();
  final SupabaseClient _supabase = Supabase.instance.client;
  
  final RxBool _isProcessing = false.obs;
  final RxString _errorMessage = ''.obs;
  final Rx<PaymentMethod?> _selectedPaymentMethod = Rx<PaymentMethod?>(null);
  final RxList<PaymentMethod> _paymentMethods = <PaymentMethod>[].obs;
  final Rx<PaymentIntent?> _paymentIntent = Rx<PaymentIntent?>(null);

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('支付订单'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 订单信息卡片
            _buildOrderInfoCard(),
            
            const SizedBox(height: 20),
            
            // 支付方式选择
            _buildPaymentMethodSection(),
            
            const SizedBox(height: 20),
            
            // 支付明细
            _buildPaymentBreakdown(),
            
            const SizedBox(height: 20),
            
            // 错误信息显示
            Obx(() => _errorMessage.value.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[200]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage.value,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildPaymentButton(),
    );
  }

  /// 订单信息卡片
  Widget _buildOrderInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '订单信息',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    widget.order.status.label,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(widget.order.status),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            _buildInfoRow('订单号', widget.order.orderNumber),
            _buildInfoRow('商家', widget.order.industryMetadata['provider_name'] as String? ?? '餐厅'),
            _buildInfoRow('配送地址', widget.order.serviceAddress?.fullAddress ?? '待确认'),
            _buildInfoRow('下单时间', _formatDateTime(widget.order.createdAt)),
            
            if (widget.order.customerNotes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              _buildInfoRow('备注', widget.order.customerNotes!),
            ],
          ],
        ),
      ),
    );
  }

  /// 支付方式选择部分
  Widget _buildPaymentMethodSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '支付方式',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _showAddPaymentMethodDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('添加'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Obx(() => _paymentMethods.isEmpty
                ? _buildNoPaymentMethodsWidget()
                : _buildPaymentMethodsList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 支付明细
  Widget _buildPaymentBreakdown() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '支付明细',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // 基础费用
            _buildBreakdownRow('商品总价', widget.order.totalAmount),
            
            // 额外费用（从餐饮行业处理器获取）
            if (widget.order.industryMetadata.containsKey('fees')) ...[
              const Divider(),
              ..._buildFeesList(widget.order.industryMetadata['fees']),
            ],
            
            // 折扣
            if (widget.order.industryMetadata.containsKey('discounts')) ...[
              const Divider(),
              ..._buildDiscountsList(widget.order.industryMetadata['discounts']),
            ],
            
            const Divider(thickness: 2),
            _buildBreakdownRow(
              '总计', 
              widget.order.totalAmount,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  /// 支付按钮
  Widget _buildPaymentButton() {
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
        child: Obx(() => SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isProcessing.value || _selectedPaymentMethod.value == null
                ? null
                : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: _isProcessing.value
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
                      SizedBox(width: 8),
                      Text('处理中...'),
                    ],
                  )
                : Text(
                    '支付 ${widget.order.totalAmount.formatted}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        )),
      ),
    );
  }

  // ========================================
  // 辅助方法
  // ========================================

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, Price amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount.formatted,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeesList(dynamic fees) {
    if (fees is! List) return [];
    
    return fees.map<Widget>((fee) {
      if (fee is Map<String, dynamic>) {
        return _buildBreakdownRow(
          fee['name'] ?? 'Additional Fee',
          Price(amount: (fee['amount'] ?? 0.0).toDouble()),
        );
      }
      return const SizedBox.shrink();
    }).toList();
  }

  List<Widget> _buildDiscountsList(dynamic discounts) {
    if (discounts is! List) return [];
    
    return discounts.map<Widget>((discount) {
      if (discount is Map<String, dynamic>) {
        return _buildBreakdownRow(
          discount['name'] ?? 'Discount',
          Price(amount: -(discount['amount'] ?? 0.0).toDouble()),
        );
      }
      return const SizedBox.shrink();
    }).toList();
  }

  Widget _buildNoPaymentMethodsWidget() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.payment, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            '暂无支付方式',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _showAddPaymentMethodDialog,
            child: const Text('添加支付方式'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return Obx(() => Column(
      children: _paymentMethods.map((method) => _buildPaymentMethodTile(method)).toList(),
    ));
  }

  Widget _buildPaymentMethodTile(PaymentMethod method) {
    return Obx(() => RadioListTile<PaymentMethod>(
      value: method,
      groupValue: _selectedPaymentMethod.value,
      onChanged: (value) => _selectedPaymentMethod.value = value,
      title: Text(method.displayName),
      subtitle: Text('${method.type.label} • ${method.providerId}'),
      secondary: Icon(_getPaymentMethodIcon(method.type)),
      controlAffinity: ListTileControlAffinity.trailing,
    ));
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange[100]!;
      case OrderStatus.accepted:
        return Colors.blue[100]!;
      case OrderStatus.inProgress:
        return Colors.purple[100]!;
      case OrderStatus.completed:
        return Colors.green[100]!;
      case OrderStatus.cancelled:
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  IconData _getPaymentMethodIcon(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        return Icons.credit_card;
      case PaymentMethodType.paypal:
        return Icons.account_balance_wallet;
      case PaymentMethodType.applePay:
        return Icons.apple;
      case PaymentMethodType.googlePay:
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // ========================================
  // 业务逻辑
  // ========================================

  /// 加载支付方式
  Future<void> _loadPaymentMethods() async {
    try {
      // TODO: 从当前用户获取支付方式
      // 现在使用模拟数据
      await Future.delayed(const Duration(milliseconds: 500));
      
      _paymentMethods.value = [
        PaymentMethod(
          id: 'pm_1',
          userId: 'user_123',
          type: PaymentMethodType.creditCard,
          providerId: 'Stripe',
          externalTokenId: 'pm_1234567890',
          cardLast4: '4242',
          cardBrand: 'Visa',
          cardExpMonth: 12,
          cardExpYear: 2025,
          isDefault: true,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      if (_paymentMethods.isNotEmpty) {
        _selectedPaymentMethod.value = _paymentMethods.first;
      }
    } catch (e) {
      _errorMessage.value = '加载支付方式失败: $e';
    }
  }

  /// 显示添加支付方式对话框
  void _showAddPaymentMethodDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EnhancedPaymentForm(
          title: '添加支付方式',
          onPaymentMethodCreated: (type, data) async {
            Navigator.of(context).pop();
            await _addPaymentMethodFromForm(type, data);
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  /// 从表单添加支付方式
  Future<void> _addPaymentMethodFromForm(
    PaymentMethodType type,
    Map<String, dynamic> data,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('用户未登录');
      }

      // 使用UniversalPaymentService添加支付方式
      final newMethod = await _paymentService.addPaymentMethod(
        userId: userId,
        type: type,
        providerId: 'stripe',
        paymentMethodData: data,
        setAsDefault: _paymentMethods.isEmpty, // 如果是第一个支付方式，设为默认
      );

      // 更新本地列表
      _paymentMethods.add(newMethod);
      
      // 如果没有选中的支付方式，选中新添加的
      if (_selectedPaymentMethod.value == null) {
        _selectedPaymentMethod.value = newMethod;
      }

      Get.snackbar(
        '成功',
        '支付方式添加成功！',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      print('添加支付方式失败: $e');
      Get.snackbar(
        '错误',
        '添加支付方式失败: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// 处理支付
  Future<void> _processPayment() async {
    if (_selectedPaymentMethod.value == null) {
      _errorMessage.value = '请选择支付方式';
      return;
    }

    _isProcessing.value = true;
    _errorMessage.value = '';

    try {
      // 1. 创建支付意图
      final paymentIntent = await _paymentService.createPaymentIntent(
        order: widget.order,
        paymentMethod: _selectedPaymentMethod.value!,
        metadata: {
          'industry': 'food',
          'order_type': 'delivery',
        },
      );

      _paymentIntent.value = paymentIntent;

      // 2. 确认支付（这里应该调用Stripe的支付确认界面）
      final success = await _confirmPaymentWithStripe(paymentIntent);

      if (success) {
        // 3. 更新订单状态
        await _orderController.updateOrderStatus(
          orderId: widget.order.id,
          newStatus: OrderStatus.accepted,
          reason: '支付成功，订单已确认',
        );

        // 4. 显示成功消息
        Get.snackbar(
          '支付成功',
          '订单 ${widget.order.orderNumber} 支付成功！',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // 5. 调用成功回调
        widget.onPaymentSuccess?.call();

        // 6. 返回上一页
        Get.back();
      } else {
        _errorMessage.value = '支付失败，请重试';
        widget.onPaymentFailed?.call();
      }

    } catch (e) {
      _errorMessage.value = '支付过程中出现错误: $e';
      widget.onPaymentFailed?.call();
    } finally {
      _isProcessing.value = false;
    }
  }

  /// 使用Stripe确认支付
  Future<bool> _confirmPaymentWithStripe(PaymentIntent paymentIntent) async {
    try {
      // 这里应该集成Stripe的确认支付界面
      // 现在使用模拟实现
      await Future.delayed(const Duration(seconds: 2));
      
      // 模拟95%成功率
      final success = DateTime.now().millisecond % 100 < 95;
      
      if (success) {
        // 确认支付成功，调用支付服务的confirmPayment方法
        final payment = await _paymentService.confirmPayment(
          paymentIntentId: paymentIntent.id,
          additionalData: {
            'paymentMethodId': _selectedPaymentMethod.value!.id,
            'userId': widget.order.customerId,
          },
        );
        
        return payment.status == PaymentStatus.completed;
      } else {
        throw Exception('支付被拒绝');
      }
      
    } catch (e) {
      print('Stripe支付确认失败: $e');
      return false;
    }
  }
}
