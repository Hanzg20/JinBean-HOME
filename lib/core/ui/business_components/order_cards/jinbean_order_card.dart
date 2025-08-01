import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../design_system/typography.dart';
import '../cards/jinbean_card.dart';

/// JinBean 订单卡片组件
class JinBeanOrderCard extends StatelessWidget {
  final String orderId;
  final String serviceTitle;
  final String? serviceDescription;
  final String price;
  final String status;
  final String? customerName;
  final String? customerAvatar;
  final String? serviceDate;
  final String? serviceTime;
  final String? serviceAddress;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool showActions;

  const JinBeanOrderCard({
    super.key,
    required this.orderId,
    required this.serviceTitle,
    this.serviceDescription,
    required this.price,
    required this.status,
    this.customerName,
    this.customerAvatar,
    this.serviceDate,
    this.serviceTime,
    this.serviceAddress,
    this.onTap,
    this.onAccept,
    this.onReject,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return JinBeanCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 订单头部
          _buildOrderHeader(),
          const SizedBox(height: 12),
          
          // 服务信息
          _buildServiceInfo(),
          const SizedBox(height: 12),
          
          // 客户信息
          if (customerName != null) ...[
            _buildCustomerInfo(),
            const SizedBox(height: 12),
          ],
          
          // 服务详情
          if (serviceDate != null || serviceAddress != null) ...[
            _buildServiceDetails(),
            const SizedBox(height: 12),
          ],
          
          // 操作按钮
          if (showActions) ...[
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _getStatusColor().withOpacity(0.3)),
          ),
          child: Text(
            _getStatusText(),
            style: JinBeanTypography.labelSmall.copyWith(
              color: _getStatusColor(),
              fontWeight: JinBeanTypography.semiBold,
            ),
          ),
        ),
        const Spacer(),
        Text(
          price,
          style: JinBeanTypography.h5.copyWith(
            color: JinBeanColors.primary,
            fontWeight: JinBeanTypography.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          serviceTitle,
          style: JinBeanTypography.h6.copyWith(
            color: JinBeanColors.textPrimary,
            fontWeight: JinBeanTypography.semiBold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (serviceDescription != null) ...[
          const SizedBox(height: 4),
          Text(
            serviceDescription!,
            style: JinBeanTypography.bodySmall.copyWith(
              color: JinBeanColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildCustomerInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: JinBeanColors.surfaceVariant,
          backgroundImage: customerAvatar != null 
              ? NetworkImage(customerAvatar!) 
              : null,
          child: customerAvatar == null
              ? Text(
                  customerName!.substring(0, 1).toUpperCase(),
                  style: JinBeanTypography.labelMedium.copyWith(
                    color: JinBeanColors.textPrimary,
                    fontWeight: JinBeanTypography.semiBold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            customerName!,
            style: JinBeanTypography.bodyMedium.copyWith(
              color: JinBeanColors.textPrimary,
              fontWeight: JinBeanTypography.medium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceDetails() {
    return Column(
      children: [
        if (serviceDate != null) ...[
          _buildDetailRow(Icons.calendar_today, serviceDate!),
          const SizedBox(height: 4),
        ],
        if (serviceTime != null) ...[
          _buildDetailRow(Icons.access_time, serviceTime!),
          const SizedBox(height: 4),
        ],
        if (serviceAddress != null) ...[
          _buildDetailRow(Icons.location_on, serviceAddress!),
        ],
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: JinBeanColors.textTertiary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: JinBeanTypography.bodySmall.copyWith(
              color: JinBeanColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: JinBeanColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              '接单',
              style: JinBeanTypography.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: JinBeanTypography.semiBold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: onReject,
            style: OutlinedButton.styleFrom(
              foregroundColor: JinBeanColors.error,
              side: const BorderSide(color: JinBeanColors.error),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              '拒绝',
              style: JinBeanTypography.labelMedium.copyWith(
                color: JinBeanColors.error,
                fontWeight: JinBeanTypography.semiBold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pending':
      case '待处理':
        return JinBeanColors.warning;
      case 'accepted':
      case '已接单':
        return JinBeanColors.success;
      case 'completed':
      case '已完成':
        return JinBeanColors.info;
      case 'cancelled':
      case '已取消':
        return JinBeanColors.error;
      default:
        return JinBeanColors.textTertiary;
    }
  }

  String _getStatusText() {
    switch (status.toLowerCase()) {
      case 'pending':
        return '待处理';
      case 'accepted':
        return '已接单';
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      default:
        return status;
    }
  }
}

/// JinBean 订单列表项组件
class JinBeanOrderListItem extends StatelessWidget {
  final String orderId;
  final String serviceTitle;
  final String price;
  final String status;
  final String? customerName;
  final String? serviceDate;
  final VoidCallback? onTap;

  const JinBeanOrderListItem({
    super.key,
    required this.orderId,
    required this.serviceTitle,
    required this.price,
    required this.status,
    this.customerName,
    this.serviceDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: JinBeanSpacing.horizontalCardPadding,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _getStatusColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.shopping_cart,
          color: _getStatusColor(),
          size: 24,
        ),
      ),
      title: Text(
        serviceTitle,
        style: JinBeanTypography.bodyMedium.copyWith(
          color: JinBeanColors.textPrimary,
          fontWeight: JinBeanTypography.medium,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (customerName != null) ...[
            Text(
              customerName!,
              style: JinBeanTypography.bodySmall.copyWith(
                color: JinBeanColors.textSecondary,
              ),
            ),
          ],
          if (serviceDate != null) ...[
            Text(
              serviceDate!,
              style: JinBeanTypography.bodySmall.copyWith(
                color: JinBeanColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            price,
            style: JinBeanTypography.labelLarge.copyWith(
              color: JinBeanColors.primary,
              fontWeight: JinBeanTypography.semiBold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getStatusText(),
              style: JinBeanTypography.labelSmall.copyWith(
                color: _getStatusColor(),
                fontWeight: JinBeanTypography.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pending':
      case '待处理':
        return JinBeanColors.warning;
      case 'accepted':
      case '已接单':
        return JinBeanColors.success;
      case 'completed':
      case '已完成':
        return JinBeanColors.info;
      case 'cancelled':
      case '已取消':
        return JinBeanColors.error;
      default:
        return JinBeanColors.textTertiary;
    }
  }

  String _getStatusText() {
    switch (status.toLowerCase()) {
      case 'pending':
        return '待处理';
      case 'accepted':
        return '已接单';
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      default:
        return status;
    }
  }
} 