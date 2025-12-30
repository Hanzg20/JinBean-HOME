import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/models/review_models.dart';
import '../../../../../core/services/review_service.dart';

class ProviderReplyDialog extends StatefulWidget {
  final Review review;
  final VoidCallback? onReplySent;

  const ProviderReplyDialog({
    super.key,
    required this.review,
    this.onReplySent,
  });

  @override
  State<ProviderReplyDialog> createState() => _ProviderReplyDialogState();
}

class _ProviderReplyDialogState extends State<ProviderReplyDialog> {
  final TextEditingController _replyController = TextEditingController();
  final ReviewService _reviewService = Get.find<ReviewService>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 如果已有回复，显示在输入框中
    if (widget.review.providerResponse != null) {
      _replyController.text = widget.review.providerResponse!;
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _submitReply() async {
    final replyText = _replyController.text.trim();

    if (replyText.isEmpty) {
      setState(() {
        _errorMessage = '请输入回复内容';
      });
      return;
    }

    if (replyText.length < 10) {
      setState(() {
        _errorMessage = '回复内容至少需要10个字符';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _reviewService.replyToReview(widget.review.id, replyText);

      Get.back();
      Get.snackbar(
        '回复成功',
        '您的回复已发布',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // 触发回调刷新评价列表
      widget.onReplySent?.call();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '回复评价',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 原评价内容
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          widget.review.getDisplayName()[0].toUpperCase(),
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.review.getDisplayName(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildRatingStars(widget.review.overallRating),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.review.getLocalizedContent('zh') ?? '无评价内容',
                    style: const TextStyle(fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 回复输入框
            const Text(
              '您的回复',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _replyController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: '请输入您的回复内容...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                errorText: _errorMessage,
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 8),

            // 提示信息
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '友好、专业的回复有助于建立良好的客户关系',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Get.back(),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitReply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.review.providerResponse != null ? '更新回复' : '发布回复',
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating) {
          return const Icon(Icons.star, color: Colors.amber, size: 14);
        } else {
          return Icon(Icons.star_border, color: Colors.grey[400], size: 14);
        }
      }),
    );
  }
}