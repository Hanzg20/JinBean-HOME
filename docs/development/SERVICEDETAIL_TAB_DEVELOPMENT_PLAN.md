# ServiceDetail Dynamic Tab 开发计划

> **版本**: v1.0
> **日期**: 2025-12-28
> **状态**: 规划中

---

## 📊 **当前实施状态总结**

### ✅ **已完成部分**

#### 1. **架构设计完成** (100%)
- ✅ Tab配置工厂模式实现完成
- ✅ 动态Tab替换策略完成
- ✅ 行业识别逻辑完成
- ✅ 5个基础Tab页实现完成
  - Overview (概览)
  - Provider (服务商)
  - Reviews (评价)
  - Recommendations (推荐)
  - Details/Industry-Specific (详情/行业特定)

#### 2. **行业特定Tab页UI框架完成** (100%)
所有6个服务类别的Tab页UI框架已创建:

| 类别ID | 行业名称 | Tab名称 | UI状态 | 数据集成 | 代码位置 |
|--------|---------|---------|--------|---------|---------|
| 1010000 | 餐饮服务 | Menu | ✅ 完成 | ⚠️ 占位数据 | line 973-1013 |
| 1020000 | 家政服务 | Services | ✅ 完成 | ❌ 占位数据 | line 1016-1056 |
| 1030000 | 交通出行 | Details | ✅ 完成 | ⚠️ 通用数据 | line 258-356 |
| 1040000 | 共享租赁 | Inventory | ✅ 完成 | ❌ 占位数据 | line 1059-1099 |
| 1050000 | 教育培训 | Courses | ✅ 完成 | ❌ 占位数据 | line 1102-1142 |
| 1060000 | 生活帮忙 | Treatments | ✅ 完成 | ❌ 占位数据 | line 1145-1184 |

#### 3. **Tab工厂配置完成** (100%)
- ✅ `TabConfigurationFactory.generateTabsForService()` 实现完成
- ✅ `_getIndustrySpecificTab()` 所有6个类别配置完成
- ✅ Tab图标、标签、builder映射完成

---

## ⚠️ **当前问题和不足**

### 1. **数据集成问题** (Critical - P0)

#### 问题描述:
所有行业特定Tab页使用硬编码的占位数据，未连接真实数据源。

**示例 - Menu Tab当前实现:**
```dart
static Widget _buildMenuTab(BuildContext context, dynamic service) {
  return SingleChildScrollView(
    child: Column(
      children: [
        // ❌ 硬编码占位数据
        _buildMenuItem(context, 'Appetizer', 'Fresh Spring Rolls', 'CAD 8.99'),
        _buildMenuItem(context, 'Main Course', 'Beef Noodle Soup', 'CAD 15.99'),
        _buildMenuItem(context, 'Dessert', 'Mango Sticky Rice', 'CAD 6.99'),
      ],
    ),
  );
}
```

**应该的实现:**
```dart
static Widget _buildMenuTab(BuildContext context, dynamic service) {
  final controller = Get.find<ServiceDetailController>();

  return Obx(() {
    final menuItems = controller.menuItems;  // ✅ 从controller获取真实数据
    final isLoading = controller.isLoadingMenuItems.value;

    if (isLoading) {
      return CircularProgressIndicator();
    }

    return ListView.builder(
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuItem(
          context,
          item.category,
          item.getLocalizedName('en'),
          'CAD ${item.price.toStringAsFixed(2)}',
        );
      },
    );
  });
}
```

#### 影响范围:
- 🔴 Menu Tab (Food - 1010000)
- 🔴 Services Tab (Home Services - 1020000)
- 🔴 Inventory Tab (Rental - 1040000)
- 🔴 Courses Tab (Education - 1050000)
- 🔴 Treatments Tab (Life Help - 1060000)

---

### 2. **缺少数据加载逻辑** (P0)

#### Controller缺少的方法:
- ❌ `loadMenuItems(String serviceId)` - 加载菜单项
- ❌ `loadServicePackages(String serviceId)` - 加载服务套餐
- ❌ `loadInventoryItems(String serviceId)` - 加载库存项
- ❌ `loadCourses(String serviceId)` - 加载课程
- ❌ `loadTreatments(String serviceId)` - 加载治疗项目

#### 需要添加的响应式状态:
```dart
class ServiceDetailController extends GetxController {
  // 菜单项 (for Food)
  final RxList<ServiceDetail> menuItems = <ServiceDetail>[].obs;
  final RxBool isLoadingMenuItems = false.obs;

  // 服务套餐 (for Home Services)
  final RxList<ServiceDetail> servicePackages = <ServiceDetail>[].obs;
  final RxBool isLoadingServicePackages = false.obs;

  // 库存项 (for Rental)
  final RxList<ServiceDetail> inventoryItems = <ServiceDetail>[].obs;
  final RxBool isLoadingInventoryItems = false.obs;

  // 课程 (for Education)
  final RxList<ServiceDetail> courses = <ServiceDetail>[].obs;
  final RxBool isLoadingCourses = false.obs;

  // 治疗项目 (for Life Help)
  final RxList<ServiceDetail> treatments = <ServiceDetail>[].obs;
  final RxBool isLoadingTreatments = false.obs;
}
```

