#!/bin/bash

echo "🧹 开始清理代码警告和优化..."

# 1. 运行静态分析
echo "📊 运行静态分析..."
flutter analyze --write=analysis_results.txt

# 2. 格式化代码
echo "🎨 格式化代码..."
dart format .

# 3. 修复导入顺序
echo "📦 修复导入顺序..."
dart fix --apply

# 4. 清理构建缓存
echo "🗑️ 清理构建缓存..."
flutter clean

# 5. 重新获取依赖
echo "📥 重新获取依赖..."
flutter pub get

# 6. 生成代码 (如果有需要)
echo "⚙️ 生成代码..."
flutter packages pub run build_runner build --delete-conflicting-outputs

echo "✅ 清理完成！"
echo "📋 分析结果已保存到 analysis_results.txt"
