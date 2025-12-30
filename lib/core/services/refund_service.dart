import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_models.dart';
import '../models/base_models.dart';
import '../utils/app_logger.dart';
import 'payment_providers/stripe_payment_handler.dart';

/// 退款服务
/// 处理退款申请、审核、处理、状态同步等完整流程
class RefundService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  late final StripePaymentHandler _stripeHandler;

  @override
  void onInit() {
    super.onInit();
    _stripeHandler = StripePaymentHandler();
  }

  // ========================================
  // 1. 退款申请
  // ========================================

  /// 申请退款
  ///
  /// [orderId] 订单ID
  /// [reason] 退款原因
  /// [refundType] 退款类型：full（全额）, partial（部分）
  /// [amount] 退款金额（部分退款时必填）
  /// [description] 详细说明
  /// [images] 证明图片URL列表
  Future<RefundApplication> applyRefund({
    required String orderId,
    required String reason,
    String refundType = 'full',
    double? amount,
    String? description,
    List<String>? images,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // 1. 验证订单
      final order = await _validateOrder(orderId, currentUser.id);

      // 2. 检查是否已有待处理的退款申请
      final existingRefund = await _supabase
          .from('refunds')
          .select('id, status')
          .eq('order_id', orderId)
          .inFilter('status', ['pending', 'approved', 'processing'])
          .maybeSingle();

      if (existingRefund != null) {
        throw Exception('该订单已有待处理的退款申请');
      }

      // 3. 计算退款金额
      final refundAmount = refundType == 'full'
          ? order['total_price'] as double
          : amount;

      if (refundAmount == null || refundAmount <= 0) {
        throw Exception('退款金额无效');
      }

      if (refundAmount > order['total_price']) {
        throw Exception('退款金额不能超过订单金额');
      }

      // 4. 创建退款申请
      final refundData = {
        'order_id': orderId,
        'user_id': currentUser.id,
        'provider_id': order['provider_id'],
        'refund_type': refundType,
        'amount': refundAmount,
        'original_amount': order['total_price'],
        'reason': reason,
        'reason_type': _categorizeReason(reason),
        'description': description,
        'images': images,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('refunds')
          .insert(refundData)
          .select()
          .single();

      final refund = RefundApplication.fromJson(response);

      // 5. 记录退款日志
      await _logRefundEvent(
        refundId: refund.id,
        event: 'refund_applied',
        details: {
          'order_id': orderId,
          'amount': refundAmount,
          'reason': reason,
        },
      );

      // 6. 发送通知（异步，不阻塞）
      _sendRefundNotification(
        userId: currentUser.id,
        providerId: order['provider_id'],
        refundId: refund.id,
        type: 'refund_applied',
      ).catchError((e) {
        AppLogger.error('[RefundService] Failed to send notification: $e');
      });

      AppLogger.info('[RefundService] Refund application created: ${refund.id}');
      return refund;
    } catch (e) {
      AppLogger.error('[RefundService] Error applying refund: $e');
      throw Exception('Failed to apply refund: $e');
    }
  }

  // ========================================
  // 2. 退款审核
  // ========================================

  /// 审核退款申请（服务商或管理员）
  Future<void> reviewRefund({
    required String refundId,
    required bool approved,
    String? reviewNote,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // 1. 获取退款信息
      final refund = await _supabase
          .from('refunds')
          .select('*, orders!inner(provider_id)')
          .eq('id', refundId)
          .single();

      // 2. 验证权限（必须是服务商或管理员）
      final isProvider = refund['orders']['provider_id'] == currentUser.id;
      final isAdmin = await _isAdmin(currentUser.id);

      if (!isProvider && !isAdmin) {
        throw Exception('无权限审核此退款申请');
      }

      // 3. 检查状态
      if (refund['status'] != 'pending') {
        throw Exception('只能审核待处理的退款申请');
      }

      // 4. 更新退款状态
      final newStatus = approved ? 'approved' : 'rejected';
      await _supabase.from('refunds').update({
        'status': newStatus,
        'reviewed_by': currentUser.id,
        'reviewed_at': DateTime.now().toIso8601String(),
        'review_note': reviewNote,
      }).eq('id', refundId);

      // 5. 如果批准，自动开始处理退款
      if (approved) {
        await processRefund(refundId);
      }

      // 6. 记录日志
      await _logRefundEvent(
        refundId: refundId,
        event: approved ? 'refund_approved' : 'refund_rejected',
        details: {
          'reviewed_by': currentUser.id,
          'review_note': reviewNote,
        },
      );

      // 7. 发送通知
      _sendRefundNotification(
        userId: refund['user_id'],
        providerId: refund['provider_id'],
        refundId: refundId,
        type: approved ? 'refund_approved' : 'refund_rejected',
      ).catchError((e) {
        AppLogger.error('[RefundService] Failed to send notification: $e');
      });

      AppLogger.info('[RefundService] Refund $refundId ${approved ? "approved" : "rejected"}');
    } catch (e) {
      AppLogger.error('[RefundService] Error reviewing refund: $e');
      throw Exception('Failed to review refund: $e');
    }
  }

  // ========================================
  // 3. 退款处理
  // ========================================

  /// 处理退款（调用Stripe API）
  Future<void> processRefund(String refundId) async {
    try {
      AppLogger.info('[RefundService] Processing refund: $refundId');

      // 1. 获取退款和订单信息
      final refund = await _supabase
          .from('refunds')
          .select('*, orders!inner(payment_intent_id)')
          .eq('id', refundId)
          .single();

      // 2. 检查状态
      if (refund['status'] != 'approved') {
        throw Exception('只能处理已批准的退款');
      }

      // 3. 更新状态为处理中
      await _supabase.from('refunds').update({
        'status': 'processing',
        'processing_started_at': DateTime.now().toIso8601String(),
      }).eq('id', refundId);

      // 4. 调用Stripe退款API
      final paymentIntentId = refund['orders']['payment_intent_id'] as String?;
      if (paymentIntentId == null) {
        throw Exception('订单没有关联的支付意图');
      }

      final refundResult = await _stripeHandler.processRefund(
        originalPaymentId: paymentIntentId,
        amount: Price(
          amount: refund['amount'] as double,
          currency: 'USD', // TODO: 从订单获取货币
        ),
        reason: refund['reason'] as String,
        metadata: {
          'refund_id': refundId,
          'order_id': refund['order_id'],
        },
      );

      // 5. 更新退款状态
      if (refundResult.success) {
        await _supabase.from('refunds').update({
          'status': 'completed',
          'stripe_refund_id': refundResult.refundId,
          'completed_at': DateTime.now().toIso8601String(),
          'provider_response': refundResult.rawResponse,
        }).eq('id', refundId);

        // 更新订单状态
        await _supabase.from('orders').update({
          'order_status': 'refunded',
          'refunded_at': DateTime.now().toIso8601String(),
        }).eq('id', refund['order_id']);

        AppLogger.info('[RefundService] Refund completed successfully: $refundId');
      } else {
        // 退款失败
        await _supabase.from('refunds').update({
          'status': 'failed',
          'error_message': refundResult.message,
          'failed_at': DateTime.now().toIso8601String(),
        }).eq('id', refundId);

        AppLogger.error('[RefundService] Refund failed: ${refundResult.message}');
        throw Exception('退款处理失败: ${refundResult.message}');
      }

      // 6. 记录日志
      await _logRefundEvent(
        refundId: refundId,
        event: refundResult.success ? 'refund_completed' : 'refund_failed',
        details: {
          'stripe_refund_id': refundResult.refundId,
          'message': refundResult.message,
        },
      );

      // 7. 发送通知
      _sendRefundNotification(
        userId: refund['user_id'],
        providerId: refund['provider_id'],
        refundId: refundId,
        type: refundResult.success ? 'refund_completed' : 'refund_failed',
      ).catchError((e) {
        AppLogger.error('[RefundService] Failed to send notification: $e');
      });
    } catch (e) {
      // 更新为失败状态
      await _supabase.from('refunds').update({
        'status': 'failed',
        'error_message': e.toString(),
        'failed_at': DateTime.now().toIso8601String(),
      }).eq('id', refundId);

      AppLogger.error('[RefundService] Error processing refund: $e');
      throw Exception('Failed to process refund: $e');
    }
  }

  // ========================================
  // 4. 退款查询
  // ========================================

  /// 获取用户的退款列表
  Future<List<RefundApplication>> getUserRefunds({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      dynamic query = _supabase
          .from('refunds')
          .select('*')
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => RefundApplication.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('[RefundService] Error fetching user refunds: $e');
      throw Exception('Failed to fetch refunds: $e');
    }
  }

  /// 获取退款详情
  Future<RefundApplication> getRefundDetails(String refundId) async {
    try {
      final response = await _supabase
          .from('refunds')
          .select('*')
          .eq('id', refundId)
          .single();

      return RefundApplication.fromJson(response);
    } catch (e) {
      AppLogger.error('[RefundService] Error fetching refund details: $e');
      throw Exception('Failed to fetch refund details: $e');
    }
  }

  /// 获取退款日志
  Future<List<Map<String, dynamic>>> getRefundLogs(String refundId) async {
    try {
      final response = await _supabase
          .from('refund_logs')
          .select('*')
          .eq('refund_id', refundId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      AppLogger.error('[RefundService] Error fetching refund logs: $e');
      return [];
    }
  }

  // ========================================
  // 5. 辅助方法
  // ========================================

  /// 验证订单
  Future<Map<String, dynamic>> _validateOrder(
      String orderId, String userId) async {
    final order = await _supabase
        .from('orders')
        .select('id, user_id, provider_id, total_price, order_status, payment_intent_id')
        .eq('id', orderId)
        .single();

    // 验证订单所有权
    if (order['user_id'] != userId) {
      throw Exception('无权对此订单申请退款');
    }

    // 验证订单状态
    final status = order['order_status'] as String;
    if (!['completed', 'delivered'].contains(status)) {
      throw Exception('只能对已完成或已交付的订单申请退款');
    }

    return order;
  }

  /// 判断用户是否为管理员
  Future<bool> _isAdmin(String userId) async {
    try {
      final user = await _supabase
          .from('users')
          .select('role')
          .eq('id', userId)
          .single();

      return ['admin', 'super_admin'].contains(user['role']);
    } catch (e) {
      return false;
    }
  }

  /// 分类退款原因
  String _categorizeReason(String reason) {
    final lowerReason = reason.toLowerCase();

    if (lowerReason.contains('质量') || lowerReason.contains('quality')) {
      return 'quality_issue';
    } else if (lowerReason.contains('不满意') || lowerReason.contains('unsatisfied')) {
      return 'unsatisfied';
    } else if (lowerReason.contains('错误') || lowerReason.contains('mistake')) {
      return 'order_mistake';
    } else if (lowerReason.contains('取消') || lowerReason.contains('cancel')) {
      return 'cancellation';
    } else if (lowerReason.contains('延迟') || lowerReason.contains('delay')) {
      return 'service_delay';
    }

    return 'other';
  }

  /// 记录退款事件
  Future<void> _logRefundEvent({
    required String refundId,
    required String event,
    Map<String, dynamic>? details,
  }) async {
    try {
      await _supabase.from('refund_logs').insert({
        'refund_id': refundId,
        'event': event,
        'details': details,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      AppLogger.error('[RefundService] Error logging refund event: $e');
      // 不抛出异常，日志失败不应阻塞主流程
    }
  }

  /// 发送退款通知
  Future<void> _sendRefundNotification({
    required String userId,
    required String providerId,
    required String refundId,
    required String type,
  }) async {
    try {
      // TODO: 集成通知服务
      AppLogger.info('[RefundService] Sending notification: $type for refund $refundId');
    } catch (e) {
      AppLogger.error('[RefundService] Error sending notification: $e');
    }
  }

  // ========================================
  // 6. 统计方法
  // ========================================

  /// 获取退款统计
  Future<RefundStatistics> getRefundStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      dynamic query = _supabase
          .from('refunds')
          .select('status, amount')
          .eq('user_id', currentUser.id);

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      final refunds = response as List;

      int totalCount = refunds.length;
      int pendingCount = 0;
      int approvedCount = 0;
      int rejectedCount = 0;
      int completedCount = 0;
      double totalAmount = 0;

      for (final refund in refunds) {
        final status = refund['status'] as String;
        final amount = (refund['amount'] as num?)?.toDouble() ?? 0;

        totalAmount += amount;

        switch (status) {
          case 'pending':
            pendingCount++;
            break;
          case 'approved':
            approvedCount++;
            break;
          case 'rejected':
            rejectedCount++;
            break;
          case 'completed':
            completedCount++;
            break;
        }
      }

      return RefundStatistics(
        totalCount: totalCount,
        pendingCount: pendingCount,
        approvedCount: approvedCount,
        rejectedCount: rejectedCount,
        completedCount: completedCount,
        totalAmount: totalAmount,
      );
    } catch (e) {
      AppLogger.error('[RefundService] Error fetching statistics: $e');
      throw Exception('Failed to fetch refund statistics: $e');
    }
  }
}

// ========================================
// 数据模型
// ========================================

/// 退款申请模型
class RefundApplication {
  final String id;
  final String orderId;
  final String userId;
  final String providerId;
  final String refundType;
  final double amount;
  final double originalAmount;
  final String reason;
  final String reasonType;
  final String? description;
  final List<String>? images;
  final String status;
  final String? stripeRefundId;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNote;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;

  RefundApplication({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.providerId,
    required this.refundType,
    required this.amount,
    required this.originalAmount,
    required this.reason,
    required this.reasonType,
    this.description,
    this.images,
    required this.status,
    this.stripeRefundId,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNote,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
  });

  factory RefundApplication.fromJson(Map<String, dynamic> json) {
    return RefundApplication(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      userId: json['user_id'] as String,
      providerId: json['provider_id'] as String,
      refundType: json['refund_type'] as String,
      amount: (json['amount'] as num).toDouble(),
      originalAmount: (json['original_amount'] as num).toDouble(),
      reason: json['reason'] as String,
      reasonType: json['reason_type'] as String,
      description: json['description'] as String?,
      images: (json['images'] as List?)?.cast<String>(),
      status: json['status'] as String,
      stripeRefundId: json['stripe_refund_id'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      reviewNote: json['review_note'] as String?,
      errorMessage: json['error_message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }
}

/// 退款统计模型
class RefundStatistics {
  final int totalCount;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;
  final int completedCount;
  final double totalAmount;

  RefundStatistics({
    required this.totalCount,
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
    required this.completedCount,
    required this.totalAmount,
  });
}