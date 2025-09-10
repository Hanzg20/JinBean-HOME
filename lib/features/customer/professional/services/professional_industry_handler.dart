import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/base_models.dart';
import '../../../../core/models/order_models.dart';
import '../../../../core/models/payment_models.dart';
import '../../../../core/services/universal_order_service.dart';
import '../../../../core/services/universal_payment_service.dart';

/// 专业速帮行业订单处理器
/// 
/// 实现专业速帮行业特定的订单处理逻辑：
/// - 专业资质验证和匹配
/// - 咨询预约和时间管理
/// - 专业报告和成果交付
/// - 保密协议和合规要求
/// - 多种专业服务支持（法律、财务、设计、咨询）
class ProfessionalIndustryOrderHandler implements IndustryOrderHandler {
  final _supabase = Supabase.instance.client;

  @override
  Future<void> preprocessOrder(OrderRequest request) async {
    print('💼 专业速帮订单预处理');

    final serviceType = request.industrySpecificData.get<String>('service_type', 'consultation');
    
    // 验证专业服务类型和时间
    if (['consultation', 'legal_advice', 'financial_planning'].contains(serviceType)) {
      if (request.scheduledTime == null) {
        throw OrderException('${_getServiceTypeName(serviceType ?? 'consultation')}需要预约时间');
      }
    }

    // 验证专业资质要求
    await _validateProfessionalRequirements(request);

    // 检查专家可用性
    final isAvailable = await _checkExpertAvailability(
      request.providerId,
      request.scheduledTime,
    );
    if (!isAvailable) {
      throw OrderException('专家在选定时间不可用');
    }

    // 验证保密协议
    await _validateConfidentialityAgreement(request);

    // 检查服务复杂度和预算匹配
    await _validateServiceScope(request);

    // 验证必要的文档和资料
    await _validateRequiredDocuments(request);
  }

  @override
  Future<void> postprocessOrder(Order order) async {
    print('💼 专业速帮订单后处理');

    final serviceType = order.getIndustryData<String>('service_type', 'consultation');
    
    // 设置专业服务特定的元数据
    order.setIndustryData('service_category', await _getServiceCategory(order.serviceId));
    order.setIndustryData('expertise_level', await _getExpertiseLevel(order.providerId));
    order.setIndustryData('estimated_completion_time', await _getEstimatedCompletionTime(order.serviceId));
    order.setIndustryData('deliverable_type', await _getDeliverableType(order.serviceId));
    
    // 根据服务类型设置特定信息
    switch (serviceType) {
      case 'legal_advice':
        await _setupLegalService(order);
        break;
      case 'financial_planning':
        await _setupFinancialService(order);
        break;
      case 'design_service':
        await _setupDesignService(order);
        break;
      case 'business_consulting':
        await _setupConsultingService(order);
        break;
      case 'technical_consulting':
        await _setupTechnicalService(order);
        break;
    }

    // 创建专业服务工作区
    await _createWorkspace(order);

    // 分配专家和建立沟通渠道
    await _assignExpert(order);
    await _setupCommunicationChannel(order);

    // 发送服务启动通知
    await _sendServiceInitiationNotification(order);
  }

