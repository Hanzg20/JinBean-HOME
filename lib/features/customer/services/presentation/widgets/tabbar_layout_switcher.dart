import 'package:flutter/material.dart';
import 'flexible_tabbar_layout.dart';

/// Tab bar布局切换器
class TabBarLayoutSwitcher extends StatelessWidget {
  /// 当前配置
  final TabBarLayoutConfig currentConfig;

  /// 配置改变回调
  final ValueChanged<TabBarLayoutConfig> onConfigChanged;

  /// 是否显示为浮动按钮
  final bool isFloating;

  const TabBarLayoutSwitcher({
    super.key,
    required this.currentConfig,
    required this.onConfigChanged,
    this.isFloating = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isFloating) {
      return _buildFloatingButton(context);
    } else {
      return _buildInlineButtons(context);
    }
  }

  /// 构建浮动按钮（悬浮在右下角）
  Widget _buildFloatingButton(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 100, // 避免与其他浮动按钮冲突
      child: FloatingActionButton(
        mini: true,
        heroTag: "tabbar_layout_switcher",
        onPressed: () => _showLayoutOptions(context),
        backgroundColor: Colors.white,
        child: Icon(
          _getLayoutIcon(),
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
    );
  }

  /// 构建内联按钮组
  Widget _buildInlineButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeButton(
            context,
            TabBarLayoutMode.expanded,
            Icons.layers,
            '默认',
          ),
          const SizedBox(width: 4),
          _buildModeButton(
            context,
            TabBarLayoutMode.overlay,
            Icons.layers_outlined,
            '覆盖',
          ),
          const SizedBox(width: 4),
          _buildModeButton(
            context,
            TabBarLayoutMode.compact,
            Icons.compress,
            '紧凑',
          ),
        ],
      ),
    );
  }

  /// 构建模式切换按钮
  Widget _buildModeButton(
    BuildContext context,
    TabBarLayoutMode mode,
    IconData icon,
    String label,
  ) {
    final isSelected = currentConfig.mode == mode;
    return GestureDetector(
      onTap: () => _switchToMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示布局选项对话框
  void _showLayoutOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tab栏布局模式',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildOptionTile(
              context,
              TabBarLayoutMode.expanded,
              Icons.layers,
              '默认模式',
              '轮播图在上，Tab栏在下方',
            ),
            _buildOptionTile(
              context,
              TabBarLayoutMode.overlay,
              Icons.layers_outlined,
              '覆盖模式',
              'Tab栏浮动在轮播图上方',
            ),
            _buildOptionTile(
              context,
              TabBarLayoutMode.compact,
              Icons.compress,
              '紧凑模式',
              '减少轮播图高度，节省空间',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// 构建选项列表项
  Widget _buildOptionTile(
    BuildContext context,
    TabBarLayoutMode mode,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = currentConfig.mode == mode;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).primaryColor,
            )
          : null,
      onTap: () {
        Navigator.of(context).pop();
        _switchToMode(mode);
      },
    );
  }

  /// 切换到指定模式
  void _switchToMode(TabBarLayoutMode mode) {
    TabBarLayoutConfig newConfig;
    switch (mode) {
      case TabBarLayoutMode.expanded:
        newConfig = TabBarLayoutConfig.defaultConfig;
        break;
      case TabBarLayoutMode.overlay:
        newConfig = widget.config.copyWith(mode: TabBarLayoutMode.overlay);
        break;
      case TabBarLayoutMode.compact:
        newConfig = widget.config.copyWith(mode: TabBarLayoutMode.compact);
        break;
    }
    onConfigChanged(newConfig);
  }

  /// 获取当前模式的图标
  IconData _getLayoutIcon() {
    switch (currentConfig.mode) {
      case TabBarLayoutMode.expanded:
        return Icons.layers;
      case TabBarLayoutMode.overlay:
        return Icons.layers_outlined;
      case TabBarLayoutMode.compact:
        return Icons.compress;
    }
  }
}
