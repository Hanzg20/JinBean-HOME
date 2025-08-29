# 订单生成流程实施指南

## 📋 **文档概述**

### **目标**
提供详细的技术实施指南，帮助开发团队实现Service Details页面中的差异化订单生成流程，包括购物车模式和直接下单模式。

### **适用范围**
- Flutter移动端开发
- Supabase后端集成
- GetX状态管理
- 多行业服务适配

---

## 🚀 **实施阶段规划**

### **Phase 1: 数据库架构 (第1-2周)**

#### **Step 1.1: 创建购物车相关表**

```sql
-- 执行文件：docs/ServiceDetail/cart_tables_creation.sql
-- =====================================================
-- 统一购物车表结构创建
-- =====================================================

-- 1. 统一购物车表
CREATE TABLE public.unified_carts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    cart_type text NOT NULL CHECK (cart_type IN ('restaurant', 'appointment', 'mixed')),
    status text DEFAULT 'active' CHECK (status IN ('active', 'converting', 'converted', 'expired')),
    
    -- 餐饮服务专用字段
    delivery_method text, -- 'delivery', 'pickup', 'dine_in'
    delivery_address_id uuid REFERENCES public.user_addresses(id),
    estimated_delivery_time timestamptz,
    special_instructions text,
    
    -- 通用字段
    expires_at timestamptz DEFAULT (now() + interval '24 hours'),
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    
    -- 约束条件
    UNIQUE(user_id, cart_type, status)
);

-- 2. 购物车项目表
CREATE TABLE public.cart_items (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id uuid NOT NULL REFERENCES public.unified_carts(id) ON DELETE CASCADE,
    
    -- 服务关联
    service_id uuid NOT NULL REFERENCES public.services(id),
    service_detail_id uuid REFERENCES public.service_details(id),
    
    -- 基础信息
    item_type text NOT NULL CHECK (item_type IN ('menu_item', 'appointment', 'package')),
    quantity integer NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price numeric NOT NULL CHECK (unit_price >= 0),
    
    -- 预约服务专用字段
    scheduled_start_time timestamptz,
    scheduled_end_time timestamptz,
    service_address_snapshot jsonb,
    
    -- 餐饮服务专用字段
    customizations jsonb DEFAULT '{}', -- 口味、配料、烹饪方式等
    dietary_restrictions text[], -- 饮食限制
    
    -- 通用字段
    special_instructions text,
    
    -- 快照字段（防止原数据变更影响订单）
    item_name_snapshot jsonb NOT NULL,
    item_description_snapshot text,
    item_image_snapshot text,
    provider_name_snapshot text,
    
    -- 计算字段
    subtotal numeric GENERATED ALWAYS AS (quantity * unit_price) STORED,
    
    -- 时间戳
    added_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 3. 购物车操作日志表
CREATE TABLE public.cart_operation_logs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id uuid NOT NULL REFERENCES public.unified_carts(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id),
    
    operation_type text NOT NULL CHECK (operation_type IN ('add', 'remove', 'update_quantity', 'update_customization', 'clear', 'convert_to_order')),
    item_id uuid REFERENCES public.cart_items(id),
    
    -- 操作详情
    operation_data jsonb,
    old_value jsonb,
    new_value jsonb,
    
    -- 元数据
    user_agent text,
    ip_address inet,
    session_id text,
    
    created_at timestamptz DEFAULT now()
);

-- 4. 创建索引
CREATE INDEX idx_unified_carts_user_status ON public.unified_carts(user_id, status);
CREATE INDEX idx_unified_carts_expires_at ON public.unified_carts(expires_at);
CREATE INDEX idx_cart_items_cart_id ON public.cart_items(cart_id);
CREATE INDEX idx_cart_items_service_id ON public.cart_items(service_id);
CREATE INDEX idx_cart_items_scheduled_time ON public.cart_items(scheduled_start_time);
CREATE INDEX idx_cart_items_added_at ON public.cart_items(added_at);
CREATE INDEX idx_cart_operation_logs_cart_id ON public.cart_operation_logs(cart_id);
CREATE INDEX idx_cart_operation_logs_operation_type ON public.cart_operation_logs(operation_type);
```

#### **Step 1.2: 扩展现有订单表**

```sql
-- 执行文件：docs/ServiceDetail/order_tables_extension.sql
-- =====================================================
-- 扩展订单表支持多种来源
-- =====================================================

-- 扩展orders表
ALTER TABLE public.orders 
ADD COLUMN IF NOT EXISTS order_source text DEFAULT 'direct' CHECK (order_source IN ('direct', 'cart', 'quote')),
ADD COLUMN IF NOT EXISTS source_cart_id uuid REFERENCES public.unified_carts(id),
ADD COLUMN IF NOT EXISTS source_quote_id uuid REFERENCES public.negotiation_records(id),
ADD COLUMN IF NOT EXISTS batch_order_id uuid,
ADD COLUMN IF NOT EXISTS delivery_method text,
ADD COLUMN IF NOT EXISTS estimated_completion_time timestamptz,
ADD COLUMN IF NOT EXISTS cart_snapshot jsonb; -- 购物车转换时的快照

-- 扩展order_items表
ALTER TABLE public.order_items
ADD COLUMN IF NOT EXISTS item_type text DEFAULT 'service',
ADD COLUMN IF NOT EXISTS customizations_snapshot jsonb DEFAULT '{}',
ADD COLUMN IF NOT EXISTS dietary_restrictions_snapshot text[],
ADD COLUMN IF NOT EXISTS scheduled_start_time timestamptz,
ADD COLUMN IF NOT EXISTS scheduled_end_time timestamptz;

-- 创建批量订单表
CREATE TABLE IF NOT EXISTS public.batch_orders (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id),
    cart_id uuid REFERENCES public.unified_carts(id),
    
    -- 批次信息
    total_orders_count integer NOT NULL CHECK (total_orders_count > 0),
    completed_orders_count integer DEFAULT 0,
    total_amount numeric NOT NULL CHECK (total_amount >= 0),
    currency text DEFAULT 'CAD',
    
    -- 支付信息
    payment_status text DEFAULT 'pending' CHECK (payment_status IN ('pending', 'partial', 'completed', 'failed', 'refunded')),
    payment_method_id uuid,
    payment_intent_id text, -- Stripe等支付平台的意图ID
    
    -- 时间戳
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    paid_at timestamptz,
    completed_at timestamptz
);

-- 创建新索引
CREATE INDEX IF NOT EXISTS idx_orders_order_source ON public.orders(order_source);
CREATE INDEX IF NOT EXISTS idx_orders_source_cart_id ON public.orders(source_cart_id);
CREATE INDEX IF NOT EXISTS idx_orders_batch_order_id ON public.orders(batch_order_id);
CREATE INDEX IF NOT EXISTS idx_batch_orders_user_id ON public.batch_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_batch_orders_payment_status ON public.batch_orders(payment_status);
```

