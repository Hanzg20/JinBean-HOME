import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'create_order_controller.dart';
import '../../../../shared/widgets/smart_address_input.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';

class CreateOrderPage extends GetView<CreateOrderController> {
  const CreateOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createOrder),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 服务信息卡片
              _buildServiceInfoCard(context),
              const SizedBox(height: 24),
              
              // 服务商信息
              _buildProviderInfoCard(context),
              const SizedBox(height: 24),
              
              // 订单详情表单
              _buildOrderDetailsForm(context),
              const SizedBox(height: 24),
              
              // 价格信息
              _buildPriceInfo(context),
              const SizedBox(height: 32),
              
              // 创建订单按钮
              _buildCreateOrderButton(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildServiceInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.serviceInformation,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.category, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.serviceName.value.isNotEmpty ? controller.serviceName.value : AppLocalizations.of(context)!.noServiceSelected,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.providerInformation,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.providerName.value.isNotEmpty ? controller.providerName.value : AppLocalizations.of(context)!.noProviderSelected,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsForm(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.orderDetails,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 服务地址
            TextField(
              controller: controller.addressController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.serviceAddress,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // 服务日期
            InkWell(
              onTap: () => controller.selectDate(),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.serviceDate,
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  controller.selectedDate?.value ?? AppLocalizations.of(context)!.selectDate,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 服务时间
            InkWell(
              onTap: () => controller.selectTime(),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.serviceTime,
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  controller.selectedTime?.value ?? AppLocalizations.of(context)!.selectTime,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 服务描述
            TextField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.serviceDescription,
                border: const OutlineInputBorder(),
                hintText: AppLocalizations.of(context)!.serviceDescriptionHint,
              ),
              maxLines: 3,
              onChanged: (value) => controller.serviceDescription.value = value,
            ),
            const SizedBox(height: 16),
            
            // 定价类型
            Text(
              AppLocalizations.of(context)!.pricingType,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Row(
              children: [
                Radio<String>(
                  value: 'fixed',
                  groupValue: controller.pricingType.value,
                  onChanged: (value) => controller.pricingType.value = value!,
                ),
                Text(AppLocalizations.of(context)!.fixedPrice),
                const SizedBox(width: 16),
                Radio<String>(
                  value: 'negotiable',
                  groupValue: controller.pricingType.value,
                  onChanged: (value) => controller.pricingType.value = value!,
                ),
                Text(AppLocalizations.of(context)!.negotiablePrice),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.priceInformation,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.basePrice),
                Text('\$' + (controller.price?.value ?? 0.0).toStringAsFixed(2)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.serviceFee),
                Text('\$' + (controller.platformFee.value ?? 0.0).toStringAsFixed(2)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.total,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  controller.pricingType.value == 'negotiable'
                      ? AppLocalizations.of(context)!.tbd
                      : '\$${controller.totalPrice.value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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

  Widget _buildCreateOrderButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.canCreateOrder.value ? () => controller.createOrder() : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        child: Text(
          controller.pricingType.value == 'negotiable'
              ? AppLocalizations.of(context)!.requestQuote
              : AppLocalizations.of(context)!.createOrder,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
} 