import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/models/base_models.dart';
import '../../../../../core/models/order_models.dart';
import '../../../../../core/services/address_service.dart';
import '../../../../../core/utils/app_logger.dart';

/// 家居服务预订Widget
class HomeServiceBookingWidget extends StatefulWidget {
  final RxList<OrderItemRequest> selectedServices;
  final RxDouble totalCost;
  final Rx<Address?> serviceAddress;
  final RxString serviceNotes;
  final Function(Address) onAddressChanged;
  final Function(String) onNotesChanged;
  final Function(int) onRemoveService;
  final Function() onProceedToPayment;

  const HomeServiceBookingWidget({
    super.key,
    required this.selectedServices,
    required this.totalCost,
    required this.serviceAddress,
    required this.serviceNotes,
    required this.onAddressChanged,
    required this.onNotesChanged,
    required this.onRemoveService,
    required this.onProceedToPayment,
  });

  @override
  State<HomeServiceBookingWidget> createState() => _HomeServiceBookingWidgetState();
}

class _HomeServiceBookingWidgetState extends State<HomeServiceBookingWidget> {
  late final AddressService _addressService;
  final TextEditingController _notesController = TextEditingController();
  final Rx<DateTime> _selectedDateTime = DateTime.now().add(const Duration(hours: 2)).obs;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _notesController.text = widget.serviceNotes.value;
    _notesController.addListener(() {
      widget.onNotesChanged(_notesController.text);
    });
  }

  void _initializeServices() {
    try {
      _addressService = Get.find<AddressService>();
    } catch (e) {
      _addressService = Get.put(AddressService());
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.selectedServices.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_basket_outlined,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                '还没有选择服务',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '请先在服务分类中选择需要的服务',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 已选服务列表
            _buildSelectedServicesList(),
            
            const SizedBox(height: 24),
            
            // 服务时间选择
            _buildDateTimeSelector(),
            
            const SizedBox(height: 24),
            
            // 服务地址选择
            _buildAddressSelector(),
            
            const SizedBox(height: 24),
            
            // 服务备注
            _buildNotesSection(),
            
            const SizedBox(height: 24),
            
            // 费用明细
            _buildCostBreakdown(),
            
            const SizedBox(height: 32),
            
            // 确认预订按钮
            _buildConfirmButton(),
          ],
        ),
      );
    });
  }

  Widget _buildSelectedServicesList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '已选服务',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.selectedServices.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final service = widget.selectedServices[index];
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                                                  Text(
                          service.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                          const SizedBox(height: 4),
                          Text(
                            '数量: ${service.quantity}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${(service.unitPrice * service.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                      onPressed: () => widget.onRemoveService(index),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '服务时间',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectDateTime,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _formatDateTime(_selectedDateTime.value),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '服务地址',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: _selectAddress,
                  child: const Text('更换地址'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.serviceAddress.value != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.serviceAddress.value!.addressType.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.serviceAddress.value!.shortAddress,
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
              )
            else
              InkWell(
                onTap: _selectAddress,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_location, color: Colors.blue),
                      SizedBox(width: 12),
                      Text('选择服务地址'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '服务备注',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '请输入特殊要求或备注信息...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostBreakdown() {
    final subtotal = widget.totalCost.value;
    final tax = subtotal * 0.13; // 13% HST
    final total = subtotal + tax;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '费用明细',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('服务费用'),
                Text('\$${subtotal.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('税费 (HST 13%)'),
                Text('\$${tax.toStringAsFixed(2)}'),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '总计',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    final canProceed = widget.selectedServices.isNotEmpty && 
                      widget.serviceAddress.value != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canProceed ? widget.onProceedToPayment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '确认预订并支付',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final now = DateTime.now();
    final initialDate = _selectedDateTime.value.isBefore(now.add(const Duration(hours: 1)))
        ? now.add(const Duration(hours: 2))
        : _selectedDateTime.value;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (date != null) {
      if (!mounted) return;
      
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (time != null) {
        final selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        // 确保选择的时间至少是1小时后
        if (selectedDateTime.isAfter(now.add(const Duration(hours: 1)))) {
          _selectedDateTime.value = selectedDateTime;
        } else {
          Get.snackbar(
            '时间无效',
            '请选择至少1小时后的时间',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
        }
      }
    }
  }

  Future<void> _selectAddress() async {
    try {
      // 加载用户地址
      await _addressService.getUserAddresses();
      final addresses = _addressService.addresses;

      if (addresses.isEmpty) {
        // 如果没有地址，提示用户添加
        Get.snackbar(
          '没有地址',
          '请先添加服务地址',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange,
        );
        return;
      }

      // 显示地址选择对话框
      final selectedAddress = await showDialog<Address>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('选择服务地址'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return ListTile(
                  leading: Icon(
                    address.addressType == AddressType.home
                        ? Icons.home
                        : address.addressType == AddressType.work
                            ? Icons.work
                            : Icons.location_on,
                    color: Colors.blue,
                  ),
                  title: Text(address.addressType.displayName),
                  subtitle: Text(address.shortAddress),
                  onTap: () => Navigator.of(context).pop(address),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ],
        ),
      );

      if (selectedAddress != null) {
        widget.onAddressChanged(selectedAddress);
      }

    } catch (e) {
      AppLogger.error('🏠 选择地址失败: $e');
      Get.snackbar(
        '选择地址失败',
        '无法加载地址列表，请稍后重试',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selectedDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (selectedDate == today) {
      dateStr = '今天';
    } else if (selectedDate == tomorrow) {
      dateStr = '明天';
    } else {
      dateStr = '${dateTime.month}月${dateTime.day}日';
    }

    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    
    return '$dateStr $timeStr';
  }
}
