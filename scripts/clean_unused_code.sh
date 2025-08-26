#!/bin/bash

# 清理未使用代码脚本
echo "开始清理未使用的代码..."

# 使用dart fix清理未使用的代码
echo "运行dart fix清理未使用的代码..."
dart fix --apply

# 手动清理一些明显的未使用代码
echo "手动清理未使用的代码..."

# 清理未使用的字段
find lib -name "*.dart" -exec sed -i '' '/^\s*\/\/.*unused_field/d' {} \;

# 清理未使用的函数
find lib -name "*.dart" -exec sed -i '' '/^\s*\/\/.*unused_element/d' {} \;

echo "未使用的代码清理完成！"
