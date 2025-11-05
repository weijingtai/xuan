# 阶段 5: 幽灵元素代码分析

**分析时间**: 2025-11-04
**文件**: `lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart`

---

## 📊 幽灵元素状态变量

### 列幽灵 (Ghost Column) 状态
- `bool _hoveringExternalPillar` (line 248): 是否有外部柱悬停
- `double _externalColHoverWidth` (line 251): 外部柱的宽度
- `int? _hoverColumnInsertIndex` (line 225): 当前插入位索引
- `int? _lastColInsertIndex` (line 244): 上次插入位索引

### 行幽灵 (Ghost Row) 状态
- `bool _hoveringExternalRow` (line 249): 是否有外部行悬停
- `double _externalRowHoverHeight` (line 250): 外部行的高度
- `int? _hoverRowInsertIndex` (line 230): 当前插入位索引
- `int? _lastRowInsertIndex` (line 245): 上次插入位索引

---

## 🔍 幽灵宽度计算逻辑

### 位置 1: 主布局计算 (Line 430-432)
```dart
final double ghostWidth = hasColGhost && _externalColHoverWidth > 0
    ? _externalColHoverWidth
    : pillarWidth;
```

### 位置 2: topGripRow 区域 (Line 742-744)
```dart
final bool hasColGhost = _hoveringExternalPillar && !rowDraggingActive;
double ghostWidth = hasColGhost && _externalColHoverWidth > 0
    ? _externalColHoverWidth
    : pillarWidth;
```

**问题**: 相同的逻辑重复了 2 次，应该提取为方法。

---

## 🎯 幽灵列渲染位置

### 1. topGripRow (gripColumn) 区域幽灵列 (Line 1490-1524)
```dart
final bool dragging = (d != null || _hoveringExternalPillar) &&
    !rowDraggingActive;
final double gridGhostWidth =
    (d != null) ? _colWidthAtIndex(d, pillars) : ghostWidth;

children.add(AnimatedContainer(
  width: (dragging && t == i) ? gridGhostWidth : 0,
  duration: _ghostAnimDuration,
  child: (dragging && t == i)
      ? SizedBox(
          width: gridGhostWidth,
          height: dragHandleRowHeight,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(20),
              border: Border.all(
                color: Colors.blue.withAlpha(128),
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
          ),
        )
      : const SizedBox.shrink(),
));
```

**改进方向**: 使用 `GhostPillarWidget`

### 2. dataGrid 末尾幽灵列 (Line 1862-1876)
```dart
final bool dragging =
    (d != null || _hoveringExternalPillar) && !rowDraggingActive;
final double endGhostWidth =
    (d != null) ? _colWidthAtIndex(d, pillars) : ghostWidth;
children.add(AnimatedContainer(
  width: (dragging && t == pillars.length) ? endGhostWidth : 0,
  duration: _ghostAnimDuration,
  child: (dragging && t == pillars.length)
      ? Container(
          width: endGhostWidth,
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha(20),
            border: Border.all(
              color: Colors.blue.withAlpha(128),
              width: 1.5,
            ),
          ),
        )
      : const SizedBox.shrink(),
));
```

**改进方向**: 使用 `GhostPillarWidget`

### 3. dataGrid 行间幽灵列 (Line 1626-1660)
与位置 1 类似的 AnimatedContainer 结构，使用相同的蓝色半透明装饰。

**改进方向**: 使用 `GhostPillarWidget`

---

## 🎯 幽灵行渲染位置

### 1. leftGripColumn 区域幽灵行 (Line 958-1051)
```dart
final bool draggingRow = d != null || _hoveringExternalRow;

// 在每个行前插入幽灵行
if (draggingRow && t == absRowIdx) {
  final ghostHeight = (d != null)
      ? _rowCellSize(rows[d]).height
      : _externalRowHoverHeight;
  children.add(AnimatedContainer(
    height: (draggingRow && t == absRowIdx) ? ghostHeight : 0,
    duration: _ghostAnimDuration,
    child: (draggingRow && t == absRowIdx)
        ? Container(
            height: ghostHeight,
            width: dragHandleColWidth,
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(20),
              border: Border.all(
                color: Colors.green.withAlpha(128),
                width: 1.5,
              ),
            ),
          )
        : const SizedBox.shrink(),
  ));
}
```

