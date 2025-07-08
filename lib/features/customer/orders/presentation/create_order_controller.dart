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
    
    print('[CreateOrderController] Initializing CreateOrderController...');
    
    // Get parameters passed from service detail page
    final arguments = Get.arguments as Map<String, dynamic>?;
    print('[CreateOrderController] Received arguments: $arguments');
    
    if (arguments != null) {
      serviceId.value = arguments['serviceId'] ?? '';
      serviceName.value = arguments['serviceName'] ?? '';
      providerId.value = arguments['providerId'] ?? '';
      price?.value = arguments['price']?.toDouble() ?? 0.0;
      pricingType.value = arguments['pricingType'] ?? '';
      
      print('[CreateOrderController] Parameters set:');
      print('[CreateOrderController] - serviceId: ${serviceId.value}');
      print('[CreateOrderController] - serviceName: ${serviceName.value}');
      print('[CreateOrderController] - providerId: ${providerId.value}');
      print('[CreateOrderController] - price: ${price?.value}');
      print('[CreateOrderController] - pricingType: ${pricingType.value}');
      
      // Load provider information
      loadProviderInfo();
      
      // Load service details
      loadServiceDetails();
    } else {
      print('[CreateOrderController] WARNING: No arguments received');
    }

    // Listen for form changes
    ever(selectedDate!, (_) => _validateForm());
    ever(selectedTime!, (_) => _validateForm());
    
    // Listen for address input
    addressController.addListener(_validateForm);
    
    print('[CreateOrderController] Initialization completed');
  }

  Future<void> loadProviderInfo() async {
    try {
      print('[CreateOrderController] Loading provider info for providerId: ${providerId.value}');
      if (providerId.value.isEmpty) {
        print('[CreateOrderController] ERROR: providerId is empty');
        return;
      }

      final response = await Supabase.instance.client
          .from('provider_profiles')
          .select()
          .eq('id', providerId.value)
          .single();

      print('[CreateOrderController] Provider info loaded: $response');
      providerName.value = response['company_name'] ?? 'Unknown Provider';
      providerPhone.value = response['contact_phone'] ?? '';
      print('[CreateOrderController] Provider name set to: ${providerName.value}');
      print('[CreateOrderController] Provider phone set to: ${providerPhone.value}');
    } catch (e) {
      print('[CreateOrderController] ERROR loading provider info: $e');
      print('[CreateOrderController] Error type: ${e.runtimeType}');
      if (e is PostgrestException) {
        print('[CreateOrderController] PostgrestException details: ${e.message}');
        print('[CreateOrderController] PostgrestException details: ${e.details}');
        print('[CreateOrderController] PostgrestException hint: ${e.hint}');
      }
    }
  }

  Future<void> loadServiceDetails() async {
    try {
      print('[CreateOrderController] Loading service details for serviceId: ${serviceId.value}');
      if (serviceId.value.isEmpty) {
        print('[CreateOrderController] ERROR: serviceId is empty');
        return;
      }

      final response = await Supabase.instance.client
          .from('service_details')
          .select()
          .eq('service_id', serviceId.value)
          .single();

      print('[CreateOrderController] Service details loaded: $response');
      serviceDescription.value = response['service_details_json']?['description'] ?? '';
      print('[CreateOrderController] Service description set to: ${serviceDescription.value}');
      
      // Calculate platform fee
      final servicePrice = response['price']?.toDouble() ?? 0.0;
      final feeRate = response['platform_service_fee_rate']?.toDouble() ?? 0.1; // Default 10%
      platformFee.value = servicePrice * feeRate;
      totalPrice.value = servicePrice + platformFee.value;
      print('[CreateOrderController] Service price: $servicePrice');
      print('[CreateOrderController] Platform fee rate: $feeRate');
      print('[CreateOrderController] Platform fee: ${platformFee.value}');
      print('[CreateOrderController] Total price: ${totalPrice.value}');
    } catch (e) {
      print('[CreateOrderController] ERROR loading service details: $e');
      print('[CreateOrderController] Error type: ${e.runtimeType}');
      if (e is PostgrestException) {
        print('[CreateOrderController] PostgrestException details: ${e.message}');
        print('[CreateOrderController] PostgrestException details: ${e.details}');
        print('[CreateOrderController] PostgrestException hint: ${e.hint}');
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
      print('[CreateOrderController] Starting order creation process...');
      isLoading.value = true;

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('[CreateOrderController] ERROR: User not authenticated');
        Get.snackbar(
          'Error',
          'Please login to create an order',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      print('[CreateOrderController] User authenticated: ${user.id}');

      // Validate required data
      print('[CreateOrderController] Validating order data...');
      print('[CreateOrderController] serviceId: ${serviceId.value}');
      print('[CreateOrderController] providerId: ${providerId.value}');
      print('[CreateOrderController] selectedDate: ${selectedDate?.value}');
      print('[CreateOrderController] selectedTime: ${selectedTime?.value}');
      print('[CreateOrderController] address: ${addressController.text.trim()}');
      print('[CreateOrderController] totalPrice: ${totalPrice.value}');

      if (serviceId.value.isEmpty || providerId.value.isEmpty || 
          selectedDate?.value.isEmpty == true || selectedTime?.value.isEmpty == true ||
          addressController.text.trim().isEmpty) {
        print('[CreateOrderController] ERROR: Required fields missing');
        Get.snackbar(
          'Error',
          'Please fill in all required fields',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Generate order number
      final orderNumber = 'ORD-${DateFormat('yyyyMMdd-HHmmss').format(DateTime.now())}';
      print('[CreateOrderController] Generated order number: $orderNumber');

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
      print('[CreateOrderController] Order data prepared: $orderData');

      // Create order in database
      print('[CreateOrderController] Inserting order into database...');
      final orderResponse = await Supabase.instance.client
          .from('orders')
          .insert(orderData)
          .select()
          .single();
      print('[CreateOrderController] Order created successfully: ${orderResponse['id']}');

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
      print('[CreateOrderController] Order item data prepared: $orderItemData');

      // Create order item in database
      print('[CreateOrderController] Inserting order item into database...');
      await Supabase.instance.client
          .from('order_items')
          .insert(orderItemData);
      print('[CreateOrderController] Order item created successfully');

      print('[CreateOrderController] Order creation completed successfully');
      Get.snackbar(
        'Success',
        'Order created successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to orders page
      print('[CreateOrderController] Navigating to orders page...');
      Get.offNamed('/orders');
    } catch (e) {
      print('[CreateOrderController] ERROR creating order: $e');
      print('[CreateOrderController] Error type: ${e.runtimeType}');
      if (e is PostgrestException) {
        print('[CreateOrderController] PostgrestException details: ${e.message}');
        print('[CreateOrderController] PostgrestException details: ${e.details}');
        print('[CreateOrderController] PostgrestException hint: ${e.hint}');
      }
      Get.snackbar(
        'Error',
        'Failed to create order. Please try again. Error: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      print('[CreateOrderController] Order creation process finished');
    }
  }

  @override
  void onClose() {
    addressController.dispose();
    notesController.dispose();
    super.onClose();
  }
} 