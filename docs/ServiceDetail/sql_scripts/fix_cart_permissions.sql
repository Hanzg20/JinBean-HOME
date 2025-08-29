-- 修复购物车数据库权限问题
-- 解决 "new row violates row-level security policy" 错误

-- 1. 检查当前权限状态
DO $$ 
DECLARE
    policy_exists boolean;
BEGIN
    RAISE NOTICE '🔍 开始检查购物车表权限状态...';
    
    -- 检查 cart_operation_logs 表的 RLS 状态
    SELECT EXISTS (
        SELECT 1 FROM pg_class c 
        JOIN pg_namespace n ON n.oid = c.relnamespace 
        WHERE n.nspname = 'public' 
        AND c.relname = 'cart_operation_logs' 
        AND c.relrowsecurity = true
    ) INTO policy_exists;
    
    IF policy_exists THEN
        RAISE NOTICE '✅ cart_operation_logs 表已启用 RLS';
    ELSE
        RAISE NOTICE '❌ cart_operation_logs 表未启用 RLS';
    END IF;
END $$;

-- 2. 为 cart_operation_logs 表设置正确的 RLS 策略
DROP POLICY IF EXISTS "cart_operation_logs_policy" ON public.cart_operation_logs;

CREATE POLICY "cart_operation_logs_policy" 
ON public.cart_operation_logs 
FOR ALL 
TO authenticated 
USING (auth.uid() = user_id);

-- 3. 为 unified_carts 表设置 RLS 策略（如果还没有）
DROP POLICY IF EXISTS "unified_carts_policy" ON public.unified_carts;

CREATE POLICY "unified_carts_policy" 
ON public.unified_carts 
FOR ALL 
TO authenticated 
USING (auth.uid() = user_id);

-- 4. 为 cart_items 表设置 RLS 策略（如果还没有）
DROP POLICY IF EXISTS "cart_items_policy" ON public.cart_items;

CREATE POLICY "cart_items_policy" 
ON public.cart_items 
FOR ALL 
TO authenticated 
USING (
    EXISTS (
        SELECT 1 FROM public.unified_carts uc 
        WHERE uc.id = cart_items.cart_id 
        AND uc.user_id = auth.uid()
    )
);

-- 5. 确保所有表都启用了 RLS
ALTER TABLE public.unified_carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_operation_logs ENABLE ROW LEVEL SECURITY;

-- 6. 授予必要的权限
GRANT SELECT, INSERT, UPDATE, DELETE ON public.unified_carts TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.cart_items TO authenticated;
GRANT SELECT, INSERT ON public.cart_operation_logs TO authenticated;

-- 7. 验证权限设置
DO $$ 
DECLARE
    cart_policies int;
    items_policies int;
    logs_policies int;
BEGIN
    RAISE NOTICE '🔍 验证权限策略...';
    
    -- 检查策略数量
    SELECT COUNT(*) INTO cart_policies 
    FROM pg_policies 
    WHERE tablename = 'unified_carts' AND schemaname = 'public';
    
    SELECT COUNT(*) INTO items_policies 
    FROM pg_policies 
    WHERE tablename = 'cart_items' AND schemaname = 'public';
    
    SELECT COUNT(*) INTO logs_policies 
    FROM pg_policies 
    WHERE tablename = 'cart_operation_logs' AND schemaname = 'public';
    
    RAISE NOTICE '📊 权限策略统计:';
    RAISE NOTICE '   - unified_carts: % 个策略', cart_policies;
    RAISE NOTICE '   - cart_items: % 个策略', items_policies;
    RAISE NOTICE '   - cart_operation_logs: % 个策略', logs_policies;
    
    IF cart_policies > 0 AND items_policies > 0 AND logs_policies > 0 THEN
        RAISE NOTICE '✅ 所有购物车表权限策略设置完成！';
    ELSE
        RAISE NOTICE '❌ 部分表缺少权限策略，请检查！';
    END IF;
END $$;

-- 8. 最终确认
DO $$ 
BEGIN
    RAISE NOTICE '🎉 购物车权限修复完成！现在您可以：';
    RAISE NOTICE '   ✅ 正常添加商品到购物车';
    RAISE NOTICE '   ✅ 查看购物车内容';
    RAISE NOTICE '   ✅ 记录购物车操作日志';
    RAISE NOTICE '   ✅ 不再出现 RLS 权限错误';
END $$;
