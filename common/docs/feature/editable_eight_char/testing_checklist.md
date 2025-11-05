# PillarDecoration 重构测试检查清单

> EditableFourZhuCard 数据驱动装饰系统 - 完整测试指南

## 📋 目录

- [测试策略概述](#测试策略概述)
- [阶段 1 测试清单](#阶段-1-测试清单)
- [阶段 2 测试清单](#阶段-2-测试清单)
- [阶段 3 测试清单](#阶段-3-测试清单)
- [阶段 4 测试清单](#阶段-4-测试清单)
- [阶段 5 测试清单](#阶段-5-测试清单)
- [阶段 6 测试清单](#阶段-6-测试清单)
- [完整回归测试清单](#完整回归测试清单)
- [自动化测试建议](#自动化测试建议)

---

## 测试策略概述

### 测试层次

```
单元测试 (Unit Tests)
  ├── CellDecoration 尺寸计算
  ├── PillarDecoration 尺寸计算
  └── 缓存机制测试

Widget 测试 (Widget Tests)
  ├── CellWidget 渲染
  ├── PillarWidget 渲染
  ├── GhostPillarWidget 渲染
  └── DraggingFeedbackWidget 渲染

集成测试 (Integration Tests)
  ├── 拖拽功能（行/列）
  ├── 插入功能
  ├── 重排功能
  └── 幽灵元素显示

手动测试 (Manual Tests)
  ├── 视觉对齐检查
  ├── 交互流畅度
  └── 边界情况处理
```

### 测试优先级

| 优先级 | 测试类型 | 执行时机 |
|--------|----------|----------|
| P0 | 功能测试 | 每阶段完成后 |
| P1 | 视觉测试 | 每阶段完成后 |
| P2 | 性能测试 | 阶段 6 完成后 |
| P3 | 边界测试 | 阶段 6 完成后 |

---

## 阶段 1 测试清单

**目标：** 验证数据模型的尺寸计算逻辑

### 单元测试（7 项）

- [ ] **测试 1.1: CellDecoration.effectiveHeight - 显式高度**
  ```dart
  test('CellDecoration uses explicit height when provided', () {
    final cell = CellDecoration(
      rowType: RowType.heavenlyStem,
      height: 60,
    );
    expect(cell.effectiveHeight, 60);
  });
  ```

- [ ] **测试 1.2: CellDecoration.effectiveHeight - 表头行**
  ```dart
  test('CellDecoration uses columnTitleHeight for header row', () {
    final cell = CellDecoration(
      rowType: RowType.columnTitle,
      isHeaderRow: true,
    );
    expect(cell.effectiveHeight, 40);  // columnTitleHeight
  });
  ```

- [ ] **测试 1.3: CellDecoration.effectiveHeight - rowType 推断**
  ```dart
  test('CellDecoration infers height from rowType', () {
    final cell1 = CellDecoration(rowType: RowType.heavenlyStem);
    expect(cell1.effectiveHeight, 48);  // ganZhiCellHeight

    final cell2 = CellDecoration(rowType: RowType.rowDivider);
    expect(cell2.effectiveHeight, 12);  // dividerCellHeight
  });
  ```

- [ ] **测试 1.4: CellDecoration.getSize - 含 padding + border**
  ```dart
  test('CellDecoration.getSize includes padding and border', () {
    final cell = CellDecoration(
      rowType: RowType.heavenlyStem,
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      border: Border.all(width: 2),
      height: 48,
    );

    final size = cell.getSize(64);
    expect(size.width, 64 + 16 + 4);  // pillarWidth + padding + border
    expect(size.height, 48 + 8 + 4);  // height + padding + border
  });
  ```

- [ ] **测试 1.5: PillarDecoration.size - 总尺寸计算**
  ```dart
  test('PillarDecoration.size calculation', () {
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

    expect(decoration.size.width, 64 + 12 + 4 + 16);  // 96
    expect(decoration.size.height, 96 + 12 + 4 + 16);  // 128
  });
  ```

- [ ] **测试 1.6: PillarDecoration.contentCenter - 内容区中点**
  ```dart
  test('PillarDecoration.contentCenter calculation', () {
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

    final center = decoration.contentCenter;
    expect(center.dx, 8 + 2 + 6 + 32);  // 48
    expect(center.dy, 8 + 2 + 6 + 48);  // 64
  });
  ```

- [ ] **测试 1.7: PillarDecoration 缓存机制**
  ```dart
  test('PillarDecoration caches size calculations', () {
    final decoration = PillarDecoration(
      margin: EdgeInsets.all(8),
      cells: [CellDecoration(rowType: RowType.heavenlyStem, height: 48)],
      basePillarWidth: 64,
    );

    final size1 = decoration.size;
    final size2 = decoration.size;
    expect(identical(size1, size2), true);  // 缓存生效

    decoration.invalidateCache();
    final size3 = decoration.size;
    expect(identical(size2, size3), false);  // 缓存已失效
  });
  ```

### 验收标准

- ✅ 所有单元测试通过
- ✅ 编译无错误
- ✅ `flutter analyze` 无警告

---

## 阶段 2 测试清单

**目标：** 验证 Widget 组件的渲染逻辑

### Widget 测试（8 项）

- [ ] **测试 2.1: CellWidget 正确渲染**
  ```dart
  testWidgets('CellWidget renders with correct size and padding', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CellWidget(
          decoration: CellDecoration.ganZhi(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            backgroundColor: Colors.white,
          ),
          width: 64,
          child: Text('甲'),
        ),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container));
    expect(container.padding, EdgeInsets.symmetric(vertical: 4, horizontal: 8));
    expect((container.decoration as BoxDecoration).color, Colors.white);
  });
  ```

- [ ] **测试 2.2: PillarWidget 正确渲染**
  ```dart
  testWidgets('PillarWidget renders with correct structure', (tester) async {
    final decoration = PillarDecoration.normal(
      cells: [
        CellDecoration.ganZhi(),
        CellDecoration.ganZhi(),
      ],
      basePillarWidth: 64,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PillarWidget(
          decoration: decoration,
          children: [Text('甲'), Text('子')],
        ),
      ),
    );

    // 检查 Column 存在
    expect(find.byType(Column), findsOneWidget);

    // 检查 CellWidget 数量
    expect(find.byType(CellWidget), findsNWidgets(2));
  });
  ```

- [ ] **测试 2.3: PillarWidget 的 margin 正确应用**
  ```dart
  testWidgets('PillarWidget applies margin correctly', (tester) async {
    final decoration = PillarDecoration.normal(
      cells: [CellDecoration.ganZhi()],
      basePillarWidth: 64,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PillarWidget(
          decoration: decoration,
          children: [Text('甲')],
        ),
      ),
    );

    final outerContainer = tester.widget<Container>(
      find.byType(Container).first,
    );
    expect(outerContainer.margin, decoration.margin);
  });
  ```

- [ ] **测试 2.4: PillarWidget 的 padding 正确应用**
  ```dart
  testWidgets('PillarWidget applies padding correctly', (tester) async {
    final decoration = PillarDecoration.normal(
      cells: [CellDecoration.ganZhi()],
      basePillarWidth: 64,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PillarWidget(
          decoration: decoration,
          children: [Text('甲')],
        ),
      ),
    );

    final innerContainer = tester.widget<Container>(
      find.byType(Container).at(1),
    );
    expect(innerContainer.padding, decoration.padding);
  });
  ```

- [ ] **测试 2.5: GhostPillarWidget 显示为半透明**
  ```dart
  testWidgets('GhostPillarWidget has semi-transparent style', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GhostPillarWidget(
          width: 80,
          height: 200,
        ),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;

    // 检查背景色透明度
    expect(decoration.color!.opacity, lessThan(0.2));

    // 检查边框存在
    expect(decoration.border, isNotNull);
  });
  ```

- [ ] **测试 2.6: DraggingFeedbackWidget 有阴影效果**
  ```dart
  testWidgets('DraggingFeedbackWidget has elevation', (tester) async {
    final decoration = PillarDecoration.normal(
      cells: [CellDecoration.ganZhi()],
      basePillarWidth: 64,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DraggingFeedbackWidget(
          decoration: decoration,
          children: [Text('甲')],
        ),
      ),
    );

    final material = tester.widget<Material>(find.byType(Material));
    expect(material.elevation, 4);
  });
  ```

- [ ] **测试 2.7: ColumnGripWidget 正确对齐**
  ```dart
  testWidgets('ColumnGripWidget centers child', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ColumnGripWidget(
          width: 96,
          height: 30,
          horizontalPadding: 8,
          child: Icon(Icons.drag_indicator),
        ),
      ),
    );

    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
    expect(sizedBox.width, 96);
    expect(sizedBox.height, 30);

    expect(find.byType(Padding), findsOneWidget);
    expect(find.byType(Center), findsOneWidget);
  });
  ```

- [ ] **测试 2.8: RowGripWidget 正确对齐**
  ```dart
  testWidgets('RowGripWidget centers child', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RowGripWidget(
          width: 50,
          height: 120,
          verticalPadding: 8,
          child: Icon(Icons.drag_indicator),
        ),
      ),
    );

    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
    expect(sizedBox.width, 50);
    expect(sizedBox.height, 120);

    expect(find.byType(Padding), findsOneWidget);
    expect(find.byType(Center), findsOneWidget);
  });
  ```

### 验收标准

- ✅ 所有 Widget 测试通过
- ✅ 热重载测试通过（修改 children 内容，检查是否正确更新）
- ✅ 无渲染错误

---

## 阶段 3 测试清单

**目标：** 验证渲染层替换后的功能正确性

### 功能测试（6 项）

- [ ] **测试 3.1: 柱宽度计算正确**
  - **操作：** 运行应用，检查柱的实际宽度
  - **预期：** 柱宽度 = 64（base） + 12（padding） + 4（border） + 16（margin） = 96
  - **验证方法：** 使用 Flutter DevTools 的 Inspector 检查 Container 的宽度

- [ ] **测试 3.2: topGripRow 抓手对齐**
  - **操作：** 运行应用，视觉检查抓手是否居中
  - **预期：** 抓手图标居中对齐到柱的内容区（不受 margin 影响）
  - **验证方法：** 截图对比，抓手应该在柱的视觉中心

- [ ] **测试 3.3: dataGrid 无 overflow 警告**
  - **操作：** 运行应用，检查控制台输出
  - **预期：** 无 "RenderFlex overflowed" 警告
  - **验证方法：** 观察控制台，确认无警告

- [ ] **测试 3.4: 让位边界计算精确**
  - **操作：** 拖拽列到柱之间，检查让位边界
  - **预期：** 让位边界应该在两柱的内容区中点
  - **验证方法：** 拖拽时观察边界位置，应该精确到柱的中心

- [ ] **测试 3.5: 行高度覆盖生效**
  - **操作：** 手动调整某一行的高度（如果有此功能）
  - **预期：** 所有柱的该行高度同步更新
  - **验证方法：** 调整行高度，检查所有柱是否同步

- [ ] **测试 3.6: 热重载正常**
  - **操作：** 修改代码（如修改柱的背景色），执行热重载
  - **预期：** 应用立即更新，无需重启
  - **验证方法：** 执行 `r` 热重载，检查是否更新

### 验收标准

- ✅ 柱宽度计算正确
- ✅ 抓手完美对齐
- ✅ 无 overflow 警告
- ✅ 让位边界精确
- ✅ 行高度覆盖生效
- ✅ 热重载正常

---

## 阶段 4 测试清单

**目标：** 验证拖拽反馈的视觉和功能正确性

### 拖拽测试（10 项）

- [ ] **测试 4.1: 列拖拽反馈显示**
  - **操作：** 从 topGripRow 拖拽列抓手
  - **预期：** 显示拖拽反馈视图（半透明，有阴影）
  - **验证方法：** 拖拽时观察反馈视图

- [ ] **测试 4.2: 列拖拽反馈尺寸匹配**
  - **操作：** 拖拽列抓手，对比反馈视图与原柱的尺寸
  - **预期：** 反馈视图的宽度/高度与原柱完全一致
  - **验证方法：** 视觉对比，反馈视图应与原柱重叠时完美匹配

- [ ] **测试 4.3: 列拖拽反馈透明度**
  - **操作：** 拖拽列抓手，检查反馈视图的透明度
  - **预期：** 反馈视图透明度约 0.7（可透过看到背景）
  - **验证方法：** 视觉检查，反馈视图应该是半透明的

- [ ] **测试 4.4: 列拖拽反馈阴影**
  - **操作：** 拖拽列抓手，检查反馈视图的阴影
  - **预期：** 反馈视图有 elevation = 4 的阴影效果
  - **验证方法：** 视觉检查，反馈视图应该有明显阴影

- [ ] **测试 4.5: 行拖拽反馈显示**
  - **操作：** 从 leftGripColumn 拖拽行抓手
  - **预期：** 显示拖拽反馈视图（包含所有柱的该行单元格）
  - **验证方法：** 拖拽时观察反馈视图

- [ ] **测试 4.6: 行拖拽反馈尺寸匹配**
  - **操作：** 拖拽行抓手，对比反馈视图的高度
  - **预期：** 反馈视图的高度与原行完全一致
  - **验证方法：** 视觉对比，反馈视图应与原行重叠时完美匹配

- [ ] **测试 4.7: 外部柱拖拽反馈**
  - **操作：** 从外部数据源拖拽柱到卡片
  - **预期：** 显示外部柱的拖拽反馈视图
  - **验证方法：** 拖拽时观察反馈视图

- [ ] **测试 4.8: 自定义 dragFeedbackBuilder 优先级**
  - **操作：** 如果设置了 `widget.dragFeedbackBuilder`，拖拽列
  - **预期：** 使用自定义 builder 的反馈视图，而非默认反馈
  - **验证方法：** 检查反馈视图是否符合自定义 builder 的输出

- [ ] **测试 4.9: 拖拽反馈跟随鼠标**
  - **操作：** 拖拽列/行，移动鼠标
  - **预期：** 反馈视图平滑跟随鼠标移动
  - **验证方法：** 拖拽时观察反馈视图的位置

- [ ] **测试 4.10: 拖拽释放后反馈消失**
  - **操作：** 拖拽列/行并释放
  - **预期：** 反馈视图立即消失
  - **验证方法：** 释放鼠标后观察

### 验收标准

- ✅ 列拖拽反馈显示正确
- ✅ 行拖拽反馈显示正确
- ✅ 反馈尺寸与原柱/行一致
- ✅ 反馈有透明度和阴影效果
- ✅ 自定义 builder 优先级正确
- ✅ 反馈视图流畅跟随鼠标
- ✅ 释放后反馈消失

---

## 阶段 5 测试清单

**目标：** 验证幽灵元素的尺寸一致性和视觉效果

### 幽灵元素测试（5 项）

- [ ] **测试 5.1: 幽灵列宽度匹配**
  - **操作：** 拖拽外部柱到卡片，在插入位置显示幽灵列
  - **预期：** 幽灵列的宽度与外部柱的 decoration.size.width 一致
  - **验证方法：** 视觉对比，幽灵列与拖拽反馈的宽度应完全一致

- [ ] **测试 5.2: 幽灵列高度匹配**
  - **操作：** 拖拽外部柱到卡片
  - **预期：** 幽灵列的高度与卡片的总行高度一致
  - **验证方法：** 视觉对比，幽灵列应与现有柱的高度一致

- [ ] **测试 5.3: 幽灵行高度匹配**
  - **操作：** 拖拽外部行到卡片
  - **预期：** 幽灵行的高度与外部行的高度一致
  - **验证方法：** 视觉对比，幽灵行高度应与拖拽反馈一致

- [ ] **测试 5.4: 拖拽到 insertIndex=0 无跳变**
  - **操作：** 拖拽行到表头行位置（insertIndex=0）
  - **预期：** 幽灵行高度不跳变，保持与拖拽行一致
  - **验证方法：** 拖拽时观察幽灵行高度，应无跳变

- [ ] **测试 5.5: 幽灵元素颜色和边框统一**
  - **操作：** 拖拽柱/行到卡片
  - **预期：** 所有幽灵元素（gripColumn、leftHeader、dataGrid）的颜色和边框样式一致
  - **验证方法：** 视觉检查，幽灵元素应为半透明蓝色，虚线边框

### 验收标准

- ✅ 幽灵列宽度与外部柱一致
- ✅ 幽灵列高度与卡片总行高度一致
- ✅ 幽灵行高度与外部行一致
- ✅ 拖拽到 insertIndex=0 无跳变
- ✅ 幽灵元素样式统一

---

## 阶段 6 测试清单

**目标：** 验证清理和优化后的代码质量和性能

### 代码质量测试（7 项）

- [ ] **测试 6.1: 无临时装饰代码**
  - **操作：** 检查 `editable_fourzhu_card_impl.dart` 文件
  - **预期：** 无临时 margin/padding/decoration 代码（Line 1813-1830 已删除）
  - **验证方法：** 搜索 `margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8)` 等临时代码

- [ ] **测试 6.2: 无调试日志**
  - **操作：** 运行应用，检查控制台输出
  - **预期：** 无调试日志（如 `🔍 [幽灵行-gripColumn]`）
  - **验证方法：** 观察控制台，确认无调试输出

- [ ] **测试 6.3: flutter analyze 通过**
  - **操作：** 运行 `flutter analyze`
  - **预期：** 无错误，无警告
  - **验证方法：** 检查命令行输出

- [ ] **测试 6.4: 单元测试覆盖率**
  - **操作：** 运行 `flutter test --coverage`
  - **预期：** 核心模型类（CellDecoration、PillarDecoration）覆盖率 > 80%
  - **验证方法：** 查看生成的 coverage 报告

- [ ] **测试 6.5: 性能无回归**
  - **操作：** 运行应用，执行拖拽、插入、重排等操作
  - **预期：** 帧率稳定，无卡顿
  - **验证方法：** 使用 Flutter DevTools 的 Performance 视图检查帧率

- [ ] **测试 6.6: 缓存机制生效**
  - **操作：** 在 `PillarDecoration.size` 中添加日志，检查调用次数
  - **预期：** 每个 decoration 的 `size` 计算只执行一次（后续调用返回缓存）
  - **验证方法：** 添加 `print('Computing size...')`，检查输出次数

- [ ] **测试 6.7: 热重载测试**
  - **操作：** 修改代码（如修改柱的圆角半径），执行热重载
  - **预期：** 应用立即更新，无需重启
  - **验证方法：** 执行 `r` 热重载，检查是否更新

### 验收标准

- ✅ 无临时代码和调试日志
- ✅ `flutter analyze` 无警告
- ✅ 单元测试覆盖率 > 80%
- ✅ 性能无回归
- ✅ 缓存机制生效
- ✅ 热重载正常

---

## 完整回归测试清单

**目标：** 验证所有功能正常，无回归问题

### 核心功能测试（14 项）

- [ ] **回归 1: 拖拽列功能**
  - **操作：** 从 topGripRow 拖拽列抓手，移动到其他位置
  - **预期：** 列成功移动，无错误
  - **验证方法：** 拖拽多次，确认功能正常

- [ ] **回归 2: 拖拽行功能**
  - **操作：** 从 leftGripColumn 拖拽行抓手，移动到其他位置
  - **预期：** 行成功移动，无错误
  - **验证方法：** 拖拽多次，确认功能正常

- [ ] **回归 3: 插入外部柱**
  - **操作：** 从外部数据源拖拽柱到卡片
  - **预期：** 柱成功插入，渲染正确
  - **验证方法：** 插入多个柱，确认功能正常

- [ ] **回归 4: 插入外部行**
  - **操作：** 从外部数据源拖拽行到卡片
  - **预期：** 行成功插入，渲染正确
  - **验证方法：** 插入多个行，确认功能正常

- [ ] **回归 5: 删除柱**
  - **操作：** 拖拽柱到删除区域（如果有此功能）
  - **预期：** 柱成功删除，其他柱位置调整
  - **验证方法：** 删除多个柱，确认功能正常

- [ ] **回归 6: 删除行**
  - **操作：** 拖拽行到删除区域
  - **预期：** 行成功删除，其他行位置调整
  - **验证方法：** 删除多个行，确认功能正常

- [ ] **回归 7: 柱重排**
  - **操作：** 拖拽柱到其他位置
  - **预期：** 柱顺序更新，无视觉跳变
  - **验证方法：** 重排多次，确认顺序正确

- [ ] **回归 8: 行重排**
  - **操作：** 拖拽行到其他位置
  - **预期：** 行顺序更新，无视觉跳变
  - **验证方法：** 重排多次，确认顺序正确

- [ ] **回归 9: 让位边界精确**
  - **操作：** 拖拽列到柱之间，观察让位边界
  - **预期：** 让位边界应该在两柱的内容区中点
  - **验证方法：** 拖拽时观察边界位置

- [ ] **回归 10: 抓手对齐**
  - **操作：** 视觉检查所有柱的抓手是否居中
  - **预期：** 抓手居中对齐到柱的内容区
  - **验证方法：** 截图对比，抓手应在柱的视觉中心

- [ ] **回归 11: 无 overflow 警告**
  - **操作：** 运行应用，执行各种操作
  - **预期：** 控制台无 "RenderFlex overflowed" 警告
  - **验证方法：** 观察控制台，确认无警告

- [ ] **回归 12: 柱装饰渲染**
  - **操作：** 检查柱的 margin、padding、border、shadow
  - **预期：** 装饰正确渲染，符合设计
  - **验证方法：** 视觉检查，使用 Inspector 确认属性

- [ ] **回归 13: 行高度调整（如果有此功能）**
  - **操作：** 手动调整某一行的高度
  - **预期：** 所有柱的该行高度同步更新
  - **验证方法：** 调整行高度，检查所有柱是否同步

- [ ] **回归 14: 柱宽度调整（如果有此功能）**
  - **操作：** 手动调整某一柱的宽度
  - **预期：** 柱宽度更新，抓手对齐保持正确
  - **验证方法：** 调整柱宽度，检查抓手是否仍居中

### 边界情况测试（6 项）

- [ ] **边界 1: 空卡片**
  - **操作：** 删除所有柱和行
  - **预期：** 应用不崩溃，显示空状态
  - **验证方法：** 删除所有内容，检查应用是否正常

- [ ] **边界 2: 单柱单行**
  - **操作：** 仅保留一个柱和一行
  - **预期：** 应用正常显示，拖拽功能可用
  - **验证方法：** 测试拖拽功能

- [ ] **边界 3: 大量柱（>20）**
  - **操作：** 添加 20+ 个柱
  - **预期：** 应用流畅，无性能问题
  - **验证方法：** 检查帧率，拖拽是否流畅

- [ ] **边界 4: 大量行（>20）**
  - **操作：** 添加 20+ 行
  - **预期：** 应用流畅，无性能问题
  - **验证方法：** 检查帧率，拖拽是否流畅

- [ ] **边界 5: 极窄柱**
  - **操作：** 创建宽度极窄的柱（如 16px）
  - **预期：** 柱正确渲染，抓手对齐正确
  - **验证方法：** 视觉检查，测试拖拽

- [ ] **边界 6: 极高行**
  - **操作：** 创建高度极高的行（如 200px）
  - **预期：** 行正确渲染，幽灵行高度匹配
  - **验证方法：** 视觉检查，测试拖拽

### 验收标准

- ✅ 所有核心功能测试通过
- ✅ 所有边界情况测试通过
- ✅ 无功能回归
- ✅ 无性能回归
- ✅ 无视觉问题

---

## 自动化测试建议

### 单元测试示例

```dart
// test/widgets/editable_fourzhu_card/models/pillar_decoration_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:common/widgets/editable_fourzhu_card/models/decoration/pillar_decoration.dart';
import 'package:common/widgets/editable_fourzhu_card/models/decoration/cell_decoration.dart';
import 'package:common/enums/row_type.dart';

void main() {
  group('PillarDecoration', () {
    test('size calculation includes margin, border, padding, and cells', () {
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

      expect(decoration.size.width, 64 + 12 + 4 + 16);  // 96
      expect(decoration.size.height, 96 + 12 + 4 + 16);  // 128
    });

    test('contentCenter calculation', () {
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

      final center = decoration.contentCenter;
      expect(center.dx, 8 + 2 + 6 + 32);  // 48
      expect(center.dy, 8 + 2 + 6 + 48);  // 64
    });

    test('cache mechanism', () {
      final decoration = PillarDecoration(
        margin: EdgeInsets.all(8),
        cells: [CellDecoration(rowType: RowType.heavenlyStem, height: 48)],
        basePillarWidth: 64,
      );

      final size1 = decoration.size;
      final size2 = decoration.size;
      expect(identical(size1, size2), true);

      decoration.invalidateCache();
      final size3 = decoration.size;
      expect(identical(size2, size3), false);
    });
  });

  group('CellDecoration', () {
    test('effectiveHeight priority: explicit height', () {
      final cell = CellDecoration(
        rowType: RowType.heavenlyStem,
        height: 60,
      );
      expect(cell.effectiveHeight, 60);
    });

    test('effectiveHeight priority: isHeaderRow', () {
      final cell = CellDecoration(
        rowType: RowType.columnTitle,
        isHeaderRow: true,
      );
      expect(cell.effectiveHeight, 40);  // columnTitleHeight
    });

    test('effectiveHeight priority: rowType inference', () {
      final cell1 = CellDecoration(rowType: RowType.heavenlyStem);
      expect(cell1.effectiveHeight, 48);  // ganZhiCellHeight

      final cell2 = CellDecoration(rowType: RowType.rowDivider);
      expect(cell2.effectiveHeight, 12);  // dividerCellHeight
    });
  });
}
```

### Widget 测试示例

```dart
// test/widgets/editable_fourzhu_card/widgets/pillar_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/widgets/editable_fourzhu_card/widgets/pillar_widget.dart';
import 'package:common/widgets/editable_fourzhu_card/models/decoration/pillar_decoration.dart';
import 'package:common/widgets/editable_fourzhu_card/models/decoration/cell_decoration.dart';
import 'package:common/enums/row_type.dart';

void main() {
  group('PillarWidget', () {
    testWidgets('renders with correct structure', (tester) async {
      final decoration = PillarDecoration.normal(
        cells: [
          CellDecoration.ganZhi(),
          CellDecoration.ganZhi(),
        ],
        basePillarWidth: 64,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PillarWidget(
              decoration: decoration,
              children: [Text('甲'), Text('子')],
            ),
          ),
        ),
      );

      // 检查 Column 存在
      expect(find.byType(Column), findsOneWidget);

      // 检查 CellWidget 数量
      expect(find.byType(CellWidget), findsNWidgets(2));

      // 检查 Text 内容
      expect(find.text('甲'), findsOneWidget);
      expect(find.text('子'), findsOneWidget);
    });

    testWidgets('applies margin correctly', (tester) async {
      final decoration = PillarDecoration.normal(
        cells: [CellDecoration.ganZhi()],
        basePillarWidth: 64,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PillarWidget(
              decoration: decoration,
              children: [Text('甲')],
            ),
          ),
        ),
      );

      final outerContainer = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(outerContainer.margin, decoration.margin);
    });
  });
}
```

### 集成测试示例

```dart
// integration_test/drag_drop_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:your_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Drag and Drop', () {
    testWidgets('drag column to reorder', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 找到第一个柱的抓手
      final firstGrip = find.byIcon(Icons.drag_indicator).first;

      // 找到第三个柱的位置
      final thirdColumn = find.text('第三柱');  // 根据实际内容调整

      // 拖拽第一个柱到第三个柱的位置
      await tester.drag(firstGrip, Offset(200, 0));
      await tester.pumpAndSettle();

      // 验证顺序已更新
      // ... 添加验证逻辑
    });

    testWidgets('drag row to reorder', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 找到第一行的抓手
      final firstGrip = find.byIcon(Icons.drag_indicator).at(10);  // 根据实际索引调整

      // 拖拽第一行到第二行的位置
      await tester.drag(firstGrip, Offset(0, 100));
      await tester.pumpAndSettle();

      // 验证顺序已更新
      // ... 添加验证逻辑
    });
  });
}
```

### 性能基准测试脚本

```dart
// test/performance/pillar_decoration_benchmark.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/widgets/editable_fourzhu_card/models/decoration/pillar_decoration.dart';
import 'package:common/widgets/editable_fourzhu_card/models/decoration/cell_decoration.dart';
import 'package:common/enums/row_type.dart';

void main() {
  group('Performance Benchmarks', () {
    test('PillarDecoration.size calculation performance', () {
      final decoration = PillarDecoration(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(6),
        border: Border.all(width: 2),
        cells: List.generate(20, (_) => CellDecoration.ganZhi()),
        basePillarWidth: 64,
      );

      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        decoration.invalidateCache();
        final _ = decoration.size;
      }
      stopwatch.stop();

      print('10000 size calculations: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));  // 应在 1 秒内完成
    });

    test('Cache effectiveness', () {
      final decoration = PillarDecoration(
        margin: EdgeInsets.all(8),
        cells: List.generate(20, (_) => CellDecoration.ganZhi()),
        basePillarWidth: 64,
      );

      final stopwatch1 = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        decoration.invalidateCache();
        final _ = decoration.size;
      }
      stopwatch1.stop();

      final stopwatch2 = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        final _ = decoration.size;  // 使用缓存
      }
      stopwatch2.stop();

      print('Without cache: ${stopwatch1.elapsedMilliseconds}ms');
      print('With cache: ${stopwatch2.elapsedMilliseconds}ms');
      expect(stopwatch2.elapsedMilliseconds, lessThan(stopwatch1.elapsedMilliseconds ~/ 10));
    });
  });
}
```

---

## 总结

本测试检查清单提供了完整的测试覆盖：

1. **阶段性测试** - 每个阶段都有详细的测试清单，确保质量
2. **完整回归测试** - 验证所有功能，无回归问题
3. **自动化测试建议** - 单元测试、Widget 测试、集成测试、性能基准测试

**建议：**

- 每完成一个阶段，立即执行该阶段的测试清单
- 阶段 6 完成后，执行完整回归测试
- 定期运行自动化测试，确保代码质量

**测试覆盖目标：**

- 单元测试覆盖率 > 80%
- Widget 测试覆盖核心组件
- 集成测试覆盖核心流程
- 手动测试覆盖视觉和交互

---

**祝测试顺利！** 🚀
