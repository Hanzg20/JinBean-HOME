import 'package:flutter/material.dart';

/// 服务详情页面格式化工具类
class ServiceDetailFormatters {
  /// 格式化时长
  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  /// 格式化价格
  static String formatPrice(double? price) {
    if (price == null) return 'N/A';
    return '\$${price.toStringAsFixed(2)}';
  }

  /// 格式化评分
  static String formatRating(double? rating) {
    if (rating == null) return 'N/A';
    return rating.toStringAsFixed(1);
  }

  /// 格式化距离
  static String formatDistance(double? distance) {
    if (distance == null) return 'N/A';
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)}m';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }

  /// 格式化日期
  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 格式化时间
  static String formatTime(TimeOfDay? time) {
    if (time == null) return 'N/A';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
