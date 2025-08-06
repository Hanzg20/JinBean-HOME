import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service_detail_controller.dart';
import '../widgets/service_detail_card.dart';

class ServiceActionsSection extends StatelessWidget {
  final ServiceDetailController controller;
  final VoidCallback? onGetQuote;
  final VoidCallback? onSchedule;

  const ServiceActionsSection({
    Key? key,
    required this.controller,
    this.onGetQuote,
    this.onSchedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ServiceDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '服务操作',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _requestQuote(),
                  icon: const Icon(Icons.request_quote, size: 18),
                  label: const Text('获取报价'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _bookService(),
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: const Text('立即预订'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _contactProvider('chat'),
                  icon: const Icon(Icons.chat),
                  label: const Text('聊天'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _contactProvider('call'),
                  icon: const Icon(Icons.phone),
                  label: const Text('电话'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _requestQuote() {
    if (onGetQuote != null) {
      onGetQuote!();
    } else {
      Get.snackbar(
        '获取报价',
        '报价功能即将推出',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _bookService() {
    if (onSchedule != null) {
      onSchedule!();
    } else {
      Get.snackbar(
        '预订服务',
        '预订功能即将推出',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _contactProvider(String method) {
    switch (method) {
      case 'chat':
        Get.snackbar(
          '聊天功能',
          '聊天功能即将推出',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'call':
        Get.snackbar(
          '电话功能',
          '电话功能即将推出',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
    }
  }
}
