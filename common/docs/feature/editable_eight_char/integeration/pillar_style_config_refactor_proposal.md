# PillarStyleConfig 重构方案 - 原子化任务清单

## 1. 概述与目标
- 目标：以 `PillarStyleConfig` 聚合柱样式，替代 V3 中分散的参数传递，降低构造参数数量并提升语义清晰度。
- 收益：
  - 简化 `EditableFourZhuCardV3` 的参数与渲染逻辑；
  - 提升 Sidebar → ThemeController → Workspace → V3 的联动一致性；
  - 统一序列化与持久化，便于主题预置与导入导出。

## 2. 范围与不改动
- 范围：模型定义、主题解析、工作区与 V3 卡片集成、编辑器输出、测试与文档。
- 不改动：
  - 保持 `pillarsNotifier/rowListNotifier/paddingNotifier` 与统一监听器的联动；
  - 保持测量与尺寸计算主链路（含装饰参与测量）；
  - 现有行样式、文本分组映射与字体解析逻辑不在本次调整范围。

## 3. 前置假设与约束
- `CardStyleConfig` 已具备边框/背景/内边距/阴影等转换与序列化能力，可复用方法与结构约定。
- `EditableFourZhuThemeController` 目前提供柱相关解析方法（margin/padding/border/...），可在其上聚合为对象输出。
- 非负约束：`margin/padding/borderWidth/cornerRadius` 均需校验为非负数；颜色与阴影需可解析。

## 4. 交付物
- 新的 `PillarStyleConfig` 模型与 `toBoxDecoration()/toJson/fromJson/copyWith`。
- 主题解析方法：`resolveGlobalPillarStyle()` 与可选 `resolvePillarStyle(PillarType)`。
- 工作区与 V3 的对象化传参与渲染/测量使用。
- Sidebar 编辑器输出 `PillarStyleConfig` 并写回 ViewModel。
- 单元测试与集成测试覆盖；迁移与弃用说明。

## 5. 执行顺序（建议）
- 阶段1：模型与解析（引入不影响现有调用）
- 阶段2：V3 双栈支持（旧参数 + 新对象并存，旧参数标记为 deprecated）
- 阶段3：Workspace/Sidebar 切换为对象化传参
- 阶段4：清理收敛（移除旧参数），完成测试与验收

## 6. 原子化任务清单

### 6.1 数据模型与序列化
1. 定义 PillarStyleConfig 类
   - 输入契约：样式字段需求（margin/padding/border/背景/阴影/圆角）
   - 输出契约：`class PillarStyleConfig { margin, padding, borderWidth, borderColor, cornerRadius, backgroundColor, boxShadow }`
   - 验收标准：编译通过，字段齐全，文档注释完整

2. 实现 copyWith 与 equals/hashCode
   - 输入契约：不可变对象更新需求
   - 输出契约：`copyWith(...)`、`==/hashCode`
   - 验收标准：单测覆盖对象等价与拷贝语义

3. 实现 toBoxDecoration 与 getters
   - 输入契约：渲染层需要 `BoxDecoration` 与 `EdgeInsets`
   - 输出契约：`toBoxDecoration()`、`EdgeInsets? get margin/padding`
   - 验收标准：装饰转换正确，空值保持兼容

4. 实现 toJson/fromJson
   - 输入契约：持久化与预置主题需求
   - 输出契约：JSON 序列化/反序列化（嵌套与可选字段）
   - 验收标准：单测验证 round-trip 一致性

### 6.2 主题解析与聚合
5. 在 EditableFourZhuThemeController 聚合解析（全局）
   - 输入契约：现有 `resolvePillar*` 方法与 `EditableFourZhuCardTheme.pillar`
   - 输出契约：`PillarStyleConfig resolveGlobalPillarStyle()`
   - 验收标准：返回对象字段与现有解析一致

6. 提供按柱类型解析（可选差异化）
   - 输入契约：`perPillarMargin` 等差异化需求
   - 输出契约：`PillarStyleConfig resolvePillarStyle(PillarType type)`（至少支持 margin 差异）
   - 验收标准：优先级 `perPillar > global > 默认` 正确

### 6.3 Workspace 集成（对象化传参）
7. 在 EditorWorkspace 构造 PillarStyleConfig
   - 输入契约：ThemeController 解析方法
   - 输出契约：`final pillarStyle = controller.resolveGlobalPillarStyle()`
   - 验收标准：构造逻辑清晰，未引入循环依赖

8. 改造传参为对象
   - 输入契约：当前 V3 多字段传参路径
   - 输出契约：`EditableFourZhuCardV3(pillarStyle: pillarStyle, perPillarStyles: ...)`
   - 验收标准：编译通过，预览正常，旧字段仍保留（双栈期）

