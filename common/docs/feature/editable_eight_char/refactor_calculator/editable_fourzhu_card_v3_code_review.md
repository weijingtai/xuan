# EditableFourZhuCardV3 代码审查与功能说明

- 组件位置：`common/lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart`
- 组件职责：在一个统一的网格视图中完成四柱卡片的渲染与交互（列/行重排、外部拖拽插入、列宽调整、插入位指示、删除意图提示等），并与主题、度量、数据载荷保持一致的双向联动。

## 总览
- 单视图双轴拖拽：统一使用一个 `Stack + Column + Row` 组合完成列与行的拖拽，让位与插入，避免两个 `ReorderableListView` 带来的复杂性和重绘成本。
- 三大通知器联动：`themeNotifier` 提供样式，`cardPayloadNotifier` 提供行列载荷，`paddingNotifier` 提供卡片内边距。所有尺寸计算与渲染都通过这些通知器的值一致驱动。
- 尺寸度量集中化：由 `CardMetricsCalculator` 统一计算列宽、行高与单元格尺寸，避免手工推断错误；通过 `MetricsComputeOptions` 控制是否显示抓手、标题行/列等开关对最终尺寸的影响。
- 交互节流与批处理：使用 `EditableCardDragController` 对 `onMove` 事件做轻节流（默认 12ms），并通过 `_scheduleRebuild` 合并多处状态更新，显著降低重建次数与抖动。

## 外部 API
- 构造函数参数（重点）：
  - `dayGanZhi`：日柱甲子，用于行策略计算（如十神等）
  - `themeNotifier`：卡片主题，含 `card/pillar/cell/typography`（`common/models/text_style_config.dart` 等）
  - `cardPayloadNotifier`：行列载荷（`PillarPayload`、`TextRowPayload` 的映射与顺序）
  - `paddingNotifier`：卡片级 padding 变更触发尺寸重算与重绘
  - `brightnessNotifier`、`colorPreviewModeNotifier`：明暗与颜色预览模式，驱动文字与阴影颜色
  - `gender`：性别，表头行用于显示“乾造/坤造”
  - 可选：`dragFeedbackBuilder`、`row/columnInsertDecorationBuilder`、`onRowsReordered`、`debugHysteresisOverlay`、`showGrip`
- 构造处参考：`common/lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart:94`

## 初始化与生命周期
- `initState`（构建度量上下文、布局模型、尺寸通知器、拖拽控制器）：`editable_fourzhu_card_impl.dart:825`
  - 初始化 `ValueNotifier`：`_pillarSectionNotifier/_cellSectionNotifier/_typographySectionNotifier`，其变化会触发 `_computeSizeWithDecorationsV2` 重新度量
  - 构建基础布局度量模型 `_basicLayoutModel` 并监听其 `version`，在改变分割线/抓手有效尺寸时联动 `_measurementContext` 与整体尺寸
  - 通过 `_layoutModelSyncListener` 将 `cardPayloadNotifier/paddingNotifier` 的变化同步到 `CardLayoutModel` 与尺寸、以及 `_metricsSnapshotNotifier`
  - 初始化拖拽节流控制器 `_dragController`，统一列/行节流逻辑
- `didUpdateWidget`（属性变化时同步抓手开关与尺寸）：`editable_fourzhu_card_impl.dart:941`
- `dispose`（移除监听与释放通知器）：`editable_fourzhu_card_impl.dart:995`

## 度量与尺寸
- `CardMetricsCalculator` 快照与映射：
  - `_computeMetricsSnapshot`：生成 `CardMetricsSnapshot`（列/行/单元格度量字典）：`editable_fourzhu_card_impl.dart:397`
  - `_buildCellTextSpecMap`：构造每个单元格的文字规格（字符数、字体大小）：`editable_fourzhu_card_impl.dart:415`
  - `_computeSizeWithDecorationsV2`：根据 `MetricsComputeOptions` 计算最终卡片宽高（含抓手、标题、装饰、边框）：`editable_fourzhu_card_impl.dart:4903`
  - 卡片边框占用解析：`_cardBorderHorizontalEff/_cardBorderVerticalEff` 与 `_resolveUniformCardBorderWidth`：`editable_fourzhu_card_impl.dart:362`、`editable_fourzhu_card_impl.dart:372`、`editable_fourzhu_card_impl.dart:382`
