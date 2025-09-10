import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/enhanced_search_service.dart';
import '../../../core/widgets/enhanced_search_bar.dart';

/// 搜索结果页面
/// 
/// 显示搜索结果，支持：
/// - 搜索结果列表
/// - 筛选和排序
/// - 加载更多
/// - 空状态处理
class SearchResultsPage extends StatefulWidget {
  final String? initialQuery;
  final SearchFilters? initialFilters;

  const SearchResultsPage({
    super.key,
    this.initialQuery,
    this.initialFilters,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final _searchService = Get.find<EnhancedSearchService>();
  final _scrollController = ScrollController();
  
  final RxBool _isLoadingMore = false.obs;
  final RxInt _currentPage = 1.obs;
  final RxBool _hasMoreData = true.obs;
  final RxString _currentQuery = ''.obs;
  final Rx<SearchFilters?> _currentFilters = Rx<SearchFilters?>(null);

  @override
  void initState() {
    super.initState();
    _currentQuery.value = widget.initialQuery ?? '';
    _currentFilters.value = widget.initialFilters;
    _setupScrollListener();
    
    // 如果有初始查询，立即搜索
    if (widget.initialQuery?.isNotEmpty == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(widget.initialQuery!, widget.initialFilters);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreResults();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // 搜索栏
            _buildSearchSection(),
            
            // 搜索结果
            Expanded(
              child: _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // 返回按钮和搜索栏
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: EnhancedSearchBar(
                  hintText: '搜索服务...',
                  initialFilters: _currentFilters.value,
                  onSearch: _performSearch,
                  onResultTap: _onResultTap,
                ),
              ),
            ],
          ),
          
          // 搜索状态信息
          _buildSearchStatusInfo(),
        ],
      ),
    );
  }

  Widget _buildSearchStatusInfo() {
    return Obx(() {
      final query = _currentQuery.value;
      final results = _searchService.searchResults;
      final isSearching = _searchService.isSearching;

      if (query.isEmpty) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (isSearching)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                Icons.search,
                size: 16,
                color: Colors.grey[600],
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isSearching 
                    ? '搜索中...'
                    : '找到 ${results.length} 个结果',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),
            if (_hasActiveFilters())
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '已筛选',
                  style: TextStyle(
                    fontSize: 12,
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchResults() {
    return Obx(() {
      final results = _searchService.searchResults;
      final isSearching = _searchService.isSearching;
      final query = _currentQuery.value;

      // 空查询状态
      if (query.isEmpty) {
        return _buildEmptyQueryState();
      }

      // 搜索中状态
      if (isSearching && results.isEmpty) {
        return _buildLoadingState();
      }

      // 无结果状态
      if (!isSearching && results.isEmpty) {
        return _buildNoResultsState();
      }

      // 搜索结果列表
      return _buildResultsList(results);
    });
  }

  Widget _buildEmptyQueryState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '输入关键词开始搜索',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '试试搜索"清洁服务"、"维修"等',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            '搜索中...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '没有找到相关结果',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '试试其他关键词或调整筛选条件',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _clearFilters,
            child: const Text('清除筛选条件'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<SearchResult> results) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: results.length + (_hasMoreData.value ? 1 : 0),
      itemBuilder: (context, index) {
        // 加载更多指示器
        if (index == results.length) {
          return _buildLoadMoreIndicator();
        }
        
        final result = results[index];
        return _buildResultItem(result, index);
      },
    );
  }

  Widget _buildResultItem(SearchResult result, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _onResultTap(result),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 服务图片
              _buildResultImage(result),
              
              const SizedBox(width: 12),
              
              // 服务信息
              Expanded(
                child: _buildResultInfo(result),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultImage(SearchResult result) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 60,
        height: 60,
        color: Colors.grey[200],
        child: result.imageUrl != null
            ? Image.network(
                result.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                    _buildDefaultImage(),
              )
            : _buildDefaultImage(),
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Icon(
      Icons.business,
      size: 30,
      color: Colors.grey[400],
    );
  }

  Widget _buildResultInfo(SearchResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 服务标题
        Text(
          result.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 4),
        
        // 服务描述
        Text(
          result.description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 8),
        
        // 价格和评分
        Row(
          children: [
            if (result.price != null) ...[
              Text(
                '¥${result.price!.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Get.theme.colorScheme.primary,
                ),
              ),
              if (result.currency != null && result.currency != 'CNY')
                Text(
                  ' ${result.currency}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              const SizedBox(width: 16),
            ],
            
            if (result.rating != null) ...[
              Icon(
                Icons.star,
                size: 16,
                color: Colors.amber[600],
              ),
              const SizedBox(width: 2),
              Text(
                result.rating!.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (result.reviewCount != null)
                Text(
                  ' (${result.reviewCount})',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ],
        ),
        
        const SizedBox(height: 4),
        
        // 提供商和分类
        Row(
          children: [
            if (result.providerName != null) ...[
              Icon(
                Icons.store,
                size: 12,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                result.providerName!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            
            if (result.categoryName != null) ...[
              const SizedBox(width: 12),
              Icon(
                Icons.category,
                size: 12,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                result.categoryName!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: _isLoadingMore.value
            ? const CircularProgressIndicator()
            : const Text(
                '已加载全部结果',
                style: TextStyle(color: Colors.grey),
              ),
      ),
    ));
  }

  void _performSearch(String query, SearchFilters? filters) {
    _currentQuery.value = query;
    _currentFilters.value = filters;
    _currentPage.value = 1;
    _hasMoreData.value = true;
    
    _searchService.search(
      query: query,
      filters: filters,
      page: 1,
    );
  }

  void _loadMoreResults() {
    if (_isLoadingMore.value || !_hasMoreData.value) return;
    
    final query = _currentQuery.value;
    if (query.isEmpty) return;

    _isLoadingMore.value = true;
    
    _searchService.search(
      query: query,
      filters: _currentFilters.value,
      page: _currentPage.value + 1,
    ).then((results) {
      _currentPage.value++;
      _hasMoreData.value = results.length >= 20; // 假设每页20条
    }).catchError((error) {
      Get.snackbar('错误', '加载更多结果失败: $error');
    }).whenComplete(() {
      _isLoadingMore.value = false;
    });
  }

  void _onResultTap(SearchResult result) {
    // 导航到服务详情页
    Get.toNamed('/service_detail', arguments: {'serviceId': result.id});
  }

  void _clearFilters() {
    _currentFilters.value = null;
    if (_currentQuery.value.isNotEmpty) {
      _performSearch(_currentQuery.value, null);
    }
  }

  bool _hasActiveFilters() {
    final filters = _currentFilters.value;
    if (filters == null) return false;
    
    return filters.industryType != null ||
           filters.minPrice != null ||
           filters.maxPrice != null ||
           filters.minRating != null ||
           filters.location != null ||
           filters.tags.isNotEmpty;
  }
}
