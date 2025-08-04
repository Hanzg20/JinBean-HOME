#!/bin/bash

# 自动运行Flutter应用的脚本
# 使用方法: ./auto_run.sh

echo "🚀 开始自动运行Flutter应用..."

# 1. 检查Flutter环境
echo "📋 检查Flutter环境..."
flutter doctor --android-licenses > /dev/null 2>&1

# 2. 清理并获取依赖
echo "🧹 清理项目..."
flutter clean
flutter pub get

# 3. 检查编译错误
echo "🔍 检查编译错误..."
flutter analyze

# 4. 运行应用
echo "📱 启动Flutter应用..."
flutter run -d iPhone &

# 5. 等待应用启动
echo "⏳ 等待应用启动..."
sleep 30

# 6. 检查应用状态
echo "✅ 检查应用状态..."
if pgrep -f "flutter run" > /dev/null; then
    echo "🎉 Flutter应用运行成功！"
    echo "📊 应用进程信息："
    ps aux | grep flutter | grep -v grep
else
    echo "❌ Flutter应用启动失败"
    exit 1
fi

echo "✨ 自动运行完成！" 