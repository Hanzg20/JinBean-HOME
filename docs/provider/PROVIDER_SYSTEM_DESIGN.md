# Provider System Design Document

> This document describes the comprehensive system design for the JinBean Provider platform, including architecture, functional modules, UI/UX design, and technical implementation.

## Table of Contents
1. [System Overview](#1-system-overview)
2. [Architecture Design](#2-architecture-design)
3. [Functional Modules](#3-functional-modules)
4. [UI/UX Design](#4-uiux-design)
5. [Technical Implementation](#5-technical-implementation)
6. [Integration & APIs](#6-integration--apis)
7. [Security & Performance](#7-security--performance)
8. [Development Guidelines](#8-development-guidelines)

---

## 1. System Overview

### 1.1 Purpose
The Provider platform is designed to serve service providers with a comprehensive business management tool, enabling them to manage orders, clients, services, and income efficiently.

### 1.2 Core Objectives
- **Order Management**: Complete order lifecycle management
- **Client Relationship Management**: Build and maintain client relationships
- **Service Management**: Create and manage service offerings
- **Income Management**: Track and analyze financial performance
- **Business Intelligence**: Provide insights for business growth

### 1.3 Target Users
- **Service Providers**: Individual professionals and small businesses
- **Service Teams**: Multi-person service organizations
- **Business Owners**: Entrepreneurs managing service operations

---

## 2. Architecture Design

### 2.1 Layered Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Provider Platform                        │
├─────────────────────────────────────────────────────────────┤
│   Presentation Layer (UI/UX)                                │
│  ├── Pages (Dashboard, Orders, Clients, Services, Income)   │
│  ├── Widgets (Common Components)                            │
│  └── Navigation (Bottom Tabs, Routing)                      │
├─────────────────────────────────────────────────────────────┤
│   Business Logic Layer (Controllers)                        │
│  ├── OrderManageController                                  │
│  ├── ClientController                                       │
│  ├── ServiceManageController                                │
│  └── IncomeController                                       │
├─────────────────────────────────────────────────────────────┤
│   Data Access Layer (Services)                              │
│  ├── OrderService                                           │
│  ├── ClientService                                          │
│  ├── ServiceService                                         │
│  └── IncomeService                                          │
├─────────────────────────────────────────────────────────────┤
│   Infrastructure Layer                                      │
│  ├── Database (Supabase PostgreSQL)                         │
│  ├── Authentication (Supabase Auth)                         │
│  ├── Storage (Supabase Storage)                             │
│  └── Real-time (Supabase Realtime)                          │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Plugin Architecture

#### 2.2.1 Plugin System Design
- **IPlugin Interface**: Defines plugin contract
- **BasePlugin Class**: Provides common functionality
- **PluginManager**: Manages plugin lifecycle
- **EventBus**: Enables inter-plugin communication

#### 2.2.2 Plugin Types
```dart
enum PluginType {
  bottomTab,      // Bottom navigation tabs
  standalonePage, // Independent pages
  modal,          // Modal dialogs
  widget          // Reusable widgets
}
```

#### 2.2.3 Plugin Registration
```dart
class OrderManagePlugin extends AppPlugin {
  @override
  PluginMetadata get metadata => PluginMetadata(
    id: 'order_manage',
    nameKey: 'order_management',
    icon: Icons.assignment,
    enabled: true,
    order: 1,
    type: PluginType.bottomTab,
    routeName: '/provider/orders',
    role: 'provider',
  );
}
```

### 2.3 State Management

#### 2.3.1 GetX Architecture
- **Reactive State**: Rx variables for UI updates
- **Dependency Injection**: Automatic controller injection
- **Route Management**: Declarative routing
- **Internationalization**: Multi-language support

#### 2.3.2 State Flow
```
User Action → Controller → Service → Database
     ↑                                        ↓
     └────────── UI Update ← State ← Response
```

---

## 3. Functional Modules

### 3.1 Order Management Module

#### 3.1.1 Core Features
- **Order Dashboard**: Overview of all orders
- **Order List**: Paginated list with filtering
- **Order Details**: Complete order information
- **Order Actions**: Accept, reject, start, complete
- **Order Search**: Multi-criteria search
- **Order Statistics**: Performance metrics

#### 3.1.2 Order States
```dart
enum OrderStatus {
  pendingAcceptance,  // Waiting for provider acceptance
  accepted,           // Provider accepted the order
  inProgress,         // Service in progress
  completed,          // Service completed
  cancelled,          // Order cancelled
  disputed            // Order under dispute
}
```

#### 3.1.3 Order Flow
```
New Order → Pending Acceptance → Accepted → In Progress → Completed
    ↓              ↓                ↓           ↓           ↓
Notification   Review Order    Start Service  Update Status  Request Payment
```

#### 3.1.4 Key Components
- **OrderListPage**: Main order listing
- **OrderDetailPage**: Detailed order view
- **OrderActionButtons**: Accept/Reject/Start/Complete
- **OrderFilterPanel**: Status and date filtering
- **OrderStatisticsCard**: Performance metrics

### 3.2 Client Management Module

#### 3.2.1 Core Features
- **Client Dashboard**: Client overview and metrics
- **Client List**: All clients with relationship status
- **Client Profile**: Detailed client information
- **Communication History**: Message and call logs
- **Client Notes**: Private notes and reminders
- **Client Analytics**: Relationship insights

#### 3.2.2 Client Categories
```dart
enum ClientCategory {
  served,           // Previously served clients
  inNegotiation,    // Clients in discussion phase
  potential,        // Prospective clients
  inactive          // Inactive clients
}
```

#### 3.2.3 Client Relationship Model
```dart
class ClientRelationship {
  final String id;
  final String clientId;
  final String providerId;
  final ClientCategory category;
  final DateTime lastContactDate;
  final int totalOrders;
  final double totalRevenue;
  final String notes;
}
```

#### 3.2.4 Key Components
- **ClientListPage**: Client listing with categories
- **ClientDetailPage**: Client profile and history
- **ClientCommunicationPanel**: Message and call interface
- **ClientNotesWidget**: Notes management
- **ClientAnalyticsCard**: Relationship metrics

### 3.3 Service Management Module

#### 3.3.1 Core Features
- **Service Dashboard**: Service overview and performance
- **Service List**: All offered services
- **Service Creation**: Add new services
- **Service Editing**: Modify existing services
- **Service Pricing**: Dynamic pricing management
- **Service Availability**: Schedule management

#### 3.3.2 Service Model
```dart
class Service {
  final String id;
  final String providerId;
  final String title;
  final String description;
  final String categoryLevel1Id;
  final String categoryLevel2Id;
  final ServiceStatus status;
  final double averageRating;
  final int reviewCount;
  final ServicePricing pricing;
  final ServiceAvailability availability;
}
```

#### 3.3.3 Service States
```dart
enum ServiceStatus {
  active,      // Available for booking
  inactive,    // Temporarily unavailable
  draft,       // Under development
  archived     // No longer offered
}
```

#### 3.3.4 Key Components
- **ServiceListPage**: Service listing and management
- **ServiceCreatePage**: New service creation
- **ServiceEditPage**: Service modification
- **ServicePricingPanel**: Pricing configuration
- **ServiceAvailabilityWidget**: Schedule management

### 3.4 Income Management Module

#### 3.4.1 Core Features
- **Income Dashboard**: Financial overview
- **Income Reports**: Detailed financial reports
- **Payment Tracking**: Payment status monitoring
- **Settlement Management**: Payment processing
- **Tax Records**: Tax documentation
- **Financial Analytics**: Performance insights

#### 3.4.2 Income Model
```dart
class IncomeRecord {
  final String id;
  final String providerId;
  final String orderId;
  final double amount;
  final PaymentStatus status;
  final DateTime earnedDate;
  final DateTime? paidDate;
  final String paymentMethod;
  final double? platformFee;
  final double? taxAmount;
}
```

#### 3.4.3 Payment States
```dart
enum PaymentStatus {
  pending,     // Payment pending
  processing,  // Payment being processed
  completed,   // Payment completed
  failed,      // Payment failed
  refunded     // Payment refunded
}
```

#### 3.4.4 Key Components
- **IncomeDashboardPage**: Financial overview
- **IncomeReportPage**: Detailed reports
- **PaymentTrackingWidget**: Payment status
- **SettlementPanel**: Payment processing
- **FinancialAnalyticsCard**: Performance metrics

---

## 4. UI/UX Design

### 4.1 Design System

#### 4.1.1 Color Palette
```dart
class ProviderColors {
  // Primary Colors
  static const Color primary = Color(0xFFFFC300);      // Golden
  static const Color primaryDark = Color(0xFFE6B800);
  static const Color primaryLight = Color(0xFFFFD54F);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);      // Green
  static const Color warning = Color(0xFFFF9800);      // Orange
  static const Color error = Color(0xFFF44336);        // Red
  static const Color info = Color(0xFF2196F3);         // Blue
  
  // Neutral Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}
```

#### 4.1.2 Typography
```dart
class ProviderTypography {
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: ProviderColors.textPrimary,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: ProviderColors.textPrimary,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: ProviderColors.textPrimary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: ProviderColors.textSecondary,
  );
}
```

### 4.2 Page Layouts

#### 4.2.1 Dashboard Layout
```
┌─────────────────────────────────────┐
│ Header (Title + Date + Status)      │
├─────────────────────────────────────┤
│ Overview Cards (3-column grid)      │
│ ├── Today's Earnings               │
│ ├── Completed Orders               │
│ └── Average Rating                 │
├─────────────────────────────────────┤
│ Progress Indicators                 │
│ ├── Acceptance Rate                │
│ ├── Completion Rate                │
│ └── Satisfaction Rate              │
├─────────────────────────────────────┤
│ Quick Actions                       │
│ ├── Accept New Orders              │
│ ├── View Pending Orders            │
│ └── Contact Clients                │
└─────────────────────────────────────┘
```

#### 4.2.2 List Page Layout
```
┌─────────────────────────────────────┐
│ Header (Title + Search + Filter)    │
├─────────────────────────────────────┤
│ Filter Tabs                         │
│ ├── All                             │
│ ├── Pending                         │
│ ├── Active                          │
│ └── Completed                       │
├─────────────────────────────────────┤
│ List Items (Scrollable)             │
│ ├── Item Card 1                    │
│ ├── Item Card 2                    │
│ ├── Item Card 3                    │
│ └── ...                            │
├─────────────────────────────────────┤
│ Pagination / Load More              │
└─────────────────────────────────────┘
```

### 4.3 Component Library

#### 4.3.1 Common Components
- **ProviderCard**: Standard card component
- **StatusBadge**: Status indicator badges
- **ActionButton**: Primary action buttons
- **FilterChip**: Filter selection chips
- **ProgressIndicator**: Progress visualization
- **EmptyState**: Empty list states

#### 4.3.2 Business Components
- **OrderCard**: Order information display
- **ClientCard**: Client information display
- **ServiceCard**: Service information display
- **IncomeCard**: Income information display
- **StatisticsCard**: Metrics visualization

---

## 5. Technical Implementation

### 5.1 Technology Stack

#### 5.1.1 Frontend
- **Framework**: Flutter 3.x
- **State Management**: GetX
- **UI Components**: Material Design 3
- **Navigation**: GetX Routing
- **Local Storage**: GetStorage
- **HTTP Client**: Supabase Client

#### 5.1.2 Backend
- **Database**: PostgreSQL (Supabase)
- **Authentication**: Supabase Auth
- **Storage**: Supabase Storage
- **Real-time**: Supabase Realtime
- **API**: RESTful APIs

#### 5.1.3 Development Tools
- **IDE**: VS Code / Android Studio
- **Version Control**: Git
- **Package Management**: Flutter Pub
- **Testing**: Flutter Test
- **CI/CD**: GitHub Actions

### 5.2 Project Structure

```
lib/features/provider/
├── provider_home_page.dart           # Main provider app
├── plugins/                          # Plugin modules
│   ├── order_manage/                 # Order management
│   │   ├── order_manage_controller.dart
│   │   ├── order_manage_page.dart
│   │   └── order_manage_plugin.dart
│   ├── client/                       # Client management
│   │   ├── client_controller.dart
│   │   ├── client_page.dart
│   │   └── client_plugin.dart
│   ├── service_manage/               # Service management
│   │   ├── service_manage_controller.dart
│   │   ├── service_manage_page.dart
│   │   └── service_manage_plugin.dart
│   └── income/                       # Income management
│       ├── income_controller.dart
│       ├── income_page.dart
│       └── income_plugin.dart
├── shared/                           # Shared components
│   ├── widgets/                      # Common widgets
│   ├── models/                       # Data models
│   └── services/                     # Shared services
└── settings/                         # Settings module
    ├── settings_page.dart
    └── settings_controller.dart
```

### 5.3 Data Models

#### 5.3.1 Base Models
```dart
abstract class BaseEntity {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  BaseEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });
}

abstract class BaseUser extends BaseEntity {
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String phone;
  
  BaseUser({
    required super.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.phone,
    required super.createdAt,
    required super.updatedAt,
  });
}
```

#### 5.3.2 Provider Models
```dart
class ProviderUser extends BaseUser {
  final String businessName;
  final String businessDescription;
  final CertificationStatus certificationStatus;
  final bool isActive;
  final double rating;
  final int reviewCount;
  final List<String> serviceCategories;
  final List<String> serviceAreas;
  
  ProviderUser({
    required super.id,
    required super.email,
    required super.displayName,
    super.avatarUrl,
    required super.phone,
    required this.businessName,
    required this.businessDescription,
    required this.certificationStatus,
    required this.isActive,
    required this.rating,
    required this.reviewCount,
    required this.serviceCategories,
    required this.serviceAreas,
    required super.createdAt,
    required super.updatedAt,
  });
}
```

### 5.4 Service Layer

#### 5.4.1 Base Service
```dart
abstract class BaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  Future<T?> getById<T>(String id, String table);
  Future<List<T>> getAll<T>(String table, {Map<String, dynamic>? filters});
  Future<T> create<T>(String table, Map<String, dynamic> data);
  Future<T> update<T>(String id, String table, Map<String, dynamic> data);
  Future<void> delete(String id, String table);
}
```

#### 5.4.2 Order Service
```dart
class OrderService extends BaseService {
  Future<List<Order>> getProviderOrders({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    var query = _supabase
        .from('orders')
        .select('*, customer:users(*), service:services(*)')
        .eq('provider_id', _supabase.auth.currentUser?.id);
    
    if (status != null) query = query.eq('status', status);
    if (startDate != null) query = query.gte('created_at', startDate.toIso8601String());
    if (endDate != null) query = query.lte('created_at', endDate.toIso8601String());
    
    final response = await query
        .order('created_at', ascending: false)
        .range((page - 1) * limit, page * limit - 1);
    
    return (response as List).map((json) => Order.fromJson(json)).toList();
  }
  
  Future<Order> updateOrderStatus(String orderId, OrderStatus status) async {
    final response = await _supabase
        .from('orders')
        .update({'status': status.name})
        .eq('id', orderId)
        .select()
        .single();
    
    return Order.fromJson(response);
  }
}
```

---

## 6. Integration & APIs

### 6.1 Supabase Integration

#### 6.1.1 Database Connection
```dart
class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  static SupabaseClient get client => _client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }
}
```

#### 6.1.2 Real-time Subscriptions
```dart
class RealtimeService {
  final SupabaseClient _client = Supabase.instance.client;
  
  Stream<List<Order>> subscribeToOrders(String providerId) {
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('provider_id', providerId)
        .map((event) => event.map((json) => Order.fromJson(json)).toList());
  }
}
```

### 6.2 External APIs

#### 6.2.1 Payment Integration
```dart
class PaymentService {
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    // Integrate with Stripe or other payment providers
    final response = await _stripeClient.charges.create({
      'amount': request.amount,
      'currency': 'usd',
      'source': request.paymentMethodId,
      'description': request.description,
    });
    
    return PaymentResult.fromStripeResponse(response);
  }
}
```

#### 6.2.2 Notification Service
```dart
class NotificationService {
  Future<void> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Integrate with Firebase Cloud Messaging or similar
    await _fcmClient.send({
      'to': userId,
      'notification': {
        'title': title,
        'body': body,
      },
      'data': data,
    });
  }
}
```

---

## 7. Security & Performance

### 7.1 Security Measures

#### 7.1.1 Authentication
- **JWT Tokens**: Secure token-based authentication
- **Role-based Access**: Provider-specific permissions
- **Session Management**: Secure session handling
- **Password Policies**: Strong password requirements

#### 7.1.2 Data Protection
- **Row Level Security**: Database-level access control
- **Data Encryption**: Encrypted data transmission
- **Input Validation**: Comprehensive input sanitization
- **SQL Injection Prevention**: Parameterized queries

#### 7.1.3 Privacy Compliance
- **GDPR Compliance**: Data protection regulations
- **Data Minimization**: Collect only necessary data
- **User Consent**: Explicit consent management
- **Data Portability**: User data export capabilities

### 7.2 Performance Optimization

#### 7.2.1 Database Optimization
- **Indexing Strategy**: Optimized database indexes
- **Query Optimization**: Efficient SQL queries
- **Connection Pooling**: Database connection management
- **Caching**: Redis-based caching layer

#### 7.2.2 Frontend Optimization
- **Lazy Loading**: On-demand component loading
- **Image Optimization**: Compressed and cached images
- **State Management**: Efficient state updates
- **Memory Management**: Proper resource cleanup

#### 7.2.3 Network Optimization
- **API Caching**: Response caching strategies
- **Compression**: Gzip compression for responses
- **CDN Integration**: Content delivery optimization
- **Rate Limiting**: API rate limiting protection

---

## 8. Development Guidelines

### 8.1 Code Standards

#### 8.1.1 Naming Conventions
```dart
// Classes: PascalCase
class OrderManageController extends GetxController {}

// Variables: camelCase
final RxList<Order> orders = <Order>[].obs;

// Constants: SCREAMING_SNAKE_CASE
const String API_BASE_URL = 'https://api.example.com';

// Files: snake_case
order_manage_controller.dart
```

#### 8.1.2 Code Organization
```dart
class ExampleController extends GetxController {
  // 1. Constants
  static const int PAGE_SIZE = 20;
  
  // 2. Dependencies
  final _orderService = Get.find<OrderService>();
  
  // 3. Observable variables
  final RxList<Order> orders = <Order>[].obs;
  final RxBool isLoading = false.obs;
  
  // 4. Lifecycle methods
  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }
  
  // 5. Public methods
  Future<void> loadOrders() async {
    // Implementation
  }
  
  // 6. Private methods
  void _handleError(String message) {
    // Error handling
  }
}
```

### 8.2 Testing Strategy

#### 8.2.1 Unit Testing
```dart
void main() {
  group('OrderManageController', () {
    late OrderManageController controller;
    late MockOrderService mockOrderService;
    
    setUp(() {
      mockOrderService = MockOrderService();
      controller = OrderManageController();
    });
    
    test('should load orders successfully', () async {
      // Arrange
      final orders = [Order(id: '1'), Order(id: '2')];
      when(mockOrderService.getOrders()).thenAnswer((_) async => orders);
      
      // Act
      await controller.loadOrders();
      
      // Assert
      expect(controller.orders.length, equals(2));
      expect(controller.isLoading.value, isFalse);
    });
  });
}
```

#### 8.2.2 Integration Testing
```dart
void main() {
  group('Provider App Integration', () {
    testWidgets('should navigate between tabs', (tester) async {
      await tester.pumpWidget(ProviderShellApp());
      
      // Test navigation to orders tab
      await tester.tap(find.byIcon(Icons.assignment));
      await tester.pumpAndSettle();
      expect(find.text('Order Management'), findsOneWidget);
      
      // Test navigation to clients tab
      await tester.tap(find.byIcon(Icons.people));
      await tester.pumpAndSettle();
      expect(find.text('Client Management'), findsOneWidget);
    });
  });
}
```

### 8.3 Documentation Standards

#### 8.3.1 Code Documentation
```dart
/// Controller for managing provider orders
/// 
/// This controller handles all order-related operations including:
/// - Loading order lists
/// - Updating order status
/// - Filtering and searching orders
/// - Order statistics
class OrderManageController extends GetxController {
  /// Loads orders for the current provider
  /// 
  /// [refresh] - If true, clears existing orders and reloads
  /// [status] - Optional status filter
  /// 
  /// Returns a Future that completes when orders are loaded
  Future<void> loadOrders({bool refresh = false, String? status}) async {
    // Implementation
  }
}
```

#### 8.3.2 API Documentation
```dart
/// Order Management API
/// 
/// Provides endpoints for managing provider orders
class OrderApi {
  /// Get provider orders
  /// 
  /// GET /api/provider/orders
  /// 
  /// Query Parameters:
  /// - status: Order status filter
  /// - page: Page number (default: 1)
  /// - limit: Items per page (default: 20)
  /// 
  /// Returns: List of orders with customer and service details
  Future<List<Order>> getOrders({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    // Implementation
  }
}
```

---

## 9. Deployment & Maintenance

### 9.1 Deployment Strategy

#### 9.1.1 Environment Configuration
```dart
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );
}
```

#### 9.1.2 Build Configuration
```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
  
  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
```

### 9.2 Monitoring & Analytics

#### 9.2.1 Error Tracking
```dart
class ErrorTrackingService {
  static void trackError(dynamic error, StackTrace? stackTrace) {
    // Integrate with Sentry or similar service
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
    );
  }
}
```

#### 9.2.2 Analytics
```dart
class AnalyticsService {
  static void trackEvent(String eventName, Map<String, dynamic>? parameters) {
    // Integrate with Firebase Analytics or similar
    FirebaseAnalytics.instance.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }
}
```

---

## 10. Future Enhancements

### 10.1 Planned Features
- **AI-Powered Insights**: Machine learning for business optimization
- **Advanced Analytics**: Comprehensive business intelligence
- **Multi-language Support**: Internationalization
- **Offline Mode**: Offline functionality
- **Advanced Scheduling**: Intelligent scheduling algorithms

### 10.2 Technical Improvements
- **Microservices Architecture**: Scalable backend services
- **Real-time Collaboration**: Multi-user real-time features
- **Advanced Security**: Biometric authentication
- **Performance Optimization**: Advanced caching strategies

---

**Document Version**: 1.0  
**Last Updated**: December 2024  
**Maintained By**: Provider Development Team 