import 'package:flutter/material.dart';

import '../enums/layout_template_enums.dart';
import '../models/eight_chars.dart';
import '../enums/enum_jia_zi.dart';
import '../models/layout_template.dart';
import '../widgets/editable_four_zhu_card.dart';
import '../widgets/test_pillar_draggable.dart';
import '../widgets/column_reorderable_four_zhu_card.dart';
import '../widgets/row_reorderable_four_zhu_card.dart';

class EditableFourZhuCardDemoPage extends StatefulWidget {
  const EditableFourZhuCardDemoPage({super.key});

  @override
  State<EditableFourZhuCardDemoPage> createState() =>
      _EditableFourZhuCardDemoPageState();
}

class _EditableFourZhuCardDemoPageState
    extends State<EditableFourZhuCardDemoPage> {
  bool _isEditable = false;

  late EightChars _sample;
  late List<PillarType> _pillars;
  late List<RowConfig> _rows;
  late CardStyle _cardStyle;

  // 列拖拽卡片状态
  late List<PillarType> _columnPillars;
  late List<RowConfig> _columnRows;

  // 行拖拽卡片状态
  late List<PillarType> _rowPillars;
  late List<RowConfig> _rowRows;

  @override
  void initState() {
    super.initState();
    _sample = EightChars(
      year: JiaZi.JIA_ZI,
      month: JiaZi.YI_CHOU,
      day: JiaZi.BING_YIN,
      time: JiaZi.DING_MAO,
    );
    _pillars = const [
      PillarType.year,
      PillarType.month,
      PillarType.day,
      PillarType.hour
    ];
    _rows = const [
      RowConfig(
          type: RowType.heavenlyStem, isVisible: true, isTitleVisible: true),
      RowConfig(
          type: RowType.earthlyBranch, isVisible: true, isTitleVisible: true),
      RowConfig(type: RowType.naYin, isVisible: true, isTitleVisible: true),
    ];

    // 初始化列拖拽卡片状态
    _columnPillars = const [
      PillarType.year,
      PillarType.month,
      PillarType.day,
      PillarType.hour
    ];
    _columnRows = const [
      RowConfig(
          type: RowType.heavenlyStem, isVisible: true, isTitleVisible: true),
      RowConfig(
          type: RowType.earthlyBranch, isVisible: true, isTitleVisible: true),
      RowConfig(type: RowType.naYin, isVisible: true, isTitleVisible: true),
    ];

    // 初始化行拖拽卡片状态
    _rowPillars = const [
      PillarType.year,
      PillarType.month,
      PillarType.day,
      PillarType.hour
    ];
    _rowRows = const [
      RowConfig(
          type: RowType.heavenlyStem, isVisible: true, isTitleVisible: true),
      RowConfig(
          type: RowType.earthlyBranch, isVisible: true, isTitleVisible: true),
      RowConfig(type: RowType.naYin, isVisible: true, isTitleVisible: true),
    ];

    _cardStyle = const CardStyle(
      dividerType: BorderType.solid,
      dividerColorHex: '#FF334155',
      dividerThickness: 1,
      globalFontFamily: 'NotoSansSC-Regular',
      globalFontSize: 16,
      globalFontColorHex: '#FF0F172A',
    );
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    TestPillarDraggable(type: PillarType.year),
                    TestPillarDraggable(type: PillarType.month),
                    TestPillarDraggable(type: PillarType.day),
                    TestPillarDraggable(type: PillarType.hour),
                    TestPillarDraggable(type: PillarType.separator),
                  ],
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
                    pillarOrder: _pillars,
                    rowConfigs: _rows,
                    cardStyle: _cardStyle,
                    rowLabelResolver: _rowLabel,
                    pillarLabelResolver: _pillarLabel,
                    onPillarOrderChanged: (updated) =>
                        setState(() => _pillars = updated),
                    onAddPillarRequested: () => _showAddMenu(context),
                  ),
                ),

                const SizedBox(height: 24),

                // 列拖拽卡片
                _buildCardSection(
                  title: '列拖拽卡片 (ColumnReorderableFourZhuCard)',
                  subtitle: _isEditable ? '拖拽列标题或底部👆重排列' : null,
                  color: Colors.green,
                  child: ColumnReorderableFourZhuCard(
                    eightChars: _sample,
                    isEditable: _isEditable,
                    pillarOrder: _columnPillars,
                    rowConfigs: _columnRows,
                    cardStyle: _cardStyle,
                    rowLabelResolver: _rowLabel,
                    pillarLabelResolver: _pillarLabel,
                    onPillarOrderChanged: (updated) =>
                        setState(() => _columnPillars = updated),
                  ),
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
                    pillarOrder: _rowPillars,
                    rowConfigs: _rowRows,
                    cardStyle: _cardStyle,
                    rowLabelResolver: _rowLabel,
                    pillarLabelResolver: _pillarLabel,
                    onRowConfigsChanged: (updated) =>
                        setState(() => _rowRows = updated),
                  ),
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
        // Card内容 - 添加背景颜色
        Card(
          elevation: 2,
          color: cardBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
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
      setState(() => _pillars = List.of(_pillars)..add(selected));
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
}
