# Database Setup Guide

> **Purpose:** Step-by-step guide to set up all database schemas for JinBean
> **Date:** 2025-12-28

## ⚠️ Important: Setup Order

The database schemas **must be executed in the correct order** due to dependencies between tables.

---

## 📋 Prerequisites Check

Before running any SQL scripts, verify your Supabase database has these core tables:

### Required Core Tables

1. **`user_profiles`** (or `users`) - User information
   - Must have columns: `id`, `role`
   - Roles should include: `customer`, `provider`, `admin`, `super_admin`

2. **`orders`** - Order records
   - Must have columns: `id`, `user_id`, `provider_id`, `order_status`, `total_price`, etc.

3. **`reviews`** - Review records (will be extended by our scripts)
   - Must have columns: `id`, `user_id`, `service_id`, `rating`, `content`, etc.

### Check if Tables Exist

Run this SQL in Supabase SQL Editor:

```sql
-- Check core tables
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('user_profiles', 'users', 'orders', 'reviews');
```

**Expected result:** Should return at least `orders` and `reviews` tables.

---

## 🚀 Quick Start (Recommended)

**Just run these 2 files in order - no prerequisites needed!**

### Step 1: Content Moderation System ✅

**File:** [content_moderation_system_safe.sql](content_moderation_system_safe.sql)

1. Open Supabase SQL Editor
2. Copy the entire content of `docs/database/content_moderation_system_safe.sql`
3. Paste and click "Run"

**Success message:**
```
内容审核系统数据库架构创建成功！
```

---

### Step 2: Refund System ✅

**File:** [refund_system_minimal.sql](refund_system_minimal.sql)

1. In Supabase SQL Editor
2. Copy the entire content of `docs/database/refund_system_minimal.sql`
3. Paste and click "Run"

**Success message:**
```
退款系统数据库架构创建成功（最小版本）！
```

---

## ✅ That's It!

You should now have:
- ✅ Content moderation working
- ✅ Refund system working
- ✅ All necessary tables and policies

**Ready to test your app!**

---

## 📋 Detailed Instructions (Optional)

### What Was Created?

#### Content Moderation System
- Tables: `sensitive_words`, `moderation_logs`
- Views: `pending_manual_reviews`, `moderation_statistics`
- Functions: `approve_pending_content()`, `reject_pending_content()`
- RLS Policies: Basic authentication-based policies

#### Refund System
- Tables: `refunds`, `refund_logs`
- Views: `pending_refunds_simple`, `refund_statistics_simple`
- Functions: `get_provider_refund_stats()`, `cleanup_old_failed_refunds()`
- RLS Policies: User/provider/service role based

---

## 🔧 Advanced Setup (If You Have All Tables)

If your database already has complete `orders` and `users` tables with all proper columns:

**Prerequisites:**
- ✅ `orders` table must exist
- ✅ `user_profiles` or `users` table must exist

**File:** `docs/database/refund_system.sql` (original full version)

**What it does:**
- Creates `refunds` table
- Creates `refund_logs` table
- Adds refund fields to existing `orders` table
- Creates views and RLS policies

**If you get errors:**

If you see **"relation 'users' does not exist"**, modify the script:

1. Find all instances of `users` table references
2. Replace with your actual user table name (likely `user_profiles`)

Example:
```sql
-- Original
SELECT 1 FROM users WHERE id = auth.uid()

-- Replace with
SELECT 1 FROM user_profiles WHERE id = auth.uid()
```

**OR use the safe version below.**

---

## 🛡️ Safe Version: Refund System (No Dependencies)

If you're getting errors about missing tables, use this minimal version first:

