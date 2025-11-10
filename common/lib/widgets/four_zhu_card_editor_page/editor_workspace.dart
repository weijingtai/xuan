import 'package:day_night_themed_switcher/day_night_themed_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../enums/enum_gender.dart';
import '../../enums/layout_template_enums.dart';
import '../../models/drag_payloads.dart';
import '../../models/eight_chars.dart';
import '../../models/layout_template.dart';
import '../../models/pillar_content.dart';
import '../../models/row_strategy.dart';
import '../../themes/editor_theme.dart';
import '../../viewmodels/four_zhu_editor_view_model.dart';
import '../editable_fourzhu_card.dart';
import '../editable_fourzhu_card/text_groups.dart';

class EditorWorkspace extends StatefulWidget {
  /// 组件内部展示的八字数据，用于填充四柱内容。
  /// 参数：
  /// - eightChars：四柱八字（年、月、日、时）数据。
  /// 返回值：无（Widget组件）。
  const EditorWorkspace({required this.eightChars});

  final EightChars eightChars;

  @override
  State<EditorWorkspace> createState() => EditorWorkspaceState();
}

class EditorWorkspaceState extends State<EditorWorkspace> {
  /// 本地主题开关：true 为 Dark，false 为 Light。
  bool _isDarkLocal = false;

  /// 亮度初始化标记：保证只在首轮依赖变更时读取外层主题亮度一次。
  bool _initializedBrightness = false;

  /// V3 卡片数据源：柱/行/内边距。
  late final ValueNotifier<List<PillarPayload>> _pillarsNotifier;
  late final ValueNotifier<List<RowInfoPayload>> _rowListNotifier;
  late final ValueNotifier<EdgeInsets> _paddingNotifier;

  /// V3 卡片分组样式：从 RowConfig 转换而来，用于覆盖全局样式。
  Map<TextGroup, TextStyle>? _groupTextStyles;

  /// 初始化卡片数据源（不访问 Theme）
  /// 参数：无
  /// 返回：无
  @override
  void initState() {
    super.initState();
    _pillarsNotifier =
        ValueNotifier<List<PillarPayload>>(_buildPillars(widget.eightChars));
    _rowListNotifier = ValueNotifier<List<RowInfoPayload>>(_buildDefaultRows());
    _paddingNotifier = ValueNotifier<EdgeInsets>(EdgeInsets.zero);
    // 注意：不要在 initState 中调用 Theme.of(context)
  }

