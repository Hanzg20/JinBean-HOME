import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service_detail_controller.dart';

class ServiceBookingDialog extends StatelessWidget {
  final ServiceDetailController controller;

  const ServiceBookingDialog({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Book Service'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Service Date',
              hintText: 'Select date',
            ),
            readOnly: true,
            onTap: () => _selectDate(),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Service Time',
              hintText: 'Select time',
            ),
            readOnly: true,
            onTap: () => _selectTime(),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Requirements',
              hintText: 'Enter your requirements',
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _bookService(),
          child: const Text('Book'),
        ),
      ],
    );
  }

  void _selectDate() {
    showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((date) {
      if (date != null) {
        // TODO: 更新控制器中的日期
      }
    });
  }

  void _selectTime() {
    showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    ).then((time) {
      if (time != null) {
        // TODO: 更新控制器中的时间
      }
    });
  }

  void _bookService() {
    Get.back();
    Get.snackbar(
      'Booking Successful',
      'Your service has been booked successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
