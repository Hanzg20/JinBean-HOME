// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '金豆荚 App';

  @override
  String get homePageTitle => '首页';

  @override
  String get homePageWelcome => '欢迎来到金豆荚 App 首页！';

  @override
  String get loginPageTitle => '登录';

  @override
  String get registerPageTitle => '注册';

  @override
  String get usernameHint => '请输入用户名';

  @override
  String get passwordHint => '请输入密码';

  @override
  String get loginButton => '登录';

  @override
  String get registerButton => '注册';

  @override
  String get noAccountPrompt => '还没有账号？';

  @override
  String get alreadyHaveAccountPrompt => '已有账号？';

  @override
  String get home => '首页';

  @override
  String get service => '服务';

  @override
  String get community => '社区';

  @override
  String get profile => '我的';

  @override
  String get serviceBookingPageTitle => '服务预约';

  @override
  String get availableServices => '可用服务';

  @override
  String bookService(Object service) {
    return '预约 $service';
  }

  @override
  String get selectDateAndTime => '选择日期和时间';

  @override
  String get yourBookings => '您的预约';
}
