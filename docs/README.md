# JinBean 项目文档

## 📁 文档结构

### 🗄️ **数据库文档** (`docs/database/`)
- `schema_master.sql` - 数据库表结构主入口文件 ⭐
- `README_TABLE_STRUCTURES.md` - 表结构状态说明
- `VERSION_MANAGEMENT.md` - 版本管理策略
- `database design.md` - 数据库设计文档
- `data_dictionary.md` - 数据字典
- `ref_codes.sql` - 分类编码表结构
- `database_setup_instructions.md` - 数据库设置说明
- `ref_codes_rows .sql` - 分类数据
- `migration_scripts/` - 数据库迁移脚本

### 🚀 **开发文档** (`docs/development/`)
- `development_progress.md` - 开发进度记录
- `customer_ui_rework_plan.md` - 客户UI重构计划
- `dual_instance_development_guide.md` - 双实例开发指南

### 🔌 **API文档** (`docs/api/`)
- `api_rest_spec.md` - REST API规范
- `api_websocket_spec.md` - WebSocket API规范
- `api_examples.md` - API使用示例

### 👥 **用户指南** (`docs/user-guide/`)
- `user_manual.md` - 用户手册
- `admin_guide.md` - 管理员指南
- `faq.md` - 常见问题

### 🚀 **部署文档** (`docs/deployment/`)
- `deployment_guide.md` - 部署指南
- `environment_config.md` - 环境配置
- `ci_cd_pipeline.md` - CI/CD流水线

## 🎯 **重要提醒**

### **生产环境数据库部署**
- ✅ **使用**: `docs/database/schema_master.sql`
- ❌ **不要使用**: 单独的模块文件

### **文档更新流程**
1. 修改相应的文档文件
2. 更新版本号（如适用）
3. 提交Git变更
4. 保持文档同步

## 🔗 **快速链接**

- [数据库表结构](./database/README_TABLE_STRUCTURES.md)
- [版本管理策略](./database/VERSION_MANAGEMENT.md)
- [开发进度](./development/development_progress.md)
- [API规范](./api/api_rest_spec.md)
- [部署指南](./deployment/deployment_guide.md)

---

**最后更新**: 2025-01-08  
**文档状态**: ✅ 已整理完成  
**维护人员**: AI Assistant 