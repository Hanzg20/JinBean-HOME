# Provider端部署指南

## 🚀 部署概览

本指南详细说明如何将Provider端功能部署到生产环境。

## 📋 部署前检查清单

### 代码质量检查
- [x] 所有测试通过
- [x] 代码审查完成
- [x] 性能测试达标
- [x] 安全审查通过

### 环境准备
- [x] 生产环境配置
- [x] 数据库迁移脚本
- [x] 环境变量配置
- [x] 监控工具配置

### 文档准备
- [x] 技术文档完整
- [x] 用户手册更新
- [x] 故障排除指南
- [x] 回滚计划准备

## 🏗️ 环境配置

### 1. 生产环境要求

#### 服务器配置
- **操作系统**: Ubuntu 20.04 LTS 或更高版本
- **CPU**: 4核心或以上
- **内存**: 8GB或以上
- **存储**: 100GB SSD
- **网络**: 稳定的互联网连接

#### 软件依赖
- **Flutter**: 3.16.0或更高版本
- **Dart**: 3.2.0或更高版本
- **Node.js**: 18.x或更高版本
- **PostgreSQL**: 14.x或更高版本
- **Redis**: 6.x或更高版本（可选，用于缓存）

### 2. 环境变量配置

创建 `.env` 文件：

```bash
# Supabase配置
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

# 应用配置
APP_NAME=JinBean Provider
APP_VERSION=1.0.0
ENVIRONMENT=production

# 数据库配置
DATABASE_URL=your_database_url
DATABASE_POOL_SIZE=20

# 缓存配置
REDIS_URL=your_redis_url

# 监控配置
SENTRY_DSN=your_sentry_dsn
LOG_LEVEL=info

# 支付配置
STRIPE_PUBLISHABLE_KEY=your_stripe_key
STRIPE_SECRET_KEY=your_stripe_secret

# 通知配置
FIREBASE_SERVER_KEY=your_firebase_key
```

### 3. 数据库配置

#### PostgreSQL配置
```sql
-- 创建数据库用户
CREATE USER jinbean_provider WITH PASSWORD 'secure_password';

-- 创建数据库
CREATE DATABASE jinbean_provider_db OWNER jinbean_provider;

-- 授予权限
GRANT ALL PRIVILEGES ON DATABASE jinbean_provider_db TO jinbean_provider;

-- 启用扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
```

#### 数据库迁移
```bash
# 运行数据库迁移脚本
psql -h localhost -U jinbean_provider -d jinbean_provider_db -f Docu/database_schema/create_all_tables.sql
```

## 📦 构建和部署

### 1. 代码构建

#### Flutter构建
```bash
# 清理项目
flutter clean

# 获取依赖
flutter pub get

# 构建生产版本
flutter build apk --release
flutter build ios --release
```

#### Web构建（如果需要）
```bash
# 构建Web版本
flutter build web --release

# 优化构建
flutter build web --release --web-renderer html
```

### 2. 部署步骤

#### 步骤1: 准备部署环境
```bash
# 克隆代码
git clone https://github.com/Hanzg20/JinBean-HOME.git
cd JinBean-HOME

# 切换到Provider分支
git checkout feature/provider-core-features

# 安装依赖
flutter pub get
```

#### 步骤2: 配置环境变量
```bash
# 复制环境变量模板
cp .env.example .env

# 编辑环境变量
nano .env
```

#### 步骤3: 运行数据库迁移
```bash
# 执行数据库迁移
./scripts/run_migrations.sh
```

#### 步骤4: 构建应用
```bash
# 构建Android版本
flutter build apk --release

# 构建iOS版本
flutter build ios --release
```

#### 步骤5: 部署到应用商店

##### Android部署
```bash
# 签名APK
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore android/app/upload-keystore.jks android/app/build/outputs/flutter-apk/app-release.apk upload

# 优化APK
zipalign -v 4 android/app/build/outputs/flutter-apk/app-release.apk android/app/build/outputs/flutter-apk/app-release-optimized.apk
```

