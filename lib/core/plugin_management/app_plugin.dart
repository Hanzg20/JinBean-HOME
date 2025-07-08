import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 假设你已经集成了GetX

// 插件类型枚举
enum PluginType {
  bottomTab, // 底部导航栏插件
  standalonePage, // 独立页面插件
  widgetModule, // 可嵌入的Widget模块
}

// 插件元数据定义
class PluginMetadata {
  final String id; // 插件唯一标识
  final String nameKey; // 插件名称的国际化Key
  final IconData icon; // 插件图标 (如果适用，如底部导航栏)
  final bool enabled; // 是否启用
  final int order; // 显示顺序
  final PluginType type; // 插件类型
  final String? routeName; // 如果是页面插件，对应的路由名
  final String role; // 新增字段

  PluginMetadata({
    required this.id,
    required this.nameKey,
    required this.icon,
    required this.enabled,
    required this.order,
    required this.type,
    this.routeName,
    required this.role,
  });

  // 从后端JSON数据反序列化
  factory PluginMetadata.fromJson(Map<String, dynamic> json) {
    return PluginMetadata(
      id: json['id'],
      nameKey: json['nameKey'],
      icon: _parseIconData(json['iconName']),
      enabled: json['enabled'],
      order: json['order'],
      type: json['type'] as PluginType, // 直接用枚举对象
      routeName: json['routeName'],
      role: json['role'] ?? 'customer',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameKey': nameKey,
    'iconName': icon.codePoint, // 这里只是示例，实际项目需映射
    'enabled': enabled,
    'order': order,
    'type': type.toString().split('.').last,
    'routeName': routeName,
    'role': role,
  };

  PluginMetadata copyWith({
    String? id,
    String? nameKey,
    IconData? icon,
    bool? enabled,
    int? order,
    PluginType? type,
    String? routeName,
    String? role,
  }) {
    return PluginMetadata(
      id: id ?? this.id,
      nameKey: nameKey ?? this.nameKey,
      icon: icon ?? this.icon,
      enabled: enabled ?? this.enabled,
      order: order ?? this.order,
      type: type ?? this.type,
      routeName: routeName ?? this.routeName,
      role: role ?? this.role,
    );
  }

  // 辅助函数：根据字符串名称获取IconData
  static IconData _parseIconData(String? iconName) {
    // 实际项目中需要一个IconData映射表或更复杂的解析逻辑
    switch (iconName) {
      case 'home': return Icons.home;
      case 'event': return Icons.event;
      case 'build': return Icons.build;
      case 'person': return Icons.person;
      case 'calendar_today': return Icons.calendar_today;
      case 'groups': return Icons.groups;
      // ... 更多图标
      default: return Icons.extension; // 默认图标
    }
  }
}

// 抽象插件基类
abstract class AppPlugin {
  PluginMetadata get metadata; // 插件元数据

  // 获取插件主入口Widget (例如用于底部导航栏)
  Widget buildEntryWidget();

  // 注册插件相关路由 (GetX路由)
  List<GetPage> getRoutes();

  // 插件初始化逻辑 (可选)
  void init() {}

  // 插件销毁逻辑 (可选)
  void dispose() {}

  // 获取插件的控制器 (可选，用于GetX依赖注入和状态管理)
  Bindings? get bindings => null;
} 