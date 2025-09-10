/// 支付管理器
/// 统一处理所有支付相关业务逻辑，支持多种支付方式和风险控制

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/payment_models.dart';
import '../models/order_models.dart';
import '../utils/app_logger.dart';

/// 支付方式工厂抽象
abstract class PaymentMethodFactory {
  PaymentMethodHandler createHandler(PaymentMethodType type);
  List<PaymentMethodType> getSupportedMethods();
  bool isMethodAvailable(PaymentMethodType type);
}

/// 支付方式处理器抽象
abstract class PaymentMethodHandler {
  String get name;
  PaymentMethodType get type;
  List<String> get supportedCurrencies;
  
  Future<PaymentResult> processPayment(PaymentRequest request);
  Future<RefundResult> processRefund(RefundRequest request);
  Future<bool> validatePaymentData(Map<String, dynamic> data);
  Future<PaymentMethod> savePaymentMethod(String userId, Map<String, dynamic> data);
}

/// 风险控制器
class RiskController {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// 评估支付风险
  Future<RiskAssessment> assessRisk(PaymentRequest request) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw PaymentException('用户未认证');
      }

      // 基础风险因子检查
      final riskFactors = <String>[];
      double riskScore = 0.0;

      // 检查金额异常
      if (request.amount > 1000) {
        riskFactors.add('high_amount');
        riskScore += 30;
      }

      // 检查用户历史
      final userHistory = await _getUserPaymentHistory(userId);
      if (userHistory.length < 3) {
        riskFactors.add('new_user');
        riskScore += 20;
      }

      // 检查时间异常（深夜支付）
      final now = DateTime.now();
      if (now.hour >= 23 || now.hour <= 5) {
        riskFactors.add('unusual_time');
        riskScore += 10;
      }

      // 检查频繁支付
      final recentPayments = await _getRecentPayments(userId, const Duration(hours: 1));
      if (recentPayments.length >= 3) {
        riskFactors.add('frequent_payments');
        riskScore += 25;
      }

      // 确定风险等级
      RiskLevel riskLevel;
      if (riskScore <= 20) {
        riskLevel = RiskLevel.low;
      } else if (riskScore <= 50) {
        riskLevel = RiskLevel.medium;
      } else if (riskScore <= 80) {
        riskLevel = RiskLevel.high;
      } else {
        riskLevel = RiskLevel.blocked;
      }

      return RiskAssessment(
        paymentId: '', // 支付创建后更新
        riskLevel: riskLevel,
        riskScore: riskScore,
        riskFactors: riskFactors,
        analysis: {
          'user_history_count': userHistory.length,
          'recent_payments_count': recentPayments.length,
          'payment_hour': now.hour,
          'amount': request.amount,
        },
        requiresManualReview: riskLevel == RiskLevel.high,
        assessedAt: DateTime.now(),
      );
    } catch (e) {
      AppLogger.error('[RiskController] Risk assessment failed: $e');
      // 默认中等风险
      return RiskAssessment(
        paymentId: '',
        riskLevel: RiskLevel.medium,
        riskScore: 50.0,
        riskFactors: ['assessment_error'],
        analysis: {'error': e.toString()},
        requiresManualReview: true,
        assessedAt: DateTime.now(),
      );
    }
  }

  /// 获取用户支付历史
  Future<List<Payment>> _getUserPaymentHistory(String userId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('*')
          .eq('user_id', userId)
          .eq('status', 'completed')
          .order('created_at', ascending: false)
          .limit(10);

      return response.map<Payment>((data) => Payment.fromJson(data)).toList();
    } catch (e) {
      AppLogger.error('[RiskController] Failed to get user payment history: $e');
      return [];
    }
  }

  /// 获取最近支付记录
  Future<List<Payment>> _getRecentPayments(String userId, Duration duration) async {
    try {
      final cutoffTime = DateTime.now().subtract(duration);
      final response = await _supabase
          .from('payments')
          .select('*')
          .eq('user_id', userId)
          .gte('created_at', cutoffTime.toIso8601String())
          .order('created_at', ascending: false);

      return response.map<Payment>((data) => Payment.fromJson(data)).toList();
    } catch (e) {
      AppLogger.error('[RiskController] Failed to get recent payments: $e');
      return [];
    }
  }
}

