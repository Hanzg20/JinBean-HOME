#!/bin/bash

# GoldSky MessageCore 快速构建脚本
# 适用于其他机器快速部署

set -e

echo "🚀 GoldSky MessageCore 快速构建脚本"
echo "=================================="

# 检查基本环境
echo "📋 检查环境..."

# 检查Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未安装，请先安装 Node.js 18+"
    exit 1
fi

# 检查npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm 未安装，请先安装 npm"
    exit 1
fi

# 检查Docker
if ! command -v docker &> /dev/null; then
    echo "⚠️  Docker 未安装，将使用本地数据库"
    USE_DOCKER=false
else
    USE_DOCKER=true
fi

echo "✅ 环境检查通过"

# 创建项目结构
echo "📁 创建项目结构..."
mkdir -p apps/{api,realtime,admin}
mkdir -p packages/{shared,sdk-js,sdk-flutter,db}
mkdir -p infrastructure/{docker,k8s}
mkdir -p docs scripts

# 创建根目录package.json
if [ ! -f "package.json" ]; then
    echo "📦 创建根目录package.json..."
    cat > package.json << 'EOL'
{
  "name": "goldsky-messagecore",
  "version": "1.0.0",
  "description": "GoldSky MessageCore - Multi-tenant Chat Platform",
  "private": true,
  "workspaces": [
    "apps/*",
    "packages/*"
  ],
  "scripts": {
    "build": "npm run build --workspaces",
    "dev": "concurrently \"npm run dev:api\" \"npm run dev:realtime\" \"npm run dev:admin\"",
    "dev:api": "cd apps/api && npm run dev",
    "dev:realtime": "cd apps/realtime && npm run dev",
    "dev:admin": "cd apps/admin && npm run dev",
    "start": "concurrently \"npm run start:api\" \"npm run start:realtime\" \"npm run start:admin\"",
    "start:api": "cd apps/api && npm start",
    "start:realtime": "cd apps/realtime && npm start",
    "start:admin": "cd apps/admin && npm start",
    "test": "npm run test --workspaces",
    "clean": "rm -rf node_modules apps/*/node_modules packages/*/node_modules"
  },
  "devDependencies": {
    "concurrently": "^8.2.2"
  },
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=8.0.0"
  }
}
EOL
fi

# 创建环境变量文件
if [ ! -f ".env" ]; then
    echo "⚙️  创建环境变量文件..."
    cat > .env << 'EOL'
# GoldSky MessageCore Environment Configuration

# Environment
NODE_ENV=development
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
EOL
fi

# 创建API服务
echo "🌐 创建API服务..."
cat > apps/api/package.json << 'EOL'
{
  "name": "@goldsky/messagecore-api",
  "version": "1.0.0",
  "description": "GoldSky MessageCore API Service",
  "main": "dist/index.js",
  "scripts": {
    "dev": "nodemon src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "dotenv": "^16.3.1",
    "pg": "^8.11.3",
    "redis": "^4.6.10",
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3",
    "multer": "^1.4.5-lts.1",
    "socket.io": "^4.7.4"
  },
  "devDependencies": {
    "@types/express": "^4.17.21",
    "@types/cors": "^2.8.17",
    "@types/node": "^20.8.10",
    "@types/jsonwebtoken": "^9.0.5",
    "@types/bcryptjs": "^2.4.6",
    "@types/multer": "^1.4.11",
    "typescript": "^5.2.2",
    "nodemon": "^3.0.1",
    "ts-node": "^10.9.1",
    "jest": "^29.7.0",
    "@types/jest": "^29.5.8"
  }
}
EOL

# 创建实时服务
echo "🔗 创建实时服务..."
cat > apps/realtime/package.json << 'EOL'
{
  "name": "@goldsky/messagecore-realtime",
  "version": "1.0.0",
  "description": "GoldSky MessageCore Realtime Service",
  "main": "dist/index.js",
  "scripts": {
    "dev": "nodemon src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest"
  },
  "dependencies": {
    "socket.io": "^4.7.4",
    "redis": "^4.6.10",
    "dotenv": "^16.3.1",
    "pg": "^8.11.3"
  },
  "devDependencies": {
    "@types/node": "^20.8.10",
    "typescript": "^5.2.2",
    "nodemon": "^3.0.1",
    "ts-node": "^10.9.1",
    "jest": "^29.7.0",
    "@types/jest": "^29.5.8"
  }
}
EOL

