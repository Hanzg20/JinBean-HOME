import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/order_manage/order_manage_page.dart';
import 'package:jinbeanpod_83904710/features/provider/clients/presentation/client_page.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/service_manage/presentation/service_manage_page.dart';
import 'package:jinbeanpod_83904710/features/provider/income/income_page.dart';
import 'package:jinbeanpod_83904710/features/provider/notifications/notification_page.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/order_manage/order_manage_controller.dart';
import 'package:jinbeanpod_83904710/features/provider/clients/presentation/client_controller.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/service_manage/service_manage_controller.dart';
import 'package:jinbeanpod_83904710/features/provider/income/income_controller.dart';
import 'package:jinbeanpod_83904710/features/provider/notifications/notification_controller.dart';

void main() {
  group('Provider Widget Tests', () {
    setUp(() {
      // Initialize GetX for testing
      Get.testMode = true;
    });

    tearDown(() {
      // Clean up GetX
      Get.reset();
    });

    group('Order Management Page Tests', () {
      testWidgets('should render order management page', (WidgetTester tester) async {
        // Arrange
        Get.put(OrderManageController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const OrderManagePage(),
          ),
        );

        // Assert
        expect(find.text('Order Management'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should show search bar', (WidgetTester tester) async {
        // Arrange
        Get.put(OrderManageController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const OrderManagePage(),
          ),
        );

        // Assert
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Search orders by ID or customer name...'), findsOneWidget);
      });

      testWidgets('should show status filter chips', (WidgetTester tester) async {
        // Arrange
        Get.put(OrderManageController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const OrderManagePage(),
          ),
        );

        // Assert
        expect(find.byType(FilterChip), findsWidgets);
      });

      testWidgets('should show empty state when no orders', (WidgetTester tester) async {
        // Arrange
        Get.put(OrderManageController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const OrderManagePage(),
          ),
        );

        // Assert
        expect(find.text('No orders found'), findsOneWidget);
        expect(find.text('Orders will appear here when customers place them'), findsOneWidget);
      });
    });

    group('Client Management Page Tests', () {
      testWidgets('should render client management page', (WidgetTester tester) async {
        // Arrange
        Get.put(ClientController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const ClientPage(),
          ),
        );

        // Assert
        expect(find.text('Client Management'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should show search bar', (WidgetTester tester) async {
        // Arrange
        Get.put(ClientController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const ClientPage(),
          ),
        );

        // Assert
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Search clients by name or email...'), findsOneWidget);
      });

      testWidgets('should show category filter chips', (WidgetTester tester) async {
        // Arrange
        Get.put(ClientController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const ClientPage(),
          ),
        );

        // Assert
        expect(find.byType(FilterChip), findsWidgets);
      });

      testWidgets('should show empty state when no clients', (WidgetTester tester) async {
        // Arrange
        Get.put(ClientController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const ClientPage(),
          ),
        );

        // Assert
        expect(find.text('No clients found'), findsOneWidget);
        expect(find.text('Add your first client to get started'), findsOneWidget);
      });
    });

    group('Service Management Page Tests', () {
      testWidgets('should render service management page', (WidgetTester tester) async {
        // Arrange
        Get.put(ServiceManageController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const ServiceManagePage(),
          ),
        );

        // Assert
        expect(find.text('Service Management'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should show search bar', (WidgetTester tester) async {
        // Arrange
        Get.put(ServiceManageController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const ServiceManagePage(),
          ),
        );

        // Assert
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Search services by name or description...'), findsOneWidget);
      });

      testWidgets('should show status filter chips', (WidgetTester tester) async {
        // Arrange
        Get.put(ServiceManageController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const ServiceManagePage(),
          ),
        );

        // Assert
        expect(find.byType(FilterChip), findsWidgets);
      });

      testWidgets('should show empty state when no services', (WidgetTester tester) async {
        // Arrange
        Get.put(ServiceManageController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const ServiceManagePage(),
          ),
        );

        // Assert
        expect(find.text('No services found'), findsOneWidget);
        expect(find.text('Create your first service to get started'), findsOneWidget);
      });
    });

    group('Income Management Page Tests', () {
      testWidgets('should render income management page', (WidgetTester tester) async {
        // Arrange
        Get.put(IncomeController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const IncomePage(),
          ),
        );

        // Assert
        expect(find.text('Income Management'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should show period selector', (WidgetTester tester) async {
        // Arrange
        Get.put(IncomeController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const IncomePage(),
          ),
        );

        // Assert
        expect(find.byType(FilterChip), findsWidgets);
      });

      testWidgets('should show statistics cards', (WidgetTester tester) async {
        // Arrange
        Get.put(IncomeController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const IncomePage(),
          ),
        );

        // Assert
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('should show empty state when no income records', (WidgetTester tester) async {
        // Arrange
        Get.put(IncomeController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const IncomePage(),
          ),
        );

        // Assert
        expect(find.text('No income records found'), findsOneWidget);
        expect(find.text('Income will appear here when orders are completed'), findsOneWidget);
      });
    });

    group('Notification Page Tests', () {
      testWidgets('should render notification page', (WidgetTester tester) async {
        // Arrange
        Get.put(NotificationController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const NotificationPage(),
          ),
        );

        // Assert
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should show tab bar', (WidgetTester tester) async {
        // Arrange
        Get.put(NotificationController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const NotificationPage(),
          ),
        );

        // Assert
        expect(find.byType(TabBar), findsOneWidget);
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.text('Messages'), findsOneWidget);
      });

      testWidgets('should show filter chips', (WidgetTester tester) async {
        // Arrange
        Get.put(NotificationController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const NotificationPage(),
          ),
        );

        // Assert
        expect(find.byType(FilterChip), findsWidgets);
      });

      testWidgets('should show empty state when no notifications', (WidgetTester tester) async {
        // Arrange
        Get.put(NotificationController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const NotificationPage(),
          ),
        );

        // Assert
        expect(find.text('No notifications found'), findsOneWidget);
        expect(find.text('Notifications will appear here when you receive them'), findsOneWidget);
      });
    });

    group('Common UI Elements Tests', () {
      testWidgets('should show loading indicators', (WidgetTester tester) async {
        // Arrange
        final orderController = Get.put(OrderManageController());
        orderController.isLoading.value = true;

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const OrderManagePage(),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should show refresh indicators', (WidgetTester tester) async {
        // Arrange
        Get.put(OrderManageController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const OrderManagePage(),
          ),
        );

        // Assert
        expect(find.byType(RefreshIndicator), findsOneWidget);
      });

      testWidgets('should show action buttons in app bar', (WidgetTester tester) async {
        // Arrange
        Get.put(OrderManageController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const OrderManagePage(),
          ),
        );

        // Assert
        expect(find.byType(IconButton), findsWidgets);
      });
    });

    group('Navigation Tests', () {
      testWidgets('should handle navigation between tabs', (WidgetTester tester) async {
        // Arrange
        Get.put(NotificationController());

        // Act
        await tester.pumpWidget(
          GetMaterialApp(
            home: const NotificationPage(),
          ),
        );

        // Tap on Messages tab
        await tester.tap(find.text('Messages'));
        await tester.pump();

        // Assert
        expect(find.text('No messages found'), findsOneWidget);
      });
    });

    group('Responsive Design Tests', () {
      testWidgets('should adapt to different screen sizes', (WidgetTester tester) async {
        // Arrange
        Get.put(OrderManageController());

        // Act - Test with different screen sizes
        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpWidget(
          GetMaterialApp(
            home: const OrderManagePage(),
          ),
        );

        // Assert
        expect(find.byType(Scaffold), findsOneWidget);

        // Test with larger screen
        await tester.binding.setSurfaceSize(const Size(800, 600));
        await tester.pump();

        // Assert
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });
  });
} 