#### **Step 1.3: 扩展议价记录表**

```sql
-- 执行文件：docs/ServiceDetail/negotiation_tables_extension.sql
-- =====================================================
-- 扩展议价记录表
-- =====================================================

-- 如果negotiation_records表不存在，先创建
CREATE TABLE IF NOT EXISTS public.negotiation_records (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id uuid NOT NULL REFERENCES public.services(id),
    user_id uuid NOT NULL REFERENCES auth.users(id),
    provider_id uuid NOT NULL REFERENCES public.provider_profiles(id),
    
    -- 询价类型和状态
    quote_type text NOT NULL CHECK (quote_type IN ('quick', 'detailed', 'chat')),
    status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'quoted', 'negotiating', 'accepted', 'rejected', 'expired')),
    
    -- 价格协商
    user_budget_range jsonb, -- {min: 100, max: 200, currency: 'CAD'}
    provider_quote numeric,
    final_agreed_price numeric,
    currency text DEFAULT 'CAD',
    
    -- 需求描述
    user_requirements text NOT NULL,
    user_additional_details jsonb, -- 详细需求的结构化数据
    provider_response text,
    provider_quote_breakdown jsonb, -- 报价明细
    
    -- 时间相关
    requested_service_time timestamptz,
    quote_expires_at timestamptz,
    provider_response_deadline timestamptz,
    
    -- 沟通记录
    communication_history jsonb DEFAULT '[]', -- 聊天记录摘要
    attachments text[], -- 相关附件URL
    
    -- 转换追踪
    converted_to_order_id uuid REFERENCES public.orders(id),
    conversion_rate numeric, -- 最终成交价格/初始预算的比率
    
    -- 时间戳
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    quoted_at timestamptz,
    accepted_at timestamptz
);

-- 议价消息表（用于实时聊天）
CREATE TABLE IF NOT EXISTS public.negotiation_messages (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    negotiation_id uuid NOT NULL REFERENCES public.negotiation_records(id) ON DELETE CASCADE,
    sender_id uuid NOT NULL REFERENCES auth.users(id),
    sender_type text NOT NULL CHECK (sender_type IN ('user', 'provider')),
    
    -- 消息内容
    message_type text NOT NULL CHECK (message_type IN ('text', 'quote', 'image', 'document', 'system')),
    content text,
    quote_amount numeric,
    attachments text[],
    
    -- 状态
    is_read boolean DEFAULT false,
    read_at timestamptz,
    
    created_at timestamptz DEFAULT now()
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_negotiation_records_service_id ON public.negotiation_records(service_id);
CREATE INDEX IF NOT EXISTS idx_negotiation_records_user_id ON public.negotiation_records(user_id);
CREATE INDEX IF NOT EXISTS idx_negotiation_records_provider_id ON public.negotiation_records(provider_id);
CREATE INDEX IF NOT EXISTS idx_negotiation_records_status ON public.negotiation_records(status);
CREATE INDEX IF NOT EXISTS idx_negotiation_records_expires_at ON public.negotiation_records(quote_expires_at);
CREATE INDEX IF NOT EXISTS idx_negotiation_messages_negotiation_id ON public.negotiation_messages(negotiation_id);
CREATE INDEX IF NOT EXISTS idx_negotiation_messages_sender_id ON public.negotiation_messages(sender_id);
```

### **Phase 2: 核心服务类实现 (第3-4周)**

#### **Step 2.1: 统一购物车控制器**

创建文件：`lib/core/controllers/unified_cart_controller.dart`

```dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/customer/domain/entities/service.dart';
import '../../features/customer/domain/entities/service_detail.dart';
import '../models/cart_models.dart';
import '../services/cart_service.dart';
import '../utils/app_logger.dart';

class UnifiedCartController extends GetxController {
  final CartService _cartService = Get.find<CartService>();
  
  // 响应式状态
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxDouble totalAmount = 0.0.obs;
  final RxInt totalItems = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  
  // 购物车分组
  final RxMap<String, List<CartItem>> groupedItems = <String, List<CartItem>>{}.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadCartFromStorage();
    
    // 监听cartItems变化，自动更新统计信息
    ever(cartItems, (_) => _updateTotals());
  }
  
  /// 添加服务到购物车
  Future<void> addServiceToCart({
    required String serviceId,
    required String serviceDetailId,
    int quantity = 1,
    DateTime? scheduledTime,
    Map<String, dynamic>? customizations,
    String? specialInstructions,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      AppLogger.info('[Cart] Adding service to cart: $serviceId');
      
      // 获取服务信息
      final service = await _getServiceInfo(serviceId);
      final serviceDetail = await _getServiceDetailInfo(serviceDetailId);
      
      // 确定购物车类型
      final cartType = _determineCartType(service);
      
      // 检查是否已存在相同配置的商品
      final existingItemIndex = _findExistingItem(
        serviceDetailId, 
        customizations, 
        scheduledTime
      );
      
      if (existingItemIndex >= 0) {
        // 更新现有商品数量
        await _updateItemQuantity(existingItemIndex, 
          cartItems[existingItemIndex].quantity + quantity);
      } else {
        // 添加新商品
        final cartItem = CartItem(
          id: _generateCartItemId(),
          serviceId: serviceId,
          serviceDetailId: serviceDetailId,
          itemType: _getItemType(service),
          quantity: quantity,
          unitPrice: serviceDetail.price ?? 0,
          scheduledStartTime: scheduledTime,
          customizations: customizations ?? {},
          specialInstructions: specialInstructions,
          itemNameSnapshot: serviceDetail.name,
          itemDescriptionSnapshot: serviceDetail.description,
          addedAt: DateTime.now(),
        );
        
        cartItems.add(cartItem);
        await _persistCartItem(cartItem);
      }
      
      _showAddToCartFeedback(service.title);
      
    } catch (e) {
      AppLogger.error('[Cart] Failed to add service to cart: $e');
      error.value = 'Failed to add item to cart';
      _showErrorFeedback();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 移除购物车商品
  Future<void> removeCartItem(String itemId) async {
    try {
      final itemIndex = cartItems.indexWhere((item) => item.id == itemId);
      if (itemIndex >= 0) {
        final item = cartItems[itemIndex];
        cartItems.removeAt(itemIndex);
        await _removeCartItemFromStorage(itemId);
        
        Get.snackbar(
          '已移除',
          '${item.itemNameSnapshot} 已从购物车移除',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      AppLogger.error('[Cart] Failed to remove cart item: $e');
    }
  }
  
  /// 更新商品数量
  Future<void> updateItemQuantity(String itemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeCartItem(itemId);
        return;
      }
      
      final itemIndex = cartItems.indexWhere((item) => item.id == itemId);
      if (itemIndex >= 0) {
        cartItems[itemIndex] = cartItems[itemIndex].copyWith(
          quantity: newQuantity,
          updatedAt: DateTime.now(),
        );
        await _updateCartItemInStorage(cartItems[itemIndex]);
      }
    } catch (e) {
      AppLogger.error('[Cart] Failed to update item quantity: $e');
    }
  }
  
  /// 清空购物车
  Future<void> clearCart() async {
    try {
      await _clearCartInStorage();
      cartItems.clear();
      Get.snackbar(
        '购物车已清空',
        '所有商品已从购物车移除',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      AppLogger.error('[Cart] Failed to clear cart: $e');
    }
  }
  
  /// 创建订单
  Future<List<Order>> createOrdersFromCart() async {
    try {
      isLoading.value = true;
      
      // 按服务分组
      final serviceGroups = _groupItemsByService();
      final orders = <Order>[];
      
      // 为每个服务组创建订单
      for (final serviceGroup in serviceGroups.entries) {
        final order = await _createOrderForServiceGroup(
          serviceGroup.key, 
          serviceGroup.value
        );
        orders.add(order);
      }
      
      // 清空购物车
      await clearCart();
      
      return orders;
      
    } catch (e) {
      AppLogger.error('[Cart] Failed to create orders: $e');
      error.value = 'Failed to create orders';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 获取服务类型的预订模式
  ServiceBookingType getBookingType(Service service) {
    final categoryId = service.categoryLevel1Id;
    final tags = service.tags ?? [];
    
    // 餐饮服务强制购物车
    if (categoryId == '1010000') {
      return ServiceBookingType.cartOnly;
    }
    
    // 紧急或咨询服务直接下单
    if (tags.contains('emergency') || tags.contains('consultation')) {
      return ServiceBookingType.directOnly;
    }
    
    // 其他服务支持双模式
    switch (categoryId) {
      case '1020000': // 家政服务
      case '1050000': // 教育培训
      case '1060000': // 生活帮忙
        return ServiceBookingType.both;
      default:
        return ServiceBookingType.directOnly;
    }
  }
  
  // ===== 私有方法 =====
  
  void _updateTotals() {
    totalItems.value = cartItems.fold(0, (sum, item) => sum + item.quantity);
    totalAmount.value = cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
    _updateGroupedItems();
  }
  
  void _updateGroupedItems() {
    final grouped = <String, List<CartItem>>{};
    for (final item in cartItems) {
      grouped.putIfAbsent(item.serviceId, () => []).add(item);
    }
    groupedItems.value = grouped;
  }
  
  String _determineCartType(Service service) {
    switch (service.categoryLevel1Id) {
      case '1010000':
        return 'restaurant';
      default:
        return 'appointment';
    }
  }
  
  String _getItemType(Service service) {
    switch (service.categoryLevel1Id) {
      case '1010000':
        return 'menu_item';
      default:
        return 'appointment';
    }
  }
  
  int _findExistingItem(
    String serviceDetailId, 
    Map<String, dynamic>? customizations,
    DateTime? scheduledTime,
  ) {
    return cartItems.indexWhere((item) =>
      item.serviceDetailId == serviceDetailId &&
      _customizationsEqual(item.customizations, customizations) &&
      _timesEqual(item.scheduledStartTime, scheduledTime)
    );
  }
  
  bool _customizationsEqual(
    Map<String, dynamic> a, 
    Map<String, dynamic>? b,
  ) {
    final bNonNull = b ?? {};
    if (a.length != bNonNull.length) return false;
    
    for (final entry in a.entries) {
      if (bNonNull[entry.key] != entry.value) return false;
    }
    return true;
  }
  
  bool _timesEqual(DateTime? a, DateTime? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.isAtSameMomentAs(b);
  }
  
  String _generateCartItemId() {
    return 'cart_item_${DateTime.now().millisecondsSinceEpoch}_${Get.find<Random>().nextInt(10000)}';
  }
  
  Map<String, List<CartItem>> _groupItemsByService() {
    final grouped = <String, List<CartItem>>{};
    for (final item in cartItems) {
      grouped.putIfAbsent(item.serviceId, () => []).add(item);
    }
    return grouped;
  }
  
  void _showAddToCartFeedback(String serviceName) {
    Get.snackbar(
      '已添加到购物车',
      serviceName,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }
  
  void _showErrorFeedback() {
    Get.snackbar(
      '添加失败',
      '请稍后重试',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
  
  // 数据持久化方法
  Future<void> _loadCartFromStorage() async {
    // 从Supabase加载购物车数据
  }
  
  Future<void> _persistCartItem(CartItem item) async {
    // 持久化到Supabase
  }
  
  Future<void> _updateCartItemInStorage(CartItem item) async {
    // 更新Supabase中的数据
  }
  
  Future<void> _removeCartItemFromStorage(String itemId) async {
    // 从Supabase删除
  }
  
  Future<void> _clearCartInStorage() async {
    // 清空Supabase中的购物车
  }
  
  Future<Service> _getServiceInfo(String serviceId) async {
    // 获取服务信息
    throw UnimplementedError();
  }
  
  Future<ServiceDetail> _getServiceDetailInfo(String serviceDetailId) async {
    // 获取服务详情信息
    throw UnimplementedError();
  }
  
  Future<Order> _createOrderForServiceGroup(
    String serviceId, 
    List<CartItem> items,
  ) async {
    // 为服务组创建订单
    throw UnimplementedError();
  }
}

enum ServiceBookingType {
  directOnly,   // 只支持直接下单
  cartOnly,     // 只支持购物车
  both,         // 两者都支持
}
```

#### **Step 2.2: 购物车数据模型**

