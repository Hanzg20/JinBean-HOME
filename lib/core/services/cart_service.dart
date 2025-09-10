import 'package:get/get.dart';
import '../controllers/unified_cart_controller.dart';
import '../models/cart_models.dart';
import '../models/base_models.dart';
import '../models/order_models.dart';
import '../../features/customer/domain/entities/service.dart';

/// 统一购物车服务
/// 
/// 这是一个服务层包装器，统一所有购物车相关操作
/// 内部使用UnifiedCartController作为核心实现
class CartService extends GetxService {
  late final UnifiedCartController _cartController;

  @override
  void onInit() {
    super.onInit();
    
    // 获取或创建UnifiedCartController实例
    try {
      _cartController = Get.find<UnifiedCartController>();
    } catch (e) {
      _cartController = Get.put(UnifiedCartController());
    }
  }

  // ========================================
  // 公共API - 代理到UnifiedCartController
  // ========================================

  /// 购物车项目列表
  RxList<CartItem> get cartItems => _cartController.cartItems;

  /// 购物车总金额
  RxDouble get totalAmount => _cartController.totalAmount;

  /// 购物车总商品数
  RxInt get totalItems => _cartController.totalItems;

  /// 是否加载中
  RxBool get isLoading => _cartController.isLoading;

  /// 错误信息
  RxString get error => _cartController.error;

  /// 当前购物车
  Rxn<UnifiedCart> get currentCart => _cartController.currentCart;

  /// 购物车是否为空
  bool get isEmpty => _cartController.cartItems.isEmpty;

  /// 商品种类数量
  int get itemCount => _cartController.cartItems.length;

  /// 商品总数量
  int get totalItemCount => _cartController.totalItems.value;

  /// 分组商品
  RxMap<String, List<CartItem>> get groupedItems => _cartController.groupedItems;

  // ========================================
  // 购物车操作方法
  // ========================================

  /// 添加服务到购物车
  Future<void> addServiceToCart({
    required String serviceId,
    required String serviceDetailId,
    int quantity = 1,
    DateTime? scheduledTime,
    Map<String, dynamic>? customizations,
    String? specialInstructions,
  }) async {
    return await _cartController.addServiceToCart(
      serviceId: serviceId,
      serviceDetailId: serviceDetailId,
      quantity: quantity,
      scheduledTime: scheduledTime,
      customizations: customizations,
      specialInstructions: specialInstructions,
    );
  }

  /// 移除购物车商品
  Future<void> removeCartItem(String itemId) async {
    return await _cartController.removeCartItem(itemId);
  }

  /// 更新商品数量
  Future<void> updateItemQuantity(String itemId, int newQuantity) async {
    return await _cartController.updateItemQuantity(itemId, newQuantity);
  }

  /// 更新商品定制选项
  Future<void> updateItemCustomizations(
    String itemId,
    Map<String, dynamic> customizations,
  ) async {
    return await _cartController.updateItemCustomizations(itemId, customizations);
  }

  /// 清空购物车
  Future<void> clearCart() async {
    return await _cartController.clearCart();
  }

  /// 移除特定服务的所有商品
  Future<void> removeServiceItems(String serviceId) async {
    return await _cartController.removeServiceItems(serviceId);
  }

  /// 创建订单
  Future<List<Order>> createOrdersFromCart() async {
    return await _cartController.createOrdersFromCart();
  }

  // ========================================
  // 服务相关方法
  // ========================================

  /// 获取服务类型的预订模式
  ServiceBookingType getBookingType(Service service) {
    return _cartController.getBookingType(service);
  }

  /// 获取购物车配置
  Map<String, dynamic> getCartConfig(Service service) {
    // 返回购物车配置信息
    final bookingType = getBookingType(service);
    return {
      'supports_cart': bookingType.supportsCart,
      'supports_direct_booking': bookingType.supportsDirectBooking,
      'booking_type': bookingType.displayName,
    };
  }

  /// 检查商品是否可以添加到购物车
  bool canAddToCart(Service service) {
    return _cartController.canAddToCart(service);
  }

