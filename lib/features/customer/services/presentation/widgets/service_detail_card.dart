import 'package:flutter/material.dart';

/// 服务详情页面通用卡片组件
class ServiceDetailCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool showShadow;

  const ServiceDetailCard({
    Key? key,
    required this.child,
    this.padding,
    this.onTap,
    this.showShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      elevation: showShadow ? 2.0 : 0.0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

/// 服务详情页面标题卡片
class ServiceDetailTitleCard extends StatelessWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? subtitle;

  const ServiceDetailTitleCard({
    Key? key,
    required this.title,
    this.leading,
    this.actions,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ServiceDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            subtitle!,
          ],
        ],
      ),
    );
  }
}
