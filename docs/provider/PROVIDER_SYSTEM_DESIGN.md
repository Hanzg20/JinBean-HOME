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
The Provider platform is designed to serve service providers with a comprehensive business management tool, enabling them to manage orders, clients, services, income, and schedules efficiently.

### 1.2 Core Objectives
- **Order Management**: Complete order lifecycle management with order management and rob order hall
- **Client Relationship Management**: Build and maintain client relationships with automatic conversion
- **Service Management**: Create and manage service offerings with status management
- **Income Management**: Track and analyze financial performance with detailed reports
- **Schedule Management**: Manage work schedules and availability
- **Notification System**: Real-time notifications and communication
- **Settings Management**: Comprehensive provider settings and preferences

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
│  ├── Pages (Dashboard, Orders, Clients, Settings)          │
│  ├── Widgets (Common Components)                            │
│  └── Navigation (Bottom Tabs, Routing)                      │
├─────────────────────────────────────────────────────────────┤
│   Business Logic Layer (Controllers)                        │
│  ├── OrderManageController                                  │
│  ├── RobOrderHallController                                 │
│  ├── ClientController                                       │
│  ├── ServiceManagementController                            │
│  ├── IncomeController                                       │
│  ├── NotificationController                                 │
│  └── ScheduleManagementController                           │
├─────────────────────────────────────────────────────────────┤
│   Data Access Layer (Services)                              │
│  ├── ProviderSettingsService                                │
│  ├── ClientConversionService                                │
│  ├── IncomeManagementService                                │
│  ├── NotificationService                                    │
│  ├── ServiceManagementService                               │
│  └── ScheduleManagementService                              │
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
- **AppPlugin Interface**: Defines plugin contract
- **PluginManager**: Manages plugin lifecycle and role-based loading
- **PluginMetadata**: Plugin configuration and metadata
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
- **Controllers**: Business logic and state management
- **Services**: Data access and business operations
- **Bindings**: Dependency injection and controller registration
- **Reactive Programming**: Rx variables for reactive UI updates

#### 2.3.2 Controller Structure
```dart
class OrderManageController extends GetxController {
  final RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentStatus = 'all'.obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;
}
```

---

## 3. Functional Modules

### 3.1 Dashboard Module

#### 3.1.1 Core Features
- **Overview Cards**: Today's earnings, completed orders, rating, pending orders
- **Recent Orders**: Latest order activities
- **Top Services**: Most popular services
- **Weekly Statistics**: Performance trends
- **Quick Actions**: Common provider actions

#### 3.1.2 Dashboard Components
```dart
class ProviderHomePage extends StatefulWidget {
  final Function(int) onNavigateToTab;
  
  // Key metrics
  final RxInt todayEarnings = 320.obs;
  final RxInt completedOrders = 8.obs;
  final RxDouble rating = 4.8.obs;
  final RxInt pendingOrders = 3.obs;
  final RxInt totalClients = 45.obs;
  final RxInt thisMonthEarnings = 2840.obs;
}
```

### 3.2 Order Management Module

#### 3.2.1 Core Features
- **Order List**: Complete order listing with filtering and search
- **Order Details**: Detailed order information and actions
- **Status Management**: Order status updates and tracking
- **Client Conversion**: Automatic client conversion on order completion
- **Rob Order Hall**: Available orders for providers to accept

#### 3.2.2 Order Model
```dart
class Order {
  final String id;
  final String orderNumber;
  final String customerId;
  final String providerId;
  final String serviceId;
  final OrderStatus status;
  final double amount;
  final DateTime scheduledTime;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
}
```

#### 3.2.3 Order States
```dart
enum OrderStatus {
  pending,           // Waiting for provider acceptance
  accepted,          // Provider accepted the order
  inProgress,        // Service in progress
  completed,         // Service completed
  cancelled,         // Order cancelled
  disputed           // Order under dispute
}
```

