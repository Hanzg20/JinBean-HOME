-- =====================================================
-- JinBean Platform - 数据库索引和约束详细说明
-- 配合带注释的主表结构文件使用
-- 包含所有索引、约束、触发器的详细说明
-- =====================================================

-- =====================================================
-- 1. 基础表索引
-- =====================================================

-- addresses 表索引
CREATE INDEX IF NOT EXISTS idx_addresses_user_id ON addresses (user_id);                    -- 按用户查询地址
CREATE INDEX IF NOT EXISTS idx_addresses_type ON addresses (address_type);                  -- 按地址类型查询
CREATE INDEX IF NOT EXISTS idx_addresses_location ON addresses (latitude, longitude);       -- 地理位置查询
CREATE INDEX IF NOT EXISTS idx_addresses_default ON addresses (user_id, is_default);        -- 查询用户默认地址

-- user_profiles 表索引
CREATE INDEX IF NOT EXISTS idx_user_profiles_language ON user_profiles (preferred_language); -- 按语言偏好查询
CREATE INDEX IF NOT EXISTS idx_user_profiles_created ON user_profiles (created_at);         -- 按注册时间查询

-- =====================================================
-- 2. 分类系统索引
-- =====================================================

-- ref_codes 表索引
CREATE INDEX IF NOT EXISTS idx_ref_codes_type_code ON ref_codes (type_code);                -- 按分类类型查询
CREATE INDEX IF NOT EXISTS idx_ref_codes_code ON ref_codes (code);                          -- 按代码查询
CREATE INDEX IF NOT EXISTS idx_ref_codes_parent_id ON ref_codes (parent_id);                -- 按父级查询子分类
CREATE INDEX IF NOT EXISTS idx_ref_codes_level ON ref_codes (level);                        -- 按层级查询
CREATE INDEX IF NOT EXISTS idx_ref_codes_status ON ref_codes (status);                      -- 按状态查询
CREATE INDEX IF NOT EXISTS idx_ref_codes_industry_type ON ref_codes (industry_type);        -- 按行业类型查询
CREATE INDEX IF NOT EXISTS idx_ref_codes_sort ON ref_codes (type_code, sort_order);         -- 分类排序查询
CREATE INDEX IF NOT EXISTS idx_ref_codes_active_sort ON ref_codes (type_code, sort_order, status) WHERE status = 1; -- 有效分类排序

-- industry_configs 表索引
CREATE INDEX IF NOT EXISTS idx_industry_configs_type ON industry_configs (industry_type);   -- 按行业类型查询
CREATE INDEX IF NOT EXISTS idx_industry_configs_active ON industry_configs (is_active);     -- 按激活状态查询
CREATE INDEX IF NOT EXISTS idx_industry_configs_sort ON industry_configs (sort_order);      -- 按排序查询

-- =====================================================
-- 3. 购物车系统索引
-- =====================================================

-- shopping_carts 表索引
CREATE INDEX IF NOT EXISTS idx_shopping_carts_user_id ON shopping_carts (user_id);          -- 按用户查询购物车
CREATE INDEX IF NOT EXISTS idx_shopping_carts_service_id ON shopping_carts (service_id);    -- 按服务商查询购物车
CREATE INDEX IF NOT EXISTS idx_shopping_carts_status ON shopping_carts (status);            -- 按状态查询购物车
CREATE INDEX IF NOT EXISTS idx_shopping_carts_expires_at ON shopping_carts (expires_at);    -- 过期时间查询（用于清理）
CREATE INDEX IF NOT EXISTS idx_shopping_carts_user_active ON shopping_carts (user_id, status) WHERE status = 'active'; -- 用户活跃购物车
CREATE INDEX IF NOT EXISTS idx_shopping_carts_industry ON shopping_carts (industry_type);   -- 按行业查询购物车

-- cart_items 表索引
CREATE INDEX IF NOT EXISTS idx_cart_items_cart_id ON cart_items (cart_id);                  -- 按购物车查询商品
CREATE INDEX IF NOT EXISTS idx_cart_items_service_detail_id ON cart_items (service_detail_id); -- 按服务详情查询
CREATE INDEX IF NOT EXISTS idx_cart_items_added_at ON cart_items (added_at);                -- 按添加时间查询