- 装饰尺寸派生与像素对齐：
  - 每列装饰宽/高：`_pillarDecorationWidthAtIndex/_pillarDecorationHeightAtIndex`：`editable_fourzhu_card_impl.dart:328`、`editable_fourzhu_card_impl.dart:336`
  - 顶/底部装饰偏移（用于抓手列对齐）：`_pillarDecorationTopOffsetEff/_pillarDecorationBottomOffsetEff`：`editable_fourzhu_card_impl.dart:352`、`editable_fourzhu_card_impl.dart:356`
  - `_pixelFloor`：将逻辑尺寸对齐到物理像素，消除子像素溢出：`editable_fourzhu_card_impl.dart:462`

## 数据载荷与映射
- 当前行/列获取与设置：
  - `_currentTextRows/_currentPillars/_setTextRows/_setPillars`：`editable_fourzhu_card_impl.dart:589`、`editable_fourzhu_card_impl.dart:584`、`editable_fourzhu_card_impl.dart:597`、`editable_fourzhu_card_impl.dart:605`
- 载荷到显示映射：
  - `_pillarLabelFromPayload/_pillarJiaZiFromPayload`：支持 `ContentPillarPayload` 与其他类型：`editable_fourzhu_card_impl.dart:537`、`editable_fourzhu_card_impl.dart:544`
  - 行标签列表：`_currentRowLabels`：`editable_fourzhu_card_impl.dart:579`

## 拖拽与插入逻辑
- 批处理与采样：
  - `_scheduleRebuild`：合并多处状态变更为一次 `setState`，降低重建：`editable_fourzhu_card_impl.dart:174`
  - `takeAndResetRebuildSampling/takeAndResetDragMoveCounts/takeAndResetNotifierSampling`：采样重建次数、`onMove` 次数、插入/删除提示更新次数：`editable_fourzhu_card_impl.dart:191`、`editable_fourzhu_card_impl.dart:201`、`editable_fourzhu_card_impl.dart:210`
- 插入位计算与滞回：
  - 列插入位（可变列宽中点规则）：`_dragController.computeInsertIndexByMidpoints` + `spans`：使用 `_colWidthAtIndex` 聚合：`editable_fourzhu_card_impl.dart:1209`
  - 行插入位（中点规则与滞回缓冲）：`_dragController.computeInsertIndexByMidpoints` + `_rowSpansCache`：`editable_fourzhu_card_impl.dart:1631`
  - 滞回开关判断：`allowColumnHysteresisSwitch/allowRowHysteresisSwitch` 统一控制边界切换：`editable_fourzhu_card_impl.dart:1234`、`editable_fourzhu_card_impl.dart:1665`
- 统一拖拽节流：
  - `allowColumnMove/allowRowMove` 检查，减少 `onMove` 高频重绘：`editable_fourzhu_card_impl.dart:1154`、`editable_fourzhu_card_impl.dart:1594`
- 插入/删除意图提示：
  - `_dragWantsInsert/_dragWantsDelete` 两个 `ValueNotifier<bool>` 驱动拖拽物左上角徽标显示（插入/删除优先）：`editable_fourzhu_card_impl.dart:719`、`editable_fourzhu_card_impl.dart:3913`
- 外部载荷悬停带来的“幽灵列/行”尺寸：
  - 列幽灵宽度 `_externalColHoverWidth` 与 `resolveGhostColumnWidth`：`editable_fourzhu_card_impl.dart:1147`、`editable_fourzhu_card_impl.dart:1437`
  - 行幽灵高度 `_externalRowHoverHeight` 与 `resolveGhostRowHeight`：`editable_fourzhu_card_impl.dart:1059`、`editable_fourzhu_card_impl.dart:1583`
- 插入/重排操作：
  - 列：`_reorderColumns/_reorderColumnsByType/_insertExternalPillar/_insertExternalPillarFromType`：`editable_fourzhu_card_impl.dart:3987`、`editable_fourzhu_card_impl.dart:4028`、`editable_fourzhu_card_impl.dart:4065`、`editable_fourzhu_card_impl.dart:4134`
  - 行：`_reorderRows/_reorderRowsByTitlePayload/_insertExternalRow`：`editable_fourzhu_card_impl.dart:4215`、`editable_fourzhu_card_impl.dart:4269`、`editable_fourzhu_card_impl.dart:3692`
  - 删除：`_deleteColumn/_deleteRow`：`editable_fourzhu_card_impl.dart:3661`、`editable_fourzhu_card_impl.dart:3669`
  - 覆盖重映射：列宽 `_remapColumnOverridesOnMove`，行高 `_remapRowOverridesOnMove` 保持覆盖键与新索引同步：`editable_fourzhu_card_impl.dart:4036`、`editable_fourzhu_card_impl.dart:4285`

