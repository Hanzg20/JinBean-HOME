# GoldSky MessageCore 构建说明

## 📋 目录
1. [环境要求](#1-环境要求)
2. [快速构建](#2-快速构建)
3. [详细构建步骤](#3-详细构建步骤)
4. [配置说明](#4-配置说明)
5. [故障排除](#5-故障排除)
6. [部署选项](#6-部署选项)

## 1. 环境要求

### 1.1 基本要求

```yaml
操作系统:
  - macOS 10.15+
  - Ubuntu 20.04+
  - CentOS 8+
  - Windows 10+ (WSL2推荐)

Node.js:
  - 版本: 18.0.0 或更高
  - 推荐: 20.x LTS

npm:
  - 版本: 8.0.0 或更高
  - 推荐: 10.x

Git:
  - 版本: 2.30.0 或更高
```

### 1.2 可选依赖

```yaml
Docker:
  - 版本: 20.10+ (用于本地数据库)
  - 推荐: 24.x

PostgreSQL:
  - 版本: 13+ (如果不用Docker)
  - 推荐: 15.x

Redis:
  - 版本: 6+ (如果不用Docker)
  - 推荐: 7.x
```

### 1.3 硬件要求

```yaml
最低配置:
  - CPU: 2核心
  - 内存: 4GB RAM
  - 存储: 10GB 可用空间
  - 网络: 稳定的互联网连接

推荐配置:
  - CPU: 4核心
  - 内存: 8GB RAM
  - 存储: 20GB SSD
  - 网络: 100Mbps+
```

## 2. 快速构建

### 2.1 一键构建脚本

```bash
# 克隆项目
git clone <your-repo-url>
cd messagecore

# 运行快速构建脚本
./scripts/quick-build.sh
```

### 2.2 完整构建脚本

```bash
# 运行完整构建脚本（包含更多选项）
./scripts/build-platform.sh

# 查看帮助
./scripts/build-platform.sh --help
```

### 2.3 构建选项

```bash
# 开发环境构建
./scripts/build-platform.sh -e development

# 生产环境构建
./scripts/build-platform.sh -e production

# 使用Supabase数据库
./scripts/build-platform.sh -d supabase

# 使用Azure数据库
./scripts/build-platform.sh -d azure

# 清理缓存并构建
./scripts/build-platform.sh -c

# 运行测试
./scripts/build-platform.sh -t
```

## 3. 详细构建步骤

### 3.1 环境准备

```bash
# 1. 检查Node.js版本
node --version  # 应该 >= 18.0.0

# 2. 检查npm版本
npm --version   # 应该 >= 8.0.0

# 3. 检查Git版本
git --version   # 应该 >= 2.30.0

# 4. 检查Docker（可选）
docker --version  # 如果安装了Docker
```

### 3.2 项目初始化

```bash
# 1. 创建项目目录
mkdir goldsky-messagecore
cd goldsky-messagecore

# 2. 初始化Git仓库
git init

# 3. 创建项目结构
mkdir -p apps/{api,realtime,admin}
mkdir -p packages/{shared,sdk-js,sdk-flutter,db}
mkdir -p infrastructure/{docker,k8s}
mkdir -p docs scripts
```

### 3.3 依赖安装

```bash
# 1. 安装根目录依赖
npm install

# 2. 安装各个包的依赖
cd apps/api && npm install && cd ../..
cd apps/realtime && npm install && cd ../..
cd apps/admin && npm install && cd ../..
cd packages/shared && npm install && cd ../..
cd packages/sdk-js && npm install && cd ../..
cd packages/db && npm install && cd ../..
```

### 3.4 数据库配置

#### 本地PostgreSQL（推荐）

```bash
# 使用Docker启动PostgreSQL
docker run -d \
  --name messagecore-postgres \
  -e POSTGRES_DB=messagecore \
  -e POSTGRES_USER=messagecore \
  -e POSTGRES_PASSWORD=changeme \
  -p 5432:5432 \
  postgres:15

# 启动Redis
docker run -d \
  --name messagecore-redis \
  -p 6379:6379 \
  redis:7-alpine
```

#### Supabase配置

```bash
# 1. 在Supabase控制台创建项目
# 2. 获取连接字符串
# 3. 更新.env文件
DATABASE_URL="postgresql://postgres:[password]@[host]:5432/postgres"
```

#### Azure配置

```bash
# 运行Azure迁移准备脚本
./scripts/azure-migration-prep.sh
```

### 3.5 数据库初始化

```bash
# 1. 生成Prisma客户端
cd packages/db
npx prisma generate

# 2. 运行数据库迁移
npx prisma migrate dev --name init

# 3. 验证数据库连接
npx prisma studio
```

### 3.6 项目构建

```bash
# 1. 构建所有包
npm run build

# 2. 或分别构建
cd apps/api && npm run build && cd ../..
cd apps/realtime && npm run build && cd ../..
cd apps/admin && npm run build && cd ../..
cd packages/sdk-js && npm run build && cd ../..
```

### 3.7 启动服务

```bash
# 使用启动脚本
./start.sh

# 或手动启动
npm start

# 或分别启动
npm run start:api &
npm run start:realtime &
npm run start:admin &
```

## 4. 配置说明

### 4.1 环境变量

```bash
# .env 文件配置
NODE_ENV=development                    # 环境: development|production
PORT=3000                              # API服务端口
DATABASE_URL=postgresql://...          # 数据库连接字符串
REDIS_URL=redis://localhost:6379       # Redis连接字符串
JWT_SECRET=your-secret-key             # JWT密钥
DEFAULT_PLAN_TYPE=basic                # 默认套餐类型
ENABLE_RATE_LIMITING=true              # 启用限流
MIGRATION_MODE=supabase                # 迁移模式
```

### 4.2 数据库配置

#### PostgreSQL配置

```sql
-- 创建数据库
CREATE DATABASE messagecore;

-- 创建用户
CREATE USER messagecore WITH PASSWORD 'changeme';

-- 授权
GRANT ALL PRIVILEGES ON DATABASE messagecore TO messagecore;
```

#### Redis配置

```bash
# Redis配置文件 (redis.conf)
bind 127.0.0.1
port 6379
maxmemory 256mb
maxmemory-policy allkeys-lru
```

### 4.3 网络配置

```bash
# 防火墙配置 (Ubuntu/CentOS)
sudo ufw allow 3000  # API服务
sudo ufw allow 3001  # 实时服务
sudo ufw allow 3002  # 管理后台
sudo ufw allow 5432  # PostgreSQL
sudo ufw allow 6379  # Redis
```

## 5. 故障排除

### 5.1 常见问题

#### Node.js版本问题

```bash
# 错误: Node.js版本过低
# 解决: 升级Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# 或使用nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 20
nvm use 20
```

#### 端口占用问题

```bash
# 检查端口占用
lsof -i :3000
lsof -i :3001
lsof -i :3002

# 停止占用进程
kill -9 <PID>

# 或修改端口
# 在.env文件中修改PORT
PORT=3003
```

#### 数据库连接问题

```bash
# 检查PostgreSQL状态
docker ps | grep postgres
docker logs messagecore-postgres

# 重启PostgreSQL
docker restart messagecore-postgres

# 检查连接
psql -h localhost -U messagecore -d messagecore
```

#### 依赖安装失败

```bash
# 清理npm缓存
npm cache clean --force

# 删除node_modules
rm -rf node_modules package-lock.json
rm -rf apps/*/node_modules packages/*/node_modules

# 重新安装
npm install
```

#### 构建失败

```bash
# 检查TypeScript配置
npx tsc --noEmit

# 检查依赖版本
npm ls

# 清理构建缓存
npm run clean
npm run build
```

### 5.2 日志查看

```bash
# API服务日志
tail -f apps/api/logs/app.log

# 实时服务日志
tail -f apps/realtime/logs/app.log

# Docker容器日志
docker logs messagecore-api
docker logs messagecore-realtime
docker logs messagecore-postgres
docker logs messagecore-redis
```

### 5.3 性能优化

```bash
# 启用Node.js优化
export NODE_OPTIONS="--max-old-space-size=4096"

# 启用PM2进程管理
npm install -g pm2
pm2 start ecosystem.config.js

# 启用Redis持久化
docker run -d \
  --name messagecore-redis \
  -p 6379:6379 \
  -v redis_data:/data \
  redis:7-alpine redis-server --appendonly yes
```

## 6. 部署选项

### 6.1 本地开发

```bash
# 开发模式启动
npm run dev

# 或分别启动
npm run dev:api &
npm run dev:realtime &
npm run dev:admin &
```

### 6.2 Docker部署

```bash
# 使用Docker Compose
docker-compose up -d

# 构建镜像
docker build -t messagecore/api -f infrastructure/docker/api.Dockerfile .
docker build -t messagecore/realtime -f infrastructure/docker/realtime.Dockerfile .
docker build -t messagecore/admin -f infrastructure/docker/admin.Dockerfile .
```

### 6.3 Kubernetes部署

```bash
# 应用Kubernetes配置
kubectl apply -f infrastructure/k8s/

# 检查部署状态
kubectl get pods
kubectl get services
kubectl get ingress
```

### 6.4 云平台部署

#### 部署到Supabase

```bash
# 1. 配置Supabase项目
# 2. 更新环境变量
# 3. 部署到Vercel/Netlify

# Vercel部署
vercel --prod

# Netlify部署
netlify deploy --prod
```

#### 部署到Azure

```bash
# 1. 运行Azure迁移脚本
./scripts/azure-migration-prep.sh

# 2. 配置Azure资源
# 3. 部署到Azure Container Instances
az container create \
  --resource-group messagecore-rg \
  --name messagecore-api \
  --image messagecore/api:latest \
  --ports 3000
```

### 6.5 生产环境配置

```bash
# 1. 更新环境变量
NODE_ENV=production
JWT_SECRET=<strong-secret-key>
DATABASE_URL=<production-db-url>

# 2. 配置SSL证书
# 3. 设置反向代理 (Nginx)
# 4. 配置监控和日志
# 5. 设置备份策略
```

## 总结

通过以上步骤，您可以在任何机器上成功构建和部署GoldSky MessageCore平台。如果遇到问题，请参考故障排除部分或查看相关文档。

### 📞 获取帮助

- 📧 技术问题: [GitHub Issues](https://github.com/goldsky/messagecore)
- 💬 实时讨论: [Discord](https://discord.gg/goldsky)
- 📖 完整文档: [docs/](./docs/) 