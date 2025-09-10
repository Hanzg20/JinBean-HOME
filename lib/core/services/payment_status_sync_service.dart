import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/base_models.dart';
import '../utils/app_logger.dart';

/// 支付状态同步服务
/// 
/// 负责与后端同步支付状态，处理支付状态变更通知
/// 提供实时支付状态更新和webhook处理
class PaymentStatusSyncService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // 支付状态监听器
  final Map<String, StreamSubscription> _paymentListeners = {};
  
  // 支付状态缓存
  final RxMap<String, PaymentStatus> _paymentStatusCache = <String, PaymentStatus>{}.obs;
  
  // 同步状态
  final RxBool _isSyncing = false.obs;
  final RxString _lastSyncError = ''.obs;
  final Rx<DateTime?> _lastSyncTime = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  @override
  void onClose() {
    _cleanupListeners();
    super.onClose();
  }

  void _initializeService() {
    AppLogger.info('[PaymentStatusSyncService] Initializing payment status sync service');
    
    // 启动定期同步
    _startPeriodicSync();
  }

  /// 启动定期同步
  void _startPeriodicSync() {
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _syncAllPaymentStatuses();
    });
  }

  /// 监听特定支付的状态变化
  Future<void> watchPaymentStatus(String paymentId) async {
    try {
      AppLogger.info('[PaymentStatusSyncService] Starting to watch payment: $paymentId');
      
      // 如果已经在监听，先停止
      await stopWatchingPayment(paymentId);
      
      // 创建实时监听
      final subscription = _supabase
          .from('payments')
          .stream(primaryKey: ['id'])
          .eq('id', paymentId)
          .listen((data) {
            if (data.isNotEmpty) {
              final paymentData = data.first;
              final status = PaymentStatus.fromCode(paymentData['status']);
              
              // 更新缓存
              _paymentStatusCache[paymentId] = status;
              
              // 触发状态变更事件
              _notifyPaymentStatusChanged(paymentId, status, paymentData);
            }
          });
      
      _paymentListeners[paymentId] = subscription;
      
      // 立即获取一次当前状态
      await _fetchPaymentStatus(paymentId);
      
    } catch (e) {
      AppLogger.error('[PaymentStatusSyncService] Failed to watch payment $paymentId: $e');
      throw PaymentException('监听支付状态失败: $e');
    }
  }

  /// 停止监听特定支付
  Future<void> stopWatchingPayment(String paymentId) async {
    final subscription = _paymentListeners.remove(paymentId);
    await subscription?.cancel();
    _paymentStatusCache.remove(paymentId);
    
    AppLogger.info('[PaymentStatusSyncService] Stopped watching payment: $paymentId');
  }

  /// 获取支付状态
  Future<PaymentStatus> getPaymentStatus(String paymentId) async {
    try {
      // 先检查缓存
      if (_paymentStatusCache.containsKey(paymentId)) {
        return _paymentStatusCache[paymentId]!;
      }
      
      // 从数据库获取
      return await _fetchPaymentStatus(paymentId);
      
    } catch (e) {
      AppLogger.error('[PaymentStatusSyncService] Failed to get payment status for $paymentId: $e');
      throw PaymentException('获取支付状态失败: $e');
    }
  }

  /// 从数据库获取支付状态
  Future<PaymentStatus> _fetchPaymentStatus(String paymentId) async {
    final response = await _supabase
        .from('payments')
        .select('status, updated_at')
        .eq('id', paymentId)
        .single();

    final status = PaymentStatus.fromCode(response['status']);
    _paymentStatusCache[paymentId] = status;
    
    return status;
  }

  /// 同步所有支付状态
  Future<void> _syncAllPaymentStatuses() async {
    if (_isSyncing.value) return;
    
    try {
      _isSyncing.value = true;
      _lastSyncError.value = '';
      
      AppLogger.info('[PaymentStatusSyncService] Starting payment status sync');
      
      // 获取需要同步的支付ID列表
      final paymentIds = _paymentListeners.keys.toList();
      
      if (paymentIds.isEmpty) {
        _lastSyncTime.value = DateTime.now();
        return;
      }
      
      // 批量获取支付状态
      final response = await _supabase
          .from('payments')
          .select('id, status, updated_at')
          .inFilter('id', paymentIds);
      
      // 更新缓存
      for (final paymentData in response) {
        final paymentId = paymentData['id'] as String;
        final status = PaymentStatus.fromCode(paymentData['status']);
        
        final oldStatus = _paymentStatusCache[paymentId];
        _paymentStatusCache[paymentId] = status;
        
        // 如果状态发生变化，触发通知
        if (oldStatus != status) {
          _notifyPaymentStatusChanged(paymentId, status, paymentData);
        }
      }
      
      _lastSyncTime.value = DateTime.now();
      AppLogger.info('[PaymentStatusSyncService] Payment status sync completed');
      
    } catch (e) {
      _lastSyncError.value = e.toString();
      AppLogger.error('[PaymentStatusSyncService] Payment status sync failed: $e');
    } finally {
      _isSyncing.value = false;
    }
  }

  /// 通知支付状态变更
  void _notifyPaymentStatusChanged(
    String paymentId,
    PaymentStatus newStatus,
    Map<String, dynamic> paymentData,
  ) {
    AppLogger.info('[PaymentStatusSyncService] Payment $paymentId status changed to ${newStatus.code}');
    
    // 触发GetX更新
    update();
    
    // 可以在这里添加其他通知逻辑，比如：
    // - 发送本地通知
    // - 更新UI
    // - 触发业务逻辑
    
    switch (newStatus) {
      case PaymentStatus.completed:
        _handlePaymentCompleted(paymentId, paymentData);
        break;
      case PaymentStatus.failed:
        _handlePaymentFailed(paymentId, paymentData);
        break;
      case PaymentStatus.cancelled:
        _handlePaymentCancelled(paymentId, paymentData);
        break;
      case PaymentStatus.refunded:
        _handlePaymentRefunded(paymentId, paymentData);
        break;
      default:
        break;
    }
  }

  /// 处理支付完成
  void _handlePaymentCompleted(String paymentId, Map<String, dynamic> paymentData) {
    AppLogger.info('[PaymentStatusSyncService] Payment completed: $paymentId');
    
    Get.snackbar(
      '支付成功',
      '您的支付已完成',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: const Duration(seconds: 3),
    );
  }

  /// 处理支付失败
  void _handlePaymentFailed(String paymentId, Map<String, dynamic> paymentData) {
    AppLogger.info('[PaymentStatusSyncService] Payment failed: $paymentId');
    
    final failureReason = paymentData['failure_reason'] as String?;
    
    Get.snackbar(
      '支付失败',
      failureReason ?? '支付处理失败，请重试',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 5),
    );
  }

  /// 处理支付取消
  void _handlePaymentCancelled(String paymentId, Map<String, dynamic> paymentData) {
    AppLogger.info('[PaymentStatusSyncService] Payment cancelled: $paymentId');
    
    Get.snackbar(
      '支付取消',
      '支付已取消',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.secondary,
      colorText: Get.theme.colorScheme.onSecondary,
      duration: const Duration(seconds: 3),
    );
  }

  /// 处理支付退款
  void _handlePaymentRefunded(String paymentId, Map<String, dynamic> paymentData) {
    AppLogger.info('[PaymentStatusSyncService] Payment refunded: $paymentId');
    
    Get.snackbar(
      '退款完成',
      '您的退款已处理完成',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: const Duration(seconds: 3),
    );
  }

  /// 手动刷新支付状态
  Future<void> refreshPaymentStatus(String paymentId) async {
    try {
      AppLogger.info('[PaymentStatusSyncService] Manually refreshing payment status: $paymentId');
      
      await _fetchPaymentStatus(paymentId);
      
    } catch (e) {
      AppLogger.error('[PaymentStatusSyncService] Failed to refresh payment status: $e');
      throw PaymentException('刷新支付状态失败: $e');
    }
  }

  /// 批量刷新支付状态
  Future<void> refreshAllPaymentStatuses() async {
    await _syncAllPaymentStatuses();
  }

  /// 清理监听器
  void _cleanupListeners() {
    for (final subscription in _paymentListeners.values) {
      subscription.cancel();
    }
    _paymentListeners.clear();
    _paymentStatusCache.clear();
    
    AppLogger.info('[PaymentStatusSyncService] Cleaned up all payment listeners');
  }

  /// 获取服务状态
  Map<String, dynamic> getServiceStatus() {
    return {
      'is_syncing': _isSyncing.value,
      'last_sync_time': _lastSyncTime.value?.toIso8601String(),
      'last_sync_error': _lastSyncError.value,
      'watching_payments_count': _paymentListeners.length,
      'cached_statuses_count': _paymentStatusCache.length,
    };
  }

  /// 获取缓存的支付状态
  Map<String, PaymentStatus> getCachedStatuses() {
    return Map.from(_paymentStatusCache);
  }

  /// 检查支付是否正在被监听
  bool isWatchingPayment(String paymentId) {
    return _paymentListeners.containsKey(paymentId);
  }

  /// 获取同步统计信息
  Map<String, dynamic> getSyncStats() {
    final statusCounts = <String, int>{};
    for (final status in _paymentStatusCache.values) {
      final statusName = status.code;
      statusCounts[statusName] = (statusCounts[statusName] ?? 0) + 1;
    }

    return {
      'total_payments': _paymentStatusCache.length,
      'status_distribution': statusCounts,
      'sync_frequency': '5 minutes',
      'last_sync': _lastSyncTime.value?.toIso8601String() ?? 'Never',
      'sync_errors': _lastSyncError.value.isNotEmpty ? 1 : 0,
    };
  }
}
