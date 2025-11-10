# PillarStyleConfig 重构方案 - 原子化任务清单

**创建日期**: 2025-11-10
**状态**: 待审阅
**迁移周期**: 1.5-2 周（激进模式）
**依赖**: TextStyleConfig 和 CardStyleConfig 重构完成后启动

---

## 📋 方案概述

### 核心问题
- **柱样式硬编码**：每柱（年/月/日/时）的 border、radius、shadow、padding、**margin** 等样式硬编码在 V3Card 中
- **无法独立配置**：当前仅支持 `perPillarMargin`，其他柱样式无法为每柱单独设置
- **扩展困难**：新增柱样式属性需要修改多处硬编码

### 解决方案
创建 `PillarStyleConfig` 数据类，封装**每柱容器**的所有视觉样式：
- 边框：width, colorHex, style
- 背景：backgroundColorHex
- 圆角：borderRadius（统一）或 topLeft/topRight/bottomLeft/bottomRight（独立）
- **内边距**：paddingTop/Bottom/Left/Right
- **外边距**：marginTop/Bottom/Left/Right ⚠️ **新增关键属性**
- 阴影：shadowColorHex, offsetX/Y, blurRadius, spreadRadius
- 尺寸：width, height（可选）

### 核心差异：Margin vs Padding

**Padding（内边距）**：
- 柱容器内部的空白
- 影响柱内内容的位置
- 在 CardStyleConfig 中已支持

**Margin（外边距）** ⚠️ **关键新增**：
- 柱容器外部的空白
- 控制柱与柱之间的间距
- 当前仅有 `perPillarMargin: [8, 8, 8, 8]`（硬编码）
- **新方案**：每柱独立配置 4 方向 margin

### 集成方案

```dart
// LayoutTemplate 新增字段
class LayoutTemplate {
  final CardStyle cardStyle;  // 全局字体+分隔线
  final CardStyleConfig? cardContainerStyle;  // 卡片容器样式
  final PillarStyleConfig? globalPillarStyle;  // 🆕 全局柱样式（默认）
  final Map<PillarType, PillarStyleConfig>? perPillarStyles;  // 🆕 每柱独立样式（覆盖）
}

// 优先级：perPillarStyles > globalPillarStyle > 默认值

// ViewModel 新增方法
void updateGlobalPillarStyle(PillarStyleConfig? config);
void updatePillarStyle(PillarType type, PillarStyleConfig? config);

// V3Card 应用样式
Container(
  margin: pillarStyle?.margin,  // ⚠️ 外边距
  decoration: pillarStyle?.toBoxDecoration(),
  padding: pillarStyle?.padding,
  child: /* 柱内容 */,
)
```

### 与 CardStyleConfig 的对比

| 属性 | CardStyleConfig | PillarStyleConfig | 差异 |
|-----|----------------|------------------|-----|
| 边框 | ✅ 3 个 | ✅ 3 个 | 相同 |
| 背景 | ✅ 1 个 | ✅ 1 个 | 相同 |
| 圆角 | ✅ 5 个 | ✅ 5 个 | 相同 |
| 内边距 | ✅ 4 个 | ✅ 4 个 | 相同 |
| **外边距** | ❌ 无 | ✅ **4 个** | **新增** |
| 阴影 | ✅ 5 个 | ✅ 5 个 | 相同 |
| 尺寸 | ✅ 6 个 | ✅ 2 个 | 简化 |
| **总计** | 24 个 | **28 个** | **+4** |

**代码复用**：83% 属性相同，建议抽取 `StyleConfigUtils` 工具类

---

## ✅ 原子化 Todo List（50 项任务）

### Week 1 Day 1: PillarStyleConfig 类创建（5 项）

1. **创建 PillarStyleConfig 类骨架**
   - 文件：`lib/models/pillar_style_config.dart`
   - 28 个字段（border 3, background 1, radius 5, padding 4, **margin 4**, shadow 5, size 2）
   - 验收：编译通过

2. **实现类型转换方法**
   - `BoxDecoration toBoxDecoration()`
   - `EdgeInsets? get padding`
   - `EdgeInsets? get margin` ⚠️ 新增
   - 验收：转换正确

3. **实现工厂方法**
   - `fromBoxDecoration(...)`
   - `fromLegacy(...)`
   - `fromCardStyleConfig(CardStyleConfig, {margin})` ⚠️ 复用
   - 验收：双向转换一致

4. **运行 build_runner**
   - `dart run build_runner build --delete-conflicting-outputs`
   - 验收：生成 .g.dart

5. **抽取公共工具类 StyleConfigUtils（可选）**
   - 文件：`lib/utils/style_config_utils.dart`
   - 提取颜色解析、阴影构建等公共方法
   - 验收：代码重复减少 80%

---

### Week 1 Day 2: 单元测试（4 项）

