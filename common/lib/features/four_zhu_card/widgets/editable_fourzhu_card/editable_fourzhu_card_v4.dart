import 'dart:async';
import 'package:flutter/material.dart';

import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/drag_payloads.dart';
import 'package:common/models/row_strategy.dart';
import 'package:common/models/text_style_config.dart';
import 'package:common/themes/editable_four_zhu_card_theme.dart';
import 'package:provider/provider.dart';
import '../../../../viewmodels/four_zhu_editor_view_model.dart';
import 'drag_controller.dart';
import 'internal/card_builders.dart';
import 'internal/card_drag_handler.dart';
import 'internal/card_size_manager.dart';

/// EditableFourZhuCardV4
///
/// V4 版本的四柱卡片,完全基于 size_calculator 系统重写。
///
/// 主要改进:
/// - 移除了旧的 CardLayoutModel/MeasurementContext 系统
/// - 统一使用 CardMetricsCalculator + CardMetricsSnapshot
/// - 代码拆分为多个职责明确的文件
/// - 主文件从 4,984 行减少到 ~300 行
///
/// 参数说明:
/// - [cardPayloadNotifier]: 卡片数据通知器
/// - [themeNotifier]: 主题配置通知器
/// - [rowStrategyMapper]: 行计算策略映射
/// - [brightnessNotifier]: 亮度模式通知器
/// - [colorPreviewModeNotifier]: 颜色预览模式通知器
/// - [paddingNotifier]: 内边距通知器
/// - [showGripRows]: 是否显示行拖拽手柄
/// - [showGripColumns]: 是否显示列拖拽手柄
@Deprecated('已废弃：请使用 EditableFourZhuCardV3')
class EditableFourZhuCardV4 extends StatefulWidget {
  final ValueNotifier<CardPayload> cardPayloadNotifier;
  final ValueNotifier<EditableFourZhuCardTheme> themeNotifier;
  final Map<RowType, RowComputationStrategy> rowStrategyMapper;
  final Map<PillarType, PillarComputationStrategy> pillarStrategyMapper;
  final ValueNotifier<Brightness> brightnessNotifier;
  final ValueNotifier<ColorPreviewMode> colorPreviewModeNotifier;
  final ValueNotifier<EdgeInsets> paddingNotifier;
  final bool showGripRows;
  final bool showGripColumns;

  const EditableFourZhuCardV4({
    super.key,
    required this.cardPayloadNotifier,
    required this.themeNotifier,
    required this.rowStrategyMapper,
    this.pillarStrategyMapper = const <PillarType, PillarComputationStrategy>{},
    required this.brightnessNotifier,
    required this.colorPreviewModeNotifier,
    required this.paddingNotifier,
    this.showGripRows = true,
    this.showGripColumns = true,
  });

  @override
  State<EditableFourZhuCardV4> createState() => _EditableFourZhuCardV4State();
}

class _EditableFourZhuCardV4State extends State<EditableFourZhuCardV4> {
  // 核心管理器
  late CardSizeManager _sizeManager;
  late CardDragHandler _dragHandler;

  // 全局 Key
  final GlobalKey _cardKey = GlobalKey();

  // 尺寸通知器
  late ValueNotifier<Size> _sizeNotifier;

  // 拖拽控制器
  late EditableCardDragController _dragController;

  // 批处理重建标记
  bool _rebuildScheduled = false;

  @override
  void initState() {
    super.initState();

    // 初始化拖拽控制器
    _dragController = EditableCardDragController(
      columnMoveCooldownMs: 12,
      rowMoveCooldownMs: 12,
    );

    // 初始化尺寸管理器
    _sizeManager = CardSizeManager(
      theme: widget.themeNotifier.value,
      payload: widget.cardPayloadNotifier.value,
      rowStrategyMapper: widget.rowStrategyMapper,
      pillarStrategyMapper: widget.pillarStrategyMapper,
      showGripRows: widget.showGripRows,
      showGripColumns: widget.showGripColumns,
      cardPadding: widget.paddingNotifier.value,
    );

    // 设置CardSizeManager到ViewModel，供边框编辑器清除缓存
    try {
      final viewModel = context.read<FourZhuEditorViewModel>();
      viewModel.cardSizeManager = _sizeManager;
    } catch (e) {
      // 忽略错误，可能在某些上下文中不可用
    }

    // 初始化拖拽处理器
    _dragHandler = CardDragHandler(
      onStateChanged: () => setState(() {}),
      sizeManager: _sizeManager,
      dragController: _dragController,
    );

    // 初始化尺寸通知器
    _sizeNotifier = ValueNotifier(_sizeManager.computeCardSize());

    // 监听数据变化
    widget.cardPayloadNotifier.addListener(_onPayloadChanged);
    widget.themeNotifier.addListener(_onThemeChanged);
    widget.paddingNotifier.addListener(_onPaddingChanged);
  }

  @override
  void dispose() {
    widget.cardPayloadNotifier.removeListener(_onPayloadChanged);
    widget.themeNotifier.removeListener(_onThemeChanged);
    widget.paddingNotifier.removeListener(_onPaddingChanged);
    _sizeNotifier.dispose();
    super.dispose();
  }

  void _onPayloadChanged() {
    _sizeManager.updatePayload(widget.cardPayloadNotifier.value);
    _sizeManager.cardPadding = widget.paddingNotifier.value;
    _sizeNotifier.value = _sizeManager.computeCardSize();
    _scheduleRebuild();
  }

  void _onThemeChanged() {
    _sizeManager.updateTheme(widget.themeNotifier.value);
    _sizeNotifier.value = _sizeManager.computeCardSize();
    _scheduleRebuild();
  }

  void _onPaddingChanged() {
    _sizeManager.cardPadding = widget.paddingNotifier.value;
    _sizeNotifier.value = _sizeManager.computeCardSize();
    _scheduleRebuild();
  }

  /// 批处理重建调度
  void _scheduleRebuild() {
    if (_rebuildScheduled) return;
    _rebuildScheduled = true;
    scheduleMicrotask(() {
      if (!mounted) return;
      setState(() {
        _rebuildScheduled = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Size>(
      valueListenable: _sizeNotifier,
      builder: (context, size, child) {
        return CardBuilders.buildCard(
          context: context,
          sizeManager: _sizeManager,
          dragHandler: _dragHandler,
          cardKey: _cardKey,
          size: size,
          theme: widget.themeNotifier.value,
          payload: widget.cardPayloadNotifier.value,
          brightness: widget.brightnessNotifier.value,
          colorPreviewMode: widget.colorPreviewModeNotifier.value,
          padding: widget.paddingNotifier.value,
          showGripRows: widget.showGripRows,
          showGripColumns: widget.showGripColumns,
        );
      },
    );
  }
}
