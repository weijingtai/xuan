# PillarDecoration 架构设计文档

> EditableFourZhuCard 数据驱动装饰系统 - 详细设计说明

## 📋 目录

- [设计理念](#设计理念)
- [类层次结构](#类层次结构)
- [数据模型详细设计](#数据模型详细设计)
  - [CellDecoration](#celldecorat

ion)
  - [PillarDecoration](#pillardecoration)
  - [DecorationDefaults](#decorationdefaults)
- [Widget 组件详细设计](#widget-组件详细设计)
  - [CellWidget](#cellwidget)
  - [PillarWidget](#pillarwidget)
  - [GhostPillarWidget](#ghostpillarwidget)
  - [DraggingFeedbackWidget](#draggingfeedbackwidget)
  - [GripWidget](#gripwidget)
- [与现有系统的集成](#与现有系统的集成)
- [尺寸计算算法详解](#尺寸计算算法详解)
- [代码示例](#代码示例)
- [设计决策记录](#设计决策记录)

---

## 设计理念

### 从过程式到数据驱动

**核心原则：** 数据应该知道如何描述自己，而不是由外部代码来解释数据。

#### 过程式计算（旧方式）

```dart
// 问题 1：计算逻辑散落
double _colWidthAtIndex(int i, List<Tuple2<String, JiaZi>> pillars) {
  final payloads = widget.pillarsNotifier.value;
  if (i >= 0 && i < payloads.length) {
    final p = payloads[i];
    if (p.pillarType == PillarType.rowTitleColumn) { ... }
  }
  if (_isSeparatorColumnIndex(i)) return _colDividerWidthEffective;
  final override = _columnWidthOverrides[i];
  if (override != null) { ... }
  // ... 40+ 行逻辑
}

// 问题 2：重复计算
double _totalColsWidth(List<Tuple2<String, JiaZi>> pillars) {
  double acc = 0.0;
  for (int i = 0; i < pillars.length; i++) {
    acc += _colWidthAtIndex(i, pillars);  // 每次重新计算
  }
  return acc;
}

// 问题 3：难以维护
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

**问题总结：**

1. ❌ **逻辑散落：** 宽度计算散布在多个方法中
2. ❌ **重复计算：** 每次调用都重新计算，无缓存
3. ❌ **难以测试：** 需要完整的 Widget 上下文
4. ❌ **耦合度高：** UI 层与计算逻辑混合
5. ❌ **扩展困难：** 新增装饰需要修改多处

#### 数据驱动（新方式）

```dart
// ✅ 解决方案 1：数据自描述
double _colWidthAtIndex(int i, List<Tuple2<String, JiaZi>> pillars) {
  final payload = widget.pillarsNotifier.value[i];
  return payload.decoration?.size.width ?? pillarWidth;  // 一行搞定
}

// ✅ 解决方案 2：自动缓存
class PillarDecoration {
  Size? _cachedSize;

  Size get size {
    if (_cachedSize != null) return _cachedSize!;
    _cachedSize = _computeSize();
    return _cachedSize!;
  }
}

// ✅ 解决方案 3：精确计算
double _columnBoundaryMidX(int idx, ...) {
  double acc = 0.0;
  for (int i = 0; i < idx; i++) {
    acc += payloads[i].decoration?.size.width ?? pillarWidth;
  }
  final decoration = payloads[idx].decoration;
  return acc + (decoration?.contentCenter.dx ?? pillarWidth / 2);
}
```

**优势总结：**

1. ✅ **封装性强：** 尺寸计算封装在数据模型中
2. ✅ **性能优化：** 支持缓存，避免重复计算
3. ✅ **易于测试：** 可独立测试尺寸计算逻辑
4. ✅ **低耦合：** UI 层与计算逻辑分离
5. ✅ **易扩展：** 新增装饰只需修改数据模型

---

## 类层次结构

### UML 类图

```
┌─────────────────────────────────────────────────────────┐
│                 EditableFourZhuCardV3                   │  // 主 Widget
├─────────────────────────────────────────────────────────┤
│ + pillarsNotifier: ValueNotifier<List<PillarPayload>>  │
│ + rowListNotifier: ValueNotifier<List<RowInfo>>        │
│ + dragFeedbackBuilder: DragFeedbackBuilder?            │
│ + columnInsertDecorationBuilder: ...                   │
│ + rowInsertDecorationBuilder: ...                      │
└─────────────────────────────────────────────────────────┘
                        │
                        │ 包含
                        ▼
┌─────────────────────────────────────────────────────────┐
│           _EditableFourZhuCardV3State                   │  // State 类
├─────────────────────────────────────────────────────────┤
│ - _pillarDecorations: Map<int, PillarDecoration>        │  ◄──┐
│ - _rowHeightOverrides: Map<int, double>                 │     │
│ - _columnWidthOverrides: Map<int, double>               │     │
│                                                         │     │
│ // 核心方法                                             │     │
│ + _initializePillarDecorations(): void                  │     │
│ + _createPillarDecoration(int): PillarDecoration        │─────┘
│ + _colWidthAtIndex(int): double                         │
│ + _columnBoundaryMidX(int): double                      │
│ + _buildColumnDraggingFeedback(int): Widget             │
└─────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────┐
│                   PillarPayload                         │  // 柱数据载荷
├─────────────────────────────────────────────────────────┤
│ + pillarType: PillarType                                │
│ + pillarContent: PillarContent?                         │
│ + decoration: PillarDecoration?                         │  ◄──┐
│ + resolveWidth(...): double                             │     │
└─────────────────────────────────────────────────────────┘     │
                                                               │
        ┌──────────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────┐
│                PillarDecoration                         │  // 柱装饰配置
├─────────────────────────────────────────────────────────┤
│ // 字段                                                 │
│ + margin: EdgeInsets                                    │
│ + padding: EdgeInsets                                   │
│ + border: BoxBorder?                                    │
│ + borderRadius: BorderRadius?                           │
│ + backgroundColor: Color?                               │
│ + boxShadow: List<BoxShadow>?                          │
│ + basePillarWidth: double                               │
│ + cells: List<CellDecoration>                           │  ◄──┐
│ - _cachedSize: Size?                                    │     │
│                                                         │     │
│ // 计算属性                                             │     │
│ + size: Size (get)                                      │     │
│ + contentSize: Size (get)                               │     │
│ + contentOffset: Offset (get)                           │     │
│ + contentCenter: Offset (get)                           │     │
│                                                         │     │
│ // 方法                                                 │     │
│ + toBoxDecoration(): BoxDecoration                      │     │
│ + invalidateCache(): void                               │     │
│ + cellAt(int): CellDecoration                           │     │
│ + copyWith(...): PillarDecoration                       │     │
│                                                         │     │
│ // 工厂方法                                             │     │
│ + PillarDecoration.normal(...)                          │     │
│ + PillarDecoration.separator(...)                       │     │
│ + PillarDecoration.ghost(...)                           │     │
└─────────────────────────────────────────────────────────┘     │
                                                               │
        ┌──────────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────┐
│                 CellDecoration                          │  // 单元格装饰
├─────────────────────────────────────────────────────────┤
│ // 字段                                                 │
│ + rowType: RowType                                      │
│ + padding: EdgeInsets                                   │
│ + border: BoxBorder?                                    │
│ + backgroundColor: Color?                               │
│ + height: double?                                       │
│ + isHeaderRow: bool                                     │
│                                                         │
│ // 计算属性                                             │
│ + effectiveHeight: double (get)                         │
│                                                         │
│ // 方法                                                 │
│ + getSize(double width): Size                           │
│ + copyWith(...): CellDecoration                         │
│                                                         │
│ // 工厂方法                                             │
│ + CellDecoration.ganZhi(...)                            │
│ + CellDecoration.divider(...)                           │
│ + CellDecoration.header(...)                            │
└─────────────────────────────────────────────────────────┘
```

### Widget 组件层次

```
PillarWidget (柱组件)
  ├── Container (margin)
  │     └── Container (padding + decoration)
  │           └── Column
  │                 ├── CellWidget (第一个单元格)
  │                 │     └── Container (padding + border + backgroundColor)
  │                 │           └── child (内容)
  │                 ├── CellWidget (第二个单元格)
  │                 │     └── ...
  │                 └── ...

GhostPillarWidget (幽灵柱组件)
  └── Container (半透明 + 虚线边框)

DraggingFeedbackWidget (拖拽反馈组件)
  └── Opacity
        └── Material (elevation + borderRadius)
              └── PillarWidget

ColumnGripWidget (列抓手组件)
  └── SizedBox (totalWidth × gripHeight)
        └── Padding (抵消 margin)
              └── Center
                    └── Draggable (抓手图标)

RowGripWidget (行抓手组件)
  └── SizedBox (gripWidth × totalHeight)
        └── Padding (抵消 margin)
              └── Center
                    └── Draggable (抓手图标)
```

---

## 数据模型详细设计

### CellDecoration

#### 完整 API

```dart
class CellDecoration {
  /// 行类型（决定默认高度）
  final RowType rowType;

  /// 内边距
  final EdgeInsets padding;

  /// 边框
  final BoxBorder? border;

  /// 背景色
  final Color? backgroundColor;

  /// 显式高度（优先级最高）
  final double? height;

  /// 是否为表头行（影响高度计算）
  final bool isHeaderRow;

  /// 构造函数
  CellDecoration({
    required this.rowType,
    this.padding = EdgeInsets.zero,
    this.border,
    this.backgroundColor,
    this.height,
    this.isHeaderRow = false,
  });

  /// 计算有效高度（核心算法）
  double get effectiveHeight {
    // 1. 优先使用显式高度
    if (height != null) return height!;

    // 2. 表头行特殊处理
    if (isHeaderRow) return DecorationDefaults.columnTitleHeight;

    // 3. 根据行类型推断
    switch (rowType) {
      case RowType.heavenlyStem:
      case RowType.earthlyBranch:
        return DecorationDefaults.ganZhiCellHeight;
      case RowType.rowDivider:
        return DecorationDefaults.dividerCellHeight;
      default:
        return DecorationDefaults.otherCellHeight;
    }
  }

  /// 计算总尺寸（含 padding + border）
  Size getSize(double pillarWidth) {
    final contentHeight = effectiveHeight;
    final borderVertical = (border?.top.width ?? 0) + (border?.bottom.width ?? 0);
    final totalHeight = contentHeight + padding.vertical + borderVertical;

    final borderHorizontal = (border?.left.width ?? 0) + (border?.right.width ?? 0);
    final totalWidth = pillarWidth + padding.horizontal + borderHorizontal;

    return Size(totalWidth, totalHeight);
  }

  /// 复制并修改部分字段
  CellDecoration copyWith({
    RowType? rowType,
    EdgeInsets? padding,
    BoxBorder? border,
    Color? backgroundColor,
    double? height,
    bool? isHeaderRow,
  }) {
    return CellDecoration(
      rowType: rowType ?? this.rowType,
      padding: padding ?? this.padding,
      border: border ?? this.border,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      height: height ?? this.height,
      isHeaderRow: isHeaderRow ?? this.isHeaderRow,
    );
  }

  /// 工厂方法：干支行装饰
  factory CellDecoration.ganZhi({
    EdgeInsets? padding,
    Color? backgroundColor,
    double? height,
  }) {
    return CellDecoration(
      rowType: RowType.heavenlyStem,
      padding: padding ?? DecorationDefaults.defaultCellPadding,
      backgroundColor: backgroundColor,
      height: height,
    );
  }

  /// 工厂方法：分隔行装饰
  factory CellDecoration.divider({
    EdgeInsets? padding,
    Color? backgroundColor,
  }) {
    return CellDecoration(
      rowType: RowType.rowDivider,
      padding: padding ?? EdgeInsets.zero,
      backgroundColor: backgroundColor,
      height: DecorationDefaults.dividerCellHeight,
    );
  }

  /// 工厂方法：表头行装饰
  factory CellDecoration.header({
    EdgeInsets? padding,
    Color? backgroundColor,
  }) {
    return CellDecoration(
      rowType: RowType.columnTitle,
      padding: padding ?? DecorationDefaults.defaultCellPadding,
      backgroundColor: backgroundColor,
      isHeaderRow: true,
    );
  }
}
```

#### 高度计算优先级

```
显式 height (最高优先级)
  ↓ (height == null)
isHeaderRow 标记
  ↓ (isHeaderRow == false)
rowType 推断
  ├── RowType.heavenlyStem / earthlyBranch → ganZhiCellHeight (48)
  ├── RowType.rowDivider → dividerCellHeight (12)
  └── 其他 → otherCellHeight (36)
```

---

### PillarDecoration

#### 完整 API

```dart
class PillarDecoration {
  /// 外边距
  final EdgeInsets margin;

  /// 内边距
  final EdgeInsets padding;

  /// 边框
  final BoxBorder? border;

  /// 圆角
  final BorderRadius? borderRadius;

  /// 背景色
  final Color? backgroundColor;

  /// 阴影
  final List<BoxShadow>? boxShadow;

  /// 基础柱宽（不含装饰）
  final double basePillarWidth;

  /// 单元格装饰列表
  final List<CellDecoration> cells;

  /// 尺寸缓存（内部使用）
  Size? _cachedSize;
  Size? _cachedContentSize;
  Offset? _cachedContentOffset;
  Offset? _cachedContentCenter;

  /// 构造函数
  PillarDecoration({
    required this.basePillarWidth,
    required this.cells,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.border,
    this.borderRadius,
    this.backgroundColor,
    this.boxShadow,
  });

  /// 计算总尺寸（含 margin + border + padding + cells）
  Size get size {
    if (_cachedSize != null) return _cachedSize!;
    _cachedSize = _computeSize();
    return _cachedSize!;
  }

  Size _computeSize() {
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
    if (_cachedContentSize != null) return _cachedContentSize!;
    final s = size;
    _cachedContentSize = Size(
      s.width - margin.horizontal,
      s.height - margin.vertical,
    );
    return _cachedContentSize!;
  }

  /// 内容区起始偏移（相对于 size 左上角）
  Offset get contentOffset {
    if (_cachedContentOffset != null) return _cachedContentOffset!;
    _cachedContentOffset = Offset(
      margin.left + (border?.left.width ?? 0) + padding.left,
      margin.top + (border?.top.width ?? 0) + padding.top,
    );
    return _cachedContentOffset!;
  }

  /// 内容区中点（用于让位边界）
  Offset get contentCenter {
    if (_cachedContentCenter != null) return _cachedContentCenter!;
    final offset = contentOffset;
    final cSize = contentSize;
    _cachedContentCenter = Offset(
      offset.dx + (cSize.width - padding.horizontal) / 2,
      offset.dy + (cSize.height - padding.vertical) / 2,
    );
    return _cachedContentCenter!;
  }

  /// 失效所有缓存（当 cells 或装饰属性变化时调用）
  void invalidateCache() {
    _cachedSize = null;
    _cachedContentSize = null;
    _cachedContentOffset = null;
    _cachedContentCenter = null;
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

  /// 获取指定行的单元格装饰
  CellDecoration cellAt(int rowIndex) {
    if (rowIndex < 0 || rowIndex >= cells.length) {
      throw RangeError('rowIndex $rowIndex out of range [0, ${cells.length})');
    }
    return cells[rowIndex];
  }

  /// 复制并修改部分字段
  PillarDecoration copyWith({
    EdgeInsets? margin,
    EdgeInsets? padding,
    BoxBorder? border,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    List<BoxShadow>? boxShadow,
    double? basePillarWidth,
    List<CellDecoration>? cells,
  }) {
    return PillarDecoration(
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      boxShadow: boxShadow ?? this.boxShadow,
      basePillarWidth: basePillarWidth ?? this.basePillarWidth,
      cells: cells ?? this.cells,
    );
  }

  /// 工厂方法：普通柱装饰（带 margin/padding/border/shadow）
  factory PillarDecoration.normal({
    required List<CellDecoration> cells,
    double basePillarWidth = DecorationDefaults.basePillarWidth,
    EdgeInsets? margin,
    EdgeInsets? padding,
    BoxBorder? border,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    List<BoxShadow>? boxShadow,
  }) {
    return PillarDecoration(
      margin: margin ?? DecorationDefaults.defaultPillarMargin,
      padding: padding ?? DecorationDefaults.defaultPillarPadding,
      border: border ?? Border.all(color: Colors.green, width: 2),
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      backgroundColor: backgroundColor ?? Colors.red.withAlpha(10),
      boxShadow: boxShadow ?? [
        BoxShadow(
          offset: Offset(1, 1),
          color: Colors.black.withAlpha(20),
          blurRadius: 2,
          spreadRadius: 2,
        ),
      ],
      cells: cells,
      basePillarWidth: basePillarWidth,
    );
  }

  /// 工厂方法：分隔柱装饰（窄宽度，无装饰）
  factory PillarDecoration.separator({
    required double totalHeight,
    double separatorWidth = DecorationDefaults.separatorPillarWidth,
  }) {
    return PillarDecoration(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(horizontal: 4),
      border: null,
      borderRadius: null,
      backgroundColor: null,
      boxShadow: null,
      cells: [],  // 分隔符没有 cells
      basePillarWidth: separatorWidth - 8,  // 减去 padding
    );
  }

  /// 工厂方法：幽灵柱装饰（半透明，虚线边框）
  factory PillarDecoration.ghost({
    required List<CellDecoration> cells,
    double basePillarWidth = DecorationDefaults.basePillarWidth,
  }) {
    return PillarDecoration(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.all(4),
      border: Border.all(color: Colors.blue.withOpacity(0.5), width: 2),
      borderRadius: BorderRadius.circular(8),
      backgroundColor: Colors.blue.withOpacity(0.1),
      boxShadow: null,  // 幽灵柱无阴影
      cells: cells,
      basePillarWidth: basePillarWidth,
    );
  }
}
```

#### 尺寸计算详解

##### 1. size（总尺寸）

```
┌────────────────── totalWidth ─────────────────────┐
│                                                   │
│  ┌─── margin.left                                │
│  │                                                │
│  │  ┌─── border.left.width                       │
│  │  │                                             │
│  │  │  ┌─── padding.left                         │
│  │  │  │                                          │
│  │  │  │  ┌──── basePillarWidth ────┐            │
│  │  │  │  │                          │            │
├──┼──┼──┼──┼──────────────────────────┼────┬───────┤
│  │  │  │  │                          │    │       │
│  │  │  │  │    Cell Content          │    │       │
│  │  │  │  │                          │    │       │
│  │  │  │  └──────────────────────────┘    │       │
│  │  │  └─ padding.right                   │       │
│  │  └─ border.right.width                 │       │
│  └─ margin.right                           │       │
└───────────────────────────────────────────┴───────┘

totalWidth = margin.left + border.left.width + padding.left +
             basePillarWidth +
             padding.right + border.right.width + margin.right

totalHeight = margin.top + border.top.width + padding.top +
              Σ(cell.effectiveHeight) +
              padding.bottom + border.bottom.width + margin.bottom
```

##### 2. contentSize（内容区尺寸）

```
contentSize = Size(
  size.width - margin.horizontal,   // 不含 margin
  size.height - margin.vertical,
)
```

##### 3. contentOffset（内容区起始偏移）

```
contentOffset = Offset(
  margin.left + border.left.width + padding.left,
  margin.top + border.top.width + padding.top,
)
```

##### 4. contentCenter（内容区中点）

```
contentCenter = Offset(
  contentOffset.dx + (basePillarWidth) / 2,  // 精确到内容宽度中点
  contentOffset.dy + (Σ cell.effectiveHeight) / 2,
)
```

---

### DecorationDefaults

#### 常量定义

```dart
class DecorationDefaults {
  // 单元格高度
  static const double ganZhiCellHeight = 48.0;      // 干支行高度
  static const double otherCellHeight = 36.0;       // 其他行高度
  static const double dividerCellHeight = 12.0;     // 分隔行高度
  static const double columnTitleHeight = 40.0;     // 表头行高度

  // 柱宽度
  static const double basePillarWidth = 64.0;       // 基础柱宽
  static const double separatorPillarWidth = 16.0;  // 分隔柱宽

  // 内边距
  static const EdgeInsets defaultCellPadding = EdgeInsets.symmetric(
    vertical: 4,
    horizontal: 8,
  );

  static const EdgeInsets defaultPillarPadding = EdgeInsets.all(6);

  // 外边距
  static const EdgeInsets defaultPillarMargin = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 8,
  );

  // 边框
  static final BoxBorder defaultPillarBorder = Border.all(
    color: Colors.green,
    width: 2,
  );

  // 圆角
  static final BorderRadius defaultPillarBorderRadius = BorderRadius.circular(12);

  // 阴影
  static final List<BoxShadow> defaultPillarBoxShadow = [
    BoxShadow(
      offset: Offset(1, 1),
      color: Colors.black.withAlpha(20),
      blurRadius: 2,
      spreadRadius: 2,
    ),
  ];

  // 背景色
  static final Color defaultPillarBackgroundColor = Colors.red.withAlpha(10);
}
```

---

## Widget 组件详细设计

### CellWidget

#### 完整 API

```dart
class CellWidget extends StatelessWidget {
  /// 单元格装饰
  final CellDecoration decoration;

  /// 单元格内容
  final Widget child;

  /// 单元格宽度
  final double width;

  const CellWidget({
    Key? key,
    required this.decoration,
    required this.child,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: decoration.padding,
      decoration: BoxDecoration(
        color: decoration.backgroundColor,
        border: decoration.border,
      ),
      width: width,
      height: decoration.effectiveHeight,
      child: child,
    );
  }
}
```

#### 使用示例

```dart
CellWidget(
  decoration: CellDecoration.ganZhi(
    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    backgroundColor: Colors.white,
  ),
  width: 64,
  child: Text('甲子', style: TextStyle(fontSize: 16)),
)
```

---

### PillarWidget

#### 完整 API

```dart
class PillarWidget extends StatelessWidget {
  /// 柱装饰
  final PillarDecoration decoration;

  /// 单元格内容列表
  final List<Widget> children;

  const PillarWidget({
    Key? key,
    required this.decoration,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 外层 Container: margin
    return Container(
      margin: decoration.margin,
      width: decoration.size.width,
      // 中层 Container: padding + decoration
      child: Container(
        padding: decoration.padding,
        decoration: decoration.toBoxDecoration(),
        // 内层 Column: cells
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(children.length, (i) {
            final cell = decoration.cells[i];
            return CellWidget(
              decoration: cell,
              width: decoration.basePillarWidth,
              child: children[i],
            );
          }),
        ),
      ),
    );
  }

  /// 工厂方法：幽灵柱变体
  factory PillarWidget.ghost({
    required PillarDecoration decoration,
    required List<Widget> children,
  }) {
    final ghostDecoration = decoration.copyWith(
      backgroundColor: decoration.backgroundColor?.withOpacity(0.3),
      border: Border.all(color: Colors.blue.withOpacity(0.5), width: 2),
      boxShadow: null,  // 移除阴影
    );

    return PillarWidget(
      decoration: ghostDecoration,
      children: children,
    );
  }
}
```

#### 使用示例

```dart
PillarWidget(
  decoration: PillarDecoration.normal(
    cells: [
      CellDecoration.ganZhi(),
      CellDecoration.ganZhi(),
      CellDecoration.ganZhi(),
      CellDecoration.ganZhi(),
    ],
    basePillarWidth: 64,
  ),
  children: [
    Text('甲'),
    Text('子'),
    Text('甲'),
    Text('子'),
  ],
)
```

---

### GhostPillarWidget

#### 完整 API

```dart
class GhostPillarWidget extends StatelessWidget {
  /// 幽灵柱宽度
  final double width;

  /// 幽灵柱高度
  final double height;

  /// 边框颜色
  final Color borderColor;

  /// 背景色
  final Color backgroundColor;

  const GhostPillarWidget({
    Key? key,
    required this.width,
    required this.height,
    this.borderColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.blue.withOpacity(0.1),
        border: Border.all(
          color: borderColor ?? Colors.blue.withOpacity(0.5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
```

#### 使用示例

```dart
// 拖拽时显示的插入位置提示
GhostPillarWidget(
  width: _externalColHoverWidth ?? 64,
  height: _totalRowsHeight(),
)
```

---

### DraggingFeedbackWidget

#### 完整 API

```dart
class DraggingFeedbackWidget extends StatelessWidget {
  /// 柱装饰
  final PillarDecoration decoration;

  /// 单元格内容列表
  final List<Widget> children;

  /// 不透明度
  final double opacity;

  /// 缩放比例
  final double scale;

  const DraggingFeedbackWidget({
    Key? key,
    required this.decoration,
    required this.children,
    this.opacity = 0.7,
    this.scale = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Material(
          elevation: 4,
          borderRadius: decoration.borderRadius,
          child: PillarWidget(
            decoration: decoration,
            children: children,
          ),
        ),
      ),
    );
  }
}
```

#### 使用示例

```dart
// 拖拽反馈视图
Draggable<Object>(
  feedback: DraggingFeedbackWidget(
    decoration: _pillarDecorations[pillarIndex]!,
    children: _buildCellChildren(pillarIndex),
    opacity: 0.7,
    scale: 1.05,  // 拖拽时稍微放大
  ),
  ...
)
```

---

### GripWidget

#### ColumnGripWidget

```dart
class ColumnGripWidget extends StatelessWidget {
  /// 总宽度（含 margin）
  final double width;

  /// 抓手高度
  final double height;

  /// 水平 padding（用于抵消 margin）
  final double horizontalPadding;

  /// 抓手图标
  final Widget child;

  const ColumnGripWidget({
    Key? key,
    required this.width,
    required this.height,
    required this.horizontalPadding,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Center(child: child),
      ),
    );
  }
}
```

#### RowGripWidget

```dart
class RowGripWidget extends StatelessWidget {
  /// 抓手宽度
  final double width;

  /// 总高度（含 margin）
  final double height;

  /// 垂直 padding（用于抵消 margin）
  final double verticalPadding;

  /// 抓手图标
  final Widget child;

  const RowGripWidget({
    Key? key,
    required this.width,
    required this.height,
    required this.verticalPadding,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        child: Center(child: child),
      ),
    );
  }
}
```

---

## 与现有系统的集成

### 与拖拽系统集成

#### 不影响 Draggable/DragTarget

```dart
// topGripRow 的列抓手
Draggable<Tuple2<_DragKind, int>>(
  data: Tuple2(_DragKind.column, i),
  feedback: DraggingFeedbackWidget(  // ✅ 使用新的反馈 Widget
    decoration: _pillarDecorations[i]!,
    children: _buildCellChildren(i),
  ),
  child: ColumnGripWidget(  // ✅ 使用新的抓手 Widget
    width: _pillarDecorations[i]!.size.width,
    height: dragHandleRowHeight,
    horizontalPadding: _pillarDecorations[i]!.margin.horizontal / 2,
    child: Icon(Icons.drag_indicator),
  ),
)
```

### 与动画系统集成

#### AnimatedOpacity

```dart
// dataGrid 的柱淡出动画
AnimatedOpacity(
  opacity: (_dropColFadeActive && _dropAnimatingColIndex == i) ? 0.0 : 1.0,
  duration: _dropColFadeDuration,
  child: PillarWidget(  // ✅ 直接使用 PillarWidget
    decoration: _pillarDecorations[i]!,
    children: _buildCellChildren(i),
  ),
)
```

#### AnimatedContainer

```dart
// 幽灵柱出现动画
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  width: showGhost ? _getGhostColumnWidth() : 0,
  child: showGhost
    ? GhostPillarWidget(  // ✅ 使用 GhostPillarWidget
        width: _getGhostColumnWidth(),
        height: _totalRowsHeight(),
      )
    : SizedBox.shrink(),
)
```

### 坐标转换的精确性保证

#### 让位边界计算

```dart
double _columnBoundaryMidX(int idx, List<Tuple2<String, JiaZi>> pillars) {
  final payloads = widget.pillarsNotifier.value;

  // 累加前面所有柱的总宽度
  double acc = 0.0;
  for (int i = 0; i < idx; i++) {
    final decoration = _pillarDecorations[i];
    acc += decoration?.size.width ?? pillarWidth;
  }

  // 加上当前柱的内容区中点偏移
  final decoration = _pillarDecorations[idx];
  if (decoration != null) {
    return acc + decoration.contentCenter.dx;  // ✅ 精确的内容区中点
  }

  return acc + pillarWidth / 2;
}
```

#### 尺寸一致性保证

```
┌─────────────────────────────────────────────────────┐
│                   尺寸一致性原则                     │
├─────────────────────────────────────────────────────┤
│ 1. 所有使用同一柱的组件必须使用相同的 decoration    │
│ 2. topGripRow 的抓手宽度 = decoration.size.width    │
│ 3. dataGrid 的柱宽度 = decoration.size.width        │
│ 4. 拖拽反馈的柱宽度 = decoration.size.width         │
│ 5. 幽灵柱的宽度 = externalDecoration.size.width     │
│                                                     │
│ ✅ 保证：抓手、柱、反馈、幽灵元素的尺寸完全一致    │
└─────────────────────────────────────────────────────┘
```

---

## 尺寸计算算法详解

### 算法 1：单元格有效高度

```
effectiveHeight =
  if height != null:
    height  (显式高度，最高优先级)
  else if isHeaderRow:
    columnTitleHeight  (表头行高度)
  else:
    switch rowType:
      case heavenlyStem / earthlyBranch:
        ganZhiCellHeight
      case rowDivider:
        dividerCellHeight
      default:
        otherCellHeight
```

**示例：**

```dart
// 示例 1：显式高度
final cell1 = CellDecoration(
  rowType: RowType.heavenlyStem,
  height: 60,  // 显式高度
);
print(cell1.effectiveHeight);  // 输出：60.0

// 示例 2：表头行
final cell2 = CellDecoration(
  rowType: RowType.columnTitle,
  isHeaderRow: true,
);
print(cell2.effectiveHeight);  // 输出：40.0 (columnTitleHeight)

// 示例 3：干支行
final cell3 = CellDecoration(
  rowType: RowType.heavenlyStem,
);
print(cell3.effectiveHeight);  // 输出：48.0 (ganZhiCellHeight)
```

### 算法 2：柱总尺寸

```
totalWidth =
  margin.left +
  border.left.width +
  padding.left +
  basePillarWidth +
  padding.right +
  border.right.width +
  margin.right

totalHeight =
  margin.top +
  border.top.width +
  padding.top +
  Σ(cell.effectiveHeight for cell in cells) +
  padding.bottom +
  border.bottom.width +
  margin.bottom
```

**示例：**

```dart
final decoration = PillarDecoration(
  margin: EdgeInsets.all(8),          // 8 * 2 = 16
  padding: EdgeInsets.all(6),         // 6 * 2 = 12
  border: Border.all(width: 2),       // 2 * 2 = 4
  basePillarWidth: 64,
  cells: [
    CellDecoration(rowType: RowType.heavenlyStem, height: 48),
    CellDecoration(rowType: RowType.earthlyBranch, height: 48),
  ],
);

// 宽度计算
print(decoration.size.width);
// = 8 + 2 + 6 + 64 + 6 + 2 + 8
// = 96

// 高度计算
print(decoration.size.height);
// = 8 + 2 + 6 + (48 + 48) + 6 + 2 + 8
// = 128
```

### 算法 3：内容区中点

```
contentCenter.dx =
  margin.left +
  border.left.width +
  padding.left +
  (basePillarWidth / 2)

contentCenter.dy =
  margin.top +
  border.top.width +
  padding.top +
  (Σ cell.effectiveHeight / 2)
```

**示例：**

```dart
final decoration = PillarDecoration(
  margin: EdgeInsets.all(8),
  padding: EdgeInsets.all(6),
  border: Border.all(width: 2),
  basePillarWidth: 64,
  cells: [
    CellDecoration(rowType: RowType.heavenlyStem, height: 48),
    CellDecoration(rowType: RowType.earthlyBranch, height: 48),
  ],
);

print(decoration.contentCenter);
// dx = 8 + 2 + 6 + (64 / 2) = 48
// dy = 8 + 2 + 6 + ((48 + 48) / 2) = 64
// Offset(48.0, 64.0)
```

---

## 代码示例

### 示例 1：创建普通柱装饰

```dart
final pillarDecoration = PillarDecoration.normal(
  cells: [
    CellDecoration.ganZhi(backgroundColor: Colors.white),
    CellDecoration.ganZhi(backgroundColor: Colors.white),
    CellDecoration.ganZhi(backgroundColor: Colors.grey[100]),
    CellDecoration.ganZhi(backgroundColor: Colors.grey[100]),
  ],
  basePillarWidth: 64,
);

// 使用装饰
final pillarWidget = PillarWidget(
  decoration: pillarDecoration,
  children: [
    Text('甲', style: TextStyle(fontSize: 18)),
    Text('子', style: TextStyle(fontSize: 18)),
    Text('甲', style: TextStyle(fontSize: 18)),
    Text('子', style: TextStyle(fontSize: 18)),
  ],
);
```

### 示例 2：创建幽灵柱

```dart
final ghostDecoration = PillarDecoration.ghost(
  cells: [
    CellDecoration.ganZhi(),
    CellDecoration.ganZhi(),
    CellDecoration.ganZhi(),
    CellDecoration.ganZhi(),
  ],
  basePillarWidth: 64,
);

final ghostWidget = GhostPillarWidget(
  width: ghostDecoration.size.width,
  height: ghostDecoration.size.height,
);
```

### 示例 3：创建拖拽反馈

```dart
Widget _buildColumnDraggingFeedback(int pillarIndex) {
  final decoration = _pillarDecorations[pillarIndex]!;
  final children = _buildCellChildren(pillarIndex);

  return DraggingFeedbackWidget(
    decoration: decoration,
    children: children,
    opacity: 0.7,
    scale: 1.05,  // 拖拽时稍微放大
  );
}
```

### 示例 4：处理行高度覆盖

```dart
void _updateRowHeightOverride(int rowIndex, double newHeight) {
  setState(() {
    _rowHeightOverrides[rowIndex] = newHeight;

    // 重新创建所有柱的 decoration
    _initializePillarDecorations();
  });
}

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
      padding: DecorationDefaults.defaultCellPadding,
    );
  }).toList();

  return PillarDecoration.normal(
    cells: cellDecorations,
    basePillarWidth: pillarWidth,
  );
}
```

### 示例 5：响应行列表变化

```dart
@override
void initState() {
  super.initState();

  // 监听行列表变化
  widget.rowListNotifier.addListener(() {
    setState(() {
      // 失效所有柱的缓存
      for (final decoration in _pillarDecorations.values) {
        decoration.invalidateCache();
      }

      // 重新初始化 decorations（更新 cells 列表）
      _initializePillarDecorations();
    });
  });
}
```

### 示例 6：抓手对齐

```dart
// topGripRow
Row(
  children: List.generate(pillars.length, (i) {
    final decoration = _pillarDecorations[i];
    final totalWidth = decoration?.size.width ?? pillarWidth;

    return ColumnGripWidget(
      width: totalWidth,
      height: dragHandleRowHeight,
      horizontalPadding: decoration != null
        ? decoration.margin.horizontal / 2
        : 0,
      child: Draggable<Tuple2<_DragKind, int>>(
        data: Tuple2(_DragKind.column, i),
        feedback: _buildColumnDraggingFeedback(i),
        child: Icon(Icons.drag_indicator, size: 16),
      ),
    );
  }),
)
```

### 示例 7：dataGrid 渲染

```dart
// dataGrid
List.generate(pillars.length, (i) {
  final decoration = _pillarDecorations[i];
  final columnContent = _buildColumnContent(i);

  return AnimatedOpacity(
    opacity: (_dropColFadeActive && _dropAnimatingColIndex == i) ? 0.0 : 1.0,
    duration: _dropColFadeDuration,
    child: decoration != null
      ? Container(
          margin: decoration.margin,  // ✅ 外层 margin
          child: Container(
            padding: decoration.padding,  // ✅ 中层 padding
            decoration: decoration.toBoxDecoration(),
            child: SizedBox(
              width: decoration.basePillarWidth,  // ✅ 精确的内容宽度
              child: columnContent,
            ),
          ),
        )
      : SizedBox(
          width: pillarWidth,
          child: columnContent,
        ),
  );
})
```

### 示例 8：幽灵列渲染

```dart
// gripColumn 幽灵列
if (_hoveringExternalPillar && _hoverColumnInsertIndex != null) {
  final ghostWidth = _externalPillarDecoration?.size.width ??
                     _externalColHoverWidth ??
                     pillarWidth;

  GhostPillarWidget(
    width: ghostWidth,
    height: dragHandleRowHeight,
  )
}
```

### 示例 9：让位边界计算

```dart
double _columnBoundaryMidX(int idx, List<Tuple2<String, JiaZi>> pillars) {
  // 累加前面所有柱的总宽度
  double acc = 0.0;
  for (int i = 0; i < idx; i++) {
    final decoration = _pillarDecorations[i];
    acc += decoration?.size.width ?? pillarWidth;
  }

  // 加上当前柱的内容区中点偏移
  final decoration = _pillarDecorations[idx];
  if (decoration != null) {
    return acc + decoration.contentCenter.dx;  // ✅ 精确
  }

  return acc + pillarWidth / 2;  // 兜底逻辑
}
```

### 示例 10：单元测试

```dart
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

  // 宽度计算
  expect(decoration.size.width, 64 + 12 + 4 + 16);  // 96

  // 高度计算
  expect(decoration.size.height, 96 + 12 + 4 + 16);  // 128

  // 内容区中点
  expect(decoration.contentCenter.dx, 8 + 2 + 6 + 32);  // 48
  expect(decoration.contentCenter.dy, 8 + 2 + 6 + 48);  // 64
});

test('CellDecoration effective height priority', () {
  // 优先级 1：显式高度
  final cell1 = CellDecoration(
    rowType: RowType.heavenlyStem,
    height: 60,
  );
  expect(cell1.effectiveHeight, 60);

  // 优先级 2：表头行
  final cell2 = CellDecoration(
    rowType: RowType.columnTitle,
    isHeaderRow: true,
  );
  expect(cell2.effectiveHeight, 40);  // columnTitleHeight

  // 优先级 3：rowType 推断
  final cell3 = CellDecoration(
    rowType: RowType.heavenlyStem,
  );
  expect(cell3.effectiveHeight, 48);  // ganZhiCellHeight
});

test('PillarDecoration cache mechanism', () {
  final decoration = PillarDecoration(
    margin: EdgeInsets.all(8),
    cells: [CellDecoration(rowType: RowType.heavenlyStem, height: 48)],
    basePillarWidth: 64,
  );

  // 第一次调用
  final size1 = decoration.size;
  expect(size1.width, 64 + 16);

  // 第二次调用（应返回缓存值）
  final size2 = decoration.size;
  expect(identical(size1, size2), true);  // ✅ 缓存生效

  // 失效缓存
  decoration.invalidateCache();

  // 第三次调用（重新计算）
  final size3 = decoration.size;
  expect(identical(size2, size3), false);  // ✅ 缓存已失效
});
```

---

## 设计决策记录

### ADR-001: 使用 margin/padding/border 分层结构

**上下文：** 柱装饰需要同时支持外边距、内边距、边框、圆角、阴影等多种样式。

**决策：** 采用 CSS 盒模型的分层结构：`margin` → `border` → `padding` → `content`。

**理由：**

1. ✅ 符合开发者对 CSS 盒模型的认知
2. ✅ 可精确控制每一层的尺寸
3. ✅ 易于计算 `contentCenter`（内容区中点）
4. ✅ 与 Flutter 的 `Container` API 一致

**后果：**

- 尺寸计算略复杂（需累加多层）
- 但换来精确的布局控制

---

### ADR-002: 使用缓存机制优化尺寸计算

**上下文：** `size`、`contentSize`、`contentCenter` 等计算属性可能被频繁调用（每次 build 都会调用）。

**决策：** 添加内部缓存字段 `_cachedSize`、`_cachedContentSize` 等，首次计算后缓存结果。

**理由：**

1. ✅ 避免重复计算，提升性能
2. ✅ 缓存对外部透明，不影响 API
3. ✅ 支持手动失效缓存 `invalidateCache()`

**后果：**

- 需要在 `cells` 或装饰属性变化时手动调用 `invalidateCache()`
- 内存占用略微增加（缓存 4 个对象）

---

### ADR-003: 新建文件而非修改现有代码

**上下文：** 重构风险较高，需要确保可安全回滚。

**决策：** 所有数据模型和 Widget 组件都创建为新文件，尽量减少对现有文件的修改。

**理由：**

1. ✅ 降低回滚成本（直接删除新文件）
2. ✅ 新旧代码可并存，便于对比测试
3. ✅ 阶段性验收更安全

**后果：**

- 文件数量增加（新增 10+ 个文件）
- 但换来更安全的重构流程

---

### ADR-004: 优先使用工厂方法而非多个构造函数

**上下文：** `PillarDecoration` 和 `CellDecoration` 有多种常见配置（normal、ghost、separator、ganZhi、divider、header）。

**决策：** 使用命名工厂方法 `PillarDecoration.normal()`、`CellDecoration.ganZhi()` 等。

**理由：**

1. ✅ 语义清晰，易于理解
2. ✅ 可提供合理的默认值
3. ✅ 扩展性强（新增配置只需添加新工厂方法）
4. ✅ 符合 Dart 的最佳实践

**后果：**

- 类内部方法数量增加
- 但换来更简洁的调用方式

---

### ADR-005: 使用 Offset 和 Size 而非 double

**上下文：** 需要表示位置（contentOffset、contentCenter）和尺寸（size、contentSize）。

**决策：** 使用 Dart 的 `Offset` 和 `Size` 类，而非单独的 `double` 字段。

**理由：**

1. ✅ 类型安全，避免混淆 x/y 或 width/height
2. ✅ 语义明确，易于理解
3. ✅ 可直接用于 Flutter 的 API（如 `Positioned`、`SizedBox`）
4. ✅ 支持运算（如 `Size.lerp`、`Offset.distance`）

**后果：**

- 无明显劣势

---

### ADR-006: 支持显式高度覆盖（height 字段）

**上下文：** 用户可能手动调整某一行的高度（通过 `_rowHeightOverrides`）。

**决策：** `CellDecoration` 添加 `height` 字段，优先级最高。

**理由：**

1. ✅ 支持动态调整行高度
2. ✅ 优先级明确：`height` > `isHeaderRow` > `rowType` 推断
3. ✅ 易于测试

**后果：**

- 高度计算逻辑略复杂（需判断 3 层优先级）
- 但换来灵活性

---

### ADR-007: 分隔符柱特殊处理

**上下文：** 分隔符柱的宽度很窄，且没有 cells。

**决策：** 添加工厂方法 `PillarDecoration.separator()`，`cells` 为空列表。

**理由：**

1. ✅ 避免为分隔符创建虚拟 cells
2. ✅ 尺寸计算特殊处理（cells 为空时使用固定高度）
3. ✅ 语义清晰

**后果：**

- `size` 计算需特殊判断 `cells.isEmpty`
- 但换来简洁的 API

---

## 总结

这个架构设计实现了：

1. **数据驱动** - 数据自描述尺寸，而非外部计算
2. **单一职责** - 每个类只负责自己的尺寸计算
3. **易维护** - 修改规则只需改一个地方
4. **易测试** - 可独立测试尺寸计算逻辑
5. **高性能** - 支持缓存，避免重复计算
6. **类型安全** - 使用 Size/Offset 语义明确
7. **易扩展** - 支持动画、响应式等未来需求
8. **低耦合** - UI 层与计算逻辑分离

通过这个重构，可以彻底解决当前的抓手对齐、overflow、让位边界等问题，并为未来的功能扩展打下坚实基础。

---

**祝重构顺利！** 🚀