创建文件：`lib/core/models/cart_models.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'cart_models.g.dart';

@JsonSerializable()
class CartItem {
  final String id;
  final String serviceId;
  final String serviceDetailId;
  final String itemType; // 'menu_item', 'appointment', 'package'
  final int quantity;
  final double unitPrice;
  final DateTime? scheduledStartTime;
  final DateTime? scheduledEndTime;
  final Map<String, dynamic> customizations;
  final String? specialInstructions;
  
  // 快照数据
  final Map<String, String> itemNameSnapshot; // 多语言名称
  final String? itemDescriptionSnapshot;
  final String? itemImageSnapshot;
  final String? providerNameSnapshot;
  
  // 时间戳
  final DateTime addedAt;
  final DateTime? updatedAt;
  
  // 计算属性
  double get subtotal => quantity * unitPrice;
  
  const CartItem({
    required this.id,
    required this.serviceId,
    required this.serviceDetailId,
    required this.itemType,
    required this.quantity,
    required this.unitPrice,
    this.scheduledStartTime,
    this.scheduledEndTime,
    this.customizations = const {},
    this.specialInstructions,
    required this.itemNameSnapshot,
    this.itemDescriptionSnapshot,
    this.itemImageSnapshot,
    this.providerNameSnapshot,
    required this.addedAt,
    this.updatedAt,
  });
  
  // JSON序列化
  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);
  
  // 复制方法
  CartItem copyWith({
    String? id,
    String? serviceId,
    String? serviceDetailId,
    String? itemType,
    int? quantity,
    double? unitPrice,
    DateTime? scheduledStartTime,
    DateTime? scheduledEndTime,
    Map<String, dynamic>? customizations,
    String? specialInstructions,
    Map<String, String>? itemNameSnapshot,
    String? itemDescriptionSnapshot,
    String? itemImageSnapshot,
    String? providerNameSnapshot,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      serviceDetailId: serviceDetailId ?? this.serviceDetailId,
      itemType: itemType ?? this.itemType,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      scheduledEndTime: scheduledEndTime ?? this.scheduledEndTime,
      customizations: customizations ?? this.customizations,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      itemNameSnapshot: itemNameSnapshot ?? this.itemNameSnapshot,
      itemDescriptionSnapshot: itemDescriptionSnapshot ?? this.itemDescriptionSnapshot,
      itemImageSnapshot: itemImageSnapshot ?? this.itemImageSnapshot,
      providerNameSnapshot: providerNameSnapshot ?? this.providerNameSnapshot,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

@JsonSerializable()
class Cart {
  final String id;
  final String userId;
  final String cartType; // 'restaurant', 'appointment', 'mixed'
  final String status; // 'active', 'converting', 'converted', 'expired'
  final List<CartItem> items;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // 餐饮专用字段
  final String? deliveryMethod; // 'delivery', 'pickup', 'dine_in'
  final String? deliveryAddressId;
  final DateTime? estimatedDeliveryTime;
  final String? specialInstructions;
  
  // 计算属性
  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.subtotal);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  
  const Cart({
    required this.id,
    required this.userId,
    required this.cartType,
    required this.status,
    required this.items,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.deliveryMethod,
    this.deliveryAddressId,
    this.estimatedDeliveryTime,
    this.specialInstructions,
  });
  
  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
  Map<String, dynamic> toJson() => _$CartToJson(this);
}

@JsonSerializable()
class PricingResult {
  final double basePrice;
  final double itemsTotal;
  final double deliveryFee;
  final double serviceFee;
  final double urgencyFee;
  final double distanceFee;
  final double taxAmount;
  final double subtotal;
  final double total;
  final double? suggestedTip;
  final String currency;
  
  const PricingResult({
    this.basePrice = 0,
    required this.itemsTotal,
    this.deliveryFee = 0,
    this.serviceFee = 0,
    this.urgencyFee = 0,
    this.distanceFee = 0,
    required this.taxAmount,
    required this.subtotal,
    required this.total,
    this.suggestedTip,
    this.currency = 'CAD',
  });
  
  factory PricingResult.fromJson(Map<String, dynamic> json) => _$PricingResultFromJson(json);
  Map<String, dynamic> toJson() => _$PricingResultToJson(this);
}

@JsonSerializable()
class Order {
  final String id;
  final String orderNumber;
  final String userId;
  final String providerId;
  final String serviceId;
  final String orderType;
  final String orderStatus;
  final String orderSource; // 'direct', 'cart', 'quote'
  final double totalPrice;
  final String currency;
  final String paymentStatus;
  final DateTime? scheduledStartTime;
  final DateTime? scheduledEndTime;
  final Map<String, dynamic>? serviceAddressSnapshot;
  final String? userNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.providerId,
    required this.serviceId,
    required this.orderType,
    required this.orderStatus,
    required this.orderSource,
    required this.totalPrice,
    required this.currency,
    required this.paymentStatus,
    this.scheduledStartTime,
    this.scheduledEndTime,
    this.serviceAddressSnapshot,
    this.userNotes,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
```

#### **Step 2.3: 服务类型判断器**

创建文件：`lib/core/services/service_booking_type_resolver.dart`

```dart
import '../../features/customer/domain/entities/service.dart';
import '../models/cart_models.dart';

class ServiceBookingTypeResolver {
  /// 解析服务的预订类型
  static ServiceBookingType resolve(Service service) {
    final categoryId = service.categoryLevel1Id;
    final tags = service.tags ?? [];
    
    // 1. 餐饮服务强制购物车模式
    if (categoryId == '1010000') {
      return ServiceBookingType.cartOnly;
    }
    
    // 2. 紧急或即时服务直接下单
    if (_isEmergencyService(service) || _isInstantService(service)) {
      return ServiceBookingType.directOnly;
    }
    
    // 3. 咨询类服务直接下单
    if (_isConsultationService(service)) {
      return ServiceBookingType.directOnly;
    }
    
    // 4. 预约类服务提供双选项
    if (_isAppointmentService(service)) {
      return ServiceBookingType.both;
    }
    
    // 5. 默认情况
    return ServiceBookingType.directOnly;
  }
  
  /// 判断是否为紧急服务
  static bool _isEmergencyService(Service service) {
    final tags = service.tags ?? [];
    return tags.any((tag) => 
      tag.toLowerCase().contains('emergency') ||
      tag.toLowerCase().contains('urgent') ||
      tag.toLowerCase().contains('紧急')
    );
  }
  
  /// 判断是否为即时服务
  static bool _isInstantService(Service service) {
    final tags = service.tags ?? [];
    return tags.any((tag) => 
      tag.toLowerCase().contains('instant') ||
      tag.toLowerCase().contains('immediate') ||
      tag.toLowerCase().contains('即时')
    );
  }
  
  /// 判断是否为咨询服务
  static bool _isConsultationService(Service service) {
    final title = service.title?.toLowerCase() ?? '';
    final tags = service.tags ?? [];
    
    return title.contains('consultation') ||
           title.contains('咨询') ||
           tags.any((tag) => 
             tag.toLowerCase().contains('consultation') ||
             tag.toLowerCase().contains('咨询')
           );
  }
  
  /// 判断是否为预约类服务
  static bool _isAppointmentService(Service service) {
    final categoryId = service.categoryLevel1Id;
    
    return [
      '1020000', // 家政服务
      '1050000', // 教育培训
      '1060000', // 生活帮忙
    ].contains(categoryId);
  }
  
  /// 获取UI提示文本
  static String getBookingModeDescription(ServiceBookingType type) {
    switch (type) {
      case ServiceBookingType.directOnly:
        return '立即预订，快速下单';
      case ServiceBookingType.cartOnly:
        return '添加到购物车，统一结算';
      case ServiceBookingType.both:
        return '立即预订或加入购物车';
    }
  }
  
  /// 获取默认建议
  static String getRecommendedAction(ServiceBookingType type) {
    switch (type) {
      case ServiceBookingType.directOnly:
        return '立即预订';
      case ServiceBookingType.cartOnly:
        return '加入购物车';
      case ServiceBookingType.both:
        return '立即预订'; // 默认推荐立即预订
    }
  }
}

enum ServiceBookingType {
  directOnly,   // 只支持直接下单
  cartOnly,     // 只支持购物车
  both,         // 两者都支持
}
```

