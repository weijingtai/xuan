import 'package:common/enums/enum_gender.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/widgets/editable_fourzhu_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../enums/layout_template_enums.dart';
import '../../models/eight_chars.dart';
import '../../models/text_style_config.dart';
import '../../viewmodels/four_zhu_editor_view_model.dart';

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
  bool _didInitWorkspaceBrightness = false;

  final ValueNotifier<bool> _showGripNotifier = ValueNotifier<bool>(true);
  // final ValueNotifier<bool> _showGripColumnsNotifier =
  // ValueNotifier<bool>(true);
  final TextEditingController _cardNameController = TextEditingController();
  final ValueNotifier<String> _cardNameNotifier = ValueNotifier<String>('');

  /// 初始化卡片数据源（不访问 Theme）
  /// 参数：无
  /// 返回：无
  @override
  void initState() {
    super.initState();
    // 注意：不要在 initState 中调用 Theme.of(context)
  }

  /// 在依赖可用后初始化一次本地主题开关
  /// 参数：无
  /// 返回：无
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitWorkspaceBrightness) return;
    _didInitWorkspaceBrightness = true;
    final brightness = Theme.of(context).brightness;
    final editorVm = context.read<FourZhuEditorViewModel>();
    editorVm.cardBrightnessNotifier.value = brightness;
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
    // _pillarsNotifier.dispose();
    _showGripNotifier.dispose();
    // _showGripColumnsNotifier.dispose();
    _cardNameController.dispose();
    _cardNameNotifier.dispose();
    super.dispose();
  }

  /// 构建工作区：顶部 DayNightSwitch 切换本地主题，内容区使用单视图重叠显示
  /// 参数：context 构建上下文
  /// 返回：组件树
  @override
  Widget build(BuildContext context) {
    return Consumer<FourZhuEditorViewModel>(
      builder: (context, viewModel, _) {
        return ValueListenableBuilder<Brightness>(
          valueListenable: viewModel.cardBrightnessNotifier,
          builder: (context, workspaceBrightness, _) {
            final workspaceLocalTheme = workspaceBrightness == Brightness.dark
                ? ThemeData.dark()
                : ThemeData.light();

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
                                      style: workspaceLocalTheme
                                          .textTheme.bodyMedium,
                                    ),
                                  ),
                                  Switch(
                                    value:
                                        workspaceBrightness == Brightness.dark,
                                    onChanged: (v) {
                                      viewModel.cardBrightnessNotifier.value = v
                                          ? Brightness.dark
                                          : Brightness.light;
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ValueListenableBuilder<ColorPreviewMode>(
                                valueListenable:
                                    viewModel.colorPreviewModeNotifier,
                                builder: (context, mode, _) {
                                  return Row(
                                    children: [
                                      const Icon(Icons.invert_colors),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '颜色预览模式',
                                          style: workspaceLocalTheme
                                              .textTheme.bodyMedium,
                                        ),
                                      ),
                                      ToggleButtons(
                                        isSelected: [
                                          mode == ColorPreviewMode.pure,
                                          mode == ColorPreviewMode.colorful,
                                          mode == ColorPreviewMode.blackwhite,
                                        ],
                                        onPressed: (index) {
                                          ColorPreviewMode next = mode;
                                          if (index == 0) {
                                            next = ColorPreviewMode.pure;
                                          } else if (index == 1) {
                                            next = ColorPreviewMode.colorful;
                                          } else if (index == 2) {
                                            next = ColorPreviewMode.blackwhite;
                                          }
                                          viewModel.colorPreviewModeNotifier
                                              .value = next;
                                        },
                                        constraints: const BoxConstraints(
                                          minHeight: 32,
                                          minWidth: 52,
                                        ),
                                        children: const [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text('纯色'),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text('色彩'),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text('黑白'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.drag_handle),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '显示抓手行列',
                                      style: workspaceLocalTheme
                                          .textTheme.bodyMedium,
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
                              brightnessNotifier:
                                  viewModel.cardBrightnessNotifier,
                              colorPreviewModeNotifier:
                                  viewModel.colorPreviewModeNotifier,
                              cardPayloadNotifier: viewModel.cardPayloadNotifier,
                              showGrip: _showGripNotifier.value,
                              // showGripColumns: _showGripColumnsNotifier.value,
                              paddingNotifier: viewModel.paddingNotifier,
                              themeNotifier: viewModel.editableThemeNotifier,
                              rowStrategyMapper: viewModel.rowStrategyMapper,
                              gender: Gender.male,
                              onReorderRow: viewModel.reorderRow,
                              onInsertRow: viewModel.insertRow,
                              onDeleteRow: viewModel.deleteRow,
                              onReorderPillar: viewModel.reorderPillarGlobal,
                              onInsertPillar: viewModel.insertPillarGlobal,
                              onDeletePillar: viewModel.deletePillarGlobal,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
