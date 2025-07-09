# Database Design Document

> 本文件为 JinBean 数据库主设计文档，详细内容见本目录 README.md。

## 目录
1. 概述与设计原则
2. ER 图
3. 表结构与关系说明
4. 地址管理策略
5. 用户认证与权限模型
6. 字典与地区/分类编码
7. 其它说明
8. 附录

---

## 1. 概述与设计原则
// ... 合并原 database design.md 概述、设计原则 ...

## 2. ER 图
// ... 合并 ER图.md 内容，可用 mermaid 或图片 ...

## 3. 表结构与关系说明
// ... 合并原 database design.md 表结构章节 ...

## 4. 地址管理策略
// ... 合并 address_management_strategy.md ...

## 5. 用户认证与权限模型
// ... 合并 user_auth_schema.md ...

## 6. 字典与地区/分类编码
// ... 合并 ref_codes_data.md ...

## 7. 其它说明
// ... 其它相关设计说明 ...

## 8. 附录
// ... 迁移脚本、历史变更、特殊说明等 ... # 地址管理策略与实现方案

## 1. 设计原则

### 1.1 按需动态插入策略
- **不一次性导入全量地址库**：避免存储大量无用数据，节省存储空间和维护成本
- **用户输入时动态创建**：根据用户实际输入的地址，按需插入到 `addresses` 表
- **智能去重机制**：基于邮编和街道名进行去重，避免重复地址记录

### 1.2 标准化地址结构
- 采用加拿大 Civic Address 标准
- 支持结构化字段：国家、省/地区、城市、区/社区、门牌号、街道名、街道类型、邮编、经纬度等
- 便于地理分析、距离计算、服务区域匹配等业务需求

## 2. 数据库设计

### 2.1 addresses 表结构
```sql
CREATE TABLE public.addresses (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    standard_address_id text,                       -- 标准地址唯一编码
    country text DEFAULT 'Canada',                  -- 国家
    province text,                                  -- 省/地区
    city text,                                      -- 城市
    district text,                                  -- 区/社区
    street_number text,                             -- 门牌号
    street_name text,                               -- 街道名
    street_type text,                               -- 街道类型
    street_direction text,                          -- 街道方向
    suite_unit text,                                -- 单元/房间号
    postal_code text,                               -- 邮编
    latitude numeric,                               -- 纬度
    longitude numeric,                              -- 经度
    geonames_id integer,                            -- GeoNames/官方地址库ID
    extra jsonb,                                    -- 其它补充信息
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);
```

### 2.2 provider_profiles 表关联
```sql
-- 使用 address_id 外键关联
address_id uuid REFERENCES public.addresses(id)
```

## 3. 实现方案

### 3.1 地址服务类 (AddressService)
- **统一地址处理逻辑**：解析、验证、去重、数据库操作
- **加拿大地址格式支持**：邮编格式 A1A 1A1、省份缩写、城市解析
- **智能去重机制**：基于邮编和街道名的唯一性检查

### 3.2 地址解析功能
- **邮编提取**：正则匹配加拿大邮编格式
- **街道名提取**：去除邮编、城市、省份信息，提取纯街道名
- **城市提取**：从逗号分隔的地址中提取城市名
- **省份提取**：匹配加拿大省份缩写

### 3.3 用户体验优化
- **实时地址解析显示**：用户输入时实时显示解析结果
- **格式验证**：确保地址包含必要信息（邮编、城市、街道）
- **输入提示**：提供标准格式示例和说明

## 4. 工作流程

### 4.1 地址处理流程
1. 用户输入地址
2. 前端实时解析并显示结果
3. 提交时调用 AddressService.getOrCreateAddress()
4. 检查地址是否已存在（基于邮编+街道名）
5. 如存在则复用 address_id，如不存在则创建新记录
6. 返回 address_id 用于业务表关联

### 4.2 去重策略
- **唯一性检查**：邮编 + 街道名组合
- **避免重复插入**：相同地址只创建一条记录
- **数据一致性**：所有业务表引用同一个 address_id

## 5. 扩展性设计

### 5.1 地理信息扩展
- 预留经纬度字段，支持地图定位
- 预留 geonames_id，支持与权威地址库对接
- 支持服务半径计算、距离排序等功能

### 5.2 地址库集成
- 可后续集成 Google Places API 自动补全
- 可集成 Canada Post AddressComplete API
- 可批量导入高频地址（如主要城市中心区域）

### 5.3 多表复用
- user_profiles 表可复用 address_id
- orders 表可复用 address_id
- 其他需要地址信息的表均可复用

