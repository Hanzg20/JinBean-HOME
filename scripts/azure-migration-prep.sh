#!/bin/bash

# GoldSky MessageCore Azure迁移准备脚本
# 帮助准备Microsoft Startup申请和Azure环境配置

set -e

echo "🚀 GoldSky MessageCore Azure迁移准备脚本"
echo "=========================================="

# 检查Azure CLI
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI 未安装，请先安装 Azure CLI"
    echo "安装命令: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    exit 1
fi

# 检查是否已登录Azure
if ! az account show &> /dev/null; then
    echo "⚠️  未登录Azure，请先登录"
    echo "登录命令: az login"
    exit 1
fi

echo "✅ Azure环境检查通过"

# 创建Azure资源组
echo "📁 创建Azure资源组..."
RESOURCE_GROUP="messagecore-rg"
LOCATION="eastus"

az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION \
  --tags "project=messagecore" "environment=development"

echo "✅ 资源组创建完成: $RESOURCE_GROUP"

# 创建Azure PostgreSQL数据库
echo "🗄️  创建Azure PostgreSQL数据库..."
DB_SERVER_NAME="messagecore-postgresql"
DB_NAME="messagecore"
DB_USERNAME="messagecore_admin"
DB_PASSWORD=$(openssl rand -base64 32)

az postgres flexible-server create \
  --resource-group $RESOURCE_GROUP \
  --name $DB_SERVER_NAME \
  --location $LOCATION \
  --admin-user $DB_USERNAME \
  --admin-password $DB_PASSWORD \
  --sku-name Standard_B1ms \
  --version 15 \
  --storage-size 32

# 创建数据库
az postgres flexible-server db create \
  --resource-group $RESOURCE_GROUP \
  --server-name $DB_SERVER_NAME \
  --database-name $DB_NAME

echo "✅ PostgreSQL数据库创建完成"

# 创建Azure Blob Storage
echo "📦 创建Azure Blob Storage..."
STORAGE_ACCOUNT_NAME="messagecore$(openssl rand -hex 4)"

az storage account create \
  --resource-group $RESOURCE_GROUP \
  --name $STORAGE_ACCOUNT_NAME \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2

# 创建容器
az storage container create \
  --account-name $STORAGE_ACCOUNT_NAME \
  --name messagecore-files

echo "✅ Blob Storage创建完成"

# 创建Azure SignalR Service
echo "🔗 创建Azure SignalR Service..."
SIGNALR_NAME="messagecore-signalr"

az signalr create \
  --resource-group $RESOURCE_GROUP \
  --name $SIGNALR_NAME \
  --location $LOCATION \
  --sku Free_F1

echo "✅ SignalR Service创建完成"

# 创建Azure Active Directory B2C
echo "🔐 创建Azure AD B2C..."
B2C_NAME="messagecore-b2c"

az ad b2c directory create \
  --location $LOCATION \
  --name $B2C_NAME \
  --resource-group $RESOURCE_GROUP

echo "✅ Azure AD B2C创建完成"

# 生成配置文件
echo "⚙️  生成Azure配置文件..."

cat > azure-config.env << EOL
# Azure Configuration for GoldSky MessageCore
# Generated on $(date)

# Database Configuration
AZURE_DATABASE_URL="postgresql://${DB_USERNAME}:${DB_PASSWORD}@${DB_SERVER_NAME}.postgres.database.azure.com:5432/${DB_NAME}?sslmode=require"

# Storage Configuration
AZURE_STORAGE_ACCOUNT_NAME="${STORAGE_ACCOUNT_NAME}"
AZURE_STORAGE_CONNECTION_STRING="$(az storage account show-connection-string --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --query connectionString -o tsv)"

# SignalR Configuration
AZURE_SIGNALR_CONNECTION_STRING="$(az signalr key list --name $SIGNALR_NAME --resource-group $RESOURCE_GROUP --query primaryConnectionString -o tsv)"

# B2C Configuration
AZURE_B2C_TENANT="${B2C_NAME}.onmicrosoft.com"
AZURE_B2C_CLIENT_ID="$(az ad app create --display-name 'MessageCore B2C' --query appId -o tsv)"