#### 3.2.4 Key Components
- **OrdersShellPage**: Tab-based interface with order management and rob order hall
- **OrderManagePage**: Order listing and management
- **RobOrderHallPage**: Available orders for acceptance
- **OrderDetailPage**: Detailed order view
- **OrderActionButtons**: Accept/Reject/Start/Complete actions
- **OrderFilterPanel**: Status and date filtering
- **OrderStatisticsCard**: Performance metrics

### 3.3 Client Management Module

#### 3.3.1 Core Features
- **Client Dashboard**: Client overview and metrics
- **Client List**: All clients with relationship status
- **Client Profile**: Detailed client information
- **Client Conversion**: Automatic client conversion from orders
- **Client Analytics**: Relationship insights and statistics

#### 3.3.2 Client Categories
```dart
enum ClientCategory {
  served,           // Previously served clients
  inNegotiation,    // Clients in discussion phase
  potential,        // Prospective clients
  inactive          // Inactive clients
}
```

#### 3.3.3 Client Relationship Model
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

#### 3.3.4 Key Components
- **ClientPage**: Client listing with categories and search
- **ClientDetailPage**: Client profile and history
- **ClientCommunicationPanel**: Message and call interface
- **ClientNotesWidget**: Notes management
- **ClientStatisticsCard**: Client metrics and insights

### 3.4 Service Management Module

#### 3.4.1 Core Features
- **Service Dashboard**: Service overview and performance
- **Service List**: All offered services with status management
- **Service Creation**: Add new services with detailed configuration
- **Service Editing**: Modify existing services
- **Service Pricing**: Dynamic pricing management
- **Service Availability**: Schedule management

#### 3.4.2 Service Model
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
  final double price;
  final String? location;
  final List<String> imagesUrl;
  final Map<String, dynamic>? extraData;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

#### 3.4.3 Service States
```dart
enum ServiceStatus {
  active,      // Available for booking
  inactive,    // Temporarily unavailable
  draft,       // Under development
  archived     // No longer offered
}
```

#### 3.4.4 Key Components
- **ServiceManagementPage**: Service listing and management
- **ServiceCreatePage**: New service creation
- **ServiceEditPage**: Service modification
- **ServicePricingPanel**: Pricing configuration
- **ServiceAvailabilityWidget**: Schedule management

### 3.5 Income Management Module

#### 3.5.1 Core Features
- **Income Dashboard**: Financial overview and trends
- **Income Reports**: Detailed financial reports
- **Payment Tracking**: Payment status monitoring
- **Settlement Management**: Payment processing
- **Tax Records**: Tax documentation
- **Financial Analytics**: Performance insights

#### 3.5.2 Income Model
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

#### 3.5.3 Payment States
```dart
enum PaymentStatus {
  pending,     // Payment pending
  processing,  // Payment being processed
  completed,   // Payment completed
  failed,      // Payment failed
  refunded     // Payment refunded
}
```

#### 3.5.4 Key Components
- **IncomePage**: Financial overview and reports
- **IncomeReportPage**: Detailed reports
- **PaymentTrackingWidget**: Payment status
- **SettlementPanel**: Payment processing
- **FinancialAnalyticsCard**: Performance metrics

### 3.6 Notification Management Module

#### 3.6.1 Core Features
- **Notification List**: All notifications with filtering
- **Unread Management**: Unread notification tracking
- **Notification Types**: Different notification categories
- **Real-time Updates**: Live notification updates
- **Action Integration**: Direct actions from notifications

#### 3.6.2 Notification Model
```dart
class Notification {
  final String id;
  final String providerId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
}
```

#### 3.6.3 Notification Types
```dart
enum NotificationType {
  order,           // Order-related notifications
  payment,         // Payment-related notifications
  client,          // Client-related notifications
  system,          // System notifications
  marketing        // Marketing notifications
}
```

### 3.7 Settings Management Module

#### 3.7.1 Core Features
- **Profile Management**: Provider profile and information
- **Business Settings**: Business configuration and preferences
- **App Settings**: Application settings and preferences
- **Security Settings**: Security and privacy settings
- **Notification Settings**: Notification preferences
- **Account Management**: Account and billing management