### 2. leftHeader 区域幽灵行 (Line 1097-1219)
与位置 1 类似的逻辑，绿色半透明装饰。

### 3. dataGrid 区域幽灵行 (Line 1539-1634)
与位置 1、2 类似的逻辑，绿色半透明装饰。

---

## 📊 幽灵高度计算逻辑

### 当前实现 (重复 3 次)
```dart
final ghostHeight = (d != null)
    ? _rowCellSize(rows[d]).height
    : _externalRowHoverHeight;
```

**问题**:
1. 当拖拽行到 `insertIndex=0` (表头行位置) 时，可能出现高度跳变
2. 未考虑 `_rowHeightOverrides` 的影响
3. 逻辑重复 3 次

---

## 🔧 改进计划

### 任务 5.3: 创建 `_getGhostColumnWidth()` 方法
**目标**: 统一幽灵列宽度计算逻辑

**实现**:
```dart
double _getGhostColumnWidth() {
  // 优先使用外部柱的 decoration (如果有的话)
  if (_hoveringExternalPillar && _externalPillarDecoration != null) {
    return _externalPillarDecoration!.size.width;
  }

  // 否则使用 _externalColHoverWidth
  if (_externalColHoverWidth > 0) {
    return _externalColHoverWidth;
  }

  // 兜底：使用默认柱宽
  return pillarWidth;
}
```

### ��务 5.4: 替换 gripColumn 和 dataGrid 幽灵列
**目标**: 使用 `GhostPillarWidget` 统一渲染

**替换位置**:
- Line 1490-1524 (gripColumn)
- Line 1626-1660 (dataGrid 中间)
- Line 1862-1876 (dataGrid 末尾)

**统一渲染**:
```dart
GhostPillarWidget(
  width: _getGhostColumnWidth(),
  height: dragHandleRowHeight, // 或数据网格高度
)
```

### 任务 5.5: 优化幽灵行高度计算
**目标**: 创建 `_getGhostRowHeight()` 方法处理 insertIndex=0 的跳变问题

**实现**:
```dart
double _getGhostRowHeight(int rowIndex) {
  // 优先使用 _rowHeightOverrides
  if (_rowHeightOverrides.containsKey(rowIndex)) {
    return _rowHeightOverrides[rowIndex]!;
  }

  // 否则根据 rowType 推断默认高度
  if (rowIndex >= 0 && rowIndex < widget.rowListNotifier.value.length) {
    final row = widget.rowListNotifier.value[rowIndex];
    return _getDefaultRowHeight(row.rowType);
  }

  // 兜底：使用外部行高度或默认高度
  return _externalRowHoverHeight > 0 ? _externalRowHoverHeight : 48.0;
}
```

---

## 🎨 GhostPillarWidget 规范

### 期望样式
- **背景色**: `Colors.blue.withAlpha(20)` (列) / `Colors.green.withAlpha(20)` (行)
- **边框**: `Border.all(color: Colors.blue/green.withAlpha(128), width: 1.5)`
- **圆角**: `BorderRadius.circular(8)` (可选)
- **动画**: `AnimatedContainer` 包裹，duration = `_ghostAnimDuration`

### 统一规范建议
使用 `GhostPillarWidget` 的命名参数控制颜色：
```dart
GhostPillarWidget(
  width: _getGhostColumnWidth(),
  height: dragHandleRowHeight,
  color: Colors.blue, // 或 Colors.green (行)
)
```

---

## 📝 关键发现

1. **重复代码**: 幽灵宽度计算逻辑重复 2 次
2. **渲染位置**: 幽灵列 3 个位置，幽灵行 3 个位置，共 6 个位置
3. **装饰不统一**: 虽然都是半透明 + 边框，但代码分散，难以维护
4. **高度跳变风险**: 拖拽到 insertIndex=0 时可能出现高度不一致

---

## ✅ 验收标准

完成阶段 5 后：
- ✅ 幽灵列宽度由 `_getGhostColumnWidth()` 统一计算
- ✅ 幽灵行高度由 `_getGhostRowHeight()` 统一计算
- ✅ 所有幽灵元素使用 `GhostPillarWidget` 渲染
- ✅ 拖拽到 insertIndex=0 时无高度跳变
- ✅ 幽灵元素颜色、边框样式统一

---

**分析完成！准备执行任务 5.3-5.5**
