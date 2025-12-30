import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_logger.dart';

/// 内容审核服务
/// 负责评价、评论等UGC内容的审核
class ContentModerationService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 敏感词缓存
  List<String> _sensitiveWords = [];
  DateTime? _lastLoadTime;
  static const _cacheValidDuration = Duration(hours: 1);

  // ========================================
  // 1. 敏感词管理
  // ========================================

  /// 加载敏感词库
  Future<void> loadSensitiveWords() async {
    try {
      // 如果缓存仍然有效，直接返回
      if (_lastLoadTime != null &&
          DateTime.now().difference(_lastLoadTime!) < _cacheValidDuration) {
        return;
      }

      final response = await _supabase
          .from('sensitive_words')
          .select('word')
          .eq('is_active', true)
          .order('word', ascending: true);

      _sensitiveWords = (response as List)
          .map((item) => (item['word'] as String).toLowerCase())
          .toList();

      _lastLoadTime = DateTime.now();
      AppLogger.info('Loaded ${_sensitiveWords.length} sensitive words');
    } catch (e) {
      AppLogger.info('Error loading sensitive words: $e');
      // 使用默认敏感词库作为后备
      _loadDefaultSensitiveWords();
    }
  }

  /// 加载默认敏感词库（后备方案）
  void _loadDefaultSensitiveWords() {
    _sensitiveWords = [
      // 政治敏感词
      '政治敏感词1', '政治敏感词2',

      // 色情低俗
      '色情', '低俗', '裸体', '性交', '色情图片',

      // 暴力恐怖
      '暴力', '恐怖', '杀人', '自杀', '爆炸',

      // 欺诈违法
      '诈骗', '赌博', '毒品', '走私', '洗钱', '传销',

      // 侮辱谩骂
      '傻逼', '操你', '妈的', '去死', '垃圾',
      '傻b', '煞笔', 'sb', 'cnm', 'nmsl',

      // 广告垃圾
      '加微信', '加qq', '联系方式', '私聊', '代办',
      '办证', '刷单', '兼职', '贷款', '发票',

      // 其他违规
      '翻墙', 'vpn', '代理服务器',
    ];
    _lastLoadTime = DateTime.now();
  }

  /// 检测文本中的敏感词
  Future<ModerationResult> checkSensitiveWords(String text) async {
    await loadSensitiveWords();

    final lowerText = text.toLowerCase();
    final foundWords = <String>[];

    for (final word in _sensitiveWords) {
      if (lowerText.contains(word)) {
        foundWords.add(word);
      }
    }

    if (foundWords.isNotEmpty) {
      return ModerationResult(
        isApproved: false,
        reason: 'sensitive_words',
        details: '包含敏感词：${foundWords.join(", ")}',
        foundWords: foundWords,
      );
    }

    return ModerationResult(isApproved: true);
  }

  /// 替换敏感词为星号
  String maskSensitiveWords(String text) {
    String maskedText = text;
    for (final word in _sensitiveWords) {
      if (maskedText.toLowerCase().contains(word)) {
        maskedText = maskedText.replaceAll(
          RegExp(word, caseSensitive: false),
          '*' * word.length,
        );
      }
    }
    return maskedText;
  }

  // ========================================
  // 2. 自动审核规则
  // ========================================

  /// 检查内容长度
  ModerationResult checkContentLength(String content, {
    int minLength = 10,
    int maxLength = 1000,
  }) {
    final trimmedContent = content.trim();

    if (trimmedContent.isEmpty) {
      return ModerationResult(
        isApproved: false,
        reason: 'empty_content',
        details: '内容不能为空',
      );
    }

    if (trimmedContent.length < minLength) {
      return ModerationResult(
        isApproved: false,
        reason: 'content_too_short',
        details: '内容过短，至少需要$minLength个字符',
      );
    }

    if (trimmedContent.length > maxLength) {
      return ModerationResult(
        isApproved: false,
        reason: 'content_too_long',
        details: '内容过长，最多$maxLength个字符',
      );
    }

    return ModerationResult(isApproved: true);
  }

  /// 检测垃圾内容（重复字符、无意义内容）
  ModerationResult checkSpamContent(String content) {
    final trimmedContent = content.trim();

    // 检测重复字符（如：aaaaaa, 111111）
    final repeatingPattern = RegExp(r'(.)\1{9,}'); // 10个或更多重复字符
    if (repeatingPattern.hasMatch(trimmedContent)) {
      return ModerationResult(
        isApproved: false,
        reason: 'spam_repeated_chars',
        details: '检测到大量重复字符，可能是垃圾内容',
      );
    }

    // 检测过多的特殊符号
    final specialChars = RegExp(r'[!@#$%^&*()_+=\-\[\]{};:"|,.<>?/~`]');
    final specialCharCount = specialChars.allMatches(trimmedContent).length;
    final specialCharRatio = specialCharCount / trimmedContent.length;

    if (specialCharRatio > 0.3) { // 超过30%是特殊字符
      return ModerationResult(
        isApproved: false,
        reason: 'spam_special_chars',
        details: '包含过多特殊符号',
      );
    }

    // 检测联系方式模式
    final contactPatterns = [
      RegExp(r'\d{11}'), // 11位数字（可能是电话号码）
      RegExp(r'qq[:：]?\s*\d+', caseSensitive: false),
      RegExp(r'微信[:：]?\s*\w+', caseSensitive: false),
      RegExp(r'vx[:：]?\s*\w+', caseSensitive: false),
      RegExp(r'wx[:：]?\s*\w+', caseSensitive: false),
      RegExp(r'\w+@\w+\.\w+'), // Email地址
    ];

    for (final pattern in contactPatterns) {
      if (pattern.hasMatch(trimmedContent)) {
        return ModerationResult(
          isApproved: false,
          reason: 'spam_contact_info',
          details: '不允许发布联系方式',
        );
      }
    }

    // 检测URL链接
    final urlPattern = RegExp(
      r'(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b',
      caseSensitive: false,
    );
    if (urlPattern.hasMatch(trimmedContent)) {
      return ModerationResult(
        isApproved: false,
        reason: 'spam_url',
        details: '不允许发布外部链接',
      );
    }

    return ModerationResult(isApproved: true);
  }

  /// 检查评分合理性
  ModerationResult checkRatingValidity(int rating, {
    int minRating = 1,
    int maxRating = 5,
  }) {
    if (rating < minRating || rating > maxRating) {
      return ModerationResult(
        isApproved: false,
        reason: 'invalid_rating',
        details: '评分必须在$minRating-$maxRating之间',
      );
    }

    return ModerationResult(isApproved: true);
  }

  /// 检测评分与内容不一致
  ModerationResult checkRatingContentConsistency(int rating, String? content) {
    if (content == null || content.trim().isEmpty) {
      return ModerationResult(isApproved: true); // 无内容时不做检查
    }

    final lowerContent = content.toLowerCase();

    // 高分评价但包含负面词汇
    if (rating >= 4) {
      final negativeWords = [
        '差', '烂', '垃圾', '失望', '后悔', '不好', '很差',
        '糟糕', '恶劣', '坑人', '骗人', '欺诈', '不值',
      ];

      for (final word in negativeWords) {
        if (lowerContent.contains(word)) {
          return ModerationResult(
            isApproved: false,
            reason: 'rating_content_mismatch',
            details: '评分与评价内容不一致（高分但有负面评价）',
            requiresManualReview: true,
          );
        }
      }
    }

    // 低分评价但包含正面词汇
    if (rating <= 2) {
      final positiveWords = [
        '好', '棒', '优秀', '满意', '推荐', '赞', '不错',
        '完美', '专业', '值得', '喜欢',
      ];

      for (final word in positiveWords) {
        if (lowerContent.contains(word)) {
          return ModerationResult(
            isApproved: false,
            reason: 'rating_content_mismatch',
            details: '评分与评价内容不一致（低分但有正面评价）',
            requiresManualReview: true,
          );
        }
      }
    }

    return ModerationResult(isApproved: true);
  }

  // ========================================
  // 3. 综合审核
  // ========================================

  /// 综合审核评价内容
  Future<ModerationResult> moderateReviewContent({
    required String? title,
    required String? content,
    required int overallRating,
    int? serviceRating,
    int? valueRating,
    int? atmosphereRating,
  }) async {
    // 1. 检查评分有效性
    final ratingCheck = checkRatingValidity(overallRating);
    if (!ratingCheck.isApproved) {
      return ratingCheck;
    }

    // 检查其他评分
    if (serviceRating != null) {
      final serviceRatingCheck = checkRatingValidity(serviceRating);
      if (!serviceRatingCheck.isApproved) {
        return serviceRatingCheck;
      }
    }

    if (valueRating != null) {
      final valueRatingCheck = checkRatingValidity(valueRating);
      if (!valueRatingCheck.isApproved) {
        return valueRatingCheck;
      }
    }

    if (atmosphereRating != null) {
      final atmosphereRatingCheck = checkRatingValidity(atmosphereRating);
      if (!atmosphereRatingCheck.isApproved) {
        return atmosphereRatingCheck;
      }
    }

    // 2. 检查标题（如果有）
    if (title != null && title.trim().isNotEmpty) {
      final titleLengthCheck = checkContentLength(title, minLength: 2, maxLength: 100);
      if (!titleLengthCheck.isApproved) {
        return titleLengthCheck;
      }

      final titleSensitiveCheck = await checkSensitiveWords(title);
      if (!titleSensitiveCheck.isApproved) {
        return titleSensitiveCheck;
      }

      final titleSpamCheck = checkSpamContent(title);
      if (!titleSpamCheck.isApproved) {
        return titleSpamCheck;
      }
    }

    // 3. 检查内容（如果有）
    if (content != null && content.trim().isNotEmpty) {
      final contentLengthCheck = checkContentLength(content, minLength: 10, maxLength: 1000);
      if (!contentLengthCheck.isApproved) {
        return contentLengthCheck;
      }

      final contentSensitiveCheck = await checkSensitiveWords(content);
      if (!contentSensitiveCheck.isApproved) {
        return contentSensitiveCheck;
      }

      final contentSpamCheck = checkSpamContent(content);
      if (!contentSpamCheck.isApproved) {
        return contentSpamCheck;
      }

      // 检查评分与内容一致性
      final consistencyCheck = checkRatingContentConsistency(overallRating, content);
      if (!consistencyCheck.isApproved) {
        return consistencyCheck;
      }
    }

    return ModerationResult(
      isApproved: true,
      details: '内容审核通过',
    );
  }

  /// 审核回复内容
  Future<ModerationResult> moderateReplyContent(String replyContent) async {
    // 1. 检查长度
    final lengthCheck = checkContentLength(replyContent, minLength: 10, maxLength: 500);
    if (!lengthCheck.isApproved) {
      return lengthCheck;
    }

    // 2. 检查敏感词
    final sensitiveCheck = await checkSensitiveWords(replyContent);
    if (!sensitiveCheck.isApproved) {
      return sensitiveCheck;
    }

    // 3. 检查垃圾内容
    final spamCheck = checkSpamContent(replyContent);
    if (!spamCheck.isApproved) {
      return spamCheck;
    }

    return ModerationResult(
      isApproved: true,
      details: '回复内容审核通过',
    );
  }

  // ========================================
  // 4. 审核记录
  // ========================================

  /// 记录审核结果
  Future<void> logModerationResult({
    required String contentType, // 'review', 'reply', 'comment'
    required String contentId,
    required ModerationResult result,
    String? userId,
  }) async {
    try {
      await _supabase.from('moderation_logs').insert({
        'content_type': contentType,
        'content_id': contentId,
        'user_id': userId ?? _supabase.auth.currentUser?.id,
        'is_approved': result.isApproved,
        'reason': result.reason,
        'details': result.details,
        'requires_manual_review': result.requiresManualReview,
        'found_words': result.foundWords,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      AppLogger.info('Error logging moderation result: $e');
      // 不抛出异常，审核日志失败不应阻塞主流程
    }
  }

  // ========================================
  // 5. 管理功能
  // ========================================

  /// 添加敏感词
  Future<void> addSensitiveWord(String word, {String? category}) async {
    try {
      await _supabase.from('sensitive_words').insert({
        'word': word.toLowerCase().trim(),
        'category': category ?? 'custom',
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      });

      // 清除缓存，强制重新加载
      _lastLoadTime = null;
      await loadSensitiveWords();
    } catch (e) {
      AppLogger.info('Error adding sensitive word: $e');
      throw Exception('Failed to add sensitive word: $e');
    }
  }

  /// 删除敏感词
  Future<void> removeSensitiveWord(String word) async {
    try {
      await _supabase
          .from('sensitive_words')
          .update({'is_active': false})
          .eq('word', word.toLowerCase().trim());

      // 清除缓存，强制重新加载
      _lastLoadTime = null;
      await loadSensitiveWords();
    } catch (e) {
      AppLogger.info('Error removing sensitive word: $e');
      throw Exception('Failed to remove sensitive word: $e');
    }
  }

  /// 获取待人工审核的内容列表
  Future<List<Map<String, dynamic>>> getPendingManualReviews({
    String? contentType,
    int limit = 50,
  }) async {
    try {
      dynamic query = _supabase
          .from('moderation_logs')
          .select('*')
          .eq('requires_manual_review', true)
          .eq('manual_review_status', 'pending')
          .order('created_at', ascending: false);

      if (contentType != null) {
        query = query.eq('content_type', contentType);
      }

      final response = await query.limit(limit);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      AppLogger.info('Error fetching pending manual reviews: $e');
      return [];
    }
  }
}

/// 审核结果模型
class ModerationResult {
  final bool isApproved;
  final String? reason;
  final String? details;
  final bool requiresManualReview;
  final List<String> foundWords;

  ModerationResult({
    required this.isApproved,
    this.reason,
    this.details,
    this.requiresManualReview = false,
    this.foundWords = const [],
  });

  Map<String, dynamic> toJson() => {
        'is_approved': isApproved,
        'reason': reason,
        'details': details,
        'requires_manual_review': requiresManualReview,
        'found_words': foundWords,
      };

  @override
  String toString() {
    return 'ModerationResult(isApproved: $isApproved, reason: $reason, details: $details)';
  }
}
