import 'package:flutter/material.dart';

/// 服务详情页面验证工具类
class ServiceDetailValidators {
  /// 验证服务ID
  static bool isValidServiceId(String? serviceId) {
    return serviceId != null && serviceId.isNotEmpty;
  }

  /// 验证价格
  static bool isValidPrice(double? price) {
    return price != null && price > 0;
  }

  /// 验证评分
  static bool isValidRating(double? rating) {
    return rating != null && rating >= 0 && rating <= 5;
  }

  /// 验证日期
  static bool isValidDate(DateTime? date) {
    return date != null && date.isAfter(DateTime.now());
  }

  /// 验证时间
  static bool isValidTime(TimeOfDay? time) {
    return time != null;
  }

  /// 验证电话号码
  static bool isValidPhone(String? phone) {
    if (phone == null) return false;
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    return phoneRegex.hasMatch(phone);
  }

  /// 验证邮箱
  static bool isValidEmail(String? email) {
    if (email == null) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
