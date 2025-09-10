#!/usr/bin/env dart

/// 智能自动修复编译系统
/// 既能检测错误又能自动修复

import 'dart:io';
import 'dart:async';

void main() async {
  print('🤖 启动智能自动修复编译系统...');
  
  while (true) {
    try {
      print('\n🔨 开始编译检查...');
      
      // 尝试编译
      final result = await Process.run(
        'flutter',
        ['run', '-d', 'iPhone 16 Pro'],
        workingDirectory: Directory.current.path,
      );
      
      if (result.exitCode == 0) {
        print('🎉 应用成功启动！');
        break;
      } else {
        final output = result.stdout.toString() + result.stderr.toString();
        
        // 提取关键错误信息
        final errorInfo = _extractErrorInfo(output);
        if (errorInfo != null) {
          print('❌ 发现错误: ${errorInfo.file}:${errorInfo.line} - ${errorInfo.description}');
          
          final fixed = await _attemptAutoFix(errorInfo);
          if (fixed) {
            print('✅ 自动修复成功，重新编译...');
            continue;
          } else {
            print('❌ 无法自动修复，需要人工干预');
          }
        } else {
          print('❌ 编译失败，但无法识别错误模式');
        }
        
        print('⏳ 等待10秒后重试...');
        await Future.delayed(Duration(seconds: 10));
      }
      
    } catch (e) {
      print('❌ 编译过程出错: $e');
      await Future.delayed(Duration(seconds: 10));
    }
  }
}

class ErrorInfo {
  final String file;
  final int line;
  final String description;
  final String errorType;
  
  ErrorInfo({
    required this.file,
    required this.line, 
    required this.description,
    required this.errorType,
  });
}

ErrorInfo? _extractErrorInfo(String output) {
  // 匹配错误模式: lib/file.dart:line:col: Error: description
  final errorPattern = RegExp(r'lib/([^:]+):(\d+):\d+:\s*Error:\s*(.+)');
  final match = errorPattern.firstMatch(output);
  
  if (match != null) {
    final file = 'lib/${match.group(1)}';
    final line = int.parse(match.group(2)!);
    final description = match.group(3)!.trim();
    
    String errorType = 'unknown';
    if (description.contains("can't be assigned")) {
      errorType = 'type_mismatch';
    } else if (description.contains("isn't defined")) {
      errorType = 'missing_member';
    } else if (description.contains("nullable")) {
      errorType = 'null_safety';
    } else if (description.contains("Too many positional arguments")) {
      errorType = 'parameter_error';
    }
    
    return ErrorInfo(
      file: file,
      line: line,
      description: description,
      errorType: errorType,
    );
  }
  
  return null;
}

Future<bool> _attemptAutoFix(ErrorInfo error) async {
  try {
    switch (error.errorType) {
      case 'type_mismatch':
        return await _fixTypeMismatch(error);
      case 'missing_member':
        return await _fixMissingMember(error);
      case 'null_safety':
        return await _fixNullSafety(error);
      case 'parameter_error':
        return await _fixParameterError(error);
      default:
        return false;
    }
  } catch (e) {
    print('❌ 修复过程出错: $e');
    return false;
  }
}

Future<bool> _fixTypeMismatch(ErrorInfo error) async {
  final file = File(error.file);
  if (!await file.exists()) return false;
  
  final lines = await file.readAsLines();
  if (error.line > lines.length) return false;
  
  final lineIndex = error.line - 1;
  final originalLine = lines[lineIndex];
  String fixedLine = originalLine;
  
  // 常见类型修复
  if (error.description.contains("'Object' can't be assigned to") && 
      error.description.contains("'Map<String, dynamic>'")) {
    // Configuration 到 Map 的类型错误
    fixedLine = fixedLine.replaceAll('Configuration?', 'Map<String, dynamic>?');
    fixedLine = fixedLine.replaceAll('Configuration', 'Map<String, dynamic>');
  }
  
  if (error.description.contains("'String?' can't be assigned to") &&
      error.description.contains("'String'")) {
    // 空安全问题 - 添加 ?? 操作符
    fixedLine = fixedLine.replaceAll(RegExp(r'(\w+)(?=\s*[,)])'), r'$1 ?? ""');
  }
  
  if (originalLine != fixedLine) {
    lines[lineIndex] = fixedLine;
    await file.writeAsString(lines.join('\n'));
    print('🔧 修复类型错误: $fixedLine');
    return true;
  }
  
  return false;
}

Future<bool> _fixMissingMember(ErrorInfo error) async {
  final file = File(error.file);
  if (!await file.exists()) return false;
  
  final lines = await file.readAsLines();
  if (error.line > lines.length) return false;
  
  final lineIndex = error.line - 1;
  final originalLine = lines[lineIndex];
  String fixedLine = originalLine;
  
  // 常见成员名称修复
  if (error.description.contains("'canceled'")) {
    fixedLine = fixedLine.replaceAll('.canceled', '.cancelled');
    fixedLine = fixedLine.replaceAll('OrderStatus.canceled', 'OrderStatus.cancelled');
  }
  
  // Icons修复
  if (error.description.contains("'google'") && fixedLine.contains('Icons.google')) {
    fixedLine = fixedLine.replaceAll('Icons.google', 'Icons.account_balance_wallet');
  }
  
  // 属性名修复
  if (error.description.contains("'userId'") && fixedLine.contains('.userId')) {
    fixedLine = fixedLine.replaceAll('.userId', '.customerId');
  }
  
  if (originalLine != fixedLine) {
    lines[lineIndex] = fixedLine;
    await file.writeAsString(lines.join('\n'));
    print('🔧 修复成员名称错误: $fixedLine');
    return true;
  }
  
  return false;
}

Future<bool> _fixNullSafety(ErrorInfo error) async {
  final file = File(error.file);
  if (!await file.exists()) return false;
  
  final lines = await file.readAsLines();
  if (error.line > lines.length) return false;
  
  final lineIndex = error.line - 1;
  final originalLine = lines[lineIndex];
  String fixedLine = originalLine;
  
  // 添加空安全操作符
  if (error.description.contains("nullable") && error.description.contains("can't be assigned")) {
    fixedLine = fixedLine.replaceAll(RegExp(r'(\w+)(?=\s*[,)])'), r'$1 ?? defaultValue');
  }
  
  if (originalLine != fixedLine) {
    lines[lineIndex] = fixedLine;
    await file.writeAsString(lines.join('\n'));
    print('🔧 修复空安全问题: $fixedLine');
    return true;
  }
  
  return false;
}

Future<bool> _fixParameterError(ErrorInfo error) async {
  print('🔧 检测到参数错误: ${error.description}');
  return false; // 暂时需要手动修复
}