---

### 3. **缺少数据库测试数据** (P1)

#### 当前数据库状态:
- ✅ `service_details` 表结构已重构（支持子服务）
- ❌ 缺少各类别的测试数据
- ❌ 未创建示例菜单项、服务套餐、课程等

#### 需要的测试数据SQL:
```sql
-- 1. 餐饮服务 - 菜单项
INSERT INTO service_details (service_id, category, sub_category, name, price, ...)
VALUES
  ('service-food-001', 'menu_item', 'appetizer', '{"en": "Spring Rolls", "zh": "春卷"}', 8.99, ...),
  ('service-food-001', 'menu_item', 'main_course', '{"en": "Beef Noodle", "zh": "牛肉面"}', 15.99, ...);

-- 2. 家政服务 - 服务套餐
INSERT INTO service_details (service_id, category, sub_category, name, price, ...)
VALUES
  ('service-cleaning-001', 'service_package', 'deep_cleaning', '{"en": "Deep Cleaning", "zh": "深度清洁"}', 120.00, ...);

-- 3. 租赁服务 - 库存项
INSERT INTO service_details (service_id, category, sub_category, name, price, current_stock, max_stock, ...)
VALUES
  ('service-rental-001', 'rental_item', 'tools', '{"en": "Power Drill", "zh": "电钻"}', 25.00, 5, 10, ...);

-- 4. 教育培训 - 课程
INSERT INTO service_details (service_id, category, sub_category, name, price, ...)
VALUES
  ('service-education-001', 'course', 'beginner', '{"en": "Basic English", "zh": "基础英语"}', 200.00, ...);

-- 5. 生活帮忙 - 治疗项目
INSERT INTO service_details (service_id, category, sub_category, name, price, ...)
VALUES
  ('service-health-001', 'treatment', 'consultation', '{"en": "Consultation", "zh": "咨询"}', 80.00, ...);
```

---

### 4. **缺少交互功能** (P2)

#### Menu Tab缺少的功能:
- ❌ 添加到购物车按钮
- ❌ 菜品选项配置 (辣度、份量等)
- ❌ 菜品详情弹窗
- ❌ 菜品搜索/筛选

#### Services Tab缺少的功能:
- ❌ 立即预订按钮
- ❌ 服务时长选择
- ❌ 服务区域检查
- ❌ 价格计算器

#### Inventory Tab缺少的功能:
- ❌ 库存可用性日历
- ❌ 租赁时长选择
- ❌ 押金显示
- ❌ 预订按钮

#### Courses Tab缺少的功能:
- ❌ 课程详情展开
- ❌ 课程时间表
- ❌ 报名按钮
- ❌ 学习进度显示

#### Treatments Tab缺少的功能:
- ❌ 预约时间选择
- ❌ 医师资质展示
- ❌ 治疗说明
- ❌ 预约按钮

---

## 🎯 **开发优先级和阶段规划**

### **阶段一: 数据集成 (2周) - P0**

#### 目标:
将所有行业特定Tab页连接到真实数据源

#### 任务清单:

**Week 1: Controller和API层开发**

1. **扩展 ServiceDetailController** (3天)
   - [ ] 添加menuItems响应式列表和加载状态
   - [ ] 添加servicePackages响应式列表和加载状态
   - [ ] 添加inventoryItems响应式列表和加载状态
   - [ ] 添加courses响应式列表和加载状态
   - [ ] 添加treatments响应式列表和加载状态
   - [ ] 实现`loadMenuItems(String serviceId)`方法
   - [ ] 实现`loadServicePackages(String serviceId)`方法
   - [ ] 实现`loadInventoryItems(String serviceId)`方法
   - [ ] 实现`loadCourses(String serviceId)`方法
   - [ ] 实现`loadTreatments(String serviceId)`方法

2. **扩展 ServiceDetailApiService** (2天)
   - [ ] 添加`fetchServiceDetails(serviceId, category)`通用方法
   - [ ] 添加错误处理和重试逻辑
   - [ ] 添加缓存策略
   - [ ] 测试API调用

**Week 2: UI集成和测试数据**

3. **重构Tab Builder方法** (3天)
   - [ ] 重构`_buildMenuTab` - 使用Obx连接真实数据
   - [ ] 重构`_buildServicesTab` - 使用Obx连接真实数据
   - [ ] 重构`_buildInventoryTab` - 使用Obx连接真实数据
   - [ ] 重构`_buildCoursesTab` - 使用Obx连接真实数据
   - [ ] 重构`_buildTreatmentsTab` - 使用Obx连接真实数据
   - [ ] 添加loading状态显示
   - [ ] 添加空数据状态显示
   - [ ] 添加错误状态显示

4. **创建测试数据** (2天)
   - [ ] 创建SQL脚本: `service_details_test_data.sql`
   - [ ] 为Food服务创建10个菜单项
   - [ ] 为Home Services创建5个服务套餐
   - [ ] 为Rental创建8个库存项
   - [ ] 为Education创建6个课程
   - [ ] 为Life Help创建5个治疗项目
   - [ ] 在Supabase中执行SQL
   - [ ] 验证数据正确性

