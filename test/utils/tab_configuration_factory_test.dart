import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jinbeanpod_83904710/features/customer/services/presentation/utils/tab_configuration_factory.dart';

void main() {
  group('TabConfigurationFactory Tests', () {
    test('should generate correct tabs for cleaning service', () {
      final tabs = TabConfigurationFactory.generateTabsForService('1020000');

      expect(tabs.length, 7); // 5 common + 2 specific

      // 检查通用Tab
      expect(tabs.any((tab) => tab.label == 'Overview'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Details'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Provider'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Reviews'), isTrue);
      expect(tabs.any((tab) => tab.label == 'For You'), isTrue);

      // 检查家政服务特定Tab
      expect(tabs.any((tab) => tab.label == 'Schedule'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Equipment'), isTrue);
    });

    test('should generate correct tabs for food service', () {
      final tabs = TabConfigurationFactory.generateTabsForService('1010000');

      expect(tabs.length, 8); // 5 common + 3 specific

      // 检查通用Tab
      expect(tabs.any((tab) => tab.label == 'Overview'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Details'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Provider'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Reviews'), isTrue);
      expect(tabs.any((tab) => tab.label == 'For You'), isTrue);

      // 检查餐饮服务特定Tab
      expect(tabs.any((tab) => tab.label == 'Menu'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Ingredients'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Nutrition'), isTrue);
    });

    test('should generate correct tabs for transportation service', () {
      final tabs = TabConfigurationFactory.generateTabsForService('1030000');

      expect(tabs.length, 7); // 5 common + 2 specific

      // 检查通用Tab
      expect(tabs.any((tab) => tab.label == 'Overview'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Details'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Provider'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Reviews'), isTrue);
      expect(tabs.any((tab) => tab.label == 'For You'), isTrue);

      // 检查运输服务特定Tab
      expect(tabs.any((tab) => tab.label == 'Routes'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Vehicles'), isTrue);
    });

    test('should generate correct tabs for education service', () {
      final tabs = TabConfigurationFactory.generateTabsForService('1040000');

      expect(tabs.length, 8); // 5 common + 3 specific

      // 检查通用Tab
      expect(tabs.any((tab) => tab.label == 'Overview'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Details'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Provider'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Reviews'), isTrue);
      expect(tabs.any((tab) => tab.label == 'For You'), isTrue);

      // 检查教育服务特定Tab
      expect(tabs.any((tab) => tab.label == 'Courses'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Curriculum'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Schedule'), isTrue);
    });

    test('should generate correct tabs for technology service', () {
      final tabs = TabConfigurationFactory.generateTabsForService('1050000');

      expect(tabs.length, 8); // 5 common + 3 specific

      // 检查通用Tab
      expect(tabs.any((tab) => tab.label == 'Overview'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Details'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Provider'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Reviews'), isTrue);
      expect(tabs.any((tab) => tab.label == 'For You'), isTrue);

      // 检查技术服务特定Tab
      expect(tabs.any((tab) => tab.label == 'Features'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Specifications'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Support'), isTrue);
    });

    test('should generate default tabs for unknown service type', () {
      final tabs = TabConfigurationFactory.generateTabsForService('9999999');

      expect(tabs.length, 5); // 只有通用Tab

      // 检查通用Tab
      expect(tabs.any((tab) => tab.label == 'Overview'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Details'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Provider'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Reviews'), isTrue);
      expect(tabs.any((tab) => tab.label == 'For You'), isTrue);
    });

    test('should generate tabs for empty category ID', () {
      final tabs = TabConfigurationFactory.generateTabsForService('');

      expect(tabs.length, 5); // 只有通用Tab

      // 检查通用Tab
      expect(tabs.any((tab) => tab.label == 'Overview'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Details'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Provider'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Reviews'), isTrue);
      expect(tabs.any((tab) => tab.label == 'For You'), isTrue);
    });

    test('should have correct icons for all tabs', () {
      final tabs = TabConfigurationFactory.generateTabsForService('1020000');

      for (final tab in tabs) {
        expect(tab.icon, isNotNull);
        expect(tab.builder, isNotNull);
      }
    });

    test('should have unique labels for all tabs', () {
      final tabs = TabConfigurationFactory.generateTabsForService('1020000');
      final labels = tabs.map((tab) => tab.label).toSet();

      expect(labels.length, tabs.length); // 所有标签都应该是唯一的
    });

    test('should handle empty category ID', () {
      final tabs = TabConfigurationFactory.generateTabsForService('');

      expect(tabs.length, 5); // 只有通用Tab

      // 检查通用Tab
      expect(tabs.any((tab) => tab.label == 'Overview'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Details'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Provider'), isTrue);
      expect(tabs.any((tab) => tab.label == 'Reviews'), isTrue);
      expect(tabs.any((tab) => tab.label == 'For You'), isTrue);
    });
  });

  group('Tab Content Builder Tests', () {
    testWidgets('should build overview tab content',
        (WidgetTester tester) async {
      final mockService = MockService(
        title: 'Test Service',
        description: 'Test Description',
        price: 99.99,
        rating: 4.5,
        reviewCount: 10,
        categoryId: '1020000',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) =>
                  TabConfigurationFactory.generateTabsForService('1020000')
                      .firstWhere((tab) => tab.label == 'Overview')
                      .builder(context, mockService),
            ),
          ),
        ),
      );

      expect(find.text('Test Service'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('\$99.99'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('(10 reviews)'), findsOneWidget);
    });

    testWidgets('should build details tab content',
        (WidgetTester tester) async {
      final mockService = MockService(
        title: 'Test Service',
        description: 'Test Description',
        categoryId: '1020000',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) =>
                  TabConfigurationFactory.generateTabsForService('1020000')
                      .firstWhere((tab) => tab.label == 'Details')
                      .builder(context, mockService),
            ),
          ),
        ),
      );

      expect(find.text('Service Details'), findsOneWidget);
      expect(
          find.text('Detailed information about the service'), findsOneWidget);
    });

    testWidgets('should build provider tab content',
        (WidgetTester tester) async {
      final mockService = MockService(
        title: 'Test Service',
        description: 'Test Description',
        categoryId: '1020000',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) =>
                  TabConfigurationFactory.generateTabsForService('1020000')
                      .firstWhere((tab) => tab.label == 'Provider')
                      .builder(context, mockService),
            ),
          ),
        ),
      );

      expect(find.text('Provider Information'), findsOneWidget);
      expect(
          find.text('Information about the service provider'), findsOneWidget);
    });

    testWidgets('should build reviews tab content',
        (WidgetTester tester) async {
      final mockService = MockService(
        title: 'Test Service',
        description: 'Test Description',
        categoryId: '1020000',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) =>
                  TabConfigurationFactory.generateTabsForService('1020000')
                      .firstWhere((tab) => tab.label == 'Reviews')
                      .builder(context, mockService),
            ),
          ),
        ),
      );

      expect(find.text('Customer Reviews'), findsOneWidget);
      expect(find.text('Reviews and ratings from customers'), findsOneWidget);
    });

    testWidgets('should build personalized tab content',
        (WidgetTester tester) async {
      final mockService = MockService(
        title: 'Test Service',
        description: 'Test Description',
        categoryId: '1020000',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) =>
                  TabConfigurationFactory.generateTabsForService('1020000')
                      .firstWhere((tab) => tab.label == 'For You')
                      .builder(context, mockService),
            ),
          ),
        ),
      );

      expect(find.text('Personalized Recommendations'), findsOneWidget);
      expect(find.text('Customized suggestions based on your preferences'),
          findsOneWidget);
    });
  });
}

/// Mock Service class for testing
class MockService {
  final String title;
  final String description;
  final double? price;
  final double? rating;
  final int? reviewCount;
  final String? categoryId;

  MockService({
    required this.title,
    required this.description,
    this.price,
    this.rating,
    this.reviewCount,
    this.categoryId,
  });
}
