#!/bin/bash

# 批量替换废弃的API脚本
echo "开始批量替换废弃的API..."

# 替换withOpacity为withValues
echo "替换withOpacity为withValues..."
find lib -name "*.dart" -exec sed -i '' 's/\.withOpacity(\([^)]*\))/\.withValues(alpha: \1)/g' {} \;

# 替换surfaceVariant为surfaceContainerHighest
echo "替换surfaceVariant为surfaceContainerHighest..."
find lib -name "*.dart" -exec sed -i '' 's/surfaceVariant/surfaceContainerHighest/g' {} \;

# 替换fromAssetImage为BitmapDescriptor.asset
echo "替换fromAssetImage为BitmapDescriptor.asset..."
find lib -name "*.dart" -exec sed -i '' 's/fromAssetImage/BitmapDescriptor.asset/g' {} \;

echo "废弃API替换完成！"
