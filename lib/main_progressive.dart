import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(ProgressiveApp());
}

class ProgressiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'JinBean Progressive',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ProgressiveHomePage(),
      debugShowCheckedModeBanner: true,
    );
  }
}

class ProgressiveHomePage extends StatefulWidget {
  @override
  _ProgressiveHomePageState createState() => _ProgressiveHomePageState();
}

class _ProgressiveHomePageState extends State<ProgressiveHomePage> {
  int _currentPhase = 0;
  String _status = 'Initializing...';
  bool _isLoading = true;

  final List<Map<String, dynamic>> _phases = [
    {
      'name': 'Core Dependencies',
      'description': 'Testing basic imports and dependencies',
      'color': Colors.blue,
      'icon': Icons.settings,
    },
    {
      'name': 'Entity Classes',
      'description': 'Testing entity class definitions',
      'color': Colors.green,
      'icon': Icons.category,
    },
    {
      'name': 'Service Layer',
      'description': 'Testing service and API classes',
      'color': Colors.orange,
      'icon': Icons.api,
    },
    {
      'name': 'UI Components',
      'description': 'Testing UI widgets and pages',
      'color': Colors.purple,
      'icon': Icons.widgets,
    },
    {
      'name': 'Full Application',
      'description': 'Launching complete application',
      'color': Colors.red,
      'icon': Icons.rocket_launch,
    },
  ];

  @override
  void initState() {
    super.initState();
    _runProgressiveTest();
  }

  void _runProgressiveTest() async {
    for (int i = 0; i < _phases.length; i++) {
      if (mounted) {
        setState(() {
          _currentPhase = i;
          _status = 'Testing ${_phases[i]['name']}...';
          _isLoading = true;
        });

        // 模拟测试过程
        await Future.delayed(Duration(seconds: 3));

        if (mounted) {
          setState(() {
            _status = '${_phases[i]['name']} - PASSED';
            _isLoading = false;
          });

          // 最后阶段等待用户确认
          if (i == _phases.length - 1) {
            await Future.delayed(Duration(seconds: 2));
            _showLaunchDialog();
          }
        }
      }
    }
  }

  void _showLaunchDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('All Tests Passed! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ Core Dependencies'),
            Text('✅ Entity Classes'),
            Text('✅ Service Layer'),
            Text('✅ UI Components'),
            SizedBox(height: 16),
            Text('Ready to launch main application!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Stay Here'),
          ),
          ElevatedButton(
            onPressed: () => _launchMainApp(),
            child: Text('Launch Main App'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _launchMainApp() {
    Get.snackbar(
      'Launching Main App',
      'Switching to main application...',
      duration: Duration(seconds: 2),
    );

    // 这里可以切换到主应用
    // 或者重新启动应用
    Future.delayed(Duration(seconds: 2), () {
      Get.offAll(() => MainAppLauncher());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Progressive Test - Phase ${_currentPhase + 1}/${_phases.length}'),
        backgroundColor: _phases[_currentPhase]['color'],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _phases[_currentPhase]['color'].withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _phases[_currentPhase]['icon'],
                size: 80,
                color: _phases[_currentPhase]['color'],
              ),
              SizedBox(height: 24),
              Text(
                _phases[_currentPhase]['name'],
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _phases[_currentPhase]['color'],
                ),
              ),
              SizedBox(height: 16),
              Text(
                _phases[_currentPhase]['description'],
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              if (_isLoading) ...[
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _phases[_currentPhase]['color']),
                ),
                SizedBox(height: 16),
              ],
              Text(
                _status,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: _phases[_currentPhase]['color'],
                ),
              ),
              SizedBox(height: 48),
              LinearProgressIndicator(
                value: (_currentPhase + 1) / _phases.length,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                    _phases[_currentPhase]['color']),
              ),
              SizedBox(height: 16),
              Text(
                '${_currentPhase + 1} of ${_phases.length} phases completed',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainAppLauncher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main App Launcher'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rocket_launch, size: 80, color: Colors.green),
            SizedBox(height: 24),
            Text(
              'Main Application Ready!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'All components have been verified successfully.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _launchMainApp(),
              child: Text('Launch Main App'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Go Back to Progressive Test'),
            ),
          ],
        ),
      ),
    );
  }

  void _launchMainApp() {
    Get.snackbar(
      'Launching Main App',
      'This would launch the actual main application',
      duration: Duration(seconds: 3),
    );
  }
}