## 渲染结构
- `build` 根渲染：
  - 外层 `AnimatedContainer` 按卡片装饰、padding、边框宽度计算真实容器尺寸，并在外部载荷悬停时增加 `extraColWidth/extraRowHeight`：`editable_fourzhu_card_impl.dart:1076`
  - 全卡 `DragTarget` 负责列插入计算与幽灵列宽设置；离开时清理状态并根据删除意图显示红色边框：`editable_fourzhu_card_impl.dart:1114`
  - 插入指示线：根据累计列宽定位细线（支持不等宽列）：`editable_fourzhu_card_impl.dart:1339`
  - Debug 行边界覆盖层：在 `debugHysteresisOverlay` 为真时绘制每行中点与滞回范围：`editable_fourzhu_card_impl.dart:1370`
- 网格与抓手：
  - `_buildGrid` 包含顶部抓手行、数据网格、左右抓手列、底部抓手行，以及全区域行 `DragTarget`：`editable_fourzhu_card_impl.dart:1418`
  - 顶/底部抓手行：`_buildTopGripRow/_buildBottomGripRow`，支持在分隔列仅显示抓手图标；拖拽开始/结束/取消统一处理状态清理与删除：`editable_fourzhu_card_impl.dart:2420`、`editable_fourzhu_card_impl.dart:2572`
  - 左/右抓手列：`_buildLeftGripColumn/_buildRightGripColumn`，覆盖幽灵占位、独立 `Draggable`、外层行 `DragTarget` 与插入指示线位置对齐：`editable_fourzhu_card_impl.dart:2717`、`editable_fourzhu_card_impl.dart:2861`
  - 列宽调整：`_buildResizeHandles/_buildSingleResizeHandle`，根据 `onPanUpdate` 动态计算新内容宽度（扣除装饰），范围夹在 `_min/_max` 并写入 `_columnWidthOverrides`：`editable_fourzhu_card_impl.dart:2341`、`editable_fourzhu_card_impl.dart:2355`
- 数据网格：
  - `_buildDataGrid` 用 `Stack` 叠加：数据列、行插入覆盖层、垂直分割线拖拽手柄：`editable_fourzhu_card_impl.dart:1763`
  - `_buildPillarsRow/_buildPillarWidgets`：按拖拽状态插入幽灵列、真实列并在末尾追加幽灵列：`editable_fourzhu_card_impl.dart:1843`、`editable_fourzhu_card_impl.dart:1854`
  - `_buildRealPillar/_buildPillarCells/_buildSingleCell`：按列类型渲染行标题、分隔列或数据单元格；使用 `multiLineCell` 统一文字渲染与装饰：`editable_fourzhu_card_impl.dart:1926`、`editable_fourzhu_card_impl.dart:2003`、`editable_fourzhu_card_impl.dart:2085`
  - 单元格内容：天干/地支分别由 `_tianGanText/_diZhiText` 构建，并通过 `_resolveGanZhiTextStyle` 从主题映射颜色与阴影：`editable_fourzhu_card_impl.dart:5217`、`editable_fourzhu_card_impl.dart:5265`、`editable_fourzhu_card_impl.dart:5227`

## 视觉反馈与复用
- 拖拽物状态徽标：`_statusFeedback` 在拖拽物左上角显示“插入/删除”徽标，删除优先：`editable_fourzhu_card_impl.dart:3913`
- 复用已渲染柱作为拖拽反馈：`_buildReusedPillarFeedback` 通过 `GlobalKey` 引用现有 Widget，避免重复构建并保持风格一致：`editable_fourzhu_card_impl.dart:4569`

