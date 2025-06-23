# 金豆荚数据库设计文档

## 目录
1. [概述](#1-概述)
2. [数据库选型](#2-数据库选型)
3. [表结构设计](#3-表结构设计)
4. [关系模型](#4-关系模型)
5. [安全策略](#5-安全策略)
6. [触发器设计](#6-触发器设计)
7. [索引设计](#7-索引设计)
8. [数据字典](#8-数据字典)
9. [性能优化](#9-性能优化)
10. [数据迁移](#10-数据迁移)
11. [备份策略](#11-备份策略)
12. [监控方案](#12-监控方案)

## 1. 概述

### 1.1 项目背景
金豆荚便民服务平台是一个面向北美居民的生活服务对接平台，需要处理用户认证、服务管理、订单处理等核心业务数据。

### 1.2 设计目标
- 支持多角色用户管理（普通用户、服务商、管理员）
- 确保数据安全性和完整性
- 提供良好的查询性能
- 支持业务扩展
- 便于维护和管理

### 1.3 核心功能
- 用户认证与授权
- 用户资料管理
- 地址管理
- 服务商管理
- 服务类别管理
- 订单管理
- 支付管理

## 2. 数据库选型

### 2.1 技术选型
- 数据库：PostgreSQL 15
- 服务提供商：Supabase
- 连接方式：PostgreSQL 原生连接

### 2.2 选型理由
1. PostgreSQL 优势：
   - 强大的数据完整性
   - 完善的事务支持
   - 丰富的索引类型
   - 优秀的并发处理能力
   - 强大的 JSON 支持

2. Supabase 优势：
   - 内置身份认证
   - 实时数据订阅
   - 自动 API 生成
   - 内置行级安全策略
   - 便捷的数据库管理

## 3. 表结构设计

### 3.1 用户认证相关表

#### 3.1.1 users (auth.users)
用户基本认证信息表，由 Supabase Auth 管理。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| id | uuid | PK | 用户ID (Firebase Auth UID) | PK |
| email | text | UNIQUE, NOT NULL | 用户邮箱 | UNIQUE |
| phone | text | | 手机号 | |
| username | text | | 用户名 | |
| created_at | timestamptz | NOT NULL | 创建时间 | |
| updated_at | timestamptz | NOT NULL | 更新时间 | |
| last_login | timestamptz | | 最后登录时间 | |
| status | text | NOT NULL | 账户状态：active/disabled/banned | INDEX |
| auth_providers | jsonb | | 第三方登录信息 | |
| device_info | jsonb | | 设备信息 | |

字段说明：
- id: 使用 UUID 类型，由 Supabase Auth 生成
- email: 用户邮箱，用于登录和通知
- phone: 用户手机号，用于短信通知
- username: 用户登录名
- status: 用户状态，用于账号管理
- auth_providers: 存储第三方登录信息，如 Google, Apple, WeChat
- device_info: 存储设备信息，如最后使用设备、推送令牌、APP版本

#### 3.1.2 user_profiles（用户资料表）
用户扩展个人资料表，与 auth.users 一对一关联。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| user_id | uuid | PK, FK | 用户ID，关联 auth.users | PK |
| avatar_url | text | | 头像URL | |
| display_name | text | | 显示名称 | INDEX |
| gender | text | | 性别 | |
| birthday | date | | 生日 | |
| language | text | | 首选语言 | |
| timezone | text | | 时区 | |
| bio | text | | 个人简介 | |
| preferences | jsonb | | 用户偏好设置 | |
| created_at | timestamptz | NOT NULL | 创建时间 | |
| updated_at | timestamptz | NOT NULL | 更新时间 | |

字段说明：
- user_id: 关联 auth.users 的 id
- avatar_url: 用户头像URL，存储在 Supabase Storage
- display_name: 用户显示名称，用于界面展示
- preferences: 存储用户偏好设置，如通知设置、隐私设置

#### 3.1.3 user_settings（用户设置表）
用户个性化设置表，与 auth.users 一对一关联。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| user_id | uuid | PK, FK | 用户ID，关联 auth.users | PK |
| theme | text | NOT NULL | 主题设置 | |
| language | text | NOT NULL | 语言设置 | |
| notification_enabled | boolean | NOT NULL | 通知总开关 | |
| email_notification | boolean | NOT NULL | 邮件通知 | |
| sms_notification | boolean | NOT NULL | 短信通知 | |
| push_notification | boolean | NOT NULL | 推送通知 | |
| created_at | timestamptz | NOT NULL | 创建时间 | |
| updated_at | timestamptz | NOT NULL | 更新时间 | |

字段说明：
- theme: 支持浅色/深色/跟随系统
- language: 支持中文/英文
- notification_enabled: 控制所有通知
- 各类通知开关：独立控制不同类型的通知

#### 3.1.4 user_addresses（地址表）
用户地址管理表，与 auth.users 多对一关联。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| id | uuid | PK | 地址ID | PK |
| user_id | uuid | FK, NOT NULL | 用户ID | FK |
| name | text | NOT NULL | 地址名称 | |
| recipient | text | NOT NULL | 收件人 | |
| phone | text | NOT NULL | 联系电话 | |
| country | text | NOT NULL | 国家 | |
| state | text | NOT NULL | 州/省 | |
| city | text | NOT NULL | 城市 | |
| street | text | NOT NULL | 街道 | |
| postal_code | text | NOT NULL | 邮编 | |
| is_default | boolean | NOT NULL | 默认地址 | |
| location | jsonb | | 地理位置（经纬度） | |
| created_at | timestamptz | NOT NULL | 创建时间 | |
| updated_at | timestamptz | NOT NULL | 更新时间 | |

字段说明：
- name: 地址名称，如"家"、"公司"
- is_default: 标记默认地址，每个用户只能有一个默认地址
- location: 存储地址的地理位置信息，用于地图显示和距离计算

#### 3.1.5 user_payment_methods（支付方式表）
用户支付方式表，与 auth.users 多对一关联。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| id | uuid | PK | 支付方式ID | PK |
| user_id | uuid | FK, NOT NULL | 用户ID | FK |
| type | text | NOT NULL | 支付方式类型：card/bank/wallet | |
| provider | text | NOT NULL | 支付提供商 | |
| token | text | NOT NULL | 支付令牌（加密存储） | |
| last_4 | text | | 卡号后4位 | |
| is_default | boolean | NOT NULL | 是否默认支付方式 | |
| expires_at | timestamptz | | 过期时间 | |
| billing_address | jsonb | | 账单地址 | |
| created_at | timestamptz | NOT NULL | 创建时间 | |
| updated_at | timestamptz | NOT NULL | 更新时间 | |

字段说明：
- type: 支付方式类型，如信用卡、银行账户、电子钱包
- provider: 支付提供商，如 Stripe, PayPal
- token: 加密存储的支付令牌，用于安全支付
- billing_address: 存储账单地址信息，关联 user_addresses

#### 3.1.6 user_wallet（钱包表）
用户虚拟钱包表，与 auth.users 一对一关联。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| user_id | uuid | PK, FK | 用户ID | PK |
| balance | numeric | NOT NULL | 金豆余额 | |
| points | numeric | NOT NULL | 积分 | |
| currency | text | NOT NULL | 货币类型 | |
| frozen_amount | numeric | NOT NULL | 冻结金额 | |
| updated_at | timestamptz | NOT NULL | 更新时间 | |

字段说明：
- balance: 用户金豆余额，用于应用内支付
- points: 用户积分，用于奖励和兑换
- frozen_amount: 冻结金额，用于处理中的交易

#### 3.1.7 user_coupons（优惠券表）
用户优惠券表，与 auth.users 多对一关联。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| id | uuid | PK | 优惠券ID | PK |
| user_id | uuid | FK, NOT NULL | 用户ID | FK |
| coupon_id | uuid | FK, NOT NULL | 优惠券模板ID | FK |
| status | text | NOT NULL | 状态：valid/used/expired | |
| amount | numeric | NOT NULL | 优惠金额 | |
| min_order_amount | numeric | NOT NULL | 最低使用金额 | |
| valid_from | timestamptz | NOT NULL | 生效时间 | |
| valid_until | timestamptz | NOT NULL | 过期时间 | |
| used_at | timestamptz | | 使用时间 | |
| order_id | uuid | FK | 关联订单ID | FK |
| created_at | timestamptz | NOT NULL | 创建时间 | |
| updated_at | timestamptz | NOT NULL | 更新时间 | |

字段说明：
- coupon_id: 关联优惠券模板表
- status: 优惠券状态，控制使用条件
- amount: 优惠金额，可以是固定金额或折扣比例
- min_order_amount: 最低订单金额，满足条件才能使用
- order_id: 使用优惠券的订单ID，如果已使用

### 3.2 服务分类表

#### 3.2.1 ref_codes（引用代码表）
分层分类系统表，用于存储服务类型、提供商类型等分类数据。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| id | bigint | PK | 主键ID | PK |
| type_code | varchar(30) | NOT NULL | 实体类型编码 | INDEX |
| code | varchar(50) | NOT NULL | 分类编码 | INDEX |
| chinese_name | varchar(100) | NOT NULL | 中文名称 | |
| english_name | varchar(100) | | 英文名称 | |
| parent_id | bigint | FK | 父节点ID | FK |
| level | smallint | NOT NULL | 层级（1=一级，2=二级，3=三级） | INDEX |
| description | varchar(255) | | 分类描述 | |
| sort_order | integer | NOT NULL | 排序序号 | |
| status | smallint | NOT NULL | 状态（1=启用，0=禁用） | INDEX |
| created_at | timestamptz | NOT NULL | 创建时间 | |
| updated_at | timestamptz | NOT NULL | 更新时间 | |
| extra_data | jsonb | NOT NULL | 额外数据 | |

字段说明：
- type_code: 实体类型编码，如 SERVICE_TYPE, PROVIDER_TYPE
- code: 分类编码，同一类型下唯一
- parent_id: 父节点ID，NULL 表示一级分类
- level: 层级，用于区分一级、二级、三级分类
- sort_order: 排序序号，用于控制显示顺序
- status: 状态，控制分类是否可用
- extra_data: 存储额外数据，如图标、特定属性等

### 3.3 服务商管理

#### 3.3.1 provider_profiles（服务商资料表）
服务商详细信息表，与 auth.users 一对一关联。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| id | uuid | PK, FK | 用户ID | PK |
| business_name | text | NOT NULL | 商家名称 | |
| business_description | text | | 商家描述 | |
| business_phone | text | | 商家电话 | |
| business_email | text | | 商家邮箱 | |
| business_address | text | | 商家地址 | |
| service_areas | text[] | | 服务区域 | |
| service_categories | text[] | | 服务类别 | |
| verification_status | text | NOT NULL | 认证状态 | INDEX |
| verification_documents | text[] | | 认证文档 | |
| created_at | timestamptz | NOT NULL | 创建时间 | |
| updated_at | timestamptz | NOT NULL | 更新时间 |
| default_fulfillment_mode | text | NOT NULL | 默认服务履行模式：platform/external | INDEX |
| provider_type | text | NOT NULL | 服务者身份：personal/business/via_platform | INDEX |
| has_gst_hst | boolean | NOT NULL | 是否注册 GST/HST | |
| bn_number | text | | 商户 BN 编号 | |
| annual_income_estimate | numeric | | 年收入预估（仅用户填写，不作强校验） | |
| tax_status_notice_shown | boolean | NOT NULL | 是否展示过合规提示 | |
| tax_report_available | boolean | NOT NULL | 是否已生成年度税务汇总报表 | |

字段说明：
- service_areas: 数组类型，存储服务区域
- service_categories: 数组类型，存储服务类别，关联 ref_codes
- verification_status: 控制服务商认证状态
- verification_documents: 数组类型，存储认证文档URL
- default_fulfillment_mode: 服务商默认发布的服务模式，可在发布时修改
- provider_type: 服务者身份类型，区分个人服务者、注册商户或平台代办注册
- has_gst_hst: 标记服务者是否已注册 GST/HST 号码
- bn_number: 加拿大注册商户的 Business Number (BN)，如果适用
- annual_income_estimate: 服务者提供的年收入预估，用于税务提示逻辑
- tax_status_notice_shown: 标记是否已向服务者展示过税务合规提示
- tax_report_available: 标记是否已为该服务者生成年度税务汇总报表

### 3.4 服务信息管理

#### 3.4.1 services（核心服务信息表）
存储平台上的服务项目的核心信息。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|---|---|---|---|---|---|
| id | uuid | PK | 服务ID | PK |
| provider_id | uuid | FK, NOT NULL | 服务商ID，关联 provider_profiles | FK, INDEX |
| title | text | NOT NULL | 服务标题 | INDEX |
| description | text | | 服务详细描述 | |
| category_level1_id | bigint | FK, NOT NULL | 关联一级服务类别 | FK, INDEX |
| category_level2_id | bigint | FK | 关联二级服务类别 | FK, INDEX |
| status | text | NOT NULL | 服务状态：draft/active/paused/archived | INDEX |
| average_rating | numeric | | 平均评分（聚合） | |
| review_count | integer | | 评价数量（聚合） | |
| latitude | numeric | | 服务提供地点纬度 | INDEX |
| longitude | numeric | | 服务提供地点经度 | INDEX |
| service_delivery_method | text | NOT NULL | 服务交付方式：on_site/remote/online/pickup | INDEX |
| created_at | timestamptz | NOT NULL | 创建时间 | |
| updated_at | timestamptz | NOT NULL | 更新时间 | |

字段说明：
- id: 服务的唯一标识符
- provider_id: 提供此服务的服务商ID，关联 provider_profiles 表
- title: 服务的名称，如"上门清洁"、"搬家服务"
- description: 服务的详细描述，介绍服务内容和特点
- category_level1_id: 服务所属的一级分类ID，关联 ref_codes 表
- category_level2_id: 服务所属的二级分类ID，关联 ref_codes 表
- status: 服务的当前状态，如活跃、非活跃、暂停等
- average_rating: 服务的平均评分
- review_count: 服务的评价总数
- latitude: 服务的纬度坐标
- longitude: 服务的经度坐标
- service_delivery_method: 定义服务如何交付，影响位置信息是否必填和地图展示方式
- created_at: 服务记录的创建时间
- updated_at: 服务记录的最后更新时间

#### 3.4.2 service_details（服务详细信息表）
存储服务项目的详细属性，与 services 表一对一关联。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|---|---|---|---|---|---|
| service_id | uuid | PK, FK | 关联到 services 表的ID | PK, FK |
| pricing_type | text | NOT NULL | 定价方式：fixed/negotiable/quote_based/free/custom | INDEX |
| price | numeric | | 服务价格（仅当 pricing_type 为固定价时有效） | |
| currency | text | | 货币类型 | |
| negotiation_details | text | | 议价说明（仅当定价方式为议价时有效） | |
| duration_type | text | NOT NULL | 时长类型：fixed/variable/scope_based | INDEX |
| duration | interval | | 服务时长（仅当时长类型为固定时长时有效） | |
| images_url | text[] | | 服务图片URLs | |
| videos_url | text[] | | 服务视频URLs | |
| tags | text[] | | 服务标签 | GIN |
| service_area_codes | text[] | | 服务覆盖区域编码（针对线上服务） | GIN |
| platform_service_fee_rate | numeric | | 平台服务费率（仅托管模式） | |
| min_platform_service_fee | numeric | | 最小平台服务费（仅托管模式） | |
| service_details_json | jsonb | | 服务详情（流程、材料、注意事项等，通用JSON字段） | |
| extra_data | jsonb | | 额外数据（通用JSON字段） | |
| promotion_start | timestamptz | | 促销开始时间 | |
| promotion_end | timestamptz | | 促销结束时间 | |
| view_count | integer | | 浏览次数 | |
| favorite_count | integer | | 收藏次数 | |
| order_count | integer | | 订单数量 | |
| verification_status | text | NOT NULL | 服务的审核状态：verified/pending/rejected | |
| verification_documents | text[] | | 服务的相关认证文档URLs列表 | |
| created_at | timestamptz | NOT NULL | 创建时间 | |
| updated_at | timestamptz | NOT NULL | 更新时间 | |

字段说明：
- service_id: 关联到 services 表的ID，作为主键，确保一对一关系
- pricing_type: 定义服务的定价方式，决定 price 字段是否必填
- price: 服务价格，仅当 pricing_type 为 'fixed' 时有效
- currency: 服务价格的货币类型
- negotiation_details: 当 pricing_type 为 'negotiable' 或 'quote_based' 时的议价说明
- duration_type: 定义服务的时长类型，决定 duration 字段是否必填
- duration: 服务时长，仅当 duration_type 为 'fixed' 时有效
- images_url: 服务相关的图片URLs列表
- videos_url: 服务相关的视频URLs列表
- tags: 用于描述服务的关键词列表，方便搜索和筛选
- service_area_codes: 针对非物理位置服务，定义其可服务的地理区域（如国家、州、城市编码）
- platform_service_fee_rate: 平台从托管服务中抽取的服务费率（例如 0.15 表示 15%）
- min_platform_service_fee: 平台从托管服务中收取的最小服务费
- service_details_json: 存储服务的具体细节，如服务流程、所需材料、注意事项等，使用JSONB可以灵活存储结构化数据
- extra_data: 用于存储任何其他非标准的服务属性，使用JSONB提高灵活性
- promotion_start: 促销活动的开始时间
- promotion_end: 促销活动的结束时间
- view_count: 服务的浏览次数
- favorite_count: 服务的收藏次数
- order_count: 服务的订单数量
- verification_status: 服务的审核状态，如已认证、待审核、已拒绝
- verification_documents: 服务的相关认证文档URLs列表
- created_at: 服务详细信息记录的创建时间
- updated_at: 服务详细信息记录的最后更新时间

### 3.5 订单管理相关表

#### 3.5.1 orders（订单主表）
记录用户下单的服务交易信息。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| id | uuid | PK | 订单ID | PK |
| order_number | text | UNIQUE, NOT NULL | 订单号（业务唯一） | UNIQUE |
| user_id | uuid | FK, NOT NULL | 下单用户ID，关联 auth.users | FK, INDEX |
| provider_id | uuid | FK, NOT NULL | 服务商ID，关联 provider_profiles | FK, INDEX |
| order_type | text | NOT NULL | 订单类型：on_demand/rental/appointment/negotiated/package | INDEX |
| fulfillment_mode_snapshot | text | NOT NULL | 订单创建时服务的履行模式快照：platform/external | INDEX |
| order_status | text | NOT NULL | 订单状态：PendingAcceptance/Accepted/InProgress/Completed/Canceled/Refunded/Disputed/PendingPayment | INDEX |
| total_price | numeric | NOT NULL | 订单总价 | |
| currency | text | NOT NULL | 货币类型 | |
| payment_status | text | NOT NULL | 支付状态：Pending/Paid/PartiallyPaid/Refunded/Failed | INDEX |
| deposit_amount | numeric | | 订金/押金金额 | |
| final_payment_amount | numeric | | 尾款金额 | |
| coupon_id | uuid | FK | 使用的优惠券ID（如果存在优惠券模板表） | FK |
| points_deduction_amount | numeric | | 积分抵扣金额 | |
| platform_service_fee_rate_snapshot | numeric | | 订单创建时的平台服务费率快照 | |
| platform_service_fee_amount | numeric | | 平台从订单中实际收取的服务费金额 | |
| scheduled_start_time | timestamptz | | 预约开始时间 | |
| scheduled_end_time | timestamptz | | 预约结束时间 | |
| actual_start_time | timestamptz | | 实际服务开始时间 | |
| actual_end_time | timestamptz | | 实际服务结束时间 | |
| service_address_id | uuid | FK | 服务地址ID，关联 user_addresses（如果使用用户已存地址） | FK |
| service_address_snapshot | jsonb | | 服务地址快照（存储下单时的完整地址信息） | |
| service_latitude | numeric | | 服务地点纬度 | INDEX |
| service_longitude | numeric | | 服务地点经度 | INDEX |
| user_notes | text | | 用户备注 | |
| provider_notes | text | | 服务商备注 | |
| expires_at | timestamptz | | 订单过期时间（针对待支付/待接单状态） | |
| cancellation_reason | text | | 取消原因 | |
| cancellation_fee | numeric | | 取消违约金 | |
| dispute_status | text | | 纠纷状态：NoDispute/UnderReview/Resolved | |
| support_ticket_id | uuid | | 关联客服工单ID | |
| created_at | timestamptz | NOT NULL | 创建时间 |
| updated_at | timestamptz | NOT NULL | 更新时间 |

字段说明：
- id: 订单的唯一标识符
- order_number: 订单的业务编号，供用户和平台查询使用，需唯一
- user_id: 下单用户的ID
- provider_id: 提供服务的服务商ID
- order_type: 订单类型，如按需服务、租赁、预约、议价、套餐等
- fulfillment_mode_snapshot: 订单创建时服务的履行模式快照，用于后续的审计和追踪
- order_status: 订单的当前状态，支持完整的生命周期流转
- total_price: 订单的总价，包括所有费用
- currency: 订单价格的货币类型
- payment_status: 支付状态，记录支付的进度
- deposit_amount: 如果服务需要支付订金或押金，此字段记录金额
- final_payment_amount: 如果存在尾款，此字段记录金额
- coupon_id: 记录订单使用了哪个优惠券
- points_deduction_amount: 记录订单使用了多少积分抵扣
- platform_service_fee_rate_snapshot: 订单创建时的平台服务费率快照，用于后续的审计和追踪
- platform_service_fee_amount: 平台从订单中实际收取的服务费金额，用于后续的审计和追踪
- scheduled_start_time / scheduled_end_time: 预约服务的计划开始和结束时间
- actual_start_time / actual_end_time: 实际服务开始和结束时间，用于结算和统计
- service_address_id: 如果服务地点是用户已保存的地址，关联其ID
- service_address_snapshot: 存储下单时服务的详细地址，作为快照防止用户修改地址后订单信息不一致
- service_latitude / service_longitude: 服务地点的经纬度，用于地图显示和导航
- user_notes: 用户在下单时或后续添加的备注
- provider_notes: 服务商在接单或服务过程中添加的备注
- expires_at: 订单在某些状态下的过期时间，过期自动作废
- cancellation_reason: 订单取消的原因
- cancellation_fee: 订单取消可能产生的违约金
- dispute_status: 订单是否存在纠纷，以及纠纷处理状态
- support_ticket_id: 关联到客服系统的工单ID
- created_at: 订单的创建时间
- updated_at: 订单的最后更新时间

#### 3.5.2 order_items（订单明细表）
记录订单中包含的具体服务项目，支持复杂订单结构。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| id | uuid | PK | 订单项ID | PK |
| order_id | uuid | FK, NOT NULL | 所属订单ID，关联 orders | FK, INDEX |
| service_id | uuid | FK, NOT NULL | 关联服务ID，关联 service_info | FK, INDEX |
| quantity | integer | NOT NULL | 服务数量 | |
| unit_price_snapshot | numeric | NOT NULL | 下单时的服务单价（快照） | |
| subtotal_price | numeric | NOT NULL | 订单项小计价格 | |
| service_name_snapshot | text | NOT NULL | 服务名称快照 | |
| service_description_snapshot | text | | 服务描述快照 | |
| service_image_snapshot | text[] | | 服务图片快照 | |
| item_details_snapshot | jsonb | | 订单项具体细节快照（如规格、定制选项） | |
| pricing_type_snapshot | text | | 定价方式快照 | |
| duration_type_snapshot | text | | 时长类型快照 | |
| duration_snapshot | interval | | 服务时长快照 | |
| is_package_item | boolean | NOT NULL | 是否为套餐内项目 | |
| parent_item_id | uuid | FK | 如果是套餐内子项，关联主套餐项ID | FK |
| created_at | timestamptz | NOT NULL | 创建时间 | |
| updated_at | timestamptz | NOT NULL | 更新时间 | |

字段说明：
- id: 订单项的唯一标识符
- order_id: 关联到主订单表
- service_id: 关联到具体的服务信息表
- quantity: 服务的数量
- unit_price_snapshot: 下单时服务的单价，作为快照
- subtotal_price: 该订单项的总价
- service_name_snapshot / service_description_snapshot / service_image_snapshot: 复制服务的基本信息作为快照，确保订单记录的稳定性
- item_details_snapshot: 存储该订单项的额外细节，如选择的颜色、尺寸、定制内容等
- pricing_type_snapshot / duration_type_snapshot / duration_snapshot: 复制服务定价和时长相关信息快照
- is_package_item: 标记此订单项是否属于某个套餐
- parent_item_id: 如果是套餐内的子项，指向其所属的套餐订单项
- created_at: 订单项的创建时间
- updated_at: 订单项的最后更新时间

#### 3.5.3 reviews（评价表）
记录用户和服务商之间对订单的评价信息。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| id | uuid | PK | 评价ID | PK |
| order_id | uuid | FK, NOT NULL | 所属订单ID，关联 orders | FK, INDEX |
| service_id | uuid | FK, NOT NULL | 关联服务ID，关联 service_info | FK, INDEX |
| reviewer_id | uuid | FK, NOT NULL | 评价人ID（用户或服务商） | FK, INDEX |
| reviewed_id | uuid | FK, NOT NULL | 被评价人ID（用户或服务商） | FK, INDEX |
| rating | smallint | NOT NULL | 评分（1-5星） | |
| comment | text | | 评价内容 | |
| image_urls | text[] | | 评价图片URL列表 | |
| is_anonymous | boolean | NOT NULL | 是否匿名评价 | |
| review_type | text | NOT NULL | 评价类型：user_to_provider/provider_to_user | INDEX |
| created_at | timestamptz | NOT NULL | 创建时间 | |
| updated_at | timestamptz | NOT NULL | 更新时间 | |

字段说明：
- id: 评价的唯一标识符
- order_id: 关联到订单表，一个订单可以产生用户对服务商的评价和服务商对用户的评价
- service_id: 关联到具体服务
- reviewer_id: 实施评价的用户或服务商ID
- reviewed_id: 被评价的用户或服务商ID
- rating: 评分等级
- comment: 评价的文本内容
- image_urls: 评价时上传的图片链接
- is_anonymous: 标记是否匿名评价
- review_type: 区分是用户评价服务商还是服务商评价用户
- created_at: 评价的创建时间
- updated_at: 评价的最后更新时间

#### 3.5.4 negotiation_records（议价记录表）
记录议价类服务的价格协商过程。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| id | uuid | PK | 议价记录ID | PK |
| order_id | uuid | FK, NOT NULL | 关联订单ID（议价成功后会关联到订单） | FK, INDEX |
| proposer_id | uuid | FK, NOT NULL | 提出报价/反报价的用户或服务商ID | FK, INDEX |
| proposed_amount | numeric | NOT NULL | 提出的金额 | |
| proposed_duration | interval | | 提出的服务时长 | |
| message | text | | 协商留言 | |
| status | text | NOT NULL | 协商状态：Pending/Accepted/Rejected/Countered/Canceled | INDEX |
| created_at | timestamptz | NOT NULL | 创建时间 | |
| updated_at | timestamptz | NOT NULL | 更新时间 | |

字段说明：
- id: 议价记录的唯一标识符
- order_id: 议价成功后，该记录会关联到对应的订单
- proposer_id: 提出当前报价的用户ID或服务商ID
- proposed_amount: 本次协商提出的金额
- proposed_duration: 本次协商提出的服务时长
- message: 协商过程中交流的文本信息
- status: 协商的状态，如待确认、已接受、已拒绝、已反驳等
- created_at: 议价记录的创建时间
- updated_at: 议价记录的最后更新时间

#### 3.5.5 order_audit_log（订单审计日志表）
记录订单的关键操作和状态变更历史，用于审计和追踪。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| id | uuid | PK | 日志ID | PK |
| order_id | uuid | FK, NOT NULL | 关联订单ID | FK, INDEX |
| event_type | text | NOT NULL | 事件类型：OrderStatusChange/PriceChange/AddressChange/NoteAdded/Other | INDEX |
| old_value | jsonb | | 变更前的值（适用于字段变更） | |
| new_value | jsonb | | 变更后的值（适用于字段变更） | |
| changed_by_id | uuid | FK, NOT NULL | 操作人ID（用户/服务商/管理员） | FK, INDEX |
| description | text | | 事件描述 | |
| created_at | timestamptz | NOT NULL | 事件发生时间 | |

字段说明：
- id: 审计日志的唯一标识符
- order_id: 关联到被审计的订单
- event_type: 记录发生的事件类型，如订单状态变更、价格调整、地址修改等
- old_value / new_value: 存储字段变更前后的具体值，便于追溯
- changed_by_id: 记录执行此操作的用户、服务商或管理员ID
- description: 对事件的简要描述
- created_at: 事件发生的时间戳

#### 3.5.6 order_messages（订单消息表）
记录用户和服务商在订单详情页内的即时沟通消息。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| id | uuid | PK | 消息ID | PK |
| order_id | uuid | FK, NOT NULL | 关联订单ID | FK, INDEX |
| sender_id | uuid | FK, NOT NULL | 发送者ID（用户或服务商） | FK, INDEX |
| receiver_id | uuid | FK, NOT NULL | 接收者ID（用户或服务商） | FK, INDEX |
| message_text | text | | 消息内容 | |
| image_urls | text[] | | 消息图片URL列表 | |
| sent_at | timestamptz | NOT NULL | 发送时间 | |
| read_at | timestamptz | | 阅读时间 | |

字段说明：
- id: 消息的唯一标识符
- order_id: 关联到所属订单
- sender_id: 消息发送者ID
- receiver_id: 消息接收者ID
- message_text: 消息的文本内容
- image_urls: 消息中包含的图片链接
- sent_at: 消息发送的时间戳
- read_at: 消息被接收者阅读的时间戳

#### 3.5.7 refunds（退款表）
记录订单的退款信息，支持退款流程管理。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| id | uuid | PK | 退款ID | PK |
| order_id | uuid | FK, NOT NULL | 关联订单ID | FK, INDEX |
| refund_amount | numeric | NOT NULL | 退款金额 | |
| refund_status | text | NOT NULL | 退款状态：Pending/Approved/Rejected/Processed/Failed | INDEX |
| reason | text | | 退款原因 | |
| evidence_urls | text[] | | 退款证据图片/视频URL列表 | |
| processed_by_id | uuid | FK | 处理退款的管理员ID | FK |
| processed_at | timestamptz | | 退款处理时间 | |
| created_at | timestamptz | NOT NULL | 创建时间 | |
| updated_at | timestamptz | NOT NULL | 更新时间 | |

字段说明：
- id: 退款的唯一标识符
- order_id: 关联到所属订单
- refund_amount: 实际退款金额
- refund_status: 退款的当前状态，如待审核、已批准、已处理等
- reason: 用户申请退款的原因
- evidence_urls: 用户提供的退款证据链接
- processed_by_id: 处理此退款请求的管理员ID
- processed_at: 退款处理完成的时间戳
- created_at: 退款请求的创建时间
- updated_at: 退款记录的最后更新时间

### 3.6 平台通知与营销相关表

#### 3.6.1 notifications（通知表）
存储平台向用户或服务商发送的各类通知消息。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| id | uuid | PK | 通知ID | PK |
| recipient_id | uuid | FK, NOT NULL | 接收者ID（用户或服务商） | FK, INDEX |
| recipient_type | text | NOT NULL | 接收者类型：user/provider | INDEX |
| notification_type | text | NOT NULL | 通知类型：system/order/promotion/account/announcement | INDEX |
| title | text | NOT NULL | 通知标题 | |
| message | text | NOT NULL | 通知内容 | |
| related_entity_id | uuid | FK | 关联实体ID（如订单ID、服务ID） | FK, INDEX |
| related_entity_type | text | | 关联实体类型（如order/service/promotion） | |
| is_read | boolean | NOT NULL | 是否已读 | INDEX |
| sent_at | timestamptz | NOT NULL | 发送时间 | |
| read_at | timestamptz | | 阅读时间 | |
| created_at | timestamptz | NOT NULL | 创建时间 | |
| updated_at | timestamptz | NOT NULL | 更新时间 | |

字段说明：
- id: 通知的唯一标识符
- recipient_id: 接收此通知的用户或服务商ID
- recipient_type: 接收者的类型，区分是用户还是服务商
- notification_type: 通知的具体类型，用于分类展示和处理
- title: 通知的标题
- message: 通知的详细内容
- related_entity_id: 如果通知与某个实体（如订单）相关，记录其ID
- related_entity_type: 关联实体的类型
- is_read: 标记通知是否已被接收者阅读
- sent_at: 通知发送的时间戳
- read_at: 通知被接收者阅读的时间戳
- created_at: 通知记录的创建时间
- updated_at: 通知记录的最后更新时间

#### 3.6.2 promotions（营销活动表）
管理平台各类营销活动和优惠券模板。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| id | uuid | PK | 活动ID | PK |
| name | text | NOT NULL | 活动名称 | |
| description | text | | 活动描述 | |
| type | text | NOT NULL | 活动类型：coupon/discount/package/referral | INDEX |
| value | numeric | NOT NULL | 优惠值（如折扣比例、固定金额） | |
| value_type | text | NOT NULL | 优惠值类型：percentage/fixed_amount | |
| min_order_amount | numeric | | 最低使用金额 | |
| max_discount_amount | numeric | | 最大优惠金额（针对百分比折扣） | |
| usage_limit_per_user | integer | | 每用户使用限制 | |
| usage_limit_total | integer | | 总使用限制 | |
| start_time | timestamptz | NOT NULL | 活动开始时间 | |
| end_time | timestamptz | NOT NULL | 活动结束时间 | |
| target_audience | text | NOT NULL | 目标用户：all/new_users/specific_users/specific_providers | INDEX |
| target_categories | bigint[] | | 目标服务类别（关联 ref_codes） | GIN |
| target_services | uuid[] | | 目标服务（关联 service_info） | GIN |
| status | text | NOT NULL | 活动状态：active/inactive/ended/scheduled | INDEX |
| created_at | timestamptz | NOT NULL | 创建时间 | |
| updated_at | timestamptz | NOT NULL | 更新时间 | |

字段说明：
- id: 营销活动的唯一标识符
- name: 活动的名称，如"新用户优惠券"、"夏季大促"
- description: 活动的详细说明
- type: 活动的类型，如优惠券、直接折扣、套餐、推荐返利等
- value: 优惠的具体数值，如 0.8（8折）或 10（立减10元）
- value_type: 优惠值是百分比还是固定金额
- min_order_amount: 使用此优惠的最低订单金额
- max_discount_amount: 如果是百分比折扣，设定的最大优惠金额
- usage_limit_per_user: 每个用户可以使用此优惠的次数限制
- usage_limit_total: 此优惠的总使用次数限制
- start_time / end_time: 活动的生效和结束时间
- target_audience: 目标用户群体，如所有用户、新用户、特定用户ID或特定服务商等
- target_categories: 优惠适用的服务类别列表
- target_services: 优惠适用的具体服务列表
- status: 活动的当前状态
- created_at: 活动记录的创建时间
- updated_at: 活动记录的最后更新时间

### 3.7 服务商日程管理相关表

#### 3.7.1 provider_schedules（服务商日程表）
记录服务商可提供服务的时间段和排班信息。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| id | uuid | PK | 日程ID | PK |
| provider_id | uuid | FK, NOT NULL | 服务商ID，关联 provider_profiles | FK, INDEX |
| service_id | uuid | FK | 关联的服务ID（如果日程针对特定服务） | FK, INDEX |
| schedule_type | text | NOT NULL | 日程类型：daily/weekly/one_time/block | INDEX |
| start_time | timestamptz | NOT NULL | 可用时间段开始时间 | INDEX |
| end_time | timestamptz | NOT NULL | 可用时间段结束时间 | INDEX |
| is_available | boolean | NOT NULL | 当前时间段是否可用 | |
| capacity | integer | | 当前时间段的可接单容量 | |
| booked_capacity | integer | | 已被预订的容量 | |
| recurrence_rule | text | | 重复规则（如 daily, weekly, custom cron） | |
| created_at | timestamptz | NOT NULL | 创建时间 | |
| updated_at | timestamptz | NOT NULL | 更新时间 | |

字段说明：
- id: 日程记录的唯一标识符
- provider_id: 关联到服务商
- service_id: 如果服务商的日程是针对某个特定服务，则关联该服务，否则为空表示通用日程
- schedule_type: 日程的类型，如每日重复、每周重复、一次性排班、或特定时间块
- start_time / end_time: 服务商可用的时间段
- is_available: 标记该时间段是否可用（服务商可手动设置忙碌）
- capacity: 该时间段内可接受的订单或服务数量
- booked_capacity: 该时间段内已被预订的容量
- recurrence_rule: 针对重复性日程的规则定义，如 CRON 表达式或简单枚举
- created_at: 日程记录的创建时间
- updated_at: 日程记录的最后更新时间

### 3.8 平台管理功能相关表

#### 3.8.1 admin_users（管理员用户表）
存储平台管理员账户信息。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| id | uuid | PK | 管理员用户ID | PK |
| username | text | UNIQUE, NOT NULL | 管理员登录名 | UNIQUE |
| email | text | UNIQUE, NOT NULL | 管理员邮箱 | UNIQUE |
| password_hash | text | NOT NULL | 密码哈希值 | |
| display_name | text | | 显示名称 | |
| role_id | uuid | FK, NOT NULL | 角色ID，关联 roles_permissions | FK, INDEX |
| status | text | NOT NULL | 账户状态：active/inactive/locked | |
| last_login_at | timestamptz | | 最后登录时间 | |
| created_at | timestamptz | NOT NULL | 创建时间 | |
| updated_at | timestamptz | NOT NULL | 更新时间 | |

字段说明：
- id: 管理员的唯一标识符
- username: 管理员登录系统的用户名
- email: 管理员的邮箱
- password_hash: 加密后的密码，确保安全
- display_name: 管理员的显示名称
- role_id: 关联到 `roles_permissions` 表，定义管理员的权限
- status: 管理员账户状态
- last_login_at: 最后登录时间
- created_at: 账户创建时间
- updated_at: 账户最后更新时间

#### 3.8.2 roles_permissions（角色权限表）
定义平台管理员的角色及其对应的权限集。

| 字段名 | 类型 | 约束 | 说明 | 索引 |
|--------|------|------|------|------|
| id | uuid | PK | 角色ID | PK |
| role_name | text | UNIQUE, NOT NULL | 角色名称（如 SuperAdmin, OrderManager, ContentEditor） | UNIQUE |
| description | text | | 角色描述 | |
| permissions | text[] | NOT NULL | 权限列表（如 manage_users, view_orders, edit_services） | GIN |
| created_at | timestamptz | NOT NULL | 创建时间 | |
| updated_at | timestamptz | NOT NULL | 更新时间 | |

字段说明：
- id: 角色的唯一标识符
- role_name: 角色的名称，如"超级管理员"、"订单管理员"
- description: 角色的详细描述
- permissions: 存储该角色所拥有的具体权限列表（字符串数组）
- created_at: 角色记录的创建时间
- updated_at: 角色记录的最后更新时间

## 4. 关系模型

### 4.1 实体关系图
```
auth.users 1:1 user_profiles
auth.users 1:1 user_settings
auth.users 1:N user_addresses
auth.users 1:1 user_wallet
auth.users 1:N user_payment_methods
auth.users 1:N user_coupons
auth.users 1:1 provider_profiles (当 user_type = 'provider')
ref_codes 1:N ref_codes (自关联，表示分类层级)
ref_codes 1:N provider_profiles (服务类别)
ref_codes 1:N services (服务分类)
services 1:1 service_details
provider_profiles 1:N services
auth.users 1:N orders
provider_profiles 1:N orders
orders 1:N order_items
services 1:N order_items
orders 1:N reviews (用户对服务商)
orders 1:N reviews (服务商对用户)
orders 1:N negotiation_records
orders 1:N order_audit_log
orders 1:N order_messages
orders 1:N refunds
user_addresses 1:N orders (通过 service_address_id)
auth.users 1:N notifications (接收者)
provider_profiles 1:N notifications (接收者)
promotions 1:N orders (通过 coupon_id)
services 1:N promotions (目标服务)
ref_codes 1:N promotions (目标分类)
provider_profiles 1:N provider_schedules
services 1:N provider_schedules
admin_users 1:1 roles_permissions
```

### 4.2 关系说明
1. 用户与资料：一对一关系，确保每个用户都有基本资料
2. 用户与设置：一对一关系，存储用户个性化设置
3. 用户与地址：一对多关系，支持多个地址管理
4. 用户与钱包：一对一关系，管理用户虚拟货币和积分
5. 用户与支付方式：一对多关系，支持多种支付方式
6. 用户与优惠券：一对多关系，管理用户拥有的优惠券
7. 用户与服务商资料：一对一关系，仅当用户类型为服务商时存在
8. 分类自关联：一对多关系，表示分类的层级结构
9. 分类与服务商：一对多关系，服务商可以提供多种服务类别
10. 分类与服务信息：一对多关系，服务信息关联到具体分类 (现为 `ref_codes` 与 `services`)
11. 服务商与服务信息：一对多关系，一个服务商可以提供多个服务 (现为 `provider_profiles` 与 `services`)
12. 用户与订单：一对多关系，一个用户可以创建多个订单
13. 服务商与订单：一对多关系，一个服务商可以接收多个订单
14. 订单与订单明细：一对多关系，一个订单可以包含多个服务明细
15. 服务信息与订单明细：一对多关系，一个服务信息可以被多个订单明细引用 (现为 `services` 与 `order_items`)
16. 订单与评价：一对多关系，一个订单可能产生用户对服务商的评价和服务商对用户的评价
17. 订单与议价记录：一对多关系，一个订单可以有多轮议价记录
18. 订单与审计日志：一对多关系，一个订单可以有多个操作审计日志
19. 订单与消息：一对多关系，一个订单可以有多条沟通消息
20. 订单与退款：一对多关系，一个订单可以有多次退款记录
21. 用户地址与订单：一对多关系，订单服务地址可关联到用户已保存的地址
22. 用户/服务商与通知：一对多关系，一个用户或服务商可接收多条通知
23. 营销活动与订单：一对多关系（通过优惠券ID），营销活动可被多个订单使用
24. 营销活动与服务：多对多关系（通过 target_services 字段），一个营销活动可针对多个服务 (现为 `promotions` 与 `services`)
25. 营销活动与分类：多对多关系（通过 target_categories 字段），一个营销活动可针对多个服务类别
26. 服务商与日程：一对多关系，一个服务商可设置多个日程安排
27. 服务信息与日程：一对多关系，一个服务可被多个日程引用（可选，如果日程针对特定服务） (现为 `provider_schedules` 与 `services`)
28. 管理员用户与角色权限：一对一关系，一个管理员用户对应一个角色权限
29. **服务与服务详情：** 一对一关系，`services` 表存储核心信息，`service_details` 存储详细信息。

## 5. 安全策略

### 5.1 行级安全策略 (RLS)

#### 5.1.1 user_profiles 表策略
```sql
-- 查看策略
create policy "Public profiles are viewable by everyone"
  on public.user_profiles for select
  using ( true );

-- 插入策略
create policy "Users can insert their own profile"
  on public.user_profiles for insert
  with check ( auth.uid() = user_id );

-- 更新策略
create policy "Users can update their own profile"
  on public.user_profiles for update
  using ( auth.uid() = user_id );
```

#### 5.1.2 user_settings 表策略
```sql
-- 查看策略
create policy "Public user settings are viewable by everyone"
  on public.user_settings for select
  using ( true );

-- 插入策略
create policy "Users can insert their own settings"
  on public.user_settings for insert
  with check ( auth.uid() = user_id );

-- 更新策略
create policy "Users can update their own settings"
  on public.user_settings for update
  using ( auth.uid() = user_id );
```

#### 5.1.3 user_addresses 表策略
```sql
-- 查看策略
create policy "Users can view their own addresses"
  on public.user_addresses for select
  using ( auth.uid() = user_id );

-- 插入策略
create policy "Users can insert their own addresses"
  on public.user_addresses for insert
  with check ( auth.uid() = user_id );

-- 更新策略
create policy "Users can update their own addresses"
  on public.user_addresses for update
  using ( auth.uid() = user_id );

-- 删除策略
create policy "Users can delete their own addresses"
  on public.user_addresses for delete
  using ( auth.uid() = user_id );
```

#### 5.1.4 user_payment_methods 表策略
```sql
-- 查看策略
create policy "Users can view their own payment methods"
  on public.user_payment_methods for select
  using ( auth.uid() = user_id );

-- 插入策略
create policy "Users can insert their own payment methods"
  on public.user_payment_methods for insert
  with check ( auth.uid() = user_id );

-- 更新策略
create policy "Users can update their own payment methods"
  on public.user_payment_methods for update
  using ( auth.uid() = user_id );

-- 删除策略
create policy "Users can delete their own payment methods"
  on public.user_payment_methods for delete
  using ( auth.uid() = user_id );
```

#### 5.1.5 user_wallet 表策略
```sql
-- 查看策略
create policy "Users can view their own wallet"
  on public.user_wallet for select
  using ( auth.uid() = user_id );

-- 插入策略
create policy "Users can insert their own wallet"
  on public.user_wallet for insert
  with check ( auth.uid() = user_id );

-- 更新策略
create policy "Users can update their own wallet"
  on public.user_wallet for update
  using ( auth.uid() = user_id );
```

#### 5.1.6 user_coupons 表策略
```sql
-- 查看策略
create policy "Users can view their own coupons"
  on public.user_coupons for select
  using ( auth.uid() = user_id );

-- 插入策略
create policy "Users can insert their own coupons"
  on public.user_coupons for insert
  with check ( auth.uid() = user_id );

-- 更新策略
create policy "Users can update their own coupons"
  on public.user_coupons for update
  using ( auth.uid() = user_id );

-- 删除策略
create policy "Users can delete their own coupons"
  on public.user_coupons for delete
  using ( auth.uid() = user_id );
```

#### 5.1.7 provider_profiles 表策略
```sql
-- 查看策略
create policy "Provider profiles are viewable by everyone"
  on public.provider_profiles for select
  using ( true );

-- 插入策略
create policy "Providers can insert their own profile"
  on public.provider_profiles for insert
  with check ( auth.uid() = id );

-- 更新策略
create policy "Providers can update their own profile"
  on public.provider_profiles for update
  using ( auth.uid() = id );
```

#### 5.1.8 ref_codes 表策略
```sql
-- 查看策略
create policy "Ref codes are viewable by everyone"
  on public.ref_codes for select
  using ( true );

-- 插入策略
create policy "Only admins can insert ref codes"
  on public.ref_codes for insert
  with check ( auth.role() = 'admin' );

-- 更新策略
create policy "Only admins can update ref codes"
  on public.ref_codes for update
  using ( auth.role() = 'admin' );

-- 删除策略
create policy "Only admins can delete ref codes"
  on public.ref_codes for delete
  using ( auth.role() = 'admin' );
```

#### 5.1.9 services 表策略
```sql
-- 查看策略：允许所有用户查看活跃的服务信息
create policy "Active services are viewable by everyone"
  on public.services for select
  using ( status = 'active' );

-- 插入策略：允许服务商插入自己的服务信息
create policy "Providers can insert their own services"
  on public.services for insert
  with check ( auth.uid() = provider_id );

-- 更新策略：允许服务商更新自己的服务信息
create policy "Providers can update their own services"
  on public.services for update
  using ( auth.uid() = provider_id );

-- 删除策略：允许服务商删除自己的服务信息
create policy "Providers can delete their own services"
  on public.services for delete
  using ( auth.uid() = provider_id );
```

#### 5.1.10 service_details 表策略
```sql
-- 查看策略：所有用户可以查看关联的活跃服务详情
create policy "Service details are viewable by everyone for active services"
  on public.service_details for select
  using ( exists(select 1 from public.services where services.id = service_details.service_id and services.status = 'active') );

-- 插入策略：服务商可以插入自己服务的详细信息
create policy "Providers can insert service details for their own services"
  on public.service_details for insert
  with check ( exists(select 1 from public.services where services.id = service_details.service_id and services.provider_id = auth.uid()) );

-- 更新策略：服务商可以更新自己服务的详细信息
create policy "Providers can update service details for their own services"
  on public.service_details for update
  using ( exists(select 1 from public.services where services.id = service_details.service_id and services.provider_id = auth.uid()) );

-- 删除策略：服务商可以删除自己服务的详细信息
create policy "Providers can delete service details for their own services"
  on public.service_details for delete
  using ( exists(select 1 from public.services where services.id = service_details.service_id and services.provider_id = auth.uid()) );
```

#### 5.1.11 orders 表策略
```sql
-- 用户查看自己的订单
create policy "Users can view their own orders"
  on public.orders for select
  using ( auth.uid() = user_id );

-- 服务商查看自己的订单
create policy "Providers can view their own orders"
  on public.orders for select
  using ( auth.uid() = provider_id );

-- 用户插入订单
create policy "Users can insert orders"
  on public.orders for insert
  with check ( auth.uid() = user_id );

-- 用户更新自己的订单（有限状态，如取消）
create policy "Users can update their own orders"
  on public.orders for update
  using ( auth.uid() = user_id );

-- 服务商更新自己的订单（有限状态，如接单，完成）
create policy "Providers can update their own assigned orders"
  on public.orders for update
  using ( auth.uid() = provider_id );
```

#### 5.1.12 order_items 表策略
```sql
-- 订单项查看策略：用户和服务商可查看关联的订单项
create policy "Users and providers can view order items"
  on public.order_items for select
  using (
    exists(select 1 from public.orders where orders.id = order_items.order_id and orders.user_id = auth.uid()) OR
    exists(select 1 from public.orders where orders.id = order_items.order_id and orders.provider_id = auth.uid())
  );

-- 订单项插入策略：只允许在订单创建时由用户插入
create policy "Users can insert order items for their own orders"
  on public.order_items for insert
  with check (
    exists(select 1 from public.orders where orders.id = order_items.order_id and orders.user_id = auth.uid())
  );
```

#### 5.1.13 reviews 表策略
```sql
-- 评价查看策略：所有已发布的评价都可被查看
create policy "Reviews are viewable by everyone"
  on public.reviews for select
  using ( true );

-- 评价插入策略：用户或服务商可以为自己的订单插入评价
create policy "Users and providers can insert reviews for their own orders"
  on public.reviews for insert
  with check (
    (auth.uid() = reviewer_id AND EXISTS(SELECT 1 FROM public.orders WHERE orders.id = reviews.order_id AND orders.user_id = auth.uid())) OR
    (auth.uid() = reviewer_id AND EXISTS(SELECT 1 FROM public.orders WHERE orders.id = reviews.order_id AND orders.provider_id = auth.uid()))
  );
```

#### 5.1.14 negotiation_records 表策略
```sql
-- 议价记录查看策略：订单相关方可查看
create policy "Order parties can view negotiation records"
  on public.negotiation_records for select
  using (
    exists(select 1 from public.orders where orders.id = negotiation_records.order_id and (orders.user_id = auth.uid() OR orders.provider_id = auth.uid()))
  );

-- 议价记录插入策略：订单相关方可插入
create policy "Order parties can insert negotiation records"
  on public.negotiation_records for insert
  with check (
    exists(select 1 from public.orders where orders.id = negotiation_records.order_id and (orders.user_id = auth.uid() OR orders.provider_id = auth.uid()))
  );
```

#### 5.1.15 order_audit_log 表策略
```sql
-- 审计日志查看策略：订单相关方可查看
create policy "Order parties can view audit logs"
  on public.order_audit_log for select
  using (
    exists(select 1 from public.orders where orders.id = order_audit_log.order_id and (orders.user_id = auth.uid() OR orders.provider_id = auth.uid()))
  );

-- 审计日志插入策略：由平台/触发器自动插入，不允许外部手动插入
create policy "Only platform can insert audit logs"
  on public.order_audit_log for insert
  with check ( auth.role() = 'service_role' ); -- 假设有一个服务角色用于平台内部操作
```

#### 5.1.16 order_messages 表策略
```sql
-- 消息查看策略：订单相关方可查看
create policy "Order parties can view messages"
  on public.order_messages for select
  using (
    exists(select 1 from public.orders where orders.id = order_messages.order_id and (orders.user_id = auth.uid() OR orders.provider_id = auth.uid()))
  );

-- 消息插入策略：订单相关方可插入
create policy "Order parties can insert messages"
  on public.order_messages for insert
  with check (
    exists(select 1 from public.orders where orders.id = order_messages.order_id and (orders.user_id = auth.uid() OR orders.provider_id = auth.uid()))
  );
```

#### 5.1.17 refunds 表策略
```sql
-- 退款查看策略：用户和服务商可查看关联的退款记录，管理员也可查看
create policy "Users and providers can view refunds, admins too"
  on public.refunds for select
  using (
    auth.role() = 'admin' OR
    exists(select 1 from public.orders where orders.id = refunds.order_id and orders.user_id = auth.uid()) OR
    exists(select 1 from public.orders where orders.id = refunds.order_id and orders.provider_id = auth.uid())
  );

-- 退款插入策略：用户可申请退款
create policy "Users can request refunds"
  on public.refunds for insert
  with check (
    exists(select 1 from public.orders where orders.id = refunds.order_id and orders.user_id = auth.uid())
  );

-- 退款更新策略：只允许管理员更新退款状态
create policy "Only admins can update refunds"
  on public.refunds for update
  using ( auth.role() = 'admin' );
```

## 6. 索引设计

### 6.1 user_profiles 表索引
```sql
-- 主索引
CREATE INDEX idx_user_profiles_user_id ON public.user_profiles (user_id);

-- 复合索引
CREATE INDEX idx_user_profiles_display_name ON public.user_profiles (display_name);
```

### 6.2 user_addresses 表索引
```sql
-- 复合索引
CREATE INDEX idx_user_addresses_user_id_is_default ON public.user_addresses (user_id, is_default);
CREATE INDEX idx_user_addresses_user_id_created_at ON public.user_addresses (user_id, created_at);
```

### 6.3 user_payment_methods 表索引
```sql
-- 复合索引
CREATE INDEX idx_user_payment_methods_user_id_is_default ON public.user_payment_methods (user_id, is_default);
CREATE INDEX idx_user_payment_methods_user_id_type ON public.user_payment_methods (user_id, type);
```

### 6.4 user_coupons 表索引
```sql
-- 复合索引
CREATE INDEX idx_user_coupons_user_id_status ON public.user_coupons (user_id, status);
CREATE INDEX idx_user_coupons_user_id_valid_until ON public.user_coupons (user_id, valid_until);
```

### 6.5 provider_profiles 表索引
```sql
-- 复合索引
CREATE INDEX idx_provider_profiles_verification_status ON public.provider_profiles (verification_status);
CREATE INDEX idx_provider_profiles_service_categories ON public.provider_profiles USING GIN (service_categories);
CREATE INDEX idx_provider_profiles_default_fulfillment_mode ON public.provider_profiles (default_fulfillment_mode);
CREATE INDEX idx_provider_profiles_provider_type ON public.provider_profiles (provider_type);
```

### 6.6 ref_codes 表索引
```sql
-- 主索引
CREATE INDEX idx_ref_codes_id ON public.ref_codes (id);

-- 复合索引
CREATE INDEX idx_ref_codes_type_code_code ON public.ref_codes (type_code, code);
CREATE INDEX idx_ref_codes_type_code_parent_id ON public.ref_codes (type_code, parent_id);
CREATE INDEX idx_ref_codes_type_code_level ON public.ref_codes (type_code, level);
CREATE INDEX idx_ref_codes_status ON public.ref_codes (status);
```

### 6.7 services 表索引
```sql
-- 主索引
CREATE INDEX idx_services_id ON public.services (id);

-- 复合索引
CREATE INDEX idx_services_category_id_status ON public.services (category_level1_id, status);
CREATE INDEX idx_services_provider_id_status ON public.services (provider_id, status);
CREATE INDEX idx_services_title ON public.services (title);
CREATE INDEX idx_services_location ON public.services (latitude, longitude);
CREATE INDEX idx_services_delivery_method ON public.services (service_delivery_method);
CREATE INDEX idx_services_created_at ON public.services (created_at);
```

### 6.8 service_details 表索引
```sql
-- 主索引
CREATE UNIQUE INDEX idx_service_details_service_id ON public.service_details (service_id);

-- 复合索引
CREATE INDEX idx_service_details_pricing_type ON public.service_details (pricing_type);
CREATE INDEX idx_service_details_duration_type ON public.service_details (duration_type);
CREATE INDEX idx_service_details_tags ON public.service_details USING GIN (tags);
CREATE INDEX idx_service_details_service_area_codes ON public.service_details USING GIN (service_area_codes);
```

### 6.9 orders 表索引
```sql
-- 主索引
CREATE INDEX idx_orders_id ON public.orders (id);

-- 复合索引
CREATE INDEX idx_orders_user_id ON public.orders (user_id);
CREATE INDEX idx_orders_provider_id ON public.orders (provider_id);
CREATE INDEX idx_orders_order_status ON public.orders (order_status);
CREATE INDEX idx_orders_payment_status ON public.orders (payment_status);
CREATE INDEX idx_orders_order_type ON public.orders (order_type);
CREATE INDEX idx_orders_scheduled_start_time ON public.orders (scheduled_start_time);
CREATE INDEX idx_orders_created_at ON public.orders (created_at);
CREATE INDEX idx_orders_fulfillment_mode_snapshot ON public.orders (fulfillment_mode_snapshot);
```

### 6.10 order_items 表索引
```sql
-- 主索引
CREATE INDEX idx_order_items_id ON public.order_items (id);

-- 复合索引
CREATE INDEX idx_order_items_order_id ON public.order_items (order_id);
CREATE INDEX idx_order_items_service_id ON public.order_items (service_id);
```

### 6.11 reviews 表索引
```sql
-- 主索引
CREATE INDEX idx_reviews_id ON public.reviews (id);

-- 复合索引
CREATE INDEX idx_reviews_order_id ON public.reviews (order_id);
CREATE INDEX idx_reviews_service_id ON public.reviews (service_id);
CREATE INDEX idx_reviews_reviewer_id ON public.reviews (reviewer_id);
CREATE INDEX idx_reviews_reviewed_id ON public.reviews (reviewed_id);
CREATE INDEX idx_reviews_review_type ON public.reviews (review_type);
CREATE INDEX idx_reviews_created_at ON public.reviews (created_at);
```

### 6.12 negotiation_records 表索引
```sql
-- 主索引
CREATE INDEX idx_negotiation_records_id ON public.negotiation_records (id);

-- 复合索引
CREATE INDEX idx_negotiation_records_order_id ON public.negotiation_records (order_id);
CREATE INDEX idx_negotiation_records_proposer_id ON public.negotiation_records (proposer_id);
CREATE INDEX idx_negotiation_records_status ON public.negotiation_records (status);
CREATE INDEX idx_negotiation_records_created_at ON public.negotiation_records (created_at);
```

### 6.13 order_audit_log 表索引
```sql
-- 主索引
CREATE INDEX idx_order_audit_log_id ON public.order_audit_log (id);

-- 复合索引
CREATE INDEX idx_order_audit_log_order_id ON public.order_audit_log (order_id);
CREATE INDEX idx_order_audit_log_event_type ON public.order_audit_log (event_type);
CREATE INDEX idx_order_audit_log_changed_by_id ON public.order_audit_log (changed_by_id);
CREATE INDEX idx_order_audit_log_created_at ON public.order_audit_log (created_at);
```

### 6.14 order_messages 表索引
```sql
-- 主索引
CREATE INDEX idx_order_messages_id ON public.order_messages (id);

-- 复合索引
CREATE INDEX idx_order_messages_order_id ON public.order_messages (order_id);
CREATE INDEX idx_order_messages_sender_id ON public.order_messages (sender_id);
CREATE INDEX idx_order_messages_receiver_id ON public.order_messages (receiver_id);
CREATE INDEX idx_order_messages_sent_at ON public.order_messages (sent_at);
```

### 6.15 refunds 表索引
```sql
-- 主索引
CREATE INDEX idx_refunds_id ON public.refunds (id);

-- 复合索引
CREATE INDEX idx_refunds_order_id ON public.refunds (order_id);
CREATE INDEX idx_refunds_refund_status ON public.refunds (refund_status);
CREATE INDEX idx_refunds_created_at ON public.refunds (created_at);
```

## 7. 数据字典

### 7.1 表字段说明

以下表格详细说明了数据库中各表的字段信息，包括字段名、数据类型、是否可空、默认值、描述以及相关约束和索引。

#### auth.users（认证用户表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| id | uuid | 否 | | Supabase Auth 自动生成的用户ID | PK |
| email | text | 否 | | 用户邮箱 | UNIQUE |
| phone | text | 是 | | 用户电话号码 | UNIQUE |
| username | text | 是 | | 用户名 | UNIQUE |
| created_at | timestamptz | 否 | now() | 注册时间 | |
| updated_at | timestamptz | 否 | now() | 最后更新时间 | |
| last_login | timestamptz | 是 | | 最后登录时间 | |
| status | text | 否 | 'active' | 账户状态：active/inactive/suspended | |
| auth_providers | text[] | 是 | '{}' | 认证提供者列表 (如 'email', 'google') | |
| device_info | jsonb | 是 | | 设备信息 | |

#### user_profiles（用户资料表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| user_id | uuid | 否 | | 关联到 auth.users 表的ID | PK, FK |
| avatar_url | text | 是 | | 用户头像URL | |
| display_name | text | 是 | | 显示名称 | INDEX |
| gender | text | 是 | | 性别：male/female/other | |
| birthday | date | 是 | | 出生日期 | |
| language | text | 是 | 'en' | 偏好语言 | |
| timezone | text | 是 | | 偏好时区 | |
| bio | text | 是 | | 个人简介/签名 | |
| preferences | jsonb | 是 | '{}' | 用户偏好设置（如通知设置） | |
| level | integer | 否 | 1 | 用户等级/会员状态 | |
| points | numeric | 否 | 0 | 用户积分/信用分数 | |
| email_verified | boolean | 否 | FALSE | 邮箱验证状态 | |
| phone_verified | boolean | 否 | FALSE | 手机验证状态 | |
| created_at | timestamptz | 否 | now() | 创建时间 | |
| updated_at | timestamptz | 否 | now() | 更新时间 | |

#### provider_profiles（服务商资料表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| id | uuid | 否 | gen_random_uuid() | 服务商ID | PK |
| user_id | uuid | 否 | | 关联到 auth.users 表的ID | UNIQUE, FK |
| company_name | text | 是 | | 公司名称（如果是企业服务商） | |
| contact_phone | text | 否 | | 联系电话 | |
| contact_email | text | 否 | | 联系邮箱 | |
| business_address | text | 是 | | 营业地址 | |
| license_number | text | 是 | | 营业执照号/专业资质号 | |
| description | text | 是 | | 服务商简介 | |
| ratings_avg | numeric | 是 | 0.0 | 平均评分 | |
| review_count | integer | 是 | 0 | 评论数量 | |
| status | text | 否 | 'pending' | 服务商状态：pending/active/suspended/rejected | |
| created_at | timestamptz | 否 | now() | 创建时间 | |
| updated_at | timestamptz | 否 | now() | 更新时间 | |
| provider_type | text | 是 | 'individual' | 服务商类型：individual/corporate | INDEX |
| has_gst_hst | boolean | 是 | FALSE | 是否注册GST/HST | INDEX |
| bn_number | text | 是 | | 商业号码 (Business Number) | |
| annual_income_estimate | numeric | 是 | 0 | 年收入估算（用于税务提醒） | |
| tax_status_notice_shown | boolean | 是 | FALSE | 是否已显示税务状态提醒 | |
| tax_report_available | boolean | 是 | FALSE | 是否可生成税务报告 | |

#### service_categories_level1（一级服务类别表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| id | bigint | 否 | | 类别ID（通过 ref_codes 获取） | PK |
| name_zh | text | 否 | | 中文名称 | UNIQUE |
| name_en | text | 否 | | 英文名称 | UNIQUE |
| description | text | 是 | | 描述 | |
| icon_url | text | 是 | | 图标URL | |
| created_at | timestamptz | 否 | now() | 创建时间 | |
| updated_at | timestamptz | 否 | now() | 更新时间 | |

#### service_categories_level2（二级服务类别表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| id | bigint | 否 | | 类别ID（通过 ref_codes 获取） | PK |
| level1_id | bigint | 否 | | 关联到一级类别ID | FK, INDEX |
| name_zh | text | 否 | | 中文名称 | UNIQUE |
| name_en | text | 否 | | 英文名称 | UNIQUE |
| description | text | 是 | | 描述 | |
| icon_url | text | 是 | | 图标URL | |
| created_at | timestamptz | 否 | now() | 创建时间 | |
| updated_at | timestamptz | 否 | now() | 更新时间 | |

#### services（核心服务信息表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| id | uuid | 否 | gen_random_uuid() | 服务唯一ID | PK |
| provider_id | uuid | 否 | | 服务商ID，关联 provider_profiles | FK, INDEX |
| title | text | 否 | | 服务标题 | INDEX |
| description | text | 否 | | 服务详细描述 | |
| category_level1_id | bigint | 否 | | 关联一级服务类别 | FK, INDEX |
| category_level2_id | bigint | 是 | | 关联二级服务类别 | FK, INDEX |
| status | text | 否 | 'draft' | 服务状态：draft/active/paused/archived | INDEX |
| average_rating | numeric | 是 | 0.0 | 平均评分 | |
| review_count | integer | 是 | 0 | 评论数量 | |
| latitude | numeric | 是 | | 服务提供地点纬度 | INDEX |
| longitude | numeric | 是 | | 服务提供地点经度 | INDEX |
| service_delivery_method | text | 否 | 'on_site' | 服务交付方式：on_site/remote/online/pickup | INDEX |
| created_at | timestamptz | 否 | now() | 创建时间 | |
| updated_at | timestamptz | 否 | now() | 更新时间 | |

#### service_details（服务详细信息表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| service_id | uuid | 否 | | 关联到 services 表的ID | PK, FK |
| pricing_type | text | 否 | 'fixed_price' | 定价类型：fixed_price/hourly/by_project/negotiable/quote_based/free/custom | INDEX |
| price | numeric | 是 | | 服务价格 | |
| currency | text | 是 | | 货币类型 | |
| negotiation_details | text | 是 | | 议价详细说明（如果 pricing_type 是 negotiable） | |
| duration_type | text | 否 | 'hours' | 时长单位：minutes/hours/days/visits/fixed/variable/scope_based | INDEX |
| duration | interval | 是 | | 服务时长 | |
| images_url | text[] | 是 | '{}' | 服务图片URLs | |
| videos_url | text[] | 是 | '{}' | 服务视频URLs | |
| tags | text[] | 是 | '{}' | 服务标签 | GIN |
| service_area_codes | text[] | 是 | '{}' | 服务覆盖区域编码列表（如邮政编码，关联 ref_codes） | GIN |
| platform_service_fee_rate | numeric | 是 | | 平台从托管服务中抽取的服务费率 | |
| min_platform_service_fee | numeric | 是 | | 平台从托管服务中收取的最小服务费 | |
| service_details_json | jsonb | 是 | | 服务详情（流程、材料、注意事项等，通用JSON字段） | |
| extra_data | jsonb | 是 | | 额外数据（通用JSON字段） | |
| promotion_start | timestamptz | 是 | | 促销开始时间 | |
| promotion_end | timestamptz | 是 | | 促销结束时间 | |
| view_count | integer | 是 | 0 | 浏览次数 | |
| favorite_count | integer | 是 | 0 | 收藏次数 | |
| order_count | integer | 是 | 0 | 订单数量 | |
| verification_status | text | 否 | 'pending' | 服务的审核状态：verified/pending/rejected | |
| verification_documents | text[] | 是 | '{}' | 服务的相关认证文档URLs列表 | |
| created_at | timestamptz | 否 | now() | 创建时间 | |
| updated_at | timestamptz | 否 | now() | 更新时间 | |

#### user_addresses（用户地址表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| id | uuid | 否 | gen_random_uuid() | 地址唯一ID | PK |
| user_id | uuid | 否 | | 关联到 auth.users 表的ID | FK, INDEX |
| address_line1 | text | 否 | | 地址第一行 | |
| address_line2 | text | 是 | | 地址第二行 | |
| city | text | 否 | | 城市 | |
| province | text | 否 | | 省份/州 | |
| postal_code | text | 否 | | 邮政编码 | |
| country | text | 否 | 'CA' | 国家 | |
| is_default | boolean | 否 | FALSE | 是否默认地址 | |
| created_at | timestamptz | 否 | now() | 创建时间 | |
| updated_at | timestamptz | 否 | now() | 更新时间 | |

#### orders（订单表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| id | uuid | 否 | gen_random_uuid() | 订单唯一ID | PK |
| user_id | uuid | 否 | | 用户ID，关联 auth.users | FK, INDEX |
| service_id | uuid | 否 | | 服务ID，关联 service_info | FK, INDEX |
| service_provider_id | uuid | 否 | | 服务商ID，关联 provider_profiles | FK, INDEX |
| order_status | text | 否 | 'pending' | 订单状态：pending/accepted/rejected/in_progress/completed/cancelled/refunded | INDEX |
| total_amount | numeric | 否 | | 订单总金额 | |
| deposit_amount | numeric | 是 | | 预付定金金额 | |
| final_payment_amount | numeric | 是 | | 最终支付金额 | |
| payment_status | text | 否 | 'unpaid' | 支付状态：unpaid/paid_deposit/paid_full/refunded/partially_refunded | |
| payment_method_id | uuid | 是 | | 支付方式ID（如果需要更详细记录） | |
| order_date | timestamptz | 否 | now() | 下单时间 | INDEX |
| scheduled_start_time | timestamptz | 是 | | 预约服务开始时间 | |
| scheduled_end_time | timestamptz | 是 | | 预约服务结束时间 | |
| actual_start_time | timestamptz | 是 | | 实际服务开始时间 | |
| actual_end_time | timestamptz | 是 | | 实际服务结束时间 | |
| service_address_id | uuid | 是 | | 服务地址ID，关联 user_addresses | FK, INDEX |
| cancellation_reason | text | 是 | | 取消原因 | |
| refund_status | text | 是 | | 退款状态：pending/approved/rejected/completed | |
| created_at | timestamptz | 否 | now() | 创建时间 | |
| updated_at | timestamptz | 否 | now() | 更新时间 | |

#### order_items（订单项表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| id | uuid | 否 | gen_random_uuid() | 订单项ID | PK |
| order_id | uuid | 否 | | 关联到 orders 表的ID | FK, INDEX |
| service_id | uuid | 否 | | 关联到 service_info 表的ID | FK, INDEX |
| quantity | integer | 否 | 1 | 数量 | |
| unit_price | numeric | 否 | | 单位价格 | |
| item_total | numeric | 否 | | 订单项总价 | |
| created_at | timestamptz | 否 | now() | 创建时间 | |
| updated_at | timestamptz | 否 | now() | 更新时间 | |

#### reviews（评价表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| id | uuid | 否 | gen_random_uuid() | 评价唯一ID | PK |
| order_id | uuid | 否 | | 关联到 orders 表的ID | UNIQUE, FK, INDEX |
| service_id | uuid | 否 | | 关联到 service_info 表的ID | FK, INDEX |
| user_id | uuid | 否 | | 关联到 auth.users 表的ID | FK, INDEX |
| rating | integer | 否 | | 评分 (1-5星) | INDEX |
| comment | text | 是 | | 评价内容 | |
| review_images_url | text[] | 是 | '{}' | 评价图片URLs | |
| created_at | timestamptz | 否 | now() | 创建时间 | |
| updated_at | timestamptz | 否 | now() | 更新时间 | |

#### negotiation_records（议价记录表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| id | uuid | 否 | gen_random_uuid() | 议价记录ID | PK |
| order_id | uuid | 否 | | 关联到 orders 表的ID | FK, INDEX |
| negotiator_id | uuid | 否 | | 议价方ID (用户或服务商) | FK, INDEX |
| negotiator_type | text | 否 | | 议价方类型：user/provider | |
| proposed_amount | numeric | 否 | | 提议金额 | |
| proposed_duration | interval | 是 | | 提议时长 | |
| message | text | 是 | | 议价留言 | |
| status | text | 否 | 'pending' | 议价状态：pending/accepted/rejected/countered | |
| created_at | timestamptz | 否 | now() | 创建时间 | |
| updated_at | timestamptz | 否 | now() | 更新时间 | |

#### order_audit_log（订单审计日志表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| id | uuid | 否 | gen_random_uuid() | 日志ID | PK |
| order_id | uuid | 否 | | 关联到 orders 表的ID | FK, INDEX |
| actor_id | uuid | 否 | | 操作执行者ID (用户、服务商或系统) | FK, INDEX |
| actor_type | text | 否 | | 操作执行者类型：user/provider/system | |
| action_type | text | 否 | | 操作类型：create/update_status/cancel/refund/message/negotiate | INDEX |
| old_value | jsonb | 是 | | 旧值（JSON格式） | |
| new_value | jsonb | 是 | | 新值（JSON格式） | |
| reason | text | 是 | | 操作原因 | |
| created_at | timestamptz | 否 | now() | 操作时间 | |

#### order_messages（订单消息表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| id | uuid | 否 | gen_random_uuid() | 消息ID | PK |
| order_id | uuid | 否 | | 关联到 orders 表的ID | FK, INDEX |
| sender_id | uuid | 否 | | 发送者ID (用户或服务商) | FK, INDEX |
| sender_type | text | 否 | | 发送者类型：user/provider | |
| message_content | text | 否 | | 消息内容 | |
| sent_at | timestamptz | 否 | now() | 发送时间 | INDEX |
| is_read | boolean | 否 | FALSE | 是否已读 | |
| read_at | timestamptz | 是 | | 阅读时间 | |

#### refunds（退款表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| id | uuid | 否 | gen_random_uuid() | 退款ID | PK |
| order_id | uuid | 否 | | 关联到 orders 表的ID | FK, INDEX |
| refund_amount | numeric | 否 | | 退款金额 | |
| refund_reason | text | 否 | | 退款原因 | |
| refund_status | text | 否 | 'pending' | 退款状态：pending/approved/rejected/completed | INDEX |
| processed_by | uuid | 是 | | 处理人ID (管理员) | |
| processed_at | timestamptz | 是 | | 处理时间 | |
| created_at | timestamptz | 否 | now() | 退款请求的创建时间 | |
| updated_at | timestamptz | 否 | now() | 退款记录的最后更新时间 | |

#### notifications（通知表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| id | uuid | 否 | gen_random_uuid() | 通知唯一ID | PK |
| recipient_id | uuid | 否 | | 接收者ID（用户或服务商） | FK, INDEX |
| recipient_type | text | 否 | | 接收者类型：user/provider | INDEX |
| notification_type | text | 否 | | 通知类型：system/order/promotion/account/announcement | INDEX |
| title | text | 否 | | 通知标题 | |
| message | text | 否 | | 通知内容 | |
| related_entity_id | uuid | 是 | | 关联实体ID | FK, INDEX |
| related_entity_type | text | 是 | | 关联实体类型 | |
| is_read | boolean | 否 | FALSE | 是否已读 | INDEX |
| sent_at | timestamptz | 否 | now() | 发送时间 | |
| read_at | timestamptz | 是 | | 阅读时间 | |
| created_at | timestamptz | 否 | now() | 创建时间 | |
| updated_at | timestamptz | 否 | now() | 更新时间 | |

#### promotions（营销活动表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| id | uuid | 否 | gen_random_uuid() | 活动唯一ID | PK |
| name | text | 否 | | 活动名称 | |
| description | text | 是 | | 活动描述 | |
| type | text | 否 | | 活动类型：coupon/discount/package/referral | INDEX |
| value | numeric | 否 | | 优惠值 | |
| value_type | text | 否 | | 优惠值类型：percentage/fixed_amount | |
| min_order_amount | numeric | 是 | 0 | 最低使用金额 | |
| max_discount_amount | numeric | 是 | | 最大优惠金额 | |
| usage_limit_per_user | integer | 是 | | 每用户使用限制 | |
| usage_limit_total | integer | 是 | | 总使用限制 | |
| start_time | timestamptz | 否 | | 活动开始时间 | |
| end_time | timestamptz | 否 | | 活动结束时间 | |
| target_audience | text | 否 | 'all' | 目标用户 | INDEX |
| target_categories | bigint[] | 是 | '{}' | 目标服务类别 | GIN |
| target_services | uuid[] | 是 | '{}' | 目标服务 | GIN |
| status | text | 否 | 'scheduled' | 活动状态：active/inactive/ended/scheduled | INDEX |
| created_at | timestamptz | 否 | now() | 创建时间 | |
| updated_at | timestamptz | 否 | now() | 更新时间 | |

#### provider_schedules（服务商日程表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| id | uuid | 否 | gen_random_uuid() | 日程唯一ID | PK |
| provider_id | uuid | 否 | | 服务商ID | FK, INDEX |
| service_id | uuid | 是 | | 关联服务ID | FK, INDEX |
| schedule_type | text | 否 | | 日程类型：daily/weekly/one_time/block | INDEX |
| start_time | timestamptz | 否 | | 可用时间段开始时间 | INDEX |
| end_time | timestamptz | 否 | | 可用时间段结束时间 | INDEX |
| is_available | boolean | 否 | TRUE | 当前时间段是否可用 | |
| capacity | integer | 是 | 1 | 可接单容量 | |
| booked_capacity | integer | 是 | 0 | 已预订容量 | |
| recurrence_rule | text | 是 | | 重复规则 | |
| created_at | timestamptz | 否 | now() | 创建时间 | |
| updated_at | timestamptz | 否 | now() | 更新时间 | |

#### admin_users（管理员用户表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| id | uuid | 否 | gen_random_uuid() | 管理员用户ID | PK |
| username | text | 否 | | 登录名 | UNIQUE |
| email | text | 否 | | 邮箱 | UNIQUE |
| password_hash | text | 否 | | 密码哈希 | |
| display_name | text | 是 | | 显示名称 | |
| role_id | uuid | 否 | | 角色ID | FK, INDEX |
| status | text | 否 | 'active' | 账户状态：active/inactive/locked | |
| last_login_at | timestamptz | 是 | | 最后登录时间 | |
| created_at | timestamptz | 否 | now() | 创建时间 | |
| updated_at | timestamptz | 否 | now() | 更新时间 | |

#### roles_permissions（角色权限表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| id | uuid | 否 | gen_random_uuid() | 角色ID | PK |
| role_name | text | 否 | | 角色名称 | UNIQUE |
| description | text | 是 | | 角色描述 | |
| permissions | text[] | 否 | '{}' | 权限列表 | GIN |
| created_at | timestamptz | 否 | now() | 创建时间 | |
| updated_at | timestamptz | 否 | now() | 更新时间 | |

#### ref_codes（层级编码表）
| 字段名 | 类型 | 可空 | 默认值 | 描述 | 约束/索引 |
|---|---|---|---|---|---|
| id | bigint | 否 | | 编码ID | PK |
| type_code | text | 否 | | 类型编码 (如 service_category, address_province) | INDEX |
| code | text | 否 | | 具体编码 (如 01, AB) | INDEX |
| chinese_name | text | 否 | | 中文名称 | |
| english_name | text | 否 | | 英文名称 | |
| parent_id | bigint | 是 | | 父级编码ID（用于层级结构） | FK, INDEX |
| level | integer | 否 | | 层级 | INDEX |
| description | text | 是 | | 描述 | |
| sort_order | integer | 是 | 0 | 排序顺序 | |
| status | text | 否 | 'active' | 状态：active/inactive | |
| created_at | timestamptz | 否 | now() | 创建时间 | |
| updated_at | timestamptz | 否 | now() | 更新时间 | |
| extra_data | jsonb | 是 | | 额外数据（如图标URL、颜色） | |

## 8. 数据字典

### 8.1 user_profiles 表字段说明
- user_id: 用户ID，关联 auth.users
- avatar_url: 用户头像URL
- display_name: 用户显示名称
- gender: 用户性别
- birthday: 用户生日
- language: 用户首选语言
- timezone: 用户时区
- bio: 用户个人简介
- preferences: 用户偏好设置，包括通知设置和隐私设置

### 8.2 user_addresses 表字段说明
- id: 地址ID
- user_id: 用户ID，关联 auth.users
- name: 地址名称
- recipient: 收件人姓名
- phone: 联系电话
- country: 国家
- state: 州/省
- city: 城市
- street: 街道
- postal_code: 邮政编码
- is_default: 是否默认地址
- location: 地理位置信息，包括经纬度

### 8.3 user_payment_methods 表字段说明
- id: 支付方式ID
- user_id: 用户ID，关联 auth.users
- type: 支付方式类型，如信用卡、银行账户、电子钱包
- provider: 支付提供商，如 Stripe, PayPal
- token: 加密存储的支付令牌
- last_4: 卡号后四位
- is_default: 是否默认支付方式
- expires_at: 过期时间
- billing_address: 账单地址信息

### 8.4 user_wallet 表字段说明
- user_id: 用户ID，关联 auth.users
- balance: 用户金豆余额
- points: 用户积分
- currency: 货币类型
- frozen_amount: 冻结金额

### 8.5 user_coupons 表字段说明
- id: 优惠券ID
- user_id: 用户ID，关联 auth.users
- coupon_id: 优惠券模板ID
- status: 优惠券状态，如有效、已使用、过期
- amount: 优惠金额
- min_order_amount: 最低使用金额
- valid_from: 生效时间
- valid_until: 过期时间
- used_at: 使用时间
- order_id: 关联订单ID

### 8.6 ref_codes 表字段说明
- id: 主键ID
- type_code: 实体类型编码，如 SERVICE_TYPE, PROVIDER_TYPE
- code: 分类编码，同一类型下唯一
- chinese_name: 中文名称
- english_name: 英文名称
- parent_id: 父节点ID，NULL 表示一级分类
- level: 层级，用于区分一级、二级、三级分类
- description: 分类描述
- sort_order: 排序序号
- status: 状态，控制分类是否可用
- created_at: 创建时间
- updated_at: 更新时间
- extra_data: 额外数据，如图标、特定属性等

### 8.7 services 表字段说明
- id: 服务的唯一标识符
- provider_id: 提供此服务的服务商ID，关联 provider_profiles 表
- title: 服务的名称，如"上门清洁"、"搬家服务"
- description: 服务的详细描述，介绍服务内容和特点
- category_level1_id: 服务所属的一级分类ID，关联 ref_codes 表
- category_level2_id: 服务所属的二级分类ID，关联 ref_codes 表
- status: 服务的当前状态，如活跃、非活跃、暂停等
- average_rating: 服务的平均评分
- review_count: 服务的评价总数
- latitude: 服务的纬度坐标
- longitude: 服务的经度坐标
- service_delivery_method: 定义服务如何交付，影响位置信息是否必填和地图展示方式
- created_at: 服务记录的创建时间
- updated_at: 服务记录的最后更新时间

### 8.8 service_details 表字段说明
- service_id: 关联到 services 表的ID，作为主键，确保一对一关系
- pricing_type: 定义服务的定价方式
- price: 服务价格
- currency: 货币类型
- negotiation_details: 议价详细说明
- duration_type: 定义服务的时长类型
- duration: 服务时长
- images_url: 服务相关的图片URLs列表
- videos_url: 服务相关的视频URLs列表
- tags: 用于描述服务的关键词列表
- service_area_codes: 服务覆盖区域编码列表
- platform_service_fee_rate: 平台从托管服务中抽取的服务费率
- min_platform_service_fee: 平台从托管服务中收取的最小服务费
- service_details_json: 服务详情（流程、材料、注意事项等），通用JSON字段
- extra_data: 额外数据，通用JSON字段
- promotion_start: 促销活动的开始时间
- promotion_end: 促销活动的结束时间
- view_count: 服务的浏览次数
- favorite_count: 服务的收藏次数
- order_count: 服务的订单数量
- verification_status: 服务的审核状态
- verification_documents: 服务的相关认证文档URLs列表
- created_at: 服务详细信息记录的创建时间
- updated_at: 服务详细信息记录的最后更新时间

### 8.9 orders 表字段说明
- id: 订单的唯一标识符
- order_number: 订单的业务编号，供用户和平台查询使用，需唯一
- user_id: 下单用户的ID
- provider_id: 提供服务的服务商ID
- order_type: 订单类型，如按需服务、租赁、预约、议价、套餐等
- fulfillment_mode_snapshot: 订单创建时服务的履行模式快照：platform/external
- order_status: 订单的当前状态，支持完整的生命周期流转
- total_price: 订单的总价，包括所有费用
- currency: 订单价格的货币类型
- payment_status: 支付状态，记录支付的进度
- deposit_amount: 如果服务需要支付订金或押金，此字段记录金额
- final_payment_amount: 如果存在尾款，此字段记录金额
- coupon_id: 记录订单使用了哪个优惠券
- points_deduction_amount: 记录订单使用了多少积分抵扣
- platform_service_fee_rate_snapshot: 订单创建时的平台服务费率快照
- platform_service_fee_amount: 平台从订单中实际收取的服务费金额
- scheduled_start_time: 预约服务的计划开始时间
- scheduled_end_time: 预约服务的计划结束时间
- actual_start_time: 实际服务开始时间，用于结算和统计
- actual_end_time: 实际服务结束时间，用于结算和统计
- service_address_id: 如果服务地点是用户已保存的地址，关联其ID
- service_address_snapshot: 存储下单时服务的详细地址，作为快照防止用户修改地址后订单信息不一致
- service_latitude: 服务地点的纬度，用于地图显示和导航
- service_longitude: 服务地点的经度，用于地图显示和导航
- user_notes: 用户在下单时或后续添加的备注
- provider_notes: 服务商在接单或服务过程中添加的备注
- expires_at: 订单在某些状态下的过期时间，过期自动作废
- cancellation_reason: 订单取消的原因
- cancellation_fee: 订单取消可能产生的违约金
- dispute_status: 订单是否存在纠纷，以及纠纷处理状态
- support_ticket_id: 关联到客服系统的工单ID
- created_at: 订单的创建时间
- updated_at: 订单的最后更新时间

### 8.10 order_items 表字段说明
- id: 订单项的唯一标识符
- order_id: 关联到主订单表
- service_id: 关联到具体的服务信息表
- quantity: 服务的数量
- unit_price_snapshot: 下单时服务的单价，作为快照
- subtotal_price: 该订单项的总价
- service_name_snapshot: 服务名称快照
- service_description_snapshot: 服务描述快照
- service_image_snapshot: 服务图片快照
- item_details_snapshot: 存储该订单项的额外细节，如选择的颜色、尺寸、定制内容等
- pricing_type_snapshot: 定价方式快照
- duration_type_snapshot: 时长类型快照
- duration_snapshot: 服务时长快照
- is_package_item: 标记此订单项是否属于某个套餐
- parent_item_id: 如果是套餐内的子项，指向其所属的套餐订单项
- created_at: 订单项的创建时间
- updated_at: 订单项的最后更新时间

### 8.11 reviews 表字段说明
- id: 评价的唯一标识符
- order_id: 关联到订单表，一个订单可以产生用户对服务商的评价和服务商对用户的评价
- service_id: 关联到具体服务
- reviewer_id: 实施评价的用户或服务商ID
- reviewed_id: 被评价的用户或服务商ID
- rating: 评分等级（1-5星）
- comment: 评价的文本内容
- image_urls: 评价时上传的图片链接
- is_anonymous: 标记是否匿名评价
- review_type: 区分是用户评价服务商还是服务商评价用户
- created_at: 评价的创建时间
- updated_at: 评价的最后更新时间

### 8.12 negotiation_records 表字段说明
- id: 议价记录的唯一标识符
- order_id: 议价成功后，该记录会关联到对应的订单
- proposer_id: 提出当前报价的用户ID或服务商ID
- proposed_amount: 本次协商提出的金额
- proposed_duration: 本次协商提出的服务时长
- message: 协商过程中交流的文本信息
- status: 协商的状态，如待确认、已接受、已拒绝、已反驳等
- created_at: 议价记录的创建时间
- updated_at: 议价记录的最后更新时间

### 8.13 order_audit_log 表字段说明
- id: 审计日志的唯一标识符
- order_id: 关联到被审计的订单
- event_type: 记录发生的事件类型，如订单状态变更、价格调整、地址修改等
- old_value: 存储字段变更前的值，适用于字段变更
- new_value: 存储字段变更后的值，适用于字段变更
- changed_by_id: 记录执行此操作的用户、服务商或管理员ID
- description: 对事件的简要描述
- created_at: 事件发生的时间戳

### 8.14 order_messages 表字段说明
- id: 消息的唯一标识符
- order_id: 关联到所属订单
- sender_id: 消息发送者ID
- receiver_id: 消息接收者ID
- message_text: 消息的文本内容
- image_urls: 消息中包含的图片链接
- sent_at: 消息发送的时间戳
- read_at: 消息被接收者阅读的时间戳

### 8.15 refunds 表字段说明
- id: 退款的唯一标识符
- order_id: 关联到所属订单
- refund_amount: 实际退款金额
- refund_status: 退款的当前状态，如待审核、已批准、已处理等
- reason: 用户申请退款的原因
- evidence_urls: 用户提供的退款证据链接
- processed_by_id: 处理此退款请求的管理员ID
- processed_at: 退款处理完成的时间戳
- created_at: 退款请求的创建时间
- updated_at: 退款记录的最后更新时间

### 8.16 provider_profiles 表字段说明
- id: 用户ID，关联 auth.users
- business_name: 商家名称
- business_description: 商家描述
- business_phone: 商家电话
- business_email: 商家邮箱
- business_address: 商家地址
- service_areas: 服务区域
- service_categories: 服务类别，关联 ref_codes
- verification_status: 认证状态
- verification_documents: 认证文档URLs列表
- created_at: 创建时间
- updated_at: 更新时间
- default_fulfillment_mode: 服务商默认发布的服务模式，可在发布时修改
- provider_type: 服务者身份类型，区分个人服务者、注册商户或平台代办注册
- has_gst_hst: 标记服务者是否已注册 GST/HST 号码
- bn_number: 加拿大注册商户的 Business Number (BN)，如果适用
- annual_income_estimate: 服务者提供的年收入预估，用于税务提示逻辑
- tax_status_notice_shown: 标记是否已向服务者展示过税务合规提示
- tax_report_available: 标记是否已为该服务者生成年度税务汇总报表

## 9. 性能优化

### 9.1 查询优化
1. 使用适当的索引
2. 优化查询语句
3. 使用物化视图
4. 定期维护索引

### 9.2 数据分区
1. 按时间分区
2. 按用户类型分区
3. 按地区分区

### 9.3 缓存策略
1. 使用 Redis 缓存
2. 实现查询缓存
3. 缓存失效策略

## 10. 数据迁移

### 10.1 迁移策略
1. 使用 Supabase 迁移工具
2. 版本控制迁移脚本
3. 回滚机制

### 10.2 迁移步骤
1. 备份数据
2. 执行迁移
3. 验证数据
4. 更新应用

## 11. 备份策略

### 11.1 备份方式
1. 自动备份
2. 手动备份
3. 增量备份

### 11.2 备份周期
1. 每日备份
2. 每周备份
3. 每月备份

### 11.3 备份验证
1. 定期恢复测试
2. 数据完整性检查
3. 性能测试

## 12. 监控方案

### 12.1 监控指标
1. 数据库性能
2. 查询性能
3. 存储使用
4. 连接数

### 12.2 告警设置
1. 性能告警
2. 容量告警
3. 错误告警

### 12.3 日志管理
1. 错误日志
2. 慢查询日志
3. 审计日志 