/// 支付状态管理器
class PaymentStateManager {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 创建支付记录
  Future<Payment> createPayment({
    required String orderId,
    required String paymentMethod,
    required String paymentProvider,
    required double amount,
    String currency = 'CAD',
    String? paymentIntentId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw PaymentException('用户未认证');
      }

      final paymentData = {
        'order_id': orderId,
        'user_id': userId,
        'payment_method': paymentMethod,
        'payment_provider': paymentProvider,
        'payment_intent_id': paymentIntentId,
        'amount': amount,
        'currency': currency,
        'status': PaymentStatus.pending.name,
        'metadata': metadata,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('payments')
          .insert(paymentData)
          .select()
          .single();

      return Payment.fromJson(response);
    } catch (e) {
      AppLogger.error('[PaymentStateManager] Failed to create payment: $e');
      throw PaymentException('创建支付记录失败', originalError: e);
    }
  }

  /// 更新支付状态
  Future<Payment> updatePaymentStatus({
    required String paymentId,
    required PaymentStatus status,
    String? failureReason,
    Map<String, dynamic>? providerResponse,
  }) async {
    try {
      final updateData = {
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (status == PaymentStatus.completed) {
        updateData['processed_at'] = DateTime.now().toIso8601String();
      }

      if (failureReason != null) {
        updateData['failure_reason'] = failureReason;
      }

      if (providerResponse != null) {
        updateData['provider_response'] = providerResponse;
      }

      final response = await _supabase
          .from('payments')
          .update(updateData)
          .eq('id', paymentId)
          .select()
          .single();

      return Payment.fromJson(response);
    } catch (e) {
      AppLogger.error('[PaymentStateManager] Failed to update payment status: $e');
      throw PaymentException('更新支付状态失败', originalError: e);
    }
  }

  /// 获取支付记录
  Future<Payment?> getPayment(String paymentId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('*')
          .eq('id', paymentId)
          .maybeSingle();

      return response != null ? Payment.fromJson(response) : null;
    } catch (e) {
      AppLogger.error('[PaymentStateManager] Failed to get payment: $e');
      return null;
    }
  }

  /// 获取订单的支付记录
  Future<List<Payment>> getOrderPayments(String orderId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('*')
          .eq('order_id', orderId)
          .order('created_at', ascending: false);

      return response.map<Payment>((data) => Payment.fromJson(data)).toList();
    } catch (e) {
      AppLogger.error('[PaymentStateManager] Failed to get order payments: $e');
      return [];
    }
  }
}

/// 主支付管理器
class PaymentManager extends GetxController {
  final PaymentMethodFactory _methodFactory;
  final RiskController _riskController;
  final PaymentStateManager _stateManager;
  final SupabaseClient _supabase = Supabase.instance.client;

  PaymentManager({
    required PaymentMethodFactory methodFactory,
    required RiskController riskController,
    required PaymentStateManager stateManager,
  })  : _methodFactory = methodFactory,
        _riskController = riskController,
        _stateManager = stateManager;

