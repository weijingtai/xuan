import 'package:flutter/material.dart';

import '../enums/enum_gender.dart';
import '../enums/layout_template_enums.dart';
import '../models/text_style_config.dart';
import '../widgets/editable_fourzhu_card.dart';
import '../widgets/four_zhu_add_palette.dart';
import '../widgets/test_pillar_draggable.dart';
// 已清理未使用的旧版卡片与测试组件导入：
// - EditableFourZhuCardV2.dart（旧版卡片实现）
// - editable_four_zhu_card.dart（旧接口，不再使用）
// - test_pillar_info_draggable.dart / test_row_info_draggable.dart / test_divider_row_draggable.dart（本页未用）
// - column_reorderable_four_zhu_card.dart / row_reorderable_four_zhu_card.dart（旧演示控件）
import '../viewmodels/four_zhu_card_demo_viewmodel.dart';
import '../widgets/style_editor/editable_four_zhu_style_editor_panel.dart';
import '../widgets/text_style/group_text_style_editor_panel.dart';

@Deprecated('Use  instead')
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
  // 使用集中式 ViewModel 管理页面状态与通知。
  late final FourZhuCardDemoViewModel _vm;

  final ValueNotifier<Brightness> _brightnessNotifier =
      ValueNotifier<Brightness>(Brightness.light);
  final ValueNotifier<ColorPreviewMode> _colorPreviewModeNotifier =
      ValueNotifier<ColorPreviewMode>(ColorPreviewMode.colorful);

  @override
  void initState() {
    super.initState();
    _vm = FourZhuCardDemoViewModel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 根据主题明暗生成每字颜色映射（仅在非彩色模式下生效）
    _vm.applyBrightness(Theme.of(context).brightness);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editable Four Zhu Card Demo'),
        actions: [
          IconButton(
            icon: Icon(_vm.isEditable ? Icons.done : Icons.edit_outlined),
            tooltip: _vm.isEditable ? '完成' : '编辑',
            onPressed: () => setState(() {
              _vm.setEditable(!_vm.isEditable);
            }),
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
                                  // theme: _vm.theme,
                                  // onChanged: (next) {
                                  //   setState(() {
                                  //     _vm.setTheme(next);
                                  //     // Apply card padding directly to V3 card
                                  //     final resolvedPadding = _vm.themeController
                                  //             ?.resolveCardPadding() ??
                                  //         const EdgeInsets.all(12);
                                  //     _vm.paddingNotifier.value = resolvedPadding;

                                  //     // Bind per-pillar margin to payloads so sliders only affect that pillar
                                  //     final current = _vm.pillarsNotifier.value;
                                  //     final mapped = current
                                  //         .map((p) => p.copyWith(
                                  //               columnMargin: _vm.themeController
                                  //                   ?.resolvePillarMargin(
                                  //                       p.pillarType),
                                  //             ))
                                  //         .toList();
                                  //     _vm.pillarsNotifier.value = mapped;
                                  //   });
                                  // },
                                  ),
                            );
                            // 仅保留编辑面板，移除“预览”及其下方预览卡片
                            return editor;
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
                const SizedBox(height: 24),
                // 渲染设置（参考编辑页的分区样式）
                _buildCardSection(
                  title: '渲染设置',
                  subtitle: _vm.isEditable ? '编辑模式' : null,
                  color: Colors.teal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 分组字体编辑面板：允许天干/地支/纳音/空亡/柱标题/行标题分别调整
                      GroupTextStyleEditorPanel(
                        initial: _vm.groupTextStyles,
                        isColorful: _vm.v3ColorfulMode,
                        onChanged: (m) {
                          setState(() {
                            _vm.setGroupTextStyles(m);
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      // 切换是否使用“独立映射渲染”模式
                      SwitchListTile(
                        title: const Text('使用独立映射渲染'),
                        subtitle: const Text('禁用全局字体，仅按分组/行样式渲染'),
                        value: _vm.useIndependentMapping,
                        onChanged: (v) => setState(() {
                          _vm.setUseIndependentMapping(v);
                        }),
                      ),
                      // V3 彩色模式
                      SwitchListTile(
                        title: const Text('V3 彩色默认模式（卡片级开关）'),
                        subtitle: const Text('天干/地支按字上色；支持明/暗两套调色盘'),
                        value: _vm.v3ColorfulMode,
                        onChanged: (v) => setState(() {
                          _vm.setV3ColorfulModeWithBrightness(
                            v,
                            Theme.of(context).brightness,
                          );
                        }),
                      ),
                      // 抓手显示开关（行与列）
                      SwitchListTile(
                        title: const Text('显示抓手（行与列）'),
                        subtitle: const Text('单个开关同时控制顶部/底部抓手行与左右抓手列'),
                        value: _vm.showGrips,
                        onChanged: (v) => setState(() {
                          _vm.setShowGrips(v);
                        }),
                      ),
                      // 调试：滞回可视化开关（显示中点与滞回边界）
                      SwitchListTile(
                        title: const Text('调试：显示滞回可视化叠加层'),
                        subtitle: const Text('显示列/行中点与滞回边界（用于拖拽判定调试）'),
                        value: _vm.debugHysteresisOverlay,
                        onChanged: (v) => setState(() {
                          _vm.setDebugHysteresisOverlay(v);
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                // 卡片示例（将 V3 卡片包裹在统一的 Section 卡片结构中）
                _buildCardSection(
                  title: '四柱卡片',
                  subtitle: _vm.isEditable ? '拖拽抓手重排' : null,
                  color: Colors.indigo,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 添加面板：提供四个可拖拽入口（大运柱、柱分隔符、空亡行、行分割符）
                      FourZhuAddPalette(),
                      const SizedBox(height: 12),
                      // EditableFourZhuCardV3(
                      //   brightnessNotifier: _brightnessNotifier,
                      //   colorPreviewModeNotifier: _colorPreviewModeNotifier,
                      //   pillarsNotifier: _vm.pillarsNotifier,
                      //   rowListNotifier: _vm.rowListNotifier,
                      //   paddingNotifier: _vm.paddingNotifier,
                      //   gender: Gender.male,
                      //   colorfulMode: _vm.v3ColorfulMode,
                      //   debugHysteresisOverlay: _vm.debugHysteresisOverlay,
                      //   showGripRows: _vm.showGrips,
                      //   showGripColumns: _vm.showGrips,
                      //   globalFontFamily: _vm.useIndependentMapping
                      //       ? null
                      //       : _vm.themeController?.theme.typography
                      //           ?.globalFontFamily,
                      //   globalFontSize: _vm.useIndependentMapping
                      //       ? null
                      //       : _vm.themeController?.theme.typography
                      //           ?.globalFontSize,
                      //   globalFontColor: _vm.useIndependentMapping
                      //       ? null
                      //       : _vm.themeController?.theme.typography
                      //           ?.globalFontColor,
                      //   // Bind per-group typography to V3
                      //   groupTextStyles: _vm.groupTextStyles,
                      //   // Bind theme-driven decoration to V3 card
                      //   cardDecoration: BoxDecoration(
                      //     color: _vm.themeController
                      //             ?.resolveCardBackgroundColor() ??
                      //         Theme.of(context).colorScheme.surface,
                      //     borderRadius: BorderRadius.circular(
                      //       _vm.themeController?.resolveCardCornerRadius() ??
                      //           12,
                      //     ),
                      //     boxShadow:
                      //         _vm.themeController?.resolveCardBoxShadow(),
                      //     border: Border.all(
                      //       color:
                      //           _vm.themeController?.resolveCardBorderColor() ??
                      //               Theme.of(context)
                      //                   .dividerColor
                      //                   .withOpacity(0.35),
                      //       width:
                      //           _vm.themeController?.resolveCardBorderWidth() ??
                      //               1,
                      //     ),
                      //   ),
                      //   // pillarSection: _vm.themeController?.resolveGlobalPillarStyle(),
                      //   // pillarSection:
                      //   //     _vm.themeController?.resolveGlobalPillarStyle(),
                      //   // debugHysteresisOverlay: false,
                      // ),
                    ],
                  ),
                ),
                // 已移除：模式切换按钮与以下所有演示内容
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

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }
}

// 已移除：内部预览组件与独立字符样式演示，避免重复渲染与体积膨胀。
