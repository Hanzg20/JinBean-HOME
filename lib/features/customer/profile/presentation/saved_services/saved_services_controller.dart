import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SavedService {
  final String id;
  final String serviceId;
  final String name;
  final String description;
  final String? imageUrl;
  final double? price;
  final String? currency;
  final DateTime savedAt;

  SavedService({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.description,
    this.imageUrl,
    this.price,
    this.currency,
    required this.savedAt,
  });

  factory SavedService.fromJson(Map<String, dynamic> json) {
    return SavedService(
      id: json['id'],
      serviceId: json['service_id'],
      name: json['service_name'] ?? json['name'] ?? 'Unknown Service',
      description: json['service_description'] ?? json['description'] ?? '',
      imageUrl: json['image_url'],
      price: json['price']?.toDouble(),
      currency: json['currency'] ?? 'CAD',
      savedAt: DateTime.parse(json['created_at']),
    );
  }
}

class SavedServicesController extends GetxController {
  final isLoading = false.obs;
  final savedServices = <SavedService>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('SavedServicesController initialized',
        tag: 'SavedServicesController');
    loadSavedServices();
  }

  Future<void> loadSavedServices() async {
    AppLogger.info('SavedServicesController: loadSavedServices called',
        tag: 'SavedServicesController');
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // 查询用户保存的服务
      final response = await Supabase.instance.client
          .from('saved_services')
          .select('''
            id,
            service_id,
            created_at,
            services!inner(
              title,
              description,
              price,
              currency,
              images_url
            )
          ''')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final List<SavedService> serviceList = [];
      for (final serviceData in response) {
        try {
          final service = serviceData['services'];
          final savedService = SavedService(
            id: serviceData['id'],
            serviceId: serviceData['service_id'],
            name: service['title']?.toString() ?? 'Unknown Service',
            description: service['description']?.toString() ?? '',
            imageUrl: service['images_url'] is List && (service['images_url'] as List).isNotEmpty
                ? (service['images_url'] as List).first?.toString()
                : null,
            price: service['price']?.toDouble(),
            currency: service['currency'] ?? 'CAD',
            savedAt: DateTime.parse(serviceData['created_at']),
          );
          
          serviceList.add(savedService);
        } catch (e) {
          AppLogger.warning('Failed to parse saved service data: $e');
        }
      }

      savedServices.assignAll(serviceList);
      
      AppLogger.info('SavedServicesController: Saved services loaded successfully, count: ${savedServices.length}',
          tag: 'SavedServicesController');
          
    } catch (e, stack) {
      AppLogger.error('SavedServicesController: Failed to load saved services',
          error: e, stackTrace: stack, tag: 'SavedServicesController');
      errorMessage.value = 'Failed to load saved services: $e';
      
      // 直接抛出错误，不使用Mock数据作为备用
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }



  Future<void> removeService(String id) async {
    try {
      AppLogger.info('Removing saved service: $id');
      
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // 从数据库中删除
      await Supabase.instance.client
          .from('saved_services')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);

      // 从本地列表中移除
      savedServices.removeWhere((service) => service.id == id);
      
      AppLogger.info('Saved service removed successfully');
      
      // 显示成功消息
      _showRemoveSuccessMessage();
      
    } catch (e) {
      AppLogger.error('Failed to remove saved service: $e');
      
      Get.snackbar(
        'Error',
        'Failed to remove service: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  void _showRemoveSuccessMessage() {
    // 使用空值安全的方式获取context
    final context = Get.context;
    if (context != null) {
      final localizations = AppLocalizations.of(context);
      if (localizations != null) {
        Get.snackbar(
          localizations.removed,
          localizations.serviceRemovedFromSavedList,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Fallback to English
        Get.snackbar(
          'Removed',
          'Service removed from saved list',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      // Fallback when context is null
      Get.snackbar(
        'Removed',
        'Service removed from saved list',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 添加服务到收藏
  Future<bool> saveService(String serviceId) async {
    try {
      AppLogger.info('Saving service: $serviceId');
      
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // 检查是否已经保存过
      final existing = savedServices.firstWhereOrNull(
        (service) => service.serviceId == serviceId,
      );
      
      if (existing != null) {
        Get.snackbar(
          'Already Saved',
          'This service is already in your saved list',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // 添加到数据库
      final response = await Supabase.instance.client
          .from('saved_services')
          .insert({
            'user_id': user.id,
            'service_id': serviceId,
          })
          .select()
          .single();

      // 重新加载保存的服务列表
      await loadSavedServices();
      
      AppLogger.info('Service saved successfully');
      
      Get.snackbar(
        'Saved',
        'Service added to your saved list',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
      
      return true;
      
    } catch (e) {
      AppLogger.error('Failed to save service: $e');
      
      Get.snackbar(
        'Error',
        'Failed to save service: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      
      return false;
    }
  }

  /// 检查服务是否已保存
  bool isServiceSaved(String serviceId) {
    return savedServices.any((service) => service.serviceId == serviceId);
  }

  Future<void> refreshSavedServices() async {
    AppLogger.info('SavedServicesController: refreshSavedServices called',
        tag: 'SavedServicesController');
    await loadSavedServices();
  }
}
