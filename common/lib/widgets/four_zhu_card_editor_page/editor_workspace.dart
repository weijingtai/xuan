import 'package:common/enums/enum_gender.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../enums/layout_template_enums.dart';
import '../../models/drag_payloads.dart';
import '../../models/eight_chars.dart';
import '../../models/text_style_config.dart';
import '../../models/row_strategy.dart';
import '../../themes/editor_theme.dart';
import '../../viewmodels/four_zhu_editor_view_model.dart';
import '../../viewmodels/four_zhu_card_demo_viewmodel.dart';
import '../editable_fourzhu_card/editable_fourzhu_card_v4.dart';
import '../editable_fourzhu_card/text_groups.dart';

class EditorWorkspace extends StatefulWidget {
  /// 组件内部展示的八字数据，用于填充四柱内容。
  /// 参数：
  /// - eightChars：四柱八字（年、月、日、时）数据。
  /// 返回值：无（Widget组件）。
  const EditorWorkspace({super.key, required this.eightChars});

  final EightChars eightChars;

  @override
  State<EditorWorkspace> createState() => EditorWorkspaceState();
}

class EditorWorkspaceState extends State<EditorWorkspace> {
  /// 本地主题开关：true 为 Dark，false 为 Light。

  final ValueNotifier<ColorPreviewMode> _colorPreviewModeNotifier =
      ValueNotifier<ColorPreviewMode>(ColorPreviewMode.colorful);
  // bool _isDarkLocal = false;

  /// 启用色彩模式开关：true 为启用，false 为禁用。
  // bool _enableColorfulMode = false;

  final ValueNotifier<Brightness> _cardBrightnessNotifier =
      ValueNotifier<Brightness>(Brightness.light);

  /// V3 卡片数据源：柱/行/内边距。
  // late final ValueNotifier<List<PillarPayload>> _pillarsNotifier;
  late final ValueNotifier<List<TextRowPayload>> _rowListNotifier;
  late final ValueNotifier<EdgeInsets> _paddingNotifier;
  final ValueNotifier<bool> _showGripNotifier = ValueNotifier<bool>(true);
  // final ValueNotifier<bool> _showGripColumnsNotifier =
  // ValueNotifier<bool>(true);
  final TextEditingController _cardNameController = TextEditingController();
  final ValueNotifier<String> _cardNameNotifier = ValueNotifier<String>('');
  final ValueNotifier<ThemeMode> _themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  /// 初始化卡片数据源（不访问 Theme）
  /// 参数：无
  /// 返回：无
  @override
  void initState() {
    super.initState();
    _rowListNotifier = ValueNotifier<List<TextRowPayload>>([]);
    _paddingNotifier = ValueNotifier<EdgeInsets>(EdgeInsets.zero);
    // 注意：不要在 initState 中调用 Theme.of(context)
  }

