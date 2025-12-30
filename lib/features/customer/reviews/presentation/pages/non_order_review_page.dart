import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/models/review_models.dart';
import 'package:jinbeanpod_83904710/core/services/review_service.dart';
import 'package:jinbeanpod_83904710/features/customer/services/presentation/service_detail_controller.dart';

/// 非订单评价发布页面
/// 支持多种评价类型：到店体验、咨询体验、在线互动、环境感知
class NonOrderReviewPage extends StatefulWidget {
  final String serviceId;
  final String serviceName;
  final String providerId;

  const NonOrderReviewPage({
    Key? key,
    required this.serviceId,
    required this.serviceName,
    required this.providerId,
  }) : super(key: key);

  @override
  State<NonOrderReviewPage> createState() => _NonOrderReviewPageState();
}

class _NonOrderReviewPageState extends State<NonOrderReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // 固定使用到店体验类型
  final ReviewType _selectedReviewType = ReviewType.visitBased;
  
  // 评分
  int _overallRating = 0;
  int _qualityRating = 0;
  int _serviceRating = 0;
  int _valueRating = 0;
  int _atmosphereRating = 0;

  // 标签
  List<String> _selectedTags = [];
  List<String> _availableTags = [
    '环境优雅', '装修精美', '空间宽敞', '氛围温馨', '干净整洁',
    '服务热情', '响应迅速', '专业细致', '态度友好', '效率很高',
    '性价比高', '价格合理', '物有所值', '价格实惠', '价格偏贵',
    '味道不错', '食材新鲜', '分量充足', '口味独特', '健康营养',
  ];

  // 其他选项
  bool _isAnonymous = false;
  List<String> _images = [];
  List<String> _videos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('评价 ${widget.serviceName}'),
        actions: [
          TextButton(
            onPressed: _submitReview,
            child: const Text('发布', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRatingSection(),
              const SizedBox(height: 24),
              _buildContentSection(),
              const SizedBox(height: 24),
              _buildTagsSection(),
              const SizedBox(height: 24),
              _buildMediaSection(),
              const SizedBox(height: 24),
              _buildOptionsSection(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }


  /// 评分部分
  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '评分',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildRatingRow('整体评分', _overallRating, (rating) {
          setState(() => _overallRating = rating);
        }, required: true),
        const SizedBox(height: 16),
        _buildRatingRow('服务质量', _serviceRating, (rating) {
          setState(() => _serviceRating = rating);
        }),
        const SizedBox(height: 16),
        _buildRatingRow('性价比', _valueRating, (rating) {
          setState(() => _valueRating = rating);
        }),
        const SizedBox(height: 16),
        _buildRatingRow('环境氛围', _atmosphereRating, (rating) {
          setState(() => _atmosphereRating = rating);
        }),
      ],
    );
  }

  /// 评分行组件
  Widget _buildRatingRow(String label, int rating, Function(int) onChanged, {bool required = false}) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label + (required ? ' *' : ''),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => onChanged(index + 1),
                child: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 28,
                ),
              );
            }),
          ),
        ),
        Text(
          rating > 0 ? '$rating分' : '未评分',
          style: TextStyle(
            color: rating > 0 ? Colors.amber[700] : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 内容部分
  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '评价内容',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: '评价标题',
            hintText: '给您的评价起个标题...',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入评价标题';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _contentController,
          decoration: const InputDecoration(
            labelText: '详细评价',
            hintText: '分享您的真实体验...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入详细评价';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 标签部分
  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '评价标签',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
              selectedColor: Colors.blue[100],
              checkmarkColor: Colors.blue[700],
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 媒体部分
  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '图片/视频',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addImage,
                icon: const Icon(Icons.photo),
                label: const Text('添加图片'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addVideo,
                icon: const Icon(Icons.videocam),
                label: const Text('添加视频'),
              ),
            ),
          ],
        ),
        if (_images.isNotEmpty || _videos.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('已添加: ${_images.length}张图片, ${_videos.length}个视频'),
        ],
      ],
    );
  }

  /// 选项部分
  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '其他选项',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('匿名评价'),
          subtitle: const Text('不显示您的用户名'),
          value: _isAnonymous,
          onChanged: (value) {
            setState(() {
              _isAnonymous = value;
            });
          },
        ),
      ],
    );
  }

  /// 提交按钮
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitReview,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
        ),
        child: const Text(
          '发布评价',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }


  /// 添加图片
  void _addImage() {
    // TODO: 实现图片选择功能
    Get.snackbar('提示', '图片上传功能开发中...');
  }

  /// 添加视频
  void _addVideo() {
    // TODO: 实现视频选择功能
    Get.snackbar('提示', '视频上传功能开发中...');
  }

  /// 提交评价
  void _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_overallRating == 0) {
      Get.snackbar('错误', '请选择整体评分');
      return;
    }

    try {
      // 显示加载状态
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final request = CreateReviewRequest(
        serviceId: widget.serviceId,
        revieweeId: widget.providerId,
        orderId: null, // 非订单评价
        reviewType: _selectedReviewType,
        overallRating: _overallRating,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        serviceRating: _serviceRating > 0 ? _serviceRating : null,
        valueRating: _valueRating > 0 ? _valueRating : null,
        atmosphereRating: _atmosphereRating > 0 ? _atmosphereRating : null,
        images: _images,
        videos: _videos,
        tags: _selectedTags,
        isAnonymous: _isAnonymous,
      );

      // 调用API提交评价
      final reviewService = Get.find<ReviewService>();
      final newReview = await reviewService.createReview(request);

      // 关闭加载对话框
      Get.back();

      // 刷新服务详情页面的评价列表
      try {
        final serviceDetailController = Get.find<ServiceDetailController>();
        await serviceDetailController.loadReviews(widget.serviceId, refresh: true);
      } catch (e) {
        // 如果找不到ServiceDetailController，忽略错误
      }

      // 显示成功消息并自动返回
      Get.snackbar(
        '评价提交成功！', 
        '感谢您的反馈，您的评价已成功提交。',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
      );
      
      // 延迟返回，让用户看到成功消息
      print('🔄 开始延迟返回，2秒后执行Get.back()');
      Future.delayed(const Duration(seconds: 2), () {
        print('🔄 延迟时间到，准备执行Get.back()');
        if (mounted) {
          print('✅ 页面仍然mounted，执行Get.back()');
          Get.back();
        } else {
          print('❌ 页面已unmounted，无法执行Get.back()');
        }
      });
    } catch (e) {
      // 关闭加载对话框
      Get.back();
      Get.snackbar('错误', '提交失败: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