-- =====================================================
-- 4. 订单系统索引
-- =====================================================

-- orders 表索引
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders (user_id);                          -- 按用户查询订单
CREATE INDEX IF NOT EXISTS idx_orders_provider_id ON orders (provider_id);                  -- 按服务商查询订单
CREATE INDEX IF NOT EXISTS idx_orders_service_id ON orders (service_id);                    -- 按服务查询订单
CREATE INDEX IF NOT EXISTS idx_orders_industry_type ON orders (industry_type);              -- 按行业查询订单
CREATE INDEX IF NOT EXISTS idx_orders_order_type ON orders (order_type);                    -- 按订单类型查询
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders (status);                            -- 按订单状态查询
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON orders (payment_status);            -- 按支付状态查询
CREATE INDEX IF NOT EXISTS idx_orders_fulfillment_status ON orders (fulfillment_status);    -- 按履约状态查询
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders (created_at);                    -- 按创建时间查询
CREATE INDEX IF NOT EXISTS idx_orders_scheduled_time ON orders (scheduled_time);            -- 按预约时间查询
CREATE INDEX IF NOT EXISTS idx_orders_cart_id ON orders (cart_id);                          -- 按购物车查询订单
CREATE INDEX IF NOT EXISTS idx_orders_order_number ON orders (order_number);                -- 按订单号查询
CREATE INDEX IF NOT EXISTS idx_orders_location ON orders (service_latitude, service_longitude); -- 按服务位置查询
CREATE INDEX IF NOT EXISTS idx_orders_user_status ON orders (user_id, status);              -- 用户订单状态组合查询
CREATE INDEX IF NOT EXISTS idx_orders_provider_status ON orders (provider_id, status);      -- 服务商订单状态组合查询
CREATE INDEX IF NOT EXISTS idx_orders_recent ON orders (created_at DESC, status);           -- 最近订单查询
CREATE INDEX IF NOT EXISTS idx_orders_pending ON orders (status, created_at) WHERE status = 'pending'; -- 待处理订单

-- order_items 表索引
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items (order_id);              -- 按订单查询商品
CREATE INDEX IF NOT EXISTS idx_order_items_service_detail_id ON order_items (service_detail_id); -- 按服务详情查询
CREATE INDEX IF NOT EXISTS idx_order_items_cart_item_id ON order_items (cart_item_id);      -- 按购物车商品查询
CREATE INDEX IF NOT EXISTS idx_order_items_status ON order_items (status);                  -- 按商品状态查询

-- =====================================================
-- 5. 通知系统索引
-- =====================================================

-- notifications 表索引
CREATE INDEX IF NOT EXISTS idx_notifications_recipient_id ON notifications (recipient_id);   -- 按接收者查询通知
CREATE INDEX IF NOT EXISTS idx_notifications_sender_id ON notifications (sender_id);        -- 按发送者查询通知
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications (notification_type);     -- 按通知类型查询
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications (is_read);               -- 按阅读状态查询
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications (created_at);      -- 按创建时间查询
CREATE INDEX IF NOT EXISTS idx_notifications_priority ON notifications (priority);          -- 按优先级查询
CREATE INDEX IF NOT EXISTS idx_notifications_expires_at ON notifications (expires_at);      -- 按过期时间查询
CREATE INDEX IF NOT EXISTS idx_notifications_related ON notifications (related_id, related_type); -- 按关联对象查询
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications (recipient_id, is_read, created_at) WHERE is_read = false; -- 未读通知
CREATE INDEX IF NOT EXISTS idx_notifications_recent ON notifications (recipient_id, created_at DESC); -- 最近通知

-- =====================================================
-- 6. 文件存储系统索引
-- =====================================================

