import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class CreateOrderController extends GetxController {
  // 从服务详情页面传递的参数
  final RxString serviceId = ''.obs;
  final RxString serviceName = ''.obs;
  final RxString serviceDescription = ''.obs;
  final RxString providerId = ''.obs;
  final RxString providerName = ''.obs;
  final RxString providerPhone = ''.obs;
  final RxDouble? price = RxDouble(0.0);
  final RxString pricingType = ''.obs;

  // 订单表单数据
  final TextEditingController addressController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final RxString? selectedDate = RxString('');
  final RxString? selectedTime = RxString('');

  // 状态管理
  final RxBool isLoading = false.obs;
  final RxBool canCreateOrder = false.obs;

  // 价格计算
  final RxDouble platformFee = 0.0.obs;
  final RxDouble totalPrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    
    // 获取从服务详情页面传递的参数
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      serviceId.value = arguments['serviceId'] ?? '';
      serviceName.value = arguments['serviceName'] ?? '';
      providerId.value = arguments['providerId'] ?? '';
      price?.value = arguments['price']?.toDouble() ?? 0.0;
      pricingType.value = arguments['pricingType'] ?? '';
      
      // 加载服务商信息
      loadProviderInfo();
      
      // 加载服务详情
      loadServiceDetails();
    }

    // 监听表单变化
    ever(selectedDate!, (_) => _validateForm());
    ever(selectedTime!, (_) => _validateForm());
    
    // 监听地址输入
    addressController.addListener(_validateForm);
  }

  Future<void> loadProviderInfo() async {
    try {
      if (providerId.value.isEmpty) return;

      final response = await Supabase.instance.client
          .from('provider_profiles')
          .select()
          .eq('id', providerId.value)
          .single();

      providerName.value = response['company_name'] ?? 'Unknown Provider';
      providerPhone.value = response['contact_phone'] ?? '';
        } catch (e) {
      print('Error loading provider info: $e');
    }
  }

  Future<void> loadServiceDetails() async {
    try {
      if (serviceId.value.isEmpty) return;

      final response = await Supabase.instance.client
          .from('service_details')
          .select()
          .eq('service_id', serviceId.value)
          .single();

      serviceDescription.value = response['service_details_json']?['description'] ?? '';
      
      // 计算平台费用
      final servicePrice = response['price']?.toDouble() ?? 0.0;
      final feeRate = response['platform_service_fee_rate']?.toDouble() ?? 0.1; // 默认10%
      platformFee.value = servicePrice * feeRate;
      totalPrice.value = servicePrice + platformFee.value;
        } catch (e) {
      print('Error loading service details: $e');
    }
  }

  void selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      selectedDate?.value = DateFormat('yyyy-MM-dd').format(picked);
      _validateForm();
    }
  }

  void selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      selectedTime?.value = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      _validateForm();
    }
  }

  void _validateForm() {
    bool isValid = true;

    // 检查必填字段
    if (selectedDate?.value.isEmpty == true) isValid = false;
    if (selectedTime?.value.isEmpty == true) isValid = false;
    if (addressController.text.trim().isEmpty) isValid = false;

    canCreateOrder.value = isValid;
  }

  Future<void> createOrder() async {
    try {
      isLoading.value = true;

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Error',
          'Please login to create an order',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // 生成订单号
      final orderNumber = 'ORD-${DateFormat('yyyyMMdd-HHmmss').format(DateTime.now())}';

      // 创建订单
      final orderData = {
        'order_number': orderNumber,
        'user_id': user.id,
        'provider_id': providerId.value,
        'service_id': serviceId.value,
        'order_type': 'on_demand',
        'fulfillment_mode_snapshot': 'platform',
        'order_status': 'PendingAcceptance',
        'total_price': totalPrice.value,
        'currency': 'CAD',
        'payment_status': 'Pending',
        'scheduled_start_time': '${selectedDate?.value} ${selectedTime?.value}:00',
        'user_notes': notesController.text.trim(),
        'service_address_snapshot': {
          'address': addressController.text.trim(),
        },
      };

      final orderResponse = await Supabase.instance.client
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      // 创建订单项
      final orderItemData = {
        'order_id': orderResponse['id'],
        'service_id': serviceId.value,
        'quantity': 1,
        'unit_price_snapshot': price?.value ?? 0.0,
        'subtotal_price': price?.value ?? 0.0,
        'service_name_snapshot': serviceName.value,
        'service_description_snapshot': serviceDescription.value,
        'pricing_type_snapshot': pricingType.value,
      };

      await Supabase.instance.client
          .from('order_items')
          .insert(orderItemData);

      Get.snackbar(
        'Success',
        'Order created successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );

      // 导航到订单详情页面
      Get.offAllNamed('/my_orders');
        } catch (e) {
      print('Error creating order: $e');
      Get.snackbar(
        'Error',
        'Failed to create order. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    addressController.dispose();
    notesController.dispose();
    super.onClose();
  }
} 