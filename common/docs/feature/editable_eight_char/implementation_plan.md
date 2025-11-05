# PillarDecoration 重构实施计划

> EditableFourZhuCard 数据驱动装饰系统 - 完整任务清单

## 📋 目录

- [项目概述](#项目概述)
- [架构设计简述](#架构设计简述)
- [实施阶段](#实施阶段)
  - [阶段 1: 数据模型创建](#阶段-1-数据模型创建)
  - [阶段 2: Widget 组件创建](#阶段-2-widget-组件创建)
  - [阶段 3: 渲染层局部替换](#阶段-3-渲染层局部替换)
  - [阶段 4: 拖拽反馈重构](#阶段-4-拖拽反馈重构)
  - [阶段 5: 幽灵元素优化](#阶段-5-幽灵元素优化)
  - [阶段 6: 清理与优化](#阶段-6-清理与优化)
- [风险评估](#风险评估)
- [时间估算](#时间估算)
- [验收标准](#验收标准)

---

## 项目概述

### 目标

将 `EditableFourZhuCardV3` 从**过程式尺寸计算**重构为**数据驱动的装饰系统**，解决以下问题：

1. ✅ 抓手对齐问题（topGripRow/leftGripColumn）
2. ✅ 柱装饰 overflow 警告
3. ✅ 让位边界计算不精确
4. ✅ 幽灵行/列尺寸不一致
5. ✅ 拖拽反馈尺寸不匹配

### 核心理念

**从"外部计算"到"数据自描述"**

```dart
// 旧方式：外部计算
double width = _colWidthAtIndex(i, pillars);  // 40+ 行逻辑

// 新方式：数据自描述
double width = payload.decoration?.size.width ?? pillarWidth;  // ✅ 一行搞定
```

---

## 架构设计简述

### 数据模型层次

```
PillarPayload
  └── PillarDecoration (柱装饰配置)
        ├── margin, padding, border, borderRadius, backgroundColor, boxShadow
        ├── basePillarWidth (基础柱宽)
        ├── cells: List<CellDecoration> (单元格装饰列表)
        └── 计算属性:
              ├── size (总尺寸，含 margin)
              ├── contentSize (内容尺寸，不含 margin)
              ├── contentOffset (内容区起始偏移)
              └── contentCenter (内容区中点)

CellDecoration (单元格装饰)
  ├── rowType, padding, border, backgroundColor
  ├── height (显式高度，可选)
  └── 计算属性:
        ├── effectiveHeight (有效高度：height ?? 根据 rowType 推断)
        └── getSize(width) (总尺寸，含 padding + border)
```

### 新建文件策略

**重要：** 所有数据模型和 Widget 组件都创建为**新文件**，不修改现有文件（除 impl 文件外），确保可安全回滚。

```
lib/
├── widgets/editable_fourzhu_card/
│   ├── models/                          # ✨ 新建目录
│   │   ├── decoration/                  # ✨ 新建子目录
│   │   │   ├── cell_decoration.dart     # ✨ 新建文件
│   │   │   ├── pillar_decoration.dart   # ✨ 新建文件
│   │   │   └── decoration_defaults.dart # ✨ 新建文件（常量）
│   │   └── drag_payloads.dart           # 现有文件（需扩展）
│   ├── widgets/                         # ✨ 新建目录
│   │   ├── cell_widget.dart             # ✨ 新建文件
│   │   ├── pillar_widget.dart           # ✨ 新建文件
│   │   ├── ghost_pillar_widget.dart     # ✨ 新建文件
│   │   └── dragging_feedback_widget.dart # ✨ 新建文件
│   └── editable_fourzhu_card_impl.dart  # 现有文件（需修改）
```

---

## 实施阶段

### 阶段 1: 数据模型创建

**目标：** 创建核心数据模型，封装尺寸计算逻辑

**预计时间：** 2-3 小时

**前置依赖：** 无

#### 任务清单

- [ ] **任务 1.1: 创建 decoration 目录结构**（5 分钟）
  - **文件：** `lib/widgets/editable_fourzhu_card/models/decoration/`
  - **操作：** 创建目录
  - **验证：** 目录存在

- [ ] **任务 1.2: 创建 DecorationDefaults 常量类**（15 分钟）
  - **文件：** `lib/widgets/editable_fourzhu_card/models/decoration/decoration_defaults.dart`
  - **内容：**
    ```dart
    class DecorationDefaults {
      static const double ganZhiCellHeight = 48.0;
      static const double otherCellHeight = 36.0;
      static const double dividerCellHeight = 12.0;
      static const double columnTitleHeight = 40.0;
      static const double basePillarWidth = 64.0;
      static const double separatorPillarWidth = 16.0;

      static const EdgeInsets defaultCellPadding = EdgeInsets.symmetric(vertical: 4, horizontal: 8);
      static const EdgeInsets defaultPillarPadding = EdgeInsets.all(6);
      static const EdgeInsets defaultPillarMargin = EdgeInsets.symmetric(horizontal: 8, vertical: 8);
    }
    ```
  - **验证：** 文件存在，常量定义正确

- [ ] **任务 1.3: 创建 CellDecoration 基础类**（30 分钟）
  - **文件：** `lib/widgets/editable_fourzhu_card/models/decoration/cell_decoration.dart`
  - **字段：**
    - `rowType: RowType` - 行类型
    - `padding: EdgeInsets` - 内边距
    - `border: BoxBorder?` - 边框
    - `backgroundColor: Color?` - 背景色
    - `height: double?` - 显式高度（可选）
    - `isHeaderRow: bool` - 是否为表头行
  - **方法：**
    - `double get effectiveHeight` - 计算有效高度（height ?? 根据 rowType 推断）
    - `Size getSize(double pillarWidth)` - 计算总尺寸（含 padding + border）
  - **预期输出：**
    ```dart
    final cell = CellDecoration(rowType: RowType.heavenlyStem);
    expect(cell.effectiveHeight, 48.0);
    expect(cell.getSize(64).height, 48 + 8 + 0);  // content + padding + border
    ```
  - **验证：** 编译通过，effectiveHeight 计算正确

- [ ] **任务 1.4: 添加 CellDecoration 的工厂方法**（15 分钟）
  - **文件：** `cell_decoration.dart`
  - **新增工厂方法：**
    - `CellDecoration.ganZhi()` - 干支行装饰
    - `CellDecoration.divider()` - 分隔行装饰
    - `CellDecoration.header()` - 表头行装饰
  - **示例：**
    ```dart
    factory CellDecoration.ganZhi({
      EdgeInsets? padding,
      Color? backgroundColor,
    }) {
      return CellDecoration(
        rowType: RowType.heavenlyStem,
        padding: padding ?? DecorationDefaults.defaultCellPadding,
        backgroundColor: backgroundColor,
      );
    }
    ```
  - **验证：** 工厂方法创建的对象属性正确

- [ ] **任务 1.5: 创建 PillarDecoration 基础类**（45 分钟）
  - **文件：** `lib/widgets/editable_fourzhu_card/models/decoration/pillar_decoration.dart`
  - **字段：**
    - `margin: EdgeInsets` - 外边距
    - `padding: EdgeInsets` - 内边距
    - `border: BoxBorder?` - 边框
    - `borderRadius: BorderRadius?` - 圆角
    - `backgroundColor: Color?` - 背景色
    - `boxShadow: List<BoxShadow>?` - 阴影
    - `basePillarWidth: double` - 基础柱宽
    - `cells: List<CellDecoration>` - 单元格装饰列表
  - **计算属性：**
    - `Size get size` - 总尺寸（含 margin）
    - `Size get contentSize` - 内容尺寸（不含 margin）
    - `Offset get contentOffset` - 内容区起始偏移
    - `Offset get contentCenter` - 内容区中点
  - **方法：**
    - `BoxDecoration toBoxDecoration()` - 转换为 BoxDecoration
    - `CellDecoration cellAt(int rowIndex)` - 获取指定行的单元格装饰
  - **预期输出：**
    ```dart
    final pillar = PillarDecoration(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(6),
      border: Border.all(width: 2),
      cells: [
        CellDecoration.ganZhi(),
        CellDecoration.ganZhi(),
      ],
      basePillarWidth: 64,
    );
    expect(pillar.size.width, 64 + 12 + 4 + 16);  // base + padding + border + margin
    expect(pillar.size.height, 96 + 12 + 4 + 16);  // cells + padding + border + margin
    ```
  - **验证：** 尺寸计算正确

- [ ] **任务 1.6: 添加 PillarDecoration 的工厂方法**（20 分钟）
  - **文件：** `pillar_decoration.dart`
  - **新增工厂方法：**
    - `PillarDecoration.normal()` - 普通柱装饰（带 margin/padding/border/shadow）
    - `PillarDecoration.separator()` - 分隔柱装饰（窄宽度，无装饰）
    - `PillarDecoration.ghost()` - 幽灵柱装饰（半透明，虚线边框）
  - **示例：**
    ```dart
    factory PillarDecoration.normal({
      required List<CellDecoration> cells,
      double basePillarWidth = DecorationDefaults.basePillarWidth,
    }) {
      return PillarDecoration(
        margin: DecorationDefaults.defaultPillarMargin,
        padding: DecorationDefaults.defaultPillarPadding,
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.red.withAlpha(10),
        boxShadow: [
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
    ```
  - **验证：** 工厂方法创建的对象装饰属性正确

- [ ] **任务 1.7: 添加尺寸缓存机制**（15 分钟）
  - **文件：** `pillar_decoration.dart`
  - **新增字段：** `Size? _cachedSize`
  - **修改方法：**
    ```dart
    Size get size {
      if (_cachedSize != null) return _cachedSize!;
      _cachedSize = _computeSize();
      return _cachedSize!;
    }

    void invalidateCache() {
      _cachedSize = null;
    }
    ```
  - **验证：** 第二次调用 size 时返回缓存值

- [ ] **任务 1.8: 扩展 PillarPayload 添加 decoration 字段**（15 分钟）
  - **文件：** `lib/widgets/editable_fourzhu_card/models/drag_payloads.dart`
  - **操作：** 在 `PillarPayload` 类中添加 `decoration: PillarDecoration?` 字段
  - **示例：**
    ```dart
    class PillarPayload {
      final PillarType pillarType;
      final PillarContent? pillarContent;
      final PillarDecoration? decoration;  // ✨ 新增字段

      PillarPayload({
        required this.pillarType,
        this.pillarContent,
        this.decoration,  // ✨ 新增参数
      });
    }
    ```
  - **验证：** 编译通过，可创建带 decoration 的 PillarPayload

#### 阶段 1 验证标准

- ✅ 所有模型文件创建完成，编译无错误
- ✅ `CellDecoration.effectiveHeight` 计算正确（包含 height 覆盖、rowType 推断、isHeaderRow 特殊处理）
- ✅ `PillarDecoration.size` 计算正确（margin + border + padding + cells 累加）
- ✅ `PillarDecoration.contentCenter` 精确计算内容区中点
- ✅ 工厂方法创建的对象装饰属性符合预期
- ✅ 缓存机制生效，重复调用 size 返回缓存值

---

### 阶段 2: Widget 组件创建

**目标：** 创建独立的 Widget 组件，封装渲染逻辑

**预计时间：** 2-3 小时

**前置依赖：** 阶段 1 完成

#### 任务清单

- [ ] **任务 2.1: 创建 widgets 目录结构**（5 分钟）
  - **文件：** `lib/widgets/editable_fourzhu_card/widgets/`
  - **操作：** 创建目录
  - **验证：** 目录存在

- [ ] **任务 2.2: 创建 CellWidget 基础组件**（30 分钟）
  - **文件：** `lib/widgets/editable_fourzhu_card/widgets/cell_widget.dart`
  - **参数：**
    - `decoration: CellDecoration` - 单元格装饰
    - `child: Widget` - 单元格内容
    - `width: double` - 单元格宽度
  - **结构：**
    ```dart
    class CellWidget extends StatelessWidget {
      final CellDecoration decoration;
      final Widget child;
      final double width;

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
  - **预期输出：** 单元格按照 decoration 配置渲染
  - **验证：** 单元格尺寸、padding、边框正确

- [ ] **任务 2.3: 创建 PillarWidget 普通柱组件**（45 分钟）
  - **文件：** `lib/widgets/editable_fourzhu_card/widgets/pillar_widget.dart`
  - **参数：**
    - `decoration: PillarDecoration` - 柱装饰
    - `children: List<Widget>` - 单元格内容列表
  - **结构：**
    ```dart
    class PillarWidget extends StatelessWidget {
      final PillarDecoration decoration;
      final List<Widget> children;

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
    }
    ```
  - **预期输出：** 柱按照 decoration 配置渲染，无 overflow
  - **验证：** 柱尺寸、margin、padding、边框、阴影正确

- [ ] **任务 2.4: 创建 PillarWidget 变体 - ghost（幽灵柱）**（20 分钟）
  - **文件：** `pillar_widget.dart`
  - **新增构造函数：**
    ```dart
    factory PillarWidget.ghost({
      required PillarDecoration decoration,
      required List<Widget> children,
    }) {
      // 创建幽灵装饰：半透明背景，虚线边框
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
    ```
  - **验证：** 幽灵柱显示为半透明样式

- [ ] **任务 2.5: 创建 GhostPillarWidget（简化版幽灵柱）**（20 分钟）
  - **文件：** `lib/widgets/editable_fourzhu_card/widgets/ghost_pillar_widget.dart`
  - **用途：** 拖拽时的插入位置提示
  - **参数：**
    - `width: double` - 幽灵柱宽度
    - `height: double` - 幽灵柱高度
  - **结构：**
    ```dart
    class GhostPillarWidget extends StatelessWidget {
      final double width;
      final double height;

      @override
      Widget build(BuildContext context) {
        return Container(
          width: width,
          height: height,
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            border: Border.all(
              color: Colors.blue.withOpacity(0.5),
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }
    }
    ```
  - **验证：** 幽灵柱显示为蓝色半透明占位符

- [ ] **任务 2.6: 创建 DraggingFeedbackWidget（拖拽反馈组件）**（30 分钟）
  - **文件：** `lib/widgets/editable_fourzhu_card/widgets/dragging_feedback_widget.dart`
  - **用途：** 拖拽时跟随鼠标的反馈视图
  - **参数：**
    - `decoration: PillarDecoration` - 柱装饰
    - `children: List<Widget>` - 单元格内容
    - `opacity: double` - 不透明度（默认 0.7）
  - **结构：**
    ```dart
    class DraggingFeedbackWidget extends StatelessWidget {
      final PillarDecoration decoration;
      final List<Widget> children;
      final double opacity;

      DraggingFeedbackWidget({
        required this.decoration,
        required this.children,
        this.opacity = 0.7,
      });

      @override
      Widget build(BuildContext context) {
        return Opacity(
          opacity: opacity,
          child: Material(
            elevation: 4,
            borderRadius: decoration.borderRadius,
            child: PillarWidget(
              decoration: decoration,
              children: children,
            ),
          ),
        );
      }
    }
    ```
  - **验证：** 拖拽反馈视图有阴影、半透明效果

- [ ] **任务 2.7: 创建 ColumnGripWidget（列抓手组件）**（25 分钟）
  - **文件：** `lib/widgets/editable_fourzhu_card/widgets/column_grip_widget.dart`
  - **用途：** topGripRow 的列抓手
  - **参数：**
    - `width: double` - 总宽度
    - `height: double` - 抓手高度
    - `horizontalPadding: double` - 水平 padding（用于抵消 margin）
    - `child: Widget` - 抓手图标
  - **结构：**
    ```dart
    class ColumnGripWidget extends StatelessWidget {
      final double width;
      final double height;
      final double horizontalPadding;
      final Widget child;

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
  - **验证：** 抓手居中对齐到柱的内容区

- [ ] **任务 2.8: 创建 RowGripWidget（行抓手组件）**（25 分钟）
  - **文件：** `lib/widgets/editable_fourzhu_card/widgets/row_grip_widget.dart`
  - **用途：** leftGripColumn 的行抓手
  - **参数：**
    - `width: double` - 抓手宽度
    - `height: double` - 总高度
    - `verticalPadding: double` - 垂直 padding（用于抵消 margin）
    - `child: Widget` - 抓手图标
  - **结构：**
    ```dart
    class RowGripWidget extends StatelessWidget {
      final double width;
      final double height;
      final double verticalPadding;
      final Widget child;

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
  - **验证：** 抓手居中对齐到行的内容区

- [ ] **任务 2.9: 创建 widgets 导出文件**（10 分钟）
  - **文件：** `lib/widgets/editable_fourzhu_card/widgets/widgets.dart`
  - **内容：**
    ```dart
    export 'cell_widget.dart';
    export 'pillar_widget.dart';
    export 'ghost_pillar_widget.dart';
    export 'dragging_feedback_widget.dart';
    export 'column_grip_widget.dart';
    export 'row_grip_widget.dart';
    ```
  - **验证：** 可通过 `import 'widgets/widgets.dart'` 导入所有组件

#### 阶段 2 验证标准

- ✅ 所有 Widget 文件创建完成，编译无错误
- ✅ `CellWidget` 正确渲染单元格（padding、border、backgroundColor）
- ✅ `PillarWidget` 正确渲染柱（margin、padding、border、shadow）
- ✅ `GhostPillarWidget` 显示为半透明占位符
- ✅ `DraggingFeedbackWidget` 有阴影和透明度效果
- ✅ `ColumnGripWidget` 和 `RowGripWidget` 正确对齐到内容区中心
- ✅ 热重载测试通过

---

### 阶段 3: 渲染层局部替换

**目标：** 在 `editable_fourzhu_card_impl.dart` 中逐步替换渲染逻辑

**预计时间：** 3-4 小时

**前置依赖：** 阶段 2 完成

⚠️ **风险提示：** 此阶段将修改现有文件，建议创建 Git 分支 `refactor/common/card-stage-3`

#### 任务清单

- [ ] **任务 3.1: 创建 Git 分支**（5 分钟）
  - **操作：** `git checkout -b refactor/common/card-stage-3`
  - **验证：** `git branch` 显示当前分支为 `refactor/common/card-stage-3`

- [ ] **任务 3.2: 在 State 中添加 _pillarDecorations 字段**（15 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **位置：** `_EditableFourZhuCardV3State` 类
  - **新增字段：**
    ```dart
    // 柱装饰映射：pillarIndex -> PillarDecoration
    final Map<int, PillarDecoration> _pillarDecorations = {};
    ```
  - **验证：** 编译通过

- [ ] **任务 3.3: 创建 _createPillarDecoration() 方法**（30 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **方法签名：** `PillarDecoration _createPillarDecoration(int pillarIndex)`
  - **逻辑：**
    1. 获取当前行列表 `rows = widget.rowListNotifier.value`
    2. 遍历 rows，为每行创建 `CellDecoration`
    3. 从 `_rowHeightOverrides` 读取高度覆盖
    4. 创建 `PillarDecoration.normal(cells: cellDecorations)`
  - **示例：**
    ```dart
    PillarDecoration _createPillarDecoration(int pillarIndex) {
      final rows = widget.rowListNotifier.value;
      final cellDecorations = rows.asMap().entries.map((entry) {
        final rowIndex = entry.key;
        final row = entry.value;

        // 从 override 读取高度
        final overrideHeight = _rowHeightOverrides[rowIndex];

        return CellDecoration(
          rowType: row.rowType,
          height: overrideHeight,  // 覆盖优先
          padding: DecorationDefaults.defaultCellPadding,
          backgroundColor: null,
        );
      }).toList();

      return PillarDecoration.normal(
        cells: cellDecorations,
        basePillarWidth: pillarWidth,
      );
    }
    ```
  - **验证：** 方法返回正确的 PillarDecoration

- [ ] **任务 3.4: 创建 _initializePillarDecorations() 方法**（20 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **方法签名：** `void _initializePillarDecorations()`
  - **逻辑：**
    1. 清空 `_pillarDecorations`
    2. 遍历 `widget.pillarsNotifier.value`
    3. 为每个柱创建 decoration
    4. 存入 `_pillarDecorations[i] = decoration`
  - **示例：**
    ```dart
    void _initializePillarDecorations() {
      _pillarDecorations.clear();
      final payloads = widget.pillarsNotifier.value;
      for (int i = 0; i < payloads.length; i++) {
        _pillarDecorations[i] = _createPillarDecoration(i);
      }
    }
    ```
  - **调用位置：** `initState()` 末尾
  - **验证：** `_pillarDecorations` 填充正确

- [ ] **任务 3.5: 在 pillarsNotifier 监听器中更新 decorations**（15 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **位置：** `initState()` 中的 `widget.pillarsNotifier.addListener`
  - **修改：**
    ```dart
    widget.pillarsNotifier.addListener(() {
      setState(() {
        _initializePillarDecorations();  // ✨ 新增调用
      });
    });
    ```
  - **验证：** 柱列表变化时 decorations 同步更新

- [ ] **任务 3.6: 在 rowListNotifier 监听器中更新 decorations**（15 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **位置：** `initState()` 中的 `widget.rowListNotifier.addListener`
  - **修改：**
    ```dart
    widget.rowListNotifier.addListener(() {
      setState(() {
        _initializePillarDecorations();  // ✨ 新增调用
        // 或更精细地只更新 cells 列表
      });
    });
    ```
  - **验证：** 行列表变化时 decorations 同步更新

- [ ] **任务 3.7: 简化 _colWidthAtIndex() 方法**（20 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **原逻辑：** 40+ 行复杂判断
  - **新逻辑：**
    ```dart
    double _colWidthAtIndex(int i, List<Tuple2<String, JiaZi>> pillars) {
      final decoration = _pillarDecorations[i];
      if (decoration != null) {
        return decoration.size.width;  // ✅ 使用 decoration 计算
      }

      // 兜底逻辑（无 decoration 时）
      if (_isSeparatorColumnIndex(i)) return _colDividerWidthEffective;
      final override = _columnWidthOverrides[i];
      if (override != null) return override;
      return pillarWidth;
    }
    ```
  - **验证：** 宽度计算与之前一致

- [ ] **任务 3.8: 简化 _totalColsWidth() 方法**（15 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **新逻辑：**
    ```dart
    double _totalColsWidth(List<Tuple2<String, JiaZi>> pillars) {
      double total = 0.0;
      for (int i = 0; i < pillars.length; i++) {
        total += _colWidthAtIndex(i, pillars);
      }
      return total;
    }
    ```
  - **验证：** 总宽度计算正确

- [ ] **任务 3.9: 重构 _columnBoundaryMidX() 使用 contentCenter**（25 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **新逻辑：**
    ```dart
    double _columnBoundaryMidX(int idx, List<Tuple2<String, JiaZi>> pillars) {
      // 累加前面所有柱的总宽度
      double acc = 0.0;
      for (int i = 0; i < idx; i++) {
        acc += _colWidthAtIndex(i, pillars);
      }

      // 加上当前柱的内容区中点偏移
      final decoration = _pillarDecorations[idx];
      if (decoration != null) {
        return acc + decoration.contentCenter.dx;  // ✅ 精确的内容区中点
      }

      // 兜底逻辑
      return acc + _colWidthAtIndex(idx, pillars) / 2;
    }
    ```
  - **验证：** 让位边界计算精确

- [ ] **任务 3.10: 替换 topGripRow 的柱抓手渲染**（30 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **位置：** `topGripRow` 构建代码（约 Line 764-776）
  - **原逻辑：**
    ```dart
    ...List.generate(pillars.length, (i) {
      return SizedBox(
        width: _colWidthAtIndex(i, pillars),
        height: dragHandleRowHeight,
        child: Center(child: Draggable(...)),
      );
    })
    ```
  - **新逻辑：**
    ```dart
    ...List.generate(pillars.length, (i) {
      final decoration = _pillarDecorations[i];
      final totalWidth = decoration?.size.width ?? _colWidthAtIndex(i, pillars);

      return ColumnGripWidget(
        width: totalWidth,
        height: dragHandleRowHeight,
        horizontalPadding: decoration != null
          ? decoration.margin.horizontal / 2
          : 0,
        child: Draggable(...),
      );
    })
    ```
  - **验证：** 抓手完美对齐到柱的内容区中心

- [ ] **任务 3.11: 替换 dataGrid 的柱渲染（初步）**（45 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **位置：** `dataGrid` 的 `List.generate` 构建柱（约 Line 1800-1900）
  - **原逻辑：**
    ```dart
    child: Container(
      decoration: BoxDecoration(...),  // 直接应用装饰
      width: colW,
      child: columnContent,
    )
    ```
  - **新逻辑：**
    ```dart
    final decoration = _pillarDecorations[i];

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
      : Container(
          width: colW,
          child: columnContent,
        ),
    ```
  - **⚠️ 重要：** 暂时保留原来的临时装饰代码（Line 1813-1830），确保对比测试
  - **验证：** 柱渲染正确，无 overflow 警告

- [ ] **任务 3.12: 测试渲染替换效果**（30 分钟）
  - **操作：**
    1. 运行应用 `flutter run`
    2. 检查柱是否正常显示
    3. 检查抓手是否对齐
    4. 检查是否有 overflow 警告
    5. 测试拖拽行/列功能
  - **验证：** 所有功能正常，无警告

#### 阶段 3 验证标准

- ✅ `_pillarDecorations` 正确初始化和同步
- ✅ `_colWidthAtIndex()` 使用 decoration 计算宽度
- ✅ `_columnBoundaryMidX()` 使用 `contentCenter` 精确计算
- ✅ topGripRow 的抓手完美对齐到柱的内容区
- ✅ dataGrid 的柱渲染无 overflow 警告
- ✅ 拖拽功能正常（行/列拖拽、插入、重排）
- ✅ 热重载测试通过

---

### 阶段 4: 拖拽反馈重构

**目标：** 使用 `DraggingFeedbackWidget` 替换拖拽反馈视图

**预计时间：** 2-3 小时

**前置依赖：** 阶段 3 完成

⚠️ **风险提示：** 建议创建新分支 `refactor/common/card-stage-4`

#### 任务清单

- [ ] **任务 4.1: 创建 Git 分支**（5 分钟）
  - **操作：** `git checkout -b refactor/common/card-stage-4`
  - **验证：** 分支切换成功

- [ ] **任务 4.2: 分析现有拖拽反馈代码**（20 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **位置：** 搜索 `feedback:` 关键字
  - **记录：**
    - 列拖拽反馈位置（topGripRow Draggable）
    - 行拖拽反馈位置（leftGripColumn Draggable）
    - 自定义 feedback builder 位置
  - **验证：** 找到所有拖拽反馈代码位置

- [ ] **任务 4.3: 替换列拖拽反馈（topGripRow）**（30 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **位置：** topGripRow 的 Draggable 组件
  - **原逻辑：**
    ```dart
    Draggable<Object>(
      feedback: Material(
        elevation: 4,
        child: Container(...),  // 手动构建反馈视图
      ),
      ...
    )
    ```
  - **新逻辑：**
    ```dart
    Draggable<Object>(
      feedback: _buildColumnDraggingFeedback(i),  // ✨ 使用新方法
      ...
    )
    ```
  - **新增方法：**
    ```dart
    Widget _buildColumnDraggingFeedback(int pillarIndex) {
      final decoration = _pillarDecorations[pillarIndex];
      if (decoration == null) {
        // 兜底逻辑：使用默认反馈
        return _buildDefaultColumnFeedback(pillarIndex);
      }

      final pillar = widget.pillarsNotifier.value[pillarIndex];
      final rows = widget.rowListNotifier.value;

      // 构建 children
      final children = rows.map((row) {
        return _buildCellContent(pillar, row);  // 复用现有方法
      }).toList();

      return DraggingFeedbackWidget(
        decoration: decoration,
        children: children,
        opacity: 0.7,
      );
    }
    ```
  - **验证：** 拖拽列时反馈视图正确显示

- [ ] **任务 4.4: 替换行拖拽反馈（leftGripColumn）**（30 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **位置：** leftGripColumn 的 Draggable 组件
  - **原逻辑：** 手动构建反馈视图
  - **新逻辑：**
    ```dart
    Widget _buildRowDraggingFeedback(int rowIndex) {
      final row = widget.rowListNotifier.value[rowIndex];
      final pillars = widget.pillarsNotifier.value;

      // 构建横向的行反馈（包含所有柱的该行单元格）
      return Material(
        elevation: 4,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: pillars.asMap().entries.map((entry) {
            final pillarIndex = entry.key;
            final pillar = entry.value;
            final decoration = _pillarDecorations[pillarIndex];
            final cellDecoration = decoration?.cells[rowIndex];

            return CellWidget(
              decoration: cellDecoration ?? CellDecoration(rowType: row.rowType),
              width: decoration?.basePillarWidth ?? pillarWidth,
              child: _buildCellContent(pillar, row),
            );
          }).toList(),
        ),
      );
    }
    ```
  - **验证：** 拖拽行时反馈视图正确显示

- [ ] **任务 4.5: 处理自定义 dragFeedbackBuilder**（25 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **检查：** `widget.dragFeedbackBuilder` 是否存在
  - **逻辑：**
    ```dart
    Widget _buildColumnDraggingFeedback(int pillarIndex) {
      // 优先使用自定义 builder
      if (widget.dragFeedbackBuilder != null) {
        return widget.dragFeedbackBuilder!(pillarIndex);
      }

      // 否则使用 decoration
      final decoration = _pillarDecorations[pillarIndex];
      // ...
    }
    ```
  - **验证：** 自定义 builder 优先级高于 decoration

- [ ] **任务 4.6: 优化拖拽反馈尺寸匹配**（20 分钟）
  - **问题：** 拖拽反馈视图与实际柱的尺寸可能不一致
  - **解决方案：** 确保 `DraggingFeedbackWidget` 使用与实际柱相同的 decoration
  - **验证方法：**
    1. 开始拖拽
    2. 对比拖拽反馈的宽度/高度与原柱
    3. 应完全一致（视觉上无缩放/变形）
  - **验证：** 拖拽反馈尺寸与原柱一致

- [ ] **任务 4.7: 添加拖拽反馈动画效果**（15 分钟）
  - **文件：** `dragging_feedback_widget.dart`
  - **增强：** 添加可选的缩放动画
  - **修改：**
    ```dart
    class DraggingFeedbackWidget extends StatelessWidget {
      final double scale;  // ✨ 新增参数

      @override
      Widget build(BuildContext context) {
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Material(...),
          ),
        );
      }
    }
    ```
  - **验证：** 拖拽时可选缩放效果（例如放大 1.05 倍）

- [ ] **任务 4.8: 测试拖拽反馈效果**（30 分钟）
  - **操作：**
    1. 拖拽列（从 topGripRow）
    2. 拖拽行（从 leftGripColumn）
    3. 拖拽外部柱（从外部数据源）
    4. 检查反馈视图尺寸、样式、透明度
  - **验证：** 所有拖拽反馈视图正确显示

#### 阶段 4 验证标准

- ✅ 列拖拽反馈使用 `DraggingFeedbackWidget`
- ✅ 行拖拽反馈使用 `CellWidget` 组合
- ✅ 自定义 `dragFeedbackBuilder` 优先级正确
- ✅ 拖拽反馈尺寸与原柱一致
- ✅ 拖拽反馈有透明度和阴影效果
- ✅ 拖拽功能正常，无视觉问题

---

### 阶段 5: 幽灵元素优化

**目标：** 使用 `GhostPillarWidget` 统一幽灵行/列的渲染

**预计时间：** 1-2 小时

**前置依赖：** 阶段 4 完成

⚠️ **风险提示：** 建议创建新分支 `refactor/common/card-stage-5`

#### 任务清单

- [ ] **任务 5.1: 创建 Git 分支**（5 分钟）
  - **操作：** `git checkout -b refactor/common/card-stage-5`
  - **验证：** 分支切换成功

- [ ] **任务 5.2: 分析现有幽灵元素代码**（20 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **位置：** 搜索 `_hoverColumnInsertIndex`, `_hoverRowInsertIndex`
  - **记录：**
    - 幽灵列的渲染位置（gripColumn、leftHeader、dataGrid）
    - 幽灵行的渲染位置（topGripRow、dataColumns）
    - 幽灵元素的尺寸计算逻辑
  - **验证：** 找到所有幽灵元素代码位置

- [ ] **任务 5.3: 创建 _getGhostColumnWidth() 方法**（15 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **方法签名：** `double _getGhostColumnWidth()`
  - **逻辑：**
    ```dart
    double _getGhostColumnWidth() {
      // 优先使用外部柱的 decoration
      if (_hoveringExternalPillar && _externalPillarDecoration != null) {
        return _externalPillarDecoration!.size.width;
      }

      // 否则使用 _externalColHoverWidth
      return _externalColHoverWidth ?? pillarWidth;
    }
    ```
  - **新增字段：** `PillarDecoration? _externalPillarDecoration`
  - **验证：** 幽灵列宽度计算正确

- [ ] **任务 5.4: 替换 gripColumn 的幽灵列渲染**（25 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **位置：** gripColumn 构建代码（约 Line 1700-1720）
  - **原逻辑：**
    ```dart
    if (showGhost) {
      SizedBox(
        width: _externalColHoverWidth ?? pillarWidth,
        height: dragHandleRowHeight,
        child: Container(...),  // 手动构建幽灵占位
      )
    }
    ```
  - **新逻辑：**
    ```dart
    if (showGhost) {
      GhostPillarWidget(
        width: _getGhostColumnWidth(),
        height: dragHandleRowHeight,
      )
    }
    ```
  - **验证：** 幽灵列显示正确

- [ ] **任务 5.5: 替换 dataGrid 的幽灵列渲染**（25 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **位置：** dataGrid 的幽灵列渲染（约 Line 2480-2500）
  - **原逻辑：** 手动构建幽灵占位
  - **新逻辑：**
    ```dart
    if (showGhost) {
      GhostPillarWidget(
        width: _getGhostColumnWidth(),
        height: _totalRowsHeight(),  // 使用总行高度
      )
    }
    ```
  - **验证：** 幽灵列高度与实际柱一致

- [ ] **任务 5.6: 优化幽灵行高度计算**（20 分钟）
  - **问题：** 幽灵行高度可能与实际行不一致（尤其是拖拽到 insertIndex=0 时）
  - **创建方法：** `double _getGhostRowHeight(int rowIndex)`
  - **逻辑：**
    ```dart
    double _getGhostRowHeight(int rowIndex) {
      // 优先使用 _rowHeightOverrides
      if (_rowHeightOverrides.containsKey(rowIndex)) {
        return _rowHeightOverrides[rowIndex]!;
      }

      // 否则根据 rowType 推断
      final row = widget.rowListNotifier.value[rowIndex];
      return _getDefaultRowHeight(row.rowType);
    }
    ```
  - **验证：** 幽灵行高度精确匹配

- [ ] **任务 5.7: 测试幽灵元素效果**（20 分钟）
  - **操作：**
    1. 拖拽外部柱到卡片，检查幽灵列显示
    2. 拖拽外部行到卡片，检查幽灵行显示
    3. 拖拽到 insertIndex=0（表头行位置），检查幽灵元素高度
    4. 检查幽灵元素颜色、边框样式
  - **验证：** 幽灵元素尺寸一致，无跳变

#### 阶段 5 验证标准

- ✅ 幽灵列使用 `GhostPillarWidget` 统一渲染
- ✅ 幽灵列宽度精确匹配外部柱的 decoration
- ✅ 幽灵行高度精确匹配 `_rowHeightOverrides` 或默认高度
- ✅ 拖拽到 insertIndex=0 时无高度跳变
- ✅ 幽灵元素颜色、边框样式统一

---

### 阶段 6: 清理与优化

**目标：** 删除临时代码，优化性能，完善文档

**预计时间：** 2 小时

**前置依赖：** 阶段 5 完成

#### 任务清单

- [ ] **任务 6.1: 删除临时装饰代码**（20 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **位置：** dataGrid 的 Container（Line 1813-1830）
  - **操作：** 删除 `margin`, `padding`, `decoration` 临时代码
  - **验证：** 柱渲染完全由 `_pillarDecorations` 控制

- [ ] **任务 6.2: 移除调试日志**（15 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **操作：** 搜索 `print(`, `debugPrint(`, `🔍`，删除所有调试日志
  - **验证：** 无调试输出

- [ ] **任务 6.3: 优化 _colWidthAtIndex() 兜底逻辑**（15 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **检查：** 是否还需要 `_columnWidthOverrides` 兜底？
  - **决策：** 如果所有柱都有 decoration，可移除兜底逻辑
  - **验证：** 简化后功能正常

- [ ] **任务 6.4: 添加 decoration 缓存失效逻辑**（20 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **场景：** 当 `_rowHeightOverrides` 变化时，需调用 `invalidateCache()`
  - **修改：**
    ```dart
    void _updateRowHeightOverride(int rowIndex, double height) {
      _rowHeightOverrides[rowIndex] = height;

      // 失效所有柱的缓存
      for (final decoration in _pillarDecorations.values) {
        decoration.invalidateCache();
      }

      setState(() {});
    }
    ```
  - **验证：** 调整行高度后，柱尺寸立即更新

- [ ] **任务 6.5: 添加单元测试**（30 分钟）
  - **文件：** `test/widgets/editable_fourzhu_card/pillar_decoration_test.dart`（新建）
  - **测试用例：**
    1. `PillarDecoration.size` 计算正确性
    2. `PillarDecoration.contentCenter` 精确计算
    3. `CellDecoration.effectiveHeight` 覆盖优先级
    4. 缓存机制生效
  - **示例：**
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

      expect(decoration.size.width, 64 + 12 + 4 + 16);
      expect(decoration.size.height, 96 + 12 + 4 + 16);
    });
    ```
  - **验证：** 所有测试通过

- [ ] **任务 6.6: 添加 Widget 测试**（25 分钟）
  - **文件：** `test/widgets/editable_fourzhu_card/pillar_widget_test.dart`（新建）
  - **测试用例：**
    1. `PillarWidget` 正确渲染
    2. `GhostPillarWidget` 显示为半透明
    3. `DraggingFeedbackWidget` 有阴影效果
  - **验证：** Widget 测试通过

- [ ] **任务 6.7: 性能优化 - 减少重建**（20 分钟）
  - **文件：** `editable_fourzhu_card_impl.dart`
  - **优化：** 避免每次 `setState` 都重新创建 decorations
  - **策略：** 仅在必要时调用 `_initializePillarDecorations()`
  - **验证：** 性能分析显示重建次数减少

#### 阶段 6 验证标准

- ✅ 删除所有临时代码和调试日志
- ✅ 代码简洁，无冗余逻辑
- ✅ 单元测试覆盖核心计算逻辑
- ✅ Widget 测试覆盖组件渲染
- ✅ 性能优化生效，无卡顿
- ✅ 代码通过 `flutter analyze`

---

## 风险评估

### 高风险项

1. **阶段 3-6：修改现有文件**
   - **风险：** 可能引入 bug，影响现有功能
   - **缓解措施：**
     - 每阶段创建新分支
     - 每阶段完成后充分测试
     - 保留原代码作为兜底逻辑
   - **回滚方案：** Git 分支切换或 `git revert`

2. **幽灵元素尺寸不一致**
   - **风险：** 拖拽时出现跳变
   - **缓解措施：**
     - 详细记录调试日志（阶段 5）
     - 精确计算幽灵元素高度/宽度
   - **回滚方案：** 保留原幽灵元素渲染逻辑

### 中风险项

1. **动态行列表同步**
   - **风险：** `PillarDecoration.cells` 与实际行列表不同步
   - **缓解措施：**
     - 监听 `rowListNotifier` 变化
     - 调用 `invalidateCache()` 失效缓存
   - **回滚方案：** 移除动态更新逻辑，手动刷新

2. **拖拽反馈尺寸不匹配**
   - **风险：** 拖拽反馈视图与原柱尺寸不一致
   - **缓解措施：**
     - 使用相同的 decoration 创建反馈视图
     - 视觉对比测试
   - **回滚方案：** 保留原拖拽反馈代码

### 低风险项

1. **阶段 1-2：创建新文件**
   - **风险：** 极低，不影响现有代码
   - **回滚方案：** 直接删除新文件

---

## 时间估算

### 各阶段时间

| 阶段 | 预计时间 | 任务数 | 平均每任务时间 |
|------|----------|--------|----------------|
| 阶段 1: 数据模型创建 | 2-3 小时 | 8 | 15-25 分钟 |
| 阶段 2: Widget 组件创建 | 2-3 小时 | 9 | 15-30 分钟 |
| 阶段 3: 渲染层局部替换 | 3-4 小时 | 12 | 15-30 分钟 |
| 阶段 4: 拖拽反馈重构 | 2-3 小时 | 8 | 15-30 分钟 |
| 阶段 5: 幽灵元素优化 | 1-2 小时 | 5 | 15-25 分钟 |
| 阶段 6: 清理与优化 | 2 小时 | 7 | 15-20 分钟 |
| **总计** | **12-17 小时** | **49** | **15-30 分钟** |

### 建议执行节奏

- **集中执行：** 每天 4-6 小时，3-4 天完成
- **分散执行：** 每天 2-3 小时，6-8 天完成
- **周末突击：** 2 个周末，每个周末 6-9 小时

---

## 验收标准

### 功能验收

- ✅ 所有拖拽功能正常（行拖拽、列拖拽、插入、重排）
- ✅ 抓手完美对齐到柱/行的内容区中心
- ✅ 柱装饰无 overflow 警告
- ✅ 幽灵元素尺寸一致，无跳变
- ✅ 拖拽反馈尺寸与原柱一致
- ✅ 让位边界计算精确

### 代码质量验收

- ✅ 通过 `flutter analyze`，无警告
- ✅ 单元测试覆盖率 > 80%
- ✅ Widget 测试通过
- ✅ 代码简洁，无冗余逻辑
- ✅ 注释清晰，易于维护

### 性能验收

- ✅ 无性能回归（帧率稳定）
- ✅ 缓存机制生效，尺寸计算高效
- ✅ 热重载正常

### 文档验收

- ✅ 架构设计文档完整（`architecture_design.md`）
- ✅ 回滚指南完整（`rollback_guide.md`）
- ✅ 测试检查清单完整（`testing_checklist.md`）

---

## 下一步

完成此实施计划后：

1. **执行重构：** 按照任务清单逐步执行
2. **测试验收：** 参考 `testing_checklist.md` 进行测试
3. **合并代码：** 将各阶段分支合并到主分支
4. **更新文档：** 更新 `decoration_pillar.md` 添加导航链接

---

**祝重构顺利！** 🚀
