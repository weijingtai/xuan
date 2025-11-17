import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import '../../enums/layout_template_enums.dart';
import '../../models/drag_payloads.dart';

/// CardLayoutModel
/// 负责卡片的基础布局度量与通知机制（padding、抓手有效尺寸、分隔线高度等）。
///
/// 功能描述：
/// - 提供行高度解析：RowType 为分割线时返回分隔线高度；否则按 payload 或默认高度解析。
/// - 提供抓手显示/隐藏下的有效宽度计算，分隔行隐藏抓手。
/// - 提供基础布局参数更新与版本号（ValueListenable）变更通知。
///
/// 参数说明：
/// - 构造函数各参数用于初始化布局度量的默认值。
///
/// 返回值说明：
/// - 各度量方法返回具体的像素值；通知相关方法无返回。
class CardLayoutModel {
  /// 创建布局模型，所有数值单位为像素且应为非负。
  CardLayoutModel({
    EdgeInsets? padding,
    double dividerHeight = 1.0,
    double gripVisibleWidth = 12.0,
    double gripHiddenWidth = 0.0,
    double pillarSpacing = 8.0,
    // 行分割线参数（padding + thickness）
    double rowDividerPaddingTop = 0.0,
    double rowDividerPaddingBottom = 0.0,
    double rowDividerThickness = 1.0,
    // 列分割线参数（padding + thickness）
    double colDividerPaddingLeft = 0.0,
    double colDividerPaddingRight = 0.0,
    double colDividerThickness = 1.0,
  })  : _padding = padding ?? EdgeInsets.zero,
        _dividerHeight = dividerHeight,
        _gripVisibleWidth = gripVisibleWidth,
        _gripHiddenWidth = gripHiddenWidth,
        _pillarSpacing = pillarSpacing,
        _rowDividerPaddingTop = rowDividerPaddingTop,
        _rowDividerPaddingBottom = rowDividerPaddingBottom,
        _rowDividerThickness = rowDividerThickness,
        _colDividerPaddingLeft = colDividerPaddingLeft,
        _colDividerPaddingRight = colDividerPaddingRight,
        _colDividerThickness = colDividerThickness;

  EdgeInsets _padding;
  double _dividerHeight;
  double _gripVisibleWidth;
  double _gripHiddenWidth;
  double _pillarSpacing;
  // 分割线参数
  double _rowDividerPaddingTop;
  double _rowDividerPaddingBottom;
  double _rowDividerThickness;
  double _colDividerPaddingLeft;
  double _colDividerPaddingRight;
  double _colDividerThickness;

  final ValueNotifier<int> _version = ValueNotifier<int>(0);

  /// 返回当前布局版本的可监听对象，用于外部联动刷新。
  ValueListenable<int> get version => _version;

  /// 获取卡片内边距。
  /// 返回：`EdgeInsets` 当前内边距。
  EdgeInsets get padding => _padding;

  /// 更新卡片内边距并发送版本变更通知。
  /// 参数：`newPadding` 新的边距值（应为非负）。
  /// 返回：`void`
  void updatePadding(EdgeInsets newPadding) {
    _padding = newPadding;
    _notifyChanged();
  }

  /// 获取分割线高度。
  /// 返回：`double` 分割线显示高度。
  double get dividerHeight => _dividerHeight;

  /// 更新分割线高度并通知。
  /// 参数：`height` 新的高度（非负）。
  /// 返回：`void`
  void updateDividerHeight(double height) {
    _dividerHeight = height;
    _notifyChanged();
  }

  /// 更新行分割线的 padding 与 thickness 参数并通知。
  /// 参数：
  /// - `paddingTop` 行分割线顶部内边距（非负）
  /// - `paddingBottom` 行分割线底部内边距（非负）
  /// - `thickness` 行分割线线宽（非负）
  /// 返回：`void`
  void updateRowDividerParams({
    required double paddingTop,
    required double paddingBottom,
    required double thickness,
  }) {
    _rowDividerPaddingTop = paddingTop;
    _rowDividerPaddingBottom = paddingBottom;
    _rowDividerThickness = thickness;
    _notifyChanged();
  }

