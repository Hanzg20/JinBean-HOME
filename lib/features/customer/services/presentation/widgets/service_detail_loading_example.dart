import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'service_detail_loading.dart';

/// ServiceDetailPage 加载状态使用示例
/// 展示如何集成骨架屏、渐进式加载、离线支持和错误恢复机制

class ServiceDetailLoadingExample extends StatefulWidget {
  const ServiceDetailLoadingExample({Key? key}) : super(key: key);

  @override
  State<ServiceDetailLoadingExample> createState() => _ServiceDetailLoadingExampleState();
}

class _ServiceDetailLoadingExampleState extends State<ServiceDetailLoadingExample> {
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
      // 模拟网络请求延迟
      await Future.delayed(const Duration(seconds: 2));
      
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('加载状态示例'),
        actions: [
          // 网络状态切换按钮
          IconButton(
            icon: Icon(_isOnline ? Icons.wifi : Icons.wifi_off),
            onPressed: _toggleNetworkStatus,
          ),
        ],
      ),
      body: ListenableBuilder(
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
    );
  }

  /// 构建服务内容（成功加载后显示）
  Widget _buildServiceContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 使用渐进式加载显示各个区块
          ProgressiveLoadingWidget(
            delay: const Duration(milliseconds: 100),
            child: _buildHeroSection(),
          ),
          
          ProgressiveLoadingWidget(
            delay: const Duration(milliseconds: 200),
            child: _buildActionButtons(),
          ),
          
          ProgressiveLoadingWidget(
            delay: const Duration(milliseconds: 300),
            child: _buildTabBar(),
          ),
          
          ProgressiveLoadingWidget(
            delay: const Duration(milliseconds: 400),
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

/// 使用示例：在ServiceDetailPage中集成
class ServiceDetailPageWithLoading extends StatefulWidget {
  final String serviceId;

  const ServiceDetailPageWithLoading({
    Key? key,
    required this.serviceId,
  }) : super(key: key);

  @override
  State<ServiceDetailPageWithLoading> createState() => _ServiceDetailPageWithLoadingState();
}

class _ServiceDetailPageWithLoadingState extends State<ServiceDetailPageWithLoading> {
  final LoadingStateManager _loadingManager = LoadingStateManager();
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _loadServiceDetail();
  }

  @override
  void dispose() {
    _loadingManager.dispose();
    super.dispose();
  }

  /// 加载服务详情
  Future<void> _loadServiceDetail() async {
    await _loadingManager.retry(() async {
      // TODO: 实际的API调用
      // final serviceDetail = await serviceDetailApiService.getServiceDetail(widget.serviceId);
      
      // 模拟API调用
      await Future.delayed(Duration(seconds: 1.5));
      
      // 模拟网络错误
      if (DateTime.now().millisecond % 5 == 0) {
        throw Exception('服务详情加载失败');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _loadingManager,
        builder: (context, child) {
          return ServiceDetailLoading(
            state: _loadingManager.state,
            loadingMessage: '正在加载服务详情...',
            errorMessage: _loadingManager.errorMessage,
            onRetry: _loadServiceDetail,
            onBack: () => Get.back(),
            showSkeleton: true,
            child: _buildServiceDetailContent(),
          );
        },
      ),
    );
  }

  Widget _buildServiceDetailContent() {
    // TODO: 实际的ServiceDetailPage内容
    return const Center(
      child: Text('服务详情内容'),
    );
  }
}

/// 网络状态监听器
class NetworkStatusListener extends StatefulWidget {
  final Widget child;
  final Function(bool) onNetworkStatusChanged;

  const NetworkStatusListener({
    Key? key,
    required this.child,
    required this.onNetworkStatusChanged,
  }) : super(key: key);

  @override
  State<NetworkStatusListener> createState() => _NetworkStatusListenerState();
}

class _NetworkStatusListenerState extends State<NetworkStatusListener> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkNetworkStatus();
  }

  void _checkNetworkStatus() {
    // TODO: 实现实际的网络状态检查
    // 这里可以集成connectivity_plus包或其他网络状态检测库
    
    // 模拟网络状态检查
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isOnline = DateTime.now().millisecond % 2 == 0;
        });
        widget.onNetworkStatusChanged(_isOnline);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
} 