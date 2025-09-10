#!/usr/bin/env dart

/// 简化的自动编译系统
/// 专注于编译而不是代码分析

import 'dart:io';
import 'dart:async';

void main() async {
  print('🚀 启动简化自动编译系统...');
  
  while (true) {
    try {
      print('\n🔨 开始编译...');
      
      // 直接尝试编译
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
        print('❌ 编译失败:');
        
        // 只显示关键错误信息
        final errorLines = output.split('\n')
            .where((line) => line.contains('Error:') && !line.contains('info •') && !line.contains('warning •'))
            .take(3)
            .toList();
            
        for (final error in errorLines) {
          print('   $error');
        }
        
        print('\n⏳ 等待5秒后重试...');
        await Future.delayed(Duration(seconds: 5));
      }
      
    } catch (e) {
      print('❌ 编译过程出错: $e');
      await Future.delayed(Duration(seconds: 5));
    }
  }
}
