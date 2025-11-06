# EditableFourZhuCardV3 使用与功能说明

- 创建时间：2025/11/05 12:40
- Git 分支：refactor/common/card-stage-6
- 文件位置：`common/lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart`
- 适用范围：八字排盘编辑卡片（四柱/扩展列）在单视图中完成行、列的拖拽重排与插入。

## 1. 组件总览

EditableFourZhuCardV3 是「单视图、双轴拖拽」的重构版卡片组件：
- 在同一个 Stack/Grid 视图中完成「列重排、行重排、插入新列/新行、删除列/行」等交互；
- 独立的上下抓手行（topGripRow/bottomGripRow）与左右抓手列（leftGripCol/rightGripCol），避免误拖拽标题；
- 统一的尺寸管理模型（CardLayoutModel + MeasurementContext），确保宽高计算一致、可预测；
- 内置“分隔列/分隔行”的窄宽/窄高策略，避免 UI 抖动；
- 支持外部拖拽载荷（PillarPayload/RowInfoPayload），可插入「扩展列/信息行」；
- 可自定义拖拽反馈与插入装饰；
- 可开启调试覆盖层（debugHysteresisOverlay）观测插入阈值与边界。

相关子模块与模型：
- 维度/尺寸模型：`common/lib/widgets/editable_fourzhu_card/dimension_models.dart`
  - MeasurementContext（全局尺寸上下文）
  - CardLayoutModel（卡片布局模型）
  - ColumnDimension / RowDimension（列/行尺寸对象）
- 幽灵占位 Widget：`common/lib/widgets/editable_fourzhu_card/widgets/ghost_pillar_widget.dart`
- 拖拽载荷模型：`common/lib/models/drag_payloads.dart`
  - PillarPayload（列）/ RowInfoPayload（行）
  - RowTitleColumnPayload（行标题列）/ ColumnHeaderRowPayload（表头行）
  - TitleColumnPayload / TitleRowPayload（标题拖拽特化载荷）

演示示例：`common/lib/pages/editable_four_zhu_card_demo_page.dart`

## 2. 快速开始

### 2.1 数据模型准备

- 列（柱）载荷 PillarPayload：描述一列的类型、标签、各行值、可选宽度等；
- 行载荷 RowInfoPayload：描述一行的类型、标签、各列值、可选高度等；
- 性别 Gender：表头/行标题左上角的性别标识（乾造/坤造）。

常见枚举：
- PillarType：year/month/day/hour/luckCycle/separator/rowTitleColumn 等；
- RowType：heavenlyStem/earthlyBranch/kongWang/naYin/columnHeaderRow 等。

### 2.2 构建 Notifier

- pillarsNotifier：ValueNotifier<List<PillarPayload>>（列数据源）
- rowListNotifier：ValueNotifier<List<RowInfoPayload>>（行数据源）
- paddingNotifier：ValueNotifier<EdgeInsets>（卡片内边距）

### 2.3 使用示例（最小可运行）

