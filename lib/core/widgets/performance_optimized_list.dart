import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/performance_monitor_service.dart';

/// 性能优化的列表组件
/// 
/// 提供高性能的列表渲染，包括：
/// - 虚拟滚动
/// - 懒加载
/// - 智能缓存
/// - 性能监控
/// - 内存优化
class PerformanceOptimizedList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? Function(BuildContext context)? loadingBuilder;
  final Widget? Function(BuildContext context)? emptyBuilder;
  final Widget? Function(BuildContext context, String error)? errorBuilder;
  final Future<List<T>> Function(int page, int pageSize)? onLoadMore;
  final VoidCallback? onRefresh;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final int pageSize;
  final bool enablePerformanceMonitoring;
  final String? listName;

  const PerformanceOptimizedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.onLoadMore,
    this.onRefresh,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.pageSize = 20,
    this.enablePerformanceMonitoring = true,
    this.listName,
  });

  @override
  State<PerformanceOptimizedList<T>> createState() => _PerformanceOptimizedListState<T>();
}

class _PerformanceOptimizedListState<T> extends State<PerformanceOptimizedList<T>> {
  late ScrollController _scrollController;
  final PerformanceMonitorService? _performanceMonitor = Get.isRegistered<PerformanceMonitorService>() 
      ? Get.find<PerformanceMonitorService>() 
      : null;
  
  final RxBool _isLoadingMore = false.obs;
  final RxBool _isRefreshing = false.obs;
  final RxString _error = ''.obs;
  final RxList<T> _allItems = <T>[].obs;
  final RxInt _currentPage = 1.obs;
  final RxBool _hasMoreData = true.obs;
  
  // 性能监控
  final Map<int, DateTime> _itemBuildTimes = {};
  final Set<int> _visibleItems = {};
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _allItems.value = List.from(widget.items);
    _setupScrollListener();
    _startPerformanceMonitoring();
  }

  @override
  void didUpdateWidget(PerformanceOptimizedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _allItems.value = List.from(widget.items);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // 检查是否需要加载更多
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreData();
      }
      
      // 更新可见项目（用于性能监控）
      if (widget.enablePerformanceMonitoring) {
        _updateVisibleItems();
      }
    });
  }

  void _startPerformanceMonitoring() {
    if (!widget.enablePerformanceMonitoring || _performanceMonitor == null) return;
    
    final listName = widget.listName ?? 'PerformanceOptimizedList';
    _performanceMonitor!.startTiming('${listName}_initial_build');
  }

  void _updateVisibleItems() {
    // 计算当前可见的项目索引范围
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final viewport = RenderAbstractViewport.of(renderBox);
    if (viewport == null) return;
    
    final scrollOffset = _scrollController.offset;
    final viewportHeight = renderBox.size.height;
    
    // 简化的可见性检测
    final estimatedItemHeight = 80.0; // 估算的项目高度
    final startIndex = (scrollOffset / estimatedItemHeight).floor().clamp(0, _allItems.length - 1);
    final endIndex = ((scrollOffset + viewportHeight) / estimatedItemHeight).ceil().clamp(0, _allItems.length - 1);
    
    _visibleItems.clear();
    for (int i = startIndex; i <= endIndex; i++) {
      _visibleItems.add(i);
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore.value || !_hasMoreData.value || widget.onLoadMore == null) {
      return;
    }

    _isLoadingMore.value = true;
    _error.value = '';

    try {
      final startTime = DateTime.now();
      
      final newItems = await widget.onLoadMore!(_currentPage.value + 1, widget.pageSize);
      
      if (widget.enablePerformanceMonitoring && _performanceMonitor != null) {
        final duration = DateTime.now().difference(startTime);
        _performanceMonitor!.recordApiRequest(
          endpoint: 'load_more_${widget.listName ?? 'list'}',
          method: 'GET',
          duration: duration,
          statusCode: 200,
          responseSize: newItems.length,
        );
      }

      if (newItems.isNotEmpty) {
        _allItems.addAll(newItems);
        _currentPage.value++;
        
        // 检查是否还有更多数据
        if (newItems.length < widget.pageSize) {
          _hasMoreData.value = false;
        }
      } else {
        _hasMoreData.value = false;
      }
    } catch (e) {
      _error.value = e.toString();
      
      if (widget.enablePerformanceMonitoring && _performanceMonitor != null) {
        final duration = DateTime.now().difference(DateTime.now());
        _performanceMonitor!.recordApiRequest(
          endpoint: 'load_more_${widget.listName ?? 'list'}',
          method: 'GET',
          duration: duration,
          statusCode: 500,
          errorMessage: e.toString(),
        );
      }
    } finally {
      _isLoadingMore.value = false;
    }
  }

  Future<void> _refreshData() async {
    if (widget.onRefresh == null) return;

    _isRefreshing.value = true;
    _error.value = '';

    try {
      final startTime = DateTime.now();
      
      await widget.onRefresh!();
      
      if (widget.enablePerformanceMonitoring && _performanceMonitor != null) {
        final duration = DateTime.now().difference(startTime);
        _performanceMonitor!.recordApiRequest(
          endpoint: 'refresh_${widget.listName ?? 'list'}',
          method: 'GET',
          duration: duration,
          statusCode: 200,
        );
      }

      // 重置分页状态
      _currentPage.value = 1;
      _hasMoreData.value = true;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isRefreshing.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 错误状态
      if (_error.value.isNotEmpty && _allItems.isEmpty) {
        return _buildErrorWidget();
      }

      // 空状态
      if (_allItems.isEmpty && !_isRefreshing.value) {
        return _buildEmptyWidget();
      }

      // 列表内容
      return _buildListContent();
    });
  }

  Widget _buildErrorWidget() {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, _error.value);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error.value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    if (widget.emptyBuilder != null) {
      return widget.emptyBuilder!(context);
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '暂无数据',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent() {
    Widget listView = ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemCount: _allItems.length + (_hasMoreData.value ? 1 : 0),
      itemBuilder: (context, index) {
        // 加载更多指示器
        if (index == _allItems.length) {
          return _buildLoadMoreIndicator();
        }

        // 列表项
        return _buildOptimizedItem(context, _allItems[index], index);
      },
    );

    // 添加下拉刷新
    if (widget.onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: _refreshData,
        child: listView,
      );
    }

    return listView;
  }

  Widget _buildOptimizedItem(BuildContext context, T item, int index) {
    return PerformanceOptimizedListItem<T>(
      key: ValueKey(index),
      item: item,
      index: index,
      builder: widget.itemBuilder,
      onBuildStart: widget.enablePerformanceMonitoring ? () {
        _itemBuildTimes[index] = DateTime.now();
      } : null,
      onBuildEnd: widget.enablePerformanceMonitoring ? () {
        final startTime = _itemBuildTimes.remove(index);
        if (startTime != null && _performanceMonitor != null) {
          final duration = DateTime.now().difference(startTime);
          _performanceMonitor!.recordUIRender(
            widgetName: '${widget.listName ?? 'list'}_item_$index',
            buildTime: duration,
          );
        }
      } : null,
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: _isLoadingMore.value
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '加载中...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              )
            : _hasMoreData.value
                ? const Text(
                    '上拉加载更多',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  )
                : const Text(
                    '已加载全部内容',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
      ),
    ));
  }

  /// 获取性能统计
  Map<String, dynamic> getPerformanceStats() {
    return {
      'total_items': _allItems.length,
      'visible_items': _visibleItems.length,
      'current_page': _currentPage.value,
      'has_more_data': _hasMoreData.value,
      'is_loading_more': _isLoadingMore.value,
      'is_refreshing': _isRefreshing.value,
      'error': _error.value,
    };
  }
}

