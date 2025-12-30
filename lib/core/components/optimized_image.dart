import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/image_parser.dart';

/// 优化的网络图片组件
///
/// 特性：
/// - 自动缓存
/// - 加载占位符
/// - 错误处理
/// - 自动尺寸优化
/// - Shimmer加载效果
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool enableOptimization;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.enableOptimization = true,
  });

  @override
  Widget build(BuildContext context) {
    // 获取优化后的URL
    final optimizedUrl = enableOptimization
        ? ImageParser.getOptimizedUrl(
            imageUrl,
            pixelRatio: MediaQuery.of(context).devicePixelRatio,
          )
        : imageUrl;

    Widget imageWidget = CachedNetworkImage(
      imageUrl: optimizedUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ?? _buildDefaultPlaceholder(),
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildDefaultErrorWidget(),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
    );

    // 如果有圆角，包装在ClipRRect中
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  /// 默认的加载占位符（Shimmer效果）
  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE0E0E0),
            Color(0xFFF5F5F5),
            Color(0xFFE0E0E0),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
    );
  }

  /// 默认的错误显示组件
  Widget _buildDefaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: (height != null && height! < 100) ? 24 : 48,
            color: Colors.grey[400],
          ),
          if (height == null || height! >= 100) ...[
            const SizedBox(height: 8),
            Text(
              '图片加载失败',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 圆形头像图片组件
class OptimizedAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Widget? placeholder;
  final Color? backgroundColor;

  const OptimizedAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.placeholder,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty || !ImageParser.hasValidImages([imageUrl!])) {
      return _buildPlaceholder();
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[200],
      child: ClipOval(
        child: OptimizedImage(
          imageUrl: imageUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorWidget: _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? Colors.grey[200],
          child: Icon(
            Icons.person_outline,
            size: radius,
            color: Colors.grey[400],
          ),
        );
  }
}

/// 图片轮播/画廊组件
class OptimizedImageGallery extends StatelessWidget {
  final List<String> imageUrls;
  final double height;
  final BorderRadius? borderRadius;
  final bool showIndicator;

  const OptimizedImageGallery({
    super.key,
    required this.imageUrls,
    this.height = 200,
    this.borderRadius,
    this.showIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    // 过滤出有效的图片URL
    final validImages = ImageParser.getValidImages(imageUrls);

    if (validImages.isEmpty) {
      return _buildEmptyState();
    }

    if (validImages.length == 1) {
      // 单张图片，直接显示
      return OptimizedImage(
        imageUrl: validImages[0],
        height: height,
        width: double.infinity,
        borderRadius: borderRadius,
      );
    }

    // 多张图片，使用PageView
    return SizedBox(
      height: height,
      child: PageView.builder(
        itemCount: validImages.length,
        itemBuilder: (context, index) {
          return OptimizedImage(
            imageUrl: validImages[index],
            height: height,
            width: double.infinity,
            borderRadius: borderRadius,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '精美图片即将呈现',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
