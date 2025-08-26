import 'package:flutter/material.dart';
import '../../../domain/entities/service.dart';
import 'dynamic_tab_builder.dart';

/// 家政服务 - 时间安排Tab
class CleaningScheduleTab extends StatelessWidget {
  final Service service;

  const CleaningScheduleTab({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedTabContent(
      title: 'Cleaning Schedule',
      description: 'Flexible scheduling options for your cleaning needs',
      icon: Icons.schedule,
      iconColor: Colors.blue,
      children: [
        _buildScheduleOptions(),
        const SizedBox(height: 20),
        _buildTimeSlots(),
        const SizedBox(height: 20),
        _buildPricingInfo(),
      ],
      onAction: () {
        // TODO: 实现预约功能
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking feature coming soon!')),
        );
      },
      actionLabel: 'Book Now',
    );
  }

  Widget _buildScheduleOptions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Schedule Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildScheduleOption(
              'One-time Cleaning',
              'Perfect for special occasions or deep cleaning needs',
              Icons.cleaning_services,
              Colors.green,
            ),
            _buildScheduleOption(
              'Weekly Cleaning',
              'Regular maintenance to keep your home spotless',
              Icons.repeat,
              Colors.blue,
            ),
            _buildScheduleOption(
              'Bi-weekly Cleaning',
              'Balanced cleaning schedule for busy households',
              Icons.schedule,
              Colors.orange,
            ),
            _buildScheduleOption(
              'Monthly Cleaning',
              'Comprehensive cleaning for low-maintenance homes',
              Icons.calendar_month,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleOption(String title, String description, IconData icon, Color color) {
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

  Widget _buildTimeSlots() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Available Time Slots',
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
                '8:00 AM - 10:00 AM',
                '10:00 AM - 12:00 PM',
                '1:00 PM - 3:00 PM',
                '3:00 PM - 5:00 PM',
                '5:00 PM - 7:00 PM',
                '7:00 PM - 9:00 PM',
              ].map((timeSlot) => Chip(
                label: Text(timeSlot),
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                labelStyle: const TextStyle(color: Colors.blue),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Pricing Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildPricingRow('Studio/1BR', '\$80 - \$120'),
            _buildPricingRow('2BR Apartment', '\$120 - \$180'),
            _buildPricingRow('3BR House', '\$180 - \$250'),
            _buildPricingRow('4BR+ House', '\$250 - \$350'),
            _buildPricingRow('Deep Cleaning', '+50%'),
            _buildPricingRow('Move-in/out', '+30%'),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingRow(String type, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            type,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
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
}

/// 家政服务 - 设备Tab
class CleaningEquipmentTab extends StatelessWidget {
  final Service service;

  const CleaningEquipmentTab({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedTabContent(
      title: 'Cleaning Equipment',
      description: 'Professional equipment and eco-friendly supplies',
      icon: Icons.cleaning_services,
      iconColor: Colors.green,
      children: [
        _buildEquipmentList(),
        const SizedBox(height: 20),
        _buildSuppliesList(),
        const SizedBox(height: 20),
        _buildSafetyInfo(),
      ],
    );
  }

  Widget _buildEquipmentList() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.build, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Professional Equipment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildEquipmentItem(
              'HEPA Vacuum Cleaner',
              'Advanced filtration for dust and allergens',
              Icons.cleaning_services,
            ),
            _buildEquipmentItem(
              'Steam Cleaner',
              'Sanitizing surfaces without chemicals',
              Icons.whatshot,
            ),
            _buildEquipmentItem(
              'Microfiber Cloths',
              'Ultra-soft cleaning without scratching',
              Icons.cleaning_services,
            ),
            _buildEquipmentItem(
              'Extension Poles',
              'Reach high areas safely and easily',
              Icons.height,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentItem(String name, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
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
        ],
      ),
    );
  }

  Widget _buildSuppliesList() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.eco, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Eco-friendly Supplies',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildSupplyItem('Plant-based Cleaners', 'Safe for children and pets'),
            _buildSupplyItem('Bamboo Brushes', 'Sustainable and durable'),
            _buildSupplyItem('Natural Sponges', 'Biodegradable cleaning tools'),
            _buildSupplyItem('Essential Oil Blends', 'Pleasant, natural fragrances'),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplyItem(String name, String description) {
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
                  name,
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

  Widget _buildSafetyInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Safety & Insurance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildSafetyItem('Bonded & Insured', 'Full coverage for your peace of mind'),
            _buildSafetyItem('Background Checked', 'All staff thoroughly vetted'),
            _buildSafetyItem('Safety Training', 'Certified cleaning professionals'),
            _buildSafetyItem('Quality Guarantee', '100% satisfaction or re-clean free'),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Colors.blue, size: 20),
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
}
