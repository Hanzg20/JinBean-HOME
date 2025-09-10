import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../themes/customer_theme_components.dart';

/// 通用快速预订组件
/// 
/// 提供一键预订功能，适用于所有行业页面
class QuickBookingWidget extends StatelessWidget {
  final String industryType;
  final List<QuickBookingOption> options;
  final Function(String optionId) onBookingTap;
  final bool showPriceEstimate;

  const QuickBookingWidget({
    super.key,
    required this.industryType,
    required this.options,
    required this.onBookingTap,
    this.showPriceEstimate = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomerThemeComponents.buildCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          CustomerThemeComponents.buildSectionHeader(
            context: context,
            title: '快速预订',
            subtitle: '选择常用服务，一键下单',
            icon: Icons.flash_on,
          ),
          
          const SizedBox(height: 16),
          
          // 快速选项网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return _buildQuickOption(context, option);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickOption(BuildContext context, QuickBookingOption option) {
    return CustomerThemeComponents.buildCard(
      context: context,
      onTap: () => onBookingTap(option.id),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          CustomerThemeComponents.buildIconContainer(
            context: context,
            icon: option.icon,
            size: 32,
            useGradient: true,
          ),
          
          const SizedBox(height: 8),
          
          // 标题
          Text(
            option.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 4),
          
          // 价格估算
          if (showPriceEstimate && option.estimatedPrice != null)
            Text(
              '约 ${option.estimatedPrice}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          
          // 时长估算
          if (option.estimatedDuration != null)
            Text(
              option.estimatedDuration!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }
}

/// 快速预订选项数据模型
class QuickBookingOption {
  final String id;
  final String title;
  final IconData icon;
  final String? estimatedPrice;
  final String? estimatedDuration;
  final Map<String, dynamic>? metadata;

  const QuickBookingOption({
    required this.id,
    required this.title,
    required this.icon,
    this.estimatedPrice,
    this.estimatedDuration,
    this.metadata,
  });
}

/// 行业特定的快速预订选项
class IndustryQuickOptions {
  // 家居服务快速选项
  static List<QuickBookingOption> homeServices = [
    QuickBookingOption(
      id: 'cleaning_basic',
      title: '基础清洁',
      icon: Icons.cleaning_services,
      estimatedPrice: '¥80-120',
      estimatedDuration: '2-3小时',
    ),
    QuickBookingOption(
      id: 'repair_plumbing',
      title: '水管维修',
      icon: Icons.plumbing,
      estimatedPrice: '¥150-300',
      estimatedDuration: '1-2小时',
    ),
    QuickBookingOption(
      id: 'install_furniture',
      title: '家具安装',
      icon: Icons.build,
      estimatedPrice: '¥100-200',
      estimatedDuration: '1-3小时',
    ),
    QuickBookingOption(
      id: 'deep_cleaning',
      title: '深度清洁',
      icon: Icons.auto_awesome,
      estimatedPrice: '¥200-400',
      estimatedDuration: '4-6小时',
    ),
  ];

  // 出行交通快速选项
  static List<QuickBookingOption> transportServices = [
    QuickBookingOption(
      id: 'taxi_now',
      title: '立即叫车',
      icon: Icons.local_taxi,
      estimatedPrice: '起步¥12',
      estimatedDuration: '3-8分钟',
    ),
    QuickBookingOption(
      id: 'airport_transfer',
      title: '机场接送',
      icon: Icons.flight,
      estimatedPrice: '¥80-150',
      estimatedDuration: '预约服务',
    ),
    QuickBookingOption(
      id: 'carpool',
      title: '拼车出行',
      icon: Icons.group,
      estimatedPrice: '节省30%',
      estimatedDuration: '5-15分钟',
    ),
    QuickBookingOption(
      id: 'premium_car',
      title: '商务专车',
      icon: Icons.directions_car,
      estimatedPrice: '¥2.5/公里',
      estimatedDuration: '2-5分钟',
    ),
  ];

  // 学习成长快速选项
  static List<QuickBookingOption> learningServices = [
    QuickBookingOption(
      id: 'language_tutor',
      title: '语言辅导',
      icon: Icons.translate,
      estimatedPrice: '¥100-300/小时',
      estimatedDuration: '1-2小时',
    ),
    QuickBookingOption(
      id: 'skill_workshop',
      title: '技能工坊',
      icon: Icons.school,
      estimatedPrice: '¥200-500',
      estimatedDuration: '2-4小时',
    ),
    QuickBookingOption(
      id: 'online_course',
      title: '在线课程',
      icon: Icons.computer,
      estimatedPrice: '¥50-200',
      estimatedDuration: '自主学习',
    ),
    QuickBookingOption(
      id: 'certification',
      title: '认证考试',
      icon: Icons.verified,
      estimatedPrice: '¥300-800',
      estimatedDuration: '1-3小时',
    ),
  ];
}

