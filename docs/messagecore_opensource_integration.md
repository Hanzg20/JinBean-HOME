# GoldSky MessageCore开源项目集成改造方案

## 📋 目录
1. [开源项目调研](#1-开源项目调研)
2. [推荐方案](#2-推荐方案)
3. [改造规划](#3-改造规划)
4. [集成步骤](#4-集成步骤)
5. [快速启动](#5-快速启动)

## 1. 开源项目调研

### 1.1 后端消息服务推荐

#### 🥇 **Chatwoot** (Ruby on Rails)
```yaml
项目地址: https://github.com/chatwoot/chatwoot
Stars: 20.1k
语言: Ruby on Rails + Vue.js
许可证: MIT

优势:
  - 完整的客服系统
  - 支持多渠道 (Web, Email, WhatsApp等)
  - 良好的API设计
  - 活跃的社区
  - 支持多租户

劣势:
  - Ruby技术栈，团队需要学习成本
  - 功能过于复杂，需要大量裁剪
```

#### 🥈 **Rocket.Chat** (Node.js)
```yaml
项目地址: https://github.com/RocketChat/Rocket.Chat
Stars: 40k+
语言: Node.js + React
许可证: MIT

优势:
  - 企业级即时通讯
  - 支持实时消息
  - 完整的API
  - 插件系统
  - 支持多租户

劣势:
  - 功能庞大，需要大量定制
  - 架构复杂
```

#### 🥉 **Matrix Synapse** (Python)
```yaml
项目地址: https://github.com/matrix-org/synapse
Stars: 11.7k
语言: Python
许可证: Apache 2.0

优势:
  - 分布式架构
  - 端到端加密
  - 联邦协议
  - 强大的消息功能

劣势:
  - 协议复杂
  - 学习成本高
  - 过度设计
```

### 1.2 Node.js轻量级方案推荐

#### 🌟 **Socket.io Chat Example** + **Nest.js**
```yaml
基础项目:
  - Socket.io官方聊天示例
  - Nest.js + Socket.io集成
  
优势:
  - 轻量级，易于扩展
  - Node.js技术栈熟悉
  - 可控性强
  - 快速开发
```

#### 🌟 **Feathers.js Real-time Chat**
```yaml
项目地址: https://github.com/feathersjs/feathers-chat
Stars: 500+
语言: Node.js
许可证: MIT

优势:
  - 实时API框架
  - 自动生成RESTful + WebSocket API
  - 简洁的架构
  - 易于扩展多租户
```

### 1.3 前端SDK推荐

#### **Stream Chat SDK**
```yaml
项目地址: https://github.com/GetStream/stream-chat-js
语言: TypeScript
许可证: 商业友好

优势:
  - 成熟的聊天SDK
  - 支持React/Flutter/JavaScript
  - 完整的UI组件
  - 可以参考API设计
```

## 2. 推荐方案

### 2.1 最佳方案：Feathers.js + 定制改造

```mermaid
graph TB
    subgraph "开源基础"
        A[Feathers.js Core]
        B[Socket.io Integration]
        C[Authentication]
        D[Database ORM]
    end
    
    subgraph "我们的改造"
        E[多租户系统]
        F[配额管理]
        G[消息路由]
        H[文件服务]
        I[管理后台]
    end
    
    subgraph "SDK开发"
        J[JavaScript SDK]
        K[Flutter SDK]
        L[React Components]
    end
    
    A --> E
    B --> G
    C --> E
    D --> F
    
    E --> J
    F --> K
    G --> L
```

### 2.2 技术架构

```yaml
核心框架: Feathers.js (Node.js)
数据库: PostgreSQL + Prisma ORM
实时通信: Socket.io
认证: JWT + Passport
缓存: Redis
文件存储: AWS S3 / 本地存储
前端: React + TypeScript
移动端: Flutter SDK
```

### 2.3 开发优势

```yaml
时间节省:
  - 基础实时通信: 70%时间节省
  - 认证系统: 60%时间节省
  - RESTful API: 80%时间节省
  - WebSocket处理: 90%时间节省

总体开发时间:
  - 原计划16周 → 优化后8-10周
  - 人力成本降低50%
```

## 3. 改造规划

### 3.1 Phase 1: 基础项目搭建 (1周)

```bash
# 1. 克隆Feathers.js聊天示例
git clone https://github.com/feathersjs/feathers-chat.git messagecore
cd messagecore

# 2. 安装依赖并启动
npm install
npm start

# 3. 分析现有架构
# - 查看src/目录结构
# - 理解services/hooks机制
# - 分析客户端连接方式
```

**改造重点:**
- 理解Feathers.js架构
- 分析消息流程
- 规划多租户改造方案

### 3.2 Phase 2: 多租户架构改造 (2周)

#### 3.2.1 数据库Schema改造

```sql
-- 添加租户表
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    api_key VARCHAR(255) UNIQUE NOT NULL,
    plan_type VARCHAR(50) DEFAULT 'basic',
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 修改现有用户表
ALTER TABLE users ADD COLUMN tenant_id UUID REFERENCES tenants(id);
ALTER TABLE users ADD COLUMN external_user_id VARCHAR(255);
ALTER TABLE users ADD UNIQUE(tenant_id, external_user_id);

-- 修改消息表
ALTER TABLE messages ADD COLUMN tenant_id UUID REFERENCES tenants(id);

-- 添加索引
CREATE INDEX idx_messages_tenant ON messages(tenant_id, created_at DESC);
```

#### 3.2.2 Feathers.js Hook改造

```javascript
// src/hooks/multi-tenant.js
const multiTenant = () => {
  return async (context) => {
    // API Key验证
    const apiKey = context.params.headers['x-api-key'];
    if (!apiKey) {
      throw new Error('API key required');
    }

    // 获取租户信息
    const tenant = await context.app.service('tenants').find({
      query: { api_key: apiKey }
    });

    if (!tenant.data.length) {
      throw new Error('Invalid API key');
    }

    // 设置租户上下文
    context.params.tenant = tenant.data[0];
    
    // 自动添加tenant_id过滤
    if (context.method === 'find' || context.method === 'get') {
      context.params.query.tenant_id = tenant.data[0].id;
    }
    
    if (context.method === 'create') {
      context.data.tenant_id = tenant.data[0].id;
    }

    return context;
  };
};

module.exports = multiTenant;
```

#### 3.2.3 服务改造

```javascript
// src/services/messages/messages.hooks.js
const multiTenant = require('../../hooks/multi-tenant');
const quotaCheck = require('../../hooks/quota-check');

module.exports = {
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
    create: [broadcastMessage()],
    update: [],
    patch: [],
    remove: []
  }
};
```

### 3.3 Phase 3: 配额管理系统 (1周)

```javascript
// src/hooks/quota-check.js
const Redis = require('redis');
const redis = Redis.createClient(process.env.REDIS_URL);

const quotaCheck = () => {
  return async (context) => {
    const tenant = context.params.tenant;
    const maxMessages = tenant.settings.maxMessages || 10000;
    
    // 检查当月配额
    const currentMonth = new Date().toISOString().slice(0, 7);
    const key = `quota:messages:${tenant.id}:${currentMonth}`;
    
    const currentCount = await redis.get(key) || 0;
    
    if (parseInt(currentCount) >= maxMessages) {
      throw new Error('Message quota exceeded');
    }
    
    // 增加计数
    await redis.incr(key);
    await redis.expire(key, 60 * 60 * 24 * 32); // 32天过期
    
    return context;
  };
};

module.exports = quotaCheck;
```

### 3.4 Phase 4: API标准化 (1周)

```javascript
// src/services/api/v1/messages.js
const { Service } = require('feathers-memory');

class MessagesAPIService extends Service {
  async create(data, params) {
    // 标准化输入格式
    const message = {
      conversationId: data.conversationId,
      senderId: data.senderId,
      type: data.type,
      content: data.content,
      replyToId: data.replyToId
    };

    // 调用原始消息服务
    return await this.app.service('messages').create(message, params);
  }

  async find(params) {
    const { conversationId, page = 1, limit = 50, before } = params.query;
    
    const query = {
      conversationId,
      ...(before && { createdAt: { $lt: before } })
    };

    const result = await this.app.service('messages').find({
      ...params,
      query,
      paginate: {
        default: limit,
        max: 100
      }
    });

    // 标准化输出格式
    return {
      success: true,
      data: {
        messages: result.data,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: result.total,
          hasMore: (page * limit) < result.total
        }
      }
    };
  }
}

module.exports = MessagesAPIService;
```

### 3.5 Phase 5: SDK开发 (2周)

#### 3.5.1 JavaScript SDK

```typescript
// packages/sdk-js/src/messagecore-sdk.ts
import io from 'socket.io-client';

export class MessageCoreSDK {
  private apiKey: string;
  private baseUrl: string;
  private socket: any;

  constructor(config: { apiKey: string; baseUrl?: string }) {
    this.apiKey = config.apiKey;
    this.baseUrl = config.baseUrl || 'https://api.messagecore.goldsky.com';
  }

  // 基于Feathers.js客户端改造
  async connect(userToken: string) {
    this.socket = io(this.baseUrl, {
      auth: {
        apiKey: this.apiKey,
        token: userToken
      }
    });

    return new Promise((resolve, reject) => {
      this.socket.on('connect', resolve);
      this.socket.on('connect_error', reject);
    });
  }

  async sendMessage(data: any) {
    return await this.socket.emit('create', 'messages', data);
  }

  async getMessages(conversationId: string, options: any = {}) {
    return await this.socket.emit('find', 'api/v1/messages', {
      conversationId,
      ...options
    });
  }

  on(event: string, callback: Function) {
    this.socket.on(event, callback);
  }
}
```

#### 3.5.2 Flutter SDK

```dart
// packages/sdk-flutter/lib/messagecore_sdk.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

class MessageCoreSDK {
  final String apiKey;
  final String baseUrl;
  IO.Socket? _socket;

  MessageCoreSDK({
    required this.apiKey,
    this.baseUrl = 'https://api.messagecore.goldsky.com',
  });

  Future<void> connect(String userToken) async {
    _socket = IO.io(baseUrl, IO.OptionBuilder()
        .setAuth({
          'apiKey': apiKey,
          'token': userToken,
        })
        .build());

    _socket?.connect();
  }

  Future<Map<String, dynamic>> sendMessage(Map<String, dynamic> data) async {
    final completer = Completer<Map<String, dynamic>>();
    
    _socket?.emitWithAck('create', ['messages', data], ack: (response) {
      completer.complete(response);
    });
    
    return completer.future;
  }

  void onMessage(Function(Map<String, dynamic>) callback) {
    _socket?.on('messages created', (data) {
      callback(data);
    });
  }
}
```

### 3.6 Phase 6: 管理后台开发 (2周)

```typescript
// apps/admin/src/services/api.ts
import { MessageCoreSDK } from '@goldsky/messagecore-sdk-js';

class AdminAPI {
  private sdk: MessageCoreSDK;

  constructor() {
    this.sdk = new MessageCoreSDK({
      apiKey: process.env.REACT_APP_ADMIN_API_KEY!,
      baseUrl: process.env.REACT_APP_API_URL!
    });
  }

  async getTenants() {
    return await this.sdk.socket.emit('find', 'tenants');
  }

  async createTenant(data: any) {
    return await this.sdk.socket.emit('create', 'tenants', data);
  }

  async getTenantUsage(tenantId: string) {
    return await this.sdk.socket.emit('find', 'quota-usage', {
      tenantId
    });
  }
}
```

## 4. 集成步骤

### 4.1 Step 1: 环境准备

```bash
# 1. 创建工作目录
mkdir messagecore-project
cd messagecore-project

# 2. 克隆Feathers.js聊天模板
git clone https://github.com/feathersjs/feathers-chat.git backend
cd backend

# 3. 安装依赖
npm install

# 4. 添加额外依赖
npm install @prisma/client prisma redis ioredis uuid
npm install -D @types/uuid

# 5. 初始化数据库
npx prisma init
```

### 4.2 Step 2: 项目结构重组

```bash
messagecore-project/
├── backend/                 # Feathers.js后端 (改造)
│   ├── src/
│   │   ├── services/
│   │   │   ├── tenants/     # 新增租户服务
│   │   │   ├── quota/       # 新增配额服务
│   │   │   └── api/         # 新增标准化API
│   │   ├── hooks/
│   │   │   ├── multi-tenant.js
│   │   │   └── quota-check.js
│   │   └── prisma/
│   │       └── schema.prisma
│   └── package.json
├── packages/
│   ├── sdk-js/              # JavaScript SDK
│   ├── sdk-flutter/         # Flutter SDK
│   └── shared/              # 共享类型定义
├── apps/
│   ├── admin/               # React管理后台
│   └── docs/                # 文档站点
└── README.md
```

### 4.3 Step 3: 数据库迁移

```prisma
// backend/prisma/schema.prisma
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
  id             String  @id @default(uuid())
  tenantId       String  @map("tenant_id")
  externalUserId String  @map("external_user_id")
  email          String?
  displayName    String  @map("display_name")
  avatarUrl      String? @map("avatar_url")
  isActive       Boolean @default(true) @map("is_active")
  createdAt      DateTime @default(now()) @map("created_at")

  tenant   Tenant    @relation(fields: [tenantId], references: [id])
  messages Message[]

  @@unique([tenantId, externalUserId])
  @@map("users")
}

model Message {
  id             String   @id @default(uuid())
  tenantId       String   @map("tenant_id")
  conversationId String   @map("conversation_id")
  senderId       String   @map("sender_id")
  messageType    String   @map("message_type")
  content        Json
  replyToId      String?  @map("reply_to_id")
  status         String   @default("sent")
  createdAt      DateTime @default(now()) @map("created_at")
  updatedAt      DateTime @updatedAt @map("updated_at")

  tenant Tenant @relation(fields: [tenantId], references: [id])
  sender User   @relation(fields: [senderId], references: [id])

  @@index([tenantId, conversationId, createdAt])
  @@map("messages")
}
```

### 4.4 Step 4: 核心服务改造

```javascript
// backend/src/services/tenants/tenants.service.js
const { Service } = require('feathers-prisma');
const { PrismaClient } = require('@prisma/client');

class TenantsService extends Service {
  constructor(options, app) {
    super(options, app);
    this.prisma = new PrismaClient();
  }

  async create(data, params) {
    const apiKey = this.generateApiKey();
    
    const tenant = await this.prisma.tenant.create({
      data: {
        ...data,
        apiKey,
        settings: {
          maxUsers: this.getMaxUsers(data.planType),
          maxMessages: this.getMaxMessages(data.planType),
          ...data.settings
        }
      }
    });

    return tenant;
  }

  generateApiKey() {
    return 'mc_' + require('uuid').v4().replace(/-/g, '');
  }

  getMaxUsers(planType) {
    const limits = { basic: 100, pro: 1000, enterprise: 10000 };
    return limits[planType] || limits.basic;
  }

  getMaxMessages(planType) {
    const limits = { basic: 10000, pro: 100000, enterprise: 1000000 };
    return limits[planType] || limits.basic;
  }
}

module.exports = TenantsService;
```

## 5. 快速启动

### 5.1 一键部署脚本

```bash
#!/bin/bash
# scripts/quick-setup.sh

echo "🚀 GoldSky MessageCore快速启动脚本"

# 1. 克隆Feathers.js基础项目
echo "📦 克隆基础项目..."
git clone https://github.com/feathersjs/feathers-chat.git messagecore-backend
cd messagecore-backend

# 2. 安装依赖
echo "📚 安装依赖..."
npm install
npm install @prisma/client prisma redis ioredis uuid express-rate-limit

# 3. 设置环境变量
echo "⚙️ 配置环境..."
cp .env.example .env
echo "DATABASE_URL=postgresql://username:password@localhost:5432/messagecore" >> .env
echo "REDIS_URL=redis://localhost:6379" >> .env

# 4. 数据库初始化
echo "🗄️ 初始化数据库..."
npx prisma generate
npx prisma db push

# 5. 启动服务
echo "🎯 启动服务..."
npm run dev

echo "✅ GoldSky MessageCore启动完成!"
echo "📖 API文档: http://localhost:3030"
echo "🔧 管理后台: http://localhost:3000"
```

### 5.2 Docker快速部署

```yaml
# docker-compose.quick.yml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: messagecore
      POSTGRES_USER: messagecore
      POSTGRES_PASSWORD: changeme
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  messagecore-api:
    build: ./backend
    environment:
      DATABASE_URL: postgresql://messagecore:changeme@postgres:5432/messagecore
      REDIS_URL: redis://redis:6379
    ports:
      - "3030:3030"
    depends_on:
      - postgres
      - redis
    volumes:
      - ./backend:/app
    command: npm run dev

volumes:
  postgres_data:
```

### 5.3 测试验证

```javascript
// test/integration.test.js
const assert = require('assert');
const axios = require('axios');

describe('GoldSky MessageCore API测试', () => {
  let apiKey;
  
  before(async () => {
    // 创建测试租户
    const tenant = await axios.post('http://localhost:3030/tenants', {
      name: '测试公司',
      subdomain: 'test-company',
      planType: 'basic'
    });
    
    apiKey = tenant.data.apiKey;
  });

  it('应该能够发送消息', async () => {
    const response = await axios.post(
      'http://localhost:3030/api/v1/messages/send',
      {
        conversationId: 'conv-123',
        senderId: 'user-456',
        type: 'text',
        content: { text: 'Hello MessageCore!' }
      },
      {
        headers: { 'X-API-Key': apiKey }
      }
    );

    assert.equal(response.data.success, true);
    assert.equal(response.data.data.content.text, 'Hello MessageCore!');
  });
});
```

## 6. 预期收益

### 6.1 开发时间对比

| 功能模块 | 从零开发 | 基于开源 | 时间节省 |
|----------|----------|----------|----------|
| 基础架构 | 4周 | 1周 | 75% |
| 实时通信 | 3周 | 0.5周 | 83% |
| 认证系统 | 2周 | 0.5周 | 75% |
| API开发 | 4周 | 2周 | 50% |
| SDK开发 | 3周 | 2周 | 33% |
| **总计** | **16周** | **6周** | **62.5%** |

### 6.2 质量优势

```yaml
稳定性:
  - Feathers.js已在生产环境验证
  - Socket.io处理并发连接能力强
  - 减少自研风险

扩展性:
  - Feathers.js插件生态丰富
  - 支持多种数据库
  - 易于水平扩展

维护性:
  - 标准化架构
  - 活跃的社区支持
  - 详细的文档
```

### 6.3 成本优化

```yaml
人力成本: 
  - 原需4人×4月 = 16人月
  - 现需3人×2月 = 6人月
  - 节省成本: 62.5%

时间成本:
  - 原计划16周上线
  - 现6-8周即可上线
  - 提前2个月抢占市场

技术风险:
  - 基于成熟开源项目
  - 降低技术选型风险
  - 快速迭代验证
```

## 总结

通过基于Feathers.js改造，我们可以：

1. **快速启动**: 1周内搭建基础架构
2. **成本控制**: 开发时间节省62.5%  
3. **质量保证**: 基于生产级开源项目
4. **灵活扩展**: 保持完全的定制能力

这个方案既满足了快速上线的需求，又保证了产品的质量和可扩展性，是最优的技术选择。 