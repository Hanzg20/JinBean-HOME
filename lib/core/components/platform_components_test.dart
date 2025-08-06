import 'package:flutter/material.dart';
import 'platform_core.dart';

/// 平台组件测试页面
class PlatformComponentsTestPage extends StatelessWidget {
  const PlatformComponentsTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Platform Components Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 骨架屏测试
            _buildSectionTitle('Skeleton System Test'),
            PlatformCore.createSkeleton(
              type: SkeletonType.list,
            ),
            const SizedBox(height: 24),
            
            // 渐进式加载测试
            _buildSectionTitle('Progressive Loading Test'),
            PlatformCore.createProgressiveLoading(
              type: ProgressiveType.sequential,
              loadFunction: () async {
                await Future.delayed(Duration(seconds: 2));
              },
              contentBuilder: (context) => _buildTestContent('Progressive Loading Content'),
            ),
            const SizedBox(height: 24),
            
            // 离线支持测试
            _buildSectionTitle('Offline Support Test'),
            PlatformCore.createOfflineSupport(
              type: OfflineType.hybrid,
              onlineBuilder: (context) => _buildTestContent('Online Content'),
              offlineBuilder: (context) => _buildTestContent('Offline Content'),
            ),
            const SizedBox(height: 24),
            
            // 错误恢复测试
            _buildSectionTitle('Error Recovery Test'),
            PlatformCore.createErrorRecovery(
              type: ErrorRecoveryType.automatic,
              contentBuilder: (context) => _buildTestContent('Normal Content'),
              recoveryFunction: () async {
                await Future.delayed(Duration(seconds: 1));
                throw Exception('Test error');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTestContent(String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue),
      ),
      child: Text(
        content,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
} 