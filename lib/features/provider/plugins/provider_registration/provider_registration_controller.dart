import 'package:flutter/material.dart';

enum ProviderType { individual, team, corporate }

class ProviderRegistrationController extends ChangeNotifier {
  // 步骤索引
  int stepIndex = 0;

  // 注册类型
  ProviderType? providerType;

  // 基本信息
  String? displayName;
  String? phone;
  String? email;
  String? password;

  // 地址
  String? addressInput;
  String? addressId;

  // 服务信息
  List<String> serviceCategories = [];
  List<String> serviceAreas = [];
  double? basePrice;
  Map<String, List<Map<String, String>>> workSchedule = {};
  List<Map<String, String>> teamMembers = [];
  List<Map<String, String>> paymentMethods = [];

  // 资质/证照
  List<String> certificationFiles = [];
  String certificationStatus = 'pending';

  // 合规信息
  bool? hasGstHst;
  String? bnNumber;
  double? annualIncomeEstimate;
  String? licenseNumber;
  bool taxStatusNoticeShown = false;
  bool taxReportAvailable = false;

  // 其它
  String? avatarUrl;
  String? bio;

  // 校验与步骤切换
  void nextStep() {
    if (stepIndex < 6) {
      stepIndex++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (stepIndex > 0) {
      stepIndex--;
      notifyListeners();
    }
  }

  void setProviderType(ProviderType type) {
    providerType = type;
    notifyListeners();
  }

  // 其它 setter/getter 可按需补充
} 