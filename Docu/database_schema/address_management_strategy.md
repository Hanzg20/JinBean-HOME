# 地址管理策略与实现方案

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

**总结**：本方案采用按需动态插入策略，既保证了数据标准化和一致性，又避免了全量导入的存储和维护成本。通过 AddressService 统一管理地址逻辑，提供了良好的用户体验和扩展性。 