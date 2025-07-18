// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'JinBean';

  @override
  String get homePageTitle => 'Home';

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

  @override
  String get provider_switch_button => 'Switch to Provider';

  @override
  String get provider_register_button => 'Register as Provider';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get continueText => 'Continue';

  @override
  String get searchForServices => 'Search for services...';

  @override
  String get viewAll => 'View All';

  @override
  String get news => 'News';

  @override
  String get job => 'Job';

  @override
  String get welfare => 'Welfare';

  @override
  String get noRecommendations => 'No recommendations available';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get languageSettingsPageContent => 'Language Settings Page Content';

  @override
  String get languageChanged => 'Language Changed';

  @override
  String languageChangedTo(String languageCode) {
    return 'App language changed to $languageCode';
  }

  @override
  String get messageCenter => 'Message Center';

  @override
  String get messageCenterDescription => 'Here is the message center where you can view all notifications and chat records.';

  @override
  String get serviceManagement => 'Service Management';

  @override
  String get serviceManagementDescription => 'Here is the service management page, more detailed features coming soon.';

  @override
  String get confirmInformation => 'Confirm Information';

  @override
  String get providerType => 'Provider Type';

  @override
  String get name => 'Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get address => 'Address';

  @override
  String get serviceCategories => 'Service Categories';

  @override
  String get serviceAreas => 'Service Areas';

  @override
  String get basePrice => 'Base Price';

  @override
  String get certificationFilesCount => 'Certification Files Count';

  @override
  String get complianceInfo => 'Compliance Information';

  @override
  String get submitRegistration => 'Submit Registration';

  @override
  String get serviceInformation => 'Service Information';

  @override
  String get mainServiceCategories => 'Main Service Categories (comma separated)';

  @override
  String get certificationUpload => 'Certification/License Upload';

  @override
  String get uploadCertification => 'Upload Certification/License';

  @override
  String get currentStatus => 'Current Status';

  @override
  String get complianceInformation => 'Compliance Information';

  @override
  String get hasGstHst => 'Has registered GST/HST';

  @override
  String get bnNumber => 'BN Number (if any)';

  @override
  String get annualIncomeEstimate => 'Annual Income Estimate (CAD)';

  @override
  String get licenseNumber => 'License Number (if any)';

  @override
  String get taxComplianceNotice => 'I have read and understand the tax compliance notice';

  @override
  String get taxReportUploaded => 'I have uploaded tax reports/certificates';

  @override
  String get selectProviderType => 'Select Provider Type';

  @override
  String get individual => 'Individual';

  @override
  String get team => 'Team';

  @override
  String get enterprise => 'Enterprise';

  @override
  String get providerName => 'Provider Name';

  @override
  String get setPassword => 'Set Password';

  @override
  String get robOrderHall => 'Rob Order Hall';

  @override
  String get robOrderHallDescription => 'Here is the rob order hall where you can view and grab new orders.';

  @override
  String get securityAndCompliance => 'Security and Compliance';

  @override
  String get securityAndComplianceContent => 'Security and Compliance Content (Placeholder)';

  @override
  String get orderManagement => 'Order Management';

  @override
  String get orderManagementDescription => 'Here is the order management page where you can view and process all orders.';

  @override
  String get themeSettings => 'Theme Settings';

  @override
  String get chooseAppTheme => 'Choose your app theme:';

  @override
  String get deepTealTheme => 'Deep Teal Theme';

  @override
  String get goldenJinBeanTheme => 'Golden JinBean Theme';

  @override
  String get createOrder => 'Create Order';

  @override
  String get noServiceSelected => 'No service selected';

  @override
  String get providerInformation => 'Provider Information';

  @override
  String get noProviderSelected => 'No provider selected';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get serviceAddress => 'Service Address';

  @override
  String get serviceDate => 'Service Date';

  @override
  String get selectDate => 'Select date';

  @override
  String get serviceTime => 'Service Time';

  @override
  String get selectTime => 'Select time';

  @override
  String get serviceDescription => 'Service Description';

  @override
  String get serviceDescriptionHint => 'Describe your service requirements...';

  @override
  String get pricingType => 'Pricing Type';

  @override
  String get fixedPrice => 'Fixed Price';

  @override
  String get negotiablePrice => 'Negotiable Price';

  @override
  String get priceInformation => 'Price Information';

  @override
  String get serviceFee => 'Service Fee';

  @override
  String get total => 'Total';

  @override
  String get tbd => 'TBD';

  @override
  String get requestQuote => 'Request Quote';

  @override
  String get serviceMap => 'Service Map';

  @override
  String get locationMissing => 'Location information missing, please allow location or select a position first.';

  @override
  String get addressInputDemo => 'Address Input Demo';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get noLocationSelected => 'No location selected';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get city => 'City';

  @override
  String get province => 'Province';

  @override
  String get postalCode => 'Postal Code';

  @override
  String get smartAddressInput => 'Smart Address Input';

  @override
  String get addressInputHint => 'Click the location icon to automatically get the address, or enter manually';

  @override
  String get usageInstructions => 'Usage Instructions';

  @override
  String get addressInputInstructions => '1. Click the location icon (📍) to open the location selection dialog\n2. Select \"Use Current Location\" to get GPS location\n3. Select \"Search Address\" to manually enter address search\n4. Select \"Common Cities\" to quickly select major Canadian cities\n5. When manually entering addresses, the system will parse and validate in real-time\n6. Common city suggestions will be displayed when typing\n7. Click the help icon (❓) to view address format instructions\n8. Map point selection feature is under development\n\nSupported address formats:\n• 123 Bank St, Ottawa, ON K2P 1L4\n• 456 Queen St W, Toronto, ON M5V 2A9\n• 789 Robson St, Vancouver, BC V6Z 1C3';

  @override
  String get removed => 'Removed';

  @override
  String get serviceRemovedFromSavedList => 'Service removed from saved list.';

  @override
  String get refCodesTest => 'ref_codes Test';

  @override
  String get returnCount => 'Return Count';

  @override
  String get example => 'Example';

  @override
  String get noData => 'No data';

  @override
  String get ok => 'OK';

  @override
  String get requestError => 'Request Error';

  @override
  String get testRefCodes => 'Test ref_codes';

  @override
  String get clients => 'Clients';

  @override
  String get servedClients => 'Served Clients';

  @override
  String get potentialClients => 'Potential Clients';

  @override
  String get clientList => 'Client List';

  @override
  String get clientListPlaceholder => 'No client data yet';

  @override
  String get clientStatistics => 'Client Statistics';

  @override
  String get statisticsToBeAdded => 'Statistics to be added';

  @override
  String get customerReviewsAndReputation => 'Customer Reviews and Reputation';

  @override
  String get customerReviewsAndReputationContent => 'Customer Reviews and Reputation Content (Placeholder)';

  @override
  String get switchToProvider => 'Switch to Provider';

  @override
  String get waitingForApproval => 'Waiting for Approval';

  @override
  String get registerAsProvider => 'Register as Provider';
}
