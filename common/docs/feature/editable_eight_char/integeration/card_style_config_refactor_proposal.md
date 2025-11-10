# CardStyleConfig 重构方案 - 原子化任务清单

**创建日期**: 2025-11-10
**状态**: 待审阅
**迁移周期**: 1-2 周（激进模式）
**依赖**: TextStyleConfig 重构完成后启动

---

## 📋 方案概述

### 核心问题
- **样式硬编码**：卡片容器的 border、radius、shadow、padding 等样式在 V3Card 中硬编码（如 `borderRadius: 16`）
- **无法编辑**：Sidebar 无法编辑卡片容器样式
- **扩展困难**：新增样式属性需要修改多处硬编码

### 解决方案
创建 `CardStyleConfig` 数据类，封装卡片容器的所有视觉样式：
- 边框：width, colorHex, style
- 背景：backgroundColorHex
- 圆角：borderRadius（统一）或 topLeft/topRight/bottomLeft/bottomRight（独立）
- 内边距：paddingTop/Bottom/Left/Right
- 阴影：shadowColorHex, offsetX/Y, blurRadius, spreadRadius
- 尺寸：width, height, min/max constraints（可选）

### 集成方案
```dart
// LayoutTemplate 新增字段
class LayoutTemplate {
  final CardStyle cardStyle;  // 保留（全局字体+分隔线）
  final CardStyleConfig? cardContainerStyle;  // 🆕 卡片容器样式
}

// ViewModel 新增方法
void updateCardContainerStyle(CardStyleConfig? config);

// V3Card 应用样式
Container(
  decoration: cardContainerStyle?.toBoxDecoration(),
  padding: cardContainerStyle?.padding,
  // ...
)
```

---

## ✅ 原子化 Todo List（40 项任务）

### Week 1 Day 1: CardStyleConfig 类创建（4 项）

**1. 创建 CardStyleConfig 类骨架**
- 文件：`lib/models/card_style_config.dart`
- 定义 24 个字段（border 3个, background 1个, radius 5个, padding 4个, shadow 5个, size 6个）
- 添加 `@JsonSerializable()` 注解
- 实现 copyWith, ==, hashCode
- **验收**：编译通过，包含所有字段

**2. 实现 CardStyleConfig 类型转换方法**
- 实现 `BoxDecoration toBoxDecoration()`
- 实现 `EdgeInsets? get padding`
- 实现 `BoxConstraints? get constraints`
- 实现私有方法：`_buildBorder()`, `_buildBorderRadius()`, `_buildShadows()`, `_parseColor()`
- **验收**：类型转换正确，null 处理得当

**3. 实现 CardStyleConfig 工厂方法**
- 实现 `factory CardStyleConfig.fromBoxDecoration(BoxDecoration)`
- 实现 `factory CardStyleConfig.fromLegacy({...})`（向后兼容）
- **验收**：双向转换一致

**4. 运行 build_runner 生成 JSON 序列化代码**
- 执行 `dart run build_runner build --delete-conflicting-outputs`
- 生成 `card_style_config.g.dart`
- **验收**：fromJson/toJson 可用，无编译错误

---

### Week 1 Day 2: CardStyleConfig 单元测试（4 项）

**5. 测试 toBoxDecoration 方法**
- 测试所有属性正确转换（border, radius, shadow, background）
- 测试 null 字段处理
- 测试边界值（0, 负数, 极大值）
- **验收**：测试通过，覆盖核心逻辑

**6. 测试 padding 和 constraints getters**
- 测试 padding 四向独立值
- 测试 padding 全 null 返回 null
- 测试 constraints 各种组合
- **验收**：测试通过

**7. 测试 JSON 序列化**
- 测试 toJson/fromJson 双向转换
- 测试 null 字段不写入 JSON
- 测试反序列化兼容性
- **验收**：JSON 往返一致

**8. 测试向后兼容和边界情况**
- 测试 fromLegacy 正确构造
- 测试无效颜色格式处理
- 测试负数/零值处理
- **验收**：覆盖率 >90%，所有测试通过

---

### Week 1 Day 3: LayoutTemplate 集成（3 项）