# 创建管理后台
echo "📊 创建管理后台..."
cat > apps/admin/package.json << 'EOL'
{
  "name": "@goldsky/messagecore-admin",
  "version": "1.0.0",
  "description": "GoldSky MessageCore Admin Dashboard",
  "scripts": {
    "dev": "next dev -p 3002",
    "build": "next build",
    "start": "next start -p 3002",
    "test": "jest"
  },
  "dependencies": {
    "next": "^14.0.3",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "antd": "^5.12.8",
    "@ant-design/icons": "^5.2.6",
    "axios": "^1.6.2"
  },
  "devDependencies": {
    "@types/react": "^18.2.37",
    "@types/react-dom": "^18.2.15",
    "@types/node": "^20.8.10",
    "typescript": "^5.2.2",
    "jest": "^29.7.0",
    "@types/jest": "^29.5.8"
  }
}
EOL

# 创建共享包
echo "📦 创建共享包..."
cat > packages/shared/package.json << 'EOL'
{
  "name": "@goldsky/messagecore-shared",
  "version": "1.0.0",
  "description": "GoldSky MessageCore Shared Utilities",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "test": "jest"
  },
  "dependencies": {
    "uuid": "^9.0.1"
  },
  "devDependencies": {
    "@types/uuid": "^9.0.7",
    "@types/node": "^20.8.10",
    "typescript": "^5.2.2",
    "jest": "^29.7.0",
    "@types/jest": "^29.5.8"
  }
}
EOL

# 创建JavaScript SDK
echo "🔧 创建JavaScript SDK..."
cat > packages/sdk-js/package.json << 'EOL'
{
  "name": "@goldsky/messagecore-sdk-js",
  "version": "1.0.0",
  "description": "GoldSky MessageCore JavaScript SDK",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "test": "jest"
  },
  "dependencies": {
    "socket.io-client": "^4.7.4",
    "axios": "^1.6.2"
  },
  "devDependencies": {
    "@types/node": "^20.8.10",
    "typescript": "^5.2.2",
    "jest": "^29.7.0",
    "@types/jest": "^29.5.8"
  }
}
EOL

# 创建数据库包
echo "🗄️  创建数据库包..."
cat > packages/db/package.json << 'EOL'
{
  "name": "@goldsky/messagecore-db",
  "version": "1.0.0",
  "description": "GoldSky MessageCore Database Models",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "db:generate": "prisma generate",
    "db:migrate": "prisma migrate deploy",
    "db:studio": "prisma studio"
  },
  "dependencies": {
    "@prisma/client": "^5.6.0"
  },
  "devDependencies": {
    "prisma": "^5.6.0",
    "@types/node": "^20.8.10",
    "typescript": "^5.2.2"
  }
}
EOL

# 创建Prisma配置
echo "⚙️  创建Prisma配置..."
mkdir -p packages/db/prisma
cat > packages/db/prisma/schema.prisma << 'EOL'
// GoldSky MessageCore Database Schema
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Tenant {
  id        String   @id @default(cuid())
  name      String
  subdomain String   @unique
  apiKey    String   @unique
  planType  String   @default("basic")
  status    String   @default("active")
  settings  Json     @default("{}")
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  users          TenantUser[]
  conversations  Conversation[]
  messages       Message[]

  @@map("tenants")
}

model TenantUser {
  id             String   @id @default(cuid())
  tenantId       String
  externalUserId String
  displayName    String
  avatarUrl      String?
  metadata       Json     @default("{}")
  isActive       Boolean  @default(true)
  createdAt      DateTime @default(now())

  tenant Tenant @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  messages Message[]

  @@unique([tenantId, externalUserId])
  @@map("tenant_users")
}