-- file_uploads 表索引
CREATE INDEX IF NOT EXISTS idx_file_uploads_uploader_id ON file_uploads (uploader_id);       -- 按上传者查询文件
CREATE INDEX IF NOT EXISTS idx_file_uploads_category ON file_uploads (category);            -- 按文件分类查询
CREATE INDEX IF NOT EXISTS idx_file_uploads_subcategory ON file_uploads (subcategory);      -- 按子分类查询
CREATE INDEX IF NOT EXISTS idx_file_uploads_related ON file_uploads (related_id, related_type); -- 按关联对象查询
CREATE INDEX IF NOT EXISTS idx_file_uploads_visibility ON file_uploads (visibility);        -- 按可见性查询
CREATE INDEX IF NOT EXISTS idx_file_uploads_processing_status ON file_uploads (processing_status); -- 按处理状态查询
CREATE INDEX IF NOT EXISTS idx_file_uploads_created_at ON file_uploads (created_at);         -- 按创建时间查询
CREATE INDEX IF NOT EXISTS idx_file_uploads_expires_at ON file_uploads (expires_at);         -- 按过期时间查询（临时文件清理）
CREATE INDEX IF NOT EXISTS idx_file_uploads_type ON file_uploads (file_type);               -- 按文件类型查询
CREATE INDEX IF NOT EXISTS idx_file_uploads_size ON file_uploads (file_size);               -- 按文件大小查询

-- =====================================================
-- 7. 系统配置索引
-- =====================================================

-- system_configs 表索引
CREATE INDEX IF NOT EXISTS idx_system_configs_key ON system_configs (config_key);           -- 按配置键查询
CREATE INDEX IF NOT EXISTS idx_system_configs_category ON system_configs (category);        -- 按配置分类查询
CREATE INDEX IF NOT EXISTS idx_system_configs_type ON system_configs (config_type);         -- 按配置类型查询
CREATE INDEX IF NOT EXISTS idx_system_configs_environment ON system_configs (environment);  -- 按环境查询
CREATE INDEX IF NOT EXISTS idx_system_configs_public ON system_configs (is_public);         -- 按公开状态查询
CREATE INDEX IF NOT EXISTS idx_system_configs_active ON system_configs (is_active);         -- 按激活状态查询

-- feature_flags 表索引
CREATE INDEX IF NOT EXISTS idx_feature_flags_key ON feature_flags (flag_key);               -- 按功能键查询
CREATE INDEX IF NOT EXISTS idx_feature_flags_enabled ON feature_flags (is_enabled);         -- 按启用状态查询
CREATE INDEX IF NOT EXISTS idx_feature_flags_rollout ON feature_flags (rollout_percentage); -- 按发布比例查询
CREATE INDEX IF NOT EXISTS idx_feature_flags_industry ON feature_flags USING GIN (industry_types); -- 按适用行业查询
CREATE INDEX IF NOT EXISTS idx_feature_flags_user_types ON feature_flags USING GIN (user_types); -- 按用户类型查询
CREATE INDEX IF NOT EXISTS idx_feature_flags_time_range ON feature_flags (starts_at, ends_at); -- 按时间范围查询

-- =====================================================
-- 8. 审计日志索引
-- =====================================================

-- audit_logs 表索引
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs (user_id);                  -- 按用户查询审计日志
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs (action);                    -- 按操作类型查询
CREATE INDEX IF NOT EXISTS idx_audit_logs_table_name ON audit_logs (table_name);            -- 按表名查询
CREATE INDEX IF NOT EXISTS idx_audit_logs_record_id ON audit_logs (record_id);              -- 按记录ID查询
CREATE INDEX IF NOT EXISTS idx_audit_logs_table_record ON audit_logs (table_name, record_id); -- 按表和记录查询
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs (created_at);             -- 按创建时间查询
CREATE INDEX IF NOT EXISTS idx_audit_logs_severity ON audit_logs (severity);                -- 按严重程度查询
CREATE INDEX IF NOT EXISTS idx_audit_logs_ip_address ON audit_logs (ip_address);            -- 按IP地址查询
CREATE INDEX IF NOT EXISTS idx_audit_logs_session_id ON audit_logs (session_id);            -- 按会话ID查询
CREATE INDEX IF NOT EXISTS idx_audit_logs_request_id ON audit_logs (request_id);            -- 按请求ID查询

