import 'package:supabase_flutter/supabase_flutter.dart';
import 'service_image_manager.dart';

class ImageBatchProcessor {
  static final ImageBatchProcessor _instance = ImageBatchProcessor._internal();
  factory ImageBatchProcessor() => _instance;
  ImageBatchProcessor._internal();

  final ServiceImageManager _imageManager = ServiceImageManager();

  /// Quick fix: Update all services with placeholder images
  Future<void> quickFixAllServiceImages() async {
    try {
      print('[ImageBatchProcessor] Starting quick fix for all service images...');
      
      // Get all services that need images
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
          
          // Check if service already has images
          final existingDetails = await Supabase.instance.client
              .from('service_details')
              .select('images_url')
              .eq('service_id', serviceId)
              .maybeSingle();
          
          if (existingDetails != null && 
              existingDetails['images_url'] != null && 
              (existingDetails['images_url'] as List).isNotEmpty) {
            print('[ImageBatchProcessor] Service $serviceId already has images, skipping...');
            continue;
          }
          
          // Generate category-specific images
          final int categoryId = service['category_level1_id'] ?? service['category_level2_id'] ?? 0;
          final String category = await _getCategoryCode(categoryId);
          
          final List<String> images = _imageManager.generateTestImagesForService(
            serviceId: serviceId,
            category: category,
            count: 2,
          );
          
          // Update or insert service details
          await _updateServiceDetails(serviceId, images);
          
          processedCount++;
          print('[ImageBatchProcessor] Processed service: $serviceName (ID: $serviceId)');
          
        } catch (e) {
          errorCount++;
          print('[ImageBatchProcessor] Error processing service ${service['id']}: $e');
        }
      }
      
      print('[ImageBatchProcessor] Quick fix completed!');
      print('[ImageBatchProcessor] Successfully processed: $processedCount services');
      print('[ImageBatchProcessor] Errors: $errorCount services');
      
    } catch (e) {
      print('[ImageBatchProcessor] Error in quick fix: $e');
      rethrow;
    }
  }

  /// Update specific service with new images
  Future<void> updateServiceImages({
    required String serviceId,
    required String category,
    int imageCount = 3,
  }) async {
    try {
      final List<String> images = _imageManager.generateTestImagesForService(
        serviceId: serviceId,
        category: category,
        count: imageCount,
      );
      
      await _updateServiceDetails(serviceId, images);
      
      print('[ImageBatchProcessor] Updated service $serviceId with ${images.length} images');
    } catch (e) {
      print('[ImageBatchProcessor] Error updating service $serviceId: $e');
      rethrow;
    }
  }

  /// Get category code from category ID
  Future<String> _getCategoryCode(int categoryId) async {
    try {
      final response = await Supabase.instance.client
          .from('ref_codes')
          .select('code')
          .eq('id', categoryId)
          .maybeSingle();
      
      return response?['code'] ?? 'LIFESTYLE';
    } catch (e) {
      print('[ImageBatchProcessor] Error getting category code: $e');
      return 'LIFESTYLE';
    }
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
        // Insert new record
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
      print('[ImageBatchProcessor] Error updating service details: $e');
      rethrow;
    }
  }

  /// Generate sample images for testing
  Future<void> generateSampleImagesForTesting() async {
    try {
      print('[ImageBatchProcessor] Generating sample images for testing...');
      
      // Sample services with different categories
      final List<Map<String, dynamic>> sampleServices = [
        {'id': 'sample-food-1', 'category': 'FOOD', 'name': '美食外卖'},
        {'id': 'sample-home-1', 'category': 'HOME', 'name': '家居清洁'},
        {'id': 'sample-transport-1', 'category': 'TRANSPORT', 'name': '机场接送'},
        {'id': 'sample-beauty-1', 'category': 'BEAUTY', 'name': '美容美发'},
        {'id': 'sample-wellness-1', 'category': 'WELLNESS', 'name': '按摩理疗'},
        {'id': 'sample-tech-1', 'category': 'TECH_SUPPORT', 'name': '技术支持'},
      ];
      
      for (final service in sampleServices) {
        final List<String> images = _imageManager.generateTestImagesForService(
          serviceId: service['id'],
          category: service['category'],
          count: 3,
        );
        
        print('[ImageBatchProcessor] Generated ${images.length} images for ${service['name']}:');
        for (int i = 0; i < images.length; i++) {
          print('  Image ${i + 1}: ${images[i]}');
        }
        print('');
      }
      
    } catch (e) {
      print('[ImageBatchProcessor] Error generating sample images: $e');
      rethrow;
    }
  }

  /// Validate all service images
  Future<Map<String, dynamic>> validateAllServiceImages() async {
    try {
      print('[ImageBatchProcessor] Validating all service images...');
      
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
            if (_imageManager.isValidImageUrl(imageUrl.toString())) {
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
      
      print('[ImageBatchProcessor] Validation completed:');
      print('  Total services: $totalServices');
      print('  Valid images: $validImages');
      print('  Invalid images: $invalidImages');
      print('  Services with issues: ${servicesWithIssues.length}');
      
      return result;
    } catch (e) {
      print('[ImageBatchProcessor] Error validating images: $e');
      rethrow;
    }
  }
} 