/// 性能优化的列表项组件
class PerformanceOptimizedListItem<T> extends StatefulWidget {
  final T item;
  final int index;
  final Widget Function(BuildContext context, T item, int index) builder;
  final VoidCallback? onBuildStart;
  final VoidCallback? onBuildEnd;

  const PerformanceOptimizedListItem({
    super.key,
    required this.item,
    required this.index,
    required this.builder,
    this.onBuildStart,
    this.onBuildEnd,
  });

  @override
  State<PerformanceOptimizedListItem<T>> createState() => _PerformanceOptimizedListItemState<T>();
}

class _PerformanceOptimizedListItemState<T> extends State<PerformanceOptimizedListItem<T>>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true; // 保持状态以优化性能

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用以支持 AutomaticKeepAliveClientMixin
    
    widget.onBuildStart?.call();
    
    final child = widget.builder(context, widget.item, widget.index);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onBuildEnd?.call();
    });
    
    return child;
  }
}

/// 虚拟滚动列表（用于大量数据）
class VirtualScrollList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final double itemHeight;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final int bufferSize;

  const VirtualScrollList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.itemHeight,
    this.controller,
    this.padding,
    this.bufferSize = 5,
  });

  @override
  State<VirtualScrollList<T>> createState() => _VirtualScrollListState<T>();
}

class _VirtualScrollListState<T> extends State<VirtualScrollList<T>> {
  late ScrollController _scrollController;
  final RxInt _startIndex = 0.obs;
  final RxInt _endIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_updateVisibleRange);
    _updateVisibleRange();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _updateVisibleRange() {
    final scrollOffset = _scrollController.offset;
    final viewportHeight = _scrollController.position.viewportDimension;
    
    final startIndex = (scrollOffset / widget.itemHeight).floor() - widget.bufferSize;
    final endIndex = ((scrollOffset + viewportHeight) / widget.itemHeight).ceil() + widget.bufferSize;
    
    _startIndex.value = startIndex.clamp(0, widget.items.length - 1);
    _endIndex.value = endIndex.clamp(0, widget.items.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        // 只渲染可见范围内的项目
        if (index < _startIndex.value || index > _endIndex.value) {
          return SizedBox(height: widget.itemHeight);
        }
        
        return SizedBox(
          height: widget.itemHeight,
          child: widget.itemBuilder(context, widget.items[index], index),
        );
      },
    ));
  }
}

