import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';import 'package:supabase_flutter/supabase_flutter.dart';

class QuickImageFix {
  static final QuickImageFix _instance = QuickImageFix._internal();
  factory QuickImageFix() => _instance;
  QuickImageFix._internal();

  /// Quick fix: Update all services with working image URLs
  Future<void> fixAllServiceImages() async {
    try {
      AppLogger.info('[QuickImageFix] Starting quick fix for all service images...');
      
      // Get all services
      final services = await Supabase.instance.client
          .from('services')
          .select('id, title, category_level1_id, category_level2_id');
      
      int processedCount = 0;
      int errorCount = 0;
      
      for (final service in services) {
        try {
          final String serviceId = service['id'];
          final Map<String, dynamic> title = service['title'] ?? {};
          final String serviceName = title['zh'] ?? title['en'] ?? 'Unknown Service';
          
          AppLogger.info('[QuickImageFix] Processing service: $serviceName (ID: $serviceId)');
          
          // Generate working image URLs based on service ID
          final List<String> images = _generateWorkingImages(serviceId, 3);
          
          // Update service details
          await _updateServiceDetails(serviceId, images);
          
          processedCount++;
          AppLogger.info('[QuickImageFix] ✓ Updated service: $serviceName with ${images.length} images');
          
        } catch (e) {
          errorCount++;
          AppLogger.info('[QuickImageFix] ✗ Error processing service ${service['id']}: $e');
        }
      }
      
      AppLogger.info('[QuickImageFix] ==========================================');
      AppLogger.info('[QuickImageFix] Quick fix completed!');
      AppLogger.info('[QuickImageFix] Successfully processed: $processedCount services');
      AppLogger.info('[QuickImageFix] Errors: $errorCount services');
      AppLogger.info('[QuickImageFix] ==========================================');
      
    } catch (e) {
      AppLogger.info('[QuickImageFix] Error in quick fix: $e');
      rethrow;
    }
  }

  /// Generate working image URLs
  List<String> _generateWorkingImages(String serviceId, int count) {
    List<String> images = [];
    
    // Generate hash from service ID for consistent images
    int hash = 0;
    for (int i = 0; i < serviceId.length; i++) {
      hash = ((hash << 5) - hash + serviceId.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    
    for (int i = 0; i < count; i++) {
      final int seed = (hash + i) & 0xFFFFFFFF;
      final String imageUrl = 'https://picsum.photos/seed/$seed/400/300';
      images.add(imageUrl);
    }
    
    return images;
  }

  /// Update service details with new images
  Future<void> _updateServiceDetails(String serviceId, List<String> images) async {
    try {
      // Check if service details exist
      final existing = await Supabase.instance.client
          .from('service_details')
          .select('service_id')
          .eq('service_id', serviceId)
          .maybeSingle();
      
      if (existing != null) {
        // Update existing record
        await Supabase.instance.client
            .from('service_details')
            .update({
              'images_url': images,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('service_id', serviceId);
      } else {
        // Insert new record with basic service details
        await Supabase.instance.client
            .from('service_details')
            .insert({
              'service_id': serviceId,
              'images_url': images,
              'pricing_type': 'fixed_price',
              'price': 100.0,
              'currency': 'CAD',
              'duration_type': 'fixed',
              'duration': '01:00:00',
              'tags': ['service'],
              'service_area_codes': ['K1A'],
              'platform_service_fee_rate': 0.1,
            });
      }
    } catch (e) {
      AppLogger.info('[QuickImageFix] Error updating service details: $e');
      rethrow;
    }
  }

  /// Validate current image status
  Future<Map<String, dynamic>> validateImageStatus() async {
    try {
      AppLogger.info('[QuickImageFix] Validating current image status...');
      
      final services = await Supabase.instance.client
          .from('service_details')
          .select('service_id, images_url');
      
      int totalServices = services.length;
      int validImages = 0;
      int invalidImages = 0;
      List<String> servicesWithIssues = [];
      
      for (final service in services) {
        final String serviceId = service['service_id'];
        final List<dynamic> images = service['images_url'] ?? [];
        
        if (images.isEmpty) {
          servicesWithIssues.add('$serviceId: No images');
          invalidImages++;
        } else {
          for (final imageUrl in images) {
            if (_isValidImageUrl(imageUrl.toString())) {
              validImages++;
            } else {
              servicesWithIssues.add('$serviceId: Invalid URL - $imageUrl');
              invalidImages++;
            }
          }
        }
      }
      
      final result = {
        'totalServices': totalServices,
        'validImages': validImages,
        'invalidImages': invalidImages,
        'servicesWithIssues': servicesWithIssues,
      };
      
      AppLogger.info('[QuickImageFix] Validation completed:');
      AppLogger.info('  Total services: $totalServices');
      AppLogger.info('  Valid images: $validImages');
      AppLogger.info('  Invalid images: $invalidImages');
      AppLogger.info('  Services with issues: ${servicesWithIssues.length}');
      
      return result;
    } catch (e) {
      AppLogger.info('[QuickImageFix] Error validating images: $e');
      rethrow;
    }
  }

  /// Check if URL is valid
  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    
    try {
      final Uri uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Test the fix on a single service
  Future<void> testFixOnSingleService(String serviceId) async {
    try {
      AppLogger.info('[QuickImageFix] Testing fix on service: $serviceId');
      
      final List<String> images = _generateWorkingImages(serviceId, 2);
      await _updateServiceDetails(serviceId, images);
      
      AppLogger.info('[QuickImageFix] Test completed for service: $serviceId');
      AppLogger.info('[QuickImageFix] Generated images:');
      for (int i = 0; i < images.length; i++) {
        AppLogger.info('  Image ${i + 1}: ${images[i]}');
      }
    } catch (e) {
      AppLogger.info('[QuickImageFix] Error testing fix: $e');
      rethrow;
    }
  }
} 