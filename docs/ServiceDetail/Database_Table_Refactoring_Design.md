# Service_Details数据库表重构设计方案

## 📋 **重构概述**

### 🎯 **重构目标**
将单一服务详情表重构为支持子服务的灵活架构，实现一个主服务下包含多个子服务项目的功能。

### 🏗️ **设计原则**
- **向后兼容**: 保留现有数据和业务逻辑
- **渐进迁移**: 分阶段实施，降低风险
- **功能扩展**: 支持复杂的多子服务场景
- **性能优化**: 优化查询和索引结构

---

## 🗃️ **现有表结构分析**

### **原有service_details表**

```sql
CREATE TABLE public.service_details (
    service_id uuid PRIMARY KEY REFERENCES public.services(id),
    pricing_type text NOT NULL DEFAULT 'fixed_price',
    price numeric,
    currency text,
    negotiation_details text,
    duration_type text NOT NULL DEFAULT 'hours',
    duration interval,
    images_url text[] DEFAULT '{}',
    videos_url text[] DEFAULT '{}',
    tags text[] DEFAULT '{}',
    service_area_codes text[] DEFAULT '{}',
    platform_service_fee_rate numeric DEFAULT 0.05,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);
```

### **现有结构的限制**
- ❌ **单一服务**: 一个服务只能有一个详情记录
- ❌ **扩展性差**: 难以支持子服务或服务变体
- ❌ **业务约束**: 无法满足餐饮菜单、租赁库存等复杂场景
- ❌ **灵活性低**: 字段固定，难以适应不同行业需求

---

## 🏗️ **重构架构设计**

### **1. 新表结构设计**

```sql
-- 重构后的service_details表
CREATE TABLE public.service_details (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id uuid NOT NULL REFERENCES public.services(id),
    category text NOT NULL DEFAULT 'main',
    name jsonb NOT NULL,
    description text,
    pricing_type text NOT NULL DEFAULT 'fixed_price',
    price numeric,
    currency text DEFAULT 'CAD',
    negotiation_details text,
    duration_type text NOT NULL DEFAULT 'hours',
    duration interval,
    images_url text[] DEFAULT '{}',
    videos_url text[] DEFAULT '{}',
    tags text[] DEFAULT '{}',
    service_area_codes text[] DEFAULT '{}',
    platform_service_fee_rate numeric DEFAULT 0.05,
    
    -- 新增字段：支持子服务功能
    sub_category text,
    is_available boolean DEFAULT true,
    sort_order integer DEFAULT 0,
    current_stock integer,
    max_stock integer,
    
    -- 扩展属性字段
    attributes jsonb DEFAULT '{}',
    business_rules jsonb DEFAULT '{}',
    
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    
    -- 复合索引
    UNIQUE(service_id, category, name)
);
```

### **2. 核心字段说明**

| 字段名 | 类型 | 说明 | 示例 |
|--------|------|------|------|
| `id` | uuid | 主键，唯一标识 | `auto-generated` |
| `service_id` | uuid | 关联的主服务ID | `existing service id` |
| `category` | text | 服务类别 | `main`, `menu_item`, `rental_item` |
| `name` | jsonb | 多语言名称 | `{"en": "Pasta", "zh": "意大利面"}` |
| `sub_category` | text | 子分类 | `appetizer`, `main_course`, `dessert` |
| `is_available` | boolean | 是否可用 | `true/false` |
| `sort_order` | integer | 排序顺序 | `1, 2, 3...` |
| `current_stock` | integer | 当前库存 | `50` |
| `max_stock` | integer | 最大库存 | `100` |
| `attributes` | jsonb | 扩展属性 | `{"spicy": true, "vegetarian": false}` |
| `business_rules` | jsonb | 业务规则 | `{"min_order": 2, "advance_booking": 24}` |

---

## 🎯 **应用场景设计**

### **1. 餐饮行业 - 菜单系统**

```sql
-- 主服务记录
INSERT INTO service_details (service_id, category, name, description) VALUES
('main-service-id', 'main', '{"en": "Italian Restaurant", "zh": "意大利餐厅"}', 'Authentic Italian cuisine');

-- 菜单项目
INSERT INTO service_details (service_id, category, sub_category, name, price, attributes) VALUES
('main-service-id', 'menu_item', 'appetizer', '{"en": "Caesar Salad", "zh": "凯撒沙拉"}', 12.99, '{"vegetarian": true, "calories": 350}'),
('main-service-id', 'menu_item', 'main_course', '{"en": "Spaghetti Carbonara", "zh": "奶油培根意面"}', 18.99, '{"spicy": false, "contains_dairy": true}'),
('main-service-id', 'menu_item', 'dessert', '{"en": "Tiramisu", "zh": "提拉米苏"}', 8.99, '{"contains_alcohol": true, "gluten_free": false}');
```

