import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/models/cart_models.dart';
import '../../../../core/models/base_models.dart';

/// 统一购物车功能测试页面
class CartTestPage extends StatelessWidget {
  final CartService cartService = Get.put(CartService());

  CartTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛒 Day 1 - 购物车功能测试'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => cartService.printCartSummary(),
            tooltip: '打印状态摘要',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 16),
            _buildStatusCard(context),
            const SizedBox(height: 16),
            _buildTestButtonsCard(),
            const SizedBox(height: 16),
            _buildCartItemsList(context),
            const SizedBox(height: 16),
            _buildAdvancedTestsCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQuickActions,
        label: const Text('快速操作'),
        icon: const Icon(Icons.flash_on),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rocket_launch, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Day 1 成果验证',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '这个页面验证增强购物车服务的所有核心功能：\n'
              '• 创建和管理购物车\n'
              '• 添加/修改/删除商品\n'
              '• 实时价格计算\n'
              '• 响应式状态更新',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dashboard, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  '实时购物车状态',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
              children: [
                _buildStatusRow('购物车状态', cartService.cart != null ? '已创建' : '未创建'),
                _buildStatusRow('购物车ID', cartService.cart?.id ?? '无'),
                _buildStatusRow('购物车类型', cartService.cart?.cartType.displayName ?? '无'),
                _buildStatusRow('行业类型', cartService.cart?.industryType?.displayName ?? '无'),
                const Divider(),
                _buildStatusRow('商品种类', '${cartService.itemCount} 种', highlight: true),
                _buildStatusRow('商品总数', '${cartService.totalItemCount} 个', highlight: true),
                _buildStatusRow('购物车总额', '\$${cartService.totalAmount.toStringAsFixed(2)}', highlight: true),
                _buildStatusRow('是否为空', cartService.isEmpty ? '是' : '否'),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight ? Colors.blue.shade700 : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: highlight ? Colors.green.shade700 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButtonsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🧪 基础功能测试',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTestButton('1️⃣ 创建购物车', _testCreateCart, Colors.blue),
                _buildTestButton('2️⃣ 添加披萨', _testAddPizza, Colors.green),
                _buildTestButton('3️⃣ 添加沙拉', _testAddSalad, Colors.orange),
                _buildTestButton('4️⃣ 添加饮料', _testAddDrink, Colors.cyan),
                _buildTestButton('5️⃣ 增加数量', _testIncreaseQuantity, Colors.indigo),
                _buildTestButton('6️⃣ 删除商品', _testRemoveItem, Colors.red),
                _buildTestButton('7️⃣ 清空购物车', _testClearCart, Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String text, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildCartItemsList(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  '购物车商品列表',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() => cartService.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('购物车为空', style: TextStyle(color: Colors.grey)),
                          Text('点击上方按钮添加商品', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: cartService.cartItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return _buildCartItemCard(item, index);
                    }).toList(),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item, int index) {
    final itemName = item.itemNameSnapshot['en'] ?? item.itemNameSnapshot['zh'] ?? 'Unknown Item';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text('${index + 1}', style: TextStyle(color: Colors.blue.shade700)),
        ),
        title: Text(
          itemName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('数量: ${item.quantity} | 单价: \$${item.unitPrice.toStringAsFixed(2)}'),
            if (item.customizations.isNotEmpty)
              Text('定制: ${item.customizations.toString()}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${item.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              item.itemType.displayName,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        onTap: () => _showItemActions(item),
      ),
    );
  }

  Widget _buildAdvancedTestsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔬 高级功能测试',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTestButton('📊 打印状态摘要', () => cartService.printCartSummary(), Colors.teal),
                _buildTestButton('✅ 验证功能', _validateFunctionality, Colors.purple),
                _buildTestButton('🎲 随机测试', _randomTest, Colors.amber),
                _buildTestButton('🔄 获取详情', _refreshCartDetails, Colors.brown),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 测试方法
  Future<void> _testCreateCart() async {
    try {
      _showLoading('正在创建购物车...');
      
      final cart = await cartService.getOrCreateCart(
        'test-user-123', 
        CartType.restaurant,
        industryType: IndustryType.food,
      );
      
      Get.back();
      Get.snackbar(
        '✅ 成功',
        '购物车创建成功\nID: ${cart.id}\n类型: ${cart.cartType.displayName}',
        backgroundColor: Colors.green.shade100,
        duration: const Duration(seconds: 3),
      );
      
      cartService.printCartSummary();
    } catch (e) {
      Get.back();
      _showError('创建购物车失败', e.toString());
    }
  }

  Future<void> _testAddPizza() async {
    if (cartService.currentCart.value == null) {
      Get.snackbar('提示', '请先创建购物车', backgroundColor: Colors.yellow.shade100);
      return;
    }

    try {
      _showLoading('正在添加披萨...');
      
      await cartService.addItemToCart(
        cartId: cartService.currentCart.value!.id,
        serviceId: 'pizza-margherita-001',
        itemType: CartItemType.menuItem,
        quantity: 1,
        unitPrice: 18.99,
        itemNameSnapshot: {'en': 'Margherita Pizza', 'zh': '玛格丽特披萨'},
        itemDescriptionSnapshot: 'Classic pizza with tomato sauce, mozzarella, and fresh basil',
        customizations: {'size': 'Large', 'crust': 'Thin', 'extra_cheese': true},
      );
      
      Get.back();
      Get.snackbar('✅ 成功', '玛格丽特披萨已添加到购物车', backgroundColor: Colors.green.shade100);
      cartService.printCartSummary();
    } catch (e) {
      Get.back();
      _showError('添加披萨失败', e.toString());
    }
  }

  Future<void> _testAddSalad() async {
    if (cartService.currentCart.value == null) {
      Get.snackbar('提示', '请先创建购物车', backgroundColor: Colors.yellow.shade100);
      return;
    }

    try {
      _showLoading('正在添加沙拉...');
      
      await cartService.addItemToCart(
        cartId: cartService.currentCart.value!.id,
        serviceId: 'salad-caesar-002',
        itemType: CartItemType.menuItem,
        quantity: 2,
        unitPrice: 12.99,
        itemNameSnapshot: {'en': 'Caesar Salad', 'zh': '凯撒沙拉'},
        itemDescriptionSnapshot: 'Crisp romaine lettuce with parmesan cheese and Caesar dressing',
        customizations: {'dressing': 'on_side', 'croutons': true},
        dietaryRestrictions: ['vegetarian'],
      );
      
      Get.back();
      Get.snackbar('✅ 成功', '凯撒沙拉已添加到购物车（2份）', backgroundColor: Colors.green.shade100);
      cartService.printCartSummary();
    } catch (e) {
      Get.back();
      _showError('添加沙拉失败', e.toString());
    }
  }

  Future<void> _testAddDrink() async {
    if (cartService.currentCart.value == null) {
      Get.snackbar('提示', '请先创建购物车', backgroundColor: Colors.yellow.shade100);
      return;
    }

    try {
      _showLoading('正在添加饮料...');
      
      await cartService.addItemToCart(
        cartId: cartService.currentCart.value!.id,
        serviceId: 'drink-coke-003',
        itemType: CartItemType.menuItem,
        quantity: 3,
        unitPrice: 2.99,
        itemNameSnapshot: {'en': 'Coca Cola', 'zh': '可口可乐'},
        itemDescriptionSnapshot: 'Classic Coca Cola 355ml can',
        customizations: {'size': '355ml', 'ice': false},
      );
      
      Get.back();
      Get.snackbar('✅ 成功', '可口可乐已添加到购物车（3瓶）', backgroundColor: Colors.green.shade100);
      cartService.printCartSummary();
    } catch (e) {
      Get.back();
      _showError('添加饮料失败', e.toString());
    }
  }

  Future<void> _testIncreaseQuantity() async {
    if (cartService.cartItems.isEmpty) {
      Get.snackbar('提示', '购物车中没有商品', backgroundColor: Colors.yellow.shade100);
      return;
    }

    try {
      _showLoading('正在更新数量...');
      
      final firstItem = cartService.cartItems.first;
      await cartService.updateItemQuantity(firstItem.id, firstItem.quantity + 1);
      
      Get.back();
      Get.snackbar('✅ 成功', '商品数量已增加', backgroundColor: Colors.green.shade100);
      cartService.printCartSummary();
    } catch (e) {
      Get.back();
      _showError('更新数量失败', e.toString());
    }
  }

  Future<void> _testRemoveItem() async {
    if (cartService.cartItems.isEmpty) {
      Get.snackbar('提示', '购物车中没有商品', backgroundColor: Colors.yellow.shade100);
      return;
    }

    try {
      _showLoading('正在删除商品...');
      
      final lastItem = cartService.cartItems.last;
      final itemName = lastItem.itemNameSnapshot['en'] ?? '商品';
      await cartService.removeItem(lastItem.id);
      
      Get.back();
      Get.snackbar('✅ 成功', '$itemName 已从购物车删除', backgroundColor: Colors.green.shade100);
      cartService.printCartSummary();
    } catch (e) {
      Get.back();
      _showError('删除商品失败', e.toString());
    }
  }

  Future<void> _testClearCart() async {
    if (cartService.currentCart.value == null) {
      Get.snackbar('提示', '没有购物车可清空', backgroundColor: Colors.yellow.shade100);
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空整个购物车吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('清空', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        _showLoading('正在清空购物车...');
        
        await cartService.clearCart();
        
        Get.back();
        Get.snackbar('✅ 成功', '购物车已清空', backgroundColor: Colors.green.shade100);
        cartService.printCartSummary();
      } catch (e) {
        Get.back();
        _showError('清空购物车失败', e.toString());
      }
    }
  }

  Future<void> _validateFunctionality() async {
    try {
      _showLoading('正在验证功能...');
      
      final isValid = await cartService.validateCartFunctionality();
      
      Get.back();
      
      if (isValid) {
        Get.snackbar(
          '🎉 验证通过',
          'Day 1 购物车服务功能验证成功！\n所有核心功能正常工作。',
          backgroundColor: Colors.green.shade100,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          '❌ 验证失败',
          '部分功能存在问题，请检查日志。',
          backgroundColor: Colors.red.shade100,
        );
      }
    } catch (e) {
      Get.back();
      _showError('验证过程出错', e.toString());
    }
  }

  Future<void> _randomTest() async {
    final random = DateTime.now().millisecond % 3;
    switch (random) {
      case 0:
        await _testAddPizza();
        break;
      case 1:
        await _testAddSalad();
        break;
      case 2:
        await _testAddDrink();
        break;
    }
  }

  Future<void> _refreshCartDetails() async {
    if (cartService.currentCart.value == null) {
      Get.snackbar('提示', '没有购物车可刷新', backgroundColor: Colors.yellow.shade100);
      return;
    }

    try {
      _showLoading('正在刷新购物车详情...');
      
      await cartService.getCartDetails(cartService.currentCart.value!.id);
      
      Get.back();
      Get.snackbar('✅ 成功', '购物车详情已刷新', backgroundColor: Colors.green.shade100);
      cartService.printCartSummary();
    } catch (e) {
      Get.back();
      _showError('刷新详情失败', e.toString());
    }
  }

  void _showLoading(String message) {
    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showError(String title, String message) {
    Get.snackbar(
      '❌ $title',
      message,
      backgroundColor: Colors.red.shade100,
      duration: const Duration(seconds: 4),
    );
  }

  void _showItemActions(CartItem item) {
    final itemName = item.itemNameSnapshot['en'] ?? '商品';
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              itemName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('增加数量'),
              onTap: () {
                Get.back();
                cartService.updateItemQuantity(item.id, item.quantity + 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove),
              title: const Text('减少数量'),
              onTap: () {
                Get.back();
                cartService.updateItemQuantity(item.id, item.quantity - 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除商品', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                cartService.removeItem(item.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickActions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '⚡ 快速操作',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add_shopping_cart),
              title: const Text('快速添加套餐'),
              onTap: () {
                Get.back();
                _quickAddCombo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('打印状态摘要'),
              onTap: () {
                Get.back();
                cartService.printCartSummary();
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('刷新购物车'),
              onTap: () {
                Get.back();
                _refreshCartDetails();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _quickAddCombo() async {
    if (cartService.currentCart.value == null) {
      await _testCreateCart();
    }
    
    await _testAddPizza();
    await Future.delayed(const Duration(milliseconds: 500));
    await _testAddSalad();
    await Future.delayed(const Duration(milliseconds: 500));
    await _testAddDrink();
  }
}