model Conversation {
  id             String   @id @default(cuid())
  tenantId       String
  type           String
  title          String?
  participantIds String[]
  metadata       Json     @default("{}")
  createdAt      DateTime @default(now())
  updatedAt      DateTime @updatedAt
  lastMessageAt  DateTime?

  tenant   Tenant    @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  messages Message[]

  @@map("conversations")
}

model Message {
  id             String   @id @default(cuid())
  tenantId       String
  conversationId String
  senderId       String
  messageType    String
  content        Json
  replyToId      String?
  status         String   @default("sent")
  createdAt      DateTime @default(now())
  updatedAt      DateTime @updatedAt

  tenant       Tenant       @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  conversation Conversation @relation(fields: [conversationId], references: [id], onDelete: Cascade)
  sender       TenantUser   @relation(fields: [senderId], references: [id], onDelete: Cascade)
  replyTo      Message?     @relation("MessageReplies", fields: [replyToId], references: [id])
  replies      Message[]    @relation("MessageReplies")

  @@map("messages")
}
EOL

# 启动数据库（如果Docker可用）
if [ "$USE_DOCKER" = true ]; then
    echo "🐳 启动数据库服务..."
    
    # 启动PostgreSQL
    if ! docker ps | grep -q "messagecore-postgres"; then
        docker run -d \
            --name messagecore-postgres \
            -e POSTGRES_DB=messagecore \
            -e POSTGRES_USER=messagecore \
            -e POSTGRES_PASSWORD=changeme \
            -p 5432:5432 \
            postgres:15
        echo "✅ PostgreSQL 启动完成"
    else
        echo "✅ PostgreSQL 已运行"
    fi
    
    # 启动Redis
    if ! docker ps | grep -q "messagecore-redis"; then
        docker run -d \
            --name messagecore-redis \
            -p 6379:6379 \
            redis:7-alpine
        echo "✅ Redis 启动完成"
    else
        echo "✅ Redis 已运行"
    fi
    
    # 等待数据库启动
    echo "⏳ 等待数据库启动..."
    sleep 10
else
    echo "⚠️  请手动启动PostgreSQL和Redis服务"
fi

# 安装依赖
echo "📚 安装依赖..."
npm install

# 初始化数据库
echo "🗄️  初始化数据库..."
cd packages/db
npx prisma generate
npx prisma migrate dev --name init
cd ../..

# 构建项目
echo "🔨 构建项目..."
npm run build

# 创建启动脚本
echo "🚀 创建启动脚本..."
cat > start.sh << 'EOL'
#!/bin/bash

echo "🚀 启动 GoldSky MessageCore..."

# 检查数据库
if ! docker ps | grep -q "messagecore-postgres"; then
    echo "📦 启动 PostgreSQL..."
    docker run -d \
        --name messagecore-postgres \
        -e POSTGRES_DB=messagecore \
        -e POSTGRES_USER=messagecore \
        -e POSTGRES_PASSWORD=changeme \
        -p 5432:5432 \
        postgres:15
fi

if ! docker ps | grep -q "messagecore-redis"; then
    echo "📦 启动 Redis..."
    docker run -d \
        --name messagecore-redis \
        -p 6379:6379 \
        redis:7-alpine
fi

# 等待数据库启动
sleep 5

# 启动服务
echo "🌐 启动服务..."
npm start
EOL

chmod +x start.sh

# 创建Docker Compose配置
echo "🐳 创建Docker Compose配置..."
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

echo ""
echo "🎉 GoldSky MessageCore 快速构建完成！"
echo ""
echo "📋 下一步操作："
echo "1. 启动平台:"
echo "   ./start.sh"
echo ""
echo "2. 或使用Docker Compose:"
echo "   docker-compose up -d"
echo ""
echo "🌐 服务地址："
echo "   API服务: http://localhost:3000"
echo "   实时服务: http://localhost:3001"
echo "   管理后台: http://localhost:3002"
echo ""
echo "✨ 构建成功！现在可以开始使用GoldSky MessageCore了！" 