### **2. 共享租赁 - 库存系统**

```sql
-- 主服务记录
INSERT INTO service_details (service_id, category, name, description) VALUES
('rental-service-id', 'main', '{"en": "Power Tools Rental", "zh": "电动工具租赁"}', 'Professional power tools for rent');

-- 租赁物品
INSERT INTO service_details (service_id, category, sub_category, name, price, current_stock, max_stock, business_rules) VALUES
('rental-service-id', 'rental_item', 'drill', '{"en": "Electric Drill", "zh": "电钻"}', 25.00, 5, 10, '{"rental_unit": "day", "min_rental": 1, "deposit": 50}'),
('rental-service-id', 'rental_item', 'saw', '{"en": "Circular Saw", "zh": "圆锯"}', 35.00, 3, 8, '{"rental_unit": "day", "min_rental": 1, "deposit": 100}'),
('rental-service-id', 'rental_item', 'sander', '{"en": "Orbital Sander", "zh": "砂光机"}', 20.00, 7, 12, '{"rental_unit": "day", "min_rental": 1, "deposit": 30}');
```

### **3. 教育培训 - 课程系统**

```sql
-- 主服务记录
INSERT INTO service_details (service_id, category, name, description) VALUES
('education-service-id', 'main', '{"en": "Programming Bootcamp", "zh": "编程训练营"}', 'Comprehensive programming training');

-- 课程模块
INSERT INTO service_details (service_id, category, sub_category, name, price, duration, attributes) VALUES
('education-service-id', 'course_module', 'beginner', '{"en": "HTML/CSS Basics", "zh": "HTML/CSS基础"}', 299.00, '20 hours', '{"difficulty": "beginner", "certificate": true}'),
('education-service-id', 'course_module', 'intermediate', '{"en": "JavaScript Fundamentals", "zh": "JavaScript基础"}', 399.00, '30 hours', '{"difficulty": "intermediate", "prerequisites": ["HTML/CSS"]}'),
('education-service-id', 'course_module', 'advanced', '{"en": "React.js Advanced", "zh": "React.js高级"}', 499.00, '40 hours', '{"difficulty": "advanced", "project_based": true}');
```

---

## 🔄 **数据迁移策略**

### **1. 迁移步骤**

```sql
-- 第一步：备份现有数据
CREATE TABLE service_details_backup AS 
SELECT * FROM service_details;

-- 第二步：添加新字段（渐进式）
ALTER TABLE service_details 
ADD COLUMN id uuid DEFAULT gen_random_uuid(),
ADD COLUMN category text DEFAULT 'main',
ADD COLUMN name jsonb,
ADD COLUMN sub_category text,
ADD COLUMN is_available boolean DEFAULT true,
ADD COLUMN sort_order integer DEFAULT 0,
ADD COLUMN current_stock integer,
ADD COLUMN max_stock integer,
ADD COLUMN attributes jsonb DEFAULT '{}',
ADD COLUMN business_rules jsonb DEFAULT '{}';

-- 第三步：迁移现有数据
UPDATE service_details SET
    category = 'main',
    name = jsonb_build_object('en', 'Service Detail', 'zh', '服务详情'),
    is_available = true,
    sort_order = 0;

-- 第四步：调整主键和约束
ALTER TABLE service_details 
DROP CONSTRAINT service_details_pkey,
ADD CONSTRAINT service_details_pkey PRIMARY KEY (id),
ADD CONSTRAINT unique_service_category_name UNIQUE(service_id, category, name);
```

### **2. 向后兼容视图**

```sql
-- 创建兼容视图，保持现有API不变
CREATE VIEW service_details_legacy AS
SELECT 
    service_id,
    pricing_type,
    price,
    currency,
    negotiation_details,
    duration_type,
    duration,
    images_url,
    videos_url,
    tags,
    service_area_codes,
    platform_service_fee_rate,
    created_at,
    updated_at
FROM service_details 
WHERE category = 'main';
```

### **3. 数据验证**

```sql
-- 验证迁移结果
SELECT 
    COUNT(*) as total_records,
    COUNT(CASE WHEN category = 'main' THEN 1 END) as main_services,
    COUNT(CASE WHEN category != 'main' THEN 1 END) as sub_services
FROM service_details;
```

---

## 📊 **索引优化策略**

### **1. 核心索引**

