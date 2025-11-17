import 'package:day_night_themed_switcher/day_night_themed_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../enums/enum_gender.dart';
import '../../enums/enum_tian_gan.dart';
import '../../enums/enum_di_zhi.dart';
import '../../enums/layout_template_enums.dart';
import '../../models/drag_payloads.dart';
import '../../models/eight_chars.dart';
import '../../models/layout_template.dart';
import '../../models/text_style_config.dart';
import '../../models/pillar_content.dart';
import '../../models/row_strategy.dart';
import '../../themes/editable_four_zhu_card_theme.dart';
import '../../themes/editor_theme.dart';
import '../../viewmodels/four_zhu_editor_view_model.dart';
import '../../viewmodels/four_zhu_card_demo_viewmodel.dart';
import '../style_editor/four_zhu_pillar_style_editor.dart';
import '../../widgets/pillar_tag_bar.dart';
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

  final ValueNotifier<Brightness> _brightnessNotifier =
      ValueNotifier<Brightness>(Brightness.light);
  final ValueNotifier<ColorPreviewMode> _colorPreviewModeNotifier =
      ValueNotifier<ColorPreviewMode>(ColorPreviewMode.colorful);
  // bool _isDarkLocal = false;

  /// 启用色彩模式开关：true 为启用，false 为禁用。
  // bool _enableColorfulMode = false;

  /// 亮度初始化标记：保证只在首轮依赖变更时读取外层主题亮度一次。
  bool _initializedBrightness = false;

  /// V3 卡片数据源：柱/行/内边距。
  late final ValueNotifier<List<PillarPayload>> _pillarsNotifier;
  late final ValueNotifier<List<TextRowPayload>> _rowListNotifier;
  late final ValueNotifier<EdgeInsets> _paddingNotifier;
  final ValueNotifier<bool> _showGripRowsNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _showGripColumnsNotifier =
      ValueNotifier<bool>(true);

  /// V3 卡片分组样式：从 RowConfig 转换而来，用于覆盖全局样式。
  Map<TextGroup, TextStyle>? _groupTextStyles;

  /// 临时逐字颜色覆盖（不持久化）：用于实时预览用户在 Sidebar 中修改的单个字符颜色
  Map<TianGan, Color>? _perGanColorOverrides;
  Map<DiZhi, Color>? _perZhiColorOverrides;

  /// 初始化卡片数据源（不访问 Theme）
  /// 参数：无
  /// 返回：无
  @override
  void initState() {
    super.initState();
    _pillarsNotifier =
        ValueNotifier<List<PillarPayload>>(_buildPillars(widget.eightChars));
    _rowListNotifier = ValueNotifier<List<TextRowPayload>>(_buildDefaultRows());
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
      _brightnessNotifier.value = Theme.of(context).brightness;
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
    // 释放 Notifier 资源
    _brightnessNotifier.dispose();
    _colorPreviewModeNotifier.dispose();
    _pillarsNotifier.dispose();
    _rowListNotifier.dispose();
    _paddingNotifier.dispose();
    _showGripRowsNotifier.dispose();
    _showGripColumnsNotifier.dispose();
    super.dispose();
  }

  /// 构建工作区：顶部 DayNightSwitch 切换本地主题，内容区使用单视图重叠显示
  /// 参数：context 构建上下文
  /// 返回：组件树
  @override
  Widget build(BuildContext context) {
    final ThemeData localTheme = _brightnessNotifier.value == Brightness.dark
        ? EditorTheme.darkTheme
        : EditorTheme.lightTheme;

    return Consumer<FourZhuEditorViewModel>(
      builder: (context, viewModel, _) {
        // 在构建时将 ViewModel 的行配置映射到工作区 Notifier
        _applyViewModelToNotifiers(viewModel);

        // 从 ViewModel 读取全局字体样式
        final cardStyle = viewModel.cardStyle;
        final String? globalFamily = cardStyle?.globalFontFamily;
        final double? globalSize = cardStyle?.globalFontSize;
        final Color? globalColor =
            _parseHexColor(cardStyle?.globalFontColorHex);
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
                // 替换第三方组件为本地 Switch，避免未定义引用导致编译失败
                Switch(
                  value: _brightnessNotifier.value == Brightness.dark,
                  onChanged: (dark) => setState(() => _brightnessNotifier
                      .value = dark ? Brightness.dark : Brightness.light),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.invert_colors),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '启用色彩模式',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                // 替换第三方组件为本地 Switch，避免未定义引用导致编译失败
                Switch(
                  value: _colorPreviewModeNotifier.value ==
                      ColorPreviewMode.colorful,
                  onChanged: (dark) => setState(() => _colorPreviewModeNotifier
                          .value =
                      dark ? ColorPreviewMode.colorful : ColorPreviewMode.pure),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.view_day),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '显示上下抓手行',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Switch(
                  value: _showGripRowsNotifier.value,
                  onChanged: (v) =>
                      setState(() => _showGripRowsNotifier.value = v),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.view_column),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '显示左右抓手列',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Switch(
                  value: _showGripColumnsNotifier.value,
                  onChanged: (v) =>
                      setState(() => _showGripColumnsNotifier.value = v),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Theme(
                data: workspaceTheme,
                child: Container(
                  child: Center(
                    child: Selector<FourZhuCardDemoViewModel,
                        EditableFourZhuCardTheme>(
                      builder: (context, show, child) => EditableFourZhuCardV3(
                        brightnessNotifier: _brightnessNotifier,
                        colorPreviewModeNotifier: _colorPreviewModeNotifier,
                        pillarsNotifier: _pillarsNotifier,
                        rowListNotifier: _rowListNotifier,
                        paddingNotifier: _paddingNotifier,
                        gender: Gender.male,
                        showGripRows: _showGripRowsNotifier.value,
                        showGripColumns: _showGripColumnsNotifier.value,
                        pillarSection: show.pillar,
                        cellSection: show.cell,
                        typographySection: show.typography,
                        rowStrategyMapper: {
                          RowType.tenGod: TenGodRowStrategy(),
                          RowType.hiddenStemsTenGod:
                              HiddenStemsTenGodsRowStrategy(),
                          RowType.hiddenStems: HiddenStemsRowStrategy(),
                          RowType.kongWang: KongWangRowStrategy(),
                          RowType.naYin: NaYinRowStrategy(),
                          RowType.xunShou: XunShouRowStrategy(),
                        },

                        cardDecoration: BoxDecoration(
                          color: Provider.of<FourZhuCardDemoViewModel>(context,
                                      listen: true)
                                  .themeController
                                  ?.resolveCardBackgroundColor() ??
                              Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(
                            Provider.of<FourZhuCardDemoViewModel>(context,
                                        listen: false)
                                    .themeController
                                    ?.resolveCardCornerRadius() ??
                                12,
                          ),
                          boxShadow: Provider.of<FourZhuCardDemoViewModel>(
                                  context,
                                  listen: false)
                              .themeController
                              ?.resolveCardBoxShadow(),
                          border: Border.all(
                            color: Provider.of<FourZhuCardDemoViewModel>(
                                        context,
                                        listen: false)
                                    .themeController
                                    ?.resolveCardBorderColor() ??
                                Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.35),
                            width: Provider.of<FourZhuCardDemoViewModel>(
                                        context,
                                        listen: false)
                                    .themeController
                                    ?.resolveCardEffectiveBorderWidth() ??
                                1,
                          ),
                        ),
                        // 绑定全局排版到 V3 卡片
                        globalFontFamily:
                            (globalFamily != null && globalFamily.isNotEmpty)
                                ? globalFamily
                                : null,
                        globalFontSize: globalSize,
                        globalFontColor: globalColor,
                        // 绑定分组样式到 V3 卡片（从 RowConfig 转换而来，优先级高于全局样式）
                        // groupTextStyles: _groupTextStyles,
                        // 🔧 修复：启用色彩模式，允许字符映射生效
                        colorfulMode: true,
                      ),
                      selector: (_, vm) => vm.theme,
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
  List<TextRowPayload> _buildDefaultRows() {
    // var defaultTextStyleConfig =
    return [
      TextRowPayload(
        rowType: RowType.columnHeaderRow,
        config: TextStyleConfig.defaultConfig,
      ),
      TextRowPayload(
          rowType: RowType.xunShou,
          rowLabel: "旬首",
          config: TextStyleConfig.defaultConfig),
      TextRowPayload(
        rowType: RowType.heavenlyStem,
        rowLabel: '天干',
        config: TextStyleConfig.defaultConfig,
      ),
      TextRowPayload(
        rowType: RowType.earthlyBranch,
        rowLabel: '地支',
        config: TextStyleConfig.defaultConfig,
      ),
      TextRowPayload(
        rowType: RowType.naYin,
        rowLabel: '纳音',
        config: TextStyleConfig.defaultConfig,
      ),
      TextRowPayload(
        rowType: RowType.kongWang,
        rowLabel: '空亡',
        config: TextStyleConfig.defaultConfig,
      ),
      // RowInfoPayload.kongWang(
      //   label: '空亡',
      //   strategy: KongWangRowStrategy(),
      //   config: defaultTextStyleConfig,
      // ),
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
      _rowListNotifier.value = _buildDefaultRows();
      // _groupTextStyles = null;
      return;
    }

    // final groupStyles = <TextGroup, TextStyle>{};
    for (final config in configs) {
      final textGroup = _rowTypeToTextGroup(config.type);
      if (textGroup != null) {
        // final style = config.textStyleConfig?.toTextStyle() ??
        //     TextStyleConfig.fromLegacyRowConfig(
        //       shadowColorHex: config.shadowColorHex,
        //       shadowOffsetX: config.shadowOffsetX,
        //       shadowOffsetY: config.shadowOffsetY,
        //       shadowBlurRadius: config.shadowBlurRadius,
        //     ).toTextStyle();
        // groupStyles[textGroup] = style;
      }
    }
    // _groupTextStyles = groupStyles.isNotEmpty ? groupStyles : null;

    final rows = <TextRowPayload>[
      TextRowPayload(rowType: RowType.columnHeaderRow, config: null),
      for (final c in configs)
        if (c.isVisible)
          TextRowPayload(
            rowType: c.type,
            rowLabel: c.isTitleVisible ? _defaultRowLabel(c.type) : null,
            textAlign: c.textAlign,
            config: c.textStyleConfig,
            padding: c.paddingVertical,
            marginVertical: c.marginVertical,
            marginHorizontal: c.marginHorizontal,
            paddingHorizontal: c.paddingHorizontal,
          ),
    ];

    // 打印调试信息：确认 padding 是否传递
    for (final row in rows) {
      if (row.padding != null) {
        print(
            '🔍 [EditorWorkspace._applyViewModelToNotifiers] ${row.rowType.name} padding=${row.padding}');
      }
    }

    _rowListNotifier.value = rows;

    final insets = viewModel.cardStyle?.contentPadding;
    if (insets != null) {
      _paddingNotifier.value = insets;
    }
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
      case RowType.xunShou:
        return '旬首';
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
}