-- error_logs 表索引
CREATE INDEX IF NOT EXISTS idx_error_logs_error_type ON error_logs (error_type);            -- 按错误类型查询
CREATE INDEX IF NOT EXISTS idx_error_logs_error_code ON error_logs (error_code);            -- 按错误代码查询
CREATE INDEX IF NOT EXISTS idx_error_logs_user_id ON error_logs (user_id);                  -- 按用户查询错误
CREATE INDEX IF NOT EXISTS idx_error_logs_created_at ON error_logs (created_at);            -- 按创建时间查询
CREATE INDEX IF NOT EXISTS idx_error_logs_severity ON error_logs (severity);                -- 按严重程度查询
CREATE INDEX IF NOT EXISTS idx_error_logs_resolved ON error_logs (is_resolved);             -- 按解决状态查询
CREATE INDEX IF NOT EXISTS idx_error_logs_environment ON error_logs (environment);          -- 按环境查询
CREATE INDEX IF NOT EXISTS idx_error_logs_service ON error_logs (service_name);             -- 按服务名查询

-- =====================================================
-- 9. 会话管理索引
-- =====================================================

-- user_sessions 表索引
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions (user_id);            -- 按用户查询会话
CREATE INDEX IF NOT EXISTS idx_user_sessions_token ON user_sessions (session_token);        -- 按会话令牌查询
CREATE INDEX IF NOT EXISTS idx_user_sessions_refresh_token ON user_sessions (refresh_token); -- 按刷新令牌查询
CREATE INDEX IF NOT EXISTS idx_user_sessions_device_id ON user_sessions (device_id);        -- 按设备ID查询
CREATE INDEX IF NOT EXISTS idx_user_sessions_active ON user_sessions (is_active);           -- 按活跃状态查询
CREATE INDEX IF NOT EXISTS idx_user_sessions_expires_at ON user_sessions (expires_at);      -- 按过期时间查询
CREATE INDEX IF NOT EXISTS idx_user_sessions_last_activity ON user_sessions (last_activity_at); -- 按最后活动时间查询
CREATE INDEX IF NOT EXISTS idx_user_sessions_device_type ON user_sessions (device_type);    -- 按设备类型查询
CREATE INDEX IF NOT EXISTS idx_user_sessions_ip_address ON user_sessions (ip_address);      -- 按IP地址查询
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_active ON user_sessions (user_id, is_active); -- 用户活跃会话

-- =====================================================
-- 10. 缓存系统索引
-- =====================================================

-- cache_entries 表索引
CREATE INDEX IF NOT EXISTS idx_cache_entries_namespace ON cache_entries (cache_namespace);  -- 按命名空间查询
CREATE INDEX IF NOT EXISTS idx_cache_entries_expires_at ON cache_entries (expires_at);      -- 按过期时间查询（清理）
CREATE INDEX IF NOT EXISTS idx_cache_entries_tags ON cache_entries USING GIN (tags);        -- 按标签查询（批量清理）
CREATE INDEX IF NOT EXISTS idx_cache_entries_access_count ON cache_entries (access_count);  -- 按访问次数查询
CREATE INDEX IF NOT EXISTS idx_cache_entries_last_accessed ON cache_entries (last_accessed_at); -- 按最后访问时间查询
CREATE INDEX IF NOT EXISTS idx_cache_entries_size ON cache_entries (size_bytes);            -- 按大小查询

-- =====================================================
-- 11. 服务商和服务系统索引
-- =====================================================

