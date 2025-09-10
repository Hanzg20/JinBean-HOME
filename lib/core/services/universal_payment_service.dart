import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/base_models.dart';
import '../models/order_models.dart';
import '../models/payment_models.dart';

/// 通用支付服务
/// 
/// 提供跨行业的统一支付处理功能：
/// - 多支付渠道集成（Stripe、Square、PayPal）
/// - 支付流程管理和状态跟踪
/// - 退款处理和争议管理
/// - 支付安全和风控
class UniversalPaymentService extends GetxService {
  final _supabase = Supabase.instance.client;

  /// 支付提供商处理器注册表
  final Map<String, PaymentProviderHandler> _providerHandlers = {};

  /// 行业支付处理器注册表
  final Map<IndustryType, IndustryPaymentHandler> _industryHandlers = {};

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  void _initializeService() {
    print('💳 通用支付服务初始化');
    
    // 注册默认支付提供商处理器
    _registerDefaultProviders();
  }

  /// 注册支付提供商处理器
  void registerProviderHandler(String providerId, PaymentProviderHandler handler) {
    _providerHandlers[providerId] = handler;
    print('💳 注册支付提供商: $providerId');
  }

  /// 注册行业支付处理器
  void registerIndustryHandler(IndustryType industry, IndustryPaymentHandler handler) {
    _industryHandlers[industry] = handler;
    print('🏭 注册${industry.label}支付处理器');
  }

  /// 获取支付提供商处理器
  PaymentProviderHandler? getProviderHandler(String providerId) {
    return _providerHandlers[providerId];
  }

  /// 获取行业支付处理器
  IndustryPaymentHandler? getIndustryHandler(IndustryType industry) {
    return _industryHandlers[industry];
  }

  // ========================================
  // 支付意图管理
  // ========================================