```dart
import 'package:flutter/material.dart';
import 'package:xuan/common/lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart';
import 'package:xuan/common/lib/models/drag_payloads.dart';
import 'package:xuan/common/lib/enums.dart';

class EditableCardDemo extends StatefulWidget {
  const EditableCardDemo({super.key});
  @override
  State<EditableCardDemo> createState() => _EditableCardDemoState();
}

class _EditableCardDemoState extends State<EditableCardDemo> {
  late final ValueNotifier<List<PillarPayload>> _pillarsPayloadNotifier;
  late final ValueNotifier<List<RowInfoPayload>> _rowsPayloadNotifier;
  late final ValueNotifier<EdgeInsets> _paddingNotifier;

  @override
  void initState() {
    super.initState();
    _pillarsPayloadNotifier = ValueNotifier<List<PillarPayload>>([
      // 行标题列（左上角单元格显示性别）
      RowTitleColumnPayload(width: 52),
      // 年、月、日、时四柱（可根据业务填充 perRowValues）
      PillarPayload(pillarType: PillarType.year, pillarLabel: '年'),
      PillarPayload(pillarType: PillarType.month, pillarLabel: '月'),
      PillarPayload(pillarType: PillarType.day, pillarLabel: '日'),
      PillarPayload(pillarType: PillarType.hour, pillarLabel: '时'),
      // 分隔列（窄宽，用于视觉区分）
      PillarPayload(pillarType: PillarType.separator, pillarLabel: '|'),
    ]);

    _rowsPayloadNotifier = ValueNotifier<List<RowInfoPayload>>([
      // 表头行（列标题 + 性别）
      ColumnHeaderRowPayload(gender: Gender.male, height: 24),
      // 天干、地支（高度统一按 MeasurementContext.ganZhiCellHeight）
      RowInfoPayload(rowType: RowType.heavenlyStem, rowLabel: '天干'),
      RowInfoPayload(rowType: RowType.earthlyBranch, rowLabel: '地支'),
      // 其他信息行（例如空亡/纳音等）
      RowInfoPayload.kongWang(label: '空亡'),
    ]);

    _paddingNotifier = ValueNotifier<EdgeInsets>(const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 8,
    ));
  }

  @override
  void dispose() {
    _pillarsPayloadNotifier.dispose();
    _rowsPayloadNotifier.dispose();
    _paddingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditableFourZhuCardV3(
      pillarsNotifier: _pillarsPayloadNotifier,
      rowListNotifier: _rowsPayloadNotifier,
      paddingNotifier: _paddingNotifier,
      gender: Gender.male,
      // 可选：自定义拖拽反馈或插入装饰
      dragFeedbackBuilder: (ctx, child) => Material(
        elevation: 3,
        color: Colors.transparent,
        child: child,
      ),
      columnInsertDecorationBuilder: (ctx, isHover) => BoxDecoration(
        color: isHover ? Colors.blue.withOpacity(0.08) : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: isHover ? Colors.blue : Colors.blueGrey,
            width: 1.5,
          ),
        ),
      ),
      rowInsertDecorationBuilder: (ctx, isHover) => BoxDecoration(
        color: isHover ? Colors.green.withOpacity(0.08) : Colors.transparent,
        border: Border(
          top: BorderSide(
            color: isHover ? Colors.green : Colors.greenAccent,
            width: 1.2,
          ),
        ),
      ),
      debugHysteresisOverlay: false,
    );
  }
}
```

## 3. 构造参数详解

- pillarsNotifier（必填）
  - 类型：ValueNotifier<List<PillarPayload>>
  - 作用：当前卡片的所有列（包含行标题列/分隔列）数据源；
  - Tips：在外部插入列或重排后，组件会更新此数据；你也可以主动 set。

- rowListNotifier（必填）
  - 类型：ValueNotifier<List<RowInfoPayload>>
  - 作用：当前卡片的所有行（包含表头行/天干/地支/信息行）数据源；
  - Tips：与 pillarsNotifier 同步参与布局模型构建与尺寸计算。

- paddingNotifier（必填）
  - 类型：ValueNotifier<EdgeInsets>
  - 作用：卡片的内边距；支持动态调整（布局模型会自动重新计算）。

- gender（必填）
  - 类型：Gender（枚举）
  - 作用：用于左上角性别标识（乾造/坤造），与 ColumnHeaderRowPayload 协同展示。

- dragFeedbackBuilder（可选）
  - 类型：Widget Function(BuildContext, Widget)
  - 作用：自定义拖拽反馈（Overlay 代理），用于 Draggable 的反馈组件包装；
  - 默认：null（使用系统默认样式）。

- columnInsertDecorationBuilder / rowInsertDecorationBuilder（可选）
  - 类型：Decoration Function(BuildContext, bool isHover)
  - 作用：当悬停（hover）时，绘制列/行插入指示装饰；
  - 默认：null（使用内置幽灵占位 GhostPillarWidget）。

- debugHysteresisOverlay（可选）
  - 类型：bool
  - 作用：显示拖拽插入边界的调试区域（阈值可视化）；
  - 默认：false。

## 4. 数据模型详解（drag_payloads.dart）

### 4.1 PillarPayload（列载荷）

字段：
- pillarType：列类型（year/month/day/hour/luckCycle/separator/rowTitleColumn 等）；
- pillarLabel：显示标签；
- perRowValues：各行的值覆盖（Map<RowType, String>）；
- columnWidth：显示宽度覆盖（用于外部拖拽时的幽灵列宽）；
- placeholderStyle：拖拽反馈的占位样式（可选）；
- textAlign：列文本对齐（可选）；
- orderIndex：UI 插入顺序提示（可选）；
- pillarContent：嵌入的核心数据（包含 id、干支等）。

方法：
- resolveWidth(defaultWidth, minWidth=40, maxWidth=160)：统一解析幽灵/实际列宽；
- copyWith(...)：生成变更后的副本；
- 工厂：`PillarPayload.luckCycle(...)` 快捷创建「大运」列载荷。

特殊：
- RowTitleColumnPayload：`pillarType = PillarType.rowTitleColumn`，用于“行标题列”；
- TitleColumnPayload：仅用于标题拖拽排序，非插入新列。