#### 3.7.2 Settings Structure
```dart
class ProviderSettings {
  final String providerId;
  final Map<String, dynamic> autoConvertToClient;
  final Map<String, dynamic> notificationPreferences;
  final Map<String, dynamic> businessSettings;
  final Map<String, dynamic> appSettings;
}
```

---

## 4. UI/UX Design

### 4.1 Design System

#### 4.1.1 Color Palette
```dart
class JinBeanColors {
  // Primary Colors
  static const Color primary = Color(0xFF1976D2);      // Blue
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  
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
    color: JinBeanColors.textPrimary,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: JinBeanColors.textPrimary,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: JinBeanColors.textPrimary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: JinBeanColors.textSecondary,
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
├── provider_home_page.dart           # Main provider dashboard
├── provider_bindings.dart            # Controller bindings
├── orders/                           # Order management
│   └── presentation/
│       └── orders_shell_page.dart    # Orders shell with tabs
├── clients/                          # Client management
│   └── presentation/
│       ├── client_controller.dart    # Client controller
│       └── client_page.dart          # Client management page
├── settings/                         # Settings management
│   ├── settings_page.dart            # Main settings page
│   └── provider_settings_page.dart   # Provider-specific settings
├── income/                           # Income management
│   ├── income_controller.dart        # Income controller
│   └── income_page.dart              # Income management page
├── notifications/                    # Notification management
│   ├── notification_controller.dart  # Notification controller
│   └── notification_page.dart        # Notification page
├── services/                         # Service management
│   ├── service_management_controller.dart
│   ├── service_management_page.dart
│   └── service_management_service.dart
├── plugins/                          # Plugin modules
│   ├── order_manage/                 # Order management plugin
│   │   ├── order_manage_controller.dart
│   │   └── order_manage_page.dart
│   ├── rob_order_hall/               # Rob order hall plugin
│   │   ├── rob_order_hall_controller.dart
│   │   └── presentation/
│   │       └── rob_order_hall_page.dart
│   ├── service_manage/               # Service management plugin
│   ├── message_center/               # Message center plugin
│   ├── provider_registration/        # Provider registration plugin
│   ├── profile/                      # Provider profile plugin
│   ├── provider_home/                # Provider home plugin
│   └── provider_identity/            # Provider identity plugin
└── services/                         # Business services
    ├── provider_settings_service.dart
    ├── client_conversion_service.dart
    ├── income_management_service.dart
    ├── notification_service.dart
    ├── service_management_service.dart
    └── schedule_management_service.dart
```

### 5.3 Database Design

#### 5.3.1 Core Tables
1. **provider_settings** - Provider个性化设置
2. **client_relationships** - 客户关系管理
3. **income_records** - 收入记录管理
4. **notifications** - 通知系统
5. **orders** - 订单管理（已存在）
6. **services** - 服务管理（已存在）
7. **provider_schedules** - 日程管理

#### 5.3.2 Table Relationships
- Provider ↔ Client Relationships (1:N)
- Provider ↔ Income Records (1:N)
- Provider ↔ Notifications (1:N)
- Provider ↔ Services (1:N)
- Provider ↔ Schedules (1:N)
- Orders ↔ Income Records (1:1)

### 5.4 State Management

#### 5.4.1 GetX Controllers
```dart
// Example: OrderManageController
class OrderManageController extends GetxController {
  final RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentStatus = 'all'.obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }
  
  Future<void> loadOrders({bool refresh = false}) async {
    // Implementation
  }
}
```

#### 5.4.2 Service Layer
```dart
// Example: ProviderSettingsService
class ProviderSettingsService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  Future<Map<String, dynamic>?> getSetting(String settingKey) async {
    // Implementation
  }
  
  Future<bool> setSetting(String settingKey, Map<String, dynamic> settingValue) async {
    // Implementation
  }
}
```

---

## 6. Integration & APIs

### 6.1 Supabase Integration

