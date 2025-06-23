// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'JinBean App';

  @override
  String get homePageTitle => 'Home Page';

  @override
  String get homePageWelcome => 'Welcome to JinBean App Home Page!';

  @override
  String get loginPageTitle => 'Login';

  @override
  String get registerPageTitle => 'Register';

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
  String get serviceBookingPageTitle => 'Service Booking';

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
}
