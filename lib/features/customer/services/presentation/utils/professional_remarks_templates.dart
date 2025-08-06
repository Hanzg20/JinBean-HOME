import 'package:flutter/material.dart';

/// 专业说明文字模板系统
/// 为不同类型的服务商提供定制化的专业说明文字
class ProfessionalRemarksTemplates {
  
  /// 服务商类型枚举
  static const String CLEANING_SERVICE = 'cleaning';
  static const String MAINTENANCE_SERVICE = 'maintenance';
  static const String BEAUTY_SERVICE = 'beauty';
  static const String EDUCATION_SERVICE = 'education';
  static const String TRANSPORTATION_SERVICE = 'transportation';
  static const String FOOD_SERVICE = 'food';
  static const String HEALTH_SERVICE = 'health';
  static const String TECHNOLOGY_SERVICE = 'technology';
  static const String GENERAL_SERVICE = 'general';

  /// 获取服务特色模板
  static List<FeatureItem> getServiceFeatures(String serviceType, Map<String, dynamic>? providerData) {
    switch (serviceType) {
      case CLEANING_SERVICE:
        return _getCleaningServiceFeatures(providerData);
      case MAINTENANCE_SERVICE:
        return _getMaintenanceServiceFeatures(providerData);
      case BEAUTY_SERVICE:
        return _getBeautyServiceFeatures(providerData);
      case EDUCATION_SERVICE:
        return _getEducationServiceFeatures(providerData);
      case TRANSPORTATION_SERVICE:
        return _getTransportationServiceFeatures(providerData);
      case FOOD_SERVICE:
        return _getFoodServiceFeatures(providerData);
      case HEALTH_SERVICE:
        return _getHealthServiceFeatures(providerData);
      case TECHNOLOGY_SERVICE:
        return _getTechnologyServiceFeatures(providerData);
      default:
        return _getGeneralServiceFeatures(providerData);
    }
  }

  /// 获取质量保证模板
  static String getQualityAssurance(String serviceType, Map<String, dynamic>? providerData) {
    switch (serviceType) {
      case CLEANING_SERVICE:
        return _getCleaningQualityAssurance(providerData);
      case MAINTENANCE_SERVICE:
        return _getMaintenanceQualityAssurance(providerData);
      case BEAUTY_SERVICE:
        return _getBeautyQualityAssurance(providerData);
      case EDUCATION_SERVICE:
        return _getEducationQualityAssurance(providerData);
      case TRANSPORTATION_SERVICE:
        return _getTransportationQualityAssurance(providerData);
      case FOOD_SERVICE:
        return _getFoodQualityAssurance(providerData);
      case HEALTH_SERVICE:
        return _getHealthQualityAssurance(providerData);
      case TECHNOLOGY_SERVICE:
        return _getTechnologyQualityAssurance(providerData);
      default:
        return _getGeneralQualityAssurance(providerData);
    }
  }

  /// 获取专业资质模板
  static String getProfessionalQualification(String serviceType, Map<String, dynamic>? providerData) {
    switch (serviceType) {
      case CLEANING_SERVICE:
        return _getCleaningProfessionalQualification(providerData);
      case MAINTENANCE_SERVICE:
        return _getMaintenanceProfessionalQualification(providerData);
      case BEAUTY_SERVICE:
        return _getBeautyProfessionalQualification(providerData);
      case EDUCATION_SERVICE:
        return _getEducationProfessionalQualification(providerData);
      case TRANSPORTATION_SERVICE:
        return _getTransportationProfessionalQualification(providerData);
      case FOOD_SERVICE:
        return _getFoodProfessionalQualification(providerData);
      case HEALTH_SERVICE:
        return _getHealthProfessionalQualification(providerData);
      case TECHNOLOGY_SERVICE:
        return _getTechnologyProfessionalQualification(providerData);
      default:
        return _getGeneralProfessionalQualification(providerData);
    }
  }

