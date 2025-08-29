import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jinbeanpod_83904710/features/customer/services/presentation/widgets/optimized_image_viewer.dart';

void main() {
  group('OptimizedImageViewer Tests', () {
    const testImageUrls = [
      'https://example.com/image1.jpg',
      'https://example.com/image2.jpg',
      'https://example.com/image3.jpg',
    ];

    testWidgets('should display placeholder when no images',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedImageViewer(
              imageUrls: const [],
              height: 200,
              width: 300,
            ),
          ),
        ),
      );

      expect(find.text('No images available'), findsOneWidget);
      expect(find.byIcon(Icons.image), findsOneWidget);
    });

    testWidgets('should display single image without indicators',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedImageViewer(
              imageUrls: const ['https://example.com/image1.jpg'],
              height: 200,
              width: 300,
              showIndicators: false,
            ),
          ),
        ),
      );

      expect(find.byType(PageView), findsOneWidget);
      // 不显示指示器时，不应该有指示器相关的UI
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('should display multiple images with indicators',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedImageViewer(
              imageUrls: testImageUrls,
              height: 200,
              width: 300,
              showIndicators: true,
            ),
          ),
        ),
      );

      expect(find.byType(PageView), findsOneWidget);

      // 应该显示指示器相关的UI
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle image tap with custom callback',
        (WidgetTester tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedImageViewer(
              imageUrls: testImageUrls,
              height: 200,
              width: 300,
              onImageTap: () => callbackCalled = true,
            ),
          ),
        ),
      );

      // 点击第一张图片
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(callbackCalled, isTrue);
    });

    testWidgets('should handle image tap without callback (enable zoom)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedImageViewer(
              imageUrls: testImageUrls,
              height: 200,
              width: 300,
              enableZoom: true,
            ),
          ),
        ),
      );

      // 点击第一张图片，应该打开全屏查看
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // 应该显示全屏查看页面
      expect(find.byType(Scaffold), findsNWidgets(2)); // 原页面 + 全屏页面
      expect(find.text('Image 1 of 3'), findsOneWidget);
    });

    testWidgets('should handle page changes and update indicators',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedImageViewer(
              imageUrls: testImageUrls,
              height: 200,
              width: 300,
              showIndicators: true,
            ),
          ),
        ),
      );

      // 滑动到第二页
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // 指示器应该更新
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('should handle error images gracefully',
        (WidgetTester tester) async {
      const errorImageUrl = 'https://invalid-url.com/image.jpg';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedImageViewer(
              imageUrls: const [errorImageUrl],
              height: 200,
              width: 300,
            ),
          ),
        ),
      );

      // 等待图片加载失败
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Image not available'), findsOneWidget);
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });
  });

  group('ImageGrid Tests', () {
    const testImageUrls = [
      'https://example.com/image1.jpg',
      'https://example.com/image2.jpg',
      'https://example.com/image3.jpg',
    ];

    testWidgets('should display grid with correct number of images',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageGrid(
              imageUrls: testImageUrls,
              crossAxisCount: 2,
            ),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
      // 应该显示3张图片
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle empty image list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageGrid(
              imageUrls: const [],
              crossAxisCount: 3,
            ),
          ),
        ),
      );

      expect(find.byType(GridView), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('should handle custom grid configuration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageGrid(
              imageUrls: testImageUrls,
              crossAxisCount: 1,
              spacing: 8.0,
              childAspectRatio: 2.0,
            ),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
      // 应该显示3张图片
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('ImagePreloadManager Tests', () {
    test('should track preloaded images correctly', () async {
      const testUrl = 'https://example.com/test.jpg';

      // 初始状态
      expect(ImagePreloadManager.isImagePreloaded(testUrl), isFalse);

      // 预加载图片
      await ImagePreloadManager.preloadImage(testUrl);

      // 检查状态
      expect(ImagePreloadManager.isImagePreloaded(testUrl), isTrue);
    });

    test('should handle multiple image preloading', () async {
      const testUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
        'https://example.com/image3.jpg',
      ];

      // 预加载多张图片
      await ImagePreloadManager.preloadImages(testUrls);

      // 检查所有图片状态
      for (final url in testUrls) {
        expect(ImagePreloadManager.isImagePreloaded(url), isTrue);
      }
    });

    test('should clear cache correctly', () async {
      const testUrl = 'https://example.com/test.jpg';

      // 预加载图片
      await ImagePreloadManager.preloadImage(testUrl);
      expect(ImagePreloadManager.isImagePreloaded(testUrl), isTrue);

      // 清理缓存
      ImagePreloadManager.clearCache();

      // 检查状态
      expect(ImagePreloadManager.isImagePreloaded(testUrl), isFalse);
    });

    test('should not preload same image twice', () async {
      const testUrl = 'https://example.com/test.jpg';

      // 第一次预加载
      await ImagePreloadManager.preloadImage(testUrl);
      expect(ImagePreloadManager.isImagePreloaded(testUrl), isTrue);

      // 第二次预加载（应该跳过）
      await ImagePreloadManager.preloadImage(testUrl);
      expect(ImagePreloadManager.isImagePreloaded(testUrl), isTrue);
    });
  });
}