## 重要辅助方法
- 分隔行/列识别：`_isSeparatorRowAtIndex/_isSeparatorColumnIndex` 完全基于载荷类型，不再依赖中文标题字符串：`editable_fourzhu_card_impl.dart:512`、`editable_fourzhu_card_impl.dart:476`
- 插入位顶部/目标行定位：`_computeRowInsertTopFromIndex/_computeRowTopFromIndex`，考虑表头行存在与索引夹值：`editable_fourzhu_card_impl.dart:3581`、`editable_fourzhu_card_impl.dart:3621`
- 中点坐标计算（滞回辅助）：`_rowBoundaryMidY/_columnBoundaryMidX`：`editable_fourzhu_card_impl.dart:4761`、`editable_fourzhu_card_impl.dart:4823`

## 已废弃/待移除
- 旧布局系统（V4 将移除）：`_layoutNotifier/_measurementContext/_computeSizeWithDecorations` 标注为 `@Deprecated`，建议统一迁移到 `CardMetricsCalculator`：`editable_fourzhu_card_impl.dart:527`、`editable_fourzhu_card_impl.dart:530`、`editable_fourzhu_card_impl.dart:4942`
- 旧反馈构建：`_buildFullColumnFeedback/_buildFullRowFeedback/_buildLeftHeader` 已标注废弃或不复用，建议删除或迁移至 demo-only：`editable_fourzhu_card_impl.dart:4463`、`editable_fourzhu_card_impl.dart:5019`、`editable_fourzhu_card_impl.dart:3026`

## 代码审查

### Critical（必须修复）
- 旧度量/布局混用带来的维护成本与潜在不一致：
  - 当前同时存在 `CardMetricsCalculator` 与旧版 `CardLayoutModel/MeasurementContext` 两套系统，且部分逻辑仍依赖旧模型计算或监听（例如 `_onBasicLayoutChanged`），易引入差异。建议尽快删除旧系统，统一走新度量（保留必要的兼容适配层）。
  - 参考位置：`editable_fourzhu_card_impl.dart:4973`、`editable_fourzhu_card_impl.dart:4942`
- 列/行反馈构建中的废弃分支仍在代码路径中出现，增加复杂度与认知负担：
  - `_buildFullColumnFeedback` 与 `_buildFullRowFeedback` 已标注废弃，但仍有回退调用点；应统一走 `_buildReusedPillarFeedback` 或最简反馈构造，删除过时分支。
  - 参考位置：`editable_fourzhu_card_impl.dart:2520`、`editable_fourzhu_card_impl.dart:2670`、`editable_fourzhu_card_impl.dart:4463`、`editable_fourzhu_card_impl.dart:5019`
- `print/debugPrint` 出现在交互路径可能影响性能：
  - 如 `RowDragTarget onMove/onAccept`、`reorderRowsForTest` 的输出；建议限定在 `assert` 或 `kDebugMode` 下。
  - 参考位置：`editable_fourzhu_card_impl.dart:1582`、`editable_fourzhu_card_impl.dart:1709`、`editable_fourzhu_card_impl.dart:245`

### Warnings（应当修复）
- `GlobalKey` 复用与渲染边界依赖可能在首帧或未布局时失败：
  - `_buildReusedPillarFeedback` 已做 `hasSize` 判定，但在复杂重绘场景仍可能命中回退；建议为回退路径统一样式，避免与实时柱风格产生差异。
  - 参考位置：`editable_fourzhu_card_impl.dart:4569`
- 行标题与行内 padding 计算口径不完全统一：
  - `_rowHeightByName/_rowHeightByPayload` 与 `_getRowPadding*` 的使用有时在反馈与真实渲染中不一致；建议以 `metricsSnap.rows[*]` 为唯一来源，减少分支。
  - 参考位置：`editable_fourzhu_card_impl.dart:4315`、`editable_fourzhu_card_impl.dart:754`
- 删除行为缺少确认/撤销机制：
  - 当前在拖拽取消且光标位于卡片外部时直接删除列/行；建议增加轻提示或撤销窗口，以防误操作。
  - 参考位置：`editable_fourzhu_card_impl.dart:2500`、`editable_fourzhu_card_impl.dart:2648`、`editable_fourzhu_card_impl.dart:2785`
- 列宽覆盖与度量快照的并发一致性：
  - 在 `onPanUpdate` 写入 `_columnWidthOverrides` 后，度量快照更新依赖批处理调度；若外层也触发度量重算可能造成短暂不同步。建议在写入时直接触发 `_metricsSnapshotNotifier.value = _computeMetricsSnapshot()` 或在批处理末尾统一刷新。
  - 参考位置：`editable_fourzhu_card_impl.dart:2395`

