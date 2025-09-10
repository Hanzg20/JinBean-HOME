import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/base_models.dart';
import '../utils/app_logger.dart';
import '../../features/customer/domain/entities/service.dart';

/// 增强搜索服务
/// 
/// 提供跨行业的智能搜索功能，包括：
/// - 全文搜索
/// - 智能建议
/// - 搜索历史
/// - 热门搜索
/// - 分类筛选
/// - 地理位置搜索
class EnhancedSearchService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // 搜索状态
  final RxBool _isSearching = false.obs;
  final RxString _currentQuery = ''.obs;
  final RxList<SearchResult> _searchResults = <SearchResult>[].obs;
  final RxList<SearchSuggestion> _suggestions = <SearchSuggestion>[].obs;
  final RxList<String> _searchHistory = <String>[].obs;
  final RxList<String> _hotSearches = <String>[].obs;
  
  // 搜索配置
  final int _maxHistoryItems = 20;
  final int _maxSuggestions = 10;
  final Duration _searchDebounceTime = const Duration(milliseconds: 500);
  
  // 防抖定时器
  Timer? _debounceTimer;

  // Getters
  bool get isSearching => _isSearching.value;
  String get currentQuery => _currentQuery.value;
  List<SearchResult> get searchResults => _searchResults;
  List<SearchSuggestion> get suggestions => _suggestions;
  List<String> get searchHistory => _searchHistory;
  List<String> get hotSearches => _hotSearches;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  void _initializeService() {
    AppLogger.info('[EnhancedSearchService] Initializing enhanced search service');
    _loadSearchHistory();
    _loadHotSearches();
  }

  /// 执行搜索
  Future<List<SearchResult>> search({
    required String query,
    SearchFilters? filters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      if (query.trim().isEmpty) {
        _searchResults.clear();
        return [];
      }

      _isSearching.value = true;
      _currentQuery.value = query;
      
      AppLogger.info('[EnhancedSearchService] Searching for: $query');
      
      // 添加到搜索历史
      _addToSearchHistory(query);
      
      // 构建搜索查询
      final searchQuery = _buildSearchQuery(query, filters, page, limit);
      final results = await _executeSearch(searchQuery);
      
      // 更新搜索结果
      if (page == 1) {
        _searchResults.value = results;
      } else {
        _searchResults.addAll(results);
      }
      
      // 记录搜索行为
      await _recordSearchBehavior(query, results.length);
      
      AppLogger.info('[EnhancedSearchService] Found ${results.length} results');
      return results;
      
    } catch (e) {
      AppLogger.error('[EnhancedSearchService] Search failed: $e');
      throw SearchException('搜索失败: $e');
    } finally {
      _isSearching.value = false;
    }
  }

  /// 获取搜索建议
  Future<List<SearchSuggestion>> getSuggestions(String query) async {
    try {
      if (query.trim().isEmpty) {
        _suggestions.clear();
        return [];
      }

      AppLogger.info('[EnhancedSearchService] Getting suggestions for: $query');
      
      final suggestions = await _fetchSuggestions(query);
      _suggestions.value = suggestions;
      
      return suggestions;
      
    } catch (e) {
      AppLogger.error('[EnhancedSearchService] Failed to get suggestions: $e');
      return [];
    }
  }

  /// 防抖搜索
  void searchWithDebounce({
    required String query,
    SearchFilters? filters,
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_searchDebounceTime, () {
      if (query.trim().isNotEmpty) {
        search(query: query, filters: filters);
      } else {
        _searchResults.clear();
      }
    });
  }

  /// 获取搜索建议（防抖）
  void getSuggestionsWithDebounce(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_searchDebounceTime, () {
      getSuggestions(query);
    });
  }

  /// 构建搜索查询
  Map<String, dynamic> _buildSearchQuery(
    String query,
    SearchFilters? filters,
    int page,
    int limit,
  ) {
    final searchTerms = query.toLowerCase().split(' ').where((term) => term.isNotEmpty).toList();
    
    return {
      'query': query,
      'search_terms': searchTerms,
      'filters': filters?.toJson() ?? {},
      'page': page,
      'limit': limit,
      'offset': (page - 1) * limit,
    };
  }

  /// 执行搜索
  Future<List<SearchResult>> _executeSearch(Map<String, dynamic> searchQuery) async {
    final query = searchQuery['query'] as String;
    final filters = SearchFilters.fromJson(searchQuery['filters']);
    final limit = searchQuery['limit'] as int;
    final offset = searchQuery['offset'] as int;

    // 构建Supabase查询
    dynamic dbQuery = _supabase
        .from('services')
        .select('''
          id,
          title,
          description,
          category_level1_id,
          category_level2_id,
          provider_id,
          status,
          average_rating,
          review_count,
          created_at,
          updated_at,
          service_details:service_details(
            id,
            price,
            currency,
            images_url,
            tags,
            service_area_codes
          ),
          provider:providers(
            id,
            business_name,
            display_name,
            avatar_url
          ),
          category_level1:ref_codes!services_category_level1_id_fkey(
            id,
            code_value,
            code_description
          ),
          category_level2:ref_codes!services_category_level2_id_fkey(
            id,
            code_value,
            code_description
          )
        ''')
        .eq('status', 'active');

    // 应用全文搜索
    dbQuery = dbQuery.or(_buildFullTextSearchCondition(query));

    // 应用筛选条件
    if (filters.industryType != null) {
      dbQuery = dbQuery.eq('category_level1_id', _getIndustryTypeId(filters.industryType!));
    }

    if (filters.minPrice != null || filters.maxPrice != null) {
      // 需要通过service_details表筛选价格
      // 这里简化处理，实际可能需要更复杂的查询
    }

    if (filters.minRating != null) {
      dbQuery = dbQuery.gte('average_rating', filters.minRating!);
    }

    if (filters.location != null) {
      // 地理位置筛选
      // TODO: 实现地理位置筛选逻辑
    }

    // 排序
    switch (filters.sortBy) {
      case SearchSortBy.relevance:
        // 相关性排序（默认）
        break;
      case SearchSortBy.rating:
        dbQuery = dbQuery.order('average_rating', ascending: false);
        break;
      case SearchSortBy.price:
        // 价格排序需要通过service_details
        break;
      case SearchSortBy.distance:
        // 距离排序
        break;
      case SearchSortBy.newest:
        dbQuery = dbQuery.order('created_at', ascending: false);
        break;
      default:
        dbQuery = dbQuery.order('average_rating', ascending: false);
    }

    // 分页
    dbQuery = dbQuery.range(offset, offset + limit - 1);

    final response = await dbQuery;
    
    return (response as List).map((data) => SearchResult.fromJson(data)).toList();
  }

  /// 构建全文搜索条件
  String _buildFullTextSearchCondition(String query) {
    final terms = query.toLowerCase().split(' ').where((term) => term.isNotEmpty);
    final conditions = <String>[];

    for (final term in terms) {
      conditions.addAll([
        'title->>zh.ilike.%$term%',
        'title->>en.ilike.%$term%',
        'description->>zh.ilike.%$term%',
        'description->>en.ilike.%$term%',
      ]);
    }

    return conditions.join(',');
  }

  /// 获取行业类型ID
  String _getIndustryTypeId(IndustryType industryType) {
    switch (industryType) {
      case IndustryType.food:
        return '1010000';
      case IndustryType.home:
        return '1020000';
      case IndustryType.transport:
        return '1030000';
      case IndustryType.rental:
        return '1040000';
      case IndustryType.learning:
        return '1050000';
      case IndustryType.professional:
        return '1060000';
    }
  }

  /// 获取搜索建议
  Future<List<SearchSuggestion>> _fetchSuggestions(String query) async {
    final suggestions = <SearchSuggestion>[];

    // 1. 从搜索历史获取建议
    final historyMatches = _searchHistory
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .take(3)
        .map((item) => SearchSuggestion(
              text: item,
              type: SearchSuggestionType.history,
              score: 1.0,
            ));
    suggestions.addAll(historyMatches);

    // 2. 从热门搜索获取建议
    final hotMatches = _hotSearches
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .take(3)
        .map((item) => SearchSuggestion(
              text: item,
              type: SearchSuggestionType.trending,
              score: 0.8,
            ));
    suggestions.addAll(hotMatches);

    // 3. 从服务标题获取建议
    try {
      final response = await _supabase
          .from('services')
          .select('title')
          .or('title->>zh.ilike.%$query%,title->>en.ilike.%$query%')
          .eq('status', 'active')
          .limit(5);

      final serviceMatches = (response as List).map((data) {
        final title = _getLocalizedText(data['title']);
        return SearchSuggestion(
          text: title,
          type: SearchSuggestionType.service,
          score: 0.6,
        );
      });
      suggestions.addAll(serviceMatches);
    } catch (e) {
      AppLogger.error('[EnhancedSearchService] Failed to fetch service suggestions: $e');
    }

    // 4. 从分类获取建议
    try {
      final response = await _supabase
          .from('ref_codes')
          .select('code_description')
          .eq('type_code', 'SERVICE_TYPE')
          .or('code_description->>zh.ilike.%$query%,code_description->>en.ilike.%$query%')
          .eq('status', 1)
          .limit(3);

      final categoryMatches = (response as List).map((data) {
        final description = _getLocalizedText(data['code_description']);
        return SearchSuggestion(
          text: description,
          type: SearchSuggestionType.category,
          score: 0.5,
        );
      });
      suggestions.addAll(categoryMatches);
    } catch (e) {
      AppLogger.error('[EnhancedSearchService] Failed to fetch category suggestions: $e');
    }

    // 排序并限制数量
    suggestions.sort((a, b) => b.score.compareTo(a.score));
    return suggestions.take(_maxSuggestions).toList();
  }

  /// 添加到搜索历史
  void _addToSearchHistory(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    // 移除重复项
    _searchHistory.remove(trimmedQuery);
    
    // 添加到开头
    _searchHistory.insert(0, trimmedQuery);
    
    // 限制历史记录数量
    if (_searchHistory.length > _maxHistoryItems) {
      _searchHistory.removeRange(_maxHistoryItems, _searchHistory.length);
    }
    
    // 保存到本地存储
    _saveSearchHistory();
  }

  /// 清除搜索历史
  void clearSearchHistory() {
    _searchHistory.clear();
    _saveSearchHistory();
  }

  /// 删除搜索历史项
  void removeFromSearchHistory(String query) {
    _searchHistory.remove(query);
    _saveSearchHistory();
  }

  /// 加载搜索历史
  void _loadSearchHistory() {
    try {
      // TODO: 从本地存储加载搜索历史
      // 现在使用模拟数据
      _searchHistory.value = [
        '家庭清洁',
        '水电维修',
        '搬家服务',
        '空调维修',
        '管道疏通',
      ];
    } catch (e) {
      AppLogger.error('[EnhancedSearchService] Failed to load search history: $e');
    }
  }

  /// 保存搜索历史
  void _saveSearchHistory() {
    try {
      // TODO: 保存搜索历史到本地存储
      AppLogger.info('[EnhancedSearchService] Search history saved');
    } catch (e) {
      AppLogger.error('[EnhancedSearchService] Failed to save search history: $e');
    }
  }

  /// 加载热门搜索
  Future<void> _loadHotSearches() async {
    try {
      // TODO: 从后端获取热门搜索
      // 现在使用模拟数据
      _hotSearches.value = [
        '清洁服务',
        '维修服务',
        '搬家',
        '家政',
        '装修',
        '保洁',
        '修理',
        '安装',
      ];
    } catch (e) {
      AppLogger.error('[EnhancedSearchService] Failed to load hot searches: $e');
    }
  }

  /// 记录搜索行为
  Future<void> _recordSearchBehavior(String query, int resultCount) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('search_behaviors').insert({
        'user_id': userId,
        'query': query,
        'result_count': resultCount,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      AppLogger.error('[EnhancedSearchService] Failed to record search behavior: $e');
    }
  }

  /// 获取本地化文本
  String _getLocalizedText(dynamic value, {String locale = 'zh'}) {
    if (value is Map<String, dynamic>) {
      return value[locale] ?? value['zh'] ?? value['en'] ?? '';
    } else if (value is String) {
      return value;
    }
    return '';
  }

  /// 清除搜索结果
  void clearSearchResults() {
    _searchResults.clear();
    _currentQuery.value = '';
  }

  /// 获取搜索统计
  Map<String, dynamic> getSearchStats() {
    return {
      'total_searches': _searchHistory.length,
      'current_results': _searchResults.length,
      'is_searching': _isSearching.value,
      'current_query': _currentQuery.value,
      'suggestions_count': _suggestions.length,
      'hot_searches_count': _hotSearches.length,
    };
  }
}

