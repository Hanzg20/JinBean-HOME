// 点评列表页面
// 展示服务的所有点评，支持筛选、排序、投票等功能

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/models/review_models.dart';
import 'reviews_controller.dart';
import 'widgets/review_card.dart';
import 'widgets/review_filter_panel.dart';
import 'widgets/rating_stats_card.dart';

class ReviewsListPage extends StatelessWidget {
  final String serviceId;
  final String serviceTitle;

  const ReviewsListPage({
    Key? key,
    required this.serviceId,
    required this.serviceTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReviewsController());
    
    // 初始化页面数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeReviews(serviceId);
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Reviews'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterPanel(context, controller),
          ),
        ],
      ),
      body: Column(
        children: [
          // 评分统计卡片
          Obx(() => controller.ratingStats.value != null
              ? RatingStatsCard(stats: controller.ratingStats.value!)
              : const SizedBox.shrink()),
          
          // 筛选标签
          Obx(() => _buildFilterTags(controller)),
          
          // 点评列表
          Expanded(
            child: Obx(() {
              if (controller.isLoadingReviews.value && controller.reviews.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              if (controller.reviews.isEmpty) {
                return _buildEmptyState();
              }
              
              return RefreshIndicator(
                onRefresh: () => controller.loadReviews(serviceId, refresh: true),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.reviews.length + 1,
                  itemBuilder: (context, index) {
                    if (index == controller.reviews.length) {
                      // 加载更多
                      if (controller.hasMoreReviews.value) {
                        if (!controller.isLoadingReviews.value) {
                          controller.loadReviews(serviceId);
                        }
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }
                    
                    final review = controller.reviews[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ReviewCard(
                        review: review,
                        onVote: (isHelpful) => controller.voteReview(review.id, isHelpful),
                        onReply: () => _showReplyDialog(context, controller, review),
                        onReport: () => _showReportDialog(context, controller, review),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToWriteReview(context, controller),
        icon: const Icon(Icons.rate_review),
        label: const Text('Write Review'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildFilterTags(ReviewsController controller) {
    final selectedTags = controller.filterOptions.value.tags;
    if (selectedTags.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: selectedTags.length + 1,
        itemBuilder: (context, index) {
          if (index == selectedTags.length) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: TextButton(
                onPressed: () => controller.updateFilterOptions(
                  controller.filterOptions.value.copyWith(tags: []),
                ),
                child: const Text('Clear All'),
              ),
            );
          }
          
          final tag = selectedTags[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              label: Text(tag),
              onDeleted: () {
                final newTags = List<String>.from(selectedTags)..remove(tag);
                controller.updateFilterOptions(
                  controller.filterOptions.value.copyWith(tags: newTags),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to review this service!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterPanel(BuildContext context, ReviewsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReviewFilterPanel(
        filterOptions: controller.filterOptions.value,
        onApply: (options) {
          controller.updateFilterOptions(options);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showReplyDialog(BuildContext context, ReviewsController controller, Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Review'),
        content: TextField(
          controller: controller.replyContentController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter your reply...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isSubmittingReply.value
                ? null
                : () async {
                    final success = await controller.submitReply(review.id, 'user');
                    if (success) Navigator.pop(context);
                  },
            child: controller.isSubmittingReply.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit'),
          )),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context, ReviewsController controller, Review review) {
    String? selectedReason;
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a reason for reporting:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedReason,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Reason',
              ),
              items: const [
                DropdownMenuItem(value: 'spam', child: Text('Spam')),
                DropdownMenuItem(value: 'inappropriate', child: Text('Inappropriate')),
                DropdownMenuItem(value: 'fake', child: Text('Fake Review')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) => selectedReason = value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Additional details (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: selectedReason == null
                ? null
                : () {
                    controller.reportReview(
                      review.id,
                      selectedReason!,
                      descriptionController.text.trim().isEmpty
                          ? null
                          : descriptionController.text.trim(),
                    );
                    Navigator.pop(context);
                  },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _navigateToWriteReview(BuildContext context, ReviewsController controller) {
    Get.toNamed('/write_review', arguments: {
      'serviceId': serviceId,
      'serviceTitle': serviceTitle,
    });
  }
} 