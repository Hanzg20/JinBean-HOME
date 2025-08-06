import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service_detail_controller.dart';

/// 服务报价对话框组件
class ServiceQuoteDialog extends StatelessWidget {
  final ServiceDetailController controller;

  const ServiceQuoteDialog({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(64),
          bottomLeft: const Radius.circular(16),
          bottomRight: const Radius.circular(16),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部
            Row(
              children: [
                Icon(Icons.request_quote, color: colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '获取报价',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '为这项服务获取个性化报价',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 快速选项
            Text(
              '您希望如何继续？',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // 选项按钮
            Column(
              children: [
                // 快速报价
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.flash_on, color: colorScheme.primary),
                  ),
                  title: const Text('快速报价'),
                  subtitle: const Text('提交基本需求获取快速估算'),
                  onTap: () {
                    Get.back();
                    _showQuickQuoteForm(context);
                  },
                ),
                
                // 详细报价
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.description, color: colorScheme.secondary),
                  ),
                  title: const Text('详细报价'),
                  subtitle: const Text('提供详细需求获取准确定价'),
                  onTap: () {
                    Get.back();
                    _showDetailedQuoteForm(context);
                  },
                ),
                
                // 先聊天
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.chat, color: Colors.green),
                  ),
                  title: const Text('先聊天'),
                  subtitle: const Text('与提供商讨论您的需求'),
                  onTap: () {
                    Get.back();
                    _startChat();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 说明
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '提供商将在24小时内回复详细报价',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue[700],
                      ),
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

  void _showQuickQuoteForm(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final requirementsController = TextEditingController();
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(64),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '快速报价请求',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: requirementsController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: '简要描述',
                  hintText: '描述您的需求（例如："3居室公寓清洁"）',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(48),
                      bottomLeft: const Radius.circular(12),
                      bottomRight: const Radius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (requirementsController.text.trim().isNotEmpty) {
                          controller.updateQuoteDetails('requirements', requirementsController.text.trim());
                          Get.back();
                          _submitQuickQuote();
                        } else {
                          Get.snackbar(
                            '错误',
                            '请描述您的需求',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      child: const Text('提交'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailedQuoteForm(BuildContext context) {
    // 导航到Overview tab并显示完整的报价表单
    Get.back(); // 关闭对话框
    
    // 显示详细报价表单
    Get.dialog(
      _DetailedQuoteForm(controller: controller),
    );
  }

  void _startChat() {
    Get.snackbar(
      '聊天功能',
      '聊天功能即将推出',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _submitQuickQuote() {
    // 显示加载状态
    Get.dialog(
      const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('正在提交快速报价请求...'),
          ],
        ),
      ),
    );
    
    // 提交快速报价
    controller.submitQuoteRequest().then((_) {
      Get.back(); // 关闭加载对话框
      
      if (controller.quoteError.value.isEmpty) {
        Get.snackbar(
          '快速报价已提交',
          '您的报价请求已发送。您将在24小时内收到回复。',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          '错误',
          controller.quoteError.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
  }
}

/// 详细报价表单
class _DetailedQuoteForm extends StatefulWidget {
  final ServiceDetailController controller;

  const _DetailedQuoteForm({
    required this.controller,
  });

  @override
  State<_DetailedQuoteForm> createState() => _DetailedQuoteFormState();
}

class _DetailedQuoteFormState extends State<_DetailedQuoteForm> {
  final _formKey = GlobalKey<FormState>();
  final _requirementsController = TextEditingController();
  final _budgetController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _urgencyLevel = 'normal';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 头部
            Row(
              children: [
                Icon(Icons.description, color: theme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '详细报价请求',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 表单
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 需求描述
                      TextFormField(
                        controller: _requirementsController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: '详细需求描述',
                          hintText: '请详细描述您的服务需求...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '请输入需求描述';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 预算范围
                      TextFormField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '预算范围（可选）',
                          hintText: '例如：100-200 USD',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 服务日期
                      ListTile(
                        title: const Text('服务日期'),
                        subtitle: Text(_selectedDate?.toString().split(' ')[0] ?? '请选择日期'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 服务时间
                      ListTile(
                        title: const Text('服务时间'),
                        subtitle: Text(_selectedTime?.format(context) ?? '请选择时间'),
                        trailing: const Icon(Icons.access_time),
                        onTap: () => _selectTime(context),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 紧急程度
                      DropdownButtonFormField<String>(
                        value: _urgencyLevel,
                        decoration: const InputDecoration(
                          labelText: '紧急程度',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'low', child: Text('不急')),
                          DropdownMenuItem(value: 'normal', child: Text('正常')),
                          DropdownMenuItem(value: 'high', child: Text('紧急')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _urgencyLevel = value ?? 'normal';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitDetailedQuote,
                    child: const Text('提交报价请求'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitDetailedQuote() {
    if (_formKey.currentState?.validate() ?? false) {
      // 更新控制器中的报价详情
      widget.controller.updateQuoteDetails('requirements', _requirementsController.text);
      widget.controller.updateQuoteDetails('budget', _budgetController.text);
      widget.controller.updateQuoteDetails('serviceDate', _selectedDate?.toIso8601String());
      widget.controller.updateQuoteDetails('serviceTime', _selectedTime?.format(context));
      widget.controller.updateQuoteDetails('urgencyLevel', _urgencyLevel);
      
      Get.back(); // 关闭表单
      
      // 提交详细报价
      widget.controller.submitQuoteRequest().then((_) {
        if (widget.controller.quoteError.value.isEmpty) {
          Get.snackbar(
            '详细报价已提交',
            '您的详细报价请求已发送。您将在24小时内收到回复。',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
        } else {
          Get.snackbar(
            '错误',
            widget.controller.quoteError.value,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      });
    }
  }
} 