/// 搜索结果模型
class SearchResult {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final double? price;
  final String? currency;
  final double? rating;
  final int? reviewCount;
  final String? providerName;
  final String? categoryName;
  final IndustryType? industryType;
  final double? distance;
  final List<String> tags;
  final double relevanceScore;

  SearchResult({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.price,
    this.currency,
    this.rating,
    this.reviewCount,
    this.providerName,
    this.categoryName,
    this.industryType,
    this.distance,
    this.tags = const [],
    this.relevanceScore = 0.0,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final serviceDetails = json['service_details'] as List?;
    final provider = json['provider'] as Map<String, dynamic>?;
    final category1 = json['category_level1'] as Map<String, dynamic>?;

    return SearchResult(
      id: json['id'],
      title: _getLocalizedText(json['title']),
      description: _getLocalizedText(json['description']),
      imageUrl: serviceDetails?.isNotEmpty == true 
          ? (serviceDetails!.first['images_url'] as List?)?.first
          : null,
      price: serviceDetails?.isNotEmpty == true 
          ? serviceDetails!.first['price']?.toDouble()
          : null,
      currency: serviceDetails?.isNotEmpty == true 
          ? serviceDetails!.first['currency']
          : null,
      rating: json['average_rating']?.toDouble(),
      reviewCount: json['review_count'],
      providerName: provider?['business_name'] ?? provider?['display_name'],
      categoryName: _getLocalizedText(category1?['code_description']),
      tags: serviceDetails?.isNotEmpty == true 
          ? List<String>.from(serviceDetails!.first['tags'] ?? [])
          : [],
      relevanceScore: 1.0, // TODO: 实现相关性评分算法
    );
  }

  static String _getLocalizedText(dynamic value, {String locale = 'zh'}) {
    if (value is Map<String, dynamic>) {
      return value[locale] ?? value['zh'] ?? value['en'] ?? '';
    } else if (value is String) {
      return value;
    }
    return '';
  }
}

/// 搜索建议模型
class SearchSuggestion {
  final String text;
  final SearchSuggestionType type;
  final double score;
  final Map<String, dynamic> metadata;

