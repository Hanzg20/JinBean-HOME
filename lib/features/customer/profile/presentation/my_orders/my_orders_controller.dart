import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

class Order {
  final String id;
  final String serviceId;
  final String serviceName;
  final String date;
  final double total;
  final String status;

  Order({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.date,
    required this.total,
    required this.status,
  });
}

class MyOrdersController extends GetxController {
  final isLoading = false.obs;
  final orders = <Order>[].obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('MyOrdersController initialized', tag: 'MyOrdersController');
    loadOrders();
  }

  Future<void> loadOrders() async {
    AppLogger.info('MyOrdersController: loadOrders called', tag: 'MyOrdersController');
    isLoading.value = true;
    try {
      // TODO: Implement actual API call to fetch orders
      // For now, using mock data
      await Future.delayed(const Duration(seconds: 1));
      orders.value = [
        Order(
          id: '001',
          serviceId: 'service_001',
          serviceName: 'House Cleaning',
          date: '2024-03-15',
          total: 120.00,
          status: 'Completed',
        ),
        Order(
          id: '002',
          serviceId: 'service_002',
          serviceName: 'Plumbing Repair',
          date: '2024-03-20',
          total: 85.50,
          status: 'In Progress',
        ),
        Order(
          id: '003',
          serviceId: 'service_003',
          serviceName: 'Electrical Work',
          date: '2024-03-25',
          total: 150.00,
          status: 'Cancelled',
        ),
      ];
    } catch (e, stack) {
      AppLogger.error('MyOrdersController: Failed to load orders', error: e, stackTrace: stack, tag: 'MyOrdersController');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrders() async {
    AppLogger.info('MyOrdersController: refreshOrders called', tag: 'MyOrdersController');
    await loadOrders();
  }
} 