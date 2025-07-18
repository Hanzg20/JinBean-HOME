import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'JinBean'**
  String get appTitle;

  /// No description provided for @homePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homePageTitle;

  /// No description provided for @homePageWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to JinBean App Home Page!'**
  String get homePageWelcome;

  /// No description provided for @loginPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginPageTitle;

  /// No description provided for @registerPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerPageTitle;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get usernameHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountPrompt;

  /// No description provided for @alreadyHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccountPrompt;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @provider_home.
  ///
  /// In en, this message translates to:
  /// **'Provider Home'**
  String get provider_home;

  /// No description provided for @serviceBookingPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Service Booking'**
  String get serviceBookingPageTitle;

  /// No description provided for @availableServices.
  ///
  /// In en, this message translates to:
  /// **'Available Services'**
  String get availableServices;

  /// No description provided for @bookService.
  ///
  /// In en, this message translates to:
  /// **'Book {service}'**
  String bookService(Object service);

  /// No description provided for @selectDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Select Date and Time'**
  String get selectDateAndTime;

  /// Text for 'Your Bookings'
  ///
  /// In en, this message translates to:
  /// **'Your Bookings'**
  String get yourBookings;

  /// No description provided for @provider_switch_button.
  ///
  /// In en, this message translates to:
  /// **'Switch to Provider'**
  String get provider_switch_button;

  /// No description provided for @provider_register_button.
  ///
  /// In en, this message translates to:
  /// **'Register as Provider'**
  String get provider_register_button;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @searchForServices.
  ///
  /// In en, this message translates to:
  /// **'Search for services...'**
  String get searchForServices;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @job.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get job;

  /// No description provided for @welfare.
  ///
  /// In en, this message translates to:
  /// **'Welfare'**
  String get welfare;

  /// No description provided for @noRecommendations.
  ///
  /// In en, this message translates to:
  /// **'No recommendations available'**
  String get noRecommendations;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @languageSettingsPageContent.
  ///
  /// In en, this message translates to:
  /// **'Language Settings Page Content'**
  String get languageSettingsPageContent;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language Changed'**
  String get languageChanged;

  /// No description provided for @languageChangedTo.
  ///
  /// In en, this message translates to:
  /// **'App language changed to {languageCode}'**
  String languageChangedTo(String languageCode);

  /// No description provided for @messageCenter.
  ///
  /// In en, this message translates to:
  /// **'Message Center'**
  String get messageCenter;

  /// No description provided for @messageCenterDescription.
  ///
  /// In en, this message translates to:
  /// **'Here is the message center where you can view all notifications and chat records.'**
  String get messageCenterDescription;

  /// No description provided for @serviceManagement.
  ///
  /// In en, this message translates to:
  /// **'Service Management'**
  String get serviceManagement;

  /// No description provided for @serviceManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Here is the service management page, more detailed features coming soon.'**
  String get serviceManagementDescription;

  /// No description provided for @confirmInformation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Information'**
  String get confirmInformation;

  /// No description provided for @providerType.
  ///
  /// In en, this message translates to:
  /// **'Provider Type'**
  String get providerType;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @serviceCategories.
  ///
  /// In en, this message translates to:
  /// **'Service Categories'**
  String get serviceCategories;

  /// No description provided for @serviceAreas.
  ///
  /// In en, this message translates to:
  /// **'Service Areas'**
  String get serviceAreas;

  /// No description provided for @basePrice.
  ///
  /// In en, this message translates to:
  /// **'Base Price'**
  String get basePrice;

  /// No description provided for @certificationFilesCount.
  ///
  /// In en, this message translates to:
  /// **'Certification Files Count'**
  String get certificationFilesCount;

  /// No description provided for @complianceInfo.
  ///
  /// In en, this message translates to:
  /// **'Compliance Information'**
  String get complianceInfo;

  /// No description provided for @submitRegistration.
  ///
  /// In en, this message translates to:
  /// **'Submit Registration'**
  String get submitRegistration;

  /// No description provided for @serviceInformation.
  ///
  /// In en, this message translates to:
  /// **'Service Information'**
  String get serviceInformation;

  /// No description provided for @mainServiceCategories.
  ///
  /// In en, this message translates to:
  /// **'Main Service Categories (comma separated)'**
  String get mainServiceCategories;

  /// No description provided for @certificationUpload.
  ///
  /// In en, this message translates to:
  /// **'Certification/License Upload'**
  String get certificationUpload;

  /// No description provided for @uploadCertification.
  ///
  /// In en, this message translates to:
  /// **'Upload Certification/License'**
  String get uploadCertification;

  /// No description provided for @currentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get currentStatus;

  /// No description provided for @complianceInformation.
  ///
  /// In en, this message translates to:
  /// **'Compliance Information'**
  String get complianceInformation;

  /// No description provided for @hasGstHst.
  ///
  /// In en, this message translates to:
  /// **'Has registered GST/HST'**
  String get hasGstHst;

  /// No description provided for @bnNumber.
  ///
  /// In en, this message translates to:
  /// **'BN Number (if any)'**
  String get bnNumber;

  /// No description provided for @annualIncomeEstimate.
  ///
  /// In en, this message translates to:
  /// **'Annual Income Estimate (CAD)'**
  String get annualIncomeEstimate;

  /// No description provided for @licenseNumber.
  ///
  /// In en, this message translates to:
  /// **'License Number (if any)'**
  String get licenseNumber;

  /// No description provided for @taxComplianceNotice.
  ///
  /// In en, this message translates to:
  /// **'I have read and understand the tax compliance notice'**
  String get taxComplianceNotice;

  /// No description provided for @taxReportUploaded.
  ///
  /// In en, this message translates to:
  /// **'I have uploaded tax reports/certificates'**
  String get taxReportUploaded;

  /// No description provided for @selectProviderType.
  ///
  /// In en, this message translates to:
  /// **'Select Provider Type'**
  String get selectProviderType;

  /// No description provided for @individual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individual;

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// No description provided for @enterprise.
  ///
  /// In en, this message translates to:
  /// **'Enterprise'**
  String get enterprise;

  /// No description provided for @providerName.
  ///
  /// In en, this message translates to:
  /// **'Provider Name'**
  String get providerName;

  /// No description provided for @setPassword.
  ///
  /// In en, this message translates to:
  /// **'Set Password'**
  String get setPassword;

  /// No description provided for @robOrderHall.
  ///
  /// In en, this message translates to:
  /// **'Rob Order Hall'**
  String get robOrderHall;

  /// No description provided for @robOrderHallDescription.
  ///
  /// In en, this message translates to:
  /// **'Here is the rob order hall where you can view and grab new orders.'**
  String get robOrderHallDescription;

  /// No description provided for @securityAndCompliance.
  ///
  /// In en, this message translates to:
  /// **'Security and Compliance'**
  String get securityAndCompliance;

  /// No description provided for @securityAndComplianceContent.
  ///
  /// In en, this message translates to:
  /// **'Security and Compliance Content (Placeholder)'**
  String get securityAndComplianceContent;

  /// No description provided for @orderManagement.
  ///
  /// In en, this message translates to:
  /// **'Order Management'**
  String get orderManagement;

  /// No description provided for @orderManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Here is the order management page where you can view and process all orders.'**
  String get orderManagementDescription;

  /// No description provided for @themeSettings.
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get themeSettings;

  /// No description provided for @chooseAppTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose your app theme:'**
  String get chooseAppTheme;

  /// No description provided for @deepTealTheme.
  ///
  /// In en, this message translates to:
  /// **'Deep Teal Theme'**
  String get deepTealTheme;

  /// No description provided for @goldenJinBeanTheme.
  ///
  /// In en, this message translates to:
  /// **'Golden JinBean Theme'**
  String get goldenJinBeanTheme;

  /// No description provided for @createOrder.
  ///
  /// In en, this message translates to:
  /// **'Create Order'**
  String get createOrder;

  /// No description provided for @noServiceSelected.
  ///
  /// In en, this message translates to:
  /// **'No service selected'**
  String get noServiceSelected;

  /// No description provided for @providerInformation.
  ///
  /// In en, this message translates to:
  /// **'Provider Information'**
  String get providerInformation;

  /// No description provided for @noProviderSelected.
  ///
  /// In en, this message translates to:
  /// **'No provider selected'**
  String get noProviderSelected;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @serviceAddress.
  ///
  /// In en, this message translates to:
  /// **'Service Address'**
  String get serviceAddress;

  /// No description provided for @serviceDate.
  ///
  /// In en, this message translates to:
  /// **'Service Date'**
  String get serviceDate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @serviceTime.
  ///
  /// In en, this message translates to:
  /// **'Service Time'**
  String get serviceTime;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// No description provided for @serviceDescription.
  ///
  /// In en, this message translates to:
  /// **'Service Description'**
  String get serviceDescription;

  /// No description provided for @serviceDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your service requirements...'**
  String get serviceDescriptionHint;

  /// No description provided for @pricingType.
  ///
  /// In en, this message translates to:
  /// **'Pricing Type'**
  String get pricingType;

  /// No description provided for @fixedPrice.
  ///
  /// In en, this message translates to:
  /// **'Fixed Price'**
  String get fixedPrice;

  /// No description provided for @negotiablePrice.
  ///
  /// In en, this message translates to:
  /// **'Negotiable Price'**
  String get negotiablePrice;

  /// No description provided for @priceInformation.
  ///
  /// In en, this message translates to:
  /// **'Price Information'**
  String get priceInformation;

  /// No description provided for @serviceFee.
  ///
  /// In en, this message translates to:
  /// **'Service Fee'**
  String get serviceFee;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @tbd.
  ///
  /// In en, this message translates to:
  /// **'TBD'**
  String get tbd;

  /// No description provided for @requestQuote.
  ///
  /// In en, this message translates to:
  /// **'Request Quote'**
  String get requestQuote;

  /// No description provided for @serviceMap.
  ///
  /// In en, this message translates to:
  /// **'Service Map'**
  String get serviceMap;

  /// No description provided for @locationMissing.
  ///
  /// In en, this message translates to:
  /// **'Location information missing, please allow location or select a position first.'**
  String get locationMissing;

  /// No description provided for @addressInputDemo.
  ///
  /// In en, this message translates to:
  /// **'Address Input Demo'**
  String get addressInputDemo;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @noLocationSelected.
  ///
  /// In en, this message translates to:
  /// **'No location selected'**
  String get noLocationSelected;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @province.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get province;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get postalCode;

  /// No description provided for @smartAddressInput.
  ///
  /// In en, this message translates to:
  /// **'Smart Address Input'**
  String get smartAddressInput;

  /// No description provided for @addressInputHint.
  ///
  /// In en, this message translates to:
  /// **'Click the location icon to automatically get the address, or enter manually'**
  String get addressInputHint;

  /// No description provided for @usageInstructions.
  ///
  /// In en, this message translates to:
  /// **'Usage Instructions'**
  String get usageInstructions;

  /// No description provided for @addressInputInstructions.
  ///
  /// In en, this message translates to:
  /// **'1. Click the location icon (📍) to open the location selection dialog\n2. Select \"Use Current Location\" to get GPS location\n3. Select \"Search Address\" to manually enter address search\n4. Select \"Common Cities\" to quickly select major Canadian cities\n5. When manually entering addresses, the system will parse and validate in real-time\n6. Common city suggestions will be displayed when typing\n7. Click the help icon (❓) to view address format instructions\n8. Map point selection feature is under development\n\nSupported address formats:\n• 123 Bank St, Ottawa, ON K2P 1L4\n• 456 Queen St W, Toronto, ON M5V 2A9\n• 789 Robson St, Vancouver, BC V6Z 1C3'**
  String get addressInputInstructions;

  /// No description provided for @removed.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get removed;

  /// No description provided for @serviceRemovedFromSavedList.
  ///
  /// In en, this message translates to:
  /// **'Service removed from saved list.'**
  String get serviceRemovedFromSavedList;

  /// No description provided for @refCodesTest.
  ///
  /// In en, this message translates to:
  /// **'ref_codes Test'**
  String get refCodesTest;

  /// No description provided for @returnCount.
  ///
  /// In en, this message translates to:
  /// **'Return Count'**
  String get returnCount;

  /// No description provided for @example.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get example;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @requestError.
  ///
  /// In en, this message translates to:
  /// **'Request Error'**
  String get requestError;

  /// No description provided for @testRefCodes.
  ///
  /// In en, this message translates to:
  /// **'Test ref_codes'**
  String get testRefCodes;

  /// No description provided for @clients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// No description provided for @servedClients.
  ///
  /// In en, this message translates to:
  /// **'Served Clients'**
  String get servedClients;

  /// No description provided for @potentialClients.
  ///
  /// In en, this message translates to:
  /// **'Potential Clients'**
  String get potentialClients;

  /// No description provided for @clientList.
  ///
  /// In en, this message translates to:
  /// **'Client List'**
  String get clientList;

  /// No description provided for @clientListPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'No client data yet'**
  String get clientListPlaceholder;

  /// No description provided for @clientStatistics.
  ///
  /// In en, this message translates to:
  /// **'Client Statistics'**
  String get clientStatistics;

  /// No description provided for @statisticsToBeAdded.
  ///
  /// In en, this message translates to:
  /// **'Statistics to be added'**
  String get statisticsToBeAdded;

  /// No description provided for @customerReviewsAndReputation.
  ///
  /// In en, this message translates to:
  /// **'Customer Reviews and Reputation'**
  String get customerReviewsAndReputation;

  /// No description provided for @customerReviewsAndReputationContent.
  ///
  /// In en, this message translates to:
  /// **'Customer Reviews and Reputation Content (Placeholder)'**
  String get customerReviewsAndReputationContent;

  /// No description provided for @switchToProvider.
  ///
  /// In en, this message translates to:
  /// **'Switch to Provider'**
  String get switchToProvider;

  /// No description provided for @waitingForApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Approval'**
  String get waitingForApproval;

  /// No description provided for @registerAsProvider.
  ///
  /// In en, this message translates to:
  /// **'Register as Provider'**
  String get registerAsProvider;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
