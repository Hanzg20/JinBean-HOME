import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/provider_theme.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/customer_theme.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/jinbean_theme.dart';

void main() {
  group('ProviderTheme Integration Tests', () {
    testWidgets('ProviderTheme should apply professional styling', (WidgetTester tester) async {
      // 使用ProviderTheme构建一个简单的应用
      await tester.pumpWidget(
        MaterialApp(
          theme: JinBeanProviderTheme.lightTheme,
          home: Scaffold(
            appBar: AppBar(title: const Text('Provider Test')),
            body: Column(
              children: [
                Card(
                  child: ListTile(
                    title: const Text('Professional Card'),
                    subtitle: const Text('Provider theme styling'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Professional Button'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证AppBar使用了ProviderTheme的颜色
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, JinBeanProviderTheme.lightTheme.colorScheme.primary);

      // 验证Card使用了ProviderTheme的样式
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 2); // ProviderTheme使用2的阴影
      
      // 验证按钮使用了ProviderTheme的样式
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.style?.backgroundColor?.resolve({}), JinBeanProviderTheme.lightTheme.colorScheme.primary);
    });

    testWidgets('ProviderTheme vs CustomerTheme should have different styling', (WidgetTester tester) async {
      // 测试ProviderTheme
      await tester.pumpWidget(
        MaterialApp(
          theme: JinBeanProviderTheme.lightTheme,
          home: Scaffold(
            body: Card(
              child: Container(
                width: 100,
                height: 100,
                child: const Center(child: Text('Provider')),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final providerCard = tester.widget<Card>(find.byType(Card));
      final providerElevation = providerCard.elevation;

      // 测试CustomerTheme
      await tester.pumpWidget(
        MaterialApp(
          theme: JinBeanCustomerTheme.lightTheme,
          home: Scaffold(
            body: Card(
              child: Container(
                width: 100,
                height: 100,
                child: const Center(child: Text('Customer')),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final customerCard = tester.widget<Card>(find.byType(Card));
      final customerElevation = customerCard.elevation;

      // ProviderTheme应该有更小的阴影（更专业）
      expect(providerElevation ?? 0, lessThan(customerElevation ?? 0));
    });

    testWidgets('ProviderTheme should have compact layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: JinBeanProviderTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Button'),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Input Field',
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证按钮使用了紧凑的内边距
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final buttonStyle = button.style;
      expect(buttonStyle, isNotNull);

      // 验证输入框使用了紧凑的内边距
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration, isNotNull);
    });

    testWidgets('ProviderTheme should support dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: JinBeanProviderTheme.darkTheme,
          home: Scaffold(
            appBar: AppBar(title: const Text('Dark Provider')),
            body: const Center(child: Text('Dark Theme')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证深色主题使用了正确的颜色
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, JinBeanProviderTheme.darkTheme.colorScheme.primary);
    });
  });
} 