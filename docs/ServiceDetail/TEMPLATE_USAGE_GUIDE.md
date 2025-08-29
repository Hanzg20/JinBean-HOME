# 通用数据插入模板使用指南

## 📋 模板概述

`data_insertion_template.sql` 是一个通用的数据插入模板，可以用于任何分类的Provider、Services和Service Details数据插入。

## 🔧 使用方法

### 第一步：准备数据

1. **确定分类信息**：
   - 分类中文名称
   - 分类英文名称
   - 一级分类ID
   - 二级分类列表

2. **准备提供商数据**：
   - 提供商名称（中英文）
   - 提供商简介（中英文）
   - 联系方式
   - 评分和评价数
   - 专业技能标签

3. **准备服务数据**：
   - 服务名称（中英文）
   - 服务描述（中英文）
   - 服务交付方式
   - 评分和评价数

### 第二步：替换模板变量

#### 需要替换的变量：

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `{CATEGORY_NAME_ZH}` | 分类中文名称 | "美食天地" |
| `{CATEGORY_NAME_EN}` | 分类英文名称 | "Food World" |
| `{PROVIDER_COUNT}` | 提供商数量 | 10 |
| `{SERVICE_COUNT_PER_CATEGORY}` | 每个二级分类的服务数量 | 2 |
| `{PROVIDER_DATA}` | 提供商数据块 | 见下方示例 |
| `{SERVICE_DATA}` | 服务数据块 | 见下方示例 |

#### 动态变量（根据分类数量自动生成）：

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `{SUBCATEGORY_VARIABLES}` | 二级分类变量声明 | `subcategory1_id INTEGER; subcategory2_id INTEGER;` |
| `{SUBCATEGORY_ID_QUERIES}` | 二级分类ID查询 | `SELECT id INTO subcategory1_id FROM ref_codes WHERE...` |
| `{SUBCATEGORY_NAMES}` | 二级分类名称列表 | "社区美食、餐厅预订" |

## 📝 数据格式示例

### 提供商数据格式：

```sql
-- 提供商数据模板
(gen_random_uuid(), 
 '{"zh": "提供商名称", "en": "Provider Name"}',
 '{"zh": "提供商简介", "en": "Provider Description"}',
 'https://picsum.photos/id/300/200/200',
 '+1-416-555-0101', 'provider@example.com', 
 4.8, 156, 'active', 'individual', true,
 20, ARRAY['技能1', '技能2', '技能3'], 
 '{"specialties": ["技能1", "技能2"], "certifications": ["认证1"], "languages": ["中文", "英文"]}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
```

### 服务数据格式：

```sql
-- 服务数据模板
INSERT INTO services (id, provider_id, title, description, category_level1_id, category_level2_id, status, average_rating, review_count, service_delivery_method, created_at, updated_at) VALUES 
(gen_random_uuid(), (SELECT id FROM provider_profiles WHERE display_name->>'zh' = '提供商名称'), '{"zh": "服务名称", "en": "Service Name"}', '{"zh": "服务描述", "en": "Service Description"}', category_level1_id, subcategory1_id, 'active', 4.8, 156, 'delivery', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
```

## 🚀 快速生成脚本

### 使用Python脚本自动生成：

```python
def generate_data_script(category_info, provider_data, service_data):
    """
    自动生成数据插入脚本
    
    Args:
        category_info: 分类信息字典
        provider_data: 提供商数据列表
        service_data: 服务数据列表
    """
    
    # 读取模板
    with open('data_insertion_template.sql', 'r', encoding='utf-8') as f:
        template = f.read()
    
    # 替换变量
    script = template.replace('{CATEGORY_NAME_ZH}', category_info['name_zh'])
    script = script.replace('{CATEGORY_NAME_EN}', category_info['name_en'])
    script = script.replace('{PROVIDER_COUNT}', str(len(provider_data)))
    script = script.replace('{PROVIDER_DATA}', format_provider_data(provider_data))
    script = script.replace('{SERVICE_DATA}', format_service_data(service_data))
    
    # 生成动态变量
    script = generate_dynamic_variables(script, category_info['subcategories'])
    
    return script
```

## 📊 分类示例