  /// 处理支付
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    try {
      AppLogger.info('[PaymentManager] Processing payment for order: ${request.orderId}');

      // 1. 风险评估
      final riskAssessment = await _riskController.assessRisk(request);
      
      if (riskAssessment.riskLevel == RiskLevel.blocked) {
        throw PaymentException(
          '支付被阻止，风险等级过高',
          code: 'PAYMENT_BLOCKED',
          status: PaymentStatus.failed,
        );
      }

      // 2. 确定支付方式
      PaymentMethodType? paymentType;
      if (request.paymentMethodId != null) {
        // 使用已保存的支付方式
        final savedMethod = await _getPaymentMethod(request.paymentMethodId!);
        if (savedMethod == null) {
          throw PaymentException('支付方式不存在');
        }
        paymentType = savedMethod.type;
      } else if (request.paymentType != null) {
        paymentType = request.paymentType!;
      } else {
        throw PaymentException('未指定支付方式');
      }

      // 3. 检查支付方式是否可用
      if (!_methodFactory.isMethodAvailable(paymentType)) {
        throw PaymentException('支付方式不可用');
      }

      // 4. 创建支付记录
      final payment = await _stateManager.createPayment(
        orderId: request.orderId,
        paymentMethod: paymentType.name,
        paymentProvider: _getProviderForMethod(paymentType),
        amount: request.amount,
        currency: request.currency,
        metadata: request.metadata,
      );

      // 5. 更新风险评估中的支付ID
      riskAssessment = RiskAssessment(
        paymentId: payment.id,
        riskLevel: riskAssessment.riskLevel,
        riskScore: riskAssessment.riskScore,
        riskFactors: riskAssessment.riskFactors,
        analysis: riskAssessment.analysis,
        requiresManualReview: riskAssessment.requiresManualReview,
        assessedAt: riskAssessment.assessedAt,
      );

      // 6. 如果需要人工审核，暂停处理
      if (riskAssessment.requiresManualReview) {
        AppLogger.info('[PaymentManager] Payment requires manual review: ${payment.id}');
        return PaymentResult(
          paymentId: payment.id,
          status: PaymentStatus.processing,
          errorMessage: '支付需要人工审核，请稍后查看状态',
        );
      }

      // 7. 调用具体支付方式处理器
      final handler = _methodFactory.createHandler(paymentType);
      final result = await handler.processPayment(request);

      // 8. 更新支付状态
      await _stateManager.updatePaymentStatus(
        paymentId: payment.id,
        status: result.status,
        failureReason: result.errorMessage,
        providerResponse: result.providerResponse,
      );

      // 9. 如果支付成功，更新订单状态
      if (result.isSuccess) {
        await _updateOrderPaymentStatus(request.orderId, 'completed');
      }

      return PaymentResult(
        paymentId: payment.id,
        status: result.status,
        clientSecret: result.clientSecret,
        confirmationUrl: result.confirmationUrl,
        errorMessage: result.errorMessage,
        errorCode: result.errorCode,
        providerResponse: result.providerResponse,
        expiresAt: result.expiresAt,
      );

    } catch (e) {
      AppLogger.error('[PaymentManager] Payment processing failed: $e');
      if (e is PaymentException) {
        rethrow;
      }
      throw PaymentException('支付处理失败', originalError: e);
    }
  }

  /// 处理退款
  Future<RefundResult> processRefund(RefundRequest request) async {
    try {
      AppLogger.info('[PaymentManager] Processing refund for payment: ${request.paymentId}');

      // 1. 获取原支付记录
      final payment = await _stateManager.getPayment(request.paymentId);
      if (payment == null) {
        throw PaymentException('支付记录不存在');
      }

      if (payment.status != PaymentStatus.completed) {
        throw PaymentException('只能对已完成的支付进行退款');
      }

      // 2. 验证退款金额
      final refundAmount = request.amount ?? payment.amount;
      if (refundAmount > payment.amount) {
        throw PaymentException('退款金额不能超过原支付金额');
      }

      // 3. 创建退款记录
      final refundData = {
        'payment_id': request.paymentId,
        'order_id': request.orderId,
        'refund_reason': request.reason,
        'refund_type': refundAmount == payment.amount ? 'full' : 'partial',
        'requested_amount': refundAmount,
        'status': RefundStatus.pending.name,
        'created_at': DateTime.now().toIso8601String(),
      };

      final refundResponse = await _supabase
          .from('refunds')
          .insert(refundData)
          .select()
          .single();

      final refund = Refund.fromJson(refundResponse);

      // 4. 调用支付方式处理器进行退款
      final paymentType = PaymentMethodType.values.firstWhere(
        (e) => e.name == payment.paymentMethod,
        orElse: () => PaymentMethodType.creditCard,
      );

      final handler = _methodFactory.createHandler(paymentType);
      final result = await handler.processRefund(request);

      // 5. 更新退款状态
      await _supabase
          .from('refunds')
          .update({
            'status': result.status.name,
            'approved_amount': result.approvedAmount,
            'provider_refund_id': result.providerRefundId,
            'processed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', refund.id);

      // 6. 如果退款成功，更新支付状态
      if (result.status == RefundStatus.completed) {
        final newPaymentStatus = refundAmount == payment.amount 
            ? PaymentStatus.refunded 
            : PaymentStatus.partiallyRefunded;
        
        await _stateManager.updatePaymentStatus(
          paymentId: payment.id,
          status: newPaymentStatus,
        );
      }

      return result;

    } catch (e) {
      AppLogger.error('[PaymentManager] Refund processing failed: $e');
      if (e is PaymentException) {
        rethrow;
      }
      throw PaymentException('退款处理失败', originalError: e);
    }
  }

  /// 获取支付状态
  Future<PaymentStatus> getPaymentStatus(String paymentId) async {
    try {
      final payment = await _stateManager.getPayment(paymentId);
      return payment?.status ?? PaymentStatus.failed;
    } catch (e) {
      AppLogger.error('[PaymentManager] Failed to get payment status: $e');
      return PaymentStatus.failed;
    }
  }

  /// 获取用户的支付方式列表
  Future<List<PaymentMethod>> getUserPaymentMethods(String userId) async {
    try {
      final response = await _supabase
          .from('payment_methods')
          .select('*')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return response.map<PaymentMethod>((data) => PaymentMethod.fromJson(data)).toList();
    } catch (e) {
      AppLogger.error('[PaymentManager] Failed to get user payment methods: $e');
      return [];
    }
  }

  /// 保存支付方式
  Future<PaymentMethod> savePaymentMethod({
    required String userId,
    required PaymentMethodType type,
    required Map<String, dynamic> paymentData,
    bool setAsDefault = false,
  }) async {
    try {
      final handler = _methodFactory.createHandler(type);
      final paymentMethod = await handler.savePaymentMethod(userId, paymentData);

      if (setAsDefault) {
        await _setDefaultPaymentMethod(userId, paymentMethod.id);
      }

      return paymentMethod;
    } catch (e) {
      AppLogger.error('[PaymentManager] Failed to save payment method: $e');
      throw PaymentException('保存支付方式失败', originalError: e);
    }
  }

  /// 删除支付方式
  Future<void> deletePaymentMethod(String paymentMethodId) async {
    try {
      await _supabase
          .from('payment_methods')
          .update({'is_active': false})
          .eq('id', paymentMethodId);
    } catch (e) {
      AppLogger.error('[PaymentManager] Failed to delete payment method: $e');
      throw PaymentException('删除支付方式失败', originalError: e);
    }
  }

  /// 获取支付方式
  Future<PaymentMethod?> _getPaymentMethod(String paymentMethodId) async {
    try {
      final response = await _supabase
          .from('payment_methods')
          .select('*')
          .eq('id', paymentMethodId)
          .eq('is_active', true)
          .maybeSingle();

      return response != null ? PaymentMethod.fromJson(response) : null;
    } catch (e) {
      AppLogger.error('[PaymentManager] Failed to get payment method: $e');
      return null;
    }
  }

  /// 设置默认支付方式
  Future<void> _setDefaultPaymentMethod(String userId, String paymentMethodId) async {
    try {
      // 先取消所有默认设置
      await _supabase
          .from('payment_methods')
          .update({'is_default': false})
          .eq('user_id', userId);

      // 设置新的默认支付方式
      await _supabase
          .from('payment_methods')
          .update({'is_default': true})
          .eq('id', paymentMethodId);
    } catch (e) {
      AppLogger.error('[PaymentManager] Failed to set default payment method: $e');
    }
  }

  /// 更新订单支付状态
  Future<void> _updateOrderPaymentStatus(String orderId, String paymentStatus) async {
    try {
      await _supabase
          .from('orders')
          .update({
            'payment_status': paymentStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);
    } catch (e) {
      AppLogger.error('[PaymentManager] Failed to update order payment status: $e');
    }
  }

  /// 获取支付方式对应的提供商
  String _getProviderForMethod(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        return 'stripe';
      case PaymentMethodType.applePay:
      case PaymentMethodType.googlePay:
        return 'stripe';
      case PaymentMethodType.paypal:
        return 'paypal';
      case PaymentMethodType.interac:
        return 'interac';
      default:
        return 'stripe';
    }
  }
}