### 6.4 V3 卡片渲染与测量
9. 在 V3 新增参数并应用对象
   - 输入契约：Widget API 与内部状态
   - 输出契约：`final PillarStyleConfig? pillarStyle; final Map<PillarType, PillarStyleConfig>? perPillarStyles;`
   - 验收标准：热重载与属性更新能触发重算链

10. 替换散列字段使用 PillarStyleConfig
   - 输入契约：当前 `pillarMargin/padding/borderWidth/...`
   - 输出契约：统一从 `pillarStyle` 读取并应用到列容器与装饰
   - 验收标准：视觉一致，不丢失功能

11. 更新尺寸计算使用对象字段
   - 输入契约：`_computeSizeWithDecorations()` 叠加逻辑
   - 输出契约：读取 `margin/padding/borderWidth` 叠加
   - 验收标准：总尺寸与列间距/列高度符合预期，边界值稳定

### 6.5 Sidebar 编辑器与 ViewModel
12. 编辑器输出 PillarStyleConfig
   - 输入契约：`FourZhuPillarStyleEditorPanel` 控件值
   - 输出契约：组合为 `PillarStyleConfig` 并写回 VM
   - 验收标准：交互与预览即时联动

13. ViewModel API 增加更新方法
   - 输入契约：主题对象更新需求
   - 输出契约：`updateGlobalPillarStyle(PillarStyleConfig)`、`updatePillarStyle(PillarType, PillarStyleConfig)`
   - 验收标准：调用后 `notifyListeners()` 生效，Workspace 重建读取到新对象

### 6.6 兼容与收敛
14. 标记 V3 旧柱参数为 deprecated
   - 输入契约：现有 API
   - 输出契约：`@deprecated` 注解与迁移说明
   - 验收标准：编译告警可控，调用方不被破坏

15. 双栈过渡验证与回退策略
   - 输入契约：同时存在新旧参数的运行态
   - 输出契约：以对象为主，旧参数为兜底，确保一致性
   - 验收标准：在故障时可快速回退到旧参数路径

16. 清理收敛移除旧参数
   - 输入契约：所有调用方已迁移
   - 输出契约：移除旧字段与路径
   - 验收标准：测试通过，无编译错误与运行回归

### 6.7 测试与质量保障
17. 单元测试：模型与序列化
   - 输入契约：toJson/fromJson、copyWith、equals
   - 输出契约：覆盖典型与边界用例
   - 验收标准：100% 通过，round-trip 一致

18. 单元测试：装饰转换
   - 输入契约：toBoxDecoration 与阴影/圆角/边框
   - 输出契约：断言 `BoxDecoration` 与约束值
   - 验收标准：非负约束与空值兼容均通过

19. 集成测试：Sidebar → V3 联动
   - 输入契约：拖动 margin/padding/border/圆角/背景/阴影
   - 输出契约：预览即时更新与尺寸联动
   - 验收标准：用户可见的行为符合预期，无抖动

20. 性能与稳定验证
   - 输入契约：频繁编辑与拖拽场景
   - 输出契约：节流/冻结策略评估（必要时）
   - 验收标准：无明显卡顿；拖拽期间尺寸稳定

### 6.8 文档与迁移说明
21. 更新开发文档与示例
   - 输入契约：新 API 与使用场景
   - 输出契约：示例代码与迁移指南
   - 验收标准：文档完整、可操作

22. 变更日志与弃用时间线
   - 输入契约：版本规划与影响面
   - 输出契约：明确弃用窗口与回退路径
   - 验收标准：团队知悉并遵循

## 7. 验收标准（汇总）
- V3 构造参数由分散字段收敛为 `pillarStyle`（可选 `perPillarStyles`）。
- Sidebar 柱样式编辑的全部项（外/内边距、边框宽度/颜色、圆角、背景、阴影）即时联动 V3，尺寸计算正确。
- 单元测试与集成测试通过；文档与迁移指南齐全。
- 旧参数在收敛阶段移除前标记为 deprecated，移除后无回归。

## 8. 风险与缓解
- 向后兼容风险：通过双栈过渡与 `@deprecated` 降低影响；提供回退策略。
- 测量抖动风险：必要时对编辑交互进行节流/冻结，保持尺寸稳定；装饰参与测量的逻辑保持与现有一致。
- 性能风险：缩小监听范围（仅必要位置 `listen: true`），减少不必要的构建与重算；缓存不可变对象。

## 9. 依赖关系（简要）
- 6.1 → 6.2 → 6.3 → 6.4（模型→解析→集成→应用）
- 6.5 依赖 6.2 与 6.3（编辑器与 VM 输出对象）
- 6.6 依赖 6.3/6.4/6.5 完成后进行收敛
- 6.7/6.8 全程伴随，里程碑回归与文档同步
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
