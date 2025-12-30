import 'package:flutter/material.dart';
import 'package:jinbeanpod_83904710/core/services/review_data_creation_service.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

/// 评价数据创建测试
class ReviewDataCreationTest {
  static final ReviewDataCreationService _service = ReviewDataCreationService();

  /// 执行评价数据创建测试
  static Future<void> runTest() async {
    try {
      AppLogger.info('[ReviewDataCreationTest] 开始执行评价数据创建测试');

      // 1. 获取当前统计
      final statsBefore = await _service.getReviewStats();
      AppLogger.info('[ReviewDataCreationTest] 创建前统计: $statsBefore');

      // 2. 创建评价数据
      await _service.createReviewsFromLatestOrder();

      // 3. 获取创建后统计
      final statsAfter = await _service.getReviewStats();
      AppLogger.info('[ReviewDataCreationTest] 创建后统计: $statsAfter');

      // 4. 计算增量
      final orderBasedIncrease = statsAfter['orderBased']! - statsBefore['orderBased']!;
      final serviceBasedIncrease = statsAfter['serviceBased']! - statsBefore['serviceBased']!;
      final totalIncrease = statsAfter['total']! - statsBefore['total']!;

      AppLogger.info('[ReviewDataCreationTest] 创建结果:');
      AppLogger.info('[ReviewDataCreationTest] - 基于订单评价增加: $orderBasedIncrease');
      AppLogger.info('[ReviewDataCreationTest] - 基于服务评价增加: $serviceBasedIncrease');
      AppLogger.info('[ReviewDataCreationTest] - 总评价增加: $totalIncrease');

      AppLogger.info('[ReviewDataCreationTest] 评价数据创建测试完成');

    } catch (e) {
      AppLogger.error('[ReviewDataCreationTest] 测试失败: $e');
      rethrow;
    }
  }

  /// 在应用启动时自动执行（可选）
  static Future<void> runOnStartup() async {
    try {
      // 延迟5秒执行，确保应用完全启动
      await Future.delayed(const Duration(seconds: 5));
      await runTest();
    } catch (e) {
      AppLogger.error('[ReviewDataCreationTest] 启动时执行失败: $e');
    }
  }
}