```sql
-- ================================================
-- Refund System - Minimal Version (No Dependencies)
-- ================================================

-- 1. Create refunds table (basic version)
CREATE TABLE IF NOT EXISTS refunds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL,
    user_id UUID NOT NULL,
    provider_id UUID NOT NULL,

    -- Refund info
    refund_type VARCHAR(20) NOT NULL DEFAULT 'full',
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    original_amount DECIMAL(10, 2) NOT NULL,

    -- Refund reason
    reason TEXT NOT NULL,
    reason_type VARCHAR(50),
    description TEXT,
    images TEXT[],

    -- Review info
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    reviewed_by UUID,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    review_note TEXT,

    -- Stripe info
    stripe_refund_id VARCHAR(255),
    provider_response JSONB,

    -- Error info
    error_message TEXT,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processing_started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    failed_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT refund_type_check CHECK (refund_type IN ('full', 'partial')),
    CONSTRAINT refund_status_check CHECK (
        status IN ('pending', 'approved', 'rejected', 'processing', 'completed', 'failed')
    ),
    CONSTRAINT refund_amount_check CHECK (amount <= original_amount)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_refunds_order_id ON refunds(order_id);
CREATE INDEX IF NOT EXISTS idx_refunds_user_id ON refunds(user_id);
CREATE INDEX IF NOT EXISTS idx_refunds_provider_id ON refunds(provider_id);
CREATE INDEX IF NOT EXISTS idx_refunds_status ON refunds(status);
CREATE INDEX IF NOT EXISTS idx_refunds_created_at ON refunds(created_at DESC);

-- 2. Create refund_logs table
CREATE TABLE IF NOT EXISTS refund_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    refund_id UUID NOT NULL,
    event VARCHAR(50) NOT NULL,
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_refund_logs_refund_id ON refund_logs(refund_id);
CREATE INDEX IF NOT EXISTS idx_refund_logs_created_at ON refund_logs(created_at DESC);

-- 3. Enable RLS with basic policies
ALTER TABLE refunds ENABLE ROW LEVEL SECURITY;
ALTER TABLE refund_logs ENABLE ROW LEVEL SECURITY;

-- Users can view their own refunds
DROP POLICY IF EXISTS "users_view_own_refunds" ON refunds;
CREATE POLICY "users_view_own_refunds" ON refunds
    FOR SELECT USING (user_id = auth.uid() OR provider_id = auth.uid());

-- Users can create refunds
DROP POLICY IF EXISTS "users_create_refunds" ON refunds;
CREATE POLICY "users_create_refunds" ON refunds
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Service role can do everything
DROP POLICY IF EXISTS "service_role_all_refunds" ON refunds;
CREATE POLICY "service_role_all_refunds" ON refunds
    FOR ALL USING (auth.role() = 'service_role');

-- Logs can be inserted by anyone (system)
DROP POLICY IF EXISTS "anyone_insert_logs" ON refund_logs;
CREATE POLICY "anyone_insert_logs" ON refund_logs
    FOR INSERT WITH CHECK (true);

-- Users can view logs for their refunds
DROP POLICY IF EXISTS "users_view_own_logs" ON refund_logs;
CREATE POLICY "users_view_own_logs" ON refund_logs
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM refunds
            WHERE refunds.id = refund_logs.refund_id
            AND (refunds.user_id = auth.uid() OR refunds.provider_id = auth.uid())
        )
    );

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Refund system created successfully (minimal version)!';
    RAISE NOTICE 'Tables created: refunds, refund_logs';
    RAISE NOTICE 'Note: Advanced features (views, functions) require orders table';
END $$;
```

---

## 🧪 Testing the Setup

After running all scripts, verify everything works:

### 1. Check All Tables

```sql
SELECT
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE columns.table_name = tables.table_name) as column_count
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('sensitive_words', 'moderation_logs', 'refunds', 'refund_logs', 'reviews', 'orders')
ORDER BY table_name;
```

### 2. Test Sensitive Words

```sql
-- Should return some default words
SELECT category, COUNT(*) as word_count
FROM sensitive_words
WHERE is_active = true
GROUP BY category;
```

