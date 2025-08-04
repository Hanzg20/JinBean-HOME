# 🚀 Flutter自动运行指南

## 📋 自动化脚本说明

### 1. `auto_run.sh` - 一次性自动运行
```bash
./auto_run.sh
```
**功能：**
- 清理项目
- 获取依赖
- 检查编译错误
- 启动Flutter应用
- 验证运行状态

### 2. `watch_and_run.sh` - 持续监控自动运行
```bash
./watch_and_run.sh
```
**功能：**
- 监控`lib/`目录下的文件变化
- 自动检测代码修改
- 自动重启Flutter应用
- 持续运行直到手动停止

## 🎯 使用方法

### 方法一：手动触发自动运行
```bash
# 每次修改代码后运行
./auto_run.sh
```

### 方法二：持续监控自动运行
```bash
# 启动监控模式（推荐）
./watch_and_run.sh

# 停止监控：Ctrl+C
```

### 方法三：VS Code集成
在VS Code的`settings.json`中添加：
```json
{
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 1000,
    "terminal.integrated.shellArgs.osx": ["-c", "cd /path/to/your/project && ./watch_and_run.sh"]
}
```

## 🔧 故障排除

### 常见问题

1. **权限问题**
```bash
chmod +x auto_run.sh
chmod +x watch_and_run.sh
```

2. **fswatch未安装**
```bash
brew install fswatch
```

3. **Flutter环境问题**
```bash
flutter doctor
flutter clean
flutter pub get
```

4. **模拟器问题**
```bash
# 检查可用设备
flutter devices

# 启动iOS模拟器
open -a Simulator
```

## 📱 应用状态检查

### 检查Flutter进程
```bash
ps aux | grep flutter | grep -v grep
```

### 检查应用日志
```bash
flutter logs
```

## 🎉 自动化工作流

1. **开发阶段**：使用`watch_and_run.sh`持续监控
2. **测试阶段**：使用`auto_run.sh`确保稳定运行
3. **部署阶段**：手动验证后提交代码

## 📊 状态指示器

- 🚀 正在启动
- ✅ 运行成功
- ❌ 运行失败
- ⏳ 等待中
- 🔍 检查中
- 📝 检测到变化

---

**提示：** 建议在开发时使用`watch_and_run.sh`，这样可以实现真正的自动化开发体验！ 