/// 支付管理器工厂
class PaymentManagerFactory {
  static PaymentManager create() {
    final methodFactory = DefaultPaymentMethodFactory();
    final riskController = RiskController();
    final stateManager = PaymentStateManager();

    return PaymentManager(
      methodFactory: methodFactory,
      riskController: riskController,
      stateManager: stateManager,
    );
  }
}

/// 默认支付方式工厂实现
class DefaultPaymentMethodFactory implements PaymentMethodFactory {
  final Map<PaymentMethodType, PaymentMethodHandler> _handlers = {};

  DefaultPaymentMethodFactory() {
    // 注册默认支付方式处理器
    _handlers[PaymentMethodType.creditCard] = StripePaymentHandler();
    _handlers[PaymentMethodType.debitCard] = StripePaymentHandler();
    _handlers[PaymentMethodType.applePay] = StripePaymentHandler();
    _handlers[PaymentMethodType.googlePay] = StripePaymentHandler();
    // TODO: 添加其他支付方式处理器
  }

  @override
  PaymentMethodHandler createHandler(PaymentMethodType type) {
    final handler = _handlers[type];
    if (handler == null) {
      throw PaymentException('不支持的支付方式: $type');
    }
    return handler;
  }

  @override
  List<PaymentMethodType> getSupportedMethods() {
    return _handlers.keys.toList();
  }

