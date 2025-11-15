import 'package:common/widgets/editable_fourzhu_card/models/base_style_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../enums/enum_gender.dart';
import '../../enums/layout_template_enums.dart';
import '../../models/drag_payloads.dart';
import '../../models/pillar_content.dart';
import '../../models/row_strategy.dart';
import '../../models/eight_chars.dart';
import '../../enums/enum_jia_zi.dart';
import '../../models/text_style_config.dart';
import '../../themes/editable_four_zhu_card_theme.dart';
import '../../viewmodels/editable_four_zhu_theme_controller.dart';
import '../../viewmodels/four_zhu_card_demo_viewmodel.dart';
import '../../viewmodels/four_zhu_editor_view_model.dart';
import '../editable_fourzhu_card.dart';
import '../editable_fourzhu_card/models/card_style_config.dart';
import '../editable_fourzhu_card/models/pillar_style_config.dart';
import '../editable_fourzhu_card/text_groups.dart';
import 'editable_four_zhu_style_editor_panel.dart';

/// ThemeEditPreviewSidebar
/// 侧边栏专用的“主题编辑与预览”组件：将 Demo 页的主题编辑能力进行压缩适配，
/// 在 320px 左侧栏内提供基本主题编辑与小型实时预览。
///
/// 职责：
/// - 提供 `EditableFourZhuStyleEditorPanel` 的精简承载
/// - 在面板下方渲染一个窄版 `EditableFourZhuCardV3` 预览
/// - 将排版相关的变更（全局字体家族、字号、颜色）同步写入编辑页 ViewModel
class ThemeEditPreviewSidebar extends StatefulWidget {
  /// 构造函数：可传入初始主题；若未提供则使用内建默认值。
  const ThemeEditPreviewSidebar({super.key, this.initialTheme});

  /// 初始主题对象（可选）。
  final EditableFourZhuCardTheme? initialTheme;

  @override
  State<ThemeEditPreviewSidebar> createState() =>
      _ThemeEditPreviewSidebarState();
}

class _ThemeEditPreviewSidebarState extends State<ThemeEditPreviewSidebar> {
  /// 当前主题与解析控制器。
  late EditableFourZhuCardTheme _theme;
  EditableFourZhuThemeController? _controller;

  /// 预览用的载荷 ValueNotifier（柱/行/内边距）。
  late final ValueNotifier<List<PillarPayload>> _pillarsNotifier;
  late final ValueNotifier<List<TextRowInfoPayload>> _rowListNotifier;
  late final ValueNotifier<EdgeInsets> _paddingNotifier;

  /// 是否启用 V3 彩色模式（与 Demo 一致）；侧栏默认关闭，保证对比度与信息清晰。
  bool _colorfulMode = false;

  /// 分组文本样式覆写（保留接口，未来可在侧栏扩展）。
  Map<TextGroup, TextStyle> _groupTextStyles = {};

