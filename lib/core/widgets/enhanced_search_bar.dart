import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/enhanced_search_service.dart';
import '../models/base_models.dart';

/// 增强搜索栏组件
/// 
/// 提供完整的搜索体验，包括：
/// - 搜索输入
/// - 实时建议
/// - 搜索历史
/// - 热门搜索
/// - 筛选选项
class EnhancedSearchBar extends StatefulWidget {
  final String? hintText;
  final Function(String query, SearchFilters? filters)? onSearch;
  final Function(SearchResult result)? onResultTap;
  final bool showFilters;
  final bool showSuggestions;
  final SearchFilters? initialFilters;

  const EnhancedSearchBar({
    super.key,
    this.hintText,
    this.onSearch,
    this.onResultTap,
    this.showFilters = true,
    this.showSuggestions = true,
    this.initialFilters,
  });

  @override
  State<EnhancedSearchBar> createState() => _EnhancedSearchBarState();
}

class _EnhancedSearchBarState extends State<EnhancedSearchBar> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final _searchService = Get.find<EnhancedSearchService>();
  
  final RxBool _isFocused = false.obs;
  final RxBool _showSuggestions = false.obs;
  final Rx<SearchFilters?> _currentFilters = Rx<SearchFilters?>(null);

  @override
  void initState() {
    super.initState();
    _currentFilters.value = widget.initialFilters;
    _setupListeners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _setupListeners() {
    _focusNode.addListener(() {
      _isFocused.value = _focusNode.hasFocus;
      if (_focusNode.hasFocus && widget.showSuggestions) {
        _showSuggestions.value = true;
        if (_searchController.text.isNotEmpty) {
          _searchService.getSuggestionsWithDebounce(_searchController.text);
        }
      } else {
        _showSuggestions.value = false;
      }
    });

    _searchController.addListener(() {
      final query = _searchController.text;
      if (query.isNotEmpty && _isFocused.value && widget.showSuggestions) {
        _searchService.getSuggestionsWithDebounce(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 搜索输入栏
        _buildSearchInput(),
        
        // 搜索建议和结果
        Obx(() => _showSuggestions.value 
            ? _buildSuggestionsOverlay()
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildSearchInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          // 搜索图标
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(
              Icons.search,
              color: Colors.grey,
              size: 20,
            ),
          ),
          
          // 搜索输入框
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: widget.hintText ?? '搜索服务...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              onSubmitted: (query) => _performSearch(query),
            ),
          ),
          
          // 清除按钮
          Obx(() => _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.grey,
                    size: 20,
                  ),
                )
              : const SizedBox.shrink()),
          
          // 筛选按钮
          if (widget.showFilters)
            Obx(() => IconButton(
              onPressed: _showFiltersDialog,
              icon: Icon(
                Icons.tune,
                color: _hasActiveFilters() 
                    ? Get.theme.colorScheme.primary 
                    : Colors.grey,
                size: 20,
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildSuggestionsOverlay() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 16,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索建议
          if (_searchController.text.isNotEmpty)
            _buildSuggestionsList()
          else
            _buildDefaultSuggestions(),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return Obx(() {
      final suggestions = _searchService.suggestions;
      
      if (suggestions.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            '没有找到相关建议',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return _buildSuggestionItem(suggestion);
        },
      );
    });
  }

  Widget _buildDefaultSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 搜索历史
        _buildSearchHistory(),
        
        // 热门搜索
        _buildHotSearches(),
      ],
    );
  }

  Widget _buildSuggestionItem(SearchSuggestion suggestion) {
    return ListTile(
      leading: Icon(
        suggestion.icon,
        size: 20,
        color: Colors.grey[600],
      ),
      title: Text(
        suggestion.displayText,
        style: const TextStyle(fontSize: 14),
      ),
      trailing: IconButton(
        onPressed: () => _fillSearchText(suggestion.text),
        icon: const Icon(
          Icons.north_west,
          size: 16,
          color: Colors.grey,
        ),
      ),
      onTap: () => _performSearch(suggestion.text),
    );
  }

  Widget _buildSearchHistory() {
    return Obx(() {
      final history = _searchService.searchHistory;
      
      if (history.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '搜索历史',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                TextButton(
                  onPressed: _clearSearchHistory,
                  child: const Text(
                    '清除',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          ...history.take(5).map((query) => ListTile(
            leading: const Icon(
              Icons.history,
              size: 20,
              color: Colors.grey,
            ),
            title: Text(
              query,
              style: const TextStyle(fontSize: 14),
            ),
            trailing: IconButton(
              onPressed: () => _removeFromHistory(query),
              icon: const Icon(
                Icons.close,
                size: 16,
                color: Colors.grey,
              ),
            ),
            onTap: () => _performSearch(query),
          )),
        ],
      );
    });
  }

  Widget _buildHotSearches() {
    return Obx(() {
      final hotSearches = _searchService.hotSearches;
      
      if (hotSearches.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '热门搜索',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: hotSearches.take(8).map((query) => 
                _buildHotSearchChip(query)
              ).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    });
  }

  Widget _buildHotSearchChip(String query) {
    return GestureDetector(
      onTap: () => _performSearch(query),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          query,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    _searchController.text = query;
    _focusNode.unfocus();
    _showSuggestions.value = false;
    
    widget.onSearch?.call(query, _currentFilters.value);
  }

  void _fillSearchText(String text) {
    _searchController.text = text;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    _searchService.clearSearchResults();
  }

  void _clearSearchHistory() {
    _searchService.clearSearchHistory();
  }

  void _removeFromHistory(String query) {
    _searchService.removeFromSearchHistory(query);
  }

  void _showFiltersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchFiltersDialog(
        initialFilters: _currentFilters.value,
        onFiltersChanged: (filters) {
          _currentFilters.value = filters;
          if (_searchController.text.isNotEmpty) {
            _performSearch(_searchController.text);
          }
        },
      ),
    );
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

/// 搜索筛选对话框
class SearchFiltersDialog extends StatefulWidget {
  final SearchFilters? initialFilters;
  final Function(SearchFilters? filters) onFiltersChanged;

  const SearchFiltersDialog({
    super.key,
    this.initialFilters,
    required this.onFiltersChanged,
  });

  @override
  State<SearchFiltersDialog> createState() => _SearchFiltersDialogState();
}

class _SearchFiltersDialogState extends State<SearchFiltersDialog> {
  late SearchFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters ?? SearchFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          _buildHeader(),
          
          // 筛选选项
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIndustryTypeFilter(),
                  const SizedBox(height: 24),
                  _buildPriceRangeFilter(),
                  const SizedBox(height: 24),
                  _buildRatingFilter(),
                  const SizedBox(height: 24),
                  _buildSortByFilter(),
                ],
              ),
            ),
          ),
          
          // 操作按钮
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '筛选条件',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: _resetFilters,
            child: const Text('重置'),
          ),
        ],
      ),
    );
  }

  Widget _buildIndustryTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '服务类型',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: IndustryType.values.map((type) => 
            FilterChip(
              label: Text(type.label),
              selected: _filters.industryType == type,
              onSelected: (selected) {
                setState(() {
                  _filters = SearchFilters(
                    industryType: selected ? type : null,
                    minPrice: _filters.minPrice,
                    maxPrice: _filters.maxPrice,
                    minRating: _filters.minRating,
                    location: _filters.location,
                    maxDistance: _filters.maxDistance,
                    sortBy: _filters.sortBy,
                    tags: _filters.tags,
                  );
                });
              },
            )
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '价格范围',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: '最低价格',
                  prefixText: '¥',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final price = double.tryParse(value);
                  setState(() {
                    _filters = SearchFilters(
                      industryType: _filters.industryType,
                      minPrice: price,
                      maxPrice: _filters.maxPrice,
                      minRating: _filters.minRating,
                      location: _filters.location,
                      maxDistance: _filters.maxDistance,
                      sortBy: _filters.sortBy,
                      tags: _filters.tags,
                    );
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: '最高价格',
                  prefixText: '¥',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final price = double.tryParse(value);
                  setState(() {
                    _filters = SearchFilters(
                      industryType: _filters.industryType,
                      minPrice: _filters.minPrice,
                      maxPrice: price,
                      minRating: _filters.minRating,
                      location: _filters.location,
                      maxDistance: _filters.maxDistance,
                      sortBy: _filters.sortBy,
                      tags: _filters.tags,
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '最低评分',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [1.0, 2.0, 3.0, 4.0, 4.5].map((rating) => 
            FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('$rating+'),
                ],
              ),
              selected: _filters.minRating == rating,
              onSelected: (selected) {
                setState(() {
                  _filters = SearchFilters(
                    industryType: _filters.industryType,
                    minPrice: _filters.minPrice,
                    maxPrice: _filters.maxPrice,
                    minRating: selected ? rating : null,
                    location: _filters.location,
                    maxDistance: _filters.maxDistance,
                    sortBy: _filters.sortBy,
                    tags: _filters.tags,
                  );
                });
              },
            )
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildSortByFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '排序方式',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...SearchSortBy.values.map((sortBy) => 
          RadioListTile<SearchSortBy>(
            title: Text(_getSortByLabel(sortBy)),
            value: sortBy,
            groupValue: _filters.sortBy,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _filters = SearchFilters(
                    industryType: _filters.industryType,
                    minPrice: _filters.minPrice,
                    maxPrice: _filters.maxPrice,
                    minRating: _filters.minRating,
                    location: _filters.location,
                    maxDistance: _filters.maxDistance,
                    sortBy: value,
                    tags: _filters.tags,
                  );
                });
              }
            },
          )
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                widget.onFiltersChanged(_filters);
                Navigator.of(context).pop();
              },
              child: const Text('应用'),
            ),
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _filters = SearchFilters();
    });
  }

  String _getSortByLabel(SearchSortBy sortBy) {
    switch (sortBy) {
      case SearchSortBy.relevance:
        return '相关性';
      case SearchSortBy.rating:
        return '评分';
      case SearchSortBy.price:
        return '价格';
      case SearchSortBy.distance:
        return '距离';
      case SearchSortBy.newest:
        return '最新';
    }
  }
}

