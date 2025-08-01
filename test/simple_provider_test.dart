import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/provider_home_page.dart';

void main() {
  group('Simple Provider Test', () {
    testWidgets('ProviderShellApp should not crash', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        GetMaterialApp(
          home: ProviderShellApp(),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - 只要不崩溃就是成功
      expect(find.byType(ProviderShellApp), findsOneWidget);
    });

    testWidgets('ProviderHomePage should display content', (WidgetTester tester) async {
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
      expect(find.text('Provider Dashboard'), findsOneWidget);
      expect(find.text('今日概览'), findsOneWidget);
    });
  });
} 