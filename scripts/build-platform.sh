#!/bin/bash

# GoldSky MessageCore 平台构建脚本
# 适用于其他机器快速构建和部署

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "$1 未安装，请先安装 $1"
        return 1
    fi
    return 0
}

# 检查端口是否被占用
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null ; then
        log_warning "端口 $1 已被占用"
        return 1
    fi
    return 0
}

# 显示帮助信息
show_help() {
    echo "GoldSky MessageCore 平台构建脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help              显示此帮助信息"
    echo "  -e, --env <环境>        指定环境 (development|production) [默认: development]"
    echo "  -d, --database <类型>   指定数据库类型 (local|supabase|azure) [默认: local]"
    echo "  -s, --skip-deps         跳过依赖安装"
    echo "  -c, --clean             清理构建缓存"
    echo "  -t, --test              运行测试"
    echo ""
    echo "示例:"
    echo "  $0                        # 开发环境构建"
    echo "  $0 -e production          # 生产环境构建"
    echo "  $0 -d supabase            # 使用Supabase数据库"
    echo "  $0 -c -t                  # 清理缓存并运行测试"
}

# 默认参数
ENVIRONMENT="development"
DATABASE_TYPE="local"
SKIP_DEPS=false
CLEAN_BUILD=false
RUN_TESTS=false

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -e|--env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -d|--database)
            DATABASE_TYPE="$2"
            shift 2
            ;;
        -s|--skip-deps)
            SKIP_DEPS=true
            shift
            ;;
        -c|--clean)
            CLEAN_BUILD=true
            shift
            ;;
        -t|--test)
            RUN_TESTS=true
            shift
            ;;
        *)
            log_error "未知参数: $1"
            show_help
            exit 1
            ;;
    esac
done

log_info "开始构建 GoldSky MessageCore 平台"
log_info "环境: $ENVIRONMENT"
log_info "数据库: $DATABASE_TYPE"

# 1. 环境检查
log_info "步骤 1: 环境检查"

check_command "node" || exit 1
check_command "npm" || exit 1
check_command "git" || exit 1

# 检查Node.js版本
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    log_error "Node.js版本过低，需要18.0.0或更高版本"
    exit 1
fi

log_success "Node.js版本检查通过: $(node -v)"

# 检查端口
check_port 3000 || log_warning "API服务端口3000被占用"
check_port 3001 || log_warning "实时服务端口3001被占用"
check_port 5432 || log_warning "PostgreSQL端口5432被占用"
check_port 6379 || log_warning "Redis端口6379被占用"

# 2. 项目结构检查
log_info "步骤 2: 项目结构检查"

if [ ! -f "package.json" ]; then
    log_error "未找到package.json，请确保在项目根目录运行此脚本"
    exit 1
fi

# 创建必要的目录
mkdir -p apps/api
mkdir -p apps/realtime
mkdir -p apps/admin
mkdir -p packages/shared
mkdir -p packages/sdk-js
mkdir -p packages/sdk-flutter
mkdir -p infrastructure/docker
mkdir -p infrastructure/k8s
mkdir -p docs
mkdir -p scripts

log_success "项目结构检查完成"

# 3. 清理构建缓存（如果需要）
if [ "$CLEAN_BUILD" = true ]; then
    log_info "步骤 3: 清理构建缓存"
    
    rm -rf node_modules
    rm -rf apps/*/node_modules
    rm -rf packages/*/node_modules
    rm -rf dist
    rm -rf build
    rm -rf .next
    rm -rf coverage
    
    log_success "构建缓存清理完成"
fi

