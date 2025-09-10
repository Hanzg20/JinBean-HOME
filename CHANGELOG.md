# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [0.0.3] - 2025-09-10

### 🚀 重大修复
- **彻底解决购物车卡顿和崩溃问题**
  - 修复 `Lost connection to device` 崩溃问题
  - 实现强制对话框关闭机制，确保UI状态一致性
  - 添加多层次对话框关闭重试机制（最多3次重试）
  - 实现紧急关闭机制，防止UI状态冲突

### 🔧 技术优化
- **购物车控制器全面优化**
  - 添加UI状态监控系统，实时追踪卡顿点
  - 实现内存管理优化，防止内存泄漏
  - 优化防抖机制，延迟从50ms减少到20ms
  - 添加PostFrame UI刷新机制

- **Menu Tab功能增强**
  - 实现崩溃防护机制，完整的try-catch-finally包装
  - 添加Context状态检查，确保UI操作安全
  - 优化异步操作时序，使用Future.microtask替代Future.delayed
  - 实现UI状态验证机制，检测崩溃前兆

### 📊 性能提升
- **购物车添加操作响应时间优化**
  - 并行服务信息获取优化50%
  - 缓存命中率提升，本地数据0ms响应
  - UI更新立即响应，无阻塞操作
  - 后台持久化异步执行

### 🛡️ 稳定性改进
- **错误处理机制完善**
  - 添加详细的错误日志和状态监控
  - 实现多层错误恢复机制
  - 确保所有UI操作都有完整的异常处理
  - 添加资源释放和内存清理机制

### 📝 文档更新
- **数据库架构整理**
  - 合并多个schema文件，保留最新版本
  - 更新Review模型，匹配数据库schema
  - 修复所有数据库查询中的外键引用错误
  - 完善Reviews功能实现

## [Unreleased]
- Initial international documentation structure and refactor.

### Bug 修复
- 修复角色切换后页面卡死、tab 越界、主题未切换等问题。
- 修复多角色用户首次登录后自动跳转错误问题。
- 修复 profile 页自动切换 provider 的副作用，只有用户主动点击才切换。
- 修复所有与角色切换、tab、主题相关的历史遗留 bug。

---

如需历史版本变更，请查阅 Git 历史。 