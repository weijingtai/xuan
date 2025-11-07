import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../enums/enum_gender.dart';
import '../enums/layout_template_enums.dart';
import '../models/eight_chars.dart';
import '../enums/enum_jia_zi.dart';
import '../models/layout_template.dart';
import '../widgets/EditableFourZhuCardV2.dart';
import '../widgets/editable_four_zhu_card.dart';
import '../widgets/editable_fourzhu_card.dart';
import '../widgets/test_pillar_draggable.dart';
import '../widgets/test_pillar_info_draggable.dart';
import '../widgets/test_row_info_draggable.dart';
import '../widgets/test_divider_row_draggable.dart';
import '../widgets/column_reorderable_four_zhu_card.dart';
import '../widgets/row_reorderable_four_zhu_card.dart';
import '../viewmodels/four_zhu_layout_controller.dart';
import '../models/drag_payloads.dart';
import '../models/pillar_content.dart';
import '../models/row_strategy.dart';
import '../themes/editable_four_zhu_card_theme.dart';
import '../viewmodels/editable_four_zhu_theme_controller.dart';
import '../widgets/style_editor/editable_four_zhu_style_editor_panel.dart';
import '../widgets/style_editor/colorful_text_style_editor_widget.dart';
import '../widgets/editable_fourzhu_card/text_groups.dart';

class EditableFourZhuCardDemoPage extends StatefulWidget {
  const EditableFourZhuCardDemoPage({super.key});

  @override
  State<EditableFourZhuCardDemoPage> createState() =>
      _EditableFourZhuCardDemoPageState();
}

enum CardMode {
  normal,
  column,
  row,
}

