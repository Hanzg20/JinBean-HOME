import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service_detail_controller.dart';

/// 服务日程安排对话框组件
class ServiceScheduleDialog extends StatefulWidget {
  final ServiceDetailController controller;

  const ServiceScheduleDialog({
    super.key,
    required this.controller,
  });

  @override
  State<ServiceScheduleDialog> createState() => _ServiceScheduleDialogState();
}

class _ServiceScheduleDialogState extends State<ServiceScheduleDialog> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedTimeSlot = '';
  final List<String> _availableTimeSlots = [
    '09:00 - 11:00',
    '11:00 - 13:00',
    '14:00 - 16:00',
    '16:00 - 18:00',
    '18:00 - 20:00',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 头部
            Row(
              children: [
                Icon(Icons.schedule, color: theme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '安排服务时间',
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
            
            // 内容
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 服务信息
                    _buildServiceInfo(),
                    
                    const SizedBox(height: 24),
                    
                    // 日期选择
                    _buildDateSelection(),
                    
                    const SizedBox(height: 24),
                    
                    // 时间选择
                    _buildTimeSelection(),
                    
                    const SizedBox(height: 24),
                    
                    // 可用时段
                    _buildAvailableTimeSlots(),
                    
                    const SizedBox(height: 24),
                    
                    // 注意事项
                    _buildNotes(),
                  ],
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
                    onPressed: _canConfirm() ? _confirmSchedule : null,
                    child: const Text('确认安排'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[300],
            ),
            child: const Icon(Icons.cleaning_services, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '专业清洁服务',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '标准清洁套餐',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '预计时长：2-3小时',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择服务日期',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedDate != null
                      ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                      : '请选择日期',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedDate != null ? Colors.black : Colors.grey[500],
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _selectDate(context),
                child: const Text('选择'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择服务时间',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedTime != null
                      ? _selectedTime!.format(context)
                      : '请选择时间',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedTime != null ? Colors.black : Colors.grey[500],
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _selectTime(context),
                child: const Text('选择'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableTimeSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '可用时段',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTimeSlots.map((slot) {
            final isSelected = _selectedTimeSlot == slot;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedTimeSlot = isSelected ? '' : slot;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  slot,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                '注意事项',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• 请确保在服务时间前准备好房间\n'
            '• 如需取消或改期，请提前24小时通知\n'
            '• 服务人员会提前15分钟到达\n'
            '• 如有特殊要求，请在备注中说明',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      selectableDayPredicate: (DateTime date) {
        // 排除周末（可选）
        return date.weekday != DateTime.saturday && date.weekday != DateTime.sunday;
      },
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
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  bool _canConfirm() {
    return _selectedDate != null && (_selectedTime != null || _selectedTimeSlot.isNotEmpty);
  }

  void _confirmSchedule() {
    final selectedTime = _selectedTimeSlot.isNotEmpty 
        ? _selectedTimeSlot 
        : _selectedTime?.format(context);
    
    // 更新控制器中的预订详情
    widget.controller.bookingDetails['serviceDate'] = _selectedDate?.toIso8601String();
    widget.controller.bookingDetails['serviceTime'] = selectedTime;
    widget.controller.bookingDetails['timeSlot'] = _selectedTimeSlot;
    
    Get.back(); // 关闭对话框
    
    // 显示确认信息
    Get.snackbar(
      '日程已安排',
      '您的服务已安排在 ${_selectedDate?.toString().split(' ')[0]} $selectedTime',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
    
    // 可以在这里调用预订API
    // widget.controller.createBooking();
  }
} 