6. **测试类型转换**
   - toBoxDecoration, padding, **margin**
   - 验收：测试通过

7. **测试 JSON 序列化**
   - toJson/fromJson 往返
   - 验收：一致

8. **测试向后兼容**
   - fromLegacy, fromCardStyleConfig
   - 验收：覆盖率 >90%

9. **测试 margin vs padding 差异**
   - 验收：行为符合预期

---

### Week 1 Day 3: LayoutTemplate 集成（4 项）

10. **添加柱样式字段**
    - `globalPillarStyle`, `perPillarStyles`
    - 验收：编译通过

11. **更新 JSON 序列化**
    - 处理 Map<PillarType, PillarStyleConfig>
    - 验收：JSON 正确

12. **集成测试**
    - 旧/新 JSON 加载
    - 验收：向后兼容

13. **测试样式优先级**
    - perPillarStyles > globalPillarStyle > 默认
    - 验收：优先级正确

---

### Week 1 Day 4: ViewModel 更新（4 项）

14. **添加 updateGlobalPillarStyle**
    - 验收：功能正确

15. **添加 updatePillarStyle（每柱）**
    - 验收：独立更新

16. **ViewModel 单元测试**
    - 验收：测试通过

17. **回归测试**
    - 验收：无现有测试失败

---

### Week 1 Day 5-6: Sidebar UI（8 项）

18. **创建 _PillarStyleSection 组件**
    - 柱选择器（全局/年/月/日/时）
    - 验收：UI 正常

19. **边框编辑 UI**
    - 验收：编辑触发回调

20. **背景和圆角 UI**
    - 验收：实时更新

21. **内边距 UI**
    - 4 个输入框
    - 验收：独立编辑

22. **外边距 UI** ⚠️ 新增
    - 4 个输入框，标签："外边距（柱间距）"
    - 验收：与 padding 区分

23. **阴影编辑 UI**
    - 验收：实时预览

24. **柱类型切换逻辑**
    - 验收：切换正常

25. **集成到 EditorSidebarV2**
    - 验收：显示新区域

---

### Week 2 Day 1: EditorWorkspace 集成（5 项）

26. **获取有效柱样式**
    - 考虑优先级
    - 验收：逻辑正确

27. **传递配置到 V3Card**
    - 验收：正确传递

28. **更新 V3Card 参数**
    - 验收：接收正确

29. **应用 margin**
    - 验收：柱间距可调

30. **移除硬编码**
    - 验收：无残留

---

### Week 2 Day 2: 回归测试（6 项）

31. **旧模板加载**
    - 验收：默认样式

32. **全局柱样式编辑**
    - 验收：统一生效

33. **每柱独立编辑**
    - 年柱红边框、月柱0圆角、日柱大margin、时柱浅蓝背景
    - 验收：独立持久化

34. **margin vs padding 视觉差异**
    - 验收：明确区分

35. **边界值测试**
    - 验收：正确处理

36. **完整回归**
    - 验收：无回归

---

### Week 2 Day 3: 文档与清理（5 项）

37. **迁移指南**
    - 解释 margin vs padding
    - 验收：清晰

38. **架构文档**
    - 优先级图表
    - 验收：准确

39. **对比文档**
    - PillarStyleConfig vs CardStyleConfig
    - 验收：差异清晰

40. **代码审查**
    - flutter analyze
    - 验收：0 errors

41. **清理代码**
    - 验收：整洁

---

### Week 2 Day 4-5: 最终验证（9 项）

42. **所有单元测试**
43. **所有集成测试**
44. **全局柱样式验证**
45. **每柱独立样式验证**
46. **margin 实时预览验证**
47. **性能基准**
48. **Commit message**
49. **Git Tag**: `pillarstyle-config-v1`
50. **合并主分支**

---

## 📊 预期收益

| 指标 | 当前 | 重构后 | 改进 |
|------|------|--------|------|
| 可编辑性 | ❌ 仅 margin 部分可配 | ✅ 全部 28 属性 | 🆕 |
| 每柱独立 | ❌ 仅 margin | ✅ 全部属性 | 🆕 |
| 代码重复 | 4 处 | 1 处 | -75% |
| 扩展成本 | 20+ 处 | 3 处 | -85% |

---

## 🎯 关键设计决策

1. **Margin 实现**：通过外层 Container 的 margin 属性（推荐）
2. **配置策略**：全局 + 每柱覆盖（推荐）
3. **代码复用**：抽取 StyleConfigUtils（推荐）
4. **UI 设计**：柱选择器切换（推荐）

---

## 📋 验收标准

### 功能性
- ✅ 28 个字段（含 margin）
- ✅ 样式优先级正确
- ✅ Margin vs Padding 明确区分
- ✅ 每柱独立配置
- ✅ 向后兼容

