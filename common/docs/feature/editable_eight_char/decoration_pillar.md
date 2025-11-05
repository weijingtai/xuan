# PillarDecoration 数据驱动尺寸计算架构

> 架构方案文档 - EditableFourZhuCard 柱装饰系统重构

## 📋 目录

- [文档导航](#文档导航)
- [核心设计哲学](#核心设计哲学)
- [架构设计](#架构设计)
  - [类层级结构](#类层级结构)
  - [尺寸计算链](#尺寸计算链)
  - [重构对比](#重构对比)
- [方案优势](#方案优势)
- [实施挑战与解决方案](#实施挑战与解决方案)
- [完整实施计划](#完整实施计划)

---

## 文档导航

本重构项目包含完整的文档体系，方便查阅和执行：

### 核心文档

- **[implementation_plan.md](./implementation_plan.md)** - 完整实施计划
  - 49 个极细粒度任务清单（每个 15-30 分钟）
  - 6 个实施阶段，每个阶段包含详细任务、验证标准
  - 风险评估和时间估算（总计 12-17 小时）

- **[architecture_design.md](./architecture_design.md)** - 架构设计文档
  - 完整的 UML 类图和层次结构
  - CellDecoration 和 PillarDecoration 完整 API 详解
  - 尺寸计算算法详解（含公式和示例）
  - 10+ 个典型代码示例
  - 7 个设计决策记录（ADR 风格）

- **[rollback_guide.md](./rollback_guide.md)** - 回滚指南
  - 分阶段详细回滚方案
  - Git 分支管理策略
  - 数据备份建议
  - 5 个常见问题的快速修复指南
  - 完全回滚的终极方案

- **[testing_checklist.md](./testing_checklist.md)** - 测试检查清单
  - 6 个阶段的详细测试清单（50+ 个检查项）
  - 完整回归测试清单（20 个测试项）
  - 单元测试、Widget 测试、集成测试示例代码
  - 性能基准测试脚本

### 快速链接

| 需求 | 推荐文档 |
|------|----------|
| 我想开始执行重构 | [implementation_plan.md](./implementation_plan.md) - 从阶段 1 开始 |
| 我想了解详细架构 | [architecture_design.md](./architecture_design.md) - 查看类图和 API |
| 我想回滚某个阶段 | [rollback_guide.md](./rollback_guide.md) - 查看对应阶段的回滚方案 |
| 我想测试功能 | [testing_checklist.md](./testing_checklist.md) - 执行对应阶段的测试清单 |
| 我遇到问题了 | [rollback_guide.md](./rollback_guide.md#常见问题快速修复) - 查看快速修复指南 |

---

## 核心设计哲学

### 从"过程式计算"到"对象自描述"

**当前问题：** 计算逻辑散落在 State 类的多个方法中

```dart
// 计算逻辑散落、重复、易错、难维护
_colWidthAtIndex() -> 判断类型 -> 累加 override -> 累加 default -> 累加 border
_totalColsWidth() -> 遍历 -> 累加
_columnBoundaryMidX() -> 遍历 -> 累加 -> 计算中点
```

**新方案：** 数据自己知道自己的尺寸

```dart
// 数据自描述 - 单一职责、易测试、可缓存
pillarPayload.decoration.size  // ✅ 一个属性搞定！
```

---

## 架构设计

### 类层级结构

```
┌─────────────────────────────────────────────┐
│           PillarPayload                     │  // 柱数据载荷
├─────────────────────────────────────────────┤
│ - pillarType: PillarType                    │
│ - pillarContent: PillarContent              │
│ - decoration: PillarDecoration?             │◄──┐
└─────────────────────────────────────────────┘   │
                                                  │
        ┌─────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────┐
│        PillarDecoration                     │  // 柱装饰配置
├─────────────────────────────────────────────┤
│ - margin: EdgeInsets                        │
│ - padding: EdgeInsets                       │
│ - border: BoxBorder?                        │
│ - borderRadius: BorderRadius?               │
│ - backgroundColor: Color?                   │
│ - boxShadow: List<BoxShadow>?              │
│ - cells: List<CellDecoration>               │◄──┐
│                                             │   │
│ // 计算属性（核心）                          │   │
│ + size: Size (get)                          │   │
│ + contentSize: Size (get)                   │   │
│ + contentOffset: Offset (get)               │   │
│ + contentCenter: Offset (get)               │   │
│ + cellAt(rowIndex): CellDecoration          │   │
└─────────────────────────────────────────────┘   │
                                                  │
        ┌─────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────┐
│         CellDecoration                      │  // 单元格装饰
├─────────────────────────────────────────────┤
│ - rowType: RowType                          │
│ - padding: EdgeInsets                       │
│ - border: BoxBorder?                        │
│ - backgroundColor: Color?                   │
│ - height: double?  // 显式高度，可选        │
│                                             │
│ // 计算属性                                 │
│ + size: Size (get)                          │
│ + effectiveHeight: double (get)             │
└─────────────────────────────────────────────┘
```

### 尺寸计算链

#### CellDecoration 实现

```dart
class CellDecoration {
  final RowType rowType;
  final EdgeInsets padding;
  final BoxBorder? border;
  final Color? backgroundColor;
  final double? height;  // 显式高度（优先级最高）

  // 上下文依赖（从外部传入或通过构造函数注入）
  final double defaultGanZhiHeight;
  final double defaultOtherHeight;
  final double defaultDividerHeight;

  /// 核心：计算有效高度
  double get effectiveHeight {
    // 1. 优先使用显式高度
    if (height != null) return height!;

    // 2. 根据行类型推断
    switch (rowType) {
      case RowType.heavenlyStem:
      case RowType.earthlyBranch:
        return defaultGanZhiHeight;
      case RowType.rowDivider:
        return defaultDividerHeight;
      default:
        return defaultOtherHeight;
    }
  }

  /// 关键：计算总尺寸（含 padding + border）
  Size getSize(double pillarWidth) {
    final contentHeight = effectiveHeight;
    final borderVertical = (border?.top.width ?? 0) + (border?.bottom.width ?? 0);
    final totalHeight = contentHeight + padding.vertical + borderVertical;

    final borderHorizontal = (border?.left.width ?? 0) + (border?.right.width ?? 0);
    final totalWidth = pillarWidth + padding.horizontal + borderHorizontal;

    return Size(totalWidth, totalHeight);
  }
}
```

#### PillarDecoration 实现

```dart
class PillarDecoration {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final BoxBorder? border;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final List<CellDecoration> cells;
  final double basePillarWidth;  // 基础柱宽（不含装饰）

  /// 核心计算属性：总尺寸
  Size get size {
    // 1. 累加所有 Cell 的内容高度
    double totalCellHeight = 0.0;
    for (final cell in cells) {
      totalCellHeight += cell.effectiveHeight;
    }

    // 2. 加上柱的 padding
    double contentHeight = totalCellHeight + padding.vertical;

    // 3. 加上柱的 border
    final borderTop = border?.top.width ?? 0;
    final borderBottom = border?.bottom.width ?? 0;
    double boxHeight = contentHeight + borderTop + borderBottom;

    // 4. 加上柱的 margin
    double totalHeight = boxHeight + margin.vertical;

    // 宽度计算（所有 Cell 宽度一致）
    final borderLeft = border?.left.width ?? 0;
    final borderRight = border?.right.width ?? 0;
    double totalWidth = basePillarWidth + padding.horizontal +
                       borderLeft + borderRight + margin.horizontal;

    return Size(totalWidth, totalHeight);
  }

  /// 内容区尺寸（不含 margin）
  Size get contentSize {
    return Size(
      size.width - margin.horizontal,
      size.height - margin.vertical,
    );
  }

  /// 内容区起始偏移（相对于 size 左上角）
  Offset get contentOffset {
    return Offset(
      margin.left + (border?.left.width ?? 0) + padding.left,
      margin.top + (border?.top.width ?? 0) + padding.top,
    );
  }

  /// 内容区中点（用于让位边界）
  Offset get contentCenter {
    return Offset(
      contentOffset.dx + (contentSize.width - padding.horizontal) / 2,
      contentOffset.dy + (contentSize.height - padding.vertical) / 2,
    );
  }

  /// 转换为 BoxDecoration（用于渲染）
  BoxDecoration toBoxDecoration() {
    return BoxDecoration(
      color: backgroundColor,
      border: border,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
    );
  }
}
```

### 重构对比

#### 列宽计算

**原来：40+ 行的复杂逻辑**

```dart
double _colWidthAtIndex(int i, List<Tuple2<String, JiaZi>> pillars) {
  final payloads = widget.pillarsNotifier.value;
  if (i >= 0 && i < payloads.length) {
    final p = payloads[i];
    // 特殊处理：行标题列
    if (p.pillarType == PillarType.rowTitleColumn) { ... }
  }
  // 分隔列：统一使用分隔列的有效窄宽度
  if (_isSeparatorColumnIndex(i)) return _colDividerWidthEffective;
  final override = _columnWidthOverrides[i];
  if (override != null) { ... }
  // ... 更多逻辑
}
```

**重构后：3 行搞定**

```dart
double _colWidthAtIndex(int i, List<Tuple2<String, JiaZi>> pillars) {
  final payload = widget.pillarsNotifier.value[i];
  return payload.decoration?.size.width ?? pillarWidth;  // ✅ 数据自描述
}
```

#### 总宽度计算

**原来：遍历累加**

```dart
double _totalColsWidth(List<Tuple2<String, JiaZi>> pillars) {
  double acc = 0.0;
  for (int i = 0; i < pillars.length; i++) {
    acc += _colWidthAtIndex(i, pillars);
  }
  return acc;
}
```

**重构后：函数式一行**

```dart
double _totalColsWidth(List<Tuple2<String, JiaZi>> pillars) {
  return widget.pillarsNotifier.value.fold<double>(
    0.0,
    (sum, p) => sum + (p.decoration?.size.width ?? pillarWidth),
  );
}
```

#### 抓手对齐

**原来：宽度计算不准确，抓手偏移**

```dart
// topGripRow
SizedBox(
  width: _colWidthAtIndex(i, pillars),  // 不准确
  child: Center(child: Draggable(...)),
)
```

**重构后：完美对齐**

```dart
// topGripRow (Line 764-776)
...List.generate(pillars.length, (i) {
  final payload = widget.pillarsNotifier.value[i];
  final decoration = payload.decoration;
  final totalWidth = decoration?.size.width ?? pillarWidth;

  return SizedBox(
    width: totalWidth,  // ✅ 总宽度（含 margin）
    height: dragHandleRowHeight,
    child: decoration != null
      ? Padding(  // ✅ 抵消 margin，让抓手居中到内容区
          padding: EdgeInsets.symmetric(
            horizontal: decoration.margin.horizontal / 2,
          ),
          child: Center(child: Draggable(...)),
        )
      : Center(child: Draggable(...)),
  );
})
```

#### 让位边界计算

**原来：手动累加，容易出错**

```dart
double _columnBoundaryMidX(int idx, ...) {
  double acc = 0.0;
  for (int i = 0; i < pillars.length; i++) {
    final w = _colWidthAtIndex(i, pillars);
    if (i == idx) {
      return acc + w / 2.0;  // ❌ 简单中点，不考虑 margin
    }
    acc += w;
  }
}
```

**重构后：精确的内容区中点**

```dart
double _columnBoundaryMidX(int idx, ...) {
  final payloads = widget.pillarsNotifier.value;

  // 累加前面所有柱的总宽度
  double acc = 0.0;
  for (int i = 0; i < idx; i++) {
    acc += payloads[i].decoration?.size.width ?? pillarWidth;
  }

  // 加上当前柱的内容区中点偏移
  final decoration = payloads[idx].decoration;
  if (decoration != null) {
    return acc + decoration.contentCenter.dx;  // ✅ 精确的内容区中点
  }
  return acc + pillarWidth / 2;
}
```

#### dataGrid 渲染

**原来：直接应用装饰，尺寸不匹配**

```dart
child: Container(
  decoration: BoxDecoration(...),  // ❌ 直接应用，overflow
  width: pillarWidth,
  child: columnContent,
)
```

**重构后：结构清晰，尺寸精确**

```dart
final payload = widget.pillarsNotifier.value[i];
final decoration = payload.decoration;

child: decoration != null
  ? Container(
      margin: decoration.margin,  // ✅ 外层 margin
      child: Container(
        padding: decoration.padding,  // ✅ 中层 padding
        decoration: decoration.toBoxDecoration(),
        child: SizedBox(
          width: decoration.contentSize.width - decoration.padding.horizontal,
          // ✅ 精确的内容宽度
          child: columnContent,
        ),
      ),
    )
  : SizedBox(
      width: pillarWidth,
      child: columnContent,
    ),
```

---

## 方案优势

### 1. 封装性（Encapsulation）

- ✅ 尺寸计算逻辑封装在 `PillarDecoration` 类内
- ✅ 外部只需调用 `.size`，不关心内部实现
- ✅ 修改计算规则只需改一个地方

### 2. 可测试性（Testability）

```dart
// 单元测试变得极其简单
test('PillarDecoration size calculation', () {
  final decoration = PillarDecoration(
    margin: EdgeInsets.all(8),
    padding: EdgeInsets.all(6),
    border: Border.all(width: 2),
    cells: [
      CellDecoration(rowType: RowType.heavenlyStem, height: 48),
      CellDecoration(rowType: RowType.earthlyBranch, height: 48),
    ],
    basePillarWidth: 64,
  );

  expect(decoration.size.width, 64 + 12 + 4 + 16);  // base + padding + border + margin
  expect(decoration.size.height, 96 + 12 + 4 + 16);  // cells + padding + border + margin
});
```

### 3. 性能优化（Performance）

```dart
class PillarDecoration {
  Size? _cachedSize;  // 缓存

  Size get size {
    if (_cachedSize != null) return _cachedSize!;
    _cachedSize = _computeSize();
    return _cachedSize!;
  }

  void invalidateCache() {
    _cachedSize = null;
  }
}
```

### 4. 类型安全（Type Safety）

```dart
// 原来：返回 double，容易混淆
double width = _colWidthAtIndex(i);  // 这是总宽度？内容宽度？含 margin 吗？

// 重构后：返回 Size，语义明确
Size size = decoration.size;              // 总尺寸（含 margin）
Size contentSize = decoration.contentSize;  // 内容尺寸（不含 margin）
Offset contentCenter = decoration.contentCenter;  // 内容中点
```

### 5. 扩展性（Extensibility）

```dart
// 未来轻松添加新功能
class PillarDecoration {
  // 添加动画尺寸
  Size getSizeWithAnimation(double progress) {
    return Size.lerp(Size.zero, size, progress)!;
  }

  // 添加响应式尺寸
  Size getResponsiveSize(double screenWidth) {
    if (screenWidth < 600) return size * 0.8;
    return size;
  }
}
```

---

## 实施挑战与解决方案

### 挑战 1：动态行列表

**问题：** 行可以被拖拽重排，Cell 数量/顺序会变化，`PillarDecoration.cells` 如何同步？

**解决方案：** 使用"生成策略"而非直接存储 cells

```dart
class PillarDecoration {
  // 不直接存储 cells，而是存储"生成策略"
  final List<RowType> rowTypes;  // 行类型列表（动态）
  final Map<RowType, CellDecoration> cellTemplates;  // 模板

  List<CellDecoration> get cells {
    return rowTypes.map((type) => cellTemplates[type]!).toList();
  }
}

// 在 State 中
void _updatePillarDecorations() {
  final currentRows = widget.rowListNotifier.value;
  for (int i = 0; i < payloads.length; i++) {
    final decoration = payloads[i].decoration;
    if (decoration != null) {
      // 更新 rowTypes 列表（响应行重排）
      decoration.rowTypes = currentRows.map((r) => r.rowType).toList();
      decoration.invalidateCache();
    }
  }
}
```

### 挑战 2：表头行特殊高度

**问题：** 表头行使用 `columnTitleHeight`，普通行使用 `ganZhiCellSize.height` 或 `otherCellHeight`。

**解决方案：** 添加 `isHeaderRow` 标记

```dart
class CellDecoration {
  final RowType rowType;
  final bool isHeaderRow;  // 标记是否为表头行

  double get effectiveHeight {
    if (height != null) return height!;

    // 表头行特殊处理
    if (isHeaderRow) return defaultColumnTitleHeight;

    switch (rowType) {
      case RowType.heavenlyStem:
      case RowType.earthlyBranch:
        return defaultGanZhiHeight;
      // ...
    }
  }
}
```

### 挑战 3：分隔符柱/行

**问题：** 分隔符柱宽度很窄（`_colDividerWidthEffective`），分隔行高度也不同。

**解决方案：** 工厂方法模式

```dart
class PillarDecoration {
  factory PillarDecoration.separator({
    required double dividerWidth,
    required double totalHeight,
  }) {
    return PillarDecoration(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(horizontal: 4),
      border: null,
      cells: [],  // 分隔符没有 cells
      basePillarWidth: dividerWidth - 8,  // 减去 padding
    );
  }

  @override
  Size get size {
    if (cells.isEmpty) {
      // 分隔符特殊处理：宽度固定，高度继承父容器
      return Size(basePillarWidth + margin.horizontal, 0);  // 高度由外部控制
    }
    return _computeNormalSize();
  }
}
```

### 挑战 4：行高度覆盖（_rowHeightOverrides）

**问题：** 用户可以手动调整某一行的高度，这如何影响 `CellDecoration.effectiveHeight`？

**解决方案：** 在创建时注入 override

```dart
// 在 State 中维护 override 映射
final Map<int, double> _rowHeightOverrides = {};

// 创建 PillarDecoration 时注入 override
PillarDecoration _createPillarDecoration(int pillarIndex) {
  final rows = widget.rowListNotifier.value;
  final cellDecorations = rows.asMap().entries.map((entry) {
    final rowIndex = entry.key;
    final row = entry.value;

    // 从 override 读取高度
    final overrideHeight = _rowHeightOverrides[rowIndex];

    return CellDecoration(
      rowType: row.rowType,
      height: overrideHeight,  // ✅ 覆盖优先
      // ...
    );
  }).toList();

  return PillarDecoration(
    cells: cellDecorations,
    // ...
  );
}
```

---

## 完整实施计划

> 详细的任务清单和时间估算请查看 **[implementation_plan.md](./implementation_plan.md)**

### 计划概览

本次重构分为 **6 个阶段**，总计 **49 个极细粒度任务**，预计耗时 **12-17 小时**：

| 阶段 | 内容 | 任务数 | 预计时间 | 详细文档 |
|------|------|--------|----------|----------|
| 阶段 1 | 数据模型创建 | 8 | 2-3 小时 | [查看详情](./implementation_plan.md#阶段-1-数据模型创建) |
| 阶段 2 | Widget 组件创建 | 9 | 2-3 小时 | [查看详情](./implementation_plan.md#阶段-2-widget-组件创建) |
| 阶段 3 | 渲染层局部替换 | 12 | 3-4 小时 | [查看详情](./implementation_plan.md#阶段-3-渲染层局部替换) |
| 阶段 4 | 拖拽反馈重构 | 8 | 2-3 小时 | [查看详情](./implementation_plan.md#阶段-4-拖拽反馈重构) |
| 阶段 5 | 幽灵元素优化 | 5 | 1-2 小时 | [查看详情](./implementation_plan.md#阶段-5-幽灵元素优化) |
| 阶段 6 | 清理与优化 | 7 | 2 小时 | [查看详情](./implementation_plan.md#阶段-6-清理与优化) |

### 快速开始

1. **阅读架构文档：** [architecture_design.md](./architecture_design.md) - 了解设计理念
2. **执行任务清单：** [implementation_plan.md](./implementation_plan.md) - 从阶段 1 开始
3. **测试验收：** [testing_checklist.md](./testing_checklist.md) - 执行对应阶段的测试
4. **遇到问题：** [rollback_guide.md](./rollback_guide.md) - 查看回滚方案或快速修复

### 阶段概要

以下是各阶段的简要说明，详细任务清单请查看 [implementation_plan.md](./implementation_plan.md)。

---

### 阶段 1：定义数据模型

**任务 1：创建 CellDecoration 类**
- 文件：`lib/models/cell_decoration.dart`
- 字段：`rowType`, `padding`, `border`, `backgroundColor`, `height`
- 计算属性：`effectiveHeight`, `getSize(width)`
- 支持默认高度推断和显式高度覆盖

**任务 2：创建 PillarDecoration 类**
- 文件：`lib/models/pillar_decoration.dart`
- 字段：`margin`, `padding`, `border`, `borderRadius`, `backgroundColor`, `boxShadow`, `basePillarWidth`
- 关联：`List<CellDecoration> cells` 或 `List<RowType> rowTypes + templates`
- 计算属性：
  - `size`: 总尺寸（含 margin）
  - `contentSize`: 内容尺寸（不含 margin）
  - `contentOffset`: 内容区起始偏移
  - `contentCenter`: 内容区中点
- 方法：`toBoxDecoration()`, `invalidateCache()`
- 工厂方法：`PillarDecoration.separator()`

**任务 3：扩展 PillarPayload**
- 文件：`lib/models/drag_payloads.dart`
- 添加 `decoration: PillarDecoration?` 字段

### 阶段 2：重构计算方法

**任务 4：简化 _colWidthAtIndex()**
- 文件：`editable_fourzhu_card_impl.dart`
- 改为 `payload.decoration?.size.width ?? defaultWidth`

**任务 5：简化 _totalColsWidth()**
- 使用 `fold` 函数式累加

**任务 6：重构 _columnBoundaryMidX()**
- 使用 `decoration.contentCenter.dx`

**任务 7：新增 _rowHeightAtIndex()**（可选）
- 如果行也需要装饰，添加此方法

### 阶段 3：修改渲染逻辑

**任务 8：修改 topGripRow 抓手对齐**
- `SizedBox width` 使用 `decoration.size.width`
- 添加 `Padding` 抵消 margin

**任务 9：修改 dataGrid 的 Container 渲染**
- 外层 `Container` 应用 margin
- 内层 `Container` 应用 padding + decoration
- `SizedBox` 设置精确的内容宽度

**任务 10：同步 leftGripColumn 的行抓手**（如果行有装饰）

### 阶段 4：动态更新机制

**任务 11：添加 _updatePillarDecorations() 方法**
- 监听 `rowListNotifier` 变化
- 更新所有 `PillarDecoration` 的 `cells/rowTypes`
- 调用 `invalidateCache()`

**任务 12：处理 _rowHeightOverrides**
- 在创建 `CellDecoration` 时注入 override 高度

**任务 13：处理分隔符特殊情况**
- 工厂方法 `PillarDecoration.separator()`

### 阶段 5：测试与优化

**任务 14：单元测试 PillarDecoration.size 计算**
**任务 15：验证抓手对齐（无偏移）**
**任务 16：验证无 overflow 警告**
**任务 17：测试拖拽功能（行/列）**
**任务 18：性能优化（缓存 size 计算）**

---

## 关键文件

- `lib/models/drag_payloads.dart` - 扩展 PillarPayload
- `lib/models/pillar_decoration.dart` - 新建 PillarDecoration
- `lib/models/cell_decoration.dart` - 新建 CellDecoration
- `lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart` - 重构计算逻辑

---

## 总结

这个架构方案将复杂的尺寸计算逻辑从 UI 层分离，封装到数据模型中，实现了：

1. **数据驱动** - 数据自描述尺寸，而非外部计算
2. **单一职责** - 每个类只负责自己的尺寸计算
3. **易维护** - 修改规则只需改一个地方
4. **易测试** - 可独立测试尺寸计算逻辑
5. **高性能** - 支持缓存，避免重复计算
6. **类型安全** - 使用 Size/Offset 语义明确
7. **易扩展** - 支持动画、响应式等未来需求

通过这个重构，可以彻底解决当前的抓手对齐、overflow、让位边界等问题，并为未来的功能扩展打下坚实基础。

---

## 相关文档

- **[implementation_plan.md](./implementation_plan.md)** - 完整实施计划（49 个任务清单）
- **[architecture_design.md](./architecture_design.md)** - 架构设计文档（详细 API 和代码示例）
- **[rollback_guide.md](./rollback_guide.md)** - 回滚指南（分阶段回滚方案）
- **[testing_checklist.md](./testing_checklist.md)** - 测试检查清单（50+ 个测试项）

---

**祝重构顺利！** 🚀
