import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/admin/presentation/pages/review_data_creation_page.dart';

/// 管理功能路由
class AdminRoutes {
  static const String reviewDataCreation = '/admin/review-data-creation';

  static List<GetPage> get routes => [
    GetPage(
      name: reviewDataCreation,
      page: () => const ReviewDataCreationPage(),
    ),
  ];
}

/// 快速访问管理功能的工具类
class AdminUtils {
  /// 打开评价数据创建页面
  static void openReviewDataCreation() {
    Get.toNamed(AdminRoutes.reviewDataCreation);
  }
}






