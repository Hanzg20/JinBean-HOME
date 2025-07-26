#!/bin/bash

# GoldSky MessageCore 快速启动脚本
# 基于 Feathers.js 的开源项目改造

set -e

echo "🚀 GoldSky MessageCore 快速启动脚本"
echo "基于 Feathers.js 开源项目改造"
echo "=================================="

# 检查Node.js环境
if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未安装，请先安装 Node.js (推荐版本 18+)"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "❌ Git 未安装，请先安装 Git"
    exit 1
fi

echo "✅ 环境检查通过"

# 创建MessageCore工作目录
echo "📁 创建项目目录..."
mkdir -p messagecore-project
cd messagecore-project

# 1. 克隆Feathers.js聊天基础项目
echo "📦 克隆 Feathers.js 聊天基础项目..."
if [ ! -d "backend" ]; then
    git clone https://github.com/feathersjs/feathers-chat.git backend
    echo "✅ 基础项目克隆完成"
else
    echo "⚠️  后端项目已存在，跳过克隆"
fi

cd backend

# 2. 安装基础依赖
echo "📚 安装项目依赖..."
npm install

# 3. 安装MessageCore所需的额外依赖
echo "📦 安装MessageCore扩展依赖..."
npm install @prisma/client prisma redis ioredis uuid express-rate-limit helmet cors

# 安装开发依赖
npm install -D @types/uuid nodemon concurrently

echo "✅ 依赖安装完成"

# 4. 初始化Prisma数据库
echo "🗄️  初始化数据库配置..."
if [ ! -f "prisma/schema.prisma" ]; then
    npx prisma init
fi

# 5. 创建MessageCore配置文件
echo "⚙️  创建配置文件..."

# 创建环境变量文件
cat > .env << EOL
# GoldSky MessageCore Environment Configuration

# Database (初期使用Supabase，后续迁移到Azure)
DATABASE_URL="postgresql://messagecore:changeme@localhost:5432/messagecore"

# Redis
REDIS_URL="redis://localhost:6379"

# JWT Secret
JWT_SECRET="your-super-secret-jwt-key-change-in-production"

# App Configuration
PORT=3030
NODE_ENV=development

# MessageCore Specific
DEFAULT_PLAN_TYPE=basic
ENABLE_RATE_LIMITING=true

# Azure Configuration (为后续迁移准备)
# AZURE_DATABASE_URL="postgresql://username:password@azure-postgresql-server.postgres.database.azure.com:5432/messagecore"
# AZURE_STORAGE_CONNECTION_STRING="DefaultEndpointsProtocol=https;AccountName=messagecore;AccountKey=your-key;EndpointSuffix=core.windows.net"
# AZURE_SIGNALR_CONNECTION_STRING="Endpoint=https://messagecore.service.signalr.net;AccessKey=your-key;Version=1.0;"
# AZURE_CLIENT_ID="your-azure-client-id"
# AZURE_TENANT="your-azure-tenant"

# Migration Configuration
MIGRATION_MODE="supabase"  # supabase | azure | hybrid
EOL

# 创建Prisma Schema
cat > prisma/schema.prisma << EOL
// GoldSky MessageCore Database Schema
// 基于 Feathers.js 扩展的多租户消息系统

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Tenant {
  id        String   @id @default(uuid())
  name      String
  subdomain String   @unique
  apiKey    String   @unique @map("api_key")
  planType  String   @default("basic") @map("plan_type")
  settings  Json     @default("{}")
  status    String   @default("active")
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  users     User[]
  messages  Message[]

  @@map("tenants")
}

model User {
  id             String   @id @default(uuid())
  tenantId       String?  @map("tenant_id")
  externalUserId String?  @map("external_user_id")
  email          String   @unique
  displayName    String   @map("display_name")
  avatarUrl      String?  @map("avatar_url")
  isActive       Boolean  @default(true) @map("is_active")
  createdAt      DateTime @default(now()) @map("created_at")

  tenant   Tenant?   @relation(fields: [tenantId], references: [id])
  messages Message[]

  @@unique([tenantId, externalUserId])
  @@map("users")
}

