import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/payment_models.dart';
import '../../models/base_models.dart';
import '../universal_payment_service.dart';
import '../../utils/app_logger.dart';

/// Stripe支付处理器
/// 
/// 实现PaymentProviderHandler接口，提供Stripe支付功能
/// 包括支付意图创建、支付确认、退款处理等核心功能
class StripePaymentHandler implements PaymentProviderHandler {

  /// 初始化Stripe SDK
  static Future<void> initialize({
    required String publishableKey,
    String? merchantIdentifier,
  }) async {
    try {
      stripe.Stripe.publishableKey = publishableKey;
      if (merchantIdentifier != null) {
        stripe.Stripe.merchantIdentifier = merchantIdentifier;
      }
      
      await stripe.Stripe.instance.applySettings();
      AppLogger.info('[StripePaymentHandler] Stripe SDK initialized successfully');
    } catch (e) {
      AppLogger.error('[StripePaymentHandler] Failed to initialize Stripe SDK: $e');
      rethrow;
    }
  }

  @override
  Future<ExternalPaymentIntent> createPaymentIntent({
    required String paymentIntentId,
    required Price amount,
    required PaymentMethod paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      AppLogger.info('[StripePaymentHandler] Creating payment intent: $paymentIntentId');
      
      // 调用Supabase Edge Function创建Stripe PaymentIntent
      final response = await Supabase.instance.client.functions.invoke(
        'create-payment-intent',
        body: {
          'amount': (amount.amount * 100).round(), // Stripe uses cents
          'currency': amount.currency.toLowerCase(),
          'customer_id': paymentMethod.userId,
          'order_id': paymentIntentId,
          'metadata': metadata ?? {},
        },
      );

      if (response.status != 200) {
        throw PaymentException('Failed to create payment intent: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      
      return ExternalPaymentIntent(
        id: data['id'] ?? '',
        clientSecret: data['client_secret'],
        confirmationMethod: 'automatic',
      );
      
    } catch (e) {
      AppLogger.error('[StripePaymentHandler] Error creating payment intent: $e');
      throw PaymentException('Failed to create payment intent: $e');
    }
  }

  @override
  Future<ProviderPaymentResult> confirmPayment({
    required String paymentIntentId,
    String? confirmationToken,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      AppLogger.info('[StripePaymentHandler] Confirming payment intent: $paymentIntentId');
      
      // 使用Flutter Stripe SDK确认支付
      final paymentIntent = await stripe.Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntentId,
        data: stripe.PaymentMethodParams.card(
          paymentMethodData: stripe.PaymentMethodData(
            billingDetails: additionalData != null 
              ? stripe.BillingDetails.fromJson(additionalData)
              : null,
          ),
        ),
      );

      // 调用后端验证支付结果
      final response = await Supabase.instance.client.functions.invoke(
        'confirm-payment',
        body: {
          'payment_intent_id': paymentIntent.id,
          'customer_id': additionalData?['customer_id'],
        },
      );

      if (response.status != 200) {
        throw PaymentException('Failed to confirm payment: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      
      return ProviderPaymentResult(
        success: true,
        message: 'Payment confirmed successfully',
        transactionId: paymentIntent.id!,
        paymentMethodType: 'credit_card',
        processingFee: _calculateProcessingFee(data['amount'] ?? 0.0),
        paymentMethodDetails: _extractPaymentMethodDetails(data),
        rawResponse: data,
      );
      
    } on stripe.StripeException catch (e) {
      AppLogger.error('[StripePaymentHandler] Stripe error confirming payment: ${e.error}');
      return ProviderPaymentResult(
        success: false,
        message: 'Stripe payment failed: ${e.error.localizedMessage}',
        paymentMethodType: 'credit_card',
        rawResponse: {'error': e.error.toJson()},
      );
    } catch (e) {
      AppLogger.error('[StripePaymentHandler] Error confirming payment: $e');
      return ProviderPaymentResult(
        success: false,
        message: 'Failed to confirm payment: $e',
        paymentMethodType: 'credit_card',
        rawResponse: {},
      );
    }
  }

  @override
  Future<ProviderRefundResult> processRefund({
    required String originalPaymentId,
    required Price amount,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      AppLogger.info('[StripePaymentHandler] Processing refund for payment: $originalPaymentId');
      
      // 调用Supabase Edge Function处理退款
      final response = await Supabase.instance.client.functions.invoke(
        'process-refund',
        body: {
          'payment_id': originalPaymentId,
          'amount': (amount.amount * 100).round(), // Stripe uses cents
          'reason': reason,
          'metadata': metadata ?? {},
        },
      );

      if (response.status != 200) {
        throw PaymentException('Failed to process refund: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      
      return ProviderRefundResult(
        success: true,
        refundId: data['id'] ?? '',
        message: 'Refund processed successfully',
        rawResponse: data,
      );
      
    } catch (e) {
      AppLogger.error('[StripePaymentHandler] Error processing refund: $e');
      return ProviderRefundResult(
        success: false,
        refundId: '',
        message: 'Failed to process refund: $e',
        rawResponse: {},
      );
    }
  }

  @override
  Future<ProviderPaymentMethod> createPaymentMethod({
    required String userId,
    required PaymentMethodType type,
    required Map<String, dynamic> paymentMethodData,
  }) async {
    try {
      AppLogger.info('[StripePaymentHandler] Creating payment method for user: $userId');
      
      final response = await Supabase.instance.client.functions.invoke(
        'create-payment-method',
        body: {
          'user_id': userId,
          'type': type.code,
          'payment_method_data': paymentMethodData,
        },
      );

      if (response.status != 200) {
        throw PaymentException('Failed to create payment method: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      
      return ProviderPaymentMethod(
        tokenId: data['id'] ?? '',
        cardLast4: data['card']?['last4'],
        cardBrand: data['card']?['brand'],
        cardExpMonth: data['card']?['exp_month'],
        cardExpYear: data['card']?['exp_year'],
        cardHolderName: data['card']?['holder_name'],
        email: data['email'],
        metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      );
      
    } catch (e) {
      AppLogger.error('[StripePaymentHandler] Error creating payment method: $e');
      throw PaymentException('Failed to create payment method: $e');
    }
  }

  @override
  Future<void> deletePaymentMethod(String tokenId) async {
    try {
      AppLogger.info('[StripePaymentHandler] Deleting payment method: $tokenId');
      
      final response = await Supabase.instance.client.functions.invoke(
        'delete-payment-method',
        body: {
          'payment_method_id': tokenId,
        },
      );

      if (response.status != 200) {
        throw PaymentException('Failed to delete payment method: ${response.data}');
      }

      AppLogger.info('[StripePaymentHandler] Payment method deleted successfully');
      
    } catch (e) {
      AppLogger.error('[StripePaymentHandler] Error deleting payment method: $e');
      throw PaymentException('Failed to delete payment method: $e');
    }
  }

  /// 计算处理费用（基于金额的2.9% + $0.30）
  double _calculateProcessingFee(double amount) {
    return (amount * 0.029) + 0.30;
  }

  /// 提取支付方式详情
  Map<String, dynamic> _extractPaymentMethodDetails(Map<String, dynamic> data) {
    final paymentMethod = data['payment_method'];
    if (paymentMethod is Map<String, dynamic>) {
      return {
        'type': paymentMethod['type'] ?? 'card',
        'brand': paymentMethod['card']?['brand'],
        'last4': paymentMethod['card']?['last4'],
        'exp_month': paymentMethod['card']?['exp_month'],
        'exp_year': paymentMethod['card']?['exp_year'],
      };
    }
    return {
      'type': 'card',
      'brand': 'unknown',
      'last4': '0000',
    };
  }
}

// PaymentException moved to base_models.dart to avoid duplication