##### iOS部署
```bash
# 构建Archive
flutter build ios --release --no-codesign

# 使用Xcode进行签名和上传
open ios/Runner.xcworkspace
```

### 3. 服务器部署（Web版本）

#### Nginx配置
```nginx
server {
    listen 80;
    server_name provider.jinbean.com;
    
    root /var/www/jinbean-provider;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /api {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location /static {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

#### PM2配置
```json
{
  "name": "jinbean-provider",
  "script": "server.js",
  "instances": "max",
  "exec_mode": "cluster",
  "env": {
    "NODE_ENV": "production",
    "PORT": 3000
  }
}
```

## 🔧 监控和日志

### 1. 应用监控

#### Sentry配置
```dart
// 在main.dart中配置Sentry
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'your_sentry_dsn';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(MyApp()),
  );
}
```

#### 性能监控
```dart
// 添加性能监控
import 'package:flutter_performance/flutter_performance.dart';

class PerformanceMonitor {
  static void trackPageLoad(String pageName) {
    PerformanceMonitor.trackEvent('page_load', {
      'page': pageName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
```

### 2. 日志配置

#### 日志级别
```dart
// 配置日志级别
import 'package:logger/logger.dart';

final logger = Logger(
  level: Level.info,
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);
```

#### 日志文件
```bash
# 配置日志轮转
sudo logrotate -f /etc/logrotate.d/jinbean-provider
```

## 🔒 安全配置

### 1. 网络安全

#### SSL证书
```bash
# 安装Let's Encrypt证书
sudo certbot --nginx -d provider.jinbean.com
```

#### 防火墙配置
```bash
# 配置UFW防火墙
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

### 2. 数据安全

#### 数据库加密
```sql
-- 启用数据库加密
ALTER DATABASE jinbean_provider_db SET encryption = 'on';
```

#### 备份策略
```bash
# 创建备份脚本
#!/bin/bash
pg_dump jinbean_provider_db > backup_$(date +%Y%m%d_%H%M%S).sql
```

## 📊 性能优化

### 1. 应用优化

#### 代码分割
```dart
// 使用懒加载
class LazyLoadedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadModule(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data;
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

#### 缓存策略
```dart
// 实现缓存
class CacheManager {
  static final Map<String, dynamic> _cache = {};
  
  static void set(String key, dynamic value) {
    _cache[key] = value;
  }
  
  static dynamic get(String key) {
    return _cache[key];
  }
}
```

### 2. 服务器优化

#### Nginx优化
```nginx
# 启用Gzip压缩
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
```

#### 数据库优化
```sql
-- 创建索引
CREATE INDEX idx_orders_provider_id ON orders(provider_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
```

## 🚨 故障排除

### 1. 常见问题

#### 构建失败
```bash
# 清理并重新构建
flutter clean
flutter pub get
flutter build apk --release
```

#### 数据库连接失败
```bash
# 检查数据库连接
psql -h localhost -U jinbean_provider -d jinbean_provider_db -c "SELECT 1;"
```

#### 应用崩溃
```bash
# 查看应用日志
flutter logs
```

### 2. 回滚计划

#### 代码回滚
```bash
# 回滚到上一个版本
git revert HEAD
git push origin feature/provider-core-features
```

#### 数据库回滚
```bash
# 恢复数据库备份
psql -h localhost -U jinbean_provider -d jinbean_provider_db < backup_file.sql
```

## 📞 支持联系

### 技术支持
- **邮箱**: tech-support@jinbean.com
- **电话**: +1-800-JINBEAN
- **在线支持**: https://support.jinbean.com

### 紧急联系
- **运维团队**: ops@jinbean.com
- **开发团队**: dev@jinbean.com
- **产品团队**: product@jinbean.com

---

**部署状态**: 🚀 **准备就绪**  
**最后更新**: 2024年12月  
**文档版本**: v1.0 