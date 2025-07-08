import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceImageManager {
  static final ServiceImageManager _instance = ServiceImageManager._internal();
  factory ServiceImageManager() => _instance;
  ServiceImageManager._internal();

  /// Generate test images for services based on category
  List<String> generateTestImagesForService({
    required String serviceId,
    required String category,
    int count = 3,
  }) {
    List<String> images = [];

    // Generate category-specific test images
    for (int i = 0; i < count; i++) {
      final int seed = _generateSeedFromServiceId(serviceId, i);
      final String imageUrl = _getCategorySpecificImage(category, seed);
      images.add(imageUrl);
    }

    return images;
  }

  /// Generate seed from service ID for consistent image generation
  int _generateSeedFromServiceId(String serviceId, int index) {
    int hash = 0;
    for (int i = 0; i < serviceId.length; i++) {
      hash = ((hash << 5) - hash + serviceId.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return (hash + index) & 0xFFFFFFFF;
  }

  /// Get category-specific image URL
  String _getCategorySpecificImage(String category, int seed) {
    // Map categories to specific image themes
    final Map<String, String> categoryThemes = {
      'FOOD': 'food',
      'HOME': 'home',
      'TRANSPORT': 'transport',
      'SHARING': 'sharing',
      'EDUCATION': 'education',
      'LIFESTYLE': 'lifestyle',
      'CLEANING': 'cleaning',
      'REPAIR': 'repair',
      'BEAUTY': 'beauty',
      'WELLNESS': 'wellness',
      'TECH_SUPPORT': 'tech',
    };

    final String theme = categoryThemes[category] ?? 'service';

    // Use different image services based on theme
    switch (theme) {
      case 'food':
        return 'https://picsum.photos/seed/${seed}_food/400/300';
      case 'home':
        return 'https://picsum.photos/seed/${seed}_home/400/300';
      case 'cleaning':
        return 'https://picsum.photos/seed/${seed}_cleaning/400/300';
      case 'beauty':
        return 'https://picsum.photos/seed/${seed}_beauty/400/300';
      case 'wellness':
        return 'https://picsum.photos/seed/${seed}_wellness/400/300';
      case 'tech':
        return 'https://picsum.photos/seed/${seed}_tech/400/300';
      default:
        return 'https://picsum.photos/seed/$seed/400/300';
    }
  }

  /// Update service images in database
  Future<void> updateServiceImages({
    required String serviceId,
    required List<String> imageUrls,
  }) async {
    try {
      await Supabase.instance.client.from('service_details').update({
        'images_url': imageUrls,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('service_id', serviceId);

      print('[ServiceImageManager] Updated images for service $serviceId');
    } catch (e) {
      print('[ServiceImageManager] Error updating service images: $e');
      rethrow;
    }
  }

  /// Batch update all services with test images
  Future<void> batchUpdateAllServicesWithTestImages() async {
    try {
      print('[ServiceImageManager] Starting batch update of service images...');

      // Get all services
      final services = await Supabase.instance.client
          .from('services')
          .select('id, category_level1_id, category_level2_id');

      int updatedCount = 0;

      for (final service in services) {
        final String serviceId = service['id'];
        final int categoryId =
            service['category_level1_id'] ?? service['category_level2_id'] ?? 0;

        // Get category name
        final categoryResponse = await Supabase.instance.client
            .from('ref_codes')
            .select('code')
            .eq('id', categoryId)
            .single();

        final String category = categoryResponse['code'] ?? 'LIFESTYLE';

        // Generate test images
        final List<String> testImages = generateTestImagesForService(
          serviceId: serviceId,
          category: category,
          count: 3,
        );

        // Update service details
        await updateServiceImages(
          serviceId: serviceId,
          imageUrls: testImages,
        );

        updatedCount++;
        print(
            '[ServiceImageManager] Updated service $serviceId with ${testImages.length} images');
      }

      print(
          '[ServiceImageManager] Batch update completed. Updated $updatedCount services.');
    } catch (e) {
      print('[ServiceImageManager] Error in batch update: $e');
      rethrow;
    }
  }

  /// Get placeholder image for specific service type
  String getPlaceholderImage({
    required String serviceType,
    int width = 400,
    int height = 300,
  }) {
    final Map<String, String> serviceIcons = {
      'FOOD': '🍽️',
      'HOME': '🏠',
      'TRANSPORT': '🚗',
      'SHARING': '🤝',
      'EDUCATION': '📚',
      'LIFESTYLE': '💎',
      'CLEANING': '🧹',
      'REPAIR': '🔧',
      'BEAUTY': '💄',
      'WELLNESS': '🧘',
      'TECH_SUPPORT': '💻',
    };

    final String icon = serviceIcons[serviceType] ?? '📋';
    final String text = '$icon $serviceType';

    return 'https://via.placeholder.com/${width}x$height/4A90E2/FFFFFF?text=${Uri.encodeComponent(text)}';
  }

  /// Validate image URL
  bool isValidImageUrl(String url) {
    if (url.isEmpty) return false;

    try {
      final Uri uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Get fallback image URL
  String getFallbackImageUrl() {
    return 'https://via.placeholder.com/400x300/CCCCCC/666666?text=No+Image';
  }
}
