# JinBean 数据库版本管理策略

## 🎯 **核心原则：单一入口 + 版本控制**

### **方案1：单一入口文件（推荐）**
- **主文件**: `schema_master.sql` - 包含所有表结构定义
- **其他文件**: 作为参考和备份，不用于生产环境
- **优势**: 确保一致性，避免版本冲突

### **方案2：模块化 + 主入口**
- **主入口**: `schema_master.sql` - 调用各个模块
- **模块文件**: 按功能分组（如用户相关、订单相关等）
- **优势**: 便于维护，支持团队协作

## 📁 **文件组织结构**

```
docu/database_schema/
├── schema_master.sql          # 🎯 主入口文件（生产环境使用）
├── VERSION_MANAGEMENT.md      # 版本管理策略
├── README_TABLE_STRUCTURES.md # 表结构状态说明
├── 
├── 📋 参考文件（不用于生产）
│   ├── provider_profiles.sql
│   ├── services.sql
│   ├── service_details.sql
│   ├── orders.sql
│   ├── order_items.sql
│   └── ref_codes.sql
├── 
├── 📚 设计文档
│   ├── database design.md
│   └── data_dictionary.md
└── 
└── 🔧 迁移脚本
    ├── service_details_migration.sql
    └── migration_scripts/
```

## 🔄 **版本更新流程**

### **步骤1：更新主入口文件**
```bash
# 1. 修改 schema_master.sql
# 2. 更新版本号（如 v2.0.0 → v2.1.0）
# 3. 更新变更日志
```

### **步骤2：同步其他文件**
```bash
# 1. 更新对应的模块文件（保持同步）
# 2. 更新设计文档
# 3. 更新数据字典
```

### **步骤3：版本控制**
```bash
# 1. Git提交
git add docu/database_schema/
git commit -m "feat: 更新数据库表结构到v2.1.0"
git tag v2.1.0

# 2. 推送到远程
git push origin main
git push origin v2.1.0
```

## 📊 **版本号规范**

### **语义化版本 (SemVer)**
```
v主版本.次版本.修订版本
v2.0.0
│ │ │
│ │ └─ 修订版本：Bug修复，向后兼容
│ └─── 次版本：新功能，向后兼容  
└───── 主版本：重大变更，不向后兼容
```

### **版本类型**
- **v1.x.x**: 基础版本
- **v2.x.x**: 重构版本（当前）
- **v3.x.x**: 未来重大升级

## 🚀 **部署策略**

### **生产环境**
```sql
-- 使用主入口文件
\i docu/database_schema/schema_master.sql
```

### **开发环境**
```sql
-- 可以使用模块文件进行测试
\i docu/database_schema/provider_profiles.sql
\i docu/database_schema/services.sql
-- ... 其他表
```

### **测试环境**
```sql
-- 使用主入口文件 + 测试数据
\i docu/database_schema/schema_master.sql
\i docs/ServiceDetail/fixed_id_test_data.sql
```

## 📝 **变更日志管理**

### **变更记录格式**
```markdown
## [v2.1.0] - 2025-01-XX

### 新增
- 新增用户地址管理功能
- 新增服务评价系统

### 变更
- 优化service_details表索引
- 更新RLS策略

### 修复
- 修复外键约束问题
- 修复数据类型不匹配
```

### **变更类型标识**
- 🆕 **新增**: 新功能、新表、新字段
- 🔄 **变更**: 字段类型、约束、索引修改
- 🐛 **修复**: Bug修复、数据问题
- 🗑️ **删除**: 废弃字段、表、功能
- 📈 **优化**: 性能优化、索引优化

## 🔒 **安全策略**

### **备份策略**
```bash
# 1. 自动备份
pg_dump -h localhost -U username -d jinbean > backup_$(date +%Y%m%d_%H%M%S).sql

# 2. 版本备份
cp schema_master.sql schema_master_v2.0.0_backup.sql
```

### **回滚策略**
```sql
-- 1. 恢复备份
\i backup_20250108_143022.sql

-- 2. 或使用历史版本
\i schema_master_v2.0.0_backup.sql
```

## 📋 **维护检查清单**

### **每次更新前**
- [ ] 备份当前数据库
- [ ] 在测试环境验证
- [ ] 检查向后兼容性
- [ ] 更新版本号
- [ ] 更新变更日志

### **每次更新后**
- [ ] 验证表结构完整性
- [ ] 测试关键功能
- [ ] 检查索引性能
- [ ] 更新文档
- [ ] 提交Git版本

## 🎯 **最佳实践**

### **1. 单一真相源**
- 所有表结构变更都在`schema_master.sql`中进行
- 其他文件作为参考，不直接使用

### **2. 版本锁定**
- 生产环境使用特定版本标签
- 避免使用`main`分支的未测试代码

### **3. 渐进式更新**
- 重大变更分多个小版本
- 每个版本都有完整的测试和验证

### **4. 文档同步**
- 代码变更与文档更新同步
- 保持README和设计文档的一致性

---

**当前版本**: v2.0.0  
**最后更新**: 2025-01-08  
**维护人员**: AI Assistant + 开发团队