  /// 创建支付意图
  Future<PaymentIntent> createPaymentIntent({
    required Order order,
    required PaymentMethod paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('💳 创建支付意图: ${order.orderNumber}');

      // 1. 验证订单状态
      if (order.status != OrderStatus.pending && order.status != OrderStatus.accepted) {
        throw PaymentException('订单状态不允许支付');
      }

      // 2. 验证支付方式
      if (!paymentMethod.isActive || paymentMethod.isExpired) {
        throw PaymentException('支付方式无效或已过期');
      }

      // 3. 调用行业处理器预处理
      final industryHandler = getIndustryHandler(order.industry);
      if (industryHandler != null) {
        await industryHandler.preprocessPayment(order, paymentMethod);
      }

      // 4. 获取支付提供商处理器
      final providerHandler = getProviderHandler(paymentMethod.providerId);
      if (providerHandler == null) {
        throw PaymentException('不支持的支付提供商: ${paymentMethod.providerId}');
      }

      // 5. 创建支付意图
      final paymentIntentId = _generatePaymentIntentId();
      
      final externalPaymentIntent = await providerHandler.createPaymentIntent(
        paymentIntentId: paymentIntentId,
        amount: order.totalAmount,
        paymentMethod: paymentMethod,
        metadata: {
          'order_id': order.id,
          'order_number': order.orderNumber,
          'industry': order.industry.code,
          ...?metadata,
        },
      );

      // 6. 保存支付意图到数据库
      final paymentIntent = PaymentIntent(
        id: paymentIntentId,
        orderId: order.id,
        amount: order.totalAmount,
        paymentProvider: paymentMethod.providerId,
        status: PaymentStatus.pending,
        clientSecret: externalPaymentIntent.clientSecret,
        confirmationMethod: externalPaymentIntent.confirmationMethod,
        metadata: metadata ?? {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _savePaymentIntentToDatabase(paymentIntent);

      // 7. 更新订单支付意图ID
      await _updateOrderPaymentIntent(order.id, paymentIntentId);

      print('✅ 支付意图创建成功: $paymentIntentId');
      return paymentIntent;

    } catch (e) {
      print('❌ 创建支付意图失败: $e');
      rethrow;
    }
  }

  /// 确认支付
  Future<PaymentResult> confirmPayment({
    required String paymentIntentId,
    String? confirmationToken,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      print('🔍 确认支付: $paymentIntentId');

      // 1. 获取支付意图
      final paymentIntent = await getPaymentIntentById(paymentIntentId);
      
      // 2. 获取订单信息
      final order = await _getOrderById(paymentIntent.orderId);

      // 3. 获取支付提供商处理器
      final providerHandler = getProviderHandler(paymentIntent.paymentProvider);
      if (providerHandler == null) {
        throw PaymentException('不支持的支付提供商: ${paymentIntent.paymentProvider}');
      }

      // 4. 调用提供商确认支付
      final providerResult = await providerHandler.confirmPayment(
        paymentIntentId: paymentIntentId,
        confirmationToken: confirmationToken,
        additionalData: additionalData,
      );

      // 5. 创建支付记录
      final payment = Payment(
        id: _generatePaymentId(),
        paymentId: paymentIntentId,
        orderId: order.id,
        paymentType: 'charge',
        paymentMethod: PaymentMethodType.fromCode(providerResult.paymentMethodType),
        paymentProvider: paymentIntent.paymentProvider,
        amount: paymentIntent.amount,
        processingFee: Price(amount: providerResult.processingFee ?? 0.0, currency: paymentIntent.amount.currency),
        netAmount: Price(
          amount: paymentIntent.amount.amount - (providerResult.processingFee ?? 0.0),
          currency: paymentIntent.amount.currency,
        ),
        status: providerResult.success ? PaymentStatus.completed : PaymentStatus.failed,
        failureReason: providerResult.success ? null : providerResult.message,
        paymentMethodDetails: providerResult.paymentMethodDetails,
        externalTransactionId: providerResult.transactionId,
        providerResponse: providerResult.rawResponse,
        processedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 6. 保存支付记录
      await _savePaymentToDatabase(payment);

      // 7. 更新支付意图状态
      await _updatePaymentIntentStatus(
        paymentIntentId, 
        payment.status,
        providerResult.success ? DateTime.now() : null,
      );

      // 8. 更新订单支付状态
      await _updateOrderPaymentStatus(order.id, payment.status);

      // 9. 调用行业处理器后处理
      final industryHandler = getIndustryHandler(order.industry);
      if (industryHandler != null) {
        await industryHandler.postprocessPayment(order, payment, providerResult.success);
      }

      final result = PaymentResult(
        success: providerResult.success,
        paymentId: paymentIntentId,
        transactionId: providerResult.transactionId,
        message: providerResult.message,
        status: payment.status,
        details: {
          'payment_method': payment.paymentMethod.code,
          'processing_fee': payment.processingFee.amount,
          'net_amount': payment.netAmount.amount,
        },
      );

      print(providerResult.success ? '✅ 支付确认成功' : '❌ 支付确认失败: ${providerResult.message}');
      return result;

    } catch (e) {
      print('❌ 确认支付失败: $e');
      rethrow;
    }
  }

  // ========================================
  // 退款管理
  // ========================================

  /// 处理退款
  Future<RefundResult> processRefund({
    required String orderId,
    Price? amount,
    required String reason,
    String? requestedBy,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('💸 处理退款: $orderId');

      // 1. 获取订单和支付信息
      final order = await _getOrderById(orderId);
      final payments = await _getOrderPayments(orderId);

      final successfulPayments = payments.where((p) => p.isSuccessful && p.isCharge).toList();
      if (successfulPayments.isEmpty) {
        throw PaymentException('没有找到可退款的支付记录');
      }

      // 2. 计算退款金额
      final refundAmount = amount ?? order.totalAmount;
      final totalPaid = successfulPayments.fold(
        Price(amount: 0.0, currency: order.totalAmount.currency),
        (sum, payment) => sum + payment.amount,
      );

      if (refundAmount > totalPaid) {
        throw PaymentException('退款金额超过已支付金额');
      }

      // 3. 调用行业处理器验证退款
      final industryHandler = getIndustryHandler(order.industry);
      if (industryHandler != null) {
        final validation = await industryHandler.validateRefund(order, refundAmount, reason);
        if (!validation.isValid) {
          throw PaymentException('退款验证失败: ${validation.firstError}');
        }
      }

      // 4. 处理退款（使用最近的支付记录）
      final latestPayment = successfulPayments.last;
      final providerHandler = getProviderHandler(latestPayment.paymentProvider);
      if (providerHandler == null) {
        throw PaymentException('不支持的支付提供商: ${latestPayment.paymentProvider}');
      }

      final providerRefundResult = await providerHandler.processRefund(
        originalPaymentId: latestPayment.paymentId,
        amount: refundAmount,
        reason: reason,
        metadata: metadata,
      );

      // 5. 创建退款记录
      final refund = Payment(
        id: _generatePaymentId(),
        paymentId: providerRefundResult.refundId,
        orderId: orderId,
        paymentType: 'refund',
        paymentMethod: latestPayment.paymentMethod,
        paymentProvider: latestPayment.paymentProvider,
        amount: refundAmount,
        processingFee: Price(amount: 0.0, currency: refundAmount.currency), // 退款通常不收费
        netAmount: refundAmount,
        status: providerRefundResult.success ? PaymentStatus.completed : PaymentStatus.failed,
        failureReason: providerRefundResult.success ? null : providerRefundResult.message,
        externalTransactionId: providerRefundResult.refundId,
        externalReference: reason,
        providerResponse: providerRefundResult.rawResponse ?? {},
        processedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 6. 保存退款记录
      await _savePaymentToDatabase(refund);

      // 7. 更新订单退款状态
      final allRefunds = await _getOrderRefunds(orderId);
      final totalRefunded = allRefunds.fold(
        Price(amount: 0.0, currency: order.totalAmount.currency),
        (sum, refund) => sum + refund.amount,
      );

      PaymentStatus newPaymentStatus;
      if (totalRefunded.amount >= totalPaid.amount) {
        newPaymentStatus = PaymentStatus.refunded;
      } else {
        newPaymentStatus = PaymentStatus.partiallyRefunded;
      }

      await _updateOrderPaymentStatus(orderId, newPaymentStatus);

      // 8. 调用行业处理器后处理
      if (industryHandler != null) {
        await industryHandler.postprocessRefund(order, refund, providerRefundResult.success);
      }

      final result = RefundResult(
        success: providerRefundResult.success,
        refundId: providerRefundResult.refundId,
        amount: refundAmount,
        message: providerRefundResult.message,
        details: {
          'original_payment_id': latestPayment.paymentId,
          'reason': reason,
          'requested_by': requestedBy,
        },
      );

      print(providerRefundResult.success ? '✅ 退款处理成功' : '❌ 退款处理失败: ${providerRefundResult.message}');
      return result;

    } catch (e) {
      print('❌ 退款处理失败: $e');
      rethrow;
    }
  }

  // ========================================
  // 支付方式管理
  // ========================================

  /// 添加支付方式
  Future<PaymentMethod> addPaymentMethod({
    required String userId,
    required PaymentMethodType type,
    required String providerId,
    required Map<String, dynamic> paymentMethodData,
    bool setAsDefault = false,
  }) async {
    try {
      print('💳 添加支付方式: ${type.label}');

      // 1. 获取支付提供商处理器
      final providerHandler = getProviderHandler(providerId);
      if (providerHandler == null) {
        throw PaymentException('不支持的支付提供商: $providerId');
      }

      // 2. 在支付提供商创建支付方式
      final providerResult = await providerHandler.createPaymentMethod(
        userId: userId,
        type: type,
        paymentMethodData: paymentMethodData,
      );

      // 3. 如果设为默认，先取消其他默认支付方式
      if (setAsDefault) {
        await _clearDefaultPaymentMethods(userId);
      }

      // 4. 创建支付方式记录
      final paymentMethod = PaymentMethod(
        id: _generatePaymentMethodId(),
        userId: userId,
        type: type,
        providerId: providerId,
        externalTokenId: providerResult.tokenId,
        cardLast4: providerResult.cardLast4,
        cardBrand: providerResult.cardBrand,
        cardExpMonth: providerResult.cardExpMonth,
        cardExpYear: providerResult.cardExpYear,
        cardHolderName: providerResult.cardHolderName,
        email: providerResult.email,
        isDefault: setAsDefault,
        isActive: true,
        metadata: providerResult.metadata,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 5. 保存到数据库
      await _savePaymentMethodToDatabase(paymentMethod);

      print('✅ 支付方式添加成功');
      return paymentMethod;

    } catch (e) {
      print('❌ 添加支付方式失败: $e');
      rethrow;
    }
  }

  /// 获取用户支付方式列表
  Future<List<PaymentMethod>> getUserPaymentMethods(String userId) async {
    try {
      final response = await _supabase
          .from('payment_methods')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      return response.map((data) => PaymentMethod.fromJson(data)).toList();

    } catch (e) {
      print('❌ 获取支付方式列表失败: $e');
      throw PaymentException('获取支付方式列表失败: $e');
    }
  }

  /// 删除支付方式
  Future<void> deletePaymentMethod(String paymentMethodId) async {
    try {
      print('🗑️ 删除支付方式: $paymentMethodId');

      // 1. 获取支付方式信息
      final response = await _supabase
          .from('payment_methods')
          .select()
          .eq('id', paymentMethodId)
          .single();

      final paymentMethod = PaymentMethod.fromJson(response);

      // 2. 在支付提供商删除
      final providerHandler = getProviderHandler(paymentMethod.providerId);
      if (providerHandler != null) {
        await providerHandler.deletePaymentMethod(paymentMethod.externalTokenId);
      }

      // 3. 软删除（标记为不活跃）
      await _supabase
          .from('payment_methods')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentMethodId);

      print('✅ 支付方式删除成功');

    } catch (e) {
      print('❌ 删除支付方式失败: $e');
      rethrow;
    }
  }

  // ========================================
  // 查询方法
  // ========================================

  /// 获取支付意图
  Future<PaymentIntent> getPaymentIntentById(String paymentIntentId) async {
    try {
      final response = await _supabase
          .from('payment_intents')
          .select()
          .eq('id', paymentIntentId)
          .single();

      return PaymentIntent.fromJson(response);

    } catch (e) {
      print('❌ 获取支付意图失败: $e');
      throw PaymentException('支付意图不存在: $paymentIntentId');
    }
  }

  /// 获取支付记录
  Future<List<Payment>> getOrderPayments(String orderId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select()
          .eq('order_id', orderId)
          .order('created_at', ascending: false);

      return response.map((data) => Payment.fromJson(data)).toList();

    } catch (e) {
      print('❌ 获取支付记录失败: $e');
      throw PaymentException('获取支付记录失败: $e');
    }
  }

  // ========================================
  // 私有方法
  // ========================================

  /// 注册默认支付提供商
  void _registerDefaultProviders() {
    // 注册模拟的Stripe处理器
    registerProviderHandler('stripe', MockStripeHandler());
    
    // TODO: 注册其他支付提供商
    // registerProviderHandler('square', SquareHandler());
    // registerProviderHandler('paypal', PayPalHandler());
  }

  /// 保存支付意图到数据库
  Future<void> _savePaymentIntentToDatabase(PaymentIntent paymentIntent) async {
    await _supabase.from('payment_intents').insert(paymentIntent.toJson());
  }

  /// 保存支付记录到数据库
  Future<void> _savePaymentToDatabase(Payment payment) async {
    await _supabase.from('payments').insert(payment.toJson());
  }

  /// 保存支付方式到数据库
  Future<void> _savePaymentMethodToDatabase(PaymentMethod paymentMethod) async {
    await _supabase.from('payment_methods').insert(paymentMethod.toJson());
  }

  /// 更新订单支付意图ID
  Future<void> _updateOrderPaymentIntent(String orderId, String paymentIntentId) async {
    await _supabase
        .from('orders')
        .update({
          'payment_intent_id': paymentIntentId,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', orderId);
  }

  /// 更新支付意图状态
  Future<void> _updatePaymentIntentStatus(
    String paymentIntentId,
    PaymentStatus status, [
    DateTime? confirmedAt,
  ]) async {
    final updateData = {
      'status': status.code,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (confirmedAt != null) {
      updateData['confirmed_at'] = confirmedAt.toIso8601String();
    }

    await _supabase
        .from('payment_intents')
        .update(updateData)
        .eq('id', paymentIntentId);
  }

  /// 更新订单支付状态
  Future<void> _updateOrderPaymentStatus(String orderId, PaymentStatus status) async {
    await _supabase
        .from('orders')
        .update({
          'payment_status': status.code,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', orderId);
  }

  /// 获取订单信息
  Future<Order> _getOrderById(String orderId) async {
    final response = await _supabase
        .from('orders')
        .select()
        .eq('id', orderId)
        .single();

    return Order.fromJson(response);
  }

  /// 获取订单支付记录
  Future<List<Payment>> _getOrderPayments(String orderId) async {
    return await getOrderPayments(orderId);
  }

  /// 获取订单退款记录
  Future<List<Payment>> _getOrderRefunds(String orderId) async {
    final response = await _supabase
        .from('payments')
        .select()
        .eq('order_id', orderId)
        .eq('payment_type', 'refund')
        .order('created_at', ascending: false);

    return response.map((data) => Payment.fromJson(data)).toList();
  }

  /// 清除默认支付方式
  Future<void> _clearDefaultPaymentMethods(String userId) async {
    await _supabase
        .from('payment_methods')
        .update({
          'is_default': false,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('is_default', true);
  }

  /// 生成支付意图ID
  String _generatePaymentIntentId() {
    return 'pi_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomSuffix()}';
  }

  /// 生成支付ID
  String _generatePaymentId() {
    return 'pay_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomSuffix()}';
  }

  /// 生成支付方式ID
  String _generatePaymentMethodId() {
    return 'pm_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomSuffix()}';
  }

  /// 生成随机后缀
  String _generateRandomSuffix() {
    return (1000 + (DateTime.now().microsecond % 9000)).toString();
  }
}

/// 支付提供商处理器接口
abstract class PaymentProviderHandler {
  /// 创建支付意图
  Future<ExternalPaymentIntent> createPaymentIntent({
    required String paymentIntentId,
    required Price amount,
    required PaymentMethod paymentMethod,
    Map<String, dynamic>? metadata,
  });

  /// 确认支付
  Future<ProviderPaymentResult> confirmPayment({
    required String paymentIntentId,
    String? confirmationToken,
    Map<String, dynamic>? additionalData,
  });

  /// 处理退款
  Future<ProviderRefundResult> processRefund({
    required String originalPaymentId,
    required Price amount,
    required String reason,
    Map<String, dynamic>? metadata,
  });

  /// 创建支付方式
  Future<ProviderPaymentMethod> createPaymentMethod({
    required String userId,
    required PaymentMethodType type,
    required Map<String, dynamic> paymentMethodData,
  });

  /// 删除支付方式
  Future<void> deletePaymentMethod(String tokenId);
}

/// 行业支付处理器接口
abstract class IndustryPaymentHandler {
  /// 支付预处理
  Future<void> preprocessPayment(Order order, PaymentMethod paymentMethod);

  /// 支付后处理
  Future<void> postprocessPayment(Order order, Payment payment, bool success);

  /// 退款验证
  Future<ValidationResult> validateRefund(Order order, Price amount, String reason);

  /// 退款后处理
  Future<void> postprocessRefund(Order order, Payment refund, bool success);
}

/// 外部支付意图
class ExternalPaymentIntent {
  final String id;
  final String? clientSecret;
  final String? confirmationMethod;

  ExternalPaymentIntent({
    required this.id,
    this.clientSecret,
    this.confirmationMethod,
  });
}

/// 提供商支付结果
class ProviderPaymentResult {
  final bool success;
  final String message;
  final String? transactionId;
  final String paymentMethodType;
  final double? processingFee;
  final Map<String, dynamic> paymentMethodDetails;
  final Map<String, dynamic> rawResponse;

  ProviderPaymentResult({
    required this.success,
    required this.message,
    this.transactionId,
    required this.paymentMethodType,
    this.processingFee,
    this.paymentMethodDetails = const {},
    this.rawResponse = const {},
  });
}

/// 提供商退款结果
class ProviderRefundResult {
  final bool success;
  final String refundId;
  final String message;
  final Map<String, dynamic>? rawResponse;

  ProviderRefundResult({
    required this.success,
    required this.refundId,
    required this.message,
    this.rawResponse,
  });
}

/// 提供商支付方式
class ProviderPaymentMethod {
  final String tokenId;
  final String? cardLast4;
  final String? cardBrand;
  final int? cardExpMonth;
  final int? cardExpYear;
  final String? cardHolderName;
  final String? email;
  final Map<String, dynamic> metadata;

  ProviderPaymentMethod({
    required this.tokenId,
    this.cardLast4,
    this.cardBrand,
    this.cardExpMonth,
    this.cardExpYear,
    this.cardHolderName,
    this.email,
    this.metadata = const {},
  });
}

/// 模拟Stripe处理器（用于开发测试）
class MockStripeHandler implements PaymentProviderHandler {
  @override
  Future<ExternalPaymentIntent> createPaymentIntent({
    required String paymentIntentId,
    required Price amount,
    required PaymentMethod paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return ExternalPaymentIntent(
      id: paymentIntentId,
      clientSecret: '${paymentIntentId}_secret_${DateTime.now().millisecondsSinceEpoch}',
      confirmationMethod: 'automatic',
    );
  }

  @override
  Future<ProviderPaymentResult> confirmPayment({
    required String paymentIntentId,
    String? confirmationToken,
    Map<String, dynamic>? additionalData,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    // 模拟95%成功率
    final success = DateTime.now().millisecond % 100 < 95;
    
    return ProviderPaymentResult(
      success: success,
      message: success ? '支付成功' : '支付失败，请检查卡片信息',
      transactionId: success ? 'txn_${DateTime.now().millisecondsSinceEpoch}' : null,
      paymentMethodType: 'credit_card',
      processingFee: success ? 1.50 : null,
      paymentMethodDetails: {
        'brand': 'visa',
        'last4': '4242',
        'exp_month': 12,
        'exp_year': 2025,
      },
      rawResponse: {
        'stripe_payment_intent_id': paymentIntentId,
        'status': success ? 'succeeded' : 'failed',
        'amount': 4567,
        'currency': 'cad',
      },
    );
  }

  @override
  Future<ProviderRefundResult> processRefund({
    required String originalPaymentId,
    required Price amount,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final refundId = 're_${DateTime.now().millisecondsSinceEpoch}';
    
    return ProviderRefundResult(
      success: true,
      refundId: refundId,
      message: '退款处理成功',
      rawResponse: {
        'stripe_refund_id': refundId,
        'amount': (amount.amount * 100).round(),
        'currency': amount.currency.toLowerCase(),
        'status': 'succeeded',
      },
    );
  }

  @override
  Future<ProviderPaymentMethod> createPaymentMethod({
    required String userId,
    required PaymentMethodType type,
    required Map<String, dynamic> paymentMethodData,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final tokenId = 'pm_${DateTime.now().millisecondsSinceEpoch}';
    
    return ProviderPaymentMethod(
      tokenId: tokenId,
      cardLast4: '4242',
      cardBrand: 'visa',
      cardExpMonth: paymentMethodData['exp_month'],
      cardExpYear: paymentMethodData['exp_year'],
      cardHolderName: paymentMethodData['cardholder_name'],
      metadata: {
        'stripe_payment_method_id': tokenId,
        'fingerprint': 'fingerprint_${DateTime.now().millisecondsSinceEpoch}',
      },
    );
  }

  @override
  Future<void> deletePaymentMethod(String tokenId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // 模拟删除成功
    print('🗑️ Stripe支付方式已删除: $tokenId');
  }
}

// PaymentException moved to base_models.dart to avoid duplication