**交付物:**
- ✅ ServiceDetailController扩展完成
- ✅ API层实现完成
- ✅ 所有Tab页连接真实数据
- ✅ 测试数据创建完成
- ✅ 基础数据展示功能可用

**验收标准:**
- [ ] 打开任何服务详情页，能看到真实的子服务数据
- [ ] Loading状态正常显示
- [ ] 错误处理正常工作
- [ ] 无hardcoded占位数据

---

### **阶段二: 交互功能开发 (3周) - P1**

#### 目标:
为每个Tab页添加核心交互功能

#### 任务清单:

**Week 3: Menu Tab和Services Tab**

1. **Menu Tab增强** (3天)
   - [ ] 实现"添加到购物车"按钮
   - [ ] 实现菜品选项配置弹窗 (辣度、份量、备注)
   - [ ] 集成UnifiedCartController
   - [ ] 实现菜品详情模态框
   - [ ] 添加菜品图片轮播
   - [ ] 实现分类筛选 (appetizer, main, dessert)
   - [ ] 测试购物车集成

2. **Services Tab增强** (4天)
   - [ ] 实现"立即预订"按钮
   - [ ] 实现"添加到购物车"按钮
   - [ ] 实现服务时长选择器
   - [ ] 实现服务区域验证
   - [ ] 实现动态价格计算
   - [ ] 添加服务详情展开/收起
   - [ ] 测试预约流程

**Week 4: Inventory Tab和Courses Tab**

3. **Inventory Tab增强** (3天)
   - [ ] 实现库存可用性日历组件
   - [ ] 实现租赁时长选择 (小时/天/周)
   - [ ] 实现价格自动计算
   - [ ] 显示押金和规则说明
   - [ ] 实现"立即租赁"按钮
   - [ ] 添加库存状态指示器
   - [ ] 测试租赁流程

4. **Courses Tab增强** (4天)
   - [ ] 实现课程详情可展开列表
   - [ ] 实现课程时间表显示
   - [ ] 实现"立即报名"按钮
   - [ ] 添加学习进度展示 (未来功能)
   - [ ] 实现课程分类筛选
   - [ ] 添加难度级别标签
   - [ ] 测试报名流程

**Week 5: Treatments Tab和优化**

5. **Treatments Tab增强** (3天)
   - [ ] 实现预约时间选择器
   - [ ] 显示医师/技师资质信息
   - [ ] 实现治疗说明模态框
   - [ ] 实现"预约"按钮
   - [ ] 添加治疗前后注意事项
   - [ ] 测试预约流程

6. **通用优化** (4天)
   - [ ] 统一所有Tab的loading状态样式
   - [ ] 统一所有Tab的空数据样式
   - [ ] 统一所有Tab的错误状态样式
   - [ ] 添加下拉刷新功能
   - [ ] 添加上拉加载更多
   - [ ] 性能优化 - 图片懒加载
   - [ ] 性能优化 - Tab切换动画优化

**交付物:**
- ✅ 5个行业Tab页核心交互功能完成
- ✅ 购物车集成完成
- ✅ 预约流程集成完成
- ✅ 性能优化完成

**验收标准:**
- [ ] 用户可以从Menu Tab添加菜品到购物车
- [ ] 用户可以从Services Tab预订服务
- [ ] 用户可以查看Inventory库存并选择租赁时长
- [ ] 用户可以报名课程
- [ ] 用户可以预约治疗

---

### **阶段三: 高级功能和完善 (2周) - P2**

#### 目标:
添加高级功能，提升用户体验

#### 任务清单:

**Week 6: 搜索、筛选、排序**

1. **全局搜索功能** (3天)
   - [ ] 为每个Tab添加搜索框
   - [ ] 实现实时搜索过滤
   - [ ] 实现搜索历史记录
   - [ ] 实现搜索建议
   - [ ] 优化搜索性能

2. **筛选功能** (2天)
   - [ ] Menu: 按分类、价格区间、营养标签筛选
   - [ ] Services: 按服务时长、价格、服务区域筛选
   - [ ] Inventory: 按可用性、价格筛选
   - [ ] Courses: 按难度、价格、时长筛选
   - [ ] Treatments: 按价格、时长筛选

3. **排序功能** (2天)
   - [ ] 按价格排序 (升序/降序)
   - [ ] 按评分排序
   - [ ] 按受欢迎程度排序
   - [ ] 按最新添加排序

**Week 7: 数据持久化和国际化**

4. **数据持久化** (2天)
   - [ ] 实现Tab数据缓存 (Get Storage)
   - [ ] 实现离线数据展示
   - [ ] 实现智能预加载
   - [ ] 实现缓存过期策略

5. **国际化完善** (2天)
   - [ ] 更新app_en.arb - 添加所有Tab页翻译
   - [ ] 更新app_zh.arb - 添加所有Tab页翻译
   - [ ] 测试中英文切换
   - [ ] 测试文本显示正确性

6. **用户体验优化** (3天)
   - [ ] 添加骨架屏loading效果
   - [ ] 添加微交互动画
   - [ ] 优化图片加载体验
   - [ ] 添加触觉反馈
   - [ ] 优化错误提示文案

