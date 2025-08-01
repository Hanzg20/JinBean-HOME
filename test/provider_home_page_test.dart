import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/provider_home_page.dart';

void main() {
  group('ProviderHomePage Tests', () {
    testWidgets('ProviderHomePage should display content', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        GetMaterialApp(
          home: ProviderHomePage(
            onNavigateToTab: (index) {},
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Provider Dashboard'), findsOneWidget);
      expect(find.text('今日概览'), findsOneWidget);
      expect(find.text('快速操作'), findsOneWidget);
      expect(find.text('最新动态'), findsOneWidget);
    });

    testWidgets('ProviderHomePage should show online status', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        GetMaterialApp(
          home: ProviderHomePage(
            onNavigateToTab: (index) {},
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Online'), findsOneWidget);
    });

    testWidgets('ProviderHomePage should show today overview', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        GetMaterialApp(
          home: ProviderHomePage(
            onNavigateToTab: (index) {},
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('\$320'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
    });
  });
} 