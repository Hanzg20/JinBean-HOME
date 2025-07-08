import 'provider_registration_controller.dart';

ProviderRegistrationController mockProviderRegistrationController() {
  final c = ProviderRegistrationController();
  c.providerType = ProviderType.team;
  c.displayName = 'Ottawa Home Services';
  c.phone = '613-555-0000';
  c.email = 'contact@ottawahomeservices.ca';
  c.addressInput = '123 Bank St, Ottawa, ON K2P 1L4, Canada';
  c.serviceCategories = ['Cleaning', 'Handyman'];
  c.serviceAreas = ['Ottawa', 'Nepean'];
  c.basePrice = 80;
  c.certificationFiles = ['https://example.com/license.pdf'];
  c.hasGstHst = true;
  c.bnNumber = 'ON-987654';
  c.annualIncomeEstimate = 50000;
  c.licenseNumber = 'ON-987654';
  c.taxStatusNoticeShown = true;
  c.taxReportAvailable = true;
  return c;
} 