-- provider_profiles 表索引
CREATE INDEX IF NOT EXISTS idx_provider_profiles_user_id ON provider_profiles (user_id);    -- 按用户查询服务商档案
CREATE INDEX IF NOT EXISTS idx_provider_profiles_status ON provider_profiles (status);      -- 按状态查询
CREATE INDEX IF NOT EXISTS idx_provider_profiles_provider_type ON provider_profiles (provider_type); -- 按类型查询
CREATE INDEX IF NOT EXISTS idx_provider_profiles_certification_status ON provider_profiles (certification_status); -- 按认证状态查询
CREATE INDEX IF NOT EXISTS idx_provider_profiles_is_certified ON provider_profiles (is_certified); -- 按认证状态查询
CREATE INDEX IF NOT EXISTS idx_provider_profiles_is_active ON provider_profiles (is_active); -- 按激活状态查询
CREATE INDEX IF NOT EXISTS idx_provider_profiles_vacation_mode ON provider_profiles (vacation_mode); -- 按休假模式查询
CREATE INDEX IF NOT EXISTS idx_provider_profiles_rating ON provider_profiles (rating);      -- 按评分查询
CREATE INDEX IF NOT EXISTS idx_provider_profiles_review_count ON provider_profiles (review_count); -- 按评价数查询
CREATE INDEX IF NOT EXISTS idx_provider_profiles_experience ON provider_profiles (experience_years); -- 按经验年限查询
CREATE INDEX IF NOT EXISTS idx_provider_profiles_service_categories ON provider_profiles USING GIN (service_categories); -- 按服务分类查询
CREATE INDEX IF NOT EXISTS idx_provider_profiles_service_areas ON provider_profiles USING GIN (service_areas); -- 按服务区域查询
CREATE INDEX IF NOT EXISTS idx_provider_profiles_tags ON provider_profiles USING GIN (tags); -- 按标签查询
CREATE INDEX IF NOT EXISTS idx_provider_profiles_address_id ON provider_profiles (address_id); -- 按地址查询

-- services 表索引
CREATE INDEX IF NOT EXISTS idx_services_provider_id ON services (provider_id);              -- 按服务商查询服务
CREATE INDEX IF NOT EXISTS idx_services_category_level1_id ON services (category_level1_id); -- 按一级分类查询
CREATE INDEX IF NOT EXISTS idx_services_category_level2_id ON services (category_level2_id); -- 按二级分类查询
CREATE INDEX IF NOT EXISTS idx_services_status ON services (status);                        -- 按状态查询
CREATE INDEX IF NOT EXISTS idx_services_industry_type ON services (industry_type);          -- 按行业类型查询
CREATE INDEX IF NOT EXISTS idx_services_is_available ON services (is_available);            -- 按可用状态查询
CREATE INDEX IF NOT EXISTS idx_services_location ON services (latitude, longitude);         -- 按地理位置查询
CREATE INDEX IF NOT EXISTS idx_services_service_delivery_method ON services (service_delivery_method); -- 按交付方式查询
CREATE INDEX IF NOT EXISTS idx_services_pricing_model ON services (pricing_model);          -- 按定价模式查询
CREATE INDEX IF NOT EXISTS idx_services_base_price ON services (base_price);                -- 按基础价格查询
CREATE INDEX IF NOT EXISTS idx_services_rating ON services (average_rating);                -- 按评分查询
CREATE INDEX IF NOT EXISTS idx_services_review_count ON services (review_count);            -- 按评价数查询
CREATE INDEX IF NOT EXISTS idx_services_created_at ON services (created_at);                -- 按创建时间查询
CREATE INDEX IF NOT EXISTS idx_services_active_available ON services (status, is_available) WHERE status = 'active' AND is_available = true; -- 可用服务

-- service_details 表索引
CREATE INDEX IF NOT EXISTS idx_service_details_service_id ON service_details (service_id);  -- 按服务查询详情
CREATE INDEX IF NOT EXISTS idx_service_details_category ON service_details (category);      -- 按分类查询
CREATE INDEX IF NOT EXISTS idx_service_details_sub_category ON service_details (sub_category); -- 按子分类查询
CREATE INDEX IF NOT EXISTS idx_service_details_pricing_type ON service_details (pricing_type); -- 按定价类型查询
CREATE INDEX IF NOT EXISTS idx_service_details_is_available ON service_details (is_available); -- 按可用状态查询
CREATE INDEX IF NOT EXISTS idx_service_details_price ON service_details (price);            -- 按价格查询
CREATE INDEX IF NOT EXISTS idx_service_details_sort_order ON service_details (sort_order);  -- 按排序查询
CREATE INDEX IF NOT EXISTS idx_service_details_verification_status ON service_details (verification_status); -- 按验证状态查询
CREATE INDEX IF NOT EXISTS idx_service_details_view_count ON service_details (view_count);  -- 按浏览次数查询
CREATE INDEX IF NOT EXISTS idx_service_details_order_count ON service_details (order_count); -- 按订购次数查询
CREATE INDEX IF NOT EXISTS idx_service_details_favorite_count ON service_details (favorite_count); -- 按收藏次数查询
CREATE INDEX IF NOT EXISTS idx_service_details_promotion ON service_details (promotion_start, promotion_end); -- 按促销时间查询
CREATE INDEX IF NOT EXISTS idx_service_details_stock ON service_details (current_stock, max_stock); -- 按库存查询
CREATE INDEX IF NOT EXISTS idx_service_details_tags ON service_details USING GIN (tags);    -- 按标签查询
CREATE INDEX IF NOT EXISTS idx_service_details_service_area_codes ON service_details USING GIN (service_area_codes); -- 按服务区域查询
CREATE INDEX IF NOT EXISTS idx_service_details_name ON service_details USING GIN (name);    -- 按名称搜索
CREATE INDEX IF NOT EXISTS idx_service_details_attributes ON service_details USING GIN (attributes); -- 按属性查询

