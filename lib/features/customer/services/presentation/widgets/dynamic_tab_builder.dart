import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/tab_configuration_factory.dart';
import '../../../domain/entities/service.dart';

class DynamicTabBuilder extends StatefulWidget {
  final Service service;
  final TabController tabController;

  const DynamicTabBuilder({
    super.key,
    required this.service,
    required this.tabController,
  });

  @override
  State<DynamicTabBuilder> createState() => _DynamicTabBuilderState();
}

class _DynamicTabBuilderState extends State<DynamicTabBuilder> {
  late List<TabConfiguration> _tabConfigurations;

  @override
  void initState() {
    super.initState();
    _initializeTabs();
  }

  void _initializeTabs() {
    // 使用 categoryLevel1Id 来确定行业特定的Tab
    final categoryId = widget.service.categoryLevel1Id ??
                       widget.service.categoryId ??
                       '0';

    debugPrint('🔍 [DynamicTabBuilder] Service ID: ${widget.service.id}');
    debugPrint('🔍 [DynamicTabBuilder] Service Title: ${widget.service.title}');
    debugPrint('🔍 [DynamicTabBuilder] categoryLevel1Id: ${widget.service.categoryLevel1Id}');
    debugPrint('🔍 [DynamicTabBuilder] categoryId: ${widget.service.categoryId}');
    debugPrint('🔍 [DynamicTabBuilder] Using categoryId for tabs: $categoryId');

    _tabConfigurations = TabConfigurationFactory.generateTabsForService(
      categoryId,
    );

    debugPrint('🔍 [DynamicTabBuilder] Generated ${_tabConfigurations.length} tabs:');
    for (var config in _tabConfigurations) {
      debugPrint('  - ${config.key}: ${config.label} (isIndustrySpecific: ${config.isIndustrySpecific ?? false})');
    }

    // 更新外部TabController的长度，而不是创建新的
    if (widget.tabController.length != _tabConfigurations.length) {
      // 注意：这里我们不能直接修改外部TabController的长度
      // 所以我们需要确保外部TabController有足够的长度
      debugPrint(
          'Warning: TabController length mismatch. Expected: ${_tabConfigurations.length}, Actual: ${widget.tabController.length}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDynamicTabBar(),
        Expanded(
          child: _buildDynamicTabBarView(),
        ),
      ],
    );
  }

  Widget _buildDynamicTabBar() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: TabBar(
        controller: widget.tabController,
        isScrollable: true,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).colorScheme.primary,
        indicatorWeight: 2,
        tabAlignment: TabAlignment.start,
        tabs: _tabConfigurations.map((config) {
          return Tab(
            icon: Icon(config.icon, size: 20),
            text: config.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDynamicTabBarView() {
    return TabBarView(
      controller: widget.tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: _tabConfigurations.map((config) {
        return config.builder(context, widget.service);
      }).toList(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class EnhancedTabContent extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final List<Widget> children;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EnhancedTabContent({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
    required this.children,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          ...children,
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 20),
            _buildActionButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (iconColor ?? Theme.of(context).colorScheme.primary)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor ?? Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onAction,
        icon: const Icon(Icons.add),
        label: Text(actionLabel!),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: iconColor ?? Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
