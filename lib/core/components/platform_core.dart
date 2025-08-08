import 'package:flutter/material.dart';
import 'skeleton/skeleton_system.dart';
import 'progressive_loading/progressive_loading_system.dart';
import 'offline_support/offline_support_system.dart';
import 'error_recovery/error_recovery_system.dart';
import 'loading_state_manager.dart';

/// 平台组件导出
export 'skeleton/skeleton_system.dart';
export 'progressive_loading/progressive_loading_system.dart';
export 'offline_support/offline_support_system.dart';
export 'error_recovery/error_recovery_system.dart';
export 'loading_state_manager.dart';

/// 平台核心类
class PlatformCore {
  static final PlatformCore _instance = PlatformCore._internal();
  factory PlatformCore() => _instance;
  PlatformCore._internal();

  /// 初始化平台组件
  Future<void> initialize({
    SkeletonConfig? skeletonConfig,
    ProgressiveConfig? progressiveConfig,
    OfflineConfig? offlineConfig,
    ErrorRecoveryConfig? errorRecoveryConfig,
  }) async {
    // 初始化各个系统组件
    await _initializeSkeletonSystem(skeletonConfig);
    await _initializeProgressiveLoading(progressiveConfig);
    await _initializeOfflineSupport(offlineConfig);
    await _initializeErrorRecovery(errorRecoveryConfig);
  }

  /// 初始化骨架屏系统
  Future<void> _initializeSkeletonSystem(SkeletonConfig? config) async {
    // 骨架屏系统初始化逻辑
    print('骨架屏系统初始化完成');
  }

  /// 初始化渐进式加载系统
  Future<void> _initializeProgressiveLoading(ProgressiveConfig? config) async {
    // 渐进式加载系统初始化逻辑
    print('渐进式加载系统初始化完成');
  }

  /// 初始化离线支持系统
  Future<void> _initializeOfflineSupport(OfflineConfig? config) async {
    // 离线支持系统初始化逻辑
    print('离线支持系统初始化完成');
  }

  /// 初始化错误恢复系统
  Future<void> _initializeErrorRecovery(ErrorRecoveryConfig? config) async {
    // 错误恢复系统初始化逻辑
    print('错误恢复系统初始化完成');
  }

  /// 获取骨架屏系统（静态方法）
  static Widget createSkeleton({
    required SkeletonType type,
    SkeletonConfig? config,
    Map<String, dynamic>? customData,
  }) {
    return PlatformSkeleton.create(
      type: type,
      config: config,
      customData: customData,
    );
  }
  
  /// 获取渐进式加载系统（静态方法）
  static Widget createProgressiveLoading({
    required ProgressiveType type,
    ProgressiveConfig? config,
    required Future<void> Function() loadFunction,
    required Widget Function(BuildContext) contentBuilder,
    Widget? loadingWidget,
    Widget? errorWidget,
  }) {
    return PlatformProgressiveLoading.create(
      type: type,
      config: config,
      loadFunction: loadFunction,
      contentBuilder: contentBuilder,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
    );
  }
  
  /// 获取离线支持系统（静态方法）
  static Widget createOfflineSupport({
    required OfflineType type,
    OfflineConfig? config,
    required Widget Function(BuildContext) onlineBuilder,
    required Widget Function(BuildContext) offlineBuilder,
    Widget? syncIndicator,
  }) {
    return PlatformOfflineSupport.create(
      type: type,
      config: config,
      onlineBuilder: onlineBuilder,
      offlineBuilder: offlineBuilder,
      syncIndicator: syncIndicator,
    );
  }
  
  /// 获取错误恢复系统（静态方法）
  static Widget createErrorRecovery({
    required ErrorRecoveryType type,
    ErrorRecoveryConfig? config,
    required Widget Function(BuildContext) contentBuilder,
    required Future<void> Function() recoveryFunction,
    Widget? errorWidget,
    Widget? recoveryWidget,
  }) {
    return PlatformErrorRecovery.create(
      type: type,
      config: config,
      contentBuilder: contentBuilder,
      recoveryFunction: recoveryFunction,
      errorWidget: errorWidget,
      recoveryWidget: recoveryWidget,
    );
  }
} 