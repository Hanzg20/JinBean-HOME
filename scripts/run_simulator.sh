#!/bin/bash

# JinBean Provider端模拟器运行脚本

echo "🚀 启动JinBean Provider端模拟器..."
echo "=================================="

# 设置颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查Flutter环境
check_flutter() {
    echo -e "${BLUE}📋 检查Flutter环境...${NC}"
    if command -v flutter &> /dev/null; then
        echo -e "${GREEN}✅ Flutter已安装${NC}"
        flutter --version
    else
        echo -e "${RED}❌ Flutter未安装，请先安装Flutter${NC}"
        exit 1
    fi
}

# 检查依赖
check_dependencies() {
    echo -e "${BLUE}📦 检查项目依赖...${NC}"
    if [ -f "pubspec.yaml" ]; then
        echo -e "${GREEN}✅ 找到pubspec.yaml${NC}"
        flutter pub get
    else
        echo -e "${RED}❌ 未找到pubspec.yaml，请确保在Flutter项目根目录${NC}"
        exit 1
    fi
}

# 启动模拟器
start_simulator() {
    echo -e "${BLUE}🎮 启动Provider端模拟器...${NC}"
    
    # 检查是否有可用的设备
    echo -e "${YELLOW}📱 检查可用设备...${NC}"
    flutter devices
    
    echo -e "${YELLOW}🚀 启动模拟器...${NC}"
    
    # 尝试启动模拟器
    if flutter run --debug; then
        echo -e "${GREEN}✅ 模拟器启动成功！${NC}"
    else
        echo -e "${RED}❌ 模拟器启动失败${NC}"
        echo -e "${YELLOW}💡 提示：请确保有可用的设备或模拟器${NC}"
        exit 1
    fi
}

# 显示模拟器信息
show_simulator_info() {
    echo -e "${BLUE}📊 模拟器信息...${NC}"
    
    echo "=================================="
    echo -e "${GREEN}🎉 JinBean Provider端模拟器${NC}"
    echo "=================================="
    echo ""
    echo "📋 功能模块:"
    echo "   • 订单管理模拟器"
    echo "   • 客户管理模拟器"
    echo "   • 服务管理模拟器"
    echo "   • 收入管理模拟器"
    echo "   • 通知系统模拟器"
    echo ""
    echo "🎯 使用方法:"
    echo "   1. 启动应用后，点击'模拟器'按钮"
    echo "   2. 选择'Provider端模拟器'"
    echo "   3. 使用底部导航栏切换不同模块"
    echo "   4. 点击按钮生成模拟数据"
    echo ""
    echo "🔧 快捷键:"
    echo "   • R - 热重载"
    echo "   • Shift+R - 热重启"
    echo "   • Q - 退出"
    echo ""
    echo "📞 技术支持:"
    echo "   • 邮箱: support@jinbean.com"
    echo "   • 文档: docs/simulator/"
    echo ""
}

# 主函数
main() {
    echo -e "${BLUE}🎯 JinBean Provider端模拟器启动${NC}"
    echo "=================================="
    
    # 检查环境
    check_flutter
    check_dependencies
    
    # 显示信息
    show_simulator_info
    
    # 启动模拟器
    start_simulator
}

# 运行主函数
main "$@" 