-- =====================================================
-- 12. 支付系统索引
-- =====================================================

-- payment_methods 表索引
CREATE INDEX IF NOT EXISTS idx_payment_methods_user_id ON payment_methods (user_id);        -- 按用户查询支付方式
CREATE INDEX IF NOT EXISTS idx_payment_methods_type ON payment_methods (type);              -- 按类型查询
CREATE INDEX IF NOT EXISTS idx_payment_methods_provider ON payment_methods (provider);      -- 按提供商查询
CREATE INDEX IF NOT EXISTS idx_payment_methods_is_default ON payment_methods (is_default);  -- 按默认状态查询
CREATE INDEX IF NOT EXISTS idx_payment_methods_is_active ON payment_methods (is_active);    -- 按激活状态查询
CREATE INDEX IF NOT EXISTS idx_payment_methods_external_id ON payment_methods (external_id); -- 按外部ID查询
CREATE INDEX IF NOT EXISTS idx_payment_methods_user_default ON payment_methods (user_id, is_default) WHERE is_default = true; -- 用户默认支付方式

-- payments 表索引
CREATE INDEX IF NOT EXISTS idx_payments_order_id ON payments (order_id);                    -- 按订单查询支付
CREATE INDEX IF NOT EXISTS idx_payments_payment_method_id ON payments (payment_method_id);  -- 按支付方式查询
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments (status);                        -- 按支付状态查询
CREATE INDEX IF NOT EXISTS idx_payments_provider ON payments (provider);                    -- 按支付提供商查询
CREATE INDEX IF NOT EXISTS idx_payments_external_transaction_id ON payments (external_transaction_id); -- 按外部交易ID查询
CREATE INDEX IF NOT EXISTS idx_payments_external_charge_id ON payments (external_charge_id); -- 按外部收费ID查询
CREATE INDEX IF NOT EXISTS idx_payments_amount ON payments (amount);                        -- 按金额查询
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON payments (created_at);                -- 按创建时间查询
CREATE INDEX IF NOT EXISTS idx_payments_authorized_at ON payments (authorized_at);          -- 按授权时间查询
CREATE INDEX IF NOT EXISTS idx_payments_captured_at ON payments (captured_at);              -- 按收款时间查询

-- =====================================================
-- 13. 评价和消息系统索引
-- =====================================================

-- reviews 表索引
CREATE INDEX IF NOT EXISTS idx_reviews_order_id ON reviews (order_id);                      -- 按订单查询评价
CREATE INDEX IF NOT EXISTS idx_reviews_reviewer_id ON reviews (reviewer_id);                -- 按评价者查询
CREATE INDEX IF NOT EXISTS idx_reviews_reviewee_id ON reviews (reviewee_id);                -- 按被评价者查询
CREATE INDEX IF NOT EXISTS idx_reviews_service_id ON reviews (service_id);                  -- 按服务查询评价
CREATE INDEX IF NOT EXISTS idx_reviews_overall_rating ON reviews (overall_rating);          -- 按总体评分查询
CREATE INDEX IF NOT EXISTS idx_reviews_status ON reviews (status);                          -- 按状态查询
CREATE INDEX IF NOT EXISTS idx_reviews_is_verified ON reviews (is_verified);                -- 按验证状态查询
CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON reviews (created_at);                  -- 按创建时间查询
CREATE INDEX IF NOT EXISTS idx_reviews_helpful_count ON reviews (helpful_count);            -- 按有用评价数查询