#### 6.1.1 Database Operations
- **CRUD Operations**: Standard database operations
- **Real-time Subscriptions**: Live data updates
- **Row Level Security**: Data access control
- **Stored Procedures**: Complex business logic

#### 6.1.2 Authentication
- **User Management**: User registration and login
- **Role-based Access**: Provider and customer roles
- **Session Management**: Secure session handling
- **Profile Management**: User profile data

### 6.2 External Integrations

#### 6.2.1 Payment Processing
- **Payment Gateways**: Multiple payment method support
- **Transaction Management**: Payment tracking and reconciliation
- **Refund Processing**: Automated refund handling
- **Tax Calculation**: Automated tax calculations

#### 6.2.2 Communication
- **Push Notifications**: Real-time notifications
- **Email Integration**: Email notifications and marketing
- **SMS Integration**: SMS notifications
- **In-app Messaging**: Internal messaging system

---

## 7. Security & Performance

### 7.1 Security Measures

#### 7.1.1 Data Protection
- **Encryption**: Data encryption at rest and in transit
- **Access Control**: Role-based access control
- **Audit Logging**: Comprehensive audit trails
- **Data Backup**: Regular data backups

#### 7.1.2 Application Security
- **Input Validation**: Comprehensive input validation
- **SQL Injection Prevention**: Parameterized queries
- **XSS Protection**: Cross-site scripting protection
- **CSRF Protection**: Cross-site request forgery protection

### 7.2 Performance Optimization

#### 7.2.1 Database Optimization
- **Indexing**: Strategic database indexing
- **Query Optimization**: Optimized database queries
- **Connection Pooling**: Efficient connection management
- **Caching**: Application-level caching

#### 7.2.2 Application Performance
- **Lazy Loading**: On-demand data loading
- **Pagination**: Efficient data pagination
- **Image Optimization**: Optimized image handling
- **Code Splitting**: Efficient code organization

---

## 8. Development Guidelines

### 8.1 Code Standards

#### 8.1.1 Naming Conventions
- **Files**: snake_case for file names
- **Classes**: PascalCase for class names
- **Variables**: camelCase for variable names
- **Constants**: UPPER_SNAKE_CASE for constants

#### 8.1.2 Code Organization
- **Separation of Concerns**: Clear separation of business logic
- **Dependency Injection**: Use GetX for dependency injection
- **Error Handling**: Comprehensive error handling
- **Documentation**: Clear code documentation

### 8.2 Testing Strategy

#### 8.2.1 Unit Testing
- **Controller Testing**: Test business logic
- **Service Testing**: Test data access layer
- **Widget Testing**: Test UI components
- **Integration Testing**: Test complete workflows

#### 8.2.2 Quality Assurance
- **Code Review**: Peer code review process
- **Automated Testing**: CI/CD pipeline integration
- **Performance Testing**: Load and stress testing
- **Security Testing**: Security vulnerability testing

### 8.3 Deployment

#### 8.3.1 Environment Management
- **Development**: Local development environment
- **Staging**: Pre-production testing environment
- **Production**: Live production environment
- **Monitoring**: Application monitoring and alerting

#### 8.3.2 Release Management
- **Version Control**: Git-based version control
- **Release Process**: Automated release process
- **Rollback Strategy**: Quick rollback capabilities
- **Documentation**: Release documentation

---

## 9. Future Enhancements

### 9.1 Planned Features
- **AI-powered Recommendations**: Intelligent service recommendations
- **Advanced Analytics**: Comprehensive business analytics
- **Mobile App**: Native mobile applications
- **Third-party Integrations**: External service integrations

### 9.2 Scalability Considerations
- **Microservices Architecture**: Scalable service architecture
- **Cloud Infrastructure**: Cloud-based deployment
- **Load Balancing**: Efficient load distribution
- **Auto-scaling**: Automatic resource scaling

---

**Last Updated**: 2025-01-08
**Version**: v1.1.0
**Status**: Core functionality implemented and tested 