**交付物:**
- ✅ 搜索、筛选、排序功能完成
- ✅ 数据持久化完成
- ✅ 国际化完善
- ✅ UX优化完成

**验收标准:**
- [ ] 用户可以搜索、筛选、排序所有Tab内容
- [ ] 离线也能查看已缓存的数据
- [ ] 中英文切换无问题
- [ ] 动画流畅自然

---

### **阶段四: 测试和发布 (1周) - P3**

#### 目标:
全面测试，修复bug，准备发布

#### 任务清单:

**Week 8: 测试和发布**

1. **单元测试** (2天)
   - [ ] 为ServiceDetailController编写单元测试
   - [ ] 为TabConfigurationFactory编写单元测试
   - [ ] 为API层编写单元测试
   - [ ] 测试覆盖率 > 80%

2. **集成测试** (2天)
   - [ ] 测试所有6个类别的服务详情页
   - [ ] 测试Tab切换流程
   - [ ] 测试购物车集成
   - [ ] 测试预约流程
   - [ ] 测试数据加载和缓存
   - [ ] 测试错误处理

3. **UI/UX测试** (1天)
   - [ ] iOS真机测试 (iPhone 13, 14, 15)
   - [ ] Android真机测试
   - [ ] 不同屏幕尺寸测试
   - [ ] 暗黑模式测试
   - [ ] 无障碍功能测试

4. **性能测试** (1天)
   - [ ] Tab切换性能测试 (目标 < 300ms)
   - [ ] 数据加载性能测试 (目标 < 2s)
   - [ ] 内存使用测试 (目标 < 50MB)
   - [ ] 网络请求优化
   - [ ] 图片加载优化

5. **Bug修复和文档** (1天)
   - [ ] 修复测试中发现的所有P0 bug
   - [ ] 修复测试中发现的P1 bug
   - [ ] 更新技术文档
   - [ ] 创建用户指南
   - [ ] 准备发布说明

**交付物:**
- ✅ 完整测试报告
- ✅ 所有P0/P1 bug修复完成
- ✅ 技术文档更新
- ✅ 准备生产发布

**验收标准:**
- [ ] 测试覆盖率 > 80%
- [ ] 所有P0 bug已修复
- [ ] 性能指标达标
- [ ] 文档完整

---

## 📂 **技术实施细节**

### 1. **Controller扩展示例**

**文件**: `lib/features/customer/services/presentation/service_detail_controller.dart`

```dart
class ServiceDetailController extends GetxController {
  // ... 现有代码 ...

  // ========== 新增: 行业特定数据 ==========

  // 菜单项 (Food - 1010000)
  final RxList<ServiceDetail> menuItems = <ServiceDetail>[].obs;
  final RxBool isLoadingMenuItems = false.obs;

  // 服务套餐 (Home Services - 1020000)
  final RxList<ServiceDetail> servicePackages = <ServiceDetail>[].obs;
  final RxBool isLoadingServicePackages = false.obs;

  // 库存项 (Rental - 1040000)
  final RxList<ServiceDetail> inventoryItems = <ServiceDetail>[].obs;
  final RxBool isLoadingInventoryItems = false.obs;

  // 课程 (Education - 1050000)
  final RxList<ServiceDetail> courses = <ServiceDetail>[].obs;
  final RxBool isLoadingCourses = false.obs;

  // 治疗项目 (Life Help - 1060000)
  final RxList<ServiceDetail> treatments = <ServiceDetail>[].obs;
  final RxBool isLoadingTreatments = false.obs;

  // ========== 数据加载方法 ==========

  /// 加载菜单项 (Food)
  Future<void> loadMenuItems(String serviceId) async {
    try {
      isLoadingMenuItems.value = true;
      AppLogger.info('[Controller] 开始加载菜单项 - Service ID: $serviceId');

      final items = await _apiService.fetchServiceDetails(
        serviceId: serviceId,
        category: 'menu_item',
      );

      menuItems.value = items;
      AppLogger.info('[Controller] 菜单项加载成功 - 数量: ${items.length}');
    } catch (e) {
      AppLogger.error('[Controller] 菜单项加载失败: $e');
      Get.snackbar('Error', 'Failed to load menu items');
    } finally {
      isLoadingMenuItems.value = false;
    }
  }

  /// 加载服务套餐 (Home Services)
  Future<void> loadServicePackages(String serviceId) async {
    try {
      isLoadingServicePackages.value = true;
      AppLogger.info('[Controller] 开始加载服务套餐 - Service ID: $serviceId');

      final packages = await _apiService.fetchServiceDetails(
        serviceId: serviceId,
        category: 'service_package',
      );

      servicePackages.value = packages;
      AppLogger.info('[Controller] 服务套餐加载成功 - 数量: ${packages.length}');
    } catch (e) {
      AppLogger.error('[Controller] 服务套餐加载失败: $e');
      Get.snackbar('Error', 'Failed to load service packages');
    } finally {
      isLoadingServicePackages.value = false;
    }
  }

  /// 加载库存项 (Rental)
  Future<void> loadInventoryItems(String serviceId) async {
    try {
      isLoadingInventoryItems.value = true;
      AppLogger.info('[Controller] 开始加载库存项 - Service ID: $serviceId');

      final items = await _apiService.fetchServiceDetails(
        serviceId: serviceId,
        category: 'rental_item',
      );

      inventoryItems.value = items;
      AppLogger.info('[Controller] 库存项加载成功 - 数量: ${items.length}');
    } catch (e) {
      AppLogger.error('[Controller] 库存项加载失败: $e');
      Get.snackbar('Error', 'Failed to load inventory items');
    } finally {
      isLoadingInventoryItems.value = false;
    }
  }

  /// 加载课程 (Education)
  Future<void> loadCourses(String serviceId) async {
    try {
      isLoadingCourses.value = true;
      AppLogger.info('[Controller] 开始加载课程 - Service ID: $serviceId');

      final items = await _apiService.fetchServiceDetails(
        serviceId: serviceId,
        category: 'course',
      );

      courses.value = items;
      AppLogger.info('[Controller] 课程加载成功 - 数量: ${items.length}');
    } catch (e) {
      AppLogger.error('[Controller] 课程加载失败: $e');
      Get.snackbar('Error', 'Failed to load courses');
    } finally {
      isLoadingCourses.value = false;
    }
  }

  /// 加载治疗项目 (Life Help)
  Future<void> loadTreatments(String serviceId) async {
    try {
      isLoadingTreatments.value = true;
      AppLogger.info('[Controller] 开始加载治疗项目 - Service ID: $serviceId');

      final items = await _apiService.fetchServiceDetails(
        serviceId: serviceId,
        category: 'treatment',
      );

      treatments.value = items;
      AppLogger.info('[Controller] 治疗项目加载成功 - 数量: ${items.length}');
    } catch (e) {
      AppLogger.error('[Controller] 治疗项目加载失败: $e');
      Get.snackbar('Error', 'Failed to load treatments');
    } finally {
      isLoadingTreatments.value = false;
    }
  }
}
```