  /// 获取服务经验模板
  static String getServiceExperience(String serviceType, Map<String, dynamic>? providerData) {
    final completedOrders = providerData?['completedOrders'] ?? 0;
    final rating = providerData?['rating'] ?? 4.8;
    
    switch (serviceType) {
      case CLEANING_SERVICE:
        return '拥有$completedOrders次成功清洁服务经验，平均评分${rating.toStringAsFixed(1)}分。我们深知不同家庭的清洁需求，能够提供个性化的专业清洁服务。';
      case MAINTENANCE_SERVICE:
        return '拥有$completedOrders次成功维修服务经验，平均评分${rating.toStringAsFixed(1)}分。我们具备丰富的技术经验，能够快速诊断和解决各种维修问题。';
      case BEAUTY_SERVICE:
        return '拥有$completedOrders次成功美容服务经验，平均评分${rating.toStringAsFixed(1)}分。我们了解不同肤质和需求，能够提供专业的美容护理服务。';
      case EDUCATION_SERVICE:
        return '拥有$completedOrders次成功教学服务经验，平均评分${rating.toStringAsFixed(1)}分。我们具备丰富的教学经验，能够因材施教，帮助学生取得进步。';
      case TRANSPORTATION_SERVICE:
        return '拥有$completedOrders次成功运输服务经验，平均评分${rating.toStringAsFixed(1)}分。我们熟悉各种路线，能够提供安全、准时的运输服务。';
      case FOOD_SERVICE:
        return '拥有$completedOrders次成功餐饮服务经验，平均评分${rating.toStringAsFixed(1)}分。我们注重食材质量和口味，能够提供美味的餐饮服务。';
      case HEALTH_SERVICE:
        return '拥有$completedOrders次成功健康服务经验，平均评分${rating.toStringAsFixed(1)}分。我们具备专业的医疗知识，能够提供安全、有效的健康服务。';
      case TECHNOLOGY_SERVICE:
        return '拥有$completedOrders次成功技术服务经验，平均评分${rating.toStringAsFixed(1)}分。我们具备最新的技术知识，能够提供专业的技术解决方案。';
      default:
        return '拥有$completedOrders次成功服务经验，平均评分${rating.toStringAsFixed(1)}分。我们深知客户需求，能够提供个性化的专业服务。';
    }
  }

  /// 获取服务特色模板
  static String getServiceHighlights(String serviceType, Map<String, dynamic>? providerData) {
    switch (serviceType) {
      case CLEANING_SERVICE:
        return '• 专业团队：经验丰富的清洁人员\n'
               '• 环保产品：使用环保清洁剂，保护家庭健康\n'
               '• 深度清洁：彻底清洁每个角落\n'
               '• 灵活安排：根据客户时间灵活调整\n'
               '• 质量保证：清洁不满意免费重做';
      case MAINTENANCE_SERVICE:
        return '• 技术团队：经验丰富的维修技师\n'
               '• 专业工具：配备专业维修设备\n'
               '• 快速响应：24小时内响应维修需求\n'
               '• 质量保证：维修后提供保修服务\n'
               '• 透明报价：维修前明确告知费用';
      case BEAUTY_SERVICE:
        return '• 专业美容师：持证上岗的美容师\n'
               '• 优质产品：使用知名品牌美容产品\n'
               '• 个性化服务：根据肤质定制护理方案\n'
               '• 卫生标准：严格消毒，确保卫生安全\n'
               '• 效果保证：美容效果不满意免费调整';
      case EDUCATION_SERVICE:
        return '• 专业教师：经验丰富的教育工作者\n'
               '• 个性化教学：根据学生特点制定教学计划\n'
               '• 小班教学：确保每个学生得到充分关注\n'
               '• 进度跟踪：定期评估学生学习进度\n'
               '• 效果保证：学习效果不满意免费补课';
      case TRANSPORTATION_SERVICE:
        return '• 专业司机：经验丰富的驾驶人员\n'
               '• 安全车辆：定期维护的安全车辆\n'
               '• 准时服务：严格按照约定时间到达\n'
               '• 保险保障：全程保险覆盖\n'
               '• 价格透明：无隐藏费用';
      case FOOD_SERVICE:
        return '• 专业厨师：经验丰富的烹饪师\n'
               '• 新鲜食材：严格挑选优质食材\n'
               '• 卫生标准：严格遵循食品安全标准\n'
               '• 口味定制：根据客户喜好调整口味\n'
               '• 准时配送：按时送达，保持食物新鲜';
      case HEALTH_SERVICE:
        return '• 专业医师：持证上岗的医疗人员\n'
               '• 安全标准：严格遵循医疗安全标准\n'
               '• 隐私保护：严格保护客户隐私\n'
               '• 专业设备：配备专业医疗设备\n'
               '• 后续服务：提供康复指导和建议';
      case TECHNOLOGY_SERVICE:
        return '• 技术专家：经验丰富的技术人员\n'
               '• 最新技术：掌握最新技术趋势\n'
               '• 快速解决：快速诊断和解决问题\n'
               '• 远程支持：提供远程技术支持\n'
               '• 培训服务：提供技术培训指导';
      default:
        return '• 专业团队：经验丰富的服务人员\n'
               '• 质量保证：服务不满意全额退款\n'
               '• 安全保障：所有服务都有保险覆盖\n'
               '• 灵活安排：根据客户时间灵活调整\n'
               '• 环保理念：使用环保产品，保护环境';
    }
  }