class _EditableFourZhuCardDemoPageState
    extends State<EditableFourZhuCardDemoPage> {
  final ValueNotifier<CardMode> _cardModeNotifier =
      ValueNotifier<CardMode>(CardMode.normal);
  bool _isEditable = false;
  // 是否启用“独立映射渲染”（禁用全局字体，按分组/行配置渲染）
  bool _useIndependentMapping = true;
  // V3 卡片级彩色模式开关（使用按字调色盘，支持深/浅色）
  bool _v3ColorfulMode = false;
  double? _desiredColumnCardWidth;

  late EightChars _sample;
  late FourZhuLayoutController _controller;
  late CardStyle _cardStyle;
  late EditableFourZhuCardTheme _theme;
  EditableFourZhuThemeController? _themeController;

  ValueNotifier<EdgeInsets> _paddingNotifier = ValueNotifier<EdgeInsets>(
    EdgeInsets.zero,
  );

  // 列拖拽卡片状态
  late List<PillarType> _columnPillars;
  late List<RowConfig> _columnRows;

  // 行拖拽卡片状态
  late List<PillarType> _rowPillars;
  late List<RowConfig> _rowRows;

  final ValueNotifier<List<Tuple2<String, JiaZi>>> _jiaZiNotifier =
      ValueNotifier<List<Tuple2<String, JiaZi>>>([
    Tuple2("年", JiaZi.JIA_ZI),
    Tuple2("月", JiaZi.YI_CHOU),
    Tuple2("日", JiaZi.BING_YIN),
    Tuple2("时", JiaZi.DING_MAO),
  ]);
  final ValueNotifier<List<String>> _rowListNotifier =
      ValueNotifier<List<String>>([
    '乾造',
    '天干',
    '地支',
    '纳音',
  ]);

  // 新版 V3 载荷：柱与行都承载语义与数据
  late final ValueNotifier<List<PillarPayload>> _pillarsPayloadNotifier;
  late final ValueNotifier<List<RowInfoPayload>> _rowsPayloadNotifier;
  // Per-group typography overrides for V3 preview
  Map<TextGroup, TextStyle> _groupTextStyles = {};
  // Per-character pure color overrides for V3 (applied when colorfulMode=false)
  Map<String, Color> _perCharColors = {};

  @override
  void initState() {
    super.initState();
    _sample = EightChars(
      year: JiaZi.JIA_ZI,
      month: JiaZi.YI_CHOU,
      day: JiaZi.BING_YIN,
      time: JiaZi.DING_MAO,
    );
    // Initialize shared controller with default pillars/rows
    _controller = FourZhuLayoutController(
      pillars: const [
        PillarType.year,
        PillarType.month,
        PillarType.day,
        PillarType.hour,
      ],
      rows: const [
        RowConfig(
            type: RowType.heavenlyStem, isVisible: true, isTitleVisible: true),
        RowConfig(
            type: RowType.earthlyBranch, isVisible: true, isTitleVisible: true),
        RowConfig(type: RowType.naYin, isVisible: true, isTitleVisible: true),
      ],
    );
    // Rebuild page when pillars or rows update
    _controller.pillars.addListener(() => setState(() {}));
    _controller.rows.addListener(() => setState(() {}));
    // Also listen for shared overrides/labels changes
    _controller.columnOverrides.addListener(() => setState(() {}));
    _controller.pillarLabelOverrides.addListener(() => setState(() {}));
    _controller.rowOverrides.addListener(() => setState(() {}));
    _controller.rowLabelOverrides.addListener(() => setState(() {}));

    _cardStyle = const CardStyle(
      dividerType: BorderType.solid,
      dividerColorHex: '#FF334155',
      dividerThickness: 1,
      globalFontFamily: 'NotoSansSC-Regular',
      globalFontSize: 16,
      globalFontColorHex: '#FF0F172A',
    );
    // 初始化主题（用于样式编辑与预览）
    _theme = const EditableFourZhuCardTheme(
      card: CardSection(
        cornerRadius: 8,
        padding: EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 12),
      ),
      pillar: PillarSection(
        defaultMargin: EdgeInsets.only(left: 6, top: 6, right: 6, bottom: 6),
        borderWidth: 0,
      ),
      typography: TypographySection(
        globalFontFamily: 'NotoSansSC-Regular',
        globalFontSize: 16,
        preferredFamilies: ['NotoSansSC-Regular', 'PingFang SC', 'Roboto'],
      ),
    );
    _themeController = EditableFourZhuThemeController(_theme);

    // 初始化 V3 载荷型 Notifier
    _pillarsPayloadNotifier = ValueNotifier<List<PillarPayload>>([
      // 第一列：行标题列（特殊柱）
      RowTitleColumnPayload(width: 52),
      // 数据柱：年月日时
      PillarPayload(
        pillarType: PillarType.year,
        pillarContent: PillarContent(
          id: 'pillar-year',
          pillarType: PillarType.year,
          label: '年',
          jiaZi: _sample.year,
          description: '示例年柱',
          version: '1',
          sourceKind: PillarSourceKind.userInput,
        ),
      ),
      PillarPayload(
        pillarType: PillarType.month,
        pillarContent: PillarContent(
          id: 'pillar-month',
          pillarType: PillarType.month,
          label: '月',
          jiaZi: _sample.month,
          description: '示例月柱',
          version: '1',
          sourceKind: PillarSourceKind.userInput,
        ),
      ),
      PillarPayload(
        pillarType: PillarType.day,
        pillarContent: PillarContent(
          id: 'pillar-day',
          pillarType: PillarType.day,
          label: '日',
          jiaZi: _sample.day,
          description: '示例日柱',
          version: '1',
          sourceKind: PillarSourceKind.userInput,
        ),
      ),
      PillarPayload(
        pillarType: PillarType.hour,
        pillarContent: PillarContent(
          id: 'pillar-hour',
          pillarType: PillarType.hour,
          label: '时',
          jiaZi: _sample.time,
          description: '示例时柱',
          version: '1',
          sourceKind: PillarSourceKind.userInput,
        ),
      ),
    ]);

    _rowsPayloadNotifier = ValueNotifier<List<RowInfoPayload>>([
      // 第一行：表头行（特殊行，包含性别标识和列标题）
      ColumnHeaderRowPayload(gender: Gender.male, height: 24),
      // 数据行
      RowInfoPayload(
          rowType: RowType.heavenlyStem, rowLabel: '天干', rowHeight: 48),
      RowInfoPayload(
          rowType: RowType.earthlyBranch, rowLabel: '地支', rowHeight: 48),
      // 纳音行：加入策略以便与 V3 的策略渲染路径对齐
      RowInfoPayload(
          rowType: RowType.naYin,
          rowLabel: '纳音',
          strategy: NaYinRowStrategy(),
          rowHeight: 32),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editable Four Zhu Card Demo'),
        actions: [
          IconButton(
            icon: Icon(_isEditable ? Icons.done : Icons.edit_outlined),
            tooltip: _isEditable ? '完成' : '编辑',
            onPressed: () => setState(() => _isEditable = !_isEditable),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 主题编辑与预览
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '主题编辑与预览',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isNarrow = constraints.maxWidth < 720;
                            final editor = SizedBox(
                              width: isNarrow ? constraints.maxWidth : 420,
                              child: EditableFourZhuStyleEditorPanel(
                                theme: _theme,
                                onChanged: (next) {
                                  setState(() {
                                    _theme = next;
                                    _themeController =
                                        EditableFourZhuThemeController(next);
                                    // Apply card padding directly to V3 card
                                    final resolvedPadding = _themeController
                                            ?.resolveCardPadding() ??
                                        const EdgeInsets.all(12);
                                    _paddingNotifier.value = resolvedPadding;

                                    // Bind per-pillar margin to payloads so sliders only affect that pillar
                                    final current =
                                        _pillarsPayloadNotifier.value;
                                    final mapped = current
                                        .map((p) => p.copyWith(
                                              columnMargin: _themeController
                                                  ?.resolvePillarMargin(
                                                      p.pillarType),
                                            ))
                                        .toList();
                                    _pillarsPayloadNotifier.value = mapped;
                                  });
                                },
                              ),
                            );
                            final preview = _ThemePreview(
                              controller: _themeController,
                            );
                            return isNarrow
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      editor,
                                      const SizedBox(height: 12),
                                      preview,
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      editor,
                                      const SizedBox(width: 16),
                                      Expanded(child: preview),
                                    ],
                                  );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TestPillarDraggable(type: PillarType.year),
                    TestPillarDraggable(type: PillarType.month),
                    TestPillarDraggable(type: PillarType.day),
                    TestPillarDraggable(type: PillarType.hour),
                    TestPillarDraggable(type: PillarType.separator),
                  ],
                ),
                const SizedBox(height: 16),
                // 外部“柱信息”拖拽源（仅用于列卡的插入演示）
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    TestPillarInfoDraggable(),
                  ],
                ),
                const SizedBox(height: 16),
                // 外部“行信息”拖拽源（仅用于行卡的插入演示）
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    TestRowInfoDraggable(),
                    TestDividerRowDraggable(),
                  ],
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // 分组字体编辑面板：允许天干/地支/纳音/空亡/柱标题/行标题分别调整
                    SizedBox(
                      width: 720,
                      child: GroupTextStyleEditorPanel(
                        initial: _groupTextStyles,
                        onChanged: (m) {
                          setState(() {
                            _groupTextStyles = Map<TextGroup, TextStyle>.of(m);
                          });
                        },
                      ),
                    ),
                    // 切换是否使用“独立映射渲染”模式
                    SizedBox(
                      width: 720,
                      child: SwitchListTile(
                        title: const Text('使用独立映射渲染'),
                        subtitle: const Text('禁用全局字体，仅按分组/行样式渲染'),
                        value: _useIndependentMapping,
                        onChanged: (v) =>
                            setState(() => _useIndependentMapping = v),
                      ),
                    ),
                    SizedBox(
                      width: 720,
                      child: SwitchListTile(
                        title: const Text('V3 彩色默认模式（卡片级开关）'),
                        subtitle: const Text('天干/地支按字上色；支持明/暗两套调色盘'),
                        value: _v3ColorfulMode,
                        onChanged: (v) => setState(() => _v3ColorfulMode = v),
                      ),
                    ),
                    // 仅展示 V3（独立抓手版），避免与旧版 V2 标题拖拽混淆
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'V3（独立抓手版）：首行/首列仅通过抓手排序，标题不可拖拽',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    // 单视图双轴拖拽的 V3 版本
                    EditableFourZhuCardV3(
                      pillarsNotifier: _pillarsPayloadNotifier,
                      rowListNotifier: _rowsPayloadNotifier,
                      paddingNotifier: _paddingNotifier,
                      gender: Gender.male,
                      colorfulMode: _v3ColorfulMode,
                      perCharColors: _perCharColors,
                      // Bind global typography to V3
                      globalFontFamily: _useIndependentMapping
                          ? null
                          : _themeController
                              ?.theme.typography?.globalFontFamily,
                      globalFontSize: _useIndependentMapping
                          ? null
                          : _themeController?.theme.typography?.globalFontSize,
                      globalFontColor: _useIndependentMapping
                          ? null
                          : _themeController?.theme.typography?.globalFontColor,
                      // Bind per-group typography to V3
                      groupTextStyles: _groupTextStyles,
                      // Bind theme-driven decoration to V3 card
                      cardDecoration: BoxDecoration(
                        color: _themeController?.resolveCardBackgroundColor() ??
                            Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(
                          _themeController?.resolveCardCornerRadius() ?? 12,
                        ),
                        boxShadow:
                            _themeController?.resolveCardBoxShadow(),
                        // Configurable card border from theme
                        border: Border.all(
                          color: _themeController?.resolveCardBorderColor() ??
                              Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.35),
                          width:
                              _themeController?.resolveCardBorderWidth() ?? 1,
                        ),
                      ),
                      // Bind pillar decoration (margin/border) for dynamic sizing and offsets
                      // Use THEME default margin as global fallback; per-column overrides come from payload.columnMargin
                      pillarMargin: _theme.pillar?.defaultMargin ??
                          const EdgeInsets.all(8),
                      pillarPadding: _themeController?.resolvePillarPadding() ??
                          const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                      pillarBorderWidth:
                          _themeController?.resolvePillarBorderWidth() ?? 2,
                      pillarBorderColor:
                          _themeController?.resolvePillarBorderColor() ??
                              Colors.red,
                      pillarCornerRadius:
                          _themeController?.resolvePillarCornerRadius() ?? 0,
                      pillarBackgroundColor:
                          _themeController?.resolvePillarBackgroundColor() ??
                              Colors.transparent,
                      pillarBoxShadow:
                          _themeController?.resolvePillarBoxShadow(),
                      // debugHysteresisOverlay: false,
                    ),
                  ],
                ),
                SizedBox(height: 18),
                ValueListenableBuilder<CardMode>(
                  valueListenable: _cardModeNotifier,
                  builder: (context, value, child) {
                    return Row(children: [
                      ElevatedButton(
                          onPressed: () {
                            _cardModeNotifier.value = CardMode.normal;
                          },
                          child: Text(
                            '普通模式',
                            style: TextStyle(
                                color: value == CardMode.normal
                                    ? Colors.red
                                    : Colors.black),
                          )),
                      ElevatedButton(
                          onPressed: () {
                            _cardModeNotifier.value = CardMode.column;
                          },
                          child: Text(
                            '列模式',
                            style: TextStyle(
                                color: value == CardMode.column
                                    ? Colors.red
                                    : Colors.black),
                          )),
                      ElevatedButton(
                          onPressed: () {
                            _cardModeNotifier.value = CardMode.row;
                          },
                          child: Text(
                            '行模式',
                            style: TextStyle(
                                color: value == CardMode.row
                                    ? Colors.red
                                    : Colors.black),
                          )),
                    ]);
                  },
                ),

                const SizedBox(height: 24),

                // 原始的 EditableFourZhuCard
                _buildCardSection(
                  title: '原始版本 (EditableFourZhuCard)',
                  subtitle: _isEditable ? '拖拽列标题或底部👆重排列' : null,
                  color: Colors.blue,
                  child: EditableFourZhuCard(
                    eightChars: _sample,
                    isEditable: _isEditable,
                    axis: Axis.horizontal,
                    pillarOrder: _controller.pillars.value,
                    rowConfigs: _controller.rows.value,
                    cardStyle: _cardStyle,
                    rowLabelResolver: _rowLabel,
                    pillarLabelResolver: _pillarLabel,
                    onPillarOrderChanged: _controller.setPillars,
                    onRowConfigsChanged: _controller.setRows,
                    onAddPillarRequested: () => _showAddMenu(context),
                    // NEW: 传入控制器的覆盖数据
                    columnOverrides: _controller.columnOverrides.value,
                    pillarLabelOverrides:
                        _controller.pillarLabelOverrides.value,
                    rowOverrides: _controller.rowOverrides.value,
                    rowLabelOverrides: _controller.rowLabelOverrides.value,
                    // 使内层Card无视觉效果，与外层Card一致
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    borderRadius: BorderRadius.zero,
                  ),
                  desiredWidth: _desiredColumnCardWidth,
                ),

                const SizedBox(height: 24),

                // 列拖拽卡片
                _buildCardSection(
                  title: '列拖拽卡片 (ColumnReorderableFourZhuCard)',
                  subtitle: _isEditable ? '拖拽列标题或底部👆重排列' : null,
                  color: Colors.green,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxW = constraints.maxWidth;
                      final targetW = (_desiredColumnCardWidth ?? maxW)
                          .clamp(0, maxW)
                          .toDouble();
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: targetW,
                          child: ColumnReorderableFourZhuCard(
                            eightChars: _sample,
                            isEditable: _isEditable,
                            pillarOrder: _controller.pillars.value,
                            rowConfigs: _controller.rows.value,
                            cardStyle: _useIndependentMapping
                                ? _cardStyle
                                : (_themeController
                                        ?.resolveCardStyle(_cardStyle) ??
                                    _cardStyle),
                            rowLabelResolver: _rowLabel,
                            pillarLabelResolver: _pillarLabel,
                            onPillarOrderChanged: _controller.setPillars,
                            // Shared overrides wiring
                            columnOverrides: _controller.columnOverrides.value,
                            pillarLabelOverrides:
                                _controller.pillarLabelOverrides.value,
                            onColumnOverridesChanged:
                                _controller.setColumnOverrides,
                            onPillarLabelOverridesChanged:
                                _controller.setPillarLabelOverrides,
                            // New: read shared row-level overrides and labels
                            rowOverrides: _controller.rowOverrides.value,
                            rowLabelOverrides:
                                _controller.rowLabelOverrides.value,
                            // 缩放柱宽至当前宽度的50%
                            pillarWidthScale: 0.5,
                            // 接入内容驱动的期望卡片宽度回调
                            onDesiredCardWidthChanged: (w) {
                              if (_desiredColumnCardWidth != w) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (!mounted) return;
                                  setState(() => _desiredColumnCardWidth = w);
                                });
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  desiredWidth: _desiredColumnCardWidth,
                ),

                const SizedBox(height: 24),

                // 行拖拽卡片
                _buildCardSection(
                  title: '行拖拽卡片 (RowReorderableFourZhuCard)',
                  subtitle: _isEditable ? '拖拽行右侧👆重排行' : null,
                  color: Colors.orange,
                  child: RowReorderableFourZhuCard(
                    eightChars: _sample,
                    isEditable: _isEditable,
                    pillarOrder: _controller.pillars.value,
                    rowConfigs: _controller.rows.value,
                    cardStyle: _useIndependentMapping
                        ? _cardStyle
                        : (_themeController?.resolveCardStyle(_cardStyle) ??
                            _cardStyle),
                    rowLabelResolver: _rowLabel,
                    pillarLabelResolver: _pillarLabel,
                    // Shared overrides wiring
                    rowOverrides: _controller.rowOverrides.value,
                    rowLabelOverrides: _controller.rowLabelOverrides.value,
                    onRowOverridesChanged: _controller.setRowOverrides,
                    onRowLabelOverridesChanged:
                        _controller.setRowLabelOverrides,
                    // New: read-only column-level overrides and pillar label overrides
                    columnOverrides: _controller.columnOverrides.value,
                    pillarLabelOverrides:
                        _controller.pillarLabelOverrides.value,
                    // 新增：将行配置更新回传到控制器，保持单一数据源
                    onRowConfigsChanged: _controller.setRows,
                  ),
                  desiredWidth: _desiredColumnCardWidth,
                ),

                const SizedBox(height: 24),

                // 说明卡片
                if (!_isEditable)
                  Card(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '使用说明',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '点击右上角的编辑按钮进入编辑模式，即可拖拽调整列或行的顺序。',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• 原始版本：使用 LongPressDraggable 实现拖拽',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '• 列拖拽卡片：使用 ReorderableListView 实现列拖拽',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '• 行拖拽卡片：使用 ReorderableListView 实现行拖拽',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    String? subtitle,
    required Color color,
    required Widget child,
    double? desiredWidth,
  }) {
    // 根据标题确定背景颜色
    Color cardBackgroundColor;
    if (title.contains('列拖拽')) {
      cardBackgroundColor = const Color(0xFFE3F2FD); // 淡蓝色 Material Blue 50
    } else if (title.contains('行拖拽')) {
      cardBackgroundColor = const Color(0xFFE8F5E9); // 淡绿色 Material Green 50
    } else {
      cardBackgroundColor = Colors.white;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题和提示 - 移到Card外部
        Row(
          children: [
            Icon(Icons.dashboard, size: 20, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (subtitle != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                      ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Card内容 - 使用 Align+SizedBox 保持按期望宽度收缩
        LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth;
            final targetW = (desiredWidth ?? maxW).clamp(0, maxW).toDouble();
            return Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: targetW,
                child: Card(
                  elevation: 2,
                  color: cardBackgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: child,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAddMenu(BuildContext context) async {
    final selected = await showMenu<PillarType>(
      context: context,
      position: const RelativeRect.fromLTRB(300, 300, 300, 300),
      items: const [
        PopupMenuItem(value: PillarType.year, child: Text('年柱')),
        PopupMenuItem(value: PillarType.month, child: Text('月柱')),
        PopupMenuItem(value: PillarType.day, child: Text('日柱')),
        PopupMenuItem(value: PillarType.hour, child: Text('时柱')),
        PopupMenuItem(value: PillarType.separator, child: Text('分隔符')),
      ],
    );
    if (selected != null) {
      _controller.setPillars(List.of(_controller.pillars.value)..add(selected));
    }
  }

  String _rowLabel(RowType type) {
    switch (type) {
      case RowType.heavenlyStem:
        return '天干';
      case RowType.earthlyBranch:
        return '地支';
      case RowType.tenGod:
        return '十神';
      case RowType.naYin:
        return '纳音';
      default:
        return '';
    }
  }

  String _pillarLabel(PillarType type) {
    switch (type) {
      case PillarType.year:
        return '年';
      case PillarType.month:
        return '月';
      case PillarType.day:
        return '日';
      case PillarType.hour:
        return '时';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _cardModeNotifier.dispose();
    _jiaZiNotifier.dispose();
    _rowListNotifier.dispose();
    _pillarsPayloadNotifier.dispose();
    _rowsPayloadNotifier.dispose();
    _paddingNotifier.dispose();
    super.dispose();
  }
}

/// _ThemePreview
/// Visualizes current theme effects without changing existing cards yet.
/// Shows card-level decoration, per-pillar margins, and per-character text style demo.
class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.controller});

  /// Theme controller that resolves effective values.
  final EditableFourZhuThemeController? controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final cardPadding = c?.resolveCardPadding() ?? const EdgeInsets.all(12);
    final cardMargin = c?.resolveCardMargin() ?? const EdgeInsets.all(0);
    final cardRadius = c?.resolveCardCornerRadius() ?? 8.0;
    final cardBg = c?.resolveCardBackgroundColor() ??
        Theme.of(context).colorScheme.surface;

    final pillarTypes = const [
      PillarType.year,
      PillarType.month,
      PillarType.day,
      PillarType.hour,
      PillarType.luckCycle,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '预览',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: cardMargin,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(cardRadius),
            child: Container(
              color: cardBg,
              padding: cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pillar margin visualization
                  Row(
                    children: [
                      for (final t in pillarTypes)
                        Container(
                          margin: c?.resolvePillarMargin(t) ?? EdgeInsets.zero,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: (c?.resolvePillarBorderColor() ??
                                      Theme.of(context).dividerColor)
                                  .withOpacity(0.6),
                              width: c?.resolvePillarBorderWidth() ?? 0,
                            ),
                            color:
                                c?.resolvePillarBackgroundColor() ??
                                    Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(_pillarLabel(t, context)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Per-character style demo
                  _PerCharacterDemo(controller: c),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _pillarLabel(PillarType type, BuildContext context) {
    switch (type) {
      case PillarType.year:
        return '年';
      case PillarType.month:
        return '月';
      case PillarType.day:
        return '日';
      case PillarType.hour:
        return '时';
      case PillarType.luckCycle:
        return '大运';
      case PillarType.separator:
        return '|';
      case PillarType.ke:
        return '克';
      case PillarType.taiMeta:
        return '太乙元';
      case PillarType.taiMonth:
        return '太乙月';
      case PillarType.taiDay:
        return '太乙日';
      case PillarType.lifeHouse:
        return '命宫';
      case PillarType.annual:
        return '流年';
      case PillarType.monthly:
        return '流月';
      case PillarType.daily:
        return '流日';
      case PillarType.hourly:
        return '流时';
      case PillarType.rowTitleColumn:
        return '行标题';
      default:
        return type.toString().split('.').last;
    }
  }
}

/// _PerCharacterDemo
/// Demonstrates independent TextStyle per character using RichText.
class _PerCharacterDemo extends StatelessWidget {
  const _PerCharacterDemo({required this.controller});

  final EditableFourZhuThemeController? controller;

  @override
  Widget build(BuildContext context) {
    final t = controller?.theme.typography;
    final baseFamily = t?.globalFontFamily;
    final size = t?.globalFontSize ?? 16;
    final color = t?.globalFontColor ?? Theme.of(context).colorScheme.onSurface;

    const sample = '甲子乙丑丙寅丁卯';
    final spans = <TextSpan>[];
    for (var i = 0; i < sample.length; i++) {
      final ch = sample[i];
      // Alternate styles: weight, color tint, italic
      final isEven = i % 2 == 0;
      final tinted = Color.alphaBlend(
        Theme.of(context).colorScheme.primary.withOpacity(0.15),
        color,
      );
      spans.add(
        TextSpan(
          text: ch,
          style: TextStyle(
            fontFamily: baseFamily,
            fontSize: size,
            color: isEven ? color : tinted,
            fontWeight: isEven ? FontWeight.w600 : FontWeight.w400,
            fontStyle: isEven ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '独立字符样式示例',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        RichText(text: TextSpan(children: spans)),
      ],
    );
  }
}