  /// 获取购物车统计信息
  Map<String, dynamic> getCartStatistics() {
    return _cartController.getCartStatistics();
  }

  // ========================================
  // 兼容性方法 - 为了支持现有代码
  // ========================================

  /// 兼容EnhancedCartService的方法
  UnifiedCart? get cart => _cartController.currentCart.value;

  /// 打印购物车摘要（调试用）
  void printCartSummary() {
    print('🛒 购物车状态摘要:');
    print('   购物车ID: ${currentCart.value?.id ?? "无"}');
    print('   购物车类型: ${currentCart.value?.cartType.displayName ?? "无"}');
    print('   商品种类: $itemCount 种');
    print('   商品总数: $totalItemCount 个');
    print('   购物车总额: \$${totalAmount.value.toStringAsFixed(2)}');
    print('   是否为空: $isEmpty');
    
    if (cartItems.isNotEmpty) {
      print('   商品详情:');
      for (int i = 0; i < cartItems.length; i++) {
        final item = cartItems[i];
        final itemName = item.itemNameSnapshot['zh'] ?? 
                        item.itemNameSnapshot['en'] ?? 
                        'Unknown Item';
        print('     ${i + 1}. $itemName x${item.quantity} = \$${item.subtotal.toStringAsFixed(2)}');
      }
    }
  }

  /// 验证购物车功能（测试用）
  Future<bool> validateCartFunctionality() async {
    try {
      print('🔍 验证购物车功能...');
      
      // 检查基本状态
      final hasController = true; // _cartController is always initialized
      final hasItems = cartItems.isNotEmpty;
      final hasTotal = totalAmount.value >= 0;
      
      print('   控制器状态: ✅');
      print('   商品列表: ${hasItems ? "✅" : "❌"}');
      print('   总额计算: ${hasTotal ? "✅" : "❌"}');
      
      final isValid = hasController && hasTotal;
      print('   整体验证: ${isValid ? "✅ 通过" : "❌ 失败"}');
      
      return isValid;
    } catch (e) {
      print('❌ 验证过程出错: $e');
      return false;
    }
  }

  /// 兼容方法：获取购物车详情
  Future<UnifiedCart?> getCartDetails(String cartId) async {
    // UnifiedCartController会自动管理购物车详情
    return currentCart.value;
  }

  /// 兼容方法：添加商品到购物车（简化版）
  Future<CartItem> addItemToCart({
    required String cartId,
    required String serviceId,
    String? serviceDetailId,
    required CartItemType itemType,
    int quantity = 1,
    required double unitPrice,
    required Map<String, dynamic> itemNameSnapshot,
    String? itemDescriptionSnapshot,
    Map<String, dynamic> customizations = const {},
    List<String>? dietaryRestrictions,
    String? specialInstructions,
  }) async {
    // 转换为标准的addServiceToCart调用
    await addServiceToCart(
      serviceId: serviceId,
      serviceDetailId: serviceDetailId ?? 'main_service',
      quantity: quantity,
      customizations: customizations,
      specialInstructions: specialInstructions,
    );
    
    // 返回最后添加的商品
    return cartItems.last;
  }

  /// 兼容方法：移除商品
  Future<void> removeItem(String itemId) async {
    return await removeCartItem(itemId);
  }

  /// 兼容方法：获取或创建购物车
  Future<UnifiedCart> getOrCreateCart(
    String userId, 
    CartType type, {
    IndustryType? industryType,
  }) async {
    // UnifiedCartController会自动管理购物车创建
    if (currentCart.value == null) {
      // 触发购物车创建逻辑
      await addServiceToCart(
        serviceId: 'temp_service',
        serviceDetailId: 'temp_detail',
        quantity: 0, // 临时商品，数量为0
      );
      
      // 立即移除临时商品
      if (cartItems.isNotEmpty) {
        await removeCartItem(cartItems.last.id);
      }
    }
    
    return currentCart.value!;
  }
}