### 示例1：家政服务

```sql
-- 分类信息
CATEGORY_NAME_ZH = "家政服务"
CATEGORY_NAME_EN = "Home Services"
SUBCATEGORIES = ["清洁服务", "维修服务", "搬家服务", "其他"]

-- 提供商示例
(gen_random_uuid(), 
 '{"zh": "专业清洁公司", "en": "Professional Cleaning Company"}',
 '{"zh": "专业家庭清洁服务，10年经验", "en": "Professional home cleaning service, 10 years experience"}',
 'https://picsum.photos/id/400/200/200',
 '+1-416-555-0201', 'cleaning@example.com', 
 4.9, 234, 'active', 'corporate', true,
 10, ARRAY['清洁', '消毒', '整理'], 
 '{"specialties": ["清洁", "消毒"], "certifications": ["清洁认证"], "languages": ["中文", "英文"]}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
```

### 示例2：教育培训

```sql
-- 分类信息
CATEGORY_NAME_ZH = "教育培训"
CATEGORY_NAME_EN = "Education & Training"
SUBCATEGORIES = ["语言培训", "技能培训", "学术辅导", "其他"]

-- 提供商示例
(gen_random_uuid(), 
 '{"zh": "英语培训中心", "en": "English Training Center"}',
 '{"zh": "专业英语培训，雅思托福专家", "en": "Professional English training, IELTS TOEFL expert"}',
 'https://picsum.photos/id/500/200/200',
 '+1-416-555-0301', 'english@example.com', 
 4.7, 189, 'active', 'corporate', true,
 15, ARRAY['英语', '雅思', '托福'], 
 '{"specialties": ["英语", "雅思"], "certifications": ["教师资格"], "languages": ["中文", "英文"]}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
```

## ✅ 验证步骤

执行生成的脚本后，运行以下验证查询：

```sql
-- 1. 检查数据完整性
SELECT 
    'Provider数量' as "类型",
    COUNT(*) as "数量"
FROM provider_profiles 
WHERE id IN (SELECT DISTINCT provider_id FROM services WHERE category_level1_id = (SELECT id FROM ref_codes WHERE name->>'zh' = '分类名称'))

UNION ALL

SELECT 
    'Services数量' as "类型",
    COUNT(*) as "数量"
FROM services 
WHERE category_level1_id = (SELECT id FROM ref_codes WHERE name->>'zh' = '分类名称')

UNION ALL

SELECT 
    'Service Details数量' as "类型",
    COUNT(*) as "数量"
FROM service_details 
WHERE service_id IN (SELECT id FROM services WHERE category_level1_id = (SELECT id FROM ref_codes WHERE name->>'zh' = '分类名称'));

-- 2. 检查分类分布
SELECT 
    rc2.name->>'zh' as "二级分类",
    COUNT(s.id) as "服务数量"
FROM ref_codes rc1
JOIN ref_codes rc2 ON rc1.id = rc2.parent_id
LEFT JOIN services s ON rc2.id = s.category_level2_id
WHERE rc1.name->>'zh' = '分类名称'
GROUP BY rc2.id, rc2.name->>'zh'
ORDER BY rc2.sort_order;
```

## 🎯 最佳实践

1. **数据质量**：确保所有数据都是真实、合理的
2. **命名规范**：使用一致的命名规范
3. **图片URL**：使用不同的图片ID避免重复
4. **联系方式**：使用不同的电话号码和邮箱
5. **评分分布**：使用合理的评分分布（4.0-5.0）
6. **标签系统**：使用相关的技能标签
7. **验证测试**：执行后运行验证查询

## 📁 文件组织

建议按以下方式组织文件：

```
docs/ServiceDetail/
├── data_insertion_template.sql          # 通用模板
├── TEMPLATE_USAGE_GUIDE.md             # 使用指南
├── examples/
│   ├── food_services_data.sql          # 美食服务示例
│   ├── home_services_data.sql          # 家政服务示例
│   └── education_services_data.sql     # 教育培训示例
└── generated/
    ├── category1_data.sql              # 生成的脚本
    └── category2_data.sql
```

使用这个模板，您可以快速为任何分类生成标准化的测试数据！
