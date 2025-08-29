import 'package:flutter/material.dart';
import '../../../domain/entities/service.dart';
import 'dynamic_tab_builder.dart';

/// 餐饮服务 - 菜单Tab
class FoodMenuTab extends StatelessWidget {
  final Service service;

  const FoodMenuTab({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedTabContent(
      title: 'Menu Items',
      description: 'Delicious dishes prepared with fresh ingredients',
      icon: Icons.restaurant_menu,
      iconColor: Colors.orange,
      children: [
        _buildMenuCategories(),
        const SizedBox(height: 20),
        _buildPopularDishes(),
        const SizedBox(height: 20),
        _buildSpecialOffers(),
      ],
      onAction: () {
        // TODO: 实现点餐功能
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ordering feature coming soon!')),
        );
      },
      actionLabel: 'Order Now',
    );
  }

  Widget _buildMenuCategories() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.category, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Menu Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMenuCategory(
              'Appetizers',
              'Start your meal with our delicious starters',
              Icons.tapas,
              Colors.green,
            ),
            _buildMenuCategory(
              'Main Courses',
              'Signature dishes prepared with care',
              Icons.restaurant,
              Colors.orange,
            ),
            _buildMenuCategory(
              'Desserts',
              'Sweet endings to perfect your meal',
              Icons.cake,
              Colors.pink,
            ),
            _buildMenuCategory(
              'Beverages',
              'Refreshing drinks and hot beverages',
              Icons.local_drink,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCategory(
      String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularDishes() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  'Popular Dishes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDishItem(
              'Grilled Salmon',
              'Fresh Atlantic salmon with herbs and lemon',
              '\$28.99',
              Icons.favorite,
            ),
            _buildDishItem(
              'Beef Tenderloin',
              'Premium cut with red wine reduction',
              '\$34.99',
              Icons.favorite,
            ),
            _buildDishItem(
              'Vegetarian Pasta',
              'Fresh vegetables with homemade sauce',
              '\$22.99',
              Icons.favorite_border,
            ),
            _buildDishItem(
              'Chocolate Lava Cake',
              'Warm chocolate cake with vanilla ice cream',
              '\$12.99',
              Icons.favorite,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishItem(
      String name, String description, String price, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialOffers() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_offer, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Special Offers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildOfferItem(
              'Lunch Special',
              '20% off all main courses 11AM-2PM',
              'Valid until 2:00 PM',
              Colors.green,
            ),
            _buildOfferItem(
              'Happy Hour',
              '50% off appetizers 4PM-6PM',
              'Valid until 6:00 PM',
              Colors.blue,
            ),
            _buildOfferItem(
              'Weekend Brunch',
              'Free mimosa with any brunch item',
              'Valid Sat-Sun 10AM-2PM',
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferItem(
      String title, String description, String validity, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            validity,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// 餐饮服务 - 食材Tab
class FoodIngredientsTab extends StatelessWidget {
  final Service service;

  const FoodIngredientsTab({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedTabContent(
      title: 'Fresh Ingredients',
      description: 'Quality ingredients sourced from local suppliers',
      icon: Icons.grain,
      iconColor: Colors.green,
      children: [
        _buildIngredientSources(),
        const SizedBox(height: 20),
        _buildQualityStandards(),
        const SizedBox(height: 20),
        _buildSeasonalItems(),
      ],
    );
  }

  Widget _buildIngredientSources() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Local Suppliers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSupplierItem(
              'Fresh Market',
              'Daily fresh vegetables and fruits',
              '2 miles away',
              Icons.store,
            ),
            _buildSupplierItem(
              'Organic Farm',
              'Certified organic produce',
              '5 miles away',
              Icons.eco,
            ),
            _buildSupplierItem(
              'Local Butcher',
              'Premium quality meats',
              '1 mile away',
              Icons.restaurant,
            ),
            _buildSupplierItem(
              'Seafood Market',
              'Fresh catch of the day',
              '3 miles away',
              Icons.set_meal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierItem(
      String name, String description, String distance, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              distance,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityStandards() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Quality Standards',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStandardItem(
                'Fresh Daily', 'All ingredients delivered same day'),
            _buildStandardItem('No Preservatives', '100% natural ingredients'),
            _buildStandardItem(
                'Temperature Controlled', 'Proper storage conditions'),
            _buildStandardItem('Quality Check', 'Inspected before use'),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonalItems() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wb_sunny, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Seasonal Specialties',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Spring Asparagus',
                'Summer Berries',
                'Fall Squash',
                'Winter Root Vegetables',
                'Fresh Herbs',
                'Local Honey',
              ]
                  .map((item) => Chip(
                        label: Text(item),
                        backgroundColor: Colors.orange.withValues(alpha: 0.1),
                        labelStyle: const TextStyle(color: Colors.orange),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// 餐饮服务 - 营养信息Tab
class FoodNutritionTab extends StatelessWidget {
  final Service service;

  const FoodNutritionTab({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedTabContent(
      title: 'Nutrition Information',
      description: 'Detailed nutritional facts and dietary information',
      icon: Icons.monitor_heart,
      iconColor: Colors.purple,
      children: [
        _buildNutritionalFacts(),
        const SizedBox(height: 20),
        _buildDietaryOptions(),
        const SizedBox(height: 20),
        _buildAllergenInfo(),
      ],
    );
  }

  Widget _buildNutritionalFacts() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Nutritional Facts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildNutritionRow('Calories', '250-350 per serving'),
            _buildNutritionRow('Protein', '15-25g per serving'),
            _buildNutritionRow('Carbohydrates', '30-45g per serving'),
            _buildNutritionRow('Fat', '8-15g per serving'),
            _buildNutritionRow('Fiber', '5-8g per serving'),
            _buildNutritionRow('Sodium', '400-600mg per serving'),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String nutrient, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nutrient,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryOptions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant_menu, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Dietary Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDietaryItem('Vegetarian', 'Plant-based options available'),
            _buildDietaryItem('Vegan', 'No animal products'),
            _buildDietaryItem('Gluten-Free', 'Safe for celiac disease'),
            _buildDietaryItem('Low-Carb', 'Reduced carbohydrate options'),
            _buildDietaryItem('Low-Sodium', 'Reduced salt options'),
            _buildDietaryItem('Dairy-Free', 'No dairy products'),
          ],
        ),
      ),
    );
  }

  Widget _buildDietaryItem(String option, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergenInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Allergen Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAllergenItem(
                'Contains Nuts', 'Some dishes may contain tree nuts'),
            _buildAllergenItem(
                'Contains Dairy', 'Milk and cheese in some dishes'),
            _buildAllergenItem(
                'Contains Gluten', 'Wheat products in some dishes'),
            _buildAllergenItem(
                'Contains Seafood', 'Fish and shellfish options'),
            _buildAllergenItem(
                'Contains Eggs', 'Eggs used in some preparations'),
            _buildAllergenItem('Contains Soy', 'Soy products in some dishes'),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergenItem(String allergen, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allergen,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
