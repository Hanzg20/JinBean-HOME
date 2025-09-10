import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/models/base_models.dart';
import '../../../../../core/models/order_models.dart';

/// 餐饮菜单组件
/// 
/// 基于通用模型系统构建的菜单展示组件
/// 支持分类浏览、商品详情、添加到购物车等功能
class FoodMenuWidget extends StatefulWidget {
  final String serviceId;
  final String providerId;
  final Function(OrderItemRequest) onAddToCart;
  final Function(String, Map<String, dynamic>?) onRemoveFromCart;
  final RxList<OrderItemRequest> cartItems;

  const FoodMenuWidget({
    super.key,
    required this.serviceId,
    required this.providerId,
    required this.onAddToCart,
    required this.onRemoveFromCart,
    required this.cartItems,
  });

  @override
  State<FoodMenuWidget> createState() => _FoodMenuWidgetState();
}

class _FoodMenuWidgetState extends State<FoodMenuWidget> {
  final _supabase = Supabase.instance.client;
  
  final RxList<MenuCategory> categories = <MenuCategory>[].obs;
  final RxList<MenuItem> allMenuItems = <MenuItem>[].obs;
  final RxList<MenuItem> filteredMenuItems = <MenuItem>[].obs;
  final Rx<MenuCategory?> selectedCategory = Rx<MenuCategory?>(null);
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadMenuData();
  }

  /// 加载菜单数据
  Future<void> _loadMenuData() async {
    try {
      isLoading.value = true;

      // 加载菜单分类
      await _loadCategories();
      
      // 加载菜单项目
      await _loadMenuItems();

      // 设置默认选中第一个分类
      if (categories.isNotEmpty) {
        selectedCategory.value = categories.first;
        _filterItemsByCategory(categories.first);
      }

    } catch (e) {
      print('❌ 加载菜单数据失败: $e');
      Get.snackbar('错误', '加载菜单失败');
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载菜单分类
  Future<void> _loadCategories() async {
    final response = await _supabase
        .from('ref_codes')
        .select('code, name_en, name_zh, display_order')
        .eq('parent_code', 'food_categories')
        .eq('is_active', true)
        .order('display_order', ascending: true);

    categories.clear();
    for (final data in response) {
      categories.add(MenuCategory.fromJson(data));
    }
  }

  /// 加载菜单项目
  Future<void> _loadMenuItems() async {
    final response = await _supabase
        .from('service_details')
        .select('''
          id,
          name_en,
          name_zh,
          description_en,
          description_zh,
          base_price,
          currency,
          category,
          image_url,
          is_available,
          tags,
          options,
          nutritional_info,
          allergens
        ''')
        .eq('service_id', widget.serviceId)
        .eq('is_available', true)
        .order('display_order', ascending: true);

    allMenuItems.clear();
    for (final data in response) {
      allMenuItems.add(MenuItem.fromJson(data));
    }
  }

  /// 按分类过滤菜单项目
  void _filterItemsByCategory(MenuCategory category) {
    filteredMenuItems.clear();
    
    final categoryItems = allMenuItems.where((item) => 
        item.category == category.code).toList();
    
    // 如果有搜索查询，进一步过滤
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filteredMenuItems.addAll(categoryItems.where((item) =>
          item.name.chinese.toLowerCase().contains(query) ||
          item.name.english.toLowerCase().contains(query) ||
          item.description?.chinese.toLowerCase().contains(query) == true ||
          item.description?.english.toLowerCase().contains(query) == true));
    } else {
      filteredMenuItems.addAll(categoryItems);
    }
  }

  /// 搜索菜单项目
  void _searchMenuItems(String query) {
    searchQuery.value = query;
    if (selectedCategory.value != null) {
      _filterItemsByCategory(selectedCategory.value!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          // 搜索栏
          _buildSearchBar(),
          
          // 分类标签栏
          _buildCategoryTabs(),
          
          // 菜单项目列表
          Expanded(
            child: _buildMenuItemsList(),
          ),
        ],
      );
    });
  }

  /// 搜索栏
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: _searchMenuItems,
        decoration: InputDecoration(
          hintText: '搜索菜品...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchQuery.value = '';
                    if (selectedCategory.value != null) {
                      _filterItemsByCategory(selectedCategory.value!);
                    }
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  /// 分类标签栏
  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory.value?.code == category.code;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category.name.chinese),
              selected: isSelected,
              onSelected: (selected) {
                selectedCategory.value = category;
                _filterItemsByCategory(category);
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.orange[200],
              checkmarkColor: Colors.orange[800],
            ),
          );
        },
      ),
    );
  }

  /// 菜单项目列表
  Widget _buildMenuItemsList() {
    if (filteredMenuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              searchQuery.value.isNotEmpty ? '没有找到相关菜品' : '此分类暂无菜品',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredMenuItems.length,
      itemBuilder: (context, index) {
        final item = filteredMenuItems[index];
        return _buildMenuItemCard(item);
      },
    );
  }

  /// 菜单项目卡片
  Widget _buildMenuItemCard(MenuItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showItemDetailDialog(item),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 商品图片
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                        item.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
              ),
              
              const SizedBox(width: 12),
              
              // 商品信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 商品名称
                    Text(
                      item.name.chinese,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    if (item.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description!.chinese,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const SizedBox(height: 8),
                    
                    // 标签
                    if (item.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: item.tags.take(3).map((tag) =>
                          Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: Colors.blue[100],
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ).toList(),
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // 价格和操作按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.price.formatted,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        
                        Obx(() {
                          final cartQuantity = _getCartQuantity(item.id);
                          
                          if (cartQuantity == 0) {
                            return ElevatedButton(
                              onPressed: () => _addItemToCart(item),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text('加入购物车'),
                            );
                          } else {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => _decreaseQuantity(item),
                                    icon: const Icon(Icons.remove, color: Colors.white),
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  ),
                                  Text(
                                    '$cartQuantity',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _increaseQuantity(item),
                                    icon: const Icon(Icons.add, color: Colors.white),
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  ),
                                ],
                              ),
                            );
                          }
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 占位图片
  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.restaurant,
        color: Colors.grey[500],
        size: 32,
      ),
    );
  }

  /// 显示商品详情对话框
  void _showItemDetailDialog(MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => _MenuItemDetailDialog(
        item: item,
        onAddToCart: _addItemToCart,
      ),
    );
  }

  /// 获取购物车中的数量
  int _getCartQuantity(String itemId) {
    return widget.cartItems
        .where((cartItem) => cartItem.serviceDetailId == itemId)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  /// 添加到购物车
  void _addItemToCart(MenuItem item, {Map<String, dynamic>? customizations}) {
    final orderItem = OrderItemRequest(
      serviceDetailId: item.id,
      name: item.name.chinese,
      description: item.description?.chinese,
      quantity: 1,
      unitPrice: item.price.amount,
      customizations: customizations ?? {},
    );

    widget.onAddToCart(orderItem);
  }

  /// 增加数量
  void _increaseQuantity(MenuItem item) {
    _addItemToCart(item);
  }

  /// 减少数量
  void _decreaseQuantity(MenuItem item) {
    widget.onRemoveFromCart(item.id, null);
  }
}

