import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/provider_home_page.dart';

void main() {
  group('ProviderHomePage Simple Test', () {
    testWidgets('ProviderHomePage should display basic content', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderHomePage(
            onNavigateToTab: (index) {},
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - 检查基本元素是否存在
      expect(find.text('Provider Dashboard'), findsOneWidget);
      expect(find.text('今日概览'), findsOneWidget);
      expect(find.text('快速操作'), findsOneWidget);
      expect(find.text('最新动态'), findsOneWidget);
    });

    testWidgets('ProviderHomePage should show online status', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
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

    testWidgets('ProviderHomePage should show today overview data', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
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

    testWidgets('ProviderHomePage should have scrollable content', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderHomePage(
            onNavigateToTab: (index) {},
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - 检查是否有滚动视图
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
} 