  /// 初始化：设置默认主题、构建预览载荷。
  @override
  void initState() {
    super.initState();

    _controller = EditableFourZhuThemeController(
        Provider.of<FourZhuCardDemoViewModel>(context, listen: false).theme);

    final sample = EightChars(
      year: JiaZi.JIA_ZI,
      month: JiaZi.YI_CHOU,
      day: JiaZi.BING_YIN,
      time: JiaZi.DING_MAO,
    );

    _pillarsNotifier = ValueNotifier<List<PillarPayload>>([
      RowTitleColumnPayload(width: 48),
      PillarPayload(
        pillarType: PillarType.year,
        pillarContent: PillarContent(
          id: 'sidebar-year',
          pillarType: PillarType.year,
          label: '年',
          jiaZi: sample.year,
          description: '侧栏预览年柱',
          version: '1',
          sourceKind: PillarSourceKind.userInput,
        ),
      ),
      PillarPayload(
        pillarType: PillarType.month,
        pillarContent: PillarContent(
          id: 'sidebar-month',
          pillarType: PillarType.month,
          label: '月',
          jiaZi: sample.month,
          description: '侧栏预览月柱',
          version: '1',
          sourceKind: PillarSourceKind.userInput,
        ),
      ),
      PillarPayload(
        pillarType: PillarType.day,
        pillarContent: PillarContent(
          id: 'sidebar-day',
          pillarType: PillarType.day,
          label: '日',
          jiaZi: sample.day,
          description: '侧栏预览日柱',
          version: '1',
          sourceKind: PillarSourceKind.userInput,
        ),
      ),
      PillarPayload(
        pillarType: PillarType.hour,
        pillarContent: PillarContent(
          id: 'sidebar-hour',
          pillarType: PillarType.hour,
          label: '时',
          jiaZi: sample.time,
          description: '侧栏预览时柱',
          version: '1',
          sourceKind: PillarSourceKind.userInput,
        ),
      ),
    ]);

    _rowListNotifier = ValueNotifier<List<TextRowInfoPayload>>([
      TextRowInfoPayload(
          rowType: RowType.columnHeaderRow,
          config: TextStyleConfig.defaultConfig),
      TextRowInfoPayload(
          rowType: RowType.heavenlyStem,
          rowLabel: '天干',
          config: TextStyleConfig.defaultConfig),
      TextRowInfoPayload(
          rowType: RowType.earthlyBranch,
          rowLabel: '地支',
          config: TextStyleConfig.defaultConfig),
      TextRowInfoPayload(
          rowType: RowType.naYin,
          rowLabel: '纳音',
          config: TextStyleConfig.defaultConfig),
      TextRowInfoPayload(
          rowType: RowType.kongWang,
          rowLabel: '空亡',
          config: TextStyleConfig.defaultConfig),
      // RowInfoPayload.kongWang(label: '空亡', strategy: KongWangRowStrategy()),
    ]);

    _paddingNotifier = ValueNotifier<EdgeInsets>(EdgeInsets.zero);
  }

  /// 主题变更处理：更新本地主题与控制器，并同步到编辑页 ViewModel。
  ///
  /// 参数：next 新主题对象。
  /// 返回：无。
  void _onThemeChanged(EditableFourZhuCardTheme next) {
    setState(() {
      _theme = next;
      _controller = EditableFourZhuThemeController(_theme);
      // 侧栏预览的内边距取主题卡片 padding；若为空则为 12。
      _paddingNotifier.value =
          _controller?.resolveCardPadding() ?? const EdgeInsets.all(12);
    });

    // 同步“排版相关”到编辑页 ViewModel（全局字体家族、字号、颜色）。
    final vm = context.read<FourZhuEditorViewModel>();
    final tp = next.typography;
    if (tp != null) {
      final fam = tp.globalFontFamily ?? '';
      final size = tp.globalFontSize ?? 14;
      final colorHex = tp.globalFontColor?.value != null
          ? _intColorToHex(tp.globalFontColor!.value)
          : vm.cardStyle?.globalFontColorHex ?? '#FF000000';
      vm.updateGlobalFontFamily(fam);
      vm.updateGlobalFontSize(size);
      vm.updateGlobalFontColor(colorHex);
    }
  }

  /// 将整型颜色值转换为 `#AARRGGBB` 十六进制字符串。
  /// 参数：value 颜色整数值（AARRGGBB）。
  /// 返回：形如 `#FFFFFFFF` 的字符串表示。
  String _intColorToHex(int value) {
    return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  /// 构建组件树：上方为编辑面板，下方为小型预览卡片。
  /// 返回：Widget
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 标题与说明
        Text(
          '主题编辑与预览',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          '在侧栏中快速调整主题并预览效果',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 12),

        // 编辑面板：复用 Demo 的编辑器，但在侧栏使用紧凑布局容器。
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: theme.dividerColor.withValues(alpha: 0.12)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: EditableFourZhuStyleEditorPanel(
                // theme: _theme,
                // onChanged: _onThemeChanged,
                ),
          ),
        ),

        // 侧边栏不再渲染 V3 预览卡片，避免占用空间与产生溢出。
      ],
    );
  }
}