### 4.2 RowInfoPayload（行载荷）

字段：
- rowType：行类型（heavenlyStem/earthlyBranch/kongWang/naYin/columnHeaderRow 等）；
- rowLabel：显示标签；
- perPillarValues：各列值覆盖（Map<String pillarId, String>）；使用 pillarContent.id 作为 key；
- rowHeight：显示高度覆盖；
- textAlign：行文本对齐；
- strategy：计算策略（RowComputationStrategy），与输入组合生成值。

方法：
- valueFor(pillar, input)：优先使用覆盖值，否则按策略计算；
- computeValues(input)：策略填充 + 覆盖合并；
- resolveHeight(heavenlyAndEarthly=48, other=32, divider=8, header=24)：统一解析行高；
- copyWith(...)：生成变更后的副本；

特殊：
- ColumnHeaderRowPayload：`rowType = RowType.columnHeaderRow`，含性别与列标题；
- TitleRowPayload：仅用于标题拖拽排序，非插入新行；
- 快捷：`RowInfoPayload.kongWang(...)` 创建空亡信息行。

## 5. 尺寸管理体系（dimension_models.dart）

### 5.1 MeasurementContext（上下文）
- defaultPillarWidth：普通列默认宽；
- defaultOtherCellHeight：普通信息行高；
- ganZhiCellHeight：干支行高；
- columnTitleHeight：列标题行高；
- rowDividerHeightEffective / colDividerWidthEffective：分隔行/列有效尺寸（padding+thickness）；
- minPillarWidth / maxPillarWidth：列宽范围；
- rowTitleWidth：行标题列默认宽。

支持 `MeasurementContext.fromStateConfig(...)` 从 State 的实时配置生成上下文。

### 5.2 ColumnDimension / RowDimension
- ColumnDimension.measure(ctx)：优先覆盖 → 分隔列窄宽 → 行标题列宽 → payload 解析宽度；
- RowDimension.measure(ctx)：优先覆盖 → payload 解析高度（含表头行、干支、分隔行、其他行）。

### 5.3 CardLayoutModel（核心）
- computeSize(ctx)：自动计算卡片总宽高（包含左右抓手列与上下抓手行）；
- columnWidth(index, ctx) / rowHeight(index, ctx)：单列/单行尺寸；
- sumColumnWidthsUpTo(count, ctx) / sumRowHeightsUpTo(count, ctx)：前缀和；
- totalColumnsWidth(ctx) / totalRowsHeight(ctx)：总宽高；
- 列操作：insertColumn/removeColumn/reorderColumn/updateColumnWidth/clearColumnWidthOverride；
- 行操作：insertRow/removeRow/reorderRow/updateRowHeight/clearRowHeightOverride；
- withPadding(newPadding)：更新内边距；
- fromNotifiers(...)：从旧系统的 Notifier 构建新模型（迁移桥接）。

## 6. 交互与拖拽行为（editable_fourzhu_card_impl.dart）

> 关键 API：Flutter Draggable / DragTarget。组件实现了多层 DragTarget 覆盖与节流/防重入 Guard，确保插入索引计算稳定。

- 双轴拖拽：
  - 列：在卡片任意区域 hover 时计算插入索引（“全卡列插入 DragTarget”），支持拖入外部 PillarPayload；
  - 行：Stack 顶层覆盖统一 DragTarget（含 top/bottom grip 行），进行插入索引计算；
- 抓手专用：
  - 上下抓手行（dragHandleRowHeight=20）、左右抓手列（dragHandleColWidth=20）用于重排，不允许误拖拽标题；
- 分隔元素：
  - 分隔列识别：`pillarType == PillarType.separator` 或标题别名（“分隔符/列分隔符/|”），使用窄宽 `colDividerWidthEffective`；
  - 分隔行识别：行标签别名（“分割线/行分割线/行分割符/行分隔符”），使用窄高 `rowDividerHeightEffective`；
- 列宽调整：
  - 通过垂直分割线 Draggable 调整 `_resizingDividerIndex`，并更新 `CardLayoutModel.updateColumnWidth`；
- 删除行为：
  - 拖拽释放在卡片外且未被任何 DragTarget 接受时，删除该列/行（具体逻辑见备份文件与 demo 行为）；
- 幽灵占位与插入装饰：
  - 使用 `GhostPillarWidget.column(...)` / `.row(...)` 显示半透明占位；
  - 可通过 `columnInsertDecorationBuilder` 与 `rowInsertDecorationBuilder` 自定义装饰（边框/底色等）。