# Resource Group
AZURE_RESOURCE_GROUP="${RESOURCE_GROUP}"
AZURE_LOCATION="${LOCATION}"
EOL

echo "✅ Azure配置文件生成完成: azure-config.env"

# 创建Microsoft Startup申请指南
echo "📋 创建Microsoft Startup申请指南..."

cat > microsoft-startup-guide.md << EOL
# Microsoft Startup申请指南

## 申请链接
https://startups.microsoft.com/

## 申请材料准备

### 1. 公司信息
- 公司名称: GoldSky Technology
- 成立时间: [填写实际时间]
- 团队规模: [填写实际人数]
- 融资阶段: [填写当前阶段]

### 2. 产品介绍
- 产品名称: GoldSky MessageCore
- 产品描述: 企业级多租户即时通讯SaaS平台
- 技术亮点: 实时通信、多租户隔离、企业级安全
- 目标市场: 中小企业、SaaS开发商

### 3. Azure使用计划
- 数据库: Azure Database for PostgreSQL
- 存储: Azure Blob Storage
- 实时通信: Azure SignalR Service
- 认证: Azure Active Directory B2C
- 监控: Azure Application Insights

### 4. 商业价值
- 解决企业通信痛点
- 降低中小企业技术门槛
- 支持全球化部署
- 企业级安全保障

## 申请步骤
1. 访问 https://startups.microsoft.com/
2. 注册账户并填写基本信息
3. 上传公司资料和产品介绍
4. 说明Azure服务使用计划
5. 等待审核结果

## 预期福利
- \$150,000 Azure免费额度
- 技术专家支持
- 企业级服务
- 市场推广支持
EOL

echo "✅ Microsoft Startup申请指南创建完成: microsoft-startup-guide.md"

# 创建迁移检查清单
echo "📝 创建迁移检查清单..."

cat > migration-checklist.md << EOL
# GoldSky MessageCore Azure迁移检查清单

## 迁移前准备
- [ ] Microsoft Startup项目申请完成
- [ ] Azure资源创建完成
- [ ] 测试环境搭建完成
- [ ] 数据备份完成
- [ ] 迁移脚本准备完成

## 数据迁移
- [ ] 数据库结构迁移
- [ ] 用户数据迁移
- [ ] 文件存储迁移
- [ ] 数据完整性验证
- [ ] 性能测试完成

## 服务迁移
- [ ] API服务迁移
- [ ] 实时通信迁移
- [ ] 认证系统迁移
- [ ] 监控系统迁移
- [ ] 集成测试完成

## 切换上线
- [ ] 灰度发布测试
- [ ] 监控验证
- [ ] 全量切换
- [ ] 旧服务清理
- [ ] 用户通知发送

## 迁移后验证
- [ ] 功能验证
- [ ] 性能验证
- [ ] 安全验证
- [ ] 用户反馈收集
- [ ] 文档更新
EOL

echo "✅ 迁移检查清单创建完成: migration-checklist.md"

echo ""
echo "🎉 Azure迁移准备完成！"
echo ""
echo "📋 下一步操作："
echo "1. 查看Microsoft Startup申请指南:"
echo "   open microsoft-startup-guide.md"
echo ""
echo "2. 查看迁移检查清单:"
echo "   open migration-checklist.md"
echo ""
echo "3. 配置Azure环境变量:"
echo "   cp azure-config.env .env"
echo ""
echo "4. 开始Microsoft Startup申请:"
echo "   访问 https://startups.microsoft.com/"
echo ""
echo "🌐 Azure资源信息："
echo "   - 资源组: $RESOURCE_GROUP"
echo "   - 数据库: $DB_SERVER_NAME"
echo "   - 存储账户: $STORAGE_ACCOUNT_NAME"
echo "   - SignalR: $SIGNALR_NAME"
echo "   - B2C: $B2C_NAME"
echo ""
echo "✨ 准备就绪，开始Azure迁移之旅！" 