**9. 更新 LayoutTemplate 添加 cardContainerStyle 字段**
- 添加 `final CardStyleConfig? cardContainerStyle`
- 更新 copyWith, ==, hashCode
- **验收**：编译通过

**10. 更新 LayoutTemplate JSON 序列化**
- toJson 包含 cardContainerStyle
- fromJson 支持 cardContainerStyle（可选，向后兼容）
- **验收**：JSON 格式正确

**11. 编写 LayoutTemplate 集成测试**
- 测试旧 JSON 加载（无 cardContainerStyle）
- 测试新 JSON 加载（有 cardContainerStyle）
- 测试混合场景
- **验收**：3 种场景通过，向后兼容

---

### Week 1 Day 4: ViewModel 更新（3 项）

**12. 添加 updateCardContainerStyle 方法**
- 实现 `void updateCardContainerStyle(CardStyleConfig? config)`
- 添加 `CardStyleConfig? get cardContainerStyle` getter
- **验收**：方法功能正确

**13. 编写 ViewModel 单元测试**
- 测试 updateCardContainerStyle 更新模板
- 测试 hasUnsavedChanges 标记
- 测试 null 配置清除样式
- **验收**：测试通过

**14. 运行 ViewModel 回归测试**
- 运行 `flutter test test/viewmodels/`
- 确保无现有测试失败
- **验收**：所有测试通过

---

### Week 1 Day 5: Sidebar UI 开发（6 项）

**15. 创建 _CardContainerStyleSection 组件骨架**
- 创建可折叠区域
- 添加标题"卡片容器样式"
- **验收**：UI 显示正常

**16. 实现边框编辑 UI**
- 宽度输入框（TextField, 数字类型）
- 颜色选择器（ColorPickerButton）
- **验收**：编辑触发 onChanged 回调

**17. 实现背景和圆角编辑 UI**
- 背景颜色选择器
- 圆角滑块（0-32px）
- **验收**：实时更新配置对象

**18. 实现内边距编辑 UI**
- 四个输入框（上下左右）
- 网格布局
- **验收**：4 个方向独立编辑

**19. 实现阴影编辑 UI**
- 阴影颜色选择器
- X/Y 偏移输入框
- 模糊半径输入框
- **验收**：阴影实时预览

**20. 集成到 EditorSidebarV2**
- 在分隔线区域下方添加 _CardContainerStyleSection
- 连接 viewModel.cardContainerStyle 和 updateCardContainerStyle
- **验收**：Sidebar 显示新区域，编辑触发更新

---

### Week 2 Day 1: EditorWorkspace 集成（4 项）

**21. 传递 CardStyleConfig 到 V3Card**
- 从 viewModel.currentTemplate.cardContainerStyle 获取配置
- 调用 config.toBoxDecoration(), config.padding, config.constraints
- 传递给 EditableFourZhuCardV3
- **验收**：配置正确传递

**22. 更新 V3Card 接收参数**
- 添加 cardContainerDecoration, cardContainerPadding, cardContainerConstraints 参数
- 应用到顶层 Container
- **验收**：参数接收正确

**23. 移除 V3Card 硬编码样式**
- 搜索 `borderRadius: 16` 并替换为动态配置
- 添加 fallback 默认值（向后兼容）
- **验收**：无硬编码残留

**24. 端到端测试：Sidebar → V3Card**
- 编辑 Sidebar 卡片样式
- 验证 V3Card 实时更新
- 验证样式应用正确
- **验收**：端到端流程正常

---

### Week 2 Day 2: 回归测试（5 项）

**25. 测试旧模板加载**
- 加载历史模板（无 cardContainerStyle）
- 验证使用默认样式（borderRadius: 16）
- **验收**：旧模板正常显示

**26. 测试新建模板编辑**
- 创建新模板
- 编辑所有卡片样式属性（border, radius, padding, shadow, background）
- 保存并重新加载
- **验收**：样式持久化

**27. 测试边界值**
- 边框宽度 0, 10
- 圆角 0, 32
- 负数处理
- 无效颜色处理
- **验收**：边界情况正确处理

**28. 测试性能**
- 测试编辑响应时间（<100ms）
- 测试大模板加载速度
- **验收**：无性能回退