## 6. 最佳实践

### 6.1 地址输入规范
- 要求用户输入完整地址：门牌号 + 街道 + 城市 + 省份 + 邮编
- 提供标准格式示例：`123 Bank St, Ottawa, ON K2P 1L4`
- 实时验证和提示，确保数据质量

### 6.2 性能优化
- 地址查询使用索引：postal_code, street_name
- 避免重复解析，缓存解析结果
- 批量操作时考虑事务处理

### 6.3 错误处理
- 地址格式验证失败时的友好提示
- 网络异常时的重试机制
- 数据库操作异常时的回滚处理

## 7. 后续优化方向

### 7.1 地址自动补全
- 集成 Google Places API
- 集成 Canada Post AddressComplete API
- 本地地址库缓存

### 7.2 地理分析功能
- 服务半径计算
- 距离排序
- 地理围栏
- 热力图分析

### 7.3 数据质量提升
- 地址标准化
- 错误地址检测
- 地址验证服务集成

---

**总结**：本方案采用按需动态插入策略，既保证了数据标准化和一致性，又避免了全量导入的存储和维护成本。通过 AddressService 统一管理地址逻辑，提供了良好的用户体验和扩展性。 # 用户认证与个人中心数据结构设计

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
``` # Ref Codes Data (全量分类数据维护)

本文件用于维护 JinBean 项目 ref_codes 表的所有分类数据，便于多语言、层级、图标等批量管理。

## 字段说明
- **id**: 主键ID
- **type_code**: 分类类型（如 SERVICE_TYPE）
- **code**: 唯一编码
- **name.zh**: 中文名称
- **name.en**: 英文名称
- **parent_id**: 父级ID（一级为 null）
- **level**: 层级（1/2/3）
- **sort_order**: 排序
- **status**: 1=启用, 0=禁用
- **icon**: 图标（extra_data.icon）

> name 字段为 jsonb 结构，如： {"zh": "家政到家", "en": "Home Help"}

---

## 分类数据表（表结构）


| id  | type_code    | code                | chinese_name | english_name               | parent_id | level | description | sort_order | status | created_at                    | updated_at                    | extra_data                       |
| --- | ------------ | ------------------- | ------------ | -------------------------- | --------- | ----- | ----------- | ---------- | ------ | ----------------------------- | ----------------------------- | -------------------------------- |
| 1   | SERVICE_TYPE | DINING              | 餐饮美食         | Dining                     | null      | 1     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"restaurant"}            |
| 20  | SERVICE_TYPE | HOME_SERVICES       | 家居服务         | Home Services              | null      | 1     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"home"}                  |
| 40  | SERVICE_TYPE | TRANSPORTATION      | 出行交通         | Transportation             | null      | 1     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"directions_car"}        |
| 55  | SERVICE_TYPE | RENTAL_SHARE        | 租赁共享         | Rental & Share             | null      | 1     | null        | 4          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"share"}                 |
| 70  | SERVICE_TYPE | LEARNING            | 学习成长         | Learning                   | null      | 1     | null        | 5          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"school"}                |
| 90  | SERVICE_TYPE | PRO_GIGS            | 专业速帮         | Pro & Gigs                 | null      | 1     | null        | 6          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"work"}                  |
| 2   | SERVICE_TYPE | HOME_MEALS          | 家庭餐          | Home Meals                 | 1         | 2     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"home"}                  |
| 3   | SERVICE_TYPE | HOME_KITCHEN        | 家庭厨房         | Home Kitchen               | 2         | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"kitchen"}               |
| 4   | SERVICE_TYPE | PRIVATE_CHEF        | 私厨服务         | Private Chef               | 2         | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"person"}                |
| 5   | SERVICE_TYPE | HOMESTYLE_DELIVERY  | 食材配送        |  Delivery         | 2         | 3     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"delivery_dining"}       |
| 6   | SERVICE_TYPE | CUSTOM_CATERING     | 美食定制         | Custom Catering            | 1         | 2     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"cake"}                  |
| 7   | SERVICE_TYPE | GATHERING_MEALS     | 聚会宴席         | Gathering Meals            | 6         | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"groups"}                |
| 8   | SERVICE_TYPE | CAKE_CUSTOM         | 蛋糕定制         | Cake Custom                | 6         | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"cake"}                  |
| 9   | SERVICE_TYPE | BREAKFAST_BENTO     | 早餐便当         | Breakfast Bento            | 6         | 3     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"breakfast_dining"}      |
| 10  | SERVICE_TYPE | DIVERSE_DINING      | 餐饮多样         | Diverse Dining             | 1         | 2     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"diversity_3"}           |
| 11  | SERVICE_TYPE | ASIAN_CUISINE       | 中餐/韩餐/东南亚餐   | Chinese/Korean/SEA Cuisine | 10        | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"ramen_dining"}          |
| 12  | SERVICE_TYPE | COFFEE_TEA          | 咖啡茶饮         | Coffee & Tea               | 10        | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"local_cafe"}            |
| 13  | SERVICE_TYPE | EXOTIC_FOOD         | 异国料理         | Exotic Food                | 10        | 3     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"restaurant_menu"}       |
| 15  | SERVICE_TYPE | GROCERY_DELIVERY    | 食材代购配送       | Grocery Shop&Delivery      | 1         | 2     | null        | 4          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"shopping_cart"}         |
| 16  | SERVICE_TYPE | FOOD_DELIVERY       | 餐饮配送         | Food Delivery              | 1         | 2     | null        | 5          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"delivery_dining"}       |
| 21  | SERVICE_TYPE | CLEANING            | 清洁维护         | Cleaning                   | 20        | 2     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"cleaning_services"}     |
| 22  | SERVICE_TYPE | HOME_CLEAN          | 居家清洁         | Home Clean                 | 21        | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"cleaning_services"}     |
| 23  | SERVICE_TYPE | POST_RENO_CLEAN     | 装修清洁         | Post-Reno Clean            | 21        | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"construction"}          |
| 24  | SERVICE_TYPE | DEEP_CLEAN          | 深度清洁         | Deep Clean                 | 21        | 3     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"cleaning_services"}     |
| 25  | SERVICE_TYPE | PLUMBING            | 管道疏通         | Plumbing                   | 21        | 3     | null        | 4          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"plumbing"}              |
| 26  | SERVICE_TYPE | FURNITURE           | 家具安装         | Furniture                  | 20        | 2     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"chair"}                 |
| 27  | SERVICE_TYPE | FURNITURE_ASSM      | 家具安装         | Furniture Assm             | 26        | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"build"}                 |
| 28  | SERVICE_TYPE | WALL_REPAIR         | 墙修/涂刷        | Wall Repair/Paint          | 26        | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"format_paint"}          |
| 29  | SERVICE_TYPE | APPLIANCE_INSTALL   | 家电装/修        | Appliance Install/Repair   | 26        | 3     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"electrical_services"}   |
| 30  | SERVICE_TYPE | GARDENING           | 园艺户外         | Gardening                  | 20        | 2     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"landscape"}             |
| 31  | SERVICE_TYPE | LAWN_MOWING         | 割草修剪         | Lawn Mowing                | 30        | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"grass"}                 |
| 32  | SERVICE_TYPE | GARDEN_MAIN         | 园艺维护         | Garden Main                | 30        | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"park"}                  |
| 33  | SERVICE_TYPE | SNOW_REMOVAL        | 铲雪服务         | Snow Removal               | 30        | 3     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"ac_unit"}               |
| 34  | SERVICE_TYPE | PET_CARE            | 宠物服务         | Pet Care                   | 20        | 2     | null        | 4          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"pets"}                  |
| 35  | SERVICE_TYPE | PET_SIT             | 宠物照料         | Pet Sit                    | 34        | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"pets"}                  |
| 36  | SERVICE_TYPE | DOG_WALK            | 遛宠           | Dog Walk                   | 34        | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"directions_walk"}       |
| 37  | SERVICE_TYPE | REAL_ESTATE         | 房产空间         | Real Estate                | 20        | 2     | null        | 5          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"home_work"}             |
| 38  | SERVICE_TYPE | REAL_ESTATE_AGENT   | 房屋经纪         | Real Estate                | 37        | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"real_estate_agent"}     |
| 39  | SERVICE_TYPE | HOME_ENTERTAINMENT  | 家庭娱乐         | Home Entertainment         | 37        | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"sports_esports"}        |
| 41  | SERVICE_TYPE | DAILY_SHUTTLE       | 日常接送         | Daily Shuttle              | 40        | 2     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"airport_shuttle"}       |
| 42  | SERVICE_TYPE | AIRPORT_TRANSFER    | 机场接送         | Airport Transfer           | 41        | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"flight"}                |
| 43  | SERVICE_TYPE | SCHOOL_SHUTTLE      | 学校接送         | School Shuttle             | 41        | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"school"}                |
| 44  | SERVICE_TYPE | CARPOOLING          | 拼车           | Carpooling                 | 41        | 3     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"group"}                 |
| 45  | SERVICE_TYPE | COURIER_SHOP        | 快递代购         | Courier & Shop             | 40        | 2     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"local_shipping"}        |
| 46  | SERVICE_TYPE | SAME_CITY_COURIER   | 同城快递         | Same-City Courier          | 45        | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"local_shipping"}        |
| 47  | SERVICE_TYPE | PACKAGE_SERVICE     | 包裹代收寄        | Package Service            | 45        | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"inventory_2"}           |
| 48  | SERVICE_TYPE | SHOPPING_SERVICE    | 代购           | Local/IntShop              | 45        | 3     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"shopping_bag"}          |
| 49  | SERVICE_TYPE | MOVING              | 移动搬运         | Moving                     | 40        | 2     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"move_to_inbox"}         |
| 50  | SERVICE_TYPE | MOVING_SERVICE      | 搬家           | Moving                     | 49        | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"home"}                  |
| 51  | SERVICE_TYPE | CHAUFFEUR           | 代驾           | Chauffeur                  | 49        | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"drive_eta"}             |
| 52  | SERVICE_TYPE | ERRANDS             | 跑腿           | Errands                    | 40        | 2     | null        | 4          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"directions_run"}        |
| 53  | SERVICE_TYPE | QUEUE_PICKUP        | 代办(排队/领物)    | Errands (Queue/Pickup)     | 52        | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"queue"}                 |
| 56  | SERVICE_TYPE | TOOLS_EQUIP         | 工具设备         | Tools & Equip              | 55        | 2     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"build"}                 |
| 57  | SERVICE_TYPE | TOOL_RENTAL         | 工具租赁         | Tool Rental                | 56        | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"handyman"}              |
| 58  | SERVICE_TYPE | APPLIANCE_RENTAL    | 家电租赁         | Appliance Rental           | 56        | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"electrical_services"}   |
| 59  | SERVICE_TYPE | PHOTO_3D_EQUIP      | 摄影/3D设备      | Photo/3D Equip             | 56        | 3     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"camera_alt"}            |
| 60  | SERVICE_TYPE | SPACE_SHARE         | 空间共享         | Space Share                | 55        | 2     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"space_dashboard"}       |
| 61  | SERVICE_TYPE | TEMP_OFFICE         | 临时办公         | Temp Office                | 60        | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"work"}                  |
| 62  | SERVICE_TYPE | HOME_VENUE          | 家庭场地         | Home Venue                 | 60        | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"home"}                  |
| 63  | SERVICE_TYPE | STORAGE_RENTAL      | 储物租赁         | Storage Rental             | 60        | 3     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"storage"}               |
| 64  | SERVICE_TYPE | KIDS_FAMILY         | 儿童家庭         | Kids & Family              | 55        | 2     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"family_restroom"}       |
| 65  | SERVICE_TYPE | KIDS_PLAY           | 儿童游乐         | Kids\Play                  | 64        | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"child_care"}            |
| 66  | SERVICE_TYPE | BABY_GEAR           | 婴幼用品         | Baby Gear                  | 64        | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"baby_changing_station"} |
| 67  | SERVICE_TYPE | ITEM_SHARE          | 物品共享         | Item Share                 | 55        | 2     | null        | 4          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"share"}                 |
| 68  | SERVICE_TYPE | SECOND_HAND_RENTAL  | 闲置租借         | Second-hand Rental         | 67        | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"recycling"}             |
| 71  | SERVICE_TYPE | ACADEMIC_TUTORING   | 学科辅导         | Academic Tutoring          | 70        | 2     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"menu_book"}             |
| 72  | SERVICE_TYPE | K12_COURSES         | 小初高课程        | K-12 Courses               | 71        | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"school"}                |
| 73  | SERVICE_TYPE | LANGUAGE_COURSES    | 英语/法语        | English/French             | 71        | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"language"}              |
| 74  | SERVICE_TYPE | ONLINE_TUTORING     | 在线1对1        | Online 1-on-1              | 71        | 3     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"video_camera_front"}    |
| 75  | SERVICE_TYPE | ART_HOBBY           | 艺术兴趣         | Art & Hobby                | 70        | 2     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"palette"}               |
| 76  | SERVICE_TYPE | ART_CRAFTS          | 美术手工         | Art & Crafts               | 75        | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"brush"}                 |
| 77  | SERVICE_TYPE | MUSIC_VOCAL         | 乐器/声乐        | Instrument/Vocal           | 75        | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"music_note"}            |
| 78  | SERVICE_TYPE | DANCE_THEATRE       | 舞蹈/戏剧        | Dance/Theatre              | 75        | 3     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"theater_comedy"}        |
| 79  | SERVICE_TYPE | SKILL_GROWTH        | 技能成长         | Skill Growth               | 70        | 2     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"psychology"}            |
| 80  | SERVICE_TYPE | TECH_SKILLS         | 编程/AI/设计     | Coding/AI/Design           | 79        | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"code"}                  |
| 81  | SERVICE_TYPE | ADULT_HOBBY         | 成人兴趣班        | Adult Hobby                | 79        | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"emoji_events"}          |
| 82  | SERVICE_TYPE | SKILL_TRAINING      | 技能培训         | Skill Training             | 79        | 3     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"workspace_premium"}     |
| 83  | SERVICE_TYPE | EDU_SERVICES        | 教育服务         | Edu Services               | 70        | 2     | null        | 4          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"school"}                |
| 84  | SERVICE_TYPE | STUDY_ABROAD        | 留学申请         | Study Abroad Apps          | 83        | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"flight_takeoff"}        |
| 85  | SERVICE_TYPE | IMMIGRATION         | 移民咨询         | Immigration Consult        | 83        | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"people"}                |
| 86  | SERVICE_TYPE | MENTAL_HEALTH       | 心理教育         | Mental Health Edu          | 83        | 3     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"psychology"}            |
| 91  | SERVICE_TYPE | SIMPLE_LABOR        | 简单劳务         | Simple Labor               | 90        | 2     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"handyman"}              |
| 92  | SERVICE_TYPE | HELP_MOVING         | 搬物/安装        | Help Moving/Assm           | 91        | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"move_to_inbox"}         |
| 93  | SERVICE_TYPE | CAREGIVER           | 护工/陪护        | Caregiver                  | 91        | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"health_and_safety"}     |
| 94  | SERVICE_TYPE | NANNY               | 保姆/家政        | Nanny/Housekeeping         | 91        | 3     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"cleaning_services"}     |
| 95  | SERVICE_TYPE | PRO_SERVICES        | 专业服务         | Pro Services               | 90        | 2     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"computer"}              |
| 96  | SERVICE_TYPE | IT_SUPPORT          | IT支持         | IT Support                 | 95        | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"support_agent"}         |
| 97  | SERVICE_TYPE | DESIGN_SERVICES     | 平面/视频设计      | Graphic/Video Design       | 95        | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"design_services"}       |
| 98  | SERVICE_TYPE | PHOTO_VIDEO         | 摄影摄像         | Photo&Video                | 95        | 3     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"camera_alt"}            |
| 99  | SERVICE_TYPE | TRANSLATION         | 翻译/排版        | Trans/Typeset              | 95        | 3     | null        | 4          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"translate"}             |
| 100 | SERVICE_TYPE | CONSULTING          | 咨询顾问         | Consulting                 | 90        | 2     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"business"}              |
| 101 | SERVICE_TYPE | REAL_ESTATE_CONSULT | 房产中介         | Real Estate                | 100       | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"home_work"}             |
| 102 | SERVICE_TYPE | FINANCIAL_CONSULT   | 贷款/保险        | Loan/Insurance             | 100       | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"account_balance"}       |
| 103 | SERVICE_TYPE | TAX_ACCOUNTING      | 税务/会计        | Tax/Accounting             | 100       | 3     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"calculate"}             |
| 104 | SERVICE_TYPE | LEGAL_CONSULT       | 法律咨询         | Legal                      | 100       | 3     | null        | 4          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"gavel"}                 |
| 105 | SERVICE_TYPE | HEALTH_SUPPORT      | 健康支持         | Health Support             | 90        | 2     | null        | 4          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"health_and_safety"}     |
| 106 | SERVICE_TYPE | PHYSIO              | 理疗           | Physio                     | 105       | 3     | null        | 1          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"healing"}               |
| 107 | SERVICE_TYPE | CLINIC_ACCOMPANY    | 陪诊           | Clinic Accompany           | 105       | 3     | null        | 2          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"medical_services"}      |
| 108 | SERVICE_TYPE | DAILY_CARE          | 生活照护         | Daily Care                 | 105       | 3     | null        | 3          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"health_and_safety"}     |
| 121 | SERVICE_TYPE | OTHER_DINING        | 其它餐饮美食       | Other Dining               | 1         | 2     | null        | 6          | 1      | 2025-06-12 22:16:11.756537+00 | 2025-06-12 22:16:11.756537+00 | {"icon":"more_horiz"}            |

> 请将所有历史/现有分类数据按上述表格格式补充完整，便于后续批量生成 SQL 或维护。 