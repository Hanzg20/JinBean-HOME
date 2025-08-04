# ServiceDetailPage 全面设计文档

## 📋 **文档概述**

### **版本信息**
- **版本**: v2.0
- **创建日期**: 2024-08-03
- **最后更新**: 2024-12-19
- **负责人**: UI/UX Team
- **审核人**: 技术负责人

### **文档目的**
本设计文档旨在为JinBean应用的ServiceDetailPage提供全面的设计指导，确保开发团队能够按照统一的设计标准和功能要求进行开发。

---

## 🎯 **1. 产品定位与目标**

### **1.1 产品定位**
ServiceDetailPage是JinBean应用的核心页面之一，负责展示服务详情、提供商信息、用户评价等关键信息，是用户决策和转化的关键节点。

### **1.2 设计目标**
- **信息完整性**: 提供全面的服务信息展示
- **用户体验**: 简洁直观的界面设计，快速获取关键信息
- **转化优化**: 清晰的价值主张和行动引导
- **信任建立**: 通过评价、认证等信息建立用户信任
- **本地化**: 符合北美用户习惯的设计风格

### **1.3 多语言支持策略**
- **地址信息**: 统一使用英文，便于地图API和导航系统使用
- **业务内容**: 使用jsonb字段存储多语言版本（title, description等）
- **界面文本**: 使用Flutter国际化系统处理
- **Fallback策略**: 优先显示用户语言，无对应语言时回退到英文

### **1.4 竞品对标**
- **Yelp**: 信息密度高，评价系统完善
- **Thumbtack**: 服务导向，询价流程简化
- **Fiverr**: 模块化展示，强交互式设计
- **阿里本地生活**: 本地化体验，统一支付系统

---

## 🏗️ **2. 技术架构设计**

### **2.1 整体架构**
```
ServiceDetailPage
├── 数据层 (Data Layer)
│   ├── ServiceDetailController
│   ├── MessageService (MsgNexus集成)
│   └── 本地缓存管理
├── 业务层 (Business Layer)
│   ├── 服务信息管理
│   ├── 评价系统
│   ├── 聊天系统
│   └── 预订系统
└── 表现层 (Presentation Layer)
    ├── Hero区域
    ├── 导航标签
    ├── 内容区域
    └── 行动区域
```

### **2.2 技术栈**
- **状态管理**: GetX
- **UI框架**: Flutter Material Design 3
- **网络请求**: Dio
- **消息服务**: MsgNexus API
- **主题系统**: CustomerThemeComponents
- **路由管理**: GetX Navigation
- **地图服务**: Google Maps Flutter (复用现有服务地图功能)

---

## 🎨 **3. UI/UX 设计规范**

### **3.1 设计原则**
1. **信息层次清晰**: 重要信息突出，次要信息弱化
2. **行动导向**: 主要操作按钮始终可见
3. **一致性**: 遵循Customer主题系统规范
4. **响应式**: 适配不同屏幕尺寸
5. **可访问性**: 支持无障碍访问

### **3.2 视觉规范**