**29. 手动完整回归测试**
- 测试所有现有功能（行样式编辑、分隔线、全局字体）
- 确保无回归
- **验收**：所有功能正常

---

### Week 2 Day 3: 文档与清理（4 项）

**30. 创建迁移指南文档**
- 文件：`docs/feature/editable_eight_char/integeration/CardStyleConfig_Migration_Guide.md`
- 列出 API 变更
- 提供示例代码
- **验收**：文档清晰，示例可运行

**31. 更新架构文档**
- 更新数据流图（增加 cardContainerStyle）
- 更新 LayoutTemplate 结构说明
- **验收**：文档准确反映新架构

**32. 代码审查准备**
- 检查所有 TODO 注释
- 运行 `flutter analyze`
- 运行 `dart format .`
- **验收**：0 errors, 0 warnings

**33. 清理调试代码**
- 移除所有 debugPrint
- 移除注释掉的旧代码
- **验收**：代码整洁

---

### Week 2 Day 4-5: 最终验证与发布（7 项）

**34. 运行所有单元测试**
- 执行 `flutter test`
- **验收**：所有测试通过

**35. 运行所有集成测试**
- 测试完整用户流程
- **验收**：无回归

**36. 手动最终验证**
- 测试所有 Sidebar 编辑功能
- 测试样式实时预览
- 测试保存和加载
- **验收**：功能完整，无 Bug

**37. 性能基准测试**
- 对比重构前后性能
- **验收**：无性能下降

**38. 创建详细的 commit message**
- 格式：`🎨 新增 CardStyleConfig：卡片容器样式可视化编辑`
- 包含变更摘要、文件列表、测试结果
- **验收**：commit message 清晰

**39. 创建 Git Tag**
- Tag: `cardstyle-config-v1`
- 描述：CardStyleConfig 重构完成，支持卡片容器样式可视化编辑
- **验收**：tag 创建成功

**40. 合并到主分支**
- 创建 PR（如果需要）
- 合并到 master/main
- 推送 tag
- **验收**：代码合并成功，CI 通过

---

## 📊 预期收益

| 指标 | 当前 | 重构后 | 改进 |
|------|------|--------|------|
| **可编辑性** | ❌ 硬编码，无法编辑 | ✅ Sidebar 可视化编辑 | 🆕 新功能 |
| **ViewModel 方法数** | 0（无编辑功能） | 1 个 | 精简 |
| **代码重复** | 颜色转换器 4 处 | 1 处（内置） | -75% |
| **扩展成本** | 20+ 处（硬编码） | 3 处（配置类） | -85% |
| **类型安全** | ❌ 硬编码 | ✅ 编译时检查 | ✅ |

---

## 🔒 风险与缓解

| 风险 | 缓解措施 |
|------|---------|
| **JSON 向后兼容失败** | 完整单元测试 + fromJson 向后兼容逻辑 |
| **UI 性能下降** | BoxDecoration 缓存 + 性能基准测试 |
| **V3Card 集成问题** | 详细集成测试 + 渐进式迁移 |

---

## 📋 验收标准

### 功能性验收
- ✅ CardStyleConfig 类完成（24 个字段）
- ✅ 类型转换方法正确（toBoxDecoration, padding, constraints）
- ✅ JSON 序列化/反序列化成功
- ✅ LayoutTemplate 集成完成
- ✅ ViewModel updateCardContainerStyle 实现
- ✅ Sidebar 新增卡片容器样式编辑区域
- ✅ V3Card 应用动态样式
- ✅ 旧模板向后兼容

### 非功能性验收
- ✅ 单元测试覆盖率 >90%
- ✅ 通过 flutter analyze（0 errors）
- ✅ 编辑响应时间 <100ms
- ✅ 文档完整（迁移指南 + 架构文档）

---

## 下一步行动

1. **用户审阅本文档**，确认任务清单是否完整
2. **确认开始时间**（建议：等待 TextStyleConfig 重构完成）
3. **创建 feature 分支**：`git checkout -b feature/card-style-config-refactor`
4. **开始执行 Week 1 Day 1 任务**

**状态**: 🔄 待用户审阅和批准