  // 清洁服务特色
  static List<FeatureItem> _getCleaningServiceFeatures(Map<String, dynamic>? providerData) {
    return [
      FeatureItem(
        Icons.cleaning_services,
        '专业清洁',
        '经验丰富的清洁团队，使用专业清洁设备',
        Colors.blue,
      ),
      FeatureItem(
        Icons.eco,
        '环保产品',
        '使用环保清洁剂，保护家庭健康和环境',
        Colors.green,
      ),
      FeatureItem(
        Icons.schedule,
        '灵活安排',
        '根据客户时间灵活调整，提供便捷服务',
        Colors.purple,
      ),
      FeatureItem(
        Icons.verified,
        '质量保证',
        '清洁不满意免费重做，确保客户满意',
        Colors.orange,
      ),
    ];
  }

  // 维修服务特色
  static List<FeatureItem> _getMaintenanceServiceFeatures(Map<String, dynamic>? providerData) {
    return [
      FeatureItem(
        Icons.build,
        '专业维修',
        '经验丰富的维修技师，快速诊断问题',
        Colors.blue,
      ),
      FeatureItem(
        Icons.build,
        '专业工具',
        '配备专业维修设备，确保维修质量',
        Colors.orange,
      ),
      FeatureItem(
        Icons.schedule,
        '快速响应',
        '24小时内响应维修需求，及时解决问题',
        Colors.green,
      ),
      FeatureItem(
        Icons.security,
        '质量保证',
        '维修后提供保修服务，确保长期稳定',
        Colors.red,
      ),
    ];
  }

  // 美容服务特色
  static List<FeatureItem> _getBeautyServiceFeatures(Map<String, dynamic>? providerData) {
    return [
      FeatureItem(
        Icons.face,
        '专业美容',
        '持证上岗的美容师，提供专业美容服务',
        Colors.pink,
      ),
      FeatureItem(
        Icons.spa,
        '优质产品',
        '使用知名品牌美容产品，确保效果',
        Colors.purple,
      ),
      FeatureItem(
        Icons.person,
        '个性化服务',
        '根据肤质定制护理方案，满足不同需求',
        Colors.blue,
      ),
      FeatureItem(
        Icons.health_and_safety,
        '卫生标准',
        '严格消毒，确保卫生安全',
        Colors.green,
      ),
    ];
  }

  // 教育服务特色
  static List<FeatureItem> _getEducationServiceFeatures(Map<String, dynamic>? providerData) {
    return [
      FeatureItem(
        Icons.school,
        '专业教师',
        '经验丰富的教育工作者，因材施教',
        Colors.blue,
      ),
      FeatureItem(
        Icons.person,
        '个性化教学',
        '根据学生特点制定教学计划',
        Colors.green,
      ),
      FeatureItem(
        Icons.groups,
        '小班教学',
        '确保每个学生得到充分关注',
        Colors.orange,
      ),
      FeatureItem(
        Icons.assessment,
        '进度跟踪',
        '定期评估学生学习进度',
        Colors.purple,
      ),
    ];
  }

  // 运输服务特色
  static List<FeatureItem> _getTransportationServiceFeatures(Map<String, dynamic>? providerData) {
    return [
      FeatureItem(
        Icons.drive_eta,
        '专业司机',
        '经验丰富的驾驶人员，安全可靠',
        Colors.blue,
      ),
      FeatureItem(
        Icons.directions_car,
        '安全车辆',
        '定期维护的安全车辆，确保出行安全',
        Colors.green,
      ),
      FeatureItem(
        Icons.schedule,
        '准时服务',
        '严格按照约定时间到达',
        Colors.orange,
      ),
      FeatureItem(
        Icons.security,
        '保险保障',
        '全程保险覆盖，保障客户权益',
        Colors.red,
      ),
    ];
  }

