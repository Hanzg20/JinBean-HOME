import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/base_models.dart';
import '../models/order_models.dart';
import '../utils/app_logger.dart';

/// 订单状态机
/// 
/// 管理订单在整个生命周期中的状态转换：
/// - 基于现有OrderStatus的状态流转规则
/// - 自动处理状态变更和通知
/// - 支持状态回滚和异常处理
/// - 提供状态变更历史记录
class OrderStateMachine extends GetxService {
  final _supabase = Supabase.instance.client;
  final _uuid = const Uuid();
  
  /// 状态转换规则
  static const Map<OrderStatus, List<OrderStatus>> _transitionRules = {
    OrderStatus.pending: [OrderStatus.accepted, OrderStatus.cancelled],
    OrderStatus.accepted: [OrderStatus.inProgress, OrderStatus.cancelled],
    OrderStatus.inProgress: [OrderStatus.completed, OrderStatus.cancelled],
    OrderStatus.completed: [OrderStatus.disputed],
    OrderStatus.disputed: [OrderStatus.completed, OrderStatus.cancelled],
    OrderStatus.cancelled: [], // 终态
  };
  
  /// 状态变更监听器
  final Map<String, List<Function(OrderStatusChange)>> _stateChangeListeners = {};

  @override
  void onInit() {
    super.onInit();
    _initializeStateMachine();
  }

  void _initializeStateMachine() {
    AppLogger.info('🔄 订单状态机初始化');
    startAutomaticStateCheck();
  }

  // ========================================
  // 主要状态转换方法
  // ========================================

  /// 尝试转换订单状态
  Future<bool> tryTransitionTo({
    required String orderId,
    required OrderStatus newStatus,
    required String reason,
    String? operatorId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      AppLogger.info('🔄 尝试状态转换: $orderId -> ${newStatus.code}');

      // 1. 获取当前订单状态
      final currentOrder = await _getCurrentOrder(orderId);
      if (currentOrder == null) {
        AppLogger.error('❌ 订单不存在: $orderId');
        return false;
      }

      // 2. 验证状态转换是否允许
      if (!isValidTransition(currentOrder.status, newStatus)) {
        AppLogger.warning('⚠️ 不允许的状态转换: ${currentOrder.status.code} -> ${newStatus.code}');
        return false;
      }

      // 3. 执行行业特定的状态转换前验证
      final industryValidation = await _validateIndustrySpecificTransition(
        currentOrder,
        newStatus,
        reason,
        metadata,
      );

      if (!industryValidation.isValid) {
        AppLogger.warning('⚠️ 行业特定验证失败: ${industryValidation.errors.join(', ')}');
        return false;
      }

      // 4. 执行状态转换
      final success = await _executeTransition(
        orderId: orderId,
        currentStatus: currentOrder.status,
        newStatus: newStatus,
        reason: reason,
        operatorId: operatorId,
        metadata: metadata,
      );

      if (success) {
        // 5. 触发状态变更后处理
        await _postTransitionProcessing(
          currentOrder,
          newStatus,
          reason,
          metadata,
        );

        AppLogger.info('✅ 状态转换成功: ${currentOrder.status.code} -> ${newStatus.code}');
      } else {
        AppLogger.error('❌ 状态转换执行失败');
      }

      return success;

    } catch (e) {
      AppLogger.error('❌ 状态转换异常: $e');
      return false;
    }
  }

  /// 获取可用的下一步状态
  List<OrderStatus> getAvailableNextStates(OrderStatus currentStatus) {
    return _transitionRules[currentStatus] ?? [];
  }

  /// 检查状态转换是否有效
  bool isValidTransition(OrderStatus from, OrderStatus to) {
    final availableStates = getAvailableNextStates(from);
    return availableStates.contains(to);
  }

  /// 获取订单状态历史
  Future<List<OrderStatusChange>> getOrderStatusHistory(String orderId) async {
    try {
      final response = await _supabase
          .from('order_status_changes')
          .select()
          .eq('order_id', orderId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => OrderStatusChange.fromJson(json))
          .toList();

    } catch (e) {
      AppLogger.error('❌ 获取状态历史失败: $e');
      return [];
    }
  }

  // ========================================
  // 状态监听和通知
  // ========================================

  /// 注册状态变更监听器
  void addStateChangeListener(String listenerId, Function(OrderStatusChange) listener) {
    _stateChangeListeners.putIfAbsent(listenerId, () => []).add(listener);
    AppLogger.info('👂 注册状态监听器: $listenerId');
  }

  /// 移除状态变更监听器
  void removeStateChangeListener(String listenerId) {
    _stateChangeListeners.remove(listenerId);
    AppLogger.info('🚫 移除状态监听器: $listenerId');
  }

  /// 触发状态变更通知
  void _notifyStateChange(OrderStatusChange statusChange) {
    AppLogger.info('📢 触发状态变更通知: ${statusChange.orderId}');
    
    for (final listeners in _stateChangeListeners.values) {
      for (final listener in listeners) {
        try {
          listener(statusChange);
        } catch (e) {
          AppLogger.error('❌ 状态监听器执行失败: $e');
        }
      }
    }
  }