---

### 2. **API Service扩展示例**

**文件**: `lib/features/customer/services/services/service_detail_api_service.dart`

```dart
class ServiceDetailApiService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 通用方法: 获取服务详情（支持category筛选）
  Future<List<ServiceDetail>> fetchServiceDetails({
    required String serviceId,
    required String category,
  }) async {
    try {
      AppLogger.info('[API] 获取服务详情 - Service ID: $serviceId, Category: $category');

      final response = await _supabase
          .from('service_details')
          .select()
          .eq('service_id', serviceId)
          .eq('category', category)
          .eq('is_available', true)
          .order('sort_order', ascending: true);

      if (response == null) {
        AppLogger.warning('[API] 未找到服务详情数据');
        return [];
      }

      final List<ServiceDetail> items = (response as List)
          .map((json) => ServiceDetail.fromJson(json))
          .toList();

      AppLogger.info('[API] 服务详情获取成功 - 数量: ${items.length}');
      return items;

    } catch (e) {
      AppLogger.error('[API] 服务详情获取失败: $e');
      rethrow;
    }
  }
}
```

---

### 3. **重构后的Menu Tab示例**

**文件**: `lib/features/customer/services/presentation/utils/tab_configuration_factory.dart`

```dart
static Widget _buildMenuTab(BuildContext context, dynamic service) {
  final controller = Get.find<ServiceDetailController>();

  // 初始加载
  if (service?.id != null &&
      controller.menuItems.isEmpty &&
      !controller.isLoadingMenuItems.value) {
    AppLogger.info('[MenuTab] 触发菜单项加载 - Service ID: ${service.id}');
    controller.loadMenuItems(service.id);
  }

  return Obx(() {
    final menuItems = controller.menuItems;
    final isLoading = controller.isLoadingMenuItems.value;

    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading menu...'),
          ],
        ),
      );
    }

    if (menuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No menu items available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.loadMenuItems(service.id),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restaurant Menu',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 按分类分组显示
          ...menuItems
              .groupBy((item) => item.subCategory ?? 'Other')
              .entries
              .map((entry) => _buildMenuCategory(
                    context,
                    entry.key,
                    entry.value,
                  )),
        ],
      ),
    );
  });
}

static Widget _buildMenuCategory(
  BuildContext context,
  String category,
  List<ServiceDetail> items,
) {
  return Card(
    elevation: 2,
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getCategoryDisplayName(category),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => _buildMenuItemCard(context, item)),
        ],
      ),
    ),
  );
}

static Widget _buildMenuItemCard(BuildContext context, ServiceDetail item) {
  final cartController = Get.find<UnifiedCartController>();

  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: Row(
      children: [
        // 图片
        if (item.mainImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.mainImage!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(width: 12),

        // 名称和描述
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.getLocalizedName('en'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (item.description != null)
                Text(
                  item.description!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),

        // 价格
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item.priceDisplay,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 4),

            // 添加到购物车按钮
            ElevatedButton(
              onPressed: () {
                cartController.addServiceToCart(
                  serviceId: item.serviceId,
                  serviceDetailId: item.id,
                  quantity: 1,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: const Text('Add', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    ),
  );
}

static String _getCategoryDisplayName(String category) {
  switch (category) {
    case 'appetizer':
      return 'Appetizers';
    case 'main_course':
      return 'Main Course';
    case 'dessert':
      return 'Desserts';
    case 'beverage':
      return 'Beverages';
    default:
      return category.toUpperCase();
  }
}
```

