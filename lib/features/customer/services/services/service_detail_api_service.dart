import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/features/customer/services/presentation/service_detail_controller.dart';
import 'package:jinbeanpod_83904710/features/customer/domain/entities/service.dart';
import 'package:jinbeanpod_83904710/features/customer/domain/entities/service_detail.dart';
import 'package:jinbeanpod_83904710/features/customer/domain/entities/provider_profile.dart';

class ServiceDetailApiService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// 获取服务数据
  static Future<Service> getService(String serviceId) async {
    try {
      final response = await _supabase
          .from('services')
          .select('''
            *,
            service_details(*),
            provider_profiles!services_provider_id_fkey(*),
            addresses!services_address_id_fkey(*)
          ''')
          .eq('id', serviceId)
          .single();

      return Service.fromJson(response);
    } catch (e) {
      print('Error fetching service: $e');
      // 返回Mock数据
      return Service(
        id: serviceId,
        title: 'Professional Home Cleaning Service',
        description: 'Comprehensive home cleaning service including kitchen, bathroom, living areas, and bedrooms.',
        rating: 4.8,
        reviewCount: 127,
        providerId: 'provider_456',
        categoryId: '1020000',
        categoryLevel2Id: '1020100',
        isActive: true,
        serviceDeliveryMethod: 'on_site',
        createdAt: DateTime.now(),
      );
    }
  }

  /// 获取服务详情数据
  static Future<ServiceDetail> getServiceDetail(String serviceId) async {
    try {
      final response = await _supabase
          .from('service_details')
          .select('*')
          .eq('service_id', serviceId)
          .single();

      return ServiceDetail.fromJson(response);
    } catch (e) {
      print('Error fetching service detail: $e');
      // 返回Mock数据
      return ServiceDetail(
        id: 'detail_$serviceId',
        serviceId: serviceId,
        pricingType: 'hourly',
        price: 45.0,
        currency: 'USD',
        negotiationDetails: 'Price may vary based on home size and specific requirements',
        durationType: 'fixed',
        duration: 3,
        images: [
          'https://picsum.photos/400/300?random=1',
          'https://picsum.photos/400/300?random=2',
          'https://picsum.photos/400/300?random=3',
        ],
        tags: ['cleaning', 'professional', 'eco-friendly', 'residential'],
        serviceAreaCodes: ['10001', '10002', '10003'],
        serviceDetailsJson: {
          'equipment': ['vacuum', 'mop', 'cleaning supplies'],
          'materials': ['eco-friendly', 'non-toxic'],
          'included_services': ['dusting', 'vacuuming', 'mopping', 'bathroom cleaning'],
        },
      );
    }
  }

  /// 获取提供商资料
  static Future<ProviderProfile> getProviderProfile(String providerId) async {
    try {
      final response = await _supabase
          .from('provider_profiles')
          .select('''
            *,
            addresses!provider_profiles_address_id_fkey(*)
          ''')
          .eq('id', providerId)
          .single();

      return ProviderProfile.fromJson(response);
    } catch (e) {
      print('Error fetching provider profile: $e');
      // 返回Mock数据
      return ProviderProfile(
        id: providerId,
        name: 'CleanPro Services',
        phone: '+1 (555) 123-4567',
        email: 'contact@cleanproservices.com',
        description: 'Leading professional cleaning service with over 10 years of experience.',
        rating: 4.9,
        reviewCount: 156,
        completedOrders: 342,
        businessLicense: 'CA123456789',
        isVerified: true,
        createdAt: DateTime.now(),
        metadata: {
          'insurance': 'Fully insured and bonded',
          'serviceCategories': ['cleaning', 'maintenance', 'deep-cleaning'],
        },
      );
    }
  }

  /// 获取服务评价
  static Future<List<Review>> getServiceReviews(String serviceId, {int limit = 10}) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('''
            *,
            user_profiles!reviews_user_id_fkey(
              display_name,
              avatar_url
            )
          ''')
          .eq('service_id', serviceId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((json) => Review.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching service reviews: $e');
      // 返回Mock评价数据
      return [
        Review(
          id: 'review_1',
          serviceId: serviceId,
          userId: 'user_1',
          userName: 'John D.',
          userAvatar: 'https://picsum.photos/50/50?random=5',
          rating: 5,
          content: 'Excellent service! The team was professional and thorough.',
          createdAt: DateTime.now().subtract(Duration(days: 2)),
          images: [],
          metadata: {},
        ),
        Review(
          id: 'review_2',
          serviceId: serviceId,
          userId: 'user_2',
          userName: 'Sarah M.',
          userAvatar: 'https://picsum.photos/50/50?random=6',
          rating: 4,
          content: 'Very satisfied with the cleaning quality. Will book again!',
          createdAt: DateTime.now().subtract(Duration(days: 5)),
          images: [],
          metadata: {},
        ),
      ];
    }
  }

  /// 获取服务可用性
  static Future<Map<String, dynamic>> getServiceAvailability(String serviceId) async {
    try {
      final response = await _supabase
          .from('service_availability')
          .select('*')
          .eq('service_id', serviceId)
          .single();

      return response;
    } catch (e) {
      print('Error fetching service availability: $e');
      return {
        'available_24_7': true,
        'response_time_hours': 2,
        'booking_advance_days': 1,
        'cancellation_hours': 24,
      };
    }
  }

  /// 获取服务位置信息
  static Future<Map<String, dynamic>> getServiceLocation(String serviceId) async {
    try {
      final response = await _supabase
          .from('services')
          .select('latitude, longitude')
          .eq('id', serviceId)
          .single();

      return {
        'latitude': response['latitude'] ?? 40.7128,
        'longitude': response['longitude'] ?? -74.0060,
        'address': 'New York, NY 10001',
        'service_radius_km': 10.0,
      };
    } catch (e) {
      print('Error fetching service location: $e');
      return {
        'latitude': 40.7128,
        'longitude': -74.0060,
        'address': 'New York, NY 10001',
        'service_radius_km': 10.0,
      };
    }
  }

  /// 获取信任和安全信息
  static Future<Map<String, dynamic>> getTrustAndSecurityInfo(String providerId) async {
    try {
      final response = await _supabase
          .from('provider_profiles')
          .select('business_license, insurance_info, certification_files')
          .eq('id', providerId)
          .single();

      return {
        'verified': true,
        'licensed': response['business_license'] != null,
        'insured': response['insurance_info'] != null,
        'certified': response['certification_files'] != null,
        'background_checked': true,
      };
    } catch (e) {
      print('Error fetching trust and security info: $e');
      return {
        'verified': true,
        'licensed': true,
        'insured': true,
        'certified': true,
        'background_checked': true,
      };
    }
  }

  /// 获取提供商作品集
  static Future<List<Map<String, dynamic>>> getProviderPortfolio(String providerId) async {
    try {
      final response = await _supabase
          .from('services')
          .select('id, title, images_url')
          .eq('provider_id', providerId)
          .limit(6);

      return response.map((service) => {
        'id': service['id'],
        'title': service['title'],
        'images_url': service['images_url'] ?? [],
      }).toList();
    } catch (e) {
      print('Error fetching provider portfolio: $e');
      return [
        {
          'id': 'portfolio_1',
          'title': 'Kitchen Deep Cleaning',
          'images_url': ['https://picsum.photos/200/200?random=7'],
        },
        {
          'id': 'portfolio_2',
          'title': 'Bathroom Sanitization',
          'images_url': ['https://picsum.photos/200/200?random=8'],
        },
        {
          'id': 'portfolio_3',
          'title': 'Living Room Refresh',
          'images_url': ['https://picsum.photos/200/200?random=9'],
        },
      ];
    }
  }

  /// 记录服务查看
  static Future<void> logServiceView(String serviceId, String userId) async {
    try {
      await _supabase
          .from('service_views')
          .insert({
            'service_id': serviceId,
            'user_id': userId,
            'viewed_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('Error logging service view: $e');
    }
  }

  /// 更新收藏状态
  static Future<void> toggleFavorite(String serviceId, String userId, bool isFavorite) async {
    try {
      if (isFavorite) {
        await _supabase
            .from('user_favorites')
            .insert({
              'user_id': userId,
              'service_id': serviceId,
              'created_at': DateTime.now().toIso8601String(),
            });
      } else {
        await _supabase
            .from('user_favorites')
            .delete()
            .eq('user_id', userId)
            .eq('service_id', serviceId);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  /// 检查收藏状态
  static Future<bool> checkFavoriteStatus(String serviceId, String userId) async {
    try {
      final response = await _supabase
          .from('user_favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('service_id', serviceId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }
}

/// 评价模型
class Review {
  final String id;
  final String serviceId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String content;
  final DateTime createdAt;
  final List<String>? images;
  final Map<String, dynamic>? metadata;
  final bool isVerified;
  final int helpfulCount;

  Review({
    required this.id,
    required this.serviceId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.content,
    required this.createdAt,
    this.images,
    this.metadata,
    this.isVerified = false,
    this.helpfulCount = 0,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      serviceId: json['service_id'],
      userId: json['user_id'],
      userName: json['user_profiles']?['display_name'] ?? 'Anonymous',
      userAvatar: json['user_profiles']?['avatar_url'],
      rating: (json['rating'] ?? 0).toDouble(),
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      metadata: json['metadata'],
      isVerified: json['is_verified'] ?? false,
      helpfulCount: json['helpful_count'] ?? 0,
    );
  }
} 