### **Phase 3: UI组件实现 (第5-6周)**

#### **Step 3.1: 服务详情页操作区域适配**

修改文件：`lib/features/customer/services/presentation/service_detail_page.dart`

```dart
// 在ServiceDetailPage中添加以下方法

Widget _buildActionSection() {
  return Obx(() {
    final service = controller.service.value;
    if (service == null) return SizedBox.shrink();
    
    final bookingType = ServiceBookingTypeResolver.resolve(service);
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: _buildActionButtons(bookingType, service),
      ),
    );
  });
}

Widget _buildActionButtons(ServiceBookingType bookingType, Service service) {
  switch (bookingType) {
    case ServiceBookingType.directOnly:
      return _buildDirectBookingButton(service);
    case ServiceBookingType.cartOnly:
      return _buildCartOnlyButton(service);
    case ServiceBookingType.both:
      return _buildBothOptionsButtons(service);
  }
}

// 直接下单按钮
Widget _buildDirectBookingButton(Service service) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildPriceDisplay(service),
      SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          icon: Icon(_getBookingIcon(service)),
          label: Text(_getBookingLabel(service)),
          onPressed: () => _handleDirectBooking(service),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getBookingColor(service),
            foregroundColor: Colors.white,
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      SizedBox(height: 8),
      Text(
        ServiceBookingTypeResolver.getBookingModeDescription(
          ServiceBookingType.directOnly
        ),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

// 购物车专用按钮（餐饮服务）
Widget _buildCartOnlyButton(Service service) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // 购物车浮动按钮
      _buildFloatingCartButton(),
      SizedBox(height: 8),
      Text(
        '请在Menu菜单中选择具体菜品',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

// 双选项按钮（预约服务）
Widget _buildBothOptionsButtons(Service service) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildPriceDisplay(service),
      SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                icon: Icon(Icons.event_available),
                label: Text('立即预订'),
                onPressed: () => _handleDirectBooking(service),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                icon: Icon(Icons.add_shopping_cart),
                label: Text('购物车'),
                onPressed: () => _handleAddToCart(service),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue),
                  foregroundColor: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 8),
      Text(
        ServiceBookingTypeResolver.getBookingModeDescription(
          ServiceBookingType.both
        ),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

// 购物车浮动按钮
Widget _buildFloatingCartButton() {
  final cartController = Get.find<UnifiedCartController>();
  
  return Obx(() {
    final itemCount = cartController.totalItems.value;
    
    return FloatingActionButton.extended(
      onPressed: () => Get.toNamed('/cart'),
      icon: Stack(
        children: [
          Icon(Icons.shopping_cart),
          if (itemCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '$itemCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      label: Text(itemCount > 0 ? '购物车 ($itemCount)' : '购物车'),
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
    );
  });
}

// 价格显示组件
Widget _buildPriceDisplay(Service service) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '起步价',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          _getFormattedPrice(service),
          style: TextStyle(
            color: Colors.blue[700],
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

// 事件处理方法
void _handleDirectBooking(Service service) {
  if (service.pricingType == 'fixed_price') {
    // 固定价格直接跳转订单页面
    Get.toNamed('/create-order', arguments: {
      'serviceId': service.id,
      'serviceName': service.title,
      'providerId': service.providerId,
      'price': service.price,
      'pricingType': service.pricingType,
    });
  } else {
    // 非固定价格显示询价对话框
    _showQuoteDialog(service);
  }
}

void _handleAddToCart(Service service) {
  _showAddToCartDialog(service);
}

// 辅助方法
IconData _getBookingIcon(Service service) {
  if (ServiceBookingTypeResolver._isEmergencyService(service)) {
    return Icons.emergency;
  } else if (ServiceBookingTypeResolver._isConsultationService(service)) {
    return Icons.chat;
  } else {
    return Icons.event_available;
  }
}

String _getBookingLabel(Service service) {
  if (ServiceBookingTypeResolver._isEmergencyService(service)) {
    return '紧急预订';
  } else if (ServiceBookingTypeResolver._isConsultationService(service)) {
    return '立即咨询';
  } else {
    return '立即预订';
  }
}

Color _getBookingColor(Service service) {
  if (ServiceBookingTypeResolver._isEmergencyService(service)) {
    return Colors.red;
  } else {
    return Colors.blue;
  }
}

String _getFormattedPrice(Service service) {
  final price = service.price;
  if (price != null && price > 0) {
    return '\$${price.toStringAsFixed(2)}';
  } else {
    return '询价';
  }
}
```

#### **Step 3.2: 购物车页面实现**