- 调试覆盖层：
  - `debugHysteresisOverlay=true` 时绘制插入边界与阈值辅助线（便于调试 hover 行为）。

## 7. UI 渲染细节与装饰参数

- 装饰尺寸（State 内部静态常量）：
  - margin=8、padding=16、borderWidth=2，组合得到 `_pillarDecorationWidth/_pillarDecorationHeight`；
  - `_pillarDecorationTopOffset/_BottomOffset` 定位装饰上下偏移；
- 行标题列（RowTitleColumnPayload）：
  - 宽度优先使用覆盖（columnWidth）或 MeasurementContext.rowTitleWidth；
  - 左上角单元格显示性别文本（乾造/坤造）；
- 表头行（ColumnHeaderRowPayload）：
  - 高度优先 rowHeight，否则使用 MeasurementContext.columnTitleHeight；
  - 每列显示各自的标题文本，左上角显示性别标识；
- 天干/地支行：
  - 高度统一使用 MeasurementContext.ganZhiCellHeight；
- 其他信息行（空亡/纳音等）：
  - 使用 MeasurementContext.defaultOtherCellHeight。

## 8. 常见问题与边界情况

- 为什么我的“分隔列/分隔行”尺寸不一致？
  - 请确认列 `pillarType == PillarType.separator` 或行标签属于别名集合；
  - 若从外部拖入，建议在载荷中显式设置 `columnWidth`/`rowHeight` 提示 UI。

- 多个“大运”列如何区分 perPillarValues？
  - 使用 `pillarContent.id` 唯一标识，例如 `luckCycle#1`、`luckCycle#2`；
  - 组件内部 `_allocatePillarId` 会根据同类计数生成 id。

- 为什么拖拽偶尔不触发插入？
  - 组件使用了防重入 Guard 与节流更新，确保不会重复 onAccept；
  - 建议开启 `debugHysteresisOverlay` 观察边界线并调整 hover 区域。

- 行/列标题能否参与重排？
  - V3 采用“独立抓手版”，标题本身不参与拖拽，重排通过上下/左右抓手进行，避免误操作。

## 9. 最佳实践

- 数据与 UI 分离：使用 Notifier 管理数据列表，组件只做呈现与交互；
- 尺寸统一：通过 MeasurementContext 保持行高/列宽的一致性，避免魔法数；
- 分隔元素规范：统一别名集合与窄尺寸，提升视觉稳定性；
- 扩展载荷：插入外部列/行时，尽量提供 `columnWidth/rowHeight` 与 `pillarContent.id`，便于 UI 即时渲染与后续计算；
- 自定义装饰：利用 `columnInsertDecorationBuilder/rowInsertDecorationBuilder` 增强可视化反馈；
- 调试定位：必要时打开 `debugHysteresisOverlay` 观察插入阈值。

## 10. 参考与关联文档

- 设计文档：`common/docs/feature/editable_eight_char/architecture_design.md`
- 重构实施计划：`common/docs/feature/editable_eight_char/implementation_plan.md`
- 说明文档：`common/docs/说明文档.md`
- Demo 示例：`common/lib/pages/editable_four_zhu_card_demo_page.dart`

## 11. 进阶：外部拖拽源示例

- 外部列拖拽源（演示）：`TestPillarDraggable`/`TestPillarInfoDraggable`
- 外部行拖拽源（演示）：`TestRowInfoDraggable`/`TestDividerRowDraggable`

示例（简化）：

```dart
// 外部生成一个大运列载荷并开始拖拽
final payload = PillarPayload.luckCycle(
  label: '大运',
  columnWidth: 80,
  pillarContent: PillarContent(id: 'luckCycle#1'), // 伪代码：实际请按项目模型创建
);
// 拖拽到卡片上后，EditableFourZhuCardV3 会在 hover 插入索引处插入该列
```

## 12. 版本与兼容

- V3 与旧版 V2 的区别：
  - 视图结构：V3 单视图双轴；V2 多列表分离；
  - 交互：V3 独立抓手；V2 标题参与拖拽；
  - 尺寸：V3 统一模型（CardLayoutModel）；V2 过程式计算。

- 迁移建议：
  - 使用 `CardLayoutModel.fromNotifiers(...)` 从原有 Notifier 快速构建布局模型；
  - 按需替换分隔元素的识别与宽高策略。

---

如需进一步集成或扩展，请参考上述源码路径与模型说明，结合实际业务数据模型（PillarContent/RowComputationStrategy 等）进行增强。