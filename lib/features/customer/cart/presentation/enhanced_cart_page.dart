import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/controllers/unified_cart_controller.dart';
import '../../../../core/models/cart_models.dart';

/// 增强的购物车页面
/// 支持商品合并、数量编辑、删除等功能
class EnhancedCartPage extends StatelessWidget {
  const EnhancedCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<UnifiedCartController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('购物车'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            if (cartController.cartItems.isNotEmpty) {
              return TextButton(
                onPressed: () => _showClearCartDialog(context, cartController),
                child: const Text(
                  '清空',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (cartController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cartController.cartItems.isEmpty) {
          return _buildEmptyCart();
        }

        return Column(
          children: [
            // 购物车商品列表
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cartController.cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartController.cartItems[index];
                  return _buildCartItemCard(context, item, cartController);
                },
              ),
            ),

            // 底部结算区域
            _buildCheckoutSection(context, cartController),
          ],
        );
      }),
    );
  }

  /// 构建空购物车状态
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
          const SizedBox(height: 16),
          Text(
            '购物车为空',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '快去添加一些商品吧！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('继续购物'),
          ),
        ],
      ),
    );
  }

  /// 构建购物车商品卡片
  Widget _buildCartItemCard(
      BuildContext context, CartItem item, UnifiedCartController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 商品图片
            _buildItemImage(item),

            const SizedBox(width: 12),

            // 商品信息
            Expanded(
              child: _buildItemInfo(item),
            ),

            const SizedBox(width: 12),

            // 数量控制和删除
            _buildItemControls(context, item, controller),
          ],
        ),
      ),
    );
  }

  /// 构建商品图片
  Widget _buildItemImage(CartItem item) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child:
          item.itemImageSnapshot != null && item.itemImageSnapshot!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.itemImageSnapshot!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholderImage(),
                  ),
                )
              : _buildPlaceholderImage(),
    );
  }

  /// 构建占位图片
  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.restaurant,
        color: Colors.grey[400],
        size: 30,
      ),
    );
  }

  /// 构建商品信息
  Widget _buildItemInfo(CartItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 商品名称
        Text(
                          item.itemNameSnapshot?['zh'] ?? item.itemNameSnapshot?['en'] ?? '未知商品',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // 商品描述
        if (item.itemDescriptionSnapshot != null &&
            item.itemDescriptionSnapshot!.isNotEmpty)
          Text(
            item.itemDescriptionSnapshot!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

        const SizedBox(height: 8),

        // 服务商名称
        if (item.providerNameSnapshot != null &&
            item.providerNameSnapshot!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item.providerNameSnapshot!,
              style: TextStyle(
                fontSize: 10,
                color: Colors.blue[700],
              ),
            ),
          ),

        const SizedBox(height: 8),

        // 单价
        Text(
          '¥${item.unitPrice.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.green[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 构建商品控制区域（数量编辑和删除）
  Widget _buildItemControls(
      BuildContext context, CartItem item, UnifiedCartController controller) {
    return Column(
      children: [
        // 删除按钮
        IconButton(
          onPressed: () => _showDeleteItemDialog(context, item, controller),
          icon: const Icon(Icons.delete_outline),
          color: Colors.red[400],
          iconSize: 20,
        ),

        const SizedBox(height: 8),

        // 数量控制
        _buildQuantityControls(item, controller),

        const SizedBox(height: 8),

        // 小计
        Text(
          '¥${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 构建数量控制器
  Widget _buildQuantityControls(
      CartItem item, UnifiedCartController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 减少按钮
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              onTap: () => _updateQuantity(item, item.quantity - 1, controller),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color:
                      item.quantity <= 1 ? Colors.grey[200] : Colors.blue[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: Icon(
                  Icons.remove,
                  size: 16,
                  color:
                      item.quantity <= 1 ? Colors.grey[400] : Colors.blue[600],
                ),
              ),
            ),
          ),

          // 数量显示
          Container(
            width: 40,
            height: 32,
            alignment: Alignment.center,
            child: Text(
              '${item.quantity}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // 增加按钮
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              onTap: () => _updateQuantity(item, item.quantity + 1, controller),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: Colors.green[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建结算区域
  Widget _buildCheckoutSection(
      BuildContext context, UnifiedCartController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 总计信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '共 ${controller.totalItems.value} 件商品',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '总计：¥${controller.totalAmount.value.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 结算按钮
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: controller.cartItems.isNotEmpty
                  ? () => _handleCheckout(context, controller)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                '去结算',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 更新商品数量
  void _updateQuantity(
      CartItem item, int newQuantity, UnifiedCartController controller) {
    if (newQuantity <= 0) {
      _showDeleteItemDialog(Get.context!, item, controller);
    } else {
      controller.updateItemQuantity(item.id, newQuantity);
    }
  }

  /// 显示删除商品确认对话框
  void _showDeleteItemDialog(
      BuildContext context, CartItem item, UnifiedCartController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text(
            '确定要删除 "${item.itemNameSnapshot?['zh'] ?? item.itemNameSnapshot?['en'] ?? '该商品'}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.removeCartItem(item.id);
              Get.snackbar(
                '已删除',
                '商品已从购物车中移除',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
            child: const Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示清空购物车确认对话框
  void _showClearCartDialog(
      BuildContext context, UnifiedCartController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空整个购物车吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.clearCart();
              Get.snackbar(
                '已清空',
                '购物车已清空',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
            child: const Text(
              '清空',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// 处理结算
  void _handleCheckout(BuildContext context, UnifiedCartController controller) {
    if (controller.cartItems.isEmpty) {
      Get.snackbar(
        '购物车为空',
        '请先添加商品到购物车',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // 检查购物车数据完整性
    bool hasInvalidItems = controller.cartItems.any((item) => 
        item.itemNameSnapshot.isEmpty || 
        item.unitPrice <= 0 ||
        item.quantity <= 0
    );

    if (hasInvalidItems) {
      Get.snackbar(
        '数据异常',
        '购物车中存在异常数据，请重新添加商品',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // 导航到结算页面
    try {
      // 计算小计和税费
      final subtotal = controller.totalAmount.value;
      final taxRate = 0.13; // 13% HST (Ontario)
      final taxAmount = subtotal * taxRate;
      final finalTotal = subtotal + taxAmount;
      
      Get.toNamed('/checkout', arguments: {
        'cartItems': controller.cartItems.toList(),
        'totalAmount': finalTotal,
        'subtotal': subtotal,
        'taxAmount': taxAmount,
      });
    } catch (e) {
      // 如果结算页面不存在，显示开发中提示
      Get.snackbar(
        '功能开发中',
        '结算功能正在开发中，敬请期待！\n\n购物车数据：\n- 商品数量：${controller.cartItems.length}\n- 总金额：\$${controller.totalAmount.value.toStringAsFixed(2)}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }
}