创建文件：`lib/features/customer/cart/presentation/cart_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/controllers/unified_cart_controller.dart';
import '../../../../core/models/cart_models.dart';
import 'cart_controller.dart';

class CartPage extends GetView<CartController> {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('购物车'),
        actions: [
          Obx(() {
            final hasItems = controller.cartController.cartItems.isNotEmpty;
            return hasItems
                ? TextButton(
                    onPressed: controller.clearCart,
                    child: Text(
                      '清空',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        final cartController = controller.cartController;
        
        if (cartController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (cartController.cartItems.isEmpty) {
          return _buildEmptyCart();
        }
        
        return Column(
          children: [
            // 购物车项目列表
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: cartController.groupedItems.length,
                itemBuilder: (context, index) {
                  final serviceEntry = cartController.groupedItems.entries.elementAt(index);
                  return _buildServiceGroup(serviceEntry.key, serviceEntry.value);
                },
              ),
            ),
            
            // 底部操作栏
            _buildBottomActionBar(),
          ],
        );
      }),
    );
  }
  
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            '购物车是空的',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '快去添加一些服务吧！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.offNamed('/home'),
            child: Text('去逛逛'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildServiceGroup(String serviceId, List<CartItem> items) {
    final firstItem = items.first;
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // 服务商信息头部
          _buildServiceHeader(firstItem),
          
          // 分隔线
          Divider(height: 1),
          
          // 服务项目列表
          ...items.map((item) => _buildCartItem(item)),
          
          // 服务小计
          _buildServiceSubtotal(items),
        ],
      ),
    );
  }
  
  Widget _buildServiceHeader(CartItem item) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // 服务商头像
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue[100],
            child: Icon(
              Icons.store,
              color: Colors.blue[700],
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          
          // 服务商信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.providerNameSnapshot ?? '未知服务商',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _getServiceTypeLabel(item.itemType),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // 操作按钮
          TextButton(
            onPressed: () => _showServiceOptions(item.serviceId),
            child: Text('管理'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCartItem(CartItem item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 商品图片
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              color: Colors.grey[200],
              child: item.itemImageSnapshot != null
                  ? Image.network(
                      item.itemImageSnapshot!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
          ),
          
          SizedBox(width: 12),
          
          // 商品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemNameSnapshot['zh'] ?? 
                  item.itemNameSnapshot['en'] ?? 
                  '未知商品',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (item.customizations.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      _buildCustomizationText(item.customizations),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                
                if (item.scheduledStartTime != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      '预约时间: ${_formatDateTime(item.scheduledStartTime!)}',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                
                SizedBox(height: 8),
                
                // 价格和数量控制
                Row(
                  children: [
                    Text(
                      '\$${item.unitPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    
                    Spacer(),
                    
                    // 数量控制
                    _buildQuantityControl(item),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuantityControl(CartItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => controller.decreaseQuantity(item.id),
          icon: Icon(Icons.remove_circle_outline),
          iconSize: 24,
          constraints: BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        
        Container(
          width: 40,
          alignment: Alignment.center,
          child: Text(
            '${item.quantity}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        IconButton(
          onPressed: () => controller.increaseQuantity(item.id),
          icon: Icon(Icons.add_circle_outline),
          iconSize: 24,
          constraints: BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
  
  Widget _buildServiceSubtotal(List<CartItem> items) {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.subtotal);
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '小计 (${items.length}项)',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          Text(
            '\$${subtotal.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.orange[700],
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomActionBar() {
    final cartController = controller.cartController;
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 总价显示
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '总计',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Obx(() => Text(
                      '\$${cartController.totalAmount.value.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    )),
                  ],
                ),
                
                // 结算按钮
                Obx(() => ElevatedButton(
                  onPressed: cartController.cartItems.isNotEmpty
                      ? controller.checkout
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text(
                    '结算 (${cartController.totalItems.value})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )),
              ],
            ),
            
            SizedBox(height: 8),
            
            // 提示信息
            Text(
              '不同服务商的商品将分别生成订单',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.image,
        color: Colors.grey[400],
        size: 30,
      ),
    );
  }
  
  String _getServiceTypeLabel(String itemType) {
    switch (itemType) {
      case 'menu_item':
        return '餐饮服务';
      case 'appointment':
        return '预约服务';
      case 'package':
        return '套餐服务';
      default:
        return '服务';
    }
  }
  
  String _buildCustomizationText(Map<String, dynamic> customizations) {
    final parts = <String>[];
    
    customizations.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        parts.add('$key: $value');
      }
    });
    
    return parts.join(', ');
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}月${dateTime.day}日 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  void _showServiceOptions(String serviceId) {
    // 显示服务选项（如删除该服务商的所有商品）
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('移除该服务商的所有商品'),
              onTap: () {
                Get.back();
                controller.removeServiceItems(serviceId);
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel),
              title: Text('取消'),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }
}
```

### **Phase 4: 测试和优化 (第7-8周)**

#### **Step 4.1: 单元测试**

创建文件：`test/core/controllers/unified_cart_controller_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:jinbeanpod_83904710/core/controllers/unified_cart_controller.dart';
import 'package:jinbeanpod_83904710/core/services/cart_service.dart';
import 'package:jinbeanpod_83904710/features/customer/domain/entities/service.dart';

@GenerateMocks([CartService])
import 'unified_cart_controller_test.mocks.dart';

void main() {
  late UnifiedCartController controller;
  late MockCartService mockCartService;
  
  setUp(() {
    mockCartService = MockCartService();
    Get.put<CartService>(mockCartService);
    controller = UnifiedCartController();
  });
  
  tearDown(() {
    Get.reset();
  });
  
  group('UnifiedCartController', () {
    test('should initialize with empty cart', () {
      expect(controller.cartItems.isEmpty, true);
      expect(controller.totalAmount.value, 0.0);
      expect(controller.totalItems.value, 0);
    });
    
    test('should add service to cart successfully', () async {
      // Arrange
      final service = Service(
        id: 'service_1',
        title: 'Test Service',
        categoryLevel1Id: '1020000',
        providerId: 'provider_1',
        price: 100.0,
      );
      
      when(mockCartService.getServiceInfo('service_1'))
          .thenAnswer((_) async => service);
      
      // Act
      await controller.addServiceToCart(
        serviceId: 'service_1',
        serviceDetailId: 'detail_1',
        quantity: 2,
      );
      
      // Assert
      expect(controller.cartItems.length, 1);
      expect(controller.cartItems.first.quantity, 2);
      expect(controller.totalAmount.value, 200.0);
      expect(controller.totalItems.value, 2);
    });
    
    test('should update existing item quantity when adding same service', () async {
      // Arrange - 先添加一个商品
      await controller.addServiceToCart(
        serviceId: 'service_1',
        serviceDetailId: 'detail_1',
        quantity: 1,
      );
      
      // Act - 再添加相同商品
      await controller.addServiceToCart(
        serviceId: 'service_1',
        serviceDetailId: 'detail_1',
        quantity: 2,
      );
      
      // Assert
      expect(controller.cartItems.length, 1);
      expect(controller.cartItems.first.quantity, 3);
    });
    
    test('should remove cart item correctly', () async {
      // Arrange
      await controller.addServiceToCart(
        serviceId: 'service_1',
        serviceDetailId: 'detail_1',
        quantity: 2,
      );
      final itemId = controller.cartItems.first.id;
      
      // Act
      await controller.removeCartItem(itemId);
      
      // Assert
      expect(controller.cartItems.isEmpty, true);
      expect(controller.totalAmount.value, 0.0);
      expect(controller.totalItems.value, 0);
    });
    
    test('should determine correct booking type for different services', () {
      // Restaurant service
      final restaurantService = Service(
        id: 'service_1',
        categoryLevel1Id: '1010000',
      );
      expect(
        controller.getBookingType(restaurantService),
        ServiceBookingType.cartOnly,
      );
      
      // Emergency service
      final emergencyService = Service(
        id: 'service_2',
        categoryLevel1Id: '1020000',
        tags: ['emergency'],
      );
      expect(
        controller.getBookingType(emergencyService),
        ServiceBookingType.directOnly,
      );
      
      // Appointment service
      final appointmentService = Service(
        id: 'service_3',
        categoryLevel1Id: '1020000',
      );
      expect(
        controller.getBookingType(appointmentService),
        ServiceBookingType.both,
      );
    });
  });
}
```

