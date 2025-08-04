#!/bin/bash

# 文件监控并自动运行Flutter应用的脚本
# 使用方法: ./watch_and_run.sh

echo "👀 开始监控代码变化..."

# 检查是否安装了fswatch
if ! command -v fswatch &> /dev/null; then
    echo "📦 安装fswatch..."
    brew install fswatch
fi

# 监控Dart文件变化
echo "🔍 监控lib目录下的Dart文件变化..."
fswatch -o lib/ | while read f; do
    echo "📝 检测到文件变化，开始自动运行..."
    
    # 停止之前的Flutter进程
    pkill -f "flutter run" 2>/dev/null
    
    # 等待进程完全停止
    sleep 2
    
    # 运行应用
    echo "🚀 启动Flutter应用..."
    flutter run -d iPhone &
    
    # 等待应用启动
    sleep 30
    
    # 检查应用状态
    if pgrep -f "flutter run" > /dev/null; then
        echo "✅ Flutter应用运行成功！"
    else
        echo "❌ Flutter应用启动失败"
    fi
    
    echo "⏳ 继续监控中..."
done 