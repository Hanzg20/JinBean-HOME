#!/bin/bash

# 替换print语句为AppLogger脚本
echo "开始替换print语句为AppLogger..."

# 替换print语句
echo "替换print语句..."
find lib -name "*.dart" -exec sed -i '' 's/print(/AppLogger.info(/g' {} \;

# 添加AppLogger导入到需要的文件
echo "添加AppLogger导入..."
find lib -name "*.dart" -exec grep -l "AppLogger" {} \; | while read file; do
  if ! grep -q "import.*app_logger" "$file"; then
    echo "Adding AppLogger import to $file"
    sed -i '' '1i\
import '\''package:jinbeanpod_83904710/core/utils/app_logger.dart'\'';' "$file"
  fi
done

echo "print语句替换完成！"
