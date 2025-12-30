import 'package:flutter/foundation.dart';

/// 图片URL解析和验证工具类
///
/// 提供统一的图片URL解析、验证和过滤功能
class ImageParser {
  // 私有构造函数，防止实例化
  ImageParser._();

  /// 解析并验证图片URL列表
  ///
  /// [rawImages] 可以是 List<String>, List<dynamic>, 或 null
  /// 返回验证后的图片URL列表，如果解析失败或为空返回null
  static List<String>? parseImagesUrl(dynamic rawImages) {
    if (rawImages == null) {
      if (kDebugMode) {
        debugPrint('🖼️ [ImageParser] Raw images is null');
      }
      return null;
    }

    try {
      // 转换为字符串列表
      final List<String> urls = List<String>.from(rawImages);

      // 过滤掉无效的URL
      final validUrls = urls.where(_isValidImageUrl).toList();

      if (kDebugMode) {
        debugPrint('🖼️ [ImageParser] Parsed ${validUrls.length}/${urls.length} valid images');
        if (validUrls.length != urls.length) {
          final invalidUrls = urls.where((url) => !_isValidImageUrl(url)).toList();
          debugPrint('⚠️ [ImageParser] Filtered out invalid URLs: $invalidUrls');
        }
      }

      return validUrls.isEmpty ? null : validUrls;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [ImageParser] Failed to parse images: $e');
      }
      return null;
    }
  }

  /// 验证单个图片URL是否有效
  ///
  /// 检查条件：
  /// - URL不为空
  /// - URL以http或https开头
  /// - URL不包含占位符域名
  static bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;

    // 检查是否为占位符URL
    if (_isPlaceholderUrl(url)) return false;

    // 检查URL格式
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute &&
             (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [ImageParser] Invalid URL format: $url');
      }
      return false;
    }
  }

  /// 检查是否为占位符URL
  static bool _isPlaceholderUrl(String url) {
    final placeholderPatterns = [
      'placeholder.com',
      'example.com',
      'test.com',
      '/test/',
      '/placeholder/',
    ];

    return placeholderPatterns.any((pattern) =>
      url.toLowerCase().contains(pattern.toLowerCase())
    );
  }

  /// 获取优化后的图片URL（根据设备像素比调整尺寸）
  ///
  /// 目前仅支持Unsplash图片的尺寸优化
  static String getOptimizedUrl(String baseUrl, {double pixelRatio = 1.0}) {
    // 根据像素比选择合适的图片宽度
    final width = pixelRatio > 2 ? 1200 : (pixelRatio > 1 ? 800 : 600);

    // 如果是Unsplash图片，添加尺寸参数
    if (baseUrl.contains('unsplash.com')) {
      final uri = Uri.parse(baseUrl);
      final params = Map<String, String>.from(uri.queryParameters);

      // 更新或添加尺寸参数
      params['w'] = width.toString();
      params['q'] = '80'; // 质量80%

      return uri.replace(queryParameters: params).toString();
    }

    return baseUrl;
  }

  /// 验证图片URL列表是否包含有效图片
  static bool hasValidImages(List<String>? images) {
    if (images == null || images.isEmpty) return false;
    return images.any(_isValidImageUrl);
  }

  /// 获取第一个有效的图片URL
  static String? getFirstValidImage(List<String>? images) {
    if (images == null || images.isEmpty) return null;

    try {
      return images.firstWhere(_isValidImageUrl);
    } catch (e) {
      return null;
    }
  }

  /// 过滤并返回所有有效的图片URL
  static List<String> getValidImages(List<String>? images) {
    if (images == null || images.isEmpty) return [];
    return images.where(_isValidImageUrl).toList();
  }
}
