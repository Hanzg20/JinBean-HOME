# ServiceDetailPage 模块化结构设计

## 📁 文件结构

```
lib/features/customer/services/presentation/
├── service_detail_page.dart                    # 主页面文件 (核心逻辑)
├── widgets/                                    # 固定组件目录
│   ├── service_detail_hero_section.dart        # 头部图片区域
│   ├── service_detail_tab_bar.dart             # 标签栏组件
│   ├── service_detail_app_bar.dart             # 应用栏组件
│   ├── service_detail_card.dart                # 通用卡片组件
│   └── service_detail_loading.dart             # 加载状态组件
├── sections/                                   # 页面区块目录
│   ├── service_basic_info_section.dart         # 服务基本信息
│   ├── service_map_section.dart                # 地图相关区块
│   ├── service_actions_section.dart            # 操作按钮区块
│   ├── service_reviews_section.dart            # 评价区块
│   ├── service_provider_section.dart           # 提供商信息区块
│   └── service_personalized_section.dart       # 个性化推荐区块
├── dialogs/                                    # 对话框目录
│   ├── service_booking_dialog.dart             # 预订对话框
│   ├── service_quote_dialog.dart               # 报价对话框
│   └── service_contact_dialog.dart             # 联系对话框
├── utils/                                      # 工具类目录
│   ├── service_detail_formatters.dart          # 格式化工具
│   ├── service_detail_validators.dart          # 验证工具
│   └── service_detail_constants.dart           # 常量定义
└── models/                                     # 数据模型目录
    ├── service_detail_state.dart               # 页面状态模型
    └── service_detail_events.dart              # 事件模型
```

## 🔧 模块化拆分策略

### **1. 主页面文件 (service_detail_page.dart)**
**职责**: 页面整体结构、状态管理、路由控制
**内容**:
- 页面主类定义
- TabController 管理
- 整体布局结构
- 状态管理逻辑

**特点**: 
- 文件大小: ~200-300行
- 变化频率: 低
- 主要关注: 页面结构和状态管理

### **2. 固定组件 (widgets/)**
**职责**: 可复用的UI组件
**内容**:
- 头部图片区域
- 标签栏组件
- 应用栏组件
- 通用卡片组件

**特点**:
- 文件大小: 每个 ~100-150行
- 变化频率: 很低
- 主要关注: UI展示和交互

### **3. 页面区块 (sections/)**
**职责**: 功能完整的页面区块
**内容**:
- 服务基本信息区块
- 地图相关区块
- 操作按钮区块
- 评价区块
- 提供商信息区块

**特点**:
- 文件大小: 每个 ~200-400行
- 变化频率: 中等
- 主要关注: 业务逻辑和UI展示

### **4. 对话框 (dialogs/)**
**职责**: 各种弹窗和对话框
**内容**:
- 预订对话框
- 报价对话框
- 联系对话框

**特点**:
- 文件大小: 每个 ~150-250行
- 变化频率: 高
- 主要关注: 用户交互和表单处理

### **5. 工具类 (utils/)**
**职责**: 通用工具函数
**内容**:
- 格式化工具
- 验证工具
- 常量定义

**特点**:
- 文件大小: 每个 ~50-100行
- 变化频率: 很低
- 主要关注: 数据处理和验证

### **6. 数据模型 (models/)**
**职责**: 数据结构和事件定义
**内容**:
- 页面状态模型
- 事件模型

**特点**:
- 文件大小: 每个 ~50-100行
- 变化频率: 低
- 主要关注: 数据结构定义

## 📊 拆分优势

### **1. 维护性提升**
- **单一职责**: 每个文件专注特定功能
- **易于定位**: 问题快速定位到具体文件
- **并行开发**: 不同开发者可同时修改不同模块

### **2. 代码复用**
- **组件复用**: widgets 可在其他页面复用
- **工具复用**: utils 可在整个项目复用
- **模型复用**: models 可在相关页面复用

### **3. 测试友好**
- **单元测试**: 每个模块可独立测试
- **集成测试**: 模块间接口清晰
- **Mock测试**: 依赖关系明确

### **4. 性能优化**
- **按需加载**: 只加载需要的模块
- **缓存优化**: 固定组件可缓存
- **编译优化**: 增量编译更快

## 🚀 实施步骤

### **阶段1: 基础拆分**
1. 创建目录结构
2. 提取固定组件 (widgets/)
3. 提取工具类 (utils/)
4. 提取数据模型 (models/)

### **阶段2: 功能拆分**
1. 拆分页面区块 (sections/)
2. 拆分对话框 (dialogs/)
3. 重构主页面文件

### **阶段3: 优化完善**
1. 添加类型安全
2. 优化导入结构
3. 添加文档注释
4. 完善错误处理

## 📝 注意事项

### **1. 导入管理**
```dart
// 主页面文件导入
import 'widgets/service_detail_hero_section.dart';
import 'sections/service_basic_info_section.dart';
import 'dialogs/service_booking_dialog.dart';
import 'utils/service_detail_formatters.dart';
import 'models/service_detail_state.dart';
```

### **2. 状态管理**
```dart
// 使用 GetX 进行状态管理
class ServiceDetailState {
  final Rx<Service?> service = Rx<Service?>(null);
  final Rx<ServiceDetail?> serviceDetail = Rx<ServiceDetail?>(null);
  final RxBool isLoading = false.obs;
  // ...
}
```

### **3. 事件处理**
```dart
// 定义事件类型
abstract class ServiceDetailEvent {}

class LoadServiceDetail extends ServiceDetailEvent {
  final String serviceId;
  LoadServiceDetail(this.serviceId);
}

class BookService extends ServiceDetailEvent {
  final BookingDetails details;
  BookService(this.details);
}
```

### **4. 错误处理**
```dart
// 统一错误处理
class ServiceDetailError extends Error {
  final String message;
  final String? code;
  ServiceDetailError(this.message, {this.code});
}
```

## 📈 预期效果

### **文件大小优化**
- 主文件: 从 5000+ 行减少到 300 行
- 模块文件: 每个 100-400 行
- 总文件数: 从 1 个增加到 15+ 个

### **开发效率提升**
- 代码定位: 从分钟级减少到秒级
- 修改影响: 从全局影响减少到模块影响
- 并行开发: 支持多人同时开发

### **维护成本降低**
- 问题定位: 快速定位到具体模块
- 功能修改: 只修改相关模块
- 测试覆盖: 模块级测试更精确 