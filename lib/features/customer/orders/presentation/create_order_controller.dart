import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';import 'package:flutter/material.dart';
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
    
    AppLogger.info('[CreateOrderController] Initializing CreateOrderController...');
    
    // Get parameters passed from service detail page
    final arguments = Get.arguments as Map<String, dynamic>?;
    AppLogger.info('[CreateOrderController] Received arguments: $arguments');
    
    if (arguments != null) {
      serviceId.value = arguments['serviceId'] ?? '';
      serviceName.value = arguments['serviceName'] ?? '';
      providerId.value = arguments['providerId'] ?? '';
      price?.value = arguments['price']?.toDouble() ?? 0.0;
      pricingType.value = arguments['pricingType'] ?? '';
      
      AppLogger.info('[CreateOrderController] Parameters set:');
      AppLogger.info('[CreateOrderController] - serviceId: ${serviceId.value}');
      AppLogger.info('[CreateOrderController] - serviceName: ${serviceName.value}');
      AppLogger.info('[CreateOrderController] - providerId: ${providerId.value}');
      AppLogger.info('[CreateOrderController] - price: ${price?.value}');
      AppLogger.info('[CreateOrderController] - pricingType: ${pricingType.value}');
      
      // Load provider information
      loadProviderInfo();
      
      // Load service details
      loadServiceDetails();
    } else {
      AppLogger.info('[CreateOrderController] WARNING: No arguments received');
    }

    // Listen for form changes
    ever(selectedDate!, (_) => _validateForm());
    ever(selectedTime!, (_) => _validateForm());
    
    // Listen for address input
    addressController.addListener(_validateForm);
    
    AppLogger.info('[CreateOrderController] Initialization completed');
  }

  Future<void> loadProviderInfo() async {
    try {
      AppLogger.info('[CreateOrderController] Loading provider info for providerId: ${providerId.value}');
      if (providerId.value.isEmpty) {
        AppLogger.info('[CreateOrderController] ERROR: providerId is empty');
        return;
      }

      final response = await Supabase.instance.client
          .from('provider_profiles')
          .select()
          .eq('id', providerId.value)
          .single();

      AppLogger.info('[CreateOrderController] Provider info loaded: $response');
      providerName.value = response['company_name'] ?? 'Unknown Provider';
      providerPhone.value = response['contact_phone'] ?? '';
      AppLogger.info('[CreateOrderController] Provider name set to: ${providerName.value}');
      AppLogger.info('[CreateOrderController] Provider phone set to: ${providerPhone.value}');
    } catch (e) {
      AppLogger.info('[CreateOrderController] ERROR loading provider info: $e');
      AppLogger.info('[CreateOrderController] Error type: ${e.runtimeType}');
      if (e is PostgrestException) {
        AppLogger.info('[CreateOrderController] PostgrestException details: ${e.message}');
        AppLogger.info('[CreateOrderController] PostgrestException details: ${e.details}');
        AppLogger.info('[CreateOrderController] PostgrestException hint: ${e.hint}');
      }
    }
  }

  Future<void> loadServiceDetails() async {
    try {
      AppLogger.info('[CreateOrderController] Loading service details for serviceId: ${serviceId.value}');
      if (serviceId.value.isEmpty) {
        AppLogger.info('[CreateOrderController] ERROR: serviceId is empty');
        return;
      }

      final response = await Supabase.instance.client
          .from('service_details')
          .select()
          .eq('service_id', serviceId.value)
          .single();

      AppLogger.info('[CreateOrderController] Service details loaded: $response');
      serviceDescription.value = response['service_details_json']?['description'] ?? '';
      AppLogger.info('[CreateOrderController] Service description set to: ${serviceDescription.value}');
      
      // Calculate platform fee
      final servicePrice = response['price']?.toDouble() ?? 0.0;
      final feeRate = response['platform_service_fee_rate']?.toDouble() ?? 0.1; // Default 10%
      platformFee.value = servicePrice * feeRate;
      totalPrice.value = servicePrice + platformFee.value;
      AppLogger.info('[CreateOrderController] Service price: $servicePrice');
      AppLogger.info('[CreateOrderController] Platform fee rate: $feeRate');
      AppLogger.info('[CreateOrderController] Platform fee: ${platformFee.value}');
      AppLogger.info('[CreateOrderController] Total price: ${totalPrice.value}');
    } catch (e) {
      AppLogger.info('[CreateOrderController] ERROR loading service details: $e');
      AppLogger.info('[CreateOrderController] Error type: ${e.runtimeType}');
      if (e is PostgrestException) {
        AppLogger.info('[CreateOrderController] PostgrestException details: ${e.message}');
        AppLogger.info('[CreateOrderController] PostgrestException details: ${e.details}');
        AppLogger.info('[CreateOrderController] PostgrestException hint: ${e.hint}');
      }
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
      AppLogger.info('[CreateOrderController] Starting order creation process...');
      isLoading.value = true;

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        AppLogger.info('[CreateOrderController] ERROR: User not authenticated');
        Get.snackbar(
          'Error',
          'Please login to create an order',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      AppLogger.info('[CreateOrderController] User authenticated: ${user.id}');

      // Validate required data
      AppLogger.info('[CreateOrderController] Validating order data...');
      AppLogger.info('[CreateOrderController] serviceId: ${serviceId.value}');
      AppLogger.info('[CreateOrderController] providerId: ${providerId.value}');
      AppLogger.info('[CreateOrderController] selectedDate: ${selectedDate?.value}');
      AppLogger.info('[CreateOrderController] selectedTime: ${selectedTime?.value}');
      AppLogger.info('[CreateOrderController] address: ${addressController.text.trim()}');
      AppLogger.info('[CreateOrderController] totalPrice: ${totalPrice.value}');

      if (serviceId.value.isEmpty || providerId.value.isEmpty || 
          selectedDate?.value.isEmpty == true || selectedTime?.value.isEmpty == true ||
          addressController.text.trim().isEmpty) {
        AppLogger.info('[CreateOrderController] ERROR: Required fields missing');
        Get.snackbar(
          'Error',
          'Please fill in all required fields',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Generate order number
      final orderNumber = 'ORD-${DateFormat('yyyyMMdd-HHmmss').format(DateTime.now())}';
      AppLogger.info('[CreateOrderController] Generated order number: $orderNumber');

      // Create order data
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
      AppLogger.info('[CreateOrderController] Order data prepared: $orderData');

      // Create order in database
      AppLogger.info('[CreateOrderController] Inserting order into database...');
      final orderResponse = await Supabase.instance.client
          .from('orders')
          .insert(orderData)
          .select()
          .single();
      AppLogger.info('[CreateOrderController] Order created successfully: ${orderResponse['id']}');

      // Create order item data
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
      AppLogger.info('[CreateOrderController] Order item data prepared: $orderItemData');

      // Create order item in database
      AppLogger.info('[CreateOrderController] Inserting order item into database...');
      await Supabase.instance.client
          .from('order_items')
          .insert(orderItemData);
      AppLogger.info('[CreateOrderController] Order item created successfully');

      AppLogger.info('[CreateOrderController] Order creation completed successfully');
      Get.snackbar(
        'Success',
        'Order created successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to orders page
      AppLogger.info('[CreateOrderController] Navigating to orders page...');
      Get.offNamed('/orders');
    } catch (e) {
      AppLogger.info('[CreateOrderController] ERROR creating order: $e');
      AppLogger.info('[CreateOrderController] Error type: ${e.runtimeType}');
      if (e is PostgrestException) {
        AppLogger.info('[CreateOrderController] PostgrestException details: ${e.message}');
        AppLogger.info('[CreateOrderController] PostgrestException details: ${e.details}');
        AppLogger.info('[CreateOrderController] PostgrestException hint: ${e.hint}');
      }
      Get.snackbar(
        'Error',
        'Failed to create order. Please try again. Error: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      AppLogger.info('[CreateOrderController] Order creation process finished');
    }
  }

  @override
  void onClose() {
    addressController.dispose();
    notesController.dispose();
    super.onClose();
  }
} 