---

### 4. **测试数据SQL脚本示例**

**文件**: `docs/database/service_details_test_data.sql`

```sql
-- ================================================================
-- Service Details Test Data
-- 用于测试动态Tab页的服务详情数据
-- ================================================================

-- 前提: 先创建主服务记录
-- INSERT INTO services (id, title, category_level1_id, ...) VALUES ...

-- ================================================================
-- 1. 餐饮服务 (Category: 1010000) - Menu Items
-- ================================================================

-- 假设主服务ID: '550e8400-e29b-41d4-a716-446655440001'

INSERT INTO service_details (
  id,
  service_id,
  category,
  sub_category,
  name,
  price,
  currency,
  is_available,
  sort_order,
  images_url,
  attributes,
  created_at,
  updated_at
) VALUES
  -- Appetizers
  (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440001',
    'menu_item',
    'appetizer',
    '{"en": "Spring Rolls", "zh": "春卷"}',
    8.99,
    'CAD',
    true,
    1,
    ARRAY['https://example.com/spring-rolls.jpg'],
    '{"spicy_level": "mild", "vegetarian": true, "calories": 120}',
    NOW(),
    NOW()
  ),
  (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440001',
    'menu_item',
    'appetizer',
    '{"en": "Chicken Wings", "zh": "鸡翅"}',
    12.99,
    'CAD',
    true,
    2,
    ARRAY['https://example.com/chicken-wings.jpg'],
    '{"spicy_level": "hot", "vegetarian": false, "calories": 250}',
    NOW(),
    NOW()
  ),

  -- Main Course
  (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440001',
    'menu_item',
    'main_course',
    '{"en": "Beef Noodle Soup", "zh": "牛肉面"}',
    15.99,
    'CAD',
    true,
    3,
    ARRAY['https://example.com/beef-noodle.jpg'],
    '{"spicy_level": "medium", "vegetarian": false, "calories": 450}',
    NOW(),
    NOW()
  ),
  (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440001',
    'menu_item',
    'main_course',
    '{"en": "Vegetable Fried Rice", "zh": "蔬菜炒饭"}',
    13.99,
    'CAD',
    true,
    4,
    ARRAY['https://example.com/fried-rice.jpg'],
    '{"spicy_level": "mild", "vegetarian": true, "calories": 380}',
    NOW(),
    NOW()
  ),

  -- Desserts
  (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440001',
    'menu_item',
    'dessert',
    '{"en": "Mango Sticky Rice", "zh": "芒果糯米饭"}',
    6.99,
    'CAD',
    true,
    5,
    ARRAY['https://example.com/mango-rice.jpg'],
    '{"spicy_level": "none", "vegetarian": true, "calories": 220}',
    NOW(),
    NOW()
  );

-- ================================================================
-- 2. 家政服务 (Category: 1020000) - Service Packages
-- ================================================================

-- 假设主服务ID: '550e8400-e29b-41d4-a716-446655440002'

INSERT INTO service_details (
  id,
  service_id,
  category,
  sub_category,
  name,
  price,
  currency,
  duration,
  is_available,
  sort_order,
  attributes,
  business_rules,
  created_at,
  updated_at
) VALUES
  (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440002',
    'service_package',
    'deep_cleaning',
    '{"en": "Deep Cleaning", "zh": "深度清洁"}',
    120.00,
    'CAD',
    '3 hours',
    true,
    1,
    '{"includes": ["dusting", "mopping", "vacuuming", "bathroom"], "equipment": "provided"}',
    '{"min_notice_hours": 24, "cancellation_policy": "24h_free"}',
    NOW(),
    NOW()
  ),
  (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440002',
    'service_package',
    'regular_cleaning',
    '{"en": "Regular Cleaning", "zh": "常规清洁"}',
    80.00,
    'CAD',
    '2 hours',
    true,
    2,
    '{"includes": ["dusting", "mopping", "vacuuming"], "equipment": "provided"}',
    '{"min_notice_hours": 12, "cancellation_policy": "12h_free"}',
    NOW(),
    NOW()
  ),
  (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440002',
    'service_package',
    'window_cleaning',
    '{"en": "Window Cleaning", "zh": "擦窗服务"}',
    60.00,
    'CAD',
    '1.5 hours',
    true,
    3,
    '{"includes": ["interior_windows", "exterior_windows"], "equipment": "provided"}',
    '{"min_notice_hours": 24, "cancellation_policy": "24h_free"}',
    NOW(),
    NOW()
  );

-- ================================================================
-- 3. 共享租赁 (Category: 1040000) - Rental Items
-- ================================================================

-- 假设主服务ID: '550e8400-e29b-41d4-a716-446655440003'

INSERT INTO service_details (
  id,
  service_id,
  category,
  sub_category,
  name,
  price,
  currency,
  pricing_type,
  unit,
  current_stock,
  max_stock,
  is_available,
  sort_order,
  images_url,
  attributes,
  business_rules,
  created_at,
  updated_at
) VALUES
  (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440003',
    'rental_item',
    'tools',
    '{"en": "Power Drill", "zh": "电钻"}',
    25.00,
    'CAD',
    'hourly',
    'per day',
    5,
    10,
    true,
    1,
    ARRAY['https://example.com/power-drill.jpg'],
    '{"brand": "Bosch", "power": "18V", "condition": "excellent"}',
    '{"deposit": 50.00, "late_fee_per_hour": 5.00, "min_rental_hours": 4}',
    NOW(),
    NOW()
  ),
  (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440003',
    'rental_item',
    'tools',
    '{"en": "Ladder 6ft", "zh": "梯子6英尺"}',
    15.00,
    'CAD',
    'hourly',
    'per day',
    3,
    5,
    true,
    2,
    ARRAY['https://example.com/ladder.jpg'],
    '{"height": "6ft", "weight_capacity": "300lbs", "condition": "good"}',
    '{"deposit": 30.00, "late_fee_per_hour": 3.00, "min_rental_hours": 4}',
    NOW(),
    NOW()
  ),
  (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440003',
    'rental_item',
    'tools',
    '{"en": "Tool Set (40 pieces)", "zh": "工具套装（40件）"}',
    40.00,
    'CAD',
    'hourly',
    'per day',
    2,
    4,
    true,
    3,
    ARRAY['https://example.com/tool-set.jpg'],
    '{"pieces": 40, "includes": ["wrenches", "screwdrivers", "pliers"], "condition": "new"}',
    '{"deposit": 80.00, "late_fee_per_hour": 8.00, "min_rental_hours": 8}',
    NOW(),
    NOW()
  );

-- ================================================================
-- 4. 教育培训 (Category: 1050000) - Courses
-- ================================================================

-- 假设主服务ID: '550e8400-e29b-41d4-a716-446655440004'

INSERT INTO service_details (
  id,
  service_id,
  category,
  sub_category,
  name,
  price,
  currency,
  duration,
  is_available,
  sort_order,
  images_url,
  attributes,
  business_rules,
  created_at,
  updated_at
) VALUES
  (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440004',
    'course',
    'beginner',
    '{"en": "Basic English Conversation", "zh": "基础英语会话"}',
    200.00,
    'CAD',
    '8 weeks',
    true,
    1,
    ARRAY['https://example.com/english-basic.jpg'],
    '{"level": "beginner", "sessions": 16, "class_size": "max 10", "includes": "textbook"}',
    '{"refund_policy": "full_refund_before_2nd_class", "certificate": true}',
    NOW(),
    NOW()
  ),
  (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440004',
    'course',
    'intermediate',
    '{"en": "Intermediate Business English", "zh": "中级商务英语"}',
    350.00,
    'CAD',
    '10 weeks',
    true,
    2,
    ARRAY['https://example.com/english-intermediate.jpg'],
    '{"level": "intermediate", "sessions": 20, "class_size": "max 8", "includes": "textbook + workbook"}',
    '{"refund_policy": "50%_refund_before_3rd_class", "certificate": true}',
    NOW(),
    NOW()
  ),
  (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440004',
    'course',
    'advanced',
    '{"en": "Advanced English Literature", "zh": "高级英语文学"}',
    500.00,
    'CAD',
    '12 weeks',
    true,
    3,
    ARRAY['https://example.com/english-advanced.jpg'],
    '{"level": "advanced", "sessions": 24, "class_size": "max 6", "includes": "all materials"}',
    '{"refund_policy": "no_refund_after_1st_class", "certificate": true}',
    NOW(),
    NOW()
  );

-- ================================================================
-- 5. 生活帮忙 (Category: 1060000) - Treatments
-- ================================================================

-- 假设主服务ID: '550e8400-e29b-41d4-a716-446655440005'

INSERT INTO service_details (
  id,
  service_id,
  category,
  sub_category,
  name,
  price,
  currency,
  duration,
  is_available,
  sort_order,
  images_url,
  attributes,
  business_rules,
  created_at,
  updated_at
) VALUES
  (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440005',
    'treatment',
    'consultation',
    '{"en": "Initial Consultation", "zh": "初诊咨询"}',
    80.00,
    'CAD',
    '30 minutes',
    true,
    1,
    ARRAY['https://example.com/consultation.jpg'],
    '{"includes": ["health_assessment", "treatment_plan"], "practitioner": "licensed"}',
    '{"cancellation_policy": "24h_notice", "late_arrival": "15min_grace_period"}',
    NOW(),
    NOW()
  ),
  (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440005',
    'treatment',
    'therapy',
    '{"en": "Massage Therapy Session", "zh": "按摩理疗"}',
    120.00,
    'CAD',
    '60 minutes',
    true,
    2,
    ARRAY['https://example.com/massage.jpg'],
    '{"type": "deep_tissue", "includes": ["oils", "hot_towels"], "practitioner": "certified"}',
    '{"cancellation_policy": "24h_notice", "late_arrival": "session_shortened"}',
    NOW(),
    NOW()
  ),
  (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440005',
    'treatment',
    'followup',
    '{"en": "Follow-up Appointment", "zh": "复诊"}',
    60.00,
    'CAD',
    '20 minutes',
    true,
    3,
    ARRAY['https://example.com/followup.jpg'],
    '{"includes": ["progress_check", "treatment_adjustment"], "practitioner": "same_as_initial"}',
    '{"cancellation_policy": "12h_notice", "late_arrival": "10min_grace_period"}',
    NOW(),
    NOW()
  );

-- ================================================================
-- Verification Queries
-- ================================================================

-- 验证数据插入成功
SELECT
  category,
  sub_category,
  COUNT(*) as item_count
FROM service_details
WHERE service_id IN (
  '550e8400-e29b-41d4-a716-446655440001',
  '550e8400-e29b-41d4-a716-446655440002',
  '550e8400-e29b-41d4-a716-446655440003',
  '550e8400-e29b-41d4-a716-446655440004',
  '550e8400-e29b-41d4-a716-446655440005'
)
GROUP BY category, sub_category
ORDER BY category, sub_category;

-- 查看Menu Items
SELECT
  name->>'en' as name_en,
  name->>'zh' as name_zh,
  sub_category,
  price,
  currency
FROM service_details
WHERE category = 'menu_item'
ORDER BY sort_order;

-- ================================================================
-- Success Message
-- ================================================================

DO $$
BEGIN
  RAISE NOTICE '✅ Service Details测试数据创建成功！';
  RAISE NOTICE '📊 数据统计:';
  RAISE NOTICE '  - Menu Items (Food): 5条';
  RAISE NOTICE '  - Service Packages (Home Services): 3条';
  RAISE NOTICE '  - Rental Items (Rental): 3条';
  RAISE NOTICE '  - Courses (Education): 3条';
  RAISE NOTICE '  - Treatments (Life Help): 3条';
  RAISE NOTICE '📱 现在可以在App中测试动态Tab页了！';
END $$;
```

