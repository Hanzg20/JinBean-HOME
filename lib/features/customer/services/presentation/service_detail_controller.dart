import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Service {
  final String id;
  final String title;
  final String description;
  final double averageRating;
  final int reviewCount;
  final String providerId;
  final String categoryLevel1Id;
  final String? categoryLevel2Id;
  final String status;
  final String serviceDeliveryMethod;
  final DateTime createdAt;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.averageRating,
    required this.reviewCount,
    required this.providerId,
    required this.categoryLevel1Id,
    this.categoryLevel2Id,
    required this.status,
    required this.serviceDeliveryMethod,
    required this.createdAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      title: json['title']?['en'] ?? 'Unknown Service',
      description: json['description']?['en'] ?? '',
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      providerId: json['provider_id'],
      categoryLevel1Id: json['category_level1_id'].toString(),
      categoryLevel2Id: json['category_level2_id']?.toString(),
      status: json['status'],
      serviceDeliveryMethod: json['service_delivery_method'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ServiceDetail {
  final String serviceId;
  final String pricingType;
  final double? price;
  final String? currency;
  final String? negotiationDetails;
  final String durationType;
  final Duration? duration;
  final List<String> images;
  final List<String> tags;
  final List<String> serviceAreaCodes;
  final Map<String, dynamic>? serviceDetailsJson;

  ServiceDetail({
    required this.serviceId,
    required this.pricingType,
    this.price,
    this.currency,
    this.negotiationDetails,
    required this.durationType,
    this.duration,
    required this.images,
    required this.tags,
    required this.serviceAreaCodes,
    this.serviceDetailsJson,
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    return ServiceDetail(
      serviceId: json['service_id'],
      pricingType: json['pricing_type'],
      price: json['price']?.toDouble(),
      currency: json['currency'],
      negotiationDetails: json['negotiation_details'],
      durationType: json['duration_type'],
      duration: json['duration'] != null 
          ? Duration(minutes: int.parse(json['duration'].toString().split(':')[0]) * 60 + 
                     int.parse(json['duration'].toString().split(':')[1]))
          : null,
      images: List<String>.from(json['images_url'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      serviceAreaCodes: List<String>.from(json['service_area_codes'] ?? []),
      serviceDetailsJson: json['service_details_json'],
    );
  }
}

class ProviderProfile {
  final String id;
  final String companyName;
  final String contactPhone;
  final String contactEmail;
  final String? businessAddress;
  final String? licenseNumber;
  final String? description;
  final double ratingsAvg;
  final int reviewCount;
  final String status;
  final String providerType;

  ProviderProfile({
    required this.id,
    required this.companyName,
    required this.contactPhone,
    required this.contactEmail,
    this.businessAddress,
    this.licenseNumber,
    this.description,
    required this.ratingsAvg,
    required this.reviewCount,
    required this.status,
    required this.providerType,
  });

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    return ProviderProfile(
      id: json['id'],
      companyName: json['company_name'] ?? 'Unknown Provider',
      contactPhone: json['contact_phone'],
      contactEmail: json['contact_email'],
      businessAddress: json['business_address'],
      licenseNumber: json['license_number'],
      description: json['description'],
      ratingsAvg: (json['ratings_avg'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      status: json['status'],
      providerType: json['provider_type'],
    );
  }
}

class ServiceDetailController extends GetxController {
  final Rx<Service?> service = Rx<Service?>(null);
  final Rx<ServiceDetail?> serviceDetail = Rx<ServiceDetail?>(null);
  final Rx<ProviderProfile?> provider = Rx<ProviderProfile?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  
  final TextEditingController messageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final serviceId = Get.parameters['serviceId'];
    if (serviceId != null) {
      loadServiceDetail(serviceId);
    }
  }

  Future<void> loadServiceDetail(String serviceId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // 加载服务信息
      final serviceResponse = await Supabase.instance.client
          .from('services')
          .select()
          .eq('id', serviceId)
          .single();

      service.value = Service.fromJson(serviceResponse);
      
      // 加载服务详情
      await loadServiceDetails(serviceId);
      
      // 加载服务商信息
      if (service.value != null) {
        await loadProviderProfile(service.value?.providerId ?? '');
      }
        } catch (e) {
      print('Error loading service detail: $e');
      errorMessage.value = 'Failed to load service details';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadServiceDetails(String serviceId) async {
    try {
      final response = await Supabase.instance.client
          .from('service_details')
          .select()
          .eq('service_id', serviceId)
          .single();

      serviceDetail.value = ServiceDetail.fromJson(response);
        } catch (e) {
      print('Error loading service details: $e');
    }
  }

  Future<void> loadProviderProfile(String providerId) async {
    try {
      final response = await Supabase.instance.client
          .from('provider_profiles')
          .select()
          .eq('id', providerId)
          .single();

      provider.value = ProviderProfile.fromJson(response);
        } catch (e) {
      print('Error loading provider profile: $e');
    }
  }

  void shareService() {
    if (service.value != null) {
      // TODO: Implement share functionality
      Get.snackbar(
        'Share',
        'Share functionality will be implemented soon',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void contactProvider() {
    final providerProfile = provider.value;
    if (providerProfile != null) {
      // TODO: Implement phone call functionality
      Get.snackbar(
        'Contact',
        'Calling ${providerProfile.contactPhone}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void sendMessage() {
    final message = messageController.text.trim();
    if (message.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a message',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // TODO: Implement message sending functionality
    Get.snackbar(
      'Message Sent',
      'Your message has been sent to the provider',
      snackPosition: SnackPosition.BOTTOM,
    );
    
    messageController.clear();
  }

  void startChat() {
    // TODO: Implement chat functionality
    Get.snackbar(
      'Chat',
      'Chat functionality will be implemented soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void addToFavorites() {
    // TODO: Implement add to favorites functionality
    Get.snackbar(
      'Saved',
      'Service added to favorites',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void bookService() {
    if (service.value == null) return;

    // 导航到预订页面
    Get.toNamed('/create_order', arguments: {
      'serviceId': service.value?.id ?? '',
      'serviceName': service.value?.title ?? '',
      'providerId': service.value?.providerId ?? '',
      'price': serviceDetail.value?.price,
      'pricingType': serviceDetail.value?.pricingType,
    });
  }

  // 新增：兼容 Map 和 String 的多语言安全取值方法
  String getSafeLocalizedText(dynamic value) {
    if (value is Map<String, dynamic>) {
      final lang = Get.locale?.languageCode ?? 'zh';
      return value[lang] ?? value['zh'] ?? value['en'] ?? '';
    } else if (value is String) {
      return value;
    }
    return '';
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
} 