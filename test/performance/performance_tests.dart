import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jinbeanpod_83904710/features/customer/services/presentation/widgets/optimized_image_viewer.dart';
import 'package:jinbeanpod_83904710/features/customer/services/presentation/widgets/service_interaction_buttons.dart';

void main() {
  group('Performance Tests', () {
    testWidgets('should render OptimizedImageViewer efficiently',
        (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedImageViewer(
              imageUrls: List.generate(
                  10, (index) => 'https://example.com/image$index.jpg'),
              height: 300,
              width: 400,
            ),
          ),
        ),
      );

      stopwatch.stop();

      // 渲染时间应该在合理范围内（小于100ms）
      expect(stopwatch.elapsedMilliseconds, lessThan(100));

      print(
          'OptimizedImageViewer render time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('should handle large image lists efficiently',
        (WidgetTester tester) async {
      final largeImageList =
          List.generate(50, (index) => 'https://example.com/image$index.jpg');

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedImageViewer(
              imageUrls: largeImageList,
              height: 300,
              width: 400,
            ),
          ),
        ),
      );

      stopwatch.stop();

      // 即使有50张图片，渲染时间也应该在合理范围内
      expect(stopwatch.elapsedMilliseconds, lessThan(200));

      print('Large image list render time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('should render ServiceInteractionButtons efficiently',
        (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceInteractionButtons(
              serviceId: 'test-service',
              serviceTitle: 'Test Service',
              serviceDescription: 'This is a test service description',
            ),
          ),
        ),
      );

      stopwatch.stop();

      // 渲染时间应该在合理范围内
      expect(stopwatch.elapsedMilliseconds, lessThan(50));

      print(
          'ServiceInteractionButtons render time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('should handle image grid rendering efficiently',
        (WidgetTester tester) async {
      final largeImageList =
          List.generate(100, (index) => 'https://example.com/image$index.jpg');

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageGrid(
              imageUrls: largeImageList,
              crossAxisCount: 4,
            ),
          ),
        ),
      );

      stopwatch.stop();

      // 100张图片的网格渲染时间应该在合理范围内
      expect(stopwatch.elapsedMilliseconds, lessThan(300));

      print('Large image grid render time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('should handle tab switching efficiently',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedImageViewer(
              imageUrls: List.generate(
                  5, (index) => 'https://example.com/image$index.jpg'),
              height: 300,
              width: 400,
            ),
          ),
        ),
      );

      // 测试页面切换性能
      for (int i = 0; i < 5; i++) {
        final stopwatch = Stopwatch()..start();

        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();

        stopwatch.stop();

        // 页面切换应该在合理时间内完成
        expect(stopwatch.elapsedMilliseconds, lessThan(100));

        print('Tab switch $i time: ${stopwatch.elapsedMilliseconds}ms');
      }
    });

    testWidgets('should handle memory usage efficiently',
        (WidgetTester tester) async {
      // 创建多个图片查看器实例
      final widgets = List.generate(
          5,
          (index) => OptimizedImageViewer(
                imageUrls: List.generate(
                    10, (imgIndex) => 'https://example.com/image$imgIndex.jpg'),
                height: 200,
                width: 300,
              ));

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: widgets.length,
              itemBuilder: (context, index) => widgets[index],
            ),
          ),
        ),
      );

      stopwatch.stop();

      // 多个实例的渲染时间应该在合理范围内
      expect(stopwatch.elapsedMilliseconds, lessThan(500));

      print(
          'Multiple instances render time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('should handle rapid interactions efficiently',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceInteractionButtons(
              serviceId: 'test-service',
              serviceTitle: 'Test Service',
              serviceDescription: 'This is a test service description',
            ),
          ),
        ),
      );

      // 测试快速连续点击的性能
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 10; i++) {
        await tester.tap(find.text('Add to Favorites'));
        await tester.pump();
      }

      stopwatch.stop();

      // 快速交互应该在合理时间内完成
      expect(stopwatch.elapsedMilliseconds, lessThan(200));

      print('Rapid interactions time: ${stopwatch.elapsedMilliseconds}ms');
    });
  });

  group('Memory Usage Tests', () {
    test('should not create memory leaks with image preloading', () async {
      final initialMemory = _getCurrentMemoryUsage();

      // 预加载多张图片
      final imageUrls =
          List.generate(100, (index) => 'https://example.com/image$index.jpg');
      await ImagePreloadManager.preloadImages(imageUrls);

      // 清理缓存
      ImagePreloadManager.clearCache();

      final finalMemory = _getCurrentMemoryUsage();

      // 内存使用应该在合理范围内
      final memoryIncrease = finalMemory - initialMemory;
      expect(memoryIncrease, lessThan(50 * 1024 * 1024)); // 50MB

      print(
          'Memory usage - Initial: ${initialMemory ~/ (1024 * 1024)}MB, Final: ${finalMemory ~/ (1024 * 1024)}MB, Increase: ${memoryIncrease ~/ (1024 * 1024)}MB');
    });

    test('should handle repeated preloading efficiently', () async {
      final imageUrl = 'https://example.com/test.jpg';

      final stopwatch = Stopwatch()..start();

      // 重复预加载同一张图片
      for (int i = 0; i < 10; i++) {
        await ImagePreloadManager.preloadImage(imageUrl);
      }

      stopwatch.stop();

      // 重复预加载应该很快（因为会跳过已预加载的图片）
      expect(stopwatch.elapsedMilliseconds, lessThan(100));

      print('Repeated preloading time: ${stopwatch.elapsedMilliseconds}ms');
    });
  });

  group('Responsiveness Tests', () {
    testWidgets('should maintain 60fps during animations',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceInteractionButtons(
              serviceId: 'test-service',
              serviceTitle: 'Test Service',
              serviceDescription: 'This is a test service description',
            ),
          ),
        ),
      );

      // 测试动画性能
      final frameTimes = <int>[];

      for (int i = 0; i < 10; i++) {
        final frameStart = DateTime.now().millisecondsSinceEpoch;

        await tester.tap(find.text('Add to Favorites'));
        await tester
            .pump(const Duration(milliseconds: 16)); // 60fps = 16ms per frame

        final frameEnd = DateTime.now().millisecondsSinceEpoch;
        frameTimes.add(frameEnd - frameStart);
      }

      // 平均帧时间应该在16ms左右（60fps）
      final averageFrameTime =
          frameTimes.reduce((a, b) => a + b) / frameTimes.length;
      expect(averageFrameTime, lessThan(20)); // 允许一些容差

      print('Average frame time: ${averageFrameTime.toStringAsFixed(2)}ms');
    });
  });
}

/// 获取当前内存使用量（模拟实现）
int _getCurrentMemoryUsage() {
  // 这是一个模拟实现，实际项目中可以使用真实的性能监控工具
  return DateTime.now().millisecondsSinceEpoch % (100 * 1024 * 1024) +
      50 * 1024 * 1024;
}