  @override
  bool isMethodAvailable(PaymentMethodType type) {
    return _handlers.containsKey(type);
  }
}

/// Stripe支付处理器（示例实现）
class StripePaymentHandler implements PaymentMethodHandler {
  @override
  String get name => 'Stripe';

  @override
  PaymentMethodType get type => PaymentMethodType.creditCard;

  @override
  List<String> get supportedCurrencies => ['CAD', 'USD'];

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    // TODO: 实现Stripe支付处理逻辑
    await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求
    
    return PaymentResult(
      paymentId: 'stripe_${DateTime.now().millisecondsSinceEpoch}',
      status: PaymentStatus.completed,
      clientSecret: 'pi_test_client_secret',
    );
  }

  @override
  Future<RefundResult> processRefund(RefundRequest request) async {
    // TODO: 实现Stripe退款处理逻辑
    await Future.delayed(const Duration(seconds: 1));
    
    return RefundResult(
      refundId: 'ref_${DateTime.now().millisecondsSinceEpoch}',
      status: RefundStatus.completed,
      requestedAmount: request.amount ?? 0,
      approvedAmount: request.amount ?? 0,
    );
  }

  @override
  Future<bool> validatePaymentData(Map<String, dynamic> data) async {
    // TODO: 实现支付数据验证
    return data.containsKey('card_number') && data.containsKey('exp_month');
  }

  @override
  Future<PaymentMethod> savePaymentMethod(String userId, Map<String, dynamic> data) async {
    // TODO: 实现保存支付方式到Stripe和本地数据库
    throw UnimplementedError();
  }
}
