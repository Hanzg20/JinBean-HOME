import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'widgets/service_detail_loading.dart';

/// 测试加载状态设计的页面
class TestLoadingPage extends StatefulWidget {
  const TestLoadingPage({Key? key}) : super(key: key);

  @override
  State<TestLoadingPage> createState() => _TestLoadingPageState();
}

class _TestLoadingPageState extends State<TestLoadingPage> {
  final LoadingStateManager _loadingManager = LoadingStateManager();
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _loadServiceData();
  }

  @override
  void dispose() {
    _loadingManager.dispose();
    super.dispose();
  }

  /// 模拟加载服务数据
  Future<void> _loadServiceData() async {
    await _loadingManager.retry(() async {
      // 减少模拟网络请求延迟
      await Future.delayed(const Duration(milliseconds: 800));
      
      // 模拟随机错误
      if (DateTime.now().millisecond % 3 == 0) {
        throw Exception('网络连接超时');
      }
      
      // 模拟成功加载
      return;
    });
  }

  /// 模拟网络状态切换
  void _toggleNetworkStatus() {
    setState(() {
      _isOnline = !_isOnline;
      if (_isOnline) {
        _loadingManager.setOnline();
      } else {
        _loadingManager.setOffline();
      }
    });
  }

  /// 手动切换加载状态
  void _switchLoadingState(LoadingState state) {
    switch (state) {
      case LoadingState.initial:
        _loadingManager.setLoading();
        break;
      case LoadingState.loading:
        _loadingManager.setSuccess();
        break;
      case LoadingState.success:
        _loadingManager.setError('手动触发的错误');
        break;
      case LoadingState.error:
        _loadingManager.setLoading();
        break;
      case LoadingState.offline:
        _loadingManager.setOnline();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('加载状态测试'),
        actions: [
          // 网络状态切换按钮
          IconButton(
            icon: Icon(_isOnline ? Icons.wifi : Icons.wifi_off),
            onPressed: _toggleNetworkStatus,
            tooltip: '切换网络状态',
          ),
        ],
      ),
      body: Column(
        children: [
          // 控制按钮区域
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                const Text(
                  '状态控制',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => _switchLoadingState(LoadingState.initial),
                      child: const Text('初始状态'),
                    ),
                    ElevatedButton(
                      onPressed: () => _switchLoadingState(LoadingState.loading),
                      child: const Text('加载中'),
                    ),
                    ElevatedButton(
                      onPressed: () => _switchLoadingState(LoadingState.success),
                      child: const Text('成功'),
                    ),
                    ElevatedButton(
                      onPressed: () => _switchLoadingState(LoadingState.error),
                      child: const Text('错误'),
                    ),
                    ElevatedButton(
                      onPressed: () => _switchLoadingState(LoadingState.offline),
                      child: const Text('离线'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loadServiceData,
                  child: const Text('重新加载'),
                ),
              ],
            ),
          ),
          
          // 加载状态显示区域
          Expanded(
            child: ListenableBuilder(
              listenable: _loadingManager,
              builder: (context, child) {
                return ServiceDetailLoading(
                  state: _loadingManager.state,
                  loadingMessage: '正在加载服务详情...',
                  errorMessage: _loadingManager.errorMessage,
                  onRetry: _loadServiceData,
                  onBack: () => Get.back(),
                  showSkeleton: true,
                  child: _buildServiceContent(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建服务内容（成功加载后显示）
  Widget _buildServiceContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 使用渐进式加载显示各个区块
          ProgressiveLoadingWidget(
            delay: const Duration(milliseconds: 50),
            child: _buildHeroSection(),
          ),
          
          ProgressiveLoadingWidget(
            delay: const Duration(milliseconds: 100),
            child: _buildActionButtons(),
          ),
          
          ProgressiveLoadingWidget(
            delay: const Duration(milliseconds: 150),
            child: _buildTabBar(),
          ),
          
          ProgressiveLoadingWidget(
            delay: const Duration(milliseconds: 200),
            child: _buildContentSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: NetworkImage('https://via.placeholder.com/400x300'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '专业清洁服务',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '专业团队，品质保证',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('立即预订'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('联系商家'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildTabItem('概览', true),
          _buildTabItem('详情', false),
          _buildTabItem('评价', false),
          _buildTabItem('商家', false),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, bool isActive) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '服务详情',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildContentItem('服务类型', '深度清洁'),
          _buildContentItem('服务时长', '2-3小时'),
          _buildContentItem('服务范围', '室内清洁、家具清洁'),
          _buildContentItem('价格', '¥200起'),
          _buildContentItem('服务时间', '周一至周日 8:00-20:00'),
        ],
      ),
    );
  }

  Widget _buildContentItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 