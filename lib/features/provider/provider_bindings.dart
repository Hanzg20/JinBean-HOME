import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/income/income_controller.dart';
import 'package:jinbeanpod_83904710/features/provider/notifications/notification_controller.dart';
import 'package:jinbeanpod_83904710/features/provider/services/service_management_controller.dart';
import 'package:jinbeanpod_83904710/features/provider/clients/presentation/client_controller.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/order_manage/order_manage_controller.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/rob_order_hall/rob_order_hall_controller.dart';

/// Provider页面控制器统一注册
class ProviderBindings extends Bindings {
  @override
  void dependencies() {
    // 收入管理控制器
    Get.lazyPut<IncomeController>(() => IncomeController());
    
    // 通知管理控制器
    Get.lazyPut<NotificationController>(() => NotificationController());
    
    // 服务管理控制器
    Get.lazyPut<ServiceManagementController>(() => ServiceManagementController());
    
    // 客户管理控制器
    Get.lazyPut<ClientController>(() => ClientController());
    
    // 订单管理控制器
    Get.lazyPut<OrderManageController>(() => OrderManageController());
    
    // 抢单大厅控制器
    Get.lazyPut<RobOrderHallController>(() => RobOrderHallController());
  }
}

/// 确保所有Provider控制器都已注册
class ProviderControllerManager {
  static void ensureControllersRegistered() {
    // 收入管理控制器
    if (!Get.isRegistered<IncomeController>()) {
      Get.lazyPut<IncomeController>(() => IncomeController());
    }
    
    // 通知管理控制器
    if (!Get.isRegistered<NotificationController>()) {
      Get.lazyPut<NotificationController>(() => NotificationController());
    }
    
    // 服务管理控制器
    if (!Get.isRegistered<ServiceManagementController>()) {
      Get.lazyPut<ServiceManagementController>(() => ServiceManagementController());
    }
    
    // 客户管理控制器
    if (!Get.isRegistered<ClientController>()) {
      Get.lazyPut<ClientController>(() => ClientController());
    }
    
    // 订单管理控制器
    if (!Get.isRegistered<OrderManageController>()) {
      Get.lazyPut<OrderManageController>(() => OrderManageController());
    }
    
    // 抢单大厅控制器
    if (!Get.isRegistered<RobOrderHallController>()) {
      Get.lazyPut<RobOrderHallController>(() => RobOrderHallController());
    }
  }
} 