  /// 在依赖可用后初始化一次本地主题开关
  /// 参数：无
  /// 返回：无
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cardBrightnessNotifier.value = Theme.of(context).brightness;
  }

  /// 响应外部八字数据变化，更新柱载荷
  /// 参数：oldWidget 旧组件实例
  /// 返回：无
  @override
  void didUpdateWidget(covariant EditorWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (oldWidget.eightChars != widget.eightChars) {
    //   _pillarsNotifier.value = _buildPillars(widget.eightChars);
    // }
  }

  /// 释放 Notifier 资源
  /// 参数：无
  /// 返回：无
  @override
  void dispose() {
    // 释放 Notifier 资源
    _colorPreviewModeNotifier.dispose();
    // _pillarsNotifier.dispose();
    _rowListNotifier.dispose();
    _paddingNotifier.dispose();
    _showGripNotifier.dispose();
    // _showGripColumnsNotifier.dispose();
    _cardNameController.dispose();
    _cardNameNotifier.dispose();
    _cardBrightnessNotifier.dispose();
    _themeModeNotifier.dispose();
    super.dispose();
  }

  /// 构建工作区：顶部 DayNightSwitch 切换本地主题，内容区使用单视图重叠显示
  /// 参数：context 构建上下文
  /// 返回：组件树
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ThemeData workspaceLocalTheme =
        _themeModeNotifier.value == ThemeMode.dark
            ? ThemeData.dark()
            : (_themeModeNotifier.value == ThemeMode.light
                ? ThemeData.light()
                : theme);

    return Consumer<FourZhuEditorViewModel>(
      builder: (context, viewModel, _) {
        // 在构建时将 ViewModel 的行配置映射到工作区 Notifier
        // _applyViewModelToNotifiers(viewModel);

        // 从 ViewModel 读取全局字体样式
        final cardStyle = viewModel.cardStyle;
        // 可选：读取分隔线颜色（系统主题管理下不在本地覆写 Theme）
        final Color? dividerColor = _parseHexColor(cardStyle?.dividerColorHex);

        return SizedBox.expand(
            child: Theme(
                data: workspaceLocalTheme,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  color: workspaceLocalTheme.colorScheme.surface,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 240,
                          alignment: Alignment.topCenter,
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.brightness_6),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '工作区明暗',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                  Switch(
                                    value: _themeModeNotifier.value ==
                                        ThemeMode.dark,
                                    onChanged: (v) => setState(() =>
                                        _themeModeNotifier.value = v
                                            ? ThemeMode.dark
                                            : ThemeMode.light),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                  // 替换第三方组件为本地 Switch，避免未定义引用导致编译失败
                                  Switch(
                                    value: _colorPreviewModeNotifier.value ==
                                        ColorPreviewMode.colorful,
                                    onChanged: (dark) => setState(() =>
                                        _colorPreviewModeNotifier.value = dark
                                            ? ColorPreviewMode.colorful
                                            : ColorPreviewMode.pure),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.drag_handle),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '显示抓手行列',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                  Switch(
                                    value: _showGripNotifier.value,
                                    onChanged: (v) => setState(
                                        () => _showGripNotifier.value = v),
                                    // onChanged: (v) => _showGripNotifier.value = v,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 48,
                              width: 200,
                              child: TextField(
                                controller: _cardNameController,
                                onChanged: (v) => _cardNameNotifier.value = v,
                                decoration: InputDecoration(
                                  labelText: '卡片名称',
                                  hintText: '请输入卡片名称',
                                  border: UnderlineInputBorder(),
                                  suffixIcon: Icon(
                                    Icons.edit,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            EditableFourZhuCardV3(
                              dayGanZhi: JiaZi.JIA_ZI,
                              brightnessNotifier: _cardBrightnessNotifier,
                              colorPreviewModeNotifier:
                                  _colorPreviewModeNotifier,
                              cardPayloadNotifier:
                                  Provider.of<FourZhuCardDemoViewModel>(context,
                                          listen: true)
                                      .cardPayloadNotifier,
                              showGrip: _showGripNotifier.value,
                              // showGripColumns: _showGripColumnsNotifier.value,
                              paddingNotifier: _paddingNotifier,
                              themeNotifier:
                                  Provider.of<FourZhuCardDemoViewModel>(context,
                                          listen: true)
                                      .themeNotifier,
                              gender: Gender.male,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )));
      },
    );
  }

  /// 构建柱载荷：行标题列 + 年月日时四柱
  /// 参数：ec 八字数据
  /// 返回：柱载荷列表

  /// 将 ViewModel 的行配置映射到工作区的行 Notifier。
  ///
  /// 参数：
  /// - [viewModel]：编辑页的 `FourZhuEditorViewModel`。
  ///
  /// 返回：无。副作用为更新 `_rowListNotifier.value`，始终在首位插入表头行。
  void applyViewModelToNotifiers(FourZhuEditorViewModel viewModel) {
    final configs = viewModel.rowConfigs;
    if (configs.isEmpty) {
      return;
    }

    for (final config in configs) {
      final textGroup = _rowTypeToTextGroup(config.type);
      if (textGroup != null) {
        // Logic for text groups if needed
      }
    }
    // _groupTextStyles = groupStyles.isNotEmpty ? groupStyles : null;

    final rows = <TextRowPayload>[
      TextRowPayload(
          rowType: RowType.columnHeaderRow, uuid: 'header', titleInCell: false),
      for (final c in configs)
        if (c.isVisible)
          TextRowPayload(
            rowType: c.type,
            uuid: c.type.name,
            titleInCell: false,
            rowLabel: c.isTitleVisible ? _defaultRowLabel(c.type) : null,
          ),
    ];

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
