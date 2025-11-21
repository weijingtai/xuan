    CardLayoutModel updateColumnWidth(int index, double width);

    // 尺寸计算
    Size computeSize(MeasurementContext ctx);
  }

  @immutable
  class MeasurementContext {
    final double defaultPillarWidth;
    final double defaultOtherCellHeight;
    final double ganZhiCellHeight;
    // ... 其他测量参数
  }

  2.1.2 拖拽操作功能

  列拖拽操作：
  // 插入列
  CardLayoutModel insertColumn(int index, ColumnDimension column)

  // 删除列  
  CardLayoutModel removeColumn(int index)

  // 重排列
  CardLayoutModel reorderColumn(int from, int to)

  // 更新列宽覆盖
  CardLayoutModel updateColumnWidth(int index, double width)

  // 提取宽度覆盖
  Map<int, double> extractColumnWidthOverrides()

  行拖拽操作：
  // 插入行
  CardLayoutModel insertRow(int index, RowDimension row)

  // 删除行
  CardLayoutModel removeRow(int index)

  // 重排行
  CardLayoutModel reorderRow(int from, int to)

  // 更新行高覆盖
  CardLayoutModel updateRowHeight(int index, double height)

  // 提取高度覆盖
  Map<int, double> extractRowHeightOverrides()

  2.1.3 索引管理

  // 自动重建索引（消除索引错位 bug）
  List<ColumnDimension> _reindexColumns(List<ColumnDimension> cols);
  List<RowDimension> _reindexRows(List<RowDimension> rws);

  2.1.4 与拖拽组件的集成

  // 在拖拽过程中更新布局模型
  _layoutNotifier.value = CardLayoutModel.fromNotifiers(
    pillars: _currentPillars(),
    rows: _currentTextRows(),
    padding: widget.paddingNotifier.value,
    columnWidthOverrides: _columnWidthOverrides,
    rowHeightOverrides: _rowHeightOverrides,
    dragHandleRowHeight: _effectiveDragHandleRowHeight,
    dragHandleColWidth: _effectiveDragHandleColWidth,
  );

  2.2 当前使用场景

  2.2.1 拖拽开始

  void _onDragStart(int index, DragKind kind) {
    if (kind == DragKind.column) {
      startColumnDrag(index);
    } else {
      startRowDrag(index);
    }
  }

  2.2.2 拖拽更新

  void _onDragUpdate(int newIndex, DragKind kind) {
    if (kind == DragKind.column) {
      final currentModel = _layoutNotifier.value;
      _layoutNotifier.value = currentModel.reorderColumn(_dragIndex, newIndex);
    }
  }

  2.2.3 拖拽结束

  void _onDragEnd(DragKind kind) {
    // 更新数据源
    if (kind == DragKind.column) {
      _setPillars(_currentPillars());
    } else {
      _setTextRows(_currentTextRows());
    }

    // 清除拖拽状态
    _clearDragState();
  }

  3. 目标架构设计 (新系统)

  3.1 增强的 CardMetricsSnapshot

  3.1.1 扩展数据结构

  @immutable
  class EnhancedCardMetricsSnapshot {
    // 原有度量数据
    final Map<String, PillarMetrics> pillars;
    final Map<String, RowMetrics> rows;
    final Map<String, CellMetrics> cells;
    final CardTotals totals;

    // 新增：顺序管理
    final List<String> pillarOrderUuid;
    final List<String> rowOrderUuid;

    // 新增：覆盖管理
    final Map<int, double> columnWidthOverrides;
    final Map<int, double> rowHeightOverrides;

    // 新增：拖拽状态
    final DragState? dragState;

    // 构造函数
    const EnhancedCardMetricsSnapshot({
      required this.pillars,
      required this.rows,
      required this.cells,
      required this.totals,
      required this.pillarOrderUuid,
      required this.rowOrderUuid,
      this.columnWidthOverrides = const {},
      this.rowHeightOverrides = const {},
      this.dragState,
    });
  }

  3.1.2 拖拽状态管理

  @immutable
  sealed class DragState {}

  class ColumnDragging implements DragState {
    final int currentIndex;
    final String pillarUuid;

    const ColumnDragging({
      required this.currentIndex,
      required this.pillarUuid,
    });
  }

  class RowDragging implements DragState {
    final int currentIndex;
    final String rowUuid;

    const RowDragging({
      required this.currentIndex,
      required this.rowUuid,
    });
  }

  class IdleDragState implements DragState {
    const IdleDragState();
  }

  3.2 增强的 CardMetricsCalculator

  3.2.1 扩展计算器接口

  class EnhancedCardMetricsCalculator extends CardMetricsCalculator {
    // 原有功能
    @override
    CardMetricsSnapshot compute();

    // 新增：操作方法
    EnhancedCardMetricsSnapshot insertColumn(int index, PillarPayload column);
    EnhancedCardMetricsSnapshot removeColumn(int index);
    EnhancedCardMetricsSnapshot reorderColumn(int from, int to);
    EnhancedCardMetricsSnapshot updateColumnWidth(int index, double width);
    EnhancedCardMetricsSnapshot clearColumnWidthOverride(int index);

    EnhancedCardMetricsSnapshot insertRow(int index, TextRowPayload row);
    EnhancedCardMetricsSnapshot removeRow(int index);
    EnhancedCardMetricsSnapshot reorderRow(int from, int to);
    EnhancedCardMetricsSnapshot updateRowHeight(int index, double height);
    EnhancedCardMetricsSnapshot clearRowHeightOverride(int index);

    // 新增：拖拽支持
    EnhancedCardMetricsSnapshot startColumnDrag(int index);
    EnhancedCardMetricsSnapshot updateColumnDrag(int newIndex);
    EnhancedCardMetricsSnapshot endColumnDrag();
    EnhancedCardMetricsSnapshot startRowDrag(int index);
    EnhancedCardMetricsSnapshot updateRowDrag(int newIndex);
    EnhancedCardMetricsSnapshot endRowDrag();

    // 新增：覆盖管理
    Map<int, double> getColumnWidthOverrides();
    Map<int, double> getRowHeightOverrides();

    // 新增：幽灵元素尺寸
    Size getColumnGhostSize();
    Size getRowGhostSize();
  }

  3.2.2 核心算法实现

  列重排算法：
  EnhancedCardMetricsSnapshot reorderColumn(int from, int to) {
    final currentSnapshot = compute() as EnhancedCardMetricsSnapshot;

    // 重建顺序
    final newOrder = List<String>.from(currentSnapshot.pillarOrderUuid);
    final item = newOrder.removeAt(from);
    final target = to > from ? to - 1 : to;
    final safeTarget = target.clamp(0, newOrder.length);
    newOrder.insert(safeTarget, item);

    // 更新拖拽状态
    DragState? newDragState;
    if (currentSnapshot.dragState is ColumnDragging) {
      final currentDrag = currentSnapshot.dragState as ColumnDragging;
      if (currentDrag.currentIndex == from) {
        newDragState = ColumnDragging(
          currentIndex: safeTarget,
          pillarUuid: currentDrag.pillarUuid,
        );
      }
    }

    return EnhancedCardMetricsSnapshot(
      pillarOrderUuid: newOrder,
      dragState: newDragState ?? currentSnapshot.dragState,
      // ... 其他字段保持不变
    );
  }

  宽度覆盖算法：
  EnhancedCardMetricsSnapshot updateColumnWidth(int index, double width) {
    final currentSnapshot = compute() as EnhancedCardMetricsSnapshot;

    // 验证索引
    if (index < 0 || index >= currentSnapshot.pillarOrderUuid.length) {
      return currentSnapshot;
    }

    // 更新覆盖
    final newOverrides = Map<int, double>.from(currentSnapshot.columnWidthOverrides);
    newOverrides[index] = width;

    return EnhancedCardMetricsSnapshot(
      columnWidthOverrides: newOverrides,
      // ... 其他字段保持不变
    );
  }

  3.3 与现有拖拽组件的集成

  3.3.1 拖拽控制器扩展

  class EnhancedDragController extends EditableCardDragController {
    final EnhancedCardMetricsCalculator calculator;
    final ValueNotifier<EnhancedCardMetricsSnapshot> snapshotNotifier;

    EnhancedDragController({
      required this.calculator,
      required this.snapshotNotifier,
      int columnMoveCooldownMs = 12,
      int rowMoveCooldownMs = 12,
    });

    // 列拖拽
    void startColumnDrag(int index) {
      final newSnapshot = calculator.startColumnDrag(index);
      snapshotNotifier.value = newSnapshot;
    }

    void updateColumnDrag(int newIndex) {
      final newSnapshot = calculator.updateColumnDrag(newIndex);
      snapshotNotifier.value = newSnapshot;
    }

    void endColumnDrag() {
      final newSnapshot = calculator.endColumnDrag();
      snapshotNotifier.value = newSnapshot;
    }

    // 行拖拽（类似实现）
    // ...
  }

  3.3.2 幽灵元素支持

  class GhostPillarWidget {
    final EnhancedCardMetricsSnapshot snapshot;
    final DragState? dragState;

    const GhostPillarWidget({
      required this.snapshot,
      required this.dragState,
    });

    @override
    Widget build(BuildContext context) {
      if (dragState is ColumnDragging) {
        final dragging = dragState as ColumnDragging;
        final size = snapshot.getColumnGhostSize();

        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3),
            border: Border.all(color: Colors.blue),
          ),
        );
      }

      return const SizedBox.shrink();
    }
  }

  4. 详细迁移计划

  4.1 迁移阶段划分

  阶段一：基础设施准备（第1-2周）

  - 扩展 CardMetricsSnapshot 数据结构
  - 实现 EnhancedCardMetricsCalculator 基础框架
  - 创建拖拽状态管理类
  - 建立测试基础设施

  阶段二：核心操作实现（第3-4周）

  - 实现列/行插入、删除、重排功能
  - 实现宽度/高度覆盖管理
  - 实现索引自动重建
  - 集成到现有拖拽流程

  阶段三：拖拽支持完善（第5-6周）

  - 实现完整的拖拽状态管理
  - 实现幽灵元素显示
  - 优化拖拽性能
  - 完善错误处理

  阶段四：系统切换与优化（第7-8周）

  - 替换所有使用旧系统的地方
  - 性能优化和内存管理
  - 移除旧的 MeasurementContext 系统
  - 完整测试和文档

  4.2 技术实现细节

  4.2.1 数据结构迁移策略

  旧数据结构：
  class CardLayoutModel {
    final List<ColumnDimension> columns;  // 包含索引和载荷
    final List<RowDimension> rows;
  }

  新数据结构：
  class EnhancedCardMetricsSnapshot {
    final List<String> pillarOrderUuid;    // 顺序
    final Map<String, PillarMetrics> pillars; // 度量数据
    final Map<int, double> columnWidthOverrides; // 覆盖
  }

  迁移映射：
  // 从 CardLayoutModel 创建 EnhancedCardMetricsSnapshot
  EnhancedCardMetricsSnapshot fromCardLayoutModel(
    CardLayoutModel layoutModel,
    CardPayload payload,
  ) {
    final pillarOrder = layoutModel.columns
        .map((col) => col.payload.uuid)
        .toList();

    final pillarMap = {
      for (final col in layoutModel.columns)
        col.payload.uuid: PillarMetrics(
          pillarUuid: col.payload.uuid,
          pillarType: col.payload.pillarType.name,
          contentWidth: calculateContentWidth(col.payload),
          // ... 其他度量
        )
    };

    final widthOverrides = layoutModel.extractColumnWidthOverrides();

    return EnhancedCardMetricsSnapshot(
      pillarOrderUuid: pillarOrder,
      pillars: pillarMap,
      columnWidthOverrides: widthOverrides,
      // ... 行数据类似处理
    );
  }

  4.2.2 算法迁移策略

  旧算法：
  Size computeSize(MeasurementContext ctx) {
    final totalColumnsWidth = columns.fold<double>(
      0.0,
      (sum, col) => sum + col.measure(ctx),
    );
    // ...
  }

  新算法：
  Size computeSize() {
    final totalColumnsWidth = pillarOrderUuid.fold<double>(
      0.0,
      (sum, uuid) => sum + pillars[uuid]!.contentWidth +
                         pillars[uuid]!.decorationWidth,
    );
    // ...
  }

  4.2.3 事件处理迁移

  旧事件处理：
  void _onColumnReordered(int from, int to) {
    final currentModel = _layoutNotifier.value;
    _layoutNotifier.value = currentModel.reorderColumn(from, to);
  }

  新事件处理：
  void _onColumnReordered(int from, int to) {
    final currentSnapshot = _snapshotNotifier.value;
    final newSnapshot = _calculator.reorderColumn(from, to);
    _snapshotNotifier.value = newSnapshot;
  }

  5. 风险评估与缓解策略

  5.1 技术风险

  5.1.1 功能回归风险

  风险描述：迁移过程中可能丢失某些功能或行为改变。

  缓解策略：
  - 建立完整的自动化测试套件，覆盖所有拖拽场景
  - 实施A/B测试，并行运行新旧系统对比结果
  - 逐步迁移，每次迁移一个功能点并验证

  5.1.2 性能回归风险

  风险描述：新系统可能性能不如旧系统。

  缓解策略：
  - 进行性能基准测试，建立性能基线
  - 实施性能监控，及时发现性能问题
  - 优化关键路径算法，使用缓存减少重复计算

  5.1.3 兼容性风险

  风险描述：新系统可能与现有拖拽组件不兼容。

  缓解策略：
  - 创建适配层，确保接口兼容性
  - 渐进式替换，先在内部使用，再暴露给外部
  - 保持旧系统作为fallback，直到新系统完全稳定

  5.2 项目风险

  5.2.1 时间风险

  风险描述：迁移时间可能超出预期。

  缓解策略：
  - 分阶段交付，每个阶段都有可用的功能
  - 优先级排序，确保核心功能优先完成
  - 预留缓冲时间，应对意外问题

  5.2.2 资源风险

  风险描述：开发资源可能不足。

  缓解策略：
  - 明确依赖关系，确保关键路径资源充足
  - 考虑外部支持，如咨询或外包
  - 调整范围，确保MVP功能按时交付

  6. 测试策略

  6.1 单元测试

  6.1.1 数据结构测试

  void testEnhancedCardMetricsSnapshotCreation() {
    final snapshot = EnhancedCardMetricsSnapshot(
      pillars: testPillars,
      rows: testRows,
      cells: testCells,
      totals: testTotals,
      pillarOrderUuid: ['pillar1', 'pillar2'],
      rowOrderUuid: ['row1', 'row2'],
      columnWidthOverrides: {0: 100.0},
      rowHeightOverrides: {1: 50.0},
    );

    expect(snapshot.pillarOrderUuid, equals(['pillar1', 'pillar2']));
    expect(snapshot.columnWidthOverrides[0], equals(100.0));
  }

  6.1.2 操作方法测试

  void testColumnReordering() {
    final calculator = EnhancedCardMetricsCalculator(
      theme: testTheme,
      payload: testPayload,
    );

    final initialSnapshot = calculator.compute();
    final reorderedSnapshot = calculator.reorderColumn(0, 1);

    expect(reorderedSnapshot.pillarOrderUuid, equals(['pillar2', 'pillar1']));
  }

  6.1.3 拖拽状态测试

  void testDragStateManagement() {
    final calculator = EnhancedCardMetricsCalculator(
      theme: testTheme,
      payload: testPayload,
    );

    final startSnapshot = calculator.startColumnDrag(0);
    expect(startSnapshot.dragState, isA<ColumnDragging>());

    final updateSnapshot = calculator.updateColumnDrag(1);
    expect(updateSnapshot.dragState!.currentIndex, equals(1));

    final endSnapshot = calculator.endColumnDrag();
    expect(endSnapshot.dragState, isNull);
  }

  6.2 集成测试

  6.2.1 拖拽流程测试

  void testFullDragFlow() {
    // 创建测试组件
    await tester.pumpWidget(
      EditableFourZhuCardV3(
        cardPayloadNotifier: ValueNotifier(testPayload),
        // ... 其他参数
      ),
    );

    // 开始拖拽
    await tester.drag(find.byKey('column_0'), const Offset(0, 0), const Offset(50, 0));

    // 验证拖拽状态
    final cardState = tester.state(find.byType<EditableFourZhuCardV3>());
    expect(cardState.snapshot.dragState, isA<ColumnDragging>());

    // 结束拖拽
    await tester.drag(find.byKey('column_0'), const Offset(50, 0), const Offset(0, 0));

    // 验证结果
    expect(cardState.snapshot.dragState, isNull);
    expect(cardState.snapshot.pillarOrderUuid, equals(['pillar2', 'pillar1']));
  }

  6.2.2 性能测试

  void testDragPerformance() {
    final stopwatch = Stopwatch()..start();

    // 执行1000次拖拽操作
    for (int i = 0; i < 1000; i++) {
      calculator.reorderColumn(0, 1);
      calculator.reorderColumn(1, 0);
    }

    stopwatch.stop();

    // 验证性能
    expect(stopwatch.elapsedMilliseconds, lessThan(1000));
  }

  6.3 用户验收测试

  6.3.1 手动测试场景

  1. 基本拖拽：验证列和行可以正常拖拽重排
  2. 边界情况：验证拖拽到边界位置的行为
  3. 快速拖拽：验证快速连续拖拽的稳定性
  4. 取消拖拽：验证拖拽取消后的状态恢复
  5. 多列拖拽：验证同时拖拽多个元素的行为

  6.3.2 兼容性测试

  1. 旧数据格式：验证旧版本数据的兼容性
  2. 不同屏幕尺寸：验证在不同设备上的表现
  3. 辅助功能：验证屏幕阅读器等辅助功能
  4. 浏览器兼容：如果是Web应用，验证不同浏览器

  7. 时间线与资源估算

  7.1 详细时间线

  | 阶段       | 任务                             | 时间  | 负责人   | 交付物      |
  |----------|--------------------------------|-----|-------|----------|
  | 阶段一：基础设施 | 扩展数据结构设计                       | 3天  | 架构师   | 数据结构设计文档 |
  |          | 实现 EnhancedCardMetricsSnapshot | 2天  | 开发者   | 代码实现     |
  |          | 创建拖拽状态管理类                      | 2天  | 开发者   | 代码实现     |
  |          | 建立测试基础设施                       | 2天  | 测试工程师 | 测试框架     |
  | 阶段二：核心操作 | 实现列操作方法                        | 5天  | 开发者   | 功能实现     |
  |          | 实现行操作方法                        | 5天  | 开发者   | 功能实现     |
  |          | 实现覆盖管理                         | 3天  | 开发者   | 功能实现     |
  |          | 集成现有拖拽流程                       | 3天  | 开发者   | 集成代码     |
  | 阶段三：拖拽支持 | 实现拖拽状态管理                       | 4天  | 开发者   | 功能实现     |
  |          | 实现幽灵元素                         | 2天  | 开发者   | UI组件     |
  |          | 性能优化                           | 2天  | 开发者   | 性能报告     |
  |          | 错误处理完善                         | 2天  | 开发者   | 错误处理     |
  | 阶段四：系统切换 | 替换旧系统调用                        | 5天  | 开发者   | 重构代码     |
  |          | 移除旧系统                          | 2天  | 开发者   | 代码清理     |
  |          | 最终测试                           | 3天  | 测试工程师 | 测试报告     |
  |          | 文档更新                           | 2天  | 技术写作  | 用户文档     |

  7.2 资源需求

  7.2.1 人力资源

  | 角色      | 人数  | 时间  | 工作量  |
  |---------|-----|-----|------|
  | 架构师     | 1   | 8周  | 8人周  |
  | 高级开发工程师 | 2   | 8周  | 16人周 |
  | 测试工程师   | 1   | 6周  | 6人周  |
  | 技术写作    | 1   | 2周  | 2人周  |
  | 总计      | 5   | 8周  | 32人周 |

  7.2.2 技术资源

  - 开发环境：Flutter 3.0+，Dart 3.0+
  - 测试环境：模拟器、真实设备、Web浏览器
  - CI/CD：GitHub Actions 或类似
  - 性能监控：Firebase Performance 或类似

  7.3 风险缓冲

  - 时间缓冲：预留2周缓冲时间，总计10周
  - 资源缓冲：准备20%的额外资源应对意外情况
  - 回滚计划：准备快速回滚到旧系统的方案

  8. 成功标准

  8.1 技术指标

  - ✅ 所有现有拖拽功能在新系统中正常工作
  - ✅ 性能不低于旧系统（关键操作响应时间 < 100ms）
  - ✅ 内存使用量不超过旧系统的110%
  - ✅ 测试覆盖率达到90%以上
  - ✅ 代码质量指标达标（圈复杂度 < 10，测试通过率 100%）

  8.2 功能指标

  - ✅ 列拖拽：插入、删除、重排、宽度覆盖
  - ✅ 行拖拽：插入、删除、重排、高度覆盖
  - ✅ 拖拽状态：开始、更新、结束、取消
  - ✅ 幽灵元素：正确显示和尺寸计算
  - ✅ 索引管理：自动重建和错误处理

  8.3 用户体验指标

  - ✅ 拖拽操作流畅度（帧率 > 60fps）
  - ✅ 视觉反馈及时性（延迟 < 16ms）
  - ✅ 错误恢复能力（自动恢复到正确状态）
  - ✅ 兼容性（支持所有现有数据格式）

  ---
  可拖拽操作迁移方案 - 详细任务列表

  高优先级任务 (阶段一：基础设施)

  数据结构设计

  - DESIGN-001: 设计 EnhancedCardMetricsSnapshot 数据结构
    - 确定顺序管理字段设计
    - 确定覆盖管理字段设计
    - 确定拖拽状态字段设计
    - 创建设计文档和UML图
  - DESIGN-002: 设计拖拽状态管理类
    - 定义 DragState 基类和子类
    - 设计状态转换逻辑
    - 设计状态序列化支持
    - 创建状态图文档

  基础设施实现

  - CODE-001: 创建 EnhancedCardMetricsSnapshot 类
    - 实现基础数据结构
    - 实现序列化/反序列化
    - 实现相等性和哈希码
    - 添加单元测试
  - CODE-002: 创建 DragState 相关类
    - 实现 DragState 基类
    - 实现 ColumnDragging 类
    - 实现 RowDragging 类
    - 实现 IdleDragState 类
    - 添加单元测试
  - CODE-003: 创建 EnhancedCardMetricsCalculator 基类
    - 继承现有 CardMetricsCalculator
    - 添加操作方法占位符
    - 添加拖拽支持方法占位符
    - 添加单元测试框架

  测试基础设施

  - TEST-001: 建立单元测试框架
    - 创建测试数据工厂
    - 创建模拟对象
    - 设置测试环境
    - 编写基础测试用例
  - TEST-002: 建立集成测试框架
    - 创建测试组件包装器
    - 设置拖拽测试环境
    - 创建测试辅助方法
    - 编写集成测试用例

  中优先级任务 (阶段二：核心操作)

  列操作实现

  - CODE-004: 实现 insertColumn 方法
    - 实现列插入逻辑
    - 处理索引重建
    - 处理边界条件
    - 添加单元测试
  - CODE-005: 实现 removeColumn 方法
    - 实现列删除逻辑
    - 处理索引重建
    - 处理边界条件
    - 添加单元测试
  - CODE-006: 实现 reorderColumn 方法
    - 实现列重排逻辑
    - 处理索引重建
    - 处理拖拽状态更新
    - 添加单元测试
  - CODE-007: 实现 updateColumnWidth 方法
    - 实现宽度覆盖逻辑
    - 验证索引有效性
    - 处理边界值
    - 添加单元测试
  - CODE-008: 实现 clearColumnWidthOverride 方法
    - 实现覆盖清除逻辑
    - 验证索引有效性
    - 处理边界条件
    - 添加单元测试

  行操作实现

  - CODE-009: 实现 insertRow 方法
    - 实现行插入逻辑
    - 处理索引重建
    - 处理边界条件
    - 添加单元测试
  - CODE-010: 实现 removeRow 方法
    - 实现行删除逻辑
    - 处理索引重建
    - 处理边界条件
    - 添加单元测试
  - CODE-011: 实现 reorderRow 方法
    - 实现行重排逻辑
    - 处理索引重建
    - 处理拖拽状态更新
    - 添加单元测试
  - CODE-012: 实现 updateRowHeight 方法
    - 实现高度覆盖逻辑
    - 验证索引有效性
    - 处理边界值
    - 添加单元测试
  - CODE-013: 实现 clearRowHeightOverride 方法
    - 实现覆盖清除逻辑
    - 验证索引有效性
    - 处理边界条件
    - 添加单元测试

  覆盖管理实现

  - CODE-014: 实现 getColumnWidthOverrides 方法
    - 提取列宽度覆盖
    - 过滤无效值
    - 返回格式化结果
    - 添加单元测试
  - CODE-015: 实现 getRowHeightOverrides 方法
    - 提取行高度覆盖
    - 过滤无效值
    - 返回格式化结果
    - 添加单元测试

  集成现有系统

  - INTEGRATE-001: 集成到 EditableFourZhuCardV3
    - 替换 _layoutNotifier 为 _snapshotNotifier
    - 更新 initState 方法
    - 更新 didUpdateWidget 方法
    - 添加集成测试
  - INTEGRATE-002: 集成拖拽事件处理
    - 更新 _onColumnReordered 方法
    - 更新 _onRowReordered 方法
    - 更新拖拽开始/结束处理
    - 添加集成测试

  中优先级任务 (阶段三：拖拽支持)

  拖拽状态管理

  - CODE-016: 实现 startColumnDrag 方法
    - 创建 ColumnDragging 状态
    - 更新快照拖拽状态
    - 处理边界条件
    - 添加单元测试
  - CODE-017: 实现 updateColumnDrag 方法
    - 更新 ColumnDragging 状态
    - 重建列顺序
    - 处理边界条件
    - 添加单元测试
  - CODE-018: 实现 endColumnDrag 方法
    - 清除拖拽状态
    - 最终化列顺序
    - 触发数据源更新
    - 添加单元测试
  - CODE-019: 实现行拖拽方法 (startRowDrag, updateRowDrag, endRowDrag)
    - 实现行拖拽开始逻辑
    - 实现行拖拽更新逻辑
    - 实现行拖拽结束逻辑
    - 添加单元测试

  幽灵元素支持

  - UI-001: 实现 getColumnGhostSize 方法
    - 计算幽灵列尺寸
    - 考虑拖拽状态
    - 返回正确尺寸
    - 添加单元测试
  - UI-002: 实现 getRowGhostSize 方法
    - 计算幽灵行尺寸
    - 考虑拖拽状态
    - 返回正确尺寸
    - 添加单元测试
  - UI-003: 创建 GhostPillarWidget 组件
    - 实现幽灵列显示
    - 支持拖拽状态
    - 添加视觉效果
    - 添加单元测试
  - UI-004: 创建 GhostRowWidget 组件
    - 实现幽灵行显示
    - 支持拖拽状态
    - 添加视觉效果
    - 添加单元测试

  性能优化

  - PERF-001: 实现增量计算优化
    - 识别可重用的计算结果
    - 实现计算结果缓存
    - 减少重复计算
    - 添加性能测试
  - PERF-002: 优化内存使用
    - 实现对象池模式
    - 优化数据结构
    - 减少内存分配
    - 添加内存测试

  错误处理

  - ERROR-001: 实现索引边界检查
    - 验证所有索引操作
    - 提供有意义的错误信息
    - 实现优雅降级
    - 添加错误测试
  - ERROR-002: 实现状态一致性检查
    - 验证数据一致性
    - 检测状态冲突
    - 实现自动恢复
    - 添加错误测试

  低优先级任务 (阶段四：系统切换)

  系统切换

  - MIGRATE-001: 替换所有旧系统调用
    - 识别所有使用 CardLayoutModel 的地方
    - 替换为 EnhancedCardMetricsSnapshot
    - 更新相关方法调用
    - 添加回归测试
  - MIGRATE-002: 替换所有 MeasurementContext 调用
    - 识别所有使用 MeasurementContext 的地方
    - 替换为新的计算方法
    - 更新相关方法调用
    - 添加回归测试
  - MIGRATE-003: 移除旧系统导入
    - 移除 dimension_models.dart 导入
    - 清理未使用的引用
    - 更新依赖关系
    - 编译验证

  代码清理

  - CLEANUP-001: 移除旧系统类
    - 删除 CardLayoutModel 类
    - 删除 MeasurementContext 类
    - 删除相关辅助类
    - 验证编译成功
  - CLEANUP-002: 清理重复代码
    - 识别并删除重复的计算逻辑
    - 合并相似的方法
    - 优化代码结构
    - 添加代码审查

  最终测试

  - TEST-003: 执行完整回归测试
    - 运行所有单元测试
    - 运行所有集成测试
    - 运行性能测试
    - 生成测试报告
  - TEST-004: 执行用户验收测试
    - 执行手动测试场景
    - 验证所有拖拽功能
    - 验证性能指标
    - 生成验收报告

  文档更新

  - DOC-001: 更新技术文档
    - 更新架构文档
    - 更新API文档
    - 更新使用示例
    - 文档审查
  - DOC-002: 更新用户文档
    - 更新功能说明
    - 更新操作指南
    - 更新故障排除
    - 用户文档审查

  持续集成任务

  每日检查

  - DAILY-001: 每日编译检查
    - 验证代码编译成功
    - 检查编译警告
    - 修复编译问题
    - 记录检查结果
  - DAILY-002: 每日测试检查
    - 运行单元测试套件
    - 检查测试通过率
    - 修复测试失败
    - 记录测试结果

  每周检查

  - WEEKLY-001: 每周进度检查
    - 检查任务完成情况
    - 更新项目进度
    - 调整下周计划
    - 生成进度报告
  - WEEKLY-002: 每周性能检查
    - 运行性能基准测试
    - 检查性能指标
    - 识别性能问题
    - 生成性能报告

  阶段里程碑

  - MILESTONE-001: 阶段一完成 (第2周末)
    - 所有基础设施任务完成
    - 单元测试通过率 > 90%
    - 架构设计文档完成
    - 里程碑验收
  - MILESTONE-002: 阶段二完成 (第4周末)
    - 所有核心操作任务完成
    - 集成测试通过率 > 85%
    - 基本拖拽功能可用
    - 里程碑验收
  - MILESTONE-003: 阶段三完成 (第6周末)
    - 所有拖拽支持任务完成
    - 性能测试达标
    - 完整拖拽体验可用
    - 里程碑验收
  - MILESTONE-004: 阶段四完成 (第8周末)
    - 所有系统切换任务完成
    - 旧系统完全移除
    - 所有测试通过
    - 项目交付

  风险缓解任务

  技术风险缓解

  - RISK-001: 功能回归风险缓解
    - 建立完整的自动化测试套件
    - 实施A/B测试对比
    - 准备快速回滚方案
    - 定期验证功能完整性
  - RISK-002: 性能回归风险缓解
    - 建立性能基线测试
    - 实施性能监控
    - 优化关键路径算法
    - 定期性能评估

  项目风险缓解

  - RISK-003: 时间风险缓解
    - 分阶段交付计划
    - 优先级排序策略
    - 预留缓冲时间
    - 定期进度评估
  - RISK-004: 资源风险缓解
    - 明确依赖关系
    - 考虑外部支持方案
    - 准备资源调整计划
    - 定期资源评估

  ---
  总结：这个迁移方案提供了从 MeasurementContext + CardLayoutModel 系统到 EnhancedCardMetricsCalculator + EnhancedCardMetricsSnapshot 系统的完整路径。通过分阶段实施、详细的技术实现、
  全面的风险缓解和原子化的任务列表，确保迁移过程可控、可测量、可回滚。最终目标是消除架构冗余，提升系统性能和可维护性，同时保持所有现有功能的完整性。