  /// 更新列分割线的 padding 与 thickness 参数并通知。
  /// 参数：
  /// - `paddingLeft` 列分割线左侧内边距（非负）
  /// - `paddingRight` 列分割线右侧内边距（非负）
  /// - `thickness` 列分割线线宽（非负）
  /// 返回：`void`
  void updateColumnDividerParams({
    required double paddingLeft,
    required double paddingRight,
    required double thickness,
  }) {
    _colDividerPaddingLeft = paddingLeft;
    _colDividerPaddingRight = paddingRight;
    _colDividerThickness = thickness;
    _notifyChanged();
  }

  /// 行分割线的有效高度（padding + thickness）。
  /// 返回：`double` 有效高度像素值。
  double get rowDividerHeightEffective =>
      _rowDividerPaddingTop + _rowDividerPaddingBottom + _rowDividerThickness;

  /// 列分割线的有效宽度（padding + thickness）。
  /// 返回：`double` 有效宽度像素值。
  double get colDividerWidthEffective =>
      _colDividerPaddingLeft + _colDividerPaddingRight + _colDividerThickness;

  /// 解析行高度。
  /// 参数：
  /// - `rowType`: 行类型，分隔行返回分隔线高度。
  /// - `payload`: 行信息负载，可提供自定义高度解析。
  /// - `defaultCellHeight`: 默认单元格高度，用于一般行与缺省解析；同时作为表头/干支行的兜底值。
  /// 返回：`double` 该行的渲染高度。
  double resolveRowHeight(
    RowType rowType, {
    TextRowPayload? payload,
    double defaultCellHeight = 28.0,
  }) {
    if (rowType == RowType.separator) return _dividerHeight;
    if (payload != null) {
      return payload.resolveHeight(
        heavenlyAndEarthlyHeight: defaultCellHeight,
        otherHeight: defaultCellHeight,
        dividerHeight: _dividerHeight,
        headerHeight: defaultCellHeight,
      );
    }
    return defaultCellHeight;
  }

  /// 计算抓手的有效宽度（显示/隐藏）。
  /// 参数：`isVisible` 抓手是否显示。
  /// 返回：`double` 有效宽度。
  double effectiveGripWidth({required bool isVisible}) {
    return isVisible ? _gripVisibleWidth : _gripHiddenWidth;
  }

  /// 计算抓手的有效高度（显示/隐藏）。
  /// 说明：当前抓手的高度与宽度采用一致的可见/隐藏口径；如需将来区分，可引入独立参数。
  /// 参数：`isVisible` 抓手是否显示。
  /// 返回：`double` 有效高度。
  double effectiveGripHeight({required bool isVisible}) {
    return isVisible ? _gripVisibleWidth : _gripHiddenWidth;
  }

  /// 判断指定行类型是否显示抓手。
  /// 参数：
  /// - `rowType`: 行类型。
  /// - `showGripsConfig`: 配置层开关。
  /// 返回：`bool` 是否显示抓手（分隔行强制隐藏）。
  bool isGripVisibleForRow(RowType rowType, {required bool showGripsConfig}) {
    if (rowType == RowType.separator) return false;
    return showGripsConfig;
  }

  /// 获取柱间距（水平间距）。
  /// 返回：`double` 间距像素值。
  double get pillarSpacing => _pillarSpacing;

  /// 更新柱间距并通知。
  /// 参数：`spacing` 新的间距（非负）。
  /// 返回：`void`
  void updatePillarSpacing(double spacing) {
    _pillarSpacing = spacing;
    _notifyChanged();
  }

  /// 内部：递增版本号以通知外部刷新。
  void _notifyChanged() {
    _version.value = _version.value + 1;
  }
}