### 3. Test Moderation Logs

```sql
-- Should return 0 rows initially
SELECT COUNT(*) FROM moderation_logs;
```

### 4. Test Refunds

```sql
-- Should return 0 rows initially
SELECT COUNT(*) FROM refunds;
```

### 5. Check Views

```sql
-- List all views
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public'
AND table_name LIKE '%moderation%' OR table_name LIKE '%refund%';
```

---

## 🔧 Troubleshooting

### Error: "relation 'users' does not exist"

**Solution:** Use the safe versions provided in this guide, which don't require the `users` table.

**OR:** Replace all `users` references with your actual user table name (`user_profiles`).

### Error: "relation 'orders' does not exist"

**Cause:** The refund system requires an `orders` table.

**Solution:**
1. Create the `orders` table first, OR
2. Use the minimal refund system version above (no foreign key constraints)

### Error: "column does not exist"

**Cause:** Missing columns in existing tables.

**Solution:** The scripts use `DO $$` blocks to safely add columns. If you still get errors:

```sql
-- Check what columns exist in reviews table
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'reviews';

-- Manually add missing columns
ALTER TABLE reviews ADD COLUMN IF NOT EXISTS moderation_status VARCHAR(20) DEFAULT 'pending';
ALTER TABLE reviews ADD COLUMN IF NOT EXISTS provider_response_status VARCHAR(20) DEFAULT 'pending_review';
```

### RLS Policies Not Working

**Symptoms:** Can't query tables even when authenticated.

**Solution:** Temporarily disable RLS for testing:

```sql
-- Disable RLS (ONLY for testing!)
ALTER TABLE sensitive_words DISABLE ROW LEVEL SECURITY;
ALTER TABLE moderation_logs DISABLE ROW LEVEL SECURITY;

-- Re-enable after fixing policies
ALTER TABLE sensitive_words ENABLE ROW LEVEL SECURITY;
ALTER TABLE moderation_logs ENABLE ROW LEVEL SECURITY;
```

---

## 📦 Supabase Storage Buckets

After setting up the database, create these storage buckets:

### 1. `reviews` Bucket

```
Name: reviews
Public: Yes
File size limit: 5MB
Allowed MIME types: image/jpeg, image/png, image/webp
```

### 2. `service-images` Bucket

```
Name: service-images
Public: Yes
File size limit: 10MB
Allowed MIME types: image/jpeg, image/png, image/webp
```

### Create Buckets via SQL

```sql
-- Create buckets (Supabase only)
INSERT INTO storage.buckets (id, name, public)
VALUES
    ('reviews', 'reviews', true),
    ('service-images', 'service-images', true)
ON CONFLICT (id) DO NOTHING;
```

---

## ✅ Verification Checklist

After setup, verify:

- [ ] `sensitive_words` table exists and has default data
- [ ] `moderation_logs` table exists
- [ ] `refunds` table exists
- [ ] `refund_logs` table exists
- [ ] `reviews` table has `moderation_status` column
- [ ] `reviews` table has `provider_response_status` column
- [ ] Views are created (`pending_manual_reviews`, etc.)
- [ ] RLS policies are in place
- [ ] Storage buckets are created
- [ ] No SQL errors when querying tables

---

## 📚 Next Steps

1. ✅ Database setup complete
2. Run the Flutter app: `flutter run`
3. Test image upload on iOS device
4. Test content moderation (try creating a review with a sensitive word)
5. Test refund workflow

---

## 🆘 Getting Help

If you encounter issues:

1. Check the troubleshooting section above
2. Run the verification queries to identify what's missing
3. Check Supabase logs for detailed error messages
4. Ensure your Supabase project has authentication enabled

**Common mistakes:**
- Running scripts out of order
- Missing core tables (`orders`, `reviews`)
- Not having authentication configured
- Wrong table names (`users` vs `user_profiles`)

---

*Last Updated: 2025-12-28*
