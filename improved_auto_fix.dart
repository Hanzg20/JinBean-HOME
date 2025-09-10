#!/usr/bin/env dart

/// 改进的自动化错误监控和修复系统
/// 解决之前系统的问题，实现真正的自动化

import 'dart:io';
import 'dart:async';
import 'dart:convert';

class ImprovedAutoFix {
  Timer? _monitorTimer;
  bool _isRunning = false;
  final Set<String> _processedErrors = {};
  
  /// 启动改进的自动化监控
  Future<void> startMonitoring() async {
    print('🚀 启动改进的自动化错误监控系统...');
    _isRunning = true;
    
    // 立即检查一次
    await _checkAndFix();
    
    // 每5秒检查一次（更频繁）
    _monitorTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      if (_isRunning) {
        await _checkAndFix();
      }
    });
    
    print('✅ 改进的监控系统已启动，每5秒检查一次');
  }
  
  /// 检查错误并自动修复
  Future<void> _checkAndFix() async {
    try {
      print('🔍 检查编译状态...');
      
      // 运行 flutter analyze 来检查代码问题
      final analyzeResult = await Process.run(
        'flutter', 
        ['analyze', '--no-fatal-infos'],
        workingDirectory: Directory.current.path,
      );
      
      if (analyzeResult.exitCode != 0) {
        final errors = analyzeResult.stdout.toString() + analyzeResult.stderr.toString();
        print('📋 发现编译错误：');
        print(errors.substring(0, errors.length.clamp(0, 500)));
        
        await _tryFixErrors(errors);
      } else {
        print('✅ 代码分析通过，尝试编译...');
        await _tryCompile();
      }
      
    } catch (e) {
      print('❌ 监控过程出错: $e');
    }
  }
  
  /// 尝试编译应用
  Future<void> _tryCompile() async {
    final compileResult = await Process.run(
      'flutter',
      ['build', 'ios', '--debug', '--no-codesign'],
      workingDirectory: Directory.current.path,
    );
    
    if (compileResult.exitCode != 0) {
      final errors = compileResult.stdout.toString() + compileResult.stderr.toString();
      print('🔨 编译错误：');
      print(errors.substring(0, errors.length.clamp(0, 500)));
      
      await _tryFixErrors(errors);
    } else {
      print('🎉 编译成功！启动应用...');
      await _launchApp();
    }
  }
  
  /// 启动应用
  Future<void> _launchApp() async {
    print('📱 启动应用到模拟器...');
    
    // 在后台启动应用
    Process.start(
      'flutter',
      ['run', '-d', 'iPhone 16 Pro'],
      workingDirectory: Directory.current.path,
    ).then((process) {
      process.stdout.transform(utf8.decoder).listen((data) {
        if (data.contains('Hot reload enabled')) {
          print('🎉 应用成功启动！');
        } else if (data.contains('Error')) {
          print('❌ 运行时错误: $data');
        }
      });
    });
  }
  
  /// 尝试修复错误
  Future<void> _tryFixErrors(String errors) async {
    final errorLines = errors.split('\n');
    
    for (final line in errorLines) {
      if (line.contains('Error:') && !_processedErrors.contains(line)) {
        _processedErrors.add(line);
        
        print('🔧 尝试修复错误: ${line.substring(0, line.length.clamp(0, 200))}');
        
        final fixed = await _attemptFix(line);
        if (fixed) {
          print('✅ 修复成功，重新检查...');
          // 递归检查是否还有其他错误
          await Future.delayed(Duration(seconds: 2));
          await _checkAndFix();
          return;
        }
      }
    }
    
    print('❌ 无法自动修复当前错误，需要人工干预');
  }
  
  /// 尝试修复单个错误
  Future<bool> _attemptFix(String error) async {
    try {
      // 空安全错误
      if (error.contains("nullable") && error.contains("can't be assigned")) {
        return await _fixNullSafetyError(error);
      }
      
      // 方法不存在错误
      if (error.contains("isn't defined for the class")) {
        return await _fixMissingMethodError(error);
      }
      
      // 类型错误
      if (error.contains("argument type") && error.contains("can't be assigned")) {
        return await _fixTypeError(error);
      }
      
      return false;
    } catch (e) {
      print('❌ 修复过程出错: $e');
      return false;
    }
  }
  
  /// 修复空安全错误
  Future<bool> _fixNullSafetyError(String error) async {
    final location = _parseLocation(error);
    if (location == null) return false;
    
    final file = File(location.file);
    if (!await file.exists()) return false;
    
    final lines = await file.readAsLines();
    if (location.line >= lines.length) return false;
    
    final originalLine = lines[location.line];
    String fixedLine = originalLine;
    
    // 常见的空安全修复模式
    fixedLine = fixedLine.replaceAll(RegExp(r'(\w+\.get<\w+>\([^)]+\))(?!\s*\?\?)'), r'$1 ?? defaultValue');
    fixedLine = fixedLine.replaceAll(RegExp(r'(\w+)(?=\s*\))'), r'$1 ?? ""');
    
    if (originalLine != fixedLine) {
      lines[location.line] = fixedLine;
      await file.writeAsString(lines.join('\n'));
      print('✅ 修复空安全错误: ${location.file}:${location.line + 1}');
      return true;
    }
    
    return false;
  }
  
  /// 修复方法不存在错误
  Future<bool> _fixMissingMethodError(String error) async {
    if (error.contains("'get' isn't defined for the class 'Map")) {
      // 这个我们已经手动修复了
      return false;
    }
    
    // 可以添加更多方法缺失的修复逻辑
    return false;
  }
  
  /// 修复类型错误
  Future<bool> _fixTypeError(String error) async {
    // 可以添加类型转换的修复逻辑
    return false;
  }
  
  /// 解析错误位置
  ({String file, int line})? _parseLocation(String error) {
    final regex = RegExp(r'lib/([^:]+):(\d+):');
    final match = regex.firstMatch(error);
    
    if (match != null) {
      return (
        file: 'lib/${match.group(1)}',
        line: int.parse(match.group(2)!) - 1,
      );
    }
    
    return null;
  }
  
  /// 停止监控
  void stop() {
    _isRunning = false;
    _monitorTimer?.cancel();
    print('🛑 自动化监控已停止');
  }
}

void main() async {
  final autoFix = ImprovedAutoFix();
  
  // 处理退出信号
  ProcessSignal.sigint.watch().listen((sig) {
    print('\n🛑 收到退出信号...');
    autoFix.stop();
    exit(0);
  });
  
  await autoFix.startMonitoring();
  
  // 保持运行
  while (true) {
    await Future.delayed(Duration(seconds: 1));
  }
}
