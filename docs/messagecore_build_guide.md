# GoldSky MessageCore产品从0到1构建指南

## 📋 目录
1. [产品概述](#1-产品概述)
2. [技术架构设计](#2-技术架构设计)
3. [多租户系统搭建](#3-多租户系统搭建)
4. [核心API开发](#4-核心api开发)
5. [实时通信系统](#5-实时通信系统)
6. [管理后台开发](#6-管理后台开发)
7. [SDK开发](#7-sdk开发)
8. [部署运维](#8-部署运维)

## 1. 产品概述

### 1.1 GoldSky MessageCore定位

```yaml
产品定位:
  - SaaS消息服务平台
  - 企业级即时通讯解决方案
  - 支持多租户架构
  - 提供标准化API接口
  - 可快速集成到任何应用

目标客户:
  - 中小企业 (SMB)
  - SaaS产品开发商
  - 电商平台
  - 在线教育平台
  - 医疗健康平台
```

### 1.2 核心功能模块

```mermaid
graph TB
    A[GoldSky MessageCore核心] --> B[多租户管理]
    A --> C[消息服务]
    A --> D[实时通信]
    A --> E[文件存储]
    A --> F[用户管理]
    A --> G[API网关]
    
    B --> B1[租户注册]
    B --> B2[资源隔离]
    B --> B3[计费管理]
    
    C --> C1[消息发送]
    C --> C2[消息存储]
    C --> C3[消息查询]
    
    D --> D1[WebSocket]
    D --> D2[实时推送]
    D --> D3[在线状态]
    
    E --> E1[文件上传]
    E --> E2[图片处理]
    E --> E3[CDN分发]
```

### 1.3 技术栈选择

```yaml
后端技术栈:
  - 框架: Node.js + Express/Fastify
  - 数据库: PostgreSQL (主库) + Redis (缓存)
  - 消息队列: Redis Pub/Sub / RabbitMQ
  - 实时通信: Socket.io / ws
  - 对象存储: AWS S3 / 阿里云OSS
  - 监控: Prometheus + Grafana

前端技术栈:
  - 管理后台: React + TypeScript + Ant Design
  - 文档站点: Next.js + MDX
  - 监控面板: React + ECharts

基础设施:
  - 容器化: Docker + Kubernetes
  - CI/CD: GitHub Actions
  - 负载均衡: Nginx
  - 域名解析: Cloudflare
```

## 2. 技术架构设计

### 2.1 系统架构图

```mermaid
graph TB
    subgraph "客户端层"
        A1[客户端A]
        A2[客户端B]
        A3[Web管理端]
    end
    
    subgraph "接入层"
        B1[API网关]
        B2[负载均衡器]
        B3[CDN]
    end
    
    subgraph "业务层"
        C1[认证服务]
        C2[消息服务]
        C3[租户服务]
        C4[文件服务]
        C5[通知服务]
        C6[实时服务]
    end
    
    subgraph "数据层"
        D1[(PostgreSQL)]
        D2[(Redis)]
        D3[对象存储]
        D4[消息队列]
    end
    
    A1 --> B1
    A2 --> B1
    A3 --> B1
    B1 --> B2
    B2 --> C1
    B2 --> C2
    B2 --> C3
    B2 --> C4
    B2 --> C5
    B2 --> C6
    
    C1 --> D1
    C2 --> D1
    C2 --> D2
    C3 --> D1
    C4 --> D3
    C5 --> D4
    C6 --> D2
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

### 2.3 存储架构演进策略

```mermaid
graph LR
    A[初期: Supabase] --> B[成长期: Azure迁移]
    B --> C[成熟期: Azure全栈]
    
    subgraph "初期阶段 (0-6个月)"
        A1[Supabase PostgreSQL]
        A2[Supabase Storage]
        A3[Supabase Auth]
        A4[Supabase Realtime]
    end
    
    subgraph "迁移阶段 (6-12个月)"
        B1[Azure Database for PostgreSQL]
        B2[Azure Blob Storage]
        B3[Azure Active Directory]
        B4[Azure SignalR Service]
    end
    
    subgraph "成熟阶段 (12个月+)"
        C1[Azure全栈服务]
        C2[Azure Kubernetes Service]
        C3[Azure Application Insights]
        C4[Azure CDN]
    end
```

#### 2.3.1 初期Supabase架构 (0-6个月)

```yaml
优势:
  - 快速启动，零配置
  - 免费额度充足
  - 开发效率高
  - 实时功能内置

服务配置:
  数据库: Supabase PostgreSQL
  存储: Supabase Storage
  认证: Supabase Auth
  实时: Supabase Realtime
  API: Supabase REST API

成本预估:
  免费额度: 500MB数据库 + 1GB存储
  付费: $25/月 (基础计划)
```

#### 2.3.2 Azure迁移策略 (6-12个月)

```yaml
迁移目标:
  - 申请Microsoft Startup项目
  - 获得Azure免费额度
  - 企业级服务支持
  - 全球化部署能力

迁移服务映射:
  Supabase PostgreSQL → Azure Database for PostgreSQL
  Supabase Storage → Azure Blob Storage
  Supabase Auth → Azure Active Directory B2C
  Supabase Realtime → Azure SignalR Service
  Supabase Edge Functions → Azure Functions

Microsoft Startup福利:
  - $150,000 Azure免费额度
  - 技术专家支持
  - 企业级服务
  - 全球市场推广
```

#### 2.3.3 迁移实施计划

```yaml
Phase 1: 准备阶段 (1个月)
  - 申请Microsoft Startup项目
  - 设计Azure架构
  - 准备迁移脚本
  - 测试环境搭建

Phase 2: 数据迁移 (2周)
  - 数据库迁移 (PostgreSQL)
  - 文件存储迁移 (Blob Storage)
  - 用户数据迁移 (AAD B2C)
  - 数据验证

Phase 3: 服务迁移 (2周)
  - API服务迁移
  - 实时通信迁移
  - 认证系统迁移
  - 性能测试

Phase 4: 切换上线 (1周)
  - 灰度发布
  - 监控验证
  - 全量切换
  - 旧服务清理
```

### 2.3 项目结构

```
messageCore/
├── apps/
│   ├── api/                    # 主API服务
│   ├── realtime/               # 实时通信服务
│   ├── admin/                  # 管理后台
│   └── docs/                   # 文档站点
├── packages/
│   ├── shared/                 # 共享工具库
│   ├── db/                     # 数据库模型
│   ├── sdk-js/                 # JavaScript SDK
│   └── sdk-flutter/            # Flutter SDK
├── infrastructure/
│   ├── docker/                 # Docker配置
│   ├── k8s/                    # Kubernetes配置
│   └── terraform/              # 基础设施代码
├── docs/                       # 文档
└── scripts/                    # 脚本工具
```

## 3. 多租户系统搭建

### 3.1 租户管理服务

```typescript
// apps/api/src/services/tenant.service.ts
import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { generateApiKey } from '../utils/crypto';

@Injectable()
export class TenantService {
  constructor(private prisma: PrismaService) {}

  async createTenant(data: CreateTenantDto) {
    const apiKey = generateApiKey();
    
    const tenant = await this.prisma.tenant.create({
      data: {
        name: data.name,
        subdomain: data.subdomain,
        apiKey,
        planType: data.planType || 'basic',
        settings: {
          maxUsers: this.getMaxUsers(data.planType),
          maxMessages: this.getMaxMessages(data.planType),
          retentionDays: this.getRetentionDays(data.planType),
        }
      }
    });

    return tenant;
  }

  async getTenant(id: string) {
    return this.prisma.tenant.findUnique({
      where: { id },
      include: {
        users: {
          select: {
            id: true,
            externalUserId: true,
            displayName: true,
            isActive: true,
          }
        },
        conversations: {
          select: {
            id: true,
            type: true,
            title: true,
            createdAt: true,
          },
          orderBy: { createdAt: 'desc' },
          take: 10,
        }
      }
    });
  }

  async validateApiKey(apiKey: string) {
    return this.prisma.tenant.findUnique({
      where: { apiKey },
      select: {
        id: true,
        name: true,
        subdomain: true,
        status: true,
        planType: true,
        settings: true,
      }
    });
  }

  private getMaxUsers(planType: string): number {
    const limits = {
      basic: 100,
      pro: 1000,
      enterprise: 10000,
    };
    return limits[planType] || limits.basic;
  }

  private getMaxMessages(planType: string): number {
    const limits = {
      basic: 10000,
      pro: 100000,
      enterprise: 1000000,
    };
    return limits[planType] || limits.basic;
  }

  private getRetentionDays(planType: string): number {
    const retention = {
      basic: 30,
      pro: 90,
      enterprise: 365,
    };
    return retention[planType] || retention.basic;
  }
}
```

### 3.2 租户认证中间件

```typescript
// apps/api/src/middleware/tenant-auth.middleware.ts
import { Injectable, NestMiddleware, UnauthorizedException } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { TenantService } from '../services/tenant.service';

declare global {
  namespace Express {
    interface Request {
      tenant?: any;
    }
  }
}

@Injectable()
export class TenantAuthMiddleware implements NestMiddleware {
  constructor(private tenantService: TenantService) {}

  async use(req: Request, res: Response, next: NextFunction) {
    const apiKey = req.headers['x-api-key'] as string;
    
    if (!apiKey) {
      throw new UnauthorizedException('API key is required');
    }

    const tenant = await this.tenantService.validateApiKey(apiKey);
    
    if (!tenant) {
      throw new UnauthorizedException('Invalid API key');
    }

    if (tenant.status !== 'active') {
      throw new UnauthorizedException('Tenant is not active');
    }

    req.tenant = tenant;
    next();
  }
}
```

### 3.3 资源配额管理

```typescript
// apps/api/src/services/quota.service.ts
import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { RedisService } from './redis.service';

@Injectable()
export class QuotaService {
  constructor(
    private prisma: PrismaService,
    private redis: RedisService,
  ) {}

  async checkMessageQuota(tenantId: string): Promise<boolean> {
    const tenant = await this.prisma.tenant.findUnique({
      where: { id: tenantId },
      select: { settings: true }
    });

    const maxMessages = tenant.settings.maxMessages;
    const currentMonth = new Date().toISOString().slice(0, 7); // YYYY-MM
    const key = `quota:messages:${tenantId}:${currentMonth}`;
    
    const currentCount = await this.redis.get(key) || 0;
    
    if (parseInt(currentCount) >= maxMessages) {
      throw new BadRequestException('Message quota exceeded');
    }

    return true;
  }

  async incrementMessageCount(tenantId: string): Promise<void> {
    const currentMonth = new Date().toISOString().slice(0, 7);
    const key = `quota:messages:${tenantId}:${currentMonth}`;
    
    await this.redis.incr(key);
    await this.redis.expire(key, 60 * 60 * 24 * 32); // 32天过期
  }

  async checkUserQuota(tenantId: string): Promise<boolean> {
    const tenant = await this.prisma.tenant.findUnique({
      where: { id: tenantId },
      select: { 
        settings: true,
        _count: {
          select: { users: { where: { isActive: true } } }
        }
      }
    });

    const maxUsers = tenant.settings.maxUsers;
    const currentUsers = tenant._count.users;

    if (currentUsers >= maxUsers) {
      throw new BadRequestException('User quota exceeded');
    }

    return true;
  }

  async getQuotaUsage(tenantId: string) {
    const tenant = await this.prisma.tenant.findUnique({
      where: { id: tenantId },
      select: { 
        settings: true,
        _count: {
          select: { 
            users: { where: { isActive: true } },
            messages: {
              where: {
                createdAt: {
                  gte: new Date(new Date().getFullYear(), new Date().getMonth(), 1)
                }
              }
            }
          }
        }
      }
    });

    return {
      users: {
        current: tenant._count.users,
        limit: tenant.settings.maxUsers,
        percentage: (tenant._count.users / tenant.settings.maxUsers) * 100
      },
      messages: {
        current: tenant._count.messages,
        limit: tenant.settings.maxMessages,
        percentage: (tenant._count.messages / tenant.settings.maxMessages) * 100
      }
    };
  }
}
```

## 4. 核心API开发

### 4.1 消息发送API

```typescript
// apps/api/src/controllers/messages.controller.ts
import { Controller, Post, Get, Body, Param, Query, Req, UseGuards } from '@nestjs/common';
import { TenantAuthGuard } from '../guards/tenant-auth.guard';
import { MessageService } from '../services/message.service';
import { QuotaService } from '../services/quota.service';

@Controller('api/v1/messages')
@UseGuards(TenantAuthGuard)
export class MessagesController {
  constructor(
    private messageService: MessageService,
    private quotaService: QuotaService,
  ) {}

  @Post('send')
  async sendMessage(@Req() req, @Body() body: SendMessageDto) {
    const tenantId = req.tenant.id;
    
    // 检查配额
    await this.quotaService.checkMessageQuota(tenantId);
    
    // 发送消息
    const message = await this.messageService.sendMessage(tenantId, body);
    
    // 增加计数
    await this.quotaService.incrementMessageCount(tenantId);
    
    return { success: true, data: message };
  }

  @Get('conversations/:conversationId')
  async getMessages(
    @Req() req,
    @Param('conversationId') conversationId: string,
    @Query() query: GetMessagesQuery,
  ) {
    const tenantId = req.tenant.id;
    
    const messages = await this.messageService.getMessages(
      tenantId,
      conversationId,
      query
    );
    
    return { success: true, data: messages };
  }

  @Post('conversations')
  async createConversation(@Req() req, @Body() body: CreateConversationDto) {
    const tenantId = req.tenant.id;
    
    const conversation = await this.messageService.createConversation(
      tenantId,
      body
    );
    
    return { success: true, data: conversation };
  }
}
```

### 4.2 消息服务实现

```typescript
// apps/api/src/services/message.service.ts
import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { RealtimeService } from './realtime.service';
import { NotificationService } from './notification.service';

@Injectable()
export class MessageService {
  constructor(
    private prisma: PrismaService,
    private realtime: RealtimeService,
    private notification: NotificationService,
  ) {}

  async sendMessage(tenantId: string, data: SendMessageDto) {
    // 创建消息
    const message = await this.prisma.message.create({
      data: {
        tenantId,
        conversationId: data.conversationId,
        senderId: data.senderId,
        messageType: data.type,
        content: data.content,
        replyToId: data.replyToId,
      },
      include: {
        sender: {
          select: {
            id: true,
            externalUserId: true,
            displayName: true,
            avatarUrl: true,
          }
        },
        conversation: {
          select: {
            id: true,
            participantIds: true,
          }
        }
      }
    });

    // 更新会话最后消息时间
    await this.prisma.conversation.update({
      where: { id: data.conversationId },
      data: { lastMessageAt: new Date() }
    });

    // 实时推送
    await this.realtime.broadcastMessage(message);

    // 推送通知给离线用户
    await this.notification.sendMessageNotification(message);

    return message;
  }

  async getMessages(
    tenantId: string,
    conversationId: string,
    query: GetMessagesQuery
  ) {
    const { page = 1, limit = 50, before } = query;
    
    const where = {
      tenantId,
      conversationId,
      ...(before && { createdAt: { lt: new Date(before) } })
    };

    const messages = await this.prisma.message.findMany({
      where,
      include: {
        sender: {
          select: {
            id: true,
            externalUserId: true,
            displayName: true,
            avatarUrl: true,
          }
        }
      },
      orderBy: { createdAt: 'desc' },
      take: limit,
      skip: (page - 1) * limit,
    });

    const total = await this.prisma.message.count({ where });

    return {
      messages: messages.reverse(), // 按时间正序返回
      pagination: {
        page,
        limit,
        total,
        hasMore: page * limit < total,
      }
    };
  }

  async createConversation(tenantId: string, data: CreateConversationDto) {
    const conversation = await this.prisma.conversation.create({
      data: {
        tenantId,
        type: data.type,
        title: data.title,
        participantIds: data.participantIds,
        metadata: data.metadata || {},
      },
      include: {
        participants: {
          select: {
            id: true,
            externalUserId: true,
            displayName: true,
            avatarUrl: true,
          }
        }
      }
    });

    // 通知参与者
    await this.realtime.broadcastConversationCreated(conversation);

    return conversation;
  }
}
```

## 5. 实时通信系统

### 5.1 WebSocket服务

```typescript
// apps/realtime/src/websocket.gateway.ts
import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { TenantService } from './services/tenant.service';
import { RedisService } from './services/redis.service';

@WebSocketGateway({
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  },
  transports: ['websocket']
})
export class WebSocketGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  constructor(
    private tenantService: TenantService,
    private redis: RedisService,
  ) {}

  async handleConnection(client: Socket) {
    try {
      const token = client.handshake.auth.token;
      const apiKey = client.handshake.auth.apiKey;
      
      if (!token || !apiKey) {
        client.disconnect();
        return;
      }

      // 验证租户
      const tenant = await this.tenantService.validateApiKey(apiKey);
      if (!tenant) {
        client.disconnect();
        return;
      }

      // 验证用户token (这里需要根据实际情况实现)
      const user = await this.validateUserToken(tenant.id, token);
      if (!user) {
        client.disconnect();
        return;
      }

      // 存储连接信息
      client.data.tenantId = tenant.id;
      client.data.userId = user.id;
      
      // 加入租户房间
      await client.join(`tenant:${tenant.id}`);
      
      // 加入用户房间
      await client.join(`user:${user.id}`);
      
      // 更新在线状态
      await this.updateUserPresence(user.id, 'online');
      
      console.log(`User ${user.id} connected to tenant ${tenant.id}`);
      
    } catch (error) {
      console.error('Connection error:', error);
      client.disconnect();
    }
  }

  async handleDisconnect(client: Socket) {
    if (client.data.userId) {
      await this.updateUserPresence(client.data.userId, 'offline');
      console.log(`User ${client.data.userId} disconnected`);
    }
  }

  @SubscribeMessage('join_conversation')
  async handleJoinConversation(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { conversationId: string }
  ) {
    const { conversationId } = data;
    const tenantId = client.data.tenantId;
    const userId = client.data.userId;

    // 验证用户是否有权限加入会话
    const hasPermission = await this.checkConversationPermission(
      tenantId,
      conversationId,
      userId
    );

    if (hasPermission) {
      await client.join(`conversation:${conversationId}`);
      client.emit('joined_conversation', { conversationId });
    } else {
      client.emit('error', { message: 'No permission to join conversation' });
    }
  }

  @SubscribeMessage('leave_conversation')
  async handleLeaveConversation(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { conversationId: string }
  ) {
    const { conversationId } = data;
    await client.leave(`conversation:${conversationId}`);
    client.emit('left_conversation', { conversationId });
  }

  @SubscribeMessage('typing_start')
  async handleTypingStart(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { conversationId: string }
  ) {
    const userId = client.data.userId;
    
    // 广播给会话中的其他用户
    client.to(`conversation:${data.conversationId}`).emit('user_typing', {
      conversationId: data.conversationId,
      userId,
      isTyping: true,
    });
  }

  @SubscribeMessage('typing_stop')
  async handleTypingStop(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { conversationId: string }
  ) {
    const userId = client.data.userId;
    
    client.to(`conversation:${data.conversationId}`).emit('user_typing', {
      conversationId: data.conversationId,
      userId,
      isTyping: false,
    });
  }

  // 广播新消息
  async broadcastMessage(message: any) {
    this.server.to(`conversation:${message.conversationId}`).emit('new_message', {
      message,
      timestamp: new Date().toISOString(),
    });
  }

  // 广播会话创建
  async broadcastConversationCreated(conversation: any) {
    // 通知所有参与者
    conversation.participantIds.forEach(userId => {
      this.server.to(`user:${userId}`).emit('conversation_created', {
        conversation,
        timestamp: new Date().toISOString(),
      });
    });
  }

  private async validateUserToken(tenantId: string, token: string) {
    // 这里实现用户token验证逻辑
    // 可以是JWT验证或者查询数据库
    return { id: 'user123', name: 'Test User' }; // 示例
  }

  private async updateUserPresence(userId: string, status: 'online' | 'offline') {
    const key = `presence:${userId}`;
    await this.redis.set(key, JSON.stringify({
      status,
      lastSeen: new Date().toISOString(),
    }), 'EX', 300); // 5分钟过期
  }

  private async checkConversationPermission(
    tenantId: string,
    conversationId: string,
    userId: string
  ): Promise<boolean> {
    // 实现权限检查逻辑
    return true; // 示例
  }
}
```

### 5.2 实时服务

```typescript
// apps/api/src/services/realtime.service.ts
import { Injectable } from '@nestjs/common';
import { RedisService } from './redis.service';

@Injectable()
export class RealtimeService {
  constructor(private redis: RedisService) {}

  async broadcastMessage(message: any) {
    // 发布到Redis频道，让所有WebSocket服务实例都能收到
    await this.redis.publish('message_broadcast', JSON.stringify({
      type: 'new_message',
      data: message,
    }));
  }

  async broadcastConversationCreated(conversation: any) {
    await this.redis.publish('message_broadcast', JSON.stringify({
      type: 'conversation_created',
      data: conversation,
    }));
  }

  async broadcastUserPresence(userId: string, status: string) {
    await this.redis.publish('message_broadcast', JSON.stringify({
      type: 'user_presence',
      data: { userId, status },
    }));
  }

  async getUserPresence(userId: string) {
    const key = `presence:${userId}`;
    const presence = await this.redis.get(key);
    return presence ? JSON.parse(presence) : { status: 'offline' };
  }

  async getOnlineUsers(tenantId: string): Promise<string[]> {
    const pattern = `presence:*`;
    const keys = await this.redis.keys(pattern);
    const onlineUsers = [];

    for (const key of keys) {
      const presence = await this.redis.get(key);
      if (presence) {
        const data = JSON.parse(presence);
        if (data.status === 'online') {
          const userId = key.replace('presence:', '');
          onlineUsers.push(userId);
        }
      }
    }

    return onlineUsers;
  }
}
```

## 6. 管理后台开发

### 6.1 React管理面板

```tsx
// apps/admin/src/pages/Dashboard.tsx
import React, { useState, useEffect } from 'react';
import { Card, Row, Col, Statistic, Table, Button, Modal } from 'antd';
import { UserOutlined, MessageOutlined, TeamOutlined } from '@ant-design/icons';
import { useApi } from '../hooks/useApi';
import { CreateTenantModal } from '../components/CreateTenantModal';

export const Dashboard: React.FC = () => {
  const [tenants, setTenants] = useState([]);
  const [stats, setStats] = useState({});
  const [createModalVisible, setCreateModalVisible] = useState(false);
  const api = useApi();

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = async () => {
    try {
      const [tenantsRes, statsRes] = await Promise.all([
        api.get('/admin/tenants'),
        api.get('/admin/stats'),
      ]);
      
      setTenants(tenantsRes.data);
      setStats(statsRes.data);
    } catch (error) {
      console.error('Failed to load dashboard data:', error);
    }
  };

  const handleCreateTenant = async (values: any) => {
    try {
      await api.post('/admin/tenants', values);
      setCreateModalVisible(false);
      loadDashboardData();
    } catch (error) {
      console.error('Failed to create tenant:', error);
    }
  };

  const columns = [
    {
      title: '租户名称',
      dataIndex: 'name',
      key: 'name',
    },
    {
      title: '子域名',
      dataIndex: 'subdomain',
      key: 'subdomain',
    },
    {
      title: '套餐',
      dataIndex: 'planType',
      key: 'planType',
    },
    {
      title: '状态',
      dataIndex: 'status',
      key: 'status',
      render: (status: string) => (
        <span className={`status ${status}`}>{status}</span>
      ),
    },
    {
      title: '创建时间',
      dataIndex: 'createdAt',
      key: 'createdAt',
      render: (date: string) => new Date(date).toLocaleDateString(),
    },
    {
      title: '操作',
      key: 'actions',
      render: (_, record) => (
        <Button type="link" onClick={() => viewTenant(record.id)}>
          查看详情
        </Button>
      ),
    },
  ];

  const viewTenant = (tenantId: string) => {
    // 跳转到租户详情页面
    window.location.href = `/tenants/${tenantId}`;
  };

  return (
    <div className="dashboard">
      <h1>GoldSky MessageCore 管理后台</h1>
      
      <Row gutter={16} style={{ marginBottom: 24 }}>
        <Col span={8}>
          <Card>
            <Statistic
              title="总租户数"
              value={stats.totalTenants || 0}
              prefix={<TeamOutlined />}
            />
          </Card>
        </Col>
        <Col span={8}>
          <Card>
            <Statistic
              title="活跃用户"
              value={stats.activeUsers || 0}
              prefix={<UserOutlined />}
            />
          </Card>
        </Col>
        <Col span={8}>
          <Card>
            <Statistic
              title="今日消息数"
              value={stats.todayMessages || 0}
              prefix={<MessageOutlined />}
            />
          </Card>
        </Col>
      </Row>

      <Card
        title="租户列表"
        extra={
          <Button 
            type="primary" 
            onClick={() => setCreateModalVisible(true)}
          >
            创建租户
          </Button>
        }
      >
        <Table
          columns={columns}
          dataSource={tenants}
          rowKey="id"
          pagination={{ pageSize: 10 }}
        />
      </Card>

      <CreateTenantModal
        visible={createModalVisible}
        onCancel={() => setCreateModalVisible(false)}
        onSubmit={handleCreateTenant}
      />
    </div>
  );
};
```

### 6.2 租户详情页面

```tsx
// apps/admin/src/pages/TenantDetail.tsx
import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { Card, Row, Col, Statistic, Table, Tabs, Progress } from 'antd';
import { useApi } from '../hooks/useApi';

const { TabPane } = Tabs;

export const TenantDetail: React.FC = () => {
  const { tenantId } = useParams<{ tenantId: string }>();
  const [tenant, setTenant] = useState(null);
  const [usage, setUsage] = useState({});
  const [loading, setLoading] = useState(true);
  const api = useApi();

  useEffect(() => {
    loadTenantData();
  }, [tenantId]);

  const loadTenantData = async () => {
    try {
      setLoading(true);
      const [tenantRes, usageRes] = await Promise.all([
        api.get(`/admin/tenants/${tenantId}`),
        api.get(`/admin/tenants/${tenantId}/usage`),
      ]);
      
      setTenant(tenantRes.data);
      setUsage(usageRes.data);
    } catch (error) {
      console.error('Failed to load tenant data:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading || !tenant) {
    return <div>Loading...</div>;
  }

  const userColumns = [
    {
      title: '用户ID',
      dataIndex: 'externalUserId',
      key: 'externalUserId',
    },
    {
      title: '显示名称',
      dataIndex: 'displayName',
      key: 'displayName',
    },
    {
      title: '状态',
      dataIndex: 'isActive',
      key: 'isActive',
      render: (isActive: boolean) => isActive ? '活跃' : '停用',
    },
    {
      title: '创建时间',
      dataIndex: 'createdAt',
      key: 'createdAt',
      render: (date: string) => new Date(date).toLocaleDateString(),
    },
  ];

  const conversationColumns = [
    {
      title: '会话ID',
      dataIndex: 'id',
      key: 'id',
    },
    {
      title: '类型',
      dataIndex: 'type',
      key: 'type',
    },
    {
      title: '标题',
      dataIndex: 'title',
      key: 'title',
    },
    {
      title: '创建时间',
      dataIndex: 'createdAt',
      key: 'createdAt',
      render: (date: string) => new Date(date).toLocaleDateString(),
    },
  ];

  return (
    <div className="tenant-detail">
      <h1>{tenant.name} - 租户详情</h1>
      
      <Row gutter={16} style={{ marginBottom: 24 }}>
        <Col span={6}>
          <Card>
            <Statistic
              title="用户配额使用率"
              value={usage.users?.percentage || 0}
              suffix="%"
            />
            <Progress 
              percent={usage.users?.percentage || 0} 
              size="small"
              status={usage.users?.percentage > 80 ? 'exception' : 'normal'}
            />
            <p>{usage.users?.current || 0} / {usage.users?.limit || 0}</p>
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="消息配额使用率"
              value={usage.messages?.percentage || 0}
              suffix="%"
            />
            <Progress 
              percent={usage.messages?.percentage || 0} 
              size="small"
              status={usage.messages?.percentage > 80 ? 'exception' : 'normal'}
            />
            <p>{usage.messages?.current || 0} / {usage.messages?.limit || 0}</p>
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="API Key"
              value={tenant.apiKey}
              valueStyle={{ fontSize: '14px' }}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="套餐类型"
              value={tenant.planType}
            />
          </Card>
        </Col>
      </Row>

      <Card>
        <Tabs defaultActiveKey="users">
          <TabPane tab="用户管理" key="users">
            <Table
              columns={userColumns}
              dataSource={tenant.users}
              rowKey="id"
              pagination={{ pageSize: 10 }}
            />
          </TabPane>
          
          <TabPane tab="会话管理" key="conversations">
            <Table
              columns={conversationColumns}
              dataSource={tenant.conversations}
              rowKey="id"
              pagination={{ pageSize: 10 }}
            />
          </TabPane>
          
          <TabPane tab="设置" key="settings">
            <pre>{JSON.stringify(tenant.settings, null, 2)}</pre>
          </TabPane>
        </Tabs>
      </Card>
    </div>
  );
};
```

## 7. SDK开发

### 7.1 JavaScript SDK

```typescript
// packages/sdk-js/src/index.ts
export class MessageCoreSDK {
  private apiKey: string;
  private baseUrl: string;
  private wsUrl: string;
  private socket: WebSocket | null = null;
  private eventHandlers: Map<string, Function[]> = new Map();

  constructor(config: {
    apiKey: string;
    baseUrl?: string;
    wsUrl?: string;
  }) {
    this.apiKey = config.apiKey;
    this.baseUrl = config.baseUrl || 'https://api.messagecore.goldsky.com';
    this.wsUrl = config.wsUrl || 'wss://realtime.messagecore.goldsky.com';
  }

  // HTTP API方法
  async sendMessage(data: {
    conversationId: string;
    senderId: string;
    type: 'text' | 'image' | 'file';
    content: any;
    replyToId?: string;
  }) {
    const response = await fetch(`${this.baseUrl}/api/v1/messages/send`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': this.apiKey,
      },
      body: JSON.stringify(data),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    return response.json();
  }

  async getMessages(conversationId: string, options?: {
    page?: number;
    limit?: number;
    before?: string;
  }) {
    const params = new URLSearchParams({
      page: String(options?.page || 1),
      limit: String(options?.limit || 50),
      ...(options?.before && { before: options.before }),
    });

    const response = await fetch(
      `${this.baseUrl}/api/v1/messages/conversations/${conversationId}?${params}`,
      {
        headers: {
          'X-API-Key': this.apiKey,
        },
      }
    );

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    return response.json();
  }

  async createConversation(data: {
    type: string;
    title?: string;
    participantIds: string[];
    metadata?: any;
  }) {
    const response = await fetch(`${this.baseUrl}/api/v1/messages/conversations`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': this.apiKey,
      },
      body: JSON.stringify(data),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    return response.json();
  }

  // WebSocket方法
  connect(userToken: string) {
    if (this.socket) {
      this.disconnect();
    }

    this.socket = new WebSocket(this.wsUrl);
    
    this.socket.onopen = () => {
      // 发送认证信息
      this.send('authenticate', {
        apiKey: this.apiKey,
        token: userToken,
      });
      
      this.emit('connected');
    };

    this.socket.onmessage = (event) => {
      const data = JSON.parse(event.data);
      this.emit(data.type, data.data);
    };

    this.socket.onclose = () => {
      this.emit('disconnected');
    };

    this.socket.onerror = (error) => {
      this.emit('error', error);
    };
  }

  disconnect() {
    if (this.socket) {
      this.socket.close();
      this.socket = null;
    }
  }

  joinConversation(conversationId: string) {
    this.send('join_conversation', { conversationId });
  }

  leaveConversation(conversationId: string) {
    this.send('leave_conversation', { conversationId });
  }

  startTyping(conversationId: string) {
    this.send('typing_start', { conversationId });
  }

  stopTyping(conversationId: string) {
    this.send('typing_stop', { conversationId });
  }

  // 事件处理
  on(event: string, handler: Function) {
    if (!this.eventHandlers.has(event)) {
      this.eventHandlers.set(event, []);
    }
    this.eventHandlers.get(event)!.push(handler);
  }

  off(event: string, handler?: Function) {
    if (!handler) {
      this.eventHandlers.delete(event);
    } else {
      const handlers = this.eventHandlers.get(event);
      if (handlers) {
        const index = handlers.indexOf(handler);
        if (index > -1) {
          handlers.splice(index, 1);
        }
      }
    }
  }

  private emit(event: string, data?: any) {
    const handlers = this.eventHandlers.get(event);
    if (handlers) {
      handlers.forEach(handler => handler(data));
    }
  }

  private send(type: string, data: any) {
    if (this.socket && this.socket.readyState === WebSocket.OPEN) {
      this.socket.send(JSON.stringify({ type, data }));
    }
  }
}

// 使用示例
const sdk = new MessageCoreSDK({
  apiKey: 'your-api-key',
});

// 连接WebSocket
sdk.connect('user-token');

// 监听事件
sdk.on('new_message', (message) => {
  console.log('New message:', message);
});

sdk.on('user_typing', (data) => {
  console.log('User typing:', data);
});

// 发送消息
sdk.sendMessage({
  conversationId: 'conv-123',
  senderId: 'user-456',
  type: 'text',
  content: { text: 'Hello, world!' }
});
```

### 7.2 Flutter SDK

```dart
// packages/sdk-flutter/lib/messagecore_sdk.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class MessageCoreSDK {
  final String apiKey;
  final String baseUrl;
  final String wsUrl;
  
  WebSocketChannel? _channel;
  final Map<String, List<Function>> _eventHandlers = {};
  
  MessageCoreSDK({
    required this.apiKey,
    this.baseUrl = 'https://api.messagecore.goldsky.com',
    this.wsUrl = 'wss://realtime.messagecore.goldsky.com',
  });

  // HTTP API方法
  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String senderId,
    required String type,
    required Map<String, dynamic> content,
    String? replyToId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/messages/send'),
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': apiKey,
      },
      body: jsonEncode({
        'conversationId': conversationId,
        'senderId': senderId,
        'type': type,
        'content': content,
        'replyToId': replyToId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send message: ${response.statusCode}');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
    String? before,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (before != null) 'before': before,
    };

    final uri = Uri.parse('$baseUrl/api/v1/messages/conversations/$conversationId')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'X-API-Key': apiKey,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get messages: ${response.statusCode}');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> createConversation({
    required String type,
    String? title,
    required List<String> participantIds,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/messages/conversations'),
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': apiKey,
      },
      body: jsonEncode({
        'type': type,
        'title': title,
        'participantIds': participantIds,
        'metadata': metadata,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create conversation: ${response.statusCode}');
    }

    return jsonDecode(response.body);
  }

  // WebSocket方法
  void connect(String userToken) {
    if (_channel != null) {
      disconnect();
    }

    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    
    // 发送认证信息
    _send('authenticate', {
      'apiKey': apiKey,
      'token': userToken,
    });

    _channel!.stream.listen(
      (data) {
        final message = jsonDecode(data);
        _emit(message['type'], message['data']);
      },
      onDone: () {
        _emit('disconnected', null);
      },
      onError: (error) {
        _emit('error', error);
      },
    );

    _emit('connected', null);
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void joinConversation(String conversationId) {
    _send('join_conversation', {'conversationId': conversationId});
  }

  void leaveConversation(String conversationId) {
    _send('leave_conversation', {'conversationId': conversationId});
  }

  void startTyping(String conversationId) {
    _send('typing_start', {'conversationId': conversationId});
  }

  void stopTyping(String conversationId) {
    _send('typing_stop', {'conversationId': conversationId});
  }

  // 事件处理
  void on(String event, Function handler) {
    _eventHandlers[event] ??= [];
    _eventHandlers[event]!.add(handler);
  }

  void off(String event, [Function? handler]) {
    if (handler == null) {
      _eventHandlers.remove(event);
    } else {
      _eventHandlers[event]?.remove(handler);
    }
  }

  void _emit(String event, dynamic data) {
    final handlers = _eventHandlers[event];
    if (handlers != null) {
      for (final handler in handlers) {
        handler(data);
      }
    }
  }

  void _send(String type, Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': type,
        'data': data,
      }));
    }
  }
}

// 使用示例
class MessageHubExample {
  late MessageCoreSDK sdk;

  void initializeSDK() {
    sdk = MessageCoreSDK(apiKey: 'your-api-key');
    
    // 监听事件
    sdk.on('new_message', (message) {
      print('New message: $message');
    });
    
    sdk.on('user_typing', (data) {
      print('User typing: $data');
    });
    
    // 连接WebSocket
    sdk.connect('user-token');
  }

  Future<void> sendMessage() async {
    try {
      final result = await sdk.sendMessage(
        conversationId: 'conv-123',
        senderId: 'user-456',
        type: 'text',
        content: {'text': 'Hello from Flutter!'},
      );
      print('Message sent: $result');
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}
```

## 8. 部署运维

### 8.1 Docker配置

```dockerfile
# infrastructure/docker/api.Dockerfile
FROM node:18-alpine

WORKDIR /app

# 复制package文件
COPY package*.json ./
COPY packages/shared/package*.json ./packages/shared/
COPY apps/api/package*.json ./apps/api/

# 安装依赖
RUN npm ci --only=production

# 复制源代码
COPY packages/shared ./packages/shared
COPY apps/api ./apps/api

# 构建应用
RUN npm run build -w apps/api

EXPOSE 3000

CMD ["npm", "run", "start", "-w", "apps/api"]
```

```dockerfile
# infrastructure/docker/realtime.Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
COPY packages/shared/package*.json ./packages/shared/
COPY apps/realtime/package*.json ./apps/realtime/

RUN npm ci --only=production

COPY packages/shared ./packages/shared
COPY apps/realtime ./apps/realtime

RUN npm run build -w apps/realtime

EXPOSE 3001

CMD ["npm", "run", "start", "-w", "apps/realtime"]
```

### 8.2 Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: messagecore
      POSTGRES_USER: messagecore
      POSTGRES_PASSWORD: your-password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  api:
    build:
      context: .
      dockerfile: infrastructure/docker/api.Dockerfile
    environment:
      DATABASE_URL: postgresql://messagecore:your-password@postgres:5432/messagecore
      REDIS_URL: redis://redis:6379
      JWT_SECRET: your-jwt-secret
    ports:
      - "3000:3000"
    depends_on:
      - postgres
      - redis

  realtime:
    build:
      context: .
      dockerfile: infrastructure/docker/realtime.Dockerfile
    environment:
      DATABASE_URL: postgresql://messagecore:your-password@postgres:5432/messagecore
      REDIS_URL: redis://redis:6379
    ports:
      - "3001:3001"
    depends_on:
      - postgres
      - redis

  admin:
    build:
      context: .
      dockerfile: infrastructure/docker/admin.Dockerfile
    environment:
      REACT_APP_API_URL: http://localhost:3000
    ports:
      - "3002:3000"

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./infrastructure/nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./infrastructure/ssl:/etc/ssl
    depends_on:
      - api
      - realtime
      - admin

volumes:
  postgres_data:
  redis_data:
```

### 8.3 Kubernetes部署

```yaml
# infrastructure/k8s/api-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: messagecore-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: messagecore-api
  template:
    metadata:
      labels:
        app: messagecore-api
    spec:
      containers:
      - name: api
        image: messagecore/api:latest
        ports:
        - containerPort: 3000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: messagehub-secrets
              key: database-url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: messagehub-secrets
              key: redis-url
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: messagehub-secrets
              key: jwt-secret
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5

---
apiVersion: v1
kind: Service
metadata:
  name: messagehub-api-service
spec:
  selector:
    app: messagehub-api
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: ClusterIP
```

### 8.4 监控配置

```yaml
# infrastructure/monitoring/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'messagehub-api'
    static_configs:
      - targets: ['api:3000']
    metrics_path: /metrics
    scrape_interval: 5s

  - job_name: 'messagehub-realtime'
    static_configs:
      - targets: ['realtime:3001']
    metrics_path: /metrics
    scrape_interval: 5s

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:5432']

  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']
```

### 8.5 自动化部署脚本

```bash
#!/bin/bash
# scripts/deploy.sh

set -e

echo "Starting GoldSky MessageCore deployment..."

# 构建Docker镜像
echo "Building Docker images..."
docker build -t messagecore/api:latest -f infrastructure/docker/api.Dockerfile .
docker build -t messagecore/realtime:latest -f infrastructure/docker/realtime.Dockerfile .
docker build -t messagecore/admin:latest -f infrastructure/docker/admin.Dockerfile .

# 推送到镜像仓库
echo "Pushing images to registry..."
docker push messagecore/api:latest
docker push messagecore/realtime:latest
docker push messagecore/admin:latest

# 部署到Kubernetes
echo "Deploying to Kubernetes..."
kubectl apply -f infrastructure/k8s/namespace.yaml
kubectl apply -f infrastructure/k8s/secrets.yaml
kubectl apply -f infrastructure/k8s/configmap.yaml
kubectl apply -f infrastructure/k8s/api-deployment.yaml
kubectl apply -f infrastructure/k8s/realtime-deployment.yaml
kubectl apply -f infrastructure/k8s/admin-deployment.yaml
kubectl apply -f infrastructure/k8s/ingress.yaml

# 等待部署完成
echo "Waiting for deployment to complete..."
kubectl rollout status deployment/messagecore-api
kubectl rollout status deployment/messagecore-realtime
kubectl rollout status deployment/messagecore-admin

echo "Deployment completed successfully!"

# 验证部署
echo "Verifying deployment..."
kubectl get pods -l app=messagecore-api
kubectl get pods -l app=messagecore-realtime
kubectl get pods -l app=messagecore-admin

echo "GoldSky MessageCore is now running!"
```

## 总结

GoldSky MessageCore产品从0到1的构建包含以下关键步骤：

### 🎯 **开发时间线 (12-16周)**

1. **架构设计** (2周)
   - 技术选型确定
   - 数据库设计
   - 系统架构设计

2. **多租户系统** (3周)
   - 租户管理
   - 资源隔离
   - 配额管理

3. **核心API开发** (4周)
   - 消息API
   - 会话管理
   - 文件服务

4. **实时通信** (3周)
   - WebSocket服务
   - 实时推送
   - 在线状态

5. **管理后台** (2周)
   - React管理面板
   - 租户管理界面
   - 监控面板

6. **SDK开发** (3周)
   - JavaScript SDK
   - Flutter SDK
   - 文档和示例

7. **部署运维** (2-3周)
   - Docker容器化
   - Kubernetes部署
   - 监控系统

### 🚀 **商业化路径**

1. **MVP验证**: 先在JinBean内部使用，验证技术可行性
2. **友好用户测试**: 邀请3-5家小客户试用
3. **产品完善**: 根据反馈完善功能和体验
4. **正式商业化**: 推广给更多SMB客户

### 💰 **预期成本**

- **开发成本**: 3-4名工程师 × 4个月 ≈ $50-80K
- **基础设施**: $500-2000/月 (初期)
- **运营成本**: $5-15K/月

按照这个指南，您可以在4个月内完成GoldSky MessageCore的MVP版本开发。 