/// 菜单分类模型
class MenuCategory {
  final String code;
  final MultiLanguageText name;
  final int displayOrder;

  MenuCategory({
    required this.code,
    required this.name,
    required this.displayOrder,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      code: json['code'],
      name: MultiLanguageText({
        'en': json['name_en'] ?? json['code'],
        'zh': json['name_zh'] ?? json['name_en'] ?? json['code'],
      }),
      displayOrder: json['display_order'] ?? 0,
    );
  }
}

/// 菜单项目模型
class MenuItem {
  final String id;
  final MultiLanguageText name;
  final MultiLanguageText? description;
  final Price price;
  final String category;
  final String imageUrl;
  final bool isAvailable;
  final List<String> tags;
  final Map<String, dynamic> options;
  final Map<String, dynamic>? nutritionalInfo;
  final List<String> allergens;

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.isAvailable,
    required this.tags,
    required this.options,
    this.nutritionalInfo,
    required this.allergens,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: MultiLanguageText({
        'en': json['name_en'] ?? '',
        'zh': json['name_zh'] ?? json['name_en'] ?? '',
      }),
      description: json['description_en'] != null || json['description_zh'] != null
          ? MultiLanguageText({
              'en': json['description_en'] ?? '',
              'zh': json['description_zh'] ?? json['description_en'] ?? '',
            })
          : null,
      price: Price(
        amount: (json['base_price'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency'] ?? 'CAD',
      ),
      category: json['category'] ?? '',
      imageUrl: json['image_url'] ?? '',
      isAvailable: json['is_available'] ?? true,
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      options: json['options'] ?? {},
      nutritionalInfo: json['nutritional_info'],
      allergens: (json['allergens'] as List?)?.cast<String>() ?? [],
    );
  }
}

/// 菜单项目详情对话框
class _MenuItemDetailDialog extends StatefulWidget {
  final MenuItem item;
  final Function(MenuItem, {Map<String, dynamic>? customizations}) onAddToCart;

  const _MenuItemDetailDialog({
    required this.item,
    required this.onAddToCart,
  });

  @override
  State<_MenuItemDetailDialog> createState() => _MenuItemDetailDialogState();
}

class _MenuItemDetailDialogState extends State<_MenuItemDetailDialog> {
  final Map<String, dynamic> _customizations = {};
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 商品图片
            if (widget.item.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.network(
                  widget.item.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 商品名称
                    Text(
                      widget.item.name.chinese,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // 价格
                    Text(
                      widget.item.price.formatted,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 商品描述
                    if (widget.item.description != null)
                      Text(
                        widget.item.description!.chinese,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    
                    const SizedBox(height: 12),
                    
                    // 过敏原信息
                    if (widget.item.allergens.isNotEmpty) ...[
                      const Text(
                        '过敏原信息:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: widget.item.allergens.map((allergen) =>
                          Chip(
                            label: Text(allergen),
                            backgroundColor: Colors.red[100],
                          ),
                        ).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // 数量选择
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('数量:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Text('$_quantity', style: const TextStyle(fontSize: 16)),
                            IconButton(
                              onPressed: () => setState(() => _quantity++),
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // 操作按钮
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        for (int i = 0; i < _quantity; i++) {
                          widget.onAddToCart(widget.item, customizations: _customizations);
                        }
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('加入购物车 (${widget.item.price.formatted})'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
