import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/provider_home_page.dart';
import 'package:jinbeanpod_83904710/features/provider/orders/presentation/orders_shell_page.dart';
import 'package:jinbeanpod_83904710/features/provider/clients/presentation/client_page.dart';
import 'package:jinbeanpod_83904710/features/provider/settings/settings_page.dart';

class ProviderShellApp extends StatefulWidget {
  const ProviderShellApp({super.key});

  @override
  State<ProviderShellApp> createState() => _ProviderShellAppState();
}

class _ProviderShellAppState extends State<ProviderShellApp> {
  int _currentIndex = 0;

  void _onNavigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    print('[ProviderShellApp] initState called');
    _pages = [
      ProviderHomePage(onNavigateToTab: _onNavigateToTab), // Dashboard
      OrdersShellPage(), // Orders (包含了订单管理和抢单大厅)
      ClientPage(), // Clients
      SettingsPage(), // Settings/My - Updated to use the new SettingsPage
    ];
    print('[ProviderShellApp] _pages initialized: '
      '${_pages.map((w) => w.runtimeType).join(', ')}');
  }

  @override
  Widget build(BuildContext context) {
    print('[ProviderShellApp] build called, _currentIndex: $_currentIndex');
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
} 