  // 餐饮服务特色
  static List<FeatureItem> _getFoodServiceFeatures(Map<String, dynamic>? providerData) {
    return [
      FeatureItem(
        Icons.restaurant,
        '专业厨师',
        '经验丰富的烹饪师，制作美味佳肴',
        Colors.orange,
      ),
      FeatureItem(
        Icons.restaurant_menu,
        '新鲜食材',
        '严格挑选优质食材，确保食品安全',
        Colors.green,
      ),
      FeatureItem(
        Icons.health_and_safety,
        '卫生标准',
        '严格遵循食品安全标准',
        Colors.blue,
      ),
      FeatureItem(
        Icons.delivery_dining,
        '准时配送',
        '按时送达，保持食物新鲜',
        Colors.red,
      ),
    ];
  }

  // 健康服务特色
  static List<FeatureItem> _getHealthServiceFeatures(Map<String, dynamic>? providerData) {
    return [
      FeatureItem(
        Icons.medical_services,
        '专业医师',
        '持证上岗的医疗人员，提供专业服务',
        Colors.blue,
      ),
      FeatureItem(
        Icons.health_and_safety,
        '安全标准',
        '严格遵循医疗安全标准',
        Colors.green,
      ),
      FeatureItem(
        Icons.privacy_tip,
        '隐私保护',
        '严格保护客户隐私',
        Colors.purple,
      ),
      FeatureItem(
        Icons.medical_information,
        '专业设备',
        '配备专业医疗设备',
        Colors.orange,
      ),
    ];
  }

  // 技术服务特色
  static List<FeatureItem> _getTechnologyServiceFeatures(Map<String, dynamic>? providerData) {
    return [
      FeatureItem(
        Icons.computer,
        '技术专家',
        '经验丰富的技术人员，快速解决问题',
        Colors.blue,
      ),
      FeatureItem(
        Icons.trending_up,
        '最新技术',
        '掌握最新技术趋势，提供先进解决方案',
        Colors.green,
      ),
      FeatureItem(
        Icons.speed,
        '快速解决',
        '快速诊断和解决问题，减少停机时间',
        Colors.orange,
      ),
      FeatureItem(
        Icons.support_agent,
        '远程支持',
        '提供远程技术支持，及时响应需求',
        Colors.purple,
      ),
    ];
  }

  // 通用服务特色
  static List<FeatureItem> _getGeneralServiceFeatures(Map<String, dynamic>? providerData) {
    return [
      FeatureItem(
        Icons.verified_user,
        '专业团队',
        '经验丰富的服务人员，经过严格培训',
        Colors.blue,
      ),
      FeatureItem(
        Icons.security,
        '安全保障',
        '所有服务都有保险覆盖，确保客户权益',
        Colors.green,
      ),
      FeatureItem(
        Icons.schedule,
        '灵活安排',
        '根据客户时间灵活调整，提供便捷服务',
        Colors.purple,
      ),
      FeatureItem(
        Icons.eco,
        '环保理念',
        '使用环保产品，保护环境',
        Colors.teal,
      ),
    ];
  }

  // 质量保证模板
  static String _getCleaningQualityAssurance(Map<String, dynamic>? providerData) {
    return '我们承诺提供最优质的清洁服务：\n'
           '• 清洁不满意免费重做\n'
           '• 使用环保清洁产品\n'
           '• 专业清洁设备保障\n'
           '• 24小时客户服务支持';
  }

  static String _getMaintenanceQualityAssurance(Map<String, dynamic>? providerData) {
    return '我们承诺提供最优质的维修服务：\n'
           '• 维修后提供保修服务\n'
           '• 使用原厂配件\n'
           '• 专业工具设备保障\n'
           '• 24小时紧急维修支持';
  }

  static String _getBeautyQualityAssurance(Map<String, dynamic>? providerData) {
    return '我们承诺提供最优质的美容服务：\n'
           '• 美容效果不满意免费调整\n'
           '• 使用知名品牌产品\n'
           '• 严格卫生消毒标准\n'
           '• 专业美容设备保障';
  }

  static String _getEducationQualityAssurance(Map<String, dynamic>? providerData) {
    return '我们承诺提供最优质的教育服务：\n'
           '• 学习效果不满意免费补课\n'
           '• 个性化教学方案\n'
           '• 专业教学设备保障\n'
           '• 定期学习进度评估';
  }

