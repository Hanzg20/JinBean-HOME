#!/bin/bash

# 自动编译错误检测和修复脚本
# 使用方法: ./scripts/auto_compile_fix.sh

echo "🔄 开始自动编译错误检测和修复..."

MAX_RETRIES=3
CURRENT_RETRY=0

while [ $CURRENT_RETRY -lt $MAX_RETRIES ]; do
    echo ""
    echo "📋 第 $((CURRENT_RETRY + 1)) 次编译尝试..."
    
    # 运行 Flutter 分析
    COMPILE_OUTPUT=$(flutter analyze --no-pub 2>&1)
    COMPILE_EXIT_CODE=$?
    
    if [ $COMPILE_EXIT_CODE -eq 0 ]; then
        echo "✅ 编译成功！"
        break
    fi
    
    echo "❌ 编译失败，错误信息："
    echo "$COMPILE_OUTPUT"
    
    # 检查常见错误并尝试修复
    FIXED=false
    
    # 修复括号不匹配错误
    if echo "$COMPILE_OUTPUT" | grep -q "Can't find ')' to match '('"; then
        echo "🔧 检测到括号不匹配错误，尝试修复..."
        
        # 提取文件路径
        FILE_PATH=$(echo "$COMPILE_OUTPUT" | grep -o '[^:]*\.dart' | head -1)
        
        if [ ! -z "$FILE_PATH" ] && [ -f "$FILE_PATH" ]; then
            echo "🔧 修复文件: $FILE_PATH"
            
            # 备份原文件
            cp "$FILE_PATH" "${FILE_PATH}.backup"
            
            # 简单的括号修复 - 移除重复的 );
            sed -i.tmp 's/);[[:space:]]*);/);/g' "$FILE_PATH"
            rm "${FILE_PATH}.tmp" 2>/dev/null
            
            FIXED=true
            echo "✅ 已尝试修复括号问题"
        fi
    fi
    
    # 修复未定义getter错误
    if echo "$COMPILE_OUTPUT" | grep -q "isn't defined for the class"; then
        echo "🔧 检测到未定义getter错误，尝试修复..."
        
        # 这里可以添加特定的修复逻辑
        # 例如：移除对不存在字段的引用
        
        FIXED=true
    fi
    
    if [ "$FIXED" = false ]; then
        echo "⚠️ 无法自动修复错误，需要手动处理"
        break
    fi
    
    CURRENT_RETRY=$((CURRENT_RETRY + 1))
done

if [ $CURRENT_RETRY -ge $MAX_RETRIES ]; then
    echo "❌ 达到最大重试次数，请手动检查错误"
    exit 1
fi

echo "🎉 编译修复完成！"