#### **Step 4.2: 集成测试**

创建文件：`integration_test/cart_workflow_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:jinbeanpod_83904710/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Cart Workflow Integration Tests', () {
    testWidgets('Complete restaurant order workflow', (WidgetTester tester) async {
      // 启动应用
      app.main();
      await tester.pumpAndSettle();
      
      // 1. 导航到餐厅服务
      await tester.tap(find.text('美食天地'));
      await tester.pumpAndSettle();
      
      // 2. 选择一个餐厅
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();
      
      // 3. 切换到Menu Tab
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      
      // 4. 添加菜品到购物车
      await tester.tap(find.text('加入购物车').first);
      await tester.pumpAndSettle();
      
      // 5. 验证购物车图标显示数量
      expect(find.text('购物车 (1)'), findsOneWidget);
      
      // 6. 打开购物车
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();
      
      // 7. 验证购物车页面
      expect(find.text('购物车'), findsOneWidget);
      expect(find.byType(Card), findsWidgets); // 应该有服务分组卡片
      
      // 8. 修改数量
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();
      
      // 9. 进行结算
      await tester.tap(find.text('结算 (2)'));
      await tester.pumpAndSettle();
      
      // 10. 验证订单创建
      expect(find.text('订单创建成功'), findsOneWidget);
    });
    
    testWidgets('Appointment service direct booking workflow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 1. 导航到家政服务
      await tester.tap(find.text('家政服务'));
      await tester.pumpAndSettle();
      
      // 2. 选择一个服务
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();
      
      // 3. 选择立即预订
      await tester.tap(find.text('立即预订'));
      await tester.pumpAndSettle();
      
      // 4. 填写预约信息
      await tester.enterText(find.byType(TextField).first, '123 Test Street');
      await tester.tap(find.text('选择日期'));
      await tester.pumpAndSettle();
      
      // 选择明天
      await tester.tap(find.text('${DateTime.now().add(Duration(days: 1)).day}'));
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      
      // 5. 创建订单
      await tester.tap(find.text('创建订单'));
      await tester.pumpAndSettle();
      
      // 6. 验证订单创建成功
      expect(find.text('订单创建成功'), findsOneWidget);
    });
    
    testWidgets('Quote request workflow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 1. 找到一个需要询价的服务
      await tester.tap(find.text('定制服务'));
      await tester.pumpAndSettle();
      
      // 2. 点击获取报价
      await tester.tap(find.text('获取报价'));
      await tester.pumpAndSettle();
      
      // 3. 选择快速报价
      await tester.tap(find.text('快速报价'));
      await tester.pumpAndSettle();
      
      // 4. 填写需求
      await tester.enterText(
        find.byType(TextField),
        '需要定制一个特殊的服务方案',
      );
      
      // 5. 提交报价请求
      await tester.tap(find.text('提交'));
      await tester.pumpAndSettle();
      
      // 6. 验证提交成功
      expect(find.text('报价请求已提交'), findsOneWidget);
    });
  });
}
```

### **Phase 5: 部署和监控 (第8周)**

#### **Step 5.1: 数据库迁移脚本**

创建文件：`docs/ServiceDetail/production_migration.sql`

```sql
-- =====================================================
-- 生产环境数据库迁移脚本
-- 执行前请备份数据库
-- =====================================================

BEGIN;

-- 1. 创建新表（如果不存在）
\i cart_tables_creation.sql
\i order_tables_extension.sql
\i negotiation_tables_extension.sql

-- 2. 数据迁移和验证
DO $$
DECLARE
    cart_count INTEGER;
    order_count INTEGER;
BEGIN
    -- 检查现有数据
    SELECT COUNT(*) INTO order_count FROM public.orders;
    RAISE NOTICE '现有订单数量: %', order_count;
    
    -- 验证新表结构
    SELECT COUNT(*) INTO cart_count FROM public.unified_carts;
    RAISE NOTICE '购物车表已创建，当前记录数: %', cart_count;
    
    -- 更新现有订单的order_source字段
    UPDATE public.orders 
    SET order_source = 'direct' 
    WHERE order_source IS NULL;
    
    RAISE NOTICE '数据迁移完成';
END $$;

-- 3. 性能优化
ANALYZE public.unified_carts;
ANALYZE public.cart_items;
ANALYZE public.orders;
ANALYZE public.order_items;

-- 4. 权限设置
GRANT SELECT, INSERT, UPDATE, DELETE ON public.unified_carts TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.cart_items TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.cart_operation_logs TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.batch_orders TO authenticated;

-- 5. RLS策略
ALTER TABLE public.unified_carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_operation_logs ENABLE ROW LEVEL SECURITY;

-- 购物车RLS策略
CREATE POLICY "Users can manage their own carts" ON public.unified_carts
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their own cart items" ON public.cart_items
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.unified_carts 
            WHERE unified_carts.id = cart_items.cart_id 
            AND unified_carts.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can view their own cart operations" ON public.cart_operation_logs
    FOR SELECT USING (auth.uid() = user_id);

COMMIT;
```

#### **Step 5.2: 监控配置**

创建文件：`monitoring/cart_monitoring.sql`

