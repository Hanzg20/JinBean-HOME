#!/bin/bash

# 清理未使用的导入脚本
echo "开始清理未使用的导入..."

# 使用dart fix来自动清理未使用的导入
echo "运行dart fix清理未使用的导入..."
dart fix --apply

echo "未使用的导入清理完成！"
