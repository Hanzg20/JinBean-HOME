# 用户认证与个人中心数据结构设计

## 1. 用户认证表设计

### 1.1 users 集合
```javascript
{
  "id": "string",                    // Firebase Auth UID
  "email": "string",                 // 邮箱
  "phone": "string",                 // 手机号
  "username": "string",              // 用户名
  "created_at": "timestamp",         // 创建时间
  "updated_at": "timestamp",         // 更新时间
  "last_login": "timestamp",         // 最后登录时间
  "status": "string",                // 账户状态：active/disabled/banned
  "auth_providers": [{               // 第三方登录信息
    "provider": "string",            // 提供商：google/apple/wechat
    "provider_uid": "string",        // 第三方 UID
    "email": "string",               // 第三方邮箱
    "connected_at": "timestamp"      // 关联时间
  }],
  "device_info": {                   // 设备信息
    "last_device": "string",         // 最后使用设备
    "push_token": "string",          // 推送令牌
    "app_version": "string"          // APP版本
  }
}
```

### 1.2 user_profiles 集合
```javascript
{
  "user_id": "string",              // 关联 users.id
  "avatar_url": "string",           // 头像URL
  "display_name": "string",         // 显示名称
  "gender": "string",               // 性别
  "birthday": "date",               // 生日
  "language": "string",             // 首选语言
  "timezone": "string",             // 时区
  "bio": "string",                  // 个人简介
  "preferences": {                  // 用户偏好设置
    "notification": {               // 通知设置
      "push_enabled": "boolean",    // 推送开关
      "email_enabled": "boolean",   // 邮件开关
      "sms_enabled": "boolean"      // 短信开关
    },
    "privacy": {                    // 隐私设置
      "profile_visible": "boolean", // 个人资料可见性
      "show_online": "boolean"      // 在线状态可见性
    }
  }
}
```

### 1.3 user_addresses 集合
```javascript
{
  "id": "string",
  "user_id": "string",              // 关联 users.id
  "name": "string",                 // 地址名称
  "recipient": "string",            // 收件人
  "phone": "string",               // 联系电话
  "country": "string",             // 国家
  "state": "string",               // 州/省
  "city": "string",                // 城市
  "street": "string",              // 街道
  "postal_code": "string",         // 邮编
  "is_default": "boolean",         // 是否默认地址
  "location": {                    // 地理位置
    "latitude": "number",
    "longitude": "number"
  },
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

### 1.4 user_payment_methods 集合
```javascript
{
  "id": "string",
  "user_id": "string",              // 关联 users.id
  "type": "string",                 // 支付方式类型：card/bank/wallet
  "provider": "string",             // 支付提供商
  "token": "string",               // 支付令牌（加密存储）
  "last_4": "string",              // 卡号后4位
  "is_default": "boolean",         // 是否默认支付方式
  "expires_at": "timestamp",       // 过期时间
  "billing_address": {             // 账单地址
    "address_id": "string"         // 关联 user_addresses.id
  },
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

### 1.5 user_wallet 集合
```javascript
{
  "user_id": "string",              // 关联 users.id
  "balance": "number",              // 金豆余额
  "points": "number",               // 积分
  "currency": "string",             // 货币类型
  "frozen_amount": "number",        // 冻结金额
  "updated_at": "timestamp"         // 更新时间
}
```

### 1.6 user_coupons 集合
```javascript
{
  "id": "string",
  "user_id": "string",              // 关联 users.id
  "coupon_id": "string",            // 优惠券模板ID
  "status": "string",               // 状态：valid/used/expired
  "amount": "number",               // 优惠金额
  "min_order_amount": "number",     // 最低使用金额
  "valid_from": "timestamp",        // 生效时间
  "valid_until": "timestamp",       // 过期时间
  "used_at": "timestamp",           // 使用时间
  "order_id": "string"              // 关联订单ID（如果已使用）
}
```

## 2. 索引设计

### 2.1 users 集合索引
```javascript
// 主索引
- user_id (ASC)

// 复合索引
- email, status
- phone, status
- created_at, status
```

### 2.2 user_profiles 集合索引
```javascript
// 主索引
- user_id (ASC)

// 复合索引
- display_name, user_id
```

### 2.3 user_addresses 集合索引
```javascript
// 复合索引
- user_id, is_default
- user_id, created_at
```

### 2.4 user_payment_methods 集合索引
```javascript
// 复合索引
- user_id, is_default
- user_id, type
```

## 3. 安全规则设计

### 3.1 Firestore 安全规则
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 用户文档访问规则
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId;
    }
    
    // 用户配置文件访问规则
    match /user_profiles/{profileId} {
      allow read: if request.auth.uid == resource.data.user_id;
      allow write: if request.auth.uid == request.resource.data.user_id;
    }
    
    // 地址访问规则
    match /user_addresses/{addressId} {
      allow read, write: if request.auth.uid == resource.data.user_id;
    }
  }
}
```

## 4. 数据迁移考虑

### 4.1 未来可扩展字段
```javascript
// user_profiles 集合可扩展字段
{
  "verification": {                 // 身份验证信息
    "is_verified": "boolean",
    "documents": [{
      "type": "string",            // 证件类型
      "number": "string",          // 证件号码
      "verified_at": "timestamp"
    }]
  },
  "service_preferences": {         // 服务偏好
    "favorite_categories": ["string"],
    "preferred_providers": ["string"]
  },
  "social_links": {               // 社交媒体链接
    "facebook": "string",
    "twitter": "string",
    "instagram": "string"
  }
}
``` 