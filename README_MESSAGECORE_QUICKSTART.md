# 🚀 GoldSky MessageCore 快速启动指南

基于开源项目快速构建多租户消息系统

## 📖 方案概述

我们基于成熟的开源项目 **Feathers.js** 来快速构建GoldSky MessageCore，这样可以：

- ⏰ **节省62.5%开发时间** - 从16周缩短到6周
- 💰 **降低开发成本** - 减少人力投入50%
- 🛡️ **保证稳定性** - 基于生产级开源项目
- 🔧 **完全可控** - 保持完整的定制能力

## 🎯 一键启动

### 方式1: 自动化脚本启动

```bash
# 在当前JinBean项目目录下运行
./scripts/messagecore-quick-setup.sh
```

### 方式2: 手动启动

```bash
# 1. 创建项目目录
mkdir messagecore-project && cd messagecore-project

# 2. 克隆基础项目
git clone https://github.com/feathersjs/feathers-chat.git backend
cd backend

# 3. 安装依赖
npm install
npm install @prisma/client prisma redis ioredis uuid express-rate-limit

# 4. 启动数据库(Docker)
docker-compose up -d postgres redis

# 5. 初始化数据库
npm run setup

# 6. 启动开发服务器
npm run dev
```

## 🏗️ 项目架构

```
messagecore-project/
├── backend/                 # Feathers.js后端 (改造)
│   ├── src/
│   │   ├── hooks/
│   │   │   ├── multi-tenant.js      # 多租户支持
│   │   │   └── quota-check.js       # 配额管理
│   │   ├── services/
│   │   │   ├── tenants/             # 租户管理
│   │   │   └── api/v1/              # 标准化API
│   │   └── prisma/schema.prisma     # 数据库模型
│   ├── docker-compose.yml          # 开发环境
│   └── package.json
├── packages/                        # SDK开发
│   ├── sdk-js/                      # JavaScript SDK
│   └── sdk-flutter/                 # Flutter SDK
└── apps/
    ├── admin/                       # React管理后台
    └── docs/                        # 文档站点
```

## 🔧 核心功能

### 1. 多租户系统
```typescript
// 自动租户隔离
const multiTenant = () => {
  return async (context) => {
    const apiKey = context.params.headers['x-api-key'];
    const tenant = await validateTenant(apiKey);
    context.params.tenant = tenant;
    // 自动添加tenant_id过滤
    if (context.method === 'find') {
      context.params.query.tenantId = tenant.id;
    }
  };
};
```

### 2. 配额管理
```typescript
// 实时配额检查
const quotaCheck = () => {
  return async (context) => {
    const tenant = context.params.tenant;
    const currentCount = await redis.get(`quota:${tenant.id}`);
    if (currentCount >= tenant.maxMessages) {
      throw new Error('配额已用完');
    }
    await redis.incr(`quota:${tenant.id}`);
  };
};
```

### 3. 标准化API
```typescript
// 统一的API格式
POST /api/v1/messages
{
  "conversationId": "conv-123",
  "senderId": "user-456", 
  "type": "text",
  "content": {"text": "Hello World"}
}
```

## 📊 开发时间对比

| 功能模块 | 从零开发 | 基于开源 | 节省时间 |
|----------|----------|----------|----------|
| 基础架构 | 4周 | 1周 | **75%** |
| 实时通信 | 3周 | 0.5周 | **83%** |
| 认证系统 | 2周 | 0.5周 | **75%** |
| API开发 | 4周 | 2周 | **50%** |
| SDK开发 | 3周 | 2周 | **33%** |
| **总计** | **16周** | **6周** | **62.5%** |

## 🚀 快速测试

### 1. 创建租户
```bash
curl -X POST http://localhost:3030/tenants \
  -H "Content-Type: application/json" \
  -d '{
    "name": "测试公司",
    "subdomain": "test-company",
    "planType": "basic"
  }'
```

返回结果包含 `apiKey`，保存备用。

### 2. 发送消息
```bash
curl -X POST http://localhost:3030/api/v1/messages \
  -H "Content-Type: application/json" \
  -H "X-API-Key: 你的API密钥" \
  -d '{
    "conversationId": "conv-123",
    "senderId": "user-456",
    "type": "text",
    "content": {"text": "Hello MessageCore! 🚀"}
  }'
```

### 3. 获取消息
```bash
curl "http://localhost:3030/api/v1/messages?conversationId=conv-123" \
  -H "X-API-Key: 你的API密钥"
```

## 📱 SDK集成示例

### JavaScript SDK
```javascript
import { MessageCoreSDK } from '@goldsky/messagecore-sdk-js';

const sdk = new MessageCoreSDK({
  apiKey: 'your-api-key'
});

// 连接WebSocket
await sdk.connect('user-token');

// 发送消息
await sdk.sendMessage({
  conversationId: 'conv-123',
  senderId: 'user-456',
  type: 'text',
  content: { text: 'Hello!' }
});

// 监听新消息
sdk.on('new_message', (message) => {
  console.log('收到新消息:', message);
});
```

### Flutter SDK
```dart
final sdk = MessageCoreSDK(apiKey: 'your-api-key');

// 连接
await sdk.connect('user-token');

// 发送消息
await sdk.sendMessage(
  conversationId: 'conv-123',
  senderId: 'user-456',
  type: 'text',
  content: {'text': 'Hello from Flutter!'},
);

// 监听消息
sdk.on('new_message', (message) {
  print('收到新消息: $message');
});
```

## 🔄 开发流程

### Phase 1: 基础搭建 (1周)
- [x] 克隆Feathers.js项目
- [x] 多租户架构改造
- [x] 基础服务配置

### Phase 2: 核心功能 (2周)  
- [ ] 配额管理系统
- [ ] API标准化
- [ ] 实时通信优化

### Phase 3: SDK开发 (2周)
- [ ] JavaScript SDK
- [ ] Flutter SDK  
- [ ] React组件库

### Phase 4: 管理后台 (1周)
- [ ] React管理面板
- [ ] 租户管理界面
- [ ] 监控面板

## 📈 商业价值

### 快速上市
- **6周MVP上线** vs 原计划16周
- **提前2个月抢占市场**
- **快速验证产品市场契合度**

### 成本控制
- **开发成本降低62.5%**
- **人力投入减少50%** 
- **技术风险显著降低**

### 质量保证
- **基于生产级开源项目**
- **活跃社区支持**
- **完善的测试覆盖**

## 🎯 下一步计划

1. **立即执行**: 运行快速启动脚本
2. **核心开发**: 2周完成多租户和配额系统
3. **SDK开发**: 2周完成JS和Flutter SDK
4. **内部测试**: 在JinBean项目中集成测试
5. **友好客户**: 邀请2-3家小客户试用
6. **正式发布**: 6周后正式商业化

## 💡 关键优势

✅ **时间优势**: 6周 vs 16周，节省62.5%时间  
✅ **成本优势**: 减少50%人力投入  
✅ **技术优势**: 基于成熟稳定的开源项目  
✅ **扩展优势**: 保持完全的定制和扩展能力  
✅ **市场优势**: 快速上线，抢占先机  

立即开始，让GoldSky MessageCore在6周内从概念变为现实！

---

## 🆘 需要帮助？

- 📧 技术问题: [GitHub Issues](https://github.com/goldsky/messagecore)
- 💬 实时讨论: [Discord](https://discord.gg/goldsky)
- 📖 完整文档: [docs/](./docs/) 