// 点评系统控制器
// 管理点评相关的状态和业务逻辑

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/models/review_models.dart';
import '../../../../core/services/review_service.dart';

class ReviewsController extends GetxController {
  final ReviewService _reviewService = Get.find<ReviewService>();

  // ========================================
  // 状态变量
  // ========================================

  // 点评列表
  final RxList<Review> reviews = <Review>[].obs;
  final RxList<ReviewReply> replies = <ReviewReply>[].obs;
  final RxList<ReviewTag> tags = <ReviewTag>[].obs;
  
  // 评分统计
  final Rx<ServiceRatingStats?> ratingStats = Rx<ServiceRatingStats?>(null);
  
  // 加载状态
  final RxBool isLoadingReviews = false.obs;
  final RxBool isLoadingReplies = false.obs;
  final RxBool isLoadingTags = false.obs;
  final RxBool isLoadingStats = false.obs;
  final RxBool isSubmittingReview = false.obs;
  final RxBool isSubmittingReply = false.obs;
  
  // 分页状态
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreReviews = true.obs;
  final RxInt totalReviews = 0.obs;
  
  // 筛选选项
  final Rx<ReviewFilterOptions> filterOptions = ReviewFilterOptions().obs;
  
  // 当前服务ID
  final RxString currentServiceId = ''.obs;
  
  // 表单控制器
  final TextEditingController reviewContentController = TextEditingController();
  final TextEditingController replyContentController = TextEditingController();
  
  // 评分状态
  final RxDouble overallRating = 0.0.obs;
  final RxDouble qualityRating = 0.0.obs;
  final RxDouble punctualityRating = 0.0.obs;
  final RxDouble communicationRating = 0.0.obs;
  final RxDouble valueRating = 0.0.obs;
  
  // 选中的标签
  final RxList<String> selectedTags = <String>[].obs;
  
  // 匿名状态
  final RxBool isAnonymous = false.obs;
  
  // 图片列表
  final RxList<String> reviewImages = <String>[].obs;

  // ========================================
  // 初始化
  // ========================================

  @override
  void onInit() {
    super.onInit();
    print('=== ReviewsController onInit ===');
  }

  @override
  void onClose() {
    reviewContentController.dispose();
    replyContentController.dispose();
    super.onClose();
  }

  // ========================================
  // 加载数据方法
  // ========================================

  /// 初始化点评页面
  Future<void> initializeReviews(String serviceId) async {
    currentServiceId.value = serviceId;
    await Future.wait([
      loadReviews(serviceId, refresh: true),
      loadRatingStats(serviceId),
      loadTags(),
    ]);
  }

