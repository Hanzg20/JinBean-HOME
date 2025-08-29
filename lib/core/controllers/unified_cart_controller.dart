import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/customer/domain/entities/service.dart';
import '../../features/customer/domain/entities/service_detail.dart';
import '../models/cart_models.dart';
import '../services/service_booking_type_resolver.dart';
import '../utils/app_logger.dart';

/// 统一购物车控制器
/// 管理所有类型服务的购物车操作，包括餐饮和预约服务
class UnifiedCartController extends GetxController {
  // Supabase客户端
  final SupabaseClient _supabase = Supabase.instance.client;

  // 响应式状态
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxDouble totalAmount = 0.0.obs;
  final RxInt totalItems = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // 购物车分组（按服务分组）
  final RxMap<String, List<CartItem>> groupedItems =
      <String, List<CartItem>>{}.obs;

  // 当前用户ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('[UnifiedCartController] Initializing...');

    // 加载用户的购物车数据
    if (currentUserId != null) {
      _loadCartFromDatabase();
    }

    // 监听cartItems变化，自动更新统计信息
    ever(cartItems, (_) => _updateTotals());

    // 监听用户登录状态变化
    _supabase.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      if (user != null && user.id != currentUserId) {
        AppLogger.info('[UnifiedCartController] User changed, reloading cart');
        _loadCartFromDatabase();
      } else if (user == null) {
        AppLogger.info(
            '[UnifiedCartController] User logged out, clearing cart');
        _clearLocalCart();
      }
    });
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

      // 减少详细日志输出

      // 验证用户登录状态
      if (currentUserId == null) {
        throw CartException('用户未登录，无法添加到购物车');
      }

      // 获取服务和服务详情信息
      final service = await _getServiceInfo(serviceId);
      final serviceDetail = await _getServiceDetailInfo(serviceDetailId);

      // 验证服务是否支持购物车
      final bookingType = ServiceBookingTypeResolver.resolve(service);
      if (!bookingType.supportsCart) {
        throw CartException('该服务不支持购物车，请直接预订');
      }

      // 确定购物车类型
      final cartType = _determineCartType(service);

      // 检查是否已存在相同配置的商品
      final existingItemIndex = _findExistingItem(
          serviceDetailId, customizations ?? {}, scheduledTime);

      if (existingItemIndex >= 0) {
        // 更新现有商品数量
        await _updateItemQuantity(cartItems[existingItemIndex].id,
            cartItems[existingItemIndex].quantity + quantity);
      } else {
        // 创建新的购物车项目
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
          itemNameSnapshot: _getServiceDetailName(serviceDetail),
          itemDescriptionSnapshot: serviceDetail.getDescription('zh'),
          itemImageSnapshot: _getServiceDetailImage(serviceDetail),
          providerNameSnapshot: await _getProviderName(service.providerId),
          addedAt: DateTime.now(),
        );

        // 添加到本地列表
        cartItems.add(cartItem);

        // 立即触发UI更新 - 修复卡顿问题
        cartItems.refresh();
        // UI 更新日志减少

        // 持久化到数据库
        await _persistCartItem(cartItem, cartType);

        // 记录操作日志
        await _logCartOperation('add', cartItem);

        // 确保状态完全同步 - 添加额外的UI刷新
        WidgetsBinding.instance.addPostFrameCallback((_) {
          cartItems.refresh();
          AppLogger.info('[Cart] 🔄 Post-frame UI refresh completed');
        });
      }

      _showAddToCartFeedback(_getServiceTitle(service));
    } catch (e) {
      AppLogger.error('[Cart] Failed to add service to cart: $e');
      error.value = '添加到购物车失败: ${e.toString()}';
      _showErrorFeedback();
      rethrow;
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

        // 从本地列表移除
        cartItems.removeAt(itemIndex);

        // 立即触发UI更新 - 修复卡顿问题
        cartItems.refresh();
        AppLogger.info(
            '[Cart] 🔄 Triggered immediate UI refresh after removing item');

        // 从数据库删除
        await _removeCartItemFromDatabase(itemId);

        // 记录操作日志
        await _logCartOperation('remove', item);

        // 确保状态完全同步
        WidgetsBinding.instance.addPostFrameCallback((_) {
          cartItems.refresh();
          AppLogger.info(
              '[Cart] 🔄 Post-frame UI refresh completed for item removal');
        });

        Get.snackbar(
          '已移除',
          '${_getItemDisplayName(item)} 已从购物车移除',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      AppLogger.error('[Cart] Failed to remove cart item: $e');
      error.value = '移除商品失败';
    }
  }

  /// 更新商品数量
  Future<void> updateItemQuantity(String itemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeCartItem(itemId);
        return;
      }

      await _updateItemQuantity(itemId, newQuantity);
    } catch (e) {
      AppLogger.error('[Cart] Failed to update item quantity: $e');
      error.value = '更新数量失败';
    }
  }

  /// 私有方法：更新商品数量
  Future<void> _updateItemQuantity(String itemId, int newQuantity) async {
    final itemIndex = cartItems.indexWhere((item) => item.id == itemId);
    if (itemIndex >= 0) {
      final oldItem = cartItems[itemIndex];
      final newItem = oldItem.copyWith(
        quantity: newQuantity,
        updatedAt: DateTime.now(),
      );

      // 更新本地列表
      cartItems[itemIndex] = newItem;

      // 立即触发UI更新 - 修复卡顿问题
      cartItems.refresh();
      AppLogger.info(
          '[Cart] 🔄 Triggered immediate UI refresh after updating quantity');

      // 更新数据库
      await _updateCartItemInDatabase(newItem);

      // 记录操作日志
      await _logCartOperation('update_quantity', newItem, oldItem.toJson());

      // 确保状态完全同步
      WidgetsBinding.instance.addPostFrameCallback((_) {
        cartItems.refresh();
        AppLogger.info(
            '[Cart] 🔄 Post-frame UI refresh completed for quantity update');
      });
    }
  }

  /// 更新商品定制选项
  Future<void> updateItemCustomizations(
    String itemId,
    Map<String, dynamic> customizations,
  ) async {
    try {
      final itemIndex = cartItems.indexWhere((item) => item.id == itemId);
      if (itemIndex >= 0) {
        final oldItem = cartItems[itemIndex];
        final newItem = oldItem.copyWith(
          customizations: customizations,
          updatedAt: DateTime.now(),
        );

        // 更新本地列表
        cartItems[itemIndex] = newItem;

        // 更新数据库
        await _updateCartItemInDatabase(newItem);

        // 记录操作日志
        await _logCartOperation(
            'update_customization', newItem, oldItem.toJson());
      }
    } catch (e) {
      AppLogger.error('[Cart] Failed to update item customizations: $e');
      error.value = '更新定制选项失败';
    }
  }

  /// 清空购物车
  Future<void> clearCart() async {
    try {
      isLoading.value = true;

      // 记录操作日志
      for (final item in cartItems) {
        await _logCartOperation('remove', item);
      }

      // 清空数据库
      await _clearCartInDatabase();

      // 清空本地
      cartItems.clear();

      Get.snackbar(
        '购物车已清空',
        '所有商品已从购物车移除',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      AppLogger.error('[Cart] Failed to clear cart: $e');
      error.value = '清空购物车失败';
    } finally {
      isLoading.value = false;
    }
  }

  /// 移除特定服务的所有商品
  Future<void> removeServiceItems(String serviceId) async {
    try {
      final itemsToRemove =
          cartItems.where((item) => item.serviceId == serviceId).toList();

      for (final item in itemsToRemove) {
        await removeCartItem(item.id);
      }

      Get.snackbar(
        '已移除',
        '该服务商的所有商品已移除',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      AppLogger.error('[Cart] Failed to remove service items: $e');
      error.value = '移除服务商品失败';
    }
  }

  /// 创建订单
  Future<List<Order>> createOrdersFromCart() async {
    try {
      isLoading.value = true;
      error.value = '';

      if (cartItems.isEmpty) {
        throw CartException('购物车为空，无法创建订单');
      }

      AppLogger.info(
          '[Cart] Creating orders from cart with ${cartItems.length} items');

      // 按服务分组
      final serviceGroups = _groupItemsByService();
      final orders = <Order>[];

      // 为每个服务组创建订单
      for (final serviceGroup in serviceGroups.entries) {
        final order = await _createOrderForServiceGroup(
            serviceGroup.key, serviceGroup.value);
        orders.add(order);
      }

      // 记录转换日志
      await _logCartOperation('convert_to_order', null, {
        'orders_created': orders.length,
        'total_items': cartItems.length,
      });

      // 清空购物车
      await clearCart();

      AppLogger.info(
          '[Cart] Successfully created ${orders.length} orders from cart');
      return orders;
    } catch (e) {
      AppLogger.error('[Cart] Failed to create orders: $e');
      error.value = '创建订单失败: ${e.toString()}';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// 获取服务类型的预订模式
  ServiceBookingType getBookingType(Service service) {
    return ServiceBookingTypeResolver.resolve(service);
  }

  /// 获取购物车配置
  CartConfig getCartConfig(Service service) {
    return ServiceBookingTypeResolver.getCartConfig(service);
  }

  /// 检查商品是否可以添加到购物车
  bool canAddToCart(Service service) {
    final bookingType = getBookingType(service);
    return bookingType.supportsCart;
  }

  /// 获取购物车统计信息
  Map<String, dynamic> getCartStatistics() {
    final stats = <String, dynamic>{
      'total_items': totalItems.value,
      'total_amount': totalAmount.value,
      'unique_services': groupedItems.length,
      'restaurant_items':
          cartItems.where((item) => item.itemType == 'menu_item').length,
      'appointment_items':
          cartItems.where((item) => item.itemType == 'appointment').length,
      'package_items':
          cartItems.where((item) => item.itemType == 'package').length,
    };

    return stats;
  }

  // ===== 私有方法 =====

  /// 更新总计信息
  void _updateTotals() {
    totalItems.value = cartItems.fold(0, (sum, item) => sum + item.quantity);
    totalAmount.value = cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
    _updateGroupedItems();
  }

  /// 更新分组信息
  void _updateGroupedItems() {
    final grouped = <String, List<CartItem>>{};
    for (final item in cartItems) {
      grouped.putIfAbsent(item.serviceId, () => []).add(item);
    }
    groupedItems.value = grouped;
  }

  /// 确定购物车类型
  String _determineCartType(Service service) {
    final categoryId = service.categoryLevel1Id;

    switch (categoryId) {
      case '1010000': // 美食天地
        return 'restaurant';
      default:
        return 'appointment';
    }
  }

  /// 获取商品类型
  String _getItemType(Service service) {
    final categoryId = service.categoryLevel1Id;

    switch (categoryId) {
      case '1010000': // 美食天地
        return 'menu_item';
      default:
        return 'appointment';
    }
  }

  /// 查找已存在的商品
  int _findExistingItem(
    String serviceDetailId,
    Map<String, dynamic> customizations,
    DateTime? scheduledTime,
  ) {
    return cartItems.indexWhere((item) =>
        item.serviceDetailId == serviceDetailId &&
        _customizationsEqual(item.customizations, customizations) &&
        _timesEqual(item.scheduledStartTime, scheduledTime));
  }

  /// 比较定制选项是否相等
  bool _customizationsEqual(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    if (a.length != b.length) return false;

    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }

  /// 比较时间是否相等
  bool _timesEqual(DateTime? a, DateTime? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.isAtSameMomentAs(b);
  }

  /// 生成购物车商品ID
  String _generateCartItemId() {
    return const Uuid().v4();
  }

  /// 按服务分组商品
  Map<String, List<CartItem>> _groupItemsByService() {
    final grouped = <String, List<CartItem>>{};
    for (final item in cartItems) {
      grouped.putIfAbsent(item.serviceId, () => []).add(item);
    }
    return grouped;
  }

  /// 显示添加成功反馈
  void _showAddToCartFeedback(String serviceName) {
    Get.snackbar(
      '已添加到购物车',
      serviceName,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
      icon: Icon(Icons.shopping_cart, color: Colors.white),
    );
  }

  /// 显示错误反馈
  void _showErrorFeedback() {
    Get.snackbar(
      '操作失败',
      '请稍后重试',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: Icon(Icons.error, color: Colors.white),
    );
  }

  /// 清空本地购物车
  void _clearLocalCart() {
    cartItems.clear();
    error.value = '';
  }

  // ===== 数据库操作方法 =====

  /// 从数据库加载购物车
  Future<void> _loadCartFromDatabase() async {
    try {
      if (currentUserId == null) return;

      AppLogger.info(
          '[Cart] Loading cart from database for user: $currentUserId');

      // 查询用户的活跃购物车
      final cartResponse = await _supabase
          .from('unified_carts')
          .select('id, cart_type, status')
          .eq('user_id', currentUserId!)
          .eq('status', 'active')
          .maybeSingle();

      if (cartResponse == null) {
        AppLogger.info('[Cart] No active cart found');
        return;
      }

      final cartId = cartResponse['id'] as String;

      // 查询购物车项目
      final itemsResponse = await _supabase
          .from('cart_items')
          .select('*')
          .eq('cart_id', cartId)
          .order('added_at');

      // 转换为CartItem对象
      final items =
          itemsResponse.map((item) => CartItem.fromJson(item)).toList();

      // 更新本地状态
      cartItems.value = items;

      AppLogger.info('[Cart] Loaded ${items.length} items from database');
    } catch (e) {
      AppLogger.error('[Cart] Failed to load cart from database: $e');
    }
  }

  /// 持久化购物车项目
  Future<void> _persistCartItem(CartItem item, String cartType) async {
    try {
      if (currentUserId == null) return;

      // 获取或创建购物车
      final cartId = await _getOrCreateCart(cartType);

      // 插入购物车项目
      await _supabase.from('cart_items').insert({
        'id': item.id,
        'cart_id': cartId,
        'service_id': item.serviceId,
        'service_detail_id': item.serviceDetailId,
        'item_type': item.itemType,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
        'scheduled_start_time': item.scheduledStartTime?.toIso8601String(),
        'scheduled_end_time': item.scheduledEndTime?.toIso8601String(),
        'customizations': item.customizations,
        'special_instructions': item.specialInstructions,
        'item_name_snapshot': item.itemNameSnapshot,
        'item_description_snapshot': item.itemDescriptionSnapshot,
        'item_image_snapshot': item.itemImageSnapshot,
        'provider_name_snapshot': item.providerNameSnapshot,
        'added_at': item.addedAt.toIso8601String(),
        'updated_at': item.updatedAt?.toIso8601String(),
      });
    } catch (e) {
      AppLogger.error('[Cart] Failed to persist cart item: $e');
      rethrow;
    }
  }

  /// 获取或创建购物车
  Future<String> _getOrCreateCart(String cartType) async {
    // 尝试获取现有的活跃购物车
    final existingCart = await _supabase
        .from('unified_carts')
        .select('id')
        .eq('user_id', currentUserId!)
        .eq('cart_type', cartType)
        .eq('status', 'active')
        .maybeSingle();

    if (existingCart != null) {
      return existingCart['id'] as String;
    }

    // 创建新购物车
    final newCartResponse = await _supabase
        .from('unified_carts')
        .insert({
          'user_id': currentUserId,
          'cart_type': cartType,
          'status': 'active',
          'expires_at':
              DateTime.now().add(Duration(hours: 24)).toIso8601String(),
        })
        .select('id')
        .single();

    return newCartResponse['id'] as String;
  }

  /// 更新数据库中的购物车项目
  Future<void> _updateCartItemInDatabase(CartItem item) async {
    try {
      await _supabase.from('cart_items').update({
        'quantity': item.quantity,
        'customizations': item.customizations,
        'special_instructions': item.specialInstructions,
        'updated_at': item.updatedAt?.toIso8601String(),
      }).eq('id', item.id);
    } catch (e) {
      AppLogger.error('[Cart] Failed to update cart item in database: $e');
      rethrow;
    }
  }

  /// 从数据库删除购物车项目
  Future<void> _removeCartItemFromDatabase(String itemId) async {
    try {
      await _supabase.from('cart_items').delete().eq('id', itemId);
    } catch (e) {
      AppLogger.error('[Cart] Failed to remove cart item from database: $e');
      rethrow;
    }
  }

  /// 清空数据库中的购物车
  Future<void> _clearCartInDatabase() async {
    try {
      if (currentUserId == null) return;

      // 获取用户的所有活跃购物车
      final cartsResponse = await _supabase
          .from('unified_carts')
          .select('id')
          .eq('user_id', currentUserId!)
          .eq('status', 'active');

      // 删除所有购物车项目
      for (final cart in cartsResponse) {
        await _supabase.from('cart_items').delete().eq('cart_id', cart['id']);
      }

      // 将购物车状态设为已清空
      await _supabase
          .from('unified_carts')
          .update({'status': 'expired'})
          .eq('user_id', currentUserId!)
          .eq('status', 'active');
    } catch (e) {
      AppLogger.error('[Cart] Failed to clear cart in database: $e');
      rethrow;
    }
  }

  /// 记录购物车操作日志
  Future<void> _logCartOperation(
    String operationType,
    CartItem? item, [
    Map<String, dynamic>? oldValue,
  ]) async {
    try {
      if (currentUserId == null) return;

      // 暂时禁用数据库日志记录以避免权限问题
      AppLogger.info('[Cart] Operation logged: $operationType');

      // 注释掉有权限问题的日志记录
      /*
      await _supabase.from('cart_operation_logs').insert({
        'user_id': currentUserId,
        'cart_id': const Uuid().v4(), // 生成新的UUID用于日志记录
        'operation_type': operationType,
        'item_id': item?.id,
        'operation_data': item?.toJson(),
        'old_value': oldValue,
        'new_value': item?.toJson(),
      });
      */
    } catch (e) {
      AppLogger.warning('[Cart] Failed to log cart operation: $e');
      // 日志记录失败不应该影响主要功能
    }
  }

  // ===== 辅助方法 =====

  /// 获取服务信息
  Future<Service> _getServiceInfo(String serviceId) async {
    try {
      // 从数据库获取服务信息
      final response = await _supabase
          .from('services')
          .select('*')
          .eq('id', serviceId)
          .single();

      return Service.fromJson(response);
    } catch (e) {
      AppLogger.error('[Cart] Failed to get service info: $e');
      throw CartException('获取服务信息失败');
    }
  }

  /// 获取服务详情信息
  Future<ServiceDetail> _getServiceDetailInfo(String serviceDetailId) async {
    try {
      // 如果是主服务ID，创建一个默认的ServiceDetail
      if (serviceDetailId == 'main_service') {
        return ServiceDetail(
          id: 'main_service',
          serviceId: '',
          name: {'zh': '主服务', 'en': 'Main Service'},
          description: {'zh': '基础服务', 'en': 'Basic Service'},
          category: 'main',
          isAvailable: true,
          price: 0.0,
          currency: 'CAD',
        );
      }

      // 从数据库获取服务详情信息
      final response = await _supabase
          .from('service_details')
          .select('*')
          .eq('id', serviceDetailId)
          .single();

      return ServiceDetail.fromJson(response);
    } catch (e) {
      AppLogger.error('[Cart] Failed to get service detail info: $e');
      throw CartException('获取服务详情失败');
    }
  }

  /// 获取服务商名称
  Future<String?> _getProviderName(String? providerId) async {
    if (providerId == null) return null;

    try {
      final response = await _supabase
          .from('provider_profiles')
          .select('display_name')
          .eq('id', providerId)
          .maybeSingle();

      if (response != null && response['display_name'] != null) {
        final displayName = response['display_name'] as Map<String, dynamic>;
        return displayName['zh'] ?? displayName['en'] ?? 'Unknown Provider';
      }
    } catch (e) {
      AppLogger.warning('[Cart] Failed to get provider name: $e');
    }

    return null;
  }

  /// 获取服务详情名称
  Map<String, String> _getServiceDetailName(ServiceDetail detail) {
    if (detail.name is Map) {
      final nameMap = detail.name as Map<String, dynamic>;
      return nameMap.map((key, value) => MapEntry(key, value.toString()));
    } else if (detail.name is String) {
      return {'zh': detail.name as String};
    } else {
      return {'zh': 'Unknown Service'};
    }
  }

  /// 获取服务详情图片
  String? _getServiceDetailImage(ServiceDetail detail) {
    if (detail.images?.isNotEmpty == true) {
      return detail.images!.first;
    }
    return null;
  }

  /// 获取服务标题
  String _getServiceTitle(Service service) {
    if (service.title is Map) {
      final titleMap = service.title as Map<String, dynamic>;
      return titleMap['zh'] ?? titleMap['en'] ?? 'Unknown Service';
    } else if (service.title is String) {
      return service.title as String;
    } else {
      return 'Unknown Service';
    }
  }

  /// 获取商品显示名称
  String _getItemDisplayName(CartItem item) {
    return item.itemNameSnapshot['zh'] ??
        item.itemNameSnapshot['en'] ??
        'Unknown Item';
  }

  /// 为服务组创建订单
  Future<Order> _createOrderForServiceGroup(
    String serviceId,
    List<CartItem> items,
  ) async {
    // TODO: 实现订单创建逻辑
    // 这里需要集成实际的订单创建服务
    throw UnimplementedError('Order creation not implemented');
  }
}