```sql
-- 主键索引（自动创建）
-- PRIMARY KEY (id)

-- 服务查询索引
CREATE INDEX idx_service_details_service_id ON service_details(service_id);

-- 分类查询索引
CREATE INDEX idx_service_details_category ON service_details(category);

-- 复合查询索引
CREATE INDEX idx_service_details_service_category ON service_details(service_id, category);

-- 可用性和排序索引
CREATE INDEX idx_service_details_available_sort ON service_details(service_id, is_available, sort_order);

-- 库存查询索引
CREATE INDEX idx_service_details_stock ON service_details(current_stock) WHERE current_stock IS NOT NULL;
```

### **2. JSON字段索引**

```sql
-- 名称搜索索引
CREATE INDEX idx_service_details_name_gin ON service_details USING gin(name);

-- 属性搜索索引
CREATE INDEX idx_service_details_attributes_gin ON service_details USING gin(attributes);

-- 业务规则索引
CREATE INDEX idx_service_details_rules_gin ON service_details USING gin(business_rules);
```

---

## 🔍 **查询优化示例**

### **1. 获取主服务信息**

```sql
-- 优化前
SELECT * FROM service_details WHERE service_id = $1;

-- 优化后
SELECT * FROM service_details 
WHERE service_id = $1 AND category = 'main';
```

### **2. 获取餐厅菜单**

```sql
SELECT 
    name,
    sub_category,
    price,
    attributes->>'vegetarian' as is_vegetarian,
    attributes->>'spicy' as is_spicy
FROM service_details 
WHERE service_id = $1 
  AND category = 'menu_item' 
  AND is_available = true
ORDER BY sub_category, sort_order;
```

### **3. 检查租赁库存**

```sql
SELECT 
    name,
    current_stock,
    max_stock,
    CASE 
        WHEN current_stock > 0 THEN 'available'
        ELSE 'out_of_stock'
    END as availability_status
FROM service_details 
WHERE service_id = $1 
  AND category = 'rental_item'
  AND is_available = true;
```

---

## 🚀 **实施计划**

### **阶段一：基础重构（2周）**
- ✅ 新增字段和索引
- ✅ 数据迁移脚本
- ✅ 向后兼容视图
- ✅ 基础测试

### **阶段二：业务适配（3周）**
- 🔄 API接口调整
- 🔄 前端页面适配
- 🔄 业务逻辑重构
- 🔄 集成测试

### **阶段三：行业扩展（4周）**
- 📅 餐饮菜单功能
- 📅 租赁库存功能
- 📅 教育课程功能
- 📅 性能优化

### **阶段四：生产部署（1周）**
- 📅 生产环境迁移
- 📅 监控和告警
- 📅 性能调优
- 📅 文档更新

---

## ⚠️ **风险控制**

### **技术风险**
- **数据丢失**: 完整的备份和回滚策略
- **性能下降**: 索引优化和查询监控
- **兼容性问题**: 向后兼容视图和渐进迁移

### **业务风险**
- **服务中断**: 分阶段部署，最小化影响
- **数据不一致**: 严格的数据验证和测试
- **用户体验**: 保持现有功能不变

### **缓解措施**
- 📋 **详细测试计划**: 单元测试、集成测试、性能测试
- 🔄 **灰度发布**: 小范围试点，逐步推广
- 📊 **监控告警**: 实时监控系统状态和性能指标
- 🛠️ **快速回滚**: 自动化回滚机制和应急预案

---

## 📈 **预期收益**

### **功能扩展**
- ✅ **多子服务**: 支持复杂的业务场景
- ✅ **行业适配**: 餐饮、租赁、教育等专业化功能
- ✅ **库存管理**: 实时库存跟踪和管理
- ✅ **灵活配置**: JSON字段支持动态属性

### **性能提升**
- ✅ **查询优化**: 专用索引提升查询效率
- ✅ **存储优化**: 结构化数据减少冗余
- ✅ **缓存友好**: 分层数据便于缓存策略

### **开发效率**
- ✅ **代码复用**: 统一的数据模型和API
- ✅ **维护性**: 清晰的数据结构和业务逻辑
- ✅ **扩展性**: 易于添加新的业务场景

---

## 🔮 **未来规划**

### **技术演进**
- **微服务拆分**: 按业务域拆分为独立服务
- **缓存策略**: Redis集群化缓存方案
- **搜索优化**: Elasticsearch全文搜索集成
- **实时同步**: 事件驱动的数据同步机制

### **业务扩展**
- **AI推荐**: 基于用户行为的智能推荐
- **动态定价**: 根据供需关系的动态价格调整
- **预测分析**: 库存需求预测和自动补货
- **多租户**: 支持多商户的SaaS化部署

通过这次重构，service_details表将从单一功能的服务详情存储，升级为支持多样化业务场景的灵活数据架构，为平台的长期发展奠定坚实基础。 