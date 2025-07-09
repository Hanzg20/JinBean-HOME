# Database Schema Documentation

本目录包含 JinBean 项目的所有数据库设计文档、建表脚本、迁移脚本及相关说明。

## 目录结构
- `database_design.md`：主设计文档，包含ER图、表结构、地址/认证/字典等说明
- `data_dictionary.md`：字段/表详细说明（如有）
- `create_all_tables.sql`：全量建表脚本，推荐初始化数据库时使用
- `users.sql`、`user_profiles.sql` 等：各表单独建表脚本
- `migration_scripts/`：所有数据库结构变更/升级/迁移脚本
- `sample_data.sql`：测试/样例数据（如有）
- `security_guidelines.md`：安全与合规说明（如有）

## 数据库初始化
1. 推荐使用 `create_all_tables.sql` 一键初始化所有表结构。
2. 如需单独维护/升级某表，可使用对应的 `xxx.sql`。
3. 所有历史/增量迁移脚本请见 `migration_scripts/`。

## 文档阅读顺序
1. 建议先阅读 `database_design.md` 了解整体结构与设计原则。
2. 需要字段/表详细信息时查阅 `data_dictionary.md`。
3. 变更历史请查阅 `CHANGELOG.md` 或 `migration_scripts/`。

## 其它注意事项
- `.DS_Store` 等无关文件可删除，不纳入版本管理。
- ER 图建议以图片或 markdown/mermaid 格式嵌入主设计文档。
- 如涉及敏感数据，务必查阅 `security_guidelines.md`。

# 金豆荚数据库设计文档

## 目录
1. [概述](#1-概述)
2. [表结构](#2-表结构)
3. [关系模型](#3-关系模型)
4. [安全策略](#4-安全策略)
5. [触发器](#5-触发器)
6. [索引设计](#6-索引设计)
7. [数据字典](#7-数据字典)

## 1. 概述

本文档描述了金豆荚便民服务平台的数据库设计。数据库使用 PostgreSQL，通过 Supabase 提供服务。主要包含用户认证、用户资料、地址管理、服务商管理等核心功能的数据结构。

## 2. 表结构

### 2.1 用户认证相关表

#### profiles
用户基本资料表，与 auth.users 一对一关联。

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | uuid | PK, FK | 用户ID，关联 auth.users |
| email | text | UNIQUE, NOT NULL | 用户邮箱 |
| display_name | text | | 用户昵称 |
| avatar_url | text | | 头像URL |
| phone_number | text | | 手机号码 |
| user_type | text | NOT NULL | 用户类型：user/provider/admin |
| status | text | NOT NULL | 用户状态：active/inactive/banned |
| created_at | timestamptz | NOT NULL | 创建时间 |
| updated_at | timestamptz | NOT NULL | 更新时间 |

#### user_settings
用户设置表，与 auth.users 一对一关联。

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | uuid | PK, FK | 用户ID，关联 auth.users |
| theme | text | NOT NULL | 主题：light/dark/system |
| language | text | NOT NULL | 语言：zh/en |
| notification_enabled | boolean | NOT NULL | 是否启用通知 |
| email_notification | boolean | NOT NULL | 是否启用邮件通知 |
| sms_notification | boolean | NOT NULL | 是否启用短信通知 |
| push_notification | boolean | NOT NULL | 是否启用推送通知 |
| created_at | timestamptz | NOT NULL | 创建时间 |
| updated_at | timestamptz | NOT NULL | 更新时间 |

### 2.2 地址管理

#### addresses
用户地址表，与 auth.users 多对一关联。

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | uuid | PK | 地址ID |
| user_id | uuid | FK, NOT NULL | 用户ID，关联 auth.users |
| address_type | text | NOT NULL | 地址类型：home/work/other |
| address_line1 | text | NOT NULL | 地址行1 |
| address_line2 | text | | 地址行2 |
| city | text | NOT NULL | 城市 |
| state | text | NOT NULL | 州/省 |
| postal_code | text | NOT NULL | 邮政编码 |
| country | text | NOT NULL | 国家 |
| is_default | boolean | NOT NULL | 是否默认地址 |
| created_at | timestamptz | NOT NULL | 创建时间 |
| updated_at | timestamptz | NOT NULL | 更新时间 |

### 2.3 服务商管理

#### provider_profiles
服务商资料表，与 auth.users 一对一关联。

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | uuid | PK, FK | 用户ID，关联 auth.users |
| business_name | text | NOT NULL | 商家名称 |
| business_description | text | | 商家描述 |
| business_phone | text | | 商家电话 |
| business_email | text | | 商家邮箱 |
| business_address | text | | 商家地址 |
| service_areas | text[] | | 服务区域 |
| service_categories | text[] | | 服务类别 |
| verification_status | text | NOT NULL | 认证状态：pending/verified/rejected |
| verification_documents | text[] | | 认证文档 |
| created_at | timestamptz | NOT NULL | 创建时间 |
| updated_at | timestamptz | NOT NULL | 更新时间 |

## 3. 关系模型

```
auth.users 1:1 profiles
auth.users 1:1 user_settings
auth.users 1:N addresses
auth.users 1:1 provider_profiles (当 user_type = 'provider')
```

## 4. 安全策略

### 4.1 行级安全策略 (RLS)

所有表都启用了行级安全策略，具体策略如下：

#### profiles
- 所有人可查看
- 用户只能插入/更新自己的资料

#### user_settings
- 所有人可查看
- 用户只能插入/更新自己的设置

#### addresses
- 用户只能查看/插入/更新/删除自己的地址

#### provider_profiles
- 所有人可查看
- 服务商只能插入/更新自己的资料

## 5. 触发器

### 5.1 新用户创建触发器
当新用户在 auth.users 中创建时：
1. 自动创建对应的 profiles 记录
2. 自动创建对应的 user_settings 记录

### 5.2 更新时间触发器
所有表都配置了自动更新 updated_at 字段的触发器。

## 6. 索引设计

### 6.1 主键索引
- profiles(id)
- user_settings(id)
- addresses(id)
- provider_profiles(id)

### 6.2 外键索引
- addresses(user_id)
- profiles(id)
- user_settings(id)
- provider_profiles(id)

### 6.3 业务索引
- profiles(email)
- profiles(phone_number)
- profiles(user_type)
- provider_profiles(verification_status)

## 7. 数据字典

### 7.1 用户类型 (user_type)
- user: 普通用户
- provider: 服务商
- admin: 管理员

### 7.2 用户状态 (status)
- active: 活跃
- inactive: 非活跃
- banned: 封禁

### 7.3 主题设置 (theme)
- light: 浅色主题
- dark: 深色主题
- system: 跟随系统

### 7.4 语言设置 (language)
- zh: 中文
- en: 英文

### 7.5 地址类型 (address_type)
- home: 家庭地址
- work: 工作地址
- other: 其他地址

### 7.6 认证状态 (verification_status)
- pending: 待审核
- verified: 已认证
- rejected: 已拒绝 