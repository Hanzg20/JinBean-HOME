# 🚀 GoldSky MessageCore 构建指南

## 📋 快速开始

### 方式一：一键构建（推荐）

```bash
# 克隆项目
git clone <your-repo-url>
cd messagecore

# 运行快速构建脚本
./scripts/quick-build.sh
```

### 方式二：完整构建

```bash
# 运行完整构建脚本（更多选项）
./scripts/build-platform.sh

# 查看帮助
./scripts/build-platform.sh --help
```

### 方式三：手动构建

```bash
# 1. 环境检查
node --version  # 需要 >= 18.0.0
npm --version   # 需要 >= 8.0.0

# 2. 安装依赖
npm install

# 3. 启动数据库（需要Docker）
docker run -d --name messagecore-postgres \
  -e POSTGRES_DB=messagecore \
  -e POSTGRES_USER=messagecore \
  -e POSTGRES_PASSWORD=changeme \
  -p 5432:5432 postgres:15

docker run -d --name messagecore-redis \
  -p 6379:6379 redis:7-alpine

# 4. 初始化数据库
cd packages/db
npx prisma generate
npx prisma migrate dev --name init
cd ../..

# 5. 构建项目
npm run build

# 6. 启动服务
./start.sh
```

## 🌐 服务地址

构建完成后，访问以下地址：

- **API服务**: http://localhost:3000
- **实时服务**: http://localhost:3001
- **管理后台**: http://localhost:3002
- **API文档**: http://localhost:3000/docs

## 📋 构建选项

### 环境选择

```bash
# 开发环境
./scripts/build-platform.sh -e development

# 生产环境
./scripts/build-platform.sh -e production
```

### 数据库选择

```bash
# 本地PostgreSQL (需要Docker)
./scripts/build-platform.sh -d local

# Supabase
./scripts/build-platform.sh -d supabase

# Azure
./scripts/build-platform.sh -d azure
```

### 其他选项

```bash
# 跳过依赖安装
./scripts/build-platform.sh -s

# 清理构建缓存
./scripts/build-platform.sh -c

# 运行测试
./scripts/build-platform.sh -t
```

## 🐳 Docker部署

```bash
# 使用Docker Compose
docker-compose up -d

# 或构建镜像
docker build -t messagecore/api -f infrastructure/docker/api.Dockerfile .
docker build -t messagecore/realtime -f infrastructure/docker/realtime.Dockerfile .
docker build -t messagecore/admin -f infrastructure/docker/admin.Dockerfile .
```

## 🔧 配置说明

### 环境变量

主要配置在 `.env` 文件中：

```bash
# 数据库配置
DATABASE_URL="postgresql://messagecore:changeme@localhost:5432/messagecore"

# Redis配置
REDIS_URL="redis://localhost:6379"

# JWT密钥
JWT_SECRET="your-super-secret-jwt-key-change-in-production"
```

### 数据库配置

| 类型 | 说明 | 配置 |
|------|------|------|
| 本地 | 使用Docker | 自动配置 |
| Supabase | 云数据库 | 手动配置连接字符串 |
| Azure | 企业级 | 运行 `./scripts/azure-migration-prep.sh` |

## 🐛 常见问题

### 端口被占用

```bash
# 检查端口占用
lsof -i :3000

# 停止占用进程
kill -9 <PID>
```

### 数据库连接失败

```bash
# 检查数据库状态
docker ps | grep postgres

# 重启数据库
docker restart messagecore-postgres
```

### 依赖安装失败

```bash
# 清理缓存
npm cache clean --force

# 重新安装
rm -rf node_modules package-lock.json
npm install
```

## 📚 更多文档

- [详细构建说明](docs/build-instructions.md)
- [Azure迁移策略](docs/azure_migration_strategy.md)
- [产品构建指南](docs/messagecore_build_guide.md)
- [开源集成方案](docs/messagecore_opensource_integration.md)

## 🆘 获取帮助

- 📧 技术问题: [GitHub Issues](https://github.com/goldsky/messagecore)
- 💬 实时讨论: [Discord](https://discord.gg/goldsky)
- 📖 完整文档: [docs/](./docs/)

---

**✨ 5分钟内完成构建，开始使用GoldSky MessageCore！** 