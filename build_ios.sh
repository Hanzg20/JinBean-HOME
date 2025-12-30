#!/bin/bash

echo "🚀 开始iOS发布构建..."

# 版本号
VERSION="1.0.0"
BUILD="4"

echo "📦 版本: $VERSION ($BUILD)"

# 清理
echo "🧹 清理项目..."
flutter clean

# 获取依赖
echo "📦 获取依赖..."
flutter pub get

# iOS依赖
echo "🍎 安装iOS依赖..."
cd ios
pod install
cd ..

# 构建
echo "🔨 构建Release版本..."
flutter build ios --release --build-name=$VERSION --build-number=$BUILD

echo "✅ 构建完成！"
echo "📝 下一步："
echo "1. 打开 Xcode: open ios/Runner.xcworkspace"
echo "2. 选择设备: Generic iOS Device"
echo "3. Product → Archive"
echo "4. 上传到App Store Connect"