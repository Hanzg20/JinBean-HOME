#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// 自动编译错误检测和修复脚本
class AutoCompileErrorFixer {
  static Future<void> main(List<String> args) async {
    print('🔄 开始自动编译错误检测和修复...');
    
    int maxRetries = 3;
    int currentRetry = 0;
    
    while (currentRetry < maxRetries) {
      print('\n📋 第 ${currentRetry + 1} 次编译尝试...');
      
      // 1. 运行编译检查
      final compileResult = await _runCompileCheck();
      
      if (compileResult.success) {
        print('✅ 编译成功！');
        break;
      }
      
      print('❌ 编译失败，错误信息：');
      print(compileResult.errors.join('\n'));
      
      // 2. 自动修复错误
      final fixResult = await _autoFixErrors(compileResult.errors);
      
      if (!fixResult) {
        print('⚠️ 无法自动修复错误，需要手动处理');
        break;
      }
      
      currentRetry++;
    }
    
    if (currentRetry >= maxRetries) {
      print('❌ 达到最大重试次数，请手动检查错误');
      exit(1);
    }
  }
  
  /// 运行编译检查
  static Future<CompileResult> _runCompileCheck() async {
    try {
      final result = await Process.run(
        'flutter',
        ['analyze', '--no-pub'],
        workingDirectory: '.',
      );
      
      if (result.exitCode == 0) {
        return CompileResult(success: true, errors: []);
      }
      
      final errors = _parseErrors(result.stdout.toString() + result.stderr.toString());
      return CompileResult(success: false, errors: errors);
      
    } catch (e) {
      print('编译检查失败: $e');
      return CompileResult(success: false, errors: ['编译检查失败: $e']);
    }
  }
  
  /// 解析错误信息
  static List<String> _parseErrors(String output) {
    final lines = output.split('\n');
    final errors = <String>[];
    
    for (final line in lines) {
      if (line.contains('error:') || line.contains('Error:')) {
        errors.add(line.trim());
      }
    }
    
    return errors;
  }
  
  /// 自动修复错误
  static Future<bool> _autoFixErrors(List<String> errors) async {
    bool hasFixedAny = false;
    
    for (final error in errors) {
      final fixed = await _fixSingleError(error);
      if (fixed) {
        hasFixedAny = true;
        print('✅ 已修复: $error');
      } else {
        print('⚠️ 无法修复: $error');
      }
    }
    
    return hasFixedAny;
  }
  
  /// 修复单个错误
  static Future<bool> _fixSingleError(String error) async {
    // 括号不匹配错误
    if (error.contains("Can't find ')' to match '('")) {
      return await _fixBracketMismatch(error);
    }
    
    // 缺少分号错误
    if (error.contains("Expected to find ';'")) {
      return await _fixMissingSemicolon(error);
    }
    
    // 未定义的变量/方法错误
    if (error.contains("isn't defined")) {
      return await _fixUndefinedReference(error);
    }
    
    // 类型错误
    if (error.contains("type") && error.contains("isn't assignable")) {
      return await _fixTypeError(error);
    }
    
    return false;
  }
  
  /// 修复括号不匹配
  static Future<bool> _fixBracketMismatch(String error) async {
    // 提取文件名和行号
    final fileMatch = RegExp(r'([^:]+):(\d+):(\d+)').firstMatch(error);
    if (fileMatch == null) return false;
    
    final filePath = fileMatch.group(1)!;
    final lineNumber = int.parse(fileMatch.group(2)!);
    
    try {
      final file = File(filePath);
      if (!file.existsSync()) return false;
      
      final content = await file.readAsString();
      final lines = content.split('\n');
      
      // 简单的括号匹配修复
      final fixedContent = _fixBrackets(content);
      
      if (fixedContent != content) {
        await file.writeAsString(fixedContent);
        print('🔧 已修复括号匹配问题: $filePath');
        return true;
      }
      
    } catch (e) {
      print('修复括号错误失败: $e');
    }
    
    return false;
  }
  
  /// 修复括号匹配
  static String _fixBrackets(String content) {
    // 这是一个简化的括号修复逻辑
    // 实际应用中需要更复杂的AST分析
    
    int openParens = 0;
    int openBraces = 0;
    int openBrackets = 0;
    
    for (int i = 0; i < content.length; i++) {
      switch (content[i]) {
        case '(':
          openParens++;
          break;
        case ')':
          openParens--;
          break;
        case '{':
          openBraces++;
          break;
        case '}':
          openBraces--;
          break;
        case '[':
          openBrackets++;
          break;
        case ']':
          openBrackets--;
          break;
      }
    }
    
    // 如果有未匹配的括号，尝试添加
    String result = content;
    
    if (openParens > 0) {
      result += ')' * openParens;
    }
    if (openBraces > 0) {
      result += '}' * openBraces;
    }
    if (openBrackets > 0) {
      result += ']' * openBrackets;
    }
    
    return result;
  }
  
  /// 修复缺少分号
  static Future<bool> _fixMissingSemicolon(String error) async {
    // TODO: 实现分号修复逻辑
    return false;
  }
  
  /// 修复未定义引用
  static Future<bool> _fixUndefinedReference(String error) async {
    // TODO: 实现未定义引用修复逻辑
    return false;
  }
  
  /// 修复类型错误
  static Future<bool> _fixTypeError(String error) async {
    // TODO: 实现类型错误修复逻辑
    return false;
  }
}

class CompileResult {
  final bool success;
  final List<String> errors;
  
  CompileResult({required this.success, required this.errors});
}

void main(List<String> args) async {
  await AutoCompileErrorFixer.main(args);
}