model Message {
  id             String   @id @default(uuid())
  tenantId       String?  @map("tenant_id")
  conversationId String   @map("conversation_id")
  senderId       String   @map("sender_id")
  messageType    String   @default("text") @map("message_type")
  content        Json
  replyToId      String?  @map("reply_to_id")
  status         String   @default("sent")
  createdAt      DateTime @default(now()) @map("created_at")
  updatedAt      DateTime @updatedAt @map("updated_at")

  tenant Tenant? @relation(fields: [tenantId], references: [id])
  sender User    @relation(fields: [senderId], references: [id])

  @@index([tenantId, conversationId, createdAt])
  @@map("messages")
}
EOL

echo "✅ 配置文件创建完成"

# 6. 创建MessageCore核心文件
echo "🔧 创建MessageCore核心功能..."

# 创建多租户Hook
mkdir -p src/hooks
cat > src/hooks/multi-tenant.js << 'EOL'
// GoldSky MessageCore Multi-tenant Hook
// 为所有服务添加多租户支持

const { NotAuthenticated, Forbidden } = require('@feathersjs/errors');

const multiTenant = () => {
  return async (context) => {
    const { app, params, method } = context;
    
    // 跳过内部调用
    if (params.provider === undefined) {
      return context;
    }

    // 获取API Key
    const apiKey = params.headers['x-api-key'];
    if (!apiKey) {
      throw new NotAuthenticated('API key is required');
    }

    // 验证租户
    try {
      const tenants = await app.service('tenants').find({
        query: { apiKey: apiKey },
        paginate: false
      });

      if (!tenants || tenants.length === 0) {
        throw new NotAuthenticated('Invalid API key');
      }

      const tenant = tenants[0];
      
      if (tenant.status !== 'active') {
        throw new Forbidden('Tenant is not active');
      }

      // 设置租户上下文
      params.tenant = tenant;

      // 自动添加租户过滤
      if (method === 'find' || method === 'get') {
        context.params.query = context.params.query || {};
        context.params.query.tenantId = tenant.id;
      }

      if (method === 'create') {
        if (Array.isArray(context.data)) {
          context.data.forEach(item => item.tenantId = tenant.id);
        } else {
          context.data.tenantId = tenant.id;
        }
      }

    } catch (error) {
      throw new NotAuthenticated('Tenant validation failed: ' + error.message);
    }

    return context;
  };
};

module.exports = multiTenant;
EOL

# 创建配额检查Hook
cat > src/hooks/quota-check.js << 'EOL'
// GoldSky MessageCore Quota Management Hook
// 检查租户消息配额

const Redis = require('ioredis');
const { TooManyRequests } = require('@feathersjs/errors');

let redis;