### Suggestions（可考虑优化）
- 将抓手显示/隐藏的居中对齐策略封装为状态机：
  - 当前通过 `_preferCenterAlignment` 在一些场景切换，建议封装为 `enum CardAlignmentMode { centeredDuringGripToggle, topStart }` 并统一入口。
- 把 “幽灵列/行” 的尺寸解析抽象为策略对象：
  - 目前由 `_dragController` 与本地状态共同驱动，建议将“外部载荷 → 幽灵尺寸”规则抽象为 `HoverGhostSizeStrategy`，便于测试与替换。
- 将 `_buildPillarCells/_buildSingleCell` 的分支进一步归一化：
  - 避免在多个位置同时判断 `isRowTitleCol/isSeparatorColumn`，可先用 `CellKind` 归类，再统一调用渲染器。
- 对文本色与阴影色的映射增加缓存层：
  - `_resolveGanZhiTextStyle` 每次渲染都查映射，建议在 `themeNotifier` 或 `typography` 层构建 `Map<String, TextStyle>` 缓存，按 `char, mode, brightness` 三元键缓存。
- 增加交互测试与极端用例：
  - 如“表头行插入”、“行标题列存在时的列插入指示线定位”、“分隔列列宽调整”、“外部载荷插入后立即删除”等，构建黄金测试快照或集成测试。

## 主要函数索引（按模块分组）
- 生命周期与批处理
  - `_scheduleRebuild`：`editable_fourzhu_card_impl.dart:174`
  - `initState/didUpdateWidget/dispose`：`editable_fourzhu_card_impl.dart:825`、`editable_fourzhu_card_impl.dart:941`、`editable_fourzhu_card_impl.dart:995`
- 度量与尺寸
  - `_computeMetricsSnapshot/_buildCellTextSpecMap`：`editable_fourzhu_card_impl.dart:397`、`editable_fourzhu_card_impl.dart:415`
  - `_computeSizeWithDecorationsV2`：`editable_fourzhu_card_impl.dart:4903`
- 拖拽与插入
  - `_reorderColumns/_reorderRows`：`editable_fourzhu_card_impl.dart:3987`、`editable_fourzhu_card_impl.dart:4215`
  - `_insertExternalPillar/_insertExternalRow`：`editable_fourzhu_card_impl.dart:4065`、`editable_fourzhu_card_impl.dart:3692`
  - `_buildTopGripRow/_buildLeftGripColumn/_buildRightGripColumn/_buildBottomGripRow`：`editable_fourzhu_card_impl.dart:2420`、`editable_fourzhu_card_impl.dart:2717`、`editable_fourzhu_card_impl.dart:2861`、`editable_fourzhu_card_impl.dart:2572`
- 渲染与内容
  - `_buildDataGrid/_buildPillarsRow/_buildPillarWidgets/_buildRealPillar`：`editable_fourzhu_card_impl.dart:1763`、`editable_fourzhu_card_impl.dart:1843`、`editable_fourzhu_card_impl.dart:1854`、`editable_fourzhu_card_impl.dart:1926`
  - `_buildPillarCells/_buildSingleCell/multiLineCell`：`editable_fourzhu_card_impl.dart:2003`、`editable_fourzhu_card_impl.dart:2085`、`editable_fourzhu_card_impl.dart:3344`
  - `_tianGanText/_diZhiText/_resolveGanZhiTextStyle`：`editable_fourzhu_card_impl.dart:5217`、`editable_fourzhu_card_impl.dart:5265`、`editable_fourzhu_card_impl.dart:5227`

## 验收建议
- 移除所有 `@Deprecated` 路径并统一到 `CardMetricsCalculator`
- 为列/行插入、删除、宽度调整、滞回阈值添加单元测试与交互测试
- 在 `debugHysteresisOverlay` 开启时检查行/列边界绘制是否与快照度量一致
- 对“行标题列存在/不存在”两种模式分别验证插入指示线的定位正确性

---

以上审查与说明针对 `common` 包中的 `EditableFourZhuCardV3`，文档路径为 `common/docs/feature/editable_eight_char/refactor_calculator`，用于后续重构与度量计算一体化优化的参照。
