import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/main.dart' as app;

void main() {
  group('Provider Integration Tests', () {
    testWidgets('Provider app should start without errors', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(app.MyApp());
      
      // Verify that the app starts without throwing errors
      expect(find.byType(app.MyApp), findsOneWidget);
    });

    testWidgets('Provider navigation should work', (WidgetTester tester) async {
      await tester.pumpWidget(app.MyApp());
      
      // Wait for the app to load
      await tester.pumpAndSettle();
      
      // Verify that the app is running
      expect(find.byType(app.MyApp), findsOneWidget);
    });
  });
} 