  /// 加载点评列表
  Future<void> loadReviews(String serviceId, {bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      reviews.clear();
      hasMoreReviews.value = true;
    }

    if (!hasMoreReviews.value || isLoadingReviews.value) return;

    isLoadingReviews.value = true;
    try {
      final newReviews = await _reviewService.getServiceReviews(
        serviceId,
        filterOptions: filterOptions.value,
        page: currentPage.value,
        limit: 10,
      );

      if (refresh) {
        reviews.assignAll(newReviews);
      } else {
        reviews.addAll(newReviews);
      }

      hasMoreReviews.value = newReviews.length == 10;
      currentPage.value++;
      totalReviews.value = reviews.length;
    } catch (e) {
      print('Error loading reviews: $e');
      Get.snackbar(
        'Error',
        'Failed to load reviews. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoadingReviews.value = false;
    }
  }

  /// 加载评分统计
  Future<void> loadRatingStats(String serviceId) async {
    isLoadingStats.value = true;
    try {
      final stats = await _reviewService.getServiceRatingStats(serviceId);
      ratingStats.value = stats;
    } catch (e) {
      print('Error loading rating stats: $e');
    } finally {
      isLoadingStats.value = false;
    }
  }

  /// 加载点评标签
  Future<void> loadTags() async {
    isLoadingTags.value = true;
    try {
      final tagList = await _reviewService.getReviewTags();
      tags.assignAll(tagList);
    } catch (e) {
      print('Error loading tags: $e');
    } finally {
      isLoadingTags.value = false;
    }
  }

  /// 加载点评回复
  Future<void> loadReplies(String reviewId) async {
    isLoadingReplies.value = true;
    try {
      final replyList = await _reviewService.getReviewReplies(reviewId);
      replies.assignAll(replyList);
    } catch (e) {
      print('Error loading replies: $e');
    } finally {
      isLoadingReplies.value = false;
    }
  }

  // ========================================
  // 提交点评方法
  // ========================================

  /// 提交点评
  Future<bool> submitReview() async {
    if (!_validateReviewForm()) return false;

    isSubmittingReview.value = true;
    try {
      final request = CreateReviewRequest(
        serviceId: currentServiceId.value,
        providerId: '', // TODO: 从服务详情获取
        overallRating: overallRating.value,
        content: {
          'en': reviewContentController.text,
          'zh': reviewContentController.text,
        },
        isAnonymous: isAnonymous.value,
        qualityRating: qualityRating.value > 0 ? qualityRating.value : null,
        punctualityRating: punctualityRating.value > 0 ? punctualityRating.value : null,
        communicationRating: communicationRating.value > 0 ? communicationRating.value : null,
        valueRating: valueRating.value > 0 ? valueRating.value : null,
        tags: selectedTags.toList(),
        images: reviewImages.toList(),
      );

      final newReview = await _reviewService.createReview(request);
      reviews.insert(0, newReview);
      
      // 更新评分统计
      await loadRatingStats(currentServiceId.value);
      
      // 重置表单
      _resetReviewForm();
      
      Get.snackbar(
        'Success',
        'Review submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
      );
      
      return true;
    } catch (e) {
      print('Error submitting review: $e');
      Get.snackbar(
        'Error',
        'Failed to submit review. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return false;
    } finally {
      isSubmittingReview.value = false;
    }
  }

  /// 提交回复
  Future<bool> submitReply(String reviewId, String replierType) async {
    if (replyContentController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a reply message.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return false;
    }

    isSubmittingReply.value = true;
    try {
      final request = CreateReviewReplyRequest(
        reviewId: reviewId,
        replierType: replierType,
        content: {
          'en': replyContentController.text,
          'zh': replyContentController.text,
        },
        isAnonymous: isAnonymous.value,
      );

      final newReply = await _reviewService.createReviewReply(request);
      replies.add(newReply);
      
      // 重置回复表单
      replyContentController.clear();
      
      Get.snackbar(
        'Success',
        'Reply submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
      );
      
      return true;
    } catch (e) {
      print('Error submitting reply: $e');
      Get.snackbar(
        'Error',
        'Failed to submit reply. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return false;
    } finally {
      isSubmittingReply.value = false;
    }
  }

  // ========================================
  // 投票和举报方法
  // ========================================

  /// 投票点评有用性
  Future<void> voteReview(String reviewId, bool isHelpful) async {
    try {
      await _reviewService.voteReview(ReviewVoteRequest(
        reviewId: reviewId,
        isHelpful: isHelpful,
      ));
      
      // 更新本地点评数据
      final reviewIndex = reviews.indexWhere((r) => r.id == reviewId);
      if (reviewIndex != -1) {
        final review = reviews[reviewIndex];
        final newHelpfulCount = isHelpful 
            ? review.helpfulCount + 1 
            : review.helpfulCount - 1;
        
        reviews[reviewIndex] = review.copyWith(
          helpfulCount: newHelpfulCount,
          userVotedHelpful: isHelpful,
        );
      }
    } catch (e) {
      print('Error voting review: $e');
      Get.snackbar(
        'Error',
        'Failed to vote. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  /// 举报点评
  Future<void> reportReview(String reviewId, String reason, String? description) async {
    try {
      await _reviewService.reportReview(ReviewReportRequest(
        reviewId: reviewId,
        reason: reason,
        description: description,
      ));
      
      Get.snackbar(
        'Success',
        'Review reported successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
      );
    } catch (e) {
      print('Error reporting review: $e');
      Get.snackbar(
        'Error',
        'Failed to report review. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  // ========================================
  // 筛选和排序方法
  // ========================================

  /// 更新筛选选项
  void updateFilterOptions(ReviewFilterOptions newOptions) {
    filterOptions.value = newOptions;
    loadReviews(currentServiceId.value, refresh: true);
  }

  /// 按评分筛选
  void filterByRating(double? minRating, double? maxRating) {
    filterOptions.value = filterOptions.value.copyWith(
      minRating: minRating,
      maxRating: maxRating,
    );
    loadReviews(currentServiceId.value, refresh: true);
  }

  /// 按标签筛选
  void filterByTags(List<String> tags) {
    filterOptions.value = filterOptions.value.copyWith(tags: tags);
    loadReviews(currentServiceId.value, refresh: true);
  }

  /// 按排序方式筛选
  void sortBy(String sortBy) {
    filterOptions.value = filterOptions.value.copyWith(sortBy: sortBy);
    loadReviews(currentServiceId.value, refresh: true);
  }

  // ========================================
  // 表单操作方法
  // ========================================

  /// 设置评分
  void setOverallRating(double rating) {
    overallRating.value = rating;
  }

  void setQualityRating(double rating) {
    qualityRating.value = rating;
  }

  void setPunctualityRating(double rating) {
    punctualityRating.value = rating;
  }

  void setCommunicationRating(double rating) {
    communicationRating.value = rating;
  }

  void setValueRating(double rating) {
    valueRating.value = rating;
  }

  /// 切换标签选择
  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  /// 切换匿名状态
  void toggleAnonymous() {
    isAnonymous.value = !isAnonymous.value;
  }

  /// 添加图片
  void addImage(String imageUrl) {
    reviewImages.add(imageUrl);
  }

  /// 移除图片
  void removeImage(String imageUrl) {
    reviewImages.remove(imageUrl);
  }

  /// 清空图片
  void clearImages() {
    reviewImages.clear();
  }

  // ========================================
  // 验证方法
  // ========================================

  /// 验证点评表单
  bool _validateReviewForm() {
    if (overallRating.value == 0) {
      Get.snackbar(
        'Error',
        'Please provide an overall rating.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return false;
    }

    if (reviewContentController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a review comment.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return false;
    }

    if (reviewContentController.text.trim().length < 10) {
      Get.snackbar(
        'Error',
        'Review comment must be at least 10 characters long.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return false;
    }

    return true;
  }

  // ========================================
  // 重置方法
  // ========================================

  /// 重置点评表单
  void _resetReviewForm() {
    reviewContentController.clear();
    overallRating.value = 0.0;
    qualityRating.value = 0.0;
    punctualityRating.value = 0.0;
    communicationRating.value = 0.0;
    valueRating.value = 0.0;
    selectedTags.clear();
    isAnonymous.value = false;
    reviewImages.clear();
  }

  /// 重置回复表单
  void resetReplyForm() {
    replyContentController.clear();
  }

  // ========================================
  // 工具方法
  // ========================================

  /// 获取本地化文本
  String getLocalizedText(Map<String, String> content) {
    final lang = Get.locale?.languageCode ?? 'zh';
    return content[lang] ?? content['en'] ?? content['zh'] ?? '';
  }

  /// 格式化日期
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// 检查用户是否可以评价
  Future<bool> canUserReview(String serviceId) async {
    try {
      return !(await _reviewService.hasUserReviewedService(serviceId));
    } catch (e) {
      print('Error checking if user can review: $e');
      return false;
    }
  }

  /// 获取用户可评价的订单
  Future<List<Map<String, dynamic>>> getReviewableOrders() async {
    try {
      return await _reviewService.getUserReviewableOrders();
    } catch (e) {
      print('Error getting reviewable orders: $e');
      return [];
    }
  }
} 