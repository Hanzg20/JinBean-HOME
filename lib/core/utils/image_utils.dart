import 'package:flutter/material.dart';

class ImageUtils {
  /// Validate if URL is a valid image URL
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    try {
      final Uri uri = Uri.parse(url);
      if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return false;
      }

      // Check for common image extensions
      final String path = uri.path.toLowerCase();
      return path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.png') ||
          path.endsWith('.gif') ||
          path.endsWith('.webp') ||
          path.endsWith('.svg') ||
          path.contains('picsum.photos') ||
          path.contains('placeholder.com') ||
          path.contains('via.placeholder.com');
    } catch (e) {
      return false;
    }
  }

  /// Get fallback image widget
  static Widget getFallbackImage({
    double? width,
    double? height,
    String? text,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
  }) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 48,
                color: textColor ?? Colors.grey[600],
              ),
              const SizedBox(height: 8),
            ],
            if (text != null)
              Text(
                text,
                style: TextStyle(
                  color: textColor ?? Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  /// Get placeholder image URL
  static String getPlaceholderUrl({
    int width = 300,
    int height = 200,
    String text = 'No Image',
    String backgroundColor = 'CCCCCC',
    String textColor = '666666',
  }) {
    return 'https://via.placeholder.com/${width}x$height/$backgroundColor/$textColor?text=${Uri.encodeComponent(text)}';
  }

  /// Get category-specific placeholder URL
  static String getCategoryPlaceholderUrl({
    required String category,
    int width = 300,
    int height = 200,
  }) {
    final Map<String, String> categoryTexts = {
      'FOOD': '🍽️ Food Service',
      'HOME': '🏠 Home Service',
      'TRANSPORT': '🚗 Transport',
      'SHARING': '🤝 Sharing',
      'EDUCATION': '📚 Education',
      'LIFESTYLE': '💎 Lifestyle',
      'CLEANING': '🧹 Cleaning',
      'REPAIR': '🔧 Repair',
      'BEAUTY': '💄 Beauty',
      'WELLNESS': '🧘 Wellness',
      'TECH_SUPPORT': '💻 Tech Support',
    };

    final String text = categoryTexts[category] ?? '📋 Service';
    return getPlaceholderUrl(
      width: width,
      height: height,
      text: text,
      backgroundColor: '4A90E2',
      textColor: 'FFFFFF',
    );
  }

  /// Get random test image URL
  static String getRandomTestImageUrl({
    int width = 300,
    int height = 200,
    int? seed,
  }) {
    final int imageSeed = seed ?? DateTime.now().millisecondsSinceEpoch;
    return 'https://picsum.photos/seed/$imageSeed/$width/$height';
  }

  /// Get category-specific test image URL
  static String getCategoryTestImageUrl({
    required String category,
    int width = 300,
    int height = 200,
    int? seed,
  }) {
    final int imageSeed = seed ?? DateTime.now().millisecondsSinceEpoch;
    final String categorySuffix = category.toLowerCase().replaceAll('_', '-');
    return 'https://picsum.photos/seed/${imageSeed}_$categorySuffix/$width/$height';
  }

  /// Build image widget with error handling
  static Widget buildImageWidget({
    required String? imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    String? fallbackText,
    IconData? fallbackIcon,
    Color? fallbackBackgroundColor,
    Color? fallbackTextColor,
  }) {
    if (imageUrl == null || imageUrl.isEmpty || !isValidImageUrl(imageUrl)) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: getFallbackImage(
          width: width,
          height: height,
          text: fallbackText ?? 'No Image',
          icon: fallbackIcon ?? Icons.image_not_supported,
          backgroundColor: fallbackBackgroundColor,
          textColor: fallbackTextColor,
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return getFallbackImage(
            width: width,
            height: height,
            text: fallbackText ?? 'Load Failed',
            icon: fallbackIcon ?? Icons.broken_image,
            backgroundColor: fallbackBackgroundColor,
            textColor: fallbackTextColor,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Get service type icon
  static IconData getServiceTypeIcon(String serviceType) {
    final Map<String, IconData> serviceIcons = {
      'FOOD': Icons.restaurant,
      'HOME': Icons.home,
      'TRANSPORT': Icons.directions_car,
      'SHARING': Icons.share,
      'EDUCATION': Icons.school,
      'LIFESTYLE': Icons.work,
      'CLEANING': Icons.cleaning_services,
      'REPAIR': Icons.build,
      'BEAUTY': Icons.face,
      'WELLNESS': Icons.spa,
      'TECH_SUPPORT': Icons.computer,
    };

    return serviceIcons[serviceType] ?? Icons.category;
  }

  /// Get service type color
  static Color getServiceTypeColor(String serviceType) {
    final Map<String, Color> serviceColors = {
      'FOOD': Colors.orange,
      'HOME': Colors.blue,
      'TRANSPORT': Colors.green,
      'SHARING': Colors.purple,
      'EDUCATION': Colors.indigo,
      'LIFESTYLE': Colors.pink,
      'CLEANING': Colors.teal,
      'REPAIR': Colors.amber,
      'BEAUTY': Colors.red,
      'WELLNESS': Colors.lightGreen,
      'TECH_SUPPORT': Colors.cyan,
    };

    return serviceColors[serviceType] ?? Colors.grey;
  }
}