  /// 在依赖可用后初始化一次本地主题开关
  /// 参数：无
  /// 返回：无
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedBrightness) {
      _isDarkLocal = Theme.of(context).brightness == Brightness.dark;
      _initializedBrightness = true;
    }
  }

  /// 响应外部八字数据变化，更新柱载荷
  /// 参数：oldWidget 旧组件实例
  /// 返回：无
  @override
  void didUpdateWidget(covariant EditorWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.eightChars != widget.eightChars) {
      _pillarsNotifier.value = _buildPillars(widget.eightChars);
    }
  }

  /// 释放 Notifier 资源
  /// 参数：无
  /// 返回：无
  @override
  void dispose() {
    _pillarsNotifier.dispose();
    _rowListNotifier.dispose();
    _paddingNotifier.dispose();
    super.dispose();
  }

  /// 构建工作区：顶部 DayNightSwitch 切换本地主题，内容区使用单视图重叠显示
  /// 参数：context 构建上下文
  /// 返回：组件树
  @override
  Widget build(BuildContext context) {
    final ThemeData localTheme =
        _isDarkLocal ? EditorTheme.darkTheme : EditorTheme.lightTheme;

    return Consumer<FourZhuEditorViewModel>(
      builder: (context, viewModel, _) {
        // 在构建时将 ViewModel 的行配置映射到工作区 Notifier
        _applyViewModelToNotifiers(viewModel);

        // 从 ViewModel 读取全局字体样式
        final cardStyle = viewModel.cardStyle;
        final String? globalFamily = cardStyle?.globalFontFamily;
        final double? globalSize = cardStyle?.globalFontSize;
        final Color? globalColor = _parseHexColor(cardStyle?.globalFontColorHex);
        // 从 ViewModel 读取分隔线颜色
        final Color? dividerColor = _parseHexColor(cardStyle?.dividerColorHex);
        final ThemeData workspaceTheme = dividerColor != null
            ? localTheme.copyWith(dividerColor: dividerColor)
            : localTheme;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.invert_colors),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '工作区主题（仅组件内生效）',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                DayNightSwitch(
                  initiallyDark: _isDarkLocal,
                  size: 24,
                  onChange: (dark) => setState(() => _isDarkLocal = dark),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Theme(
                data: workspaceTheme,
                child: Container(
                  child: Center(
                    child: EditableFourZhuCardV3(
                      pillarsNotifier: _pillarsNotifier,
                      rowListNotifier: _rowListNotifier,
                      paddingNotifier: _paddingNotifier,
                      gender: Gender.male,
                      // 绑定全局排版到 V3 卡片
                      globalFontFamily: (globalFamily != null && globalFamily.isNotEmpty)
                          ? globalFamily
                          : null,
                      globalFontSize: globalSize,
                      globalFontColor: globalColor,
                      // 绑定分组样式到 V3 卡片（从 RowConfig 转换而来，优先级高于全局样式）
                      groupTextStyles: _groupTextStyles,
                      // 🔧 修复：启用色彩模式，允许自定义颜色生效
                      colorfulMode: true,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 构建柱载荷：行标题列 + 年月日时四柱
  /// 参数：ec 八字数据
  /// 返回：柱载荷列表
  List<PillarPayload> _buildPillars(EightChars ec) {
    return [
      RowTitleColumnPayload(width: 52),
      PillarPayload(
        pillarType: PillarType.year,
        pillarContent: PillarContent(
          id: 'pillar-year',
          pillarType: PillarType.year,
          label: '年',
          jiaZi: ec.year,
          description: '年柱',
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
          jiaZi: ec.month,
          description: '月柱',
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
          jiaZi: ec.day,
          description: '日柱',
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
          jiaZi: ec.time,
          description: '时柱',
          version: '1',
          sourceKind: PillarSourceKind.userInput,
        ),
      ),
    ];
  }

  /// 构建默认行：表头、天干、地支、纳音、空亡
  /// 参数：无
  /// 返回：行载荷列表
  List<RowInfoPayload> _buildDefaultRows() {
    return [
      const RowInfoPayload(rowType: RowType.columnHeaderRow),
      const RowInfoPayload(rowType: RowType.heavenlyStem, rowLabel: '天干'),
      const RowInfoPayload(rowType: RowType.earthlyBranch, rowLabel: '地支'),
      const RowInfoPayload(rowType: RowType.naYin, rowLabel: '纳音'),
      RowInfoPayload.kongWang(label: '空亡', strategy: KongWangRowStrategy()),
    ];
  }

  /// 将 ViewModel 的行配置映射到工作区的行 Notifier。
  ///
  /// 参数：
  /// - [viewModel]：编辑页的 `FourZhuEditorViewModel`。
  ///
  /// 返回：无。副作用为更新 `_rowListNotifier.value`，始终在首位插入表头行。
  void _applyViewModelToNotifiers(FourZhuEditorViewModel viewModel) {
    final configs = viewModel.rowConfigs;
    if (configs.isEmpty) {
      // 若无配置，保持默认行。
      _rowListNotifier.value = _buildDefaultRows();
      _groupTextStyles = null;
      return;
    }

    // 构建 groupTextStyles 映射：从 RowConfig 转换到 TextGroup -> TextStyle
    final groupStyles = <TextGroup, TextStyle>{};
    for (final config in configs) {
      final textGroup = _rowTypeToTextGroup(config.type);
      if (textGroup != null) {
        groupStyles[textGroup] = TextStyle(
          fontFamily: config.fontFamily,
          fontSize: config.fontSize,
          color: _parseHexColor(config.textColorHex),
          fontWeight: _parseFontWeight(config.fontWeight),
          // 构建阴影
          shadows: _buildShadows(config),
        );
      }
    }
    _groupTextStyles = groupStyles.isNotEmpty ? groupStyles : null;

    final rows = <RowInfoPayload>[
      const RowInfoPayload(rowType: RowType.columnHeaderRow),
      // 逐项映射可见行；标题隐藏时将 `rowLabel` 置空。
      for (final c in configs)
        if (c.isVisible)
          RowInfoPayload(
            rowType: c.type,
            rowLabel: c.isTitleVisible ? _defaultRowLabel(c.type) : null,
            textAlign: c.textAlign,
          ),
    ];

    _rowListNotifier.value = rows;
  }

  /// 根据行类型返回默认标题文案。
  ///
  /// 参数：
  /// - [type]：行类型 `RowType`。
  /// 返回：默认标题字符串；若未知类型返回空字符串。
  String _defaultRowLabel(RowType type) {
    switch (type) {
      case RowType.heavenlyStem:
        return '天干';
      case RowType.earthlyBranch:
        return '地支';
      case RowType.tenGod:
        return '十神';
      case RowType.hiddenStems:
        return '藏干';
      case RowType.naYin:
        return '纳音';
      case RowType.kongWang:
        return '空亡';
      case RowType.columnHeaderRow:
        return '表头';
      case RowType.separator:
        return '';
      default:
        return '';
    }
  }

  /// 将 RowType 映射到 TextGroup（用于 groupTextStyles）
  ///
  /// 参数：
  /// - [type]：行类型
  /// 返回：对应的 TextGroup，若无映射则返回 null
  TextGroup? _rowTypeToTextGroup(RowType type) {
    switch (type) {
      case RowType.heavenlyStem:
        return TextGroup.tianGan;
      case RowType.earthlyBranch:
        return TextGroup.diZhi;
      case RowType.naYin:
        return TextGroup.naYin;
      case RowType.kongWang:
        return TextGroup.kongWang;
      case RowType.tenGod:
        return TextGroup.tenGod;
      case RowType.columnHeaderRow:
        return TextGroup.columnTitle;
      default:
        return null; // 其他行类型暂不映射
    }
  }

  /// 从字符串解析 FontWeight（如 'w400' -> FontWeight.w400）
  ///
  /// 参数：
  /// - [str]：字体粗细字符串（格式：'w300', 'w400', 'w700' 等）
  /// 返回：对应的 FontWeight，若解析失败返回 null
  FontWeight? _parseFontWeight(String? str) {
    if (str == null || str.isEmpty) return null;
    final valueStr = str.replaceFirst('w', '');
    final value = int.tryParse(valueStr);
    if (value == null) return null;

    switch (value) {
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      default:
        return FontWeight.w400; // 默认 normal
    }
  }

  /// 解析 `#AARRGGBB` 或 `#RRGGBB` 形式的十六进制颜色字符串为 `Color`。
  ///
  /// 参数：
  /// - [hex]：颜色字符串；为空或非法时返回 `null`。
  /// 返回：解析后的 `Color` 或 `null`。
  Color? _parseHexColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final normalized = hex.replaceAll('#', '');
    if (normalized.length == 8) {
      // AARRGGBB
      final value = int.tryParse(normalized, radix: 16);
      if (value == null) return null;
      return Color(value);
    }
    if (normalized.length == 6) {
      // RRGGBB -> 强制不透明
      final value = int.tryParse(normalized, radix: 16);
      if (value == null) return null;
      return Color(0xFF000000 | value);
    }
    return null;
  }

  /// 从 RowConfig 构建阴影列表
  ///
  /// 参数：
  /// - [config]：行配置对象，包含阴影相关字段
  /// 返回：阴影列表，若未配置阴影则返回 null
  List<Shadow>? _buildShadows(RowConfig config) {
    if (config.shadowColorHex == null) return null;
    final color = _parseHexColor(config.shadowColorHex);
    if (color == null) return null;

    return [
      Shadow(
        color: color,
        offset: Offset(
          config.shadowOffsetX ?? 0,
          config.shadowOffsetY ?? 1,
        ),
        blurRadius: config.shadowBlurRadius ?? 2,
      ),
    ];
  }
}
