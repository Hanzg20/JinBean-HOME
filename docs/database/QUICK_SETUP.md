# 🚀 Database Quick Setup

**2 Simple Steps - No Prerequisites!**

---

## Step 1: Content Moderation System

**Copy and run this file in Supabase SQL Editor:**

```
docs/database/content_moderation_system_safe.sql
```

**Expected output:**
```
内容审核系统数据库架构创建成功！
已创建表：sensitive_words, moderation_logs
```

---

## Step 2: Refund System

**Copy and run this file in Supabase SQL Editor:**

```
docs/database/refund_system_minimal.sql
```

**Expected output:**
```
退款系统数据库架构创建成功（最小版本）！
已创建表：refunds, refund_logs
```

---

## ✅ Verification

Run this in Supabase SQL Editor to verify:

```sql
-- Check all tables were created
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('sensitive_words', 'moderation_logs', 'refunds', 'refund_logs')
ORDER BY table_name;
```

**Expected result:** 4 rows

---

## 🎉 Done!

Your database is now ready. You can:

1. ✅ Run the Flutter app
2. ✅ Test image upload on iOS
3. ✅ Test content moderation (try posting a review with "垃圾" or "骗子")
4. ✅ Test refund workflow

---

## 🆘 Troubleshooting

### Error: "relation already exists"
**This is fine!** It means the table was created before. Ignore and continue.

### Error: "relation 'users' does not exist"
**You're using the wrong file.** Use the files mentioned above (with "safe" or "minimal" in the name).

### Error: "permission denied"
**Check:** Make sure you're logged into Supabase and have admin access to the project.

---

## 📚 More Info

For detailed documentation, see:
- [DATABASE_SETUP_GUIDE.md](DATABASE_SETUP_GUIDE.md) - Full setup guide
- [CONTENT_MODERATION_GUIDE.md](../development/CONTENT_MODERATION_GUIDE.md) - How to use moderation
- [IOS_IMAGE_UPLOAD_GUIDE.md](../development/IOS_IMAGE_UPLOAD_GUIDE.md) - iOS image upload guide

---

*Quick Setup v1.0 - Last Updated: 2025-12-28*
