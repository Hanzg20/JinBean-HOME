import 'package:supabase_flutter/supabase_flutter.dart';

class QuickImageFix {
  static final QuickImageFix _instance = QuickImageFix._internal();
  factory QuickImageFix() => _instance;
  QuickImageFix._internal();

  /// Quick fix: Update all services with working image URLs
  Future<void> fixAllServiceImages() async {
    try {
      print('[QuickImageFix] Starting quick fix for all service images...');
      
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
          
          print('[QuickImageFix] Processing service: $serviceName (ID: $serviceId)');
          
          // Generate working image URLs based on service ID
          final List<String> images = _generateWorkingImages(serviceId, 3);
          
          // Update service details
          await _updateServiceDetails(serviceId, images);
          
          processedCount++;
          print('[QuickImageFix] ✓ Updated service: $serviceName with ${images.length} images');
          
        } catch (e) {
          errorCount++;
          print('[QuickImageFix] ✗ Error processing service ${service['id']}: $e');
        }
      }
      
      print('[QuickImageFix] ==========================================');
      print('[QuickImageFix] Quick fix completed!');
      print('[QuickImageFix] Successfully processed: $processedCount services');
      print('[QuickImageFix] Errors: $errorCount services');
      print('[QuickImageFix] ==========================================');
      
    } catch (e) {
      print('[QuickImageFix] Error in quick fix: $e');
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
      print('[QuickImageFix] Error updating service details: $e');
      rethrow;
    }
  }

  /// Validate current image status
  Future<Map<String, dynamic>> validateImageStatus() async {
    try {
      print('[QuickImageFix] Validating current image status...');
      
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
      
      print('[QuickImageFix] Validation completed:');
      print('  Total services: $totalServices');
      print('  Valid images: $validImages');
      print('  Invalid images: $invalidImages');
      print('  Services with issues: ${servicesWithIssues.length}');
      
      return result;
    } catch (e) {
      print('[QuickImageFix] Error validating images: $e');
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
      print('[QuickImageFix] Testing fix on service: $serviceId');
      
      final List<String> images = _generateWorkingImages(serviceId, 2);
      await _updateServiceDetails(serviceId, images);
      
      print('[QuickImageFix] Test completed for service: $serviceId');
      print('[QuickImageFix] Generated images:');
      for (int i = 0; i < images.length; i++) {
        print('  Image ${i + 1}: ${images[i]}');
      }
    } catch (e) {
      print('[QuickImageFix] Error testing fix: $e');
      rethrow;
    }
  }
} 