const quotaCheck = () => {
  return async (context) => {
    const { params } = context;
    
    if (!params.tenant) {
      return context;
    }

    try {
      // 初始化Redis连接
      if (!redis) {
        redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6379');
      }

      const tenant = params.tenant;
      const maxMessages = tenant.settings.maxMessages || 10000;
      
      // 检查当月配额
      const currentMonth = new Date().toISOString().slice(0, 7);
      const key = \`quota:messages:\${tenant.id}:\${currentMonth}\`;
      
      const currentCount = await redis.get(key) || 0;
      
      if (parseInt(currentCount) >= maxMessages) {
        throw new TooManyRequests('Message quota exceeded for this month');
      }
      
      // 增加计数
      await redis.incr(key);
      await redis.expire(key, 60 * 60 * 24 * 32); // 32天过期
      
    } catch (error) {
      if (error instanceof TooManyRequests) {
        throw error;
      }
      console.warn('Quota check failed:', error.message);
    }

    return context;
  };
};

module.exports = quotaCheck;
EOL

# 创建租户服务
mkdir -p src/services/tenants
cat > src/services/tenants/tenants.service.js << 'EOL'
// GoldSky MessageCore Tenant Service
// 租户管理服务

const { Service } = require('feathers-memory');
const { v4: uuidv4 } = require('uuid');

class TenantsService extends Service {
  constructor(options, app) {
    super(options, app);
    this.app = app;
  }

  async create(data, params) {
    const apiKey = this.generateApiKey();
    
    const tenantData = {
      id: uuidv4(),
      name: data.name,
      subdomain: data.subdomain,
      apiKey,
      planType: data.planType || 'basic',
      settings: {
        maxUsers: this.getMaxUsers(data.planType),
        maxMessages: this.getMaxMessages(data.planType),
        retentionDays: this.getRetentionDays(data.planType),
        ...data.settings
      },
      status: 'active',
      createdAt: new Date(),
      updatedAt: new Date()
    };

    return await super.create(tenantData, params);
  }

  generateApiKey() {
    return 'mc_' + uuidv4().replace(/-/g, '');
  }

  getMaxUsers(planType = 'basic') {
    const limits = {
      basic: 100,
      pro: 1000,
      enterprise: 10000,
    };
    return limits[planType] || limits.basic;
  }

  getMaxMessages(planType = 'basic') {
    const limits = {
      basic: 10000,
      pro: 100000,
      enterprise: 1000000,
    };
    return limits[planType] || limits.basic;
  }

  getRetentionDays(planType = 'basic') {
    const limits = {
      basic: 30,
      pro: 90,
      enterprise: 365,
    };
    return limits[planType] || limits.basic;
  }
}

module.exports = function (app) {
  const options = {
    paginate: app.get('paginate')
  };

  app.use('/tenants', new TenantsService(options, app));

  const service = app.service('tenants');

  service.hooks({
    before: {
      all: [],
      find: [],
      get: [],
      create: [],
      update: [],
      patch: [],
      remove: []
    },

    after: {
      all: [],
      find: [],
      get: [],
      create: [],
      update: [],
      patch: [],
      remove: []
    },

    error: {
      all: [],
      find: [],
      get: [],
      create: [],
      update: [],
      patch: [],
      remove: []
    }
  });
};
EOL

# 创建API v1服务
mkdir -p src/services/api/v1
cat > src/services/api/v1/messages.service.js << 'EOL'
// GoldSky MessageCore API v1 Messages Service
// 标准化消息API接口

const { Service } = require('feathers-memory');

class MessagesAPIService extends Service {
  constructor(options, app) {
    super(options, app);
    this.app = app;
  }

  async create(data, params) {
    // 标准化输入格式
    const messageData = {
      conversationId: data.conversationId,
      senderId: data.senderId,
      messageType: data.type || 'text',
      content: data.content,
      replyToId: data.replyToId
    };

    // 调用原始消息服务
    const message = await this.app.service('messages').create(messageData, params);

    return {
      success: true,
      data: message
    };
  }

  async find(params) {
    const { conversationId, page = 1, limit = 50, before } = params.query || {};
    
    const query = {
      conversationId,
      ...(before && { createdAt: { $lt: before } })
    };

    const result = await this.app.service('messages').find({
      ...params,
      query,
      paginate: {
        default: parseInt(limit),
        max: 100
      }
    });

    // 标准化输出格式
    return {
      success: true,
      data: {
        messages: result.data || result,
        pagination: result.total ? {
          page: parseInt(page),
          limit: parseInt(limit),
          total: result.total,
          hasMore: (page * limit) < result.total
        } : undefined
      }
    };
  }
}

module.exports = function (app) {
  const options = {
    paginate: app.get('paginate')
  };

  app.use('/api/v1/messages', new MessagesAPIService(options, app));

  const service = app.service('api/v1/messages');
  const multiTenant = require('../../../hooks/multi-tenant');
  const quotaCheck = require('../../../hooks/quota-check');

  service.hooks({
    before: {
      all: [multiTenant()],
      find: [],
      get: [],
      create: [quotaCheck()],
      update: [],
      patch: [],
      remove: []
    },

    after: {
      all: [],
      find: [],
      get: [],
      create: [],
      update: [],
      patch: [],
      remove: []
    }
  });
};
EOL

echo "✅ MessageCore核心功能创建完成"

# 7. 修改应用配置
echo "⚙️  配置应用..."

# 备份原始文件
cp src/app.js src/app.js.backup

# 在app.js中注册新服务
cat >> src/app.js << 'EOL'

// GoldSky MessageCore Services
app.configure(require('./services/tenants/tenants.service'));
app.configure(require('./services/api/v1/messages.service'));
EOL

# 8. 创建启动脚本
cat > package.json.new << 'EOL'
{
  "name": "goldsky-messagecore-backend",
  "description": "GoldSky MessageCore Backend - Multi-tenant Chat API based on Feathers.js",
  "version": "0.1.0",
  "homepage": "",
  "main": "src",
  "keywords": [
    "feathers",
    "goldsky",
    "messagecore",
    "chat",
    "multi-tenant"
  ],
  "author": {
    "name": "GoldSky Team",
    "email": "team@goldsky.com"
  },
  "contributors": [],
  "bugs": {},
  "directories": {
    "lib": "src",
    "test": "test/"
  },
  "engines": {
    "node": "^18.0.0",
    "npm": ">= 8.0.0"
  },
  "scripts": {
    "test": "npm run eslint && npm run mocha",
    "eslint": "eslint src/. test/. --config .eslintrc.json",
    "dev": "nodemon src/",
    "start": "node src/",
    "mocha": "mocha test/ --recursive --exit",
    "db:generate": "npx prisma generate",
    "db:push": "npx prisma db push",
    "db:migrate": "npx prisma migrate dev",
    "setup": "npm run db:generate && npm run db:push"
  }
}
EOL

# 合并package.json（保留原有依赖）
node -e "
const fs = require('fs');
const original = JSON.parse(fs.readFileSync('package.json', 'utf8'));
const updated = JSON.parse(fs.readFileSync('package.json.new', 'utf8'));
const merged = { ...original, ...updated, dependencies: { ...original.dependencies, ...updated.dependencies } };
fs.writeFileSync('package.json', JSON.stringify(merged, null, 2));
fs.unlinkSync('package.json.new');
"

echo "✅ 应用配置完成"

# 9. 创建示例测试
echo "🧪 创建示例测试..."
mkdir -p test
cat > test/messagecore.test.js << 'EOL'
// GoldSky MessageCore Integration Tests

const assert = require('assert');
const axios = require('axios');

const API_BASE = 'http://localhost:3030';

describe('GoldSky MessageCore API 测试', () => {
  let apiKey;
  let tenantId;

  before(async function() {
    this.timeout(10000);
    
    // 等待服务启动
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    try {
      // 创建测试租户
      const response = await axios.post(\`\${API_BASE}/tenants\`, {
        name: '测试公司',
        subdomain: 'test-company',
        planType: 'basic'
      });
      
      apiKey = response.data.apiKey;
      tenantId = response.data.id;
      console.log('✅ 测试租户创建成功:', { tenantId, apiKey });
    } catch (error) {
      console.error('❌ 测试租户创建失败:', error.message);
      throw error;
    }
  });

  it('应该能够发送消息', async function() {
    this.timeout(5000);
    
    const messageData = {
      conversationId: 'conv-test-123',
      senderId: 'user-test-456',
      type: 'text',
      content: { text: 'Hello MessageCore! 🚀' }
    };

    const response = await axios.post(
      \`\${API_BASE}/api/v1/messages\`,
      messageData,
      {
        headers: { 'X-API-Key': apiKey }
      }
    );

    assert.equal(response.data.success, true);
    assert.equal(response.data.data.content.text, 'Hello MessageCore! 🚀');
    console.log('✅ 消息发送测试通过');
  });

  it('应该能够获取消息列表', async function() {
    this.timeout(5000);
    
    const response = await axios.get(
      \`\${API_BASE}/api/v1/messages?conversationId=conv-test-123\`,
      {
        headers: { 'X-API-Key': apiKey }
      }
    );

    assert.equal(response.data.success, true);
    assert(Array.isArray(response.data.data.messages));
    console.log('✅ 消息获取测试通过');
  });
});
EOL

echo "✅ 测试文件创建完成"

# 10. 创建README文档
cat > README.md << 'EOL'
# GoldSky MessageCore Backend

基于 Feathers.js 的多租户即时通讯系统后端

## 🚀 快速开始

### 前置要求
- Node.js 18+
- PostgreSQL
- Redis

### 安装和启动

1. 安装依赖：
   ```bash
   npm install
   ```

2. 配置环境变量：
   ```bash
   cp .env.example .env
   # 编辑 .env 文件，配置数据库和Redis连接
   ```

3. 初始化数据库：
   ```bash
   npm run setup
   ```

4. 启动开发服务器：
   ```bash
   npm run dev
   ```

## 📚 API 文档

### 创建租户
```bash
curl -X POST http://localhost:3030/tenants \
  -H "Content-Type: application/json" \
  -d '{
    "name": "我的公司",
    "subdomain": "my-company",
    "planType": "basic"
  }'
```

### 发送消息
```bash
curl -X POST http://localhost:3030/api/v1/messages \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key" \
  -d '{
    "conversationId": "conv-123",
    "senderId": "user-456",
    "type": "text",
    "content": {"text": "Hello World!"}
  }'
```

### 获取消息
```bash
curl "http://localhost:3030/api/v1/messages?conversationId=conv-123" \
  -H "X-API-Key: your-api-key"
```

## 🧪 运行测试

```bash
npm test
```

## 🐳 Docker 部署

```bash
docker-compose up -d
```

## 📖 更多文档

- [API 参考](./docs/api.md)
- [部署指南](./docs/deployment.md)
- [开发指南](./docs/development.md)
EOL

echo "✅ README文档创建完成"

# 11. 创建Docker配置
echo "🐳 创建Docker配置..."

cat > Dockerfile << 'EOL'
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Generate Prisma client
RUN npx prisma generate

EXPOSE 3030

CMD ["npm", "start"]
EOL

cat > docker-compose.yml << 'EOL'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: messagecore
      POSTGRES_USER: messagecore
      POSTGRES_PASSWORD: changeme
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U messagecore -d messagecore"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  messagecore-api:
    build: .
    environment:
      DATABASE_URL: postgresql://messagecore:changeme@postgres:5432/messagecore
      REDIS_URL: redis://redis:6379
      PORT: 3030
      NODE_ENV: production
    ports:
      - "3030:3030"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
EOL

cat > .dockerignore << 'EOL'
node_modules
npm-debug.log
.env
.git
.gitignore
README.md
Dockerfile
.dockerignore
EOL

echo "✅ Docker配置创建完成"

echo ""
echo "🎉 GoldSky MessageCore 基础项目搭建完成！"
echo ""
echo "📋 下一步操作："
echo "1. 启动数据库服务："
echo "   docker-compose up -d postgres redis"
echo ""
echo "2. 初始化数据库："
echo "   npm run setup"
echo ""
echo "3. 启动开发服务器："
echo "   npm run dev"
echo ""
echo "4. 测试API："
echo "   npm test"
echo ""
echo "🌐 服务地址："
echo "   - API服务: http://localhost:3030"
echo "   - 数据库: postgresql://messagecore:changeme@localhost:5432/messagecore"
echo "   - Redis: redis://localhost:6379"
echo ""
echo "📚 快速测试："
echo "1. 创建租户: curl -X POST http://localhost:3030/tenants -H 'Content-Type: application/json' -d '{\"name\":\"测试公司\",\"subdomain\":\"test\"}'"
echo "2. 使用返回的API Key发送消息"
echo ""
echo "✨ GoldSky MessageCore 已准备就绪！" 