  SearchSuggestion({
    required this.text,
    required this.type,
    required this.score,
    this.metadata = const {},
  });

  String get displayText => text;
  
  IconData get icon {
    switch (type) {
      case SearchSuggestionType.history:
        return Icons.history;
      case SearchSuggestionType.trending:
        return Icons.trending_up;
      case SearchSuggestionType.service:
        return Icons.business;
      case SearchSuggestionType.category:
        return Icons.category;
    }
  }
}

/// 搜索建议类型
enum SearchSuggestionType {
  history,    // 搜索历史
  trending,   // 热门搜索
  service,    // 服务名称
  category,   // 分类名称
}

/// 搜索筛选条件
class SearchFilters {
  final IndustryType? industryType;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final Map<String, dynamic>? location;
  final double? maxDistance; // 公里
  final SearchSortBy sortBy;
  final List<String> tags;

  SearchFilters({
    this.industryType,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.location,
    this.maxDistance,
    this.sortBy = SearchSortBy.relevance,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'industry_type': industryType?.code,
      'min_price': minPrice,
      'max_price': maxPrice,
      'min_rating': minRating,
      'location': location,
      'max_distance': maxDistance,
      'sort_by': sortBy.name,
      'tags': tags,
    };
  }

  factory SearchFilters.fromJson(Map<String, dynamic> json) {
    return SearchFilters(
      industryType: json['industry_type'] != null 
          ? IndustryType.fromCode(json['industry_type'])
          : null,
      minPrice: json['min_price']?.toDouble(),
      maxPrice: json['max_price']?.toDouble(),
      minRating: json['min_rating']?.toDouble(),
      location: json['location'] as Map<String, dynamic>?,
      maxDistance: json['max_distance']?.toDouble(),
      sortBy: SearchSortBy.values.firstWhere(
        (e) => e.name == json['sort_by'],
        orElse: () => SearchSortBy.relevance,
      ),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}

/// 搜索排序方式
enum SearchSortBy {
  relevance,  // 相关性
  rating,     // 评分
  price,      // 价格
  distance,   // 距离
  newest,     // 最新
}

/// 搜索异常
class SearchException implements Exception {
  final String message;
  final dynamic originalError;

  SearchException(this.message, {this.originalError});

  @override
  String toString() => 'SearchException: $message';
}
