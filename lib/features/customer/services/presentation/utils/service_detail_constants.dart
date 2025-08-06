import 'package:flutter/material.dart';

/// 服务详情页面常量定义
class ServiceDetailConstants {
  // 颜色常量
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.orange;
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.amber;

  // 尺寸常量
  static const double cardPadding = 16.0;
  static const double sectionSpacing = 16.0;
  static const double buttonHeight = 48.0;
  static const double iconSize = 24.0;
  static const double avatarSize = 40.0;

  // 动画常量
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration loadingDuration = Duration(seconds: 2);

  // 文本常量
  static const String loadingText = 'Loading...';
  static const String errorText = 'Something went wrong';
  static const String retryText = 'Retry';
  static const String cancelText = 'Cancel';
  static const String confirmText = 'Confirm';
  static const String saveText = 'Save';

  // 路由常量
  static const String serviceDetailRoute = '/service-detail';
  static const String bookingRoute = '/booking';
  static const String quoteRoute = '/quote';

  // API常量
  static const String baseUrl = 'https://api.jinbean.com';
  static const String servicesEndpoint = '/services';
  static const String reviewsEndpoint = '/reviews';
  static const String bookingsEndpoint = '/bookings';

  // 缓存常量
  static const String serviceCacheKey = 'service_detail_cache';
  static const String userCacheKey = 'user_preferences_cache';
  static const Duration cacheExpiration = Duration(hours: 1);
}
