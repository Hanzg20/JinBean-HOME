import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/services/presentation/widgets/service_interaction_buttons.dart';

void main() {
  group('ServiceInteractionButtons Tests', () {
    const testServiceId = 'test-service-123';
    const testServiceTitle = 'Test Service';
    const testServiceDescription = 'This is a test service description';

    setUp(() {
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('should display all interaction buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceInteractionButtons(
              serviceId: testServiceId,
              serviceTitle: testServiceTitle,
              serviceDescription: testServiceDescription,
            ),
          ),
        ),
      );

      expect(find.text('Add to Favorites'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Book Now'), findsOneWidget);
      expect(find.text('Contact'), findsOneWidget);
    });

    testWidgets('should handle favorite toggle correctly',
        (WidgetTester tester) async {
      bool favoriteChanged = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceInteractionButtons(
              serviceId: testServiceId,
              serviceTitle: testServiceTitle,
              serviceDescription: testServiceDescription,
              onFavoriteChanged: () => favoriteChanged = true,
            ),
          ),
        ),
      );

      // 初始状态应该是未收藏
      expect(find.text('Add to Favorites'), findsOneWidget);

      // 点击收藏按钮
      await tester.tap(find.text('Add to Favorites'));
      await tester.pumpAndSettle();

      // 应该调用回调
      expect(favoriteChanged, isTrue);

      // 状态应该变为已收藏
      expect(find.text('Favorited'), findsOneWidget);
    });

    testWidgets('should show snackbar when favorite is toggled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceInteractionButtons(
              serviceId: testServiceId,
              serviceTitle: testServiceTitle,
              serviceDescription: testServiceDescription,
            ),
          ),
        ),
      );

      // 点击收藏按钮
      await tester.tap(find.text('Add to Favorites'));
      await tester.pumpAndSettle();

      // 应该显示snackbar
      expect(find.text('Added to Favorites'), findsOneWidget);
      expect(find.text('$testServiceTitle has been added to your favorites'),
          findsOneWidget);
    });

    testWidgets('should handle share functionality',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceInteractionButtons(
              serviceId: testServiceId,
              serviceTitle: testServiceTitle,
              serviceDescription: testServiceDescription,
            ),
          ),
        ),
      );

      // 点击分享按钮
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();

      // 应该显示分享内容
      expect(find.text('Check out this amazing service!'), findsOneWidget);
      expect(find.text(testServiceTitle), findsOneWidget);
      expect(find.text(testServiceDescription), findsOneWidget);
    });

    testWidgets('should handle book service with custom callback',
        (WidgetTester tester) async {
      bool bookServiceCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceInteractionButtons(
              serviceId: testServiceId,
              serviceTitle: testServiceTitle,
              serviceDescription: testServiceDescription,
              onBookService: () => bookServiceCalled = true,
            ),
          ),
        ),
      );

      // 点击预约按钮
      await tester.tap(find.text('Book Now'));
      await tester.pumpAndSettle();

      // 应该调用自定义回调
      expect(bookServiceCalled, isTrue);
    });

    testWidgets('should show booking dialog when no custom callback',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceInteractionButtons(
              serviceId: testServiceId,
              serviceTitle: testServiceTitle,
              serviceDescription: testServiceDescription,
            ),
          ),
        ),
      );

      // 点击预约按钮
      await tester.tap(find.text('Book Now'));
      await tester.pumpAndSettle();

      // 应该显示预约对话框
      expect(find.text('Book Service'), findsOneWidget);
      expect(find.text('Would you like to book "$testServiceTitle"?'),
          findsOneWidget);
    });

    testWidgets('should handle contact provider with custom callback',
        (WidgetTester tester) async {
      bool contactProviderCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceInteractionButtons(
              serviceId: testServiceId,
              serviceTitle: testServiceTitle,
              serviceDescription: testServiceDescription,
              onContactProvider: () => contactProviderCalled = true,
            ),
          ),
        ),
      );

      // 点击联系按钮
      await tester.tap(find.text('Contact'));
      await tester.pumpAndSettle();

      // 应该调用自定义回调
      expect(contactProviderCalled, isTrue);
    });

    testWidgets('should show contact dialog when no custom callback',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceInteractionButtons(
              serviceId: testServiceId,
              serviceTitle: testServiceTitle,
              serviceDescription: testServiceDescription,
            ),
          ),
        ),
      );

      // 点击联系按钮
      await tester.tap(find.text('Contact'));
      await tester.pumpAndSettle();

      // 应该显示联系对话框
      expect(find.text('Contact Provider'), findsOneWidget);
      expect(
          find.text(
              'How would you like to contact the provider for "$testServiceTitle"?'),
          findsOneWidget);
    });

    testWidgets('should handle initial favorite state correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceInteractionButtons(
              serviceId: testServiceId,
              serviceTitle: testServiceTitle,
              serviceDescription: testServiceDescription,
              isFavorite: true,
            ),
          ),
        ),
      );

      // 初始状态应该是已收藏
      expect(find.text('Favorited'), findsOneWidget);
    });

    testWidgets('should animate favorite button when toggled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceInteractionButtons(
              serviceId: testServiceId,
              serviceTitle: testServiceTitle,
              serviceDescription: testServiceDescription,
            ),
          ),
        ),
      );

      // 点击收藏按钮
      await tester.tap(find.text('Add to Favorites'));
      await tester.pump();

      // 应该播放动画
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
    });
  });

  group('QuickActionButton Tests', () {
    testWidgets('should display button with icon and label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionButton(
              icon: Icons.star,
              label: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('should handle active state correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionButton(
              icon: Icons.star,
              label: 'Test Button',
              onPressed: () {},
              isActive: true,
              color: Colors.blue,
            ),
          ),
        ),
      );

      // 活跃状态应该有不同的样式
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped',
        (WidgetTester tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionButton(
              icon: Icons.star,
              label: 'Test Button',
              onPressed: () => buttonPressed = true,
            ),
          ),
        ),
      );

      // 点击按钮
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // 应该调用回调
      expect(buttonPressed, isTrue);
    });
  });

  group('CustomFloatingActionButton Tests', () {
    testWidgets('should display extended floating action button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomFloatingActionButton(
              icon: Icons.add,
              label: 'Add Item',
              onPressed: () {},
              isExtended: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Add Item'), findsOneWidget);
    });

    testWidgets('should display compact floating action button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomFloatingActionButton(
              icon: Icons.add,
              label: 'Add Item',
              onPressed: () {},
              isExtended: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Add Item'), findsNothing); // 紧凑模式不显示标签
    });

    testWidgets('should call onPressed when tapped',
        (WidgetTester tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomFloatingActionButton(
              icon: Icons.add,
              label: 'Add Item',
              onPressed: () => buttonPressed = true,
            ),
          ),
        ),
      );

      // 点击按钮
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // 应该调用回调
      expect(buttonPressed, isTrue);
    });
  });
}