-- conversations 表索引
CREATE INDEX IF NOT EXISTS idx_conversations_customer_id ON conversations (customer_id);    -- 按客户查询对话
CREATE INDEX IF NOT EXISTS idx_conversations_provider_id ON conversations (provider_id);    -- 按服务商查询对话
CREATE INDEX IF NOT EXISTS idx_conversations_order_id ON conversations (order_id);          -- 按订单查询对话
CREATE INDEX IF NOT EXISTS idx_conversations_status ON conversations (status);              -- 按状态查询对话
CREATE INDEX IF NOT EXISTS idx_conversations_last_message_at ON conversations (last_message_at); -- 按最后消息时间查询

-- messages 表索引
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON messages (conversation_id);      -- 按对话查询消息
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages (sender_id);                  -- 按发送者查询消息
CREATE INDEX IF NOT EXISTS idx_messages_message_type ON messages (message_type);            -- 按消息类型查询
CREATE INDEX IF NOT EXISTS idx_messages_is_read ON messages (is_read);                      -- 按阅读状态查询
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages (created_at);                -- 按创建时间查询
CREATE INDEX IF NOT EXISTS idx_messages_unread ON messages (conversation_id, is_read) WHERE is_read = false; -- 未读消息

-- =====================================================
-- 14. 约束说明
-- =====================================================

/*
重要约束说明：

1. 唯一约束 (UNIQUE Constraints):
   - ref_codes: (type_code, code) - 同一类型下代码唯一
   - shopping_carts: (user_id, service_id, status) - 每个用户对同一服务商只能有一个活跃购物车
   - orders: (order_number) - 订单号全局唯一
   - service_details: (service_id, category, name) - 同一服务下的同一分类中名称唯一
   - system_configs: (config_key) - 配置键唯一
   - feature_flags: (flag_key) - 功能标识唯一
   - reviews: (order_id, reviewer_id) - 每个订单每个用户只能评价一次
   - user_sessions: (session_token), (refresh_token) - 会话令牌唯一

2. 检查约束 (CHECK Constraints):
   - 价格相关字段: 确保价格不为负数
   - 评分字段: 确保评分在1-5范围内
   - 枚举字段: 确保值在预定义的枚举范围内
   - 百分比字段: 确保在0-100范围内
   - 数量字段: 确保大于0

3. 外键约束 (FOREIGN KEY Constraints):
   - 级联删除: user_id相关的表在用户删除时自动删除相关记录
   - 置空删除: 某些引用在被引用对象删除时置为NULL
   - 保护删除: 重要引用防止误删除

4. 部分索引 (Partial Indexes):
   - 只为常用查询条件创建索引，节省存储空间
   - 如：只为活跃状态、未读状态等创建索引

5. 复合索引 (Composite Indexes):
   - 为常见的多字段查询创建复合索引
   - 字段顺序根据查询频率和选择性优化

6. GIN索引:
   - 为JSONB字段和数组字段创建GIN索引
   - 支持复杂的包含查询和全文搜索
*/

-- =====================================================
-- 15. 触发器说明
-- =====================================================

/*
自动触发器功能：

1. updated_at自动更新:
   - 所有包含updated_at字段的表
   - 在UPDATE操作时自动更新为当前时间

2. 购物车总计自动计算:
   - cart_items变更时自动更新shopping_carts的总计字段
   - 包括：total_items, subtotal, total_amount

3. 通知未读计数:
   - conversations表的未读消息计数自动维护
   - messages插入/更新时自动更新对话的未读计数

4. 评分自动计算:
   - reviews变更时自动更新services和provider_profiles的平均评分
   - 包括：average_rating, review_count

5. 库存自动更新:
   - order_items创建时自动减少service_details的current_stock
   - 订单取消时自动恢复库存

6. 缓存自动清理:
   - 定期清理过期的cache_entries
   - 清理过期的临时文件

7. 会话自动清理:
   - 清理过期的用户会话
   - 更新最后活动时间

8. 审计日志自动记录:
   - 重要表的增删改操作自动记录到audit_logs
   - 包括变更前后的值对比
*/
