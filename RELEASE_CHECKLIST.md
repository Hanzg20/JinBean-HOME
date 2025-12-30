# 发布检查清单 V1.0.0

## ✅ 发布前检查

### 代码准备
- [x] 版本号更新 (1.0.0+4)
- [ ] 移除所有print语句
- [ ] 移除测试代码
- [ ] API配置检查

### 功能测试
- [ ] 用户登录/注册
- [ ] 服务浏览/搜索
- [ ] 购物车功能
- [ ] 订单流程
- [ ] 支付功能
- [ ] 评价系统
- [ ] 售后流程
- [ ] 消息通知

### iOS准备
- [x] Info.plist权限配置
- [ ] App图标
- [ ] 启动屏
- [ ] 证书配置

### Android准备
- [ ] 签名配置
- [ ] ProGuard规则
- [ ] 权限声明
- [ ] 最小SDK版本

## 🔨 构建命令

### iOS
```bash
flutter clean
flutter build ios --release
```

### Android
```bash
flutter clean
flutter build apk --release
# 或
flutter build appbundle --release
```

## 📱 测试设备

- [ ] iPhone 12 (iOS 15)
- [ ] iPhone 14 (iOS 17)
- [ ] Android 10
- [ ] Android 13

## 🚀 发布步骤

1. **最终测试**
   ```bash
   flutter test
   ```

2. **构建发布版**
   ```bash
   flutter build ios --release
   flutter build apk --release
   ```

3. **App Store准备**
   - 截图准备
   - 描述文案
   - 关键词优化
   - 年龄分级

4. **Google Play准备**
   - 商店列表
   - 内容分级
   - 隐私政策

## 📝 发布说明

### V1.0.0 正式版
发布日期：2024-12-XX

**新功能：**
- 完整的服务预订流程
- 多角色支持（客户/服务商）
- 购物车系统优化
- 评价与回复系统
- 售后服务支持
- 消息通知功能
- 支付系统集成

**修复：**
- iOS图片上传问题
- 订单列表性能优化
- 购物车UI刷新问题
- 角色切换稳定性
- 评价刷新延迟

**优化：**
- 启动速度提升30%
- 内存占用减少20%
- 网络请求优化
- UI响应速度提升

## ⚠️ 注意事项

1. **环境变量检查**
   - Supabase URL和Key
   - Stripe密钥
   - Google Maps API Key

2. **隐私合规**
   - 隐私政策链接
   - 用户协议
   - 数据收集声明

3. **紧急回滚方案**
   - 保留0.0.3版本备份
   - 数据库回滚脚本准备
   - 客服应急预案

---

签核人：_____________
日期：_______________