  // ========================================
  // 自动状态转换
  // ========================================

  /// 启动自动状态检查定时器
  void startAutomaticStateCheck() {
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkAndProcessAutomaticTransitions();
    });
    AppLogger.info('⏰ 自动状态检查定时器已启动');
  }

  /// 检查并处理自动状态转换
  Future<void> _checkAndProcessAutomaticTransitions() async {
    try {
      // 检查超时的订单
      await _checkTimeoutOrders();
      
      // 检查需要自动推进的订单
      await _checkAutomaticProgressions();
      
    } catch (e) {
      AppLogger.error('❌ 自动状态检查失败: $e');
    }
  }

  /// 检查超时订单
  Future<void> _checkTimeoutOrders() async {
    try {
      // 查找超时的订单并自动取消
      final timeoutThreshold = DateTime.now().subtract(const Duration(hours: 24));
      
      final response = await _supabase
          .from('orders')
          .select()
          .eq('order_status', 'pending')
          .lt('created_at', timeoutThreshold.toIso8601String());

      final timeoutOrders = (response as List)
          .map((json) => Order.fromJson(json))
          .toList();

      for (final order in timeoutOrders) {
        await tryTransitionTo(
          orderId: order.id,
          newStatus: OrderStatus.cancelled,
          reason: '订单超时自动取消',
          operatorId: 'system',
          metadata: {'auto_cancel': true, 'reason': 'timeout'},
        );
      }
    } catch (e) {
      AppLogger.error('❌ 检查超时订单失败: $e');
    }
  }

  /// 检查自动推进的订单
  Future<void> _checkAutomaticProgressions() async {
    try {
      // 查找支付成功但状态还是pending的订单，自动转为accepted
      final response = await _supabase
          .from('orders')
          .select()
          .eq('order_status', 'pending')
          .eq('payment_status', 'paid');

      final paidOrders = (response as List)
          .map((json) => Order.fromJson(json))
          .toList();

      for (final order in paidOrders) {
        await tryTransitionTo(
          orderId: order.id,
          newStatus: OrderStatus.accepted,
          reason: '支付成功自动接受订单',
          operatorId: 'system',
          metadata: {'auto_accept': true, 'reason': 'payment_success'},
        );
      }
    } catch (e) {
      AppLogger.error('❌ 检查自动推进失败: $e');
    }
  }

  // ========================================
  // 私有辅助方法
  // ========================================

  /// 获取当前订单
  Future<Order?> _getCurrentOrder(String orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('id', orderId)
          .maybeSingle();

      if (response != null) {
        return Order.fromJson(response);
      }
      return null;

    } catch (e) {
      AppLogger.error('❌ 获取订单失败: $e');
      return null;
    }
  }

  /// 行业特定转换验证
  Future<ValidationResult> _validateIndustrySpecificTransition(
    Order order,
    OrderStatus newStatus,
    String reason,
    Map<String, dynamic>? metadata,
  ) async {
    // 基础验证逻辑
    switch (newStatus) {
      case OrderStatus.accepted:
        // 检查是否已支付（对于需要预付费的行业）
        if (order.industry == IndustryType.food && order.paymentStatus != PaymentStatus.completed) {
          return ValidationResult(
            isValid: false,
            errors: ['餐饮订单需要先完成支付才能接受'],
          );
        }
        break;
        
      case OrderStatus.completed:
        // 检查是否已经在进行中
        if (order.status != OrderStatus.inProgress) {
          return ValidationResult(
            isValid: false,
            errors: ['只有进行中的订单才能标记为完成'],
          );
        }
        break;
        
      case OrderStatus.cancelled:
        // 检查是否可以取消
        if (order.status == OrderStatus.completed) {
          return ValidationResult(
            isValid: false,
            errors: ['已完成的订单不能取消'],
          );
        }
        break;
        
      default:
        break;
    }

    return ValidationResult(isValid: true);
  }

  /// 执行状态转换
  Future<bool> _executeTransition({
    required String orderId,
    required OrderStatus currentStatus,
    required OrderStatus newStatus,
    required String reason,
    String? operatorId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final now = DateTime.now();
      
      // 1. 更新订单状态
      await _supabase
          .from('orders')
          .update({
            'order_status': newStatus.code,
            'updated_at': now.toIso8601String(),
          })
          .eq('id', orderId);

      // 2. 记录状态变更历史
      final statusChange = OrderStatusChange(
        id: _uuid.v4(),
        orderId: orderId,
        fromStatus: currentStatus,
        toStatus: newStatus,
        reason: reason,
        changedBy: operatorId,
        changeType: operatorId == 'system' ? 'automatic' : 'manual',
        metadata: metadata ?? {},
        createdAt: now,
        updatedAt: now,
      );

      await _supabase
          .from('order_status_changes')
          .insert(statusChange.toJson());

      // 3. 触发通知
      _notifyStateChange(statusChange);

      return true;

    } catch (e) {
      AppLogger.error('❌ 执行状态转换失败: $e');
      return false;
    }
  }

  /// 状态转换后处理
  Future<void> _postTransitionProcessing(
    Order order,
    OrderStatus newStatus,
    String reason,
    Map<String, dynamic>? metadata,
  ) async {
    // 根据新状态执行相应的后处理
    switch (newStatus) {
      case OrderStatus.accepted:
        await _handleOrderAccepted(order);
        break;
      case OrderStatus.completed:
        await _handleOrderCompleted(order);
        break;
      case OrderStatus.cancelled:
        await _handleOrderCancelled(order, reason);
        break;
      default:
        // 其他状态的通用处理
        break;
    }
  }

  /// 处理订单接受
  Future<void> _handleOrderAccepted(Order order) async {
    AppLogger.info('📧 订单已接受，发送通知: ${order.orderNumber}');
    
    // 这里可以集成推送通知服务
    // await _notificationService.sendOrderAcceptedNotification(order);
    
    // 根据不同行业执行特定逻辑
    switch (order.industry) {
      case IndustryType.food:
        AppLogger.info('🍽️ 餐饮订单已接受，通知厨房开始准备');
        break;
      case IndustryType.home:
        AppLogger.info('🏠 家居服务订单已接受，安排服务人员');
        break;
      case IndustryType.transport:
        AppLogger.info('🚗 出行订单已接受，匹配司机');
        break;
      default:
        AppLogger.info('✅ ${order.industry.label}订单已接受');
        break;
    }
  }

  /// 处理订单完成
  Future<void> _handleOrderCompleted(Order order) async {
    AppLogger.info('🎉 订单已完成，触发后处理: ${order.orderNumber}');
    
    // 发送完成通知
    // await _notificationService.sendOrderCompletedNotification(order);
    
    // 触发评价系统
    // await _reviewService.createReviewRequest(order);
    
    // 更新统计数据
    // await _analyticsService.recordOrderCompletion(order);
  }

  /// 处理订单取消
  Future<void> _handleOrderCancelled(Order order, String reason) async {
    AppLogger.info('❌ 订单已取消，原因: $reason');
    
    // 发送取消通知
    // await _notificationService.sendOrderCancelledNotification(order, reason);
    
    // 处理退款（如果已支付）
    if (order.paymentStatus == PaymentStatus.completed) {
      AppLogger.info('💰 开始处理订单退款: ${order.orderNumber}');
      // await _refundService.processRefund(order, reason);
    }
    
    // 释放资源
    AppLogger.info('🔄 释放订单相关资源');
  }

  // ========================================
  // 便捷方法
  // ========================================

  /// 接受订单
  Future<bool> acceptOrder(String orderId, {String? operatorId}) async {
    return await tryTransitionTo(
      orderId: orderId,
      newStatus: OrderStatus.accepted,
      reason: '订单已被接受',
      operatorId: operatorId,
    );
  }

  /// 开始处理订单
  Future<bool> startOrder(String orderId, {String? operatorId}) async {
    return await tryTransitionTo(
      orderId: orderId,
      newStatus: OrderStatus.inProgress,
      reason: '开始处理订单',
      operatorId: operatorId,
    );
  }

  /// 完成订单
  Future<bool> completeOrder(String orderId, {String? operatorId}) async {
    return await tryTransitionTo(
      orderId: orderId,
      newStatus: OrderStatus.completed,
      reason: '订单已完成',
      operatorId: operatorId,
    );
  }

  /// 取消订单
  Future<bool> cancelOrder(String orderId, String reason, {String? operatorId}) async {
    return await tryTransitionTo(
      orderId: orderId,
      newStatus: OrderStatus.cancelled,
      reason: reason,
      operatorId: operatorId,
    );
  }

  /// 标记订单有争议
  Future<bool> disputeOrder(String orderId, String reason, {String? operatorId}) async {
    return await tryTransitionTo(
      orderId: orderId,
      newStatus: OrderStatus.disputed,
      reason: reason,
      operatorId: operatorId,
    );
  }

  // ========================================
  // 状态统计和分析
  // ========================================

  /// 获取状态分布统计
  Future<Map<OrderStatus, int>> getStatusDistribution({
    IndustryType? industry,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase.from('orders').select('order_status');
      
      if (industry != null) {
        query = query.eq('industry', industry.code);
      }
      
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      final orders = response as List;

      final distribution = <OrderStatus, int>{};
      for (final status in OrderStatus.values) {
        distribution[status] = 0;
      }

      for (final order in orders) {
        final status = OrderStatus.fromCode(order['order_status']);
        distribution[status] = (distribution[status] ?? 0) + 1;
      }

      return distribution;

    } catch (e) {
      AppLogger.error('❌ 获取状态分布失败: $e');
      return {};
    }
  }

  /// 获取状态转换统计
  Future<Map<String, int>> getTransitionStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase.from('order_status_changes').select('from_status, to_status');
      
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      final changes = response as List;

      final statistics = <String, int>{};
      
      for (final change in changes) {
        final transition = '${change['from_status']} -> ${change['to_status']}';
        statistics[transition] = (statistics[transition] ?? 0) + 1;
      }

      return statistics;

    } catch (e) {
      AppLogger.error('❌ 获取转换统计失败: $e');
      return {};
    }
  }
}
