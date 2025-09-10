import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/models/order_models.dart';

/// 餐饮购物车组件
/// 
/// 基于通用模型系统构建的购物车组件
/// 支持商品数量修改、删除、备注编辑等功能
class FoodCartWidget extends StatefulWidget {
  final RxList<OrderItemRequest> cartItems;
  final Function(String, int, Map<String, dynamic>?) onUpdateQuantity;
  final Function(String, Map<String, dynamic>?) onRemoveItem;
  final Function(String) onUpdateNotes;
  final VoidCallback onProceedToCheckout;

  const FoodCartWidget({
    super.key,
    required this.cartItems,
    required this.onUpdateQuantity,
    required this.onRemoveItem,
    required this.onUpdateNotes,
    required this.onProceedToCheckout,
  });

  @override
  State<FoodCartWidget> createState() => _FoodCartWidgetState();
}

class _FoodCartWidgetState extends State<FoodCartWidget> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.cartItems.isEmpty) {
        return _buildEmptyCart();
      }

      return Column(
        children: [
          // 购物车商品列表
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 购物车标题
                _buildCartHeader(),
                
                const SizedBox(height: 16),
                
                // 商品列表
                ...widget.cartItems.map((item) => _buildCartItem(item)),
                
                const SizedBox(height: 16),
                
                // 备注区域
                _buildNotesSection(),
                
                const SizedBox(height: 16),
                
                // 价格汇总
                _buildPriceSummary(),
                
                const SizedBox(height: 100), // 为底部按钮留空间
              ],
            ),
          ),
          
          // 底部结算按钮
          _buildCheckoutButton(),
        ],
      );
    });
  }

  /// 空购物车界面
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
            '购物车是空的',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '快去添加一些美食吧！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // 跳转到菜单页面
              DefaultTabController.of(context)?.animateTo(0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('浏览菜单'),
          ),
        ],
      ),
    );
  }

  /// 购物车标题
  Widget _buildCartHeader() {
    final itemCount = widget.cartItems.length;
    final totalQuantity = widget.cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
    
    return Row(
      children: [
        const Icon(Icons.shopping_cart, color: Colors.orange),
        const SizedBox(width: 8),
        Text(
          '购物车 ($itemCount种商品，共$totalQuantity件)',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: _showClearCartDialog,
          child: const Text(
            '清空',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  /// 购物车商品项
  Widget _buildCartItem(OrderItemRequest item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 商品信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '单价: \$${item.unitPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 删除按钮
                IconButton(
                  onPressed: () => _showRemoveItemDialog(item),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 定制选项（如果有）
            if (item.customizations.isNotEmpty) ...[
              _buildCustomizations(item.customizations),
              const SizedBox(height: 12),
            ],
            
            // 数量控制和小计
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 数量控制
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: item.quantity > 1
                            ? () => widget.onUpdateQuantity(
                                item.serviceDetailId,
                                item.quantity - 1,
                                item.customizations,
                              )
                            : null,
                        icon: const Icon(Icons.remove),
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => widget.onUpdateQuantity(
                          item.serviceDetailId,
                          item.quantity + 1,
                          item.customizations,
                        ),
                        icon: const Icon(Icons.add),
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                    ],
                  ),
                ),
                
                // 小计
                Text(
                  '小计: \$${item.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 定制选项显示
  Widget _buildCustomizations(Map<String, dynamic> customizations) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '定制选择:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          ...customizations.entries.map(
            (entry) => Text(
              '${entry.key}: ${entry.value}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// 备注区域
  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.note_add, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  '订单备注',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              onChanged: widget.onUpdateNotes,
              decoration: const InputDecoration(
                hintText: '有什么特殊要求吗？例如：不要香菜、多加辣...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
          ],
        ),
      ),
    );
  }

  /// 价格汇总
  Widget _buildPriceSummary() {
    final subtotal = widget.cartItems.fold<double>(0, (sum, item) => sum + item.totalPrice);
    final itemCount = widget.cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('商品小计'),
                Text('\$${subtotal.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('共 $itemCount 件商品'),
                const Text('配送费待计算'),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '小计',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '最终价格以结算页面为准',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 底部结算按钮
  Widget _buildCheckoutButton() {
    final subtotal = widget.cartItems.fold<double>(0, (sum, item) => sum + item.totalPrice);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.cartItems.isNotEmpty ? widget.onProceedToCheckout : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Text('去结算 (\$${subtotal.toStringAsFixed(2)})'),
          ),
        ),
      ),
    );
  }

  /// 显示删除商品确认对话框
  void _showRemoveItemDialog(OrderItemRequest item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要从购物车中删除"${item.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              widget.onRemoveItem(item.serviceDetailId, item.customizations);
              Navigator.of(context).pop();
              Get.snackbar(
                '已删除',
                '${item.name} 已从购物车中删除',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 显示清空购物车确认对话框
  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空购物车中的所有商品吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 删除所有商品
              final itemsToRemove = List<OrderItemRequest>.from(widget.cartItems);
              for (final item in itemsToRemove) {
                widget.onRemoveItem(item.serviceDetailId, item.customizations);
              }
              Navigator.of(context).pop();
              Get.snackbar(
                '已清空',
                '购物车已清空',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }
}