```sql
-- =====================================================
-- 购物车系统监控查询
-- =====================================================

-- 1. 购物车使用统计
CREATE OR REPLACE VIEW cart_usage_stats AS
SELECT 
    DATE(created_at) as date,
    cart_type,
    COUNT(*) as carts_created,
    COUNT(CASE WHEN status = 'converted' THEN 1 END) as carts_converted,
    ROUND(
        COUNT(CASE WHEN status = 'converted' THEN 1 END)::NUMERIC / 
        COUNT(*)::NUMERIC * 100, 2
    ) as conversion_rate
FROM public.unified_carts
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(created_at), cart_type
ORDER BY date DESC, cart_type;

-- 2. 购物车转换漏斗分析
CREATE OR REPLACE VIEW cart_conversion_funnel AS
WITH cart_metrics AS (
    SELECT
        COUNT(*) as total_carts,
        COUNT(CASE WHEN status = 'active' THEN 1 END) as active_carts,
        COUNT(CASE WHEN status = 'converting' THEN 1 END) as converting_carts,
        COUNT(CASE WHEN status = 'converted' THEN 1 END) as converted_carts,
        COUNT(CASE WHEN status = 'expired' THEN 1 END) as expired_carts
    FROM public.unified_carts
    WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
)
SELECT 
    'Step 1: 创建购物车' as step,
    total_carts as count,
    100.0 as percentage
FROM cart_metrics
UNION ALL
SELECT 
    'Step 2: 开始结算',
    converting_carts,
    ROUND(converting_carts::NUMERIC / total_carts::NUMERIC * 100, 2)
FROM cart_metrics
UNION ALL
SELECT 
    'Step 3: 完成订单',
    converted_carts,
    ROUND(converted_carts::NUMERIC / total_carts::NUMERIC * 100, 2)
FROM cart_metrics;

-- 3. 购物车商品分析
CREATE OR REPLACE VIEW cart_item_analytics AS
SELECT 
    ci.item_type,
    COUNT(*) as items_added,
    AVG(ci.quantity) as avg_quantity,
    AVG(ci.unit_price) as avg_unit_price,
    SUM(ci.subtotal) as total_value
FROM public.cart_items ci
JOIN public.unified_carts uc ON ci.cart_id = uc.id
WHERE uc.created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY ci.item_type
ORDER BY items_added DESC;

-- 4. 购物车异常监控
CREATE OR REPLACE VIEW cart_anomalies AS
SELECT 
    'Expired carts with items' as anomaly_type,
    COUNT(*) as count
FROM public.unified_carts uc
JOIN public.cart_items ci ON uc.id = ci.cart_id
WHERE uc.status = 'expired' AND uc.expires_at < NOW()
UNION ALL
SELECT 
    'Carts without items',
    COUNT(*)
FROM public.unified_carts uc
LEFT JOIN public.cart_items ci ON uc.id = ci.cart_id
WHERE ci.id IS NULL AND uc.status = 'active'
UNION ALL
SELECT 
    'Items with invalid prices',
    COUNT(*)
FROM public.cart_items
WHERE unit_price <= 0;

-- 5. 性能监控查询
CREATE OR REPLACE VIEW cart_performance_metrics AS
SELECT 
    'Average cart load time' as metric,
    '< 200ms' as target,
    'Monitor via APM' as current_value
UNION ALL
SELECT 
    'Cart conversion rate',
    '> 60%',
    CONCAT(
        ROUND(
            (SELECT COUNT(*) FROM public.unified_carts WHERE status = 'converted' AND created_at >= CURRENT_DATE - 7)::NUMERIC /
            (SELECT COUNT(*) FROM public.unified_carts WHERE created_at >= CURRENT_DATE - 7)::NUMERIC * 100, 2
        ), '%'
    )
UNION ALL
SELECT 
    'Average items per cart',
    '2-5 items',
    ROUND(
        (SELECT AVG(item_count) FROM (
            SELECT COUNT(*) as item_count 
            FROM public.cart_items ci
            JOIN public.unified_carts uc ON ci.cart_id = uc.id
            WHERE uc.created_at >= CURRENT_DATE - 7
            GROUP BY ci.cart_id
        ) subq), 2
    )::TEXT;
```

#### **Step 5.3: 错误监控和告警**

创建文件：`monitoring/alert_rules.yml`

```yaml
# 购物车系统告警规则
alert_rules:
  - name: cart_conversion_rate_low
    condition: |
      SELECT conversion_rate 
      FROM cart_usage_stats 
      WHERE date = CURRENT_DATE 
      AND conversion_rate < 50
    severity: warning
    message: "购物车转换率低于50%"
    
  - name: cart_errors_high
    condition: |
      SELECT COUNT(*) 
      FROM cart_operation_logs 
      WHERE operation_type = 'error' 
      AND created_at >= NOW() - INTERVAL '1 hour'
      HAVING COUNT(*) > 10
    severity: critical
    message: "购物车操作错误频率过高"
    
  - name: abandoned_carts_high
    condition: |
      SELECT COUNT(*) 
      FROM unified_carts 
      WHERE status = 'expired' 
      AND expires_at >= CURRENT_DATE
      HAVING COUNT(*) > 100
    severity: warning
    message: "今日放弃购物车数量过高"

monitoring_queries:
  # 每5分钟执行的监控查询
  - interval: "5m"
    query: "SELECT * FROM cart_anomalies WHERE count > 0"
    alert_threshold: 1
    
  # 每小时执行的性能检查
  - interval: "1h"
    query: "SELECT * FROM cart_performance_metrics"
    
  # 每日执行的统计报告
  - interval: "1d"
    query: "SELECT * FROM cart_usage_stats WHERE date = CURRENT_DATE"
```

---

## 📋 **实施检查清单**

### **数据库部分**
- [ ] 执行购物车表创建脚本
- [ ] 执行订单表扩展脚本
- [ ] 执行议价表扩展脚本
- [ ] 验证所有索引创建成功
- [ ] 配置RLS安全策略
- [ ] 测试数据库性能

### **后端服务部分**
- [ ] 实现UnifiedCartController
- [ ] 实现CartService数据服务
- [ ] 实现ServiceBookingTypeResolver
- [ ] 实现价格计算器
- [ ] 配置依赖注入
- [ ] 编写单元测试

### **前端UI部分**
- [ ] 更新ServiceDetailPage操作区域
- [ ] 实现CartPage购物车页面
- [ ] 实现CartController
- [ ] 适配不同服务类型的UI
- [ ] 实现购物车浮动按钮
- [ ] 测试响应式设计

### **测试部分**
- [ ] 单元测试覆盖率 > 80%
- [ ] 集成测试覆盖主要流程
- [ ] 性能测试
- [ ] 用户体验测试
- [ ] 兼容性测试

### **部署部分**
- [ ] 生产环境数据库迁移
- [ ] 配置监控系统
- [ ] 设置告警规则
- [ ] 准备回滚方案
- [ ] 文档更新

---

*实施指南更新日期: 2025-01-08*  
*版本: v1.0*  
*状态: 待实施*