### 非功能性
- ✅ 覆盖率 >90%
- ✅ 0 errors
- ✅ <100ms 响应
- ✅ 文档完整

---

## 📐 核心类定义

```dart
@JsonSerializable()
class PillarStyleConfig {
  const PillarStyleConfig({
    // 边框
    this.borderWidth,
    this.borderColorHex,
    this.borderStyle,

    // 背景
    this.backgroundColorHex,

    // 圆角（5个）
    this.borderRadius,
    this.borderRadiusTopLeft,
    this.borderRadiusTopRight,
    this.borderRadiusBottomLeft,
    this.borderRadiusBottomRight,

    // 内边距（4个）
    this.paddingTop,
    this.paddingBottom,
    this.paddingLeft,
    this.paddingRight,

    // 外边距（4个）⚠️ 新增
    this.marginTop,
    this.marginBottom,
    this.marginLeft,
    this.marginRight,

    // 阴影（5个）
    this.shadowColorHex,
    this.shadowOffsetX,
    this.shadowOffsetY,
    this.shadowBlurRadius,
    this.shadowSpreadRadius,

    // 尺寸（2个）
    this.width,
    this.height,
  });

  final double? borderWidth;
  final String? borderColorHex;
  final String? borderStyle;
  final String? backgroundColorHex;
  final double? borderRadius;
  final double? borderRadiusTopLeft;
  final double? borderRadiusTopRight;
  final double? borderRadiusBottomLeft;
  final double? borderRadiusBottomRight;
  final double? paddingTop;
  final double? paddingBottom;
  final double? paddingLeft;
  final double? paddingRight;
  final double? marginTop;      // ⚠️ 新增
  final double? marginBottom;   // ⚠️ 新增
  final double? marginLeft;     // ⚠️ 新增
  final double? marginRight;    // ⚠️ 新增
  final String? shadowColorHex;
  final double? shadowOffsetX;
  final double? shadowOffsetY;
  final double? shadowBlurRadius;
  final double? shadowSpreadRadius;
  final double? width;
  final double? height;

  // 类型转换
  BoxDecoration toBoxDecoration() => BoxDecoration(
    border: _buildBorder(),
    borderRadius: _buildBorderRadius(),
    color: _parseColor(backgroundColorHex),
    boxShadow: _buildShadows(),
  );

  EdgeInsets? get padding => _buildEdgeInsets(
    paddingTop, paddingBottom, paddingLeft, paddingRight,
  );

  EdgeInsets? get margin => _buildEdgeInsets(
    marginTop, marginBottom, marginLeft, marginRight,
  );

  // 工厂方法
  factory PillarStyleConfig.fromJson(Map<String, dynamic> json) =>
      _$PillarStyleConfigFromJson(json);
  Map<String, dynamic> toJson() => _$PillarStyleConfigToJson(this);

  factory PillarStyleConfig.fromLegacy({...}) { /* ... */ }

  factory PillarStyleConfig.fromCardStyleConfig(
    CardStyleConfig config, {
    EdgeInsets? margin,
  }) {
    return PillarStyleConfig(
      // 复用 CardStyleConfig 的 24 个属性
      borderWidth: config.borderWidth,
      borderColorHex: config.borderColorHex,
      // ...
      // 新增 margin
      marginTop: margin?.top,
      marginBottom: margin?.bottom,
      marginLeft: margin?.left,
      marginRight: margin?.right,
    );
  }

  // 私有辅助方法
  Border? _buildBorder() { /* ... */ }
  BorderRadius? _buildBorderRadius() { /* ... */ }
  List<BoxShadow>? _buildShadows() { /* ... */ }
  static Color? _parseColor(String? hex) { /* ... */ }
  static EdgeInsets? _buildEdgeInsets(double? t, double? b, double? l, double? r) {
    if (t == null && b == null && l == null && r == null) return null;
    return EdgeInsets.fromLTRB(l ?? 0, t ?? 0, r ?? 0, b ?? 0);
  }

  // copyWith, ==, hashCode
  // ...
}
```

---

## 🔗 相关文档

Agent 生成的详细文档（位于 `/docs/` 根目录）：
1. **pillar_style_investigation_report.md** (563 行) - 深度调查
2. **pillar_vs_card_style_comparison.md** (483 行) - 详细对比
3. **pillar_style_config_refactor_proposal.md** (1522 行) - 完整方案

---

## 下一步行动

1. 审阅 50 项任务清单
2. 确认 margin 实现方式（Container margin）
3. 确认配置策略（全局+每柱覆盖）
4. 确认开始时间（等待 TextStyleConfig + CardStyleConfig 完成）
5. 创建 feature 分支
6. 开始执行

**状态**: 🔄 待用户审阅
**依赖**: TextStyleConfig → CardStyleConfig → PillarStyleConfig