# 4. 安装依赖
if [ "$SKIP_DEPS" = false ]; then
    log_info "步骤 4: 安装依赖"
    
    # 安装根目录依赖
    npm install
    
    # 安装各个包的依赖
    for dir in apps/* packages/*; do
        if [ -f "$dir/package.json" ]; then
            log_info "安装 $dir 依赖..."
            (cd "$dir" && npm install)
        fi
    done
    
    log_success "依赖安装完成"
else
    log_warning "跳过依赖安装"
fi

# 5. 环境配置
log_info "步骤 5: 环境配置"

# 创建环境变量文件
if [ ! -f ".env" ]; then
    log_info "创建环境变量文件..."
    
    cat > .env << EOL
# GoldSky MessageCore Environment Configuration
# Generated on $(date)

# Environment
NODE_ENV=$ENVIRONMENT
PORT=3000

# Database Configuration
DATABASE_URL="postgresql://messagecore:changeme@localhost:5432/messagecore"

# Redis Configuration
REDIS_URL="redis://localhost:6379"

# JWT Configuration
JWT_SECRET="your-super-secret-jwt-key-change-in-production"

# MessageCore Configuration
DEFAULT_PLAN_TYPE=basic
ENABLE_RATE_LIMITING=true

# Migration Configuration
MIGRATION_MODE="supabase"

# Azure Configuration (为后续迁移准备)
# AZURE_DATABASE_URL="postgresql://username:password@azure-postgresql-server.postgres.database.azure.com:5432/messagecore"
# AZURE_STORAGE_CONNECTION_STRING="DefaultEndpointsProtocol=https;AccountName=messagecore;AccountKey=your-key;EndpointSuffix=core.windows.net"
# AZURE_SIGNALR_CONNECTION_STRING="Endpoint=https://messagecore.service.signalr.net;AccessKey=your-key;Version=1.0;"
# AZURE_CLIENT_ID="your-azure-client-id"
# AZURE_TENANT="your-azure-tenant"
EOL
    
    log_success "环境变量文件创建完成"
else
    log_info "环境变量文件已存在"
fi

# 6. 数据库配置
log_info "步骤 6: 数据库配置"

case $DATABASE_TYPE in
    "local")
        log_info "配置本地PostgreSQL数据库..."
        
        # 检查Docker是否运行
        if ! docker info > /dev/null 2>&1; then
            log_error "Docker未运行，请启动Docker"
            exit 1
        fi
        
        # 启动PostgreSQL容器
        if ! docker ps | grep -q "messagecore-postgres"; then
            log_info "启动PostgreSQL容器..."
            docker run -d \
                --name messagecore-postgres \
                -e POSTGRES_DB=messagecore \
                -e POSTGRES_USER=messagecore \
                -e POSTGRES_PASSWORD=changeme \
                -p 5432:5432 \
                postgres:15
            
            # 等待数据库启动
            log_info "等待数据库启动..."
            sleep 10
        else
            log_info "PostgreSQL容器已运行"
        fi
        
        # 启动Redis容器
        if ! docker ps | grep -q "messagecore-redis"; then
            log_info "启动Redis容器..."
            docker run -d \
                --name messagecore-redis \
                -p 6379:6379 \
                redis:7-alpine
        else
            log_info "Redis容器已运行"
        fi
        ;;
        
    "supabase")
        log_info "配置Supabase数据库..."
        log_warning "请手动配置Supabase环境变量"
        ;;
        
    "azure")
        log_info "配置Azure数据库..."
        log_warning "请运行 ./scripts/azure-migration-prep.sh 配置Azure环境"
        ;;
        
    *)
        log_error "不支持的数据库类型: $DATABASE_TYPE"
        exit 1
        ;;
esac

# 7. 数据库初始化
log_info "步骤 7: 数据库初始化"

# 检查Prisma是否安装
if [ -f "packages/db/package.json" ]; then
    log_info "初始化数据库架构..."
    
    cd packages/db
    
    # 生成Prisma客户端
    npx prisma generate
    
    # 运行数据库迁移
    npx prisma migrate deploy
    
    cd ../..
    
    log_success "数据库初始化完成"
else
    log_warning "未找到数据库包，跳过数据库初始化"
fi

# 8. 构建项目
log_info "步骤 8: 构建项目"

# 构建API服务
if [ -f "apps/api/package.json" ]; then
    log_info "构建API服务..."
    (cd apps/api && npm run build)
fi

# 构建实时服务
if [ -f "apps/realtime/package.json" ]; then
    log_info "构建实时服务..."
    (cd apps/realtime && npm run build)
fi

# 构建管理后台
if [ -f "apps/admin/package.json" ]; then
    log_info "构建管理后台..."
    (cd apps/admin && npm run build)
fi

# 构建SDK
if [ -f "packages/sdk-js/package.json" ]; then
    log_info "构建JavaScript SDK..."
    (cd packages/sdk-js && npm run build)
fi

log_success "项目构建完成"

# 9. 运行测试（如果需要）
if [ "$RUN_TESTS" = true ]; then
    log_info "步骤 9: 运行测试"
    
    # 运行API测试
    if [ -f "apps/api/package.json" ]; then
        log_info "运行API测试..."
        (cd apps/api && npm test)
    fi
    
    # 运行SDK测试
    if [ -f "packages/sdk-js/package.json" ]; then
        log_info "运行SDK测试..."
        (cd packages/sdk-js && npm test)
    fi
    
    log_success "测试完成"
fi

# 10. 创建启动脚本
log_info "步骤 10: 创建启动脚本"

cat > start-platform.sh << 'EOL'
#!/bin/bash

# GoldSky MessageCore 平台启动脚本

set -e

echo "🚀 启动 GoldSky MessageCore 平台..."

# 检查环境变量
if [ ! -f ".env" ]; then
    echo "❌ 未找到.env文件，请先运行构建脚本"
    exit 1
fi

# 启动数据库服务（如果使用本地数据库）
if docker ps | grep -q "messagecore-postgres"; then
    echo "✅ PostgreSQL 已运行"
else
    echo "📦 启动 PostgreSQL..."
    docker run -d \
        --name messagecore-postgres \
        -e POSTGRES_DB=messagecore \
        -e POSTGRES_USER=messagecore \
        -e POSTGRES_PASSWORD=changeme \
        -p 5432:5432 \
        postgres:15
fi

if docker ps | grep -q "messagecore-redis"; then
    echo "✅ Redis 已运行"
else
    echo "📦 启动 Redis..."
    docker run -d \
        --name messagecore-redis \
        -p 6379:6379 \
        redis:7-alpine
fi

# 等待数据库启动
echo "⏳ 等待数据库启动..."
sleep 5

# 启动API服务
echo "🌐 启动API服务..."
cd apps/api
npm start &
API_PID=$!
cd ../..

# 启动实时服务
echo "🔗 启动实时服务..."
cd apps/realtime
npm start &
REALTIME_PID=$!
cd ../..

# 启动管理后台
echo "📊 启动管理后台..."
cd apps/admin
npm start &
ADMIN_PID=$!
cd ../..

echo ""
echo "🎉 GoldSky MessageCore 平台启动完成！"
echo ""
echo "📋 服务地址："
echo "   API服务: http://localhost:3000"
echo "   实时服务: http://localhost:3001"
echo "   管理后台: http://localhost:3002"
echo ""
echo "📚 文档地址："
echo "   API文档: http://localhost:3000/docs"
echo "   SDK文档: http://localhost:3000/sdk"
echo ""
echo "🛑 停止服务: Ctrl+C"

# 等待用户中断
trap "echo '正在停止服务...'; kill $API_PID $REALTIME_PID $ADMIN_PID 2>/dev/null; exit" INT
wait
EOL

chmod +x start-platform.sh

# 11. 创建Docker Compose配置
log_info "步骤 11: 创建Docker Compose配置"

cat > docker-compose.yml << 'EOL'
version: '3.8'

services:
  postgres:
    image: postgres:15
    container_name: messagecore-postgres
    environment:
      POSTGRES_DB: messagecore
      POSTGRES_USER: messagecore
      POSTGRES_PASSWORD: changeme
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    container_name: messagecore-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped

  api:
    build:
      context: .
      dockerfile: infrastructure/docker/api.Dockerfile
    container_name: messagecore-api
    environment:
      DATABASE_URL: postgresql://messagecore:changeme@postgres:5432/messagecore
      REDIS_URL: redis://redis:6379
      JWT_SECRET: your-jwt-secret
      NODE_ENV: production
    ports:
      - "3000:3000"
    depends_on:
      - postgres
      - redis
    restart: unless-stopped

  realtime:
    build:
      context: .
      dockerfile: infrastructure/docker/realtime.Dockerfile
    container_name: messagecore-realtime
    environment:
      DATABASE_URL: postgresql://messagecore:changeme@postgres:5432/messagecore
      REDIS_URL: redis://redis:6379
      NODE_ENV: production
    ports:
      - "3001:3001"
    depends_on:
      - postgres
      - redis
    restart: unless-stopped

  admin:
    build:
      context: .
      dockerfile: infrastructure/docker/admin.Dockerfile
    container_name: messagecore-admin
    environment:
      REACT_APP_API_URL: http://localhost:3000
      REACT_APP_REALTIME_URL: http://localhost:3001
    ports:
      - "3002:3000"
    depends_on:
      - api
      - realtime
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
EOL

# 12. 创建README
log_info "步骤 12: 创建README"

cat > README_BUILD.md << 'EOL'
# GoldSky MessageCore 平台构建指南

## 🚀 快速开始

### 1. 环境要求

- Node.js 18.0.0 或更高版本
- npm 8.0.0 或更高版本
- Git
- Docker (可选，用于本地数据库)

### 2. 一键构建

```bash
# 克隆项目
git clone <your-repo-url>
cd messagecore

# 运行构建脚本
./scripts/build-platform.sh
```

### 3. 启动平台

```bash
# 使用启动脚本
./start-platform.sh

# 或使用Docker Compose
docker-compose up -d
```

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

## 🌐 服务地址

构建完成后，可以通过以下地址访问服务：

- **API服务**: http://localhost:3000
- **实时服务**: http://localhost:3001
- **管理后台**: http://localhost:3002
- **API文档**: http://localhost:3000/docs

## 🔧 配置说明

### 环境变量

主要配置项在 `.env` 文件中：

```bash
# 数据库配置
DATABASE_URL="postgresql://messagecore:changeme@localhost:5432/messagecore"

# Redis配置
REDIS_URL="redis://localhost:6379"

# JWT密钥
JWT_SECRET="your-super-secret-jwt-key-change-in-production"
```

### 数据库配置

#### 本地PostgreSQL
- 自动启动Docker容器
- 端口: 5432
- 数据库: messagecore
- 用户名: messagecore
- 密码: changeme

#### Supabase
1. 在Supabase控制台创建项目
2. 获取连接字符串
3. 更新 `.env` 文件中的 `DATABASE_URL`

#### Azure
1. 运行 `./scripts/azure-migration-prep.sh`
2. 按照提示配置Azure环境
3. 更新 `.env` 文件中的Azure配置

## 🐛 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   # 检查端口占用
   lsof -i :3000
   
   # 停止占用进程
   kill -9 <PID>
   ```

2. **数据库连接失败**
   ```bash
   # 检查数据库状态
   docker ps | grep postgres
   
   # 重启数据库
   docker restart messagecore-postgres
   ```

3. **依赖安装失败**
   ```bash
   # 清理缓存
   npm cache clean --force
   
   # 重新安装
   rm -rf node_modules package-lock.json
   npm install
   ```

### 日志查看

```bash
# API服务日志
tail -f apps/api/logs/app.log

# 实时服务日志
tail -f apps/realtime/logs/app.log

# Docker容器日志
docker logs messagecore-api
docker logs messagecore-realtime
```

## 📚 更多文档

- [API接口文档](docs/api-reference.md)
- [SDK使用指南](docs/sdk-guide.md)
- [部署指南](docs/deployment-guide.md)
- [Azure迁移策略](docs/azure_migration_strategy.md)

## 🆘 获取帮助

- 📧 技术问题: [GitHub Issues](https://github.com/goldsky/messagecore)
- 💬 实时讨论: [Discord](https://discord.gg/goldsky)
- 📖 完整文档: [docs/](./docs/)
EOL

# 13. 完成
log_success "🎉 GoldSky MessageCore 平台构建完成！"
echo ""
echo "📋 下一步操作："
echo "1. 启动平台:"
echo "   ./start-platform.sh"
echo ""
echo "2. 或使用Docker Compose:"
echo "   docker-compose up -d"
echo ""
echo "3. 查看构建说明:"
echo "   cat README_BUILD.md"
echo ""
echo "🌐 服务地址："
echo "   API服务: http://localhost:3000"
echo "   实时服务: http://localhost:3001"
echo "   管理后台: http://localhost:3002"
echo ""
echo "✨ 构建成功！现在可以开始使用GoldSky MessageCore了！" 