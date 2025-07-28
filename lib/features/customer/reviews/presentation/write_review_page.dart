// 写点评页面
// 用户可以为服务写点评，包括评分、标签、图片等

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/models/review_models.dart';
import 'reviews_controller.dart';
import 'widgets/rating_selector.dart';
import 'widgets/tag_selector.dart';
import 'widgets/image_upload_widget.dart';

class WriteReviewPage extends StatelessWidget {
  final String serviceId;
  final String serviceTitle;

  const WriteReviewPage({
    Key? key,
    required this.serviceId,
    required this.serviceTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReviewsController());
    
    // 初始化页面数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadTags();
      controller.loadReviewableOrders(serviceId);
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Write Review'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          Obx(() => TextButton(
            onPressed: controller.isSubmittingReview.value
                ? null
                : () => _submitReview(context, controller),
            child: controller.isSubmittingReview.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit'),
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 服务信息
            _buildServiceInfo(),
            const SizedBox(height: 24),
            
            // 整体评分
            _buildOverallRating(controller),
            const SizedBox(height: 24),
            
            // 详细评分
            _buildDetailedRatings(controller),
            const SizedBox(height: 24),
            
            // 点评内容
            _buildReviewContent(controller),
            const SizedBox(height: 24),
            
            // 标签选择
            _buildTagSelection(controller),
            const SizedBox(height: 24),
            
            // 图片上传
            _buildImageUpload(controller),
            const SizedBox(height: 24),
            
            // 匿名选项
            _buildAnonymousOption(controller),
            const SizedBox(height: 24),
            
            // 订单选择（如果有）
            _buildOrderSelection(controller),
            const SizedBox(height: 32),
            
            // 提交按钮
            _buildSubmitButton(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.build,
                color: Colors.blue,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Share your experience with this service',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallRating(ReviewsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overall Rating *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        RatingSelector(
          rating: controller.overallRating.value,
          onRatingChanged: controller.setOverallRating,
          size: 32,
        ),
      ],
    );
  }

  Widget _buildDetailedRatings(ReviewsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Ratings (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildRatingRow('Quality', controller.qualityRating.value, controller.setQualityRating),
        const SizedBox(height: 12),
        _buildRatingRow('Punctuality', controller.punctualityRating.value, controller.setPunctualityRating),
        const SizedBox(height: 12),
        _buildRatingRow('Communication', controller.communicationRating.value, controller.setCommunicationRating),
        const SizedBox(height: 12),
        _buildRatingRow('Value', controller.valueRating.value, controller.setValueRating),
      ],
    );
  }

  Widget _buildRatingRow(String label, double rating, Function(double) onRatingChanged) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Expanded(
          flex: 3,
          child: RatingSelector(
            rating: rating,
            onRatingChanged: onRatingChanged,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewContent(ReviewsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review Content *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.reviewContentController,
          maxLines: 5,
          maxLength: 1000,
          decoration: InputDecoration(
            hintText: 'Share your experience with this service...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue[600]!),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Text(
          '${controller.reviewContentController.text.length}/1000 characters',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        )),
      ],
    );
  }

  Widget _buildTagSelection(ReviewsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => TagSelector(
          availableTags: controller.tags.map((tag) => tag.name).toList(),
          selectedTags: controller.selectedTags.toList(),
          onTagToggled: controller.toggleTag,
        )),
      ],
    );
  }

  Widget _buildImageUpload(ReviewsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photos (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => ImageUploadWidget(
          images: controller.reviewImages.toList(),
          onImageAdded: controller.addImage,
          onImageRemoved: controller.removeImage,
          maxImages: 5,
        )),
      ],
    );
  }

  Widget _buildAnonymousOption(ReviewsController controller) {
    return Row(
      children: [
        Obx(() => Checkbox(
          value: controller.isAnonymous.value,
          onChanged: (value) => controller.toggleAnonymous(),
        )),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Submit anonymously',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSelection(ReviewsController controller) {
    return Obx(() {
      final orders = controller.reviewableOrders;
      if (orders.isEmpty) return const SizedBox.shrink();
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Order (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: null,
              hint: const Text('Choose an order'),
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: orders.map((order) {
                return DropdownMenuItem(
                  value: order['id'],
                  child: Text('Order #${order['id'].substring(0, 8)}'),
                );
              }).toList(),
              onChanged: (orderId) {
                // TODO: 实现订单选择逻辑
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSubmitButton(BuildContext context, ReviewsController controller) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
        onPressed: controller.isSubmittingReview.value
            ? null
            : () => _submitReview(context, controller),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: controller.isSubmittingReview.value
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Submitting...'),
                ],
              )
            : const Text(
                'Submit Review',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      )),
    );
  }

  Future<void> _submitReview(BuildContext context, ReviewsController controller) async {
    final success = await controller.submitReview();
    if (success) {
      Get.back(result: true);
      Get.snackbar(
        'Success',
        'Review submitted successfully!',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: const Duration(seconds: 3),
      );
    }
  }
} 