---

## 🔍 **测试计划**

### **阶段一测试 (数据集成)**
- [ ] 打开Food服务 → 验证Menu Tab显示真实菜单项
- [ ] 打开Home Services → 验证Services Tab显示真实服务套餐
- [ ] 打开Rental服务 → 验证Inventory Tab显示真实库存
- [ ] 打开Education服务 → 验证Courses Tab显示真实课程
- [ ] 打开Life Help服务 → 验证Treatments Tab显示真实治疗项目
- [ ] 测试Loading状态显示
- [ ] 测试空数据状态显示
- [ ] 测试错误状态显示

### **阶段二测试 (交互功能)**
- [ ] Menu Tab: 测试添加到购物车
- [ ] Services Tab: 测试立即预订
- [ ] Inventory Tab: 测试租赁时长选择
- [ ] Courses Tab: 测试报名流程
- [ ] Treatments Tab: 测试预约流程
- [ ] 测试价格计算正确性
- [ ] 测试购物车集成

### **阶段三测试 (高级功能)**
- [ ] 测试搜索功能
- [ ] 测试筛选功能
- [ ] 测试排序功能
- [ ] 测试数据缓存
- [ ] 测试离线模式
- [ ] 测试中英文切换

### **阶段四测试 (全面测试)**
- [ ] iOS真机测试
- [ ] Android真机测试
- [ ] 性能测试
- [ ] 压力测试
- [ ] 无障碍测试

