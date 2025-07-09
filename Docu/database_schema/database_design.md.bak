# 金豆荚 JinBeanPod 主要数据库 ER 图（文本版）

```
# 用户与认证
[auth.users] <1---1> [user_profiles]
[auth.users] <1---1> [user_settings]
[auth.users] <1---1> [user_wallet]
[auth.users] <1---*| [user_addresses]
[auth.users] <1---*| [user_payment_methods]
[auth.users] <1---*| [user_coupons]

# 服务商
[auth.users] <1---1> [provider_profiles]
[provider_profiles] <1---*| [services]
[provider_profiles] <1---*| [provider_schedules]

# 服务与分类
[services] <1---1> [service_details]
[services] <*---1> [ref_codes]  # category_level1_id
[services] <*---1> [ref_codes]  # category_level2_id
[provider_profiles] <*---*| [ref_codes]  # service_categories

# 订单
[auth.users] <1---*| [orders]  # user_id
[provider_profiles] <1---*| [orders]  # provider_id
[orders] <1---*| [order_items]
[orders] <1---*| [negotiation_records]
[orders] <1---*| [order_audit_log]
[orders] <1---*| [order_messages]
[orders] <1---*| [refunds]
[orders] <1---*| [reviews]
[orders] <*---1> [user_addresses]  # service_address_id
[order_items] <*---1> [services]

# 评价
[reviews] <*---1> [orders]
[reviews] <*---1> [services]
[reviews] <*---1> [auth.users]  # reviewer_id
[reviews] <*---1> [auth.users]  # reviewed_id

# 钱包/支付/优惠券
[auth.users] <1---1> [user_wallet]
[auth.users] <1---*| [user_payment_methods]
[auth.users] <1---*| [user_coupons]
[orders] <*---1> [user_coupons]  # coupon_id

# 通知/营销
[auth.users] <1---*| [notifications]  # recipient_id
[promotions] <1---*| [user_coupons]  # coupon_id

# 后台管理
[admin_users] <*---1> [roles_permissions]

# 说明：
# <1---1> 一对一
# <1---*| 一对多
# <*---*| 多对多（如通过数组或中间表）
# 箭头指向被依赖方/外键方
```

---

## 实体简要说明
- **auth.users**：平台所有用户（含普通用户、服务商、管理员）
- **user_profiles**：用户扩展资料
- **user_settings**：用户个性化设置
- **user_wallet**：用户钱包/积分
- **user_addresses**：用户地址簿
- **user_payment_methods**：用户支付方式
- **user_coupons**：用户优惠券
- **provider_profiles**：服务商资料
- **provider_schedules**：服务商日程
- **services**：服务主表
- **service_details**：服务详细属性
- **ref_codes**：服务/分类/区域等多级分类
- **orders**：订单主表
- **order_items**：订单明细
- **negotiation_records**：议价记录
- **order_audit_log**：订单审计日志
- **order_messages**：订单内消息
- **refunds**：退款
- **reviews**：评价
- **notifications**：通知
- **promotions**：营销活动/优惠券模板
- **admin_users**：后台管理员
- **roles_permissions**：后台角色权限 