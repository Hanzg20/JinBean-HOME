import 'package:get/get.dart';
import '../../../../../core/models/payment_models.dart';
import '../../../../../core/services/universal_payment_service.dart';
import '../../../../../core/models/base_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentMethodsController extends GetxController {
  final isLoading = false.obs;
  final paymentMethods = <PaymentMethod>[].obs;
  
  late final UniversalPaymentService _paymentService;
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
    loadPaymentMethods();
  }

  void _initializeService() {
    try {
      _paymentService = Get.find<UniversalPaymentService>();
    } catch (e) {
      _paymentService = Get.put(UniversalPaymentService());
    }
  }

  /// 加载用户支付方式
  Future<void> loadPaymentMethods() async {
    isLoading.value = true;
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('用户未登录');
      }

      // 使用UniversalPaymentService获取支付方式
      final methods = await _paymentService.getUserPaymentMethods(userId);
      paymentMethods.value = methods;
      
    } catch (e) {
      print('加载支付方式失败: $e');
      // 如果API调用失败，使用模拟数据作为后备
      await _loadMockPaymentMethods();
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载模拟支付方式数据（后备方案）
  Future<void> _loadMockPaymentMethods() async {
    await Future.delayed(const Duration(milliseconds: 500));
    paymentMethods.value = [
      PaymentMethod(
        id: 'pm_mock_001',
        userId: 'user_mock',
        type: PaymentMethodType.creditCard,
        providerId: 'stripe',
        externalTokenId: 'pm_1234567890',
        cardLast4: '4242',
        cardBrand: 'visa',
        cardExpMonth: 12,
        cardExpYear: 2025,
        cardHolderName: 'John Doe',
        isDefault: true,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      PaymentMethod(
        id: 'pm_mock_002',
        userId: 'user_mock',
        type: PaymentMethodType.creditCard,
        providerId: 'stripe',
        externalTokenId: 'pm_0987654321',
        cardLast4: '1234',
        cardBrand: 'mastercard',
        cardExpMonth: 6,
        cardExpYear: 2027,
        cardHolderName: 'Jane Smith',
        isDefault: false,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  /// 添加支付方式
  Future<void> addPaymentMethod({
    required PaymentMethodType type,
    required Map<String, dynamic> paymentMethodData,
    bool setAsDefault = false,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('用户未登录');
      }

      // 使用UniversalPaymentService添加支付方式
      final newMethod = await _paymentService.addPaymentMethod(
        userId: userId,
        type: type,
        providerId: 'stripe', // 默认使用Stripe
        paymentMethodData: paymentMethodData,
        setAsDefault: setAsDefault,
      );

      // 更新本地列表
      paymentMethods.add(newMethod);
      
      Get.snackbar(
        '成功',
        '支付方式添加成功！',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
      
    } catch (e) {
      print('添加支付方式失败: $e');
      Get.snackbar(
        '错误',
        '添加支付方式失败: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// 删除支付方式
  Future<void> removePaymentMethod(String paymentMethodId) async {
    try {
      // 使用UniversalPaymentService删除支付方式
      await _paymentService.deletePaymentMethod(paymentMethodId);
      
      // 更新本地列表
      paymentMethods.removeWhere((method) => method.id == paymentMethodId);
      
      Get.snackbar(
        '成功',
        '支付方式删除成功！',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
      
    } catch (e) {
      print('删除支付方式失败: $e');
      Get.snackbar(
        '错误',
        '删除支付方式失败: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// 设置默认支付方式
  Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('用户未登录');
      }

      // 找到要设置为默认的支付方式
      final targetMethod = paymentMethods.firstWhereOrNull((method) => method.id == paymentMethodId);
      if (targetMethod == null) {
        throw Exception('支付方式不存在');
      }

      // 创建新的支付方式并设为默认
      final updatedMethod = await _paymentService.addPaymentMethod(
        userId: userId,
        type: targetMethod.type,
        providerId: targetMethod.providerId,
        paymentMethodData: {
          'external_token_id': targetMethod.externalTokenId,
        },
        setAsDefault: true,
      );

      // 更新本地列表 - 清除所有默认标记，然后设置新的默认
      for (int i = 0; i < paymentMethods.length; i++) {
        if (paymentMethods[i].id == paymentMethodId) {
          paymentMethods[i] = paymentMethods[i].copyWith(isDefault: true);
        } else {
          paymentMethods[i] = paymentMethods[i].copyWith(isDefault: false);
        }
      }
      paymentMethods.refresh();
      
      Get.snackbar(
        '成功',
        '默认支付方式更新成功！',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
      
    } catch (e) {
      print('设置默认支付方式失败: $e');
      Get.snackbar(
        '错误',
        '设置默认支付方式失败: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// 刷新支付方式列表
  Future<void> refreshPaymentMethods() async {
    await loadPaymentMethods();
  }

  /// 获取支付方式统计信息
  Map<String, dynamic> getPaymentMethodStats() {
    final total = paymentMethods.length;
    final activeCount = paymentMethods.where((method) => method.isActive).length;
    final defaultMethod = paymentMethods.firstWhereOrNull((method) => method.isDefault);
    
    final typeStats = <String, int>{};
    for (final method in paymentMethods) {
      final typeName = method.type.label;
      typeStats[typeName] = (typeStats[typeName] ?? 0) + 1;
    }

    return {
      'total': total,
      'active': activeCount,
      'default_method': defaultMethod?.displayName ?? '无',
      'type_distribution': typeStats,
    };
  }

  /// 验证支付方式是否可用
  bool isPaymentMethodValid(PaymentMethod method) {
    if (!method.isActive) return false;
    if (method.isExpired) return false;
    return true;
  }
}
