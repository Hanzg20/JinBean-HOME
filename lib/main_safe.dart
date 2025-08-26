import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  // 错误捕获
  FlutterError.onError = (FlutterErrorDetails details) {
    print('Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };

  runApp(SafeApp());
}

class SafeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'JinBean Safe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SafeHomePage(),
      debugShowCheckedModeBanner: true,
      // 错误页面
      builder: (context, child) {
        return ErrorBoundary(child: child!);
      },
    );
  }
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  
  const ErrorBoundary({Key? key, required this.child}) : super(key: key);
  
  @override
  _ErrorBoundaryState createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Error? _error;
  
  @override
  void initState() {
    super.initState();
    // 延迟初始化，确保所有依赖都已加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }
  
  void _initializeApp() {
    try {
      // 这里可以添加应用初始化逻辑
      print('App initialization started...');
    } catch (e, stack) {
      print('Initialization error: $e');
      print('Stack trace: $stack');
      setState(() {
        _error = Error.throwWithStackTrace(e, stack);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorPage();
    }
    
    return widget.child;
  }
  
  Widget _buildErrorPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Error Occurred'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red),
              SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'An error occurred during app initialization.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _retryInitialization(),
                child: Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => _showErrorDetails(),
                child: Text('Show Error Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _retryInitialization() {
    setState(() {
      _error = null;
    });
    _initializeApp();
  }
  
  void _showErrorDetails() {
    Get.dialog(
      AlertDialog(
        title: Text('Error Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: ${_error?.toString() ?? 'Unknown error'}'),
              SizedBox(height: 16),
              Text('Time: ${DateTime.now()}'),
              SizedBox(height: 16),
              Text('Please check the console for more details.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

class SafeHomePage extends StatefulWidget {
  @override
  _SafeHomePageState createState() => _SafeHomePageState();
}

class _SafeHomePageState extends State<SafeHomePage> {
  bool _isInitialized = false;
  String _status = 'Initializing...';
  List<String> _logs = [];
  
  @override
  void initState() {
    super.initState();
    _addLog('SafeHomePage initialized');
    _initializeSafely();
  }
  
  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
      if (_logs.length > 10) {
        _logs.removeAt(0);
      }
    });
  }
  
  void _initializeSafely() async {
    try {
      _addLog('Starting safe initialization...');
      
      // 模拟初始化步骤
      await Future.delayed(Duration(seconds: 1));
      _addLog('Step 1: Basic setup completed');
      
      await Future.delayed(Duration(seconds: 1));
      _addLog('Step 2: Dependencies loaded');
      
      await Future.delayed(Duration(seconds: 1));
      _addLog('Step 3: Services initialized');
      
      await Future.delayed(Duration(seconds: 1));
      _addLog('Step 4: UI ready');
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _status = 'Ready!';
        });
        _addLog('Initialization completed successfully');
      }
      
    } catch (e, stack) {
      _addLog('Error during initialization: $e');
      print('Initialization error: $e');
      print('Stack trace: $stack');
      
      if (mounted) {
        setState(() {
          _status = 'Error: $e';
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Safe Launch'),
        backgroundColor: _isInitialized ? Colors.green : Colors.orange,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _isInitialized ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              // 状态显示
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isInitialized ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isInitialized ? Colors.green : Colors.orange,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _isInitialized ? Icons.check_circle : Icons.hourglass_empty,
                      size: 64,
                      color: _isInitialized ? Colors.green : Colors.orange,
                    ),
                    SizedBox(height: 16),
                    Text(
                      _isInitialized ? 'Application Ready!' : 'Initializing...',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _isInitialized ? Colors.green : Colors.orange,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32),
              
              // 日志显示
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Initialization Logs:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                _logs[index],
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // 操作按钮
              if (_isInitialized) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _launchMainApp(),
                        child: Text('Launch Main App'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _resetApp(),
                        child: Text('Reset'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () => _initializeSafely(),
                  child: Text('Retry Initialization'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  void _launchMainApp() {
    _addLog('Launching main app...');
    Get.snackbar(
      'Launching Main App', 
      'This would launch the actual main application',
      duration: Duration(seconds: 3),
    );
  }
  
  void _resetApp() {
    _addLog('Resetting app...');
    setState(() {
      _isInitialized = false;
      _status = 'Initializing...';
      _logs.clear();
    });
    _initializeSafely();
  }
}