  @override
  Future<ValidationResult> validateOrder(OrderRequest request) async {
    final errors = <String>[];
    final fieldErrors = <String, String>{};

    // 验证服务类型
    final serviceType = request.industrySpecificData.get<String>('service_type');
    if (serviceType == null || !['legal_advice', 'financial_planning', 'design_service', 'business_consulting', 'technical_consulting', 'consultation'].contains(serviceType)) {
      fieldErrors['service_type'] = '请选择有效的专业服务类型';
    }

    // 验证服务时间
    if (['consultation', 'legal_advice', 'financial_planning'].contains(serviceType) && request.scheduledTime != null) {
      final timeValidation = await _validateConsultationTime(request.scheduledTime!);
      if (!timeValidation.isValid) {
        fieldErrors['scheduled_time'] = timeValidation.firstError;
      }
    }

    // 验证服务项目
    for (int i = 0; i < request.items.length; i++) {
      final item = request.items[i];
      final itemValidation = await _validateProfessionalService(item, serviceType!);
      if (!itemValidation.isValid) {
        fieldErrors['items[$i]'] = itemValidation.firstError;
      }
    }

    // 验证预算范围
    final budgetValidation = await _validateBudgetRange(request);
    if (!budgetValidation.isValid) {
      fieldErrors['budget'] = budgetValidation.firstError;
    }

    // 验证保密要求
    final confidentialityLevel = request.industrySpecificData.get<String>('confidentiality_level');
    if (confidentialityLevel != null) {
      final confidentialityValidation = await _validateConfidentialityLevel(confidentialityLevel);
      if (!confidentialityValidation.isValid) {
        fieldErrors['confidentiality_level'] = confidentialityValidation.firstError;
      }
    }

    // 验证交付要求
    final deliverableRequirements = request.industrySpecificData.get<Map<String, dynamic>>('deliverable_requirements');
    if (deliverableRequirements != null) {
      final deliverableValidation = await _validateDeliverableRequirements(deliverableRequirements);
      if (!deliverableValidation.isValid) {
        errors.addAll(deliverableValidation.errors);
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty && fieldErrors.isEmpty,
      errors: errors,
      fieldErrors: fieldErrors,
    );
  }

  @override
  Future<PricingResult?> adjustPricing({
    required Price baseAmount,
    required List<PricingFee> fees,
    required List<PricingDiscount> discounts,
    required OrderRequest request,
  }) async {
    print('🧮 专业速帮定价调整');

    final adjustedFees = List<PricingFee>.from(fees);
    final adjustedDiscounts = List<PricingDiscount>.from(discounts);

    final serviceType = request.industrySpecificData.get<String>('service_type', 'consultation');

    // 添加专业服务特定费用
    await _addExpertiseFees(adjustedFees, request, baseAmount);
    await _addUrgencyFees(adjustedFees, request, baseAmount);
    await _addComplexityFees(adjustedFees, request, baseAmount);
    await _addConfidentialityFees(adjustedFees, request, baseAmount);
    await _addDeliverableFees(adjustedFees, request, baseAmount);

    // 检查专业服务优惠
    await _checkProfessionalPromotions(adjustedDiscounts, baseAmount, request);

    // 计算最终价格
    final feesTotal = adjustedFees.fold(
      Price(amount: 0.0, currency: baseAmount.currency),
      (sum, fee) => sum + fee.amount,
    );

    final discountsTotal = adjustedDiscounts.fold(
      Price(amount: 0.0, currency: baseAmount.currency),
      (sum, discount) => sum + discount.amount,
    );

    final totalAmount = baseAmount + feesTotal - discountsTotal;

    return PricingResult(
      baseAmount: baseAmount,
      fees: adjustedFees,
      discounts: adjustedDiscounts,
      totalAmount: totalAmount,
      currency: baseAmount.currency,
      breakdown: {
        'base_consultation_fee': baseAmount.amount,
        'expertise_fee': _getFeeAmount(adjustedFees, 'expertise'),
        'urgency_fee': _getFeeAmount(adjustedFees, 'urgency'),
        'complexity_fee': _getFeeAmount(adjustedFees, 'complexity'),
        'confidentiality_fee': _getFeeAmount(adjustedFees, 'confidentiality'),
        'deliverable_fee': _getFeeAmount(adjustedFees, 'deliverable'),
        'platform_fee': _getFeeAmount(adjustedFees, 'platform'),
        'total_discounts': discountsTotal.amount,
        'final_total': totalAmount.amount,
      },
    );
  }

  @override
  Future<void> onStatusChange(Order order, OrderStatus newStatus, String? reason) async {
    print('🔄 专业速帮订单状态变更: ${order.status.label} -> ${newStatus.label}');

    switch (newStatus) {
      case OrderStatus.accepted:
        await _onServiceAccepted(order);
        break;
      case OrderStatus.inProgress:
        await _onServiceStarted(order);
        break;
      case OrderStatus.completed:
        await _onServiceCompleted(order);
        break;
      case OrderStatus.cancelled:
        await _onServiceCancelled(order, reason);
        break;
      default:
        break;
    }

    // 发送状态更新通知
    await _sendStatusUpdateNotification(order, newStatus, reason);
  }

  @override
  Future<void> onOrderCancellation(Order order, String reason) async {
    print('❌ 专业速帮订单取消处理');

    // 检查取消政策
    final cancellationPolicy = await _checkCancellationPolicy(order);
    if (!cancellationPolicy.canCancel) {
      throw OrderException(cancellationPolicy.reason ?? '服务无法取消');
    }

    // 计算取消费用
    final cancellationFee = await _calculateCancellationFee(order, reason);
    if (cancellationFee.amount > 0) {
      print('💰 取消费用: ${cancellationFee.formatted}');
    }

    // 释放专家时间
    await _releaseExpertTime(order);

    // 保存工作进度
    await _saveWorkProgress(order);

    // 通知相关方
    await _notifyServiceCancellation(order, reason);
  }

  // ========================================
  // 私有方法 - 验证逻辑
  // ========================================

  /// 验证专业资质要求
  Future<void> _validateProfessionalRequirements(OrderRequest request) async {
    final serviceType = request.industrySpecificData.get<String>('service_type');
    
    // 法律服务需要律师资格
    if (serviceType == 'legal_advice') {
      final hasLegalLicense = await _checkProviderLicense(request.providerId, 'legal');
      if (!hasLegalLicense) {
        throw OrderException('提供法律服务需要律师执业资格');
      }
    }

    // 财务规划需要相关资质
    if (serviceType == 'financial_planning') {
      final hasFinancialLicense = await _checkProviderLicense(request.providerId, 'financial');
      if (!hasFinancialLicense) {
        throw OrderException('提供财务规划服务需要相关专业资质');
      }
    }

    // 检查专业经验要求
    final requiredExperience = await _getRequiredExperience(serviceType!);
    final providerExperience = await _getProviderExperience(request.providerId, serviceType);
    
    if (providerExperience < requiredExperience) {
      throw OrderException('该服务需要至少${requiredExperience}年专业经验');
    }
  }

  /// 检查专家可用性
  Future<bool> _checkExpertAvailability(String expertId, TimeRange? scheduledTime) async {
    if (scheduledTime == null) return true;

    try {
      // 检查专家是否在指定时间有其他预约
      final conflicts = await _supabase
          .from('expert_schedules')
          .select('start_time, end_time')
          .eq('expert_id', expertId)
          .eq('is_booked', true)
          .gte('start_time', scheduledTime.start.toIso8601String())
          .lte('end_time', scheduledTime.end.toIso8601String());

      return conflicts.isEmpty;
    } catch (e) {
      print('⚠️ 专家可用性检查失败: $e');
      return true;
    }
  }

  /// 验证保密协议
  Future<void> _validateConfidentialityAgreement(OrderRequest request) async {
    final confidentialityLevel = request.industrySpecificData.get<String>('confidentiality_level');
    
    if (confidentialityLevel == 'high' || confidentialityLevel == 'enterprise') {
      final hasSignedNDA = request.industrySpecificData.get<bool>('has_signed_nda', false) ?? false;
      if (!hasSignedNDA) {
        throw OrderException('高级保密服务需要签署保密协议');
      }
    }
  }

  /// 验证服务范围
  Future<void> _validateServiceScope(OrderRequest request) async {
    final estimatedBudget = request.estimatedTotal;
    final complexity = request.industrySpecificData.get<String>('complexity_level', 'medium');
    
    // 根据复杂度检查预算是否合理
    final minBudget = await _getMinimumBudget(complexity ?? 'medium');
    if (estimatedBudget < minBudget) {
      throw OrderException('${complexity}复杂度的服务最低预算为\$${minBudget.toStringAsFixed(2)}');
    }

    // 检查服务范围是否明确
    final serviceScope = request.industrySpecificData.get<String>('service_scope');
    if (serviceScope == null || serviceScope.isEmpty) {
      throw OrderException('请明确描述服务范围和需求');
    }
  }

  /// 验证必要文档
  Future<void> _validateRequiredDocuments(OrderRequest request) async {
    final serviceType = request.industrySpecificData.get<String>('service_type');
    final requiredDocs = await _getRequiredDocuments(serviceType!);
    
    final providedDocs = request.industrySpecificData.get<List<String>>('provided_documents', []) ?? <String>[];
    
    for (final requiredDoc in requiredDocs) {
      if (!providedDocs.contains(requiredDoc)) {
        throw OrderException('缺少必要文档：${_getDocumentName(requiredDoc)}');
      }
    }
  }

  /// 验证咨询时间
  Future<ValidationResult> _validateConsultationTime(TimeRange consultationTime) async {
    final errors = <String>[];

    // 检查开始时间不能是过去
    if (consultationTime.start.isBefore(DateTime.now())) {
      errors.add('咨询开始时间不能是过去时间');
    }

    // 检查最小提前预约时间
    final minAdvanceHours = 4;
    if (consultationTime.start.isBefore(DateTime.now().add(Duration(hours: minAdvanceHours)))) {
      errors.add('专业咨询请至少提前${minAdvanceHours}小时预约');
    }

    // 检查咨询时长
    if (consultationTime.duration.inMinutes < 30) {
      errors.add('单次咨询时间不能少于30分钟');
    }

    if (consultationTime.duration.inHours > 8) {
      errors.add('单次咨询时间不能超过8小时');
    }

    // 检查营业时间
    final isBusinessHours = await _checkBusinessHours(consultationTime.start);
    if (!isBusinessHours) {
      errors.add('请在营业时间内预约咨询');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// 验证专业服务项目
  Future<ValidationResult> _validateProfessionalService(OrderItemRequest item, String serviceType) async {
    try {
      final serviceDetails = await _supabase
          .from('professional_services')
          .select('is_available, service_type, expertise_required, estimated_hours')
          .eq('id', item.serviceDetailId)
          .single();

      if (!serviceDetails['is_available']) {
        return ValidationResult.invalid(['服务当前不可用']);
      }

      final itemServiceType = serviceDetails['service_type'] as String?;
      if (itemServiceType != serviceType) {
        return ValidationResult.invalid(['服务类型不匹配']);
      }

      // 检查是否需要特殊专业资质
      final expertiseRequired = serviceDetails['expertise_required'] as String?;
      if (expertiseRequired != null) {
        final hasRequiredExpertise = await _checkExpertiseAvailability(expertiseRequired);
        if (!hasRequiredExpertise) {
          return ValidationResult.invalid(['当前没有具备所需专业资质的专家']);
        }
      }

      return ValidationResult.valid();
    } catch (e) {
      return ValidationResult.invalid(['服务验证失败']);
    }
  }

  /// 验证预算范围
  Future<ValidationResult> _validateBudgetRange(OrderRequest request) async {
    final estimatedBudget = request.estimatedTotal;
    final serviceType = request.industrySpecificData.get<String>('service_type');
    
    final budgetRange = await _getServiceBudgetRange(serviceType!);
    
    if (estimatedBudget < budgetRange.minimum) {
      return ValidationResult.invalid(['预算低于最低要求：\$${budgetRange.minimum.toStringAsFixed(2)}']);
    }
    
    if (estimatedBudget > budgetRange.maximum) {
      return ValidationResult.invalid(['预算超过最高限额：\$${budgetRange.maximum.toStringAsFixed(2)}']);
    }

    return ValidationResult.valid();
  }

  /// 验证保密级别
  Future<ValidationResult> _validateConfidentialityLevel(String level) async {
    final validLevels = ['standard', 'high', 'enterprise'];
    
    if (!validLevels.contains(level)) {
      return ValidationResult.invalid(['无效的保密级别']);
    }

    // 检查是否有提供对应级别保密服务的专家
    final hasCapacity = await _checkConfidentialityCapacity(level);
    if (!hasCapacity) {
      return ValidationResult.invalid(['当前无法提供该级别的保密服务']);
    }

    return ValidationResult.valid();
  }

  /// 验证交付要求
  Future<ValidationResult> _validateDeliverableRequirements(Map<String, dynamic> requirements) async {
    final errors = <String>[];

    // 验证交付格式
    final format = requirements['format'] as String?;
    if (format != null && !['document', 'presentation', 'report', 'consultation', 'prototype'].contains(format)) {
      errors.add('不支持的交付格式');
    }

    // 验证交付时限
    final deadline = requirements['deadline'] as String?;
    if (deadline != null) {
      final deadlineDate = DateTime.parse(deadline);
      if (deadlineDate.isBefore(DateTime.now().add(const Duration(days: 1)))) {
        errors.add('交付时限至少需要1天');
      }
    }

    // 验证质量要求
    final qualityLevel = requirements['quality_level'] as String?;
    if (qualityLevel == 'premium') {
      final hasPremiumExperts = await _checkPremiumExpertAvailability();
      if (!hasPremiumExperts) {
        errors.add('当前没有可提供高端质量服务的专家');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // ========================================
  // 私有方法 - 定价逻辑
  // ========================================

  /// 添加专业技能费用
  Future<void> _addExpertiseFees(
    List<PricingFee> fees,
    OrderRequest request,
    Price baseAmount,
  ) async {
    final expertiseLevel = request.industrySpecificData.get<String>('expertise_level', 'standard');
    
    double expertiseMultiplier = 0.0;
    String description = '';
    
    switch (expertiseLevel) {
      case 'senior':
        expertiseMultiplier = 0.3;
        description = '资深专家服务费（30%）';
        break;
      case 'expert':
        expertiseMultiplier = 0.5;
        description = '顶级专家服务费（50%）';
        break;
      case 'specialist':
        expertiseMultiplier = 0.7;
        description = '专业专家服务费（70%）';
        break;
    }

    if (expertiseMultiplier > 0) {
      final expertiseFee = baseAmount.amount * expertiseMultiplier;
      fees.add(PricingFee(
        type: 'expertise',
        name: '专业技能费',
        amount: Price(amount: expertiseFee, currency: baseAmount.currency),
        description: description,
      ));
    }
  }

  /// 添加紧急服务费用
  Future<void> _addUrgencyFees(
    List<PricingFee> fees,
    OrderRequest request,
    Price baseAmount,
  ) async {
    final isUrgent = request.industrySpecificData.get<bool>('is_urgent', false) ?? false;
    if (!isUrgent) return;

    final urgencyLevel = request.industrySpecificData.get<String>('urgency_level', 'standard');
    
    double urgencyMultiplier = 0.0;
    String description = '';
    
    switch (urgencyLevel) {
      case 'urgent':
        urgencyMultiplier = 0.5;
        description = '加急服务费（48小时内，50%）';
        break;
      case 'rush':
        urgencyMultiplier = 1.0;
        description = '特急服务费（24小时内，100%）';
        break;
      case 'emergency':
        urgencyMultiplier = 2.0;
        description = '紧急服务费（12小时内，200%）';
        break;
    }

    if (urgencyMultiplier > 0) {
      final urgencyFee = baseAmount.amount * urgencyMultiplier;
      fees.add(PricingFee(
        type: 'urgency',
        name: '紧急服务费',
        amount: Price(amount: urgencyFee, currency: baseAmount.currency),
        description: description,
      ));
    }
  }

  /// 添加复杂度费用
  Future<void> _addComplexityFees(
    List<PricingFee> fees,
    OrderRequest request,
    Price baseAmount,
  ) async {
    final complexityLevel = request.industrySpecificData.get<String>('complexity_level', 'medium');
    
    double complexityMultiplier = 0.0;
    String description = '';
    
    switch (complexityLevel) {
      case 'high':
        complexityMultiplier = 0.4;
        description = '高复杂度服务费（40%）';
        break;
      case 'very_high':
        complexityMultiplier = 0.8;
        description = '极高复杂度服务费（80%）';
        break;
    }

    if (complexityMultiplier > 0) {
      final complexityFee = baseAmount.amount * complexityMultiplier;
      fees.add(PricingFee(
        type: 'complexity',
        name: '复杂度费用',
        amount: Price(amount: complexityFee, currency: baseAmount.currency),
        description: description,
      ));
    }
  }

  /// 添加保密服务费用
  Future<void> _addConfidentialityFees(
    List<PricingFee> fees,
    OrderRequest request,
    Price baseAmount,
  ) async {
    final confidentialityLevel = request.industrySpecificData.get<String>('confidentiality_level', 'standard');
    
    double confidentialityFee = 0.0;
    String description = '';
    
    switch (confidentialityLevel) {
      case 'high':
        confidentialityFee = 100.0;
        description = '高级保密服务费';
        break;
      case 'enterprise':
        confidentialityFee = 300.0;
        description = '企业级保密服务费';
        break;
    }

    if (confidentialityFee > 0) {
      fees.add(PricingFee(
        type: 'confidentiality',
        name: '保密服务费',
        amount: Price(amount: confidentialityFee, currency: baseAmount.currency),
        description: description,
      ));
    }
  }

  /// 添加交付物费用
  Future<void> _addDeliverableFees(
    List<PricingFee> fees,
    OrderRequest request,
    Price baseAmount,
  ) async {
    final deliverableType = request.industrySpecificData.get<String>('deliverable_type');
    
    double deliverableFee = 0.0;
    String description = '';
    
    switch (deliverableType) {
      case 'detailed_report':
        deliverableFee = 150.0;
        description = '详细报告制作费';
        break;
      case 'presentation':
        deliverableFee = 100.0;
        description = '演示文稿制作费';
        break;
      case 'legal_document':
        deliverableFee = 200.0;
        description = '法律文书制作费';
        break;
      case 'technical_specification':
        deliverableFee = 250.0;
        description = '技术规格文档制作费';
        break;
    }

    if (deliverableFee > 0) {
      fees.add(PricingFee(
        type: 'deliverable',
        name: '交付物制作费',
        amount: Price(amount: deliverableFee, currency: baseAmount.currency),
        description: description,
      ));
    }

    // 平台服务费
    final platformFee = baseAmount.amount * 0.12; // 12%平台费
    fees.add(PricingFee(
      type: 'platform',
      name: '平台服务费',
      amount: Price(amount: platformFee, currency: baseAmount.currency),
      description: '12%专业服务平台费',
    ));
  }

  /// 检查专业服务优惠
  Future<void> _checkProfessionalPromotions(
    List<PricingDiscount> discounts,
    Price baseAmount,
    OrderRequest request,
  ) async {
    // 企业客户优惠
    final isEnterprise = request.industrySpecificData.get<bool>('is_enterprise_client', false) ?? false;
    if (isEnterprise) {
      discounts.add(PricingDiscount(
        type: 'enterprise',
        name: '企业客户优惠',
        amount: Price(amount: baseAmount.amount * 0.1, currency: baseAmount.currency),
        description: '企业客户享受10%折扣',
      ));
    }

    // 长期合作优惠
    final isLongTerm = request.industrySpecificData.get<bool>('is_long_term_project', false) ?? false;
    if (isLongTerm) {
      discounts.add(PricingDiscount(
        type: 'long_term',
        name: '长期项目优惠',
        amount: Price(amount: baseAmount.amount * 0.15, currency: baseAmount.currency),
        description: '长期项目享受15%折扣',
      ));
    }

    // 推荐客户优惠
    final isReferred = request.industrySpecificData.get<bool>('is_referred_client', false) ?? false;
    if (isReferred) {
      discounts.add(PricingDiscount(
        type: 'referral',
        name: '推荐客户优惠',
        amount: Price(amount: 100.0, currency: baseAmount.currency),
        description: '推荐客户专享优惠',
      ));
    }

    // 非营业时间优惠
    final scheduledTime = request.scheduledTime?.start;
    if (scheduledTime != null) {
      final isOffHours = await _isOffBusinessHours(scheduledTime);
      if (isOffHours) {
        discounts.add(PricingDiscount(
          type: 'off_hours',
          name: '非营业时间优惠',
          amount: Price(amount: 50.0, currency: baseAmount.currency),
          description: '非营业时间咨询优惠',
        ));
      }
    }
  }

  // ========================================
  // 私有方法 - 状态处理
  // ========================================

  /// 服务被接受时的处理
  Future<void> _onServiceAccepted(Order order) async {
    print('✅ 专业服务已接受');

    // 创建项目工作区
    await _createProjectWorkspace(order);

    // 发送欢迎邮件和项目启动资料
    await _sendProjectKickoffMaterials(order);

    // 安排初始会议
    await _scheduleInitialMeeting(order);

    // 设置项目里程碑
    await _setupProjectMilestones(order);
  }

  /// 服务开始时的处理
  Future<void> _onServiceStarted(Order order) async {
    print('💼 专业服务开始');

    // 记录服务开始时间
    order.setIndustryData('actual_start_time', DateTime.now().toIso8601String());

    // 激活工作区权限
    await _activateWorkspaceAccess(order);

    // 发送服务开始通知
    await _sendServiceStartNotification(order);

    // 开始进度跟踪
    await _startProgressTracking(order);
  }

  /// 服务完成时的处理
  Future<void> _onServiceCompleted(Order order) async {
    print('🎯 专业服务完成');

    // 记录服务完成时间
    order.setIndustryData('actual_end_time', DateTime.now().toIso8601String());

    // 交付最终成果
    await _deliverFinalOutput(order);

    // 生成服务报告
    await _generateServiceReport(order);

    // 安排项目总结会议
    await _scheduleWrapUpMeeting(order);

    // 发送完成通知和评价邀请
    await _sendServiceCompletionNotification(order);
    await _inviteServiceReview(order);

    // 归档项目文件
    await _archiveProjectFiles(order);
  }

  /// 服务取消时的处理
  Future<void> _onServiceCancelled(Order order, String? reason) async {
    print('❌ 专业服务已取消: $reason');

    // 记录取消信息
    order.setIndustryData('cancellation_time', DateTime.now().toIso8601String());
    order.setIndustryData('cancellation_category', _categorizeCancellationReason(reason));

    // 保存工作进度
    await _saveWorkProgress(order);

    // 释放专家时间
    await _releaseExpertTime(order);

    // 暂停工作区访问
    await _suspendWorkspaceAccess(order);
  }

  // ========================================
  // 私有方法 - 辅助功能
  // ========================================

  /// 获取服务类型名称
  String _getServiceTypeName(String type) {
    switch (type) {
      case 'legal_advice':
        return '法律咨询';
      case 'financial_planning':
        return '财务规划';
      case 'design_service':
        return '设计服务';
      case 'business_consulting':
        return '商业咨询';
      case 'technical_consulting':
        return '技术咨询';
      case 'consultation':
        return '专业咨询';
      default:
        return '专业服务';
    }
  }

  /// 获取文档名称
  String _getDocumentName(String docType) {
    switch (docType) {
      case 'business_license':
        return '营业执照';
      case 'financial_statement':
        return '财务报表';
      case 'technical_specification':
        return '技术规格';
      case 'legal_document':
        return '法律文件';
      default:
        return '相关文档';
    }
  }

  /// 工具方法
  double _getFeeAmount(List<PricingFee> fees, String type) {
    final fee = fees.firstWhereOrNull((f) => f.type == type);
    return fee?.amount.amount ?? 0.0;
  }

  String _categorizeCancellationReason(String? reason) {
    if (reason == null) return 'unknown';
    
    if (reason.contains('scope_change')) return 'scope_related';
    if (reason.contains('budget_constraint')) return 'budget_related';
    if (reason.contains('timeline_issue')) return 'timeline_related';
    if (reason.contains('expert_unavailable')) return 'resource_related';
    
    return 'other';
  }

  // ========================================
  // 私有方法 - 占位符实现
  // ========================================

  Future<bool> _checkProviderLicense(String providerId, String licenseType) async {
    // TODO: 检查服务商专业资质
    return true;
  }

  Future<int> _getRequiredExperience(String serviceType) async {
    // TODO: 获取所需经验年限
    switch (serviceType) {
      case 'legal_advice':
        return 5;
      case 'financial_planning':
        return 3;
      default:
        return 2;
    }
  }

  Future<int> _getProviderExperience(String providerId, String serviceType) async {
    // TODO: 获取服务商经验年限
    return 5; // 模拟5年经验
  }

  Future<double> _getMinimumBudget(String complexity) async {
    // TODO: 根据复杂度获取最低预算
    switch (complexity) {
      case 'high':
        return 1000.0;
      case 'very_high':
        return 2500.0;
      case 'medium':
        return 500.0;
      default:
        return 200.0;
    }
  }

  Future<List<String>> _getRequiredDocuments(String serviceType) async {
    // TODO: 获取必需文档列表
    switch (serviceType) {
      case 'legal_advice':
        return ['business_license', 'legal_document'];
      case 'financial_planning':
        return ['financial_statement'];
      default:
        return [];
    }
  }

  Future<bool> _checkBusinessHours(DateTime time) async {
    // TODO: 检查营业时间
    final hour = time.hour;
    return hour >= 9 && hour <= 17; // 9-17点营业
  }

  Future<bool> _checkExpertiseAvailability(String expertise) async {
    // TODO: 检查专业技能可用性
    return true;
  }

  Future<({double minimum, double maximum})> _getServiceBudgetRange(String serviceType) async {
    // TODO: 获取服务预算范围
    switch (serviceType) {
      case 'legal_advice':
        return (minimum: 200.0, maximum: 10000.0);
      case 'financial_planning':
        return (minimum: 300.0, maximum: 8000.0);
      default:
        return (minimum: 100.0, maximum: 5000.0);
    }
  }

  Future<bool> _checkConfidentialityCapacity(String level) async {
    // TODO: 检查保密服务能力
    return true;
  }

  Future<bool> _checkPremiumExpertAvailability() async {
    // TODO: 检查高端专家可用性
    return true;
  }

  Future<bool> _isOffBusinessHours(DateTime time) async {
    // TODO: 检查是否为非营业时间
    final hour = time.hour;
    return hour < 9 || hour > 17;
  }

  Future<String> _getServiceCategory(String serviceId) async {
    // TODO: 获取服务分类
    return 'general';
  }

  Future<String> _getExpertiseLevel(String providerId) async {
    // TODO: 获取专家技能等级
    return 'senior';
  }

  Future<int> _getEstimatedCompletionTime(String serviceId) async {
    // TODO: 获取预估完成时间
    return 7; // 7天
  }

  Future<String> _getDeliverableType(String serviceId) async {
    // TODO: 获取交付物类型
    return 'detailed_report';
  }

  Future<void> _setupLegalService(Order order) async {
    // TODO: 设置法律服务特定流程
    print('⚖️ 设置法律服务');
  }

  Future<void> _setupFinancialService(Order order) async {
    // TODO: 设置财务服务特定流程
    print('💰 设置财务服务');
  }

  Future<void> _setupDesignService(Order order) async {
    // TODO: 设置设计服务特定流程
    print('🎨 设置设计服务');
  }

  Future<void> _setupConsultingService(Order order) async {
    // TODO: 设置咨询服务特定流程
    print('📊 设置商业咨询');
  }

  Future<void> _setupTechnicalService(Order order) async {
    // TODO: 设置技术服务特定流程
    print('💻 设置技术咨询');
  }

  Future<void> _createWorkspace(Order order) async {
    // TODO: 创建专业服务工作区
    print('🏢 创建专业服务工作区');
  }

  Future<void> _assignExpert(Order order) async {
    // TODO: 分配专家
    print('👨‍💼 分配专家');
  }

  Future<void> _setupCommunicationChannel(Order order) async {
    // TODO: 设置沟通渠道
    print('💬 设置沟通渠道');
  }

  Future<void> _sendServiceInitiationNotification(Order order) async {
    // TODO: 发送服务启动通知
    print('📧 发送服务启动通知');
  }

  Future<void> _sendStatusUpdateNotification(Order order, OrderStatus status, String? reason) async {
    // TODO: 发送状态更新通知
    print('📧 发送状态更新通知: ${status.label}');
  }

  Future<({bool canCancel, String? reason})> _checkCancellationPolicy(Order order) async {
    // TODO: 检查取消政策
    return (canCancel: true, reason: null);
  }

  Future<Price> _calculateCancellationFee(Order order, String reason) async {
    // TODO: 计算取消费用
    return Price(amount: 0.0, currency: order.totalAmount.currency);
  }

  Future<void> _releaseExpertTime(Order order) async {
    // TODO: 释放专家时间
    print('🔓 释放专家时间');
  }

  Future<void> _saveWorkProgress(Order order) async {
    // TODO: 保存工作进度
    print('💾 保存工作进度');
  }

  Future<void> _notifyServiceCancellation(Order order, String reason) async {
    // TODO: 通知服务取消
    print('📧 通知服务取消');
  }

  Future<void> _createProjectWorkspace(Order order) async {
    // TODO: 创建项目工作区
    print('📁 创建项目工作区');
  }

  Future<void> _sendProjectKickoffMaterials(Order order) async {
    // TODO: 发送项目启动资料
    print('📧 发送项目启动资料');
  }

  Future<void> _scheduleInitialMeeting(Order order) async {
    // TODO: 安排初始会议
    print('📅 安排初始会议');
  }

  Future<void> _setupProjectMilestones(Order order) async {
    // TODO: 设置项目里程碑
    print('🎯 设置项目里程碑');
  }

  Future<void> _activateWorkspaceAccess(Order order) async {
    // TODO: 激活工作区权限
    print('🔑 激活工作区权限');
  }

  Future<void> _sendServiceStartNotification(Order order) async {
    // TODO: 发送服务开始通知
    print('📧 发送服务开始通知');
  }

  Future<void> _startProgressTracking(Order order) async {
    // TODO: 开始进度跟踪
    print('📈 开始进度跟踪');
  }

  Future<void> _deliverFinalOutput(Order order) async {
    // TODO: 交付最终成果
    print('📦 交付最终成果');
  }

  Future<void> _generateServiceReport(Order order) async {
    // TODO: 生成服务报告
    print('📊 生成服务报告');
  }

  Future<void> _scheduleWrapUpMeeting(Order order) async {
    // TODO: 安排项目总结会议
    print('📅 安排项目总结会议');
  }

  Future<void> _sendServiceCompletionNotification(Order order) async {
    // TODO: 发送服务完成通知
    print('📧 发送服务完成通知');
  }

  Future<void> _inviteServiceReview(Order order) async {
    // TODO: 邀请服务评价
    print('⭐ 邀请服务评价');
  }

  Future<void> _archiveProjectFiles(Order order) async {
    // TODO: 归档项目文件
    print('📚 归档项目文件');
  }

  Future<void> _suspendWorkspaceAccess(Order order) async {
    // TODO: 暂停工作区访问
    print('🔒 暂停工作区访问');
  }
}

/// 专业速帮行业支付处理器
class ProfessionalIndustryPaymentHandler implements IndustryPaymentHandler {
  @override
  Future<void> preprocessPayment(Order order, PaymentMethod paymentMethod) async {
    print('💼💳 专业速帮支付预处理');
    
    // 验证支付金额
    if (order.totalAmount.amount <= 0) {
      throw PaymentException('订单金额无效');
    }

    // 专业服务通常需要预付款
    final serviceType = order.getIndustryData<String>('service_type', 'consultation');
    if (['legal_advice', 'financial_planning', 'business_consulting'].contains(serviceType)) {
      final requiresDeposit = order.getIndustryData<bool>('requires_deposit', true) ?? true;
      if (requiresDeposit && order.depositAmount == null) {
        throw PaymentException('专业服务需要支付预付款');
      }
    }

    // 检查企业支付限制
    final isEnterprise = order.getIndustryData<bool>('is_enterprise_client', false) ?? false;
    if (isEnterprise && paymentMethod.type == PaymentMethodType.cash) {
      throw PaymentException('企业客户不支持现金支付');
    }

    // 验证高价值服务的支付方式
    if (order.totalAmount.amount > 5000.0 && !paymentMethod.type.isCard) {
      throw PaymentException('高价值专业服务需要使用信用卡支付');
    }
  }

  @override
  Future<void> postprocessPayment(Order order, Payment payment, bool success) async {
    if (success) {
      print('✅ 专业速帮支付成功');
      
      // 激活项目工作区
      // TODO: 实现工作区激活逻辑
      
      // 发送服务启动通知
      // TODO: 实现启动通知逻辑
      
      // 安排首次会议
      // TODO: 实现会议安排逻辑
    } else {
      print('❌ 专业速帮支付失败');
      
      // 释放专家时间
      // TODO: 实现时间释放逻辑
    }
  }

  @override
  Future<ValidationResult> validateRefund(Order order, Price amount, String reason) async {
    // 专业速帮退款验证
    final serviceType = order.getIndustryData<String>('service_type', 'consultation');
    
    // 检查服务是否已开始
    final actualStartTime = order.getIndustryData<String>('actual_start_time');
    if (actualStartTime != null) {
      final started = DateTime.parse(actualStartTime);
      final now = DateTime.now();
      final serviceDuration = now.difference(started);
      
      // 专业服务开始后的退款政策
      if (serviceDuration.inDays > 3) {
        return ValidationResult.invalid(['专业服务开始3天后不支持全额退款']);
      }
      
      // 部分退款计算
      final completionRate = order.getIndustryData<double>('completion_rate', 0.0) ?? 0.0;
      if (completionRate > 0.5) {
        return ValidationResult.invalid(['服务已完成超过50%，不支持退款']);
      }
    } else {
      // 服务未开始的退款政策
      final scheduledTime = order.scheduledTime?.start;
      if (scheduledTime != null) {
        final timeToStart = scheduledTime.difference(DateTime.now());
        
        // 24小时内开始的服务收取取消费
        if (timeToStart.inHours < 24) {
          final cancellationFee = order.totalAmount.amount * 0.25; // 25%取消费
          final maxRefund = order.totalAmount.amount - cancellationFee;
          
          if (amount.amount > maxRefund) {
            return ValidationResult.invalid(['24小时内取消需收取25%取消费']);
          }
        }
      }
    }

    return ValidationResult.valid();
  }

  @override
  Future<void> postprocessRefund(Order order, Payment refund, bool success) async {
    if (success) {
      print('✅ 专业速帮退款成功');
      
      // 暂停工作区访问
      // TODO: 实现工作区暂停逻辑
      
      // 保存工作进度
      // TODO: 实现进度保存逻辑
      
      // 发送退款通知
      // TODO: 实现退款通知逻辑
    } else {
      print('❌ 专业速帮退款失败');
      
      // 记录退款失败原因
      // TODO: 实现失败记录逻辑
    }
  }
}
