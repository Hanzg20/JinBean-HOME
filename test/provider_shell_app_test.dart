import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/provider_home_page.dart';

void main() {
  group('ProviderShellApp Test', () {
    testWidgets('ProviderShellApp should display content', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        GetMaterialApp(
          home: ProviderShellApp(),
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

    testWidgets('ProviderShellApp should show bottom navigation', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        GetMaterialApp(
          home: ProviderShellApp(),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - 检查底部导航栏
      expect(find.text('首页'), findsOneWidget);
      expect(find.text('订单'), findsOneWidget);
      expect(find.text('客户'), findsOneWidget);
      expect(find.text('设置'), findsOneWidget);
    });

    testWidgets('ProviderShellApp should show center button', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        GetMaterialApp(
          home: ProviderShellApp(),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - 检查中央按钮
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
} 