#### **A. 颜色系统**
- **主色调**: 青色系 (#00BCD4, #0097A7, #26C6DA)
- **状态颜色**: 成功绿、警告橙、错误红、信息蓝
- **中性色**: 白色、浅灰、深灰、黑色

#### **B. 字体规范**
- **标题字体**: 32px/28px/24px 粗体
- **正文字体**: 22px/16px/14px 常规
- **辅助文字**: 12px 常规

#### **C. 间距规范**
- **基础间距**: 4px/8px/12px/16px/24px/32px
- **组件间距**: 卡片内边距16px，区块间距24px

#### **D. 圆角规范**
- **4倍右上角圆角规则**: 右上角半径是其他角的4倍
- **卡片圆角**: 16px/64px/16px/16px
- **按钮圆角**: 12px/48px/12px/12px

---

## 📱 **4. 页面结构设计**

### **4.1 整体布局**
```
┌─────────────────────────────────────┐
│ AppBar (返回、分享、收藏)              │
├─────────────────────────────────────┤
│ Hero Section (图片轮播 + 核心信息)     │
├─────────────────────────────────────┤
│ 相似服务推荐区域                      │
├─────────────────────────────────────┤
│ Navigation Tabs (概览、服务、评价、信息) │
├─────────────────────────────────────┤
│ Content Area (标签页内容)            │
├─────────────────────────────────────┤
│ Bottom Actions (联系、预订)          │
└─────────────────────────────────────┘
```

### **4.2 详细组件设计**

#### **A. AppBar设计**
- **左侧**: 返回按钮
- **中间**: 页面标题 "Service Detail"
- **右侧**: 收藏按钮(心形图标)、分享按钮(分享图标)
- **样式**: 白色背景，无阴影，青色主题色

#### **B. Hero Section设计**
```
┌─────────────────────────────────────┐
│  ┌─────────────────────────────────┐ │
│  │        图片轮播区域              │ │
│  │     (300px高度，全宽)           │ │
│  └─────────────────────────────────┘ │
│                                     │
│  ┌─────────────────────────────────┐ │
│  │ 渐变遮罩层 (透明到黑色渐变)        │ │
│  └─────────────────────────────────┘ │
│                                     │
│  ┌─────────────────────────────────┐ │
│  │ 核心信息层 (底部16px内边距)       │ │
│  │ ┌─────────────────────────────┐ │ │
│  │ │ 商家名称 + 在线状态标签       │ │ │
│  │ └─────────────────────────────┘ │ │
│  │ ┌─────────────────────────────┐ │ │
│  │ │ 评分信息 + 价格标签          │ │ │
│  │ └─────────────────────────────┘ │ │
│  │ ┌─────────────────────────────┐ │ │
│  │ │ 快速操作按钮 (Get Quote/Chat) │ │ │
│  │ └─────────────────────────────┘ │ │
│  └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

#### **C. 相似服务推荐区域设计**
```
┌─────────────────────────────────────┐
│ ┌─────────────────────────────────┐ │
│ │ Similar Services        View All│ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ [头像] Provider Name            │ │
│ │     Service Title               │ │
│ │     ⭐ 4.7 (89)    $42    92%   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ [头像] Provider Name            │ │
│ │     Service Title               │ │
│ │     ⭐ 4.9 (156)   $48    88%   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ [头像] Provider Name            │ │
│ │     Service Title               │ │
│ │     ⭐ 4.6 (67)    $45    85%   │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

**设计特点**:
- **位置**: 紧接在Hero Section之后，服务标题之前
- **布局**: 卡片式设计，每个相似服务一行
- **信息展示**: 提供商头像、名称、服务标题、评分、价格、相似度
- **交互**: 点击可跳转到对应服务详情页
- **加载状态**: 显示加载指示器
- **空状态**: 无相似服务时隐藏整个区域

#### **D. 导航标签设计**
```
┌─────────────────────────────────────┐
│ [Overview] [Services] [Reviews] [Info] │
├─────────────────────────────────────┤
│                                     │
│        标签页内容区域                │
│                                     │
└─────────────────────────────────────┘
```

#### **E. 底部行动区域**
```
┌─────────────────────────────────────┐
│ ┌─────────────┐ ┌─────────────────┐ │
│ │   Contact   │ │    Book Now     │ │
│ │             │ │                 │ │
│ └─────────────┘ └─────────────────┘ │
└─────────────────────────────────────┘
```

---

## 🎯 **5. 核心功能设计 - Contact、Book Now、Get Quote**

### **5.1 功能边界划分**

#### **A. Contact（联系）功能范围**
**主要功能**:
- **实时聊天**: 与服务提供者进行实时消息交流
- **电话联系**: 直接拨打电话给服务提供者
- **邮件联系**: 发送邮件给服务提供者
- **查看联系信息**: 显示服务提供者的完整联系信息

**功能入口**:
- **Hero区域**: 快速聊天按钮
- **底部操作栏**: Contact按钮
- **联系选项弹窗**: 多种联系方式选择

**交互流程**:
1. 用户点击Contact按钮
2. 显示联系选项弹窗
3. 用户选择联系方式（聊天/电话/邮件/查看信息）
4. 执行相应的联系操作

**设计原则**:
- 作为通用的联系入口
- 提供多种联系方式选择
- 快速响应，无需复杂流程

#### **B. Book Now（立即预订）功能范围**
**主要功能**:
- **直接预订**: 对于固定价格服务，直接进入预订流程
- **时间选择**: 选择服务日期和时间
- **可用性检查**: 查看服务提供者的可用时间
- **支付流程**: 完成预订支付
- **预订确认**: 确认预订信息

**功能入口**:
- **Hero区域**: Book Now按钮（固定价格服务）
- **底部操作栏**: Book Now按钮（固定价格服务）
- **预订选项弹窗**: 多种预订方式选择

**交互流程**:
1. 用户点击Book Now按钮
2. 显示预订选项弹窗
3. 用户选择预订方式（立即预订/查看可用时间/联系提供者）
4. 执行相应的预订操作

**设计原则**:
- 针对固定价格服务
- 快速预订流程
- 清晰的价格信息

#### **C. Get Quote（获取报价）功能范围**
**主要功能**:
- **快速报价**: 简单描述需求，获取快速估算
- **详细报价**: 填写详细表单，获取准确报价
- **报价管理**: 查看、接受、拒绝报价
- **报价状态跟踪**: 跟踪报价请求状态

**功能入口**:
- **Hero区域**: Get Quote按钮（需要报价的服务）
- **底部操作栏**: Get Quote按钮（需要报价的服务）
- **Overview Tab**: 报价请求卡片
- **联系选项**: 报价请求选项

**交互流程**:
1. 用户点击Get Quote按钮
2. 显示报价选项弹窗（快速报价/详细报价/先聊天）
3. 用户选择报价方式
4. 填写报价表单
5. 提交报价请求
6. 跟踪报价状态

**设计原则**:
- 针对自定义价格服务
- 详细的报价表单
- 状态跟踪和反馈

### **5.2 功能区分逻辑**

#### **A. 服务类型判断**
```dart
// 服务类型判断逻辑
String getPrimaryAction(ServiceDetail serviceDetail) {
  if (serviceDetail.pricingType == 'fixed' || serviceDetail.pricingType == 'hourly') {
    return 'Book Now';
  } else if (serviceDetail.pricingType == 'custom' || serviceDetail.pricingType == 'negotiable') {
    return 'Get Quote';
  }
  return 'Get Quote'; // 默认显示报价
}
```

#### **B. 用户意图区分**
- **Contact**: 用户想要联系提供者，了解详情或讨论
- **Book Now**: 用户确定要预订服务，直接进入预订流程
- **Get Quote**: 用户需要了解具体价格，提交报价请求

#### **C. 功能优先级**
1. **主要操作**: 根据服务类型显示Book Now或Get Quote
2. **辅助操作**: Contact作为通用的联系入口
3. **详细信息**: 在Overview Tab中提供完整的报价表单

### **5.3 用户体验优化**

#### **A. 入口优化**
- **Hero区域**: 突出显示主要操作按钮
- **底部操作栏**: 提供快速访问
- **Tab内容**: 提供详细信息和支持功能

#### **B. 流程优化**
- **快速路径**: 一键进入主要功能
- **详细路径**: 提供完整的表单和选项
- **灵活选择**: 用户可以根据需要选择不同的操作方式

#### **C. 反馈机制**
- **状态提示**: 显示操作进度和结果
- **错误处理**: 友好的错误提示和恢复建议
- **成功确认**: 明确的操作成功反馈

---

## ⭐ **6. 评价系统优化设计**

### **6.1 评价统计展示**

#### **A. 总体评分展示**
```dart
Widget _buildReviewStats() {
  return Column(
    children: [
      // 大评分显示
      Row(
        children: [
          Text(
            '4.8',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          Text('/ 5.0'),
        ],
      ),
      // 星级显示
      Row(
        children: List.generate(5, (index) => Icon(Icons.star)),
      ),
      // 评价数量
      Text('127 reviews'),
    ],
  );
}
```

#### **B. 统计信息**
- **正面评价**: 4星以上评价数量
- **有评论**: 包含文字评论的评价数量
- **总评价**: 所有评价数量

#### **C. 评分分布**
- **5星**: 60% (可视化进度条)
- **4星**: 25% (可视化进度条)
- **3星**: 10% (可视化进度条)
- **2星**: 3% (可视化进度条)
- **1星**: 2% (可视化进度条)

### **6.2 评价筛选和排序**

#### **A. 排序选项**
- **最新优先**: 按时间倒序排列
- **最早优先**: 按时间正序排列
- **评分最高**: 按评分倒序排列
- **评分最低**: 按评分正序排列

#### **B. 筛选选项**
- **全部评价**: 显示所有评价
- **5星评价**: 只显示5星评价
- **4星评价**: 只显示4星评价
- **有图片**: 只显示包含图片的评价
- **已验证**: 只显示已验证购买的评价

### **6.3 评价交互功能**

#### **A. 评价操作**
- **点赞**: 标记评价为有用
- **回复**: 提供商回复评价
- **举报**: 举报不当评价
- **分享**: 分享评价到社交媒体

#### **B. 评价撰写**
- **总体评分**: 1-5星评分
- **详细评分**: 质量、准时性、沟通、性价比
- **评价内容**: 文字描述
- **图片上传**: 上传相关图片
- **标签选择**: 选择相关标签
- **匿名选项**: 选择是否匿名发布

---

## 🗺️ **7. 服务区域地图优化设计**

### **7.1 地图功能增强**

#### **A. 地图类型切换**
- **标准地图**: 基础街道地图
- **卫星视图**: 卫星图像
- **地形视图**: 地形图

#### **B. 地图控制**
- **缩放控制**: 放大/缩小按钮
- **定位功能**: 显示用户当前位置
- **全屏模式**: 全屏查看地图

#### **C. 服务区域可视化**
- **服务半径**: 圆形覆盖区域
- **服务边界**: 多边形服务区域
- **响应时间**: 不同颜色表示响应时间

### **7.2 导航信息展示**

#### **A. 距离和时间**
- **行驶距离**: 从用户位置到服务地点
- **行驶时间**: 预计行驶时间
- **公共交通**: 公共交通选项

#### **B. 导航操作**
- **获取路线**: 打开导航应用
- **复制地址**: 复制服务地址
- **查看街景**: 查看街景图像

### **7.3 服务区域详情**

#### **A. 覆盖信息**
- **服务半径**: 5公里服务半径
- **响应时间**: 2-4小时响应
- **到达时间**: 15-30分钟到达

#### **B. 可用性状态**
- **服务可用**: 绿色状态指示
- **服务不可用**: 红色状态指示
- **临时不可用**: 黄色状态指示

---

## 👨‍💼 **8. 提供商信息优化设计**

### **8.1 提供商基本信息**

#### **A. 头像和名称**
- **公司头像**: 圆形头像显示
- **公司名称**: 突出显示
- **认证状态**: 认证徽章

#### **B. 评分和评价**
- **平均评分**: 大字体显示
- **评价数量**: 括号内显示
- **星级显示**: 可视化星级

#### **C. 状态标签**
- **已验证**: 绿色标签
- **专业**: 蓝色标签
- **在线**: 实时状态

### **8.2 提供商统计信息**

#### **A. 核心统计**
- **评分**: 平均评分
- **评价**: 评价总数
- **服务**: 服务数量
- **响应**: 响应时间

#### **B. 可视化展示**
- **图标**: 相关图标
- **数值**: 大字体显示
- **标签**: 说明文字

### **8.3 认证和保险信息**

#### **A. 认证信息**
- **营业执照**: 绿色图标
- **保险信息**: 蓝色图标
- **认证状态**: 实时更新

#### **B. 详细信息**
- **证书编号**: 显示证书编号
- **有效期**: 显示有效期
- **状态**: 有效/过期状态

---

## 📊 **9. 性能优化策略**

### **9.1 图片优化**
- **懒加载**: 图片按需加载
- **缓存策略**: 本地缓存、内存缓存
- **压缩优化**: 图片压缩、格式优化

### **9.2 列表优化**
- **虚拟滚动**: 长列表性能优化
- **分页加载**: 数据分页加载
- **缓存机制**: 列表数据缓存

### **9.3 网络请求优化**
- **请求缓存**: API响应缓存
- **并发控制**: 请求并发限制
- **错误重试**: 网络错误重试机制

---

## 🔒 **10. 安全考虑**

### **10.1 数据验证**
- **输入验证**: 用户输入数据验证
- **参数验证**: API参数验证
- **权限控制**: 用户权限验证

### **10.2 隐私保护**
- **数据加密**: 敏感数据加密
- **访问控制**: 数据访问权限控制
- **日志安全**: 日志数据脱敏

---

## 📋 **11. 开发计划**

### **11.1 开发阶段**
1. **第一阶段**: 基础页面结构、数据模型 (2周)
2. **第二阶段**: 核心功能实现、API集成 (3周)
3. **第三阶段**: 聊天系统集成、UI优化 (2周)
4. **第四阶段**: 测试、性能优化、部署 (1周)

### **11.2 里程碑**
- **M1**: 基础页面完成
- **M2**: 核心功能完成
- **M3**: 聊天系统完成
- **M4**: 测试优化完成

---

## ✅ **12. 验收标准**

### **12.1 功能验收**
- ✅ 服务信息完整展示
- ✅ 提供商信息准确显示
- ✅ 评价系统正常工作
- ✅ 聊天功能正常使用
- ✅ 预订流程完整
- ✅ 地图导航功能正常
- ✅ 报价展示逻辑正确
- ✅ Contact、Book Now、Get Quote功能边界清晰

### **12.2 性能验收**
- ✅ 页面加载时间 < 3秒
- ✅ 图片加载流畅
- ✅ 聊天消息实时更新
- ✅ 内存使用合理

### **12.3 用户体验验收**
- ✅ 界面美观、符合设计规范
- ✅ 操作流畅、响应及时
- ✅ 错误处理友好
- ✅ 无障碍访问支持

---

## 📚 **13. 参考资料**

### **13.1 设计规范**
- Material Design 3 官方文档
- JinBean Customer Theme Guide
- 竞品分析报告

### **13.2 技术文档**
- Flutter 官方文档
- GetX 状态管理文档
- MsgNexus API 文档
- Google Maps Flutter 文档

### **13.3 相关链接**
- [JinBean 项目仓库](https://github.com/jinbean/jinbean-app)
- [设计系统文档](https://design.jinbean.com)
- [API 文档](https://api.jinbean.com)

---

## 🔧 **14. 开发注意事项**

### **14.1 代码规范**
- 遵循Flutter官方代码规范
- 使用CustomerThemeComponents进行UI开发
- 确保所有异步操作有适当的错误处理
- 添加必要的日志记录

### **14.2 性能考虑**
- 避免在build方法中进行复杂计算
- 合理使用GetX的响应式编程
- 图片加载使用缓存机制
- 网络请求实现重试机制

### **14.3 测试要求**
- 每个Controller都要有对应的单元测试
- UI组件需要Widget测试
- 关键用户流程需要集成测试
- 性能测试要覆盖各种网络条件

### **14.4 地图功能复用**
- 复用现有的ServiceMapController核心功能
- 扩展地图功能以支持服务详情页面需求
- 保持与现有服务地图功能的一致性
- 确保地图组件的性能优化

---

## 📝 **15. 更新日志**

### **v2.0 (2024-12-19)**
- 添加Contact、Book Now、Get Quote功能边界划分
- 优化评价系统设计，添加筛选和排序功能
- 增强服务区域地图功能，添加地图控制和导航
- 优化提供商信息展示，添加统计和认证信息
- 更新功能范围说明和用户体验优化策略

### **v1.1 (2024-08-03)**
- 添加地图导航与服务范围设计
- 添加报价展示设计
- 分析现有服务地图功能复用策略
- 更新数据模型以支持地图和报价功能

### **v1.0 (2024-08-03)**
- 初始版本创建
- 完成基础架构设计
- 定义核心数据模型
- 制定UI/UX设计规范

---

*本文档将根据开发进展持续更新，请关注最新版本。如有疑问，请联系UI/UX团队。* 

### **7.3 相似服务推荐组件设计**

#### **A. 相似服务区域组件**
```dart
Widget _buildSimilarServicesSection(ServiceDetailController controller, ThemeData theme) {
  final similarServices = controller.similarServices;
  final colorScheme = theme.colorScheme;
  
  if (similarServices.isEmpty) {
    return const SizedBox.shrink();
  }

  return CustomerCard(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Similar Services',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => controller.viewAllSimilarServices(),
                child: Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (controller.isLoadingSimilarServices)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Column(
              children: similarServices.take(3).map((service) {
                return _buildSimilarServiceCard(service, controller, theme);
              }).toList(),
            ),
        ],
      ),
    ),
  );
}
```

#### **B. 相似服务卡片组件**
```dart
Widget _buildSimilarServiceCard(SimilarService service, ServiceDetailController controller, ThemeData theme) {
  final colorScheme = theme.colorScheme;
  
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      onTap: () => controller.navigateToSimilarService(service.id),
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(32),
        bottomLeft: const Radius.circular(8),
        bottomRight: const Radius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(8),
            topRight: const Radius.circular(32),
            bottomLeft: const Radius.circular(8),
            bottomRight: const Radius.circular(8),
          ),
        ),
        child: Row(
          children: [
            // 提供商头像
            CircleAvatar(
              backgroundImage: NetworkImage(service.providerAvatar),
              radius: 24,
            ),
            const SizedBox(width: 12),
            
            // 服务信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.providerName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    service.serviceTitle,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        '${service.rating} (${service.reviewCount})',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${service.price}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 相似度标签
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(4),
                  topRight: const Radius.circular(16),
                  bottomLeft: const Radius.circular(4),
                  bottomRight: const Radius.circular(4),
                ),
              ),
              child: Text(
                '${(service.similarityScore * 100).toInt()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
```

#### **C. 相似服务列表页面**
```dart
class SimilarServicesPage extends StatelessWidget {
  final String currentServiceId;
  final String categoryId;
  
  const SimilarServicesPage({
    super.key,
    required this.currentServiceId,
    required this.categoryId,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Similar Services'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Column(
        children: [
          // 筛选器
          _buildFilters(),
          // 服务列表
          Expanded(
            child: _buildServicesList(),
          ),
        ],
      ),
    );
  }
}
``` 

## 📋 **功能范围说明**

### **1. Contact（联系）功能范围**

#### **1.1 主要功能**
- **实时聊天**：与服务提供者进行实时消息交流
- **电话联系**：直接拨打电话给服务提供者
- **邮件联系**：发送邮件给服务提供者
- **查看联系信息**：显示服务提供者的完整联系信息

#### **1.2 功能入口**
- **Hero区域**：快速聊天按钮
- **底部操作栏**：Contact按钮
- **联系选项弹窗**：多种联系方式选择

#### **1.3 交互流程**
1. 用户点击Contact按钮
2. 显示联系选项弹窗
3. 用户选择联系方式（聊天/电话/邮件/查看信息）
4. 执行相应的联系操作

### **2. Book Now（立即预订）功能范围**

#### **2.1 主要功能**
- **直接预订**：对于固定价格服务，直接进入预订流程
- **时间选择**：选择服务日期和时间
- **可用性检查**：查看服务提供者的可用时间
- **支付流程**：完成预订支付
- **预订确认**：确认预订信息

#### **2.2 功能入口**
- **Hero区域**：Book Now按钮（固定价格服务）
- **底部操作栏**：Book Now按钮（固定价格服务）
- **预订选项弹窗**：多种预订方式选择

#### **2.3 交互流程**
1. 用户点击Book Now按钮
2. 显示预订选项弹窗
3. 用户选择预订方式（立即预订/查看可用时间/联系提供者）
4. 执行相应的预订操作

### **3. Get Quote（获取报价）功能范围**

#### **3.1 主要功能**
- **快速报价**：简单描述需求，获取快速估算
- **详细报价**：填写详细表单，获取准确报价
- **报价管理**：查看、接受、拒绝报价
- **报价状态跟踪**：跟踪报价请求状态

#### **3.2 功能入口**
- **Hero区域**：Get Quote按钮（需要报价的服务）
- **底部操作栏**：Get Quote按钮（需要报价的服务）
- **Overview Tab**：报价请求卡片
- **联系选项**：报价请求选项

#### **3.3 交互流程**
1. 用户点击Get Quote按钮
2. 显示报价选项弹窗（快速报价/详细报价/先聊天）
3. 用户选择报价方式
4. 填写报价表单
5. 提交报价请求
6. 跟踪报价状态

### **4. 功能区分原则**

#### **4.1 服务类型判断**
- **固定价格服务**：显示Book Now按钮
- **自定义价格服务**：显示Get Quote按钮
- **可协商价格服务**：显示Get Quote按钮

#### **4.2 用户意图区分**
- **Contact**：用户想要联系提供者，了解详情或讨论
- **Book Now**：用户确定要预订服务，直接进入预订流程
- **Get Quote**：用户需要了解具体价格，提交报价请求

#### **4.3 功能优先级**
1. **主要操作**：根据服务类型显示Book Now或Get Quote
2. **辅助操作**：Contact作为通用的联系入口
3. **详细信息**：在Overview Tab中提供完整的报价表单

### **5. 用户体验优化**

#### **5.1 入口优化**
- **Hero区域**：突出显示主要操作按钮
- **底部操作栏**：提供快速访问
- **Tab内容**：提供详细信息和支持功能

#### **5.2 流程优化**
- **快速路径**：一键进入主要功能
- **详细路径**：提供完整的表单和选项
- **灵活选择**：用户可以根据需要选择不同的操作方式

#### **5.3 反馈机制**
- **状态提示**：显示操作进度和结果
- **错误处理**：友好的错误提示和恢复建议
- **成功确认**：明确的操作成功反馈 