  static String _getTransportationQualityAssurance(Map<String, dynamic>? providerData) {
    return '我们承诺提供最优质的运输服务：\n'
           '• 准时到达，延误全额退款\n'
           '• 安全驾驶，全程保险\n'
           '• 专业车辆维护保障\n'
           '• 24小时客服支持';
  }

  static String _getFoodQualityAssurance(Map<String, dynamic>? providerData) {
    return '我们承诺提供最优质的餐饮服务：\n'
           '• 食品安全问题全额退款\n'
           '• 使用新鲜优质食材\n'
           '• 严格卫生标准保障\n'
           '• 准时配送，保持新鲜';
  }

  static String _getHealthQualityAssurance(Map<String, dynamic>? providerData) {
    return '我们承诺提供最优质的健康服务：\n'
           '• 服务不满意全额退款\n'
           '• 严格医疗安全标准\n'
           '• 专业医疗设备保障\n'
           '• 24小时医疗咨询支持';
  }

  static String _getTechnologyQualityAssurance(Map<String, dynamic>? providerData) {
    return '我们承诺提供最优质的技术服务：\n'
           '• 技术问题解决不满意免费重做\n'
           '• 使用最新技术方案\n'
           '• 专业技术设备保障\n'
           '• 24小时技术支持';
  }

  static String _getGeneralQualityAssurance(Map<String, dynamic>? providerData) {
    return '我们承诺提供最优质的服务体验：\n'
           '• 服务不满意全额退款\n'
           '• 24小时客户服务支持\n'
           '• 专业设备和技术保障\n'
           '• 定期质量检查和改进';
  }

  // 专业资质模板
  static String _getCleaningProfessionalQualification(Map<String, dynamic>? providerData) {
    return '我们拥有专业的清洁服务团队，所有员工都经过严格培训和背景调查。我们使用环保清洁产品，确保家庭环境既清洁又健康。我们致力于为客户提供高质量、可靠的清洁服务体验。';
  }

  static String _getMaintenanceProfessionalQualification(Map<String, dynamic>? providerData) {
    return '我们拥有专业的维修技术团队，所有技师都具备相关技术资质和丰富经验。我们配备专业维修工具和设备，能够快速诊断和解决各种维修问题。我们致力于为客户提供高效、可靠的维修服务。';
  }

  static String _getBeautyProfessionalQualification(Map<String, dynamic>? providerData) {
    return '我们拥有专业的美容师团队，所有美容师都持有相关资质证书。我们使用知名品牌美容产品，严格遵循卫生消毒标准。我们致力于为客户提供安全、有效的美容护理服务。';
  }

  static String _getEducationProfessionalQualification(Map<String, dynamic>? providerData) {
    return '我们拥有专业的教育工作者团队，所有教师都具备相关教育资质和丰富教学经验。我们采用个性化教学方法，能够因材施教。我们致力于帮助学生取得学习进步。';
  }

  static String _getTransportationProfessionalQualification(Map<String, dynamic>? providerData) {
    return '我们拥有专业的驾驶团队，所有司机都具备相关驾驶资质和丰富驾驶经验。我们配备安全可靠的车辆，定期进行维护保养。我们致力于为客户提供安全、准时的运输服务。';
  }

  static String _getFoodProfessionalQualification(Map<String, dynamic>? providerData) {
    return '我们拥有专业的厨师团队，所有厨师都具备相关烹饪资质和丰富烹饪经验。我们严格挑选优质食材，遵循食品安全标准。我们致力于为客户提供美味、安全的餐饮服务。';
  }

  static String _getHealthProfessionalQualification(Map<String, dynamic>? providerData) {
    return '我们拥有专业的医疗团队，所有医师都具备相关医疗资质和丰富医疗经验。我们严格遵循医疗安全标准，保护客户隐私。我们致力于为客户提供安全、有效的健康服务。';
  }

  static String _getTechnologyProfessionalQualification(Map<String, dynamic>? providerData) {
    return '我们拥有专业的技术团队，所有技术人员都具备相关技术资质和丰富技术经验。我们掌握最新技术趋势，配备专业技术设备。我们致力于为客户提供高效、可靠的技术解决方案。';
  }

  static String _getGeneralProfessionalQualification(Map<String, dynamic>? providerData) {
    return '我们拥有专业的服务团队，所有员工都经过严格培训和背景调查。我们致力于为客户提供高质量、可靠的服务体验。';
  }
}

/// 特色项目数据模型
class FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  FeatureItem(this.icon, this.title, this.description, this.color);
} 