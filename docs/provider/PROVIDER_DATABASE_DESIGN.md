# Provider Database Design Document

> This document describes the comprehensive database design for the JinBean Provider platform, including schema design, table structures, relationships, security policies, and optimization strategies.

## Table of Contents
1. [Database Overview](#1-database-overview)
2. [Schema Design](#2-schema-design)
3. [Table Structures](#3-table-structures)
4. [Relationships & Constraints](#4-relationships--constraints)
5. [Security Policies](#5-security-policies)
6. [Performance Optimization](#6-performance-optimization)
7. [Data Migration](#7-data-migration)
8. [Backup & Recovery](#8-backup--recovery)

---

## 1. Database Overview

### 1.1 Technology Stack
- **Database**: PostgreSQL 15+
- **Platform**: Supabase
- **ORM**: Supabase Client (Flutter)
- **Authentication**: Supabase Auth
- **Storage**: Supabase Storage
- **Real-time**: Supabase Realtime

### 1.2 Design Principles
- **Unified Public Schema**: All tables in public schema for simplicity
- **Role-based Access**: Provider-specific data isolation
- **Row Level Security**: Fine-grained access control
- **Performance First**: Optimized for high-performance queries
- **Scalability**: Designed for growth and expansion

### 1.3 Naming Conventions
- **Tables**: `provider_*`, `customer_*`, `orders_*`, `system_*`
- **Columns**: `snake_case`
- **Indexes**: `idx_<table>_<column>`
- **Constraints**: `fk_<table>_<column>`, `uk_<table>_<column>`

---

## 2. Schema Design

### 2.1 Database Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    JinBean Database                         │
├─────────────────────────────────────────────────────────────┤
│  Public Schema                                              │
│  ├── User Management                                        │
│  │   ├── users                                              │
│  │   ├── user_profiles                                      │
│  │   └── user_settings                                      │
│  ├── Provider Management                                    │
│  │   ├── provider_profiles                                  │
│  │   ├── provider_services                                  │
│  │   └── provider_schedules                                 │
│  ├── Customer Management                                    │
│  │   ├── customer_profiles                                  │
│  │   ├── customer_preferences                               │
│  │   └── customer_reviews                                   │
│  ├── Business Logic                                         │
│  │   ├── orders                                             │
│  │   ├── order_items                                        │
│  │   ├── payments                                           │
│  │   └── messages                                           │
│  ├── System Management                                      │
│  │   ├── ref_codes                                          │
│  │   ├── system_config                                      │
│  │   └── notifications                                      │
│  └── Audit & Analytics                                      │
│      ├── audit_logs                                         │
│      └── analytics_events                                   │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Schema Separation Strategy

#### 2.2.1 Current Approach: Unified Public Schema
- **Advantages**: Simple, easy to manage, good for MVP
- **Disadvantages**: Less isolation, potential naming conflicts
- **Implementation**: All tables in public schema with prefix naming

#### 2.2.2 Future Approach: Schema Separation
```sql
-- Provider-specific schema
CREATE SCHEMA provider;
CREATE SCHEMA customer;
CREATE SCHEMA shared;
CREATE SCHEMA audit;
```

---

## 3. Table Structures

### 3.1 User Management Tables

#### 3.1.1 users (Supabase Auth)
```sql
-- Managed by Supabase Auth
-- Extends auth.users with additional fields
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    phone TEXT,
    avatar_url TEXT,
    user_type TEXT NOT NULL DEFAULT 'customer' CHECK (user_type IN ('customer', 'provider', 'admin')),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'banned')),
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_user_type ON users(user_type);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_created_at ON users(created_at);
```

#### 3.1.2 user_profiles
```sql
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    display_name TEXT,
    bio TEXT,
    date_of_birth DATE,
    gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
    preferred_language TEXT DEFAULT 'en',
    timezone TEXT DEFAULT 'UTC',
    notification_preferences JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_user_profiles_display_name ON user_profiles(display_name);
CREATE INDEX idx_user_profiles_preferred_language ON user_profiles(preferred_language);
```

#### 3.1.3 user_settings
```sql
CREATE TABLE public.user_settings (
    id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    theme TEXT DEFAULT 'system' CHECK (theme IN ('light', 'dark', 'system')),
    language TEXT DEFAULT 'en',
    notification_enabled BOOLEAN DEFAULT TRUE,
    email_notification BOOLEAN DEFAULT TRUE,
    sms_notification BOOLEAN DEFAULT FALSE,
    push_notification BOOLEAN DEFAULT TRUE,
    privacy_settings JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_user_settings_theme ON user_settings(theme);
CREATE INDEX idx_user_settings_language ON user_settings(language);
```

### 3.2 Provider Management Tables

#### 3.2.1 provider_profiles
```sql
CREATE TABLE public.provider_profiles (
    id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    business_name TEXT NOT NULL,
    business_description TEXT,
    business_phone TEXT,
    business_email TEXT,
    business_address TEXT,
    business_website TEXT,
    service_areas TEXT[] DEFAULT '{}',
    service_categories TEXT[] DEFAULT '{}',
    certification_status TEXT DEFAULT 'pending' CHECK (certification_status IN ('pending', 'verified', 'rejected')),
    verification_documents TEXT[] DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    rating DECIMAL(3,2) DEFAULT 0.00,
    review_count INTEGER DEFAULT 0,
    total_orders INTEGER DEFAULT 0,
    total_earnings DECIMAL(10,2) DEFAULT 0.00,
    bank_account_info JSONB,
    tax_info JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_provider_profiles_business_name ON provider_profiles(business_name);
CREATE INDEX idx_provider_profiles_certification_status ON provider_profiles(certification_status);
CREATE INDEX idx_provider_profiles_is_active ON provider_profiles(is_active);
CREATE INDEX idx_provider_profiles_rating ON provider_profiles(rating);
CREATE INDEX idx_provider_profiles_service_areas ON provider_profiles USING GIN(service_areas);
CREATE INDEX idx_provider_profiles_service_categories ON provider_profiles USING GIN(service_categories);
```

#### 3.2.2 provider_services
```sql
CREATE TABLE public.provider_services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id UUID NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    category_level1_id TEXT,
    category_level2_id TEXT,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'draft', 'archived')),
    price DECIMAL(10,2) NOT NULL,
    pricing_type TEXT DEFAULT 'fixed' CHECK (pricing_type IN ('fixed', 'hourly', 'daily', 'negotiable')),
    currency TEXT DEFAULT 'USD',
    duration_minutes INTEGER,
    availability JSONB DEFAULT '{}',
    images TEXT[] DEFAULT '{}',
    tags TEXT[] DEFAULT '{}',
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    review_count INTEGER DEFAULT 0,
    order_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_provider_services_provider_id ON provider_services(provider_id);
CREATE INDEX idx_provider_services_status ON provider_services(status);
CREATE INDEX idx_provider_services_category ON provider_services(category_level1_id, category_level2_id);
CREATE INDEX idx_provider_services_price ON provider_services(price);
CREATE INDEX idx_provider_services_rating ON provider_services(average_rating);
CREATE INDEX idx_provider_services_tags ON provider_services USING GIN(tags);
```

#### 3.2.3 provider_schedules
```sql
CREATE TABLE public.provider_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id UUID NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    break_start_time TIME,
    break_end_time TIME,
    max_bookings_per_day INTEGER DEFAULT 10,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(provider_id, day_of_week)
);

-- Indexes
CREATE INDEX idx_provider_schedules_provider_id ON provider_schedules(provider_id);
CREATE INDEX idx_provider_schedules_day_of_week ON provider_schedules(day_of_week);
CREATE INDEX idx_provider_schedules_is_available ON provider_schedules(is_available);
```

### 3.3 Customer Management Tables

#### 3.3.1 customer_profiles
```sql
CREATE TABLE public.customer_profiles (
    id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    preferred_services TEXT[] DEFAULT '{}',
    preferred_providers UUID[] DEFAULT '{}',
    address_book JSONB DEFAULT '[]',
    payment_methods JSONB DEFAULT '[]',
    loyalty_points INTEGER DEFAULT 0,
    total_orders INTEGER DEFAULT 0,
    total_spent DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_customer_profiles_preferred_services ON customer_profiles USING GIN(preferred_services);
CREATE INDEX idx_customer_profiles_preferred_providers ON customer_profiles USING GIN(preferred_providers);
```

#### 3.3.2 customer_preferences
```sql
CREATE TABLE public.customer_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES public.customer_profiles(id) ON DELETE CASCADE,
    preference_type TEXT NOT NULL,
    preference_key TEXT NOT NULL,
    preference_value JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(customer_id, preference_type, preference_key)
);

-- Indexes
CREATE INDEX idx_customer_preferences_customer_id ON customer_preferences(customer_id);
CREATE INDEX idx_customer_preferences_type_key ON customer_preferences(preference_type, preference_key);
```

### 3.4 Business Logic Tables

#### 3.4.1 orders
```sql
CREATE TABLE public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number TEXT UNIQUE NOT NULL,
    customer_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES public.provider_profiles(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES public.provider_services(id) ON DELETE CASCADE,
    order_status TEXT DEFAULT 'pending_acceptance' CHECK (order_status IN (
        'pending_acceptance', 'accepted', 'in_progress', 'completed', 'cancelled', 'disputed'
    )),
    payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN (
        'pending', 'processing', 'completed', 'failed', 'refunded'
    )),
    total_price DECIMAL(10,2) NOT NULL,
    service_price DECIMAL(10,2) NOT NULL,
    platform_fee DECIMAL(10,2) DEFAULT 0.00,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    scheduled_start_time TIMESTAMPTZ,
    scheduled_end_time TIMESTAMPTZ,
    actual_start_time TIMESTAMPTZ,
    actual_end_time TIMESTAMPTZ,
    customer_notes TEXT,
    provider_notes TEXT,
    cancellation_reason TEXT,
    refund_amount DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_orders_order_number ON orders(order_number);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_provider_id ON orders(provider_id);
CREATE INDEX idx_orders_service_id ON orders(service_id);
CREATE INDEX idx_orders_order_status ON orders(order_status);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);
CREATE INDEX idx_orders_scheduled_start_time ON orders(scheduled_start_time);
CREATE INDEX idx_orders_created_at ON orders(created_at);
```

#### 3.4.2 order_items
```sql
CREATE TABLE public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES public.provider_services(id) ON DELETE CASCADE,
    quantity INTEGER DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_service_id ON order_items(service_id);
```

#### 3.4.3 payments
```sql
CREATE TABLE public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    payment_method TEXT NOT NULL,
    payment_provider TEXT NOT NULL,
    transaction_id TEXT,
    amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'USD',
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'refunded')),
    gateway_response JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_payments_transaction_id ON payments(transaction_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_created_at ON payments(created_at);
```

### 3.5 System Management Tables

#### 3.5.1 ref_codes
```sql
CREATE TABLE public.ref_codes (
    id TEXT PRIMARY KEY,
    type_code TEXT NOT NULL,
    parent_id TEXT REFERENCES public.ref_codes(id),
    code TEXT NOT NULL,
    name JSONB NOT NULL, -- Multi-language support
    level INTEGER DEFAULT 1,
    status INTEGER DEFAULT 1 CHECK (status IN (0, 1)),
    sort_order INTEGER DEFAULT 0,
    extra_data JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_ref_codes_type_code ON ref_codes(type_code);
CREATE INDEX idx_ref_codes_parent_id ON ref_codes(parent_id);
CREATE INDEX idx_ref_codes_level ON ref_codes(level);
CREATE INDEX idx_ref_codes_status ON ref_codes(status);
CREATE INDEX idx_ref_codes_sort_order ON ref_codes(sort_order);
```

#### 3.5.2 system_config
```sql
CREATE TABLE public.system_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    config_key TEXT UNIQUE NOT NULL,
    config_value JSONB NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_system_config_key ON system_config(config_key);
CREATE INDEX idx_system_config_active ON system_config(is_active);
```

---

## 4. Relationships & Constraints

### 4.1 Entity Relationship Diagram

```
users (1) ──── (1) user_profiles
users (1) ──── (1) user_settings
users (1) ──── (1) provider_profiles
users (1) ──── (1) customer_profiles

provider_profiles (1) ──── (N) provider_services
provider_profiles (1) ──── (N) provider_schedules
provider_profiles (1) ──── (N) orders

customer_profiles (1) ──── (N) customer_preferences
customer_profiles (1) ──── (N) orders

provider_services (1) ──── (N) orders
provider_services (1) ──── (N) order_items

orders (1) ──── (N) order_items
orders (1) ──── (N) payments

ref_codes (1) ──── (N) ref_codes (self-referencing)
```

### 4.2 Foreign Key Constraints

```sql
-- Provider Services
ALTER TABLE provider_services 
ADD CONSTRAINT fk_provider_services_provider_id 
FOREIGN KEY (provider_id) REFERENCES provider_profiles(id) ON DELETE CASCADE;

-- Provider Schedules
ALTER TABLE provider_schedules 
ADD CONSTRAINT fk_provider_schedules_provider_id 
FOREIGN KEY (provider_id) REFERENCES provider_profiles(id) ON DELETE CASCADE;

-- Orders
ALTER TABLE orders 
ADD CONSTRAINT fk_orders_customer_id 
FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE orders 
ADD CONSTRAINT fk_orders_provider_id 
FOREIGN KEY (provider_id) REFERENCES provider_profiles(id) ON DELETE CASCADE;

ALTER TABLE orders 
ADD CONSTRAINT fk_orders_service_id 
FOREIGN KEY (service_id) REFERENCES provider_services(id) ON DELETE CASCADE;

-- Order Items
ALTER TABLE order_items 
ADD CONSTRAINT fk_order_items_order_id 
FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE;

ALTER TABLE order_items 
ADD CONSTRAINT fk_order_items_service_id 
FOREIGN KEY (service_id) REFERENCES provider_services(id) ON DELETE CASCADE;

-- Payments
ALTER TABLE payments 
ADD CONSTRAINT fk_payments_order_id 
FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE;
```

### 4.3 Check Constraints

```sql
-- Order status validation
ALTER TABLE orders 
ADD CONSTRAINT chk_orders_status_valid 
CHECK (order_status IN ('pending_acceptance', 'accepted', 'in_progress', 'completed', 'cancelled', 'disputed'));

-- Payment status validation
ALTER TABLE orders 
ADD CONSTRAINT chk_orders_payment_status_valid 
CHECK (payment_status IN ('pending', 'processing', 'completed', 'failed', 'refunded'));

-- Price validation
ALTER TABLE orders 
ADD CONSTRAINT chk_orders_price_positive 
CHECK (total_price >= 0 AND service_price >= 0);

-- Schedule time validation
ALTER TABLE provider_schedules 
ADD CONSTRAINT chk_schedules_time_valid 
CHECK (start_time < end_time);
```

---

## 5. Security Policies

### 5.1 Row Level Security (RLS)

#### 5.1.1 Enable RLS on All Tables
```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE provider_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE provider_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE provider_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
```

#### 5.1.2 User Profile Policies
```sql
-- Users can only access their own profile
CREATE POLICY "Users can view own profile" ON user_profiles
    FOR SELECT USING (id = auth.uid());

CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (id = auth.uid());

CREATE POLICY "Users can insert own profile" ON user_profiles
    FOR INSERT WITH CHECK (id = auth.uid());
```

#### 5.1.3 Provider Profile Policies
```sql
-- Providers can manage their own profile
CREATE POLICY "Providers can manage own profile" ON provider_profiles
    FOR ALL USING (id = auth.uid());

-- Anyone can view active provider profiles
CREATE POLICY "Anyone can view active provider profiles" ON provider_profiles
    FOR SELECT USING (is_active = true);
```

#### 5.1.4 Provider Services Policies
```sql
-- Providers can manage their own services
CREATE POLICY "Providers can manage own services" ON provider_services
    FOR ALL USING (provider_id IN (
        SELECT id FROM provider_profiles WHERE id = auth.uid()
    ));

-- Anyone can view active services
CREATE POLICY "Anyone can view active services" ON provider_services
    FOR SELECT USING (status = 'active');
```

#### 5.1.5 Orders Policies
```sql
-- Providers can view their own orders
CREATE POLICY "Providers can view own orders" ON orders
    FOR SELECT USING (provider_id IN (
        SELECT id FROM provider_profiles WHERE id = auth.uid()
    ));

-- Providers can update their own orders
CREATE POLICY "Providers can update own orders" ON orders
    FOR UPDATE USING (provider_id IN (
        SELECT id FROM provider_profiles WHERE id = auth.uid()
    ));

-- Customers can view their own orders
CREATE POLICY "Customers can view own orders" ON orders
    FOR SELECT USING (customer_id = auth.uid());

-- Customers can create orders
CREATE POLICY "Customers can create orders" ON orders
    FOR INSERT WITH CHECK (customer_id = auth.uid());
```

### 5.2 Data Encryption

#### 5.2.1 Sensitive Data Encryption
```sql
-- Encrypt sensitive fields
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Example: Encrypt bank account information
UPDATE provider_profiles 
SET bank_account_info = pgp_sym_encrypt(
    bank_account_info::text, 
    current_setting('app.encryption_key')
)::jsonb;
```

### 5.3 Audit Logging

#### 5.3.1 Audit Log Table
```sql
CREATE TABLE public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name TEXT NOT NULL,
    record_id TEXT NOT NULL,
    action TEXT NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB,
    user_id UUID REFERENCES auth.users(id),
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_audit_logs_table_name ON audit_logs(table_name);
CREATE INDEX idx_audit_logs_record_id ON audit_logs(record_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
```

---

## 6. Performance Optimization

### 6.1 Indexing Strategy

#### 6.1.1 Primary Indexes
```sql
-- Primary key indexes are automatically created
-- Additional indexes for frequently queried columns
CREATE INDEX idx_orders_composite_status_date ON orders(order_status, created_at);
CREATE INDEX idx_orders_composite_provider_status ON orders(provider_id, order_status);
CREATE INDEX idx_orders_composite_customer_status ON orders(customer_id, order_status);
```

#### 6.1.2 Partial Indexes
```sql
-- Index only active providers
CREATE INDEX idx_provider_profiles_active ON provider_profiles(id, business_name, rating)
WHERE is_active = true;

-- Index only pending orders
CREATE INDEX idx_orders_pending ON orders(id, provider_id, scheduled_start_time)
WHERE order_status = 'pending_acceptance';
```

#### 6.1.3 Full-Text Search Indexes
```sql
-- Enable full-text search on service descriptions
ALTER TABLE provider_services ADD COLUMN search_vector tsvector;
CREATE INDEX idx_provider_services_search ON provider_services USING GIN(search_vector);

-- Update search vector
CREATE OR REPLACE FUNCTION update_search_vector() RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector := 
        setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'B');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_provider_services_search_vector
    BEFORE INSERT OR UPDATE ON provider_services
    FOR EACH ROW EXECUTE FUNCTION update_search_vector();
```

### 6.2 Query Optimization

#### 6.2.1 Materialized Views
```sql
-- Provider dashboard statistics
CREATE MATERIALIZED VIEW provider_dashboard_stats AS
SELECT 
    pp.id as provider_id,
    pp.business_name,
    COUNT(DISTINCT o.id) as total_orders,
    COUNT(DISTINCT CASE WHEN o.order_status = 'completed' THEN o.id END) as completed_orders,
    COUNT(DISTINCT CASE WHEN o.order_status = 'pending_acceptance' THEN o.id END) as pending_orders,
    SUM(CASE WHEN o.payment_status = 'completed' THEN o.total_price ELSE 0 END) as total_earnings,
    AVG(CASE WHEN o.order_status = 'completed' THEN o.total_price END) as avg_order_value,
    pp.rating,
    pp.review_count
FROM provider_profiles pp
LEFT JOIN orders o ON pp.id = o.provider_id
WHERE pp.is_active = true
GROUP BY pp.id, pp.business_name, pp.rating, pp.review_count;

-- Refresh materialized view
REFRESH MATERIALIZED VIEW provider_dashboard_stats;
```

#### 6.2.2 Partitioning Strategy
```sql
-- Partition orders table by date for better performance
CREATE TABLE orders_partitioned (
    LIKE orders INCLUDING ALL
) PARTITION BY RANGE (created_at);

-- Create monthly partitions
CREATE TABLE orders_2024_01 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE orders_2024_02 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
```

### 6.3 Caching Strategy

#### 6.3.1 Application-Level Caching
```sql
-- Cache frequently accessed data
CREATE TABLE cache_store (
    cache_key TEXT PRIMARY KEY,
    cache_value JSONB NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for cache cleanup
CREATE INDEX idx_cache_store_expires_at ON cache_store(expires_at);
```

---

## 7. Data Migration

### 7.1 Migration Scripts

#### 7.1.1 Initial Schema Migration
```sql
-- Migration: 001_initial_schema.sql
BEGIN;

-- Create tables
CREATE TABLE IF NOT EXISTS users (
    -- table definition
);

CREATE TABLE IF NOT EXISTS provider_profiles (
    -- table definition
);

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Add constraints
ALTER TABLE provider_profiles 
ADD CONSTRAINT fk_provider_profiles_user_id 
FOREIGN KEY (id) REFERENCES users(id) ON DELETE CASCADE;

COMMIT;
```

#### 7.1.2 Data Migration
```sql
-- Migration: 002_migrate_existing_data.sql
BEGIN;

-- Migrate existing user data
INSERT INTO users (id, email, full_name, user_type, status)
SELECT 
    id,
    email,
    full_name,
    CASE 
        WHEN role = 'provider' THEN 'provider'
        ELSE 'customer'
    END as user_type,
    CASE 
        WHEN is_active THEN 'active'
        ELSE 'inactive'
    END as status
FROM legacy_users
ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    user_type = EXCLUDED.user_type,
    status = EXCLUDED.status;

COMMIT;
```

### 7.2 Version Control

#### 7.2.1 Migration Tracking
```sql
CREATE TABLE schema_migrations (
    version TEXT PRIMARY KEY,
    applied_at TIMESTAMPTZ DEFAULT NOW(),
    description TEXT
);

-- Track applied migrations
INSERT INTO schema_migrations (version, description) 
VALUES ('001_initial_schema', 'Initial database schema');
```

---

## 8. Backup & Recovery

### 8.1 Backup Strategy

#### 8.1.1 Automated Backups
```sql
-- Create backup function
CREATE OR REPLACE FUNCTION create_backup() RETURNS TEXT AS $$
DECLARE
    backup_file TEXT;
BEGIN
    backup_file := '/backups/jinbean_' || to_char(now(), 'YYYY_MM_DD_HH24_MI_SS') || '.sql';
    
    -- Create backup using pg_dump
    PERFORM pg_dump(
        'host=localhost dbname=jinbean user=postgres',
        backup_file
    );
    
    RETURN backup_file;
END;
$$ LANGUAGE plpgsql;
```

#### 8.1.2 Point-in-Time Recovery
```sql
-- Enable WAL archiving
ALTER SYSTEM SET wal_level = replica;
ALTER SYSTEM SET archive_mode = on;
ALTER SYSTEM SET archive_command = 'cp %p /var/lib/postgresql/archive/%f';
```

### 8.2 Data Recovery

#### 8.2.1 Recovery Procedures
```sql
-- Restore from backup
-- pg_restore -d jinbean /backups/jinbean_2024_12_01_10_30_00.sql

-- Point-in-time recovery
-- pg_ctl stop
-- pg_ctl start -D /var/lib/postgresql/data -X recovery
```

---

## 9. Monitoring & Maintenance

### 9.1 Performance Monitoring

#### 9.1.1 Query Performance
```sql
-- Monitor slow queries
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    rows
FROM pg_stat_statements 
WHERE mean_time > 1000  -- Queries taking more than 1 second
ORDER BY mean_time DESC;
```

#### 9.1.2 Table Statistics
```sql
-- Monitor table sizes and growth
SELECT 
    schemaname,
    tablename,
    attname,
    n_distinct,
    correlation
FROM pg_stats 
WHERE schemaname = 'public'
ORDER BY tablename, attname;
```

### 9.2 Maintenance Tasks

#### 9.2.1 Regular Maintenance
```sql
-- Update table statistics
ANALYZE;

-- Vacuum tables
VACUUM ANALYZE;

-- Reindex tables
REINDEX TABLE provider_profiles;
REINDEX TABLE orders;
```

---

**Document Version**: 1.0  
**Last Updated**: December 2024  
**Maintained By**: Database Development Team 