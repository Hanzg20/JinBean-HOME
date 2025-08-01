import 'package:flutter/material.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/provider_theme.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/customer_theme.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/jinbean_theme.dart';

class ProviderThemeDemoPage extends StatefulWidget {
  const ProviderThemeDemoPage({super.key});

  @override
  State<ProviderThemeDemoPage> createState() => _ProviderThemeDemoPageState();
}

class _ProviderThemeDemoPageState extends State<ProviderThemeDemoPage> {
  ThemeData _currentTheme = JinBeanProviderTheme.lightTheme;
  bool _isDarkMode = false;

  void _switchTheme() {
    setState(() {
      if (_currentTheme == JinBeanProviderTheme.lightTheme) {
        _currentTheme = JinBeanProviderTheme.darkTheme;
        _isDarkMode = true;
      } else {
        _currentTheme = JinBeanProviderTheme.lightTheme;
        _isDarkMode = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _currentTheme,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ProviderTheme Demo'),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _switchTheme,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 主题信息卡片
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ProviderTheme 演示',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '专业色调 • 紧凑布局 • 高效设计',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildThemeInfo('主色调', _currentTheme.colorScheme.primary),
                          const SizedBox(width: 16),
                          _buildThemeInfo('第三色', _currentTheme.colorScheme.tertiary),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 按钮演示
              Text(
                '按钮样式',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('主要按钮'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('次要按钮'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 输入框演示
              Text(
                '输入框样式',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: '专业输入框',
                  hintText: '请输入内容',
                  prefixIcon: const Icon(Icons.edit),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 卡片演示
              Text(
                '卡片样式',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _currentTheme.colorScheme.primary,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: const Text('专业卡片'),
                  subtitle: const Text('紧凑布局，高效信息展示'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 开关和复选框演示
              Text(
                '交互组件',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('开关'),
                  const SizedBox(width: 12),
                  Switch(
                    value: true,
                    onChanged: (value) {},
                  ),
                  const SizedBox(width: 24),
                  const Text('复选框'),
                  const SizedBox(width: 12),
                  Checkbox(
                    value: true,
                    onChanged: (value) {},
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 进度指示器演示
              Text(
                '进度指示器',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: 0.7,
                backgroundColor: _currentTheme.colorScheme.surfaceVariant,
              ),
              const SizedBox(height: 16),
              CircularProgressIndicator(
                value: 0.7,
                backgroundColor: _currentTheme.colorScheme.surfaceVariant,
              ),
              
              const SizedBox(height: 24),
              
              // 底部导航栏演示
              Text(
                '底部导航栏',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: _currentTheme.bottomNavigationBarTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(Icons.home, '首页', true),
                    _buildNavItem(Icons.list_alt, '订单', false),
                    _buildNavItem(Icons.people, '客户', false),
                    _buildNavItem(Icons.settings, '设置', false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeInfo(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    final color = isSelected 
        ? _currentTheme.bottomNavigationBarTheme.selectedItemColor
        : _currentTheme.bottomNavigationBarTheme.unselectedItemColor;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
} 