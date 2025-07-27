# JinBean 开发文档

> 本文档是JinBean项目的开发文档索引，包含开发规范、协作流程、技术指南等内容。

## 📋 文档目录

### 🎯 开发规范
- [开发规范](./development_standards.md) - 代码规范、分支管理、提交规范等
- [协作流程](./collaboration_workflow.md) - Provider端和Customer端协作开发流程

### 📚 技术文档
- [Provider端文档](../provider/README.md) - Provider端开发文档
- [Customer端文档](../customer/README.md) - Customer端开发文档
- [共享组件文档](../shared/README.md) - 共享组件开发文档

### 🗄️ 数据库文档
- [数据库架构](../shared/database_schema.md) - 数据库设计文档
- [API标准](../shared/api_standards.md) - API设计标准

## 🚀 快速开始

### 1. 环境准备

```bash
# 克隆项目
git clone https://github.com/Hanzg20/JinBean-HOME.git
cd JinBean-HOME

# 安装Flutter依赖
flutter pub get

# 配置环境
cp .env.example .env
# 编辑.env文件，配置数据库连接等信息
```

### 2. 开发流程

```bash
# 1. 创建功能分支
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name

# 2. 开发功能
# 按照开发规范进行开发

# 3. 提交代码
git add .
git commit -m "feat: 实现xxx功能"

# 4. 推送到远程
git push origin feature/your-feature-name

# 5. 创建Pull Request
# 在GitHub上创建Pull Request到develop分支
```

### 3. 测试流程

```bash
# 运行单元测试
flutter test

# 运行集成测试
flutter test integration_test/

# 代码分析
flutter analyze

# 代码格式化
dart format .
```

## 📖 开发指南

### Provider端开发

1. **项目结构**
   ```
   lib/features/provider/
   ├── orders/          # 订单管理
   ├── clients/         # 客户管理
   ├── services/        # 服务管理
   ├── income/          # 收入管理
   └── shared/          # 共享组件
   ```

2. **开发规范**
   - 遵循Flutter/Dart代码规范
   - 使用GetX进行状态管理
   - 编写单元测试和集成测试
   - 更新相关文档

3. **协作要求**
   - 修改共享组件时通知Customer端团队
   - 数据库变更需要通知相关团队
   - API变更需要协调设计

### Customer端开发

1. **项目结构**
   ```
   lib/features/customer/
   ├── booking/         # 服务预约
   ├── orders/          # 订单管理
   ├── profile/         # 个人资料
   └── reviews/         # 评价功能
   ```

2. **开发规范**
   - 遵循Flutter/Dart代码规范
   - 使用GetX进行状态管理
   - 编写单元测试和集成测试
   - 更新相关文档

3. **协作要求**
   - 修改共享组件时通知Provider端团队
   - 数据库变更需要通知相关团队
   - API变更需要协调设计

### 共享组件开发

1. **组件类型**
   ```
   lib/shared/
   ├── models/          # 共享数据模型
   ├── services/        # 共享服务
   ├── widgets/         # 共享UI组件
   └── utils/           # 共享工具类
   ```

2. **开发规范**
   - 保持向后兼容性
   - 编写完整的文档
   - 提供使用示例
   - 编写单元测试

3. **发布流程**
   - 版本号管理
   - 变更日志更新
   - 通知相关团队
   - 集成测试验证

## 🔧 工具和配置

### 开发工具

- **IDE**: VS Code / Android Studio
- **版本控制**: Git
- **项目管理**: GitHub Issues
- **文档协作**: Markdown
- **测试框架**: Flutter Test

### 代码质量工具

- **代码分析**: flutter analyze
- **代码格式化**: dart format
- **测试覆盖率**: flutter test --coverage
- **性能分析**: Flutter Inspector

### 持续集成

- **自动化测试**: GitHub Actions
- **代码审查**: GitHub Pull Request
- **自动部署**: GitHub Actions
- **质量门禁**: 代码覆盖率、测试通过率

## 📞 联系方式

### 开发团队

- **Provider端负责人**: @provider_lead
- **Customer端负责人**: @customer_lead
- **架构师**: @architect
- **数据库工程师**: @db_engineer

### 沟通渠道

- **即时通讯**: Slack/Discord
- **项目管理**: GitHub Issues
- **文档协作**: Notion/Confluence
- **邮件**: dev@jinbean.com

## 📝 更新日志

### 2024-12-XX
- 建立开发规范和协作流程
- 创建Provider端和Customer端协作机制
- 建立数据库变更和API变更流程
- 建立发布协调流程

### 2024-12-XX
- 完善开发文档结构
- 添加快速开始指南
- 更新开发工具配置
- 建立持续集成流程

---

**最后更新**: 2024年12月
**维护者**: JinBean开发团队 