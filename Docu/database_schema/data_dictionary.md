# Data Dictionary

> 本文件为 JinBean 数据库字段/表详细说明，便于开发、测试、运维查阅。

## ref_codes
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | bigint | PK | 主键 |
| type_code | text | NOT NULL | 字典类型（如 SERVICE_TYPE, AREA_CODE）|
| code | text | NOT NULL | 业务编码 |
| name | jsonb | NOT NULL | 多语言名称 |
| description | jsonb |  | 多语言描述 |
| parent_id | bigint | FK | 父级ID |
| sort_order | integer | DEFAULT 0 | 排序 |
| is_active | boolean | DEFAULT true | 是否启用 |
| created_at | timestamptz | DEFAULT now() | 创建时间 |
| updated_at | timestamptz | DEFAULT now() | 更新时间 |

## user_profiles
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | uuid | PK, DEFAULT uuid_generate_v4() | 主键 |
| user_id | uuid | UNIQUE, NOT NULL, FK | 关联 auth.users |
| avatar_url | text |  | 头像URL |
| display_name | text |  | 昵称 |
| gender | text |  | 性别 |
| birthday | date |  | 生日 |
| language | text | DEFAULT 'en' | 语言 |
| timezone | text | DEFAULT 'UTC' | 时区 |
| bio | text |  | 个人简介 |
| points | integer | DEFAULT 0 | 积分 |
| phone_verified | boolean | DEFAULT false | 手机验证 |
| preferences | jsonb | DEFAULT ... | 偏好设置 |
| verification | jsonb | DEFAULT ... | 认证信息 |
| service_preferences | jsonb | DEFAULT ... | 服务偏好 |
| social_links | jsonb | DEFAULT ... | 社交链接 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | 创建时间 |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | 更新时间 |

## provider_profiles
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | uuid | PK, DEFAULT uuid_generate_v4() | 主键 |
| user_id | uuid | UNIQUE, NOT NULL, FK | 关联 auth.users |
| company_name | text |  | 公司名 |
| contact_phone | text | NOT NULL | 联系电话 |
| contact_email | text | NOT NULL | 联系邮箱 |
| business_address | text |  | 公司地址 |
| license_number | text |  | 营业执照号 |
| description | text |  | 介绍 |
| ratings_avg | numeric | DEFAULT 0.0 | 平均评分 |
| review_count | integer | DEFAULT 0 | 评价数 |
| status | text | NOT NULL, DEFAULT 'pending' | 状态 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | 创建时间 |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | 更新时间 |
| provider_type | text | DEFAULT 'individual' | 服务商类型 |
| has_gst_hst | boolean | DEFAULT FALSE | 是否有GST/HST |
| bn_number | text |  | 税号 |
| annual_income_estimate | numeric | DEFAULT 0 | 年收入估算 |
| tax_status_notice_shown | boolean | DEFAULT FALSE | 税务提示 |
| tax_report_available | boolean | DEFAULT FALSE | 税务报告 |

## services
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | uuid | PK, DEFAULT uuid_generate_v4() | 主键 |
| provider_id | uuid | NOT NULL, FK | 关联 provider_profiles |
| title | jsonb | NOT NULL | 多语言标题 |
| description | jsonb |  | 多语言描述 |
| category_level1_id | bigint | NOT NULL, FK | 一级分类 |
| category_level2_id | bigint | FK | 二级分类 |
| status | text | NOT NULL, DEFAULT 'draft' | 状态 |
| average_rating | numeric | DEFAULT 0.0 | 平均评分 |
| review_count | integer | DEFAULT 0 | 评价数 |
| latitude | numeric |  | 纬度 |
| longitude | numeric |  | 经度 |
| service_delivery_method | text | NOT NULL, DEFAULT 'on_site' | 服务方式 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | 创建时间 |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | 更新时间 |

## service_details
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| service_id | uuid | PK, FK | 关联 services |
| pricing_type | text | NOT NULL, DEFAULT 'fixed_price' | 计价类型 |
| price | numeric |  | 价格 |
| currency | text |  | 币种 |
| negotiation_details | text |  | 协商细节 |
| duration_type | text | NOT NULL, DEFAULT 'hours' | 时长类型 |
| duration | interval |  | 时长 |
| images_url | text[] | DEFAULT '{}' | 图片 |
| videos_url | text[] | DEFAULT '{}' | 视频 |
| tags | text[] | DEFAULT '{}' | 标签 |
| service_area_codes | text[] | DEFAULT '{}' | 服务区域编码 |
| platform_service_fee_rate | numeric |  | 平台服务费率 |
| min_platform_service_fee | numeric |  | 最低服务费 |
| service_details_json | jsonb |  | 详情JSON |
| extra_data | jsonb |  | 扩展数据 |
| promotion_start | timestamptz |  | 促销开始 |
| promotion_end | timestamptz |  | 促销结束 |
| view_count | integer | DEFAULT 0 | 浏览数 |
| favorite_count | integer | DEFAULT 0 | 收藏数 |
| order_count | integer | DEFAULT 0 | 订单数 |
| verification_status | text | NOT NULL, DEFAULT 'pending' | 审核状态 |
| verification_documents | text[] | DEFAULT '{}' | 审核文档 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | 创建时间 |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | 更新时间 |

## orders
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | uuid | PK, DEFAULT uuid_generate_v4() | 主键 |
| order_number | text | UNIQUE, NOT NULL | 订单号 |
| user_id | uuid | NOT NULL, FK | 关联 auth.users |
| provider_id | uuid | NOT NULL, FK | 关联 provider_profiles |
| service_id | uuid | NOT NULL, FK | 关联 services |
| order_status | text | NOT NULL, DEFAULT 'pending' | 订单状态 |
| payment_status | text | NOT NULL, DEFAULT 'unpaid' | 支付状态 |
| order_type | text | NOT NULL, DEFAULT 'service' | 订单类型 |
| scheduled_start_time | timestamptz |  | 预约开始 |
| scheduled_end_time | timestamptz |  | 预约结束 |
| total_price | numeric |  | 总价 |
| currency | text |  | 币种 |
| address | text |  | 服务地址 |
| contact_phone | text |  | 联系电话 |
| contact_name | text |  | 联系人 |
| notes | text |  | 备注 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | 创建时间 |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | 更新时间 |

## order_items
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | uuid | PK, DEFAULT uuid_generate_v4() | 主键 |
| order_id | uuid | NOT NULL, FK | 关联 orders |
| service_id | uuid | NOT NULL, FK | 关联 services |
| item_name | text |  | 项目名称 |
| quantity | integer | DEFAULT 1 | 数量 |
| unit_price | numeric |  | 单价 |
| total_price | numeric |  | 总价 |
| created_at | timestamptz | NOT NULL, DEFAULT now() | 创建时间 |
| updated_at | timestamptz | NOT NULL, DEFAULT now() | 更新时间 | 