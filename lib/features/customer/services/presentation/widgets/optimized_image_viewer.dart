import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 优化的图片查看器组件
class OptimizedImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final double width;
  final BoxFit fit;
  final bool enableZoom;
  final bool showIndicators;
  final VoidCallback? onImageTap;

  const OptimizedImageViewer({
    super.key,
    required this.imageUrls,
    this.height = 200,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.enableZoom = true,
    this.showIndicators = true,
    this.onImageTap,
  });

  @override
  State<OptimizedImageViewer> createState() => _OptimizedImageViewerState();
}

class _OptimizedImageViewerState extends State<OptimizedImageViewer> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return _buildPlaceholder();
    }

    return Column(
      children: [
        // 图片展示区域
        SizedBox(
          height: widget.height,
          width: widget.width,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return _buildImageItem(widget.imageUrls[index], index);
            },
          ),
        ),

        // 指示器
        if (widget.showIndicators && widget.imageUrls.length > 1)
          _buildPageIndicator(),
      ],
    );
  }

  Widget _buildImageItem(String imageUrl, int index) {
    return GestureDetector(
      onTap: () => _handleImageTap(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: widget.fit,
            placeholder: (context, url) => _buildLoadingPlaceholder(),
            errorWidget: (context, url, error) => _buildErrorPlaceholder(),
            memCacheWidth:
                (widget.width * MediaQuery.of(context).devicePixelRatio)
                    .round(),
            memCacheHeight:
                (widget.height * MediaQuery.of(context).devicePixelRatio)
                    .round(),
            fadeInDuration: const Duration(milliseconds: 300),
            fadeOutDuration: const Duration(milliseconds: 300),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('Image not available'),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 80, color: Colors.grey),
            SizedBox(height: 8),
            Text('No images available'),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.imageUrls.length,
          (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == _currentIndex
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }

  void _handleImageTap(int index) {
    if (widget.onImageTap != null) {
      widget.onImageTap!();
    } else if (widget.enableZoom) {
      _showFullScreenGallery(index);
    }
  }

  void _showFullScreenGallery(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title:
                Text('Image ${initialIndex + 1} of ${widget.imageUrls.length}'),
          ),
          body: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrls[index],
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.broken_image,
                          color: Colors.white, size: 48),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 图片网格组件 - 用于显示多张图片
class ImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  final int crossAxisCount;
  final double spacing;
  final double childAspectRatio;
  final VoidCallback? onImageTap;
  final bool enableZoom;

  const ImageGrid({
    super.key,
    required this.imageUrls,
    this.crossAxisCount = 3,
    this.spacing = 4.0,
    this.childAspectRatio = 1.0,
    this.onImageTap,
    this.enableZoom = true,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return _buildGridImage(imageUrls[index], index);
      },
    );
  }

  Widget _buildGridImage(String imageUrl, int index) {
    return GestureDetector(
      onTap: () => _handleImageTap(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildGridLoadingPlaceholder(),
            errorWidget: (context, url, error) => _buildGridErrorPlaceholder(),
            memCacheWidth: 300,
            memCacheHeight: 300,
          ),
        ),
      ),
    );
  }

  Widget _buildGridLoadingPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildGridErrorPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }

  void _handleImageTap(int index) {
    if (onImageTap != null) {
      onImageTap!();
    } else if (enableZoom) {
      // 可以在这里实现网格图片的放大查看
    }
  }
}

/// 图片预加载管理器
class ImagePreloadManager {
  static final Map<String, bool> _preloadedImages = {};
  static final Map<String, ImageProvider> _imageCache = {};

  /// 预加载图片
  static Future<void> preloadImage(String imageUrl) async {
    if (_preloadedImages[imageUrl] == true) return;

    try {
      final imageProvider = CachedNetworkImageProvider(imageUrl);
      final stream = imageProvider.resolve(const ImageConfiguration());
      final completer = Completer<void>();

      stream.addListener(ImageStreamListener((info, _) {
        completer.complete();
      }));

      await completer.future;
      _preloadedImages[imageUrl] = true;
      _imageCache[imageUrl] = imageProvider;
    } catch (e) {
      _preloadedImages[imageUrl] = false;
    }
  }

  /// 预加载多张图片
  static Future<void> preloadImages(List<String> imageUrls) async {
    await Future.wait(
      imageUrls.map((url) => preloadImage(url)),
    );
  }

  /// 检查图片是否已预加载
  static bool isImagePreloaded(String imageUrl) {
    return _preloadedImages[imageUrl] == true;
  }

  /// 获取缓存的图片提供者
  static ImageProvider? getCachedImage(String imageUrl) {
    return _imageCache[imageUrl];
  }

  /// 清理缓存
  static void clearCache() {
    _preloadedImages.clear();
    _imageCache.clear();
  }
}