---

## 📈 **成功指标**

### **技术指标**
- [ ] Tab切换速度 < 300ms
- [ ] 数据加载时间 < 2s
- [ ] 内存占用 < 50MB
- [ ] 代码测试覆盖率 > 80%
- [ ] 零P0 bug

### **业务指标**
- [ ] 用户可以查看所有6个类别的详细信息
- [ ] 用户可以从Tab页直接下单/预订
- [ ] 用户满意度调查评分 > 4.5/5
- [ ] Tab页点击率 > 60%

### **代码质量指标**
- [ ] 无hardcoded数据
- [ ] 所有Tab页连接真实数据源
- [ ] 完整的错误处理
- [ ] 完整的日志记录
- [ ] 国际化完整覆盖

---

## 📚 **相关文档**

- [Dynamic_Tab_Design.md](../ServiceDetail/Dynamic_Tab_Design.md) - 动态Tab设计方案
- [ServiceDetailPage_Design_Document.md](../ServiceDetail/ServiceDetailPage_Design_Document.md) - 页面整体设计
- [DATABASE_SETUP_GUIDE.md](../database/DATABASE_SETUP_GUIDE.md) - 数据库设置指南
- [tab_configuration_factory.dart](../../lib/features/customer/services/presentation/utils/tab_configuration_factory.dart) - Tab工厂实现

---

## 🎯 **下一步行动**

### **立即开始 (本周)**
1. ✅ 阅读并理解本开发计划
2. ⏳ 创建GitHub Issues跟踪每个任务
3. ⏳ 创建测试数据SQL脚本
4. ⏳ 开始扩展ServiceDetailController

### **本月目标**
- 完成阶段一: 数据集成 (2周)
- 开始阶段二: 交互功能开发 (2周)

### **下月目标**
- 完成阶段二: 交互功能开发
- 完成阶段三: 高级功能和完善
- 开始阶段四: 测试和发布

---

**最后更新**: 2025-12-28
**创建者**: AI Development Plan
**状态**: ✅ 计划完成，等待实施
