// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '金豆';

  @override
  String get homePageTitle => '首页';

  @override
  String get homePageWelcome => '欢迎来到金豆应用首页！';

  @override
  String get loginPageTitle => '登录';

  @override
  String get registerPageTitle => '注册';

  @override
  String get usernameHint => 'Enter your username';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get loginButton => 'Login';

  @override
  String get registerButton => 'Register';

  @override
  String get noAccountPrompt => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccountPrompt => 'Already have an account?';

  @override
  String get home => 'Home';

  @override
  String get service => 'Service';

  @override
  String get community => 'Community';

  @override
  String get profile => 'Profile';

  @override
  String get provider_home => 'Provider Home';

  @override
  String get serviceBookingPageTitle => '服务预约';

  @override
  String get availableServices => 'Available Services';

  @override
  String bookService(Object service) {
    return 'Book $service';
  }

  @override
  String get selectDateAndTime => 'Select Date and Time';

  @override
  String get yourBookings => 'Your Bookings';

  @override
  String get provider_switch_button => 'Switch to Provider';

  @override
  String get provider_register_button => 'Register as Provider';

  @override
  String get welcomeBack => '欢迎回来';

  @override
  String get signInToContinue => '登录以继续';

  @override
  String get continueText => 'Continue';

  @override
  String get searchForServices => '搜索服务...';

  @override
  String get viewAll => '查看全部';

  @override
  String get news => '新闻';

  @override
  String get job => '招聘';

  @override
  String get welfare => '福利';

  @override
  String get noRecommendations => '暂无推荐服务';

  @override
  String get recommendations => '推荐服务';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get login => '登录';

  @override
  String get register => '注册';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get dontHaveAccount => '没有账户？';

  @override
  String get alreadyHaveAccount => '已有账户？';

  @override
  String get languageSettings => '语言设置';

  @override
  String get languageSettingsPageContent => '语言设置页面内容';

  @override
  String get languageChanged => '语言已更改';

  @override
  String languageChangedTo(String languageCode) {
    return '应用语言已更改为 $languageCode';
  }

  @override
  String get messageCenter => '消息中心';

  @override
  String get messageCenterDescription => '这里是消息中心，可以查看所有通知和聊天记录。';

  @override
  String get serviceManagement => '服务管理';

  @override
  String get serviceManagementDescription => '这里是服务管理页面，即将推出更详细功能。';

  @override
  String get confirmInformation => '确认信息';

  @override
  String get providerType => '服务商类型';

  @override
  String get name => '名称';

  @override
  String get phoneNumber => '手机号';

  @override
  String get address => '地址';

  @override
  String get serviceCategories => '服务类别';

  @override
  String get serviceAreas => '服务区域';

  @override
  String get basePrice => '起步价';

  @override
  String get certificationFilesCount => '资质文件数';

  @override
  String get complianceInfo => '合规信息';

  @override
  String get submitRegistration => '提交注册';

  @override
  String get serviceInformation => '服务信息';

  @override
  String get mainServiceCategories => '主营服务类别（逗号分隔）';

  @override
  String get certificationUpload => '资质/证照上传';

  @override
  String get uploadCertification => '上传资质/证照';

  @override
  String get currentStatus => '当前状态';

  @override
  String get complianceInformation => '合规信息';

  @override
  String get hasGstHst => '是否已注册GST/HST';

  @override
  String get bnNumber => 'BN号（如有）';

  @override
  String get annualIncomeEstimate => '年收入预估（加元）';

  @override
  String get licenseNumber => '执照编号（如有）';

  @override
  String get taxComplianceNotice => '我已阅读并知晓税务合规须知';

  @override
  String get taxReportUploaded => '我已上传税务报表/证明';

  @override
  String get selectProviderType => '选择服务商类型';

  @override
  String get individual => '个人';

  @override
  String get team => '团队';

  @override
  String get enterprise => '企业';

  @override
  String get providerName => '提供商名称';

  @override
  String get setPassword => '设置密码';

  @override
  String get robOrderHall => '接单大厅';

  @override
  String get robOrderHallDescription => '这里是接单大厅，可以查看并接取新订单。';

  @override
  String get securityAndCompliance => '安全与合规';

  @override
  String get securityAndComplianceContent => '安全与合规内容（占位符）';

  @override
  String get orderManagement => '订单管理';

  @override
  String get orderManagementDescription => '这里是订单管理页面，可以查看、处理所有订单。';

  @override
  String get serviceDetailPageTitle => '服务详情';

  @override
  String get overview => '概览';

  @override
  String get details => '详情';

  @override
  String get provider => '提供商';

  @override
  String get reviews => '评价';

  @override
  String get forYou => '为您推荐';

  @override
  String get serviceFeatures => '服务特色';

  @override
  String get qualityAssurance => '质量保证';

  @override
  String get professionalQualification => '专业资质';

  @override
  String get serviceExperience => '服务经验';

  @override
  String get bookNow => '立即预订';

  @override
  String get contactProvider => '联系提供商';

  @override
  String get getQuote => '获取报价';

  @override
  String get startChat => '开始聊天';

  @override
  String get callProvider => '拨打电话';

  @override
  String get sendEmail => '发送邮件';

  @override
  String get viewContactInfo => '查看联系信息';

  @override
  String get requestQuote => '请求报价';

  @override
  String get serviceName => '服务名称';

  @override
  String get serviceDescription => '服务描述';

  @override
  String get pricingType => '定价类型';

  @override
  String get price => '价格';

  @override
  String get currency => '货币';

  @override
  String get serviceDuration => '服务时长';

  @override
  String get serviceArea => '服务区域';

  @override
  String get tags => '标签';

  @override
  String get serviceTerms => '服务条款';

  @override
  String get serviceTermsContent =>
      '• 服务提供商承诺在约定时间内完成服务\n• 客户需提供准确的服务地址和联系方式\n• 如需取消服务，请提前24小时通知\n• 服务质量问题将在7天内处理\n• 付款将在服务完成后进行';

  @override
  String get trustAndSecurity => '信任与安全';

  @override
  String get verifiedProvider => '已验证提供商';

  @override
  String get verifiedProviderDescription => '此提供商已通过我们团队的验证，确保可靠性和质量。';

  @override
  String get securePayment => '安全支付';

  @override
  String get securePaymentDescription => '所有交易都受到我们安全支付系统的保护。';

  @override
  String get licensedBusiness => '持照企业';

  @override
  String get insuredAndBonded => '投保担保';

  @override
  String get contactInformation => '联系信息';

  @override
  String get chooseContactMethod => '选择您偏好的联系方式';

  @override
  String get chooseBookingMethod => '选择您偏好的预订方式。您可以立即预订或先与提供商讨论详情。';

  @override
  String get bookingOptions => '预订选项';

  @override
  String get bookNowDescription => '为特定日期和时间安排服务';

  @override
  String get checkAvailability => '查看可用时间';

  @override
  String get checkAvailabilityDescription => '查看提供商的可用时间段';

  @override
  String get discussDetails => '预订前讨论详情';

  @override
  String get quoteOptions => '报价选项';

  @override
  String get quickQuote => '快速报价';

  @override
  String get quickQuoteDescription => '提交基本需求以获得快速估算';

  @override
  String get detailedQuote => '详细报价';

  @override
  String get detailedQuoteDescription => '提供详细需求以获得准确定价';

  @override
  String get chatFirst => '先聊天';

  @override
  String get chatFirstDescription => '与提供商讨论您的需求';

  @override
  String get quoteResponseTime => '提供商将在24小时内回复详细报价';

  @override
  String get loadingServiceDetails => '正在加载服务详情...';

  @override
  String get serviceDetailsLoadFailed => '服务详情加载失败';

  @override
  String get retry => '重试';

  @override
  String get back => '返回';

  @override
  String get error => '错误';

  @override
  String get success => '成功';

  @override
  String get warning => '警告';

  @override
  String get info => '信息';

  @override
  String get networkStatus => '网络状态';

  @override
  String get networkOnline => '在线';

  @override
  String get networkOffline => '离线';

  @override
  String get networkOfflineMessage => '当前离线，部分功能可能受限';

  @override
  String get professionalRemarksTest => '专业说明文字测试';

  @override
  String get selectServiceType => '选择服务类型';

  @override
  String get cleaningService => '清洁服务';

  @override
  String get maintenanceService => '维修服务';

  @override
  String get beautyService => '美容服务';

  @override
  String get educationService => '教育服务';

  @override
  String get transportationService => '运输服务';

  @override
  String get foodService => '餐饮服务';

  @override
  String get healthService => '健康服务';

  @override
  String get technologyService => '技术服务';

  @override
  String get generalService => '通用服务';

  @override
  String get adjustProviderData => '调整提供商数据';

  @override
  String get completedOrders => '完成订单数';

  @override
  String get rating => '评分';

  @override
  String get reviewCount => '评价数量';

  @override
  String get verified => '已验证';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get testServiceData => '测试服务数据';

  @override
  String get testServiceDataLoaded => '测试服务数据加载成功';

  @override
  String get simulatedNetworkError => '模拟网络超时错误';

  @override
  String get networkTimeout => '网络连接超时';

  @override
  String manuallySwitchState(String state) {
    return '手动切换加载状态到: $state';
  }

  @override
  String get themeSettings => '主题设置';

  @override
  String get chooseAppTheme => '选择您的应用主题：';

  @override
  String get deepTealTheme => '深青色主题';

  @override
  String get goldenJinBeanTheme => '金色金豆主题';

  @override
  String get createOrder => '创建订单';

  @override
  String get noServiceSelected => '未选择服务';

  @override
  String get providerInformation => '服务商信息';

  @override
  String get noProviderSelected => '未选择服务商';

  @override
  String get orderDetails => '订单详情';

  @override
  String get serviceAddress => '服务地址';

  @override
  String get serviceDate => '服务日期';

  @override
  String get selectDate => '选择日期';

  @override
  String get serviceTime => '服务时间';

  @override
  String get selectTime => '选择时间';

  @override
  String get serviceDescriptionHint => '描述您的服务需求...';

  @override
  String get fixedPrice => '固定价格';

  @override
  String get negotiablePrice => '可协商价格';

  @override
  String get priceInformation => '价格信息';

  @override
  String get serviceFee => '服务费';

  @override
  String get total => '总计';

  @override
  String get tbd => '待定';

  @override
  String get serviceMap => '服务地图';

  @override
  String get locationMissing => '定位信息缺失，请先允许定位或选择位置。';

  @override
  String get addressInputDemo => '地址输入演示';

  @override
  String get currentLocation => '当前位置';

  @override
  String get noLocationSelected => '未选择位置';

  @override
  String get latitude => '纬度';

  @override
  String get longitude => '经度';

  @override
  String get city => '城市';

  @override
  String get province => '省份';

  @override
  String get postalCode => '邮政编码';

  @override
  String get smartAddressInput => '智能地址输入';

  @override
  String get addressInputHint => '点击定位图标自动获取地址，或手动输入';

  @override
  String get usageInstructions => '使用说明';

  @override
  String get addressInputInstructions =>
      '1. 点击定位图标（📍）打开位置选择对话框\n2. 选择\"使用当前位置\"获取GPS定位\n3. 选择\"搜索地址\"手动输入地址搜索\n4. 选择\"常用城市\"快速选择加拿大主要城市\n5. 手动输入地址时，系统会实时解析和验证\n6. 输入时会显示常用城市建议\n7. 点击帮助图标（❓）查看地址格式说明\n8. 地图选点功能正在开发中\n\n支持的地址格式：\n• 123 Bank St, Ottawa, ON K2P 1L4\n• 456 Queen St W, Toronto, ON M5V 2A9\n• 789 Robson St, Vancouver, BC V6Z 1C3';

  @override
  String get removed => '已移除';

  @override
  String get serviceRemovedFromSavedList => '服务已从收藏列表中移除。';

  @override
  String get refCodesTest => 'ref_codes 测试';

  @override
  String get returnCount => '返回数量';

  @override
  String get example => '示例';

  @override
  String get noData => '无数据';

  @override
  String get ok => '确定';

  @override
  String get requestError => '请求出错';

  @override
  String get testRefCodes => '测试ref_codes';

  @override
  String get clients => '客户管理';

  @override
  String get servedClients => '已服务客户';

  @override
  String get potentialClients => '潜在客户';

  @override
  String get clientList => '客户列表';

  @override
  String get clientListPlaceholder => '暂无客户数据';

  @override
  String get clientStatistics => '客户统计';

  @override
  String get statisticsToBeAdded => '统计数据待补充';

  @override
  String get customerReviewsAndReputation => '客户评价与信誉';

  @override
  String get customerReviewsAndReputationContent => '客户评价与信誉内容（占位符）';

  @override
  String get switchToProvider => '切换到服务商';

  @override
  String get waitingForApproval => '等待审核中';

  @override
  String get registerAsProvider => '注册服务商';
}
